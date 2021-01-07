class WaypointProcess
  def initialize(vessel, velocity, height, latitude, longitude)
    @vessel = vessel
    @control = vessel.control

    @velocity = velocity
    @height = height
    @longitude = longitude
    @latitude = latitude

    @throttle_controller = PIDController.new(0.1, 0.01, 0.2)
    @pitch_controller = PIDController.new(0.05, 0.05, 0.1, -1.0, 1.0)
    @roll_controller = PIDController.new(0.0005, 0.01, 0.7, -1.0, 1.0)
  end

  def run
    @control.sas = false
    loop do
      orbit = @vessel.flight(@vessel.orbit.body.reference_frame)
      surface = @vessel.flight(@vessel.surface_reference_frame)
      break if (orbit.latitude - @latitude).abs < 1e-4 and (orbit.longitude - @longitude).abs < 1e-4

      throttle = @throttle_controller.trigger(@velocity, orbit.speed)
      @control.throttle = throttle

      pitch = @pitch_controller.trigger(@height, orbit.mean_altitude)
      if pitch > 0.0 and surface.pitch > 10
        pitch = -0.1
      elsif pitch < 0.0 and surface.pitch < -5
        pitch = 0.1
      end
      @control.pitch = pitch

      delta_phi = Math.log(Math.tan((@latitude / 180 * Math::PI) / 2 + Math::PI / 4) / Math.tan((orbit.latitude / 180 * Math::PI) / 2 + Math::PI / 4))
      delta_lon =  (@longitude - orbit.longitude)  / 180 * Math::PI
      theta = Math.atan2(delta_lon, delta_phi)
      target_heading = theta * 180 / Math::PI

      target_heading = 360 + target_heading if target_heading < 0
      delta_heading = target_heading - surface.heading

      delta_heading = 360 - delta_heading if delta_heading > 180
      delta_heading = delta_heading + 360 if delta_heading < -180

      bank_angle = delta_heading
      bank_angle = 25 if delta_heading > 25
      bank_angle = -25 if delta_heading < -25

      roll = @roll_controller.trigger(bank_angle, surface.roll)
      @control.roll = roll
      current_roll = surface.roll
    end

    puts "Waypoint lat: #{@latitude}, lng: #{@longitude} Reached."
  end
end
