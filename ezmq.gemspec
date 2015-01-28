Gem::Specification.new do |gem|
  gem.name        = 'ezmq'
  gem.version     = '0.3.3'
  gem.licenses    = 'MIT'
  gem.authors     = ['Chris Olstrom']
  gem.email       = 'chris@olstrom.com'
  gem.homepage    = 'http://colstrom.github.io/ezmq/'
  gem.summary     = 'Effortless ZMQ'
  gem.description = 'Syntactic sugar around FFI bindings for ZMQ, to stop C from seeping into your Ruby.'

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  gem.require_paths = ['lib']

  gem.add_runtime_dependency 'ffi-rzmq', '~> 2.0'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rubocop'
  gem.add_development_dependency 'flog'
  gem.add_development_dependency 'flay'
  gem.add_development_dependency 'roodi'
  gem.add_development_dependency 'reek'
  gem.add_development_dependency 'churn'
  gem.add_development_dependency 'yard'
  gem.add_development_dependency 'inch'
end
