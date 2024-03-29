#!/usr/bin/env ruby
# $Id$

require "cgi"
require "erb"
require "csv"
require "yaml"
require "iconv"

CSVTOOLKIT_VERSION = '0.1alpha ' << "$Date$".scan(/(\d{4})\/(\d{2})\/(\d{2})/).join("")

CONFIG = "csvtoolkit.conf"

class String
   def escape_html
      CGI.escapeHTML(self)
   end
   def shorten(len = 100)
      if self.length > len
         require "nkf"
         lines = NKF.nkf("-E -e -m0 -f#{len - 2}", self).split(/\n/)
         if lines.size > 1
            lines[0].concat( '..' )
         else
            self
         end
      else
         self
      end
   end
end

class CGI
   def valid?( param, idx = 0 )
      begin
         self.params[param] and self.params[param][idx] and self.params[param][idx].length > 0
      rescue NameError # for Tempfile class of ruby 1.6
         self.params[param][idx].stat.size > 0
      end
   end
   def sort_by
      valid?("sort_by") and self.params["sort_by"][0]
   end
   def item_id
      valid?("item_id") and self.params["item_id"][0]
   end
   def start
      valid?("start") ? self.params["start"][0].to_i : 0
   end
   def self_url
      "http://" + server_name.to_s + script_name.to_s
   end
end

class CSVToolkit
   class Config
      def initialize( filename )
         @conf = open(filename){|io| YAML.load(io) }
      end
      def method_missing( name, args = nil )
         if @conf.has_key?(name.to_s)
            @conf[name.to_s]
         else
            raise NameError::new("method_missing: #{name.inspect}( #{args.inspect} )")
         end
      end
   end

   attr_reader :data, :toc
   def initialize( config )
      @conf = config
   end
   def load_csv( dir )
      @data = []
      iconv = Iconv.new( "utf-8", @conf.encoding )
      Dir.glob(File.join(dir, "*.csv")).each do |f|
         tmp = []
         CSV.open(f, "r", @conf.csv_separator){|row|
            tmp << row.map{|e|
               begin
                  iconv.iconv(e)
               rescue Iconv::IllegalSequence
               end
            }
         }
         if @conf.skip_csvheader
            tmp = tmp[@conf.skip_csvheader..-1]
         end
         @data += tmp
      end
      @data
   end
   def do_filter( criteria )
   end
   def do_sort( idx, reverse = nil )
      #p idx
      @data = @data.sort_by{|e| e[idx] || "\xff" }
      @data.reverse! if reverse
      @toc = {}
      @data.each_with_index do |e, i|
         if not @toc.has_key?(e[idx]) and not e[idx].nil? and not e[idx].empty?
            @toc[e[idx]] = i
         end
      end
      @data
   end
   def []( idx )
      @data[ idx ]
   end
   def size
      @data.size
   end
end

if $0 == __FILE__
   cgi = CGI.new
   conf = CSVToolkit::Config.new( "csvtoolkit.conf" )
   csvdata = CSVToolkit.new( conf )
   csvdata.load_csv(conf.datadir)
   if cgi.valid?("sort_by")
      sort_criteria = cgi.sort_by
      if sort_criteria.sub!(/^-/, "")
         reverse = true
      end
      csvdata.do_sort( sort_criteria.to_i, reverse )
   end

   if cgi.valid?("item_id") and item = csvdata[item_id.to_i]
      puts cgi.header
      puts ERB.new( open("./skel/item_id.html"){|f| f.read }, $SAFE, 2 ).result(binding)
   else
      puts cgi.header
      puts ERB.new( open("./skel/list.html"){|f| f.read }, $SAFE, 2 ).result(binding)
   end
end
