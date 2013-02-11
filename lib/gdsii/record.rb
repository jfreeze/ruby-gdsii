require 'gdsii/byte_order.rb'
require 'gdsii/record/consts'
require 'gdsii/record/datatypes/data.rb'
require 'gdsii/record/datatypes/ascii.rb'
require 'gdsii/record/datatypes/int2.rb'
require 'gdsii/record/datatypes/int4.rb'
require 'gdsii/record/datatypes/real4.rb'
require 'gdsii/record/datatypes/real8.rb'
require 'gdsii/record/datatypes/bitarray.rb'
require 'gdsii/record/datatypes/nodata.rb'

module Gdsii

  #
  # Basic class for interacting with GDSII records.  This class can be used
  # directly to do low-level GDSII file manipulations.  Accordingly, a good
  # working knowledge of the GDSII file structure is required when using this
  # class directly.
  #
  # For higher-level GDSII manipulations that don't require as much knowledge
  # of the GDSII file structure consider using the high-level classes such
  # as Library, Structure, Boundary, Path, Text, etc.
  #
  class Record

    include Gdsii::RecData

    #
    # Class level methods/attributes
    #
    class << self

      # A true value indicates that debugging messages should be enabled when
      # reading a GDSII file.  A false (or nil) value will suppress the
      # messages.
      def read_debug(); @debug; end

      # Sets the debugging value for reading GDSII records.
      def read_debug=(value); @debug = value; end
      
    end

# TODO: decide on this...
    # Used internally to track the last value of a UNITS record for a given
    # file object.  This allows the "to string" (#to_s) method for subequent
    # records to apply user units when reporting WIDTH and XY record types
