require 'time'
require 'gdsii/mixins'
require 'gdsii/element'
require 'gdsii/boundary'
require 'gdsii/path'
require 'gdsii/text'
require 'gdsii/node'
require 'gdsii/box'
require 'gdsii/sref'
require 'gdsii/aref'

module Gdsii

  #
  # Represents a GDSII Structure.
  #
  class Structure < Group

    include Access::GdsiiTime
    
    #
    # Structure BNF description:
    #   
    #  <structure> ::= BGNSTR STRNAME [STRCLASS] {<element>}* ENDSTR
    #  <element>   ::= {<boundary> | <path> | <sref> | <aref> |
    #                  <text> | <node> | <box>}  {<property>}*  ENDEL
    #
    self.bnf_spec = BnfSpec.new(
      BnfItem.new(GRT_BGNSTR),
      BnfItem.new(GRT_STRNAME),
      BnfItem.new(GRT_STRCLASS, true),
      BnfItem.new(Elements, true),
      BnfItem.new(GRT_ENDSTR)
    )
    
    #
    # Creates a Structure object.  Various GDSII Elements are added to a
    # structure such as a Boundary, Path, SRef, ARef, Text, Node, and Box.
    #
    #  str_sub = Structure.new('sub')
    #  str_top = Structure.new('top')
    #  str_top.add SRef.new(str_sub)
    #  str_top.add Boundary.new(1, 0, [0,0, 0,10, 10,10, 10,0, 0,0])
    #
    def initialize(name=nil)
      # Create the record grouping
      super()
      @records[Elements] = Elements.new
      @records[GRT_ENDSTR] = Record.new(GRT_ENDSTR)

      # set the name
      self.name = name unless name.nil?

      # Set create/modify time to the current time
      now = Time.now
      self.create_time = now
      self.modify_time = now

      yield self if block_given?
    end

    #
    # Access to the Elements object.  See Elements for a listing of methods.
    #
    def elements(); @records.get(Elements); end

    #
    # Shortcut for Elements#add.  For example, instead of:
    #
    #  struct = Structure.new('test')
    #  struct.elements.add Text(1, 0, [0,0], 'hello')
    #
    # It could be simply:
    #
    #  struct.add Text(1, 0, [0,0], 'hello')
    #
    def add(*args); elements.add(*args); end

    #
    # Shortcut for Elements#remove.  For example, instead of:
    #
    #  struct.elements.remove {|e| e.class == Gdsii::Text}
    #
    # It could be simply:
    #
    #  struct.remove {|e| e.class == Gdsii::Text}
    #
    def remove(*args); elements.remove(*args); end

    #
    # Get the Structure STRNAME record (returns Record).
    #
    def name_record() @records.get(GRT_STRNAME); end

    #
    # Get the Structure name (returns String).
    #
    def name() @records.get_data(GRT_STRNAME); end
  
    #
    # Set the Structure name.
    #
    def name=(val) @records.set(GRT_STRNAME, val); end

    #
    # Get the strclass record (returns Record).
    #
    def strclass_record() @records.get(GRT_STRCLASS); end

    #
    # Get the strclass bitarray number (returns Fixnum).
    #
    def strclass() @records.get_data(GRT_STRCLASS); end
  
    #
    # Set the strclass bitarray number.  According to the GDSII specification,
    # this is only to be used by Calma - otherwise it should be omitted or
    # set to 0.  It is probably a good idea to not touch this property.
    #
    def strclass=(val) @records.set(GRT_STRCLASS, val); end
    
    #
    # Get the bgnstr record (returns Record).
    #
    def bgnstr_record() @records.get(GRT_BGNSTR); end

    #
    # Get the bgnstr number (returns Fixnum).  This holds the create/modify
    # time stamp for the structure.  It is probably easier to not access this
    # directly but to use #create_time and #modify_time instead.
    #
    def bgnstr() @records.get_data(GRT_BGNSTR); end
  
    #
    # Set the bgnstr number.  The value is a Fixnum representation of the
    # create/modify time stamp for the structure.  It is probably easier to
    # not access this directly but to use #create_time= and #modify_time=
    # instead.
    #
    def bgnstr=(val) @records.set(GRT_BGNSTR, val); end
    
    #
    # Accepts a Time object and sets the create time for the structure.
    #
    #  struct.create_time = Time.now
    #
    def create_time=(time)
      @create_time = time
      update_times
    end

    #
    # Returns the create time for this structure (returns Time)
    #
    def create_time(); @create_time; end
    
    #
    # Accepts a Time object and sets the modify time for the structure.
    #
    #  struct.modify_time = Time.now
    #
    def modify_time=(time)
      @modify_time = time
      update_times
    end

    #
    # Returns the modify time for this structure (returns Time)
    #
    def modify_time(); @modify_time; end

    #
    # Reads records related to a Structure header from the given file handle.
    # It is assumed that the file position is already at BGNSTR (likely after
    # Library#read_header).  The structure is yielded (if desired) and
    # returned.  The iterative version of this method is likely preferable
    # in most cases (Structure#read_each_header).
    #
    def Structure.read_header(file)
      Structure.read(file, nil, nil, :before_group) {|struct|
        yield struct if block_given?
        break struct
      }
    end

    #
    # Reads each Structure and its Elements from the given file handle.  Each
    # Structure is yielded after the entire Structure is read from the file.
    # Compare this with Structure#read_each_header which might be more
    # efficient, more streamlined, and consume less memory.
    #
    # The Library#read_header method must be called as a prerequisite (the file
    # handle must be at a BGNSTR record).
    #
    #  File.open(file_name, 'rb') do |file|
    #    Library.read_header(file) do |lib|
    #      Structure.read_each(file) do |struct|
    #        puts "#{struct.name} has #{struct.elements.length} elements"
    #      end
    #    end
    #  end
    #
    def Structure.read_each(file)
      while (Record.peek(file).type == GRT_BGNSTR) do
        yield Structure.read(file)
      end
    end

    #
    # Reads the Structure header records from a file handle but without reading
    # any Element records.  The resulting Structure element is yielded.  This
    # is useful for using the high-level GDSII access methods as a stream file
    # is being read in.
    #
    # Prior to using this method, the file position must be at the first
    # structure definition (i.e. after the Library header).  The best method
    # to do this is to call Library#read_header first.
    #
    # Also, you _MUST_ advance the file position to the next structure record
    # header (BGNSTR) either with Structure#seek_next or
    # Structure#read_each_element within the code block.  Otherwise the file
    # pointer will not be advanced properly and only the first Structure will
    # be yielded.
    #
    #  File.open(file_name, 'rb') do |file|
    #    Library.read_header(file) do |lib|
    #      Structure.read_each_header(file) do |struct|
    #        if struct.name == 'TOP'
    #          # Show all elements in structure "TOP"
    #          puts "Processing structure #{struct.name}"
    #          Element.read_each(file) do |element|
    #            puts "--> Element: #{element.class}"
    #          end
    #        else
    #          # Skip past elements in other blocks
    #          puts "Ignoring structure #{struct.name}"
    #          Structure.seek_next(file)
    #        end
    #      end
    #    end
    #  end
    #
    def Structure.read_each_header(file)
      while (Record.peek(file).type == GRT_BGNSTR) do
        yield Structure.read_header(file)
      end
    end

    #
    # Reads from the given file handle until a ENDSTR record is met (presumably
    # to a BGNSTR or ENDLIB record.  This effectively "skips" past all elements
    # within a structure and prepares the file handle to read the next
    # structure in the file (or ENDLIB if at the end of the GDSII library).
    # See Structure#read_each_header for an example.  The new file position is
    # returned.
    #
    # Compare this with Element#read_each which accomplishes the same thing
    # but instead yields each element as it is read from the file.
    #
    def Structure.seek_next(file)
      Record.read_each(file) do |record|
        break file.pos if record.is_endstr?
      end
      nil
    end
    
    #
    # Writes only the header portion of the Structure to a file (no elements).
    # This is useful when streamlined writing is desired (for better
    # performance or when writing GDSII as another GDSII is being read).  Be
    # sure to either:
    #
    # 1. Call #write_footer after writing the header and any Element
    # objects.  Also be sure to wrap this around Library#write_header and
    # Library#write_footer; Or
    # 2. Pass a block whereupon the footer will automatically be added after
    # the block is processed.
    #
    # See Library#write_header for an example.
    #
    def write_header(file)
      # alter the BNF to exclude Elements and ENDSTR; then write to file
      # according to the modified BNF
      alt_bnf = BnfSpec.new(*Structure.bnf_spec.bnf_items[0..-3])
      self.write(file, alt_bnf)

      # if block is given, then yield to that block and then write the
      # footer afterwards
      if block_given?
        yield
        self.write_footer(file)
      end
    end

    #
    # Writes only the Structure footer (just ENDSTR record) to file.  To be
    # used with #write_header.
    #
    def write_footer(file)
      Record.new(GRT_ENDSTR).write(file)
    end
  
    #####################
    ## PRIVATE METHODS ##
    #####################
    
    private
    
    # Used by #create_time and #modify_time
    def update_times()
      if create_time and modify_time
        self.bgnstr = build_time(create_time) + build_time(modify_time)
      else
        self.bgnstr = nil
      end
    end
   
  end

  ############################################################################

  #
  # Class to hold a collection of Structure objects.  This is used in the
  # Library class BNF.
  #
  class Structures < Group

    include Access::EnumerableGroup
    
    #
    # Structures BNF description:
    #   
    #  <structures> ::= {<structure>}*
    #  <structure>  ::= {<boundary> | <path> | <sref> | <aref> |
    #                   <text> | <node> | <box>}  {<property>}*  ENDEL
    #
    self.bnf_spec = BnfSpec.new(
      BnfItem.new(Structure, true, true)
    )

    #
    # Create an Structures object.
    #
    def initialize(structures=[])
      super()
      @records[Structure] = @list = structures
    end
    
  end

  
end
