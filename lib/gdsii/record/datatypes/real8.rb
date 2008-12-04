require 'gdsii/record/datatypes/data.rb'

module Gdsii

  module RecData

    #
    # Class for REAL8 data type
    #
    class Real8 < Data
      
      # Value is an array of floating point numbers
      attr_reader :value

      # Construct an Gdsii::RecData::Real8 data object.  The value is an array
      # of floating point numbers (Float).
      def initialize(value)
        super(GDT_REAL8, value)
      end

      # Set the value for this object; verify that the value items are of
      # type Float (or at least can be coerced using "to_f").
      def value=(value)
        @value = Data.coerce_value(value, Float, :to_f)
      end

      # Returns the size of the record *data* in bytes.  Each array element
      # consumes 8 bytes (hence REAL8).
      def byte_size()
        @value.length * 8
      end

      # Reads a REAL8 record from the given file and for the length of bytes
      # given and returns a new Gdsii::RecData::Real8 object.
      def Real8.read(file, byte_count)
        data = []
        while (byte_count > 0)

          # read the first byte and get sign and exponent values from it
          raw = file.read(1)
          sign_val = raw.unpack('B')[0].to_i
          exponent = raw.unpack('C')[0]
          exponent -= (sign_val == 0) ? 64 : 192 # exponent is in Excess 64 fmt

          # read the rest of the real number - save as binary
          raw = file.read(7)
          mant_binary = raw.unpack('b*')[0]

          # convert mantissa from binary to decimal
          mantissa = 0.0
          (1...8).each do |i|
            str = mant_binary[(i-1)*8,8]
            ub = [("0"*32+str.reverse.to_s)[-32..-1]].pack("B32").unpack("N")[0]
            mantissa += ub / (256.0 ** i)
          end
          real = mantissa * (16**exponent)
          real = -real if (sign_val != 0)
          data.push real

          byte_count -= 8

        end

        Real8.new(data)
      end

      # Writes the integer values in this Gdsii::RecData::Real8 object to the
      # given file as a GDSII REAL8 record.
      def write(file)

        self.value.each do |item|

          if item == 0 then
            file.write "\x00" * 8
          else
            # Note: process differently for big endian?
            bit_str  = [item].pack('G').unpack('B*')[0]

            # get the sign and expt (IEEE)
            sign = bit_str[0,1]
            expt = ['00000'+bit_str[1,11]].pack('B16').unpack('n')[0] - 1023

            # Divide by 4 because 16**x == (2**4)**x == 2**(4*x)
            b16_expt = (expt / 4).floor
            b16_rem  = expt % 4

            # Shift the mantissa 4 bits to the right and increment the expt
            b16_expt += 1
            mant = ['0', '0', '0', '1', bit_str[12..63].split('')].flatten

            # Shift the mantissa to left to take care of the expt remainder
            (0...b16_rem).each do |i|
              mant.shift
              mant.push '0'
            end
            
            # Bias the base-16 expoent
            b16_expt += 64

            # Convert the expt to a 7-bit binary string
            b16_expt_str = [b16_expt].pack('C').unpack('B*')[0][1..7]

            # Now assemble the sign, expt and mantissa    
            real8_fmt = sign + b16_expt_str + mant.join('')
            file.write [real8_fmt].pack('B*')
          end

        end
      end
      
      # Converts the array of floating point values to a string (values are
      # joined by spaces).
      def to_s()
        value.map {|v| v.to_s}.join(' ')
      end
      
    end
  end
end

