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
   def test_do_sort
      data = @csvdata.load_csv(@conf.datadir)
      #p data, @csvdata.do_sort(1, true)
      assert_equal(@csvdata.do_sort(0), data)
      assert_equal(@csvdata.do_sort(1), data)
      assert_equal(@csvdata.do_sort(2), data)
      #assert_equal(@csvdata.do_sort(3), data)
      assert_not_equal(@csvdata.do_sort(0, true), data)
   end
end
