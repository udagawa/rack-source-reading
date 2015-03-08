$LOAD_PATH.unshift(File.dirname(__FILE__) + "/../lib")

require "minitest/autorun"
require 'minitest/power_assert'

require "minitest/reporters"
Minitest::Reporters.use!

require 'testrequest'
require 'rack/test_helpers'
