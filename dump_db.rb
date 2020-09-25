# frozen_string_literal: true

require 'gdbm'

@db = GDBM.new(File.join(__dir__, 'dbox.dat'))

puts('----------- DB DUMP START --------------')
puts("DB size: #{@db.size}")

@db.each_pair do |k, v|
  v = Marshal.load(v)
  v.sort
  puts(k + "\n  " +
               v.join("\n  "))
end
puts("DB size: #{@db.size}")
puts('----------- DB DUMP END --------------')
