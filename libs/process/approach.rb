class ApproachProcess
  def initialize(vessel, velocity, height, latitude, longitude)
    @vessel = vessel
    @control = vessel.control

    @velocity = velocity
    @height = height
    @longitude = longitude
    @latitude = latitude

    @throttle_controller = PIDController.new(0.1, 0.01, 0.2)
    @pitch_controller = PIDController.new(0.05, -0.1, 0.1, -1.0, 1.0)
    @roll_controller = PIDController.new(0.0005, 0.01, 0.007, -1.0, 1.0)
  end

  def run
    @control.sas = false
    loop do
      orbit = @vessel.flight(@vessel.orbit.body.reference_frame)
      surface = @vessel.flight(@vessel.surface_reference_frame)
      break if orbit.mean_altitude < @height

      throttle = @throttle_controller.trigger(@velocity, orbit.speed)
      @control.throttle = throttle

      distance = Geometric.distance(orbit.latitude, orbit.longitude, @latitude, @longitude)
      target_height = Math.tan(3.0 * Math::PI / 180.0) * distance + @height

      pitch = @pitch_controller.trigger(target_height, orbit.mean_altitude)
      if pitch > 0.0 and surface.pitch > 10
        pitch = -0.1
      elsif pitch < 0.0 and surface.pitch < -5
        pitch = 0.1
      end
      @control.pitch = pitch

      target_heading = Geometric.target_heading(orbit.latitude, orbit.longitude, @latitude, @longitude)
      delta_heading = Geometric.delta_heading(surface.heading, target_heading)

      bank_angle = delta_heading
      bank_angle = 25 if delta_heading > 25
      bank_angle = -25 if delta_heading < -25

      roll = @roll_controller.trigger(bank_angle, surface.roll)
      @control.roll = roll

      if orbit.mean_altitude + @height < 500
        @control.brakes = true
        @control.gear = true
      end
      sleep 0.01
    end
  end
end
