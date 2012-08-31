#!/usr/bin/env ruby
#Encoding: UTF-8

require 'json'
require 'rest_client'
require 'pp'
require './functions.rb'
require './classes/CLJoomlaMultiple.rb'

options = CLJoomlaMultiple.parse(ARGV)

$key = options.key.first
$token = options.token.first

puts "Member: "+getMember('me')['username']

# debug
#$key = '897f1e4573b21a4c8ad8a5cbb4bb3441'
#$token = 'f60eaa453d5eba261d03b8f10508ff21b302f87409f782932fd0d87ca67c4307'

# In case you want to put you key and token in the file uncomment the following lines and enter your data1.
#$key = 'PUT YOUR KEY HERE'
#$token = 'PUT YOUR TOKEN HERE'

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

if !options.cards.nil?
	options.cards.each do |cardId|
		cardsByCard = getSingleCard(cardId)
		cardsToImport.push(cardsByCard)
	end
end

if options.all == true
	boards = RestClient.get("https://api.trello.com/1/members/me/boards?key="+$key+"&token="+$token+"&filter=open")
	boards = JSON.parse(boards)

	boards.each do |board|
		cardsByBoard = getCardsByBoard(board['id'])
		cardsToImport = cardsToImport|cardsByBoard
	end
end

sectionid = options.section.first
catid = options.category.first

cardsToImport.each do |card|
	trelloJoomlaSync(card['id'], sectionid, catid, 1.5)
end