module Admin::LogsHelper
  def format_log_line(line)
    # Color code based on log level
    case line
    when /ERROR|FATAL/
      "<span class='text-red-400'>#{ERB::Util.html_escape(line)}</span>".html_safe
    when /WARN/
      "<span class='text-yellow-400'>#{ERB::Util.html_escape(line)}</span>".html_safe
    when /INFO/
      "<span class='text-blue-400'>#{ERB::Util.html_escape(line)}</span>".html_safe
    when /DEBUG/
      "<span class='text-gray-400'>#{ERB::Util.html_escape(line)}</span>".html_safe
    else
      "<span class='text-gray-300'>#{ERB::Util.html_escape(line)}</span>".html_safe
    end
  end
end
