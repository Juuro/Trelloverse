#!/usr/bin/env ruby
#Encoding: UTF-8

require 'rubygems'
require 'pp'
require 'json'
require 'open-uri'
require 'net/http'
require 'uri'
require 'zippy'
require 'rest_client'
require './functions.rb'
require './classes/CLimport.rb'

options = CLimport.parse(ARGV)

@key = options.key.first
@token = options.token.first

# debug
#@key = '897f1e4573b21a4c8ad8a5cbb4bb3441'
#@token = 'f60eaa453d5eba261d03b8f10508ff21b302f87409f782932fd0d87ca67c4307'

# In case you want to put you key and token in the file uncomment the following lines and enter your data1.
# @key = 'PUT YOUR KEY HERE'
# @token = 'PUT YOUR TOKEN HERE'

fileJson = nil
hashBoards = Hash.new
hashLists = Hash.new
hashCards = Hash.new

# create directory for caching the attachments in the temporary folder of the OS
directoryNameAttachments = File.join(Dir.tmpdir, "attachments")
if !Dir.exists?(directoryNameAttachments)
	Dir::mkdir(directoryNameAttachments)
end

puts "\n----- IMPORT BOARDS -----\n\n"

backup = String.new
Zippy.open('backup.zip') do |zip|
	backup = zip['backup.json']
end

#read backup.json
fileJson = JSON.parse(backup)

# import boards
uri = URI('https://api.trello.com/1/boards')
req = Net::HTTP::Post.new(uri.path)

fileJson['boards'].each do |board|
	pp board['name']+" : "+board['id']
	prefs = board['prefs']
	
	req.set_form_data('name' => board['name'], 
										'desc' => board['desc'],
										'prefs_permissionLevel' => prefs['permissionLevel'],
										'prefs_selfJoin' => prefs['selfJoin'],
										'prefs_invitations' => prefs['invitations'],
										'prefs_comments' => prefs['comments'],
										'prefs_voting' => prefs['voting'],
										'key'=>@key,
										'token'=>@token)
	
	Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
		response = http.request(req) # Net::HTTPResponse object	
		#pp JSON.parse(response.body)['id']
		
		newIdBoard = JSON.parse(response.body)['id']
		
		hashBoards[board['id']] = newIdBoard
	end
end

pp hashBoards

Zippy.open('backup.zip') do |zip|
	zip['boards.json'] = JSON.generate(hashBoards)
end

puts "\n----- IMPORT MEMBERS -----\n\n"

puts "Please visit http://www.trello.com. Login as "+getMember('me', @key, @token)['username']+" ("+getMember('me', @key, @token)['id']+")! Add the following members to the corresponding boards MANUALLY.\n"

fileJson['members'].each do |board|

	puts "\n"+board['name']+" ("+board['id']+"):\n"

	board['members'].each do |member|
		puts "\t"+member['username']+" ("+member['id']+")"
	end
end

puts "\nIf you have added all necessary members to your boards press ENTER to continue!"
gets

fileJson['members'].each do |board|	
	membersNewBoard = open("https://api.trello.com/1/boards/"+hashBoards[board['id']]+"/members?key="+@key+"&token="+@token+"").read
	membersNewBoard = JSON.parse(membersNewBoard)	
	
	missingMembers = board['members'] - membersNewBoard

	if !missingMembers.empty?
		missingMembers.each do |member|
			puts "You haven't added "+member['username']+" ("+member['id']+") to "+board['name']+" ("+board['id']+")!"
		end
		puts "Press ENTER to continue!"
		gets
	end
end


puts "\n----- CLOSE STANDARD LISTS -----\n\n"

#delete the standard lists which are created by Trello when creating a board
hashBoards.each do |key, value| 
	lists = open("https://api.trello.com/1/boards/"+value+"/lists?key="+@key+"&token="+@token+"").read
	lists = JSON.parse(lists)	

	lists.each do |list|	
		pp list['name']+" : "+list['id']
		
		uri = URI('https://api.trello.com/1/lists/'+list['id']+'/closed')
		req = Net::HTTP::Put.new(uri.path)
		req.set_form_data('value' => 'true',
											'key'=>@key,
											'token'=>@token)

		Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
			response = http.request(req)
		end
	end
end

puts "\n----- IMPORT LISTS -----\n\n"

