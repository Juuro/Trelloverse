require 'json'
require 'open-uri'
require 'pp'
require 'kramdown'
require './functions_old.rb'


#website aufrufen
list = open("https://api.trello.com/1/lists/4f68a4ab343ec61a754ad652/cards?key=0ccb4b07c006c5d5555a55b64a124c89&token=e9fe54ca188979634e2115c4862de38be500cd0d46c95b8a561e693d240268ba&filter=open").read

#JSON in Ruby-Object umwandeln
data = JSON.parse(list)

data.each do |element|

	title = element['name']
	element['desc'] = Kramdown::Document.new(element['desc'])
	description =  element['desc'].to_html

	#attachment
	hasAttachment = getAttachment(element['id']) 
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
		trelloToJoomla(title, description, attachments)
	else
		trelloToJoomla(title, description)
	end

	attHash = nil

end