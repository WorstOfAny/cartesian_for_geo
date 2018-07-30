RSpec.describe CartesianForGeo::Vector do
	describe '::[]' do
		it 'should create new vector' do
			expect(CFG::Vector[CFG::Point[1.0, 2.0], CFG::Point[2.0, 2.0]].class)
				.to eq(CFG::Vector)
		end
	end

	before(:example) do
		@vector_crossing =
			CFG::Vector[CFG::Point[6.0, 177.0], CFG::Point[3.0, -177.0]]

		@vector =
			CFG::Vector[CFG::Point[1.0, 1.0], CFG::Point[6.0, 7.0]]
	end

	describe '#split' do
		it 'should return 2 vectors that have point on 180' do
			splitted = @vector_crossing.split
			expect(splitted.size).to eq(2)
			expect(splitted.first.points.last.lng).to eq(180.0)
			expect(splitted.last.points.first.lng).to eq(-180.0)
		end
	end

	describe '#crossing?' do
		it 'should return true if difference between vector points lngs' \
			'between 180 and 360' do
			expect(@vector_crossing.crossing?).to eq(true)
			expect(@vector.crossing?).to eq(false)
		end
	end
end
