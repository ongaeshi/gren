require File.dirname(__FILE__) + '/test_helper.rb'
require File.dirname(__FILE__) + '/../lib/gren/util'

class TestGrenUtil < Test::Unit::TestCase
  def setup
  end
  
  def test_snip
    str = "abcdefghijkmlnopqrstuvwxyz"
    assert_equal(Gren::Util::snip(str), str)

    str = "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789|123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789|12345678901234567890123456789012345678901234567890123456"
    assert_equal(Gren::Util::snip(str), str)

    str = "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789|123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789|123456789012345678901234567890123456789012345678901234561"
    assert_equal(Gren::Util::snip(str), str[0, str.size - 1])

  end
end
