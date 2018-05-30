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
        print(v.." already exists.")
      end
    end
    fs.delete("AxiomUI")
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
local version = os.version()
if version == "CraftOS 1.5" then
  error("Axiom is not compatible with "..version.."!")
end
print("AxiomUI Community Edition Minimal Installer")
local branches = {
  "master",
  "experimental"
}
local continue = false
print("Select a branch:")
for k,v in ipairs(branches) do
  print("["..k.."] "..v)
end
while(true) do
  local e,k,h = os.pullEvent("key")
  if k > 2 and k < 11 and not continue then
    if k-1 < #branches then
      print(branch[k-1].. " was selected.")
      print("continue?")
    end
  end
  if continue then
    if k == 28 then
      continue = true
      break
    end
  end
end

local user = "nothjarnan"
local branch = "master"
if read() ~= "" then
    user = "jasonthekitten"
    print("Select branch")
    branch = read()
end
wget("http://www.pastebin.com/raw/w5zkvysi",".gitget")
shell.run(".gitget "..user.." axiom-opensource "..branch.." AxiomUI")
formatFS()
print("Installation completed.")
