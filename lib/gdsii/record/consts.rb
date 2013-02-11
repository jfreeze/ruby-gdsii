module Gdsii

  #
  # Class to store information about each record type.  The Gdsii::RECORD_INFO
  # constant is an array with an index of the record type number and the value
  # being instances of this class.  For example:
  #
  #  Gdsii::RECORD_INFO[Gdsii::GRT_HEADER].name    #=> 'HEADER'
  #  Gdsii::RECORD_INFO[Gdsii::GRT_XY].min_len     #=> 4
  #
  # See the Gdsii module for a complete listing of record type constants
  # (Gdsii::GRT_*).
  #
  class RecInfo

    # Name of this record (should be the same as the Gdsii::GRT_* name but
    # without the "Gdsii::GRT_".
    attr_reader :name

    # Record type is an integer of the constant Gdsii::GRT_* for this record
    # type.
    attr_reader :type

    # Boolean as to whether or not this record is a valid GDS record (some
    # records are not valid to the GDS specification)
    attr_reader :valid

    # Data type is an integer of the constant Gdsii::GDT_* for this record.
    # This represents the data type expected for this record.
    attr_reader :data_type

    # Size indicates how many bytes are necessary to store each element of
    # this record.  For example, the size of a Gdsii::GRT_XY record is 8 with a
    # record size of 4 bytes for each record (since it's a Gdsii::GDT_INT4).
    # This means that the minimum number of items needed (#min_items) is 2.
    attr_reader :size

    # Minimum length (in bytes) to store this record
    attr_reader :min_len

    # Maximum length (in bytes) to store this record
    attr_reader :max_len

    # Object constructor.  Intended to be used internally only to add elements
    # to the Gdsii::RECORD_INFO array.
    def initialize(name, data_type, valid, size, min_len, max_len)
      @name = name
      @data_type = data_type
      @valid = valid
      @size = size
      @min_len = min_len
      @max_len = max_len
    end

    # Returns the minimum number of items necessary for this record type.
    def min_items
      case @data_type
      when GDT_NO_DATA
		  0
      when GDT_ASCII
		  (@size == 0) ? 1 : @min_len/@size
      else 
        @min_len/@size
      end
    end

    # Returns the maximum number of items necessary for this record type.
    def max_items
      case @data_type
      when GDT_NO_DATA
		  0
      when GDT_ASCII
		  (@size == 0) ? 1 : @max_len/@size
      else 
        @max_len/@size
      end
    end

    # Returns true if this object has only a single datum; false if it can
    # have multiple data.
    def single_data_value?
      if @data_type == GDT_ASCII
        @size == 0
      else
        @size == @min_len and @size == @max_len
      end
    end

    # Converts this record to a string (returns the record's name)
    def to_s(); @name; end

  end

  ############################################################################

  #
  # Class to store information about each record data type.  The
  # Gdsii::DATATYPE_INFO array has an index of GDT_* integer values with the
  # value being an instance of this class.  For example:
  #
  #  Gdsii::RECORD_INFO[Gdsii::GDT_ASCII].name     #=> 'ASCII'
  #  Gdsii::RECORD_INFO[Gdsii::GDT_REAL4].valid    #=> false
  #
  class RecDataTypeInfo

    # Name of this record data type (should be the same as the Gdsii::GDT_* name
    # but without the "Gdsii::GDT_".
    attr_reader :name

    # Boolean value indicating whether or not this record data type is valid.
    attr_reader :valid

    # Integer value indicating the size (in bytes) required for this data
    # type.  The exception is Gdsii::GDT_ASCII which has a size of 0 but in
    # actuality has a variable-length size.
    attr_reader :size

    # Object constructor.  Intended to be used internally only to add elements
    # to the Gdsii::DATATYPE_INFO array.
    def initialize(name, valid, size)
      @name = name
      @valid = valid
      @size = size
    end
    
    # Returns the data type's name
    def to_s(); @name; end

  end

  ############################################################################

  # These numbers correspond to GDSII format indicating the path types
  if not defined?(PATHTYPE_FLUSH)
    PATHTYPE_FLUSH     = 0
    PATHTYPE_ROUND     = 1
    PATHTYPE_EXTEND    = 2
    PATHTYPE_CUSTOM    = 4

    # These numbers correspond to GDSII format
    FORMAT_GDSII_ARCHIVE   = 0
    FORMAT_GDSII_FILTERED  = 1
    FORMAT_EDSIII_ARCHIVE  = 2
    FORMAT_EDSIII_FILTERED = 3

    # These are GDSII record numbers and correspond to the GDSII number in the
    # GDSII file specification
    GRT_HEADER         = 0
    GRT_BGNLIB         = 1
    GRT_LIBNAME        = 2
    GRT_UNITS          = 3
    GRT_ENDLIB         = 4
    GRT_BGNSTR         = 5
    GRT_STRNAME        = 6
    GRT_ENDSTR         = 7
    GRT_BOUNDARY       = 8
    GRT_PATH           = 9
    GRT_SREF           = 10

    GRT_AREF           = 11
    GRT_TEXT           = 12
    GRT_LAYER          = 13
    GRT_DATATYPE       = 14
    GRT_WIDTH          = 15
    GRT_XY             = 16
    GRT_ENDEL          = 17
    GRT_SNAME          = 18
    GRT_COLROW         = 19
    GRT_TEXTNODE       = 20

    GRT_NODE           = 21
    GRT_TEXTTYPE       = 22
    GRT_PRESENTATION   = 23
    GRT_SPACING        = 24
    GRT_STRING         = 25
    GRT_STRANS         = 26
    GRT_MAG            = 27
    GRT_ANGLE          = 28
    GRT_UINTEGER       = 29
    GRT_USTRING        = 30

    GRT_REFLIBS        = 31
    GRT_FONTS          = 32
    GRT_PATHTYPE       = 33
    GRT_GENERATIONS    = 34
    GRT_ATTRTABLE      = 35
    GRT_STYPTABLE      = 36
    GRT_STRTYPE        = 37
    GRT_ELFLAGS        = 38
    GRT_ELKEY          = 39
    GRT_LINKTYPE       = 40

    GRT_LINKKEYS       = 41
    GRT_NODETYPE       = 42
    GRT_PROPATTR       = 43
    GRT_PROPVALUE      = 44
    GRT_BOX            = 45
    GRT_BOXTYPE        = 46
    GRT_PLEX           = 47
    GRT_BGNEXTN        = 48
    GRT_ENDEXTN        = 49
    GRT_TAPENUM        = 50

    GRT_TAPECODE       = 51
    GRT_STRCLASS       = 52
    GRT_RESERVED       = 53
    GRT_FORMAT         = 54
    GRT_MASK           = 55
    GRT_ENDMASKS       = 56
    GRT_LIBDIRSIZE     = 57
    GRT_SRFNAME        = 58
    GRT_LIBSECUR       = 59
    GRT_BORDER         = 60

    GRT_SOFTFENCE      = 61
    GRT_HARDFENCE      = 62
    GRT_SOFTWIRE       = 63
    GRT_HARDWIRE       = 64
    GRT_PATHPORT       = 65
    GRT_NODEPORT       = 66
    GRT_USERCONSTRAINT = 67
    GRT_SPACER_ERROR   = 68
    GRT_CONTACT        = 69

    # GDSII record data types
    GDT_NO_DATA  = 0
    GDT_BITARRAY = 1
    GDT_INT2     = 2
    GDT_INT4     = 3
    GDT_REAL4    = 4
    GDT_REAL8    = 5
    GDT_ASCII    = 6

  end

  if not defined?(RECORD_INFO)

    # Gdsii::RECORD_INFO is an array of Gdsii::RecInfo objects.  The array order
    # is significant in that the index of the array is the value of the record
    # and corresponds to the Gdsii::GRT_* constant values.  This allows easy
    # validation lookup based upon the record type constants.  Example:
    #
    #  Gdsii::RECORD_INFO[Gdsii::GRT_HEADER].name         # => "HEADER"
    #  Gdsii::RECORD_INFO[Gdsii::GRT_HEADER].valid        # => true
    #  Gdsii::RECORD_INFO[Gdsii::GRT_HEADER].data_type    # => 2
    #
    RECORD_INFO =
  [
   #           name              data_type     valid  size  minlen  maxlen num
   RecInfo.new('HEADER',         GDT_INT2,     true,     2,    2,     2), #  0 - GDS version
   RecInfo.new('BGNLIB',         GDT_INT2,     true,     2,   24,    24), #  1 - Modification & access time
   RecInfo.new('LIBNAME',        GDT_ASCII,    true,     0,    0, 65530), #  2
   RecInfo.new('UNITS',          GDT_REAL8,    true,     8,   16,    16), #  3
   RecInfo.new('ENDLIB',         GDT_NO_DATA,  true,     0,    0,     0), #  4
   RecInfo.new('BGNSTR',         GDT_INT2,     true,     2,   24,    24), #  5

   RecInfo.new('STRNAME',        GDT_ASCII,    true,     0,    2,   512), #  6
   RecInfo.new('ENDSTR',         GDT_NO_DATA,  true,     0,    0,     0), #  7
   RecInfo.new('BOUNDARY',       GDT_NO_DATA,  true,     0,    0,     0), #  8
   RecInfo.new('PATH',           GDT_NO_DATA,  true,     0,    0,     0), #  9
   RecInfo.new('SREF',           GDT_NO_DATA,  true,     0,    0,     0), # 10

   RecInfo.new('AREF',           GDT_NO_DATA,  true,     0,    0,     0), # 11
   RecInfo.new('TEXT',           GDT_NO_DATA,  true,     0,    0,     0), # 12
   RecInfo.new('LAYER',          GDT_INT2,     true,     2,    2,     2), # 13
   RecInfo.new('DATATYPE',       GDT_INT2,     true,     2,    2,     2), # 14
   RecInfo.new('WIDTH',          GDT_INT4,     true,     4,    4,     4), # 15

   RecInfo.new('XY',             GDT_INT4,     true,     4,    8, 65528), # 16
   RecInfo.new('ENDEL',          GDT_NO_DATA,  true,     0,    0,     0), # 17
   RecInfo.new('SNAME',          GDT_ASCII,    true,     0,    2, 65530), # 18
   RecInfo.new('COLROW',         GDT_INT2,     true,     2,    4,     4), # 19
   RecInfo.new('TEXTNODE',       GDT_NO_DATA,  true,     0,    0,     0), # 20

   RecInfo.new('NODE',           GDT_NO_DATA,  true,     0,    0,     0), # 21
   RecInfo.new('TEXTTYPE',       GDT_INT2,     true,     2,    2,     2), # 22
   RecInfo.new('PRESENTATION',   GDT_BITARRAY, true,     2,    2,     2), # 23
   RecInfo.new('SPACING',        0,            false,    0,    0,     0), # 24
   RecInfo.new('STRING',         GDT_ASCII,    true,     0,    2,   512), # 25

   RecInfo.new('STRANS',         GDT_BITARRAY, true,     2,    2,     2), # 26
   RecInfo.new('MAG',            GDT_REAL8,    true,     8,    8,     8), # 27
   RecInfo.new('ANGLE',          GDT_REAL8,    true,     8,    8,     8), # 28
   RecInfo.new('UINTEGER',       0,            false,    0,    0,     0), # 29
   RecInfo.new('USTRING',        0,            false,    0,    0,     0), # 30
   
   RecInfo.new('REFLIBS',        GDT_ASCII,    true,    44,   88,   748), # 31
   RecInfo.new('FONTS',          GDT_ASCII,    true,    44,  176,   176), # 32 - paths to text font def files
   RecInfo.new('PATHTYPE',       GDT_INT2,     true,     2,    2,     2), # 33
   RecInfo.new('GENERATIONS',    GDT_INT2,     true,     2,    2,     2), # 34
   RecInfo.new('ATTRTABLE',      GDT_ASCII,    true,     0,    2,    44), # 35 - path of attr def file

   RecInfo.new('STYPTABLE',      0,            false,    0,    0,     0), # 36
   RecInfo.new('STRTYPE',        0,            false,    0,    0,     0), # 37
   RecInfo.new('ELFLAGS',        GDT_BITARRAY, true,     2,    2,     2), # 38
   RecInfo.new('ELKEY',          0,            false,    0,    0,     0), # 39
   RecInfo.new('LINKTYPE',       0,            false,    0,    0,     0), # 40

   RecInfo.new('LINKKEYS',       0,            false,    0,    0,     0), # 41
   RecInfo.new('NODETYPE',       GDT_INT2,     true,     2,    2,     2), # 42
   RecInfo.new('PROPATTR',       GDT_INT2,     true,     2,    2,     2), # 43
   RecInfo.new('PROPVALUE',      GDT_ASCII,    true,     0,    2,   126), # 44
   RecInfo.new('BOX',            GDT_NO_DATA,  true,     0,    0,     0), # 45

   RecInfo.new('BOXTYPE',        GDT_INT2,     true,     2,    2,     2), # 46
   RecInfo.new('PLEX',           GDT_INT4,     true,     4,    4,     4), # 47
   RecInfo.new('BGNEXTN',        GDT_INT4,     true,     4,    4,     4), # 48
   RecInfo.new('ENDEXTN',        GDT_INT4,     true,     4,    4,     4), # 49
   RecInfo.new('TAPENUM',        GDT_INT2,     true,     2,    2,     2), # 50

   RecInfo.new('TAPECODE',       GDT_INT2,     true,     2,   12,    12), # 51
   RecInfo.new('STRCLASS',       GDT_BITARRAY, true,     2,    2,     2), # 52
   RecInfo.new('RESERVED',       0,            false,    0,    0,     0), # 53
   RecInfo.new('FORMAT',         GDT_INT2,     true,     2,    2,     2), # 54 - GdsiiFormat type
   RecInfo.new('MASK',           GDT_ASCII,    true,     0,    2, 65530), # 55

   RecInfo.new('ENDMASKS',       GDT_NO_DATA,  true,     0,    0,     0), # 56
   RecInfo.new('LIBDIRSIZE',     GDT_INT2,     true,     2,    2,     2), # 57 - # of pages in lib dir
   RecInfo.new('SRFNAME',        GDT_ASCII,    true,     0,    2, 65530), # 58 - name of spacing rules file
   RecInfo.new('LIBSECUR',       GDT_INT2,     true,     2,    6,   192), # 59 - array of ACL data
   RecInfo.new('BORDER',         GDT_NO_DATA,  true,     0,    0,     0), # 60

   RecInfo.new('SOFTFENCE',      GDT_NO_DATA,  true,     0,    0,     0), # 61
   RecInfo.new('HARDFENCE',      GDT_NO_DATA,  true,     0,    0,     0), # 62
   RecInfo.new('SOFTWIRE',       GDT_NO_DATA,  true,     0,    0,     0), # 63
   RecInfo.new('HARDWIRE',       GDT_NO_DATA,  true,     0,    0,     0), # 64
   RecInfo.new('PATHPORT',       GDT_NO_DATA,  true,     0,    0,     0), # 65

   RecInfo.new('NODEPORT',       GDT_NO_DATA,  true,     0,    0,     0), # 66
   RecInfo.new('USERCONSTRAINT', GDT_NO_DATA,  true,     0,    0,     0), # 67
   RecInfo.new('SPACER_ERROR',   GDT_NO_DATA,  true,     0,    0,     0), # 68
   RecInfo.new('CONTACT',        GDT_NO_DATA,  true,     0,    0,     0), # 69
  ]
    
  #
  # Gdsii::DATATYPE_INFO is an array of Gdsii::RecDataTypeInfo objects.  The array
  # order is significant in that the index of the array is the value of the
  # record data type constant.  This allows easy validation lookup based upon
  # the record data type constants.  Example:
  #
  #  Gdsii::DATATYPE_INFO[Gdsii::GRT_REAL8].name         # => "REAL8"
  #  Gdsii::DATATYPE_INFO[Gdsii::GRT_REAL8].valid        # => true
  #  Gdsii::DATATYPE_INFO[Gdsii::GRT_REAL8].size         # => 8
  #
  DATATYPE_INFO =
  [
   RecDataTypeInfo.new('NO_DATA',  true,  0  ), # 0
   RecDataTypeInfo.new('BITARRAY', true,  2  ), # 1
   RecDataTypeInfo.new('INT2',     true,  2  ), # 2
   RecDataTypeInfo.new('INT4',     true,  4  ), # 3
   RecDataTypeInfo.new('REAL4',    false, 4  ), # 4
   RecDataTypeInfo.new('REAL8',    true,  8  ), # 5
   RecDataTypeInfo.new('ASCII',    true,  0  ), # 6 ; string len is variable
  ]
  end
  
  # Returns the name for given record type if it is found; if not, then
  # the record number formatted as a String is returned
  def grt_name(grt_number)
    if grt_number.class == Fixnum
      if (0..RECORD_INFO.length-1).member?(grt_number)
        RECORD_INFO[grt_number].name
      else
        grt_number.to_s
      end
    else
      grt_number.inspect
    end
  end
  
  # Returns the name for given record data type if it is found; if not, then
  # the record data type number formatted as a String is returned
  def gdt_name(gdt_number)
    if gdt_number.class == Fixnum
      if (0..DATATYPE_INFO.length-1).member?(gdt_number)
        DATATYPE_INFO[gdt_number].name
      else
        gdt_number.to_s
      end
    else
      gdt_number.inspect
    end
  end
  
  module_function :grt_name
  module_function :gdt_name

end
