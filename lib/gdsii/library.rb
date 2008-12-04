require 'time'
require 'gdsii/mixins'
require 'gdsii/group'
require 'gdsii/structure'

module Gdsii

  DEF_LIB_VERSION = 5
  DEF_LIB_UNITS = [0.001,1.0e-09]
  
  #
  # Represents a GDSII Library.
  #
  class Library < Group
    
    include Access::GdsiiTime
    
    #
    # Library BNF description:
    #   
    #  <lib>        ::= HEADER <libheader> {<structure>}* ENDLIB
    #  <libheader>  ::= BGNLIB [LIBDIRSIZE] [SRFNAME] [LIBSECUR]
    #                   LIBNAME [REFLIBS] [FONTS] [ATTRTABLE] [GENERATIONS]
    #                   [<FormatType>] UNITS
    #  <FormatType> ::= FORMAT  |  FORMAT {MASK}+ ENDMASKS
    #
    self.bnf_spec = BnfSpec.new(
      BnfItem.new(GRT_HEADER),
      BnfItem.new(GRT_BGNLIB),
      BnfItem.new(GRT_LIBDIRSIZE,true),
      BnfItem.new(GRT_SRFNAME, true),
      BnfItem.new(GRT_LIBSECUR, true),
      BnfItem.new(GRT_LIBNAME),
      BnfItem.new(GRT_REFLIBS, true),
      BnfItem.new(GRT_FONTS, true),
      BnfItem.new(GRT_ATTRTABLE, true),
      BnfItem.new(GRT_GENERATIONS, true),
      BnfItem.new(GRT_FORMAT, true),
      BnfItem.new(GRT_MASK, true, true),
      BnfItem.new(GRT_ENDMASKS, true),
      BnfItem.new(GRT_UNITS),
      BnfItem.new(Structures, true),
      BnfItem.new(GRT_ENDLIB)
    )
        
    #
    # Create a new GDSII Library object.
    #
    #  lib = Library.new('MYDESIGN.DB')
    #
    # The units may be specified during construction:
    #
    #  lib2 = Library.new('OTHER.DB', [0.001, 1e-9])
    #
    def initialize(name=nil, units=DEF_LIB_UNITS)
      super()
      @records[Structure] = []
      @records[GRT_ENDLIB] = Record.new(GRT_ENDLIB)
      
      self.header = DEF_LIB_VERSION
      self.name = name unless name.nil?
      self.units = units
      
      # Set modify/access time to the current time
      now = Time.now
      self.modify_time = now
      self.access_time = now

      yield self if block_given?
    end
    
    #
    # Access to the Structures object.  See Structures for a listing of
    # methods.
    #
    def structures(); @records.get(Structures); end

    #
    # Shortcut for Structures#add.  For example, instead of:
    #
    #  lib = Library.new('MYLIB.DB')
    #  lib.structures.add Structure.new('test')
    #
    # It could be simply:
    #
    #  lib.add Structure.new('test')
    #
    def add(*args); structures.add(*args); end

    #
    # Shortcut for Structures#remove.  For example, instead of:
    #
    #  lib.structures.remove {|s| true}
    #
    # It could be simply:
    #
    #  lib.remove {|s| true}
    #
    def remove(*args); structures.remove(*args); end

    #
    # Get the Library LIBNAME record (returns Record).
    #
    def name_record() @records.get(GRT_LIBNAME); end

    #
    # Get the Library name (returns String).
    #
    def name() @records.get_data(GRT_LIBNAME); end
  
    #
    # Set the Library name.
    #
    def name=(val) @records.set(GRT_LIBNAME, val); end
  
    #
    # Get the header record (returns Record).
    #
    def header_record() @records.get(GRT_HEADER); end

    #
    # Get the header number; this is the GDSII version (returns Fixnum).
    #
    def header() @records.get_data(GRT_HEADER); end
  
    #
    # Set the header number; this is the GDSII version.  Valid numbers are
    # 3, 4, 5, 6, and 7.  The default version used is defined by the
    # constant DEF_LIB_VER.
    #
    def header=(val) @records.set(GRT_HEADER, val); end

    alias :version= :header=
    alias :version :header

    #
    # Get the library directory size LIBDIRSIZE record (returns Record).
    #
    def dirsize_record() @records.get(GRT_LIBDIRSIZE); end

    #
    # Get the number of pages in the library directory (returns Fixnum).  This
    # is likely an old Calma record and is likely unused except in rare
    # circumstances.
    #
    def dirsize() @records.get_data(GRT_LIBDIRSIZE); end
  
    #
    # Set the number of pages in the library directory (see #dirsize for more
    # information).
    #
    def dirsize=(val) @records.set(GRT_LIBDIRSIZE, val); end

    #
    # Get the Library SRFNAME record (returns Record).
    #
    def srfname_record() @records.get(GRT_SRFNAME); end

    #
    # Get the Library Calma sticks rule file name (returns String).  This
    # is likely unused except in rare circumstances.
    #
    def srfname() @records.get_data(GRT_SRFNAME); end
  
    #
    # Set the Library Calma sticks rule file name (see #srfname for details).
    #
    def srfname=(val) @records.set(GRT_SRFNAME, val); end

    #
    # Get the library security LIBSECUR record (returns Record).
    #
    def secur_record() @records.get(GRT_LIBSECUR); end

    #
    # Get the secur number (returns Fixnum).  This is an array of 1-32
    # elements of an array of 3 elements; each containing Fixnum representing
    # (respectively): group number, user number, and access rights.  Since this
    # appears to be rarely used, no high-level methods are given to access this
    # record.  Returns an Array of Fixnum.
    #
    def secur() @records.get_data(GRT_LIBSECUR); end
  
    #
    # Set the library security number (see #secur for details)
    #
    def secur=(val) @records.set(GRT_LIBSECUR, val); end
   
    #
    # Get the fonts record (returns Record).
    #
    def fonts_record() @records.get(GRT_FONTS); end

    #
    # Get the array of paths to font definition files.  If this record exists,
    # then exactly 4 array elements should exist.  Each array element is a
    # String with a maximum of 44 characters.  Returns Array of Strings.
    #
    def fonts() @records.get_data(GRT_FONTS); end
  
    #
    # Set the path to 4 font definition files.  See #fonts for more details.
    #
    def fonts=(val) @records.set(GRT_FONTS, val); end

    #
    # Get the attribute table file location ATTRTABLE record (returns Record).
    #
    def attrtable_record() @records.get(GRT_ATTRTABLE); end

    #
    # Get the attribute table file location.  This is a String with a maximum
    # of 44 characters in length.  Returns String.
    #
    def attrtable() @records.get_data(GRT_ATTRTABLE); end
  
    #
    # Set the attribute table file location.  See #attrtable for more details.
    #
    def attrtable=(val) @records.set(GRT_ATTRTABLE, val); end

    #
    # Get the generations record (returns Record).
    #
    def generations_record() @records.get(GRT_GENERATIONS); end

    #
    # Get the generations number (returns Fixnum).  This number represents
    # how many structures should be retained as backup.  This is likely
    # rarely used.
    #
    def generations() @records.get_data(GRT_GENERATIONS); end
  
    #
    # Set the generations number.  See #generations for details.
    #
    def generations=(val) @records.set(GRT_GENERATIONS, val); end

    #
    # Get the format record (returns Record).
    #
    def format_record() @records.get(GRT_FORMAT); end

    #
    # Get the format number (returns Fixnum).  This number is used to indicate
    # if the stream file is an archive and/or filtered:
    #
    # 0: Archive
    # 1: Filtered
    #
    def format() @records.get_data(GRT_FORMAT); end
  
    #
    # Set the format number.  See #format for details.
    #
    def format=(val) @records.set(GRT_FORMAT, val); end

    #
    # True if #format == 0 indicating archive status; false if not.
    #
    def archive_format?(); format == 0; end
    
    #
    # True if #format == 1 indicating filtered status; false if not.
    #
    def filtered_format?(); format == 1; end

    #
    # Get the mask record (returns Record).
    #
    def mask_record() @records.get(GRT_MASK); end

    #
    # Get the MASK record (returns Array of String).  This is only used in
    # filtered (see #format) stream files.  This string represents ranges of
    # layers and datatypes separated by a semicolon.  There can be more than
    # one MASK defined.
    #
    def mask() @records.get_data(GRT_MASK); end
  
    #
    # Set the mask number.  See #mask for details.
    #
    def mask=(val) @records.set(GRT_MASK, val); end

    #
    # Get the units record (returns Record).
    #
    def units_record() @records.get(GRT_UNITS); end

    #
    # Get the units Array (returns 2 element Array of Float).  It may be easier
    # to use the #db_units, #user_units, and/or #m_units methods instead.  The
    # units record has two parts, respectively:
    #
    # 1. User units
    # 2. Database units
    #
    # The units in meters can be found by dividing database units by user units
    # (this calculation is done in #m_units).
    #
    def units(); @records.get_data(GRT_UNITS); end
  
    #
    # Set the units number.  See #units for details.  It may be easier to use
    # #db_units= or #user_units= instead.
    #
    def units=(val)
      if val.class == Array
        if val.length == 2
          @user_units, @database_units = val
          update_units
        else
          raise ArgumentError, "UNITS Array must have exactly 2 elements"
        end
      else
        raise TypeError, "Expecting 2 element Array; given: #{val.class}"
      end
    end

    #
    # Returns the user units (returns Float).  See #units for details.
    #
    def user_units(); @user_units; end
    
    #
    # Sets the user units.  See #units for details.
    #
    def user_units=(val)
      @user_units = val
      update_units
    end
    
    #
    # Returns the database units (returns Float).  See #units for details.
    #
    def database_units(); @database_units; end
  
    #
    # Sets the database units.  See #units for details.
    #
    def database_units=(val)
      @database_units = val
      update_units
    end

    #
    # Get the units in meters (returns Float).  Both user and database
    # units must be set.  The formula is:
    #
    # m_units = database_units / user_units
    #
    def m_units()
      ((u=user_units) and (d=database_units)) ? d/u : nil
    end

    #
    # Get the bgnlib record (returns Record).
    #
    def bgnlib_record() @records.get(GRT_BGNLIB); end

    #
    # Get the bgnlib number (returns Fixnum).  This holds the modify/access
    # time stamp for the library.  It is probably easier to not access this
    # directly but to use #modify_time and #access_time instead.
    #
    def bgnlib() @records.get_data(GRT_BGNLIB); end
  
    #
    # Set the bgnlib number.  The value is a Fixnum representation of the
    # modify/access time stamp for the library.  It is probably easier to
    # not access this directly but to use #modify_time= and #access_time=
    # instead.
    #
    def bgnlib=(val) @records.set(GRT_BGNLIB, val); end
    
    #
    # Accepts a Time object and sets the modify time for the library.
    #
    #  struct.modify_time = Time.now
    #
    def modify_time=(time)
      @modify_time = time
      update_times
    end

    #
    # Returns the modify time for this library (returns Time)
    #
    def modify_time(); @modify_time; end
    
    #
    # Accepts a Time object and sets the access time for the library.
    #
    #  struct.access_time = Time.now
    #
    def access_time=(time)
      @access_time = time
      update_times
    end

    #
    # Returns the access time for this library (returns Time)
    #
    def access_time(); @access_time; end

    #
    # Reads the Library header data of a GDSII file but does not read any
    # Structure records.  The Library object is returned (also yielded if
    # a block is given).
    #
    #  File.open(file_name, 'rb') do |file|
    #    Library.read_header(file) do |lib|
    #      puts "The GDSII library name is #{lib.name}"
    #    end
    #  end
    #
    # See Structure#read_each and Structure#read_each_header for more
    # detailed examples
    #
    def Library.read_header(file)
      Library.read(file, nil, nil, :before_group) do |lib|
        yield lib if block_given?
        break lib
      end
    end

    #
    # Writes only the header portion of the Library to a file.  This is useful
    # when streamlined writing is desired (for better performance or when
    # writing GDSII as another GDSII is being read).  Be sure to either:
    #
    # 1. Call #write_footer after writing the header and any Structure
    # objects; Or
    # 2. Pass a block whereupon the footer will automatically be added after
    # the block is processed.
    #
    # Example 1 (manually writing header/footer):
    #
    #  File.open(in_file, 'rb') do |inf|
    #    File.open(out_file, 'wb') do |outf|
    #      Library.read_header(inf) do |lib|
    #        lib.write_header(outf)
    #        Structure.read_each_header(inf) do |struct|
    #          struct.write_header(outf)
    #          Element.read_each(inf) {|element| element.write(outf)}
    #          struct.write_footer(outf)
    #        end
    #        lib.write_footer(outf)
    #      end
    #    end
    #  end
    #
    # Example 2 (using a block):
    #
    #  File.open(in_file, 'rb') do |inf|
    #    File.open(out_file, 'wb') do |outf|
    #      Library.read_header(inf) do |lib|
    #        lib.write_header(outf) do 
    #          Structure.read_each_header(inf) do |struct|
    #            struct.write_header(outf) do
    #              Element.read_each(inf) {|element| element.write(outf)}
    #            end
    #          end
    #        end
    #      end
    #    end
    #  end
    #
    def write_header(file)
      # alter the BNF to exclude Structures and ENDLIB; then write to file
      # according to the modified BNF
      alt_bnf = BnfSpec.new(*Library.bnf_spec.bnf_items[0..-3])
      self.write(file, alt_bnf)
      
      # if block is given, then yield to that block and then write the
      # footer afterwards
      if block_given?
        yield
        self.write_footer(file)
      end
    end

    #
    # Writes only the Library footer (just ENDLIB record) to file.  To be used
    # with #write_header.
    #
    def write_footer(file)
      Record.new(GRT_ENDLIB).write(file)
    end
    
    #####################
    ## PRIVATE METHODS ##
    #####################
    
    private
    
    # Used by #modify_time and #access_time
    def update_times()
      if modify_time and access_time
        self.bgnlib = build_time(modify_time) + build_time(access_time)
      else
        self.bgnlib = nil
      end
    end

    # Used by various units setting methods
    def update_units()
      if @user_units and @database_units
        @records.set(GRT_UNITS, [@user_units, @database_units])
      else
        @records.set(GRT_UNITS, nil)
      end
    end
    
  end
end

