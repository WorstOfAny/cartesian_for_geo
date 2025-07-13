RSpec.describe CartesianForGeo::PolygonsCollection do
	describe '#<<' do
		before(:example) do
			@collection = described_class.new

			@first_polygon =
				CFG::Polygon.new(
					CFG::Vector[CFG::Point[1.0, 1.0], CFG::Point[6.0, 7.0]],
					CFG::Vector[CFG::Point[6.0, 7.0], CFG::Point[3.0, 9.0]],
					CFG::Vector[CFG::Point[3.0, 9.0], CFG::Point[1.0, 1.0]]
				)

			@second_polygon = @first_polygon.dup

			@third_polygon =
				CFG::Polygon.new(
					CFG::Vector[CFG::Point[1.0, 0.0], CFG::Point[6.0, 7.0]],
					CFG::Vector[CFG::Point[6.0, 7.0], CFG::Point[3.0, 9.0]],
					CFG::Vector[CFG::Point[3.0, 9.0], CFG::Point[-1.0, 0.0]]
				)

			@fourth_polygon =
				CFG::Polygon.new(
					CFG::Vector[CFG::Point[2.0, 0.0], CFG::Point[6.0, 7.0]],
					CFG::Vector[CFG::Point[6.0, 7.0], CFG::Point[4.0, 9.0]],
					CFG::Vector[CFG::Point[4.0, 9.0], CFG::Point[-2.0, 0.0]]
				)
		end

		it 'should not insert polygon if polygon already exists' do
			@collection << @first_polygon << @second_polygon
			expect(@collection.size).to eq(1)
		end

		it 'should return self if polygon already exists' do
			@collection << @first_polygon
			expect(@collection << @first_polygon).to eq(@collection)
		end

		it 'should insert polygon that includes ' \
			'another polygon and concat with him and delete included CartesianForGeo' do

			@collection << @first_polygon << @third_polygon
			expect(@collection.size).to eq(1)
			expect(@collection.include?(@third_polygon)).to eq(true)
			expect(@collection.include?(@first_polygon)).to eq(false)

			@collection << @fourth_polygon << @second_polygon
			expect(@collection.size).to eq(1)
			expect(@collection.include?(@fourth_polygon)).to eq(true)
			expect(@collection.include?(@third_polygon)).to eq(false)
			expect(@collection.include?(@second_polygon)).to eq(false)
		end
	end
end
