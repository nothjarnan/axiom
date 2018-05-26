shell.run("clear")
if cclite then
  write("CCLITE SCALE? (1-10): ")
  local scale = tonumber(read())
  if cclite and scale >= 1 or scale <= 10 then cclite.setScale(scale) end
  term.redirect(term.native())
end

if turtle then
  error("Axiom cannot be run on a turtle, silly.")
end
--local ip = http.get("http://ipecho.net/plain")
local ip_processed = nil
if not ip_processed then
  ip_processed = "Unable to determine"
end
local hasRednet = false
local rednetDist = 999
local sides = {"front","back","left","right","top","bottom"}
local detectedSide = nil
local modem = nil
local dangerousStatus = false
_G.apiErrors = {

}

local dismissed = false
local remoteChannels = {}
local remoteSystemInfo = {}
local speakerSide = nil
local speakerPresent = false
local speaker = nil
local monitor = nil
local remoteInfo = {
  systemID = os.getComputerID(),
  sharingUpdates = true,
  sharingFiles = true,
  fileDirectory = "/home/",
}
for k,v in ipairs(sides) do
  if peripheral.isPresent(v) then
    if peripheral.getType(v) == "speaker" then
      speakerSide = v
      speakerPresent = true
      speaker = peripheral.wrap(v)
      speaker.playNote("harp",1, 1)
      break
    end
    if peripheral.getType(v) == "monitor" then
      monitor = peripheral.wrap(v)
    end
  end

end
if detectedSide ~= nil then
  hasRednet = true
  modem = peripheral.wrap(detectedSide)
  for i=0,7, 1 do
    modem.open(i)
    modem.transmit(i,1, "axfs")
  end

end
local tArgs = {...}
--oldPullEvent = os.pullEvent
os.pullEvent = os.pullEventRaw
if pocket then
  if fs.exists("Axiom/sys-pocket.axs") then
    fs.delete("startup")
    shell.run("Axiom/sys-pocket.axs")
  end
end

local mx, my = term.getSize()
fixNeeded = false
local fileselect = false
local force_logcat = false
local terminalActive = false
local nameColor = colors.green
local tildeColor = colors.cyan
local dircolor = colors.lightBlue
local restColor = colors.lightGray
local recoveryMode = true
if not term.isColor() then
  nameColor = colors.white
  tildeColor = colors.gray
  dircolor = colors.lightGray
  restColor = colors.white
end
--se
--setting.set( "shell.allow_disk_startup", false)
local files = "home/"
local previousDir = files
local drawers = {}
local booting = false
local invalidInstallation = false
local file = fs.list(files)
-- alert severeties =
--[[
  0 = normal/log
  1 = warning
  2 = error
  3 = system error

]]
alerts = {
}
-- For making sure the files are A-OK
local allfiles = { -- Protected files as well
  "startup",
  "Axiom/sys.axs",
  "Axiom/images/default.axg",
  "Axiom/images/AX.nfp",
  "Axiom/images/axiom.axg",
  "Axiom/images/nature.axg",
  "Axiom/libraries/setting",
  "Axiom/libraries/edge",
  "Axiom/libraries/encryption",
  "Axiom/settings.0",
  "Axiom/libraries/button",
}
bannedHashes = {
  "b4c38037365dd3183a485d18429363f371dcc1e5b0b4b71061c353537f51c1ed",
}
events = true
_G.currentUser = "KERNEL"
disableclock = true
useOldFS = false
updating = false
_G.productName = "Axiom UI"
_G.version_sub = " "
_G.version = "4.0"
_G.hasRootAccess = false
_G.unreleased = false
if _G.unreleased then
  _G.version = _G.version.." nightly"
end
_G.latestversion = version
announcement = ""
state = ""
tasks = {kernel=false,settings_app=false,permngr=false,clock=false,filebrowser=false}
demo = "Copper"
frames_rendered = 1
menubarColor = colors.white
menuBarColor_Dark = colors.gray
nightmode = false
when = "always"
delay = 20
if _G.unreleased == true then
  allow_background_change = true
else
  allow_background_change = true
end
if _G.unreleased == true then
  edition = "AXu"
else
  edition = "AX"
end

