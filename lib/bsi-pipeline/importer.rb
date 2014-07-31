module Pipeline
  module BSI

    module Importer

      class DataEntryBatch
        attr_accessor :type, :properties, :id, :specimens, :client
        def initialize(client, batch_type, batch_properties)
          @type       = batch_type
          @properties = batch_properties
          @bsi        = client
          @id         = @bsi.batch.create(batch_type, batch_properties)
        end
      end

      class AddBatch < DataEntryBatch
        attr_accessor :seminal_parents

        def initialize(client, batch_properties)
          super client, 'A', batch_properties
        end

        def type
          'Add'
        end

        def add_specimens(specimens)
          @specimens = specimens
          format
          @bsi.batch.addVials( @id, @specimens.map{ |s| s.to_bfh } )
          nil
        end

        def format
          # Find out how many seminal parents there are
          num_seminal_parents = @specimens.select{|s| ['N/A', ''].include?( s.parent_id.to_s )}.length

          fails = 0
          begin
          # Reserve Sample ID's for all the seminal parent's
          # Returns and array of strings with both the sampleID and the sequence number in the format: AAA000000 0000
            # Only keep first 6 characters which represent the sample id's (remove the sequence suffix)
            @sample_id_pool = @bsi.batch.reserveAvailableBsiIds( @id, 'LAA000000', num_seminal_parents ).map{|i| i[0..-6]} if num_seminal_parents > 0
          # Not sure why I've been getting this error periodically, but it happens
          rescue NoMethodError
            fails += 1
            retry if fails < 3
          end

          collection_dates = @specimens.map{|s| s.date_drawn}.uniq
          specimen_types   = @specimens.map{|s| s.specimen_type}.uniq
          collection_dates.each do |date|
            specimen_types.each do |type|
              specimen_family = @specimens.select{|s| s.date_drawn == date && s.specimen_type == type}
              family_sample_id = @sample_id_pool.pop
              specimen_family.each_with_index do |spec, i|
                # Assign sample and sequence numbers
                spec.sample_id  = family_sample_id
                spec.sequence   = i+1
              end
            end
          end
        end

        def perform_edit_checks
        end

        def commit
          @bsi.batch.commit(@id)
        end
      end

      class SpecimenImporter < Pipeline::Importer::Base
        attr_accessor :specimens, :batches, :batch_delimiter

        def initialize(key, options={})
          @bsi              = RBC.new(key)
          @specimens        = specimens
          @batches          = Array.new
        end

        def import(all_specimens, options={})
          @specimens = all_specimens
          study_ids   = @specimens.map{|e| e.study_id}.uniq
          subject_ids = @specimens.map{|e| e.subject_id}.uniq

          study_ids.each do |study|
            subject_ids.each_with_index do |sid, i|
              # Filter by subject_id and study_id
              subset = @specimens.select{|e| e.study_id == study && e.subject_id == sid}

              batch_properties = {
                'batch.description' => "Subject: #{sid}",
                'batch.study_id'    => study.to_s
              }

              @batch = AddBatch.new(@bsi, batch_properties)
              @batch.add_specimens(subset)
              @batch.commit if options['commit']

              @batches << @batch
            end
          end

          @bsi.common.logoff
        end

      end

      class Subject < Pipeline::Importer::Base
      end
    end

  end
end
