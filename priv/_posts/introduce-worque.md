{
  "title": "Worque - CLI that manages your daily notes",
  "slug": "introduce-worque",
  "date": "2016-07-21",
  "keywords": ["worque", "productivity"],
  "tags": ["ruby", "productivity"],
  "description": "Worque is a CLI tool to manage all your daily notes like a boss, and (of course) vim-friendly."
}
---
I would like to introduce [Worque](https://github.com/qcam/worque) (pronounced as `work`),
which is a CLI to manage all your daily notes like a boss, with vim integration.
---
I would like to introduce [Worque](https://github.com/qcam/worque) (pronounced as `work`),
which is a CLI to manage all your daily notes like a boss, with vim integration.

### Why Worque?

**Coders hate report. Yes, let me recap: CODERS HATE REPORT!**

* Ever got stunned when your boss suddenly asked what you've done yesterday?
* To look back at your tasks for today without leaving your beloved terminal and VIM.

If so, worque might be a fit for you.

### Installation

```sh
$ gem install worque
```

### How to use Worque?

Add this to your `.bash_profile`

```sh
$ export WORQUE_PATH='/path/to/your/lovely/notes'
```

Personally I'd like to map it to my Dropbox.

```sh
$ export WORQUE_PATH='~/Dropbox/Notes/Todos'
```

After that, executing the command below will create a today's note for you

```sh
$ worque todo --for=today
# ~/notes/checklist-2016-07-19.md
```

Or look back what's done yesterday.

```sh
$ workque todo --for yebsterday
# ~/notes/checklist-2016-07-18.md
```

Oops! Today is Monday? No worries, worque got you covered

```sh
# If today is Monday 25-07-2016
$ workque todo --for yesterday
# ~/notes/checklist-2016-07-22.md
```

It's chain-able with other commands

```sh
$ vim worque
$ vim $(worque todo --for=yesterday)
$ cat $(worque todo --for=yesterday) | grep pending
```

Anyway this is how I alias it in my `.zshrc` or `.bash_profile`.
See [https://github.com/qcam/dotfiles/blob/master/zsh/aliases.zsh#L35](https://github.com/qcam/dotfiles/blob/master/zsh/aliases.zsh#L35)

```sh
$ alias today="vim $(worque todo --for today) +':cd $WORQUE_PATH'"
$ alias ytd="vim $(worque todo --for yesterday) +':cd $WORQUE_PATH'"
```

### Slack Integration

Yes, you can publish your daily notes to Slack too!

Just make sure you have set `SLACK_API_TOKEN` accordingly to spare your fingers typing everytime. See [this post](https://get.slack.help/hc/en-us/articles/215770388-Creating-and-regenerating-API-tokens) to get an idea of how to generate Slack API Token.

```sh
$ export SLACK_API_TOKEN="something-very-secret"
```

Then you can use `worque push` to push your notes to Slack

```sh
$ worque push --channel=daily-report

# or forgot do it yesterday? No worries!

$ worque push --channel=daily-report --for=yesterday
```

### VIM Integration

Yes, ***worque*** loves VIM too!!!

Add this to your vimrc

```viml
Plug 'qcam/vim-worque' # if you're using vim-plug
Plugin 'qcam/vim-worque' # or Vundle
```

Then try `:TD`, `:YTD` in your VIM to view the notes for today and yesterday respectively

### References

Read more about [worque](https://github.com/qcam/worque).
Read more about [vim-worque](https://github.com/qcam/vim-worque).
View more in my [dotfiles](https://github.com/qcam/dotfiles)

Happy Reporting!!!

Any thoughts or ideas are welcome!!!

