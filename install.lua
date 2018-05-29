local function loadURL(url)
  local h = http.get(url)
  if not h then return "" end
  local rtn = h:readAll()
  h:close()
  return rtn
end

local function dispMenu(m, header)
  term.clear()
  term.setCursorPos(1, 1)
  local hs = (header and print(header)) or 0
  local l, h = term.getSize()
  while m[h-hs-1] do
    m[h-hs-1] = nil
  end
  local sel = 1
  local function reshow()
    for k, v in pairs(m) do
      term.clearLine()
      print(v, (sel == k and "<-") or "")
    end
  end
  while true do
    local e = {os.pullEvent("key")}
    if e[2] == keys.enter then return sel end
    if e[2] == keys.down and sel < #m then
  end
end

term.clear(colors.black)
term.setCursorPos(1, 1)

local jsonp = {
  decode = function(url)
    local str = loadURL(url)
    local s = str:gsub("\"([^\"]*)\"%s*:%s*", "%1 = "):gsub("%[", "{"):gsub("]", "}"):gsub("null", "nil")
    return textutils.unserialize(s)
  end
}


print("Finding forks...")
local forks = {"nothjarnan/axiom"}
local forklist = jsonp.decode("https://api.github.com/repos/nothjarnan/axiom/forks")
for k, v in pairs(forklist) do
  table.insert(forks, string.sub(v.url, 30, #v.url))
end
local fr = dispMenu(forks, "Please select a fork")
local fork = "https://api.github.com/repos/"..fr

term.clear(colors.black)
term.setCursorPos(1, 1)
print("Finding branches...")
local branches = {}
local branchlist = jsonp.decode(fork.."/branches")
for k, v in pairs(branchlist) do
  table.insert(branches, v.name)
end
local br = dispMenu(branches, "Please select a branch")
local flist = fork.."/git/trees/"..br

term.clear(colors.black)
term.setCursorPos(1, 1)
print("Discovering files...")
local verlist = jsonp.decode(flist.."?recursive=1")
print("INSTALLING...")
local blacklist = {
  ["install.lua"] = true,
  ["uponUpdate.lua"] = true,
  ["README.md"] = true,
  ["CurVersion"] = true
}
for k, v in pairs(verlist.tree) do
  if v.type == "blob" and not blacklist[v.name] then
    local filecontent = loadURL("https://raw.githubusercontent.com/"..fr.."/"..br.."/"..v.path)
    local h = fs.open(v.path, "w")
    h.write(filecontent)
    h.close()
  end
end

local h = fs.open("Axiom/version.0", "w")
h.write(textutils.serialize({branch = br, fork = fr, ver = loadURL("https://raw.githubusercontent.com/"..fr.."/"..br.."/CurVersion")}))
h.close()

textutils.unserialize("function(isInstalling) "..loadURL("https://raw.githubusercontent.com/"..fr.."/"..br.."/onUpdate.lua").." end")(true)
 
os.reboot()
