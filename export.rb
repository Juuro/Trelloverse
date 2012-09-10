#!/usr/bin/env ruby
#Encoding: UTF-8

require 'json'
require 'tmpdir'
require 'zippy'
require './functions.rb'
require './classes/CLbackup.rb'

options = CLbackup.parse(ARGV)

$key = options.key
$token = options.token
@filename = options.name

# debug
#Juurotest
#$key = '8c23c5c0c933680a5e155668654c40e6'
#$token = 'b4f1db7377c62ce9b02a4a266c2fdb8fdb53223ace32732bcd48a0492ddc747d'

# In case you want to put you key and token in the file uncomment the following lines and enter your data1.
#$key = 'PUT YOUR KEY HERE'
#$token = 'PUT YOUR TOKEN HERE'

puts "Member: "+getMember('me')['username']

if @filename.nil?
	puts "You have to specify a filename for the backup file!"
	abort
end

arrayBoards = getBoardsByMember('me')

directoryNameAttachments = File.join(Dir.tmpdir, "attachments")

arrayMembersByBoards = Array.new
arrayLists = Array.new
arrayCards = Array.new
arrayOrganizations = Array.new

arrayOrganizations = getOrganizationsByMember('me')

arrayBoards.each do |board|
	
	dataMembers = getMembersByBoard(board['id'])
	
	arrayMembers = Array.new
	dataMembers.each do |member|			
		arrayMembers.push(member)	
	end	
	 
	hashMembers = Hash.new
	
	hashMembers['id'] = board['id']
	hashMembers['name'] = board['name']
	hashMembers['members'] = arrayMembers	
	
	arrayMembersByBoards.push(hashMembers)	
	
	hashMembers = nil
	arrayMembers = nil	
	
	dataLists = getListsByBoard(board['id'])
	
	dataLists.each do |list|
		arrayLists.push(list)
	end	
	
	dataCards = getCardsByBoard(board['id'])
	
	arrayCards += getCardsAsArray(dataCards)		
end

hashBackup = Hash.new
hashBackup['organizations'] = arrayOrganizations
hashBackup['boards'] = arrayBoards
hashBackup['members'] = arrayMembersByBoards
hashBackup['lists'] = arrayLists
hashBackup['cards'] = arrayCards

backupFile = File.new(File.join(Dir.tmpdir, 'backup.json'), "wb")
backupFile.puts JSON.generate(hashBackup)
backupFile.close()

Zippy.create @filename do |zip|
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

puts "Done!"