require 'gdsii/record/datatypes/data'

module Gdsii

  module RecData

    #
    # Class for ASCII data type
    #
    class Ascii < Data

      # Value is an array of strings.  Most Gdsii::RecData::Ascii records only
      # have a single value.
      attr_reader :value
      
      # Construct an Gdsii::RecData::Ascii data object.  The value is an array
      # of strings (String).
      def initialize(value, record=nil)
        super(GDT_ASCII, value, record)
      end

      # Set the value for this object; verify that the value items are of
      # type String (or at least can be coerced using "to_s").
      def value=(value)
        @value = Data.coerce_value(value, String, :to_s)
      end

      # Returns the size of the record *data* in bytes.  This will *always*
      # return an even-length (multiple of 2) number since odd-length GDSII
      # strings are padded with null characters when written to a file.  If the
      # record type has a specific size (i.e. Gdsii::GRT_FONTS and
      # Gdsii::GRT_REFLIBS) then that size will automatically be used for each
      # element in the value array.
      def byte_size()
        if @record and RECORD_INFO[@record.type].size > 0 then
          RECORD_INFO[@record.type].size * @value.length
        else
          sum = 0
          @value.each do |val|
            sum += (val.length % 2 == 0) ? val.length : val.length + 1
          end
          sum
        end
      end

      # Return value with stripped off trailing null characters (which are
      # present when reading this record from a file).  For example, assuming
      # that a record is read from a file and is a null padded string
      # "hello\0", then:
      #
      #  record.inspect         #=> ["hello\0"]
      #  record.unpad.inspect   #=> ["hello"]
      #
      # dmi unpad modified for use in ruby versions > 1.9
      def unpad_1_9()
        new_arr = []
        @value.each do |string|
          string = string.dup    # to avoid changing the original
          while (string.getbyte(-1) == 0) 
            string.chop!
          end
          new_arr.push string
        end
        new_arr
      end

      # dmi Original unpad
      def unpad_1_8()
        new_arr = []
        @value.each do |string|
          string = string.dup    # to avoid changing the original
          while (string[-1] == 0) 
            string.chop!
          end
          new_arr.push string
        end
        new_arr
      end

      # Choose an unpad appropriate for the Ruby version.
      # Comparison's with versions before 1.8.0 of ruby don't work here.
      # Attempts to use the output of Gem::Version('1.9.0') for
      # version comparisons require rubygems be loaded for 1.8 and
      # earlier versions of ruby complains when rubygems are missing.
      # If you've got a solution that quietly determines if we have a
      # ruby version 1.9.0 or later please fix the following:
      if Gdsii::is_1_9_or_later?
        alias_method :unpad, :unpad_1_9
      else
        alias_method :unpad, :unpad_1_8
      end

      # Same as #unpad but modifies the value of this object.
      def unpad!()
        @value = unpad
      end

      # Pad the value with a null character if the string is odd (but do not
      # change the value itself).  If a desired string length is given, then
      # the string will be padded by the length given.  For example, if we
      # created a record with the string "hello", then padding will add a
      # null character since "hello" has an odd number of characters:
      #
      #  record = Gdsii::RecType::Ascii.new(["hello"])
      #  record.pad.inspect                            #=> ["hello\0"]
      #
      def pad(str_length=nil)
        new_arr = []
        @value.each_with_index do |string, i|
          string = string.dup    # to avoid changing the original
          if str_length.nil? then
            # pad if the string is odd or use the size property if there is a
            # predefined size
            if @record and (size=RECORD_INFO[@record.type].size) > 0 then
              new_arr.push [string].pack("a#{size}")
            elsif (len=string.length)%2 == 1 then
              new_arr.push [string].pack("a#{len+1}")
            else
              new_arr.push string
            end
          else
            # A desired string length was given; ensure that the requested
            # length is a multiple of 2 and is not less than the string given.
            if str_length%2 == 1 then
              raise ArgumentError,
              "Desired string length must be a multiple of 2"
            elsif str_length < string.length then
              raise ArgumentError,
              "Desired string length given #{str_length} is less than actual string length #{string.length}"
            else
              new_arr.push [string].pack("a#{str_length}")
            end          
          end
        end
        new_arr
      end

      # Same as #pad except the value of this object is modified.
      def pad!(str_length=nil)
        @value = pad(str_length)
      end

      # Reads an ASCII record from the given file for the length of bytes
      # given and returns a new Gdsii::RecData::Ascii object.
      def Ascii.read(file, byte_count)
        # Verify byte count is even
        if byte_count%2 == 1 then
          raise ArgumentError,
          "GDT_ASCII records must have an even length; requested: #{byte_count}"
        end

        # read the string in; unpad; and return the new Gdsii::Ascii object
        raw = file.read(byte_count)
        string = raw.unpack("a#{byte_count}")
        data = Ascii.new(string)
        data.unpad!
      end

      # Writes the string values in this Gdsii::RecData::Ascii object to the
      # given file as a GDSII ASCII record.
      def write(file)
        padded_str = self.pad
        if padded_str.length != 1
          raise RuntimeError, "expect 'self' to be an array of one element"
        end
        # The following line was modified to use the [0]. Before, no
        # index was used and the call to file.write() coerced the array
        # to a string.  Under Ruby 1.8 this produced a string like:
        #     "aString"
        # under 1.9 we go a string like:
        #     "[\\"aString\\"]"
		# This, among other things, produced invalid library names.
        file.write padded_str[0]
      end

      # Joins all strings in the array with spaces and returns the joined
      # string.
      def to_s(); self.unpad[0] end

    end
  end
end
