# Sun

**Solar calculator for Ruby**

* [Source Code]
* [API documentation]
* [Rubygem]

[Source Code]: https://github.com/allspiritseve/sun "Source code at Github"
[API documentation]: http://www.rubydoc.info/gems/sun/file/README.md "RDoc API Documentation at RubyDoc.info"
[Rubygem]: http://rubygems.org/gems/sun "Ruby gem at RubyGems.org"

Sun is a solar calculator for Ruby based on the [National Oceanic & Atmospheric Administration (NOAA) solar calculator](http://www.esrl.noaa.gov/gmd/grad/solcalc/). Sunrise and sunset results are apparent times and not actual times (due to atmospheric refraction, apparent sunrise occurs shortly before the sun crosses above the horizon and apparent sunset occurs shortly after the sun crosses below the horizon).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sun'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sun

## Usage

```ruby
time = Time.new(2015, 1, 1, 12, 0, 0, '-05:00')
latitude = 40.75
longitude = -73.99

# Sunrise
Sun.sunrise(time, latitude, longitude) # => 2015-01-01 07:20:02 -0500

# Solar noon
Sun.solar_noon(time, latitude, longitude) # => 2015-01-01 11:59:09 -0500

# Sunset
Sun.sunset(time, latitude, longitude) # => 2015-01-01 16:38:16 -0500

# Sunrise in minutes after midnight (UTC)
Sun.sunrise_minutes(time, latitude, longitude) # => 740.0366212342198

# Solar noon in minutes after midnight (UTC)
Sun.solar_noon_minutes(time, latitude, longitude) # => 1019.1596410575343

# Sunset in minutes after midnight (UTC)
Sun.sunset_minutes(time, latitude, longitude) # => 1298.2826608808487
```

## Notes

All of the above methods accept Date or Time objects for `time`. If a `Time` object is passed, the calculations will be performed on the return value of [`Time#to_date`](http://ruby-doc.org/stdlib-2.2.2/libdoc/date/rdoc/Time.html#method-i-to_date), which is timezone-dependent (for example, 1am in Michigan is 10pm on the previous day in California). To force calculations on a specific date regardless of timezone, pass a `Date` object.

Sun times are returned as [`Time`](http://ruby-doc.org/core-2.2.2/Time.html) objects in the local system timezone. To convert to a different timezone, you can use [`TZInfo::Timezone#utc_to_local`](http://www.rubydoc.info/gems/tzinfo/TZInfo/Timezone#utc_to_local-instance_method) or [`ActiveSupport::TimeZone#at`](http://api.rubyonrails.org/classes/ActiveSupport/TimeZone.html#method-i-at).

## References

* [NOAA Solar Calculation Details](http://www.esrl.noaa.gov/gmd/grad/solcalc/calcdetails.html)
* [NOAA Solar Calculator](http://www.esrl.noaa.gov/gmd/grad/solcalc/)
* [Wikipedia: Sunrise equation](https://en.wikipedia.org/wiki/Sunrise_equation)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/allspiritseve/sun. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
