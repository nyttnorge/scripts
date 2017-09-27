#!/usr/bin/env ruby

# Earth radius in km
EARTH_RADIUS = 6371.0

# Distance from Earth to Moon
EARTH_TO_MOON_DISTANCE = 384400

# Orbit total distance
ORBIT_TOTAL_DISTANCE = EARTH_TO_MOON_DISTANCE * Math::PI * 2

# Moon orbital time in hours (period)
MOON_ORBITAL_TIME = 29.53 * 24

# Moon average orbital speed
MOON_ORBITAL_SPEED = ORBIT_TOTAL_DISTANCE / MOON_ORBITAL_TIME

puts "Using moon orbital speed of #{MOON_ORBITAL_SPEED.round(2)} km/h"

# Distance from center
distance = ARGV[0].to_f

while distance > 0
  result = MOON_ORBITAL_SPEED / (Math.sqrt(1 - ((distance / EARTH_RADIUS)**2)))
  puts "#{distance}: #{result.round(12)}"
  distance -= 10
end
