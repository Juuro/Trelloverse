#!/usr/bin/env ruby
#Encoding: UTF-8

require 'zippy'
require './functions.rb'
require './classes/CLbackup.rb'

options = CLbackup.parse(ARGV)

$key = options.key.first
$token = options.token.first
@filename = options.name.first

# debug
#$key = '897f1e4573b21a4c8ad8a5cbb4bb3441'
#$token = 'f60eaa453d5eba261d03b8f10508ff21b302f87409f782932fd0d87ca67c4307'

# In case you want to put you key and token in the file uncomment the following lines and enter your data1.
# $key = 'PUT YOUR KEY HERE'
# $token = 'PUT YOUR TOKEN HERE'

puts "Member: "+getMember('me')['username']

if @filename.nil?
	puts "ERROR: You have to specify a filename of the backup file!"
	abort
else
	if `file -Ib #{@filename}`.gsub(/;.*\n/, "") != "application/zip"
		puts "ERROR: The backup file has to be a ZIP file!"
		abort
	end
end

backup = nil
hashOrganizations = Hash.new
hashBoards = Hash.new
hashLists = Hash.new
hashCards = Hash.new

# create directory for caching the attachments in the temporary folder of the OS
directoryNameAttachments = File.join(Dir.tmpdir, "attachments")
if !Dir.exists?(directoryNameAttachments)
	Dir::mkdir(directoryNameAttachments)
end

backup = String.new
Zippy.open(@filename) do |zip|
	backup = zip['backup.json']
end

#read backup.json
backup = JSON.parse(backup)

puts "\n----- IMPORT ORGANIZATIONS -----\n\n"

backup['organizations'].each do |orga|
	prefs = orga['prefs']
	
	begin
		response = postOrganization(orga['name'], orga['displayName'], orga['desc'], orga['website'])
	rescue => e		
		puts "\t"+e.response+" ("+orga['name']+")"
	else		
		hashOrganizations[orga['id']] = response['id']
		
		puts "\"Organization \""+orga['name']+"\" added!"		
	end	
end

puts "\n----- IMPORT BOARDS -----\n\n"

backup['boards'].each do |board|

	prefs = board['prefs']
	
	begin
		response = postBoard(board['name'], board['desc'], hashOrganizations[board['idOrganization']], prefs['permissionLevel'], prefs['selfJoin'], prefs['invitations'], prefs['comments'], prefs['voting'])
	rescue => e
		puts "\t"+e.response+" ("+board['name']+")"
	else				
		hashBoards[board['id']] = response['id']
		
		puts "Board \""+board['name']+"\" added!"
	end
end

puts "\n----- IMPORT MEMBERS -----\n\n"

backup['members'].each do |board|

	puts "\n"+board['name']+" ("+board['id']+"):\n"

	board['members'].each do |member|
		begin
			response = postMemberInviteBoard(hashBoards[board['id']], member['id'])		
		rescue => e
			puts "\t"+e.response
		else 
			puts "\tMember "+member['id']+" ("+response['idMemberInvited']+") invited!"
		end
	end
end

puts "All members are now invited to join the imported boards. In order to add them to the respective cards they have to accecpt the invitations."
puts "To add the members to the cards later, please execute memberimport.rb."
puts "Press ENTER to continue."

gets

puts "\n----- CLOSE STANDARD LISTS -----\n\n"

#delete the standard lists which are created by Trello when creating a board
hashBoards.each do |key, value|	
	lists = getListsByBoard(value)	

	lists.each do |list|		
		begin
			response = putCloseList(list['id'])
		rescue => e
			puts e.response
		else
			puts "List "+list['id']+" closed!"
		end
	end
end

puts "\n----- IMPORT LISTS -----\n\n"

backup['lists'].each do |list|	
	begin
		response = postList(list['name'], hashBoards[list['idBoard']])		
	rescue => e
		puts e.response
	else
		puts "List "+response['name']+" ("+response['id']+") added!"
		
		hashLists[list['id']] = response['id']
	end
end

puts "\n----- IMPORT CARDS -----\n\n"

