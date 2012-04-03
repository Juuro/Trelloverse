#!/usr/bin/ruby1.9 -rubygems -w

require 'json'
require 'open-uri'
require 'pp'
require './functions.rb'


#website aufrufen
list = open("https://api.trello.com/1/boards/4f68a4ab343ec61a754ad64e/lists?key=0ccb4b07c006c5d5555a55b64a124c89&token=e9fe54ca188979634e2115c4862de38be500cd0d46c95b8a561e693d240268ba&filter=open").read

#JSON in Ruby-Object umwandeln
data = JSON.parse(list)

#=begin

fileHtml = File.new("index.html.tmp", "w+")
fileHtml.puts "<!DOCTYPE HTML>"

time = Time.now

fileHtml.puts "<!-- "+time.hour.to_s+":"+time.min.to_s+" "+time.day.to_s+"."+time.month.to_s+"."+time.year.to_s+" -->"

fileHtml.puts "<html>"
fileHtml.puts "<head>"
fileHtml.puts "\t<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />"
fileHtml.puts "\t<title>Trello List "+data[0]['name']+"</title>"
fileHtml.puts "\t<link rel=\"stylesheet\" type=\"text/css\" media=\"screen\" href=\"bootstrap.css\">"
fileHtml.puts "\t<link rel=\"stylesheet\" type=\"text/css\" media=\"screen\" href=\"style.css\">"
fileHtml.puts "<link rel=\"stylesheet\" href=\"js/fancybox/jquery.fancybox-1.3.4.css\" type=\"text/css\" media=\"screen\" />"
fileHtml.puts "</head>"
fileHtml.puts "<body>\n\n"


fileHtml.puts "<div class=\"navbar navbar-fixed-top\">"
fileHtml.puts "\t<div class=\"navbar-inner\">"
fileHtml.puts "\t\t<div class=\"container\">"
fileHtml.puts "\t\t\t<a class=\"btn btn-navbar\" data-toggle=\"collapse\" data-target=\".nav-collapse\">"
fileHtml.puts "\t\t\t\t<span class=\"icon-bar\"></span>"
fileHtml.puts "\t\t\t\t<span class=\"icon-bar\"></span>"
fileHtml.puts "\t\t\t\t<span class=\"icon-bar\"></span>"
fileHtml.puts "\t\t\t</a>"
fileHtml.puts "\t\t\t<a class=\"brand\" href=\"#\">Trello</a>"
fileHtml.puts "\t\t\t<div class=\"nav-collapse\">"
fileHtml.puts "\t\t\t\t<ul class=\"nav\">"
fileHtml.puts "\t\t\t\t\t<li class=\"active\"><a href=\"#\">"+data[0]['name']+"</a></li>"
fileHtml.puts "\t\t\t\t\t<li class=\"\"><a href=\"#\">Test 1</a></li>"
fileHtml.puts "\t\t\t\t\t<li class=\"\"><a href=\"#\">Test 2</a></li>"
fileHtml.puts "\t\t\t\t</ul>"
fileHtml.puts "\t\t\t</div>"
fileHtml.puts "\t\t</div>"
fileHtml.puts "\t</div>"
fileHtml.puts "</div>"


fileHtml.puts "<div class=\"container\">"

fileHtml.puts "\t\t<header class=\"jumbotron subhead\" id=\"overview\">"
fileHtml.puts "\t\t\t<h1>"+data[0]['name']+"</h1>"
fileHtml.puts "\t\t\t<p class=\"lead\"></p>"
fileHtml.puts "\t\t</header>"

