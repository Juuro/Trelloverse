#!/usr/bin/ruby
#Encoding: UTF-8

require 'mysql'
require 'pp'
require 'rest_client'

def getDate(date, format='de')
	# ISO-8601 to German/US date
	formattedDate = Time.new
	formattedDate = Time.iso8601(date)
	
	if format=='de'
		return formattedDate.strftime('%d.%m.%Y %H:%M:%S')
	elsif format=='us'
		return formattedDate.strftime('%m/%d/%Y %I.%M.%S %P')
	elsif format=='joomla'
		return formattedDate.strftime('%Y-%m-%d %H:%M:%S')
	else
		return formattedDate
	end
end

def getChecklist(cardId, key, token)
	checklists = open("https://api.trello.com/1/cards/"+cardId+"/checklists?key="+key+"&token="+token).read
	data = JSON.parse(checklists)

	return data  
end

def getAttachment(cardId, key, token)
	attachments = open("https://api.trello.com/1/cards/"+cardId+"/attachments?key="+key+"&token="+token).read
	data = JSON.parse(attachments)

	return data
end

def getLists(idBoard, key, token)
	list = open("https://api.trello.com/1/boards/"+idBoard+"/lists?key="+key+"&token="+token).read
end

def getList(listId, key, token)
	list = open("https://api.trello.com/1/lists/"+listId+"?key="+key+"&token="+token).read
	list = JSON.parse(list)	
end

def isCompleted(cardId, itemId, key, token)
	completedItems = open("https://api.trello.com/1/cards/"+cardId+"/checkitemstates?key="+key+"&token="+token).read
	completedItems = JSON.parse(completedItems)

	completedItems.each do |item|
		if item['idCheckItem'] == itemId
			return true
		end
	end

	return false
end

def getMember(memberId, key, token)
	member = open("https://api.trello.com/1/members/"+memberId+"?key="+key+"&token="+token+"&filter=open").read
	member = JSON.parse(member)
end

def isThisMe(memberId, key, token)
	if getMember('me', key, token)['id'] == memberId
		return true
	else
		return false
	end
end

def getCardActions(cardId, key, token)
	actions = open("https://api.trello.com/1/cards/"+cardId+"/actions?key="+key+"&token="+token).read
	actions = JSON.parse(actions)
end

def getCardComments(cardId, key, token)
	actions = open("https://api.trello.com/1/cards/"+cardId+"/actions?filter=commentCard&key="+key+"&token="+token).read
	actions = JSON.parse(actions)
end

def cardUpdated(cardId, key, token)
	reply = RestClient.get(
			'https://api.trello.com/1/cards/'+cardId+'/actions?filter=updateCard&key='+key+'&token='+token
	)

	updates = JSON.parse(reply.body)
end

def cardCreated(cardId, key, token)
	reply = RestClient.get(
			'https://api.trello.com/1/cards/'+cardId+'/actions?filter=createCard&key='+key+'&token='+token
	)

	updates = JSON.parse(reply.body)
end

def getSingleCard(cardId, key, token)
	card = open("https://api.trello.com/1/cards/"+cardId+"?key="+key+"&token="+token).read
	card = JSON.parse(card)
end

def getCardsByBoard(boardId, key, token)
	board = open("https://api.trello.com/1/boards/"+boardId+"/cards?key="+key+"&token="+token+"&filter=open").read
	board = JSON.parse(board)
end

def getCardsByList(listId, key, token)
	list = open("https://api.trello.com/1/lists/"+listId+"/cards?key="+key+"&token="+token+"&filter=open").read
	list = JSON.parse(list)
end

def getCardsAsArray(arrayCardsStd, key, token, downloads = true)
	arrayCardsFull = Array.new
	directoryNameAttachments = File.join(Dir.tmpdir, "attachments")
	
	arrayCardsStd.each do |card|
		# export members
		memberArray = Array.new
		card['idMembers'].each do |memberId|
			member = getMember(memberId, key, token)
			memberArray << member			
		end
		membersForCard = Hash.new
		membersForCard['members'] = memberArray
		card = card.merge(membersForCard)
		# end export members		
		
		# export checklists
		hasChecklist = getChecklist(card['id'], key, token) 
		
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
					if isCompleted(card['id'], item['id'], key, token)
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
			comments = getCardComments(card['id'], key, token)
			hashCommentsForCard = Hash.new			
			hashCommentsForCard['commentsContent'] = comments			
			card = card.merge(hashCommentsForCard)
		end
		# end export comments
		
		# export attachments
		if card['badges']['attachments'] != 0
			attachments = getAttachment(card['id'], key, token)			
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
					'https://api.trello.com/1/cards/'+card['id']+'/membersVoted?key='+key+'&token='+token
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


















