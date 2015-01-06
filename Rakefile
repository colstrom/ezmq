# require 'simplecov'

task default: [:test]

task :test do
  sh 'rspec'
end

task audit: [:style, :complexity, :duplication, :design, :documentation]

task :style do
  sh 'rubocop'
end

task :complexity do
  sh 'flog *.rb **/*.rb'
end

task :duplication do
  sh 'flay'
end

task :design do
  sh 'roodi'
  sh 'reek *.rb **/*.rb'
end

task :rework do
  sh 'churn'
end

task :documentation do
  sh 'inch'
end
