require 'json'
require 'open-uri'
require 'pp'
require 'kramdown'
require './functions.rb'
require './classes/CLJoomlaMultiple.rb'


options = CLJoomlaMultiple.parse(ARGV)

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

sectionid = options.section.first
catid = options.category.first

cardsToImport.each do |card|	

	title = card['name']
	card['desc'] = Kramdown::Document.new(card['desc'])
	description =  card['desc'].to_html
	cardId = card['id']
	
	created = nil
	if !cardUpdated(card['id'], @key, @token).empty?
		created = getDate(cardUpdated(card['id'], @key, @token).first['date'], 'joomla')
	else
		created = getDate(cardCreated(card['id'], @key, @token).first['date'], 'joomla')
	end

	#attachment
	hasAttachment = getAttachment(card['id'], @key, @token) 
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