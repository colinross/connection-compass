# Since my fingers are so used to using `rake` to run the test suite
task :spec do
  $LOAD_PATH.unshift('lib', 'spec')
  Dir.glob('./spec/**/*_spec.rb').each { |file| require file}
end
task :default => [:spec]

