require 'gdsii/record/datatypes/data.rb'

module Gdsii

  module RecData

    #
    # Class for REAL4 data type (UNSUPPORTED - will raise an exception)
    #
    class Real4 < Data

      # Value is an array of floating point numbers
      attr_reader :value

      # Will raise an exception immediately as REAL4 is not supported in the
      # GDSII specification.
      def initialize(value)
         raise "GDT_REAL4 is unsupported"
      end

      # Raises an TypeError exception as REAL4 is not supported
      def value=(value)
        raise "GDT_REAL4 is unsupported"
      end

      # Returns the size of the record *data* in bytes.  Each array element
      # consumes 4 bytes (hence REAL4).
      def byte_size()
        @value.length * 4
      end

      # just create the Gdsii::RecData::Real4 object and raise the exception
      def Real4.read(file, byte_count)
        Real4.new([0])
      end

      # Raises an exception since REAL4 is unsupported
      def write(file)
         raise "GDT_REAL4 is unsupported"
      end

      # Converts the array of floating point values to a string (values are
      # joined by spaces).
      def to_s()
        value.map {|v| v.to_s}.join(' ')
      end

    end

  end
end 
