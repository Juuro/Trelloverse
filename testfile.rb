#!/usr/bin/ruby
#Encoding: UTF-8
require 'json'
require 'pp'
require './functions.rb'
require 'rest_client'
require 'time'
require 'google/api_client'

$key = '0ccb4b07c006c5d5555a55b64a124c89'
$token = 'e9fe54ca188979634e2115c4862de38be500cd0d46c95b8a561e693d240268ba'
#$key = '897f1e4573b21a4c8ad8a5cbb4bb3441'
#$token = 'f60eaa453d5eba261d03b8f10508ff21b302f87409f782932fd0d87ca67c4307'

puts "Member: "+getMember('me')['username']


def getFullCards(arrayCardsStd, downloads = true)
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
      checkItemStates = card['checkItemStates']
      hasChecklist.each do |checklist|  
        hashChecklist = Hash.new  
        hashChecklist['id'] = checklist['id']
        hashChecklist['name'] = checklist['name']
        arrayItems = Array.new
        checklist['checkItems'].each do |item|
          hashItem = Hash.new
          hashItem['name'] = item['name']
          
          
          if checkItemStates.first.value?(item['id'])
            hashItem['completed'] = true
          else
            hashItem['completed'] = false
          end
=begin          
          if isCompleted(card['id'], item['id'])
            hashItem['completed'] = true
          else
            hashItem['completed'] = false
          end
=end          
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



arrayCardsStd = getCardsByList('4ffd78ff7f0c71780cc5aa1c')


#pp getFullCards(arrayCardsStd, downloads = false)

#=begin
arrayCardsStd.each do |card|
  
  checkItemStates = card['checkItemStates']
  
  checklists = getChecklist(card['id'])
  
  checklists.each do |checklist|
    checkItems = checklist['checkItems']
    
    checkItems.each do |item|
      checkItemStates.each do |state|
        if state.value?(item['id'])
          puts item['id']+" is complete!"
        else 
          puts item['id']+" is not complete!"
        end
      end
    end
  end
  
end
#=end




