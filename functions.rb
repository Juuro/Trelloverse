#!/usr/bin/ruby
#Encoding: UTF-8

require 'mysql'
require 'pp'
require 'rest_client'
require 'time'
require 'kramdown'
require 'json'

# Get basic information about a board.
def getBoard(boardId)
	response = RestClient.get("https://api.trello.com/1/boards/"+boardId+"/?&key="+$key+"&token="+$token)
	response = JSON.parse(response)	
end

# Get a single fiel of a board.
def getBoardField(boardId, field)
	response = RestClient.get("https://api.trello.com/1/boards/"+boardId+"/"+field+"?&key="+$key+"&token="+$token)
	response = JSON.parse(response)	
end

# Get all board actions.
def getBoardActions(boardId)
	response = RestClient.get("https://api.trello.com/1/boards/"+boardId+"/actions?&key="+$key+"&token="+$token)
	response = JSON.parse(response)	
end

# Filter the cards of a board.
def getBoardCardsFilter(boardId, filter)
	response = RestClient.get("https://api.trello.com/1/boards/"+boardId+"/cards/"+filter+"?&key="+$key+"&token="+$token)
	response = JSON.parse(response)	
end

# Get a card by board and card.
def getBoardCardId(boardId, cardId)
	response = RestClient.get("https://api.trello.com/1/boards/"+boardId+"/cards/"+cardId+"?&key="+$key+"&token="+$token)
	response = JSON.parse(response)	
end

# Get all checklists of a board.
def getBoardChecklists(boardId)
	response = RestClient.get("https://api.trello.com/1/boards/"+boardId+"/checklists?&key="+$key+"&token="+$token)
	response = JSON.parse(response)	
end

# Get all lists of a board.
def getBoardLists(boardId)
	response = RestClient.get("https://api.trello.com/1/boards/"+boardId+"/lists?&key="+$key+"&token="+$token)
	response = JSON.parse(response)	
end

# Filter the lists of a board.
def getBoardListsFilter(boardId, filter)
	response = RestClient.get("https://api.trello.com/1/boards/"+boardId+"/lists/"+filter+"?&key="+$key+"&token="+$token)
	response = JSON.parse(response)	
end

# Get all members of a board.
def getBoardMembers(boardId)
	response = RestClient.get("https://api.trello.com/1/boards/"+boardId+"/members?&key="+$key+"&token="+$token)
	response = JSON.parse(response)	
end

# Filter the members of a board.
def getBoardMembersFilter(boardId, filter)
	response = RestClient.get("https://api.trello.com/1/boards/"+boardId+"/members/"+filter+"?&key="+$key+"&token="+$token)
	response = JSON.parse(response)	
end

# Get all cards of a member in a specific board.
def getBoardMembersCards(boardId, memberId)
	response = RestClient.get("https://api.trello.com/1/boards/"+boardId+"/members/"+memberId+"/cards?&key="+$key+"&token="+$token)
	response = JSON.parse(response)	
end

# Get the invited members of a board.
def getBoardMembersInvited(boardId)
	response = RestClient.get("https://api.trello.com/1/boards/"+boardId+"/membersInvited?&key="+$key+"&token="+$token)
	response = JSON.parse(response)	
end

# Get a single field of the invited members of a board.
def getBoardMembersInvitedField(boardId, field)
	response = RestClient.get("https://api.trello.com/1/boards/"+boardId+"/membersInvited/"+field+"?&key="+$key+"&token="+$token)
	response = JSON.parse(response)	
end

# Get the personal preferences for a board.
def getBoardMyPrefs(boardId)
	response = RestClient.get("https://api.trello.com/1/boards/"+boardId+"/myPrefs?&key="+$key+"&token="+$token)
	response = JSON.parse(response)	
end

# Get the organization a board belongs to.
def getBoardOrganization(boardId)
	response = RestClient.get("https://api.trello.com/1/boards/"+boardId+"/organization?&key="+$key+"&token="+$token)
	response = JSON.parse(response)	
end

# Get a single field of the the organization a board belongs to.
def getBoardOrganizationField(boardId, field)
	response = RestClient.get("https://api.trello.com/1/boards/"+boardId+"/organization/"+field+"?&key="+$key+"&token="+$token)
	response = JSON.parse(response)	
end

# Change a board.
def putBoard(boardId, name, desc, closed, subscribed, idOrganization, permissionLevel, selfJoin, cardCovers, invitations, voting, comments)

	hash = Hash.new
	hash[:name] = name if !name.nil?
	hash[:desc] = desc if !desc.nil? 
	hash[:closed] = closed if !closed.nil? 
	hash[:subscribed] = subscribed if !subscribed.nil? 
	hash[:idOrganization] = idOrganization if !idOrganization.nil?
	hash[:prefs_permissionLevel] = permissionLevel if !permissionLevel.nil?
	hash[:prefs_selfJoin] = selfJoin if !selfJoin.nil?
	hash[:prefs_cardCovers] = cardCovers if !cardCovers.nil?
	hash[:prefs_invitations] = invitations if !invitations.nil?
	hash[:prefs_voting] = voting if !voting.nil?
	hash[:prefs_comments] = comments if !comments.nil?
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.put "https://api.trello.com/1/boards/"+boardId, hash 
	response = JSON.parse(response)	
end

# Close or open a board.
def putBoardClosed(boardId, closed)
	response = RestClient.put(
			'https://api.trello.com/1/boards/'+boardId+'/closed',
			:value 	=> closed,
			:key    => $key,
			:token  => $token
	)
end

# Change board description.
def putBoardDesc(boardId, desc)
	response = RestClient.put(
			'https://api.trello.com/1/boards/'+boardId+'/desc',
			:value 	=> desc,
			:key    => $key,
			:token  => $token
	)
end

# Assign board to a different organization.
def putBoardOrganization(boardId, idOrganization)
	response = RestClient.put(
			'https://api.trello.com/1/boards/'+boardId+'/idOrganization',
			:value 	=> idOrganization,
			:key    => $key,
			:token  => $token
	)
end

# Assign member to board.
def putBoardMember(boardId, memberId, type)
	response = RestClient.put(
			'https://api.trello.com/1/boards/'+boardId+'/members/'+memberId,
			:idMember 	=> memberId,
			:type 			=> type,
			:key    		=> $key,
			:token  		=> $token
	)
end

# Change board name.
def putBoardName(boardId, name)
	response = RestClient.put(
			'https://api.trello.com/1/boards/'+boardId+'/name',
			:value 	=> name,
			:key    => $key,
			:token  => $token
	)
end

# Change Card Cover settings.
def putBoardPrefsCardCovers(boardId, value)
	response = RestClient.put(
			'https://api.trello.com/1/boards/'+boardId+'/prefs/cardCovers',
			:value 	=> value,
			:key    => $key,
			:token  => $token
	)
end

# Change comments settings.
def putBoardPrefsComments(boardId, value)
	response = RestClient.put(
			'https://api.trello.com/1/boards/'+boardId+'/prefs/comments',
			:value 	=> value,
			:key    => $key,
			:token  => $token
	)
end

# Change invitation settings.
def putBoardPrefsInvitations(boardId, value)
	response = RestClient.put(
			'https://api.trello.com/1/boards/'+boardId+'/prefs/invitations',
			:value 	=> value,
			:key    => $key,
			:token  => $token
	)
end

