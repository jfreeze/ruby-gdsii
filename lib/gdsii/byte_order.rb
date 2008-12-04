#
# ByteOrder is lifted from ruby-talk 107439, cited by Michael Neumann
#
module ByteOrder 

  Native = :Native
  Big = BigEndian = Network = :BigEndian
  Little = LittleEndian = :LittleEndian

  # examines the locale byte order on the running machine
  def byte_order
    if [0x12345678].pack("L") == "\x12\x34\x56\x78" 
      BigEndian
    else
      LittleEndian
    end
  end
  alias byteorder byte_order
  module_function :byte_order, :byteorder

  def little_endian?
    byte_order == LittleEndian
  end

  def big_endian?
    byte_order == BigEndian
  end

  alias little? little_endian? 
  alias big? big_endian?
  alias network? big_endian?

  module_function :little_endian?, :little?
  module_function :big_endian?, :big?, :network?

end
