require 'gdsii/group'
require 'gdsii/element'

module Gdsii
  
  #
  # Represents a GDSII Node element.  Most methods are from Element or from
  # the various included Access module methods.
  #
  class Node < Element

    # Include various record accessors
    include Access::Layer
    include Access::XY
    include Access::ELFlags
    include Access::Plex

    #
    # Node BNF description:
    #
    #  <node> ::= NODE [ELFLAGS] [PLEX] LAYER NODETYPE XY
    #
    self.bnf_spec = BnfSpec.new(
      BnfItem.new(GRT_NODE),
      BnfItem.new(GRT_ELFLAGS, true),
      BnfItem.new(GRT_PLEX, true),
      BnfItem.new(GRT_LAYER),
      BnfItem.new(GRT_NODETYPE),
      BnfItem.new(GRT_XY),
      BnfItem.new(Properties, true),
      BnfItem.new(GRT_ENDEL)
    )

    #
    # Create a node record grouping given a layer, nodetype, and xy
    # coordinates.  The node object can have 1-50 coordinate pairs.
    #
    #  node = Gdsii::Node.new(1, 0, [0,0])
    #
    def initialize(layer=nil, nodetype=nil, xy=nil)
      super()
      @records[GRT_NODE] = Record.new(GRT_NODE)
      self.layer = layer unless layer.nil?
      self.nodetype = nodetype unless nodetype.nil?
      self.xy = xy unless xy.nil?
      yield self if block_given?
    end
    
    #
    # Get the nodetype record (returns Record).
    #
    def nodetype_record() @records.get(GRT_NODETYPE); end

    #
    # Get the nodetype number (returns Fixnum).
    #
    def nodetype() @records.get_data(GRT_NODETYPE); end

    #
    # Set the nodetype number.
    #
    def nodetype=(val) @records.set(GRT_NODETYPE, val); end  
    
  end
end
