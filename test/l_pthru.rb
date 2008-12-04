require 'gdsii/record'
include Gdsii

in_file, out_file = ARGV
unless in_file and out_file
  abort "
Uses the GDSII low-level methods to read in a GDSII file and then write out
the same GDSII file.  The file should be identical - or at least just have
just EOF null-padding differences.

l_pthru.rb <in-file> <out-file>

"
end

File.open(in_file, 'rb') do |inf|
  File.open(out_file, 'wb') do |outf|
    while (rec = Record.read(inf))
      rec.write(outf)
    end
  end
end

