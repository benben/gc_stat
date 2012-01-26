#!/usr/bin/env ruby

require 'rubygems'
require 'gruff'
require 'nokogiri'

gpx_files = Dir.new(".").entries.reject!{|name| !(name =~ /(\.gpx)/)}

data = {}

def cleanup_namespaces(xml)
  protected_ns = %w( soapenv )
  xml.traverse do |el|
    next unless el.respond_to? :namespace
    if (ns=el.namespace) && 
        !protected_ns.include?(ns.prefix) then
      el['type'] = "#{ns.prefix}:#{el.name}"
      el.namespace = nil
    end
  end

  xml
end

finder = ""
dates = []

str = ""

gpx_files.each do |gpx_file|
  doc = cleanup_namespaces(Nokogiri::XML(open(gpx_file)))
	doc.xpath("//log").each do |log|
    log.xpath("finder").each do |f|
      finder = f.content
      data[finder] = [] unless data.has_key?(finder)
    end
    if log.xpath("type").text == "Found it"
      str = log.xpath("date").text.slice!(0..9)
      data[finder] << str
      dates << str unless dates.include?(str)
    end
  end
end

dates.sort!

dates_hash = {}
data_hash = {}
dates.each_index do |i|
  dates_hash[i] = dates[i]
end

data.each_value do |finder_value|
  count = 0
  data_hash[data.key(finder_value)] = []
  dates.each do |date|
    count += finder_value.count(date) if finder_value.include?(date)
    data_hash[data.key(finder_value)] << count
  end  
end

#puts dates_hash.inspect

g = Gruff::Line.new
g.title = "GC OLYMP" 
g.labels = dates_hash

data_hash.each_value do |finder_value|
  g.data(data_hash.key(finder_value), finder_value)
end

g.write('gc.png')

#g.data("Apples", [1, 2, 3, 4, 4, 3])