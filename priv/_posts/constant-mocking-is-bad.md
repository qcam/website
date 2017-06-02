{
  "title": "Why constant mocking is a bad idea?",
  "slug": "why-constant-mocking-is-bad",
  "date": "2017-03-26",
  "description": "Mocks are not bad, mutation is bad. This blog post explains why we should never mock constant in our tests.",
  "keywords": ["testing", "mock", "ruby"],
  "tags": ["ruby", "testing"]
}
---
Says we have a `Clock` class which returns the current time of the system.
---
Says we have a `Clock` class which returns the current time of the system.

```ruby
class Clock
  def self.current
    Time.now
  end
end
```

To unit-test this class, RSpec supports an **easy** way to mock test if the
method has been called.

```ruby
expect(Time).to receive(:now).once
Clock.current
```

As easy as ABC no?  But is it as **simple** as it seems to be?

### Easy !== simple

I believe we never understand mock test until we write our own mock framework.
So off we go.

```ruby
def expect_called(klass, method_name, times, &block)
  called = 0 # method called counter
  original_method = klass.methods(method_name) # keep the original method

  klass.define_method(method_name) do # redefine the method
    called += 1 # increase the counter every time this method is called
    original_method.call # invoke the original method
  end
  yield # call the block
  assert_equal(called, times) # check if method has been called
end

# To use it
expect_called(Time, :now, 1) { Clock.current }
```

As you can see, `expect_called` needs to "monkey-patch" `klass` to count the
amount of times `:now` method being called. We all know mutation is bad and
could turn things into a disaster. What if there are some core classes or
third-party libraries we use also require `Time.now` to work?

Furthermore, we need some magical mechanisms to "revert" `Time.now` back to its
original state, which I am not going to cover in this blog post. Let me emphasis
the answer for the question in the previous section, **No, it is not simple**.

`expect_called` is exactly how `rspec-mocks` works under the hood. It redefines
the method, counts the calls, stubs the return, and reverts it back to the
original state when tear-down.

### Dependency injection

Mutation is bad but mocks are not. Mock test is so useful when we want to establish
a contract between our class and another object without needing that object to really
exist.

And it's absolutely possible to write mock test without any mutation needed in
RSpec.

Let's change our code a bit, with `Time` as an injected dependency.

```ruby
class Clock
  def self.current(clock = Time)
    clock.now
  end
end
```

And writing test is so easy.

```ruby
now = Time.now
clock = double("Time", now: now)
assert(now, Clock.current(clock))
```

Although the change is small, the improvement is huge. `clock` is a mock object which
only lives in this test example and does not require any class to be mutated. Also
we explicitly describe the contract of how the `clock` should be. Winning!

We might also want to enhance the test by covering the default case and testing
its behavior.

```ruby
assert(Time, Clock.current.class)
```

### Other bad RSpec mock tests

```ruby
# From RSpec 2 and RSpec 3 deprecated them.
allow_any_instance_of(Widget).to receive(:name).and_return("Wibble")
expect_any_instance_of(Widget).to receive(:name).and_return("Wobble")

allow(Invitation).to receive(:deliver)
```

### Read-ups

Some great blog posts about mocks and dependency injection in case you
want to read further.

1. [Mocks and explicit contracts](http://blog.plataformatec.com.br/2015/10/mocks-and-explicit-contracts/)
2. [The world needs another post about dependency injection](http://solnic.eu/2013/12/17/the-world-needs-another-post-about-dependency-injection-in-ruby.html)
