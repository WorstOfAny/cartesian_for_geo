require 'json'

RSpec.describe CartesianForGeo::Point do
	describe '::[]' do
		it 'should create new point' do
			subject { CFG::Point[1.0, 2.0].instance_of? CFG::Point }
			is_expected.to be_truthy
		end
	end

	before(:example) do
		@point1 = CFG::Point[1.0, 2.0]
		@point2 = CFG::Point[1.0, -2.0]
		@point3 = CFG::Point[1.0, nil]
	end

	describe '#side' do
		context 'if point lng negative' do
			subject { @point2.side }
			it { is_expected.to eq(-1) }
		end

		context 'if point lng positive' do
			subject { @point1.side }
			it { is_expected.to eq 1 }
		end

		context 'if point lng nil' do
			subject { @point3.side }
			it 'raises error' do
				expect { @point3.side }.to raise_error(NoMethodError)
			end
		end
	end

	describe '#empty?' do
		context ' if lat or lng nil' do
			subject { @point3.empty? }
			it { is_expected.to be_truthy }
		end

		context 'otherwise' do
			subject { @point1.empty? }
			it { is_expected.to be_falsey }
		end
	end

	describe '#lng_from_edge' do
		context 'if lng not nil' do
			it 'should return distance between 180 and point lng' do
				expect(@point1.lng_from_edge).to eq(178.0)
				expect(@point2.lng_from_edge).to eq(178.0)
			end
		end

		context 'if lng nil' do
			it 'raises error' do
				expect { @point3.lng_from_edge }.to raise_error(NoMethodError)
			end
		end
	end

	describe '#to_s' do
		context 'if not empty' do
			subject { @point1.to_s }
			it { is_expected.to match(/\(\d+\.\d+,\d+\.\d+\)/) }
		end

		context 'if empty' do
			subject { @point3.to_s }
			it { is_expected.to eq('') }
		end
	end

	describe '#to_a' do
		it 'should return array with lat lng' do
			expect(@point1.to_a).to eq([1.0, 2.0])
			expect(@point2.to_a).to eq([1.0, -2.0])
			expect(@point3.to_a).to eq([1.0, nil])
		end
	end

	describe '#to_json' do
		it 'should return json with lat lng' do
			expect(@point1.to_json).to eq(JSON.generate(lat: 1.0, lng: 2.0))
			expect(@point2.to_json).to eq(JSON.generate(lat: 1.0, lng: -2.0))
			expect(@point3.to_json).to eq(JSON.generate(lat: 1.0, lng: nil))
		end
	end

	describe '#==' do
		context 'comparing with other point' do
			subject { @point1 == @point2 }
			it { is_expected.to be_falsey }
		end

		context 'comparing with self' do
			subject { @point1 == CFG::Point[1.0, 2.0] }
			it { is_expected.to be_truthy }
		end

		context 'otherwise' do
			subject { @point1 == 1 }
			it { is_expected.to eq nil }
		end
	end

	describe '#<=>' do
		context 'if lat1 < lat2 or lat1 == lat2 and lng1 < lng2' do
			subject { @point1 <=> @point2 }
			it { is_expected.to eq 1 }
		end

		context 'if lat1 == lat2 and lng1 == lng2' do
			subject { @point1 <=> CFG::Point[1.0, 2.0] }
			it { is_expected.to eq 0 }
		end

		context 'if lat1 > lat2 or lat1 == lat2 and lng1 > lng2' do
			subject { @point2 <=> @point1 }
			it { is_expected.to eq(-1) }
		end
	end
end
