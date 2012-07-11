#!/usr/bin/env ruby
#Encoding: UTF-8

require 'rubygems'
require 'pp'
require 'json'
require 'open-uri'
require 'rest_client'
require 'tmpdir'
require 'zippy'
require './functions.rb'

#Juurotest
@key = '8c23c5c0c933680a5e155668654c40e6'
@token = 'b4f1db7377c62ce9b02a4a266c2fdb8fdb53223ace32732bcd48a0492ddc747d'

boards = open("https://api.trello.com/1/members/juurotest/boards?key="+@key+"&token="+@token+"&filter=open").read
#parse JSON
dataBoards = JSON.parse(boards)

directoryNameAttachments = File.join(Dir.tmpdir, "attachments")

arrayBoards = Array.new
arrayLists = Array.new
arrayCards = Array.new
dataBoards.each do |board|
	
	members = open("https://api.trello.com/1/boards/"+board['id']+"/members?&key="+@key+"&token="+@token+"").read
	dataMembers = JSON.parse(members)
	
	arrayMembers = Array.new
	dataMembers.each do |member|			
		arrayMembers.push(member)	
	end	
	 
	hashMembers = Hash.new
	
	hashMembers['id'] = board['id']
	hashMembers['name'] = board['name']
	hashMembers['members'] = arrayMembers	
	
	arrayBoards.push(hashMembers)	
	
	hashMembers = nil
	arrayMembers = nil	
	
	lists = open("https://api.trello.com/1/boards/"+board['id']+"/lists?&key="+@key+"&token="+@token+"").read
	dataLists = JSON.parse(lists)
	
	dataLists.each do |list|
		arrayLists.push(list)
	end	
	
	cards = open("https://api.trello.com/1/boards/"+board['id']+"/cards?&key="+@key+"&token="+@token+"").read
	dataCards = JSON.parse(cards)

	dataCards.each do |card|
		# export checklists
		hasChecklist = getChecklist(card['id']) 
		
		if hasChecklist[0] != nil
			arrayChecklists = Array.new
			hasChecklist.each do |checklist|  
				hashChecklist = Hash.new  
				hashChecklist['id'] = checklist['id']
				hashChecklist['name'] = checklist['name']
				arrayItems = Array.new
				checklist['checkItems'].each do |item|
					hashItem = Hash.new
					hashItem['name'] = item['name']
					if isCompleted(card['id'], item['id'])
						hashItem['completed'] = true
					else
						hashItem['completed'] = false
					end
					hashItem['pos'] = item['pos']
					arrayItems.push(hashItem)
				end
				hashChecklist['items'] = arrayItems
				arrayItems = nil
				arrayChecklists.push(hashChecklist)
				hashChecklist = nil
			end
			
			hashCheckListsForCard = Hash.new
			hashCheckListsForCard['checklists'] = arrayChecklists
			
			card = card.merge(hashCheckListsForCard)
		end
		# end export checklists
		
		# export comments
		if card['badges']['comments'] != 0
			comments = getCardComments(card['id'])
			hashCommentsForCard = Hash.new			
			hashCommentsForCard['commentsContent'] = comments			
			card = card.merge(hashCommentsForCard)
		end
		# end export comments
		
		# export attachments
		if card['badges']['attachments'] != 0
			attachments = getAttachment(card['id'])			
			hashAttachmentsForCard = Hash.new			
			hashAttachmentsForCard['attachments'] = attachments			
			card = card.merge(hashAttachmentsForCard)			
			
			# url runterladen
			attachments.each do |attachment|
				fileDomain = URI.parse(attachment['url']).host
				filePath = attachment['url'].gsub(URI.parse(attachment['url']).scheme+"://"+URI.parse(attachment['url']).host, '')
				fileExtension = File.extname(attachment['url'])
				
				fileName = attachment['id']+File.basename(attachment['url'])
				puts "Downloading \'"+fileName+"\'"
							
				if !Dir.exists?(directoryNameAttachments)
					Dir::mkdir(directoryNameAttachments)
				end
				
				Net::HTTP.start(fileDomain) do |http|
						resp = http.get(filePath)
						open(directoryNameAttachments+"/"+fileName, "wb") do |file|
								file.write(resp.body)
						end
				end      
			end
			# url runterladen       
		end	
		# end export attachments
		
		# export votes
		if card['badges']['votes'] > 0
			reply = RestClient.get(
					'https://api.trello.com/1/cards/'+card['id']+'/membersVoted?key='+@key+'&token='+@token
			)
			members = JSON.parse(reply)
			membersVotedArray = Array.new
			members.each do |member|
				 membersVotedArray.push(member['id'])
			end
			hashMembersVotedForCard = Hash.new			
			hashMembersVotedForCard['membersVoted'] = membersVotedArray
			card = card.merge(hashMembersVotedForCard)	
		end
		# end export votes
		
		arrayCards.push(card)
	end	
end

hashBackup = Hash.new
hashBackup['boards'] = JSON.parse(boards)
hashBackup['members'] = arrayBoards
hashBackup['lists'] = arrayLists
hashBackup['cards'] = arrayCards

backupFile = File.new(File.join(Dir.tmpdir, 'backup.json'), "wb")
backupFile.puts JSON.generate(hashBackup)
backupFile.close()
pp "Done!"

Zippy.create 'backup.zip' do |zip|
	zip['backup.json'] = File.open(backupFile)

	Dir.entries(directoryNameAttachments).each do |file|
		fileName = File.new(File.join(directoryNameAttachments, file), "r")
		if file != "." && file != ".."
			zip['attachments/'+file] = File.open(fileName)
			fileName.close
			File.delete(fileName)
		end
	end
end

Dir.rmdir(directoryNameAttachments)
File.delete(backupFile)