require 'etl-pipeline'
require 'yaml'

module Pipeline
  module BSI
    module Models
      class Specimen < Pipeline::Model::Base
        attr_accessor :seminal_parent, :bfh_map

        REQUIRED_FIELDS = %w(study_id subject_id specimen_type date_drawn date_received label_status billing_method thaws).map{|v| v.to_sym}
        BSI_CORE_FIELDS = {
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

        # Define Defaults
        def initialize(options={})
          @bfh_map = Hash.new
          add_attributes(REQUIRED_FIELDS)
          add_attributes(options[:custom_required_fields])  if options[:custom_required_fields]
          add_attributes(BSI_CORE_FIELDS)
          add_attributes(options[:custom_fields])           if options[:custom_fields]
          self.thaws = '0'
        end

        def add_attributes(attributes)
          new_attributes = Hash.new
          case attributes.class.to_s
          when Hash.to_s
            attributes.each do |k,v|
              new_attributes[k.to_sym] = v.to_s
            end
          when Array.to_s
            attributes.each do |elem|
              new_attributes[elem.to_sym] = "vial.#{elem}"
            end
          else
            raise 'Please pass either an Array or Hash of attributes'
          end
          (new_attributes.keys - bfh_map.keys).each do |attr|
            self.class.send(:attr_accessor, attr)
          end
          self.bfh_map.merge(new_attributes)
          self
        end

        def build(bfh={})
          self.seminal_parent = true
          bfh.keys.each do |bfh_key|
            if BFH_MAP.has_value?(bfh_key)
              instance_eval("self.#{BFH_MAP.key(bfh_key)} = '#{bfh[bfh_key]}'")
            else
              instance_eval("self.#{bfh_key.gsub(/vial\./, '')} = '#{bfh[bfh_key]}'")
            end
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
            if bfh_map.has_key?(k)
              bfh[bfh_map[k]] = v
            else
              bfh["vial.#{k}"] = v
            end
          end
          bfh
        end

        def valid?
          incomplete_attrs = REQUIRED_FIELDS.find{|v| send(v).nil?}.nil?
        end

        def missing_attrs
          REQUIRED_FIELDS.find_all{|a| send(a).nil?}
        end
      end # class Specimen < Pipeline::Model::Base

      class Subject < Pipeline::Model::Base
      end
    end
  end
end
