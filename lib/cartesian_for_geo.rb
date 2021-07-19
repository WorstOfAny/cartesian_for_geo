require 'cartesian_for_geo/version'
require 'gorilla_patch/cover'

module CartesianForGeo
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
			return self if include?(new_polygon)
			super new_polygon
		end
	end

	## Class for one Point
	class Point
		include Comparable

		attr_accessor :lat, :lng
		attr_reader :coords, :order

		alias to_a coords

		class << self
			alias [] new

			def parse(coords_text)
				new *coords_text.gsub(/[()\s]/, '').split(',').map(&:to_f)
			end
		end

		def initialize(*coords)
			@coords = coords.flatten
			@lat, @lng = @coords
			@order = :lat_lng
		end

		def side
			lng.negative? ? -1 : 1
		end

		def empty?
			(lat && lng).nil?
		end

		def lng_from_edge
			180 - lng.abs
		end

		def to_s
			empty? ? '' : "(#{coords.join(',')})"
		end

		def lng_lat!
			@order = :lng_lat
			@coords = [@lng, @lat]
			self
		end

		def lat_lng!
			@order = :lat_lng
			@coords = [@lat, @lng]
			self
		end

		def to_json(*)
			JSON.generate(lat: lat, lng: lng)
		end

		def ==(other)
			super if other.is_a?(Point)
		end

		def <=>(other)
			[
				to_a,
				other.to_a.public_send(order == other.order ? :itself : :reverse)
			].map { |cord| cord.map { |f| f.round 9 } }.reduce(:<=>)
		end
	end

	## Class for Vector (of two Points)
	class Vector
		attr_accessor :from, :to
		attr_reader :points
		alias to_a points

		class << self
			alias [] new
		end

		def initialize(*points)
			@points = points.flatten
			@from, @to = @points
		end

		def split
			@split ||= [
				[from, point_at_edge(from.side)], [point_at_edge(to.side), to]
			].map(&Vector.method(:[]))
		end

		def crossing?
			delta = points.map(&:lng).reduce(:-).abs
			delta > 180 && delta < 360
		end

		private

		def point_at_edge(side)
			@lat_at_edge ||= lat_at_edge
			Point[@lat_at_edge, side * 180]
		end

		def lat_at_edge
			points_by_lat = points.sort_by!(&:lat).reverse!
			lng_dists = points_by_lat.map(&:lng_from_edge)
			lat_diff = points_by_lat.map(&:lat).reduce(:-)
			points_by_lat.first.lat -
				lat_diff * lng_dists.first / lng_dists.reduce(:+)
		end
	end

	## Class for Polygon (has many Vectors)
	class Polygon
		attr_reader :vectors

		def initialize(*vectors)
			@vectors = vectors.flatten
			raise VectorsCountError if @vectors.size < 2
			first_crossing = @vectors.index(&:crossing?)
			@vectors.rotate!(first_crossing).push(@vectors.first) if first_crossing
		end

		def self.parse(text)
			points = text.tr('() ', '').split(',').each_slice(2).to_a.map! do |point|
				Point[point.map(&:to_f)]
			end
			new points.map.with_index(-1) { |point, ind| Vector[points[ind], point] }
		end

		def self.parse!(text)
			parse(text)
		rescue VectorsCountError
			nil
		end

		def split
			@polygons = PolygonsCollection.new
			@vectors.each_with_object([]) do |vector, vectors_arr|
				next vectors_arr << vector unless vector.crossing?
				@polygons << Polygon.new(vectors_arr.push(*vector.split).slice!(0..-2))
			rescue VectorsCountError
				next
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
			coords =
				vectors.each_with_object({ lat: 0, lng: 0 }.to_a) do |vector, arr|
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
end
