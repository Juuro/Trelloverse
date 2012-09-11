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

id = '4f68ba5868134a30414b8709'

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


begin
  #postBoard('Käsee', nil, 'studium1', 'private', 'true', 'members', 'members', 'members')
  postBoard('Dingens', 'Enten auf Urlaub!', nil, nil, nil, nil, nil, nil, nil, nil, nil)
rescue => e
  puts e
else

end

#putBoard('504e8e6d0f2f4b913835876b', 'Brote', 'Gmias', nil, false, nil, nil, false, false, nil, 'public', nil)