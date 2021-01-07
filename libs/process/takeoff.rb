class TakeoffProcess
  def initialize(vessel, vr, velocity, height)
    @vessel = vessel
    @control = vessel.control

    @vr = vr
    @velocity = velocity
    @height = height

    @throttle_controller = PIDController.new(0.1, 0.01, 0.2)
    @pitch_controller = PIDController.new(0.05, 0.05, 0.1, -1.0, 1.0)
  end

  def run
    @control.brakes = false
    @control.sas = true
    loop do
      orbit = @vessel.flight(@vessel.orbit.body.reference_frame)
      surface = @vessel.flight(@vessel.surface_reference_frame)
      break unless orbit.speed < @vr
      throttle = @throttle_controller.trigger(@velocity, orbit.speed)
      @control.throttle = throttle
    end

    # Rotate
    puts "Rotate, Gear Up!"
    @control.gear = false

    loop do
      orbit = @vessel.flight(@vessel.orbit.body.reference_frame)
      surface = @vessel.flight(@vessel.surface_reference_frame)
      break unless orbit.mean_altitude < @height - 100
      throttle = @throttle_controller.trigger(@velocity, orbit.speed)
      @control.throttle = throttle

      pitch = @pitch_controller.trigger(10, surface.pitch)
      @control.pitch = pitch
    end

    puts "Takeoff Process Finished."
  end
end
