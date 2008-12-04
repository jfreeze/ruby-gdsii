require 'gdsii/element'
require 'gdsii/mixins'

module Gdsii

  #
  # Represents a GDSII Boundary element (i.e. a rectangle or polygon).  Most
  # methods are from Element or from the various included Access module
  # methods.
  #
  class Boundary < Element

    # Include various record accessors
    include Access::Layer
    include Access::Datatype
    include Access::XY
    include Access::ELFlags
    include Access::Plex

    #
    # Boundary BNF description:
    #
    #  <boundary> ::= BOUNDARY [ELFLAGS] [PLEX] LAYER DATATYPE XY
    #
    self.bnf_spec = BnfSpec.new(
      BnfItem.new(GRT_BOUNDARY),
      BnfItem.new(GRT_ELFLAGS, true),
      BnfItem.new(GRT_PLEX, true),
      BnfItem.new(GRT_LAYER),
      BnfItem.new(GRT_DATATYPE),
      BnfItem.new(GRT_XY),
      BnfItem.new(Properties,true),
      BnfItem.new(GRT_ENDEL)
    )

    #
    # Boundary object constructor.  Layer and datatype are given as Fixnum
    # and the coordinate points are given as an array of Fixnum alternating
    # x and y values (coordinate pair range is 4-200).  Example:
    #
    #  rectangle = Gdsii::Boundary.new(1, 0, [0,0, 0,10, 10,10, 10,0, 0,0])
    #
    def initialize(layer=nil, datatype=nil, xy=nil)
      super()
      @records[GRT_BOUNDARY] = Record.new(GRT_BOUNDARY)
      self.layer = layer unless layer.nil?
      self.datatype = datatype unless datatype.nil?
      self.xy = xy unless xy.nil?
      yield self if block_given?
    end
    
  end
end
