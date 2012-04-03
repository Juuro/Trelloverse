#!/usr/bin/ruby1.9 -rubygems -w


def getChecklist(cardId)
	checklists = open("https://api.trello.com/1/cards/"+cardId+"/checklists?key=0ccb4b07c006c5d5555a55b64a124c89&token=e9fe54ca188979634e2115c4862de38be500cd0d46c95b8a561e693d240268ba").read
	data = JSON.parse(checklists)

	return data  
end

def getAttachment(cardId)
	attachments = open("https://api.trello.com/1/cards/"+cardId+"/attachments?key=0ccb4b07c006c5d5555a55b64a124c89&token=e9fe54ca188979634e2115c4862de38be500cd0d46c95b8a561e693d240268ba").read
	data = JSON.parse(attachments)

	return data
end

def getSingleCard(cardId)
	card = open("https://api.trello.com/1/cards/"+cardId+"?key=0ccb4b07c006c5d5555a55b64a124c89&token=e9fe54ca188979634e2115c4862de38be500cd0d46c95b8a561e693d240268ba").read
	card = JSON.parse(card)

	return card
end

def isCompleted(cardId, itemId)
	completedItems = open("https://api.trello.com/1/cards/"+cardId+"/checkitemstates?key=0ccb4b07c006c5d5555a55b64a124c89&token=e9fe54ca188979634e2115c4862de38be500cd0d46c95b8a561e693d240268ba").read
	completedItems = JSON.parse(completedItems)

	for item in completedItems

		if item['idCheckItem'] == itemId
			return true
		end

	end

	return false
end

def getMember(memberId)
	member = open("https://api.trello.com/1/members/"+memberId+"?key=0ccb4b07c006c5d5555a55b64a124c89&token=e9fe54ca188979634e2115c4862de38be500cd0d46c95b8a561e693d240268ba&filter=open").read
	member = JSON.parse(member)

	return member
end

def getCardActions(cardId)
	actions = open("https://api.trello.com/1/cards/"+cardId+"/actions?key=0ccb4b07c006c5d5555a55b64a124c89&token=e9fe54ca188979634e2115c4862de38be500cd0d46c95b8a561e693d240268ba").read
	actions = JSON.parse(actions)
end