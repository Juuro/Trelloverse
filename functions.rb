#!/usr/bin/ruby
#Encoding: UTF-8

require 'mysql'
require 'pp'
require 'rest_client'
require 'time'
require 'kramdown'

### Date

def getDate(date, format='de')
	fdate = Time.iso8601(date).getlocal
	
	if format=='de'
		return fdate.strftime('%d.%m.%Y %H:%M:%S')
	elsif format=='us'
		return fdate.strftime('%m/%d/%Y %I.%M.%S %P')
	elsif format=='joomla'
		return fdate.strftime('%Y-%m-%d %H:%M:%S')
	elsif format=='ical'
		return fdate.strftime('%Y%m%dT%H%M%S')
	elsif format=='year'
		return fdate.strftime('%Y')
	elsif format=='iso8601'
		return fdate.iso8601
	end
end




### Member methods

def getMember(memberId)
	member = RestClient.get("https://api.trello.com/1/members/"+memberId+"?key="+$key+"&token="+$token+"&filter=open")
	member = JSON.parse(member)
end

def isThisMe(memberId)
	if getMember('me')['id'] == memberId
		return true
	else
		return false
	end
end

def getMembersByBoard(boardId)
	members = RestClient.get("https://api.trello.com/1/boards/"+boardId+"/members?&key="+$key+"&token="+$token)
	members = JSON.parse(members)	
end




### Collecting data from Trello

def getBoardsByMember(memberId)
	boards = RestClient.get("https://api.trello.com/1/members/"+memberId+"/boards?key="+$key+"&token="+$token+"&filter=open")
	boards = JSON.parse(boards)
end

def getOrganizationsByMember(memberId)
	orgas = RestClient.get("https://api.trello.com/1/members/"+memberId+"/organizations?key="+$key+"&token="+$token+"")
	orgas = JSON.parse(orgas)
end

def getBoardsByOrganization(orgId)
	boards = RestClient.get("https://api.trello.com/1/organizations/"+orgId+"/boards?key="+$key+"&token="+$token+"&filter=open")
	boards = JSON.parse(boards)
end

def getCardsByOrganization(orgId)
	boards = getBoardsByOrganization(orgId)
	
	cards = Array.new
	boards.each do |board|
		cards += getCardsByBoard(board['id'])
	end
	
	return cards
end

def getListsByBoard(boardId)
	list = RestClient.get("https://api.trello.com/1/boards/"+boardId+"/lists?key="+$key+"&token="+$token)
	list = JSON.parse(list)	
end

def getList(listId)
	list = RestClient.get("https://api.trello.com/1/lists/"+listId+"?key="+$key+"&token="+$token)
	list = JSON.parse(list)	
end

def getSingleCard(cardId)
	card = RestClient.get("https://api.trello.com/1/cards/"+cardId+"?key="+$key+"&token="+$token)
	card = JSON.parse(card)
end

def getCardsByBoard(boardId)
	board = RestClient.get("https://api.trello.com/1/boards/"+boardId+"/cards?key="+$key+"&token="+$token+"&filter=open")
	board = JSON.parse(board)
end

def getCardsByList(listId)
	list = RestClient.get("https://api.trello.com/1/lists/"+listId+"/cards?key="+$key+"&token="+$token+"&filter=open")
	list = JSON.parse(list)
end

