require 'gdsii/record/datatypes/data.rb'
require 'gdsii/byte_order.rb'

module Gdsii

  module RecData

    #
    # Class for INT4 data type
    #
    class Int4 < Data
      
      # Value is an array of integers.
      attr_reader :value

      # Construct an Gdsii::RecData::Int4 data object.  The value is an array
      # of integers (Fixnum).
      def initialize(value)
        super(GDT_INT4, value)
      end

      # Set the value for this object; verify that the value items are of
      # type Fixnum (or at least can be coerced using "to_i").
      def value=(value)
        @value = Data.coerce_value(value, Fixnum, :to_i)
      end

      # Returns the size of the record *data* in bytes.  Each array element
      # consumes 4 bytes (hence INT4).
      def byte_size()
        @value.length * 4
      end

      # Reads an INT4 record from the given file and for the length of bytes
      # given and returns a new Gdsii::RecData::Int4 object.
      def Int4.read(file, byte_count)
        data = []
        while (byte_count > 0)
          raw = file.read(4)
          raw.reverse! if (ByteOrder::little_endian?)
          data.push raw.unpack('i')[0]
          byte_count -= 4
        end
        Int4.new(data)
      end

      # Writes the integer values in this Gdsii::RecData::Int2 object to the
      # given file as a GDSII INT4 record.
      def write(file)
        value.each do |item|
          # always write int4 in network order (as per GDSII spec)
          file.write [item].pack('N')
        end
      end
      
      # Converts the array of integer values to a string (values are joined by
      # spaces).
      def to_s()
        value.map {|v| v.to_s}.join(' ')
      end

    end

  end
end
