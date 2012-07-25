require 'json'
require 'open-uri'
require 'pp'
require 'kramdown'
require './functions.rb'
require './classes/article.rb'
require './classes/attachment.rb'
require './classes/CLJoomlaMultiple.rb'

options = CLJoomlaMultiple.parse(ARGV)

@key = '0ccb4b07c006c5d5555a55b64a124c89'
@token = 'e9fe54ca188979634e2115c4862de38be500cd0d46c95b8a561e693d240268ba'


cardsToImport = Array.new

if !options.lists.nil?
	options.lists.each do |listId|
		cardByList = getCardsByList(listId, @key, @token)
		cardsToImport = cardsToImport|cardByList
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

#website aufrufen
list = open("https://api.trello.com/1/lists/4f68a4ab343ec61a754ad652/cards?key="+@key+"&token="+@token+"&filter=open").read

articles = []

cardsToImport.each do |element|
	newArticle = nil
	
	title = element['name']	
	description = Kramdown::Document.new(element['desc']).to_html
	
	#attachment
	hasAttachment = getAttachment(element['id'], @key, @token) 
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