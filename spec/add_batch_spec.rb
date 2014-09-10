require'spec_helper'

describe AddBatch do
  before :all do
    @bsi = RBC.new(
      { :user     => 'biorepository_bot',
        :pass     => ENV['ECOG_BOT_PASS'],
        :server   => 'PCF',
        :url      => 'https://websvc-mirror.bsisystems.com:2271/bsi/xmlrpc'
    },
    {
      :debug => false,
      :stealth => false
    }
    )

    batch_description = {
      'batch.description' => 'My Batch Description'
    }

    @batch = AddBatch.new @bsi, batch_description
  end

  describe '#new' do
    it 'takes 2 parameters and returns an AddBatch object' do
      expect(@batch).to be_instance_of AddBatch
    end
  end

  describe '#id' do
    it "returns batch id string for the created batch" do
      expect(@batch.id).not_to be_nil
      expect(@batch.id).to be_instance_of String
    end
  end

  describe '#type' do
    it "returns Add (the correct type)" do
      expect(@batch.type).to eq('Add')
    end
  end

  describe '#specimens' do
    context 'before specimens added' do
    end

    context 'after specimens added' do
      before :each do
        test_specimens = build_list(:specimen, 10)
        @batch.add_specimens(test_specimens)
      end

      it 'returns array of Pipeline::BSI::Models::Specimen objects' do
        expect(@batch.specimens).to be_instance_of Array
      end
    end
  end

  describe '#properties' do
    it "returns correct properties hash" do
      expect(@batch.properties).to be_instance_of Hash
      expect(@batch.properties).to include('batch.description')
    end
  end

  describe '#add_specimens' do
    it 'takes an array of Pipeline::BSI::Models::Specimen objects and adds them to the batch'
  end

  describe '#perform_edit_checks' do
    it 'runs the built in edit check functionality of BSI to check for errors in the Add Batch'
  end

  describe '#commit' do
    it 'commits specimens in the batch to the BSI database if all edit checks pass'
  end
end
