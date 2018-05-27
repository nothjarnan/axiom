local function loadURL(url)
  local h = http.get(url)
  local rtn = h:readAll()
  h:close()
  return rtn
end

local function dispMenu(m)
  term.setBackgroundColor(colors.cyan)
  term.clear()
  term.setCursorPos(1, 1)
  term.setBackgroundColor(colors.orange)
  for k, v in pairs(m) do
    term.clearLine()
    print(v)
  end
  while true do
    local e = {os.pullEvent("mouse_click")}
    if e[2] == 1 and m[e[4]] then return m[e[4]] end
  end
end

term.clear(colors.cyan)
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
local fr = dispMenu(forks)
local fork = "https://api.github.com/repos/"..fr

term.clear(colors.cyan)
term.setCursorPos(1, 1)
print("Finding branches...")
local branches = {}
local branchlist = jsonp.decode(fork.."/branches")
for k, v in pairs(branchlist) do
  table.insert(branches, v.name)
end
local br = dispMenu(branches)
local flist = fork.."/git/trees/"..br

term.clear(colors.cyan)
term.setCursorPos(1, 1)
print("Finding versions...")
local vers = {}
local verlist = jsonp.decode(flist.."?recursive=1")
for k, v in pairs(verlist.tree) do
  if (not string.match(v.path, "/")) and (v.type == "tree") then
    table.insert(vers, v.path)
  end
end

local version = dispMenu(vers)

term.clear(colors.cyan)
term.setCursorPos(1, 1)
print("INSTALLING...")
for k, v in pairs(verlist.tree) do
  if v.type == "blob" and v.path:find(version.."/") then
    local filecontent = loadURL("https://raw.githubusercontent.com/"..fr.."/"..br.."/"..v.path)
    local h = fs.open(string.sub(v.path, v.path:find("/")+1, #v.path), "w")
    h.write(filecontent)
    h.close()
  end
end

local h = fs.open("Axiom/version.0", "w")
h.write(textutils.serialize({
  branch = br,
  ver = version,
  fork = fr
}))
h.close()

local c = textutils.unserialize(loadURL("https://raw.githubusercontent.com/"..fr.."/"..br.."/version.cfg"))
if c.uponUpdate[version] then
  c.uponUpdate[version](true)
end
  

os.reboot()
