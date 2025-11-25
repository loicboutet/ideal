class Admin::LogsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin

  def index
    @environment = Rails.env
    @log_file_path = Rails.root.join('log', "#{@environment}.log")
    
    if File.exist?(@log_file_path)
      # Read the last 1000 lines from the log file
      @log_lines = read_last_n_lines(@log_file_path, 1000)
    else
      @log_lines = []
      flash.now[:alert] = "Log file not found: #{@log_file_path}"
    end
  end

  private

  def require_admin
    unless current_user&.admin?
      redirect_to root_path, alert: 'Access denied.'
    end
  end

  def read_last_n_lines(file_path, n)
    lines = []
    
    File.open(file_path, 'r:UTF-8', invalid: :replace, undef: :replace, replace: '') do |file|
      # Use tail-like approach: read file in chunks from the end
      file.seek(0, IO::SEEK_END)
      file_size = file.tell
      
      # If file is empty, return empty array
      return lines if file_size == 0
      
      # Start from the end and read backwards
      chunk_size = 8192
      position = file_size
      buffer = ""
      
      while lines.size < n && position > 0
        # Calculate how much to read
        read_size = [chunk_size, position].min
        position -= read_size
        
        # Read chunk
        file.seek(position)
        chunk = file.read(read_size)
        buffer = chunk + buffer
        
        # Split into lines
        temp_lines = buffer.split("\n")
        
        # If we're not at the beginning of the file, the first element might be incomplete
        if position > 0
          buffer = temp_lines.shift || ""
        else
          buffer = ""
        end
        
        # Add lines to our collection (in reverse order since we're reading backwards)
        temp_lines.reverse.each do |line|
          lines.unshift(line)
          break if lines.size >= n
        end
      end
    end
    
    # Return the last n lines (newest first), ensuring UTF-8 encoding
    lines.last(n).reverse.map { |line| line.force_encoding('UTF-8') }
  rescue => e
    Rails.logger.error "Error reading log file: #{e.message}"
    ["Error reading log file: #{e.message}"]
  end
end
