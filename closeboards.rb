#!/usr/bin/env ruby
#Encoding: UTF-8

require 'rubygems'
require 'pp'
require 'json'
require 'open-uri'
require 'net/http'
require 'uri'
require './functions.rb'

@key = '897f1e4573b21a4c8ad8a5cbb4bb3441'
@token = 'f60eaa453d5eba261d03b8f10508ff21b302f87409f782932fd0d87ca67c4307'

puts "Member: "+getMember('me', @key, @token)['username']

boards = open("https://api.trello.com/1/members/juurotest2/boards?key="+@key+"&token="+@token+"&filter=open").read
#parse JSON
data = JSON.parse(boards)

data.each do |board|
	uri = URI('https://api.trello.com/1/boards/'+board['id']+'/closed')
	req = Net::HTTP::Put.new(uri.path)

	req.set_form_data('value' => 'true','key'=>@key, 'token'=>@token)

	Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
		response = http.request(req) # Net::HTTPResponse object	
		pp JSON.parse(response.body)['id']
	end
end

puts 'Done!'