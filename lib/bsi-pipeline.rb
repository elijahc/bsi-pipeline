require "bsi-pipeline/version"
require 'bsi-pipeline/models'
require 'bsi-pipeline/importer'
require 'rbc'

module Pipeline
  module BSI
    class Pipe
      def initialize(key, options={})
        @key = key
        @options = options
        @bsi = RBC.new( key, options.merge!( {:debug => true} ) )
      end
    end

    include Pipeline::BSI::Models
    include Pipeline::BSI::Importer

  end # module BSI
end # module Pipeline
