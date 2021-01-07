require 'matrix'
require 'krpc'

require './libs/controller/pid'
require './libs/process/takeoff'
require './libs/process/waypoint'

KRPC.connect do |client|
  vessel = client.space_center.active_vessel

  # VR: 100m/s, Climb at 390 knots to 2000m
  TakeoffProcess.new(vessel, 100, 200, 2000).run
  # Fly to North pole (N90, S0.0) at 330 knots at FL300
  WaypointProcess.new(vessel, 170, 7000, 90.0, 0.0).run
end
