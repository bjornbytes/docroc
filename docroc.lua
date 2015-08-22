local rocdoc = {}

rocdoc.processors = {
  description = function(body)
    return {
      text = body
    }
  end,

  arg = function(body)
    local name = body:match('^%s*(%w+)') or body:match('^%s*%b{}%s*(%w+)')
    local description = body:match('%-%s*(.*)$')
    local optional, default
    local type = body:match('^%s*(%b{})'):sub(2, -2):gsub('(%=)(.*)', function(_, value)
      optional = true
      default = value
      return ''
    end)

    return {
      type = type,
      name = name,
      description = description,
      optional = optional,
      default = default
    }
  end
}

function rocdoc.process(filename)
  local file = io.open(filename, 'r')
  local text = file:read('*a')
  file:close()

  local comments = {}
  text:gsub('%s*%-%-%-(.-)\n([%w\n][^\n%-]*)', function(chunk, context)
    chunk = chunk:gsub('^%s*%-*%s*', ''):gsub('\n%s*%-*%s*', ' ')
    chunk = chunk:gsub('^[^@]', '@description %1')
    context = context:match('[^\n]+')

    local tags = {}
    chunk:gsub('@(%w+)%s?([^@]*)', function(name, body)
      local processor = rocdoc.processors[name]
      local tag = processor and processor(body) or {}
      tag.tag = name
      tag.raw = body
      table.insert(tags, tag)
    end)

    table.insert(comments, {
      tags = tags,
      context = context
    })
  end)

  return comments
end

return rocdoc
