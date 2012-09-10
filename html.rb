#!/usr/bin/ruby
#Encoding: UTF-8

require "erb"
require "./classes/webpage.rb"
require 'json'
require 'kramdown'
require './functions.rb'
require './classes/CLhtml.rb'

options = CLHtml.parse(ARGV)

$key = options.key
$token = options.token

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

if !options.title.empty?
  @htmlTitle = options.title
end

cardsFull = getCardsAsArray(cardsToImport, false)

# Load template.
templateFile = File.open("templateHtml.html.erb", "rb")
template = templateFile.read
#template.gsub(/^  /, '')

rhtml = ERB.new(template)

# Set up template data.
webpage = Webpage.new( @htmlTitle )

cardsFull.each do |card|
  webpage.add_card(card)
end

# Produce result.
html = rhtml.result(webpage.get_binding)

fileHtml = File.new("index.html", "w+")
fileHtml.puts html
fileHtml.close()

puts "Done!"