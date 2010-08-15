require File.dirname(__FILE__) + '/test_helper.rb'
require File.dirname(__FILE__) + '/../lib/string_snip'

class TestStringSnip < Test::Unit::TestCase
  def setup
  end
  
  def test_string_snip
    str = "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789|123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789|12345678901234567890123456789012345678901234567890123456"

    snip_str = StringSnip::snip(str,
                                [0..7, -8..-1])
    assert_equal(str, snip_str)
  end
end
