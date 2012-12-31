require "bundler/gem_tasks"
require 'rake/dsl_definition'
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs.push "lib"
  t.test_files = FileList['spec/**/*_spec.rb']
  t.verbose = true
end

task :default => [:test]

# begin
#   require 'cane/rake_task'

#   desc "Run cane to check quality metrics"
#   Cane::RakeTask.new(:quality) do |cane|
#     cane.abc_max = 15
#     cane.add_threshold 'coverage/covered_percent', :>=, 99
#     cane.no_style = true
#     cane.abc_exclude = %w(Foo::Bar#some_method)
#   end

#   task :default => :quality
# rescue LoadError
#   warn "cane not available, quality task not provided."
# end

desc "Run both bins for backup"
task :backup => [:clean] do
  sh "rm -f *.xlsx *.tsv *.csv"
  sh "ruby bin/trello_backup.rb"
  sh "TRELLO_FORMAT='tsv' ruby bin/trello_backup.rb"
end

desc "Clean generated files"
task :clean do
  sh "rm -f *.xlsx *.tsv *.csv"
end
