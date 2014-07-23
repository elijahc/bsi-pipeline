require 'spec_helper'

describe Specimen do
  before :all do
    @specimen = build(:specimen)
  end

  describe '#new' do
    it 'returns a new specimen object'
    context 'when passed :custom_field => Hash' do
      it 'adds fields and updates bfh_map' do
        expect(@specimen.add_attributes({:stain_type => 'vial.field_268'})).to respond_to(:stain_type, :stain_type=)
      end
    end

  end

end
