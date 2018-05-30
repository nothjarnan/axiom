local tArgs= {...}
-- Installer properties
local delete_files = false
local skip_branch_select = false
local reboot = false
local format = false

local user = "nothjarnan"
local branch = 1

-- Branches
local branches = {
  "master",
  "experimental"
}

for k,v in ipairs(tArgs) do
  if v == "-f" then
    format = true
  end
  if v == "-r" then
    reboot = true
  end
  if v == "-d" then
    delete_files = true
  end
  for a,b in ipairs(branches) do
    if v == b then
      branch = a
      skip_branch_select = true
      print("Selected branch "..b)
      break
    end
  end
end
if format then
  term.setTextColor(colors.red)
  print("WARNING")
  term.setTextColor(colors.white)
  print("Formatting your system *WILL* remove *EVERY* file from your computer, CONTINUE? (hold Y)")
  while(true) do
    local event, key, isHeld = os.pullEvent("key")
    if isHeld then
      if key == keys.y then
        print("Formatting.. ")
        local files = fs.list("/")
        for k,v in ipairs(files) do
          if v ~= "rom" and v ~= shell.getRunningProgram() then
            print("-"..v)
            fs.delete(v)
            sleep(.1)
            -- Wait a tiny bit to actually make it look like it's working.
            -- This is actually a scientifically proven thing, people are more trustworthy of things that 'look' like
            -- It's doing something, rather than something that actually does something. That's how ransomware works!
          end
        end
        print("Format complete")
        break
      else
        break
      end
    end
  end
end

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
    -- Ask for user confirmation unless specified
    if not delete_files then
      print("Press and hold Y to delete unused files. Press and hold any other key to exit")
      while(true) do
        local event, key, isHeld = os.pullEvent("key")
        if isHeld then
          if key == keys.y then
            write("Deleting files.. ")
            fs.delete("install.lua")
            fs.delete("README.md")
            sleep(.25)
            print("OK")
            break
          else
            break
          end
        end
      end
    else
      write("Deleting files.. ")
      fs.delete("install.lua")
      fs.delete("README.md")
      sleep(.25)
      print("OK")
    end
  else
    error("formatFS failed")
  end
end
local function wget(url, file)
  local data = http.get(url)
  if data ~= nil then
    data = data.readAll()
    local file_handle = fs.open(file,"w")
    file_handle.write(data)
    file_handle.close()
  else
    error("Could not download "..file..", quitting..")
  end
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
print("AxiomUI Github Superfast(tm) Installer")
if not skip_branch_select then
  print("Select a branch:")

  local x,y = term.getCursorPos()
  if y > 18 then
    shell.run("clear")
    print("Select a branch:")
    x,y = term.getCursorPos()
  end
  selector(y,branch)
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
end
wget("http://www.pastebin.com/raw/w5zkvysi",".gitget")
shell.run(".gitget "..user.." axiom-opensource "..branch.." AxiomUI")
formatFS()
print("Installation completed.")
if reboot then os.reboot() end