local forcing = false
local editing = false
local theme_topbar = colors.green -- green
local theme_ui = colors.lime --lime
x, y = term.getSize()
buttons = {}
buttonapi = {
    add = function(x1, y1, x2, y2, name)
        buttons[#buttons+1] = {x1, y1, x2, y2, name}
    end,
    check = function()
        _, _, x, y = os.pullEvent("mouse_click")
        sleep()
        for i = 1, #buttons do
            if x >= buttons[i][1] and y >= buttons[i][2] and x <= buttons[i][3] and y <= buttons[i][4] then
                return buttons[i][5]
            end
        end
    end,
    clear =  function()
      for i = 1, #buttons do
        buttons[i] = nil
      end
    end
}
text = {
    format = function(str, x0, y0)
        repeat
            y0 = y0+1
            term.setCursorPos(x0, y0)
            p = string.sub(str, 0, x-2)
            term.write(p)
            str = string.sub(str, x-1, -1)
        until string.len(str) == 0
        return term.getCursorPos()
    end
}
--local settings_tips = {"Unreleased"}
-- New print functions:
function printwarn(text)
  if edge then
    if edge.hasScreen() then
      edge.printwarn(text)
    end
  end
  term.setTextColor(colors.gray)
  write("[")
  term.setTextColor(colors.orange)
  write("WARN")
  term.setTextColor(colors.gray)
  write("]")
  term.setTextColor(colors.white)
  print(" "..text)
  sleep(0.1)
end
function printerr(text)
  if edge then
    if edge.hasScreen() then
      edge.printerr(text)
    end
  end
  term.setTextColor(colors.gray)
  write("[")
  term.setTextColor(colors.red)
  write("ERROR")
  term.setTextColor(colors.gray)
  write("]")
  term.setTextColor(colors.white)
  print(" "..text)
  sleep(0.1)
end
function printout(text)
  if edge then
    if edge.hasScreen() then
      edge.printout(text)
    end
  end
  term.setTextColor(colors.gray)
  write("[")
  term.setTextColor(colors.green)
  write("INFO")
  term.setTextColor(colors.gray)
  write("]")
  term.setTextColor(colors.white)
  print(" "..text)
  sleep(0.1)
end

--
function errorMessager(errmsg)
  if not fs.exists("safeStart") then fs.makeDir("safeStart") end
  local ok = edge.windowAlert(25,8,"An application errored out. \n"..errmsg.."\nReport?",false,colors.red)
  if ok then
      local h = http.post("http://nothy.000webhostapp.com/bugreport.php","uid="..textutils.urlEncode(tostring(setting.variables.temp.debugID)).."&brep="..textutils.urlEncode(tostring(errmsg.." <br> Version: "..productName.." "..version.." <br> dev: "..tostring(_G.unreleased).."<br> IsColor:"..tostring(term.isColor()).."<br> Last updated: Day "..tostring(setting.variables.temp.last_update))))
  end
  if currentUser ~= "KERNEL" then
    if state == "desktop" then
      desktop()
    else
      login_gui_unreleased()
    end
  end
end

function errorHandler(err)
  if not fs.exists("/safeStart") then
    fs.makeDir("/safeStart")
  end

  shell.run("clear")
  print("Well, this is embarrassing.")
  print("Looks like Axiom crashed. Here's some useful information to provide the debugging monkey team:")
  print(err)
  print(productName.." "..version.." "..version_sub)
  print(currentUser)
  print("If you're not quite sure what to do with this, just screenshot it.")
end
axiom = {}
function axiom.alert(string, alertsev)
  local usedprefix = "[log]"
  if alertsev == nil then alertsev = 0 end
  if alertsev == 0 then
    usedprefix = "[log]"
  end
  if alertsev == 1 then
    usedprefix = "[warn]"
  end
  if alertsev == 2 then
    usedprefix = "[error]"
  end
  if alertsev == 3 then
    usedprefix = "[syserror]"
    edge.render(1,3,51,5,colors.white,colors.cyan," Critical alert",colors.black)
    edge.render(1,4,51,4,colors.white,colors.cyan,string,colors.black,false)
  end
  edge.log("Alert: "..usedprefix..":"..string)
  edge.notify(usedprefix..":"..string)
  local h = http.post("http://nothy.000webhostapp.com/bugreport.php","uid="..textutils.urlEncode(tostring(setting.variables.temp.debugID)).."&brep="..textutils.urlEncode(tostring(usedprefix..":"..string)))
  alerts[#alerts+1] = {
    severity = alertsev,
    prefix = usedprefix,
    text = string,
  }
end

function checkForUpdates()
  local success = false
  updated = false
  if setting.variables.temp.autoupdate then
    when = "always"
  else
    when = "never"
  end

  if not delay then
    delay = 30
  end
    if version == "1.0.3" then
      edge.windowAlert(10,10,"Checking for updates.",true)
    end
    setting.variables.temp.last_updatecheck = tonumber(""..os.day())

    setting.variables.temp.last_update = tonumber(""..os.day())
    writesettings()
    if updated == false then
      if when == "always" then
        --axiom.alert("Checking for updates! (Mode: "..when..")",0)

        if not latestversion then
          axiom.alert("Error: Could not connect to server: http://www.nothy.se/! (FATAL)",3)
          edge.log("Error: Could not connect to server: http://www.nothy.se/ ! (FATAL)")
          if edge.getOverlay() then
            edge.render(mx-9,1,mx-9,1,menubarColor,colors.cyan,"VCx",colors.green)
          end
        else
          if nv ~= version and not _G.unreleased and nv ~= nil then
            local nUpd = false
            updated = true
            local initialan = setting.variables.temp.enable_animations
            setting.variables.temp.enable_animations = false
            sleep(2.5)
            if not edge.windowAlert(25,9,"Version "..tostring(latestversion.readAll()).." (current "..tostring(version)..") is now available for download. Install?", false) then
              nUpd = true
              desktop()
            else
              edge.windowAlert(25,9,"Installing.", "noButton")
              _G.unreleased = false
            end
            setting.variables.temp.enable_animations = initialan
            if not nUpd then
              --edge.notify(notifContent)
              edge.log("Update available")
              if setting.getVariable("Axiom/settings.0","first_update") == "false" then
                setting.setVariable("Axiom/settings.0","first_update","true")
              end
              if fs.exists("Axiom/backup/os/settings.0") then
                fs.delete("Axiom/backup/os/settings.0")
                fs.copy("Axiom/settings.0","Axiom/backup/os/settings.0")
              else
                fs.copy("Axiom/settings.0","Axiom/backup/os/settings.0")
              end
              if edge.getOverlay() then
                edge.render(mx-9,1,mx-9,1,menubarColor,colors.cyan,"DL",colors.green)
              end
              download("https://www.dropbox.com/s/a7fp2jo6tgm7xsy/startup?dl=1","startup")
              sleep(0.1)
              if _G.unreleased == false then
                download("https://www.dropbox.com/s/7mzhcfe53dm2rq5/sys.axs?dl=1","Axiom/sys.axs")
              else
                download("https://www.dropbox.com/s/5v2amjjmw08n9yz/sys-latest.axs?dl=1","Axiom/sys.axs")
              end
              sleep(0.1)
              download("https://www.dropbox.com/s/9byakcx77k03yji/setting?dl=1","Axiom/libraries/setting")
              sleep(0.1)
              download("https://www.dropbox.com/s/a5kxzjl6122uti2/edge?dl=1","Axiom/libraries/edge")
              sleep(0.1)
              download("https://www.dropbox.com/s/p3kgkzhe27vr9lj/encryption?dl=1","Axiom/libraries/encryption")
              if not fs.exists("Axiom/settings.0") then
                axiom.alert("Settings file not found, fixing..",3)
                download("https://www.dropbox.com/s/ynyrs22t1hh2mry/settings?dl=1","Axiom/settings.0")
                sleep(0.1)
              end

              download("https://www.dropbox.com/s/t40vz4gvmyrcjv4/background.axg?dl=1","Axiom/images/default.axg")
              download("https://www.dropbox.com/s/cjahddofwhja8og/axiom.axg?dl=1","Axiom/images/axiom.axg")
              download("https://www.dropbox.com/s/osz72e1rnvt5opl/nature.axg?dl=1","Axiom/images/nature.axg")
              download("https://www.dropbox.com/s/wi4n0j98d82256f/AX.nfp?dl=1","Axiom/images/AX.nfp")
              download("https://www.dropbox.com/s/pe72iyt94jfs9tv/settings?dl=1","Axiom/programs/settings.app")
              sleep(0.1)
              edge.windowAlert(25,9,"Done installing.", true)
              if edge.windowAlert(25,9,"Reboot?", false) then
                os.reboot()
              else
                desktop()
              end
            else

              if not forcing then
                if setting.variables.users[currentUser].background == "black" then
                  edge.render(1,1,mx,19,colors.black,colors.cyan,"",colors.black,false)
                else
                  edge.image(1,1,setting.variables.users[currentUser].background,colors.cyan)
                end
              end
              edge.render(1,1,mx,1,menubarColor,colors.cyan," o*",colors.gray,false)
              state = "main_gui"
              local x_p = 4
              --edge.render(1,1,mx,19,colors.cyan,colors.cyan,"",colors.black,false)
              edge.render(1,1,mx,1,menubarColor,colors.cyan," o*",colors.gray,false)

            end
          end
        end
      end
    end
end
function modemHandler()
  -- Handle peripheral
  while(true) do
    local event, side = os.pullEvent("peripheral")
    edge.windowAlert(25,10,"New peripheral attached on side "..side.. " of type "..peripheral.getType(side).."!", true, colors.green)
    sleep(4)
  end
end
function keyStrokeHandler()
  local keystrokes = {
    0,
  }
  while(true) do
    local event, key, isHeld = os.pullEvent("key")

    if #keystrokes > 150 then
      keystrokes = {}
    end
    if keys.getName(key) == "f8" and isHeld then
      -- Super secret hidden menu stuff yes
      edge.windowAlert(25,10,"no",false,colors.orange)

    end
    table.insert(keystrokes, key)

    if #keystrokes >= 2 then
      --print(keystrokes[#keystrokes-2], keystrokes[#keystrokes-1], keystrokes[#keystrokes], isHeld)
      if keystrokes[#keystrokes-1] == 42 and keystrokes[#keystrokes] == 32 and isHeld then
        if currentUser ~= nil then
          if fs.exists("Axiom/programs/store.app") and invalidInstallation == false then

            shell.run("Axiom/programs/store.app")
          end
        end
      end
      if keystrokes[#keystrokes-1] == 42 and keystrokes[#keystrokes] == 20 and isHeld then
        terminal("/")

      end
      if keystrokes[#keystrokes-1] == 42 and keystrokes[#keystrokes] == 33 and isHeld then
        if fs.exists("Axiom/programs/explorer.app") and invalidInstallation == false then
          shell.run("Axiom/programs/explorer.app")
        end
        --filebrowser("/")

      end
      if keystrokes[#keystrokes-2] == 42 and keystrokes[#keystrokes] == 60 then
        write("NYI")
      end
    end
    if #keystrokes >= 3 then
      if keystrokes[#keystrokes-2] == 29 and keystrokes[#keystrokes-1] == 42 and keystrokes[#keystrokes] == 22 then
        updating = true
        execUpd()
        updating = false
      end
    end
  end
  axiom.alert("keyStrokeHandler killed",3)
end
function clock()

end
function notifHandler()

  -- This handles notifications

end
function noapidl(url, file)
  --edge.xprint("Downloading "..file.."..",2,18,colors.white)
  --edge.render(1,18,1,18,colors.cyan,colors.cyan,"Downloading "..file.."..",colors.white)

    --if not args[1] == "silent" and args[1] == nil then
    --print("Opening file "..file)
      fdl = http.get(url)
      f = fs.open(file,"w")
      f.write(fdl.readAll())
      f.close()
      --edge.xprint(" Done",1+string.len("Downloading "..file..".."),18,colors.white)
      --edge.render(2+string.len("Downloading "..file..".."),18,2+string.len("Downloading "..file.."..")+3,18,colors.cyan,colors.cyan,"Done ",colors.white)
      sleep(1)
      --edge.xprint("                                                  ",1,18,colors.white)

    --print("Written to file "..file)

end
function writesettings()
  local vars = setting.variables
  --print(textutils.serialise(vars))
  local s = textutils.serialise(vars)
  local fh = fs.open("Axiom/settings.0","w")
  fh.write(s)
  fh.close()
end
function download(url, file, logOutput)

  if logOutput then
    write("Downloading "..file..".. ")
  end
  --edge.xprint("Downloading "..file.."..",2,18,colors.white)
  --edge.render(1,18,1,18,colors.cyan,colors.cyan,"Downloading "..file.."..",colors.white)
  edge.log("Downloading from "..url..", saving to "..file)
  if fs.getFreeSpace("/") <= 1024 then
    --edge.render(1,18,1,18,colors.cyan,colors.cyan,"Warning: Low space on disk!",colors.orange)
    edge.xprint("Warning: Low space on disk! "..fs.getFreeSpace("/") / 1024 .."kb",1,18,colors.orange)
  end
  if not http then
    if speakerPresent then
      speaker.playNote("harp",1, 1)
      speaker.playNote("harp",1, 1)
      speaker.playNote("harp",1, 1)
    end
    edge.render(16,7,34,12,colors.white,colors.cyan,"",colors.black,true)
    --edge.render(17,8,34,8,colors.white,colors.cyan,"Welcome to Axiom!",colors.black,false)
    edge.render(17,9,34,9,colors.white,colors.cyan," (!) Fatal error",colors.red,false)
    edge.render(16,10,34,10,colors.white,colors.cyan,"HTTP_DISABLED",colors.orange,false)
    return false
  else




    if fs.getFreeSpace("/") <= 10 then
      --error("No space left")
      if logOutput then
        term.setTextColor(colors.red)
        write(" FAILED\n")
        term.setTextColor(colors.white)
      end
      return false
    end
    --if not args[1] == "silent" and args[1] == nil then
    --print("Opening file "..file)
    if setting.variables.users[currentUser].allow_downloads or setting.variables.users[currentUser].allow_downloads == nil  then
      fdl = http.get(url)
      if not fdl then
        if logOutput then
          term.setTextColor(colors.red)
          write("FAILED\n")
          term.setTextColor(colors.white)
        end
        return false
        --sleep(1)
      end
      f = fs.open(file,"w")
      f.write(fdl.readAll())
      f.close()
      if logOutput then
        term.setTextColor(colors.green)
        write(" OK\n")
        term.setTextColor(colors.white)
      end
      return true
      --edge.xprint(" Done",1+string.len("Downloading "..file..".."),18,colors.white)
      --edge.render(2+string.len("Downloading "..file..".."),18,2+string.len("Downloading "..file.."..")+3,18,colors.cyan,colors.cyan,"Done ",colors.white)
      --sleep(1)
      --edge.xprint("                                                  ",1,18,colors.white)
    else
      if logOutput then
        term.setTextColor(colors.red)
        write(" FAILED\n")
        term.setTextColor(colors.white)
      end
    end
    edge.log("Done downloading "..file)
  end

end
function execUpd(isTerminal)
  local out = false
  local success = false
  --setting.setVariable("Axiom/settings.0","system_last_update","Day "..os.day().." @ "..edge.c())

  if not success and isTerminal then write("Update not set up yet.\n") end
  if speakerPresent then
    speaker.playNote("harp",1, 1.5)
  end
  sleep(0.1)
  return success
end
function login_clock()
  local mx, my = term.getSize()
  local time = textutils.formatTime(os.time(),false)

  while(true) do
    if cclite then
      time = textutils.formatTime(os.time("local"),false)
    else
      time = textutils.formatTime(os.time(),false)
    end
    if state == "login_gui" then
      edge.render((mx-1)-string.len(time),2,mx-1,2,colors.lightBlue, colors.lightBlue,time,colors.white)
    end
    sleep(.5)
  end
end
function login_gui_unreleased()
  state = "login_gui"
  local attempt = 1
  local mx, my = term.getSize()
  local users = setting.variables.users
  local userButtons = {
  }
  local tstep = 0
  for k,v in pairs(users) do
    if k ~= "KERNEL" and k ~= "GUEST" and currentUser == "KERNEL" then currentUser = k end
    if k ~= "KERNEL" then
      if k ~= "GUEST" then
        userButtons[k] = {
          x = 2, y = 4+tstep,
          ex = 15, ey = 7+tstep,
          display = v.displayName,
        }
      elseif setting.variables.temp.enable_guest_login == true then
        userButtons["GUEST"] = {
          x = 2, y = 4+tstep,
          ex = 15, ey = 7+tstep,
          display = "Guest",
        }

      end
      tstep = tstep +3
    end

  end
  -- if #users < 2 then
  --   -- Completely skip if there's only one registered user with no password.
  --   if users[currentUser].password == encryption.sha256("nopassQxLUF1bgIAdeQX") then
  --     state = desktop()
  --     desktop()
  --   end
  -- end
  local showuserlist = false
  local menu = false
  local redraw = false
  edge.render(1,1,mx,my, colors.lightBlue,colors.lightBlue,"")
  edge.render(3,2,3,2,colors.lightBlue,colors.lightBlue,"o*",colors.white)
  if setting.variables.users[currentUser].password ~= encryption.sha256("nopassQxLUF1bgIAdeQX") then
    edge.render((mx/2)-8, 9, (mx/2)+8, 9, colors.lightGray, colors.lightBlue," Password..", colors.gray, false)
  else
    edge.render((mx/2)-8, 9, (mx/2)+8, 9, colors.lightBlue, colors.lightBlue,"", colors.gray, false)
    edge.render((mx/2)-5, 9, (mx/2)+5, 9, colors.lightGray, colors.lightBlue,"   Login", colors.gray, false)
  end
  term.setTextColor(colors.white)
  if currentUser == nil then currentUser = "KERNEL" end
  edge.cprint(tostring(userButtons[currentUser].display),7)
  edge.render(3,my-2,3,my-2,colors.lightBlue,colors.lightBlue,"Not you?", colors.white)
  while(true) do
    if redraw then
      showuserlist = false
      menu = false
      edge.render(1,1,mx,my, colors.lightBlue,colors.lightBlue,"")
      edge.render(3,2,3,2,colors.lightBlue,colors.lightBlue,"=",colors.white)
      if setting.variables.users[currentUser].password ~= encryption.sha256("nopassQxLUF1bgIAdeQX") then
        edge.render((mx/2)-8, 9, (mx/2)+8, 9, colors.lightGray, colors.lightBlue," Password..", colors.gray, false)
      else
        edge.render((mx/2)-8, 9, (mx/2)+8, 9, colors.lightBlue, colors.lightBlue,"", colors.gray, false)
        edge.render((mx/2)-5, 9, (mx/2)+5, 9, colors.lightGray, colors.lightBlue,"   Login", colors.gray, false)
      end
      term.setTextColor(colors.white)
      edge.cprint(userButtons[currentUser].display,7)
      edge.render(3,my-2,3,my-2,colors.lightBlue,colors.lightBlue,"Not you?", colors.white)
      redraw = false

    end
    local e,b,x,y = os.pullEvent()
    if e == "mouse_click" then
      if x == 1 and y == 1 then
        os.reboot()
      end
      if x >= 2 and x <= 4 and y == 2 then
        menu = not menu
      end

      if x >= (mx/2)-8 and x <= (mx/2)+8 and y == 9 then
        if setting.variables.users[currentUser].password ~= encryption.sha256("nopassQxLUF1bgIAdeQX") then
          edge.render((mx/2)-8, 9, (mx/2)+8, 9, colors.lightGray, colors.lightBlue,"", colors.gray, false)
          term.setTextColor(colors.gray)
          term.setBackgroundColor(colors.lightGray)
          state = "login_gui-w"
          local pw = encryption.sha256(read("*").."QxLUF1bgIAdeQX")
          state = "login_gui"
          if setting.variables.users[currentUser].password == pw and attempt <= 3  then
            state = "desktop"
            desktop()
          else
            attempt = attempt + 1
            edge.render((mx/2)-8, 9, (mx/2)+8, 9, colors.red, colors.lightBlue,"", colors.gray, false)
            sleep(0.5)
            edge.render((mx/2)-8, 9, (mx/2)+8, 9, colors.lightGray, colors.lightBlue,"", colors.gray, false)
            if attempt >= 3 then
              edge.render((mx/2)-8, 9, (mx/2)+8, 9, colors.black, colors.lightBlue,"Locked for 30s", colors.white, false)
              for i=30,0,-1 do
                sleep(1)
                edge.render((mx/2)-8, 9, (mx/2)+8, 9, colors.black, colors.lightBlue,"Locked for "..i.."s", colors.white, false)
              end
              edge.render((mx/2)-8, 9, (mx/2)+8, 9, colors.lightGray, colors.lightBlue," Password..", colors.gray, false)
            end
          end
        else
          state = "desktop"
          desktop()
        end
      end
      if x >= 2 and x <= 15 and y >= my-3 and y <= my-1 then
        edge.render(2,my-3,15,my-1,colors.gray,colors.lightBlue,"", colors.white)
        edge.render(3,my-2,11,my-2,colors.gray,colors.lightBlue,"Not you?", colors.white)
        showuserlist = not showuserlist
      end
      if showuserlist then
        edge.render(2,my-15,15,my-4,colors.gray,colors.lightBlue,"", colors.white)
        local step = 0
        for k,v in pairs(userButtons) do

            edge.render(v.x, v.y , v.ex, v.ey, colors.gray, colors.black, "" , colors.black)
            edge.render(v.x+1, v.y+1, v.ex, v.ey-1, colors.gray, colors.black, ""..tostring(v.display).."" , colors.white)

        end
      else
        edge.render(2,my-15,15,my-4,colors.lightBlue,colors.lightBlue,"", colors.white)
      end
      if menu then
        edge.render(2,2,12,5,colors.gray,colors.gray,"",colors.white)
        edge.render(3,2,3,2,colors.gray,colors.gray,"o*",colors.white)

        edge.render(3,3,8,3,colors.gray,colors.gray,"Shutdown",colors.white)
        edge.render(3,4,5,4,colors.gray,colors.gray,"Reboot",colors.white)
      else
        edge.render(2,2,12,3,colors.lightBlue,colors.lightBlue,"",colors.white)
        edge.render(3,2,3,2,colors.lightBlue,colors.lightBlue,"o*",colors.white)
      end
      if showuserlist then
        for k,v in pairs(userButtons) do
          --print(tostring(edge.aabb(x,y,v.x,v.y,v.ex,v.ey)))
          if edge.aabb(x,y,v.x,v.y,v.ex,v.ey) then
            currentUser = k
            --if setting.variables.users[currentUser].password == encryption.sha256("nopassQxLUF1bgIAdeQX") then
              redraw = true
            --end
            edge.render(v.x, v.y , v.ex, v.ey, colors.lightGray, colors.black, "" , colors.black)
            term.setBackgroundColor(colors.lightGray)
            edge.xprint(tostring(v.display),v.x+1,v.y+1,colors.white)
            term.setTextColor(colors.white)
            term.setBackgroundColor(colors.lightBlue)
            edge.cprint(currentUser,7)
            break
          end
        end
      end
    end
    if e == "mouse_up" then
      if edge.aabb(x,y,3,3,10,3) and menu then
        edge.render(1,1,mx,my, colors.lightBlue,colors.lightBlue,"",colors.white)
        term.setTextColor(colors.white)
        edge.cprint("Shutting down..",my/2)
        sleep(2.5)
        os.shutdown()
      end
      if edge.aabb(x,y,3,4,10,4) and menu then
        os.reboot()
      end
      if showuserlist then
        edge.render(2,my-3,15,my-1,colors.gray,colors.lightBlue,"", colors.white)
        edge.render(3,my-2,11,my-2,colors.gray,colors.lightBlue,"Not you?", colors.white)
      end
      if x >= 2 and x <= 15 and y >= my-3 and y <= my-1 and not showuserlist then
        edge.render(2,my-3,15,my-1,colors.lightBlue,colors.lightBlue,"", colors.white)
        edge.render(3,my-2,11,my-2,colors.lightBlue,colors.lightBlue,"Not you?", colors.white)
      end
      if showuserlist then
        for k,v in pairs(userButtons) do
          --print(tostring(edge.aabb(x,y,v.x,v.y,v.ex,v.ey)))
          if edge.aabb(x,y,v.x,v.y,v.ex,v.ey) then
            edge.render(v.x, v.y , v.ex, v.ey, colors.gray, colors.black, "" , colors.black)
            term.setBackgroundColor(colors.gray)
            edge.xprint(tostring(v.display),v.x+1,v.y+1,colors.white)
            --edge.render(v.x+1, v.y+1, v.ex, v.ey-1, colors.gray, colors.lightBlue, ""..tostring(v.display).."" , colors.white)
            break
          end
        end
      end
    end
  end
end
function login_gui() -- TO BE CONVERTED TO NEW SETTINGS SYSTEM.
  local attempts = 0
  if setting.variables.temp.enable_animations and state ~= "login_gui" then
    edge.render(1,1,mx, my, colors.black, colors.white, "", colors.black)
    sleep(0.1)
    edge.render(1,1,mx, my, colors.gray, colors.white, "", colors.black)
    sleep(0.1)
    edge.render(1,1,mx, my, colors.lightGray, colors.white, "", colors.black)
    sleep(0.1)
    edge.render(1,1,mx, my, colors.cyan, colors.white, "", colors.black)
    sleep(0.1)
  end
  state = "login_gui"
  usr = ""
  pass = ""
  currentUser = "KERNEL"
  tasks.clock = false
  edge.image(1,1,setting.variables.users[currentUser].background,colors.cyan)
  edge.render(1,1,mx,1,menubarColor,colors.cyan," o*",colors.gray,false)

  edge.render(18,7,33,12,colors.white,colors.cyan," Login", colors.black)
  edge.render(20,9,30,9,colors.lightGray,colors.cyan,"Username",colors.gray)
  edge.render(20,11,30,11,colors.lightGray,colors.cyan,"Password",colors.gray)
  edge.render(32,9,32,11,colors.lightGray,colors.cyan,"", colors.gray)
  edge.render(32,10,32,10,colors.lightGray,colors.cyan,">", colors.white)

    while(true) do

      local event, button, x, y = os.pullEvent("mouse_click")
      if event == "terminate" then
        edge.log("Termination event caught!")
        if hasRednet then
          rednet.close(detectedSide)
        end
        os.shutdown()
      end
      if x == 18 and y == 7 then
        if hasRednet then
          rednet.close(detectedSide)
        end
        os.shutdown()
      end
      if x >= 20 and x <= 30 and y == 9 then --#Error
        edge.render(20,9,30,9,colors.lightGray,colors.cyan,"",colors.gray)
        term.setCursorPos(20,9)
        term.setTextColor(colors.black)
        term.setBackgroundColor(colors.lightGray)
        usr = io.read()
        currentUser = usr
      end
      if x >= 20 and x <= 30 and y == 11 then
        edge.render(20,11,30,11,colors.lightGray,colors.cyan,"",colors.gray)
        term.setCursorPos(20,11)
        term.setTextColor(colors.black)
        term.setBackgroundColor(colors.lightGray)
        pass = read("*")
        pass = encryption.sha256(pass.."QxLUF1bgIAdeQX")
      end
      if x >= 32 and x <= 32 and y >= 9 and y <= 11 then
        for k,v in pairs(setting.variables.users) do
          if usr == k and usr ~= "KERNEL" then
            edge.log("usr "..usr.." k "..k)
            if v.password == encryption.sha256("nopassQxLUF1bgIAdeQX") then

              currentUser = k
              parallel.waitForAll(desktop,checkForUpdates) --NOTE: DO NOT FUCKING CHANGE THIS YA TWATS
              break
            end
            if pass == v.password then
              currentUser = k
              parallel.waitForAll(desktop,checkForUpdates) --NOTE: DO NOT FUCKING CHANGE THIS YA TWATS
              break
            else
              if attempts < 3 then
                attempts = attempts + 1
                usr = ""
                pass = ""

                edge.render(18,7,33,12,colors.red,colors.cyan," Attempt "..attempts.."/3", colors.black)
                edge.render(20,9,30,9,colors.lightGray,colors.cyan,"Username",colors.gray)
                edge.render(20,11,30,11,colors.lightGray,colors.cyan,"Password",colors.gray)
                edge.render(32,9,32,11,colors.lightGray,colors.cyan,"", colors.gray)
                edge.render(32,10,32,10,colors.lightGray,colors.cyan,">", colors.white)
                sleep(0.25)
                edge.render(18,7,33,12,colors.white,colors.cyan," Attempt "..attempts.."/3", colors.black)
                edge.render(20,9,30,9,colors.lightGray,colors.cyan,"Username",colors.gray)
                edge.render(20,11,30,11,colors.lightGray,colors.cyan,"Password",colors.gray)
                edge.render(32,9,32,11,colors.lightGray,colors.cyan,"", colors.gray)
                edge.render(32,10,32,10,colors.lightGray,colors.cyan,">", colors.white)
                if speakerPresent then
                  speaker.playNote("harp",1, 1.8)
                  sleep(.1)
                  speaker.playNote("harp",1, 1.8)
                  sleep(.1)
                  speaker.playNote("harp",1, 1.8)
                end
                break
              else
                edge.windowAlert(10,8,"Too many attempts. Please try again later.",true, colors.red)
                os.shutdown()
              end
            end
          end
        end

      end
      if x >= 1 and x <= 4 and y == 1 and button == 1 then
        edge.render(1,1,4,1,colors.gray,colors.cyan," o*",colors.white,false)
        edge.render(1,2,10,5,menubarColor,colors.cyan,"",colors.white,true)

        edge.render(1,2,10,2,menubarColor,colors.cyan,"   Menu   ",colors.black,false)
        edge.render(1,3,10,3,menubarColor,colors.cyan,"Shut down",colors.black,false)
        edge.render(1,4,10,4,menubarColor,colors.cyan,"Reboot",colors.black,false)

        while(true) do
          local event, button, x, y = os.pullEvent("mouse_click")
          if x >= 10 and y >= 1 or x >= 1 and y >= 6 or x >= 1 and x <= 4 and y == 1 then
            if setting.variables.temp.restore_legacy_login then
              login_gui()
            else
              parallel.waitForAll(login_gui_unreleased,login_clock)
            end
          end
          if x >= 1 and x <= 10 and y == 3 then
            if hasRednet then
              rednet.close(detectedSide)
            end
            os.shutdown()
          end
          if x >= 1 and x <= 10  and y == 4 then
            os.reboot()
          end
          if x >= 1 and x <= 10 and y == 5 then
            if unreleased then
              parallel.waitForAll(login_gui_unreleased,login_clock)
            end
          end
          if event == "terminate" then
            os.shutdown()
          end
        end
      end
    end
  end

function terminal(dir)
  if currentUser == "GUEST" then return false end
  state = "terminal"
  if not setting then
    os.loadAPI("Axiom/libraries/setting")
  end
  if not term.isColor() then
    errorcolor = colors.lightGray
    okcolor = colors.white
  else
    errorcolor = colors.red
    okcolor = colors.lime
  end

  terminalVersion = version
  local termunfucked = false
  tasks.clock = false

  terminalActive = true
  workingDir = ""
  local curDir = dir..workingDir
  curUser = currentUser
  if curUser == nil then
    curUser = "KERNEL"
  end
  sleep(0.5)
  if edge then
    edge.render(1,1,51,19,colors.black,colors.black,"",colors.white,false)
  end
  term.setCursorPos(1,1)
  write("Axiom Terminal "..terminalVersion.."\n")
  while(terminalActive) do
    term.setBackgroundColor(colors.black)
    term.setTextColor(nameColor)
    write(curUser.."@axiom")
    term.setTextColor(tildeColor)
    write(" ~")
    term.setTextColor(dircolor)
    write(workingDir)
    term.setTextColor(restColor)
    write("$: ")
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
    local input = read()
    command(input,curDir)
    termunfucked = true
  end
  tasks.clock = true
end
function command(cmd)

  term.setBackgroundColor(colors.black)
  term.setBackgroundColor(colors.black)
  term.setBackgroundColor(colors.black)
  term.setBackgroundColor(colors.black)
  term.setBackgroundColor(colors.black)
  term.setBackgroundColor(colors.black)
  term.setBackgroundColor(colors.black)

  cmdTable = {}
  for i in string.gmatch(cmd,"%S+") do
    cmdTable[#cmdTable+1] = tostring(i)
  end
  if #cmdTable > 0 then
    if fs.exists(workingDir.."/"..cmdTable[1]) and not fs.isDir(workingDir.."/"..cmdTable[1]) then
      shell.run(workingDir.."/"..cmdTable[1])
    end
  end
  if cmdTable[1] == "limbo" and cmdTable[2] == "reboot" then
    fs.makeDir("safeStart")
    fs.makeDir("limbo")
    os.reboot()
  end
  if cmdTable[1] == "date" or cmdTable[1] == "day" then
    write("Day "..os.day().."\n")
  end
  if cmdTable[1] == "set" then
    if cmdTable[2] == "systemID" then
      setting.variables.temp.systemID = os.getComputerID()
      write("System ID set to "..os.getComputerID().."\n")
    end
  end
  if setting.variables.terminalCommands ~= nil then
    for k,v in pairs(setting.variables.terminalCommands) do
      if cmdTable[1] == k then

        write(k.." exists\n")
        f = assert(loadstring(setting.variables.terminalCommands[cmdTable[1]].code))

        local ok, err = pcall(f)
        write("\n")
        write(tostring(ok).."\n")
        if not ok then
          write("Error: "..err.."\n")
        end
      end
    end

  end
  if cmdTable[1] == "axRecover" and setting.variables.users[currentUser].superuser or cmdTable[1] == "axRecover"  and hasRootAccess then
    write("Recovery mode! Rebooting in 3 seconds. \n")
    sleep(1)
    write("Recovery mode! Rebooting in 2 seconds. \n")
    sleep(1)
    write("Recovery mode! Rebooting in 1 second. \n")
    sleep(1)
    fs.makeDir("firstBoot")
    fs.makeDir("safeStart")
    os.reboot()
  end
  if cmdTable[1] == "uninstall" then
    if setting.variables.users[currentUser].superuser or hasRootAccess then
      if edge.windowAlert(22, 9, "Are you sure?",false, colors.orange) then
        write("Uninstalling. \n")
        fs.delete("startup")
        fs.delete("/Axiom/libraries")
        fs.delete("/Axiom/images")
        fs.delete("/Axiom/sys.axs")
        fs.delete("/Axiom/settings.0")
        fs.delete("/Axiom/logging")
        fs.delete("/home")
        fs.delete("/users")
        write("Uninstall complete. Rebooting.\n")
        edge.windowAlert(22,9,"Uninstall complete.", true, colors.green)
        os.reboot()
      end
    else
      term.setTextColor(errorcolor)
      write("Insufficient permissions.\n")
      term.setTextColor(colors.white)
    end
  end
  if cmdTable[1] == "testalert" then
    if cmdTable[2] ~= nil then
      axiom.alert(cmdTable[2],0)
    else
      axiom.alert("Alert test.",0)
    end
  end
  if cmdTable[1] == "version" then
    write(productName.." version "..version.." "..version_sub.."\n")
    if cmdTable[2] == "terminal" then
      write("Terminal version ".. terminalVersion.."\n")
    end
  end
  if cmdTable[1] == "exit" then
    terminalActive = false
  end
  if cmdTable[1] == "clear" then
    if edge then
      edge.render(1,2,51,19,colors.black,colors.black,"",colors.white,false)
    else
      shell.run("clear")
    end
    term.setCursorPos(1,2)
  end
  if cmdTable[1] == "reboot" then
    if speakerPresent then
      speaker.playNote("harp",1, 1)
      speaker.playNote("harp",1, .75)
      speaker.playNote("harp",1, .5)
    end
    os.reboot()
  end
  if cmdTable[1] == "crash" and _G.unreleased then
    error("Crashing")
  end
  if cmdTable[1] == "users" then
    if setting.variables.users[currentUser].superuser or hasRootAccess then
      local c = 0
      for k,v in pairs(setting.variables.users) do
        write(c..": "..tostring(k).."\n")
        c = c +1
      end
    end
  end
  if cmdTable[1] == "wget" then
    local url = cmdTable[2]
    local filename = cmdTable[3]
    local allowOverwrite = cmdTable[4]
    if url and filename then
      if not fs.exists(filename) or allowOverwrite then
        download(url,filename,true)
        write("Saved as "..filename.."\n")
      end
    end
  end
  if cmdTable[1] == "pastebin" then
    if cmdTable[2] == "get" then
      if cmdTable[3] ~= nil and cmdTable[4] ~= nil then
        if not fs.exists(cmdTable[4]) then
          download("http://www.pastebin.com/raw/"..cmdTable[3], cmdTable[4], true)
          write("Saved as "..cmdTable[4].."\n")
        end
      end
    end
  end
  if cmdTable[1] == "login" then
    if cmdTable[2] ~= nil and cmdTable[3] ~= nil then
      if setting.variables.users[cmdTable[2]] ~= nil then
        local bruteforced = false
        if cmdTable[4] == "bruteforce" and cmdTable[5] == "recovery" and hasRootAccess == true then
          currentUser = cmdTable[2]
          curUser = cmdTable[2]
          sleep(2.5)
          write("Brute forced into "..curUser.."\n")
          bruteforced = true
        end
        if encryption.sha256(cmdTable[3].."QxLUF1bgIAdeQX") == setting.variables.users[cmdTable[2]].password then
          currentUser = cmdTable[2]
          curUser = cmdTable[2]
        else
          if not bruteforced then
            write("Invalid password.\n")
          end
        end
      else
        write("User does not exist.\n")
      end
    else
      term.setTextColor(errorcolor)
      write("Usage: login [username] [password]. \n")
      term.setTextColor(colors.white)
      write("If you have no password, replace [password] with nopass\n")
    end
  end
  if cmdTable[1] == "update" then

    if cmdTable[2] == "nightly" then
      if setting.variables.users[curUser].superuser or hasRootAccess then
        write("Installing nightly.. \n")
        _G.unreleased = true
        execUpd(true)
        term.setTextColor(okcolor)
        write("OK \n")
        term.setTextColor(colors.white)
        if cmdTable[3] == "-r" then
          os.reboot()
        end
      else
        term.setTextColor(errorcolor)
        write("Insufficient permissions. \n")
        term.setTextColor(colors.white)
      end

    else
      write("Installing updates.. ")
      execUpd(true)
      term.setTextColor(okcolor)
      write("OK \n")
      term.setTextColor(colors.white)
      if cmdTable[2] == "-r" then
        os.reboot()
      end
    end
  end
  if cmdTable[1] == "shutdown" then
    if hasRednet then
      rednet.close(detectedSide)
    end
    os.shutdown()
  end
  if cmdTable[1] == "luaide" then
    if #cmdTable > 1 then
      shell.run("home/prg/luaide.app",workingDir.."/"..cmdTable[2])
    else
      shell.run("home/prg/luaide.app")
    end
  end
  if cmdTable[1] == "ls" then
    if cmdTable[2] then
      local fileList = fs.list(""..cmdTable[2])
      for k,v in ipairs(fileList) do
        if fs.isDir(workingDir.."/"..v) then
          term.setTextColor(dircolor)
          write(v.."\n")
          term.setTextColor(colors.white)
        else
          term.setTextColor(colors.white)
          write(v.."\n")
          term.setTextColor(colors.white)
        end
      end
    elseif cmdTable[2] == nil then
      local fileList = fs.list("/"..workingDir)
      for k,v in ipairs(fileList) do
        if fs.isDir(workingDir.."/"..v) then
          term.setTextColor(dircolor)
          write(v.."\n")
          term.setTextColor(colors.white)
        else
          term.setTextColor(colors.white)
          write(v.."\n")
          term.setTextColor(colors.white)
        end
      end
    end
  end
  if cmdTable[1] == "rm" then
    if cmdTable[2] then
      if fs.exists(workingDir.."/"..cmdTable[2]) then
        fs.delete(workingDir.."/"..cmdTable[2])
        term.setTextColor(colors.gray)
        write(cmdTable[2].." ")
        term.setTextColor(colors.white)
        write("was deleted. \n")

      end
    end
  end
  if cmdTable[1] == "su" then
    if setting.variables.users[currentUser].superuser or hasRootAccess then
      write("You are su! \n")
    else
      write("You are not su! \n")
    end
  end
  if cmdTable[1] == "cd" then
    if cmdTable[2] ~= nil then
      if cmdTable[2] ~= ".." then
        if cmdTable[2] ~= "/" then
          if fs.exists(workingDir.."/"..cmdTable[2]) then
            workingDir = workingDir.."/"..cmdTable[2]
          end
        else
          workingDir = "/"
        end
      else
        if fs.exists("/"..cmdTable[2]) and workingDir ~= "/" then
          workingDir = fs.getDir(workingDir)
        end
      end
    end
  end
  if cmdTable[1] == "mkdir" then
    if cmdTable[2] ~= nil then
      if not fs.exists(workingDir.."/"..cmdTable[2]) then
        fs.makeDir(workingDir.."/"..cmdTable[2])
        term.setTextColor(okcolor)
        write("Created directory "..workingDir.."/"..cmdTable[2].."\n")
        term.setTextColor(colors.white)
        sleep(0.1)
      else
        term.setTextColor(errorcolor)
        write(workingDir.."/"..cmdTable[2].." already exists.")
        term.setTextColor(colors.white)
      end
    end
  end
  if cmdTable[1] == "launch" then
    if hasRootAccess then
      if cmdTable[2] == "desktop" then
        desktop()
      end
      if cmdTable[2] == "login" then
        parallel.waitForAll(login_gui_unreleased,login_clock)
      end
    else
      term.setTextColor(errorcolor)
      write("Insufficient permissions.\n")
      term.setTextColor(colors.white)
    end
  end
  if fs.exists(cmdTable[1]) then
    local fstr = ""
    for k,v in ipairs(cmdTable) do
      fstr = fstr..v
    end
    shell.run(fstr)
  end
end
function desktop()
    if _G.currentUser == nil and not hasRootAccess or _G.currentUser == "KERNEL" and not hasRootAccess then
      sleep(3.5)
      term.setBackgroundColor(colors.blue)
      term.setTextColor(colors.white)
      shell.run("clear")
      print(" ")
      print(":/")
      print("Oh noeeeeees! Something went wrong here.")
      print("If you keep seeing this error, please contact your device manufacturer.")
      print("If this is the first time, proceed to fix your drivers.")
      print("")
      print("STOPCODE: 0x1337LOL")
      print("Seriously though, logging in as KERNEL or nil does not work.")
      sleep(0.5)
      os.shutdown()
      return false
    end
    terminalActive = false
    if nightmode == true then
      menubarColor = colors.white
    else
      menubarColor = colors.white
    end
    if forcing then
      menubarColor = colors.orange
    end
    -- if state ~= "main_gui" and setting.variables.temp.enable_animations then
    --   edge.render(1,1,mx, my, colors.black, colors.white, "", colors.black)
    --   sleep(0.1)
    --   edge.render(1,1,mx, my, colors.gray, colors.white, "", colors.black)
    --   sleep(0.1)
    --   edge.render(1,1,mx, my, colors.lightGray, colors.white, "", colors.black)
    --   sleep(0.1)
    -- end
    if not forcing then
      if setting.variables.users[currentUser].background == "black" then
        edge.render(1,1,mx,19,colors.black,colors.cyan,"",colors.black,false)
      else
        edge.image(1,1,setting.variables.users[currentUser].background,colors.cyan)
      end
    end
    edge.render(1,1,mx,1,menubarColor,colors.cyan," o*",colors.gray,false)
    state = "main_gui"
    local x_p = 4
    --edge.render(1,1,mx,19,colors.cyan,colors.cyan,"",colors.black,false)
    edge.render(1,1,mx,1,menubarColor,colors.cyan," o*",colors.gray,false)


    x_p = 4
    --edge.log(announcement)

    --edge.render(1,18,1,1,colors.cyan,colors.cyan,demo,colors.white,false)
    --edge.render(2,2,2,2,colors.white,colors.cyan,": Home",colors.black)
    --edge.render(2,4,8,4,colors.white,colors.cyan,": Update",colors.black)
    --local desktopFiles = fs.list("home/Desktop/")
    local offset = 0
    local width = 7
    if button then
      buttonapi.clear()
    end
    local function stt(str)
      if not str then str = "No string or nil!" end
      local t={}
      str:gsub(".",function(c) table.insert(t,c) end)
      return t

    end
    local function cconv(col)
      local cols = {
        ["0"] = colors.white,
        ["1"] = colors.orange,
        ["2"] = colors.magenta,
        ["3"] = colors.lightBlue,
        ["4"] = colors.yellow,
        ["5"] = colors.lime,
        ["6"] = colors.pink,
        ["7"] = colors.gray,
        ["8"] = colors.lightGray,
        ["9"] = colors.cyan,
        ["a"] = colors.purple,
        ["b"] = colors.blue,
        ["c"] = colors.brown,
        ["d"] = colors.green,
        ["e"] = colors.red,
        ["f"] = colors.black,
      }
      for k,v in pairs(cols) do
        --edge.log("KEY:"..k..";VAL:"..v)
        if tostring(col) == tostring(k) then return v end
      end
      return colors.white
    end
    local icons = {
      lua = {
        bg = "bbbbbbbbbbbb",
        fg = "    lua    >",
        tcol = colors.white,
        extension = ".lua",
      },
      app = {
        bg = "333333333333",
        fg = "010010011100",
        tcol = colors.white,
        extension = ".app",
      },
      unknown = {
        bg = "888888888888",
        fg = "     ??     ",
        tcol = colors.white,
        extension = ".*",
      },
      txt = {
        bg = "700070007000",
        fg = " --- --- ---",
        tcol = colors.gray,
        extension = ".txt",
      },
      folder = {
        bg = "444144414444",
        fg = "        fldr",
        tcol = colors.gray,
        extension = "FOLDER"
      },
      lnk = {
        bg = "bbbbbbbbbbbb",
        fg = "    prg    >",
        tcol = colors.white,
        extension = ".lnk",
      },
      nfp = {
        bg = "c3333c333383",
        fg = "    nfp    >",
        tcol = colors.white,
        extension = ".nfp",
      },
      pain = {
        bg = "c3333c333383",
        fg = "    PAIN   >",
        tcol = colors.red,
        extension = ".blt",
      },
      nft = {
        bg = "c3333c333383",
        fg = "   nft    >",
        tcol = colors.white,
        extension = ".nft",
      },

    }
    local ab = 0
    local cd = 0
    local i = 1
    local _c = 0
    local _r = 0
    local clickableIcons = {

    }
    local function drawIcon(type, label)

      for k,v in pairs(icons) do
        if type == v.extension then
          local _tc = 0
          local _tr = 0
          local chars = stt(v.fg)
          if chars[1] == nil then
            chars = stt(v.fg) -- Retry if string-to-table conversion failed.
          end
          local icoLabel = string.gsub(label,type,"")

          if string.len(icoLabel) > 8 then
            icoLabel = string.gsub(icoLabel,string.sub(icoLabel,7),"")..".."
          end
          edge.render(ab+6+_c,cd+8+_r,ab+6,cd+4+_r,colors.cyan, colors.cyan,icoLabel,colors.white)
          for key, value in ipairs(stt(v.bg)) do
            edge.render(ab+8+_c,cd+4+_r,ab+8+_c,cd+4+_r,cconv(value),colors.cyan,tostring(chars[i]),v.tcol)
            i = i + 1
            _c = _c + 1
            if _c == 4 then
              _c = 0
              _r = _r + 1
            end
          end
          local exec = false
          if string.find(label,".lua",1) or string.find(label,".app",1) then
            exec = true
          end
          clickableIcons[#clickableIcons+1] = {
            ["isfolder"] = fs.isDir("home/"..currentUser.."/Desktop/"..label), -- Get whether or not the program is a folder
            ["openable"] = exec, -- Get executable status
            ["x"] = ab+7, -- Start clickbox position x-axis
            ["y"] = cd+4, -- Start clickbox position y-axis
            ["ex"] = ab+11, -- End clickbox position x-axis
            ["ey"] = cd+6, -- End clickbox position y-axis
            ["opens"] = "home/"..currentUser.."/Desktop/"..label -- Executable location (if executable, otherwise folder)

          }
          ab = ab + 12
          if ab == 48 then
            cd = cd + 6
            ab = 0
          end
        end

      end
      local _f = nil

      i = 1
      _c = 0
      _r = 0

    end
    if fs.exists("/home/"..currentUser.."/Desktop/") then
      local desktopfiles = fs.list("/home/"..currentUser.."/Desktop/")

      for k,v in ipairs(desktopfiles) do
        if k > 12 then
          break
        end
        if fs.isDir("home/"..currentUser.."/Desktop/"..v) then
          drawIcon("FOLDER",v)
        else
          local success = false
          local ext = string.sub(v,string.len(v)-3)
          --edge.log("program ext: "..ext)
          for b,c in pairs(icons) do
            --edge.log(tostring(v..":"..c.extension))
            if ext == c.extension then
              local label = string.gsub(v,ext,"")
              drawIcon(c.extension,v)
              success = true
              break
            end
          end
          if not success then
            drawIcon(".*",v)
          end
        end

      end
    end
    -- for k,v in pairs(clickableIcons) do
    --   edge.render(v.x, v.y, v.ex, v.ey, colors.red, colors.cyan,tostring(k), colors.black)
    -- end
    -- for k,v in ipairs(desktopFiles) do
    --   if string.len(v) > 6 then
    --     substring = string.sub(v,7)
    --     filename = string.gsub(v,substring,"..")
    --     --axiom.alert(filename)
    --   else
    --     filename = v
    --   end
    --   if fs.isDir("home/Desktop/"..v) then
    --     edge.render(2+(offset),3,9+(offset),7,colors.green,colors.cyan,"",colors.white,false)
    --     edge.render(2+(offset),9,9+(offset),9,colors.white,colors.cyan,filename,colors.gray,false)
    --   else
    --     edge.render(2+(offset),3,9+(offset),7,colors.cyan,colors.cyan,"",colors.white,false)
    --     edge.render(2+(offset),9,9+(offset),9,colors.white,colors.cyan,filename,colors.gray,false)
    --   end
    --   offset = (width + 2) * k
    -- end

    while(true) do

      local event, button, x, y = os.pullEvent("mouse_click")
      if nightmode == true then
        menubarColor = colors.white
      else
        menubarColor = colors.white
      end
      if forcing then
        menubarColor = colors.orange
      end
      x_p = 4

      if event == "terminate" then
        --error("Main process was terminated.")
        if speakerPresent then
          speaker.playNote("harp",1, 1.5)

        end
        if not hasRootAccess then
          if edge.windowAlert(20,5, "Logout?",false) then
            state = "loginscreen"
            if setting.variables.temp.restore_legacy_login then
              login_gui()
            else
              parallel.waitForAll(login_gui_unreleased,login_clock)
            end
          else
            desktop()
          end
        else
          if edge.windowAlert(20,5,"Go back to terminal?",false) then
            return true
          else
            desktop()
          end
        end

      end
      for k,v in ipairs(clickableIcons) do
        --edge.render(v.x, v.y, v.ex, v.ey, colors.red, colors.cyan,tostring(k), colors.black)
        if x >= v.x and x <= v.ex and y >= v.y and y <= v.ey and button == 1 then
          -- Do stuff
          local ext = string.sub(v.opens,string.len(v.opens)-3)
          if ext == ".nfp" or ext == ".blt" or ext == ".nft" then
            if fs.exists("Axiom/programs/pain.app") and invalidInstallation == false then
              shell.run("Axiom/programs/pain.app "..v.opens)
            else
              shell.run("paint "..v.opens)
            end
          end
          if ext == ".lnk" then
            local fh = fs.open(v.opens,"r")
            if fh ~= nil then
              local lnk = fh.readLine()
              fh.close()
              if lnk ~= nil then
                if fs.exists(lnk) then
                  shell.run(lnk)
                else
                  edge.windowAlert(25,10,"Could not open link (destination not present)",true,colors.red)
                end
              end
            end
          end
          if v.openable and not v.isfolder then

            shell.run(v.opens)
          elseif v.isfolder then
            shell.run("Axiom/programs/explorer.app "..v.opens)
          end
          desktop()
        end
      end
      if x >= 1 and x <= 4 and y == 1 and button == 1 then
        edge.render(1,1,4,1,colors.gray,colors.cyan," o*",colors.white,false)
        local mWidth,mHeight = 16,10
        local mTitle = "  "
        local mPage = 1
        local mCol = colors.gray
        edge.render(1,2,mWidth,mHeight,mCol,colors.cyan,"",colors.white,false)
        edge.render((mWidth/2)-(string.len(mTitle)/2),2,mWidth,2,mCol,colors.cyan,mTitle,colors.white,false)
        edge.render(1,3,mWidth,3,mCol,mCol,"Update",colors.white,false)
        if updating then edge.render(1,3,10,3,mCol,colors.cyan,"Updating..",colors.white,false) end
        edge.render(1,4,mWidth,4,mCol,mCol,"Settings",colors.white,false)
        edge.render(1,5,mWidth,5,mCol,mCol,"Files",colors.white,false)
        edge.render(1,6,mWidth,5,mCol,mCol,"Terminal  ",colors.white,false)
        edge.render(1,7,mWidth,7,mCol,mCol,"Logout",colors.white,false)
        edge.render(1,8,mWidth,8,mCol,mCol,"Reboot",colors.white,false)
        edge.render(1,9,mWidth,9,mCol,mCol,"Shut down",colors.white,false)
        edge.render(1,10,mWidth,10,mCol,mCol,"Store",colors.white,false)
        while(true) do
          local event, button, x, y = os.pullEvent("mouse_click")
          if event == "terminate" then
            if edge.windowAlert(20,5, "Logout?",false) then
              state = "loginscreen"
              if setting.variables.temp.restore_legacy_login then
                login_gui()
              else
                parallel.waitForAll(login_gui_unreleased,login_clock)
              end
            else
              desktop()
            end
          end
          if x >= mWidth and y >= 1 or x >= 1 and y >= 11 or x >= 1 and x <= 4 and y == 1 then
            desktop()
          end
          if event == "terminate" then
            desktop()
          end
          if x >= 1 and x <= mWidth and y == 3 then
            edge.render(1,3,10,3,mCol,colors.cyan,"Updating..",colors.white,false)
            local ok, file = execUpd()
            if ok then
              edge.render(1,3,10,3,mCol,colors.cyan,"Updated!",colors.green,false)
            else
              edge.render(1,3,10,3,mCol,colors.cyan,"Error [?]",colors.red,false)
              while(true) do
                local e,b,x,y = os.pullEvent("mouse_click")
                if edge.aabb(x,y,1,3,mWidth,3) then
                  edge.windowAlert(20,10,"Some files could not be downloaded. File: "..file,true)
                  break
                else
                  break
                end
              end
              desktop()
            end
          end
          if x >= 1 and x <= mWidth and y == 4 then
            --next.newTask("Axiom/Store/settings")
            if fs.exists("Axiom/programs/settings.app") and invalidInstallation == false then
              shell.run("Axiom/programs/settings.app")
              if os.version == "CraftOS 1.8" then
                setting.loadsettings("Axiom/settings.0")
              end
              desktop()
            else
              edge.windowAlert(20,8,"Axiom/programs/settings.app is unavailable",true, colors.red)
              desktop()
            end
          end
          if x >= 1 and x <= mWidth and y == 6 then
            terminal("/")
            desktop()
          end
          if x >= 1 and x <= mWidth and y == 5 then
            files = setting.variables.users[currentUser].fexplore_startdir
            if fs.exists("Axiom/programs/explorer.app") and invalidInstallation == false then
              shell.run("Axiom/programs/explorer.app")
              desktop()
            else
              edge.windowAlert(20,8,"Axiom/programs/explorer.app is unavailable",true, colors.red)
              desktop()
            end

          end
          if x >= 1 and x <= mWidth and y == 7 then
            shell.run("clear")
            state = "loginscreen"
            if setting.variables.temp.restore_legacy_login then
              login_gui()
            else
              parallel.waitForAll(login_gui_unreleased,login_clock)
            end
          end
          if x >= 1 and x <= mWidth and y == 8 then
            if setting.variables.temp.first_update == false then
              setting.variables.temp.first_update = true
              edge.windowAlert(25,10,productName.." is downloading additional files, please wait.","noButton",colors.lightBlue)
              execUpd()
              writesettings()
              os.reboot()
            end
            writesettings()
            sleep(0.5)
            os.reboot()
          end
          if x >= 1 and x <= mWidth and y == 10 then
            if fs.exists("Axiom/programs/store.app") and invalidInstallation == false then
              shell.run("Axiom/programs/store.app")
            else
              edge.windowAlert(20,8,"Axiom/programs/store.app is unavailable",true, colors.red)
              desktop()
            end

            desktop()
          end
          if x >= 1 and x <= mWidth and y == 9 then
            tasks.clock = false
            shell.run("clear")
            cprint("A X I O M",9)
            cprint(". . . . .",10)
            sleep(0.2)
            shell.run("clear")
            cprint("  X I O  ",9)
            cprint("  . . .  ",10)
            sleep(0.2)
            shell.run("clear")
            cprint("    I    ",9)
            cprint("    .    ",10)
            sleep(0.2)
            shell.run("clear")
            cprint("         ",9)
            cprint("         ",10)
            sleep(1)
            if setting.variables.temp.first_update == false then
              setting.variables.temp.first_update = true
              edge.render(1,1,mx,19,colors.cyan,colors.cyan,"",colors.black,false)
              edge.render(16,7,34,12,colors.white,colors.cyan,"",colors.black,true)
              edge.render(17,8,34,8,colors.white,colors.cyan,productName.." is updating ",colors.black,false)
              edge.render(17,10,34,10,colors.white,colors.cyan,"  Please wait.",colors.black,false)
              execUpd()
              writesettings()
              if hasRednet then
                rednet.close(detectedSide)
              end
              os.shutdown()
            end
            writesettings()
            if hasRednet then
              rednet.close(detectedSide)
            end
            os.shutdown()
          end
        end
      end
    end
end

function ftsRender(step,usr,pw,l,adduser)
  if not adduser then adduser = false end
  local a,b = term.getSize()
  if step == 1 then
    local olicense = http.get("http://www.pastebin.com/raw/RYKHrp1c")
    if olicense then
      edge.render(3,5,3,5,colors.white,colors.cyan,olicense.readAll(),colors.lightGray)
    else
      edge.render(3,5,3,5,colors.white,colors.cyan,"Unable to fetch license! :(",colors.lightGray)
    end
    if l then
      edge.render(1,b-1,1,b-1,colors.white,colors.cyan,"[+] I have read and agree to the TOS.",colors.gray)
    else
      edge.render(1,b-1,1,b-1,colors.white,colors.cyan,"[ ] I have read and agree to the TOS.",colors.gray)
    end
  end
  if step == 2 then
    edge.render(1,4,a,b,colors.white,colors.cyan,"",colors.white)
    -- pick username(?)
    edge.render(12,6,a,6,colors.white,colors.cyan,"Enter your desired username ",colors.gray)
    if not usr then
      edge.render(15,8,a-15,8,colors.lightGray,colors.lightGray,"",colors.black)
    else
      edge.render(15,8,a-15,8,colors.lightGray,colors.lightGray,""..usr,colors.black)
    end

  end
  if step == 3 then
    edge.render(1,4,a,b,colors.white,colors.cyan,"",colors.white)
    -- pick username(?)
    edge.render(15,6,a,6,colors.white,colors.cyan,"Enter a password ",colors.gray)
    edge.render(15,7,a,7,colors.white,colors.cyan,"(optional) ",colors.lightGray)
    if pw ~= "nopass" then

      edge.render(15,8,a-15,8,colors.lightGray,colors.lightGray,string.rep("*",string.len(pw)),colors.black)
    else
      edge.render(15,8,a-15,8,colors.lightGray,colors.lightGray,"",colors.black)
    end
  end
  if step == 4 then
    edge.render(a-string.len("Next >> "),2,a,2,colors.lime,colors.cyan,"Next x ",colors.white)
    edge.render(1,4,a,b,colors.white,colors.cyan,"",colors.white)
    if not adduser then
      edge.render((a/2)-(string.len("Welcome to Axiom")/2),(b/2),(a/2)-(string.len("Welcome to Axiom")/2),(b/2),colors.white,colors.cyan,"Welcome to Axiom.",colors.gray)
      edge.render((a/2)-(string.len("Let's go!")/2),(b/2)+1,(a/2)-(string.len("Let's go!")/2),(b/2)+1,colors.white,colors.cyan,"Let's go!",colors.gray)
      edge.render(1,b-1,1,b-1,colors.white,colors.cyan,"Rebooting...",colors.lightGray)
    end
    if usr == "KERNEL" then
      usr = "kernel"
    end
    if adduser then
      setting.addUser(usr,encryption.sha256(pw.."QxLUF1bgIAdeQX"),usr)
    else
      setting.addUser(usr,encryption.sha256(pw.."QxLUF1bgIAdeQX"),usr,true)
    end
    setting.variables.temp.first_start = false
    sleep(3)
    writesettings()
    if not adduser then
      if not fs.exists("home/"..usr.."/Desktop/files.lnk") then
        edge.render(1,b-1,1,b-1,colors.white,colors.cyan,"Creating additional desktop icons.. 1/3",colors.lightGray)
        local fh = fs.open("home/"..usr.."/Desktop/files.lnk","w")
        fh.write("Axiom/programs/explorer.app")
        fh.close()
        edge.render(1,b-1,1,b-1,colors.white,colors.cyan,"Creating additional desktop icons.. 2/3",colors.lightGray)
        local fh2 = fs.open("home/"..usr.."/Desktop/settings.lnk","w")
        fh2.write("Axiom/programs/settings.app")
        fh2.close()
        edge.render(1,b-1,1,b-1,colors.white,colors.cyan,"Creating additional desktop icons.. 3/3",colors.lightGray)
        local fh2 = fs.open("home/"..usr.."/Desktop/store.lnk","w")
        fh2.write("Axiom/programs/stdgui.app")
        fh2.close()
        edge.render(1,b-1,1,b-1,colors.white,colors.cyan,"Creating additional desktop icons.. OK ",colors.lightGray)
        sleep(1)
        local mx = term.getSize()
      end
      os.reboot()
    end
    return true
  end
end
function firstTimeSetupNew(adduser)
  if not adduser then adduser = false end
  tasks.clock = false
  disableclock = true
  local a,b = term.getSize()
  local password = "nopass"
  local username = ""
  local licensed = false
  local step = 1
  if adduser then step = 2 end
  if adduser then licensed = true end
  edge.render(1,1,a,4,colors.lime,colors.cyan,"",colors.white)
  if not adduser then
    edge.render(3,2,3,2,colors.lime,colors.cyan,"First time setup", colors.white)
  else
    edge.render(3,2,3,2,colors.lime,colors.cyan,"Set up new user account", colors.white)
  end
  edge.render(a-string.len("Next >> "),2,a,2,colors.lime,colors.cyan,"Next >>",colors.white)
  edge.render(1,4,a,b,colors.white,colors.cyan,"",colors.white)
  ftsRender(step)
  while(true) do
    --edge.render(a-string.len("Next >> "),2,a,2,colors.lime,colors.cyan,"Next >> ",colors.white)
    if step == 1 then
      if licensed then
        edge.render(a-string.len("Next >> "),2,a,2,colors.lime,colors.cyan,"Next >>",colors.white)
        edge.render(1,b-1,1,b-1,colors.white,colors.cyan,"[+] I have read and agree to the TOS.",colors.gray)
      else
        edge.render(a-string.len("Next >> "),2,a,2,colors.lime,colors.cyan,"Next >>",colors.gray)
        edge.render(1,b-1,1,b-1,colors.white,colors.cyan,"[ ] I have read and agree to the TOS.",colors.gray)
      end
    end
    if step > 1 then
      local success = ftsRender(step,username,password,licensed,adduser)
      if success then
        return true
      end
    else
      ftsRender(step,"","",licensed)
    end
    local event, button, x, y = os.pullEvent("mouse_click")
    if event == "terminate" then
      return false
    end
    if x >= a-string.len("Next >> ") and x <= a and y == 2 then
      if step == 2 then
        setting.setVariable("Axiom/settings.0","username",encryption.sha256(username.."QxLUF1bgIAdeQX"))
      end
      if step == 3 then
        setting.setVariable("Axiom/settings.0","password",encryption.sha256(password.."QxLUF1bgIAdeQX"))
      end
      if licensed == true then
        setting.setVariable("Axiom/settings.0","licensed","true")
      end
      if step >= 1 and licensed == true then
        step = step + 1
      end
    end
    if step == 1 and y == b-1 and button == 1 then
      licensed = not licensed
    end
    if step == 2 and x >= 15 and x <= a-15 and y == 8 then
      edge.render(15,8,a-15,8,colors.lightGray,colors.lightGray,""..username,colors.gray)
      term.setBackgroundColor(colors.lightGray)
      term.setCursorPos(15,8)
      username = read()
      while(string.len(username) < 3) do
        edge.render(15,8,a-15,8,colors.lightGray,colors.lightGray,""..username,colors.gray)
        username = read()
      end
      if not adduser then
        if unreleased then
          os.setComputerLabel("Axiom "..version.." "..version_sub)
        else
          os.setComputerLabel("Axiom "..version.." "..version_sub)
        end
      end

    end
    if step == 3 and x >= 15 and x <= a-15 and y == 8 then
      if password ~= "nopass" then
        edge.render(15,8,a-15,8,colors.lightGray,colors.lightGray,string.rep("*",string.len(password)),colors.gray)
      else
        edge.render(15,8,a-15,8,colors.lightGray,colors.lightGray,"",colors.gray)
      end
      term.setBackgroundColor(colors.lightGray)
      term.setCursorPos(15,8)
      password = read("*")
      if password == "" or password == nil then
        password = "nopass"
      end

    end
  end
end
function initialize()

  --setting.loadsettings("Axiom/settings.0")
  if not fs.exists("Axiom/settings.0") then
    axiom.alert("FATAL ERROR, SETTINGS FILE NOT FOUND.",3)
    return false, "axiom/settings.0 could not be found."
  end

  if setting.variables.temp.first_start == true or setting.variables.temp.first_start == nil  then

    setting.variables.temp.installDate = os.day()
    setting.variables.temp.systemID = os.getComputerID()
      --local h = http.post("http://nothy.000webhostapp.com/bugreport.php","uid="..textutils.urlEncode(tostring(setting.variables.temp.debugID)).."&brep="..textutils.urlEncode(tostring("First run on "..version.."<br><b>installed on "..os.day().."</b>")))
    writesettings()
    firstTimeSetupNew()
  else
    edge.log("User already has account")
    -- Get first non kernel User
    local dUser = nil
    for k,v in pairs(setting.variables.users) do
      if k ~= "KERNEL" then
        dUser = k
        break
      end
    end
    if setting.variables.temp.debugID == 0 and dUser ~= nil then
      setting.variables.temp.debugID = "user-"..dUser..""..math.random(0,9)..math.random(0,9)..math.random(0,9)..math.random(0,9)
      writesettings()
    end
  end
  if setting.variables.temp.systemID == 0 or setting.variables.temp.systemID == nil  then
    setting.variables.temp.systemID = os.getComputerID()
  end
  if setting.variables.temp.systemID == os.getComputerID() then
    allow_background_change = true
  else
    allow_background_change = false
    dangerousStatus = true
    invalidInstallation = true
  end
  booting = false
  --login_gui()
  if setting.variables.temp.restore_legacy_login then
    login_gui()
  else
    parallel.waitForAll(login_gui_unreleased,login_clock)
  end
  --parallel.waitForAll(login_gui_unreleased,notifHandler,taskHandler,eventHandler)
end
function cprint( text, y )
  local x = term.getSize()
  local centerXPos = ( x - string.len(text) ) / 2
  term.setCursorPos( centerXPos, y )
  write( text )
end
function bootanimation()
  booting = true
  if not term.isColor() then
    printerr("No color support detected, quitting..")
    sleep(2)
    return false
  end
  local bgCol = colors.white
  local tCol = colors.black
  if dangerousStatus then
    bgCol = colors.orange
  end
  if not fs.exists("Axiom/libraries/edge") then
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
    print("ERROR: Edge Graphics not found. Are you sure you have installed "..productName.." properly?")
    print("How to install "..productName..":")
    print("- Run the following command: pastebin run 2nLQRsSd")
    print("- And wait as "..productName.." installs.")
    sleep(1)
    print("Would you like to have Edge Graphics installed for you? (y/n)")
    i = io.read()
    if string.lower(i) == "y" then
      print("Installing Edge Graphics.")
      noapidl("https://www.dropbox.com/s/a5kxzjl6122uti2/edge?dl=1","Axiom/libraries/edge")
    else
      print("OK")
    end
  end
  if shell.getRunningProgram() == "startup" then
    error("Invalid session: cannot be run as startup")
  end
  --print("edge")
  os.loadAPI("Axiom/libraries/edge")
  if not _G.unreleased then edge.noLog = true end
  --print("setting")
  if monitor then
    --printout("Connecting to monitor...")
    local ok, err = edge.setScreen(monitor)
    if ok then
      printout("Monitor connected successfully")
    else
      printerr("Monitor not present or disconnected")
    end
  end
  os.loadAPI("Axiom/libraries/setting")
  --print("encryption")
  os.loadAPI("Axiom/libraries/encryption")
  --print("loaded apis")
  if not edge then os.reboot() end
  if _G.unreleased then
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
  else
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
  end
  --sleep(10)
  shell.run("clear")

  latestversion = http.get("http://www.nothy.se/Axiom/CurrentUpdate")

  local mx, my = term.getSize()

  if setting.variables.users["KERNEL"].allow_apis == true then
    local dir = setting.variables.temp.api_dir
    if setting.variables.temp.api_dir ~= nil then

      local fileList = fs.list(dir)
      local t = 0
      local c = 0
      for _, api in ipairs(fileList) do
        local apiL = {
          "button",
          "edge",
          "encryption",
          "fs",
          "setting",
        }
        local allow = true

        if setting.variables.temp.ignore_blacklist == false then
          for k,v in ipairs(apiL) do
            if api == v then
              allow = false
              break
            end
          end
        else
          if t < 1 then
            table.insert(apiErrors, "Blacklist ignored.")
            t = t + 1

          end
        end

        edge.log("Loaded api: "..api.. " from "..dir)

        if allow then
          local apil, err = os.loadAPI(dir..api)
          c = c + 1
          if not apil then
            os.unloadAPI(apil)
            c = c - 1
            --if err then print(err) sleep(3) end
            table.insert(apiErrors, api.." could not load")
          end
        else
          table.insert(apiErrors, api.." not loaded. (access denied)")
          c = c - 1
        end
        --sleep(0.2)
        --sleep(3)
      end
      table.insert(apiErrors, "Loaded "..c.." API(s)")
      edge.log("Loaded custom apis.")
    end

  end
  writesettings()
  if not edge then
    error("Axiom did not load Edge properly.")
  end
  if not setting then
    error("Axiom did not load Settings API properly.")
  end
  if not next then
    error("Axiom did not find Next API, which doesn't affect this OS what so ever since it's obsolete. Rendering this snippet of code absolutely useless.")
  end
  edge.render(1,1,mx, my, colors.black, colors.white, "", colors.black)
  sleep(0.1)
  edge.render(1,1,mx, my, colors.gray, colors.white, "", colors.black)
  sleep(0.1)
  edge.render(1,1,mx, my, colors.lightGray, colors.white, "", colors.black)
  sleep(0.1)
  edge.render(1,1,mx, my, bgCol, colors.white, "", colors.black)
  sleep(0.1)

  --log("settings "..tostring(sysSettings))
  if not setting.variables.temp.system_skipsys_scan then
    if fs.exists("Axiom/log.txt") then
      if fs.getSize("Axiom/log.txt") >= 12000 then
        fs.delete("Axiom/log.txt")
      end
    end
    local fileList = fs.list("/")
    local loaded = 0
    local toLoad = #fileList

    for _, file in ipairs(fileList) do
      if file == "rom" then
        log("SYSTEM: CraftOS System file detected '"..file.."'. Ignoring")
        --edge.render(midx - string.len("Disallowed file detected, removing") / 2,8,48,8,colors.white,colors.cyan,"Disallowed file detected, removing",colors.black)
      else
        if fs.isDir(file) then
          log("SYSTEM: Verified folder "..file.."/ and it's contents")
        else
          log("SYSTEM: Verified file "..file)

          term.setTextColor(colors.lightGray)

          if _G.unreleased then
            term.setBackgroundColor(colors.white)
            term.setTextColor(colors.black)
          else
            term.setBackgroundColor(colors.cyan)
            term.setTextColor(colors.white)
          end
        end
        x, y = term.getSize()
        midx = x / 2
        --edge.render(midx - string.len("File"..loaded.." of "..toLoad.." verified.") / 2,8,48,8,colors.white,colors.cyan,"File "..loaded.." of "..toLoad.." verified.",colors.black)
        loaded = loaded + 1
        --sleep(0.1)
      end

      --print("Loaded: os/libraries/"..file)
    end
  end

  --sleep(0.2)
  -- cprint("  X I O  ",my/2)
  -- cprint("  . . .  ",(my/2)+1)
  -- sleep(0.2)
  -- cprint("    I    ",my/2)
  -- cprint("    .    ",(my/2)+1)
  -- sleep(0.2)
  -- cprint("         ",my/2)
  -- cprint("         ",(my/2)+1)
  term.setBackgroundColor(bgCol)
  term.setTextColor(colors.black)
  edge.cprint(productName,10)
  sleep(0.1)
  term.setTextColor(colors.gray)
  edge.cprint(productName,10)
  sleep(0.1)
  term.setTextColor(colors.lightGray)
  edge.cprint(productName,10)
  sleep(0.1)
  term.setTextColor(colors.white)
  edge.cprint(productName,10)
  sleep(0.1)
  term.setTextColor(colors.lightGray)
  edge.cprint(productName,10)
  sleep(0.1)
  term.setTextColor(colors.gray)
  edge.cprint(productName,10)
  sleep(0.1)
  term.setTextColor(colors.black)
  edge.cprint(productName,10)
  sleep(1)
  local c = 0
  while c ~= 1 do
    --edge.render(1,1,51,20,colors.orange,colors.white,"test")
    term.setTextColor(colors.black)
    edge.cprint(productName,10)
    sleep(0.1)
    term.setTextColor(colors.gray)
    edge.cprint(productName,10)
    sleep(0.1)
    term.setTextColor(colors.lightGray)
    edge.cprint(productName,10)
    sleep(0.1)
    term.setTextColor(colors.white)
    edge.cprint(productName,10)
    sleep(0.1)
    term.setTextColor(colors.lightGray)
    edge.cprint(productName,10)
    sleep(0.1)
    term.setTextColor(colors.gray)
    edge.cprint(productName,10)
    sleep(0.1)
    term.setTextColor(colors.black)
    edge.cprint(productName,10)
    sleep(1)
    c= c + 1
  end
  --local h = http.post("http://nothy.000webhostapp.com/bugreport.php","uid="..textutils.urlEncode(tostring(setting.variables.temp.debugID)).."&brep="..textutils.urlEncode(tostring(errmsg.." <br> Started! "))) -- Excessive? Probably.
  edge.render(1,1,mx, my, bgCol, colors.white, "", colors.black)
  sleep(0.1)
  edge.render(1,1,mx, my, colors.lightGray, colors.white, "", colors.black)
  sleep(0.1)
  edge.render(1,1,mx, my, colors.gray, colors.white, "", colors.black)
  sleep(0.1)
  edge.render(1,1,mx, my, colors.black, colors.white, "", colors.black)
  sleep(0.1)
  term.setCursorPos(1,1)
  initialize()
end

function safeBoot(force)
  if shell.getRunningProgram() == "startup" then
    error("Invalid session: cannot be run as startup")
  end
  if not fs.exists("Axiom/libraries/edge") then
    printerr("Edge Graphics not found. Are you sure you have installed "..productName.." properly?")
    printout("How to install "..productName..":")
    printout("- Run the following command: pastebin run 2nLQRsSd")
    printout("- And wait as "..productName.." installs.")
    sleep(1)
    printout("Would you like to have Edge Graphics installed for you? (y/n)")
    i = io.read()
    if string.lower(i) == "y" then
      printout("Installing Edge Graphics.")
      noapidl("https://www.dropbox.com/s/a5kxzjl6122uti2/edge?dl=1","Axiom/libraries/edge")
    else
      print("OK")
    end
  end
  for k,v in ipairs(allfiles) do
    if fs.exists(allfiles[k]) then
      printout(allfiles[k].. " OK")
      sleep(0.1)
    else
      if allfiles[k] ~= 12 then
        printwarn("Missing file: "..allfiles[k])
        fixNeeded = true
        sleep(0.1)
      end
    end
  end

  tasks.kernel = true
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)
  os.loadAPI("Axiom/libraries/edge")
  if not _G.unreleased then edge.noLog = true end
  printout("LOADED: Edge")
  if monitor then
    printout("Connecting to monitor...")
    local ok, err = edge.setScreen(monitor)
    if ok then
      printout("Monitor connected successfully")
    else
      printerr("Monitor not present or disconnected")
      printerr("Returned: "..tostring(err))
    end
  end


  os.loadAPI("Axiom/libraries/setting")

  --files = setting.variables.users[currentUser].fexplore_startdir
  printout("LOADED: settings")
  os.loadAPI("Axiom/libraries/encryption")
  printout("LOADED: encryption")

  --cprint("A X I O M",9)

  printout("Determining latest version.")
  latestversion = http.get("http://www.nothy.se/Axiom/CurrentUpdate")
  if latestversion.readAll() == nil or latestversion.readAll() == "" then
    printwarn("Error determining version.")
    latestversion = version
  else
    printout(latestversion.readAll())
  end
  sleep(1)
  if not edge then
    error("AXIOM-EdgeNotLoaded")
  end
  if not next then
    error("AXIOM-NextNotLoaded")
  end
  if setting.getVariable("Axiom/settings.0","system_skipsys_scan") == "false" then
    if fs.exists("Axiom/log.txt") then
      if fs.getSize("Axiom/log.txt") >= 12000 then
        fs.delete("Axiom/log.txt")
      end
    end
    local fileList = fs.list("/")
    local loaded = 0
    local toLoad = #fileList
    for _, file in ipairs(fileList) do
      if file == "rom" then
        log("SYSTEM: CraftOS System file detected '"..file.."'. Ignoring")
        --edge.render(midx - string.len("Disallowed file detected, removing") / 2,8,48,8,colors.white,colors.cyan,"Disallowed file detected, removing",colors.black)
      else
        if fs.isDir(file) then
          printout("SYSTEM: Verified folder "..file.."/ and it's contents")
        else
          printout("SYSTEM: Verified file "..file)
        end
        x, y = term.getSize()
        midx = x / 2
        --edge.render(midx - string.len("File"..loaded.." of "..toLoad.." verified.") / 2,8,48,8,colors.white,colors.cyan,"File "..loaded.." of "..toLoad.." verified.",colors.black)
        loaded = loaded + 1
        sleep(0.1)
      end

      --print("Loaded: os/libraries/"..file)
    end
  end
  if setting.variables.users["KERNEL"].allow_apis == true then
    local dir = setting.variables.temp.api_dir
    if setting.variables.temp.api_dir ~= nil then

      local fileList = fs.list(dir)
      local t = 0
      local c = 0
      for _, api in ipairs(fileList) do
        local apiL = {
          "button",
          "edge",
          "encryption",
          "fs",
          "setting",
        }
        local allow = true

        if setting.variables.temp.ignore_blacklist == false then
          for k,v in ipairs(apiL) do
            if api == v then
              allow = false
              break
            end
          end
        else
          if t < 1 then
            table.insert(apiErrors, "Blacklist ignored.")
            t = t + 1

          end
        end

        printout("Loading api "..api.. " from "..dir)

        if allow then
          local apil, err = os.loadAPI(dir..api)
          c = c + 1
          if not apil then
            os.unloadAPI(apil)
            c = c - 1
            --if err then print(err) sleep(3) end
            table.insert(apiErrors, api.." could not load")
            printerror(api.." could not load")
          else
            printout(api.." OK")
          end
        else
          table.insert(apiErrors, api.." not loaded. (access denied)")
          printerr(api.." not loaded (access denied)")
          c = c - 1
        end
        --sleep(0.2)
        --sleep(3)
      end
      table.insert(apiErrors, "Loaded "..c.." API(s)")
      printout("Loaded custom apis.")
    end

  end
  term.setBackgroundColor(colors.cyan)
  printout("Initializing")
  sleep(1)
  term.setCursorPos(1,1)
  if force == "desktop" then
    printwarn("WARNING: MAY NOT WORK.")
    printout("For security reasons you have to log in.")
    write("username:")
    username = read()
    write("password:")
    password = read("*")
    if encryption.sha256(username.."QxLUF1bgIAdeQX") == setting.getVariable("Axiom/settings.0","username") then
      if encryption.sha256(password.."QxLUF1bgIAdeQX") == setting.getVariable("Axiom/settings.0","password") then
          local ok, err = pcall(desktop)
          if not ok then
            printerr("Fatal error: "..err)
          end
      else
        printerr("Invalid password.")
        os.reboot()
      end
      printerr("Invalid username.")
      os.reboot()
    end


  end

  initialize()
end
function log(string)
  local time = os.clock()
  if not fs.exists("Axiom/log.txt") then
    logfile = fs.open("Axiom/log.txt","w")
    logfile.close()
  end
  logfile = fs.open("Axiom/log.txt","a")
  logfile.writeLine("["..time.."]: "..string.."\n")
  logfile.close()
end
if tArgs[1] == "force" then
  forcing = true
  if tArgs[2] == nil then
    print("Nothing to force")
  end
  if tArgs[2] == "desktop" then
    print("Attempting forced desktop.")
    safeBoot("desktop")
  end
end
term.setTextColor(colors.white)
term.setBackgroundColor(colors.black)
printout("SYSTEM: Starting services..")
tasks.kernel = true
tasks.permngr = true
if fs.exists("safeStart") then
  if fs.exists("limbo") then
    hasRootAccess = true
    for k,v in ipairs(fs.list("Axiom/libraries")) do
      if v ~= "button" then
        os.loadAPI("Axiom/libraries/"..v)
        printout("Loaded "..v)
      else
        printerr("Ignored "..v)
      end
    end
    terminal("/")
    os.reboot()
  end
  safe = false
  term.setBackgroundColor(colors.black)
  shell.run("clear")
  term.setTextColor(colors.white)
  --paintutils.drawLine(1,my/2,mx,my/2,colors.blue)
  term.setBackgroundColor(colors.blue)
  term.setCursorPos(1,1)
  print("[AXIOM BOOT MANAGER]")
  term.setBackgroundColor(colors.black)
  print("Please select a mode for "..productName.." to run in")
  term.setCursorPos(1,4)
  print("[ ] Last known good configuration ")
  print("    (Overrides your settings)")
  print("[ ] Normal start + cleared logs")
  print("")
  print("[ ] Terminal")
  print("")
  while(true) do
    local event, button, x, y = os.pullEvent("mouse_click")
    if x == 2 and y == 4 then
      safe = true
      craftos = false
      term.setCursorPos(1,4)
      print("[+] Last known good configuration")
      print("    (Overrides your settings)")
      print("[ ] Normal start + cleared logs")
      print("")
      print("[ ] Terminal")
      print("")
      print("[Boot]")
    end
    if x == 2 and y == 6 then
      safe = false
      craftos = false
      term.setCursorPos(1,4)
      print("[ ] Last known good configuration")
      print("    (Overrides your settings)")
      print("[+] Normal start + cleared logs")
      print("")
      print("[ ] Terminal")
      print("")
      print("[Boot]")
    end
    if x == 2 and y == 8 then
      safe = false
      craftos = true
      term.setCursorPos(1,4)
      print("[ ] Last known good configuration")
      print("    (Overrides your settings)")
      print("[ ] Normal start + cleared logs")
      print("")
      print("[+] Terminal")
      print("")
      print("[Run] ")
    end
    if x >= 1 and x <= 5 and y == 10 then
      if safe == false and craftos == false then
        if fs.exists("Axiom/settings.0") and fs.exists("Axiom/backup/os/settings.0") then
          fs.delete("Axiom/settings.0")
          fs.move("Axiom/backup/os/settings.0","Axiom/settings.0")
        end
        fs.delete("safeStart")
        bootanimation()
      else
        if craftos == true then
          currentUser = "KERNEL"
          for k,v in ipairs(fs.list("Axiom/libraries")) do
            os.loadAPI("Axiom/libraries/"..v)
            printout("Loaded "..v)
          end
          terminal("/")
          print("Goodbye!")
          if hasRednet then
            rednet.close(detectedSide)
          end
          os.shutdown()
        else
          sleep(1)
          fs.delete("safeStart")

          safeBoot()
        end
      end
    end
  end
end


--sleep(1)
--print("Total space:"..totalused + fs.getFreeSpace("/"))
--print("Space used:"..totalused)
--print("Free space:"..fs.getFreeSpace("/"))
--sleep(5)
term.setTextColor(colors.white)
term.setBackgroundColor(colors.black)
if fs.exists("bios.lua") and fs.exists("ccbox.lua") then
  dangerousStatus = true
  printwarn("Custom BIOS/CCBox detected, may be unstable")
end
if cclite then
  printout("Enabling cclite support.")
end
printout("started "..productName.." v"..version)
if force_logcat or _G.unreleased then
  printwarn("forced logcat output")
  sleep(2.5)
  local ok, err = pcall(safeBoot)
  if err then
    errorMessager(err)
  end
end
if os.version() ~= "CraftOS 1.7" then
  if os.version() == "CraftOS 1.5" then
    printerr("please update ComputerCraft.")

  end
  if os.version() == "CraftOS 1.8" then
    printwarn("Settings is known not to work properly in CC 1.80.")
    sleep(1)
  end
  printwarn("running on unsupported CraftOS version, may be unstable")
  sleep(1)
end
if not fs.exists("Axiom/settings.0") then
  term.setTextColor(colors.white)
  term.setBackgroundColor(colors.black)
  if fs.exists("Axiom/backup/os/settings.0") then
    fs.copy("Axiom/backup/os/settings.0","Axiom/settings.0")
    printout("Restored settings from backup.")
  else
    printerr("Settings file is missing or corrupt. System will reboot when repair is finished.")
    noapidl("https://www.dropbox.com/s/ynyrs22t1hh2mry/settings?dl=1","Axiom/settings.0")
    printout("Repair finished. Rebooting into first time setup.")
    sleep(5)
    os.reboot()
  end
end
if fs.exists("Axiom/settings") == true and fs.exists("Axiom/settings.0") == false then
  fs.copy("Axiom/settings","Axiom/settings.0")
  fs.delete("Axiom/settings")
  printout("Settings file has been updated to support "..version)
  sleep(1)
end
if fs.exists("firstBoot") then
  fs.delete("firstBoot")

  term.setBackgroundColor(colors.black)
  local ok, err = pcall(safeBoot)
  if edge then
    if not ok and err then
      if edge.windowAlert(26,10,productName.." has crashed. Error: "..err.."\n Reboot?", false) then
        os.reboot()
      else
        os.shutdown()
      end
    end
  else
    if not ok and err then
      printout(productName.." has run into a problem and has to shut down.")
      printerr(err)
      if cclite then
        cclite.screenshot()
        print("[CCLITE] A screenshot has been saved.")
      end
      sleep(10)
      os.reboot()
    end
  end
else
  local ok, err = pcall(bootanimation)
  if edge then
    if edge.windowAlert(26,10,productName.." has crashed. Error: "..err.."\n Reboot?", false) then
      os.reboot()
    else
      os.shutdown()
    end
  else
    printout(productName.." has run into a problem and has to shut down.")
    printerr(err)
    if cclite then
      cclite.screenshot()
      print("[CCLITE] A screenshot has been saved.")
    end
    sleep(10)
    os.reboot()
  end

end
