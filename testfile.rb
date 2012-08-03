#!/usr/bin/ruby
#Encoding: UTF-8
require 'open-uri'
require 'json'
require 'pp'
require './functions.rb'

$key = '0ccb4b07c006c5d5555a55b64a124c89'
$token = 'e9fe54ca188979634e2115c4862de38be500cd0d46c95b8a561e693d240268ba'

puts "Member: "+getMember('me')['username']


member = open("https://api.trello.com/1/members/juuro?key="+$key+"&token="+$token+"&filter=open&fields=email").read
member = JSON.parse(member)

pp member