def getCardsAsArray(arrayCardsStd, downloads = true)
	arrayCardsFull = Array.new
	directoryNameAttachments = File.join(Dir.tmpdir, "attachments")
	
	arrayCardsStd.each do |card|
		# export members
		memberArray = Array.new
		card['idMembers'].each do |memberId|
			member = getMember(memberId)
			memberArray << member			
		end
		membersForCard = Hash.new
		membersForCard['members'] = memberArray
		card = card.merge(membersForCard)
		# end export members		
		
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
			
			if downloads
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
		end	
		# end export attachments
		
		# export votes
		if card['badges']['votes'] > 0
			reply = RestClient.get(
					'https://api.trello.com/1/cards/'+card['id']+'/membersVoted?key='+$key+'&token='+$token
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
		
		arrayCardsFull.push(card)
	end
	
	return arrayCardsFull
end




### Additional card information

def getCardActions(cardId)
	actions = RestClient.get("https://api.trello.com/1/cards/"+cardId+"/actions?key="+$key+"&token="+$token)
	actions = JSON.parse(actions)
end

def getCardComments(cardId)
	actions = RestClient.get("https://api.trello.com/1/cards/"+cardId+"/actions?filter=commentCard&key="+$key+"&token="+$token)
	actions = JSON.parse(actions)
end

def cardUpdated(cardId)
	reply = RestClient.get('https://api.trello.com/1/cards/'+cardId+'/actions?filter=updateCard&key='+$key+'&token='+$token)

	updates = JSON.parse(reply.body)
end

def cardCreated(cardId)
	reply = RestClient.get('https://api.trello.com/1/cards/'+cardId+'/actions?filter=createCard&key='+$key+'&token='+$token)

	updates = JSON.parse(reply.body)
end

def isCompleted(cardId, itemId)
	completedItems = RestClient.get("https://api.trello.com/1/cards/"+cardId+"/checkitemstates?key="+$key+"&token="+$token)
	completedItems = JSON.parse(completedItems)

	completedItems.each do |item|
		if item['idCheckItem'] == itemId
			return true
		end
	end

	return false
end

def getChecklist(cardId)
	checklists = RestClient.get("https://api.trello.com/1/cards/"+cardId+"/checklists?key="+$key+"&token="+$token)
	data = JSON.parse(checklists)

	return data  
end

def getAttachment(cardId)
	attachments = RestClient.get("https://api.trello.com/1/cards/"+cardId+"/attachments?key="+$key+"&token="+$token)
	data = JSON.parse(attachments)

	return data
end




### CMS methods

def trelloToJoomlaSingle(joomlaArticleId, articles)
	# Database connection
	dbhost = 'localhost'
	dbuser = 'root'
	dbpassword = 'jMuaeObS4a'
	db = 'joomla15'
	
	htmlSite = "<h3>Universität Tübingen</h3>"
	
	htmlSite << "<p> </p>
	<table style=\"text-align: center;\" border=\"0\">
	<tbody>
	<tr style=\"background-color: #c3d2e5;\">
	<td style=\"text-align: center;\">
	<p style=\"text-align: left; padding-left: 5px;\"><strong><span><strong> Thema</strong></span></strong></p>
	</td>
	</tr>"
	
	i = 0
	articles.each do |element|
		title = element.title
		description = element.description
		if element.attachments != []		
			attachments = element.attachments
		end
		
		htmlSite << "
		<tr style=\"background-color: "
		if i.even? 
			htmlSite << "#e0e8ec;"
		else
			htmlSite <<"#c3d2e5"
		end
		htmlSite << "\">
		<td><p style=\"text-align: left; padding-left: 5px;\"><span><strong>"
		htmlSite << title
		htmlSite << "</strong></span></p>
		<div style=\"text-align: left; padding-left: 5px;\"><span style=\"font-size: xx-small;\">"
		htmlSite << description		
		htmlSite << "</span></div>
		<div style=\"text-align: left;\"><span style=\"font-weight: normal; font-size: small;\"> 
		<ul>"
		if element.attachments != []
			attachments.each do |attachment|
				name = attachment.name
				url = attachment.url
				htmlSite << "<li><a href=\""
				htmlSite << url
				htmlSite << "\">"
				htmlSite << name
				htmlSite << "<a/></li>"
			end	
		end	
		htmlSite << "</ul>
		</span></div>
		</td>
		</tr>"	
		i += 1
	end
	i = nil
	
	htmlSite << "</tbody>
	</table>"
	
	#save to file	
	fileHtml = File.new("arbeiten.html.tmp", "w+")
	fileHtml.puts "<!doctype html>
	<head>
		<meta charset=\"UTF-8\">
		<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge,chrome=1\">
	
		<title>Abgeschlossene Arbeiten</title>
	</head>
	<body>"
	fileHtml.puts htmlSite	
	fileHtml.puts "</body></html>"
	File.rename("arbeiten.html.tmp", "arbeiten.html")
	
	#save to DB
	my = Mysql.init
	my.options(Mysql::SET_CHARSET_NAME, 'utf8')
	my.real_connect(dbhost, dbuser, dbpassword, db)
	my.query("SET NAMES utf8")

	stmt = my.prepare("UPDATE jos_content SET `introtext`='"+htmlSite+"' WHERE id="+joomlaArticleId.to_s)
	#stmt = my.prepare("UPDATE jos_content SET `introtext`='äüöß' WHERE id="+joomlaArticleId.to_s)
	stmt.execute
	
	my.close if my
	
end


def trelloJoomlaSync(cardId, sectionid, catid, joomlaVersion)
	
	card = getSingleCard(cardId)
	title = card['name']	
	description = Kramdown::Document.new(card['desc']).to_html
	
	changed = nil
	if !cardUpdated(cardId).empty?
		changed = getDate(cardUpdated(cardId).first['date'], 'joomla')
	else
		changed = getDate(cardCreated(cardId).first['date'], 'joomla')
	end
	
	# attachments
	hasAttachment = getAttachment(cardId)
	
	if hasAttachment[0] != nil
		description += "<ul>"		
		hasAttachment.each do |att|	
			description += "<li><a href=\""+att['url']+"\">\""+att['name']+"\"</a></li>"
		end
		description += "</ul>"
	end
	# end attachments
	
	# checklists
	# export checklists
	hasChecklist = getChecklist(cardId) 
	
	if hasChecklist[0] != nil
		hasChecklist.each do |checklist| 			
			description += "<h4>"+checklist['name']+"</h4>"
			description += "<ul>"
			checklist['checkItems'].each do |item|				
				if isCompleted(cardId, item['id'])
					description += "<li><del>"+item['name']+"</del></li>"
				else
					description += "<li>"+item['name']+"</li>"
				end
			end
			description += "</ul>"
		end	
	end
	# end checklists

	if joomlaVersion == 2.5
		#debug
		puts "Joomla! 2.5"
		
		# Database connection
		dbhost = 'localhost'
		dbuser = 'root'
		dbpassword = 'jMuaeObS4a'
		db = 'joomla'

		#DB connection
		my = Mysql.init
		my.options(Mysql::SET_CHARSET_NAME, 'utf8')
		my.real_connect(dbhost, dbuser, dbpassword, db)
		my.query("SET NAMES utf8")
		
		stmt = my.prepare("INSERT INTO e94bi_content (
													asset_id, 
													title, 
													alias,
													`fulltext`,
													state, 
													sectionid, 
													catid, 
													created, 
													created_by,
													parentid, 
													ordering, 
													access, 
													language
												) 
												VALUES (
													170, 
													'"+title+"', 
													'"+title.downcase+"', 
													'"+description+"', 
													1, 
													0, 
													19, 
													'"+changed+"', 
													42, 
													0, 
													0, 
													1, 
													'*'
												)"
											)
		stmt.execute

		newArticleId = nil
		my.query("SELECT id 
							FROM e94bi_content 
							WHERE created='"+changed+"' 
							AND title='"+title+"'"
						).each do |thisid|
			pp thisid
			newArticleId = thisid[0]
		end

		stmt = my.prepare("INSERT INTO e94bi_menu (
													menutype, 
													title, 
													alias, path, 
													link, 
													type, 
													published, 
													parent_id, 
													level, 
													component_id, 
													access, 
													lft, 
													gt, 
													language
												) 
												VALUES(
													'aboutjoomla', 
													'"+title+"', 
													'"+title.downcase+"', 
													'getting-started/"+title.downcase+"', 
													'index.php?option=com_content&view=article&id="+newArticleId+"', 
													'component', 
													1, 
													437, 
													2, 
													22, 
													1, 
													44, 
													45, 
													'*'
												)"
											)
		stmt.execute

		my.close if my

	elsif joomlaVersion == 1.5
		#debug
		#puts "Joomla! 1.5"

		# Database connection
		dbhost = 'localhost'
		dbuser = 'root'
		dbpassword = 'jMuaeObS4a'
		db = 'joomla15'
		
		begin
			my = Mysql.init
			my.options(Mysql::SET_CHARSET_NAME, 'utf8')
			my.real_connect(dbhost, dbuser, dbpassword, db)
			my.query("SET NAMES utf8")
		rescue Mysql::Error => e
			puts e
			return	
		end		

		# checking if this card exists as article already
		begin
			existingArticleQuery = my.query("
				SELECT id, created, modified
				FROM jos_content 
				WHERE metadata='"+cardId+"'
			")
		rescue Mysql::Error => e
			puts e
		else
			# if article doesn't exist insert it into the db
			if existingArticleQuery.num_rows == 0
				begin
					stmt = my.prepare("
						INSERT INTO jos_content (
							title, 
							alias, 
							`introtext`, 
							state, 
							sectionid, 
							catid, 
							created, 
							created_by, 
							modified,
							parentid, 
							ordering, 
							access,					
							metadata
						)
						VALUES (
							?, 
							?, 
							?, 
							1, 
							?, 
							?, 
							?, 
							62, 
							?,
							0, 
							1, 
							0,
							?
						)
					")
					
					stmt.execute title, title.downcase, description.gsub(/'/, '&#39;'), sectionid, catid, changed, changed, cardId
					puts 'New article: '+cardId+" : "+title		
				rescue Mysql::Error => e
					puts e
					return
				ensure
					stmt.close if stmt
				end				
			else
				# this should be only one because per Trello card id should only exist one article in Joomla
				existingArticleQuery.each do |thisArticle|				
					
					existingId = thisArticle[0]
					existingModified = thisArticle[2]
					
					# check if the modiefied timestamp im Trello is different to the modiefied timestamp in Joomla
					begin 
						if existingModified != changed
							stmt = my.prepare("
								UPDATE jos_content 
								SET
									title = '"+title+"',
									alias = '"+title.downcase+"',
									`introtext` = '"+description.gsub(/'/, '&#39;')+"',
									state = 1,
									sectionid = 5,
									catid = 34,
									created = '"+changed+"',
									created_by = 62,
									modified = '"+changed+"',
									parentid = 0,
									ordering = 1,
									access = 0
								WHERE
									metadata = '"+cardId+"'
							")
							stmt.execute
							puts 'Changed: '+cardId+" : "+title
						else 
							puts 'Nothing changed: '+cardId+" : "+title
						end					
					rescue Mysql::Error => e
						puts e
						return
					ensure
						stmt.close if stmt
					end
				end
			end	
		ensure
			my.close if my
		end
	end
end

=begin
def trelloToWordpressMultiple(title, created, cardId, sectionid, catid, description='<p>NO U!</p>', attachments=Hash.new)
	
	dbhost = 'localhost'
	dbuser = 'root'
	dbpassword = 'jMuaeObS4a'
	db = 'joomla15'
	
	description = Kramdown::Document.new(description).to_html

	# attachments
	if attachments != nil
		description << "<ul>"
		i = 0
		while i < attachments.length do
			description << "<li><a href=\""+attachments[i]['url']+"\">\""+attachments[i]['name']+"\"</a></li>"
			i += 1
		end
		description << "</ul>"
	end
	# end attachments

	title.downcase = title.downcase	

	#DB connection
	my = Mysql.init
	my.options(Mysql::SET_CHARSET_NAME, 'utf8')
	my.real_connect(dbhost, dbuser, dbpassword, db)
	my.query("SET NAMES utf8")

	# checking if this acrticle already exists
	existingArticle = nil
	existingArticleQuery = my.query("
		SELECT id, created, modified
		FROM jos_content 
		WHERE metadata='"+cardId+"'
	")

	# if article doesn't exist insert it into the db
	if existingArticleQuery.num_rows == 0
		stmt = my.prepare("
			INSERT INTO jos_content (
				title, 
				alias, 
				`introtext`, 
				state, 
				sectionid, 
				catid, 
				created, 
				created_by, 
				modified,
				parentid, 
				ordering, 
				access,					
				metadata
			)
			VALUES (
				'"+title+"', 
				'"+title.downcase+"', 
				'"+description.gsub(/'/, '&#39;')+"', 
				1, 
				'"+sectionid+"', 
				'"+catid+"', 
				'"+created+"', 
				62, 
				'"+created+"',
				0, 
				1, 
				0,
				'"+cardId+"'
			)
		")

		stmt.execute

		# identify id of the new article
		newArticleId = nil
		newArticles = my.query("
			SELECT id 
			FROM jos_content 
			WHERE created='"+created+"' 
			AND title='"+title+"'
		")
		newArticles.each do |thisid|
			newArticleId = thisid[0]
		end

		# insert the new article into the menu
		stmt = my.prepare("
			INSERT INTO jos_menu (
				menutype,
				name, 
				alias, 
				link, 
				type, 
				published, 
				parent, 
				componentid, 
				sublevel, 
				access, 
				lft, 
				rgt) 
			VALUES (
				'mainmenu', 
				'"+title+"', 
				'"+title.downcase+"', 
				'index.php?option=com_content&view=article&id="+newArticleId+"', 
				'component', 
				1, 
				27, 
				20, 
				1, 
				0, 
				0, 
				0
			)
		")
		stmt.execute
		pp cardId+': New article!'
	else
		# this should be only one because per Trello card it should only exist one article in Joomla
		existingArticleQuery.each do |thisArticle|				

			existingId = thisArticle[0]
			existingModified = thisArticle[2]

			# check if the modiefied timestamp im Trello is different to the modiefied timestamp in Joomla
			if existingModified != created
				stmt = my.prepare("
					UPDATE jos_content 
					SET
						title = '"+title+"',
						alias = '"+title.downcase+"',
						`introtext` = '"+description.gsub(/'/, '&#39;')+"',
						state = 1,
						sectionid = 5,
						catid = 34,
						created = '"+created+"',
						created_by = 62,
						modified = '"+created+"',
						parentid = 0,
						ordering = 1,
						access = 0
					WHERE
						metadata = '"+cardId+"'
				")
				stmt.execute
				pp cardId+': Changed!'
			else 
				pp +' ('+cardId+'): Nothing changed.'
			end

			#exit
		end
	end

	my.close if my

end
=end