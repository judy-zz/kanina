Changelog
=========

v0.6.1
------
- Complete project rename! Once "Hare", now called "Kanina".
  - "Kanina" means "Bunny" in Icelandic and "a while ago" in Tagalog. More importantly, it was available on Rubygems...
- Ruby 2.2.0 support.
- Mark an exchange as durable.
- More and better documentation.
- Better coverage.
- Tweak integration with Inch & Code Climate
- Stop using Coveralls, since it was conflicting, and I'm now sending coverage to Code Climate anyway.
- Renamed exchanges and queues in specs, so all Kanina output is namespaced.

v0.6.0
------
- Mark individual messages as persistent or transient.
- Add better documentation throughout.

v0.5.0
------
- Add durable queues.

v0.4.0
------
- Update Bunny version to ~1.6.
  - Should take care of some connection issues people have been seeing from the older version of Bunny.
  - I'm not setting the patch version, so your computer will automatically install the latest minor version.

v0.3.3
------
- Started this changelog.
- Remove Spring dependency for preloading.
- Fix the way existing exchanges are found and connected to.
