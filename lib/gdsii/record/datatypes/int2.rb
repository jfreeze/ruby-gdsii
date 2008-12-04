require 'gdsii/record/datatypes/data.rb'
require 'gdsii/byte_order.rb'

module Gdsii

  module RecData

    #
    # Store a GDSII INT2 data type
    #
    class Int2 < Data
      
      # Value is an array of integers.
      attr_reader :value
     
      # Construct an Gdsii::RecData::Int2 data object.  The value is an array
      # of integers (Fixnum).
      def initialize(value)
        super(GDT_INT2, value)
      end

      # Set the value for this object; verify that the value items are of
      # type Fixnum (or at least can be coerced using "to_i").
      def value=(value)
        @value = Data.coerce_value(value, Fixnum, :to_i)
      end

      # Returns the size of the record *data* in bytes.  Each array element
      # consumes 2 bytes (hence INT2).
      def byte_size()
        @value.length * 2
      end

      # Reads an INT2 record from the given file and for the length of bytes
      # given and returns a new Gdsii::RecData::Int2 object.
      def Int2.read(file, byte_count)
        data = []
        while (byte_count > 0)
          raw = file.read(2)
          raw.reverse! if (ByteOrder::little_endian?)
          data.push raw.unpack('s')[0]
          byte_count -= 2
        end
        Int2.new(data)
      end

      # Writes the integer values in this Gdsii::RecData::Int2 object to the
      # given file as a GDSII INT2 record.
      def write(file)
        value.each do |item|
          # always write int2 as network order (as per GDSII spec)
          file.write [item].pack('n')
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

