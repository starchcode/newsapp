require "test_helper"

class SimpleWorkingTest < ActiveSupport::TestCase
  def test_basic_assertion
    assert true
  end
  
  def test_math
    assert_equal 2 + 2, 4
  end
end

