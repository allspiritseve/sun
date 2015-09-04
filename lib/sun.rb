require 'sun/version'

module Sun
  SOLAR_ZENITH = 90.833

  # Noon on January 1st, 2000
  JULIAN_CONSTANT = 2451545.to_r

  # Sun times
  def self.solar_noon(time, latitude, longitude)
    minutes = solar_noon_minutes(time, latitude, longitude)
    date_at_time(time.to_date, minutes)
  end

  def self.sunrise(time, latitude, longitude)
    minutes = sunrise_minutes(time, latitude, longitude)
    date_at_time(time.to_date, minutes)
  end

  def self.sunset(time, latitude, longitude)
    minutes = sunset_minutes(time, latitude, longitude)
    date_at_time(time.to_date, minutes)
  end

  # Helpers
  def self.degrees(radians)
    180.0 * radians / Math::PI
  end

  def self.radians(degrees)
    Math::PI * degrees / 180.0
  end

  def self.date_to_unix_time(date)
    Time.utc(date.year, date.month, date.day).to_i
  end

  def self.date_at_time(date, minutes)
    date_to_unix_time(date) + minutes * 60
  end

  def self.julian_days(time)
    time.utc.to_datetime.ajd
  end

  def self.julian_century(time)
    (julian_days(time) - JULIAN_CONSTANT) / 36525
  end

  def self.mean_obliquity_of_ecliptic(julian_century)
    23 + (26 + ((21.448 - julian_century * (46.815 + julian_century * (0.00059 - julian_century * 0.001813)))) / 60) / 60
  end

  def self.oblique_correction(julian_century)
    mean_obliquity_of_ecliptic(julian_century) + 0.00256 * Math.cos(radians(125.04 - 1934.136 * julian_century))
  end

  def self.geometric_mean_anomoly(julian_century)
    357.52911 + julian_century * (35999.05029 - 0.0001537 * julian_century)
  end

  # MOD(280.46646+G2*(36000.76983 + G2*0.0003032),360)
  def self.geometric_mean_longitude(julian_century)
    280.46646 + julian_century * (36000.76983 + julian_century * 0.0003032) % 360
  end

  def self.y(oblique_correction)
    Math.tan(radians(Rational(oblique_correction, 2))) * Math.tan(radians(Rational(oblique_correction, 2)))
  end

  def self.eccentricity_of_earth_orbit(julian_century)
    0.016708634 - julian_century * (0.000042037 + 0.0000001267 * julian_century)
  end

  def self.equation_of_center(julian_century)
    geometric_mean_anomoly = geometric_mean_anomoly(julian_century)
    Math.sin(radians(geometric_mean_anomoly)) * (1.914602 - julian_century * (0.004817 + 0.000014 * julian_century)) + Math.sin(radians(2 * geometric_mean_anomoly)) * (0.019993 - 0.000101 * julian_century) + Math.sin(radians(3 * geometric_mean_anomoly)) * 0.00028
    # =SIN(RADIANS(J2))*(1.914602-G2*(0.004817+0.000014*G2))+SIN(RADIANS(2*J2))*(0.019993-0.000101*G2)+SIN(RADIANS(3*J2))*0.00028
  end

  def self.true_longitude(julian_century)
    geometric_mean_longitude(julian_century) + equation_of_center(julian_century)
  end

  def self.apparent_longitude(julian_century)
    true_longitude(julian_century) - 0.00569 - 0.00478 * Math.sin(radians(125.04 - 1934.136 * julian_century))
  end

  def self.declination(oblique_correction, julian_century)
    degrees(Math.asin(Math.sin(radians(oblique_correction)) * Math.sin(radians(apparent_longitude(julian_century)))))
  end

  def self.equation_of_time(time, longitude)
    julian_century = julian_century(time)
    oblique_correction = oblique_correction(julian_century)
    geometric_mean_anomoly = geometric_mean_anomoly(julian_century)
    geometric_mean_longitude = geometric_mean_longitude(julian_century)
    eccentricity_of_earth_orbit = eccentricity_of_earth_orbit(julian_century)
    y = y(oblique_correction)
    4 * degrees(y * Math.sin(2 * radians(geometric_mean_longitude)) - 2 * eccentricity_of_earth_orbit * Math.sin(radians(geometric_mean_anomoly)) + 4 * eccentricity_of_earth_orbit * y * Math.sin(radians(geometric_mean_anomoly)) * Math.cos(2 * radians(geometric_mean_longitude)) - 0.5 * y * y * Math.sin(4 * radians(geometric_mean_longitude)) - 1.25 * eccentricity_of_earth_orbit * eccentricity_of_earth_orbit * Math.sin(2 * radians(geometric_mean_anomoly)))
  end

  def self.hour_angle(time, latitude)
    julian_century = julian_century(time)
    oblique_correction = oblique_correction(julian_century)
    declination = declination(oblique_correction, julian_century)
    degrees(Math.acos(Math.cos(radians(90.833)) / (Math.cos(radians(latitude)) * Math.cos(radians(declination))) - Math.tan(radians(latitude)) * Math.tan(radians(declination))))
  end

  def self.solar_noon_minutes(time, latitude, longitude)
    720 - (4 * longitude) - equation_of_time(time, longitude)
  end

  def self.sunrise_minutes(time, latitude, longitude)
    solar_noon_minutes(time, latitude, longitude) - 4 * hour_angle(time, latitude)
  end

  def self.sunset_minutes(time, latitude, longitude)
    solar_noon_minutes(time, latitude, longitude) + 4 * hour_angle(time, latitude)
  end
end
