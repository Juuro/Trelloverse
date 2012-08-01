#!/usr/bin/ruby
#Encoding: UTF-8

require "erb"
require "./classes/list.rb"
require 'json'
require 'open-uri'
require 'pp'
require 'kramdown'
require './functions.rb'
require './classes/CLhtml.rb'

options = CLHtml.parse(ARGV)

$key = options.key.first
$token = options.token.first

puts "Member: "+getMember('me')['username']

# In case you want to put you key and token in the file uncomment the following lines and enter your data1.
# $key = 'PUT YOUR KEY HERE'
# $token = 'PUT YOUR TOKEN HERE'

cardsToImport = Array.new
@htmlTitle = String.new

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
  boards = open("https://api.trello.com/1/members/me/boards?key="+$key+"&token="+$token+"&filter=open").read
  boards = JSON.parse(boards)

  boards.each do |board|
    cardsByBoard = getCardsByBoard(board['id'])
    cardsToImport = cardsToImport|cardsByBoard
  end
end

if !options.title.empty?
  @htmlTitle = options.title.first
end

cardsFull = getCardsAsArray(cardsToImport, false)

# Load template.
templateFile = File.open("templateHtml.html.erb", "rb")
template = templateFile.read
template.gsub(/^  /, '')

rhtml = ERB.new(template)

# Set up template data.
list = List.new( @htmlTitle )

cardsFull.each do |card|
  list.add_card(card)
end

# Produce result.
html = rhtml.result(list.get_binding)

fileHtml = File.new("index.html", "w+")
fileHtml.puts html
fileHtml.close()

puts "Done!"