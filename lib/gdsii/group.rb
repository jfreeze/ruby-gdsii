require 'gdsii/mixins'
require 'gdsii/record'
require 'gdsii/bnf'

module Gdsii

  #
  # Generic base class for a GDSII grouping of records (i.e. a boundary object
  # and all records associated with it).  This class will not be used directly
  # but will be inherited by the various record groupings.
  #
  class Group

    extend Read

    attr_reader :records

    #
    # Constructor of a generic GDSII record grouping.  Not intended to be
    # called directly but rather from subclasses which inherit this class.
    #
    def initialize()
      @records = BnfRecords.new(self.class)
    end

    #
    # Simply yields itself for configuration (i.e. makes for prettier code).
    # The object itself is returned.
    #
    def configure()
      yield self
      self
    end

    #
    # Write the record grouping to a file.  A file name as a String can be
    # passed in which case a new file by the given name is opened in write
    # mode ('w').  Alternatively, a file object may be passed in which case
    # the record grouping are written to the file object.  Examples (assumes
    # "object" has been initialized and descends from this class):
    #
    #  object.write('mydesign.gds')
    #
    # or
    #
    #  # Note: 'wb' is required for DOS/Windows compatibility
    #  File.open('otherdesign.gds', 'wb') do |file|
    #    object.write(file)
    #  end
    #
    def write(file, alt_bnf=nil)
      # If the file specified is a string, then open it up for writing. If it
      # is a file open it for writing if it is not already open
      if file.class == String
        file = File.open(file,"wb")
      elsif file.class == File
        file = File.open(file,"wb") if file.closed?
      else
        raise TypeError, "Invalid file object given: #{file}"
      end

      # Write to file according to BNF
      @records.write(file, alt_bnf)
    end
    
    #
    # Runs a code block to validate the object if the validate attribute is
    # set.  This is typically run to check record grouping integrity during
    # read/write of GDSII files.
    #
    def validate()
      if @validate
        @validate.call
      end
    end

    #
    # Set class instance variables to be used in subclasses.
    #
    class << self

      # Set the class bnf array
      def bnf_spec=(value); @bnf = value; end
      
      # Return class bnf array
      def bnf_spec(); @bnf; end

      # Set the BNF key for this class
      def bnf_key=(value); @bnf_key = value; end

      # Get the BNF key for this class (default is the instantiating class)
      def bnf_key(); (@bnf_key.nil?) ? self : @bnf_key ; end

    end

  end
end

