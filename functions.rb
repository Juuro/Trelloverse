#!/usr/bin/ruby
#Encoding: UTF-8

require 'mysql'
require 'pp'

@key = "0ccb4b07c006c5d5555a55b64a124c89"
@token = "e9fe54ca188979634e2115c4862de38be500cd0d46c95b8a561e693d240268ba"


def getChecklist(cardId)
	checklists = open("https://api.trello.com/1/cards/"+cardId+"/checklists?key="+@key+"&token="+@token).read
	data = JSON.parse(checklists)

	return data  
end

def getAttachment(cardId)
	attachments = open("https://api.trello.com/1/cards/"+cardId+"/attachments?key="+@key+"&token="+@token).read
	data = JSON.parse(attachments)

	return data
end

def getList(listId)
	list = open("https://api.trello.com/1/lists/"+listId+"?key="+@key+"&token="+@token).read
	list = JSON.parse(list)
	
	return list	
end

def getSingleCard(cardId)
	card = open("https://api.trello.com/1/cards/"+cardId+"?key="+@key+"&token="+@token).read
	card = JSON.parse(card)

	return card
end

def isCompleted(cardId, itemId)
	completedItems = open("https://api.trello.com/1/cards/"+cardId+"/checkitemstates?key="+@key+"&token="+@token).read
	completedItems = JSON.parse(completedItems)

	for item in completedItems

		if item['idCheckItem'] == itemId
			return true
		end

	end

	return false
end

def getMember(memberId)
	member = open("https://api.trello.com/1/members/"+memberId+"?key="+@key+"&token="+@token+"&filter=open").read
	member = JSON.parse(member)

	return member
end

def getCardActions(cardId)
	actions = open("https://api.trello.com/1/cards/"+cardId+"/actions?key="+@key+"&token="+@token).read
	actions = JSON.parse(actions)
end

def trelloToJoomlaSingle(articles=[], joomlaArticleId)
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

def trelloToJoomlaMultiple(articles=[], joomlaVersion = 1.5)
	
	articles.each do |element|
		title = element.title
		jalias = element.jalias
		description = element.description
		if element.attachments != []		
			attachments = element.attachments
		end

		if joomlaVersion == 2.5
			#debug
			puts "Joomla! 2.5"
	
			#DB connection
			my = Mysql.connect('localhost', 'root', 'jMuaeObS4a', 'joomla')
	
			stmt = my.prepare("INSERT INTO e94bi_content (asset_id, title, alias, `fulltext`, state, sectionid, catid, created, created_by, parentid, ordering, access, language) VALUES (170, '"+title+"', '"+jalias+"', '"+description+"', 1, 0, 19, '2012-03-13 16:07:06', 42, 0, 0, 1, '*')")
			stmt.execute
	
			id = nil
			my.query("SELECT id FROM e94bi_content WHERE created='2012-03-13 16:07:06' AND title='"+title+"'").each do |thisid|
				pp thisid
				id = thisid[0]
			end
	
			stmt = my.prepare("INSERT INTO e94bi_menu (menutype, title, alias, path, link, type, published, parent_id, level, component_id, access, lft, rgt, language) VALUES('aboutjoomla', '"+title+"', '"+jalias+"', 'getting-started/"+jalias+"', 'index.php?option=com_content&view=article&id="+id+"', 'component', 1, 437, 2, 22, 1, 44, 45, '*')")
			stmt.execute
	
			my.close if my
	
		elsif joomlaVersion == 1.5
			#debug
			puts "Joomla! 1.5"
	
			#DB connection
			my = Mysql.connect('localhost', 'root', 'jMuaeObS4a', 'joomla15')
	
			stmt = my.prepare("INSERT INTO jos_content (title, alias, `fulltext`, state, sectionid, catid, created, created_by, parentid, ordering, access) VALUES ('"+title+"', '"+jalias+"', '"+description+"', 1, 4, 29, '2012-03-13 16:07:06', 62, 0, 1, 0)")
			stmt.execute
	
			id = nil
			my.query("SELECT id FROM jos_content WHERE created='2012-03-13 16:07:06' AND title='"+title+"'").each do |thisid|
				pp thisid
				id = thisid[0]
			end
	
			stmt = my.prepare("INSERT INTO jos_menu 
			(menutype, name, alias, link, type, published, parent, componentid, sublevel, access, lft, rgt) VALUES
			('mainmenu', '"+title+"', '"+jalias+"', 'index.php?option=com_content&view=article&id="+id+"', 'component', 1, 27, 20, 1, 0, 0, 0)")
			stmt.execute
			
			my.close if my
	
		end
	end
end