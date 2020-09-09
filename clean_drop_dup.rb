# frozen_string_literal: true

require 'bundler/setup'
require 'dotenv'
require 'dropbox_api'
require 'gdbm'
require 'logger'

# remove duplicated files for dropbox
class CleanDropDup
  def initialize(token)
    file = File.open(File.join(__dir__, 'log',
                               File.basename(__FILE__, '.*') +
                               Time.now.strftime('-%Y%m%d') +
                               '.log'),
                     File::WRONLY | File::APPEND | File::CREAT)
    @logger = Logger.new(file)
    @token = token
  end

  def clean(path)
    @logger.info('----------- clean up start -----------')
    @db = GDBM.new(File.join(__dir__, 'dbox.dat'))
    @client = DropboxApi::Client.new(@token)
    list_files(path)

    # delete single record
    @db.delete_if do |_key, val|
      val = Marshal.load(val)
      val.size <= 1
    end

    delete_duplicated
    dump_db
    @logger.info('----------- clean up end -----------')
  ensure
    @db&.close
  end

  private

  def list_files(path)
    has_more = true
    results = @client.list_folder(path, recursive: true)
    while has_more
      results.entries.each do |i|
        next unless i.is_a?(DropboxApi::Metadata::File)

        ih = i.to_hash

        val = @db[ih['content_hash']]
        val = if val
                Marshal.load(val)
              else
                []
              end
        val << ih['path_display'] unless val.include?(ih['path_display'])
        @db[ih['content_hash']] = Marshal.dump(val)
      end

      has_more = results.has_more?
      results = @client.list_folder_continue(results.cursor) if has_more
    end
  end

  def delete_duplicated
    deleted_keys = []
    @db.each_pair do |k, v|
      v = Marshal.load(v)
      v.sort
      same_dir = true
      dir = File.dirname(v[0])
      del_targets = v[1...(v.size)]
      del_targets.each do |dv|
        unless dir == File.dirname(dv)
          same_dir = false
          break
        end
      end

      unless same_dir
        @logger.info("skip clenup due do different directory\n  " +
                     v.join("\n  "))
        next
      end

      msg =
        "remove duplicated file\n" \
        "  target key: #{k}\n" \
        "  keep: #{v[0]}\n"

      del_targets.each do |dv|
        msg += "  del : #{dv}\n"
      end

      @logger.info(msg)

      del_targets.each do |dv|
        @client.delete(dv)
        @logger.info("deleted: #{dv}")
      end
      deleted_keys << k
    end

    deleted_keys.each do |k|
      @db.delete(k)
    end
  end

  def dump_db
    @logger.info('----------- DB DUMP START --------------')
    @logger.info("DB size: #{@db.size}")

    @db.each_pair do |k, v|
      v = Marshal.load(v)
      v.sort
      @logger.info(k + "\n  " +
                   v.join("\n  "))
    end
    @logger.info('----------- DB DUMP END --------------')
  end
end

def usage
  puts 'usage:'
  puts "  ruby #{__FILE__} target_path"
end

if !ARGV[0] || ARGV[0].empty?
  usage
  exit 1
end

Dotenv.load

cleaner = CleanDropDup.new(ENV['TOKEN'])

cleaner.clean(ARGV[0])
