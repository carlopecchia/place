require 'rubygems'
require 'test/unit'

$: << File.join(File.dirname(__FILE__), '../lib')
require 'ohm'
require 'place'
include Place

Place.logger_setup('/dev/null')