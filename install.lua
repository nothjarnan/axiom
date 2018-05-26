local function formatFS()
  if fs.exists("AxiomUI") then
    for k, v in pairs(fs.list("AxiomUI")) do
        fs.move("AxiomUI/"..v, v)
    end
    mkdir("home/Desktop")
    mkdir("home/Documents")
    mkdir("home/User-Programs")
    mkdir("firstboot")
    mkdir("users/apis")
    mkdir("users/program-files")
    mkdir("Axiom/logging")
    fs.delete("AxiomUI")
  else
    error("formatFS failed")
  end
end
local function mkdir(dir)
  if not fs.exists(dir) then fs.makeDir(dir) end
end
local function wget(url, file)
  local data = http.get(url)
  data = data.readAll()
  local file_handle = fs.open(file,"w")
  file_handle.write(data)
  data.close()
  file_handle.close()

end
local version = os.version()
if version == "CraftOS 1.5" then
  error("Axiom is not compatible with "..version.."!")
end
print("AxiomUI Community Edition Minimal Installer")
print("Leave field blank for Nothy's repo. Type something for jasonthekitten (@EveryOS)'s repo")

local user = "nothjarnan"
local branch = "master"
if read() ~= "" then
    user = "jasonthekitten"
    print("Select branch")
    branch = read()
end
wget("http://www.pastebin.com/raw/w5zkvysi",".gitget")
shell.run("gitget "..user.." axiom-opensource "..branch.." AxiomUI")
formatFS()
