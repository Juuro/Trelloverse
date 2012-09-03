#!/usr/bin/env ruby
#Encoding: UTF-8

require 'optparse'
require 'ostruct'
require 'pp'

class CLHtml

  CODES = %w[iso-2022-jp shift_jis euc-jp utf8 binary]
  CODE_ALIASES = { "jis" => "iso-2022-jp", "sjis" => "shift_jis" }

  #
  # Return a structure describing the options.
  #
  def self.parse(args)
    # The options specified on the command line will be collected in *options*.
    # We set default values here.
    options = OpenStruct.new
    options.title = []
    options.key = []
    options.token = []
    options.all = false
    options.encoding = "utf8"

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: html.rb [options]"
      opts.separator "Select the input cards with -c, -l, -b, -o or -a"
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
      opts.on("-k MANDATORY, --key", "Your Trello key.") do |key|
        options.key << key
      end
      
      # Trello token
      opts.on("-t MANDATORY, --token", "The Trello token.") do |token|
        options.token << token
      end
      
      # Title of the HTML site.
      opts.on("--title MANDATORY", "A title of the HTML site.") do |title|
        options.title << title
      end

    end

    opts.parse!(args)
    options
  end  # parse()

end  # class OptparseExample