#!/usr/bin/env ruby

x = ARGV[0].to_i

x = x.to_f

v = 3411.0
r = 6371.0

while x > 0
  result = v / (Math.sqrt(1 - ((x / r)**2)))
  puts "#{x}: #{result.round(12)}"
  x -= 10
end
