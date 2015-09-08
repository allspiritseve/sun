require 'test_helper'
require 'csv'
require 'time'

class Year2015Test < Minitest::Test
  def assert_sun_times(date)
    @julian_days = Sun.julian_days(date)
    assert_expected :julian_days

    @julian_century = Sun.julian_century(date)
    assert_expected :julian_century

    @mean_obliquity_of_ecliptic = Sun.mean_obliquity_of_ecliptic(@julian_century)
    assert_expected :mean_obliquity_of_ecliptic

    @oblique_correction = Sun.oblique_correction(@julian_century)
    assert_expected :oblique_correction

    @geometric_mean_anomoly = Sun.geometric_mean_anomoly(@julian_century)
    assert_expected :geometric_mean_anomoly

    @geometric_mean_longitude = Sun.geometric_mean_longitude(@julian_century)
    assert_expected :geometric_mean_longitude

    @y = Sun.y(@oblique_correction)
    assert_expected :y

    @eccentricity_of_earth_orbit = Sun.eccentricity_of_earth_orbit(@julian_century)
    assert_expected :eccentricity_of_earth_orbit

    @equation_of_center = Sun.equation_of_center(@julian_century)
    assert_expected :equation_of_center

    @true_longitude = Sun.true_longitude(@julian_century)
    assert_expected :true_longitude

    @apparent_longitude = Sun.apparent_longitude(@julian_century)
    assert_expected :apparent_longitude

    @declination = Sun.declination(@oblique_correction, @julian_century)
    assert_expected :declination

    @equation_of_time = Sun.equation_of_time(date, longitude)
    assert_expected :equation_of_time

    @hour_angle = Sun.hour_angle(date, latitude)
    assert_expected :hour_angle

    @solar_noon_minutes = Sun.solar_noon_minutes(date, latitude, longitude)
    assert_expected :solar_noon_minutes, Rational(1, 60)

    @solar_noon = Sun.solar_noon(date, latitude, longitude)
    assert_expected :solar_noon, 1

    @sunrise_minutes = Sun.sunrise_minutes(date, latitude, longitude)
    assert_expected :sunrise_minutes, Rational(1, 60)

    @sunrise = Sun.sunrise(date, latitude, longitude)
    assert_expected :sunrise, 1

    @sunset_minutes = Sun.sunset_minutes(date, latitude, longitude)
    assert_expected :sunset_minutes, Rational(1, 60)

    @sunset = Sun.sunset(date, latitude, longitude)
    assert_expected :sunset, 1
  end

  def assert_expected(key, delta = Rational(1, 1000))
    assert_sun_calculation @expected.fetch(key), instance_variable_get("@#{key}"), key.to_s.gsub('_', ' '), delta
  end

  def latitude
    40.75
  end

  def longitude
    -73.99
  end

  def self.expected_values
    @expected_values ||= {}.tap do |values|
      CSV.read(File.expand_path(File.join(File.dirname(__FILE__), 'data', 'NOAA Solar Calculations 2015.csv')), headers: true).each do |row|
        date = parse_csv_date(row['Date'])
        values[date] = {
          julian_days: row['Julian Day'].to_f,
          julian_century: row['Julian Century'].to_f,
          geometric_mean_longitude: row['Geom Mean Long Sun (deg)'].to_f,
          geometric_mean_anomoly: row['Geom Mean Anom Sun (deg)'].to_f,
          eccentricity_of_earth_orbit: row['Eccent Earth Orbit'].to_f,
          equation_of_center: row['Sun Eq of Ctr'].to_f,
          true_longitude: row['Sun True Long (deg)'].to_f,
          sun_true_anomoly: row['Sun True Anom (deg)'].to_f,
          apparent_longitude: row['Sun App Long (deg)'].to_f,
          mean_obliquity_of_ecliptic: row['Mean Obliq Ecliptic (deg)'].to_f,
          oblique_correction: row['Obliq Corr (deg)'].to_f,
          declination: row['Sun Declin (deg)'].to_f,
          y: row['var y'].to_f,
          equation_of_time: row['Eq of Time (minutes)'].to_f,
          hour_angle: row['HA Sunrise (deg)'].to_f,
          sunrise: parse_csv_time(date, row['Sunrise Time (LST)'], before: row['Solar Noon (LST)']),
          sunrise_minutes: row['Sunrise Time Minutes (LST)'].to_f,
          solar_noon: parse_csv_time(date, row['Solar Noon (LST)']),
          solar_noon_minutes: row['Solar Noon Minutes (LST)'].to_f,
          sunset: parse_csv_time(date, row['Sunset Time (LST)'], after: row['Solar Noon (LST)']),
          sunset_minutes: row['Sunset Time Minutes (LST)'].to_f,
        }
      end
    end
  end

  def self.parse_csv_date(value)
    Date.parse(value.split('/').values_at(2, 0, 1).join('-'))
  end

  def self.parse_csv_time(date, value, options = {})
    before_time = Time.parse("#{date} #{options[:before]}Z") if options.key?(:before)
    after_time = Time.parse("#{date} #{options[:after]}Z") if options.key?(:after)

    time = Time.parse("#{date} #{value}Z")

    if before_time && time > before_time
      Time.parse("#{date - 1} #{value}Z")
    elsif after_time && time < after_time
      Time.parse("#{date + 1} #{value}Z")
    else
      time
    end
  end

  (Date.new(2015, 1, 1)..Date.new(2016, 1, 1)).each do |date|
    expected = expected_values.fetch(date)
    define_method "test_sun_times_#{date.iso8601}" do
      @expected = expected
      assert_sun_times(date)
    end
  end
end
