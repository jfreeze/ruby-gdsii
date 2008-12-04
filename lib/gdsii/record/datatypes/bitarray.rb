require 'gdsii/record/datatypes/data.rb'

module Gdsii

  module RecData

    #
    # Class for BITARRAY data type
    #
    class BitArray < Data

      # Value is an array of 16-bit integers which represent the bit array.
      # To get a String of the bit array represented as an array of strings
      # madeup of 16 1's and 0's consider using the #to_s_a or #to_s methods.
      attr_reader :value

      # Construct an Gdsii::RecData::BitArray data object.  The value is an
      # array of 16-bit integers representing the bit array.  Examples:
      #
      #  record = Gdsii::RecData::BitArray.new([1234])
      #  record.value.inspect #=> [1234]
      #
      # Or alternatively to initialize with an array of strings madeup of 16
      # 1's and 0's, use Gdsii::RecData::BitArray.s_a_to_i_a:
      #
      #  arr = Gdsii::RecData::BitArray.s_a_to_i_a(["0000010011010010"])
      #  record = Gdsii::RecData::BitArray.new(arr)
      #  record.value.inspect #=> [1234]
      #
      def initialize(value)
        super(GDT_BITARRAY, value)
      end
      
      # Set the value for this object; verify that the value items are of
      # type Fixnum (or at least can be coerced using "to_i").
      def value=(value)
        @value = Data.coerce_value(value, Integer, :to_i)
      end

      # Returns the size of the record *data* in bytes.  Each array element
      # consumes 2 bytes.
      def byte_size()
        @value.length * 2
      end

      # Reads a BITARRAY record from the given file and for the length of bytes
      # given and returns a new Gdsii::RecData::BitArray object.
      def BitArray.read(file, byte_count)
        raw = file.read(byte_count)
        data = raw.unpack("n")
        BitArray.new(data)
      end

      # Writes the integer values representing the bit array in this
      # Gdsii::RecData::BitArray object to the given file as a GDSII BITARRAY
      # record.
      def write(file)
        file.write @value.pack("n")
      end

      #
      # Returns an array containing string representations for each of the
      # 16-bit integers in the value.  Example:
      #
      #  record = Gdsii::RecData::BitArray.new([1234, 9876])
      #  record.to_s_a.inspect #=> ["0000010011010010", "0010011010010100"]
      #
      def to_s_a()
        @value.map {|string| [string].pack("n").unpack("B16")[0]}
      end

      #
      # Returns a string containing string representations for each of the
      # 16-bit integers in the value joined by spaces.  Example:
      #
      #  record = Gdsii::RecData::BitArray.new([1234, 9876])
      #  record.to_s.inspect #=> "0000010011010010 0010011010010100"
      #
      def to_s()
        to_s_a.join(' ')
      end

      #
      # Converts an array of strings at 16 characters in length using 1's and
      # 0's to an array of respective integer values.
      #
      #  arr = Gdsii::RecData::BitArray.s_a_to_i_a(["0000010011010010"])
      #  arr.inspect #=> [1234]
      #
      # Also see #new for an example used in object construction.
      #
      def BitArray.s_a_to_i_a(value)
        string_arr = Data.coerce_value(value, String, :to_s)
        string_arr.map {|string| [string].pack("B16").unpack("n")[0]}
      end

    end

  end

end
