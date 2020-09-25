# frozen_string_literal: true

require 'bundler/setup'
require 'dotenv'
require 'dropbox_api'

Dotenv.load

client = DropboxApi::Client.new(ENV['TOKEN'])
results = client.list_folder(ARGV[0])

targets = []
results.entries.each do |i|
  i = i.to_hash
  basename = File.basename(i['path_display'])
  next unless basename =~ /^([0-9]{4})([0-9]{2})([0-9]{2})(.*)/

  targets << {
    path: i['path_display'],
    year: Regexp.last_match[1],
    month: Regexp.last_match[2],
    day: Regexp.last_match[3],
    post_fix: Regexp.last_match[4]
  }
end

targets.each do |i|
  dest = File.dirname(i[:path])
  dest = File.join(dest, "#{i[:year]}.#{i[:month]}",
                   "#{i[:year]}.#{i[:month]}.#{i[:day]}#{i[:post_fix]}")

  puts "move #{i[:path]}\n  to #{dest}"
  client.move(i[:path], dest)
end
