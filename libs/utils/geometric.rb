class Geometric
  def self.target_heading(lat1, lng1, lat2, lng2)
    delta_phi = Math.log(Math.tan((lat2 / 180 * Math::PI) / 2 + Math::PI / 4) / Math.tan((lat1 / 180 * Math::PI) / 2 + Math::PI / 4))
    delta_lon =  (lng2 - lng1)  / 180 * Math::PI
    theta = Math.atan2(delta_lon, delta_phi)
    res = theta * 180 / Math::PI
    res = 360 + res if res < 0
    res
  end

  def self.delta_heading(current, target)
    res = target - current
    res = 360 - res if res > 180
    res = res + 360 if res < -180
    res
  end

  def self.distance(lat1, lng1, lat2, lng2)
    r = 600000
    psi_1 = lat1 * Math::PI / 180.0
    psi_2 = lat2 * Math::PI / 180.0
    delta_psi = (lat2 - lat1) * Math::PI / 180.0
    delta_lambda = (lng2 - lng1) * Math::PI / 180.0
    a = (Math.sin(delta_psi / 2.0) ** 2) +
        Math.cos(psi_1) * Math.cos(psi_2) *
        (Math.sin(delta_lambda / 2.0) ** 2)
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1.0 - a))
    d = r * c
    d
  end
end
