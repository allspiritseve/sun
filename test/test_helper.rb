$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'sun'

require 'byebug'

require 'minitest/autorun'
require 'minitest/reporters'

Minitest::Reporters.use! Minitest::Reporters::DefaultReporter.new
