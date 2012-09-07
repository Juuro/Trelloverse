#!/usr/bin/env ruby
#Encoding: UTF-8

require 'json'
require 'zippy'
require './functions.rb'
require './classes/CLbackup.rb'

options = CLbackup.parse(ARGV)

$key = options.key.first
$token = options.token.first
@filename = options.name.first

# debug
#$key = '897f1e4573b21a4c8ad8a5cbb4bb3441'
#$token = 'f60eaa453d5eba261d03b8f10508ff21b302f87409f782932fd0d87ca67c4307'

# In case you want to put you key and token in the file uncomment the following lines and enter your data1.
#$key = 'PUT YOUR KEY HERE'
#$token = 'PUT YOUR TOKEN HERE'

puts "Member: "+getMember('me')['username']

if @filename.nil?
  puts "ERROR: You have to specify a filename of the backup file!"
  abort
else
  if `file -Ib #{@filename}`.gsub(/;.*\n/, "") != "application/zip"
    puts "ERROR: The backup file has to be a ZIP file!"
    abort
  end
end

cardsRelation = Hash.new

backup = String.new
Zippy.open('backup.zip') do |zip|
  backup = JSON.parse(zip['backup.json'])
  
  if zip['cards.json'] == nil
    puts "Error: \"cards.json\" are not existing."
    exit
  end
  cardsRelation = JSON.parse(zip['cards.json'])
end

boardsOld = backup['members']
cardsOld = backup['cards']

puts "\n----- IMPORT MEMBERS -----\n\n"


cardsOld.each do |card|
  
  # import members		
  members = card['idMembers']
  
  members.each do |member|   
    begin
      response = postMemberAddCard(cardsRelation[card['id']], member)      
    rescue => e
      puts "\t"+e.response+" ("+member+")"
    else
      puts "\tMember \""+response.first['username']+"\" ("+response.first['id']+") added!"
    end      	
  end
  # end import members
end