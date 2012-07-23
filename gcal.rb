#!/usr/bin/env ruby
#Encoding: UTF-8

require 'rubygems'
require 'google/api_client'
#require 'yaml'
require 'pp'
require 'json'
require 'open-uri'
require './functions.rb'
require './classes/CLcalendar.rb'

options = CLcalendar.parse(ARGV)

@key = options.key.first
@token = options.token.first

# debug
#@key = '0ccb4b07c006c5d5555a55b64a124c89'
#@token = 'e9fe54ca188979634e2115c4862de38be500cd0d46c95b8a561e693d240268ba'

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



#oauth_yaml = YAML.load_file('~/Dropbox/Studium/Diplomarbeit/read/.google-api.yaml')
client = Google::APIClient.new
client.authorization.client_id = '866752766650.apps.googleusercontent.com'
client.authorization.client_secret = 'arLSDNQqkudI-hoI554ZQbj2'
client.authorization.scope = 'https://www.googleapis.com/auth/calendar'
client.authorization.refresh_token = '1/jHMBJZu-Km53p3C09aUSUfBNifFj-LMVfIrRwaG708c'
client.authorization.access_token = 'ya29.AHES6ZRrlyLgXwWGhdYzwl1Wmgwa5DLGJh4ud9aoUMNwnv5q5-2Q5Q'

result = client.authorization.fetch_access_token!
client.authorization.access_token = result['access_token']

service = client.discovered_api('calendar', 'v3')



cardsFull.each do |card|
	
	if card['due'] != nil		
		getevents = client.execute(:api_method => service.events.list,
														:parameters => {'calendarId' => 'primary', 'q' => card['id']})
		
		while true
			events = getevents.data.items
			if events.empty?
				event = {
					'summary' => card['name'],
					'description' => card['id'],
					'location' => card['url'],
					'start' => {
						'dateTime' => card['due'],
						'timeZone' => 'Europe/Berlin'
					},
					'end' => {
						'dateTime' => card['due'],
						'timeZone' => 'Europe/Berlin'
					}
				}		
				
				insertevent = client.execute(:api_method => service.events.insert,
																:parameters => {'calendarId' => 'primary'},
																:body => JSON.dump(event),
																:headers => {'Content-Type' => 'application/json'})

				puts "\""+card['name']+"\" ("+card['id']+") event created!"
			else
				events.each do |e|
					#check if this card has changedBackup
					if (e.start.dateTime - (2*60*60)).strftime("%Y-%m-%dT%H:%M:00.000Z") != card['due'] || (e.end.dateTime - (2*60*60)).strftime("%Y-%m-%dT%H:%M:00.000Z") != card['due'] || e.summary != card['name']
						result = client.execute(:api_method => service.events.delete,
																		:parameters => {'calendarId' => 'primary', 'eventId' => e.id})
						event = {
							'summary' => card['name'],
							'description' => card['id'],
							'location' => card['url'],
							'start' => {
								'dateTime' => card['due'],
								'timeZone' => 'Europe/Berlin'
							},
							'end' => {
								'dateTime' => card['due'],
								'timeZone' => 'Europe/Berlin'
							}
						}		
						
						insertevent = client.execute(:api_method => service.events.insert,
																		:parameters => {'calendarId' => 'primary'},
																		:body => JSON.dump(event),
																		:headers => {'Content-Type' => 'application/json'})
						
						puts "\""+card['name']+"\" ("+card['id']+") event changed!"
					else
						puts "\""+card['name']+"\" ("+card['id']+") not changed!"
					end					
				end
			end
			
			if !(page_token = getevents.data.next_page_token)
				break
			end
			getevents = getevents = client.execute(:api_method => service.events.list,
																			 :parameters => {'calendarId' => 'primary', 'pageToken' => page_token})
		end		
	end
end
#=end