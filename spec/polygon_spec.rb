RSpec.describe CartesianForGeo::Polygon do
	describe '::new' do
		it 'should raise error if initialized with less than 2 vectors' do
			expect do
				CFG::Polygon
					.new(CFG::Vector[CFG::Point[4.0, 9.0], CFG::Point[-2.0, 0.0]])
			end.to raise_error(CFG::VectorsCountError)
		end
	end

	describe '::[]' do
		before(:example) do
			@polygon = CFG::Polygon.new(
				CFG::Vector[CFG::Point[4.0, 9.0], CFG::Point[-2.0, 0.0]],
				CFG::Vector[CFG::Point[-2.0, 0.0], CFG::Point[-5.0, 5.0]],
				CFG::Vector[CFG::Point[-2.0, 0.0], CFG::Point[4.0, 9.0]]
			)
		end
		it 'should create new polygon' do
			expect(@polygon.instance_of?(CFG::Polygon)).to be_truthy
		end
	end

	describe '::parse' do
		before(:example) do
			@polygon = CFG::Polygon.parse('((1,0),(2,1),(2,2),(1,3))')
		end
		it 'should return 4 vectors' do
			expect(@polygon.vectors.size).to eq(4)
		end

		it 'should raise error if text includes less than 2 points' do
			expect { CFG::Polygon.parse('()') }.to raise_error(CFG::VectorsCountError)
		end
	end

	describe '::parse!' do
		it 'should return nil if text includes less than 2 points' do
			expect(CartesianForGeo::Polygon.parse!('()')).to eq(nil)
		end
	end

	before(:example) do
		@polygon_crossing = CFG::Polygon.new(
			CFG::Vector[CFG::Point[5.0, 179.0], CFG::Point[5.0, -178.0]],
			CFG::Vector[CFG::Point[5.0, -178.0], CFG::Point[1.0, -177.0]],
			CFG::Vector[CFG::Point[1.0, -177.0], CFG::Point[2.0, 177.0]],
			CFG::Vector[CFG::Point[2.0, 177.0], CFG::Point[3.0, -176.0]],
			CFG::Vector[CFG::Point[3.0, -176.0], CFG::Point[5.0, 179.0]]
		)

		@polygon = CFG::Polygon.new(
			CFG::Vector[CFG::Point[5.0, -179.0], CFG::Point[5.0, -178.0]],
			CFG::Vector[CFG::Point[5.0, -178.0], CFG::Point[1.0, -177.0]],
			CFG::Vector[CFG::Point[1.0, -177.0], CFG::Point[5.0, -179.0]]
		)
	end

	describe '#split' do
		it 'should return 3 poligons for crossing and 1 for non-crossing ' do
			expect(@polygon_crossing.split.size).to eq(3)
			expect(@polygon.split.size).to eq(1)
		end
	end

	describe '#concat' do
		it 'should return polygon with 8 vectors' do
			concated = @polygon_crossing.concat(@polygon)
			expect(concated.instance_of?(CFG::Polygon)).to be_truthy
			expect(concated.vectors.size).to eq(9)
		end
	end

	before(:example) do
		@polygon1 = CFG::Polygon.new(
			CFG::Vector[CFG::Point[1.0, 1.0], CFG::Point[1.0, 2.0]],
			CFG::Vector[CFG::Point[1.0, 2.0], CFG::Point[2.0, 2.0]],
			CFG::Vector[CFG::Point[2.0, 2.0], CFG::Point[2.0, 1.0]]
		)

		@polygon2 = CFG::Polygon.new(
			CFG::Vector[CFG::Point[1.5, 1.0], CFG::Point[1.5, 2.0]],
			CFG::Vector[CFG::Point[1.5, 2.0], CFG::Point[2.0, 2.0]],
			CFG::Vector[CFG::Point[2.0, 2.0], CFG::Point[2.0, 1.0]]
		)
	end

	describe '#include?' do
		it 'should return true if CartesianForGeo are on the same side' \
			'and lat_range of one cover lat_range of another one ' do
			expect(@polygon1.include?(@polygon2)).to be_truthy
			expect(@polygon2.include?(@polygon1)).to be_falsey
		end
	end

	describe '#lat_range' do
		it 'should return lat range' \
			'from first vector from point and last vector to point' do
			expect(@polygon1.lat_range).to eq(1.0..2.0)
			expect(@polygon2.lat_range).to eq(1.5..2.0)
		end
	end

	describe '#side' do
		it 'should return polygon side by first vector side' do
			expect(@polygon1.side).to eq(1)
		end
	end

	describe '#to_s' do
		it 'should return polygon like `(point.to_s, ..., point.to_s)`' do
			expect(@polygon1.to_s)
				.to match(/\((\(\d+\.\d+,\d+\.\d+\),)+\(\d+\.\d+,\d+\.\d+\)\)/)
			expect(@polygon2.to_s)
				.to match(/\((\(\d+\.\d+,\d+\.\d+\),)+\(\d+\.\d+,\d+\.\d+\)\)/)
		end
	end
end
