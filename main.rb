require 'matrix'
require 'krpc'

require './libs/utils/geometric'
require './libs/controller/pid'

require './libs/process/approach'
require './libs/process/land'
require './libs/process/takeoff'
require './libs/process/waypoint'

KRPC.connect do |client|
  vessel = client.space_center.active_vessel

  # VR: 100m/s, Climb at 390 knots to 2000m
  TakeoffProcess.new(vessel, 100, 200, 2000).run
  # Upwind
  WaypointProcess.new(vessel, 200, 2000, 0.0, -70.0).run
  # Crosswind
  WaypointProcess.new(vessel, 200, 2000, -5.0, -70.0).run
  # Downwind
  WaypointProcess.new(vessel, 200, 1500, -5.0, -77.7667).run
  # Base
  WaypointProcess.new(vessel, 170, 1000, -0.04833333, -77.7667).run
  # Final
  WaypointProcess.new(vessel, 120, 1000, -0.04833333, -76).run
  # Approach
  ApproachProcess.new(vessel, 100, 80, -0.04833333, -74.72389).run
  # Land
  LandProcess.new(vessel, -0.05, -74.52389).run
end
