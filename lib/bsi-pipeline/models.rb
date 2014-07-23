require 'etl-pipeline'
require 'yaml'

module Pipeline
  module BSI
    module Models
      class Specimen < Pipeline::Model::Base
        attr_accessor :seminal_parent
        REQUIRED_ATTRIBUTES = %w(study_id subject_id specimen_type date_drawn date_received label_status billing_method thaws).map{|v| v.to_sym}
        BFH_MAP = {
          :study_id               => 'vial.study_id',
          :specimen_type          => 'vial.mat_type',
          :current_label          => 'vial.current_label',
          :parent_id              => 'vial.parent_id',
          :measurement            => 'vial.volume',
          :measurement_est        => 'vial.volume_est',
          :measurement_unit       => 'vial.volume_unit',
          :stain_type             => 'vial.field_268',
          :block_status           => 'vial.field_266',
          :biobank                => 'vial.field_269',
          :grade                  => 'vial.field_271',
          :room                   => 'location.room',
          :building               => 'location.building',
          :freezer                => 'location.freezer',
          :shelf                  => 'location.shelf',
          :rack                   => 'location.rack',
          :box                    => 'location.box',
          :row                    => 'vial_location.row',
          :col                    => 'vial_location.col',
          :sample_id              => 'sample.sample_id',
          :appointment_time       => 'sample.appointment_time',
          :center                 => 'sample.center',
          :data_manager           => 'sample.data_manager',
          :date_drawn             => 'sample.date_drawn',
          :cra                    => 'sample.cra',
          :kit_id                 => 'sample.kit_id',
          :pickup_location        => 'sample.pickup_location',
          :subject_id             => 'sample.subject_id',
          :surgeon                => 'sample.surgeon',
          :referring_physician    => 'sample.field_273',
          :surgical_case_number   => 'sample.surgical_case_number',
          :surgical_case_part     => 'sample.field_267',
          :telephone              => 'sample.telephone',
          :timepoint              => 'sample.time_point',
          :sample_modifiers       => 'sample.sample_modifiers'
        }

        vial_props = (BFH_MAP.keys+REQUIRED_ATTRIBUTES).uniq
        begin
          vial_props = YAML::load(File.open(File.join(File.dirname(__FILE__), 'vial_props.yaml'))).map{|v| v.to_sym}
        rescue Errno::ENOENT
        end

        (vial_props-BFH_MAP.keys+[:specimen_code]).each{|attr_string| attr_accessor attr_string.to_sym}
        BFH_MAP.keys.each{ |attr| attr_accessor attr }

        # Define Defaults
        def initialize(bfh={})

          unless bfh.empty?
            self.seminal_parent = true
            bfh.keys.each do |bfh_key|
              if BFH_MAP.has_value?(bfh_key)
                instance_eval("self.#{BFH_MAP.key(bfh_key)} = '#{bfh[bfh_key]}'")
              else
                instance_eval("self.#{bfh_key.gsub(/vial\./, '')} = '#{bfh[bfh_key]}'")
              end
            end

          else
            self.thaws = '0'
          end

        end

        def bsi_id()
          "#{self.sample_id} #{self.seq_num}"
        end

        def seminal_parent?
          return seminal_parent
        end

        def to_bfh
          bfh = Hash.new
          # Add 1-1 matches/translations
          formatted_attributes.each do |k,v|
            if BFH_MAP.has_key?(k)
              bfh[BFH_MAP[k]] = v
            else
              bfh["vial.#{k}"] = v
            end
          end
          bfh
        end

        def valid?
          incomplete_attrs = REQUIRED_ATTRIBUTES.find{|v| send(v).nil?}.nil?
        end

        def missing_attrs
          REQUIRED_ATTRIBUTES.find_all{|a| send(a).nil?}
        end
      end # class Specimen < Pipeline::Model::Base

      class Subject < Pipeline::Model::Base
      end
    end
  end
end
