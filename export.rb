#!/usr/bin/env ruby
#Encoding: UTF-8

require 'rubygems'
require 'pp'
require 'json'
require 'open-uri'

boards = open("https://api.trello.com/1/members/juuro/boards?key=0ccb4b07c006c5d5555a55b64a124c89&token=e9fe54ca188979634e2115c4862de38be500cd0d46c95b8a561e693d240268ba&filter=open").read
#parse JSON
dataBoards = JSON.parse(boards)

fileJson = File.new("backup.boards.json.tmp", "w+")
fileJson.puts boards
fileJson.close()
File.rename("backup.boards.json.tmp", "backup.boards.json")

arrayLists = Array.new
arrayCards = Array.new
dataBoards.each do |board|
	lists = open("https://api.trello.com/1/boards/"+board['id']+"/lists?&key=0ccb4b07c006c5d5555a55b64a124c89&token=e9fe54ca188979634e2115c4862de38be500cd0d46c95b8a561e693d240268ba").read
	dataLists = JSON.parse(lists)
	
	dataLists.each do |list|
		arrayLists.push(list)
	end	
	
	cards = open("https://api.trello.com/1/boards/"+board['id']+"/cards?&key=0ccb4b07c006c5d5555a55b64a124c89&token=e9fe54ca188979634e2115c4862de38be500cd0d46c95b8a561e693d240268ba").read
	dataCards = JSON.parse(cards)

	dataCards.each do |card|
		arrayCards.push(card)
	end	
end

fileJson = File.new("backup.cards.json.tmp", "w+")
fileJson.puts JSON.generate(arrayCards)	
fileJson.close()
File.rename("backup.cards.json.tmp", "backup.cards.json")

fileJson = File.new("backup.lists.json.tmp", "w+")
fileJson.puts JSON.generate(arrayLists)	
fileJson.close()
File.rename("backup.lists.json.tmp", "backup.lists.json")