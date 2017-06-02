{
  "title": "My Heroku Checklist",
  "slug": "heroku-checklist",
  "date": "2014-09-19",
  "description": "Heroku makes deployment dead easy for developer. This is my checklist to ensure I won't miss out any stupid things.",
  "keywords": ["rails", "heroku"],
  "tags": ["heroku", "rails"]
}
---
[Heroku](http://heroku.com) makes deployment dead easy for developer, but sometimes checklist
is a great thing to ensure I won't miss out any stupid things.
---
[Heroku](http://heroku.com) makes deployment dead easy for developer, but sometimes checklist
is a great thing to ensure I won't miss out any stupid things.

* Make sure you have `rails_12factor` gem included in your Gemfile.

* Use [Unicorn](https://github.com/defunkt/unicorn), [Passenger](https://www.phusionpassenger.com/)
  or [Puma](http://puma.io/) kind of server, don't use WEBrick the default Rails server.
  It is only suitable for development and can only one request at a time.

  Click [here](https://devcenter.heroku.com/articles/rails-unicorn) to see how to setup Unicorn on Heroku.

* Sign up for a log service. (Loggy, PaperTrail)

* Make sure you have environment variables set properly in your app.

  Sometimes your app was broken mysteriously and you will spend an hour to figure out that's because of those unset variables.
  So please make sure you have them set properly.

* Ensure there is no redundant gem in the Gemfile.

* If your application has Facebook, Google authentication, make sure you have configured them correctly.

  Go config your Facebook, Google app, make sure the app url, callback works on production.

* Register for a Mailing service (SendGrid).

* Tag the release in your commit so we know exactly which code in running in production.

* Check your scheduler, background tasks, cron jobs settings.

* Ensure there is no **PASSWORD**, **TOKEN** in the source code.

  Put them into your environment variables.
