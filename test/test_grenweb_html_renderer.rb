require File.join(File.dirname(__FILE__), "test_helper.rb")
require File.join(File.dirname(__FILE__), "../lib/grenweb/html_renderer.rb")

class TestGrenwebHTMLRendeler < Test::Unit::TestCase
  def setup
  end
  
  def test_html_renderer
    assert_equal("<span class='pagination-link'><a href='./?page=1'>test</a></span>\n", Grenweb::HTMLRendeler.pagination_link(1, "test"))
  end
end
