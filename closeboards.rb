#!/usr/bin/env ruby
#Encoding: UTF-8

require './functions.rb'

$key = '897f1e4573b21a4c8ad8a5cbb4bb3441'
$token = 'f60eaa453d5eba261d03b8f10508ff21b302f87409f782932fd0d87ca67c4307'

puts "Member: "+getMember('me')['username']

boards = getBoardsByMember('me')

boards.each do |board|	
	begin
		putCloseBoard(board['id'])
	rescue => e
		puts e.response
	else
		puts "Board "+board['name']+" ("+board['id']+") closed!"
	end
	
end

orgas = getOrganizationsByMember('me')

orgas.each do |orga|	
	begin
		deleteOrganization(orga['id'])
	rescue => e
		puts e.response
	else
		puts "Organization "+orga['name']+" ("+orga['id']+") deleted!"
	end
	
end

puts 'Done!'