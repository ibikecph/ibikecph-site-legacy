I Bike CPH Site
===============

This is a Rails app that runs the I Bike CPH bicycle route planner at
http://www.ibikecph.dk. OpenStreetMap data is used for maps and
routing. Routing is handled by OSRM running on a separate server.

## Install

Remember:

* `rake acts_as_taggable_on_engine:install:migrations`

* `rake db:migrate`
