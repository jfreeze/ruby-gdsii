require 'gdsii/group'
require 'gdsii/property'

module Gdsii

  #
  # Generic class to be inherited by various GDSII elements (i.e. things that
  # can be added to a Structure).
  #
  class Element < Group

    # No BNF for generic Element; refer to actual Element itself (i.e.
    # Boundary, Path, etc.)
        
    #
    # Generic element constructor.  Not intended to be called directly but
    # rather inherited and called through sub-classes such as Gdsii::Boundary.
    #
    def initialize()
      super()
      @records[GRT_ENDEL] = Record.new(GRT_ENDEL)
      @records[Properties] = @properties = Properties.new
    end

    #
    # Shortcut for Properties#add.  For example, instead of:
    #
    #  bnd.properties.add Property(1, 'testprop')
    #
    # It could be simply:
    #
    #  bnd.add Property(1, 'testprop')
    #
    def add(*args); properties.add(*args); end

    #
    # Shortcut for Properties#remove.  For example, instead of:
    #
    #  bnd.properties.remove {|p| p.attr == 1}
    #
    # It could be simply:
    #
    #  bnd.remove {|p| p.attr == 1}
    #
    def remove(*args); properties.remove(*args); end    

    #
    # Access the Properties object for this element
    #
    def properties(); @properties; end

    class << self
      alias :read_el :read
    end

    def Element.read(file, *args)
      rec = Record.peek(file)
      case rec.type
      when GRT_BOUNDARY : Boundary.read_el(file, *args)
      when GRT_TEXT     : Text.read_el(file, *args)
      when GRT_PATH     : Path.read_el(file, *args)
      when GRT_SREF     : SRef.read_el(file, *args)
      when GRT_AREF     : ARef.read_el(file, *args)
      when GRT_BOX      : Box.read_el(file, *args)
      when GRT_NODE     : Node.read_el(file, *args)
      else
        # end of the element, increment the counter and move on
        nil
      end
    end

    #
    # After a Structure header has been read (see Structure#read_each_header)
    # then elements may be processed as a file is read using Element#read_each.
    # See Structure#read_each_header for an example.
    #
    # Compare this with Structure#seek_next which also advances the file handle
    # to the next structure but does not yield any elements (if only a file
    # pointer advancement is needed and elements can be ignored).
    #    
    def Element.read_each(file)
      while (group = Element.read(file)) do
        yield group
      end
      # rip out ENDEL - TODO: make sure that it's ENDEL
      Record.read(file)
    end

    #
    # Returns true if this is a Boundary element
    #
    def is_boundary?; self.class == Boundary; end

    #
    # Returns true if this is a Path element
    #
    def is_path?; self.class == Path; end

    #
    # Returns true if this is a Text element
    #
    def is_text?; self.class == Text; end

    #
    # Returns true if this is a SRef element
    #
    def is_sref?; self.class == SRef; end

    #
    # Returns true if this is a ARef element
    #
    def is_aref?; self.class == ARef; end

    #
    # Returns true if this is a Box element
    #
    def is_box?; self.class == Box; end

    #
    # Returns true if this is a Node element
    #
    def is_node?; self.class == Node; end
    
  end

  ############################################################################

  #
  # Class to hold a collection of Element objects.  This is used in the
  # Structure class BNF.
  #
  # Elements include: Boundary, Path, SRef, ARef, Text, Node, Box
  #
  class Elements < Group

    include Access::EnumerableGroup
    
    #
    # Elements BNF description:
    #   
    # <structure> ::= {<element>}*
    # <element>   ::= {<boundary> | <path> | <sref> | <aref> |
    #                  <text> | <node> | <box>}  {<property>}*  ENDEL
    #
    self.bnf_spec = BnfSpec.new(
      BnfItem.new(Element, true, true)
    )

    #
    # Create an Elements object.
    #
    def initialize(elements=[])
      super()
      @records[Element] = @list = elements
    end

    
    #######################
    ## PROTECTED METHODS ##
    #######################
    
    protected

    # Used by Access::EnumerableGroup to validate addition
    def validate_addition(object)
      unless object.kind_of?(Element)
        raise TypeError, "Invalid addition: #{object.class}; expecting Gdsii::Element"
      end
    end
        
  end
end
