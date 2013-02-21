#
# = Synopsis
#    Gdsii methods used solely for making code the ran in ruby versions 1.8
#    and early compatible with versions 1.9 and later.
#
module Gdsii
  # Sets home to be a directory above the location of this file, __FILE__
  GDSII_HOME = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Checks whether we're on a version of ruby (1.9+) and returns false if
  # this is not the case, also printing an appropriate warning
  def is_1_9_or_later?
    "1.9".respond_to?(:encoding)
  end

  module_function :is_1_9_or_later?
end

# Define a require_relative for pre-1.9 versions of Ruby.
unless Gdsii::is_1_9_or_later?
  unless Object.new.respond_to?('require_relative')
    def require_relative(relative_feature)

      file = caller.first.split(/:\d/,2).first

      if /\A\((.*)\)/ =~ file
        raise LoadError, "require_relative is called in #{$1}"
      end

      require File.expand_path(relative_feature, File.dirname(file))
    end
  end
end
