require 'gdsii'
include Gdsii

in_file, out_file = ARGV
unless in_file and out_file
  abort "
Uses the GDSII high-level *streamlined* methods to read in a GDSII file and
write out the contents in one pass.  The resulting GDSII file should be
identical - or at least just have just EOF null-padding differences.

hs_pthru.rb <in-file> <out-file>

"
end

File.open(in_file, 'rb') do |inf|
  File.open(out_file, 'wb') do |outf|
    puts "Reading from #{in_file}..."
    puts "Writing to #{out_file}..."
    Library.read_header(inf) do |lib|
      lib.write_header(outf) do
        Structure.read_each_header(inf) do |struct|
          struct.write_header(outf) do
            Element.read_each(inf) {|element| element.write(outf)}
          end
        end
      end
    end
  end
end

