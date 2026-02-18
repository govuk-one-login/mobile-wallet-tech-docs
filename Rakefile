task :clean_middleman_build do

    puts "Checking for an existing build directory"
    if Dir.exist?("build")
        puts "Build directory found.  Removing old build"
        FileUtils.rm_rf("build")
    end
    Rake::Task[:install_gems].invoke
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
        puts "No build directory found.  Running :clean_middleman_build"
        Rake::Task[:clean_middleman_build].invoke
    end
    puts "Running the html proofer"
    bundle exec ruby "run_html_proofer.rb"
end

task :rebuild_html_and_run_proofer => [:clean_middleman_build, :run_html_proofer] do
     puts "Completed"
end





