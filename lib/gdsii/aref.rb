require 'gdsii/element'
require 'gdsii/group'
require 'gdsii/strans'

module Gdsii

  #
  # Represents a GDSII structure array reference (ARef) element.  Most
  # methods are from Element or from the various included Access module
  # methods.
  #
  class ARef < Element

    # Include various record accessors
    include Access::ELFlags
    include Access::Plex
    include Access::StransGroup
    include Access::Sname

    #
    # ARef BNF description:
    #
    #  <aref> ::= AREF [ELFLAGS] [PLEX] SNAME [<strans>] COLROW XY
    #
    self.bnf_spec = BnfSpec.new(
      BnfItem.new(GRT_AREF),
      BnfItem.new(GRT_ELFLAGS, true),
      BnfItem.new(GRT_PLEX, true),
      BnfItem.new(GRT_SNAME),
      BnfItem.new(Strans, true),
      BnfItem.new(GRT_COLROW),
      BnfItem.new(GRT_XY),
      BnfItem.new(Properties, true),
      BnfItem.new(GRT_ENDEL)
    )
    
    #
    # Create a new structure array reference (ARef) to be used within a
    # Structure object.  The structure name is a String or anything that has
    # a #to_s method.  The ref_xy is a *single* set of x/y coordinates
    # that the placement of the ARef (note this is _NOT_ the same as the
    # XY record for ARef - see #xy_record for more details).  The colrow is an
    # array of a number of columns and rows respectively.  The colrow_spc is
    # an array of spacing values for columns and rows respectively.
    #
    #  # Create an ARef at coordinates (0,0) with 2 columns and 8 rows.  The
    #  # spacing between columns is 200 units and between rows is 300 units.
    #  aref = ARef.new('array', [0,0], [2,8], [200, 300])
    #
    # Note, the #ref_xy, #column_space, and #row_space are required.
    # See #xy_record for details.
    #
    def initialize(sname=nil, ref_xy=nil, colrow=nil, colrow_spc=nil)
      super()      
      @records[GRT_AREF] = Record.new(GRT_AREF)
      self.sname = sname unless sname.nil?
      self.colrow = colrow unless colrow.nil?
      self.ref_xy = ref_xy unless ref_xy.nil?
      self.column_space = colrow_spc[0] if colrow_spc.class == Array
      self.row_space = colrow_spc[1] if colrow_spc.class == Array
      yield self if block_given?
    end

    #
    # Get the colrow record (returns Record)
    #
    def colrow_record() @records.get(GRT_COLROW); end

    #
    # Get the colrow array of numbers (returns 2-element Array of Fixnum)
    # where the first number is columns and the second is rows [col, row].
    # Alternatively, the #rows and #columns method may also be used.
    #
    #  aref.colrow  #=> [2, 8]
    #
    def colrow() @records.get_data(GRT_COLROW); end

    #
    # Set the colrow number (see #colrow for format details).  Alternatively,
    # the #rows= and #columns= methods may be used.
    #
    #  aref.colrow = [2, 8]
    #
    def colrow=(val) @records.set(GRT_COLROW, val); end   

    #
    # Set the columns number in the COLROW record (Fixnum)
    #
    #  aref.columns = 2
    #
    def columns=(val)
      if (cr=colrow)
        @records.set(GRT_COLROW, [val, cr[1]])
      else
        @records.set(GRT_COLROW, [val, nil])
      end
    end
  	  
    #
    # Get the columns number in the COLROW record (returns Fixnum)
    #
    #  aref.columns  #=> 2
    #
    def columns()
      (cr=@records.get(GRT_COLROW)) ? cr[0] : nil
    end
    
    #
    # Set the rows number in the COLROW record
    #
    #  aref.rows = 8
    #
    def rows=(val)
      if (cr=colrow)
        @records.set(GRT_COLROW, [cr[0], val])
      else
        @records.set(GRT_COLROW, [nil, val])
      end
    end
  	  
    #
    # Get the rows number in the COLROW record (returns Fixnum)
    #
    #  aref.rows  #=> 8
    #
    def rows()
      (cr=@records.get(GRT_COLROW)) ? cr[1] : nil
    end

    #
    # Defines the placement XY coordinate for this ARef.  See #xy_record for
    # details on how the XY record is used in ARef.
    #
    #  aref.ref_xy = [10, 20]
    #
    def ref_xy=(val)
      if val.class == Array and val.length == 2
        @ref_xy = val
        update_xy
      else
        raise TypeError, "Expected Array of length 2"
      end
    end

    #
    # Returns the placement XY coordinate for this ARef.  See #xy_record for
    # details on how the XY record is used in ARef.
    #
    #  aref.ref_xy  #=> [10, 20]
    #
    def ref_xy(); @ref_xy; end

    #
    # Defines the column spacing (in units) for this ARef.  Internally this
    # value is stored in the XY record.  See #xy_record for details on how the
    # XY record is used in ARef.
    #
    #  aref.column_space = 200
    #
    def column_space=(val)
      @column_space = val
      update_xy
    end

    #
    # Returns the placement XY coordinate for this ARef.  See #xy_record for
    # details on how the XY record is used in ARef.
    #
    #  aref.column_space  #=> 200
    #
    def column_space(); @column_space; end

    #
    # Defines the row spacing (in units) for this ARef.  Internally this
    # value is stored in the XY record.  See #xy_record for details on how the
    # XY record is used in ARef.
    #
    #  aref.row_space = 300
    #
    def row_space=(val)
      @row_space = val
      update_xy
    end

    #
    # Returns the placement XY coordinate for this ARef.  See #xy_record for
    # details on how the XY record is used in ARef.
    #
    #  aref.row_space  #=> 300
    #
    def row_space(); @row_space; end

    #
    # Gets the ARef record for XY.
    #
    # Important note on the XY record (i.e. #xy, #xy_record): the GDSII
    # specification calls for exactly 3 XY records for ARef.  Because of this
    # specification, there is no #xy= method available for the ARef class.
    # Instead, the XY record is created dynamically when all three of these
    # components are set.  Otherwise, the XY record will not exist.
    #
    # The XY record data specification is as follows:
    #
    # * 1:  ARef reference point (#ref_xy)
    # * 2:  column_space*columns+reference_x (#ref_xy, #columns, and #column_space)
    # * 3:  row_space*rows+reference_y (#ref_xy, #rows, and #row_space)
    #
    def xy_record() @records.get(GRT_XY); end

    #
    # Gets an xy point record (returns an Array).  Note, it is probably easier
    # to use #ref_xy, #column_space, or #row_space instead; see #xy_record for
    # details on how the XY record is used for ARef.
    #
    def xy() @records.get_data(GRT_XY); end

    
    #####################
    ## PRIVATE METHODS ##
    #####################
    
    private

    #
    # Update the GRT_XY record if all prerequisites are met (#ref_xy,
    # #column_space, and #row_space).
    #
    def update_xy()
      if ((pxy=ref_xy) and (cs=column_space) and (rs=row_space) and (cr=colrow).length == 2)
        # see #xy_record for an explanation of this formula
        array = pxy + [pxy[0]+cs*cr[0], pxy[1]] + [pxy[0], pxy[1]+rs*cr[1]]
        @records.set(GRT_XY, array)
      else
        @records.set(GRT_XY, nil)
      end
    end

  end
end




