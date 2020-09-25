# frozen_string_literal: true

require 'bundler/setup'
require 'dotenv'
require 'dropbox_api'

def list_dirs(client, path)
  has_more = true
  dirs = []
  results = client.list_folder(path, recursive: true)
  while has_more
    results.entries.each do |i|
      next if i.is_a?(DropboxApi::Metadata::File)

      ih = i.to_hash

      dirs << ih['path_display']
    end

    has_more = results.has_more?
    results = client.list_folder_continue(results.cursor) if has_more
  end
  dirs
end

def empty_dir?(client, path)
  results = client.list_folder(path)
  results.entries.empty?
end

Dotenv.load

client = DropboxApi::Client.new(ENV['TOKEN'])
dirs = list_dirs(client, ARGV[0])

dirs.each do |d|
  if empty_dir?(client, d)
    puts "delete empty dir:#{d}"
    client.delete(d)
  else
    # puts "keep dir:#{d}"
  end
end
