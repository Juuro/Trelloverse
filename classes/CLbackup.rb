#!/usr/bin/env ruby
#Encoding: UTF-8

require 'optparse'
require 'ostruct'
require 'pp'

class CLbackup

  CODES = %w[iso-2022-jp shift_jis euc-jp utf8 binary]
  CODE_ALIASES = { "jis" => "iso-2022-jp", "sjis" => "shift_jis" }

  #
  # Return a structure describing the options.
  #
  def self.parse(args)
    # The options specified on the command line will be collected in *options*.
    # We set default values here.
    options = OpenStruct.new
    options.key = String.new
    options.token = String.new
    options.name = String.new
    options.all = false
    options.encoding = "utf8"
    
    opts = OptionParser.new do |opts|
      opts.banner = "Usage: export.rb [options]"
    
      opts.separator ""
      opts.separator "Specific options:"
      
      # Filename
      opts.on("-n MANDATORY, --name", "The filename of the backup file.") do |name|
        options.name = name
      end

      # Trello key
      opts.on("-k MANDATORY, --key", "Your Trello key.") do |key|
        options.key = key
      end
      
      # Trello token
      opts.on("-t MANDATORY, --token", "The Trello token.") do |token|
        options.token = token
      end

    end

    opts.parse!(args)
    options
  end  # parse()

end  # class OptparseExample