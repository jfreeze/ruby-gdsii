require 'gdsii/record/consts'

module Gdsii

  #
  # Various attribute accessor definitions which are used (included) by the
  # high-level GDSII classes.
  #
  module Access

    #
    # Access layer attribute
    #
    module Layer
      # Get the layer record (returns Record)
      def layer_record() @records.get(GRT_LAYER); end
      
      # Get the layer number (returns Fixnum)
      def layer() @records.get_data(GRT_LAYER); end
      
      # Set the layer number
      def layer=(val) @records.set(GRT_LAYER, val); end   
    end

    ##########################################################################

    #
    # Access Datatype attribute
    #
    module Datatype
      # Get the datatype record (returns Record)
      def datatype_record() @records.get(GRT_DATATYPE); end

      # Get the datatype number (returns Fixnum)
      def datatype() @records.get_data(GRT_DATATYPE); end
  
      # Set the datatype number
      def datatype=(val) @records.set(GRT_DATATYPE, val); end  
    end

    ##########################################################################

    #
    # Access XY attribute
    #
    module XY
      # Gets an xy point record (returns Record)
      def xy_record() @records.get(GRT_XY); end

      # Gets an xy point record (returns an Array)
      def xy() @records.get_data(GRT_XY); end
  
      # Sets an xy point record
      def xy=(val) @records.set(GRT_XY, val); end  
    end

    ##########################################################################

    #
    # Access ELFlags attribute
    #
    module ELFlags
      # Get the elflags record (returns Record)
      def elflags_record() @records.get(GRT_ELFLAGS); end
      
      # Get the elflags record data (returns Fixnum)
      def elflags() @records.get_data(GRT_ELFLAGS); end
    
      # Set the elflags record
      def elflags=(val) @records.set(GRT_ELFLAGS,val); end
    end

    ##########################################################################

    #
    # Access Plex attribute
    #
    module Plex
      # Set the plex record (returns Record)
      def plex_record() @records.get_data(GRT_PLEX); end

      # Set the plex record data (returns Fixnum)
      def plex() @records.get_data(GRT_PLEX); end
    
      # Set the plex record
      def plex=(val) @records.set(GRT_PLEX,val); end
    end

    ##########################################################################

    #
    # Access PathType attribute
    #
    module PathType
      #
      # Get the path type record (returns Record).
      #
      def pathtype_record() @records.get(GRT_PATHTYPE); end

      #
      # Get the path type number (returns Fixnum).
      #
      def pathtype() @records.get_data(GRT_PATHTYPE); end

      #
      # Set the type number (as Fixnum).  Valid range is 0-2,4 (not 3):
      #
      # * 0: Square ended paths (default)
      # * 1: Round ended
      # * 2: Square ended, extended 1/2 width
      # * 4: Variable length extensions (see #bgnextn and #endextn)
      #
      def pathtype=(val)
        record = @records.set(GRT_PATHTYPE, val)
        data_val = record.data_value
        if [0, 1, 2, 4].member?(data_val)
          if data_val != 4
            # Rip out begin/end extensions for pathtypes other than 4
            @records.delete_key(GRT_BGNEXTN)
            @records.delete_key(GRT_ENDEXTN)
          end
        else
          # If path type is not 0, 1, 2, or 4, then fail
          raise TypeError, "Path type #{data_val} is invalid; must be 0, 1, 2, or 4."
        end
      end
    end

    ##########################################################################

    #
    # Access Width attribute
    #
    module Width
      #
      # Get the path width record (returns Record)
      #
      def width_record() @records.get(GRT_WIDTH); end

      #
      # Get the path width value (returns Fixnum).  The width value is multiplied
      # with the UNITS value of the library to obtain the actual width.
      #
      def width() @records.get_data(GRT_WIDTH); end

      #
      # Set the path width value (as Fixnum).  The width value is multiplied
      # with the UNITS value of the library and magnification factor to obtain
      # the actual width.  If the width value is negative, then the value is
      # interpreted to be absolute and will not be affected by the database
      # units or magnification factor.
      #
      def width=(val) @records.set(GRT_WIDTH, val); end   
    end

    ##########################################################################

    #
    # Access Strans record grouping
    #
    module StransGroup
      #
      # Access the Strans for this object (see Gdsii::Strans class
      # documentation for a list of Strans methods).
      #
      def strans(); @records.get(Strans); end

      #
      # Set the Strans for this object
      #
      def strans=(val); @records.set(Strans, val); end
    end

    ##########################################################################

    #
    # Access Sname attribute
    #
    module Sname
      #
      # Get the referenced structure SNAME record (returns Record).
      #
      def sname_record() @records.get(GRT_SNAME); end

      #
      # Get the referenced structure name (returns String).
      #
      def sname() @records.get_data(GRT_SNAME); end
      
      #
      # Set the referenced structure name.
      #
      def sname=(val) @records.set(GRT_SNAME, val); end
    end

    ##########################################################################

    #
    # Mix in methods that work with a predefined @list attribute.  The list is
    # made Enumerable and a number of methods are mixed in.  Used in
    # Properties, Structure, and Library.
    #
    module EnumerableGroup

      include Enumerable
            
      #
      # Get the list object.
      #
      def list() @list; end

      alias :to_a :list

      #
      # Loops through each object yielding along the way.
      #
      def each(); @list.each {|e| yield e}; end

      #
      # Add an object to this list as either an object instance or as
      # the object data.  Similar to Array#push but validates the data being
      # added.  The object added is returned.
      #
      def add(object)
        self.validate_addition(object) if self.respond_to?(:validate_addition)
        @list.push object
        object
      end

      #
      # Remove object(s) from this element when the propert(y/ies) match
      # the given criteria (in the code block).  Equivalent to Array#reject!.
      #
      def remove()
        @list.reject! {|e| yield e}
      end

      #
      # Implement a trap for a method that might be missing.  Any method not
      # listed here will default to the @list Array attribute if @list
      # #respond_to? the method.  This nifty feature allows us to "inherit"
      # *all* methods related Array which will be operated upon the @list Array
      # attribute.
      #
      def method_missing(method_sym, *args)
        if @list.respond_to?(method_sym)
          # The array @list responds to this method - use it on @list
          @list.method(method_sym).call(*args)
        else
          # Raise the #method_missing error
          super
        end
      end    
    end
    
    ##########################################################################

    #
    # Shared method related to working with the standard Time library within
    # the Gdsii library.
    #
    module GdsiiTime
      #
      # Given a Time object, the time is formatted into an array of integers
      # according to the GDSII specification.
      #
      def build_time(time)
        [time.year-1900, time.month, time.day, time.hour, time.min, time.sec.to_i]
      end
    end

  end
  
  ############################################################################

  #
  # This module will be extended into all classes descended of Group (i.e.
  # the high-level GDSII access classes).  The extension brings a "read"
  # class method (i.e. singleton) into these classes which enables a GDSII
  # file to be read into these data structures using the BNF specification.
  #
  module Read
    #
    # Accepts a file handle and reads data from that file handle into an
    # object descended of Group.  The parent_records and parent_bnf_item
    # arguments are for internal use only.
    #
    def read(file, parent_records=nil, parent_bnf_item=nil, yield_at=nil)
      # Set BNF index at 0, get the BNF items, create an empty grouping object
      i = 0
      bnf_items = bnf_spec.bnf_items
      group = self.new
