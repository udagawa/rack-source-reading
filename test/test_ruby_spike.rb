require 'test_helper'

class TesRubySpike < MiniTest::Test

  def test_hash_delete_if
    h = {key:"a", key2:nil}
    assert { 2 == h.size }
    h.delete_if { |k, v| v.nil? }
    assert { 1 == h.size }
  end

  def test_hash_update_or_merge
    h = {key:"value", key2:"value2"}
    assert { 2 == h.size }
    
    h.update({key3:"value3"})
    assert("update is merge!") { 3 == h.size }
    h.merge!({key4:"value4"})
    assert { 4 == h.size }
    h.merge({key5:"value5"})
    assert { 4 == h.size }
  end

end
