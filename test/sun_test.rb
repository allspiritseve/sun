require 'helper'

class SunTest < Minitest::Test
  def test_julian_days
    assert_sun_calculation 2455197.5, Sun.julian_days(Date.new(2010, 1, 1)), 'julian days for date'
    assert_sun_calculation 2455198 + Rational(5, 24), Sun.julian_days(Time.parse('2010-01-01 12:00:00 EST')), 'julian days for time'
  end

  def test_intermediate_calculations
    julian_days = Sun.julian_days(date)
    assert_sun_calculation 2455197.5, julian_days

    julian_century = Sun.julian_century(date)
    assert_sun_calculation(0.10000000, julian_century, 'julian century')

    mean_obliquity_of_ecliptic = Sun.mean_obliquity_of_ecliptic(julian_century)
    assert_sun_calculation 23.43799069, mean_obliquity_of_ecliptic.to_f

    oblique_correction = Sun.oblique_correction(julian_century)
    assert_sun_calculation 23.43893419, oblique_correction, 'oblique_correction'

    geometric_mean_anomoly = Sun.geometric_mean_anomoly(julian_century)
    assert_sun_calculation 3957.434137, geometric_mean_anomoly, 'geometric mean anomoly'

    geometric_mean_longitude = Sun.geometric_mean_longitude(julian_century)
    assert_sun_calculation 280.543446, geometric_mean_longitude, 'geometric mean longitude'

    y = Sun.y(oblique_correction)
    assert_sun_calculation 0.043033181, y

    eccentricity_of_earth_orbit = Sun.eccentricity_of_earth_orbit(julian_century)
    assert_sun_calculation 0.016704429, eccentricity_of_earth_orbit, 'eccentricity of earth orbit'

    equation_of_center = Sun.equation_of_center(julian_century)
    assert_sun_calculation(-0.087517011, equation_of_center, 'equation of center')

    true_longitude = Sun.true_longitude(julian_century)
    assert_sun_calculation 280.455929, true_longitude, 'true longitude'

    apparent_longitude = Sun.apparent_longitude(julian_century)
    assert_sun_calculation 280.4546825, apparent_longitude

    declination = Sun.declination(oblique_correction, julian_century)
    assert_sun_calculation(-23.02719109, declination)

    equation_of_time = Sun.equation_of_time(date, longitude)
    assert_sun_calculation(-3.313375921, equation_of_time)

    hour_angle = Sun.hour_angle(date, latitude)
    assert_sun_calculation 69.79491113, hour_angle

    sunrise_minutes = Sun.sunrise_minutes(time, latitude, longitude)
    assert_sun_calculation 740.0937314, sunrise_minutes, 'sunrise minutes', Rational(1, 60)

    sunrise = Sun.sunrise(date, latitude, longitude)
    assert_sun_calculation Time.parse('2010-01-01 07:20:06 EST'), sunrise, 'sunrise', 1

    solar_noon_minutes = Sun.solar_noon_minutes(time, latitude, longitude)
    assert_sun_calculation 1019.27, solar_noon_minutes, 'solar noon minutes', Rational(1, 60)

    solar_noon = Sun.solar_noon(date, latitude, longitude)
    assert_sun_calculation Time.parse('2010-01-01 11:59:16 EST'), solar_noon, 'solar_noon', 1

    sunset_minutes = Sun.sunset_minutes(time, latitude, longitude)
    assert_sun_calculation 1298.45302, sunset_minutes, 'sunset minutes', Rational(1, 60)

    sunset = Sun.sunset(date, latitude, longitude)
    assert_sun_calculation Time.parse('2010-01-01 16:38:27 EST'), sunset, 'sunset', 1
  end

  def test_invalid_coordinates
    assert_raises Sun::InvalidCoordinates do
      Sun.sunrise(time, 84, longitude)
    end
  end

  def test_invalid_time
    assert_raises Sun::InvalidTime do
      Sun.sunrise(nil, latitude, longitude)
    end
  end

  def test_solar_noon_with_invalid_hour_angle
    # Greenland
    latitude = 71.706936
    longitude = -42.604303
    time = Time.parse('2019-12-10 12:00:00 -03:00')
    solar_noon = Sun.solar_noon(time, latitude, longitude)
    assert_sun_calculation Time.parse('2019-12-10 11:42:51 -03:00'), solar_noon, 'solar_noon', 1
    assert_raises(Sun::InvalidCoordinates) { Sun.sunrise(time, latitude, longitude) }
    assert_raises(Sun::InvalidCoordinates) { Sun.sunset(time, latitude, longitude) }
  end

  private
  def time
    @time ||= Time.parse('2010-01-01 12:00:00 EST')
  end

  def date
    time.to_date
  end

  def latitude
    40.75
  end

  def longitude
    -73.99
  end
end
