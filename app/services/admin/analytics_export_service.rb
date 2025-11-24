class Admin::AnalyticsExportService
  attr_reader :period, :start_date, :end_date, :scope

  def initialize(period:, start_date:, end_date:, scope: 'current')
    @period = period
    @start_date = start_date
    @end_date = end_date
    @scope = scope
    @analytics = Admin::DashboardAnalyticsService.new(
      period: period,
      start_date: start_date,
      end_date: end_date
    )
  end

  def to_csv
    require 'csv'
    
    CSV.generate(headers: true) do |csv|
      # Header
      csv << ["ANALYTIQUE - IDÉAL REPRISE"]
      csv << ["Période: #{start_date.strftime('%d/%m/%Y')} - #{end_date.strftime('%d/%m/%Y')}"]
      csv << []
      
      # Sector Analysis
      csv << ['ANALYSE PAR SECTEUR']
      csv << ['Secteur', 'Annonces', 'Réservations', 'Transactions', 'Taux conversion', 'Évolution']
      sector_data.each do |row|
        csv << [row[:sector], row[:listings], row[:reservations], row[:transactions], row[:conversion], row[:evolution]]
      end
      csv << []
      
      # Revenue Analysis
      csv << ['ANALYSE PAR CHIFFRE D\'AFFAIRES']
      csv << ['Tranche CA', 'Annonces', 'Réservations', 'Transactions', 'Évolution']
      revenue_data.each do |row|
        csv << [row[:range], row[:listings], row[:reservations], row[:transactions], row[:evolution]]
      end
      csv << []
      
      # Geography Analysis
      csv << ['ANALYSE PAR GÉOGRAPHIE']
      csv << ['Département', 'Annonces', 'Réservations', 'Transactions', 'Évolution']
      geography_data.each do |row|
        csv << [row[:department], row[:listings], row[:reservations], row[:transactions], row[:evolution]]
      end
      csv << []
      
      # Employee Count Analysis
      csv << ['ANALYSE PAR EFFECTIF']
      csv << ['Tranche effectif', 'Annonces', 'Réservations', 'Transactions', 'Évolution']
      employee_data.each do |row|
        csv << [row[:range], row[:listings], row[:reservations], row[:transactions], row[:evolution]]
      end
      csv << []
      
      # CRM Time Analysis
      csv << ['TEMPS MOYEN PAR STATUT CRM']
      csv << ['Statut', 'Temps moyen (jours)', 'Temps maximum (jours)']
      crm_time_stats.each do |stat|
        csv << [stat[:name], stat[:avg], stat[:max] || 'N/A']
      end
    end
  end

  def to_excel
    package = Axlsx::Package.new
    workbook = package.workbook

    # Styles
    header_style = workbook.styles.add_style(
      bg_color: '4F46E5',
      fg_color: 'FFFFFF',
      b: true,
      alignment: { horizontal: :center }
    )
    
    subheader_style = workbook.styles.add_style(
      bg_color: 'E0E7FF',
      b: true,
      alignment: { horizontal: :left }
    )

    title_style = workbook.styles.add_style(
      b: true,
      sz: 14
    )

    # Summary Sheet
    workbook.add_worksheet(name: 'Résumé') do |sheet|
      sheet.add_row ['ANALYTIQUE - IDÉAL REPRISE'], style: title_style
      sheet.add_row ["Période: #{start_date.strftime('%d/%m/%Y')} - #{end_date.strftime('%d/%m/%Y')}"]
      sheet.add_row []
      
      sheet.add_row ['Type d\'analyse', 'Nombre de lignes'], style: header_style
      sheet.add_row ['Secteur', sector_data.count]
      sheet.add_row ['Chiffre d\'affaires', revenue_data.count]
      sheet.add_row ['Géographie', geography_data.count]
      sheet.add_row ['Effectif', employee_data.count]
      sheet.add_row ['Temps CRM', crm_time_stats.count]
    end

    # Sector Analysis Sheet
    workbook.add_worksheet(name: 'Par Secteur') do |sheet|
      sheet.add_row ['Secteur', 'Annonces', 'Réservations', 'Transactions', 'Taux conversion', 'Évolution'], style: header_style
      sector_data.each do |row|
        sheet.add_row [row[:sector], row[:listings], row[:reservations], row[:transactions], row[:conversion], row[:evolution]]
      end
    end

    # Revenue Analysis Sheet
    workbook.add_worksheet(name: 'Par CA') do |sheet|
      sheet.add_row ['Tranche CA', 'Annonces', 'Réservations', 'Transactions', 'Évolution'], style: header_style
      revenue_data.each do |row|
        sheet.add_row [row[:range], row[:listings], row[:reservations], row[:transactions], row[:evolution]]
      end
    end

    # Geography Analysis Sheet
    workbook.add_worksheet(name: 'Par Géographie') do |sheet|
      sheet.add_row ['Département', 'Annonces', 'Réservations', 'Transactions', 'Évolution'], style: header_style
      geography_data.each do |row|
        sheet.add_row [row[:department], row[:listings], row[:reservations], row[:transactions], row[:evolution]]
      end
    end

    # Employee Count Analysis Sheet
    workbook.add_worksheet(name: 'Par Effectif') do |sheet|
      sheet.add_row ['Tranche effectif', 'Annonces', 'Réservations', 'Transactions', 'Évolution'], style: header_style
      employee_data.each do |row|
        sheet.add_row [row[:range], row[:listings], row[:reservations], row[:transactions], row[:evolution]]
      end
    end

    # CRM Time Analysis Sheet
    workbook.add_worksheet(name: 'Temps CRM') do |sheet|
      sheet.add_row ['Statut', 'Temps moyen (jours)', 'Temps maximum (jours)'], style: header_style
      crm_time_stats.each do |stat|
        sheet.add_row [stat[:name], stat[:avg], stat[:max] || 'N/A']
      end
    end

    package.to_stream.read
  end

  def to_pdf
    Prawn::Document.new(page_size: 'A4', page_layout: :landscape) do |pdf|
      # Title
      pdf.text "ANALYTIQUE - IDÉAL REPRISE", size: 18, style: :bold, align: :center
      pdf.text "Période: #{start_date.strftime('%d/%m/%Y')} - #{end_date.strftime('%d/%m/%Y')}", 
               size: 12, align: :center
      pdf.move_down 20

      # Sector Analysis
      pdf.text "Analyse par Secteur", size: 14, style: :bold
      pdf.move_down 10
      
      sector_table_data = [['Secteur', 'Annonces', 'Réservations', 'Transactions', 'Taux conv.', 'Évolution']]
      sector_data.each do |row|
        sector_table_data << [row[:sector], row[:listings], row[:reservations], row[:transactions], row[:conversion], row[:evolution]]
      end
      
      pdf.table(sector_table_data, header: true, width: pdf.bounds.width) do
        row(0).font_style = :bold
        row(0).background_color = '4F46E5'
        row(0).text_color = 'FFFFFF'
        self.row_colors = ['FFFFFF', 'F3F4F6']
        self.header = true
      end
      
      pdf.move_down 20

      # Revenue Analysis
      pdf.text "Analyse par Chiffre d'affaires", size: 14, style: :bold
      pdf.move_down 10
      
      revenue_table_data = [['Tranche CA', 'Annonces', 'Réservations', 'Transactions', 'Évolution']]
      revenue_data.each do |row|
        revenue_table_data << [row[:range], row[:listings], row[:reservations], row[:transactions], row[:evolution]]
      end
      
      pdf.table(revenue_table_data, header: true, width: pdf.bounds.width) do
        row(0).font_style = :bold
        row(0).background_color = '4F46E5'
        row(0).text_color = 'FFFFFF'
        self.row_colors = ['FFFFFF', 'F3F4F6']
        self.header = true
      end

      pdf.start_new_page

      # Geography Analysis
      pdf.text "Analyse par Géographie", size: 14, style: :bold
      pdf.move_down 10
      
      geography_table_data = [['Département', 'Annonces', 'Réservations', 'Transactions', 'Évolution']]
      geography_data.each do |row|
        geography_table_data << [row[:department], row[:listings], row[:reservations], row[:transactions], row[:evolution]]
      end
      
      pdf.table(geography_table_data, header: true, width: pdf.bounds.width) do
        row(0).font_style = :bold
        row(0).background_color = '4F46E5'
        row(0).text_color = 'FFFFFF'
        self.row_colors = ['FFFFFF', 'F3F4F6']
        self.header = true
      end
      
      pdf.move_down 20

      # Employee Count Analysis
      pdf.text "Analyse par Effectif", size: 14, style: :bold
      pdf.move_down 10
      
      employee_table_data = [['Tranche effectif', 'Annonces', 'Réservations', 'Transactions', 'Évolution']]
      employee_data.each do |row|
        employee_table_data << [row[:range], row[:listings], row[:reservations], row[:transactions], row[:evolution]]
      end
      
      pdf.table(employee_table_data, header: true, width: pdf.bounds.width) do
        row(0).font_style = :bold
        row(0).background_color = '4F46E5'
        row(0).text_color = 'FFFFFF'
        self.row_colors = ['FFFFFF', 'F3F4F6']
        self.header = true
      end

      pdf.start_new_page

      # CRM Time Analysis
      pdf.text "Temps moyen par Statut CRM", size: 14, style: :bold
      pdf.move_down 10
      
      crm_table_data = [['Statut', 'Temps moyen (jours)', 'Temps maximum (jours)']]
      crm_time_stats.each do |stat|
        crm_table_data << [stat[:name], stat[:avg], stat[:max] || 'N/A']
      end
      
      pdf.table(crm_table_data, header: true, width: pdf.bounds.width) do
        row(0).font_style = :bold
        row(0).background_color = '4F46E5'
        row(0).text_color = 'FFFFFF'
        self.row_colors = ['FFFFFF', 'F3F4F6']
        self.header = true
      end

      # Footer
      pdf.number_pages "Page <page> sur <total>", 
                       at: [pdf.bounds.right - 150, 0],
                       width: 150,
                       align: :right
    end.render
  end

  private

  def sector_data
    @sector_data ||= @analytics.listings_by_sector_with_evolution
  end

  def revenue_data
    @revenue_data ||= @analytics.listings_by_revenue_range
  end

  def geography_data
    @geography_data ||= @analytics.listings_by_geography
  end

  def employee_data
    @employee_data ||= @analytics.listings_by_employee_count
  end

  def crm_time_stats
    @crm_time_stats ||= @analytics.average_time_by_crm_status
  end
end
