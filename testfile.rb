#!/usr/bin/ruby
#Encoding: UTF-8
require 'json'
require 'pp'
require './functions.rb'
require 'rest_client'
require 'time'
require 'google/api_client'

#$key = '0ccb4b07c006c5d5555a55b64a124c89'
#$token = 'e9fe54ca188979634e2115c4862de38be500cd0d46c95b8a561e693d240268ba'
$key = '897f1e4573b21a4c8ad8a5cbb4bb3441'
$token = 'f60eaa453d5eba261d03b8f10508ff21b302f87409f782932fd0d87ca67c4307'


begin
  response = postMemberInviteBoard('4f615b946dfee5254c33ceb9','juurotest')
  
rescue => e
  puts "\t"+e.response
else 
  puts response
end