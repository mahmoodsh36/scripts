local stringify = pandoc.utils.stringify
local headers = {}

function collect (header)
  headers[stringify(header)] = header.identifier
end

function fix_spurious_link (span)
  print(span)
  if span.classes:includes 'spurious-link' then
    local content = span.content[1].content
    local target = span.attributes.target
    local header_target = headers[target:sub(2)]
    if header_target then
      return pandoc.Link(content, '#' .. header_target)
    end
  end
end

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

-- pandoc renders inline org links to spans with class "spurious-link" and target="<link target>"
-- this function attempts to fix this, converting them to proper links
function Span(span)
  -- print(dump(elem))
  if span.classes:includes 'spurious-link' then
    local content = span.content[1].content
    local target = span.attributes.target
    return pandoc.Link(content, '#' .. target)
  end
end

-- for the other function that filters the type `Link` to do its job, we need to give the 
function Block(elem)
  if elem.type == Div then
    --print(elem.attr)
  end
  -- print(dump(elem))
end