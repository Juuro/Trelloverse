#!/usr/bin/env ruby
#Encoding: UTF-8

require 'json'
require 'rest_client'
require 'kramdown'
require './functions.rb'
require './classes/article.rb'
require './classes/attachment.rb'
require './classes/CLJoomlaMultiple.rb'

options = CLJoomlaMultiple.parse(ARGV)

$key = '0ccb4b07c006c5d5555a55b64a124c89'
$token = 'e9fe54ca188979634e2115c4862de38be500cd0d46c95b8a561e693d240268ba'

puts "Member: "+getMember('me')['username']


cardsToImport = Array.new

if !options.lists.nil?
	options.lists.each do |listId|
		cardByList = getCardsByList(listId)
		cardsToImport = cardsToImport|cardByList
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
		cardsByCard = getSingleCard(cardId)
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

articles = []

cardsToImport.each do |element|
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