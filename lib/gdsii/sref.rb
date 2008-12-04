require 'gdsii/group'
require 'gdsii/element'
require 'gdsii/strans'

module Gdsii
  
  #
  # Represents a GDSII structure reference (SRef) element.  Most
  # methods are from Element or from the various included Access module
  # methods.
  #
  class SRef < Element
    
    # Include various record accessors
    include Access::XY
    include Access::ELFlags
    include Access::Plex
    include Access::StransGroup
    include Access::Sname

    #
    # SRef BNF description:
    #
    #  <sref> ::= SREF [ELFLAGS] [PLEX] SNAME [<strans>] XY
    #
    self.bnf_spec = BnfSpec.new(
      BnfItem.new(GRT_SREF),
      BnfItem.new(GRT_ELFLAGS, true),
      BnfItem.new(GRT_PLEX, true),
      BnfItem.new(GRT_SNAME),
      BnfItem.new(Strans, true),
      BnfItem.new(GRT_XY),
      BnfItem.new(Properties, true),
      BnfItem.new(GRT_ENDEL)
    )
                                
    #
    # Create a structure reference (SREF) within a Structure object (also
    # known as a structure "instantiation").
    #
    #  struct1 = Gdsii::Structure.new('top')
    #  struct2 = Gdsii::Structure.new('sub')
    #  struct1.add SRef.new('sub')
    #
    # Alternatively, any object with a #to_s method can be passed and the
    # #to_s method will be used to coerce the object into a string.  For
    # example, a structure object itself can be used (instead of the structure
    # name) through Structure#to_s:
    #
    #  struct1.add SRef.new(struct2)
    #
    def initialize(sname=nil, xy=nil)
      super()
      @records[GRT_SREF] = Record.new(GRT_SREF)
      self.sname = sname.to_s unless sname.nil?
      self.xy = xy unless xy.nil?
      yield self if block_given?
    end
    
  end
end
