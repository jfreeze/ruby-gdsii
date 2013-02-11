#!/usr/bin/env ruby
require 'test/helper.rb'
require_relative '../lib/gdsii/record'

include Gdsii
include Gdsii::RecData

class GdsRecordTest < Test::Unit::TestCase

  # Test record data types (Gds::Record::*)
  def test_rec_data()

    ########################################
    ### ASCII record test
    rec=Ascii.new(['hello'], nil)
    assert_equal 6, rec.byte_size

    # test ASCII padding / unpadding
    rec.pad!
    assert_equal ['hello'].pack('a6'), rec[0]
    rec.pad!(8)
    assert_equal "hello\000\000\000", rec[0]
    rec.unpad!
    assert_equal 'hello', rec[0]

    # test bad values
    assert_raise(TypeError) { rec.value = 'test' }
    assert_raise(TypeError) { rec.value = 1 }

    # test multiple values
    rec.value = ['hello', 'world']
    rec.pad!
    assert_equal ["hello\0", "world\0"], rec.value

    ########################################
    ### INT2 record test
    rec=Int2.new([3])
    assert_equal 2, rec.byte_size
    rec.value = [2,4,5]
    assert_equal 6, rec.byte_size

    ########################################
    ### INT4 record test
    rec=Int4.new([3])
    assert_equal 4, rec.byte_size
    rec.value = [2,4,5]
    assert_equal 12, rec.byte_size

    ########################################
    ### REAL4 record test
    assert_raise(RuntimeError) {rec=Real4.new([3])}

    ########################################
    ### REAL8 record test
    rec=Real8.new([1.0, 2.3])
    assert_equal 16, rec.byte_size
    rec.value = [2.0,4.0,5.0]
    assert_equal 24, rec.byte_size

    ########################################
    ### NO_DATA record test
    rec = NoData.new()
    assert_raise(ArgumentError) { rec.value = [1] } 
    assert_equal 0, rec.byte_size

    ########################################
    ### BITARRAY record test
    rec =BitArray.new(['1001000011111001'])
    assert_equal 2, rec.byte_size


  end

  def test_record()

    rec = Record.new(GRT_HEADER, [6])
    rec = Record.new(GRT_HEADER, 6)

#    assert_raise(ArgumentError) {
#      rec = Record.new(GRT_HEADER, [6,2])
#    }

    # test GDT_NO_DATA records...
    Record.new(GRT_ENDLIB)

    # test swapping out data
    rec = Record.new(GRT_HEADER, 6)
    rec.data = 7
    assert_equal [7], rec.data.value

    # Test special size for GRT_FONTS record
    fonts = Record.new(GRT_FONTS, ['one', 'two', 'three', 'four'])
    assert_equal 180, fonts.byte_size
    assert_equal 176, fonts.data.byte_size

  end

end
