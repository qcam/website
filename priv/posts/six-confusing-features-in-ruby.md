{
  "title": "Six confusing features in Ruby",
  "slug": "six-confusing-features-in-ruby",
  "datetime": "2017-08-20T09:28:59.532686Z",
  "draft": true
}
---
In this post I am trying to point out some Ruby features you might want to use with a lot of caution.
---
I love the Ruby language, undoubtedly! When you love something, you should love not only the bright side but also the dark side of it too, unconditionally. Probably that is the message Katy Perry tries to deliver.

In this post I am trying to point out some Ruby features you might want to use with a lot of caution.

_I have another post about [five gotchas in Rails](/posts/five-rails-gotchas) because I love the framework too._

## 1. The `[]` method

I really have no clue why Rubyists love the use of `[]` so much.

As in other programming language, it can be used to access Array elements.

```ruby
array = [1, 2, 3]
array[0] # => 1
```

and Hash entries.

```ruby
hash = {foo: "bar"}
hash[:foo] # => "bar"
```

You can also get the character at a given index of a String with `[]`.

```
"Hello World"[0] # => "H"
```

And most confusingly, you invoke a Proc or Lambda by `[]`.

```ruby
hello = (-> (name) { "Hi, #{name}!" })
hello["John"] # => "Hi, John"
```

What if we chain them together?

```ruby
wise_words_factory = (-> (number_of_elements) { (1..number_of_elements).map { WideWord.random } })

wise_words_factory[10][0][:category] # "Body builder"
wise_words_factory[10][0][:words] # "No pain, no gain"
wise_words_factory[10][0][:words][0] # "N"
```

Have a good time debugging, what could possibly go wrong? 🙈

## 2. The `%` operator

Like `[]`, `%` in Ruby is bewildering as hell.

`%` can be used as modulo operator.

```ruby
103 % 100 # => 3
```

We can also use `%` to format string, where the confusion arises.

```ruby
"%s: %d" % ["age", 18] # => age: 18
```

To avoid confusion, using the alternative `Kernel.format` will result the same.

```
Kernel.format(format, "age", 18) # => age: 18
```

## 3. The `Integer#zero?` method

If you are unsure of what `zero?` is about, let us do a simple walkthrough.

```ruby
assert_equal(1 == 0, 1.zero?) # => true
```

This looks cool in the first sight, using `zero?` seems to make code look more concise, beautiful and readable.

But in the end of the day, this causes more confusion than help, because they are ... **NOT EQUAL**. Using `== 0` is about doing equality comparison on the objects with all physical and semantic check, while `.zero?`, in OOP terminology, sends a message to the callee and requires the callee to be a number, even though it might proxy back to `==` eventually.

Consider the example below, the first example will fail and raise exception if `number` is not a number.

```ruby
def x_or_o(number)
  number.zero? ? "o" : "x"
end

def x_or_o(number)
  number == 0 ? "o" : "x"
end
```

Just use `== 0`, it is TOTALLY readable, and NOT ugly at all.

## 4. The `$[number]` global variables

Consider this regex matching.

```ruby
# test.rb
string = "Hi, John!"
matched = %r(^(.+), (.+)!$).match(string)
matched[0] => "Hi, John!"
matched[1] => "Hi"
matched[2] => "John"
```

Looks pretty neat, right? But wait, Ruby provides another way to retrieve the matched data too.

```ruby
string = "Hi, John!"
%r(^(.+), (.+)!$).match(string)
$1 => "Hi"
$2 => "John"
```

"Mutating global variables for every regex matching is horrible and error prone and race and such!", you might scream. Nevertheless Ruby has you covered, in a way. According to [the documentation](https://ruby-doc.org/core-2.2.0/Regexp.html#class-Regexp-label-Special+global+variables), these global variables are thread-local and method-local variables. So generally, they are not global.

> AHA moment #1: Why call them **global** while they are not?

When I thought I could apply the same thing to `matched[0]`, magic happened.

```ruby
$0 # => test.rb
```

> AHA moment #2: `$0` in Ruby is reserved as the global variable for the current filename.

And I suddenly remembered in Ruby I could use use negative number to go backward the array. Let's give it a try.

```ruby
matched[-1] # => "John"
$-1 # => nil
```

OMG it worked!

> AHA moment #2: #TIL `$-1`, even though it will not give you any matched data.

You can even assign value to `$-1`.

```ruby
$-1 = 100
$-1 # => 100
```

Awesome, let's go further.

```ruby
$-100 = 100

#SyntaxError: (irb):29: syntax error, unexpected tINTEGER, expecting end-of-input
#$-100
#     ^
#	from /usr/local/bin/irb:11:in `<main>'
```

> AHA moment #3: #TIL `$-[number]` only works when number is in 1-9.

Alright let's end here. `¯\_(ツ)_/¯`.

## 5. The masterpiece of the omnipotent God: `Time.parse`

`Time.parse` is a very powerful time parser, with many time formats supported.

```ruby
Time.parse("Thu Nov 29 14:33:20 GMT 2001")
# => 2001-11-29 14:33:20 +0000

Time.parse("2011-10-05T22:26:12-04:00")
# => 2011-10-05 22:26:12 -0400
```

But too powerful, sometimes. 😱

```ruby
Time.parse("Thu Nov 29 a:b:c GMT 2001")
# 2017-11-29 00:00:00 +0100
```

To understand why it is we need to look at [the documentation of `Time.parse`](https://ruby-doc.org/stdlib-2.1.1/libdoc/time/rdoc/Time.html#parse-method). There actually exists the second argument, a relative date which Ruby could fallback to when any part of the given string could not be parsed, with `Time.now` as the default date time.

This is a **haunting** feature. Apparently for the example above, the date string is wrong. Let me repeat, **IT IS WRONG**, and we should have an exception raised rather than a wrong date returned.

More confusing examples of `Time.parse`.

```ruby
Time.parse("12/27") # => 2017-12-27 00:00:00 +0100
Time.parse("27/12/2017") # => 2017-12-27 00:00:00 +0100
```

## 6. Delegator

Let's see this example.

```ruby
require "delegate"

class Foo < Delegator
  def initialize(the_obj)
    @the_obj = the_obj
  end

  def __getobj__
    @the_obj
  end
end

foo = Foo.new(1)
foo.inspect # => 1
foo == 1 # => true
```

In my humble opinion, this behavior is completely **WRONG** and is giving a lot of false assumption because a delegator of `1` is absolutely not equal to `1`.

> Equality — At the Object level, == returns true only if obj and other are the same object. - Ruby documentation.

Obviously they are not the same object.

The reason behind this behavior is that for each message received, the delegator will just dumbly pass it to the delegated, no matter the message is `hello` or `==`.

This leads to another problem.

```ruby
foo = Foo.new(nil)
foo.inspect # => nil
```

When we try to dump the object `foo`, it dumps the delegated object instead of the object we want to dump. Ideally it could return something like.

```
foo = Foo.new(nil)
foo.inspect # <Foo: delegated: nil>
```
