# frozen_string_literal: true

require 'gorilla-patch/cover'

## Collection (Array) of Polygons
class PolygonsCollection < Array
	def <<(new_polygon)
		each_with_index do |polygon, ind|
			if new_polygon.include?(polygon)
				insert(ind, new_polygon) unless include?(new_polygon)
				next new_polygon.concat delete(polygon)
			elsif polygon.include?(new_polygon)
				break new_polygon = polygon.concat(new_polygon)
			end
		end
		super new_polygon unless include?(new_polygon)
	end
end

## Class for one Point
class Point
	attr_accessor :lat, :lng

	def initialize(coords)
		@lat, @lng = coords
	end

	def side
		lng.negative? ? -1 : 1
	end

	def lng_from_edge
		180 - lng.abs
	end

	def to_s
		"(#{lat},#{lng})"
	end
end

## Class for Vector (of two Points)
class Vector
	attr_accessor :from, :to
	attr_reader :points
	alias to_a points

	def initialize(from, to)
		@from = from
		@to = to
		@points = [@from, @to]
	end

	def split
		@split ||= [
			Vector.new(from, point_at_edge(from.side)),
			Vector.new(point_at_edge(to.side), to)
		]
	end

	def increase_in(ratio)
		%w[lat lng].each do |var|
			value = from.send(var) + (to.send(var) - from.send(var)) * ratio
			to.send("#{var}=", value)
		end
		self
	end

	def crossing?
		delta = points.map(&:lng).reduce(:-).abs
		delta > 180 && delta < 360
	end

	private

	def point_at_edge(side)
		@lat_at_edge ||= lat_at_edge
		Point.new [@lat_at_edge, side * 180]
	end

	def lat_at_edge
		points_by_lat = points.sort_by!(&:lat).reverse!
		lng_dists = points_by_lat.map(&:lng_from_edge)
		lat_diff = points_by_lat.map(&:lat).reduce(:-)
		points_by_lat.first.lat - lat_diff * lng_dists.first / lng_dists.reduce(:+)
	end
end

## Class for Polygon (has many Vectors)
class Polygon
	attr_reader :vectors

	def initialize(vectors)
		raise VectorsCountError if vectors.size < 2
		@vectors = vectors
		first_crossing = @vectors.index(&:crossing?)
		@vectors.rotate!(first_crossing).push(@vectors.first) if first_crossing
	end

	def self.parse(text)
		points = text.tr('() ', '').split(',').each_slice(2).to_a.map! do |point|
			Point.new point.map(&:to_f)
		end
		vectors = points.map.with_index(-1) do |_p, ind|
			Vector.new(points[ind], points[ind.next])
		end
		new vectors
	end

	def self.parse!(text)
		parse(text)
	rescue VectorsCountError
		nil
	end

	def increase_in(ratio)
		help_vector = Vector.new center, nil
		vectors.each do |vector|
			help_vector.tap { |h_v| h_v.to = vector.to }.increase_in(ratio)
		end
		self
	end

	def split
		@polygons = PolygonsCollection.new
		@vectors.each_with_object([]) do |vector, vectors_array|
			begin
				next vectors_array << vector unless vector.crossing?
				polygon_vectors = vectors_array.concat(vector.split).slice!(0..-2)
				@polygons << Polygon.new(polygon_vectors)
			rescue VectorsCountError; next; end
		end
		@polygons.empty? ? @polygons << Polygon.new(@vectors) : @polygons
	end

	def concat(other)
		vectors.concat(other.vectors)
		self
	end

	using GorillaPatch::Cover

	def include?(other)
		side == other.side && lat_range.cover?(other.lat_range)
	end

	def lat_range
		@lat_range ||= Range.new(*lat_edges)
	end

	def side
		vectors.first.from.side
	end

	def to_s
		points = vectors.map(&:to_a).flatten!.uniq
		"(#{points.map(&:to_s).join(',')})"
	end

	private

	def center
		coords = vectors.each_with_object({ lat: 0, lng: 0 }.to_a) do |vector, arr|
			arr.each { |el| el[-1] += vector.to.send(el.first) }
		end
		Point.new(coords.map! { |el| el.last / vectors.size })
	end

	def lat_edges
		[vectors.first.from, vectors.last.to].map!(&:lat).sort!
	end
end

## Custom error for Polygon initialization
class VectorsCountError < ArgumentError
	def message
		'You need at least two vectors to initialize the polygon'
	end
end
