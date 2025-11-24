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
      flash[:alert] = "Veuillez sélectionner un fichier"
      redirect_to new_admin_lead_import_path
      return
    end

    file = params[:file]
    
    # Validate file type
    unless valid_file_type?(file)
      flash[:alert] = "Type de fichier invalide. Utilisez .xlsx ou .csv"
      redirect_to new_admin_lead_import_path
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
        
        if @lead_import.successful_imports > 0
          flash[:notice] = "✅ Import terminé avec succès! #{@lead_import.successful_imports} entrée(s) importée(s)"
          flash[:alert] = "⚠️ #{@lead_import.failed_imports} échec(s)" if @lead_import.failed_imports > 0
        else
          flash[:alert] = "❌ Aucune entrée n'a pu être importée. #{@lead_import.failed_imports} échec(s)."
        end
        
        redirect_to admin_lead_imports_path
      rescue => e
        Rails.logger.error "Import error: #{e.message}\n#{e.backtrace.join("\n")}"
        @lead_import.update(
          import_status: :failed,
          error_log: { global_error: e.message, backtrace: e.backtrace.first(5) }.to_json
        )
        flash[:alert] = "❌ Erreur lors de l'import: #{e.message}"
        redirect_to admin_lead_imports_path
      end
    else
      flash[:alert] = "Erreur lors de la création de l'import: #{@lead_import.errors.full_messages.join(', ')}"
      redirect_to new_admin_lead_import_path
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

  def simple_template
    # Simple CSV template with basic fields only
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
      csv << [
        'marie.martin@example.com',
        'Marie',
        'Martin',
        '0687654321',
        '',
        'Individual',
        'Free'
      ]
    end
    
    send_data csv_data,
              filename: "template_simple_import_repreneurs.csv",
              type: 'text/csv; charset=utf-8'
  end

  def complete_template
    # Complete CSV template with all available fields
    require 'csv'
    
    csv_data = CSV.generate(headers: true) do |csv|
      # Headers
      csv << [
        'Email*',
        'Prénom',
        'Nom',
        'Téléphone',
        'Entreprise',
        'Type',
        'Abonnement',
        'Formation',
        'Experience',
        'Compétences',
        'Thèse d\'investissement',
        'Secteurs cibles',
        'Localisations cibles',
        'CA minimum',
        'CA maximum',
        'Employés minimum',
        'Employés maximum',
        'Santé financière cible',
        'Horizon de transfert',
        'Capacité d\'investissement',
        'Sources de financement'
      ]
      
      # Example 1: Complete profile
      csv << [
        'jean.dupont@example.com',
        'Jean',
        'Dupont',
        '0612345678',
        'Dupont Holding',
        'Holding',
        'Premium',
        'MBA HEC Paris, Formation reprise entreprise',
        '15 ans direction commerciale PME, 5 ans directeur général',
        'Management, Commercial, Stratégie',
        'Acquérir PME industrielles rentables en vue consolidation holding familiale',
        'Industry,Construction,Services',
        'Île-de-France,Hauts-de-France',
        '1000000',
        '5000000',
        '10',
        '50',
        'in_bonis',
        '3-6 mois',
        '2000000',
        'Apport personnel 40%, Prêt bancaire 50%, Crédit vendeur 10%'
      ]
      
      # Example 2: Simpler profile
      csv << [
        'marie.martin@example.com',
        'Marie',
        'Martin',
        '0687654321',
        '',
        'Individual',
        'Starter',
        'BTS Commerce',
        '10 ans gérante magasin de détail',
        'Vente, Gestion',
        'Reprendre commerce de proximité pour développer service client',
        'Commerce,Hospitality',
        'Provence-Alpes-Côte d\'Azur',
        '300000',
        '800000',
        '3',
        '15',
        'both',
        '6-12 mois',
        '150000',
        'Apport personnel, Prêt bancaire'
      ]
      
      # Example 3: Minimal required fields only
      csv << [
        'pierre.bernard@example.com',
        'Pierre',
        'Bernard',
        '0698765432',
        'Bernard Investissements',
        'Fund',
        'Club',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        ''
      ]
    end
    
    send_data csv_data,
              filename: "template_complet_import_repreneurs.csv",
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
