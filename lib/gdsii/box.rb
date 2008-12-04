require 'gdsii/group'
require 'gdsii/element'

module Gdsii
  
  #
  # Represents a GDSII box element.  Most methods are from Element or from the
  # various included Access module methods.
  #
  class Box < Element
    
    # Include various record accessors
    include Access::Layer
    include Access::XY
    include Access::ELFlags
    include Access::Plex
    
    #
    # Box BNF description:
    #
    #  <box> ::= BOX [ELFLAGS] [PLEX] LAYER BOXTYPE XY
    #
    self.bnf_spec = BnfSpec.new(
      BnfItem.new(GRT_BOX),
      BnfItem.new(GRT_ELFLAGS, true),
      BnfItem.new(GRT_PLEX, true),
      BnfItem.new(GRT_LAYER),
      BnfItem.new(GRT_BOXTYPE),
      BnfItem.new(GRT_XY),
      BnfItem.new(Properties, true),
      BnfItem.new(GRT_ENDEL)
    )

    #
    # Create a box record grouping given a layer, boxtype, and xy coordinates.
    # The box object is to have exactly 5 coordinate pairs.
    #
    #  box = Gdsii::Box.new(1, 0, [0,0, 0,10, 10,10, 10,0, 0,0])
    #
    def initialize(layer=nil, boxtype=nil, xy=nil)
      super()
      @records[GRT_BOX] = Record.new(GRT_BOX)
      self.layer = layer unless layer.nil?
      self.boxtype = boxtype unless boxtype.nil?
      self.xy = xy unless xy.nil?
      yield self if block_given?
    end

    #
    # Get the boxtype record (returns Record).
    #
    def boxtype_record() @records.get(GRT_BOXTYPE); end

    #
    # Get the boxtype number (returns Fixnum).
    #
    def boxtype() @records.get_data(GRT_BOXTYPE); end

    #
    # Set the boxtype number.
    #
    def boxtype=(val) @records.set(GRT_BOXTYPE, val); end  
        
  end
end