# Change permission level settings.
def putBoardPrefsPermissionLevel(boardId, value)
	response = RestClient.put(
			'https://api.trello.com/1/boards/'+boardId+'/prefs/permissionLevel',
			:value 	=> value,
			:key    => $key,
			:token  => $token
	)
end

# Change self join settings.
def putBoardPrefsSelfJoin(boardId, value)
	response = RestClient.put(
			'https://api.trello.com/1/boards/'+boardId+'/prefs/selfJoin',
			:value 	=> value,
			:key    => $key,
			:token  => $token
	)
end

# Change voting settings.
def putBoardPrefsVoting(boardId, value)
	response = RestClient.put(
			'https://api.trello.com/1/boards/'+boardId+'/prefs/voting',
			:value 	=> value,
			:key    => $key,
			:token  => $token
	)
end

# Subscribe boards.
def putBoardSubscribed(boardId, value)
	response = RestClient.put(
			'https://api.trello.com/1/boards/'+boardId+'/subscribed',
			:value 	=> value,
			:key    => $key,
			:token  => $token
	)
end

# Create a new checklist.
def postBoardChecklists(boardId, name)
	response = RestClient.post(
			'https://api.trello.com/1/boards/'+boardId+'/checklists',
			:name 	=> name,
			:key    => $key,
			:token  => $token
	)
end

# Invite members to a board.
def postBoardInvitations(boardId, memberId, email, type)

	hash = Hash.new
	hash[:idMember] = memberId if !memberId.nil?
	hash[:email] = email if !email.nil?
	hash[:type] = type if !type.nil?
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.post "https://api.trello.com/1/boards/"+boardId+"/invitations", hash 
	response = JSON.parse(response)	
end

# Create new list.
def postBoardILists(boardId, name)

	hash = Hash.new
	hash[:name] = name
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.post "https://api.trello.com/1/boards/"+boardId+"/lists", hash 
	response = JSON.parse(response)	
end

# Mark as viewd
def postBoardMarkAsViewed(boardId)

	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.post "https://api.trello.com/1/boards/"+boardId+"/markAsViewed", hash 
	response = JSON.parse(response)	
end

# Change personal preferences of the board.
def postBoardMyPrefs(boardId, name, value)

	hash = Hash.new
	hash[:name] = name
	hash[:value] = value
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.post "https://api.trello.com/1/boards/"+boardId+"/myPrefs", hash 
	response = JSON.parse(response)	
end

# Delete invitation.
def deleteBoardInvitation(boardId, idInvitation)

	hash = Hash.new
	hash[:idInvitation] = idInvitation
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.delete "https://api.trello.com/1/boards/"+boardId+"/invitations/"+idInvitation, hash 
	response = JSON.parse(response)	
end

# Delete board member.
def deleteBoardMember(boardId, idMember)

	hash = Hash.new
	hash[:idMember] = idMember
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.delete "https://api.trello.com/1/boards/"+boardId+"/invitations/"+idMember, hash 
	response = JSON.parse(response)	
end


### Date

# Formatting dates for post processing.
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

# Get basic information of a member.
def getMember(memberId)
	member = RestClient.get("https://api.trello.com/1/members/"+memberId+"?key="+$key+"&token="+$token+"&filter=open")
	member = JSON.parse(member)
end

