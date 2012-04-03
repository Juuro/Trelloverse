#!/usr/bin/ruby1.9 -rubygems -w

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

def trelloToJoomla(title, description='<p>NO U!</p>', attachments=Hash.new, joomlaVersion)

	titlemenu = title+'menu'
	jalias = title.downcase
	jaliasmenu = jalias+'menu'	

	if joomlaVersion == 2.5
		#debug
		puts "Joomla! 2.5"

		#DB connection
		my = Mysql.connect('localhost', 'root', 'jMuaeObS4a', 'joomla')

		stmt = my.prepare("INSERT INTO e94bi_content (asset_id, title, alias, introtext, `fulltext`, state, sectionid, catid, created, created_by, parentid, ordering, access, language) VALUES (170, '"+title+"', '"+jalias+"', '<p>Grill it like its hot!</p>', '"+description+"', 1, 0, 19, '2012-03-13 16:07:06', 42, 0, 0, 1, '*')")
		stmt.execute

		id = nil
		my.query("SELECT id FROM e94bi_content WHERE created='2012-03-13 16:07:06' AND title='"+title+"'").each do |thisid|
			pp thisid
			id = thisid[0]
		end

		stmt = my.prepare("INSERT INTO e94bi_menu (menutype, title, alias, path, link, type, published, parent_id, level, component_id, access, lft, rgt, language) VALUES('aboutjoomla', '"+titlemenu+"', '"+jaliasmenu+"', 'getting-started/"+jaliasmenu+"', 'index.php?option=com_content&view=article&id="+id+"', 'component', 1, 437, 2, 22, 1, 44, 45, '*')")
		stmt.execute

		my.close if my

	elsif joomlaVersion == 1.5
		#debug
		puts "Joomla! 1.5"

		#DB connection
		my = Mysql.connect('localhost', 'root', 'jMuaeObS4a', 'joomla15')

		stmt = my.prepare("INSERT INTO jos_content (title, alias, introtext, `fulltext`, state, sectionid, catid, created, created_by, parentid, ordering, access) VALUES ('"+title+"', '"+jalias+"', '<p>Grill it like its hot!</p>', '"+description+"', 1, 4, 29, '2012-03-13 16:07:06', 62, 0, 1, 0)")
		stmt.execute

		id = nil
		my.query("SELECT id FROM jos_content WHERE created='2012-03-13 16:07:06' AND title='"+title+"'").each do |thisid|
			pp thisid
			id = thisid[0]
		end

		stmt = my.prepare("INSERT INTO jos_menu 
		(menutype, name, alias, link, type, published, parent, componentid, sublevel, access, lft, rgt) VALUES
		('mainmenu', '"+titlemenu+"', '"+jaliasmenu+"', 'index.php?option=com_content&view=article&id="+id+"', 'component', 1, 27, 20, 1, 0, 0, 0)")
		stmt.execute
		
		my.close if my

	end
end