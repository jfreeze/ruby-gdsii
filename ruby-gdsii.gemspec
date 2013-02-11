SPEC = Gem::Specification.new do |s|
  s.name     = 'ruby-gdsii'
  s.version  = '1.0.2'
  s.date     = '2013-02-08'
  s.summary  =
    'GDSII reader and writer with both high-level (easier to use) and' <<
    ' low-level (faster performance) methods.'
  s.description = 'A ruby-based GDSII read and writer.'
  s.author   = 'James Masters, Jim Freeze, et al'
  s.email    = 'james.d.masters@intel.com'
  s.homepage = 'http://rubyforge.org/frs/?group_id=833'
  s.files    = [ 'lib/gdsii.rb' ]
  s.platform = Gem::Platform::RUBY
  # For Ruby 1.9 and later use simplecov.  For earlier versions use
  # rspec and rcov to provide test coverage metrics.
  if "1.9".respond_to?(:encoding)
    s.add_dependency "simplecov", ">= 0.7.1"
  else
    s.add_dependency "rspec", ">= 2.5.0"
    s.add_dependency "rcov", ">= 0.9.11"
  end
  #s.rubyforge_project = 'ruby-gdsii'
  s.executables = %w(rgds-debug rgds-dump rgds-join rgds-layers rgds-sremove
					 rgds-ssplit rgds-stats rgds-structs rgds-tree rgds2rb)
#  candidates = Dir.glob("{bin,lib,pkg,samples,test}/**/*")
  candidates = []
  candidates.concat %w(
    bin/rgds2rb
    bin/rgds-debug
    bin/rgds-dump
    bin/rgds-join
    bin/rgds-layers
    bin/rgds-sremove
    bin/rgds-ssplit
    bin/rgds-stats
    bin/rgds-structs
    bin/rgds-tree
    CHANGELOG.txt
    lib/gdsii/aref.rb
    lib/gdsii/bnf.rb
    lib/gdsii/boundary.rb
    lib/gdsii/box.rb
    lib/gdsii/byte_order.rb
    lib/gdsii/element.rb
    lib/gdsii/group.rb
    lib/gdsii/library.rb
    lib/gdsii/mixins.rb
    lib/gdsii/node.rb
    lib/gdsii/path.rb
    lib/gdsii/property.rb
    lib/gdsii.rb
    lib/gdsii/record
    lib/gdsii/record/consts.rb
    lib/gdsii/record/datatypes/ascii.rb
    lib/gdsii/record/datatypes/bitarray.rb
    lib/gdsii/record/datatypes/data.rb
    lib/gdsii/record/datatypes/int2.rb
    lib/gdsii/record/datatypes/int4.rb
    lib/gdsii/record/datatypes/nodata.rb
    lib/gdsii/record/datatypes/real4.rb
    lib/gdsii/record/datatypes/real8.rb
    lib/gdsii/record.rb
    lib/gdsii/sref.rb
    lib/gdsii/strans.rb
    lib/gdsii/structure.rb
    lib/gdsii/text.rb
    lib/ruby_1_9_compat.rb
    Rakefile
    samples/hello.gds
    samples/hello.out.rb
    samples/hello.rb
    test/baseline/dcp1.gds
    test/baseline/h_write.gds
    test/helper.rb
    test/h_pthru.rb
    test/hs_pthru.rb
    test/h_write.rb
    test/l_pthru.rb
    test/test_gds_group.rb
    test/test_gds_record.rb
    test/test_h_pthru.rb
    test/test_hs_pthru.rb
    test/test_h_write.rb
    test/test_l_pthru.rb
  )
  s.files = candidates.delete_if do |item|
              item.include?("CVS")  ||
              item.include?("rdoc") ||
              item.include?(".git")
            end
  #s.require_path = "lib"
  s.test_files = [
    "test/helper.rb",
    "test/test_gds_group.rb",
    "test/test_gds_record.rb",
    "test/test_h_pthru.rb",
    "test/test_h_write.rb",
    "test/test_hs_pthru.rb",
    "test/test_l_pthru.rb"
  ]
  s.bindir     = "bin"
  s.has_rdoc   = true
  s.extra_rdoc_files = ["README.txt", "LICENSE.txt"]
end


