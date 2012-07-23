#!/usr/bin/env ruby
#Encoding: UTF-8

require 'rubygems'
require 'icalendar'
require 'date'
require 'pp'
require 'json'
require 'open-uri'
require './functions.rb'
require './classes/CLcalendar.rb'

options = CLcalendar.parse(ARGV)

@key = options.key.first
@token = options.token.first

# debug
#@key = '897f1e4573b21a4c8ad8a5cbb4bb3441'
#@token = 'f60eaa453d5eba261d03b8f10508ff21b302f87409f782932fd0d87ca67c4307'

# In case you want to put you key and token in the file uncomment the following lines and enter your data1.
#@key = 'PUT YOUR KEY HERE'
#@token = 'PUT YOUR TOKEN HERE'

cardsToImport = Array.new

if !options.lists.nil?
	options.lists.each do |listId|
		cardsByList = getCardsByList(listId, @key, @token)
		cardsToImport = cardsToImport|cardsByList
	end
end

if !options.boards.nil?
	options.boards.each do |boardId|
		cardsByBoard = getCardsByBoard(boardId, @key, @token)
		cardsToImport = cardsToImport|cardsByBoard
	end
end

if !options.cards.nil?
	options.cards.each do |cardId|
		cardsByCard = getSingleCard(cardId, @key, @token)
		cardsToImport.push(cardsByCard)
	end
end

if options.all == true
	boards = open("https://api.trello.com/1/members/me/boards?key="+@key+"&token="+@token+"&filter=open").read
	boards = JSON.parse(boards)
	
	boards.each do |board|
		cardsByBoard = getCardsByBoard(board['id'], @key, @token)
		cardsToImport = cardsToImport|cardsByBoard
	end
end

cardsFull = getCardsAsArray(cardsToImport, @key, @token, false)

include Icalendar

# Create a calendar
cal = Calendar.new

cal.timezone do
	timezone_id             "Europe/Berlin"
	
	standard do
		timezone_offset_from  "+0200"
		timezone_offset_to    "+0100"
		timezone_name         "GMT+01:00"
		dtstart               "20060811T073001"
		add_recurrence_rule   "FREQ=YEARLY;BYMONTH=10;BYDAY=-1SU"
	end
end
	
cardsFull.each do |card|

	if card['due'] != nil	
		
		cat = ["FAMILY"]
		
		# Create an event
		cal.event do
			dtstart       Date.parse(card['due'])
			dtend         Date.parse(card['due'])
			summary     	card['name']
			description 	card['id']
			location 			card['url']
			#klass       "PUBLIC"
			transp				"TRANSPARENT"
			categories		cat
			sequence			1
			#organizer			%w(CN=John Doe:MAILTO:john.doe@example.com)			
			attendees     %w(mail@sebastian-engel.de juuro@me.com bla@blu.de)
			url						card['url']
		end		
	end
end

cal.publish

icalendar = File.new("icalendar.ics", "w+")
icalendar.puts cal.to_ical

pp 'Done!'

icalendar.close()