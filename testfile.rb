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

orgas = getOrganizationsByMember('juuro')