#    @@file_user_units = {}

    # The integer value corresponding to one of the Gdsii::GRT_* constants.  This
    # indicates the record type for this record.
    attr_reader :type

    # The pointer to the data object for this record (descended from
    # the Gdsii::RecData::Data class).
    attr_reader :data

    #
    # Construct a GDSII record object given a record type (an integer
    # represented by one of the Gdsii::GRT_* constants) and also the given data.
    # The data may be given as a single element or as an array.  Data is not
    # required for records who have data types Gdsii::GDT_NO_DATA.  Examples:
    #
    #  header = Gdsii::Record.new(Gdsii::GRT_ENDLIB)
    #  string = Gdsii::Record.new(Gdsii::GRT_STRING, "Hello World!")
    #  xy = Gdsii::Record.new(Gdsii::GRT_XY, [0,0, 0,10, 10,10, 10,0, 0,0])
    #
    def initialize(type, data=nil)
      # Verify then set the record type
      @type = type
      ensure_valid_type
      self.data = data
    end

    # Set the data for this record.  The value can be a Gdsii::RecData::Data
    # descendant or the data in its raw form.  In cases where data can be
    # given as an array of items, then an array of these raw items is also 
    # acceptable.  Examples:
    #
    #  val = Gdsii::RecData
    #
    #  string = Gdsii::Record.new(Gdsii::GRT_STRING, "hi")
    #  string.data = "hello"
    #
    #  xy = Gdsii::Record.new(Gdsii::GRT_XY, [0,0, 10,10, 20,10, 30,0, 0,0])
    #  xy.data = xy.value.reverse
    #
    #  xy = Gdsii::Record.new(Gdsii::GRT_XY, [0,0])
    #  xy.data = Gdsii::RecData::Real8.new([10,10]) 
    #
    def data=(data)
      # Set the data based upon what was given: Gdsii::Data object, a single
      # object, or an array
      if data.kind_of?(Data) then
        # Data given is already descended of Gdsii::Data; leave as-is
        @data = data
      else
        # Raw data given; convert to the appropriate data type object; also
        # put into an array if it is not given as an array
        unless data.kind_of?(Array) 
          data = data.nil? ? [] : [data]
        end
        
        # convert to a data type object
        @data = case RECORD_INFO[type].data_type
                when GDT_ASCII
					Ascii.new(data, self)
                when GDT_INT2
					Int2.new(data)
                when GDT_INT4
					Int4.new(data)
                when GDT_REAL8
					Real8.new(data)
                when GDT_BITARRAY
					BitArray.new(data)
                when GDT_NO_DATA
					NoData.new()
                when GDT_REAL4
					Real4.new(data)
                else
                  raise TypeError, "Given record type (#{type}) is invalid"
                end
      end
      
      # TODO: maybe remove; had issues with FONT record type when
      # reading a GDSII file where data length is calculatd after the first
      # elmement and doesn't meet the correct size as a result.
      # Verify that the data length is OK
      #ensure_data_length_valid
    end

    #
    # Returns the value of the data for this record.  This method differs
    # from #data.value because #data.value will always return an array of
    # data.  This method (#data_value) will return the value as a single
    # object (not an array) if the record type is singular.  Otherwise if
    # the record type is multiple, then an Array of values is returned
    # (just like #data.value).
    #
    def data_value()
      (single_data_value?) ? @data.value[0] : @data.value
    end

    #
    # True if the data value is single or if there are multiple entries
    # (based upon the RECORD_INFO constant for this record type).
    #
    def single_data_value?
      RECORD_INFO[type].single_data_value?
    end

    # Quick index lookup for the data property; same as self.data[index].
    # Example:
    #
    #  xy = Gdsii::Record.new(Gdsii::GRT_XY, [10,20])
    #  xy[0] #=> 10
    #
    def [](index); @data[index]; end

    # Returns the size of this record in bytes (4 bytes header plus data
    # byte size)
    def byte_size(); @data.byte_size + 4; end

    # Check that the given record type is valid.  The default is to check
    # the current object type.  If a type is supplied, then the type given
    # is checked.
    def Record.valid_type?(type)
      (0...RECORD_INFO.length).member?(type)
    end

    # Ensures that the current type value for this record is valid.  If it is
    # not then an TypeError exception is raised.
    def ensure_valid_type(type=@type)
      unless Record.valid_type? type
        raise TypeError, "Invalid record type: '#{type}'"
      end
    end

    # Ensures that the length of the data given is valid for this record
    # according to the Gdsii::RECORD_INFO array.  If the length is not valid
    # then an ArgumentError exception is raised.
    def ensure_data_length_valid(type=@type, data_len=@data.byte_size)
      min = RECORD_INFO[type].min_len
      max = RECORD_INFO[type].max_len
      unless ((min..max).member?(data_len)) 
        raise ArgumentError,
        "Data length of #{data_len} is not in the range expected for record '#{self.name}' (#{min}..#{max})"
      end
    end

    # Reads the next GDSII record from the given file object and returns
    # a Gdsii::Record object.  If EOF is reached in the file or if the record
    # is a null-space, then nil is returned.  Example:
    #
    #  # Note: 'rb' is required for DOS/Windows compatibility
    #  File.open('mydesign.gds', 'rb') do |file|
    #    record = Gdsii::Record.read(file)
    #    # your code here...
    #  end
    #
    def Record.read(file, record_filter=nil)

      begin
        # Get the file position to save for error reporting
        orig_file_pos = file.pos
        
        # Read the header, first two bytes are length, second two are
        # record type and data type
        raw = file.read(4)
        
        # If the 4 bytes weren't read or if this record has no contents
        # (some GDSII files are null padded at the end) then return nil
        if raw.nil? or raw == "\000\000" then
          return nil
        end

        # get the record's length
        reclen = raw[0,2]
        reclen.reverse! if (ByteOrder::little_endian?)
        reclen = reclen.unpack('S')[0]

        # get the record type
        type = raw[2,1]
        type = type.unpack('c')[0]
       
        # get the record's data type
        data_type = raw[3,1]
        data_type = data_type.unpack('c')[0]
        
        # reclen includes length of header data, must subtract
        bytes_left = reclen - 4
        
        # if we are filtering records and this record type is not in the
        # filter, then return nil; else continue.        
        if record_filter and not record_filter.member?(type)
          file.seek(bytes_left, IO::SEEK_CUR)
          return nil
        end

        if bytes_left < 0 then
          if type == 0 then
            # GDSII file is sometimes padded with null characters at the
            # end of the file... so just stop parsing at this point
            return nil
          else
            raise ArgumentError,
            "Record (#{self.name}) data length is negative: #{bytes_left}"
          end
        end

        # Print a debugging message for this record if desired
        if Record.read_debug
          printf("Address = 0x%06x (%08d) ; Record = %14s (%2d) ; Length = %4d\n", orig_file_pos, orig_file_pos, Gdsii::grt_name(type), type, reclen)
        end
                
        data = case data_type
               when GDT_ASCII
				   Ascii.read(file, bytes_left)
               when GDT_INT2
				   Int2.read(file, bytes_left)
               when GDT_INT4
				   Int4.read(file, bytes_left)
               when GDT_REAL8
				   Real8.read(file, bytes_left)
               when GDT_BITARRAY
				   BitArray.read(file, bytes_left)
               when GDT_NO_DATA
				   NoData.read(file, bytes_left)
               when GDT_REAL4
				   Real4.read(file, bytes_left)
               else
                 raise TypeError, "Given record type (#{type}) is invalid"
               end

        # Create the new record
        rec = Record.new(type, data)

        # Print a debugging message for this record if desired
        if Record.read_debug
          puts "  --> #{Gdsii.gdt_name(rec.data.type)}: #{rec.data_value.inspect}"
        end
                       
        yield rec if block_given?
        rec
      rescue
        $stderr.puts "Error reading GDSII file starting at file position #{orig_file_pos}"
        $stderr.puts "Record length = #{reclen.inspect}"
        $stderr.puts "Record type   = #{Gdsii::grt_name(type)}"
        $stderr.puts "Data type     = #{Gdsii::gdt_name(data_type)}"
        raise
      end

    end

    # Reads and yields GDSII records from the given file object until EOF is
    # reached in the file.  Example (a simple GDS dump utility):
    #
    #  # Note: 'rb' is required for DOS/Windows compatibility
    #  File.open('mydesign.gds', 'rb') do |file|
    #    Gdsii::Record.read_each(file) do |record|
    #      puts record.to_s
    #    end
    #  end
    #
    def Record.read_each(file, record_filter=nil)
      until file.eof? do
        Record.read(file, record_filter) {|r| return if r.nil?; yield r}
      end
    end

    # Peeks at the next record for the given file object.  The record will be
    # returned and the file position will remain unchanged.
    def Record.peek(file)
      pos = file.pos
      rec = Record.read(file)
      file.seek pos
      rec
    end

    # Write this record to the given file object.
    def write(file)
      # write the length & header; always write length (int2) as network
      # order (as per GDSII spec)
      file.write [self.byte_size].pack('n')
      file.write [self.type].pack('c')
      file.write [self.data.type].pack('c')

      # now write the data...
      @data.write(file)
    end

    # Returns the string name of this record type which typically matches the
    # Gdsii::GRT_* constants but without the "Gdsii::GRT_" (i.e. HEADER, etc.)
    def name(); RECORD_INFO[@type].name; end

    # Return the value of this record; shortcut for self.data.value
    def value(); self.data.value; end

    # Set the value of this record; shortcut for self.data.value=
    def value=(value); self.data.value = value; end

    # Outputs the record in "L" textual layout format which is a string
    # representation.  Note, the string representation can include a newline
    # character (\n) for some record types (multi-line output).
    def to_s()

      # Immediately return records that have no data
      if @data.type == GDT_NO_DATA then
        return self.name
      end

      # Raise an exception if an invalid record is encountered
      unless RECORD_INFO[@type].valid
        raise "Record type #{self.name} is not valid"
      end
      
      # Format other data types...
      case @type
      when GRT_STRING
         self.name + " \"#{@data.to_s}\""
      when GRT_BGNLIB, GRT_BGNSTR
        # Format dates for library & structure
        out_arr = []
        tmpar = (@type == GRT_BGNLIB) ? ["LASTMOD","LASTACC"] : ["LASTMOD","CREATION"]
        tmpar.each_with_index do |label, i|
          j = i * 6
          out_arr.push sprintf("%s %02d/%02d/%02d %02d:%02d:%02d",label,
                               @data[j],@data[j+1],@data[j+2],
                               @data[j+3],@data[j+4],@data[j+5])
        end
        self.name + "\n" + out_arr.join("\n")
      when GRT_UNITS