fileHtml.puts "\t\t<div class=\"row\">"
for element in data[0]['cards'] do  
  fileHtml.puts "\t\t\t<div class=\"span12 well\">"
  
  #members
  hasMembers = element['idMembers']
  for memberId in hasMembers do
    member = getMember(memberId)
    fileHtml.puts "\t\t\t\t<a href=\""+member['url']+"\" title=\""+member['fullName']+"\" rel=\"tooltip\">"
    if member['avatarHash']
      fileHtml.puts "\t\t\t\t\t<img src=\"https://trello-avatars.s3.amazonaws.com/"+member['avatarHash']+"/30.png\" class=\"members\" alt=\""+member['fullName']+"\">"
    else
      fileHtml.puts "\t\t\t\t\t<img src=\"img/noavatar.png\" class=\"members\" alt=\""+member['fullName']+"\">"
    end
    fileHtml.puts "\t\t\t\t</a>"
  end
  #members 
  
  fileHtml.puts "\t\t\t\t<h2>"+element['name']
  #due date
  if element['due']
    fileHtml.puts "\t\t\t\t\t<small>"+element['due']+"</small>"
  end
  #end due date

  card = getSingleCard(element['id'])
  badges = card['badges']
  #votes
  if badges['votes'] != 0
    fileHtml.puts "\t\t\t\t\t<small>"+badges['votes'].to_s+"</small>"
  end
  #end votes
  #labels
  labels = card['labels']
  if labels
    for label in labels do
      fileHtml.puts "\t\t\t\t\t<small><span class=\"badge "+label['color']+"\"></span></small>"
    end
  end
  #end labels
  #comments
  if badges['comments'] != 0
    fileHtml.puts "\t\t\t\t\t<span class=\"label\">"+badges['comments'].to_s+" <img src=\"img/comment-icon.png\"></span>"
  end
  #end comments
  fileHtml.puts "\t\t\t\t</h2>"
  
  #description
  fileHtml.puts "\t\t\t\t<p class=\"article\">"+element['desc']+"</p>\n\n"
  
  #checklist
  hasChecklist = getChecklist(element['id'])  
  if hasChecklist[0] != nil
    for checklist in hasChecklist do
      fileHtml.puts "\t\t\t\t<h3>"+checklist['name']+"</h3>"
      fileHtml.puts "\t\t\t\t<ul>"
      for item in checklist['checkitems']
        if isCompleted(element['id'], item['id'])
          fileHtml.puts "\t\t\t\t\t<li><del>"+item['name']+"</del></li>"
        else
          fileHtml.puts "\t\t\t\t\t<li>"+item['name']+"</li>"
        end
      end
      fileHtml.puts "\t\t\t\t</ul>"
    end
  end
  #end checklist
  
  #attachment
  hasAttachment = getAttachment(element['id']) 
  photos = Hash.new 
  if hasAttachment[0] != nil
    c = 0
    fileHtml.puts "\t\t\t\t<h3>Attachments</h3>"
    for attachment in hasAttachment do
      url = attachment['url']
      fileHtml.puts "\t\t\t\t<ul>"
      if url.end_with?('JPEG') || url.end_with?('jpeg') || url.end_with?('JPG') || url.end_with?('jpg') || url.end_with?('PNG') || url.end_with?('png')  || url.end_with?('GIF') || url.end_with?('gif') || url.end_with?('TIFF')|| url.end_with?('tiff') || url.end_with?('PSD') || url.end_with?('psd')
        
        attHash = Hash.new
        attHash['url'] = url
        attHash['name'] = attachment['name']
        
        photos[c] = attHash      
      else
        fileHtml.puts "\t\t\t\t\t<li><a href=\""+attachment['url']+"\">"+attachment['name']+"</a></li>"      
      end
      fileHtml.puts "\t\t\t\t</ul>"
      c += 1
    end
    
    if !photos.empty?      
      fileHtml.puts "\t\t\t\t<h3>Photos</h3>"
      fileHtml.puts "\t\t\t\t<ul class=\"pic-list thumbnails\">"
      i = 0
      while i < photos.length do        
        fileHtml.puts "\t\t\t\t\t<li class=\"span2\"><a href=\""+photos[i]['url']+"\" class=\"thumbnail grouped_elements\" rel=\""+element['id']+"\"><img src=\""+photos[i]['url']+"\" alt=\""+photos[i]['name']+"\" title=\""+photos[i]['name']+"\"></a></li>"
        i += 1
      end
      fileHtml.puts "\t\t\t\t</ul>"
    end
  end
  photos = nil
  #end attachment
  
  #comments
  actions = getCardActions(element['id'])
  
  if !actions.empty?
    fileHtml.puts "\t\t\t\t<h3>Comments</h3>"
    fileHtml.puts "\t\t\t\t<div class=\"comments\">"
    
    actions.each do|n|
      if n['type'] == 'commentCard'
        member = getMember(n['idMemberCreator'])
        fileHtml.puts "\t\t\t\t\t<h4>"+member['fullName']+" "    
        fileHtml.puts "\t\t\t\t<a href=\""+member['url']+"\" title=\""+member['fullName']+"\" rel=\"tooltip\">"
        if member['avatarHash']
          fileHtml.puts "\t\t\t\t\t<img src=\"https://trello-avatars.s3.amazonaws.com/"+member['avatarHash']+"/30.png\" class=\"members\" alt=\""+member['fullName']+"\">"
        else
          fileHtml.puts "\t\t\t\t\t<img src=\"img/noavatar.png\" class=\"members\" alt=\""+member['fullName']+"\">"
        end
        fileHtml.puts "\t\t\t\t</a>"
        fileHtml.puts "\t\t\t\t\t</h4>"
        
        fileHtml.puts "\t\t\t\t\t<p>"+n['data']['text']+"</p>"
      end
    end
    fileHtml.puts "\t\t\t\t</div>"
  end	
  #end comments
  
  fileHtml.puts "\t\t\t</div>"
end
fileHtml.puts "\t</div>"

fileHtml.puts "\t<hr>"
fileHtml.puts "\t<footer>"
fileHtml.puts "\t\t<p>&copy; Company 2012</p>"
fileHtml.puts "\t</footer>"

fileHtml.puts "</div>"


fileHtml.puts "<script type=\"text/javascript\" src=\"http://platform.twitter.com/widgets.js\"></script>"
fileHtml.puts "<script src=\"js/jquery.js\"></script>"
fileHtml.puts "<script src=\"js/bootstrap-tooltip.js\"></script>"
fileHtml.puts "<script src=\"js/application.js\"></script>"
fileHtml.puts "<script type=\"text/javascript\" src=\"js/fancybox/jquery.fancybox-1.3.4.pack.js\"></script>"
fileHtml.puts "<script type=\"text/javascript\" src=\"js/fancybox/jquery.easing-1.3.pack.js\"></script>"

fileHtml.puts "</body>"
fileHtml.puts "</html>"
fileHtml.close()

File.rename("index.html.tmp", "index.html")

#=end