# import lists
uri = URI('https://api.trello.com/1/lists')
req = Net::HTTP::Post.new(uri.path)

fileJson['lists'].each do |list|
	pp list['name']+" : "+list['id']
	
	req.set_form_data('name' => list['name'], 
										'idBoard' => hashBoards[list['idBoard']],
										'key'=>@key,
										'token'=>@token)

	Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
		response = http.request(req) # Net::HTTPResponse object	
		#pp JSON.parse(response.body)['id']

		hashLists[list['id']] = JSON.parse(response.body)['id']
	end
end

pp hashLists

puts "\n----- IMPORT CARDS -----\n\n"

# import cards
uri = URI('https://api.trello.com/1/cards')
req = Net::HTTP::Post.new(uri.path)

fileJson['cards'].each do |card|
	pp card['name']+" : "+card['id']	
	
	req.set_form_data('name' => card['name'],
										'desc' => card['desc'],
										'pos' => card['pos'],
										'idList' => hashLists[card['idList']],
										'key'=>@key,
										'token'=>@token)

	Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
		response = http.request(req) # Net::HTTPResponse object	
		
		newIdCard = JSON.parse(response.body)['id']
		hashCards[card['id']] = newIdCard		
	end
	
	# import members		
	members = card['idMembers']
	
	members.each do |member|		
		begin
			RestClient.post(
					'https://api.trello.com/1/cards/'+hashCards[card['id']]+'/members',
					:value   => member,
					:key     => @key,
					:token   => @token
			)
			puts "\tMember \""+member+"\" added!"
		rescue => e
			puts "\t"+e.response+" ("+member+")"
		end 
	end
	# end import members
	
	# import checklists
	if card['checklists'] != nil
		card['checklists'].each do |checklist|
			checklistId = nil
			
			uriChecklists = URI('https://api.trello.com/1/checklists')
			reqChecklists = Net::HTTP::Post.new(uriChecklists.path)
			
			reqChecklists.set_form_data('name' => checklist['name'],
												'idBoard'=>hashBoards[card['idBoard']],
												'key'=>@key,
												'token'=>@token)
			
			Net::HTTP.start(uriChecklists.host, uriChecklists.port, :use_ssl => uriChecklists.scheme == 'https') do |http|
				responseChecklists = http.request(reqChecklists) # Net::HTTPResponse object
				response = JSON.parse(responseChecklists.body)
				checklistId = response['id']
				
				puts "\tChecklist \""+checklist['name']+"\" ("+checklist['id']+") added!"
			end
			
			uriCheckAdd = URI('https://api.trello.com/1/cards/'+hashCards[card['id']]+'/checklists')
			reqCheckAdd = Net::HTTP::Post.new(uriCheckAdd.path)
			
			reqCheckAdd.set_form_data('value' => checklistId,
												'key'		=>	@key,
												'token'	=>	@token)
			
			Net::HTTP.start(uriCheckAdd.host, uriCheckAdd.port, :use_ssl => uriCheckAdd.scheme == 'https') do |http|
				responseCheckAdd = http.request(reqCheckAdd) # Net::HTTPResponse object
				responseCheckAdd = responseCheckAdd.body
			end
			
			checklist['items'].each_with_index do |item, index|
							
				uriCheckItems = URI('https://api.trello.com/1/checklists/'+checklistId+'/checkItems')
				reqCheckItems = Net::HTTP::Post.new(uriCheckItems.path)
				
				reqCheckItems.set_form_data('name' => item['name'],
													'key'=>@key,
													'token'=>@token)
				
				Net::HTTP.start(uriCheckItems.host, uriCheckItems.port, :use_ssl => uriCheckItems.scheme == 'https') do |http|
					responseCheckItems = http.request(reqCheckItems) # Net::HTTPResponse object
					response = JSON.parse(responseCheckItems.body)
					thisItem = response.last
					itemId = thisItem['id']
					
					
					reply = RestClient.put(
							'https://api.trello.com/1/cards/'+hashCards[card['id']]+'/checklist/'+checklistId+'/checkItem/'+itemId+'/state',
							:idCheckList       	=>  checklistId,
							:idCheckItem				=>  itemId,
							:value							=>	item['completed'],
							:key        				=>  @key,
							:token   						=>  @token
					)
					
					reply = RestClient.put(
							'https://api.trello.com/1/cards/'+hashCards[card['id']]+'/checklist/'+checklistId+'/checkItem/'+itemId+'/pos',
							:idCheckList       	=>  checklistId,
							:idCheckItem				=>  itemId,
							:value							=>	item['pos'],
							:key        				=>  @key,
							:token   						=>  @token
					)
					
					puts "\t\tItem \""+thisItem['name']+"\" ("+thisItem['id']+") with completed=\""+item['completed'].to_s+"\" added!" 
									
				end					
			end
		end
	end
	# end import checklists

	# import labels
	card['labels'].each do |label|
		
		uriLabel = URI('https://api.trello.com/1/cards/'+hashCards[card['id']]+'/labels')
		reqLabel = Net::HTTP::Post.new(uriLabel.path)
		reqLabel.set_form_data('value' => label['color'],
											'key'=>@key,
											'token'=>@token)
		Net::HTTP.start(uriLabel.host, uriLabel.port, :use_ssl => uriLabel.scheme == 'https') do |http|
			responseLabel = http.request(reqLabel)
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
				
			uriComments = URI('https://api.trello.com/1/cards/'+hashCards[card['id']]+'/actions/comments')
			reqComments = Net::HTTP::Post.new(uriComments.path)
			reqComments.set_form_data('text' => commentText,
												'key'=>@key,
												'token'=>@token)
			
			Net::HTTP.start(uriComments.host, uriComments.port, :use_ssl => uriComments.scheme == 'https') do |http|
				responseComments = http.request(reqComments)	
					
				puts "\tComment \""+comment['data']['text']+"\" added!"
			end
		end
	end		
	# end import comments
	
	# import attachments		
	if card['badges']['attachments'] != 0
		attachments = card['attachments']
		
		attachments.each do |attachment|     
			Zippy.open('backup.zip') do |zip|
				
				attachmentPath = 'attachments/'+attachment['id']+File.basename(attachment['url'])
				attachmentFileContent = zip[attachmentPath]
				attachmentUploadFile = directoryNameAttachments+"/"+attachment['id']+File.basename(attachment['url'])
				IO.binwrite(attachmentUploadFile, attachmentFileContent) 
				
				attachmentFile = File.new(attachmentUploadFile, 'rb')
				attachmentFile = File.rename(attachmentUploadFile, directoryNameAttachments+"/"+File.basename(attachment['url']))        
				attachmentFile = File.new(directoryNameAttachments+"/"+File.basename(attachment['url']), 'rb')
														
				reply = RestClient.post(
						'https://api.trello.com/1/cards/'+hashCards[card['id']]+'/attachments',
						:file       =>  attachmentFile,
						:name				=>  attachment['name'], # has no effect
						:key        =>  @key,
						:token   		=>  @token
				)
				File.delete(attachmentFile) 
				puts "\tAttachment \""+File.basename(attachment['url'])+"\" added!"
			end
		end
	end	
	# end import attachments
	
	# import due dates
	if card['due'] != nil
		reply = RestClient.put(
				'https://api.trello.com/1/cards/'+hashCards[card['id']]+'/due',
				:value       =>  card['due'],
				:key        =>  @key,
				:token   		=>  @token
		)
		puts "\tDue Date \""+card['due'].to_s+"\" added!"	
	end
	# end import due dates
	
	# import votes
	if card['badges']['votes'] > 0
		
		members = card['membersVoted']
		
		members.each do |member|
			if isThisMe(member, @key, @token) == true
				reply = RestClient.post(
						'https://api.trello.com/1/cards/'+hashCards[card['id']]+'/membersVoted',
						:value   => member,
						:key     => @key,
						:token   => @token
				)
				puts "\tMember \""+member+"\" voted!"
			end
		end
	end
	# end import votes
	
	# import subscribers
	if card['subscribed'] == true
		reply = RestClient.put(
				'https://api.trello.com/1/cards/'+hashCards[card['id']]+'/subscribed',
				:value   => true,
				:key     => @key,
				:token   => @token
		)
	end
	# end import subscribers
	
end

Zippy.open('backup.zip') do |zip|
	zip['cards.json'] = JSON.generate(hashCards)
end

Dir.rmdir(directoryNameAttachments)
puts "Done!"