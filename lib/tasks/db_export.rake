# frozen_string_literal: true

namespace :db do
  desc "Import database data from JSON files"
  task :import_all, [:import_dir] => :environment do |_t, args|
    puts "\n📥 Starting database import..."
    
    # Get import directory
    if args[:import_dir].blank?
      # Find the most recent export directory
      exports_dir = Rails.root.join('db', 'exports')
      export_dirs = Dir.glob(File.join(exports_dir, 'export_*')).sort.reverse
      
      if export_dirs.empty?
        puts "❌ No export directories found in #{exports_dir}"
        puts "   Please specify an import directory: rake db:import_all[path/to/export]"
        exit 1
      end
      
      import_dir = export_dirs.first
      puts "📁 Using most recent export: #{File.basename(import_dir)}"
    else
      import_dir = args[:import_dir]
    end
    
    unless Dir.exist?(import_dir)
      puts "❌ Import directory not found: #{import_dir}"
      exit 1
    end
    
    puts "📁 Import directory: #{import_dir}"
    
    # Load summary if available
    summary_file = File.join(import_dir, 'export_summary.json')
    if File.exist?(summary_file)
      summary = JSON.parse(File.read(summary_file))
      puts "\n📊 Export Info:"
      puts "   Exported: #{summary['timestamp']}"
      puts "   Database: #{summary['database']}"
      puts "   Tables: #{summary['tables_exported']}"
      puts "   Records: #{summary['total_records']}"
    end
    
    # Track import statistics
    import_stats = {
      started_at: Time.current,
      tables_imported: 0,
      total_records: 0,
      tables: {},
      errors: []
    }
    
    begin
      # Get all JSON files in the directory (except summary)
      json_files = Dir.glob(File.join(import_dir, '*.json'))
        .reject { |f| f.end_with?('export_summary.json') }
        .sort
      
      puts "\n🔍 Found #{json_files.length} data files to import\n"
      puts "⚠️  WARNING: This will replace existing data in the database!"
      puts "   Press Ctrl+C now to cancel, or press Enter to continue..."
      STDIN.gets unless ENV['SKIP_CONFIRMATION']
      
      # Disable foreign key constraints during import
      ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = OFF") if ActiveRecord::Base.connection.adapter_name == 'SQLite'
      
      ActiveRecord::Base.transaction do
        json_files.each do |json_file|
          table_name = File.basename(json_file, '.json')
          
          begin
            puts "  📥 Importing #{table_name}..."
            
            # Read JSON data
            data = JSON.parse(File.read(json_file))
            
            # Skip empty tables
            if data.empty?
              puts "     ⊘ Skipped (empty table)"
              import_stats[:tables][table_name] = { records: 0, status: 'skipped' }
              next
            end
            
            # Create dynamic model for this table
            model_class = Class.new(ActiveRecord::Base) do
              self.table_name = table_name
            end
            
            # Clear existing data
            model_class.delete_all
            
            # Import records
            imported_count = 0
            data.each do |record_attrs|
              model_class.create!(record_attrs)
              imported_count += 1
            end
            
            import_stats[:tables][table_name] = {
              records: imported_count,
              status: 'success'
            }
            import_stats[:tables_imported] += 1
            import_stats[:total_records] += imported_count
            
            puts "     ✓ #{imported_count} records imported"
            
          rescue => e
            puts "     ✗ Error importing #{table_name}: #{e.message}"
            import_stats[:tables][table_name] = {
              error: e.message,
              status: 'failed'
            }
            import_stats[:errors] << { table: table_name, error: e.message }
          end
        end
      end
      
      # Re-enable foreign key constraints
      ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = ON") if ActiveRecord::Base.connection.adapter_name == 'SQLite'
      
      # Generate import summary
      import_stats[:completed_at] = Time.current
      import_stats[:duration_seconds] = (import_stats[:completed_at] - import_stats[:started_at]).round(2)
      
      # Print summary
      puts "\n" + "="*60
      puts "📊 IMPORT SUMMARY"
      puts "="*60
      puts "✅ Import completed!"
      puts "🗂️  Tables imported: #{import_stats[:tables_imported]}"
      puts "📝 Total records: #{import_stats[:total_records]}"
      puts "⏱️  Duration: #{import_stats[:duration_seconds]} seconds"
      
      if import_stats[:errors].any?
        puts "\n⚠️  Errors encountered: #{import_stats[:errors].length}"
        import_stats[:errors].each do |error|
          puts "   - #{error[:table]}: #{error[:error]}"
        end
      end
      
      puts "="*60
      puts "\n✨ Import completed!\n"
      
    rescue => e
      # Re-enable foreign key constraints on error
      ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = ON") if ActiveRecord::Base.connection.adapter_name == 'SQLite'
      
      puts "\n❌ Import failed: #{e.message}"
      puts e.backtrace.first(5).join("\n")
      raise e
    end
  end

  desc "Export all database data to JSON files"
  task :export_all, [:output_dir] => :environment do |_t, args|
    puts "\n📦 Starting database export..."
    
    # Set output directory with timestamp
    timestamp = Time.current.strftime("%Y%m%d_%H%M%S")
    base_dir = args[:output_dir] || Rails.root.join('db', 'exports')
    export_dir = File.join(base_dir, "export_#{timestamp}")
    
    # Create export directory
    FileUtils.mkdir_p(export_dir)
    puts "📁 Export directory: #{export_dir}"
    
    # Get all models (tables) to export
    models_to_export = get_all_models
    
    # Track export statistics
    export_stats = {
      timestamp: timestamp,
      started_at: Time.current,
      tables_exported: 0,
      total_records: 0,
      tables: {}
    }
    
    begin
      puts "\n🔍 Found #{models_to_export.length} tables to export\n"
      
      # Export each model
      models_to_export.each do |model_class|
        table_name = model_class.table_name
        
        begin
          puts "  📊 Exporting #{table_name}..."
          
          # Get all records
          records = model_class.all
          record_count = records.count
          
          # Convert to hash (without timestamps for cleaner export if needed)
          data = records.map(&:attributes)
          
          # Write to JSON file
          file_path = File.join(export_dir, "#{table_name}.json")
          File.write(file_path, JSON.pretty_generate(data))
          
          # Update statistics
          export_stats[:tables][table_name] = {
            model: model_class.name,
            records: record_count,
            file: "#{table_name}.json",
            file_size: File.size(file_path)
          }
          export_stats[:tables_exported] += 1
          export_stats[:total_records] += record_count
          
          puts "     ✓ #{record_count} records exported (#{format_bytes(File.size(file_path))})"
          
        rescue => e
          puts "     ✗ Error exporting #{table_name}: #{e.message}"
          export_stats[:tables][table_name] = {
            error: e.message,
            records: 0
          }
        end
      end
      
      # Generate export summary
      export_stats[:completed_at] = Time.current
      export_stats[:duration_seconds] = (export_stats[:completed_at] - export_stats[:started_at]).round(2)
      export_stats[:database] = get_database_name
      export_stats[:rails_env] = Rails.env
      
      # Write summary file
      summary_path = File.join(export_dir, 'export_summary.json')
      File.write(summary_path, JSON.pretty_generate(export_stats))
      
      # Print summary
      puts "\n" + "="*60
      puts "📊 EXPORT SUMMARY"
      puts "="*60
      puts "✅ Export completed successfully!"
      puts "📁 Location: #{export_dir}"
      puts "🗂️  Tables exported: #{export_stats[:tables_exported]}"
      puts "📝 Total records: #{export_stats[:total_records]}"
      puts "⏱️  Duration: #{export_stats[:duration_seconds]} seconds"
      puts "💾 Database: #{export_stats[:database]}"
      puts "🌍 Environment: #{export_stats[:rails_env]}"
      
      # Calculate total size
      total_size = Dir.glob(File.join(export_dir, '*.json')).sum { |f| File.size(f) }
      puts "📦 Total size: #{format_bytes(total_size)}"
      puts "="*60
      
      # Show largest tables
      puts "\n📈 Top 10 Largest Tables:"
      export_stats[:tables]
        .reject { |_, v| v[:error] }
        .sort_by { |_, v| -v[:records] }
        .first(10)
        .each_with_index do |(table, stats), index|
          puts "   #{index + 1}. #{table.ljust(30)} #{stats[:records].to_s.rjust(8)} records  (#{format_bytes(stats[:file_size])})"
        end
      
      puts "\n💡 To import this data, you can use the exported JSON files"
      puts "💡 Summary file: #{summary_path}"
      puts "\n✨ Export completed successfully!\n"
      
    rescue => e
      puts "\n❌ Export failed: #{e.message}"
      puts e.backtrace.first(5).join("\n")
      raise e
    end
  end
  
  # Helper method to get all models
  def get_all_models
    # Get all table names from the database
    connection = ActiveRecord::Base.connection
    tables = connection.tables
    
    # Filter out schema/internal tables
    excluded_tables = ['schema_migrations', 'ar_internal_metadata']
    tables = tables.reject { |t| excluded_tables.include?(t) }
    
    # Create dynamic models for each table
    models = tables.map do |table_name|
      # Create a dynamic class for this table
      Class.new(ActiveRecord::Base) do
        self.table_name = table_name
        
        # Define a name method to return the table name
        def self.name
          table_name.classify
        end
      end
    end
    
    # Sort by table name for consistent ordering
    models.sort_by(&:table_name)
  end
  
  # Helper method to get database name
  def get_database_name
    connection = ActiveRecord::Base.connection
    config = ActiveRecord::Base.connection_db_config.configuration_hash
    
    # For SQLite, return the database file path
    if connection.adapter_name == 'SQLite'
      config[:database] || 'sqlite_database'
    else
      # For other databases (PostgreSQL, MySQL, etc.)
      connection.current_database rescue config[:database]
    end
  end
  
  # Helper method to format bytes
  def format_bytes(bytes)
    units = ['B', 'KB', 'MB', 'GB']
    return '0 B' if bytes == 0
    
    exp = (Math.log(bytes) / Math.log(1024)).to_i
    exp = [exp, units.length - 1].min
    
    format('%.2f %s', bytes.to_f / (1024 ** exp), units[exp])
  end
end
