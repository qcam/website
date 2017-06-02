{
  "title": "Bundler Gotcha",
  "slug": "bundler-gotcha",
  "date": "2017-05-16",
  "description": "Bundler strange behavior that might trap you up",
  "keywords": ["bundler gotcha", "ruby gotcha"],
  "tags": ["bundler", "ruby"]
}
---
A few days ago I encountered a strange behavior of Bundler so this post notes
down how my experience with it was.
---
A few days ago I encountered a strange behavior of Bundler so this post notes
down how my experience with it was.

### What's up?

We know what `Bundler` provides `Bundle.require` and `Bundle.setup` to deal with
dependencies grouping/requiring in our project. With `Bundle.setup` we can explicitly
specify which gem groups we want to add to `$LOAD_PATH`.

Says we have an Gemfile

```ruby
gem "rack"
gem "sinatra"
gem "puma", group: :production
```

As the API tells, we can make only "development" gems available for requiring.

```ruby
# config.ru

require 'bundler'
Bundler.setup(:default, :development)

require 'sinatra/base'
class MyApp < ::Sinatra::Base; end

run MyApp
```

Then boot up the server with `bundle exec`

```sh
bundle install
bundle exec rackup

# Puma starting in single mode...
# * Version 3.8.2 (ruby 2.2.2-p95), codename: Sassy Salamander
# * Min threads: 0, max threads: 16
# * Environment: development
# * Listening on tcp://localhost:9292
# Use Ctrl-C to stop
```

KABOOM 💥! Puma is booted! Why?

### What happened?

#### Rack

By default Rack will boot WEBrick if there's no server found. But it will detect
for a more powerful server like Puma or Thin and if there is one, Rack will prioritize to
load that instead.

#### Bundler

But isn't Puma un-requireable? Haven't we grouped that server to only appear on
`production` and `Bundler.setup` should have their job done well?

The tickle of curiosity drove me to look through the code of `bundle exec`. It
turned out in [this line of code](https://github.com/bundler/bundler/blob/909979271a0c2fe0d59f6fc8c4f5a630e597f1ac/lib/bundler/cli/exec.rb#L71),
**Bundler tries to setup and brings everything we have in `Gemfile` into `$LOAD_PATH`.**
This part of code is executed way in prior to our `Bundler.setup` and once a `Bundler.setup`
is called, all latter ones are void (see my PR below).

That's why `Rack` could see `Puma` and therefor booted the server up.
Additionally, we can require any gem we have in `config.ru` despite of its group
specified in `Gemfile`.

I actually created [an issue on Bundler's Github](https://github.com/bundler/bundler/issues/5661)
and also [a pull request](https://github.com/bundler/bundler/pull/5659) to clarify it.
Interestingly [@segiddins](https://github.com/segiddins), the repo owner, advised the behavior
that strange to me (and some people I assume) is sort of ... intentional.

### So what?

What'd be the possible solution for this case?

#### `bundle config without`

Never run `bundle install` alone, run it with `--with`

```sh
bundle install --without production
```

With this option `Bundler` will not download the gems in production group.
`Bundler` is smart enough to remember our config and use it for future calls.

#### Build your own `bundle exec`

```ruby
# bin/bundle-exec

require "rubygems"
require "bundler"

Bundle.setup(:default, ENV.fetch("RACK_ENV", "development").to_sym)
```

#### Use `Bundler.reset!`

After digging `Bundler`'s codebase here and there, I realize that we can use
`Bundle.reset!` to reset everything, then use `Bundle.setup` to set up again.

This doesn't solve the `Puma` problem we have above but at least from our `Bundle.setup` on,
there will no gem from other groups can be required.

```ruby
# config.ru

require "rubygems"
require "bundler"

Bundle.reset!
Bundle.setup(:default, :development)
```

Anyway, **this method is untested**, in fact I never try using or testify it.
Use it at your own risk, I take no responsible for it.

### What's next?

Personally I think this behavior of Bundler might cause some false positives.
What if we accidentally loaded up some gem that's merely for development or test?
What if that gem was ... `DatabaseCleaner` 😱🙀😱🙀😱🙀?

Also there's no option in `bundle exec` for us to specify the group either.

So sorry for nagging but once more.

> Never ever run `bundle install` alone, use it with `--without`!
