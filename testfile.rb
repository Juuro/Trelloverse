#!/usr/bin/env ruby
#Encoding: UTF-8

require 'optparse'

require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'pp'

class JoomlaMultiple

  CODES = %w[iso-2022-jp shift_jis euc-jp utf8 binary]
  CODE_ALIASES = { "jis" => "iso-2022-jp", "sjis" => "shift_jis" }

  #
  # Return a structure describing the options.
  #
  def self.parse(args)
    # The options specified on the command line will be collected in *options*.
    # We set default values here.
    options = OpenStruct.new
    options.section = []
    options.category = []
    options.encoding = "utf8"

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: example.rb [options]"

      opts.separator ""
      opts.separator "Specific options:"
    
      # Trello list(s)
      opts.on("-l", "--list x,y,z", Array, "Ids of one or more Trello lists.") do |list|
        options.list = list
      end

      # Trello board(s)
      opts.on("-b", "--board x,y,z", Array, "Ids of one or more Trello boards.") do |board|
        options.board = board
      end
      
      # Trello card(s)
      opts.on("-c", "--card x,y,z", Array, "Ids of one or more Trello cards.") do |card|
        options.card = card
      end
      
      # Joomla section
      opts.on("--section MANDATORY", 
              "Id of a Joomla section.") do |section|
        options.section << section
      end
      
      # Joomla category
      opts.on("--category MANDATORY", 
              "Id of a Joomla category") do |category|
        options.category << category
      end

    end

    opts.parse!(args)
    options
  end  # parse()

end  # class OptparseExample

options = JoomlaMultiple.parse(ARGV)
pp options