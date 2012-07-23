#!/usr/bin/env ruby
#Encoding: UTF-8

require 'rubygems'
require 'pp'
require 'json'
require 'open-uri'
require 'rest_client'
require 'tmpdir'
require 'zippy'
require './functions.rb'
require './classes/CLimport.rb'

options = CLimport.parse(ARGV)

@key = options.key.first
@token = options.token.first

# debug
#Juurotest
#@key = '8c23c5c0c933680a5e155668654c40e6'
#@token = 'b4f1db7377c62ce9b02a4a266c2fdb8fdb53223ace32732bcd48a0492ddc747d'

# In case you want to put you key and token in the file uncomment the following lines and enter your data1.
#@key = 'PUT YOUR KEY HERE'
#@token = 'PUT YOUR TOKEN HERE'

boards = open("https://api.trello.com/1/members/me/boards?key="+@key+"&token="+@token+"&filter=open").read
#parse JSON
dataBoards = JSON.parse(boards)

directoryNameAttachments = File.join(Dir.tmpdir, "attachments")

arrayBoards = Array.new
arrayLists = Array.new
arrayCards = Array.new
dataBoards.each do |board|
	
	members = open("https://api.trello.com/1/boards/"+board['id']+"/members?&key="+@key+"&token="+@token+"").read
	dataMembers = JSON.parse(members)
	
	arrayMembers = Array.new
	dataMembers.each do |member|			
		arrayMembers.push(member)	
	end	
	 
	hashMembers = Hash.new
	
	hashMembers['id'] = board['id']
	hashMembers['name'] = board['name']
	hashMembers['members'] = arrayMembers	
	
	arrayBoards.push(hashMembers)	
	
	hashMembers = nil
	arrayMembers = nil	
	
	lists = open("https://api.trello.com/1/boards/"+board['id']+"/lists?&key="+@key+"&token="+@token+"").read
	dataLists = JSON.parse(lists)
	
	dataLists.each do |list|
		arrayLists.push(list)
	end	
	
	cards = open("https://api.trello.com/1/boards/"+board['id']+"/cards?&key="+@key+"&token="+@token+"").read
	dataCards = JSON.parse(cards)
	
	arrayCards = arrayCards + getCardsAsArray(dataCards, @key, @token)
		
end

hashBackup = Hash.new
hashBackup['boards'] = JSON.parse(boards)
hashBackup['members'] = arrayBoards
hashBackup['lists'] = arrayLists
hashBackup['cards'] = arrayCards

backupFile = File.new(File.join(Dir.tmpdir, 'backup.json'), "wb")
backupFile.puts JSON.generate(hashBackup)
backupFile.close()
pp "Done!"

Zippy.create 'backup.zip' do |zip|
	zip['backup.json'] = File.open(backupFile)

	Dir.entries(directoryNameAttachments).each do |file|
		fileName = File.new(File.join(directoryNameAttachments, file), "r")
		if file != "." && file != ".."
			zip['attachments/'+file] = File.open(fileName)
			fileName.close
			File.delete(fileName)
		end
	end
end

Dir.rmdir(directoryNameAttachments)
File.delete(backupFile)