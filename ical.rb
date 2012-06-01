#!/usr/bin/env ruby
#Encoding: UTF-8

require 'rubygems'
require 'icalendar'
require 'date'
require 'pp'
require 'json'
require 'open-uri'

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

boards = open("https://api.trello.com/1/members/juuro/boards?key=0ccb4b07c006c5d5555a55b64a124c89&token=e9fe54ca188979634e2115c4862de38be500cd0d46c95b8a561e693d240268ba&filter=open").read
#parse JSON
data = JSON.parse(boards)

data.each do |board|
	
	cards = open("https://api.trello.com/1/boards/"+board['id']+"/cards?key=0ccb4b07c006c5d5555a55b64a124c89&token=e9fe54ca188979634e2115c4862de38be500cd0d46c95b8a561e693d240268ba&filter=open").read
	#parse JSON
	data = JSON.parse(cards)
	
	
	cat = Array.new
	
	cat.push("FAMILY")
	
	data.each do |card|
	
		if card['due'] != nil	
			
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
end

cal.publish

icalendar = File.new("icalendar.ics", "w+")
icalendar.puts cal.to_ical

icalendar.close()