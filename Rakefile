require "bundler/gem_tasks"
begin
  require 'cane/rake_task'

  desc "Run cane to check quality metrics"
  Cane::RakeTask.new(:quality) do |cane|
    cane.abc_max = 15
    cane.add_threshold 'coverage/covered_percent', :>=, 99
    cane.no_style = true
    cane.abc_exclude = %w(Foo::Bar#some_method)
  end

  task :default => :quality
rescue LoadError
  warn "cane not available, quality task not provided."
end

desc "Run both bins for backup"
task :backup do
  sh "rm -f *.xlsx *.tsv"
  sh "ruby bin/trello_backup.rb"
  sh "TRELLO_FORMAT='tsv' ruby bin/trello_backup_tsv.rb"
end