#        @@file_user_units[file] = @data[0].to_f
        "UNITS\nUSERUNITS #{@data[0].to_s}\nPHYSUNITS #{data[1].to_s}"
      when GRT_WIDTH
        units = 1
#        units = @@file_user_units[file] || 1
        self.name + " #{@data[0]}"
      when GRT_XY
        units = 1
#        units = @@file_user_units[file] || 1
        out_arr = ["XY  " + (@data.value.length/2).to_s]
        0.step(@data.value.length-2, 2) do |i|
          out_arr.push "  X #{@data[i]*units}; Y #{@data[i+1]*units}"
        end
        out_arr.join(";\n") + ';'
      when GRT_PRESENTATION, GRT_STRANS
        if @type == GRT_PRESENTATION then
          str = [@data.to_s[10,2], @data.to_s[12,2], @data.to_s[14,2]].map {|twobits|
            [("0"*32+twobits)[-32..-1]].pack("B32").unpack("N")[0].to_s
          }.join(',')
        elsif @type == GRT_STRANS then
          str =[@data.to_s[0,1], @data.to_s[13,1], @data.to_s[14,1]].map {|onebit|
            [("0"*32+onebit)[-32..-1]].pack("B32").unpack("N")[0].to_s
          }.join(',')
        end
        self.name + ' ' + str
      else
        self.name + ' ' + @data.to_s
      end
      
    end


    ########################################################################
    # RECORD TYPE SHORTCUTS
    ########################################################################

    # Returns true if this is a HEADER record or false if not
    def is_header?(); @type == GRT_HEADER; end

    # Returns true if this is a BGNLIB record or false if not
    def is_bgnlib?(); @type == GRT_BGNLIB; end

    # Returns true if this is a LIBNAME record or false if not
    def is_libname?(); @type == GRT_LIBNAME; end

    # Returns true if this is a UNITS record or false if not
    def is_units?(); @type == GRT_UNITS; end

    # Returns true if this is a ENDLIB record or false if not
    def is_endlib?(); @type == GRT_ENDLIB; end

    # Returns true if this is a BGNSTR record or false if not
    def is_bgnstr?(); @type == GRT_BGNSTR; end

    # Returns true if this is a STRNAME record or false if not
    def is_strname?(); @type == GRT_STRNAME; end

    # Returns true if this is a ENDSTR record or false if not
    def is_endstr?(); @type == GRT_ENDSTR; end

    # Returns true if this is a BOUNDARY record or false if not
    def is_boundary?(); @type == GRT_BOUNDARY; end

    # Returns true if this is a PATH record or false if not
    def is_path?(); @type == GRT_PATH; end

    # Returns true if this is a SREF record or false if not
    def is_sref?(); @type == GRT_SREF; end

    # Returns true if this is a AREF record or false if not
    def is_aref?(); @type == GRT_AREF; end

    # Returns true if this is a TEXT record or false if not
    def is_text?(); @type == GRT_TEXT; end

    # Returns true if this is a LAYER record or false if not
    def is_layer?(); @type == GRT_LAYER; end

    # Returns true if this is a DATATYPE record or false if not
    def is_datatype?(); @type == GRT_DATATYPE; end

    # Returns true if this is a WIDTH record or false if not
    def is_width?(); @type == GRT_WIDTH; end

    # Returns true if this is a XY record or false if not
    def is_xy?(); @type == GRT_XY; end

    # Returns true if this is a ENDEL record or false if not
    def is_endel?(); @type == GRT_ENDEL; end

    # Returns true if this is a SNAME record or false if not
    def is_sname?(); @type == GRT_SNAME; end

    # Returns true if this is a COLROW record or false if not
    def is_colrow?(); @type == GRT_COLROW; end

    # Returns true if this is a TEXTNODE record or false if not
    def is_textnode?(); @type == GRT_TEXTNODE; end

    # Returns true if this is a NODE record or false if not
    def is_node?(); @type == GRT_NODE; end

    # Returns true if this is a TEXTTYPE record or false if not
    def is_texttype?(); @type == GRT_TEXTTYPE; end

    # Returns true if this is a PRESENTATION record or false if not
    def is_presentation?(); @type == GRT_PRESENTATION; end

    # Returns true if this is a SPACING record or false if not
    def is_spacing?(); @type == GRT_SPACING; end

    # Returns true if this is a STRING record or false if not
    def is_string?(); @type == GRT_STRING; end

    # Returns true if this is a STRANS record or false if not
    def is_strans?(); @type == GRT_STRANS; end

    # Returns true if this is a MAG record or false if not
    def is_mag?(); @type == GRT_MAG; end

    # Returns true if this is a ANGLE record or false if not
    def is_angle?(); @type == GRT_ANGLE; end

    # Returns true if this is a UINTEGER record or false if not
    def is_uinteger?(); @type == GRT_UINTEGER; end

    # Returns true if this is a USTRING record or false if not
    def is_ustring?(); @type == GRT_USTRING; end

    # Returns true if this is a REFLIBS record or false if not
    def is_reflibs?(); @type == GRT_REFLIBS; end

    # Returns true if this is a FONTS record or false if not
    def is_fonts?(); @type == GRT_FONTS; end

    # Returns true if this is a PATHTYPE record or false if not
    def is_pathtype?(); @type == GRT_PATHTYPE; end

    # Returns true if this is a GENERATIONS record or false if not
    def is_generations?(); @type == GRT_GENERATIONS; end

    # Returns true if this is a ATTRTABLE record or false if not
    def is_attrtable?(); @type == GRT_ATTRTABLE; end

    # Returns true if this is a STYPTABLE record or false if not
    def is_styptable?(); @type == GRT_STYPTABLE; end

    # Returns true if this is a STRTYPE record or false if not
    def is_strtype?(); @type == GRT_STRTYPE; end

    # Returns true if this is a ELFLAGS record or false if not
    def is_elflags?(); @type == GRT_ELFLAGS; end

    # Returns true if this is a ELKEY record or false if not
    def is_elkey?(); @type == GRT_ELKEY; end

    # Returns true if this is a LINKTYPE record or false if not
    def is_linktype?(); @type == GRT_LINKTYPE; end

    # Returns true if this is a LINKKEYS record or false if not
    def is_linkkeys?(); @type == GRT_LINKKEYS; end

    # Returns true if this is a NODETYPE record or false if not
    def is_nodetype?(); @type == GRT_NODETYPE; end

    # Returns true if this is a PROPATTR record or false if not
    def is_propattr?(); @type == GRT_PROPATTR; end

    # Returns true if this is a PROPVALUE record or false if not
    def is_propvalue?(); @type == GRT_PROPVALUE; end

    # Returns true if this is a BOX record or false if not
    def is_box?(); @type == GRT_BOX; end

    # Returns true if this is a BOXTYPE record or false if not
    def is_boxtype?(); @type == GRT_BOXTYPE; end

    # Returns true if this is a PLEX record or false if not
    def is_plex?(); @type == GRT_PLEX; end

    # Returns true if this is a BGNEXTN record or false if not
    def is_bgnextn?(); @type == GRT_BGNEXTN; end

    # Returns true if this is a ENDEXTN record or false if not
    def is_endextn?(); @type == GRT_ENDEXTN; end

    # Returns true if this is a TAPENUM record or false if not
    def is_tapenum?(); @type == GRT_TAPENUM; end

    # Returns true if this is a TAPECODE record or false if not
    def is_tapecode?(); @type == GRT_TAPECODE; end

    # Returns true if this is a STRCLASS record or false if not
    def is_strclass?(); @type == GRT_STRCLASS; end

    # Returns true if this is a RESERVED record or false if not
    def is_reserved?(); @type == GRT_RESERVED; end

    # Returns true if this is a FORMAT record or false if not
    def is_format?(); @type == GRT_FORMAT; end

    # Returns true if this is a MASK record or false if not
    def is_mask?(); @type == GRT_MASK; end

    # Returns true if this is a ENDMASKS record or false if not
    def is_endmasks?(); @type == GRT_ENDMASKS; end

    # Returns true if this is a LIBDIRSIZE record or false if not
    def is_libdirsize?(); @type == GRT_LIBDIRSIZE; end

    # Returns true if this is a SRFNAME record or false if not
    def is_srfname?(); @type == GRT_SRFNAME; end

    # Returns true if this is a LIBSECUR record or false if not
    def is_libsecur?(); @type == GRT_LIBSECUR; end

    # Returns true if this is a BORDER record or false if not
    def is_border?(); @type == GRT_BORDER; end

    # Returns true if this is a SOFTFENCE record or false if not
    def is_softfence?(); @type == GRT_SOFTFENCE; end

    # Returns true if this is a HARDFENCE record or false if not
    def is_hardfence?(); @type == GRT_HARDFENCE; end

    # Returns true if this is a SOFTWIRE record or false if not
    def is_softwire?(); @type == GRT_SOFTWIRE; end

    # Returns true if this is a HARDWIRE record or false if not
    def is_hardwire?(); @type == GRT_HARDWIRE; end

    # Returns true if this is a PATHPORT record or false if not
    def is_pathport?(); @type == GRT_PATHPORT; end

    # Returns true if this is a NODEPORT record or false if not
    def is_nodeport?(); @type == GRT_NODEPORT; end

    # Returns true if this is a USERCONSTRAINT record or false if not
    def is_userconstraint?(); @type == GRT_USERCONSTRAINT; end

    # Returns true if this is a SPACER_ERROR record or false if not
    def is_spacer_error?(); @type == GRT_SPACER_ERROR; end

    # Returns true if this is a CONTACT record or false if not
    def is_contact?(); @type == GRT_CONTACT; end

  end
end

