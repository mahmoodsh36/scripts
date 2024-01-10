local system = require 'pandoc.system'

exts_to_copy = { "jpg", "jpeg", "png", "svg", "gif", "webp" }

OUT_DIR = "static"

my_metadata = {}

function Meta(meta)
  for key, value in pairs(meta) do
    my_metadata[key] = value
  end
end

function Image(img)
  for i, ext in ipairs(exts_to_copy) do
    local infile = pandoc.system.environment()['infile']
    local indir = infile:match('/.*/')
    -- remove ./ from beginning of relative filepath (atleast incase its a relative one, anyway)
    local imgfile = img.src:gsub("file://", ""):gsub("^%./", "")
    -- if filepath begins with attachment, it is in the attachment's directory of the file, which depends on its id
    local id = my_metadata.id
    imgfile = imgfile:gsub("^attachment:", 'data/' .. string.sub(id, 1, 2) .. '/' .. string.sub(id, 3) .. '/')
    if indir ~= nil and string.match(imgfile, ".*" .. ext) ~= nil and string.match(imgfile, ".*attachment.*") == nil then
      pcall(system.make_directory, OUT_DIR)
      if string.match(imgfile, "^/") or string.match(imgfile, "^~") then
        -- if absolute path
        pandoc.pipe("cp", {imgfile, OUT_DIR}, "")
      else
        -- if relative path
        pandoc.pipe("cp", {indir .. "/" .. imgfile, OUT_DIR}, "")
      end
      --img.src = OUT_DIR .. "/" .. imgfile
      -- the path of <img> should just be "/<file.ext>" for the webserver to serve it
      img.src = "/" .. imgfile:gsub(".*/", "")
      table.insert(img.classes, 'figure')
      return img
    end
  end
  return img
end

-- make the Meta functions run before the latter
return {
  { Meta = Meta },
  { Image = Image }
}