# frozen_string_literal: true

require 'bundler/setup'
require 'dotenv'
require 'dropbox_api'

Dotenv.load

unless ARGV[0]
  puts("usage ruby #{File.basename(__FILE__)} REMOVE_TARGET")
  exit(1)
end
client = DropboxApi::Client.new(ENV['TOKEN'])

puts "remove #{ARGV[0]}"
client.delete(ARGV[0])
puts "deleted #{ARGV[0]}"
