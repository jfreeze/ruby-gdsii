#!/usr/bin/env ruby
require 'gdsii/boundary'
require 'gdsii/path'
require 'gdsii/strans'
require 'gdsii/text'
require 'gdsii/box'
require 'gdsii/node'
require 'gdsii/sref'
require 'gdsii/aref'
require 'gdsii/structure'
require 'gdsii/library'
require 'test/unit'


class GdsGroupTest < Test::Unit::TestCase
  
  # This is just for Ruby In Steel bug
  include Gdsii

  # Test a property item
  def test_property()
    p = Property.new(1, 'test')
    assert_equal 1, p.attr
    assert_equal 'test', p.value
  end

  ############################################################################
  
  # Test BOUNDARY items
  def test_boundary()
    b = Boundary.new(0, 1, [2,3])
    assert_equal(0, b.layer)
    assert_equal(1, b.datatype)
    assert_equal([2,3], b.xy)

    b.xy=[4,5]
    b.layer = 10
    b.datatype = 11
    assert_equal(10, b.layer)
    assert_equal(11, b.datatype)
    assert_equal([4,5], b.xy)

    # test setting/removing of properties
    b.properties.add Property.new(0, 'test1')
    b.properties.add Property.new(0, 'test2')
    b.properties.add Property.new(1, 'test3')
    
    assert_equal(3, b.properties.length)
    assert_equal('test2', b.properties[1].value)

    # test removing of properties
    b.properties.remove {|p| p.attr == 0}
    assert_equal(1, b.properties.length)
    assert_equal('test3', b.properties[0].value)
  end

  ############################################################################

  # Test Strans object
  def test_strans(object=nil)
    if object
      #
      # Test strans on an object
      #
      object.strans.abs_angle = true
      object.strans.abs_mag = true
      object.strans.reflect_x = true
      object.strans.angle=50.0
      object.strans.mag = 10.3 
      assert object.strans.abs_angle?
      assert object.strans.abs_mag?   
      assert object.strans.reflect_x?  
      assert_equal(50.0, object.strans.angle)   
      assert_equal(10.3, object.strans.mag)
    else
      #
      # stand alone test
      #
      
      s = Strans.new(2.2, 90.0)
      assert_equal 2.2, s.mag
      assert_equal 90.0, s.angle
      assert_equal false, s.reflect_x?
      assert_equal false, s.abs_mag?
      assert_equal false, s.abs_angle?

      # Tweak x-reflection
      s.reflect_x = true
      assert s.reflect_x?
      s.reflect_x = false
      assert_equal false, s.reflect_x?
      
      # Tweak absolute magnification bit
      s.abs_mag = true
      assert s.abs_mag?
      s.abs_mag = false
      assert_equal false, s.abs_mag?

      # Tweak absolute angle bit
      s.abs_angle = true
      assert s.abs_angle?
      s.abs_angle = false
      assert_equal false, s.abs_angle?
    end
  end
    
  ############################################################################

  # Test PATH items
  def test_path()
    # Create a new path; check properties
    a = Path.new(5, 3, 0, 10, [1,2])
    assert_equal([1,2], a.xy)
    assert_equal(5, a.layer)
    assert_equal(3, a.datatype)
    assert_equal(10, a.width)
    assert_equal(0, a.pathtype)
    assert_equal(nil, a.bgnextn)
    assert_equal(nil, a.endextn)

    # Change layer, datatype, width, and path type; add begin/end extensions
    # Also change xy coordinates
    a.layer = 1
    a.datatype = 0
    a.width = 100
    a.xy = [9,10]
    a.pathtype = 4
    a.bgnextn = 50
    a.endextn = 25
    assert_equal(1, a.layer)
    assert_equal(0, a.datatype)
    assert_equal(100, a.width)
    assert_equal([9,10], a.xy)
    assert_equal(4, a.pathtype)   
    assert_equal(50, a.bgnextn)
    assert_equal(25, a.endextn)

    # Try to set begin/end extensions for path type 0
    a.pathtype = 0
    assert_raise(TypeError) { a.bgnextn = 100 }
    assert_raise(TypeError) { a.endextn = 100 }
    assert_raise(TypeError) { a.pathtype = 3 }

    # Create a path of type 4
    b = Path.new4(2, 0, 100, 0, 50, [0,0, 2000,0, 2000,2000, 4000,2000])
    assert_equal(4, b.pathtype)
    assert_equal(0, b.bgnextn)
    assert_equal(50, b.endextn)
  end

  ############################################################################

  def test_text()
    a = Text.new(1, 0, [0,0], 'test')
    assert_equal(1, a.layer)
    assert_equal(0, a.texttype)
    assert_equal([0,0], a.xy)
    assert_equal('test', a.string)

    # Test font numbers
    0.upto(3) do |i|
      a.font = i
      assert_equal i, a.font
    end
    assert_raise(ArgumentError) { a.font = 4 }

    # Test compass points
    [:c, :n, :ne, :e, :se, :s, :sw, :w, :nw].each do |point|
      a.origin = point
      assert_equal point, a.origin
    end
    assert_raise(RuntimeError) { a.origin = :foo }
  end
  
  ############################################################################

  # Test BOX items
  def test_box()
    a = Box.new(1, 0, [0,0, 0,10, 10,10, 10,0, 0,0])
    assert_equal 1, a.layer
    assert_equal 0, a.boxtype
    assert_equal [0,0], a.xy[0,2]
    
    a.layer = 5
    a.boxtype = 3
    assert_equal(5, a.layer)
    assert_equal(3, a.boxtype)
  end
  
  ############################################################################

  # Test NODE items
  def test_node()
    a = Node.new(1, 0, [0,0])
    assert_equal 1, a.layer
    assert_equal 0, a.nodetype
    assert_equal [0,0], a.xy
    
    a.layer = 5
    a.nodetype = 3
    assert_equal(5, a.layer)
    assert_equal(3, a.nodetype)  
  end
    
  ############################################################################

  # Test SRef items
  def test_sref()
    a = SRef.new('TestCell', [1,2])
    assert_equal("TestCell", a.sname)
    assert_equal([1,2], a.xy)

    a.sname = 'Test2'
    a.xy = [8,9]
    assert_equal('Test2', a.sname)
    assert_equal([8,9], a.xy)

    # run tests on strans of this object
    test_strans(a)
  end

  ############################################################################

  # Test AREF items
  def test_aref()
    # basic testing
    a = ARef.new('TestCell', [0,0], [2,8], [200, 300])
    assert_equal([0,0], a.ref_xy)
    assert_equal(2, a.columns)
    assert_equal(8, a.rows)
    assert_equal(200, a.column_space)
    assert_equal(300, a.row_space)
    assert_equal([0,0, 400,0, 0,2400], a.xy)

    # property change testing
    a.ref_xy = [100, 100]
    a.columns = 4
    a.rows = 2
    a.column_space = 50
    a.row_space = 25
    assert_equal([100,100], a.ref_xy)
    assert_equal(4, a.columns)
    assert_equal(2, a.rows)
    assert_equal(50, a.column_space)
    assert_equal(25, a.row_space)
    assert_equal([100,100, 300,100, 100,150], a.xy)

    # Test omission of required XY properties
    b = ARef.new('Test2')
    assert_nil b.ref_xy
    assert_nil b.column_space
    assert_nil b.row_space
    assert_nil b.columns
    assert_nil b.rows
    
    assert_nil b.xy
    b.ref_xy = [100, 100]
    assert_nil b.xy
    b.columns = 4
    assert_nil b.xy
    b.rows = 2
    assert_nil b.xy
    b.column_space = 50
    assert_nil b.xy
    b.row_space = 25
    assert_equal([100,100, 300,100, 100,150], b.xy)
 
    # run tests on strans of this object
    test_strans(a)
  end

  ############################################################################

  # Test Structure items
  def test_structure()
    a = Structure.new('MYNAME')
    assert_equal("MYNAME", a.name)
    assert (a.create_time and a.modify_time)
    assert a.elements.empty?

    # Change the name
    a.name = 'NEWNAME'
    assert_equal 'NEWNAME', a.name

    # Set the time to an hour ahead
    now = Time.new + 360
    a.create_time = now
    a.modify_time = now
    assert_equal now, a.create_time
    assert_equal now, a.modify_time

    # Add some elements using the two different add methods
    a.add Boundary.new(1, 0, [0,0, 0,10, 10,10, 10,0, 0,0])
    a.elements.add Boundary.new(2, 0, [0,0, 0,10, 10,10, 10,0, 0,0])
    assert_equal 2, a.elements.length
    assert_equal 1, a.elements[0].layer
    
    # Manipulate the strclass bitarray
    a.strclass = 0x0002
    assert_equal(0x0002, a.strclass)

    # Try adding garbage
    assert_raise(TypeError) { a.add 1234 }
  end
  
  ############################################################################

  
   # Test library items
   def test_library()
     lib = Library.new('MYLIB')
     assert_equal 'MYLIB', lib.name
     assert_equal lib.units, DEF_LIB_UNITS
     assert_equal lib.header, DEF_LIB_VERSION
     assert_equal lib.version, DEF_LIB_VERSION
     assert (lib.access_time and lib.modify_time)
     assert lib.structures.empty?

     # test defaults
     assert_nil lib.fonts
     assert_nil lib.format
     assert_nil lib.generations
     assert_nil lib.secur
     assert_equal [], lib.mask
     assert_nil lib.srfname

     # test units
     user = lib.user_units
     db = lib.database_units
     assert_equal [user, db], lib.units
     assert_equal 1e-6, lib.m_units

     # tweak then verify all values
     lib.name = 'LIB2'
     lib.version = 7
     lib.units = [0.001, 2e-9]
     lib.fonts = ["one","two/three", "four","five"]
     lib.generations = 3
     lib.dirsize = 30
     lib.secur = [1,2,7]
     lib.mask = ['0 2-5 6 ; 0-64']
     lib.srfname = "test"
     assert_equal('LIB2', lib.name)
     assert_equal(7, lib.version)
     assert_equal(7, lib.header)
     assert_equal([0.001, 2e-9], lib.units)
     assert_equal(2e-6, lib.m_units)
     assert_equal(["one","two/three", "four","five"], lib.fonts)    
     assert_equal(3, lib.generations)
     assert_equal(30, lib.dirsize)
     assert_equal([1,2,7], lib.secur)
     assert_equal(['0 2-5 6 ; 0-64'], lib.mask)
     assert_equal("test", lib.srfname)

     # mess with the format record
     lib.format = 0
     assert_equal(0, lib.format)
     assert(lib.archive_format?)
     lib.format = 1
     assert_equal(1, lib.format)
     assert(lib.filtered_format?)

     # mess with the time
     now = Time.new + 360
     lib.access_time = now
     lib.modify_time = now
     assert_equal now, lib.access_time
     assert_equal now, lib.modify_time

     # test adding structures
     lib.structures << Structure.new("first")
     lib.structures.add(Structure.new("second"))
     lib.add(Structure.new("third"))
     assert_equal("first", lib.structures[0].name)
     assert_equal("second", lib.structures[1].name)
     assert_equal("third", lib.structures[2].name)
  end
  
end
