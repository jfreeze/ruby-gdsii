require 'gdsii/group'
require 'gdsii/mixins'

module Gdsii

  #
  # GDSII element property
  #
  class Property < Group

    include Comparable

    #
    # Property BNF description
    #
    #  <element>   ::= {<boundary> | <path> | <sref> | <aref> |
    #                  <text> | <node> | <box>}  {<property>}*  ENDEL
    #  <property>  ::= PROPATTR PROPVALUE
    #
    self.bnf_spec = BnfSpec.new(
      BnfItem.new(GRT_PROPATTR),
      BnfItem.new(GRT_PROPVALUE)
    )

    #
    # Property object constructor.  A property consists of a attribute
    # number (Fixnum) and a respective property value as a String.
    #
    def initialize(attr=nil, value=nil)
      super()
      self.attr = attr unless attr.nil?
      self.value = value unless value.nil? 
    end

    #
    # Get the attribute number (Fixnum)
    #
    def attr() @records.get_data(GRT_PROPATTR); end

    #
    # Set the attribute record
    #
    def attr=(val) @records.set(GRT_PROPATTR,val); end

    #
    # Get the property value (String)
    #
    def value() @records.get_data(GRT_PROPVALUE); end

    #
    # Set the property value
    #
    def value=(val) @records.set(GRT_PROPVALUE,val); end

    #
    # Define order for sorting and comparing of property values (through
    # inclusion of Comparable module)
    #
    def <=>(other)
      self.attr <=> other.attr
    end
    
  end

  ############################################################################

  #
  # Holds a collection of Property objects.  Most methods are mixed in from
  # the Access::EnumerableGroup module.
  #
  class Properties < Group

    include Access::EnumerableGroup
    
    #
    # Properties BNF description
    #
    #  <properties> ::= {<property>}*
    #  <property>   ::= PROPATTR PROPVALUE
    #
    self.bnf_spec = BnfSpec.new(
      BnfItem.new(Property, true, true)
    )

    #
    # Define a new list of properties
    #
    def initialize(properties=[])
      super()
      @records[Property] = @list = properties
    end


    #######################
    ## PROTECTED METHODS ##
    #######################
    
    protected

    # Used by Access::EnumerableGroup to validate addition
    def validate_addition(object)
      unless object.kind_of?(Property)
        raise TypeError, "Invalid addition: #{object.class}; expecting Gdsii::Property"
      end
    end
  
  end
end
