docroc
===

Minimal library that parses formatted Lua comments and returns them as a table.

Usage
---

```lua
local docroc = require 'docroc'
local comments = docroc.process('file.lua')
```

`comments` is now a table of comment blocks in the file, each with a table of `tags` and a `context` key. The `tags` table is an array of the tags, but also groups the tags by type. The `context` key is a string containing the contents of the line after the comment block.

Notes on parsing:

- A comment block must start with three dashes. It ends on the next non-commented line.
- Tags are recognized as any sequence of letters that start with `@`, and continue until the next tag is encountered. The first tag is implicitly `@description`.

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
        raw = 'The person to greet.',
        text = 'The person to greet.'
      },
      [2] = {
        tag = 'arg',
        raw = '{string=} name - The person to greet',
        type = 'string',
        optional = true,
        name = 'name',
        description = 'The person to greet.'
      },
      [3] = {
        tag = 'returns',
        raw = '{number}',
        type = 'number'
      },
      description = {...},
      arg = {...},
      returns = {...}
    }
  }
}
```

Related
---

- [Locco](http://rgieseke.github.io/locco)
- [LDoc](https://github.com/stevedonovan/LDoc)

License
---

MIT, see [`LICENSE`](LICENSE) for details.
