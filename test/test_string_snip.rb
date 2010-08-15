require File.dirname(__FILE__) + '/test_helper.rb'
require File.dirname(__FILE__) + '/../lib/string_snip'

class TestStringSnip < Test::Unit::TestCase
  def setup
  end
  
  def test_string_snip
    str = "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789|123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789|12345678901234567890123456789012345678901234567890123456"

    snipper = StringSnip.new
    snip_str = snipper.snip(str, [0..7, -8..-1])
    assert_equal(snip_str, str)

    snipper = StringSnip.new(128)
    snip_str = snipper.snip(str, [0..7, -8..-1])
    assert_equal(snip_str, "12345678<<snip>>90123456")
  end
end
