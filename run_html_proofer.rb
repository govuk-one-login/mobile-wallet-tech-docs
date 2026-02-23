require 'html-proofer'

class CustomReporter < HTMLProofer::Reporter
  attr_reader :failures
  
  def report
    if failures.empty?
      return "✅ No failures found!"
    end

    broken_links = []
    unknown_errors = []
    failures.flatten.each do |item|      
      if item.is_a?(HTMLProofer::Failure)
         output_report = {
          "File with broken link" => item.path, 
          "Link text" => item.content,
          "Link address" => item.element&.node&.[]('href') || "unknown"
        }
        if item.check_name == "Links > External"
          output_report["External link HTTP status code"] = item.status
        end
        broken_links << output_report
      else
        # Handle the 'type' fallback safely
        unknown_errors << item.to_s
      end
    end
    json_output = JSON.pretty_generate({"broken_links" => broken_links, "unknown_errors" => unknown_errors})
    puts "Found #{broken_links.length} broken link#{broken_links.length == 1 ? "": "s"}"
    puts json_output
  end

end

html_proofer = HTMLProofer.check_directory(
  "build",
  {
    typhoeus: {
      headers: { "User-Agent" => "Mozilla/5.0 (Android 14; Mobile; LG-M255; rv:122.0) Gecko/122.0 Firefox/122.0" },
    },
    :root_dir => "build",
    :checks=>['Links'],
    :allow_hash_href => true,
    :check_html => true,
    :raise_error => false,
    :assume_extension => true, # Important for Middleman's pretty URLs
    :directory_index_file => "index.html",
    :error_log => "proofer-errors.log",
    :ignore_status_codes=>[401,403, 0], # We often link out to the ISO spec so we want to check those links are still there (e.e not 404), but the fact we can't acess them is ok
    :ignore_files => [
      %r{^build/(javascripts|assets|images|stylesheets|search)/},
      %r{/__[^/]+$}
    ],
    :ignore_urls => [
      # Match the URL as it appears in the HTML (starting with /)
      %r{^/(javascripts|assets|images|stylesheets|search)/},
      # Also match them if they are relative links (no leading slash)
      %r{^(javascripts|assets|images|stylesheets|search)/}
    ]
  }
)
puts "------------------------------------------"
puts "Running html proofer checks for broken links:"
html_proofer.reporter = CustomReporter.new

html_proofer.run