#      puts "#{self}"
      
      # Loop through the BNF spec for this grouping...
      while i < bnf_items.length do
        bnf_item = bnf_items[i]

        # see what kind of a BNF item this is - a Class or a record type (Fixnum)
        if bnf_item.key.class == Class
          # return if stop_at_class is set to true (used internally for
          # Library#read_header and Cell#read_header).
          yield group if yield_at == :before_group

          # Determine the class to use
          klass = bnf_item.key
          
          # Read from the class
          if bnf_item.multiple?
            if (rec = klass.read(file, group.records, bnf_item))
              # if a record was returned, then add it
              group.records.add(bnf_item.key, rec)
            else
              # if nil was returned, then we're done with the record; next
              i += 1
            end
          else
            # If the record is singular, then get it from the class and
            # increment the counter
            rec = klass.read(file, group.records, bnf_item)
            group.records.set(bnf_item.key, rec)
            i += 1
          end
        else
          # ELSE, a record type is expected (Fixnum)
          rec = Record.read(file)
#          puts "  --> expect #{Gdsii::grt_name(bnf_item.key)}; rec == #{rec.name}"
          if rec.type == bnf_item.key
            # This record matches the grouping BNF item that was expected, so
            # store the data
            if bnf_item.multiple?
              group.records.add(bnf_item.key, rec)
            else
              group.records.set(bnf_item.key, rec)
              i += 1
            end
          else
            # Record does not match expected record as per BNF.  Check that we
            # have data already set in this record or that the record is
            # optional.
            if group.records.has_data?(bnf_item.key) or bnf_item.optional?
              # Already has data - just move to the next record and reset file
              # pointer
              i += 1
              file.seek(-rec.byte_size, IO::SEEK_CUR)
            elsif (parent_bnf_item and parent_bnf_item.key.class == Class and
                   (parent_records.has_data?(parent_bnf_item.key) or
                    parent_bnf_item.optional?))
              # OK, in this case, we are descended into a Class and did not
              # match the BNF expected.  Furthermore, the parent calling this
              # grouping either already got the data needed or this was an
              # optional class in the first place.  In either case, we're OK
              # and just need to get out - which is what we do by returning
              # nil.
              file.seek(-rec.byte_size, IO::SEEK_CUR)
              return nil
            else
              # Does not match the expected BNF... fail
              raise "Unexpected record while reading GDSII file starting at file position #{file.pos-rec.byte_size}\n" +
                "This record is in the wrong place according to the GDSII specification (from BNF)\n" +
                "Expected record was #{Gdsii::grt_name(bnf_item.key)}; instead, received:\n" +
                "Record type     = #{Gdsii::grt_name(rec.type)}\n" +
                "Data type       = #{Gdsii::gdt_name(rec.data.type)}\n" +
                "Record length   = #{rec.byte_size}\n"
            end
          end
          
        end
      end
      
      # Return this record grouping
      yield group if yield_at == :group
      group
    end
  end

  
end
