# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'cartesian_for_geo/version'

Gem::Specification.new do |spec|
	spec.name          = 'cartesian_for_geo'
	spec.version       = CartesianForGeo::VERSION
	spec.authors       = ['Ivan Tyurin']
	spec.email         = ['worstofany@gmail.com']

	spec.summary       = %(
		Helper for transform Polygons from GoogleMaps to PSQL DB correctly
	)
	spec.homepage      = 'https://github.com/WorstOfAny/cartesian_for_geo'
	spec.license       = 'MIT'

	spec.files = `git ls-files -z`.split("\x0").reject do |f|
		f.match(%r{^(lib|test|spec|features)/})
	end

	spec.add_runtime_dependency 'gorilla_patch', '~> 3.0'

	spec.add_development_dependency 'bundler', '~> 1.14'
	spec.add_development_dependency 'rake', '~> 10.0'
	spec.add_development_dependency 'rspec', '~> 3.0'
end
