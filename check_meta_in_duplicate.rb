# frozen_string_literal: true

require 'bundler/setup'
require 'dotenv'
require 'dropbox_api'
require 'gdbm'

@db = GDBM.new(File.join(__dir__, 'dbox.dat'))

file_path = ARGV[0]

Dotenv.load

client = DropboxApi::Client.new(ENV['TOKEN'])

def metainfo(client, path)
  client.get_metadata(path, include_media_info: true)
end

@db.each_pair do |k, v|
  v = Marshal.load(v)
  v.sort
  puts(k + "\n")
  v.each do |p|
    puts("  #{p}")
    time_taken =
      metainfo(client, p)&.media_info&.time_taken&.strftime('%Y.%m.%d %H:%M:%s')
    puts("    #{time_taken}")
  end
end
