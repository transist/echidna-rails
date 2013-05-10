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

Deploy to Production
--------------------

    cap deploy
