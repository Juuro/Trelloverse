#!/usr/bin/env ruby
#Encoding: UTF-8

require 'rubygems'
require 'pp'
require 'json'
require 'open-uri'
require 'net/http'
require 'uri'
require 'zippy'
require 'rest_client'
require './functions.rb'
require './classes/CLbackup.rb'

options = CLbackup.parse(ARGV)

$key = options.key.first
$token = options.token.first

# debug
#$key = '897f1e4573b21a4c8ad8a5cbb4bb3441'
#$token = 'f60eaa453d5eba261d03b8f10508ff21b302f87409f782932fd0d87ca67c4307'

# In case you want to put you key and token in the file uncomment the following lines and enter your data1.
#$key = 'PUT YOUR KEY HERE'
#$token = 'PUT YOUR TOKEN HERE'

cardsRelation = Hash.new
boardsRelation = Hash.new

backup = String.new
Zippy.open('backup.zip') do |zip|
  backup = JSON.parse(zip['backup.json'])
  
  if zip['boards.json'] == nil && zip['cards.json'] == nil
    puts "Error: \"boards.json\" and \"cards.json\" are not existing."
    exit
  end
  boardsRelation = JSON.parse(zip['boards.json'])
  cardsRelation = JSON.parse(zip['cards.json'])
end

boardsOld = backup['members']
cardsOld = backup['cards']

puts "\n----- IMPORT MEMBERS -----\n\n"

puts "Please visit http://www.trello.com. Login as "+getMember('me')['username']+" ("+getMember('me')['id']+")! Add the following members to the corresponding boards MANUALLY.\n"

boardsOld.each do |board|

  puts "\n"+board['name']+" ("+board['id']+"):\n"

  board['members'].each do |member|
    puts "\t"+member['username']+" ("+member['id']+")"
  end
end

puts "\nIf you have added all necessary members to your boards press ENTER to continue!"
gets

boardsOld.each do |board|	
  membersNewBoard = open("https://api.trello.com/1/boards/"+boardsRelation[board['id']]+"/members?key="+$key+"&token="+$token+"").read
  membersNewBoard = JSON.parse(membersNewBoard)	

  missingMembers = board['members'] - membersNewBoard
  
  if !missingMembers.empty?
    missingMembers.each do |member|
      puts "You haven't added "+member['username']+" ("+member['id']+") to "+board['name']+" ("+board['id']+")!"
    end
    puts "Press ENTER to continue!"
    gets
  end
end

cardsOld.each do |card|
  
  # import members		
  members = card['idMembers']
  
  members.each do |member|   
    begin
      RestClient.post(
          'https://api.trello.com/1/cards/'+cardsRelation[card['id']]+'/members',
          :value   => member,
          :key     => $key,
          :token   => $token
      )
      puts "\tMember \""+member+"\" added!"
    rescue => e
      puts "\t"+e.response+" ("+member+")"
    end      	
  end
  # end import members
end