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

puts "Member: "+getMember('me')['username']

client = Google::APIClient.new
client.authorization.client_id = '866752766650.apps.googleusercontent.com'
client.authorization.client_secret = 'arLSDNQqkudI-hoI554ZQbj2'
client.authorization.scope = 'https://www.googleapis.com/auth/calendar'
client.authorization.refresh_token = '1/jHMBJZu-Km53p3C09aUSUfBNifFj-LMVfIrRwaG708c'
client.authorization.access_token = 'ya29.AHES6ZRrlyLgXwWGhdYzwl1Wmgwa5DLGJh4ud9aoUMNwnv5q5-2Q5Q'

result = client.authorization.fetch_access_token!
client.authorization.access_token = result['access_token']

service = client.discovered_api('calendar', 'v3')

getevents = client.execute(:api_method => service.events.list,
                        :parameters => {'calendarId' => 'primary', 'q' => '4ffa4c76e75c29032a88ed19'})
                        
                   

while true
  events = getevents.data.items
  
  events.each do |e|
    pp e.summary
  end
    
  if !(page_token = getevents.data.next_page_token)
    break
  end
  getevents = getevents = client.execute(:api_method => service.events.list,
                                   :parameters => {'calendarId' => 'primary', 'pageToken' => page_token})
end