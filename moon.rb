#!/usr/bin/env ruby

require 'time'

# Location, latitude, longitude, time, difference in minutes, time zone
eclipse = [
  ['Newport', 44.8, -124.0, '17:16:58', 0, -8],
  ['Madras', 44.7, -121.1, '17:20:41', 232, -8],
  ['Weiser', 44.4, -117.0, '17:26:21', 328, -7],
  ['Idaho Falls', 43.8, -111.9, '17:34:14', 417, -7],
  ['Riverton', 43.2, -108.2, '17:40:24', 301, -7],
  ['Casper', 42.8, -106.3, '17:43:51', 161, -7],
  ['Stapleton', 41.5, -100.5, '17:55:21', 507, -6],
  ['St Joseph', 39.8, -94.9, '18:07:45', 512, -6],
  ['Columbia', 38.8, -92.3, '18:13:57', 247, -6],
  ['Carbondale', 37.6, -89.1, '18:21:56', 313, -6],
  ['Hopkinsville', 36.9, -87.5, '18:26:03', 161, -6],
  ['Anderson', 34.6, -82.6, '18:39:12', 511, -5],
  ['Columbia', 33.9, -81.1, '18:43:10', 156, -5],
  ['McClellanville', 33.1, -79.5, '18:47:30', 172, -5]
]

# Earth radius
EARTH_RADIUS = 6371.0

# Earth circumference
EARTH_CIRCUMFERENCE = EARTH_RADIUS * 2 * Math::PI

# Rotation speed at equator
EQUATOR_ROTATION_SPEED = EARTH_CIRCUMFERENCE / 24

# Offset distance from top of curvature on sphere
CURVATURE_OFFSET = 2500

# Time format
TIME_FORMAT = "%H:%M:%S %d/%m/%y"

# Variables
distance = 0
tmp = []
speeds = Hash.new{|h, k| h[k] = []}

# Calculate speeds
eclipse.each_with_index do |data, i|

  # Skip the first one as it has no distance data
  next if i == 0

  # Extract data
  loc0, lat0, long0, t0, km0, tz0 = eclipse[i - 1]
  loc1, lat1, long1, t1, km1, tz1 = data

  # Counting distance
  distance += km1

  # Parse time to UTC
  p0 = Time.parse(t0 + ' -00:00')
  p1 = Time.parse(t1 + ' -00:00')
  s = p1 - p0

  # Apply time zone
  l0 = p0.getlocal(tz0 * 3600)
  l1 = p1.getlocal(tz1 * 3600)

  # Find shadow surface speed
  h = s.to_f / 3600
  v = (km1.to_f / h)
  speeds[:surface] << v

  # Convert to radians
  lat1_rad = lat1 * Math::PI / 180

  # Find rotation speed at this latitude
  r = Math.cos(lat1_rad) * EQUATOR_ROTATION_SPEED
  speeds[:rotation] << r

  # Moon surface speed is shadow speed plus rotation
  m = v + r
  speeds[:moon_surface] << m

  # Moon real speed is the speed over the diameter line
  x = distance - CURVATURE_OFFSET

  # Make sure x is a positive number
  x = x * -1 if x < 0

  # Circumference at this latitude
  latitude_circumference = EARTH_RADIUS * Math.cos(lat1_rad)

  # Convert surface speed to speed over Earth diameter (real speed)
  q = m * (Math.sqrt(1 - ((x / latitude_circumference)**2)))
  speeds[:moon_real] << q

  tmp << [
    "#{loc0} to #{loc1} [#{lat1}, #{long1}]",
    "  - #{p1.strftime(TIME_FORMAT)} GMT, #{l1.strftime(TIME_FORMAT)} local (#{tz1})",
    "  - #{h.round(2)} hours in #{km1} km at #{(km1/h).round(2)} km/h",
    "  - #{v.round(2)} km/h surface speed",
    "  - #{r.round(2)} km/h rotation speed",
    "  - #{m.round(2)} km/h moon surface speed",
    "  - #{q.round(2)} km/h moon real speed\n\n"
  ].join("\n")
end

# Totals
first = Time.parse(eclipse[0][-3])
last = Time.parse(eclipse[-1][-3])
ttime = (last - first) / 3600.0
average = distance.to_f / ttime

puts
tmp.each do |r|
  puts r
end

puts "Total distance #{distance} km in #{ttime.round(2)} hours at #{average.round(2)} km/h"
[:surface, :rotation, :moon_surface, :moon_real].each do |r|
  speed = (speeds[r].inject(:+) / speeds[r].size)
  puts " - #{r.to_s.gsub('_', ' ').capitalize} average speed #{speed.round(2)} km/h"
end
puts
