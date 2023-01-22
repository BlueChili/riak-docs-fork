### Basho Docs' Rakefile
#
# This Rakefile is to be invoked with the `rake` Ruby Gem. It's best if the that
# Gem is installed using Bundler and the included Gemfile.
#
# This file will act as the canonical builder for all common build operations;
#   * Compiling SCSS into CSS
#   * Compiling CoffeeScript into JavaScript
#   * Aggregating project description and download package metadata
#   * Deploying the static site to S3
#
# Additionally, this file can be used by developers to
#   * Watch changes in the dynamic/ directory and automatically recompile CSS/JS
#   * Watch changes in the content/ directory and automatically rebuild the site
#
# Running `rake` or `rake -T` will output a list of useful commands and
# descriptions thereof.

require_relative 'rake_libs/compile_js'
require_relative 'rake_libs/s3_deploy'
require_relative 'rake_libs/downloads_metadata_generator_sftp'
#require_relative 'rake_libs/downloads_metadata_generator'
require_relative 'rake_libs/projects_metadata_generator'

$js_source  = "./dynamic/js"
$js_dest    = "./static/js"
$cache_dir  = "./dynamic/.cache"
$hugo_dest  = "./output" # Should always be set to `publishdir` from config.yml

### Rake directory definitions
directory "#{$js_dest}"
directory "#{$cache_dir}"


######################################################################
### Version Checks

min_hugo_version = "0.109"
min_ruby_version = "2.2.5"

# Check if Ruby is up to date
if Gem::Version.new(min_ruby_version) > Gem::Version.new(RUBY_VERSION)
  Kernel.abort("ERROR: An old version of Ruby (#{RUBY_VERSION}) is in use.\n"\
               "       Please upgrade this tool to at least version "\
               "#{min_ruby_version}.\n")
end

# Check if Hugo is installed, and confirm it's up to date.
if (`which hugo`.empty?)
  Kernel.abort("ERROR: No version of Hugo is installed.\n"\
               "       Please install the latest version of Hugo -- gohugo.io/")
end

# This regex looks for e.g. "v0.16" -- matching only the "0.16" -- and then we
# extract the first string from the returned MatchData with the `[0]`
hugo_version  = /(?<=v)\d+\.\d+/.match(`hugo version`)[0]

if Gem::Version.new(min_hugo_version) > Gem::Version.new(hugo_version)
  Kernel.abort("ERROR: An old version of Hugo (#{hugo_version}) is in use.\n"\
               "       Please upgrade this tool to at least version "\
               "#{min_hugo_version}.\n")
end


######################################################################
### Rake Namespace and Task definitions

##########
# Default
Rake::TaskManager.record_task_metadata = true
task :default do
  puts("Riak Documentation Generate System Usage:")
  puts("")
  Rake::application.options.show_tasks = :tasks  # this solves sidewaysmilk problem
  Rake::application.options.show_task_pattern = //
  Rake::application.display_tasks_and_comments
end;


########
# Clean
#TODO<drew.pirrone.brusse@gmail>: These `rm -rf`s are maybe a bit much? Should
# we be more precise with what we delete (and, if so, how)?
desc      "Clean dynamically generated content (does not clean Hugo content)"
task      :clean => ['clean:js']
namespace :clean do
  desc "Clean dynamically generated JS"
  task :js do
    # The standalone/ directory may exist if we've extracted archived content
    # (see deploy:fetch_archived_content). We don't want to remove those files.
    js_file_list = Dir["#{$js_dest}/**/*"].reject {|f| /standalone/.match(f) }
    js_file_list.each do |f|
      log_deletion(f)
      FileUtils.rm(f)
    end
  end
  desc "Clean Hugo-generated content"
  task :hugo do
    log_deletion($hugo_dest)
    FileUtils.rm_rf($hugo_dest)
  end
end


########
# Build
desc      "Compile compressed JS and compressed CSS"
task      :build => ['clean', 'build:js']
namespace :build do
  task :js  => ["#{$js_dest}", 'clean:js']   do compile_js(debug: false); end

  ################
  # Build : Debug
  desc      "Compile human-readable JS"
  task      :debug => ["#{$js_dest}", 'build:debug:js']
  namespace :debug do

    desc "Compile human-readable JS"
    task :js  => ["#{$js_dest}"]  do compile_js(debug: true); end

  end
end


########
# Watch
desc      "Rebuild compressed JS on file saves"
task      :watch do sh 'bundle exec guard -g js'; end
namespace :watch do

  task :js  do sh 'bundle exec guard -g js'; end

  ################
  # Watch : Debug
  desc      "Rebuild human-readable JS and CSS content on file saves"
  task      :debug => ['clean'] do sh 'bundle exec guard -g debug_js'; end
  namespace :debug do
    task :js  do sh 'bundle exec guard -g debug_js'; end
  end
end


#######
# Hugo
desc      "Generate the static site into #{$hugo_dest}"
task      :hugo => ['clean:hugo'] do sh "hugo -d #{$hugo_dest}"; end
namespace :hugo do

  #TODO<drew.pirrone.brusse@gmail>: Add in some way to specify ip/port.
  desc "Run Hugo Server"
  task :server do sh "hugo server"; end
end


#########
# Deploy
desc      "Build and deploy static artifacts"
task      :deploy => [
                      'clean',
                      'deploy:fetch_archived_content',
                      'build:js',
                      'hugo'
                     ] do do_deploy(); end
namespace :deploy do
  task :immediately_and_unsafely do do_deploy(); end
  task :fetch_archived_content do do_fetch_archived_content(); end
end


#####################
# Metadata Generation
#
# These tasks should be run in response to a new version of any project being
# made available. When a new package is uploaded to our downloads host, we will
# need to run `rake metadata:generate_downloads`. When a new version or project
# is added to config.yaml, run `rake metadata:generate_projects`.
task      :generate_metadata
namespace :metadata do
  desc "Update all generative metadata files"
  task :all => ['metadata:generate_downloads', 'metadata:generate_projects']

  desc "Generate package URI information"
  task :generate_downloads do generate_downloads_metadata_sftp(); end

  desc "Generate JavaScript-readable project descriptions"
  task :generate_projects do generate_projects_metadata(); end
end



######################################################################
### Helper/Compilation functions

# Prints "    deleting #{target}" to the console, and color "deleting" red.
def log_deletion(target)
  red = "\033[31m"
  nc  = "\033[0m" # no color
  print "    #{red}deleting#{nc} #{target}\n"
end

# Print "    write #{target}" to the console, and color "write" green. This is
# designed to match the Compass log output on file writes.
def log_write(target)
  green = "\033[32m"
  nc    = "\033[0m" # no color
  print "    #{green}write#{nc} #{target}\n"
end
