require 'json'
require 'open-uri'
require 'pp'
require 'kramdown'
require './functions.rb'


# listId of the list whose cards should be imported to Joomla
listId = '4f68a4ab343ec61a754ad652'

#website aufrufen
list = open("https://api.trello.com/1/lists/"+listId+"/cards?key=0ccb4b07c006c5d5555a55b64a124c89&token=e9fe54ca188979634e2115c4862de38be500cd0d46c95b8a561e693d240268ba&filter=open").read

#JSON in Ruby-Object umwandeln
data = JSON.parse(list)

data.each do |card|	

	title = card['name']
	card['desc'] = Kramdown::Document.new(card['desc'])
	description =  card['desc'].to_html
	cardId = card['id']
	
	created = nil
	if !cardUpdated(card['id']).empty?
		created = getDate(cardUpdated(card['id']).first['date'], 'joomla')
	else
		created = getDate(cardCreated(card['id']).first['date'], 'joomla')
	end

	#attachment
	hasAttachment = getAttachment(card['id']) 
	attachments = Hash.new 
	if hasAttachment[0] != nil
		c = 0
		for attachment in hasAttachment do

			url = attachment['url']
			attachment['name']

			attHash = Hash.new
			attHash['url'] = url
			attHash['name'] = attachment['name']

			attachments[c] = attHash

			c += 1
		end		

	end
	#end attachment

	if attHash != nil	
		trelloToJoomlaMultiple(title, created, cardId, description, attachments)
	else
		trelloToJoomlaMultiple(title, created, cardId, description)
	end

	attHash = nil

end