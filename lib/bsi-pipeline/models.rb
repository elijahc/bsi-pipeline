require 'etl-pipeline'
require 'yaml'

module Pipeline
  module BSI
    module Models
      class Specimen < Pipeline::Model::Base
        attr_accessor :seminal_parent, :bfh_map

        REQUIRED_FIELDS = %w(study_id subject_id specimen_type date_drawn date_received label_status billing_method thaws).map{|v| v.to_sym}
        BSI_CORE_FIELDS = {
          # Sample level fields
          :subject_id             => 'sample.subject_id',
          :sample_id              => 'sample.sample_id',
          :date_drawn             => 'sample.date_drawn',
          :kit_id                 => 'sample.kit_id',
          :pickup_location        => 'sample.pickup_location',
          :sample_modifiers       => 'sample.sample_modifiers',
          # Vial fields
          :study_id               => 'vial.study_id',
          :repos_id               => 'vial.repos_id',
          :sequence               => 'vial.seq_num',
          :current_label          => 'vial.current_label',
          :specimen_type          => 'vial.mat_type',
          :parent_id              => 'vial.parent_id',
          :measurement            => 'vial.volume',
          :vial_status            => 'vial.vial_status',
          # Location Fields
          :room                   => 'location.room',
          :building               => 'location.building',
          :freezer                => 'location.freezer',
          :shelf                  => 'location.shelf',
          :rack                   => 'location.rack',
          :box                    => 'location.box',
          # Vial-Location fields
          :row                    => 'vial_location.row',
          :col                    => 'vial_location.col'
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
              self.bfh_map[k.to_sym] = v.to_s
            end
          when Array.to_s
            attributes.each do |elem|
              new_attributes[elem.to_sym] = "vial.#{elem}"
              self.bfh_map[elem.to_sym] = "vial.#{elem}"
            end
          else
            raise 'Please pass either an Array or Hash of attributes'
          end
          new_attributes.keys.each do |attr|
            self.class.send(:attr_accessor, attr) unless self.respond_to? attr
          end
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
