# frozen_string_literal: true

require 'polygon/version'

Gem::Specification.new do |spec|
	spec.name          = 'polygon-splitter'
	spec.version       = Polygon::VERSION
	spec.authors       = ['Ivan Tyurin']
	spec.email         = ['worstofany@gmail.com']

	spec.summary       = %(
		Helper for transform Polygons from GoogleMaps to PSQL DB correctly
	)
	spec.homepage      = 'https://github.com/WorstOfAny/polygon-spliter'
	spec.license       = 'MIT'

	spec.files         = Dir[File.join('lib', '**', '{*,.*}')]

	spec.add_development_dependency 'bundler', '~> 1.14'
	spec.add_development_dependency 'rake', '~> 10.0'
	spec.add_development_dependency 'rspec', '~> 3.0'
	spec.add_development_dependency 'gorilla-patch', '~> 2.3.0'
end
