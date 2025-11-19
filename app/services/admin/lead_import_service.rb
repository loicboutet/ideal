class Admin::LeadImportService
  attr_reader :lead_import, :import_type, :errors

  def initialize(lead_import, file_path, import_type = 'buyers')
    @lead_import = lead_import
    @file_path = file_path
    @import_type = import_type
    @errors = []
    @successful_count = 0
    @failed_count = 0
  end

  def process
    lead_import.update(import_status: :processing)
    
    begin
      rows = parse_file
      lead_import.update(total_rows: rows.size)
      
      rows.each_with_index do |row, index|
        process_row(row, index + 2) # +2 for header and 0-index
      end
      
      finalize_import
    rescue => e
      handle_error(e)
      raise e
    end
  end

  private

  def parse_file
    if @file_path.end_with?('.csv')
      parse_csv
    else
      parse_excel
    end
  end

  def parse_csv
    require 'csv'
    rows = []
    CSV.foreach(@file_path, headers: true, encoding: 'UTF-8') do |row|
      rows << row.to_h
    end
    rows
  end

  def parse_excel
    require 'roo'
    xlsx = Roo::Spreadsheet.open(@file_path)
    sheet = xlsx.sheet(0)
    
    headers = sheet.row(1)
    (2..sheet.last_row).map do |row_num|
      Hash[headers.zip(sheet.row(row_num))]
    end
  end

  def process_row(row, row_number)
    if @import_type == 'buyers'
      import_buyer(row, row_number)
    else
      import_listing(row, row_number)
    end
  rescue => e
    record_error(row_number, e.message)
    @failed_count += 1
  end

  def import_buyer(row, row_number)
    # Validate required fields
    email = row['Email']&.to_s&.strip || row['Email*']&.to_s&.strip
    
    unless email.present? && valid_email?(email)
      raise "Email invalide ou manquant"
    end
    
    # Check for duplicate
    if User.exists?(email: email)
      raise "Email déjà existant"
    end
    
    # Create user
    user = User.new(
      email: email,
      first_name: row['Prénom']&.to_s,
      last_name: row['Nom']&.to_s,
      phone: row['Téléphone']&.to_s,
      company_name: row['Entreprise']&.to_s,
      role: :buyer,
      status: :active,
      password: SecureRandom.hex(16)
    )
    
    if user.save
      # Create buyer profile
      user.create_buyer_profile!(
        buyer_type: map_buyer_type(row['Type']),
        subscription_plan: map_subscription(row['Abonnement']),
        subscription_status: :active
      )
      
      @successful_count += 1
    else
      raise user.errors.full_messages.join(', ')
    end
  end

  def import_listing(row, row_number)
    # Future implementation for listing imports
    raise "Import de listings pas encore implémenté"
  end

  def finalize_import
    lead_import.update(
      import_status: :completed,
      successful_imports: @successful_count,
      failed_imports: @failed_count,
      error_log: @errors.to_json,
      completed_at: Time.current
    )
  end

  def handle_error(exception)
    lead_import.update(
      import_status: :failed,
      error_log: { global_error: exception.message }.to_json
    )
  end

  def record_error(row_number, message)
    @errors << {
      row: row_number,
      error: message
    }
  end

  def valid_email?(email)
    email.match?(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
  end

  def map_buyer_type(type)
    case type&.downcase&.strip
    when 'individuel', 'individual' then :individual
    when 'holding' then :holding
    when 'fonds', 'fund' then :fund
    when 'investisseur', 'investor' then :investor
    else :individual
    end
  end

  def map_subscription(plan)
    case plan&.downcase&.strip
    when 'starter' then :starter
    when 'standard' then :standard
    when 'premium' then :premium
    when 'club' then :club
    else :free
    end
  end
end
