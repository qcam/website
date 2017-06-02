{
  "title": "Monkey Patching for good",
  "slug": "monkey-patching-for-good",
  "date": "2016-04-10",
  "description": "Monkey-patching has been widely considered as bad practice in software engineering, in terms of source code management and maintainability.",
  "keywords": ["monkey-patching", "ruby"],
  "tags": ["ruby", "productivity"]
}
---
Monkey-patching has been widely considered as bad practice in software development, in terms of source code management and maintainability.
---
Monkey-patching has been widely considered as bad practice in software development, in terms of source code management and maintainability.

![Monkey Patch For Good](/assets/images/monkey_patch.jpg)

Anyway, I believe everything has its own reason to exist, and below are something might change your mind about Monkey Patching.

### Find yourself in development environment

Tired of keep typing something like `User.find_by_username('jack')` in Rails console? Use this.

Monkey patch your object class in `.irbrc`

```ruby
#!/usr/bin/ruby

require 'irb/completion'
require 'irb/ext/save-history'

class Object
  def find_me
    self.find_by_username 'cam@example.com'
  end
end
```

Then now `User.find_me` will return your favourite test user.

### Inspect Object

Tired of keep typing this?

```ruby
users = User.all
p users.to_sql
users = users.order(username: :desc)
p users.to_sql
```

Then this might save your time.

```ruby
class Object
  def show_me(method)
    tap { |obj| puts obj.send(method) }
  end
end

# then now
User.all.show_me(:to_sql).order(username: :desc).show_me(:to_a)
```

Convinced yet? Leave your thoughts below!
