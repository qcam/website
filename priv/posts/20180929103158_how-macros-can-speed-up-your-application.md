{
  "title": "How macros could possibly speed up your Elixir application",
  "slug": "how-macros-could-speed-up-your-application",
  "datetime": "2018-09-29T10:31:58.413158Z"
}
---
This post showcases how the streaming part in Saxy is done, and how a recent speed-up was made thanks to macros.
---
[![marco-island](/assets/images/marco-island.jpg)](https://pixabay.com/en/marco-island-florida-nature-gulf-494679/)

<p style="text-align:center"><i><a href="https://pixabay.com/en/marco-island-florida-nature-gulf-494679/">Marco Island Florida</a> by Mariamichelle on Pixabay</i></p>

A few months ago, I wrote a blog post about [how Saxy was sped up by 15 times][previous-blog]. The article was to delineate how a practical application of binary optimizations can achieve a drastic increase in speed when parsing XML.

Besides of performance and speed, one of the highlighting features of [Saxy][saxy-github] is streaming. This feature supports parsing XML without loading the whole file in memory, which is **memory efficient** when parsing a large document.

In this blog post, I will showcase how the streaming part in Saxy is done, and how a recent speed-up was made thanks to macros.

Let's start off by checking out how a "common" parsing function looks like in Saxy.

```elixir
defp element_content_rest(<<"/", rest::bits>>, more?, original, pos, state) do
  close_tag_name(rest, more?, original, pos + 1, state, 0)
end

defp element_content_rest(<<"![CDATA[", rest::bits>>, more?, original, pos, state) do
  element_cdata(rest, more?, original, pos + 8, state, 0)
end

defp element_content_rest(<<"!--", buffer::bits>>, more?, original, pos, state) do
  element_content_comment(buffer, more?, original, pos + 3, state, 0)
end

defp element_content_rest(<<??, buffer::bits>>, more?, original, pos, state) do
  element_processing_instruction(buffer, more?, original, pos + 1, state, 0)
end

defhalt(:element_content_rest, 5, "")
defhalt(:element_content_rest, 5, "!")
defhalt(:element_content_rest, 5, "!-")
defhalt(:element_content_rest, 5, "![")
defhalt(:element_content_rest, 5, "![C")
defhalt(:element_content_rest, 5, "![CD")
defhalt(:element_content_rest, 5, "![CDA")
defhalt(:element_content_rest, 5, "![CDAT")
defhalt(:element_content_rest, 5, "![CDATA")

defp element_content_rest(<<_buffer::bits>>, _more?, original, pos, state) do
  # terminate and return parsing error.
end
```

This `element_content_rest` function will be invoked every time the parser sees a `<` token when parsing XML content, in order to decide which branch the parser should be taking next. For example, if the following token is `/`, we are getting a closing tag, `![CDATA[` means CDATA, `!--` shows that we are encountering an XML comment, and so on. This function terminates the parser and returns with a parsing error if it cannot match anything.

When it comes to streaming parsing, the current in-memory buffer could end with some dangling characters such as `<foo><` or `<foo><!`. With these dangling characters, the parser does not have enough information to determine which branch to go. It requires streaming some data to continue parsing.

There `defhalt` comes to rescue. `defhalt` is a macro that takes a function name, the function's arity and a binary token to generate a "halt" function, which will match the given binary and return a function that captures the current parsing context.

```elixir
defmacro defhalt(fun_name, arity, token) do
  params_splice = build_params_splice(token, arity)
  context_fun = build_context_fun(fun_name, token, arity)

  quote do
    defp unquote(fun_name)(unquote_splicing(params_splice)) do
      {:halted, unquote(context_fun)}
    end
  end
end
```

This way the caller of the parser can determine what to do next, either buffering more data to continue or terminating if there is no more data to buffer. That is basically how [streaming feature in Saxy works](https://github.com/qcam/saxy/blob/4c490b5ddbf637a0cdcf844ab3e7539856e39eec/lib/saxy.ex#L239).

Another case `defhalt` turns out to be very helpful is when we handle UTF-8 characters in `chardata` (characters inside XML elements) parsing.

```elixir
defp chardata(<<charcode, rest::bits>>, more?, original, pos, state, acc, len)
     when is_ascii(charcode) do
  chardata(rest, more?, original, pos, state, acc, len + 1)
end

Enum.each(utf8_binaries(), &defhalt(:chardata, 7, unquote(&1)))

defp chardata(<<charcode::utf8, rest::bits>>, more?, original, pos, state, acc, len) do
  chardata(rest, more?, original, pos, state, acc, len + Utils.compute_char_len(charcode))
end

defhalt(:chardata, 7, "")

defp chardata(<<_buffer::bits>>, _more?, original, pos, state, _acc, len) do
  # terminate and return parsing error.
end

def utf8_binaries() do
  [
    # Potentially 2-byte/3-byte/4-byte Unicode character.
    quote(do: <<1::1, rest_of_first_byte::7>>),
    # Potentially 3-byte/4-byte Unicode character.
    quote(do: <<1::1, 1::1, rest_of_first_byte::6, next_byte::1-bytes>>),
    # Potentially 4-byte Unicode character.
    quote(do: <<1::1, 1::1, 1::1, rest_of_first_byte::5, next_two_bytes::2-bytes>>)
  ]
end
```

Simply put is that when the parser sees _dangling Unicode characters_, it would need to go stream more data. If you are not familar with how Unicode works, I would recommend you to go read Nathan Long's [awesome post][utf8-blog].

Let's take these Chinese characters for example `二郎` (the name of a Chinese God called Erlang who has a third truth-seeing eye if you are curious), which is internally represented by `<<228, 186, 140, 233, 131, 142>>` in Elixir binary. In edge cases we have `<<228>>` or `<<228, 186>>` in the current buffer, nothing can be matched, but returning an error is wrong because the remaining bytes could eventually be streamed up in the next chunk of binary. Those UTF-8 "halt" functions generated by `defhalt` ensure that those dangling Unicode binaries are well handled.

But "halt" functions make the code less performant, because Erlang VM will evaluate these function clauses for every Unicode character in the XML document. If users are parsing a fully loaded document, these checks are relatively superfluous.

Recently I came up with an idea to fulfill both: [Allow user to turn off streaming feature in compile time](https://github.com/qcam/saxy/pull/30). If you do not need any streaming feature, you can configure to turn it off while it is on by default. A local benchmark on my computer showed that this tweak could speed up the parser by 8-10%, just by doing this.

```
config :saxy, streaming: false
```

This was quite simply done since `defhalt` is a marco. If the setting is off, `defhalt` simply ... does nothing by generating no code at all. Similar technique is done in [Elixir Logger](https://github.com/elixir-lang/elixir/blob/master/lib/logger/lib/logger.ex#L841-L849), which allows us to configure log levels.

```elixir
@parser_config Application.get_env(:saxy, :parser, [])

defmacro defhalt(fun_name, arity, token) do
  if streaming_enabled?(@parser_config) do
    params_splice = build_params_splice(token, arity)
    context_fun = build_context_fun(fun_name, token, arity)

    quote do
      defp unquote(fun_name)(unquote_splicing(params_splice)) do
        {:halted, unquote(context_fun)}
      end
    end
  end
end
```

Woohoo, macros FTW 🙌!

## Conclusion

So I have just walked you through how streaming parser in Saxy works. I hope it was a fun read and provided a fair example on how macros in Elixir could be applied to build up your library. Anyway as recommended by the Elixir documentation, code using macros are usually harder to read and should only be used as the last resort. So enjoy macros responsibly.

Happy coding! 💜💜💜💜💜


[previous-blog]: https://tech.forzafootball.com/blog/how-i-sped-up-my-xml-parser-by-15-times
[saxy-github]: https://github.com/qcam/saxy
[utf8-blog]: https://www.bignerdranch.com/blog/unicode-and-utf-8-explained/
