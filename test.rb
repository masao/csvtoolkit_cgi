#!/usr/bin/env ruby
# $Id$

require "test/unit"
require "index.rb"

class TCConfig < Test::Unit::TestCase
   def setup
      @conf = Config::new("test.conf")
   end
   def test_config
      assert(@conf)
      assert_equal("csv/", @conf.datadir)
   end
end