backup['cards'].each do |card|		
	begin
		response = postCard(card['name'], card['desc'], card['pos'], hashLists[card['idList']])		
	rescue => e
		puts ""+e.response
	else
		puts "Card "+response['name']+" ("+response['id']+") added!"
		
		hashCards[card['id']] = response['id']
	end

	# import members		
	members = card['idMembers']

	members.each do |member|		
		begin
			response = postMemberAddCard(hashCards[card['id']], member) 
		rescue => e
			puts "\t"+e.response
		else
			puts "\tMember \""+response.first['username']+"\" ("+response.first['id']+") added!"			
		end 
	end
	# end import members

	# import checklists
	if card['checklists'] != nil
		card['checklists'].each do |checklist|
			checklistId = nil			
			
			begin
				response = postChecklist(checklist['name'], hashBoards[card['idBoard']])		
			rescue => e
				puts ""+e.response
			else
				puts "\tChecklist \""+response['name']+"\" ("+response['id']+") added!"
				checklistId = response['id']
			end		
			
			begin
				response = postAddChecklistToCard(hashCards[card['id']], checklistId)		
				
			rescue => e
				puts ""+e.response
			else
				puts "\tChecklist \""+response.first['name']+"\" ("+response.first['id']+") added to card!"				
			end
			
			checklist['items'].each_with_index do |item, index|			
				
				begin
					response = postCheckItem(checklistId, item['name'])
				rescue => e
					puts e.response
				else
					thisItem = response.last
					itemId = thisItem['id']
				end
				
				begin
					response = putCheckItemStatus(hashCards[card['id']], checklistId, itemId, item['completed'])
				rescue => e
					puts e.response
				end
				
				begin
					response = putCheckItemPos(hashCards[card['id']], checklistId, itemId, item['pos'])
				rescue => e
					puts e.response
				end

				puts "\t\tItem \""+thisItem['name']+"\" ("+thisItem['id']+") with completed=\""+item['completed'].to_s+"\" added!" 					
			end
		end
	end
	# end import checklists

	# import labels
	card['labels'].each do |label|		
		begin
			response = postLabel(hashCards[card['id']], label['color'])
		rescue => e
			puts e.response
		else
			puts "\tLabel \""+label['color']+"\" added!"	
		end
	end
	# end import labels

	# import comments
	if card['badges']['comments'] != 0
		comments = card['commentsContent']

		comments.each do |comment|      
			origin = "["+comment['memberCreator']['fullName']+" ("+comment['memberCreator']['id']+") "+getDate(comment['date'], 'us')+"]"
			commentText = comment['data']['text']				
			commentText = comment['data']['text']+"\n\n"+origin
			
			begin
				response = postComment(hashCards[card['id']], commentText)
			rescue => e
				puts e.response
			else
				puts "\tComment \""+comment['data']['text']+"\" added!"
			end			
		end
	end		
	# end import comments

	# import attachments		
	if card['badges']['attachments'] != 0
		attachments = card['attachments']

		attachments.each do |attachment|     
			Zippy.open(@filename) do |zip|

				attachmentPath = 'attachments/'+attachment['id']+File.basename(attachment['url'])
				attachmentFileContent = zip[attachmentPath]
				attachmentUploadFile = directoryNameAttachments+"/"+attachment['id']+File.basename(attachment['url'])
				IO.binwrite(attachmentUploadFile, attachmentFileContent) 

				attachmentFile = File.new(attachmentUploadFile, 'rb')
				attachmentFile = File.rename(attachmentUploadFile, directoryNameAttachments+"/"+File.basename(attachment['url']))        
				attachmentFile = File.new(directoryNameAttachments+"/"+File.basename(attachment['url']), 'rb')

				begin
					response = postAttachments(hashCards[card['id']], attachmentFile, attachment['name'])
				rescue => e
					puts e.response
				else
					File.delete(attachmentFile) 
					puts "\tAttachment \""+File.basename(attachment['url'])+"\" added!"
				end
			end
		end
	end	
	# end import attachments

	# import due dates
	if card['due'] != nil		
		begin
			response = putDueDate(hashCards[card['id']], card['due'])
		rescue => e
			puts e.response
		else
			puts "\tDue Date \""+card['due'].to_s+"\" added!"	
		end
	end
	# end import due dates

	# import votes
	if card['badges']['votes'] > 0

		members = card['membersVoted']

		members.each do |member|
			if isThisMe(member) == true				
				begin
					response = postVoting(hashCards[card['id']], member)
				rescue => e
					puts e.response
				else
					puts "\tMember \""+member+"\" voted!"
				end				
			end
		end
	end
	# end import votes

	# import subscribers	
	if card['subscribed'] == true		
		begin
			response = putSubscribe(hashCards[card['id']], true)
		rescue => e
			puts e.response
		else
			puts "\tSubscribed!"
		end
	end
	# end import subscribers

end

Zippy.open(@filename) do |zip|
	zip['cards.json'] = JSON.generate(hashCards)
end

Dir.rmdir(directoryNameAttachments)
puts "Done!"