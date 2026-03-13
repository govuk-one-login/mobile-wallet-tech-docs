task :clean_middleman_build, [:update_ruby_gems] do | task, options |
    options.with_defaults(update_ruby_gems: false)

    puts "Checking for an existing build directory"
    if Dir.exist?("build")
        puts "Build directory found.  Removing old build"
        FileUtils.rm_rf("build")
    end
    if options[:update_ruby_gems]
        Rake::Task[:install_gems].invoke
    end
    Rake::Task[:build_middleman].invoke
end

task :install_gems do
    puts "Removing Gemfile.lock"
    FileUtils.rm_rf("Gemfile.lock")
    puts "Reinstalling gems"
    sh "bundle install"
end

task :build_middleman do
     puts "Creating a new middleman build"
     bundle exec "middleman build"
end

task :run_html_proofer do
    if !Dir.exist?("build")
        puts "No build directory found."
    else
        puts "Running the html proofer"
        bundle exec "ruby run_html_proofer.rb"
    end
end