# Get a single field of a member's information.
def getMemberField(memberId, field)
	response = RestClient.get("https://api.trello.com/1/members/"+memberId+"/"+field+"?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Get a member's action.
def getMemberActions(memberId)
	response = RestClient.get("https://api.trello.com/1/members/"+memberId+"/actions?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Get basic information of all boards of a member.
def getBoardsByMember(memberId)
	boards = RestClient.get("https://api.trello.com/1/members/"+memberId+"/boards?key="+$key+"&token="+$token+"&filter=open")
	boards = JSON.parse(boards)
end

# Filter a member's boards.
def getMemberBoardsFilter(memberId, filter)
	response = RestClient.get("https://api.trello.com/1/members/"+memberId+"/boards/"+filter+"?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Get a member's board invitations.
def getMemberBoardsInvited(memberId)
	response = RestClient.get("https://api.trello.com/1/members/"+memberId+"/boardsInvited?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Get a single field of a member's board invitations.
def getMemberBoardsInvitedField(memberId, field)
	response = RestClient.get("https://api.trello.com/1/members/"+memberId+"/boardsInvited/"+field+"?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Get a single field of a member's board invitations.
def getMemberCards(memberId)
	response = RestClient.get("https://api.trello.com/1/members/"+memberId+"/cards?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Filter a member's cards.
def getMemberCardsFilter(memberId, filter)
	response = RestClient.get("https://api.trello.com/1/members/"+memberId+"/cards/"+filter+"?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Get a member's notifications.
def getMemberNotifications(memberId)
	response = RestClient.get("https://api.trello.com/1/members/"+memberId+"/notifications?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Filter a member's notifications.
def getMemberNotifications(memberId, filter)
	response = RestClient.get("https://api.trello.com/1/members/"+memberId+"/notifications/"+filter+"?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Get basic information of all organizations of a member.
def getOrganizationsByMember(memberId)
	orgas = RestClient.get("https://api.trello.com/1/members/"+memberId+"/organizations?key="+$key+"&token="+$token+"")
	orgas = JSON.parse(orgas)
end

# Filter a member's organizations.
def getMemberOrganizationsFilter(memberId, filter)
	response = RestClient.get("https://api.trello.com/1/members/"+memberId+"/organizations/"+filter+"?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Get a member's board organization.
def getMemberOrganizationsInvited(memberId)
	response = RestClient.get("https://api.trello.com/1/members/"+memberId+"/organizationsInvited?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Get a single field of a member's organization invitations.
def getMemberOrganizationsInvitedField(memberId, field)
	response = RestClient.get("https://api.trello.com/1/members/"+memberId+"/organizationsInvited/"+field+"?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Get a member's organizations.
def getMemberTokens(memberId, field)
	response = RestClient.get("https://api.trello.com/1/members/"+memberId+"/tokens?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Change a member's information.
def putMember(memberId, fullName, initials, bio)

	hash = Hash.new
	hash[:fullName] = fullName	
	hash[:initials] = initials	
	hash[:bio] = bio	
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.put "https://api.trello.com/1/members/"+memberId, hash 
	response = JSON.parse(response)	
end

# Change a member's bio.
def putMemberBio(memberId, value)

	hash = Hash.new
	hash[:value] = value	
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.put "https://api.trello.com/1/members/"+memberId+"/bio", hash 
	response = JSON.parse(response)	
end

# Change a member's full name.
def putMemberFullName(memberId, value)

	hash = Hash.new
	hash[:value] = value	
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.put "https://api.trello.com/1/members/"+memberId+"/fullName", hash 
	response = JSON.parse(response)	
end

# Change a member's initials.
def putMemberInitials(memberId, value)

	hash = Hash.new
	hash[:value] = value	
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.put "https://api.trello.com/1/members/"+memberId+"/initials", hash 
	response = JSON.parse(response)	
end




### Notifications

# Get basic information about a notification.
def getNotification(notificationId)
	response = RestClient.get("https://api.trello.com/1/notifications/"+notificationId+"?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Get a single field of a notification.
def getNotificationField(notificationId, field)
	response = RestClient.get("https://api.trello.com/1/notifications/"+notificationId+"/"+field+"?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Get a notification's board.
def getNotificationBoard(notificationId)
	response = RestClient.get("https://api.trello.com/1/notifications/"+notificationId+"/board?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Get a single field of a notification's board.
def getNotificationBoardField(notificationId, field)
	response = RestClient.get("https://api.trello.com/1/notifications/"+notificationId+"/board/"+field+"?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Get a notification's card.
def getNotificationCard(notificationId)
	response = RestClient.get("https://api.trello.com/1/notifications/"+notificationId+"/card?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Get a single field of a notification's card.
def getNotificationCardField(notificationId, field)
	response = RestClient.get("https://api.trello.com/1/notifications/"+notificationId+"/card/"+field+"?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Get a notification's list.
def getNotificationList(notificationId)
	response = RestClient.get("https://api.trello.com/1/notifications/"+notificationId+"/list?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Get a single field of a notification's list.
def getNotificationListField(notificationId, field)
	response = RestClient.get("https://api.trello.com/1/notifications/"+notificationId+"/list/"+field+"?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Get a notification's member.
def getNotificationMember(notificationId)
	response = RestClient.get("https://api.trello.com/1/notifications/"+notificationId+"/member?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Get a single field of a notification's member.
def getNotificationMemberField(notificationId, field)
	response = RestClient.get("https://api.trello.com/1/notifications/"+notificationId+"/member/"+field+"?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Get a notification's creator.
def getNotificationMemberCreator(notificationId)
	response = RestClient.get("https://api.trello.com/1/notifications/"+notificationId+"/memberCreator?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Get a single field of a notification's creator.
def getNotificationMemberCreatorField(notificationId, field)
	response = RestClient.get("https://api.trello.com/1/notifications/"+notificationId+"/memberCreator/"+field+"?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Get a notification's organization.
def getNotificationOrganization(notificationId)
	response = RestClient.get("https://api.trello.com/1/notifications/"+notificationId+"/organization?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Get a single field of a notification's organization.
def getNotificationOrganizationField(notificationId, field)
	response = RestClient.get("https://api.trello.com/1/notifications/"+notificationId+"/organization/"+field+"?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Change a notification.
def putNotification(notificationId, unread)

	hash = Hash.new
	hash[:unread] = unread	
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.put "https://api.trello.com/1/notifications/"+notificationId, hash 
	response = JSON.parse(response)	
end

# Mark a notification read or unread.
def putNotificationUnread(notificationId, value)

	hash = Hash.new
	hash[:value] = value	
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.put "https://api.trello.com/1/notifications/"+notificationId+"/unread", hash 
	response = JSON.parse(response)	
end

# Mark all notifications read.
def postNotificationsRead

	hash = Hash.new
	hash[:value] = value	
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.post "https://api.trello.com/1/notifications/all/read", hash 
	response = JSON.parse(response)	
end





















# Check if a member is the same as the actually used account.
def isThisMe(memberId)
	if getMember('me')['id'] == memberId
		return true
	else
		return false
	end
end

# Get all members which are assigned to a board.
def getMembersByBoard(boardId)
	members = RestClient.get("https://api.trello.com/1/boards/"+boardId+"/members?&key="+$key+"&token="+$token)
	members = JSON.parse(members)	
end

# Invite a member to a board.
def postMemberInviteBoard(boardId, memberId)
	response = RestClient.post(
			'https://api.trello.com/1/boards/'+boardId+'/invitations',
			:idMember => memberId,
			:key     => $key,
			:token   => $token
	)
	JSON.parse(response)
end








# Get basic information of all cards of a organization.
def getCardsByOrganization(orgId)
	boards = getBoardsByOrganization(orgId)

	cards = Array.new
	boards.each do |board|
		cards += getCardsByBoard(board['id'])
	end

	return cards
end

# Get basic information of all lists of a board.
def getListsByBoard(boardId)
	list = RestClient.get("https://api.trello.com/1/boards/"+boardId+"/lists?key="+$key+"&token="+$token)
	list = JSON.parse(list)	
end

# Get basic information of a card.
def getCard(cardId)
	response = RestClient.get("https://api.trello.com/1/cards/"+cardId+"?key="+$key+"&token="+$token)
	response = JSON.parse(response)
end

# Get a single field of a card.
def getCardField(cardId, field)
	response = RestClient.get("https://api.trello.com/1/cards/"+cardId+"/"+field+"?key="+$key+"&token="+$token)
	response = JSON.parse(response)
end

# Get card actions
def getCardActions(cardId)
	response = RestClient.get("https://api.trello.com/1/cards/"+cardId+"/actions?key="+$key+"&token="+$token)
	response = JSON.parse(response)
end

# Get all checklists of a card.
def getCardChecklist(cardId)
	response = RestClient.get("https://api.trello.com/1/cards/"+cardId+"/checklists?key="+$key+"&token="+$token)
	response = JSON.parse(response)
end

# Get all attachments of a card.
def getCardAttachments(cardId)
	response = RestClient.get("https://api.trello.com/1/cards/"+cardId+"/attachments?key="+$key+"&token="+$token)
	response = JSON.parse(response)
end

# Get information about the card's board.
def getCardBoard(cardId)
	response = RestClient.get("https://api.trello.com/1/cards/"+cardId+"/board?key="+$key+"&token="+$token)
	response = JSON.parse(response)
end

#Get a single field about a card's board.
def getCardBoardField(cardId, field)
	response = RestClient.get("https://api.trello.com/1/cards/"+cardId+"/"+field+"?key="+$key+"&token="+$token)
	response = JSON.parse(response)
end

# Get a card's check item states.
def getCardCheckItemStates(cardId, field)
	response = RestClient.get("https://api.trello.com/1/cards/"+cardId+"/checkItemStates?key="+$key+"&token="+$token)
	response = JSON.parse(response)
end

# Get information about a cards's list.
def getCardList(cardId)
	response = RestClient.get("https://api.trello.com/1/cards/"+cardId+"/list?key="+$key+"&token="+$token)
	response = JSON.parse(response)
end

# Get a single field of a card's list.
def getCardListField(cardId, field)
	response = RestClient.get("https://api.trello.com/1/cards/"+cardId+"/list/"+field+"?key="+$key+"&token="+$token)
	response = JSON.parse(response)
end

# Get members which are assigned to a card.
def getCardMembers(cardId)
	response = RestClient.get("https://api.trello.com/1/cards/"+cardId+"/members?key="+$key+"&token="+$token)
	response = JSON.parse(response)
end

# Get members which voted for a card.
def getCardMembersVoted(cardId)
	response = RestClient.get("https://api.trello.com/1/cards/"+cardId+"/membersVoted?key="+$key+"&token="+$token)
	response = JSON.parse(response)
end

# Change a card.
def putCard(cardId, name, desc, closed, idAttachmentCover, idList, idBoard, pos, due, subscribed)

	hash = Hash.new
	hash[:name] = name if !name.nil?
	hash[:desc] = desc if !desc.nil?
	hash[:closed] = closed if !closed.nil?
	hash[:idAttachmentCover] = idAttachmentCover if !idAttachmentCover.nil?
	hash[:idList] = idList if !idList.nil?
	hash[:idBoard] = idBoard if !idBoard.nil?
	hash[:pos] = pos if !pos.nil?
	hash[:due] = due if !due.nil?
	hash[:subscribed] = subscribed if !subscribed.nil?
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.put "https://api.trello.com/1/cards/"+cardId+"/", hash 
	response = JSON.parse(response)	
end

# Change a comment.
def putCardComment(cardId, idAction, text)

	hash = Hash.new
	hash[:idAction] = idAction
	hash[:text] = text
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.put "https://api.trello.com/1/cards/"+cardId+"/actions/"+idAction+"/comments", hash 
	response = JSON.parse(response)	
end

# Change a checkitem's name.
def putCardCheckItemName(cardId, idChecklist, idCheckItem, value)

	hash = Hash.new
	hash[:idChecklist] = idChecklist
	hash[:idCheckItem] = idCheckItem
	hash[:value] = value	
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.post "https://api.trello.com/1/cards/"+cardId+"/checklist/"+idChecklist+"/checkItem/"+idCheckItem+"/name", hash 
	response = JSON.parse(response)	
end

# Change a checkitem's position.
def putCardCheckItemPosition(cardId, idChecklist, idCheckItem, value)

	hash = Hash.new
	hash[:idChecklist] = idChecklist
	hash[:idCheckItem] = idCheckItem
	hash[:value] = value	
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.put "https://api.trello.com/1/cards/"+cardId+"/checklist/"+idChecklist+"/checkItem/"+idCheckItem+"/pos", hash 
	response = JSON.parse(response)	
end

# Change a checkitem's state.
def putCardCheckItemPosition(cardId, idChecklist, idCheckItem, value)

	hash = Hash.new
	hash[:idChecklist] = idChecklist
	hash[:idCheckItem] = idCheckItem
	hash[:value] = value	
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.put "https://api.trello.com/1/cards/"+cardId+"/checklist/"+idChecklist+"/checkItem/"+idCheckItem+"/state", hash 
	response = JSON.parse(response)	
end

# Close or open a card.
def putCardClose(cardId, value)

	hash = Hash.new
	hash[:value] = value	
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.put "https://api.trello.com/1/cards/"+cardId+"/closed", hash 
	response = JSON.parse(response)	
end

# Change a card's description.
def putCardDesc(cardId, value)

	hash = Hash.new
	hash[:value] = value	
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.put "https://api.trello.com/1/cards/"+cardId+"/desc", hash 
	response = JSON.parse(response)	
end

# Change a card's due date.
def putCardDue(cardId, value)

	hash = Hash.new
	hash[:value] = value	
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.put "https://api.trello.com/1/cards/"+cardId+"/due", hash 
	response = JSON.parse(response)	
end

# Change a card's Card Cover.
def putCardIdAttachmentCover(cardId, value)

	hash = Hash.new
	hash[:value] = value	
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.put "https://api.trello.com/1/cards/"+cardId+"/idAttachmentCover", hash 
	response = JSON.parse(response)	
end

# Change a card's board.
def putCardIdBoard(cardId, value, idList)

	hash = Hash.new
	hash[:value] = value	
	hash[:idList] = idList if !idList.nil?
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.put "https://api.trello.com/1/cards/"+cardId+"/idBoard", hash 
	response = JSON.parse(response)	
end

# Change a card's list.
def putCardIdList(cardId, value)

	hash = Hash.new
	hash[:value] = value	
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.put "https://api.trello.com/1/cards/"+cardId+"/idLisr", hash 
	response = JSON.parse(response)	
end

# Change a card's name.
def putCardName(cardId, value)

	hash = Hash.new
	hash[:value] = value	
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.put "https://api.trello.com/1/cards/"+cardId+"/name", hash 
	response = JSON.parse(response)	
end

# Change a card's position.
def putCardPos(cardId, value)

	hash = Hash.new
	hash[:value] = value	
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.put "https://api.trello.com/1/cards/"+cardId+"/pos", hash 
	response = JSON.parse(response)	
end

# Subscribe to a card.
def putCardSubscribed(cardId, value)

	hash = Hash.new
	hash[:value] = value	
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.put "https://api.trello.com/1/cards/"+cardId+"/subscribed", hash 
	response = JSON.parse(response)	
end

# Create a new card.
def postCard(name, desc, pos, idList, idCardSource, keepFromSource)

	hash = Hash.new
	hash[:name] = name
	hash[:desc] = desc if !desc.nil?
	hash[:pos] = pos if !pos.nil?	
	hash[:idList] = idList if !idList.nil?	
	hash[:idCardSource] = idCardSource if !idCardSource.nil?
	hash[:keepFromSource] = keepFromSource if !keepFromSource.nil?	
	hash[:key] = $key
	hash[:token] = $token	

	response = RestClient.post 'https://api.trello.com/1/cards', hash
	response = JSON.parse(response)
end

# Post a comment.
def postCardComment(cardId, text)

	hash = Hash.new
	hash[:text] = text
	hash[:key] = $key
	hash[:token] = $token	

	response = RestClient.post 'https://api.trello.com/1/cards/'+cardId+'/actions/comments', hash
	response = JSON.parse(response)
end

# Add an attachment.
def postCardAttachment(cardId, file, url, name, mimeType)

	hash = Hash.new
	hash[:file] = file if !file.nil?
	hash[:url] = url if !url.nil?	
	hash[:name] = name if !name.nil?	
	hash[:mimeType] = mimeType if !mimeType.nil?	
	hash[:key] = $key
	hash[:token] = $token	

	response = RestClient.post 'https://api.trello.com/1/cards/'+cardId+'/attachments', hash
	response = JSON.parse(response)
end

# Add a checklist to a card.
def postCardChecklist(cardId, value)

	hash = Hash.new
	hash[:value] = value
	hash[:key] = $key
	hash[:token] = $token	

	response = RestClient.post 'https://api.trello.com/1/cards/'+cardId+'/checklists', hash
	response = JSON.parse(response)
end

# Add a label to a card.
def postCardLabel(cardId, value)

	hash = Hash.new
	hash[:value] = value
	hash[:key] = $key
	hash[:token] = $token	

	response = RestClient.post 'https://api.trello.com/1/cards/'+cardId+'/labels', hash
	response = JSON.parse(response)
end

# Assign a member to a card.
def postCardMember(cardId, value)

	hash = Hash.new
	hash[:value] = value
	hash[:key] = $key
	hash[:token] = $token	

	response = RestClient.post 'https://api.trello.com/1/cards/'+cardId+'/members', hash
	response = JSON.parse(response)
end

# Add members which voted for the card.
def postCardMembersVoted(cardId, value)

	hash = Hash.new
	hash[:value] = value
	hash[:key] = $key
	hash[:token] = $token	

	response = RestClient.post 'https://api.trello.com/1/cards/'+cardId+'/membersVoted', hash
	response = JSON.parse(response)
end

# Delete a card.
def deleteCard(cardId)

	hash = Hash.new
	hash[:key] = $key
	hash[:token] = $token	

	response = RestClient.delete 'https://api.trello.com/1/cards/'+cardId, hash
	response = JSON.parse(response)
end

# Delete a comment.
def deleteCardComment(cardId, idAction)

	hash = Hash.new
	hash[:idAction] = idAction
	hash[:key] = $key
	hash[:token] = $token	

	response = RestClient.delete 'https://api.trello.com/1/cards/'+cardId+'/actions/'+idAction+'/comments', hash
	response = JSON.parse(response)
end

# Delete an attachment.
def deleteCardAttachment(cardId, idAttachment)

	hash = Hash.new
	hash[:idAttachment] = idAttachment
	hash[:key] = $key
	hash[:token] = $token	

	response = RestClient.delete 'https://api.trello.com/1/cards/'+cardId+'/attachments/'+idAttachment, hash
	response = JSON.parse(response)
end

# Delete a checklist.
def deleteCardChecklist(cardId, idChecklist)

	hash = Hash.new
	hash[:idChecklist] = idChecklist
	hash[:key] = $key
	hash[:token] = $token	

	response = RestClient.delete 'https://api.trello.com/1/cards/'+cardId+'/checklists/'+idChecklist, hash
	response = JSON.parse(response)
end

# Delete a label.
def deleteCardAttachment(cardId, color)

	hash = Hash.new
	hash[:color] = color
	hash[:key] = $key
	hash[:token] = $token	

	response = RestClient.delete 'https://api.trello.com/1/cards/'+cardId+'/labels/'+color, hash
	response = JSON.parse(response)
end

# Delete a assigned member.
def deleteCardMember(cardId, idMember)

	hash = Hash.new
	hash[:idMember] = idMember
	hash[:key] = $key
	hash[:token] = $token	

	response = RestClient.delete 'https://api.trello.com/1/cards/'+cardId+'/members/'+idMember, hash
	response = JSON.parse(response)
end

# Delete a assigned member.
def deleteCardMembersVoted(cardId, idMember)

	hash = Hash.new
	hash[:idMember] = idMember
	hash[:key] = $key
	hash[:token] = $token	

	response = RestClient.delete 'https://api.trello.com/1/cards/'+cardId+'/membersVoted/'+idMember, hash
	response = JSON.parse(response)
end

# Get information about a checklist.
def getChecklist(idChecklist)
	response = RestClient.get("https://api.trello.com/1/checklists/"+idChecklist+"?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Get a single field of a checklist.
def getChecklistField(idChecklist, field)
	response = RestClient.get("https://api.trello.com/1/checklists/"+idChecklist+"/"+field+"?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Get information about the board of a checklist.
def getChecklistBoard(idChecklist)
	response = RestClient.get("https://api.trello.com/1/checklists/"+idChecklist+"/board?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Get a single field of the board of a checklist.
def getChecklistBoardField(idChecklist, field)
	response = RestClient.get("https://api.trello.com/1/checklists/"+idChecklist+"/board/"+field+"?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Get information about the cards of a checklist.
def getChecklistCards(idChecklist)
	response = RestClient.get("https://api.trello.com/1/checklists/"+idChecklist+"/cards?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Filter the cards of a checklist.
def getChecklistCardsFilter(idChecklist, filter)
	response = RestClient.get("https://api.trello.com/1/checklists/"+idChecklist+"/board/"+filter+"?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Get the checkitems of a checklist.
def getChecklistCheckItems(idChecklist)
	response = RestClient.get("https://api.trello.com/1/checklists/"+idChecklist+"/checkItems?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Change a checklist.
def putChecklist(idChecklist, name)

	hash = Hash.new
	hash[:name] = name if !name.nil?

	response = RestClient.put "https://api.trello.com/1/checklists/"+idChecklist+"?key="+$key+"&token="+$token+"&filter=open", hash
	response = JSON.parse(response)
end

# Change a checklist's name.
def putChecklistName(idChecklist, value)

	hash = Hash.new
	hash[:value] = value if !value.nil?

	response = RestClient.put "https://api.trello.com/1/checklists/"+idChecklist+"/name?key="+$key+"&token="+$token+"&filter=open", hash
	response = JSON.parse(response)
end

# Create a new checklist.
def postChecklist(name, idBoard)

	hash = Hash.new	
	hash[:name] = name
	hash[:idBoard] = idBoard
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.post 'https://api.trello.com/1/checklists', hash
	response = JSON.parse(response)
end

# Add a new item to a checklist.
def postCheckItem(checklistId, name, pos)

	hash = Hash.new	
	hash[:name] = name
	hash[:pos] = pos if !pos.nil?
	hash[:key] = $key
	hash[:token] = $token	

	response = RestClient.post 'https://api.trello.com/1/checklists/'+checklistId+'/checkItems', hash
	response = JSON.parse(response)
end

# Delete a check item.
def deleteChecklistCheckitem(idChecklist, idCheckItem)
	hash = Hash.new
	hash[:key] = $key
	hash[:token] = $token	

	response = RestClient.delete 'https://api.trello.com/1/checklists/'+idChecklist+'/checkItems/'+idCheckItem, hash
	response = JSON.parse(response)
end

# Close a list.
def putCloseList(listId)
	response = RestClient.put('https://api.trello.com/1/lists/'+listId+'/closed',
		:value => true,
		:key =>$key,
		:token =>$token
	)
	response = JSON.parse(response)
end 

# Create a new list.
def postList(listName, idBoard)
	response = RestClient.post(
		'https://api.trello.com/1/lists',
		:name => listName, 
		:idBoard => idBoard,
		:key=>$key,
		:token=>$token
	)
	response = JSON.parse(response)
end 

# Get basic information of a list.
def getList(listId)
	list = RestClient.get("https://api.trello.com/1/lists/"+listId+"?key="+$key+"&token="+$token)
	list = JSON.parse(list)	
end 

# Get a single field of a list.
def getListField(listId, field)
	list = RestClient.get("https://api.trello.com/1/lists/"+listId+"/"+field+"?key="+$key+"&token="+$token)
	list = JSON.parse(list)	
end 

# Get basic information of all cards of a list.
def getCardsByList(listId)
	list = RestClient.get("https://api.trello.com/1/lists/"+listId+"/cards?key="+$key+"&token="+$token+"&filter=open")
	list = JSON.parse(list)
end

# Get all actions of a list.
def getListActions(listId)
	list = RestClient.get("https://api.trello.com/1/lists/"+listId+"/actions?key="+$key+"&token="+$token)
	list = JSON.parse(list)	
end 

# Get board of a list.
def getListBoard(listId)
	list = RestClient.get("https://api.trello.com/1/lists/"+listId+"/board?key="+$key+"&token="+$token)
	list = JSON.parse(list)	
end 

# Get a single field of a board of a list.
def getListBoardField(listId, field)
	list = RestClient.get("https://api.trello.com/1/lists/"+listId+"/board/"+field+"?key="+$key+"&token="+$token)
	list = JSON.parse(list)	
end 

# Change a list.
def putList(listId, name, closed, pos, subscribed)

	hash = Hash.new
	hash[:name] = name if !name.nil?
	hash[:closed] = closed if !closed.nil?
	hash[:pos] = pos if !pos.nil?
	hash[:subscribed] = subscribed if !subscribed.nil?

	response = RestClient.put "https://api.trello.com/1/list/"+listId+"?key="+$key+"&token="+$token+"&filter=open", hash
	response = JSON.parse(response)
end

# Change a list's name.
def putListName(listId, value)

	hash = Hash.new
	hash[:value] = value

	response = RestClient.put "https://api.trello.com/1/list/"+listId+"/name?key="+$key+"&token="+$token+"&filter=open", hash
	response = JSON.parse(response)
end

# Change a list's position.
def putListName(listId, value)

	hash = Hash.new
	hash[:value] = value

	response = RestClient.put "https://api.trello.com/1/list/"+listId+"/pos?key="+$key+"&token="+$token+"&filter=open", hash
	response = JSON.parse(response)
end

# Change a list's subscribed.
def putListName(listId, value)

	hash = Hash.new
	hash[:value] = value

	response = RestClient.put "https://api.trello.com/1/list/"+listId+"/subscribed?key="+$key+"&token="+$token+"&filter=open", hash
	response = JSON.parse(response)
end

# Add a new card to a list.
def postListCards(listId, name, desc)

	hash = Hash.new
	hash[:name] = name
	hash[:desc] = desc if !desc.nil?

	response = RestClient.post "https://api.trello.com/1/list/"+listId+"/cards?key="+$key+"&token="+$token+"&filter=open", hash
	response = JSON.parse(response)
end































# Get basic information of all cards of a board.
def getCardsByBoard(boardId)
	board = RestClient.get("https://api.trello.com/1/boards/"+boardId+"/cards?key="+$key+"&token="+$token+"&filter=open")
	board = JSON.parse(board)
end

# Get all information of all specified cards in detail.
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
		hasChecklist = getCardChecklist(card['id']) 

		if hasChecklist[0] != nil
			arrayChecklists = Array.new
			checkItemStates = card['checkItemStates']
			hasChecklist.each do |checklist|  
				hashChecklist = Hash.new  
				hashChecklist['id'] = checklist['id']
				hashChecklist['name'] = checklist['name']
				arrayItems = Array.new
				checklist['checkItems'].each do |item|
					hashItem = Hash.new
					hashItem['name'] = item['name']
					hashItem['completed'] = false
					checkItemStates.each do |state|
						if state.value?(item['id'])
							hashItem['completed'] = true
						end
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
			attachments = getCardAttachments(card['id'])			
			hashAttachmentsForCard = Hash.new			
			hashAttachmentsForCard['attachments'] = attachments			
			card = card.merge(hashAttachmentsForCard)			

			if downloads
				# download files
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
				# download files
			end       
		end	
		# end export attachments

		# export votes
		if card['badges']['votes'] > 0
			response = RestClient.get(
					'https://api.trello.com/1/cards/'+card['id']+'/membersVoted?key='+$key+'&token='+$token
			)
			members = JSON.parse(response)
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

# Close a board.
def putCloseBoard(boardId)
	response = RestClient.put(
		"https://api.trello.com/1/boards/"+boardId+"/closed",
		"value" => true,
		"key" => $key, 
		"token" => $token
	)
	response = JSON.parse(response)
end





# Get basic information about an organization.
def getOrganization(orgId)
	response = RestClient.get("https://api.trello.com/1/organizations/"+orgId+"?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Get a single field of an organization.
def getOrganizationField(orgId, field)
	response = RestClient.get("https://api.trello.com/1/organizations/"+orgId+"/"+field+"?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Get all actions of an organization.
def getOrganizationActions(orgId)
	response = RestClient.get("https://api.trello.com/1/organizations/"+orgId+"/actions?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Get basic information about all boards of a organization.
def getBoardsByOrganization(orgId)
	boards = RestClient.get("https://api.trello.com/1/organizations/"+orgId+"/boards?key="+$key+"&token="+$token+"&filter=open")
	boards = JSON.parse(boards)
end

# Get all actions of an organization.
def getOrganizationBoardsFilter(orgId, filter)
	response = RestClient.get("https://api.trello.com/1/organizations/"+orgId+"/boards/"+filter+"?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Get all members of an organization.
def getOrganizationMembers(orgId)
	response = RestClient.get("https://api.trello.com/1/organizations/"+orgId+"/members?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Filter a organization's members.
def getOrganizationMembersFilter(orgId, filter)
	response = RestClient.get("https://api.trello.com/1/organizations/"+orgId+"/members/"+filter+"?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Get all card of a member of a organization.
def getOrganizationMembersCards(orgId, memberId)
	response = RestClient.get("https://api.trello.com/1/organizations/"+orgId+"/members/"+memberId+"/cards?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Get all members who are invited to this organization.
def getOrganizationMembersInvited(orgId)
	response = RestClient.get("https://api.trello.com/1/organizations/"+orgId+"/membersInvited?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Get a single field of all members who are invited to this organization.
def getOrganizationMembersInvitedField(orgId, field)
	response = RestClient.get("https://api.trello.com/1/organizations/"+orgId+"/membersInvited/"+field+"?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Change an organization.
def putOrganization(orgId, orgInviteRestrict, externalMembersDisabled, boardVisibilityRestrict_private, prefs_boardVisibilityRestrict_org, boardVisibilityRestrict_public, name, displayName, desc, website, prefs_permissionLevel)

	hash = Hash.new
	hash[:prefs_orgInviteRestrict] = orgInviteRestrict	
	hash[:prefs_externalMembersDisabled] = externalMembersDisabled	
	hash[:prefs_boardVisibilityRestrict_private] = boardVisibilityRestrict_private	
	hash[:prefs_boardVisibilityRestrict_org] = prefs_boardVisibilityRestrict_org	
	hash[:prefs_boardVisibilityRestrict_public] = boardVisibilityRestrict_public	
	hash[:name] = name	
	hash[:displayName] = displayName	
	hash[:desc] = desc	
	hash[:website] = website	
	hash[:prefs_permissionLevel] = prefs_permissionLevel	
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.put "https://api.trello.com/1/organizations/"+orgId, hash 
	response = JSON.parse(response)	
end

# Change an organization's description.
def putOrganizationDesc(orgId, value)

	hash = Hash.new
	hash[:value] = value	
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.put "https://api.trello.com/1/organizations/"+orgId+"/desc", hash 
	response = JSON.parse(response)	
end

# Change an organization's description.
def putOrganizationDisplayName(orgId, value)

	hash = Hash.new
	hash[:value] = value	
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.put "https://api.trello.com/1/organizations/"+orgId+"/displayName", hash 
	response = JSON.parse(response)	
end

# Change an organization's member.
def putOrganizationMembers(orgId, idMember, type)

	hash = Hash.new
	hash[:idMember] = idMember	
	hash[:type] = type	
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.put "https://api.trello.com/1/organizations/"+orgId+"/members/"+idMember, hash 
	response = JSON.parse(response)	
end

# Deactivate an organization's member.
def putOrganizationMembersDeactivated(orgId, idMember, value)

	hash = Hash.new
	hash[:idMember] = idMember	
	hash[:value] = value
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.put "https://api.trello.com/1/organizations/"+orgId+"/members/"+idMember+"deactivated", hash 
	response = JSON.parse(response)	
end

# Change an organization's name.
def putOrganizationName(orgId, value)

	hash = Hash.new
	hash[:value] = value	
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.put "https://api.trello.com/1/organizations/"+orgId+"/name", hash 
	response = JSON.parse(response)	
end

# Change an organization's board visibility.
def putOrganizationRestrictVisOrg(orgId, value)

	hash = Hash.new
	hash[:value] = value	
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.put "https://api.trello.com/1/organizations/"+orgId+"/prefs/boardVisibilityRestrict/org", hash 
	response = JSON.parse(response)	
end

# Change an organization's board visibility.
def putOrganizationRestrictVisPrivate(orgId, value)

	hash = Hash.new
	hash[:value] = value	
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.put "https://api.trello.com/1/organizations/"+orgId+"/prefs/boardVisibilityRestrict/private", hash 
	response = JSON.parse(response)	
end

# Change an organization's board visibility.
def putOrganizationRestrictVisPublic(orgId, value)

	hash = Hash.new
	hash[:value] = value	
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.put "https://api.trello.com/1/organizations/"+orgId+"/prefs/boardVisibilityRestrict/public", hash 
	response = JSON.parse(response)	
end

# Disable an organization's external members.
def putOrganizationExternalMembersDisabled(orgId, value)

	hash = Hash.new
	hash[:value] = value	
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.put "https://api.trello.com/1/organizations/"+orgId+"/prefs/externalMembersDisabled", hash 
	response = JSON.parse(response)	
end

# 
def putOrganizationOrgInviteRestrict(orgId, value)

	hash = Hash.new
	hash[:value] = value	
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.put "https://api.trello.com/1/organizations/"+orgId+"/prefs/orgInviteRestrict", hash 
	response = JSON.parse(response)	
end

# Change an organization's permission level.
def putOrganizationPermissionLevel(orgId, value)

	hash = Hash.new
	hash[:value] = value	
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.put "https://api.trello.com/1/organizations/"+orgId+"/prefs/permissionLevel", hash 
	response = JSON.parse(response)	
end

# Change an organization's website.
def putOrganizationPermissionLevel(orgId, value)

	hash = Hash.new
	hash[:value] = value	
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.put "https://api.trello.com/1/organizations/"+orgId+"/website", hash 
	response = JSON.parse(response)	
end

# Create a new organization.
def postOrganization(name, displayName, desc, website)

	hash = Hash.new
	hash[:name] = name
	hash[:displayName] = displayName
	hash[:desc] = desc
	hash[:website] = website	
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.post "https://api.trello.com/1/organizations/", hash 
	response = JSON.parse(response)	
end

# Invite new members to an organization.
def postOrganizationInvitation(orgId, idMember, email, type)

	hash = Hash.new
	hash[:idMember] = idMember
	hash[:email] = email
	hash[:type] = type
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.post "https://api.trello.com/1/organizations/"+orgId+"/invitations", hash 
	response = JSON.parse(response)	
end

# Response to an invite for an organization.
def postOrganizationInvitationResponse(orgId, response, invitationTokens)

	hash = Hash.new
	hash[:response] = response
	hash[:invitationTokens] = invitationTokens
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.post "https://api.trello.com/1/organizations/"+orgId+"/response", hash 
	response = JSON.parse(response)	
end

# Add a logo to an organization.
def postOrganizationLogo(orgId, file)

	hash = Hash.new
	hash[:file] = file
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.post "https://api.trello.com/1/organizations/"+orgId+"/logo", hash 
	response = JSON.parse(response)	
end

# Delete an organization.
def deleteOrganization(orgId)
	response = RestClient.delete("https://api.trello.com/1/organizations/"+orgId+"?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Delete an organization's invitation.
def deleteOrganizationInvitation(orgId, idInvitation)
	response = RestClient.delete("https://api.trello.com/1/organizations/"+orgId+"/invitations/"+idInvitation+"?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Delete an organization's logo.
def deleteOrganizationILogo(orgId)
	response = RestClient.delete("https://api.trello.com/1/organizations/"+orgId+"/logo?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# 
def deleteOrganizationMember(orgId, idMember)
	response = RestClient.delete("https://api.trello.com/1/organizations/"+orgId+"/member/"+idMember+"?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# 
def deleteOrganizationMembersAll(orgId, idMember)
	response = RestClient.delete("https://api.trello.com/1/organizations/"+orgId+"/member/"+idMember+"/all?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# 
def deleteOrganizationInviteRestrict(orgId, value)

	hash = Hash.new
	hash[:value] = value
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.delete "https://api.trello.com/1/organizations/"+orgId+"/prefs/orgInviteRestrict", hash 
	response = JSON.parse(response)	
end



# Get basic information about a token.
def getToken(token)
	response = RestClient.get("https://api.trello.com/1/tokens/"+token+"?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Get a single field of a token.
def getTokenField(token, field)
	response = RestClient.get("https://api.trello.com/1/tokens/"+token+"/"+field+"?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Get basic information about a member of a token.
def getTokenMember(token)
	response = RestClient.get("https://api.trello.com/1/tokens/"+token+"/member/?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Get a single field of a member of a token.
def getTokenMemberField(token)
	response = RestClient.get("https://api.trello.com/1/tokens/"+token+"/member/"+field+"?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end

# Delete a token.
def deleteToken(token)
	response = RestClient.delete("https://api.trello.com/1/tokens/"+token+"?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end


# Get the type of an id.
def getType(id)
	response = RestClient.get("https://api.trello.com/1/types/"+id+"?key="+$key+"&token="+$token+"&filter=open")
	response = JSON.parse(response)
end









# Create a new board.
def postBoard(name, desc, idOrganization, idBoardSource, keepFromSource, permissionLevel, cardCovers, selfJoin, invitations, comments, voting)

	hash = Hash.new
	hash[:name] = name if !name.nil?
	hash[:desc] = desc if !desc.nil?  
	hash[:idOrganization] = idOrganization if !idOrganization.nil?
	hash[:idBoardSource] = idBoardSource if idBoardSource
	hash[:keepFromSource] = keepFromSource if keepFromSource
	hash[:prefs_permissionLevel] = permissionLevel if !permissionLevel.nil?
	hash[:prefs_selfJoin] = selfJoin if !selfJoin.nil?
	hash[:prefs_cardCovers] = cardCovers if !cardCovers.nil?
	hash[:prefs_invitations] = invitations if !invitations.nil?
	hash[:prefs_voting] = voting if !voting.nil?
	hash[:prefs_comments] = comments if !comments.nil?
	hash[:key] = $key
	hash[:token] = $token

	response = RestClient.post 'https://api.trello.com/1/boards', hash
	response = JSON.parse(response)
end

# Add a checklist to a card.
def postAddChecklistToCard(cardId, checklistId)
	response = RestClient.post(
		'https://api.trello.com/1/cards/'+cardId+'/checklists',
		:value => checklistId,
		:key		=>	$key,
		:token	=>	$token
	)
	response = JSON.parse(response)
end

# Assign a member to a card.
def postMemberAddCard(cardId, member)
	response = RestClient.post(
			'https://api.trello.com/1/cards/'+cardId+'/members',
			:value   => member,
			:key     => $key,
			:token   => $token
	)
	response = JSON.parse(response)
end










### Additional card information

# Get a card action.
def getAction(actionId)
	actions = RestClient.get("https://api.trello.com/1/actions/"+actionId+"/?key="+$key+"&token="+$token)
	actions = JSON.parse(actions)
end

# Get a specific field of an action.
def getActionField(actionId, field)
	actions = RestClient.get("https://api.trello.com/1/actions/"+actionId+"/"+field+"?key="+$key+"&token="+$token)
	actions = JSON.parse(actions)
end

# Get the board of an action.
def getActionBoard(actionId)
	actions = RestClient.get("https://api.trello.com/1/actions/"+actionId+"/board?key="+$key+"&token="+$token)
	actions = JSON.parse(actions)
end

# Get a single field of the board of an action.
def getActionBoardField(actionId, field)
	actions = RestClient.get("https://api.trello.com/1/actions/"+actionId+"/board/"+field+"?key="+$key+"&token="+$token)
	actions = JSON.parse(actions)
end

# Get the list of an action.
def getActionList(actionId)
	actions = RestClient.get("https://api.trello.com/1/actions/"+actionId+"/list?key="+$key+"&token="+$token)
	actions = JSON.parse(actions)
end

# Get a single field of the list of an action.
def getActionListField(actionId, field)
	actions = RestClient.get("https://api.trello.com/1/actions/"+actionId+"/list/"+field+"?key="+$key+"&token="+$token)
	actions = JSON.parse(actions)
end

# Get the card of an action.
def getActionCard(actionId)
	actions = RestClient.get("https://api.trello.com/1/actions/"+actionId+"/card?key="+$key+"&token="+$token)
	actions = JSON.parse(actions)
end

# Get a single field of the card of an action.
def getActionCardField(actionId, field)
	actions = RestClient.get("https://api.trello.com/1/actions/"+actionId+"/card/"+field+"?key="+$key+"&token="+$token)
	actions = JSON.parse(actions)
end

# Get the member of an action.
def getActionMember(actionId)
	actions = RestClient.get("https://api.trello.com/1/actions/"+actionId+"/member?key="+$key+"&token="+$token)
	actions = JSON.parse(actions)
end

# Get a single field of the member of an action.
def getActionMemberField(actionId, field)
	actions = RestClient.get("https://api.trello.com/1/actions/"+actionId+"/member/"+field+"?key="+$key+"&token="+$token)
	actions = JSON.parse(actions)
end

# Get the creator of an action.
def getActionMemberCreator(actionId)
	actions = RestClient.get("https://api.trello.com/1/actions/"+actionId+"/memberCreator?key="+$key+"&token="+$token)
	actions = JSON.parse(actions)
end

# Get a single field of the creator of an action.
def getActionMemberCreatorField(actionId, field)
	actions = RestClient.get("https://api.trello.com/1/actions/"+actionId+"/memberCreator/"+field+"?key="+$key+"&token="+$token)
	actions = JSON.parse(actions)
end

# Get the organization of an action.
def getActionOrganization(actionId)
	actions = RestClient.get("https://api.trello.com/1/actions/"+actionId+"/organization?key="+$key+"&token="+$token)
	actions = JSON.parse(actions)
end

# Get a single field of the organization of an action.
def getActionOrganizationField(actionId, field)
	actions = RestClient.get("https://api.trello.com/1/actions/"+actionId+"/organization/"+field+"?key="+$key+"&token="+$token)
	actions = JSON.parse(actions)
end

# Change the text of an action.
def putActionText(actionId, text)
	response = RestClient.put(
			'https://api.trello.com/1/actions/'+actionId+'/text',
			:value       	=>  text,
			:key        	=>  $key,
			:token   			=>  $token
	)
	response = JSON.parse(response)
end

# Delete an action.
def deleteAction(actionId)
	response = RestClient.delete('https://api.trello.com/1/actions/'+actionId)
	response = JSON.parse(response)
end








# Get all card actions.
def getCardActions(cardId)
	actions = RestClient.get("https://api.trello.com/1/cards/"+cardId+"/actions?key="+$key+"&token="+$token)
	actions = JSON.parse(actions)
end

# Get all comments of a card.
def getCardComments(cardId)
	actions = RestClient.get("https://api.trello.com/1/cards/"+cardId+"/actions?filter=commentCard&key="+$key+"&token="+$token)
	actions = JSON.parse(actions)
end

# Get a card's update date.
def cardUpdated(cardId)
	response = RestClient.get('https://api.trello.com/1/cards/'+cardId+'/actions?filter=updateCard&key='+$key+'&token='+$token)
	updates = JSON.parse(response.body)
end

# Get a card's creation date.
def cardCreated(cardId)
	response = RestClient.get('https://api.trello.com/1/cards/'+cardId+'/actions?filter=createCard&key='+$key+'&token='+$token)

	updates = JSON.parse(response.body)
end

# Check if a checklist item is completed.
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

# Change a check item's status.
def putCheckItemStatus(cardId, checklistId, itemId, status)
	response = RestClient.put(
			'https://api.trello.com/1/cards/'+cardId+'/checklist/'+checklistId+'/checkItem/'+itemId+'/state',
			:idCheckList       	=>  checklistId,
			:idCheckItem				=>  itemId,
			:value							=>	status,
			:key        				=>  $key,
			:token   						=>  $token
	)
	response = JSON.parse(response)
end

# Change a check item's position.
def putCheckItemPos(cardId, checklistId, itemId, pos)
	response = RestClient.put(
			'https://api.trello.com/1/cards/'+cardId+'/checklist/'+checklistId+'/checkItem/'+itemId+'/pos',
			:idCheckList       	=>  checklistId,
			:idCheckItem				=>  itemId,
			:value							=>	pos,
			:key        				=>  $key,
			:token   						=>  $token
	)
	response = JSON.parse(response)
end

# Add a label to a card.
def postLabel(cardId, color)
	response = RestClient.post(
		'https://api.trello.com/1/cards/'+cardId+'/labels',
		:value => color,
		:key =>$key,
		:token =>$token
	)
	response = JSON.parse(response)
end

# Post a comment to a card.
def postComment(cardId, commentText)
	response = RestClient.post(
		'https://api.trello.com/1/cards/'+cardId+'/actions/comments',
		:text => commentText,
		:key =>$key,
		:token =>$token
	)
	response = JSON.parse(response)
end

# Add an attachment to card.
def postAttachments(cardId, file, name)
	response = RestClient.post(
			'https://api.trello.com/1/cards/'+cardId+'/attachments',
			:file       =>  file,
			:name				=>  name,
			:key        =>  $key,
			:token   		=>  $token
	)
	response = JSON.parse(response)
end

# Change the due date of a card.
def putDueDate(cardId, duedate)
	response = RestClient.put(
			'https://api.trello.com/1/cards/'+cardId+'/due',
			:value       =>  duedate,
			:key        =>  $key,
			:token   		=>  $token
	)
	response = JSON.parse(response)
end

# Vote for a card.
def postVoting(cardId, member)
	response = RestClient.post(
			'https://api.trello.com/1/cards/'+cardId+'/membersVoted',
			:value   => member,
			:key     => $key,
			:token   => $token
	)
	response = JSON.parse(response)
end

# Subscribe a card.
def putSubscribe(cardId, value)	
	response = RestClient.put(
			'https://api.trello.com/1/cards/'+cardId+'/subscribed',
			:value   => value,
			:key     => $key,
			:token   => $token
	)
	response = JSON.parse(response)
end



### CMS methods

# Convert several cards to HTML an post it to a Joomla database as a single article.
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

# Post several cards as Joomla articles to a specified section and category in Joomla.
def trelloJoomlaSync(cardId, sectionid, catid, joomlaVersion)

	card = getCard(cardId)
	title = card['name']	
	description = Kramdown::Document.new(card['desc']).to_html

	changed = nil
	if !cardUpdated(cardId).empty?
		changed = getDate(cardUpdated(cardId).first['date'], 'joomla')
	else
		changed = getDate(cardCreated(cardId).first['date'], 'joomla')
	end

	# attachments
	hasAttachment = getCardAttachments(cardId)

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
	hasChecklist = getCardChecklist(cardId) 

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
									sectionid = "+sectionid+",
									catid = "+catid+",
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