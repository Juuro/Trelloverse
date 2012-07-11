require 'json'
require 'open-uri'
require 'pp'
require 'kramdown'
require './functions.rb'
require './classes/JoomlaMultiple.rb'


# listId of the list whose cards should be imported to Joomla
listId = '4f68a4ab343ec61a754ad652'

options = JoomlaMultiple.parse(ARGV)

cardsToImport = Array.new

if !options.lists.nil?
	options.lists.each do |listId|
		cardByList = JSON.parse(getCardsByList(listId))
		cardsToImport = cardsToImport|cardByList
	end
end

if !options.boards.nil?
	options.boards.each do |boardId|
		cardsByBoard = JSON.parse(getCardsByBoard(boardId))
		cardsToImport = cardsToImport|cardsByBoard
	end
end

if !options.cards.nil?
	options.cards.each do |cardId|
		cardsByCard = getSingleCard(cardId)
		cardsToImport.push(cardsByCard)
	end
end

sectionid = options.section.first
catid = options.category.first

cardsToImport.each do |card|	

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
		trelloToJoomlaMultiple(title, created, cardId, sectionid, catid, description, attachments)
	else
		trelloToJoomlaMultiple(title, created, cardId, sectionid, catid, description)
	end

	attHash = nil

end