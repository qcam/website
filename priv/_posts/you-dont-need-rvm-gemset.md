{
  "title": "You don't need RVM gemset",
  "slug": "you-dont-need-rvm-gemset",
  "date": "2016-05-04",
  "keywords": ["ruby", "rvm alternative"],
  "tags": ["ruby"],
  "description": "Almost 90% of Rubyists uses RVM for Ruby version & project packages management. Someone else uses RBenv with rbenv-gemset, but do you really need gemset?"
}
---
We can't deny the contribution RVM gemset gave up to the Ruby community, but do we really need gemsets to isolate our project dependencies these days?
---
We can't deny the contribution RVM gemset gave up to the Ruby community, but do we really need gemsets to isolate our project dependencies these days?

### Where the idea of gemset came from?

In around 2010, RVM introduced gemset, a huge improvement which changes how the whole Ruby world deals with dependency isolation. From then on, separating Ruby environments on local computers wasn't tough anymore. Just imagine you're starting a fresh Rails 5 project while maintaining a Rails 2.3 application, without gemset.

Read [this post](http://everydayrails.com/2010/09/13/rvm-project-gemsets.html) and you will understand the excitement RVM gemset brought to the world at that moment.

### But you don't need that anymore

Because `bundler` only got you covered with bundle path.

```sh
# This will install all gems into vendor/gems directory of your current project root, and this is a remembered option.
bundle install --path vendor/gems --retry 3
```

You might want to setup an alias to save your time remembering the path.

```sh
# in your .zshrc
alias bi=bundler install --path vendor/gems --retry 3 --jobs 4
alias be=bundler exec
```

Any thoughts are welcomed!
