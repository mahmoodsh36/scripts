--- source: https://github.com/oltolm/pandoc-latex-math

LATEX_OUTPUT_DIR = "ltx"

local system = require("pandoc.system")

local function starts_with(start, str)
  return str:sub(1, #start) == start
end

function appendDepthToSVGFile(depth, svgPath)
  local f = io.open(svgPath, "a")
  f:write(string.format("<!-- depth=%spt -->\n", depth))
  f:close()
end

function NewLatexRender()
  return {
    --\usepackage[active,tightpage]{preview}
    preamble = [[
\usepackage{colordvi}
\usepackage[active,tightpage]{preview}
\usepackage{\string~/.emacs.d/common}
        ]],
        --latexPath = "latex",
        latexPath = "dvilualatex",
        dvisvgmPath = "dvisvgm"
  }
end

function html2rgb(color)
  return ''
end

function wrapFormula(lr, latexFormula)
  --local bgcolor = lr.bgcolor ~= "#FFFFFF" and string.format("\\background{%s}\n", html2rgb(lr.bgcolor)) or ''
  local bgcolor = ''
  local tex = string.format([[\documentclass[preview]{standalone}
          %s
          \begin{document}\fontsize{12pt}{12pt}
\begin{preview}
          %s
\end{preview}
          \end{document}
          ]], lr.preamble, latexFormula)
  -- io.write(string.format("tex: [[%s]]\n", tex))
  return tex
end

function getDepth(out)
  local depth = string.match(out, "depth=(%d*%.?%d*)")
  return tonumber(depth)
end

function renderLatex(lr, latexFormula)
  local latexDocument = wrapFormula(lr, latexFormula)
  local currDir = system.get_working_directory()
  local svgFileName = pandoc.sha1(latexDocument) .. ".svg"
  pcall(system.make_directory, currDir .. "/" .. LATEX_OUTPUT_DIR)
  local svgPath = currDir .. "/" .. LATEX_OUTPUT_DIR .. "/" .. svgFileName
  local f = io.open(svgPath, "r")
  if f ~= nil then
    local depth = getDepth(f:read("a"))
    f:close()
    --io.write(string.format("found SVG file=%s with depth=%spt\n", svgPath, depth))
    return depth, LATEX_OUTPUT_DIR .. "/" .. svgFileName
  end
  -- SVG file does not exist
  local depth = system.with_temporary_directory("latexmath", function(tmpDir)
   return system.with_working_directory(tmpDir, function()
--    io.write(string.format("changed directory to (%s)\n", tmpDir))
    local tmpFile = io.open("latexmath.tex", "w")
    tmpFile:write(latexDocument)
    tmpFile:close()
    local out = command(lr, svgPath)
    local depth = getDepth(out)
    if depth == nil then
--      io.write(string.format("%s: depth not found\n", svgPath))
      return nil
    end
--    io.write(string.format("%s: depth=%spt\n", svgPath, depth))
    appendDepthToSVGFile(depth, svgPath)
    return depth
   end)
  end)
  return depth, LATEX_OUTPUT_DIR .. "/" .. svgFileName
end

function command(lr, svgPath)
  pandoc.pipe(lr.latexPath, {"--interaction=nonstopmode", "latexmath.tex"}, '')
  -- local out = pandoc.pipe(lr.dvisvgmPath, {"--no-fonts", "-o", svgPath, "latexmath.dvi"}, '')
  local f = io.popen(lr.dvisvgmPath .. " --no-fonts -o \"" .. svgPath .. "\" latexmath.dvi 2>&1")
  local out = f:read("a")
  f:close()
  -- io.write(string.format("out: [[%s]]\n", out))
  return out
end

function Math(elem)
  local latexFormula1
  local latexFormula = elem.text
  if elem.mathtype == "InlineMath" then
    latexFormula1 = string.format("\\(%s\\)", latexFormula)
  elseif elem.mathtype == "DisplayMath" then
    if not starts_with('\\begin{', elem.text) then
      latexFormula1 = string.format("\\[%s\\]", latexFormula)
    else
     latexFormula1 = string.format("%s", latexFormula)
    end
  end
  local lr = NewLatexRender()
  local depth, svgFilePath = renderLatex(lr, latexFormula1)
  local attr = {
    --alt = latexFormula,
    class = elem.mathtype
  }
  if depth ~= nil then
    attr["style"] = string.format("vertical-align:-%spt", depth)
  end
  -- io.write(string.format("%s\n", dump(attr)))
  return pandoc.Image('', '/' .. svgFilePath, '', attr)
end

function RawBlock(el)
  if starts_with('\\begin{', el.text) then
    return Math(pandoc.Math('DisplayMath', el.text))
  end
  return el
end


function dump(o)
  if type(o) == 'table' then
    local s = '{ '
    for k, v in pairs(o) do
      if type(k) ~= 'number' then
        k = '"' .. k .. '"'
      end
      s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
    end
    return s .. '} '
  else
    return tostring(o)
  end
end