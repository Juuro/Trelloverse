#!/usr/bin/env ruby
#Encoding: UTF-8

require 'rubygems'
require 'pp'
require 'json'
require 'open-uri'
require 'net/http'
require 'uri'



fileJson = nil

#read backup
File.open("backup.boards.json", "r") do |infile|
	fileJson = JSON.parse(infile.gets)	
end

# import boards
uri = URI('https://api.trello.com/1/boards')
req = Net::HTTP::Post.new(uri.path)

fileJson.each do |board|
	pp board['name']	
	prefs = board['prefs']
	
	req.set_form_data('name' => 'ZTest-'+board['name'], 
										'desc' => board['desc'],
										'prefs_permissionLevel' => prefs['permissionLevel'],
										'prefs_selfJoin' => prefs['selfJoin'],
										'prefs_invitations' => prefs['invitations'],
										'prefs_comments' => prefs['comments'],
										'prefs_voting' => prefs['voting'],
										'key'=>'8c23c5c0c933680a5e155668654c40e6',
										'token'=>'b4f1db7377c62ce9b02a4a266c2fdb8fdb53223ace32732bcd48a0492ddc747d')
	
	Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
		response = http.request(req) # Net::HTTPResponse object	
		pp JSON.parse(response.body)['id']
	end
end