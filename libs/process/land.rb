class LandProcess
  def initialize(vessel, latitude, longitude)
    @vessel = vessel
    @control = vessel.control

    @longitude = longitude
    @latitude = latitude

    @yaw_controller = PIDController.new(0.6, 0.2, 0.0, -1.0, 1.0)
    @pitch_controller = PIDController.new(0.05, -0.1, 0.1, -1.0, 1.0)
  end

  def run
    puts "Retard."
    @control.sas = false
    @control.throttle = 0.0
    @control.brakes = true
    loop do
      orbit = @vessel.flight(@vessel.orbit.body.reference_frame)
      surface = @vessel.flight(@vessel.surface_reference_frame)
      break if orbit.speed < 0.1
      target_heading = Geometric.target_heading(orbit.latitude, orbit.longitude, @latitude, @longitude)
      delta_heading = Geometric.delta_heading(surface.heading, target_heading)

      yaw = @yaw_controller.trigger(0, -delta_heading)
      @control.yaw = yaw
      pitch = @pitch_controller.trigger(3, surface.pitch)
      @control.pitch = pitch
      sleep 0.01
    end
  end
end
