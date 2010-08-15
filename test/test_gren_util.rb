require File.dirname(__FILE__) + '/test_helper.rb'
require File.dirname(__FILE__) + '/../lib/gren/util'

class TestGrenUtil < Test::Unit::TestCase
  def setup
  end
  
  def test_snip
    str = "abcdefghijkmlnopqrstuvwxyz"
    assert_equal(Gren::Util::snip(str, nil), str)

    str = "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789|123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789|12345678901234567890123456789012345678901234567890123456"
    assert_equal(Gren::Util::snip(str, nil), str)

#     str = "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789|123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789|123456789012345678901234567890123456789012345678901234561"
#     match_datas = []
#     match_datas << str.match(/123456789\|/)
#     assert_equal(Gren::Util::snip(str, match_datas), str[0, str.size - 1])

#     str = "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789|123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789|123456789012345678901234567890123456789012345678901234561"
#     match_datas = []
#     match_datas << str.match(/1234567890/)
#     assert_equal(Gren::Util::snip(str, match_datas), str[0, str.size - 1])

  end
end
