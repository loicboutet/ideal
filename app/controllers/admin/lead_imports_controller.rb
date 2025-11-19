class Admin::LeadImportsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin!
  before_action :set_lead_import, only: [:show, :download_errors]
  
  layout 'admin'

  def index
    @lead_imports = LeadImport.includes(:imported_by)
                               .order(created_at: :desc)
                               .page(params[:page])
                               .per(20)
  end

  def new
    @lead_import = LeadImport.new
  end

  def create
    unless params[:file].present?
      redirect_to new_admin_lead_import_path, alert: "Veuillez sélectionner un fichier"
      return
    end

    file = params[:file]
    
    # Validate file type
    unless valid_file_type?(file)
      redirect_to new_admin_lead_import_path, 
                  alert: "Type de fichier invalide. Utilisez .xlsx ou .csv"
      return
    end

    # Create import record
    @lead_import = LeadImport.new(
      imported_by: current_user,
      file_name: file.original_filename,
      total_rows: 0,
      import_status: :pending
    )

    if @lead_import.save
      # Process synchronously
      begin
        service = Admin::LeadImportService.new(
          @lead_import, 
          file.path, 
          params[:import_type] || 'buyers'
        )
        service.process
        
        redirect_to admin_lead_import_path(@lead_import),
                    notice: "Import terminé avec succès: #{@lead_import.successful_imports} entrées importées, #{@lead_import.failed_imports} échecs."
      rescue => e
        @lead_import.update(
          import_status: :failed,
          error_log: { global_error: e.message }.to_json
        )
        redirect_to admin_lead_import_path(@lead_import),
                    alert: "Erreur lors de l'import: #{e.message}"
      end
    else
      render :new
    end
  end

  def show
    @errors = parse_error_log(@lead_import.error_log) if @lead_import.error_log.present?
  end

  def download_errors
    return unless @lead_import.error_log.present?
    
    require 'csv'
    
    errors = parse_error_log(@lead_import.error_log)
    csv_data = CSV.generate(headers: true) do |csv|
      csv << ['Ligne', 'Erreur']
      errors.each do |error|
        csv << [error['row'], error['error']]
      end
    end
    
    send_data csv_data,
              filename: "erreurs_import_#{@lead_import.id}.csv",
              type: 'text/csv; charset=utf-8'
  end

  def template
    # Simple CSV template
    require 'csv'
    
    csv_data = CSV.generate(headers: true) do |csv|
      csv << [
        'Email*',
        'Prénom',
        'Nom',
        'Téléphone',
        'Entreprise',
        'Type',
        'Abonnement'
      ]
      csv << [
        'exemple@email.com',
        'Jean',
        'Dupont',
        '0612345678',
        'Dupont Holding',
        'Holding',
        'Standard'
      ]
    end
    
    send_data csv_data,
              filename: "template_import_repreneurs.csv",
              type: 'text/csv; charset=utf-8'
  end

  private

  def set_lead_import
    @lead_import = LeadImport.find(params[:id])
  end

  def valid_file_type?(file)
    %w[.xlsx .csv].include?(File.extname(file.original_filename).downcase)
  end

  def parse_error_log(error_log)
    JSON.parse(error_log)
  rescue JSON::ParserError
    []
  end

  def ensure_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: "Accès non autorisé"
    end
  end
end