def trelloToJoomlaSingle(joomlaArticleId, articles)
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
	#DB connection
	my = Mysql.init
	my.options(Mysql::SET_CHARSET_NAME, 'utf8')
	my.real_connect('localhost', 'root', 'jMuaeObS4a', 'joomla15')
	my.query("SET NAMES utf8")

	stmt = my.prepare("UPDATE jos_content SET `introtext`='"+htmlSite+"' WHERE id="+joomlaArticleId.to_s)
	#stmt = my.prepare("UPDATE jos_content SET `introtext`='äüöß' WHERE id="+joomlaArticleId.to_s)
	stmt.execute
	
	my.close if my
	
end


def trelloToJoomlaMultiple(title, created, cardId, sectionid, catid, description='<p>NO U!</p>', attachments=Hash.new, joomlaVersion = 1.5)
	
	if attachments != nil
		description << "<ul>"
		i = 0
		while i < attachments.length do
			description << "<li><a href=\""+attachments[i]['url']+"\">\""+attachments[i]['name']+"\"</a></li>"
			i += 1
		end
		description << "</ul>"
	end

	jalias = title.downcase	

	if joomlaVersion == 2.5
		#debug
		puts "Joomla! 2.5"

		#DB connection
		my = Mysql.init
		my.options(Mysql::SET_CHARSET_NAME, 'utf8')
		my.real_connect('localhost', 'root', 'jMuaeObS4a', 'joomla')
		my.query("SET NAMES utf8")
		
		stmt = my.prepare("INSERT INTO e94bi_content (asset_id, title, alias, `fulltext`, state, sectionid, catid, created, created_by, parentid, ordering, access, language) VALUES (170, '"+title+"', '"+jalias+"', '"+description+"', 1, 0, 19, '"+created+"', 42, 0, 0, 1, '*')")
		stmt.execute

		newArticleId = nil
		my.query("SELECT id FROM e94bi_content WHERE created='"+created+"' AND title='"+title+"'").each do |thisid|
			pp thisid
			newArticleId = thisid[0]
		end

		stmt = my.prepare("INSERT INTO e94bi_menu (menutype, title, alias, path, link, type, published, parent_id, level, component_id, access, lft, rgt, language) VALUES('aboutjoomla', '"+title+"', '"+jalias+"', 'getting-started/"+jalias+"', 'index.php?option=com_content&view=article&id="+newArticleId+"', 'component', 1, 437, 2, 22, 1, 44, 45, '*')")
		stmt.execute

		my.close if my

	elsif joomlaVersion == 1.5
		#debug
		#puts "Joomla! 1.5"

		#DB connection
		my = Mysql.init
		my.options(Mysql::SET_CHARSET_NAME, 'utf8')
		my.real_connect('localhost', 'root', 'jMuaeObS4a', 'joomla15')
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
					'"+jalias+"', 
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
					'"+jalias+"', 
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
			# this should be only one because per Trello card id should only exist one article in Joomla
			existingArticleQuery.each do |thisArticle|				
				
				existingId = thisArticle[0]
				existingCreated = thisArticle[1]
				existingModified = thisArticle[2]
				
				# check if the modiefied timestamp im Trello is different to the modiefied timestamp in Joomla
				if existingModified != created
					stmt = my.prepare("
						UPDATE jos_content 
						SET
							title = '"+title+"',
							alias = '"+jalias+"',
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
					pp cardId+': Nothing changed.'
				end
				
				#exit
			end
		end
		
		my.close if my

	end
end


def trelloToWordpressMultiple(title, created, cardId, sectionid, catid, description='<p>NO U!</p>', attachments=Hash.new, joomlaVersion = 1.5)

	if attachments != nil
		description << "<ul>"
		i = 0
		while i < attachments.length do
			description << "<li><a href=\""+attachments[i]['url']+"\">\""+attachments[i]['name']+"\"</a></li>"
			i += 1
		end
		description << "</ul>"
	end

	jalias = title.downcase	

	#DB connection
	my = Mysql.init
	my.options(Mysql::SET_CHARSET_NAME, 'utf8')
	my.real_connect('localhost', 'root', 'jMuaeObS4a', 'wordpress')
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
				'"+jalias+"', 
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
				'"+jalias+"', 
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
		# this should be only one because per Trello card id should only exist one article in Joomla
		existingArticleQuery.each do |thisArticle|				

			existingId = thisArticle[0]
			existingCreated = thisArticle[1]
			existingModified = thisArticle[2]

			# check if the modiefied timestamp im Trello is different to the modiefied timestamp in Joomla
			if existingModified != created
				stmt = my.prepare("
					UPDATE jos_content 
					SET
						title = '"+title+"',
						alias = '"+jalias+"',
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
				pp cardId+': Nothing changed.'
			end

			#exit
		end
	end

	my.close if my

end