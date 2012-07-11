require 'json'
require 'open-uri'
require 'pp'
require 'kramdown'
require './functions.rb'
require './classes/article.rb'
require './classes/attachment.rb'

#website aufrufen
list = open("https://api.trello.com/1/lists/4f68a4ab343ec61a754ad652/cards?key=0ccb4b07c006c5d5555a55b64a124c89&token=e9fe54ca188979634e2115c4862de38be500cd0d46c95b8a561e693d240268ba&filter=open").read

#JSON in Ruby-Object umwandeln
data = JSON.parse(list)

articles = []

data.each do |element|
	newArticle = nil
	
	title = element['name']	
	description = Kramdown::Document.new(element['desc']).to_html
	
	#attachment
	hasAttachment = getAttachment(element['id']) 
	attachments = []
	if hasAttachment[0] != nil
		for attachmentArray in hasAttachment do			
			attachment = Attachment.new(attachmentArray['name'], attachmentArray['url'])						
			attachments << attachment
		end		
		
	end
	#end attachment	
	
	newArticle = Article.new(title, title, description, attachments)
	
	articles << newArticle
end

trelloToJoomlaSingle(285, articles)