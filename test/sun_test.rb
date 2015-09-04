require 'test_helper'
require 'tzinfo'

class SunTest < Minitest::Test
  # def test_sunrise
  #   skip
  #   yday = Date.new(2015, 8, 26).yday
  #   sunrise = Sun.rise(yday, *coordinates)
  #   assert_equal Time.parse('2015-08-26 6:54'), sunrise
  # end

  # def test_fractional_year
  #   skip
  #   yday = Date.new(2015, 8, 26).yday
  #   assert_equal nil, Sun.fractional_year(yday)
  # end

  # def test_solar_declination
  #   skip
  #   yday = Date.new(2015, 8, 26).yday
  #   assert_equal 10.36, Sun.solar_declination(yday)
  # end

  # def test_equation_of_time
  #   skip
  #   assert_equal(-1.855601, Sun.equation_of_time(day_of_year))
  # end

  # def test_solar_noon
  #   date = Date.new(2015, 8, 26)
  #   assert_equal nil, Sun.solar_noon(date, longitude)
  # end

  def test_julian_days
    time = Time.parse('2010-01-01 12:00:00 EST')
    julian_days = Sun.julian_days(time)
    assert_sun_calculation 2455198 + Rational(5, 24), julian_days

    julian_century = Sun.julian_century(julian_days)
    assert_sun_calculation(0.10001369, julian_century, 'julian century')

    mean_obliquity_of_ecliptic = Sun.mean_obliquity_of_ecliptic(julian_century)
    assert_sun_calculation 23.43799044, mean_obliquity_of_ecliptic.to_f

    oblique_correction = Sun.oblique_correction(julian_century, mean_obliquity_of_ecliptic)
    assert_sun_calculation 23.43893238, oblique_correction

    geometric_mean_anomoly = Sun.geometric_mean_anomoly(julian_century)
    assert_sun_calculation 3958.132271, geometric_mean_anomoly

    geometric_mean_longitude = Sun.geometric_mean_longitude(julian_century)
    assert_sun_calculation 281.2416129, geometric_mean_longitude, 'geometric mean longitude'

    var_y = Sun.var_y(oblique_correction)
    assert_sun_calculation 0.043033175, var_y

    eccentricity_of_earth_orbit = Sun.eccentricity_of_earth_orbit(julian_century)
    assert_sun_calculation 0.016704428, eccentricity_of_earth_orbit, 'eccentricity of earth orbit'

    equation_of_time = Sun.equation_of_time(var_y, geometric_mean_longitude, geometric_mean_anomoly, eccentricity_of_earth_orbit)
    assert_sun_calculation(-3.646899915, equation_of_time)

    equation_of_center = Sun.equation_of_center(geometric_mean_anomoly, julian_century)
    assert_sun_calculation(-0.063715576, equation_of_center, 'equation of center')

    true_longitude = Sun.true_longitude(geometric_mean_longitude, equation_of_center)
    assert_sun_calculation 281.1778973, true_longitude, 'true longitude'

    apparent_longitude = Sun.apparent_longitude(true_longitude, julian_century)
    assert_sun_calculation 281.176652, apparent_longitude

    declination = Sun.declination(oblique_correction, apparent_longitude)
    assert_sun_calculation(-22.96864765, declination)

    hour_angle_sunrise = Sun.hour_angle_sunrise(latitude, declination)
    assert_sun_calculation 69.85778153, hour_angle_sunrise

    solar_noon = Sun.solar_noon(longitude, equation_of_time)
    assert_sun_calculation 1019.6069, solar_noon, 'solar_noon'

    assert_equal Time.utc(2010, 1, 1, 16, 59, 36).to_i, Sun.date_at_time(time.to_date, solar_noon).to_i, 'date at time'

    sunrise = Sun.rise(time.to_date, longitude, equation_of_time, hour_angle_sunrise)
    assert_sun_calculation Time.parse('2010-01-01 07:20:11 EST').to_i, sunrise, 'sunrise', 1
  end

  private
  def assert_sun_calculation(expected, actual, name = 'value', delta = 0.001)
    assert_in_delta expected, actual, delta, "#{name} was not in delta"
  end

  def coordinates
    [latitude, longitude]
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
