#!/usr/bin/env ruby
#Encoding: UTF-8

require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'pp'

class CLimport

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
    options.encoding = "utf8"

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: example.rb [options]"

      opts.separator ""
      opts.separator "Specific options:"

      
      # Trello key
      opts.on("-k MANDATORY, --key", "Your Trello key.") do |key|
        options.key << key
      end
      
      # Trello token
      opts.on("-t MANDATORY, --token", "The Trello token.") do |token|
        options.token << token
      end

    end

    opts.parse!(args)
    options
  end  # parse()

end  # class OptparseExample