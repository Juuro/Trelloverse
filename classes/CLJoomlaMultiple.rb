#!/usr/bin/env ruby
#Encoding: UTF-8

require 'optparse'
require 'ostruct'
require 'pp'

class CLJoomlaMultiple

  CODES = %w[iso-2022-jp shift_jis euc-jp utf8 binary]
  CODE_ALIASES = { "jis" => "iso-2022-jp", "sjis" => "shift_jis" }

  #
  # Return a structure describing the options.
  #
  def self.parse(args)
    # The options specified on the command line will be collected in *options*.
    # We set default values here.
    options = OpenStruct.new
    options.section = String.new
    options.category = String.new
    options.key = String.new
    options.token = String.new
    options.all = false
    options.encoding = "utf8"

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: joomla_multiple.rb [options]"
      opts.separator "Select the input cards with -c, -l, -b or -a"
      opts.separator ""
      opts.separator "Specific options:"
    
      # All due dates of all cards of all boards.
      opts.on("-a", "--[no-]all", "Set this if all due dates of all cards of all boards this user can see shall be used.") do |all|
        options.all = all
      end
    
      # Trello list(s)
      opts.on("-l x,y,z", "--lists x,y,z", Array, "Ids of one or more Trello lists.") do |lists|
        options.lists = lists
      end

      # Trello organization(s)
      opts.on("-o x,y,z", "--organizations x,y,z", Array, "Ids of one or more Trello organizations.") do |organizations|
        options.organizations = organizations
      end

      # Trello board(s)
      opts.on("-b x,y,z", "--boards x,y,z", Array, "Ids of one or more Trello boards.") do |boards|
        options.boards = boards
      end
      
      # Trello card(s)
      opts.on("-c x,y,z", "--cards x,y,z", Array, "Ids of one or more Trello cards.") do |cards|
        options.cards = cards
      end
      
      # Trello key
      opts.on("-k MANDATORY", "Your Trello key.") do |key|
        options.key = key
      end
      
      # Trello token
      opts.on("-t MANDATORY", "The Trello token.") do |token|
        options.token = token
      end
      
      # Joomla section
      opts.on("--section MANDATORY", "Id of a Joomla section.") do |section|
        options.section = section
      end
      
      # Joomla category
      opts.on("--category MANDATORY", "Id of a Joomla category") do |category|
        options.category = category
      end

    end

    opts.parse!(args)
    options
  end  # parse()

end  # class OptparseExample