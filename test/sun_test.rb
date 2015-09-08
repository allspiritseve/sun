require 'test_helper'
require 'tzinfo'

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

    solar_noon_minutes = Sun.solar_noon_minutes(time, latitude, longitude)
    assert_sun_calculation 1019.27, solar_noon_minutes, 'solar noon minutes', Rational(1, 60)

    solar_noon = Sun.solar_noon(date, latitude, longitude)
    assert_sun_calculation Time.parse('2010-01-01 11:59:16 EST'), Time.at(solar_noon), 'solar_noon', 1

    sunrise_minutes = Sun.sunrise_minutes(time, latitude, longitude)
    assert_sun_calculation 740.0937314, sunrise_minutes, 'sunrise minutes', Rational(1, 60)

    sunrise = Sun.sunrise(date, latitude, longitude)
    assert_sun_calculation Time.parse('2010-01-01 07:20:06 EST'), Time.at(sunrise), 'sunrise', 1

    sunset_minutes = Sun.sunset_minutes(time, latitude, longitude)
    assert_sun_calculation 1298.45302, sunset_minutes, 'sunset minutes', Rational(1, 60)

    sunset = Sun.sunset(date, latitude, longitude)
    assert_sun_calculation Time.parse('2010-01-01 16:38:27 EST'), Time.at(sunset), 'sunset', 1
  end

   def test_minutes_to_time_of_day
     time_of_day = Sun.minutes_to_time_of_day(124 + Rational(576, 1000))
     assert_equal [2, 4, 0.576], time_of_day

     time_of_day = Sun.minutes_to_time_of_day(32.5)
     assert_equal [0, 32, 0.5], time_of_day
   end

   def test_local_time
     local_time = Sun.local_time(Date.new(2010, 1, 1), 124 + Rational(576, 1000))
     assert_equal [2010, 1, 1, 2, 4, 0.576], local_time

     local_time = Sun.local_time(Date.new(2015, 6, 30), 32.5)
     assert_equal [2015, 6, 30, 0, 32, 0.5], local_time
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

  def day_of_year
    Date.new(2015, 8, 26).yday
  end

  def timezone
    @timezone ||= TZInfo::Timezone.get('America/Detroit')
  end
end
