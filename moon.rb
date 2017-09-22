#!/usr/bin/env ruby

require 'time'

# Location, latitude, longitude, time, difference in minutes

eclipse = [
  ['Newport', 44.8, -124.0, '17:16:58', 0],
  ['Madras', 44.7, -121.1, '17:20:41', 232],
  ['Weiser', 44.4, -117.0, '17:26:21', 328],
  ['Idaho Falls', 43.8, -111.9, '17:34:14', 417],
  ['Riverton', 43.2, -108.2, '17:40:24', 301],
  ['Casper', 42.8, -106.3, '17:43:51', 161],
  ['Stapleton', 41.5, -100.5, '17:55:21', 507],
  ['St Joseph', 39.8, -94.9, '18:07:45', 512],
  ['Columbia', 38.8, -92.3, '18:13:57', 247],
  ['Carbondale', 37.6, -89.1, '18:21:56', 313],
  ['Hopkinsville', 36.9, -87.5, '18:26:03', 161],
  ['Anderson', 34.6, -82.6, '18:39:12', 511],
  ['Columbia', 33.9, -81.1, '18:43:10', 156],
  ['McClellanville', 33.1, -79.5, '18:47:30', 172]
]

# Rotation speed at equator
EQUATOR_ROTATION_SPEED = 40030.0/24

distance = 0
tmp = []
speeds = Hash.new{|h, k| h[k] = []}

# Calculate speeds
eclipse.each_with_index do |data, i|
  next if i == 0

  loc0, lat0, long0, t0, km0 = eclipse[i - 1]
  loc1, lat1, long1, t1, km1 = data

  distance += km1

  p0 = Time.parse(t0)
  p1 = Time.parse(t1)
  s = p1 - p0

  h = s.to_f / 3600
  v = (km1.to_f / h)
  speeds[:surface] << v

  # Convert to radians
  lat1_rad = lat1 * Math::PI / 180

  # Find rotation speed at this latitude
  r = Math.cos(lat1_rad) * EQUATOR_ROTATION_SPEED
  speeds[:rotation] << r

  # Find surface speed
  m = v + r
  speeds[:moon] << m

  tmp << "#{loc0} to #{loc1} [#{lat1}, #{long1}]\n  - #{h.round(2)} hours in #{km1} km at #{(km1/h).round(2)} km/h\n  - #{v.round(2)} km/h surface speed\n  - #{r.round(2)} km/h rotation speed\n  - #{m.round(2)} km/h moon speed\n\n"
end

# Totals
first = Time.parse(eclipse[0][-2])
last = Time.parse(eclipse[-1][-2])
ttime = (last - first) / 3600.0
average = distance.to_f / ttime

puts
tmp.each do |r|
  puts r
end

puts "Total distance #{distance} km in #{ttime.round(2)} hours at #{average.round(2)} km/h"
[:surface, :rotation, :moon].each do |r|
  speed = (speeds[r].inject(:+) / speeds[r].size)
  puts " - #{r.capitalize} average speed #{speed.round(2)} km/h"
end
puts
