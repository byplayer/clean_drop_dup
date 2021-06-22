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
  keep_path = []
  remove_path = []
  taken_date = nil
  v.each do |p|
    puts("  #{p}")
    taken_date =
      metainfo(client, p)&.media_info&.time_taken&.strftime('%Y.%m.%d')

    if taken_date.nil?
      puts 'skip it due to no time_taken'
      next
    end

    # puts("    taken_date: #{taken_date}")

    dir_date = File.basename(File.dirname(p))
    if dir_date == taken_date
      keep_path << p
    else
      remove_path << p
    end
  end

  next if keep_path.empty?

  keep_path.each do |p|
    puts("    keep:#{p}")
  end

  remove_path.each do |p|
    puts("    remove:#{p}")
    client.delete(p)
    puts("    deleted:#{p}")
  end
end
