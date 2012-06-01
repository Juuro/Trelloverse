#!/usr/bin/env ruby
#Encoding: UTF-8

require 'rubygems'
require 'pp'
require 'json'
require 'open-uri'
require 'net/http'
require 'uri'

boards = open("https://api.trello.com/1/members/juurotest/boards?key=8c23c5c0c933680a5e155668654c40e6&token=b4f1db7377c62ce9b02a4a266c2fdb8fdb53223ace32732bcd48a0492ddc747d&filter=open").read
#parse JSON
data = JSON.parse(boards)

data.each do |board|
	uri = URI('https://api.trello.com/1/boards/'+board['id']+'/closed')
	req = Net::HTTP::Put.new(uri.path)

	req.set_form_data('value' => 'true','key'=>'8c23c5c0c933680a5e155668654c40e6', 'token'=>'b4f1db7377c62ce9b02a4a266c2fdb8fdb53223ace32732bcd48a0492ddc747d')

	Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
		response = http.request(req) # Net::HTTPResponse object	
		pp JSON.parse(response.body)['id']
	end
end
