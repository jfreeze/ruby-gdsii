require 'gdsii/element'
require 'gdsii/mixins'

module Gdsii
  
  #
  # Represents a GDSII Path element.  Most methods are from Element or from
  # the various included Access module methods.
  #
  class Path < Element
    
    # Include various record accessors
    include Access::Layer
    include Access::Datatype
    include Access::XY
    include Access::PathType
    include Access::Width
    include Access::ELFlags
    include Access::Plex

    #
    # Boundary BNF description:
    #
    #  <path> ::= PATH [ELFLAGS] [PLEX] LAYER DATATYPE [PATHTYPE]
    #             [WIDTH] [BGNEXTN] [ENDEXTN] XY
    #
    self.bnf_spec = BnfSpec.new(
      BnfItem.new(GRT_PATH),
      BnfItem.new(GRT_ELFLAGS, true),
      BnfItem.new(GRT_PLEX, true),
      BnfItem.new(GRT_LAYER),
      BnfItem.new(GRT_DATATYPE),
      BnfItem.new(GRT_PATHTYPE, true),
      BnfItem.new(GRT_WIDTH, true),
      BnfItem.new(GRT_BGNEXTN, true),
      BnfItem.new(GRT_ENDEXTN, true),
      BnfItem.new(GRT_XY),
      BnfItem.new(Properties,true),
      BnfItem.new(GRT_ENDEL)
    )

    #
    # Generic method to create a path given a layer, datatype, pathtype,
    # width, and series of alternating x/y coordinates.  The default pathtype
    # is 0.
    #
    #  path = Gdsii::Path.new(1, 0, 0, 100, [0,0, 1000,0, 1000,1000])
    #
    def initialize(layer=nil, datatype=nil, pathtype=nil, width=nil, xy=nil)
      super()
      @records[GRT_PATH] = Record.new(GRT_PATH)
      self.layer = layer unless layer.nil?
      self.datatype = datatype unless datatype.nil?
      self.pathtype = (pathtype.nil?) ? 0 : pathtype
      self.width = width unless width.nil?
      self.xy = xy unless xy.nil?

      # Set a code block to validate a path record
      @validate = proc {
        # Check for begin/end extensions for pathtype == 4
        if self.pathtype == 4
          unless self.bgnextn and self.endextn
            raise "Begin/end extensions (#bgnextn= and #endextn=) required for path type 4"
          end
        end
      }

      yield self if block_given?
    end

    #
    # Creates a path of type 0
    #
    def Path.new0(layer=nil, datatype=nil, width=nil, xy=nil)
      Path.new(layer, datatype, 0, width, xy) {|p| yield p if block_given?}
    end

    #
    # Creates a path of type 1
    #
    def Path.new1(layer=nil, datatype=nil, width=nil, xy=nil)
      Path.new(layer, datatype, 1, width, xy) {|p| yield p if block_given?}
    end

    #
    # Creates a path of type 2
    #
    def Path.new2(layer=nil, datatype=nil, width=nil, xy=nil)
      Path.new(layer, datatype, 2, width, xy) {|p| yield p if block_given?}
    end
    
    #
    # Creates a path of type 4; accepts begin/end extension values
    #
    #  path = Path.new4(1, 0, 100, 30, 30, [0,0, 1000,0, 1000,1000])
    #
    def Path.new4(layer=nil, datatype=nil, width=nil,
                  bgnextn=nil, endextn=nil, xy=nil)
      Path.new(layer, datatype, 4, width, xy) do |path|
        path.bgnextn = bgnextn
        path.endextn = endextn
        yield self if block_given?
      end
    end
        
    #
    # Set the beginning extension for path type 4 (as Fixnum).  Value is in
    # database units.
    #--
    # TODO: more explanation of database units; also example
    #++
    #
    def bgnextn=(val)
      ensure_pathtype_4
      @records.set(GRT_BGNEXTN, val)
    end

    #
    # Get the beginning extension for path type 4 (as Fixnum).  Value is in
    # database units.
    #
    def bgnextn(); @records.get_data(GRT_BGNEXTN); end
    
    #
    # Get the beginning extension record for path type 4 (as Fixnum).  Value is
    # in database units.
    #
    def bgnextn_record(); @records.get(GRT_BGNEXTN); end

    #
    # Set the ending extension for path type 4 (as Fixnum).  Value is in
    # database units.
    #--
    # TODO: more explanation of database units; also example
    #++
    #
    def endextn=(val)
      ensure_pathtype_4
      @records.set(GRT_ENDEXTN, val)
    end

    #
    # Get the ending extension for path type 4 (as Fixnum).  Value is in
    # database units.
    #
    def endextn(); @records.get_data(GRT_ENDEXTN); end
    
    #
    # Get the ending extension record for path type 4 (as Fixnum).  Value is
    # in database units.
    #
    def endextn_record(); @records.get(GRT_ENDEXTN); end
    
    ###########################################################################
    
    private

    #
    # Ensures that pathtype == 4.  This needs to be verified for a few of the
    # methods only relevant for pathtype == 4 (see #bgnextn and #endextn).
    #
    def ensure_pathtype_4()
      if pathtype != 4
        raise TypeError, "Attempt to access a method only relevant to pathtype == 4"
      end
    end
    
  end
end
