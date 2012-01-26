#!/usr/bin/env ruby

require 'rubygems'
require 'gruff'
require 'nokogiri'

gpx_files = Dir.new(".").entries.reject!{|name| !(name =~ /(\.gpx)/)}

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

gpx_files.each do |gpx_file|
  doc = cleanup_namespaces(Nokogiri::XML(open(gpx_file)))
	doc.xpath("//log").each do |log|	
		puts log.content
	end
end
