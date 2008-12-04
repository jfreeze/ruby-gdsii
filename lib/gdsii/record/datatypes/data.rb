
module Gdsii

  module RecData

    #
    # Generic class to represent various record data types.  This class is 
    # intended to be inherited and not called directly.
    #
    class Data

      # Data type integer represented by one of the Gdsii::GDT_ constants.
      attr_reader :type

      # Pointer to the parent record object
      attr_reader :record

      # 
      # Create a generic record data object.  Intended to be called internally
      # by Gdsii::RecType classes - not intended to be called directly.
      #
      def initialize(type, value, record=nil)
        if Data.valid_type?(type)
          @type = type
        else
          raise TypeError,
          "Invalid data type specified: #{type}"
        end
        @record = record
        self.value = value
      end

      # Quick access to the data value array.  Equivalent to self.value[index].
      def [](index); @value[index]; end

      # Check that the given data type (as an integer) is valid as defined by
      # the Gdsii::DATATYPE_INFO array.
      def Data.valid_type?(type)
        (0...DATATYPE_INFO.length).member?(type)
      end

      ########################################################################
      # DATA TYPE SHORTCUTS
      ########################################################################
    
      # Returns true if this record is an ASCII data type, false if not
      def is_ascii?(); @type == GDT_ASCII; end

      # Returns true if this record is an INT2 data type, false if not
      def is_int2?(); @type == GDT_INT2; end

      # Returns true if this record is an INT4 data type, false if not
      def is_int4?(); @type == GDT_INT4; end

      # Returns true if this record is a REAL8 data type, false if not
      def is_real8?(); @type == GDT_REAL8; end

      # Returns true if this record is a BITARRAY data type, false if not
      def is_bitarray?(); @type == GDT_BITARRAY; end

      # Returns true if this record is a NO_DATA data type, false if not
      def is_no_data?(); @type == GDT_NO_DATA; end

      # Returns true if this record is a REAL4 data type, false if not
      def is_real4?(); @type == GDT_REAL4; end


      ########################################################################
      # PROTECTED METHODS (private to this class)
      ########################################################################
  
      protected
      
      # Check the class for the given datum (single data element, NOT an array)
      # and raises an exception if the datum does not match the given class.
      def Data.ensure_class(datum, klass)
        unless datum.kind_of?(klass)
          raise TypeError,
          "#{self.class.to_s} value must be descended from #{klass}; given: '#{datum.class}'"
        end
      end
      
      # Ensures that the given value is descended from the Array class.  If
      # not, then an InvalidValue exception is raised.
      def Data.ensure_array(value)
        unless value.kind_of?(Array)
          raise TypeError,
          "All data must be descended from Array class; given: #{value.class}"
        end
      end
 
      # Generic method for setting a value.  The classes that inherit from
      # this class use this to coerce and validate their value.
      def Data.coerce_value(value, klass, coerce_method)
        Data.ensure_array value
        value.each_with_index do |datum, i|
          # Make sure that it matches the class; if not, try to coerce
          unless datum.kind_of?(klass) 
            if datum.respond_to?(coerce_method) then
              the_method = datum.method(coerce_method)
              value[i] = the_method.call
            end
            Data.ensure_class(value[i], klass)
          end
        end
        value
      end

    end
  end
end
