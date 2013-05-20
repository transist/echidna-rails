Install Prerequisites
---------------------

* MongoDB.

Setup
-----

    cp config/application.example.yml config/application.yml

* Tweak configuration settings in `config/application.yml`.
* Run `rake db:setup`.

Load Rails Development Environment
----------------------------------

    bundle
    guard

Guard will run Rails server and tests for you, plus automatically restart them
when related files change. Check `Guardfile` for details.

Run Sidekiq
-----------

    bundle exec sidekiq -q trends,10 -q default -q spider,1

Deploy to Production
--------------------

    cap deploy

Visit http://echidna.transi.st to access the UI. Username and password for HTTP Basic auth is `ecihdna` and `aeg3aughoh5se1OuThom`.

Mock DailyStat
--------------

    PANEL_ID=xxx rake mock_stats

it will update hourly_stats and daily_stats periodically.
