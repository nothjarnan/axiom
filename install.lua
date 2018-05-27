local branches = {
  "master",
  "experimental"
}


local function formatFS()
  local function mkdir(dir)
    if not fs.exists(dir) then fs.makeDir(dir) end
  end
  if fs.exists("AxiomUI") then
    for k, v in pairs(fs.list("AxiomUI")) do
      if not fs.exists(v) then
        fs.move("AxiomUI/"..v, v)
        print("AxiomUI/"..v.." -> "..v)
      else
        print("AxiomUI/"..v.." -x>")
      end
    end
    fs.delete("AxiomUI")
    print("Delete extra files?")
    if read() == "y" then
      fs.delete("install.lua")
      fs.delete("README.md")
    end
  else
    error("formatFS failed")
  end
end
local function wget(url, file)
  local data = http.get(url)
  data = data.readAll()
  local file_handle = fs.open(file,"w")
  file_handle.write(data)
  file_handle.close()
end
function selector(y,option)
  term.setCursorPos(1,y)
  for k,v in ipairs(branches) do
    if k == option then
      write(v.. " <-")
      term.setCursorPos(1,y+k)
    else
      write(v.. "   ")
      term.setCursorPos(1,y+k)
    end
  end
end
local version = os.version()
if version == "CraftOS 1.5" then
  error("Axiom is not compatible with "..version.."!")
end
print("Axiom UI CE Installer")
print("Select a branch using arrow keys")
local x,y = term.getCursorPos()
if y > 17 then
  shell.run("clear")
  print("Axiom UI CE Installer")
  print("Select a branch using arrow keys")
  x,y = term.getCursorPos()
end
selector(y,1)
local user = "nothjarnan"
local branch = 1
while(true) do
  local e,k,h = os.pullEvent( "key" )
  if k == keys.up then
    if branch > 1 then
      branch = branch - 1
      selector(y,branch)
    end
  end
  if k == keys.down then
    if branch < #branches then
      branch = branch + 1
      selector(y,branch)
    end
  end
  if k == keys.enter then
    branch = branches[branch]
    print("Branch selected: "..branch)
    print("Starting installation")
    break
  end
end
wget("http://www.pastebin.com/raw/w5zkvysi",".gitget")
shell.run(".gitget "..user.." axiom-opensource "..branch.." AxiomUI")
formatFS()
print("Installation completed!")
