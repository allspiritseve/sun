require 'date'
require 'sun/version'

module Sun
  # The approximate correction for atmospheric refraction at sunrise and sunset
  SOLAR_ZENITH = 90.833

  # 2000-01-01 12:00:00 UTC in Julian days
  JULIAN_CONSTANT = 2451545.to_r

  class InvalidTime < StandardError
  end

  # Sun times (UTC)

  def self.sunrise(time, latitude, longitude)
    sun_time(:sunrise, time, latitude, longitude)
  end

  def self.solar_noon(time, latitude, longitude)
    sun_time(:solar_noon, time, latitude, longitude)
  end

  def self.sunset(time, latitude, longitude)
    sun_time(:sunset, time, latitude, longitude)
  end

  # Sun times in minutes after midnight (UTC)

  def self.sunrise_minutes(time, latitude, longitude)
    sun_time_minutes(:sunrise, time, latitude, longitude)
  end

  def self.solar_noon_minutes(time, latitude, longitude)
    sun_time_minutes(:solar_noon, time, latitude, longitude)
  end

  def self.sunset_minutes(time, latitude, longitude)
    sun_time_minutes(:sunset, time, latitude, longitude)
  end

  # Helpers

  def self.date(time)
    case time
    when Date then time
    when Time then time.to_date
    else
      raise InvalidTime, "must pass a Date or Time object"
    end
  end

  def self.degrees(radians)
    Rational(180 * radians, Math::PI)
  end

  def self.radians(degrees)
    Rational(Math::PI * degrees, 180)
  end

  def self.date_to_unix_time(date)
    Time.utc(date.year, date.month, date.day).to_i
  end

  def self.date_at_time(date, minutes)
    Time.at(date_to_unix_time(date) + minutes * 60)
  end

  def self.minutes_to_time_of_day(minutes)
    [(minutes / 60).to_i, (minutes % 60).to_i, (minutes % 60) % 1]
  end

  # Base our calculations off the astronomical julian date for our input time.
  # Our formula is sensitive to time of day, so we ignore it in order to give
  # consistent results for any time on the same date.
  def self.sun_time(type, time, latitude, longitude)
    date = date(time)
    minutes = sun_time_minutes(type, date, latitude, longitude)
    date_at_time(date, minutes)
  end

  def self.sun_time_minutes(type, time, latitude, longitude)
    date = date(time)
    offset = offset_multiplier(type) * 4 * hour_angle(date, latitude)
    720 - (4 * longitude) - equation_of_time(date, longitude) + offset
  rescue Math::DomainError
    raise InvalidCoordinates, "Could not determine solar noon for coordinates: #{latitude}, #{longitude}"
  end

  def self.offset_multiplier(type)
    case type
    when :sunrise then -1
    when :solar_noon then 0
    when :sunset then 1
    end
  end

  # Calculations

  def self.julian_days(time)
    if time.is_a?(Time)
      time.to_datetime.ajd
    else
      date(time).ajd
    end
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
    (280.46646 + julian_century * (36000.76983 + julian_century * 0.0003032)) % 360
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

  def self.equation_of_time(date, longitude)
    julian_century = julian_century(date)
    oblique_correction = oblique_correction(julian_century)
    geometric_mean_anomoly = geometric_mean_anomoly(julian_century)
    geometric_mean_longitude = geometric_mean_longitude(julian_century)
    eccentricity_of_earth_orbit = eccentricity_of_earth_orbit(julian_century)
    y = y(oblique_correction)
    4 * degrees(y * Math.sin(2 * radians(geometric_mean_longitude)) - 2 * eccentricity_of_earth_orbit * Math.sin(radians(geometric_mean_anomoly)) + 4 * eccentricity_of_earth_orbit * y * Math.sin(radians(geometric_mean_anomoly)) * Math.cos(2 * radians(geometric_mean_longitude)) - 0.5 * y * y * Math.sin(4 * radians(geometric_mean_longitude)) - 1.25 * eccentricity_of_earth_orbit * eccentricity_of_earth_orbit * Math.sin(2 * radians(geometric_mean_anomoly)))
  end

  def self.hour_angle(date, latitude)
    julian_century = julian_century(date)
    oblique_correction = oblique_correction(julian_century)
    declination = declination(oblique_correction, julian_century)
    res = Math.cos(radians(SOLAR_ZENITH)) / (Math.cos(radians(latitude)) * Math.cos(radians(declination))) - Math.tan(radians(latitude)) * Math.tan(radians(declination))
    degrees(Math.acos(res))
  end
end
