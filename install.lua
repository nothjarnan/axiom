local function formatFS()
    for k, v in pairs(fs.list("AxiomUI")) do
        fs.move("AxiomUI/"..v, v)
    end
    fs.makeDir("home/Desktop")
    fs.makeDir("home/Documents")
    fs.makeDir("home/User-Programs")
    fs.makeDir("firstboot")
    fs.makeDir("users/apis")
    fs.makeDir("users/program-files")
    fs.makeDir("Axiom/logging")
    fs.delete("AxiomUI")
end

local version = os.version()
if version == "CraftOS 1.5" then
  error("Axiom is not compatible with "..version.."!")
end
print("AxiomUI Community Edition Minimal Installer")
print("Leave field blank for Nothy's repo. Type something for jasonthekitten (@EveryOS)'s repo"
    
local user = "nothjarnan"
local branch = "master"
if read() ~= "" then
    user = "jasonthekitten"
    print("Select branch")
    branch = read()
end
shell.run("pastebin run W5ZkVYSi "..user.." axiom-opensource "..branch.." AxiomUI")
formatFS()
