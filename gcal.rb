#!/usr/bin/env ruby
#Encoding: UTF-8

require 'google/api_client'
require 'json'
require './functions.rb'
require './classes/CLgcal.rb'

options = CLcalendar.parse(ARGV)

$key = options.key
$token = options.token

puts "Member: "+getMember('me')['username']

# debug
#$key = '0ccb4b07c006c5d5555a55b64a124c89'
#$token = 'e9fe54ca188979634e2115c4862de38be500cd0d46c95b8a561e693d240268ba'

# In case you want to put you key and token in the file uncomment the following lines and enter your data1.
#$key = 'PUT YOUR KEY HERE'
#$token = 'PUT YOUR TOKEN HERE'

cardsToImport = Array.new

if !options.lists.nil?
	options.lists.each do |listId|
		cardsByList = getCardsByList(listId)
		cardsToImport = cardsToImport|cardsByList
	end
end

if !options.boards.nil?
	options.boards.each do |boardId|
		cardsByBoard = getCardsByBoard(boardId)
		cardsToImport = cardsToImport|cardsByBoard
	end
end

if !options.organizations.nil?
	options.organizations.each do |orgId|
		cardsByOrganization = getCardsByOrganization(orgId)
		cardsToImport = cardsToImport|cardsByOrganization
	end
end

if !options.cards.nil?
	options.cards.each do |cardId|
		cardsByCard = getCard(cardId)
		cardsToImport.push(cardsByCard)
	end
end

if options.all == true
	boards = getBoardsByMember('me')

	boards.each do |board|
		cardsByBoard = getCardsByBoard(board['id'])
		cardsToImport = cardsToImport|cardsByBoard
	end
end

#cardsFull = getCardsAsArray(cardsToImport, $key, $token, false)

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

# delete events from Google if they're not submitted anymore
getallevents = client.execute(:api_method => service.events.list,
															:parameters => {'calendarId' => 'primary', 'q' => 'trelloid'})

alleventsArray = Array.new
keepEvents  = Array.new							
						
while true
	allevents = getallevents.data.items
	
	allevents.each do |e|		
		alleventsArray << e.id
		
		cardsToImport.each do |card|
			if card['id'] == e.location.gsub(/trelloid /, '')
				keepEvents << e.id				
			end		
		end
	end
	
	if !(page_token = getallevents.data.next_page_token)
		break
	end
	getallevents = getallevents = client.execute(:api_method => service.events.list,
																	 							:parameters => {'calendarId' => 'primary', 'pageToken' => page_token})
end

deleteEvents = alleventsArray - keepEvents

deleteEvents.each do |eventId|
	client.execute(:api_method => service.events.delete,
									:parameters => {'calendarId' => 'primary', 'eventId' => eventId})
	puts eventId+" deleted!"
end

cardsToImport.each do |card|
	
	if card['due'] != nil		
		getevents = client.execute(:api_method => service.events.list,
														:parameters => {'calendarId' => 'primary', 'q' => 'trelloid '+card['id']})
		
		while true
			events = getevents.data.items
			if events.empty?
				event = {
					'summary' => card['name'],
					'description' => card['desc'],
					'location' => 'trelloid '+card['id'],
					'start' => {
						'dateTime' => getDate(card['due'], format='iso8601'),
						'timeZone' => 'Europe/Berlin'
					},
					'end' => {
						'dateTime' => getDate(card['due'], format='iso8601'),
						'timeZone' => 'Europe/Berlin'
					}
				}				
				
				insertevent = client.execute(:api_method => service.events.insert,
																:parameters => {'calendarId' => 'primary'},
																:body => JSON.generate(event),
																:headers => {'Content-Type' => 'application/json'})

				puts "\""+card['name']+"\" ("+card['id']+") event created!"
			else
				events.each do |e|
					
					#check if this card has changed
					if e.location == card['id']
						if (e.start.dateTime - (2*60*60)).strftime("%Y-%m-%dT%H:%M:00.000Z") != card['due'] || (e.end.dateTime - (2*60*60)).strftime("%Y-%m-%dT%H:%M:00.000Z") != card['due'] || e.summary != card['name']
							
							event = {
								'summary' => card['name'],
								'description' => card['desc'],
								'location' => 'trelloid '+card['id'],
								'start' => {
									'dateTime' => getDate(card['due'], format='iso8601'),
									'timeZone' => 'Europe/Berlin'
								},
								'end' => {
									'dateTime' => getDate(card['due'], format='iso8601'),
									'timeZone' => 'Europe/Berlin'
								}
							}		
							
							updateevent = client.execute(:api_method => service.events.update,
																			:parameters => {'calendarId' => 'primary', 'eventId' => e.id},
																			:body => JSON.dump(event),
																			:headers => {'Content-Type' => 'application/json'})
							
							puts "\""+card['name']+"\" ("+card['id']+") event changed!"
						elsif (e.description != card['desc'])
							
							event = {
								'summary' => card['name'],
								'description' => card['desc'],
								'location' => 'trelloid '+card['id'],
								'start' => {
									'dateTime' => getDate(card['due'], format='iso8601'),
									'timeZone' => 'Europe/Berlin'
								},
								'end' => {
									'dateTime' => getDate(card['due'], format='iso8601'),
									'timeZone' => 'Europe/Berlin'
								}
							}		
							
							updateevent = client.execute(:api_method => service.events.update,
																			:parameters => {'calendarId' => 'primary', 'eventId' => e.id},
																			:body => JSON.dump(event),
																			:headers => {'Content-Type' => 'application/json'})
							
							puts "\""+card['name']+"\" ("+card['id']+") event changed!"
						else
							#puts "\""+card['name']+"\" ("+card['id']+") event not changed!"
						end	
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

puts "Done!"