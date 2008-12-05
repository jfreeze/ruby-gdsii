SPEC = Gem::Specification.new do |s|
  s.name     = "ruby-gdsii"
  s.version  = "1.0.1"
  s.author   = "James Masters, Jim Freeze, et al"
  s.email    = "james.d.masters@intel.com"
  s.homepage = "http://rubyforge.org/frs/?group_id=833"
  s.platform = Gem::Platform::RUBY
  #s.rubyforge_project = 'ruby-gdsii'
  s.summary  = "GDSII reader and writer with both high-level (easier to use) and low-level (faster performance) methods."
  s.executables = %w(rgds-debug rgds-dump rgds-join rgds-layers rgds-sremove rgds-ssplit rgds-stats rgds-structs rgds-tree rgds2rb)
#  candidates = Dir.glob("{bin,lib,pkg,samples,test}/**/*")
  candidates = []
  candidates.concat %w(bin/rgds-debug bin/rgds-dump bin/rgds-join bin/rgds-layers bin/rgds-sremove bin/rgds-ssplit)
  candidates.concat %w(bin/rgds-stats bin/rgds-structs bin/rgds-tree bin/rgds2rb)
  
  candidates.concat %w(lib/gdsii/aref.rb lib/gdsii/bnf.rb lib/gdsii/boundary.rb lib/gdsii/box.rb lib/gdsii/byte_order.rb)
  candidates.concat %w(lib/gdsii/element.rb lib/gdsii/group.rb lib/gdsii/library.rb lib/gdsii/mixins.rb lib/gdsii/node.rb)
  candidates.concat %w(lib/gdsii/path.rb lib/gdsii/property.rb lib/gdsii/record lib/gdsii/record/consts.rb)
  
  candidates.concat %w(lib/gdsii/record/datatypes/ascii.rb lib/gdsii/record/datatypes/bitarray.rb)
  candidates.concat %w(lib/gdsii/record/datatypes/data.rb lib/gdsii/record/datatypes/int2.rb)
  candidates.concat %w(lib/gdsii/record/datatypes/int4.rb lib/gdsii/record/datatypes/nodata.rb)
  candidates.concat %w(lib/gdsii/record/datatypes/real4.rb lib/gdsii/record/datatypes/real8.rb)
  candidates.concat %w(lib/gdsii/record.rb lib/gdsii/sref.rb lib/gdsii/strans.rb lib/gdsii/structure.rb)
  candidates.concat %w(lib/gdsii/text.rb lib/gdsii.rb)
  
  candidates.concat %w(pkg/ruby-gdsii.gem )
  
  candidates.concat %w(samples/hello.gds samples/hello.out.rb samples/hello.rb)
  
  candidates.concat %w(test/baseline/dcp1.gds test/baseline/h_write.gds test/h_pthru.rb)
  candidates.concat %w(test/h_write.rb test/hs_pthru.rb test/l_pthru.rb test/test_gds_group.rb)
  candidates.concat %w(test/test_gds_record.rb)
  candidates << "Rakefile"
  candidates << "CHANGELOG.txt"
  s.files    = candidates.delete_if do |item|
                 item.include?("CVS") || item.include?("rdoc") || item.include?(".git")
               end
  #s.require_path = "lib"
  s.test_files   = ["test/test_gds_group.rb", "test/test_gds_record.rb"]
  s.bindir       = "bin"
  s.has_rdoc     = true
  s.extra_rdoc_files = ["README.txt", "LICENSE.txt"]
end


