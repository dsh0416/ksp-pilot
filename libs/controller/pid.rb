class PIDController
  def initialize(kp, ki, kd, clip_min=0.0, clip_max=1.0)
    @prev_err = 0.0
    @integral = 0.0
    @kp = kp
    @ki = ki
    @kd = kd
    @clip_min = clip_min
    @clip_max = clip_max

    @last_frame = 0.0
  end

  def trigger(goal, measured)
    trigger_err(goal - measured)
  end

  def trigger_err(err)
    current_frame = Time.now.to_f
    dt = current_frame - @last_frame
    if dt > 1.0
      @last_frame = current_frame
      return 0.0
    end

    @integral = @integral + err * dt

    @integral = @clip_min if @integral < @clip_min
    @integral = @clip_max if @integral > @clip_max

    d = (err - @prev_err) / dt
    res = @kp * err + @ki * @integral + @kd * d
    @prev_err = err
    @last_frame = current_frame

    return @clip_min if res < @clip_min
    return @clip_max if res > @clip_max
    res
  end
end
