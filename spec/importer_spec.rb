require 'spec_helper'

describe SpecimenImporter do
  before :each do
      key = {
        :user     => 'biorepository_bot',
        :pass     => ENV['ECOG_BOT_PASS'],
        :server   => 'PCF',
        :url      => 'https://websvc-mirror.bsisystems.com:2271/bsi/xmlrpc'
      }
    @importer = SpecimenImporter.new(key, {:instance => 'mirror', :debug => 'false'})

  end

  describe '#new' do
  end

  describe '#import' do
    context '25 slides' do
      before :example do
        @specimens = build_list(:slide_specimen, 25)
        @importer.import(@specimens)
      end

      it 'stores all the specimens as an attribute' do
        expect(@importer.specimens).to be_instance_of Array
      end
    end

  end
end
