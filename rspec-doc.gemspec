lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name               = "rspec-doc"
  s.version            = "0.1.3"
  s.license            = 'MIT'

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Focinfi"]
  s.date = %q{2017-10-10}
  s.description = %q{Make markdown for rspec}
  s.email = %q{focinfi@gmail.com}
  s.executables        = ["rspecdoc"]
  s.files = [
    "Rakefile", 
    "lib/rspec-doc.rb",  
    "lib/rspec-doc/model_builder.rb",
    'lib/rspec-doc/markdown_formatter.rb',
    'lib/rspec-doc/markdown_util.rb',
    'lib/rspec-doc/rest_client.rb',
    'lib/rspec-doc/active_record.rb',
    "bin/rspecdoc"
  ]
  s.homepage = %q{https://github.com/Focinfi/rspec-doc}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{2.5.1}
  s.summary = %q{rspec-doc}

  # deps
  s.add_runtime_dependency 'activerecord', '~> 5.1.4', '>= 5.1.4'
  s.add_runtime_dependency 'rare_map', '2.2.1'
  s.add_runtime_dependency 'rest-client', '~> 2.0.2', '>= 2.0.2'
  s.add_runtime_dependency 'method_source', '~> 0.9.0', '>= 0.9.0'
  s.add_runtime_dependency 'rspec', '~> 3.6.0', '>= 3.6.0' 
end

