require 'gdsii/group'

module Gdsii

  #
  # Represents a GDSII structure translation object (Strans). 
  #
  class Strans < Group

    #
    # Strans BNF description:
    #
    # <strans> ::= STRANS [MAG] [ANGLE]
    #
    self.bnf_spec = BnfSpec.new(
      BnfItem.new(GRT_STRANS),
      BnfItem.new(GRT_MAG, true),
      BnfItem.new(GRT_ANGLE, true)
    )

    # Constructor
    def initialize(mag=nil, angle=nil, reflect_x=false, abs_mag=false, abs_angle=false)
      super()
      @records[GRT_STRANS] = Record.new(GRT_STRANS, 0)
      self.reflect_x = true if reflect_x
      self.abs_mag = true if abs_mag
      self.abs_angle = true if abs_angle
      self.mag = mag unless mag.nil?
      self.angle = angle unless angle.nil?
      yield self if block_given?
    end

    #
    # Get the strans bitarray (returns Record)
    #
    def record() @records.get(GRT_STRANS); end

    #
    # Get the strans bitarray data (returns Fixnum).  The recommendation is to
    # not access this directly but rather use the various bitwise query
    # methods instead: #reflect_x?, #abs_angle?, #abs_mag?.
    #
    def value() @records.get_data(GRT_STRANS); end

    #
    # Set the strans bitarray record.  The recommendation is to not access
    # this directly but rather use the various bitwise manipulation methods
    # instead: #reflect_x=, #abs_angle=, #abs_mag=.
    #
    # * 15 = reflect_x
    # * 2 = abs_mag
    # * 1 = abs_angle
    # * All others reserved for future use.
    #
    def value=(val)
      @records.set(GRT_STRANS,val);
    end

    #
    # Get the strans angle (returns Record)
    #
    def angle_record() @records.get_data(GRT_ANGLE); end

    #
    # Get the strans angle value (returns Fixnum)
    #
    def angle() @records.get_data(GRT_ANGLE); end

    #
    # Set the strans angle record
    #
    def angle=(val) @records.set(GRT_ANGLE,val); end
  
    #
    # Get the strans magnification (returns Record)
    #
    def mag_record() @records.get_data(GRT_MAG); end

    #
    # Get the strans magnification value (returns Fixnum)
    #
    def mag() @records.get_data(GRT_MAG); end

    #
    # Set the strans magnification record
    #
    def mag=(val) @records.set(GRT_MAG,val); end

    #
    # Return true if the translation bitarray indicates that a reflection
    # about the x-axis is set.
    #
    def reflect_x?()
      (value & 0x8000) == 0x8000
    end

    #
    # Set or clear the strans x-reflect bit (true = set; false = clear)
    #
    def reflect_x=(flag)
      self.value = flag ? value | 0x8000 : value & 0x7fff
    end

    #
    # Return true if an absolute magnification is set; false if not
    #
    def abs_mag?()
      (value & 0x0004) == 0x0004
    end

    #
    # Set or clear the absolute magnification bit (true = set; false = clear)
    #
    def abs_mag=(flag)
      self.value = flag ? value | 0x0004 : value & 0xfffb
    end

    #
    # Return true if the absolute angle bit is set; false if not
    #
    def abs_angle?()
      (value & 0x0002) == 0x0002
    end

    #
    # Set the strans absAngle bit
    #
    def abs_angle=(flag)
      self.value = flag ? value | 0x0002 : value & 0xfffd
    end

  end
end
