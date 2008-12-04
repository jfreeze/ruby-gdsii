require 'gdsii/group'
require 'gdsii/strans'
require 'gdsii/element'

module Gdsii
  
  #
  # Represents a GDSII Text element.  Most methods are from Element or from the
  # various included Access module methods.
  #
  class Text < Element
    
    # Include various record accessors
    include Access::Layer
    include Access::XY
    include Access::PathType
    include Access::Width
    include Access::ELFlags
    include Access::Plex
    include Access::StransGroup
    
    #
    # Text BNF description:
    #
    #  <text> ::= TEXT [ELFLAGS] [PLEX] LAYER TEXTTYPE [PRESENTATION]
    #             [PATHTYPE] [WIDTH] [<strans>] XY STRING
    #
    self.bnf_spec = BnfSpec.new(
      BnfItem.new(GRT_TEXT),
      BnfItem.new(GRT_ELFLAGS, true),
      BnfItem.new(GRT_PLEX, true),
      BnfItem.new(GRT_LAYER),
      BnfItem.new(GRT_TEXTTYPE),
      BnfItem.new(GRT_PRESENTATION, true),
      BnfItem.new(GRT_PATHTYPE, true),
      BnfItem.new(GRT_WIDTH, true),
      BnfItem.new(Strans, true),
      BnfItem.new(GRT_XY),
      BnfItem.new(GRT_STRING),
      BnfItem.new(Properties, true),
      BnfItem.new(GRT_ENDEL)
    )

    #
    # Create a simple hash to store compass points and their respective
    # presentation values and vice-versa.  This is used in manipulating
    # and querying the text's PRESENTATION record.
    #
    @@pres_lookup = {
      # * bits 0 and 1: x origin; 00 left, 01 center, 10 right
      # * bits 2 and 3: y origin; 00 top, 01, center, 10 bottom
      [0b0000, 0b0000] => :nw,
      [0b0000, 0b0100] => :w,
      [0b0000, 0b1000] => :sw,
      [0b0001, 0b0000] => :n,
      [0b0001, 0b0100] => :c,
      [0b0001, 0b1000] => :s,
      [0b0010, 0b0000] => :ne,
      [0b0010, 0b0100] => :e,
      [0b0010, 0b1000] => :se
    }
    @@pres_lookup.merge!(@@pres_lookup.invert)
    
    #
    # Create a text record grouping given a layer, text type, xy coordinate,
    # and a string.
    #
    #  text1 = Gdsii::Text.new(1, 0, [0,0], 'hello')
    #  text2 = Gdsii::Text.new(1, 0, [100, 0], 'world', 2, :ne)
    #
    def initialize(layer=nil, texttype=nil, xy=nil, string=nil, font=nil, origin=nil)
      super()
      @records[GRT_TEXT] = Record.new(GRT_TEXT)
      self.layer = layer unless layer.nil?
      self.texttype = texttype unless texttype.nil?
      self.xy = xy unless xy.nil?
      self.string = string unless string.nil?
      self.font = font unless font.nil?
      self.origin = origin unless origin.nil?
      yield self if block_given?
    end

    #
    # Get the texttype record (returns Record).
    #
    def texttype_record() @records.get(GRT_TEXTTYPE); end

    #
    # Get the texttype number (returns Fixnum).
    #
    def texttype() @records.get_data(GRT_TEXTTYPE); end
  
    #
    # Set the texttype number.
    #
    def texttype=(val) @records.set(GRT_TEXTTYPE, val); end

    #
    # Get the text string record (returns Record).
    #
    def string_record() @records.get(GRT_STRING); end

    #
    # Get the text string value (returns String).
    #
    def string() @records.get_data(GRT_STRING); end
  
    #
    # Set the text string value.
    #
    def string=(val) @records.set(GRT_STRING, val); end
 
    #
    # Get the presentation record (returns Record).
    #
    def presentation_record() @records.get(GRT_PRESENTATION); end

    #
    # Get the presentation bitarray number (returns Fixnum).  It is probably
    # easier to use #font and #origin instead.
    #
    def presentation() @records.get_data(GRT_PRESENTATION); end
  
    #
    # Set the presentation bitarray number.  It is easier to not modify
    # this number directly but to use #font= and #origin= instead.
    #
    # * bits 0 and 1: x origin; 00 left, 01 center, 10 right
    # * bits 2 and 3: y origin; 00 top, 01, center, 10 bottom
    # * bits 4 and 5: font number; 00 font 0, 01 font 1, 10 font 2, 11 font 3
    # * All other bits are reserved
    #
    def presentation=(val)
      @records.set(GRT_PRESENTATION, val);
    end

    #
    # Specifies the font to use (valid range is 0-3).  Calls #presentation=
    # to change the font bits.
    #
    def font=(val)
      if val >= 0 and val <= 3
        # Be sure to clear out old value first...
        # start at 4th bit; 2**4 == 16
        pres = presentation || 0
        self.presentation = (pres & 0xFFCF) | 16*val
      else
        raise ArgumentError, "Font value must be 0-3; given: #{val}"
      end
    end

    #
    # Returns the font number (Fixnum in range 0-3) according to the font bits
    # in the #presentation record.
    #
    def font()
      # clear all other bits then start at 4th bit; 2**4 == 16
      pres = presentation || 0
      (pres & 0x0030) / 16
    end

    #
    # Returns the text origin as a symbol containing one of 9 possible
    # values representing compass points:
    #
    # * :c == center (x == center; y == center)
    # * :n == north (x == center; y == top)
    # * :ne == northeast (x == right; y == top)
    # * :e == east (x == right; y == center)
    # * :se == southeast (x == right; y == bottom)
    # * :s == south (x == center; y == bottom)
    # * :sw == southwest (x == left; y == bottom)
    # * :w == west (x == left; y == center)
    # * :nw == northwest (x == left; y == top)
    #
    # The #presentation method is used to extract the bits related to the
    # text origin.
    #
    def origin()
      # origin bits: x == 0-1; y == 2-3
      pres = presentation || 0
      x_num = (pres & 0b0011)
      y_num = (pres & 0b1100)
      @@pres_lookup[[x_num, y_num]]
    end

    #
    # Sets the text origin based upon one of 9 compass points (see
    # #origin for the list).  The #presentation= method is called to manipulate
    # the presentation bits related to the text origin.
    #
    def origin=(point)
      if nums = @@pres_lookup[point]
        # clear origin bits then set to the new value
        pres = presentation || 0
        self.presentation = (pres & 0xFFF0) | nums[0] | nums[1]
      else
        raise "Compass point given: #{point.inspect} is not valid"
      end
    end
    
  end
end
