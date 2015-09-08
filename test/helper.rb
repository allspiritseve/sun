$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'simplecov'
SimpleCov.start

require 'sun'

require 'byebug'
require 'minitest/autorun'
require 'minitest/reporters'


Minitest::Reporters.use! Minitest::Reporters::DefaultReporter.new


class Minitest::Test
  def assert_sun_calculation(expected, actual, name = 'value', delta = Rational(1, 1000))
    assert_in_delta expected, actual, delta, "#{name} was not in delta"
  end
end
