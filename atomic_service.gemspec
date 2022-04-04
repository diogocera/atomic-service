Gem::Specification.new do |spec|
  spec.name        = 'atomic_service'
  spec.version     = '0.0.1'
  spec.summary     = "Service objects made easy."
  spec.description = "A base class to build DRY service objects in Ruby."
  spec.authors     = ["Diogo Cera"]
  spec.email       = 'diogocera@gmail.com'
  spec.files       = ["lib/atomic_service.rb"]
  spec.homepage    =
    'https://rubygems.org/gems/atomic_service'
  spec.license       = 'MIT'
  
  spec.add_runtime_dependency 'activemodel', '>= 4.2'
  spec.add_runtime_dependency "after_commit_everywhere", '~> 1.1.0'
  spec.add_development_dependency "rspec", '~> 3.11.0'
end