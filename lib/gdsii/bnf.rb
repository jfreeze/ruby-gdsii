require 'gdsii/record/consts'

module Gdsii

  #
  # Class to hold BNF items which are to be listed in the BnfSpec class.  The
  # BnfItem objects are used to indicate the unique BNF key and also whether
  # or not it is optional and whether or not it is multiple.
  #
  class BnfItem
    
    attr_reader :key, :optional, :multiple

    #
    # Create a new BNF item of a given key and specify if it is optional
    # and if there are multiple values.  The key is either one of the
    # Gdsii::GRT_* constants or is a class descended from Gdsii::Group.
    # Examples:
    #
    #  BnfItem.new(Property,true,true),
    #  BnfItem.new(GRT_ENDEL)
    #
    def initialize(key, optional=false, multiple=false)
      @key = key
      @optional = optional
      @multiple = multiple
    end

    #
    # True if this BNF item is optional; false if not (opposite of #required?)
    #
    def optional?() @optional; end

    #
    # True if this BNF item has multiple values; false if not
    #
    def multiple?() @multiple; end

    #
    # Dump the name for this BNF item
    #
    def to_s(); Gdsii::grt_name(@key); end

    #
    # (hide from RDoc) - Add details to inspect
    #
    def inspect() # :nodoc:
      "#<#{self.class}:0x#{sprintf("%x", self.object_id*2)} == #{self.to_s}>"
    end

  end

  ############################################################################

  #
  # This class represents the order of a GDSII record grouping using a specific
  # record order in Backus-Naur Form (BNF).  It consists of a number of BnfItem
  # objects where the order of the items is important in determining the order
  # in which the GDSII file format should be read or written from/to a file.
  #
  class BnfSpec

    include Enumerable

    attr_reader :bnf_items

    #
    # Creates a Backus-Naur Form (BNF) grouping consisting of BnfItem objects.
    #
    #  spec = BnfSpec.new(
    #    BnfItem.new(GRT_PROPATTR),
    #    BnfItem.new(GRT_PROPVALUE)
    #  )
    #
    def initialize(*bnf_items)
      @bnf_items = bnf_items
    end

    #
    # Loops through each BnfItem in this BnfSpec yielding the BnfItem along
    # the way.
    #
    #  spec.each {|bnf_item| ...}
    #
    def each()
      @bnf_items.each {|bnf_item| yield bnf_item}
    end
    alias :each_item :each

    #
    # Finds a BnfItem of a given key in this Bnf object or nil if one is not
    # found.
    #
    #  spec = ...
    #  spec.find_item(GRT_PROPATTR)  #=> BnfItem ...
    #  spec.find_item(GRT_HEADER)    #=> nil
    #
    def find_item(key)
      @bnf_items.find {|bnf_item| bnf_item.key == key}
    end

    #
    # Shortcut for #find_item but will raise an exception if the item key
    # is not part of this BNF.
    #
    #  spec = ...
    #  spec.find_item(GRT_PROPATTR)  #=> BnfItem ...
    #  spec.find_item(GRT_HEADER)    #=> raise IndexError ...
    #
    def [](key)
      if (found = find_item(key))
        found
      else
        raise IndexError, "Cannot find BnfItem of key #{Gdsii::grt_name(key)} in BNF"
      end
    end

    #
    # Format for inspection
    #
    def inspect() # :nodoc:
      "#<#{self.class}:0x#{sprintf("%x", self.object_id*2)}:@bnf_items.map {|i| i.to_s}.inspect>"
    end
          
  end
    
  ############################################################################

  #
  # Used to store records for a record grouping (i.e. classes descending
  # from Group).  Only records that are in the BnfSpec may be added.
  #
  class BnfRecords

    #
    # Create a new BnfRecords object.  The parent class is stored so that
    # entries may be compared against the BnfSpec.
    #
    def initialize(parent_class)
      @parent_class = parent_class
      @bnf_records = {}
    end

    #
    # Returns the BnfSpec of the parent class.
    #
    def bnf_spec()
      @parent_class.bnf_spec
    end

    #
    # Returns the BNF record keys that exist in this grouping of BNF records.
    #
    def bnf_keys()
      @bnf_records.keys
    end

    #
    # Retrieves the Record for a given BNF item key.  If the record is
    # multiple according to the BNF description, then an array of
    # Record objects is returned.  Used internally by various grouping accessor
    # methods.
    #
    def get(key)
      bnf_item = bnf_spec[key]
      if bnf_item.multiple?
        @bnf_records[key] = [] unless @bnf_records.has_key? key
        @bnf_records[key]
      else
        if key.class == Class and @bnf_records[key].nil?
          @bnf_records[key] = key.new
        end
        @bnf_records[key]
      end
    end

    alias :[] :get

    #
    # Retrieves the Record *data* (i.e value) for a given BNF item key.  If
    # the record is multiple according to the BNF description, then an array
    # of Record data is returned.  Used internally by various grouping accessor
    # methods.
    #
    def get_data(key)
      if bnf_spec[key].multiple?
        get(key).map {|record| record.data_value}
      else
        ((record = get(key)).nil?) ? nil : record.data_value
      end
    end

    #
    # Sets the record data for a given BNF item key.  The value may be the
    # of the class to be added or can be a raw value which is automatically
    # coerced into the proper class for the given key.  Used internally by
    # various grouping accessor methods.  Returns the object being set.
    #
    def set(key, value)
      if key.class == Class
        @bnf_records[key] = value
      elsif value.nil?
        @bnf_records[key] = value
      else
        value = coerce_record_value(key, value)
        value = [value] if bnf_spec[key].multiple? and value.class != Array
        @bnf_records[key] = value
      end
    end

    alias :[]= :set

    #
    # Adds the record or record value to the bnf_records hash (applicable only
    # for records with multiple entries).  Returns the updated list of values.
    # Used internally by various grouping accessor methods.  Returns the object
    # being set.
    #
    def add(key, value)
      if bnf_spec[key].multiple?
        value = coerce_record_value(key, value)
        get(key).push value
      else
        raise TypeError, "BNF for key #{key} is singular in class #{parent_class}; use #set instead"
      end
    end

    #
    # Accepts a code block which should return true or false.  If the return
    # value is true, then the value meeting the criteria is removed.  This
    # is used internally by various grouping accessor methods.  Note, this is
    # only applicable for records with multiple values.
    #
    #  object.reject!(Property) {|property|
    #    property.attr == 1
    #  }
    #
    def reject!(key)
      if bnf_spec[key].multiple?
        @bnf_records[key].reject! {|value| yield value}
      else
        raise TypeError, "BNF for key #{key} is singular in class #{parent_class}; use #set to nil"
      end
    end

    #
    # Deletes the given key from the bnf_records hash. 
    #
    def delete_key(key)
      @bnf_records.delete(key)
    end

    #
    # True if the record item is not nil (if the BnfItem is singular) or an
    # empty array (if the BnfItem is multiple).
    #
    def has_data?(key)
      bnf_item = bnf_spec[key]
      if (bnf_item.multiple? and get(key).empty?) or
          (not bnf_item.multiple? and get(key).nil?)
        false
      else
        true
      end
    end

    #
    # Write the BNF records to file.  Ensures that the required records exist
    # according to the BnfSpec (otherwise an error is raised).  A file object
    # is expected.
    #
    def write(file, alt_bnf=nil)
      # Loop through each BNF item
      bnf = alt_bnf ? alt_bnf : bnf_spec
      bnf.each_item do |bnf_item|
        if has_data?(bnf_item.key)
          if bnf_item.multiple?
            get(bnf_item.key).each {|record| record.write(file)}
          else
            get(bnf_item.key).write(file)
          end
        elsif not bnf_item.optional?
          raise "Required data in BNF are not set: #{bnf_item}"
        end
      end
    end

    ##########################################################################
    # PRIVATE METHODS
    ##########################################################################
    
    private

    #
    # Used by #add and #set to convert a raw value into the proper class
    # given the key (if needed).  This method is not used outside of this
    # class.
    #
    def coerce_record_value(key, value)
      if value.kind_of?(Record) or value.kind_of?(Group)
        value
      else
        Record.new(key, value)
      end
    end

  end
end

