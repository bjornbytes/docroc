docroc
===

Minimal library that parses formatted Lua comments and returns them as a table.

Usage
---

```lua
local docroc = require 'docroc'
local comments = docroc.process('file.lua')
```

`comments` is now a table of comment blocks in the file, each with a table of `tags` and a `context`
key. The `tags` table is an array of the tags, but also groups the tags by type. The `context` key
is a string containing the contents of the line after the comment block.

Notes on parsing:

- A comment block must start with three dashes. It ends on the next non-commented line.
- Tags are recognized as any sequence of letters that start with `@`, and continue until the next
tag is encountered. The first tag is implicitly `@description`.

Example
---

Go from this:

```lua
--- Displays a friendly greeting.
-- @arg {string=} name - The person to greet.
-- @returns {number}
function greet(name)
  print('hi', name)
  return 3
end
```

to this:

```lua
{
  {
    context = 'function greet(name)',
    tags = {
      [1] = {
        tag = 'description',
        text = 'The person to greet.'
      },
      [2] = {
        tag = 'arg',
        text = '{string=} name - The person to greet',
        type = 'string',
        optional = true,
        name = 'name',
        description = 'The person to greet.'
      },
      [3] = {
        tag = 'returns',
        text = '{number}',
        type = 'number'
      },
      description = {...},
      arg = {...},
      returns = {...}
    }
  }
}
```

Processors
---

By default, when docroc finds a tag, it creates an entry with two keys: `tag` and `text`.  `tag`
contains the name of the tag and `text` contains the text after the tag.  This behavior can be
extended using the `docroc.processors` table:

```lua
docroc.processors.customTag = function(body)
  return {
    numberOfCharacters = #body,
    reversed = body:reverse()
  }
end
```

Now, if we process a file containing the following:

```lua
--- @customTag hello world
local test
```

We would get this:

```lua
{
  tag = 'customTag',
  text = 'hello world',
  numberOfCharacters = 11,
  reversed = 'dlrow olleh'
}
```

For convenience, docroc provides a default set of custom processors:

- `@arg`: Collects information on an argument to a function, including the `type` of the argument,
whether or not it is `optional`, whether or not it has a `default` value, its `name`, and a
`description`.  The expected structure is `@arg {<type>=<default>} <name> - <description>`, all of
which are optional.  An equals sign after the type represents an optional argument.
- `@returns`: Similar to `@arg`, contains information on a return value of the function.  It
returns `type` and `description` keys, and expects a structure of `@returns {<type>} <description>`.

Related
---

- [Locco](http://rgieseke.github.io/locco)
- [LDoc](https://github.com/stevedonovan/LDoc)

License
---

MIT, see [`LICENSE`](LICENSE) for details.
