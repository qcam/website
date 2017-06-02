{
  "title": "UX for CLI app",
  "slug": "cli-ux",
  "date": "2017-03-12",
  "keywords": ["ux cli", "cli"],
  "tags": ["cli", "ux"],
  "description": "If you think an CLI app needs no UX, probably you are wrong."
}
---
As a terminal lover, I always want to get **everything** done on my terminal,
instead of switching to browser or an external app. I personally built up a
couple of CLI apps for my personal use (checkout
[worque](https://github.com/qcam/worque) and
[3llo](https://github.com/qcam/3llo)).
---
As a terminal lover, I always want to get **everything** done on my terminal,
instead of switching to browser or an external app. I personally built up a
couple of CLI apps for my personal use (checkout
[worque](https://github.com/qcam/worque) and
[3llo](https://github.com/qcam/3llo)).

I think every computer software needs UX, as long as it interacts with users.
So as a user and a developer, here are the experience I would love to see in an
ideal CLI app.

### I wish not to touch my mouse

Some people likes using terminal app because they want to avoid using mouses as
much as possible. Perhaps you think they are paranoid because mouse is one of
the best inventions in the computer era. But yes, note that when you design an
CLI app for other people.

### Do not mess up my environment variables

I have to admit environment variable is a handy way to start up a CLI app
development. You will see how much I love using them in my CLI apps too. But one
thing, be careful with naming because your environment variables could crash
with other CLI apps that share the same name like yours. That's a kaboom.

### Make sure you have `--help`

And keep it human readable and up-to-date. CLI users are supposed to be decently
comfortable with terminal, not all of us are professional hackers though.

### I expect a setup instruction

Let's say your app needs some sort of API tokens to get working, make sure your
documentation covers the instruction of how to get them, best with a link and
some screenshots.

### And most importantly, NEVER TRACK user behaviors

Yes, this is the **BEST** part of using an CLI app.
