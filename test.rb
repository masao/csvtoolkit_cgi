#!/usr/bin/env ruby
# $Id$

require "test/unit"
require "index.rb"

class TCConfig < Test::Unit::TestCase
   def setup
      @conf = CSVToolkit::Config.new("test/test.conf")
   end
   def test_config
      assert(@conf)
      assert_equal("test/", @conf.datadir)
   end
end

class TCCSVToolKit < Test::Unit::TestCase
   def setup
      @conf = CSVToolkit::Config::new("test/test.conf")
      @csvdata = CSVToolkit.new( @conf )
   end
   def test_load_csv
      assert(tmp1 = @csvdata.load_csv("test/"))
      assert(tmp2 = @csvdata.load_csv(@conf.datadir))
      assert(tmp1 = @csvdata.load_csv("test/"))
      assert(tmp2 = @csvdata.load_csv(@conf.datadir))
      assert_equal(tmp1, tmp2)
   end
end
