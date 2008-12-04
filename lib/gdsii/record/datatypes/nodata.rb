require 'gdsii/record/datatypes/data.rb'

module Gdsii

  module RecData

    #
    # Store a GDSII NODATA data type.  This data type has no value.
    #
    class NoData < Data

      # Value will always be an empty array for a Gdsii::RecData::NoData object
      attr_reader :value
      
      # Construct an NoData data object.  No value is given because there
      # isn't a value for Gdsii::RecData::NoData.
      def initialize()
        super(GDT_NO_DATA, [])
      end

      # Throws an exception unless an empty arra is passed because there is
      # no data associated with a Gdsii::RecData::NoData object.
      def value=(value=[])
        Data.ensure_array value
        unless value.empty?
          raise ArgumentError,
          "GDT_NO_DATA must have an empty array; given length: #{value.length}"
        end
        @value = value
      end

      # Returns the size of the record *data* in bytes.  Since a
      # Gdsii::RecData::NoData object has no data, 0 is always returned.
      def byte_size(); 0; end

      # Reads a NO_DATA record from the given file object and returns a
      # new Gdsii::RecData::NoData object.
      def NoData.read(file, byte_count=0)
        # validate byte count
        if byte_count > 0 then
          raise ArgumentError,
          "GDT_NO_DATA expects 0 bytes of record length; requested: #{byte_count}"
        end
        NoData.new()
      end

      # Performs no operation since there is no data in a Gdsii::RecType::NoData
      # object to write to a file.  However this method is necessary so that
      # it can respond to methods common to other Gdsii::RecType::Data
      # descended classes.
      def write(file); end

      # Returns an empty string (which represents no data).
      def to_s(); ''; end

    end

  end

end 
