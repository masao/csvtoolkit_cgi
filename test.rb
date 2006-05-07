#!/usr/bin/env ruby
# $Id$

require "test/unit"
require "index.rb"

class TCConfig < Test::Unit::TestCase
   def setup
      @conf = Config::new("test/test.conf")
   end
   def test_config
      assert(@conf)
      assert_equal("csv/", @conf.datadir)
   end
end

class TCCSVToolKit < Test::Unit::TestCase
   def setup
      @conf = Config::new("test/test.conf")
   end
   def test_load_csv
      assert(load_csv("test/"))
      assert(load_csv(@conf.datadir))
      assert_equal(load_csv("test/"), load_csv("test/"))
   end
end
