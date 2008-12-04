require 'gdsii'

File.open('hello.out', 'wb') do |outf|

  Gdsii::Record.new(Gdsii::GRT_HEADER, 5).write(outf)
  Gdsii::Record.new(Gdsii::GRT_BGNLIB, [108, 12, 4, 14, 51, 0, 108, 12, 4, 14, 51, 0]).write(outf)
  Gdsii::Record.new(Gdsii::GRT_LIBNAME, "HELLO.DB").write(outf)
  Gdsii::Record.new(Gdsii::GRT_UNITS, [0.001, 1.0e-09]).write(outf)

  ############################################################################
  # STRUCTURE: hello
  ############################################################################

  Gdsii::Record.new(Gdsii::GRT_BGNSTR, [108, 12, 4, 14, 51, 0, 108, 12, 4, 14, 51, 0]).write(outf)
  Gdsii::Record.new(Gdsii::GRT_STRNAME, "hello").write(outf)

  Gdsii::Record.new(Gdsii::GRT_BOUNDARY, nil).write(outf)
  Gdsii::Record.new(Gdsii::GRT_LAYER, 1).write(outf)
  Gdsii::Record.new(Gdsii::GRT_DATATYPE, 0).write(outf)
  Gdsii::Record.new(Gdsii::GRT_XY, [0, 0, 0, 700, 100, 700, 100, 400, 300, 400, 300, 700, 400, 700, 400, 0, 300, 0, 300, 300, 100, 300, 100, 0, 0, 0]).write(outf)
  Gdsii::Record.new(Gdsii::GRT_ENDEL, nil).write(outf)

  Gdsii::Record.new(Gdsii::GRT_BOUNDARY, nil).write(outf)
  Gdsii::Record.new(Gdsii::GRT_LAYER, 1).write(outf)
  Gdsii::Record.new(Gdsii::GRT_DATATYPE, 0).write(outf)
  Gdsii::Record.new(Gdsii::GRT_XY, [600, 0, 600, 700, 900, 700, 900, 600, 700, 600, 700, 400, 900, 400, 900, 300, 700, 300, 700, 100, 900, 100, 900, 0, 600, 0]).write(outf)
  Gdsii::Record.new(Gdsii::GRT_ENDEL, nil).write(outf)

  Gdsii::Record.new(Gdsii::GRT_BOUNDARY, nil).write(outf)
  Gdsii::Record.new(Gdsii::GRT_LAYER, 1).write(outf)
  Gdsii::Record.new(Gdsii::GRT_DATATYPE, 0).write(outf)
  Gdsii::Record.new(Gdsii::GRT_XY, [1100, 0, 1100, 700, 1200, 700, 1200, 100, 1400, 100, 1400, 0, 1100, 0]).write(outf)
  Gdsii::Record.new(Gdsii::GRT_ENDEL, nil).write(outf)

  Gdsii::Record.new(Gdsii::GRT_BOUNDARY, nil).write(outf)
  Gdsii::Record.new(Gdsii::GRT_LAYER, 1).write(outf)
  Gdsii::Record.new(Gdsii::GRT_DATATYPE, 0).write(outf)
  Gdsii::Record.new(Gdsii::GRT_XY, [1600, 0, 1600, 700, 1700, 700, 1700, 100, 1900, 100, 1900, 0, 1600, 0]).write(outf)
  Gdsii::Record.new(Gdsii::GRT_ENDEL, nil).write(outf)

  Gdsii::Record.new(Gdsii::GRT_BOUNDARY, nil).write(outf)
  Gdsii::Record.new(Gdsii::GRT_LAYER, 1).write(outf)
  Gdsii::Record.new(Gdsii::GRT_DATATYPE, 0).write(outf)
  Gdsii::Record.new(Gdsii::GRT_XY, [2100, 200, 2100, 600, 2200, 700, 2500, 700, 2600, 600, 2600, 100, 2500, 0, 2200, 0, 2100, 100, 2100, 200, 2200, 200, 2300, 100, 2400, 100, 2500, 200, 2500, 500, 2400, 600, 2300, 600, 2200, 500, 2200, 200, 2100, 200]).write(outf)
  Gdsii::Record.new(Gdsii::GRT_ENDEL, nil).write(outf)

  Gdsii::Record.new(Gdsii::GRT_ENDSTR, nil).write(outf)

  ############################################################################
  # STRUCTURE: top
  ############################################################################

  Gdsii::Record.new(Gdsii::GRT_BGNSTR, [108, 12, 4, 14, 51, 0, 108, 12, 4, 14, 51, 0]).write(outf)
  Gdsii::Record.new(Gdsii::GRT_STRNAME, "top").write(outf)
  Gdsii::Record.new(Gdsii::GRT_SREF, nil).write(outf)
  Gdsii::Record.new(Gdsii::GRT_SNAME, "hello").write(outf)
  Gdsii::Record.new(Gdsii::GRT_STRANS, 0).write(outf)
  Gdsii::Record.new(Gdsii::GRT_ANGLE, 0.0).write(outf)
  Gdsii::Record.new(Gdsii::GRT_XY, [0, 0]).write(outf)
  Gdsii::Record.new(Gdsii::GRT_ENDEL, nil).write(outf)
  Gdsii::Record.new(Gdsii::GRT_SREF, nil).write(outf)
  Gdsii::Record.new(Gdsii::GRT_SNAME, "hello").write(outf)
  Gdsii::Record.new(Gdsii::GRT_STRANS, 0).write(outf)
  Gdsii::Record.new(Gdsii::GRT_ANGLE, 90.0).write(outf)
  Gdsii::Record.new(Gdsii::GRT_XY, [0, 0]).write(outf)
  Gdsii::Record.new(Gdsii::GRT_ENDEL, nil).write(outf)
  Gdsii::Record.new(Gdsii::GRT_SREF, nil).write(outf)
  Gdsii::Record.new(Gdsii::GRT_SNAME, "hello").write(outf)
  Gdsii::Record.new(Gdsii::GRT_STRANS, 0).write(outf)
  Gdsii::Record.new(Gdsii::GRT_ANGLE, 180.0).write(outf)
  Gdsii::Record.new(Gdsii::GRT_XY, [0, 0]).write(outf)
  Gdsii::Record.new(Gdsii::GRT_ENDEL, nil).write(outf)
  Gdsii::Record.new(Gdsii::GRT_SREF, nil).write(outf)
  Gdsii::Record.new(Gdsii::GRT_SNAME, "hello").write(outf)
  Gdsii::Record.new(Gdsii::GRT_STRANS, 0).write(outf)
  Gdsii::Record.new(Gdsii::GRT_ANGLE, 270.0).write(outf)
  Gdsii::Record.new(Gdsii::GRT_XY, [0, 0]).write(outf)
  Gdsii::Record.new(Gdsii::GRT_ENDEL, nil).write(outf)

  Gdsii::Record.new(Gdsii::GRT_ENDSTR, nil).write(outf)

  Gdsii::Record.new(Gdsii::GRT_ENDLIB, nil).write(outf)

end
