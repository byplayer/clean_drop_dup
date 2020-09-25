# frozen_string_literal: true

require 'bundler/setup'
require 'dotenv'
require 'dropbox_api'

file_path = ARGV[0]

Dotenv.load

client = DropboxApi::Client.new(ENV['TOKEN'])

begin
  info = client.get_metadata(file_path,
                             include_media_info: true)
  puts info.inspect
rescue DropboxApi::Errors::NotFoundError => _e
  puts "Not found: #{file_path}"
end
