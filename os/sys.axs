
  --Copyright 2016 Linus Ramneborg
  --All rights reserved.
  term.redirect(term.native())
if turtle then
  error("Axiom cannot be run on a turtle, silly.")
end
local hasRednet = false
local rednetDist = 999
local sides = {"front","back","left","right","top","bottom"}
local detectedSide = nil
local modem = nil
local apiErrors = {

}
local dismissed = false
local remoteChannels = {}
local remoteSystemInfo = {}
local remoteInfo = {
  systemID = os.getComputerID(),
  sharingUpdates = true,
  sharingFiles = true,
  fileDirectory = "/home/",
}
for k,v in ipairs(sides) do
  if peripheral.isPresent(v) then
    if peripheral.getType(v) == "modem" then
      detectedSide = v

      break
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
  if oldFS.exists("Axiom/sys-pocket.axs") then
    oldFS.delete("startup")
    shell.run("Axiom/sys-pocket.axs")
  end
end
local oldFS = fs
local mx, my = term.getSize()
fixNeeded = false
local fileselect = false
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

local file = oldFS.list(files)
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
local bannedHashes = {
  "b4c38037365dd3183a485d18429363f371dcc1e5b0b4b71061c353537f51c1ed",
}
events = true
currentUser = nil
disableclock = false
useOldFS = false
updating = false
productName = "Axiom UI"
version_sub = " "
version = "2.21"

unreleased = true
latestversion = version
announcement = ""
state = ""
tasks = {kernel=false,settings_app=false,permngr=false,clock=false,filebrowser=false}
demo = "Billon"
frames_rendered = 1
menubarColor = colors.white
menuBarColor_Dark = colors.gray
nightmode = false
when = "always"
delay = 20
if unreleased == true then
  allow_background_change = true
else
  allow_background_change = true
end
if unreleased == true then
  edition = "AXu"
else
  edition = "AX"
end
local forcing = false
local editing = false
local settings_tips = {"Made by Nothy"}
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
-- New FS functions:
  _G.fs = {
    isReadOnly = function(f)
      return oldFS.isReadOnly(f)
    end,
    combine = function(basepath, localpath)
      return oldFS.combine(basepath, localpath)
    end,
    find = function(wildcard)
      return oldFS.find(wildcard)
    end,
    list = function(f)
      return oldFS.list(f)
    end,
    list = function(f)
      return oldFS.isDir(f)
    end,
    exists = function(f)
      return oldFS.exists(f)
    end,
    copy = function(s,e)
      return oldFS.copy(s,e)
    end,
    move = function(s,e)
      return oldFS.move(s,e)
    end,
    getDir = function(path)
      return oldFS.getDir(path)
    end,
    getSize = function(file)
      return oldFS.getSize(file)
    end,
    complete = function(a, b)
      return oldFS.complete(a,b)
    end,
    --getSize = oldFS.getSize,
    getFreeSpace = function(path)
      return oldFS.getFreeSpace(path)
    end,
    getDrive = function(path)
      return oldFS.getDrive(path)
    end,
    getName = function(path)
      return oldFS.getName(path)
    end,
    isDir = function(dir)
      return oldFS.isDir(dir)
    end,
    --getFreeSpace = oldFS.getFreeSpace,
    --getDrive = oldFS.getDrive,
    open = function(_str, mode)
      local success = false
      for k,v in ipairs(allfiles) do
        if _str == v or "/".._str == "/"..v then
          success = false
        else
          success = true
        end
      end
      if success then
        return oldFS.open(_str, mode)
      end

    end,
    delete = function(file)
      local success = false
      for k,v in ipairs(allfiles) do
        if file == v or file == "/"..v or file == "//"..v then
          return false
        else
          return oldFS.delete(file)
        end
      end
    end,
  }
if useOldFS then
  _G.fs = oldFS
end

--
function errorMessager(errmsg)
  if currentUser == nil then
    currentUser = "KERNEL"
  end
  if setting.variables.users[currentUser].system_skip_error then
    if state == "loginscreen" then
      login_gui_unreleased()
      axiom.alert(errmsg,2)
    else
      desktop()
      axiom.alert(errmsg,2)
    end
  end
  --oldFS.delete("Axiom/log.txt")
  if err == nil then
    edge.log("System crash! : Unknown error occured")
  else
    edge.log("System crash! : "..err)
  end

  edge.log("Version: "..version.." "..demo)
  edge.log("Shell version: "..os.version())
  if oldFS.exists("Axiom/stacktrace.log") then
    oldFS.delete("Axiom/stacktrace.log")
  end
  oldFS.move("Axiom/logging/system.log","Axiom/stacktrace.log")
  if oldFS.exists("Axiom/backup/os/settings.0") then
    oldFS.delete("Axiom/backup/os/settings.0")
  end
  if oldFS.exists("Axiom/settings.0") then
    oldFS.copy("Axiom/settings.0","Axiom/backup/os/settings.0")
  end
  edge.render(1,1,51,19,colors.cyan,colors.cyan,"",colors.black,false)
  if setting.getVariable("Axiom/settings.0","licensed") == "false" or setting.getVariable("Axiom/settings.0","general_background_name") == "black" then
    edge.render(1,1,51,19,colors.black,colors.cyan,"",colors.black,false)
  else
    edge.image(1,1,setting.variables.users[currentUser].background,colors.cyan)
  end
  edge.render(1,1,mx,1,colors.white,colors.cyan," o*",colors.black,false)
  if hasRednet then
    -- Check signal strength?
    if rednetDist < 10 then
      edge.render(37,1,37,1,menubarColor,colors.cyan,"¤>>>" ,colors.gray,false)
    elseif rednetDist > 10 and rednetDist < 20 then
      edge.render(37,1,37,1,menubarColor,colors.cyan,"¤>>" ,colors.gray,false)
    elseif rednetDist > 20 and rednetDist < 100 then
      edge.render(37,1,37,1,menubarColor,colors.cyan,"¤>" ,colors.gray,false)
    elseif rednetDist > 100 and rednetDist < 200 then
      edge.render(37,1,37,1,menubarColor,colors.cyan,"¤" ,colors.gray,false)
    elseif rednetDist > 200 then
      edge.render(37,1,37,1,menubarColor,colors.cyan,"¤x",colors.gray,false)
    end
  else
    edge.render(37,1,37,1,menubarColor,colors.cyan,"¤x",colors.red,false)
  end
  if errmsg then

    if string.find(errmsg,"System repair") then
      edge.render(1,3,mx,7,colors.white,colors.cyan,"System Self Repair: Message",colors.black,false)
      edge.render(1,5,mx,5,colors.white,colors.cyan,"System is currently repairing.",colors.black,false)
      edge.render(1,7,mx,7,colors.gray,colors.cyan,"(Click here for more information.)",colors.white,false)

    else
      edge.render(1,3,mx,7,colors.white,colors.cyan,"Application crashed unexpectedly!",colors.black,false)
      edge.render(1,5,mx,5,colors.white,colors.cyan,"Fear not, everything's totally fine.",colors.black,false)
      if setting.variables.temp.enable_telemetry == true then
        edge.render(1,7,mx,7,colors.gray,colors.cyan,"(Sending bug report, please wait..)",colors.white,false)
        local h = http.post("http://nothy.000webhostapp.com/bugreport.php","uid="..textutils.urlEncode(tostring(setting.variables.temp.debugID)).."&brep="..textutils.urlEncode(tostring(errmsg.." <br> Version: "..productName.." "..version.." <br> dev: "..tostring(unreleased).." Last updated: Day "..setting.variables.temp.last_update)))
      end
      edge.render(1,7,mx,7,colors.gray,colors.cyan,"(Click here for more information.)",colors.lime,false)
    end

    while(true) do
      local event, button, x, y = os.pullEvent("mouse_click")
      if event == "terminate" then
        desktop()
      end
      if y == 7 then
        if string.find(errmsg,"System repair") then
          edge.render(1,3,mx,10,colors.white,colors.cyan,"System Self Repair: Message",colors.black,false)
          edge.render(1,5,mx,5,colors.white,colors.cyan,"System is currently repiairing.",colors.black,false)
          edge.render(1,7,mx,7,colors.white,colors.cyan,"Some missing files are currently downloading.",colors.black,false)
          edge.render(1,8,mx,8,colors.white,colors.cyan,"Sorry about the inconvenience. :/",colors.black,false)
          edge.render(1,10,mx,10,colors.gray,colors.cyan,"(Click to continue.)",colors.white,false)
        else
          edge.render(1,3,mx,10,colors.white,colors.cyan,"Application crashed unexpectedly!",colors.black,false)
          edge.render(1,5,mx,5,colors.white,colors.cyan,"Fear not, everything's totally fine.",colors.black,false)
          edge.render(1,7,mx,7,colors.white,colors.cyan,errmsg,colors.red,false)
          edge.render(1,8,mx,8,colors.white,colors.cyan,"Version: "..version,colors.red,false)
          edge.render(1,10,mx,10,colors.gray,colors.cyan,"(Click to continue.)",colors.white,false)
        end
        local event, button, x, y = os.pullEvent("mouse_click")
        if state == "loginscreen" then
          os.reboot()
        else
          parallel.waitForAll(desktop,desktopIcons,clock,checkForUpdates,keyStrokeHandler,modemHandler)
        end
      else
        if state == "loginscreen" then
          login_gui_unreleased()
        else
          parallel.waitForAll(desktop,desktopIcons,clock,checkForUpdates,keyStrokeHandler,modemHandler)
        end
      end
    end
  else
    edge.render(1,3,mx,7,colors.white,colors.cyan,"Application crashed unexpectedly!",colors.black,false)
    edge.render(1,3,mx,3,colors.white,colors.cyan,"An unknown error occurred.",colors.black,false)
    edge.render(1,7,mx,7,colors.gray,colors.cyan,"(Click  to continue..)",colors.white,false)
  end
  local event, button, x, y = os.pullEvent("mouse_click")
  if state == "loginscreen" then
    login_gui_unreleased()
  else
    parallel.waitForAll(desktop,desktopIcons,clock,checkForUpdates)
  end
end

function errorHandler(err)
  if not oldFS.exists("/safeStart") then
    oldFS.makeDir("/safeStart")
  end
  fs = oldFS
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
  updated = false
  if setting.variables.temp.autoupdate then
    when = "always"
  else
    when = "never"
  end

  if not delay then
    delay = 30
  end

    setting.variables.temp.last_updatecheck = tonumber(""..os.day())

    setting.variables.temp.last_update = tonumber(""..os.day())
    writesettings()
    if updated == false then
      if when == "always" then
        --axiom.alert("Checking for updates! (Mode: "..when..")",0)
        versionCheck = http.get("http://www.nothy.se/Axiom/CurrentUpdate")
        if versionCheck then
          nv = versionCheck.readAll()
        end
        edge.log("latest: "..versionCheck.readAll())
        if not versionCheck then
          axiom.alert("Error: Could not connect to server: http://www.nothy.se/! (FATAL)",3)
          edge.log("Error: Could not connect to server: http://www.nothy.se/ ! (FATAL)")
          if edge.getOverlay() then
            edge.render(mx-9,1,mx-9,1,menubarColor,colors.cyan,"VCx",colors.green)
          end
        else
          if nv ~= version and not unreleased then
            local nUpd = false
            updated = true
            local initialan = setting.variables.temp.enable_animations
            setting.variables.temp.enable_animations = false
            sleep(2.5)
            if not edge.windowAlert(25,9,"Version "..nv.." (current "..version..") is now available for download. Install?", false) then
              nUpd = true
              return
            else
              edge.windowAlert(25,9,"Installing.", "noButton")
              unreleased = false
            end
            setting.variables.temp.enable_animations = initialan
            if not nUpd then
              --edge.notify(notifContent)
              edge.log("Update available")
              if setting.getVariable("Axiom/settings.0","first_update") == "false" then
                setting.setVariable("Axiom/settings.0","first_update","true")
              end
              if oldFS.exists("Axiom/backup/os/settings.0") then
                oldFS.delete("Axiom/backup/os/settings.0")
                oldFS.copy("Axiom/settings.0","Axiom/backup/os/settings.0")
              else
                oldFS.copy("Axiom/settings.0","Axiom/backup/os/settings.0")
              end
              if edge.getOverlay() then
                edge.render(mx-9,1,mx-9,1,menubarColor,colors.cyan,"DL",colors.green)
              end
              if not oldFS.exists("home/prg/luaide.app") then
                shell.run("pastebin get vyAZc6tJ home/prg/luaide.app")
              end
              download("https://www.dropbox.com/s/a7fp2jo6tgm7xsy/startup?dl=1","startup")
              sleep(0.1)
              if unreleased == false then
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
              if not oldFS.exists("Axiom/settings.0") then
                axiom.alert("Settings file not found, fixing..",3)
                download("https://www.dropbox.com/s/ynyrs22t1hh2mry/settings?dl=1","Axiom/settings.0")
                sleep(0.1)
              end

              download("https://www.dropbox.com/s/t40vz4gvmyrcjv4/background.axg?dl=1","Axiom/images/default.axg")
              download("https://www.dropbox.com/s/cjahddofwhja8og/axiom.axg?dl=1","Axiom/images/axiom.axg")
              download("https://www.dropbox.com/s/osz72e1rnvt5opl/nature.axg?dl=1","Axiom/images/nature.axg")
              download("https://www.dropbox.com/s/wi4n0j98d82256f/AX.nfp?dl=1","Axiom/images/AX.nfp")
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
              if hasRednet then
                -- Check signal strength?
                if rednetDist < 10 then
                  edge.render(37,1,37,1,menubarColor,colors.cyan,"¤>>>" ,colors.gray,false)
                elseif rednetDist > 10 and rednetDist < 20 then
                  edge.render(37,1,37,1,menubarColor,colors.cyan,"¤>>" ,colors.gray,false)
                elseif rednetDist > 20 and rednetDist < 100 then
                  edge.render(37,1,37,1,menubarColor,colors.cyan,"¤>" ,colors.gray,false)
                elseif rednetDist > 100 and rednetDist < 200 then
                  edge.render(37,1,37,1,menubarColor,colors.cyan,"¤" ,colors.gray,false)
                elseif rednetDist > 200 then
                  edge.render(37,1,37,1,menubarColor,colors.cyan,"¤x",colors.gray,false)
                end
              else
                edge.render(37,1,37,1,menubarColor,colors.cyan,"¤x",colors.red,false)
              end
            end
          end
        end
      end
    end
end
function modemHandler()
  if hasRednet then
    for i=0,7, 1 do
      modem.transmit(i,1, "axfs")
      edge.log("Checked for other machines nearby")
    end
  end
  while(true) do
    if hasRednet then


      local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")
      if senderDistance ~= nil then
        rednetDist = senderDistance
      end
      edge.log(message)
      axiom.alert(message,1)
      if string.find(message,"axfsr") then
        local substr = string.gsub(message,"axfsr:","")
        local t = textutils.unserialize(substr)
        local allowedIntoList = true
        for k,v in pairs(remoteSystemInfo) do
          if t.systemID ~= v.systemID then
            allowedIntoList = true
          else
            allowedIntoList = false
            break
          end
        end

        axiom.alert(tostring(allowedIntoList),1)
        if allowedIntoList then
          table.insert(remoteSystemInfo,textutils.unserialize(substr))
          modem.transmit(replyChannel, senderChannel, "axfsr:"..textutils.serialise(remoteInfo))
        end

      end
      if message == "axfs" then
        edge.log("virtual handshake? yes. "..senderDistance)

        modem.transmit(replyChannel, senderChannel, "axfsr:"..textutils.serialise(remoteInfo))
      end
      if event == "peripheral_disconnect" and modemSide == detectedSide then
        hasRednet = false
        modem.closeAll()
      end
    else
      local event, side = os.pullEvent("peripheral")
      if type(side) == "string" then
        if peripheral.getType(side) == "modem" then
          detectedSide = side
          modem = peripheral.wrap(side)
          edge.log("Attached modem.")
          hasRednet = true
          for i=0,7 do
            modem.open(i)
            modem.transmit(i,1, "axfs")
          end

        end
      end
    end
    sleep(0)
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
    table.insert(keystrokes, key)

    if #keystrokes >= 2 then
      --print(keystrokes[#keystrokes-2], keystrokes[#keystrokes-1], keystrokes[#keystrokes], isHeld)
      if keystrokes[#keystrokes-1] == 42 and keystrokes[#keystrokes] == 32 and isHeld then
        if currentUser ~= nil then
          sysInfo()
        end
      end
      if keystrokes[#keystrokes-1] == 42 and keystrokes[#keystrokes] == 20 and isHeld then
        terminal("/")

      end
      if keystrokes[#keystrokes-1] == 42 and keystrokes[#keystrokes] == 33 and isHeld then
        filebrowser("/")

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
  tasks.clock = true
  count = 0
  while(true) do
    sleep(0)
    if tasks.clock == true then
      frames_rendered = frames_rendered + 1
      local time = textutils.formatTime( os.time(), false )
      if time == "12:00 AM" or time == "12:00 PM" then
        writesettings()
      end
      if state == "main_gui" then
        if not tasks.settings_app == true then
          if string.find(time, "AM") then
            nightmode = true
          else
            nightmode = false
          end
          if string.find(time,"10:") or string.find(time,"11:") or string.find(time,"12:") then
            edge.render(mx-7,1,mx-7,1,menubarColor,colors.cyan,time,colors.gray,false)
          else
            edge.render(mx-7,1,mx-7,1,menubarColor,colors.cyan,"",colors.gray,false)
            edge.render(mx-6,1,mx-6,1,menubarColor,colors.cyan,time,colors.gray,false)
          end
        end
        sleep(0)
        if setting.getVariable("Axiom/settings.0","licensed") == "false" then
          edge.render(1,19,mx,my,colors.black,colors.cyan,"Unlicensed copy! Activate now.",colors.white,false)
        end
        if tasks.settings_app == false then
          tasks.settings_app_boot = false
          tasks.settings_app_http = false
          tasks.settings_app_system = false
          tasks.settings_app_account = false
          tasks.settings_app_general = false
        end
        if not oldFS.exists(shell.getRunningProgram()) then
          term.setCursorPos(1,1)
          oldFS.delete("Axiom/log.txt")
          edge.log("!!! KERNEL PANIC !!!")
          edge.log("Version: "..version.." "..demo)
          edge.log("Shell version: "..os.version())
          edge.log("!!! END OF STACKTRACE !!!")
          if oldFS.exists("Axiom/stacktrace.log") then
            oldFS.delete("Axiom/stacktrace.log")
          end
          oldFS.move("Axiom/log.txt","Axiom/stacktrace.log")
          sleep(3)
          print("[ UNRECOVERABLE ERROR ]")
          print("!!! KERNEL PANIC !!!")
          print("Kernel Version: "..version)
          for k,v in ipairs(allfiles) do
            if oldFS.exists(allfiles[k]) then

            else
              print("Missing file: "..allfiles[k])
              sleep(0.1)
            end
          end
          print("A detailed error log can be found in Axiom/stacktrace.log")
          while(true) do
            sleep(5)
          end
        end
        --edge.render(1,18,1,18,colors.cyan,colors.cyan,"kernel="..tostring(tasks.kernel)..", settings_app="..tostring(tasks.settings_app),colors.white,false)
        if not tasks.kernel == true then
          edge.log("Kernel task stopped. Stopping..")
          sleep(5)
          if hasRednet then
            rednet.close(detectedSide)
          end
          os.shutdown()

        end
      end
    end
  end
--  axiom.alert("Clock stopped!",3)
axiom.alert("You're going to time-prison now.",3)
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
      f = oldFS.open(file,"w")
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
  local fh = oldFS.open("Axiom/settings.0","w")
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
  if oldFS.getFreeSpace("/") <= 1024 then
    --edge.render(1,18,1,18,colors.cyan,colors.cyan,"Warning: Low space on disk!",colors.orange)
    edge.xprint("Warning: Low space on disk! "..oldFS.getFreeSpace("/") / 1024 .."kb",1,18,colors.orange)
  end
  if not http then
    edge.render(16,7,34,12,colors.white,colors.cyan,"",colors.black,true)
    --edge.render(17,8,34,8,colors.white,colors.cyan,"Welcome to Axiom!",colors.black,false)
    edge.render(17,9,34,9,colors.white,colors.cyan," (!) Fatal error",colors.red,false)
    edge.render(16,10,34,10,colors.white,colors.cyan,"HTTP_DISABLED",colors.orange,false)
    return false
  else



    if oldFS.exists("Axiom/backup/"..file) then
      oldFS.delete("Axiom/backup/"..file)
      if not oldFS.exists(file) then
        edge.log(file.. " - does not exist")
      else
        oldFS.copy(file,"Axiom/backup/"..file)
      end
    else
      if oldFS.exists(file) then
        oldFS.copy(file,"Axiom/backup/"..file)
      end
    end
    if oldFS.getFreeSpace("/") <= 10 then
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
          write("DL FAILED\n")
          term.setTextColor(colors.white)
        end
        return false
        --sleep(1)
      end
      f = oldFS.open(file,"w")
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
  --setting.setVariable("Axiom/settings.0","system_last_update","Day "..os.day().." @ "..edge.c())
  if setting then
    setting.variables.temp.last_update = tonumber(""..os.day())
    if isTerminal then
      write("Last update date changed to "..tonumber(""..os.day()))
    end
    writesettings()
  end
  if isTerminal then
    write("Initializing..\n")
    out = true
  end
  if setting then
    if setting.variables.temp.first_update == false then
      setting.variables.temp.first_update = true
    end
    writesettings()
  end
  if isTerminal then
    write("Updated and backed up settings..\n")
  end
  if oldFS.exists("Axiom/backup/os/settings.0") then
    oldFS.delete("Axiom/backup/os/settings.0")
    oldFS.copy("Axiom/settings.0","Axiom/backup/os/settings.0")
  else
    oldFS.copy("Axiom/settings.0","Axiom/backup/os/settings.0")
  end
  if not oldFS.exists("home/prg/luaide.app") then
    shell.run("pastebin get vyAZc6tJ home/prg/luaide.app")
  end
  download("https://www.dropbox.com/s/a7fp2jo6tgm7xsy/startup?dl=1","startup", out)
  sleep(0.1)
  if unreleased == false then
    download("https://www.dropbox.com/s/7mzhcfe53dm2rq5/sys.axs?dl=1","Axiom/sys.axs", out)
  else
    download("https://www.dropbox.com/s/5v2amjjmw08n9yz/sys-latest.axs?dl=1","Axiom/sys.axs", out)
  end
  sleep(0.1)
  download("https://www.dropbox.com/s/9byakcx77k03yji/setting?dl=1","Axiom/libraries/setting", out)
  sleep(0.1)
  download("https://www.dropbox.com/s/a5kxzjl6122uti2/edge?dl=1","Axiom/libraries/edge", out)
  sleep(0.1)
  download("https://www.dropbox.com/s/p3kgkzhe27vr9lj/encryption?dl=1","Axiom/libraries/encryption", out)
  if not oldFS.exists("Axiom/settings.0") then
    download("https://www.dropbox.com/s/ynyrs22t1hh2mry/settings?dl=1","Axiom/settings.0", out)
    sleep(0.1)
  end

  download("https://www.dropbox.com/s/cjahddofwhja8og/axiom.axg?dl=1","Axiom/images/axiom.axg", out)
  download("https://www.dropbox.com/s/t40vz4gvmyrcjv4/background.axg?dl=1","Axiom/images/default.axg", out)
  download("https://www.dropbox.com/s/osz72e1rnvt5opl/nature.axg?dl=1","Axiom/images/nature.axg", out)
  download("https://www.dropbox.com/s/wi4n0j98d82256f/AX.nfp?dl=1","Axiom/images/AX.nfp", out)
  download("https://www.dropbox.com/s/nd608k6k4boeqtx/button?dl=1","Axiom/libraries/button", out)
  sleep(0.1)
end
function login_gui_unreleased()

  if setting.variables.temp.enable_animations then
    edge.render(1,1,mx, my, colors.black, colors.white, "", colors.black)
    sleep(0.1)
    edge.render(1,1,mx, my, colors.gray, colors.white, "", colors.black)
    sleep(0.1)
    edge.render(1,1,mx, my, colors.lightGray, colors.white, "", colors.black)
    sleep(0.1)
    edge.render(1,1,mx, my, colors.cyan, colors.white, "", colors.black)
    sleep(0.1)
  end
  local users =  {}
  local count = 1
  local p = 1
  local uiPage = 1
  edge.render(1,1,mx,my,colors.cyan,colors.cyan,"",colors.black,false)
  edge.image((mx/2)-10, 1, "AX.nfp")
  if setting.variables.temp.enable_animations then
    for i=0, math.floor(mx/2), 3 do
      edge.render(1,1,i,19,colors.white,colors.cyan,"",colors.black,false)
      sleep(0)
    end
  end
  edge.render(1,1,mx/2,19,colors.white,colors.cyan,"",colors.black,true)
  edge.render(1,2,mx/2,2,colors.white,colors.cyan,"Login",colors.gray,false)
  local c = 2
  local offset = 0
  for k,v in pairs(setting.variables.users) do
    if k ~= "KERNEL" then
      edge.render(3,3*c+offset,(mx/2)-3,(3*c)+2+offset,colors.lightGray,colors.cyan,"",colors.gray,false)
      if v.superuser == true then
        edge.render(3,(3*c)+1+offset,(mx/2)-3,(3*c)+1+offset,colors.lightGray,colors.cyan," "..tostring(v.displayName),colors.black,false)
      else
        edge.render(3,(3*c)+1+offset,(mx/2)-3,(3*c)+1+offset,colors.lightGray,colors.cyan," "..tostring(v.displayName),colors.gray,false)
      end
      edge.render((mx/2)-3,(3*c)+1+offset,(mx/2)-3,(3*c)+1+offset,colors.lightGray,colors.cyan,">",colors.gray,false)
      c = c + 1
      offset = offset +1
      if count == 3 then
        count = 0
        p = p +1
        offset = 0
        c = 2
      end
      users[k] = {
        sx = 3,
        sy = 3*c+offset,
        ex = (mx/2)-3,
        ey = (3*c)+2+offset,
        page = p
      }
    end

  end
  if p > 1 then
    edge.render(3,18,3,18,colors.white,colors.cyan,"<--  "..uiPage.."/"..p.."  -->")
  end
  while(true) do
    if p > 1 then
      edge.render(3,18,3,18,colors.white,colors.cyan,"<--  "..uiPage.."/"..p.."  -->")
    end
    if event == "terminate" then
      break
    end
    local event, button, x,y = os.pullEvent("mouse_click")
    local startheight = 3
    local size = 3
    local offset = 2
    for key,val in pairs(users) do


      if x >= val.sx and x <= val.ex and y > val.sy-4 and y < val.ey-4 and val.page == uiPage then

        --edge.render(val.sx,val.sy-4,val.ex,val.ey-4,colors.orange,colors.white,key,colors.white)
        if setting.variables.users[key].password == encryption.sha256("nopass".."QxLUF1bgIAdeQX") then
          currentUser = key
          parallel.waitForAll(desktop,desktopIcons,clock,checkForUpdates)
        else
          edge.image(1,1,setting.variables.users[key].background,colors.white)
          edge.render(1,5,mx,my-5,colors.white,colors.cyan,"",colors.white)
          edge.render((mx/2)-(string.len("Enter password for "..key)/2),(my/2)-1,(mx/2)-(string.len("Enter password for "..key)/2),(my/2)-1,colors.white,colors.lightGray,"Enter password for "..setting.variables.users[key].displayName,colors.gray)
          edge.render(10,my/2,mx-10,my/2,colors.lightGray,colors.lightGray,"",colors.gray)
          term.setCursorPos(10,my/2)
          local pw = read("*")
          if pw == "" then
            login_gui_unreleased()
          end
          if encryption.sha256(pw.."QxLUF1bgIAdeQX") == setting.variables.users[key].password then
            currentUser = key
            parallel.waitForAll(desktop,desktopIcons,clock,checkForUpdates) --NOTE: DO NOT FUCKING CHANGE THIS YA TWATS
            return
          else
            login_gui_unreleased()
          end
          break
        end
      end
      --offset = offset + 1
    end
    if x >= 3 and x <= 6 and y == 18 then
      uiPage = uiPage - 1
    end
    if x >= 9 and x <= 12 and y == 18 then
      uiPage = uiPage + 1
    end
  end
  --sleep(30)
end
function login_gui() -- TO BE CONVERTED TO NEW SETTINGS SYSTEM.
  usr = ""
  pass = ""
  tasks.clock = false
  edge.render(1,1,mx,1,menubarColor,colors.cyan," o*",colors.gray,false)
  if hasRednet then
    -- Check signal strength?
    if rednetDist < 10 then
      edge.render(37,1,37,1,menubarColor,colors.cyan,"¤>>>" ,colors.gray,false)
    elseif rednetDist > 10 and rednetDist < 20 then
      edge.render(37,1,37,1,menubarColor,colors.cyan,"¤>>" ,colors.gray,false)
    elseif rednetDist > 20 and rednetDist < 100 then
      edge.render(37,1,37,1,menubarColor,colors.cyan,"¤>" ,colors.gray,false)
    elseif rednetDist > 100 and rednetDist < 200 then
      edge.render(37,1,37,1,menubarColor,colors.cyan,"¤" ,colors.gray,false)
    elseif rednetDist > 200 then
      edge.render(37,1,37,1,menubarColor,colors.cyan,"¤x",colors.gray,false)
    end
  else
    edge.render(37,1,37,1,menubarColor,colors.cyan,"¤x",colors.red,false)
  end
  if setting.getVariable("Axiom/settings.0","password") == encryption.sha256("nopass".."QxLUF1bgIAdeQX") then
    sleep(0.5)
    edge.log("Auto login")
    parallel.waitForAll(desktop,desktopIcons,clock,checkForUpdates)
    --errorHandler("0x10")
  else
    if setting.getVariable("Axiom/settings.0","dev") == "true" then
      edge.render(1,1,mx,19,colors.white,colors.cyan,demo, colors.black)
      edge.render(18,7,33,12,colors.white,colors.cyan,": Login", colors.black)
      edge.render(20,9,30,9,colors.lightGray,colors.cyan,"Username",colors.gray)
      edge.render(20,11,30,11,colors.lightGray,colors.cyan,"Password",colors.gray)
      edge.render(32,9,32,11,colors.lightGray,colors.cyan,"", colors.gray)
      edge.render(32,10,32,10,colors.lightGray,colors.cyan,">", colors.white)
    else
      edge.render(19,8,34,13,colors.gray,colors.cyan,"", colors.white)
      edge.render(18,7,33,12,colors.white,colors.cyan,": Login", colors.black)
      edge.render(20,9,30,9,colors.lightGray,colors.cyan,"Username",colors.gray)
      edge.render(20,11,30,11,colors.lightGray,colors.cyan,"Password",colors.gray)
      edge.render(32,9,32,11,colors.lightGray,colors.cyan,"", colors.gray)
      edge.render(32,10,32,10,colors.lightGray,colors.cyan,">", colors.white)
    end
    while(true) do
      if setting.getVariable("Axiom/settings.0","username") == "autoLogin" and setting.getVariable("Axiom/settings.0","password") == "kernelSpecified-AutomaticLogin" then
        tasks.clock = true
        parallel.waitForAll(desktop,desktopIcons,clock,checkForUpdates)
        term.setBackgroundColor(colors.black)
      end
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
        encryption.sha256(pass)
      end
      if x >= 32 and x <= 32 and y >= 9 and y <= 11 then
        if encryption.sha256(usr.."QxLUF1bgIAdeQX") == setting.getVariable("Axiom/settings.0","username") and encryption.sha256(pass.."QxLUF1bgIAdeQX") == setting.getVariable("Axiom/settings.0","password") then --#Temporary
          edge.render(16,7,34,12,colors.white,colors.cyan,"",colors.black,true)
          --edge.render(17,8,34,8,colors.white,colors.cyan,"Welcome to Axiom!",colors.black,false)
          edge.render(17,9,34,9,colors.white,colors.cyan,"  Please wait..",colors.black,false)
          tasks.clock = true
          --os.pullEvent = oldPullEvent
          local ok, val = pcall(parallel.waitForAll(desktop,desktopIcons,clock,checkForUpdates))
          error("Something went wrong")
        else
          if usr == "axRecover -f" then
            write("Recovery mode! Rebooting in 3 seconds. \n")
            sleep(1)
            write("Recovery mode! Rebooting in 2 seconds. \n")
            sleep(1)
            write("Recovery mode! Rebooting in 1 second. \n")
            sleep(1)
            oldFS.makeDir("firstBoot")
            oldFS.makeDir("safeStart")
            os.reboot()
          end
          login_gui_unreleased()
        end
      end
      if x >= 1 and x <= 4 and y == 1 and button == 1 then
        edge.render(1,1,4,1,colors.gray,colors.cyan," o*",colors.white,false)
        edge.render(1,2,10,4,menubarColor,colors.cyan,"",colors.white,true)

        edge.render(1,2,10,2,menubarColor,colors.cyan,"   Menu   ",colors.black,false)
        edge.render(1,3,10,3,menubarColor,colors.cyan,"Shut down",colors.black,false)
        edge.render(1,4,10,4,menubarColor,colors.cyan,"Reboot",colors.black,false)
        while(true) do
          local event, button, x, y = os.pullEvent("mouse_click")
          if x >= 10 and y >= 1 or x >= 1 and y >= 4 or x >= 1 and x <= 4 and y == 1 then
            login_gui_unreleased()
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
          if event == "terminate" then
            login_gui_unreleased()
          end
        end
      end
    end
  end
end
function settings_draw(page)
  local mx, my = term.getSize()
  local categories = {         -- Network (formerly)
    "General", "Account", "Boot","Updates","API","About"
  }
  --edge.render(1,2,mx,2,colors.lime,colors.cyan,page,colors.white)
  local curX = 2
  edge.render(1,3,mx,3,colors.lime,colors.cyan,"",colors.black)
  edge.render(1,4,2,4,colors.lime,colors.cyan,"",colors.gray)
  for k,v in ipairs(categories) do
    edge.render(curX,4,curX+string.len(v),4,colors.lime,colors.cyan,v.." | ",colors.gray)
    curX = curX + string.len(v)+3
  end
  edge.render(mx,4,mx,4,colors.lime,colors.cyan,"",colors.black)
  --edge.render(10,4,10+string.len("Account"),4,colors.lime,colors.cyan,"Account",colors.white)
  if page == "main" then
    edge.render((mx/2)-(string.len(productName)/2),my/2,(mx/2)-(string.len(productName)/2),my/2,colors.white,colors.cyan,productName,colors.gray)
  end

  if page == "general" then
    local bg = oldFS.list(edge.imageDir)
    local bg_y = 6
    edge.render(1,5,mx,my,colors.white,colors.cyan,"",colors.white)
    edge.render(1,4,8,4,colors.green,colors.cyan," General ",colors.white)
    if allow_background_change == true then
      edge.render(2,6,24,6,colors.lightGray,colors.cyan,"'"..setting.variables.users[currentUser].background.."'",colors.black,false)
      for k,v in ipairs(bg) do
          if setting.variables.users[currentUser].background  == bg[k] then
            currentExists = true
          else
            currentExists = false
          end
          if bg[k] == setting.variables.users[currentUser].background  then
            edge.render(2,bg_y,24,bg_y,colors.green,colors.cyan,bg[k],colors.white,false)
            edge.render(24-string.len("CURRENT"),bg_y,24,bg_y,colors.green,colors.cyan,"current",colors.white,false)
          else
            edge.render(2,bg_y,24,bg_y,colors.white,colors.cyan,bg[k],colors.black,false)
          end
          bg_y = bg_y +1
      end
      if currentExists == false then
        edge.render(2,bg_y+2,24,bg_y+2,colors.white,colors.cyan,"Current: "..setting.variables.users[currentUser].background ,colors.black,false)
      end
      edge.render(2,bg_y+1,24,bg_y+1,colors.white,colors.cyan,"Other..",colors.black,false)
    else
      edge.render(2,bg_y,24,bg_y,colors.white,colors.cyan,"This setting is disabled",colors.gray,false)
    end
    if edge.getOverlay() == true then
      edge.render(2,bg_y+4,24,bg_y+4,colors.green,colors.cyan,"Debug overlay enabled",colors.white,false)
      --axiom.alert("debug "..tostring(edge.getOverlay()))
    else
      edge.render(2,bg_y+4,24,bg_y+4,colors.red,colors.cyan,"Debug overlay disabled",colors.black,false)
      --axiom.alert("debug "..tostring(edge.getOverlay()))
    end
    edge.render(2,bg_y+5,24,bg_y+5,colors.white,colors.cyan,"(Feature is work in progress)",colors.gray,false)
    if setting.variables.temp.system_skipsys_scan then
      edge.render(27,6,45,6,colors.green,colors.cyan,"Skip system scan",colors.white,false)
    else
      edge.render(27,6,45,6,colors.white,colors.cyan,"Skip system scan",colors.black,false)
    end
    if setting.variables.users[currentUser].system_skip_error then
      edge.render(27,8,45,8,colors.green,colors.cyan,"Skip error screens",colors.white,false)
    else
      edge.render(27,8,45,8,colors.white,colors.cyan,"Skip error screens",colors.black,false)
    end
    if setting.variables.temp.enable_telemetry then
      edge.render(27,10,45,10,colors.green,colors.cyan,"Enable telemetry",colors.white,false)
      --edge.render(27,11,45,10,colors.white,colors.cyan,"(Sends debug/crash info)",colors.gray,false)
    else
      edge.render(27,10,45,10,colors.white,colors.cyan,"Enable telemetry",colors.black,false)
    end
    if setting.variables.temp.enable_telemetry == "forcedOff" then
        edge.render(27,10,45,10,colors.red,colors.cyan,"Enable telemetry",colors.black,false)
        edge.render(27,11,45,10,colors.white,colors.cyan,"(Disabled by System)    ",colors.gray,false)
    end
    edge.render(46, 10, 50, 10, colors.white, colors.white, "[?]", colors.gray, false)
    edge.render(46, 12, 50, 12, colors.white, colors.white, "[?]", colors.gray, false)
    if setting.variables.temp.enable_animations then
      edge.render(27,12,45,12,colors.green,colors.cyan,"Enable animations",colors.white,false)
      --edge.render(27,11,45,10,colors.white,colors.cyan,"(Sends debug/crash info)",colors.gray,false)
    else
      edge.render(27,12,45,12,colors.white,colors.cyan,"Enable animations",colors.black,false)
    end
  end
  if page == "account" then

    edge.render(1,5,mx,my,colors.white,colors.cyan,"",colors.white)
    edge.render(11,4,19,4,colors.green,colors.cyan," Account ",colors.white)
    if setting.variables.users[currentUser].superuser == true then
      edge.render(3,6,15,6,colors.white,colors.cyan,"Add new user account",colors.gray)
    else
      edge.render(3,6,15,6,colors.white,colors.cyan,"Add new user account",colors.lightGray)
    end
    edge.render(27,5,50,5,colors.white,colors.cyan,"Modify users:",colors.gray)
    if setting.variables.users[currentUser].superuser == true then
      edge.render(27,6,50,6+#setting.variables.users+1,colors.white,colors.cyan,"",colors.black)
      local count = 0
      for k,v in pairs(setting.variables.users) do
        if k ~= "KERNEL" then
          count = count + 1
          edge.render(27,6+count,50,6+count+1,colors.white,colors.cyan," "..k,colors.black)
          if v.superuser then
            edge.render(41,6+count,42,6+count,colors.green,colors.cyan,"SU",colors.white)
          else
            edge.render(41,6+count,42,6+count,colors.red,colors.cyan,"SU",colors.white)
          end
          edge.render(44,6+count,49,6+count,colors.red,colors.cyan,"DELETE",colors.white)
        end
      end
    else
      edge.render(27,6,50,6+#setting.variables.users+1,colors.white,colors.cyan,"",colors.black)
      local count = 0
      for k,v in pairs(setting.variables.users) do
        count = count + 1
        edge.render(27,6+count,50,6+count+1,colors.white,colors.cyan," "..k,colors.black)
      end
    end
    --edge.render((mx/2)-(string.len("Feel free to suggest what to put here!")/2),my/2,(mx/2)-(string.len("Feel free to suggest what to put here!")/2),my/2,colors.white,colors.cyan,"Feel free to suggest what to put here!",colors.lightGray)
  end
  if page == "boot" then
    edge.render(1,5,mx,my,colors.white,colors.cyan,"",colors.white)
    edge.render(21,4,26,4,colors.green,colors.cyan," Boot ",colors.white)
    edge.render((mx/2)-(string.len("Feel free to suggest what to put here!")/2),my/2,(mx/2)-(string.len("Feel free to suggest what to put here!")/2),my/2,colors.white,colors.cyan,"Feel free to suggest what to put here!",colors.lightGray)
  end
  if page == "updates" then
    edge.render(1,5,mx,my,colors.white,colors.cyan,"",colors.white)
    edge.render(28,4,36,4,colors.green,colors.cyan," Updates ",colors.white)
    if setting.variables.temp.autoupdate == true then
      edge.render(2,6, 17, 6, colors.green, colors.cyan, " Auto update", colors.white)
    else
      edge.render(2,6,17,6,colors.white,colors.cyan, " Auto update", colors.black)
    end

  end
  if page == "api" then
    edge.render(1,5,mx,my,colors.white,colors.cyan,"",colors.white)
    edge.render(38,4,42,4,colors.green,colors.cyan," API ",colors.white)
    --edge.render((mx/2)-(string.len("Feel free to suggest what to put here!")/2),my/2,(mx/2)-(string.len("Feel free to suggest what to put here!")/2),my/2,colors.white,colors.cyan,"Feel free to suggest what to put here!",colors.lightGray)
    if setting.variables.users["KERNEL"].allow_apis then
      edge.render(27,6,45,6,colors.green,colors.cyan,"Allow custom APIs",colors.white ,false)
      edge.render(mx-string.len("Located in: "..setting.variables.temp.api_dir),7,45,7,colors.white,colors.cyan,"Located in: "..setting.variables.temp.api_dir,colors.lightGray)
      edge.render(27,8,45,8,colors.white,colors.cyan,"Get APIs from Pastebin",colors.gray)
      if not oldFS.exists(setting.variables.temp.api_dir) then
        oldFS.makeDir(setting.variables.temp.api_dir)
      end
    else
      edge.render(27,6,45,6,colors.white,colors.cyan,"Allow custom APIs",colors.gray,false)
      edge.render(mx-string.len("Located in: "..setting.variables.temp.api_dir),7,mx,7,colors.white,colors.cyan,"",colors.lightGray)
      edge.render(27,8,mx,8,colors.white,colors.cyan,"",colors.white)
    end
    if unreleased then
      if setting.variables.temp.ignore_blacklist then
        edge.render(27, 10, 45, 10, colors.green, colors.cyan, "Ignore API blacklist", colors.white)
      else
        edge.render(27, 10, 45, 10, colors.white, colors.cyan, "Ignore API blacklist", colors.gray)
      end
    end

    edge.render(1,5,25,my, colors.gray, colors.cyan, "", colors.black)
    edge.render(2,6,2,6,colors.gray, colors.cyan, "API Errors:", colors.white)
    local prevI = 0
    for k,v in ipairs(apiErrors) do
      edge.render(2,(6)+k,2,(6)+k,colors.gray, colors.gray,"", colors.white)
      local increment = edge.printWithinBounds(2,7+k+prevI,23,k..". "..v, colors.white)
      prevI = prevI+increment
    end
  end
  if page == "about" then
    local sides = {
      "top",
      "bottom",
      "back",
      "front",
      "left",
      "right",
    }
    local disks = {}
    local ignoreFolders = {}
    for k,v in ipairs(disks) do
      print(disks[k])
      table.remove(disks, k)

    end
    for k,v in ipairs(sides) do
      if disk.hasData(v) and disk.isPresent(v) then
        table.insert(disks, v)
        table.insert(ignoreFolders, disk.getMountPath(v))
        print(v)
      end
    end
      -- Credits to LDDSTROIER
      listAll = function(_path, _files, noredundant, excludeFiles)
      	local thisProgram = ""
      	if shell then
      		thisProgram = shell.getRunningProgram()
      	end
      	local path = _path or ""
      	local files = _files or {}
      	if #path > 1 then table.insert(files, path) end
      	for _, file in ipairs(oldFS.list(path)) do
      		local path = oldFS.combine(path, file)
      		if (file ~= thisProgram) and (not oldFS.isReadOnly(file)) then
      			local guud = true
      			for a = 1, #excludeFiles do
      				if excludeFiles[a] == file then
      					guud = false
      					break
      				end
      			end
      			if guud then
      				if oldFS.isDir(path) then
      					listAll(path, files, noredundant, excludeFiles)
      				else
      					table.insert(files, path)
      				end
      			end
      		end
      	end
      	if noredundant then
      		for a = 1, #files do
      			if oldFS.isDir(tostring(files[a])) then
      				if #oldFS.list(tostring(files[a])) ~= 0 then
      					table.remove(files,a)
      				end
      			end
      		end
      	end
      	return files
      end


    local  function getAllSpace(path)
      local freespace = oldFS.getFreeSpace(path or "")
      local filetree = listAll(path or "",{},false,ignoreFolders)
      for a = 1, #filetree do
        if not oldFS.isDir(filetree[a]) then
          freespace = freespace + oldFS.getSize(filetree[a])
        end
      end
      return freespace
    end

    -- Toy around with the following four variables to change logo size/width/pos,etc.
    local logoPos = 2
    local logoY = 6
    local logoWidth = 7
    local logoHeight = 4
    local logobg = colors.cyan
    local logotc = colors.white
    local vString = edition
    edge.render(1,5,mx,my,colors.white,colors.cyan,"",colors.white)
    edge.render(44,4,50,4,colors.green,colors.cyan," About ",colors.white)
    edge.render(2,6,mx-2,6,colors.white,colors.cyan,productName.." "..version,colors.gray)
    edge.render(2,7,mx-2,7,colors.white,colors.cyan,"Current user: "..setting.variables.users[currentUser].displayName.." debugID: "..setting.variables.temp.debugID,colors.gray)
    if setting.variables.temp.installDate ~= nil then
      if os.day()-setting.variables.temp.installDate > 31 then
        edge.render(2,8,mx-2,8,colors.white,colors.cyan,"Axiom UI MT Available.",colors.green)
        edge.render(2,9,13,9,colors.lightGray,colors.cyan," Learn More",colors.gray)
      else
        edge.render(2,8,mx-2,8,colors.white,colors.cyan,"Axiom UI MT Unavailable.",colors.gray)
      end
    else
      setting.variables.temp.installDate = os.day()
      writesettings()
      edge.render(2,8,mx-2,8,colors.white,colors.cyan,"Not elegible for Axiom UI MT TESTING",colors.gray)
    end

    edge.render(2,10,2,10,colors.white,colors.cyan,"Storage devices",colors.lightGray)
    edge.render(2,12,mx-2,12,colors.lightGray,colors.cyan,"",colors.white)
    local f = oldFS.list("/")
    local freeSpace = oldFS.getFreeSpace("/")
    local totalSize = 0
    for k,v in ipairs(f) do
      totalSize = totalSize + oldFS.getSize(v)
    end
    totalSize = getAllSpace("/")
    local percentUsed = ((totalSize-freeSpace)/totalSize)
    edge.render(2,11,2,11,colors.white,colors.cyan,"Local Disk",colors.gray)
    edge.render(2,12,2+((percentUsed*48)),12,colors.green,colors.cyan,"",colors.white)
    --print(2+(percentUsed*48)/48)
    edge.render(2,13,2,13,colors.white,colors.white,math.floor(((totalSize-freeSpace)/1024)).."/"..math.floor((totalSize/1024)).."kb used ("..(math.ceil(percentUsed*100)).."%)",colors.lightGray)

    local c = 0
      for l,b in ipairs(disks) do

        if disk.hasData(b) then
          local f = oldFS.list(disk.getMountPath(b))
          local freeSpace = oldFS.getFreeSpace(disk.getMountPath(b))
          local totalSize = 0
          for k,v in ipairs(f) do
            totalSize = totalSize + oldFS.getSize(disk.getMountPath(b).."/"..v)
          end
          totalSize = getAllSpace(disk.getMountPath(b))
          local percentUsed = ((totalSize-freeSpace)/totalSize)
          local label = disk.getLabel(b)
          local bootStatus = ""
          if oldFS.exists(disk.getMountPath(b).."/startup") then bootStatus = "(Bootable)" end
          if label == nil then
            label = disk.getMountPath(b)
          end
          edge.render(2,14+c,2,14+c,colors.white,colors.cyan,"Floppy (/"..tostring(disk.getMountPath(b))..") "..bootStatus,colors.gray)
          edge.render(2,15+c,mx-2,15+c,colors.lightGray,colors.cyan,"",colors.white)
          edge.render(2,15+c,2+((percentUsed*48)),15+c,colors.green,colors.cyan,"",colors.white)
          --print(2+(percentUsed*48)/48)
          edge.render(2,16+c,2,16+c,colors.white,colors.white,math.floor(((totalSize-freeSpace)/1024)).."/"..math.floor((totalSize/1024)).."kb used ("..(math.ceil(percentUsed*100)).."%)",colors.lightGray)
          c = c + 3
          term.setTextColor(colors.black)
        elseif disk.isPresent(b) then
          edge.render(2,14+c,2,14+c,colors.white,colors.cyan,"Unknown (Unknown Format/Corrupt)",colors.gray)
          edge.render(2,15+c,mx-2,15+c,colors.red,colors.cyan,"",colors.white)
          edge.render(2,16+c,2,16+c,colors.white,colors.white,"0/0kb used (0%)",colors.lightGray)
          c = c + 3
          --edge.render(2,15+c,2+((percentUsed*48)),15+c,colors.green,colors.cyan,"",colors.white)
        end
      end
  end
  if page == "about-mt" then
    local function textCenter(y, text)
      local tLength = string.len(text)
      local tLengthHalf = tLength/2
      local mx,my = term.getSize()
      edge.render((mx/2)-(tLengthHalf),y,(mx/2)+(tLengthHalf),y,colors.white,colors.white,text,colors.black,false)
    end
    local function textCenterButton(y, text,padding)
      local tLength = string.len(text)
      local tLengthHalf = tLength/2
      local mx,my = term.getSize()
      local tOffset = mx-(padding*2)
      edge.render(15,y,mx-15,y,colors.lightGray,colors.white,string.rep(" ",math.floor((tOffset/2)-tLengthHalf)+1)..text..string.rep(" ",math.floor((tOffset/2)-tLengthHalf)),colors.gray,false)

    end
    edge.render(1,5,mx,my,colors.white,colors.cyan,"",colors.white)
    term.setBackgroundColor(colors.white)
    term.setTextColor(colors.gray)
    textCenter(6,"What is Axiom UI MT?")
    term.setCursorPos(2,8)
    term.setBackgroundColor(colors.white)
    term.setTextColor(colors.gray)
    write("Axiom UI MT is a Multitasking Beta test that you\n are now elegible to use.\n This means that you will be able to take part in\n testing multitasking for Axiom.")
    textCenter(13,"How much does it cost?")
    term.setCursorPos(2,14)
    term.setBackgroundColor(colors.white)
    term.setTextColor(colors.gray)
    write("It's free! All you have to do is click the\n download button below.")

    textCenterButton(17,"Download",15)
    edge.render(2,18,2,18,colors.white,colors.white," (Axiom MT collects data for debugging. By downloading you agree with uploading debug data.)",colors.lightGray)
  end
end




function settings_new(startpage)
  local users = {}
  local count = 0
  for k,v in pairs(setting.variables.users) do
    if k ~= "KERNEL" then
      users[k] = {
        by = 6+count,
        confirmC = false,
      }
      count = count +1
    end

  end
  local mx, my = term.getSize()
  local currentpage = "main"
  if startpage then
    currentpage = startpage
  end
  menubarColor = colors.green
  edge.render(1,1,mx,1,menubarColor,colors.cyan," o*",colors.gray,false)
  if hasRednet then
    -- Check signal strength?
    if rednetDist < 10 then
      edge.render(37,1,37,1,menubarColor,colors.cyan,"¤>>>" ,colors.gray,false)
    elseif rednetDist > 10 and rednetDist < 20 then
      edge.render(37,1,37,1,menubarColor,colors.cyan,"¤>>" ,colors.gray,false)
    elseif rednetDist > 20 and rednetDist < 100 then
      edge.render(37,1,37,1,menubarColor,colors.cyan,"¤>" ,colors.gray,false)
    elseif rednetDist > 100 and rednetDist < 200 then
      edge.render(37,1,37,1,menubarColor,colors.cyan,"¤" ,colors.gray,false)
    elseif rednetDist > 200 then
      edge.render(37,1,37,1,menubarColor,colors.cyan,"¤x",colors.gray,false)
    end
  else
    edge.render(37,1,37,1,menubarColor,colors.cyan,"¤x",colors.red,false)
  end
  edge.render(1,2,mx,my,colors.white,colors.cyan,"",colors.black)
  edge.render(1,2,mx,4,colors.lime,colors.cyan,"",colors.black)
  edge.render(mx-2,2,mx-2,2,colors.lime,colors.cyan,"x",colors.red)
  settings_draw(currentpage)
  while true do

    local event, button, x,y = os.pullEvent("mouse_click")
    if x == mx-2 and y == 2 or event == "terminate" then
      writesettings()
      parallel.waitForAll(desktop,desktopIcons,clock)
    end
    if x >= 1 and x <= 8 and y == 4 and button == 1 then
      currentpage = "general"
      settings_draw(currentpage)
    end
    if x >= 11 and x <= 19 and y == 4 and button == 1 then
      currentpage = "account"
      settings_draw(currentpage)
    end
    if x >= 21 and x <= 26 and y == 4 then
      currentpage = "boot"
      settings_draw(currentpage)
    end
    if x >= 28 and x <= 36 and y == 4 then
      currentpage = "updates"
      settings_draw(currentpage)
    end
    if x >= 38 and x <= 42 and y == 4 then
      currentpage = "api"
      settings_draw(currentpage)
    end
    if x >= 44 and x <= 50 and y == 4 then
      currentpage = "about"
      settings_draw(currentpage)
    end
    if currentpage == "account" then

      if setting.variables.users[currentUser].superuser then
        edge.render(3,6,15,6,colors.white,colors.cyan,"Add new user account",colors.gray)
        if x >= 3 and x <= 15 and y == 6 then
          firstTimeSetupNew(true)
          edge.render(1,1,mx,1,menubarColor,colors.cyan," o*",colors.gray,false)
          --edge.render(1,2,mx,my,colors.white,colors.cyan,"",colors.black)
          edge.render(1,2,mx,4,colors.lime,colors.cyan,"",colors.black)
          edge.render(mx-2,2,mx-2,2,colors.lime,colors.cyan,"x",colors.red)
          settings_draw(currentpage)
        end

      else
        edge.render(3,6,15,6,colors.white,colors.cyan,"Add new user account",colors.lightGray)
        if x >= 3 and x <= 15 and y == 6 then
          edge.render(3,7,15,7,colors.white,colors.cyan,"SU required.",colors.red)

        end
      end
      if setting.variables.users[currentUser].superuser then
        if x >= 41 and x <= 42  then
          for k,v in pairs(users) do
            if y == users[k].by+1 then
              if users[k] ~= currentUser and users[k] ~= nil  then
                setting.variables.users[k].superuser = not setting.variables.users[k].superuser
                if setting.variables.users[k].superuser then
                  edge.render(41,users[k].by+1,42,users[k].by+1,colors.green,colors.cyan,"SU",colors.white)
                else
                  edge.render(41,users[k].by+1,42,users[k].by+1,colors.red,colors.cyan,"SU",colors.white)
                end
              end
            end

          end

        end
        if x >= 44 and x <= 49 then
          users = setting.variables.users
          for k,v in pairs(users) do -- TODO: unfuck
            if y == users[k].by+1 then
              if users[k] ~= currentUser and users[k] ~= nil then
                if users[k].confirmC == true then
                  edge.render(44,users[k].by+1,49,users[k].by+1,colors.red,colors.cyan,"DELETED",colors.white)
                  setting.variables.users[k] = nil
                  users[k] = nil
                else
                  edge.render(44,users[k].by+1,49,users[k].by+1,colors.red,colors.cyan,"CONFIRM",colors.white)
                  users[k].confirmC = true
                  break
                end



              end
            end --DELETE CONFIRM
          end
        end
      end



    end
    if currentpage == "updates" then
      if x >= 2 and x <= 17 and y == 6 then
        setting.variables.temp.autoupdate = not setting.variables.temp.autoupdate
        if setting.variables.temp.autoupdate == true then
          edge.render(2,6, 17, 6, colors.green, colors.cyan, " Auto update", colors.white)
        else
          edge.render(2,6,17,6,colors.white,colors.cyan, " Auto update", colors.black)
        end
      end
    end
    if currentpage == "api" then
      if x >= 25 and x <= 45 and y == 6 and button == 1 then
        if setting.variables.users["KERNEL"].allow_apis == true then
          setting.variables.users["KERNEL"].allow_apis = false
        else
          setting.variables.users["KERNEL"].allow_apis = true
        end
        if setting.variables.users["KERNEL"].allow_apis then
          edge.render(27,6,45,6,colors.green,colors.cyan,"Allow custom APIs",colors.gray,false)
          edge.render(mx-string.len("Located in: "..setting.variables.temp.api_dir),7,45,7,colors.white,colors.cyan,"Located in: "..setting.variables.temp.api_dir,colors.lightGray)
          edge.render(27,8,45,8,colors.white,colors.cyan,"Get APIs from Pastebin",colors.gray)
          if not oldFS.exists(setting.variables.temp.api_dir) then
            oldFS.makeDir(setting.variables.temp.api_dir)
          end
        else
          edge.render(27,6,45,6,colors.white,colors.cyan,"Allow custom APIs",colors.gray,false)
          edge.render(mx-string.len("Located in: "..setting.variables.temp.api_dir),7,mx,7,colors.white,colors.cyan,"",colors.lightGray)
          edge.render(27,8,mx,8,colors.white,colors.cyan,"",colors.white)
        end
      end
      if setting.variables.users["KERNEL"].allow_apis and x >= 25 and x <= 45 and y == 8 and button == 1 then
        edge.render(27,8,49,8,colors.lightGray,colors.cyan,"Enter PB code",colors.white)
        term.setCursorPos(27,8)
        tasks.clock = false
        term.setBackgroundColor(colors.lightGray)
        local pbcode = read()

        if pbcode ~= "" or pbcode ~= "exit" or pbcode ~= "cancel" then
          edge.render(27,8,49,8,colors.lightGray,colors.cyan,"Enter API name",colors.white)
          term.setBackgroundColor(colors.lightGray)
          term.setCursorPos(27,8)
          local name = read()

          local success = download("http://www.pastebin.com/raw/"..pbcode,setting.variables.temp.api_dir..name)
          if success then
            edge.render(27,8,49,8,colors.green,colors.cyan,"Download successful",colors.white)
          else
            edge.render(27,8,49,8,colors.red,colors.cyan,"Download unsuccessful",colors.white)
          end
          sleep(1)
          edge.render(27,8,45,8,colors.white,colors.cyan,"Get APIs from Pastebin",colors.black)
          tasks.clock = true
        else
          edge.render(27,8,45,8,colors.white,colors.cyan,"Cancelled",colors.red)
        end
      end
      if x >= 25 and x <= 45 and y == 10 and button == 1 then
        if unreleased then
          setting.variables.temp.ignore_blacklist = not setting.variables.temp.ignore_blacklist
          if setting.variables.temp.ignore_blacklist then
            edge.windowAlert(22, 9, "Warning: Ignoring API blacklists may result in system APIs being hijacked. Use with caution.", true, colors.red)
            settings_draw(currentpage)
            edge.render(27, 10, 45, 10, colors.green, colors.cyan, "Ignore API blacklist", colors.white)
          else
            edge.render(27, 10, 45, 10, colors.white, colors.cyan, "Ignore API blacklist", colors.gray)
          end
        end


      end
    end
    if currentpage == "general" then
      local bg_y = 6
      local bg = oldFS.list(edge.imageDir)
      if x >= 2 and x <= 24 and y >= 6 and y <= 6 + #bg-1 and allow_background_change == true then
        --edge.render(19,y,42,y,colors.green,colors.cyan,bg[y-5],colors.white,false)
        setting.variables.users[currentUser].background = bg[y-5]
        bg_y = 6
        for k,v in ipairs(bg) do
            if bg[k] == setting.variables.users[currentUser].background then
              edge.render(2,bg_y,24,bg_y,colors.green,colors.cyan,bg[k],colors.white,false)
              edge.render(24-string.len("CURRENT"),bg_y,24,bg_y,colors.green,colors.cyan,"current",colors.white,false)
            else
              edge.render(2,bg_y,24,bg_y,colors.white,colors.cyan,bg[k],colors.black,false)
            end
            bg_y = bg_y +1
        end
      end
      if x >= 2 and x <= 24 and y == bg_y+5 then
        fileselect = true
        local file = filebrowser(setting.variables.users[currentUser].image_dir,true)
        fileselect = false
        settings_draw(currentpage)
      end
    --  write(x..","..y)
      if x >= 2 and x <= 24 and y == bg_y+8 then
        axiom.alert("debug "..tostring(edge.getOverlay()))
        if edge.toggleOverlay() then

          edge.render(2,bg_y+8,24,bg_y+8,colors.green,colors.cyan,"Debug overlay enabled",colors.white,false)
          edge.debugSay("Enabled debug")
        else
          axiom.alert("debug "..tostring(edge.getOverlay()))
          edge.render(2,bg_y+8,24,bg_y+8,colors.red,colors.cyan,"Debug overlay disabled",colors.white,false)
          edge.debugSay("Disabled debug")
        end
        --axiom.alert("debug "..tostring(edge.getOverlay()))
        -- if edge.getOverlay() == true then
        --   edge.render(2,bg_y+4,24,bg_y+4,colors.green,colors.cyan,"Debug enabled",colors.white,false)
        --   edge.debugSay("Enabled debug")
        -- else
        --   edge.render(2,bg_y+4,24,bg_y+4,colors.red,colors.cyan,"Debug disabled",colors.black,false)
        --   edge.debugSay("Disabled debug")
        -- end
      end
      if x >= 25 and x <= 45 and y == 6 and button == 1 then

        if setting.variables.temp.system_skipsys_scan == true and setting.variables.users[currentUser].superuser then
          setting.variables.temp.system_skipsys_scan = false
        else
          setting.variables.temp.system_skipsys_scan = true
        end
        if setting.variables.temp.system_skipsys_scan then
          if setting.variables.users[currentUser].superuser then
            edge.render(27,6,45,6,colors.green,colors.cyan,"Skip system scan",colors.white,false)
          else
            edge.render(27,6,45,6,colors.lightGray,colors.cyan,"Skip system scan",colors.black,false)
          end
        else
          edge.render(27,6,45,6,colors.white,colors.cyan,"Skip system scan",colors.black,false)
        end
      end
      if x >= 25 and x <= 45 and y == 8 and button == 1 then

        if setting.variables.users[currentUser].system_skip_error then
          setting.variables.users[currentUser].system_skip_error = false
        else
          setting.variables.users[currentUser].system_skip_error = true
        end
        if setting.variables.users[currentUser].system_skip_error then
          edge.render(27,8,45,8,colors.green,colors.cyan,"Skip error screens",colors.white,false)
        else
          edge.render(27,8,45,8,colors.white,colors.cyan,"Skip error screens",colors.black,false)
        end
      end
      if x >= 25 and x <= 45 and y == 10 and button == 1 and setting.variables.users[currentUser].superuser then
        local pStat = setting.variables.temp.enable_telemetry
        if setting.variables.temp.enable_telemetry and setting.variables.temp.enable_telemetry ~= "forcedOff" then
          setting.variables.temp.enable_telemetry = false
        else
          if setting.variables.temp.enable_telemetry == "forcedOff" then
            return
          else
            setting.variables.temp.enable_telemetry = true

          end
        end
        if setting.variables.temp.enable_telemetry and setting.variables.temp.enable_telemetry ~= "forcedOff" then
          edge.render(27,10,45,10,colors.green,colors.cyan,"Enable telemetry",colors.white,false)
          --edge.render(27,11,45,10,colors.white,colors.cyan,"(Sends debug/crash info)",colors.gray,false)
        else
          edge.render(27,10,45,10,colors.white,colors.cyan,"Enable telemetry",colors.black,false)
        end

      end
      if x >= 25 and x <= 45 and y == 12 and button == 1 then
        setting.variables.temp.enable_animations = not setting.variables.temp.enable_animations
        if setting.variables.temp.enable_animations then
          edge.render(27,12,45,12,colors.green,colors.cyan,"Enable animations",colors.white,false)
          --edge.render(27,11,45,10,colors.white,colors.cyan,"(Sends debug/crash info)",colors.gray,false)
        else
          edge.render(27,12,45,12,colors.white,colors.cyan,"Enable animations",colors.black,false)
        end
      end
      if x >= 45 and x <= 50 and y == 10 and button == 1 then
        edge.windowAlert(25,12, "Telemetry sends information that Nothy can use to iron out bugs that you've stumbled across. Disabling this will not delete any previously sent info.", true)
        settings_draw(currentpage)
      end
      if x >= 46 and x <= 50 and y == 12 and button == 1 then
        edge.windowAlert(25,12, "Animations are just a nice touch to "..productName..". Disabling animations is a good idea when on a server.", true)
        settings_draw(currentpage)
      end
      if pStat == "forcedOff" and setting.variables.temp.enable_telemetry ~= "forcedOff" then
        setting.variables.temp.enable_telemetry = "forcedOff"
        writesettings()
      end
    end
    if currentpage == "about" then
      if os.day()-setting.variables.temp.installDate > 31 then
        if x >= 2 and x <= 13 and y == 9 then
          currentpage = "about-mt"
          settings_draw(currentpage)
        end
      end
    end
    if currentpage == "about-mt" then
      local function textCenterButton(y, text,padding)
        local tLength = string.len(text)
        local tLengthHalf = tLength/2
        local mx,my = term.getSize()
        local tOffset = mx-(padding*2)

        --print(math.floor((tOffset/2)-tLengthHalf)+1)
        edge.render(padding,y,mx-padding,y,colors.lightGray,colors.white,string.rep(" ",math.floor((tOffset/2)-tLengthHalf)+1)..text..string.rep(" ",math.floor((tOffset/2)-tLengthHalf)+1),colors.gray,false)

      end
      --something something download yadda yadda you get the drill.
      local padding = 11
      if x >= padding and x <= mx-padding and y == 17 then
        textCenterButton(17,"Connecting...",padding)
        local h = http.post("http://nothy.000webhostapp.com/","uid="..textutils.urlEncode(tostring(setting.variables.temp.debugID)))
        if h then
          textCenterButton(17,"Connection successful.",padding)

        else
          textCenterButton(17,"Connection failed.",padding)
        end
      --textCenterButton(17,"Not yet released",padding)
      end
    end
  end
end


function desktopIcons()
  edge.debugSay("Desktop icons disabled.")
  -- while(true) do
  --   if state == "main_gui" then
  --     local button = buttonapi.check()
  --     if button ~= nil then
  --       edge.log(button)
  --       if oldFS.exists("home/Desktop/"..button) then
  --         if oldFS.isDir("home/Desktop/"..button) then
  --           filebrowser("home/Desktop/"..button.."/")
  --           --axiom.alert("home/Desktop/"..button.."/")
  --         else
  --           local f = assert(loadfile("home/Desktop/"..button))
  --           local ok, err = pcall(f)
  --           if err then
  --             errorMessager(err)
  --           end
  --         end
  --       end
  --     end
  --   end
  --   break
  -- end
  sleep(0)

end

function terminal(dir)
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
    edge.render(1,2,51,19,colors.black,colors.black,"",colors.white,false)
  end
  term.setCursorPos(1,2)
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
    if oldFS.exists(workingDir.."/"..cmdTable[1]) and not oldFS.isDir(workingDir.."/"..cmdTable[1]) then
      shell.run(workingDir.."/"..cmdTable[1])
    end
  end
  if cmdTable[1] == "date" or cmdTable[1] == "day" then
    write("Day "..os.day().."\n")
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
  if cmdTable[1] == "axRecover" and setting.variables.users[currentUser].superuser then
    write("Recovery mode! Rebooting in 3 seconds. \n")
    sleep(1)
    write("Recovery mode! Rebooting in 2 seconds. \n")
    sleep(1)
    write("Recovery mode! Rebooting in 1 second. \n")
    sleep(1)
    oldFS.makeDir("firstBoot")
    oldFS.makeDir("safeStart")
    os.reboot()
  end
  if cmdTable[1] == "uninstall" then
    if setting.variables.users[currentUser].superuser then
      if edge.windowAlert(22, 9, "Are you sure?",false, colors.orange) then
        write("Uninstalling. \n")
        oldFS.delete("startup")
        oldFS.delete("/Axiom/libraries")
        oldFS.delete("/Axiom/images")
        oldFS.delete("/Axiom/sys.axs")
        oldFS.delete("/Axiom/settings.0")
        oldFS.delete("/Axiom/logging")
        oldFS.delete("/home")
        oldFS.delete("/users")
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
    os.reboot()
  end
  if cmdTable[1] == "users" then
    if setting.variables.users[currentUser].superuser then
      local c = 0
      for k,v in pairs(setting.variables.users) do
        write(c..": "..tostring(k).."\n")
        c = c +1
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
        if cmdTable[4] == "bruteforce" and cmdTable[5] == "devmode" and recoveryMode == true then
          currentUser = cmdTable[2]
          curUser = cmdTable[2]
          write("Brute forced into "..curUser.."\n")
        end
        if encryption.sha256(cmdTable[3].."QxLUF1bgIAdeQX") == setting.variables.users[cmdTable[2]].password then
          currentUser = cmdTable[2]
          curUser = cmdTable[2]
        else
          write("Invalid password.\n")
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

    if cmdTable[2] == "dev" then
      if setting.variables.users[curUser].superuser then
        write("Installing dev branch.. ")
        unreleased = true
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
      local fileList = oldFS.list(""..cmdTable[2])
      for k,v in ipairs(fileList) do
        if oldFS.isDir(workingDir.."/"..v) then
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
      local fileList = oldFS.list("/"..workingDir)
      for k,v in ipairs(fileList) do
        if oldFS.isDir(workingDir.."/"..v) then
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
      if oldFS.exists(workingDir.."/"..cmdTable[2]) then
        oldFS.delete(workingDir.."/"..cmdTable[2])
        term.setTextColor(colors.gray)
        write(cmdTable[2].." ")
        term.setTextColor(colors.white)
        write("was deleted. \n")

      end
    end
  end
  if cmdTable[1] == "su" then
    if setting.variables.users[currentUser].superuser then
      write("You are su! \n")
    else
      write("You are not su! \n")
    end
  end
  if cmdTable[1] == "cd" then
    if cmdTable[2] ~= nil then
      if cmdTable[2] ~= ".." then
        if cmdTable[2] ~= "/" then
          if oldFS.exists(workingDir.."/"..cmdTable[2]) then
            workingDir = workingDir.."/"..cmdTable[2]
          end
        else
          workingDir = "/"
        end
      else
        if oldFS.exists("/"..cmdTable[2]) and workingDir ~= "/" then
          workingDir = oldFS.getDir(workingDir)
        end
      end
    end
  end
  if cmdTable[1] == "mkdir" then
    if cmdTable[2] ~= nil then
      if not oldFS.exists(workingDir.."/"..cmdTable[2]) then
        oldFS.makeDir(workingDir.."/"..cmdTable[2])
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
end
function desktop()

    terminalActive = false
    if nightmode == true then
      menubarColor = colors.white
    else
      menubarColor = colors.white
    end
    if forcing then
      menubarColor = colors.orange
    end
    if state ~= "main_gui" and setting.variables.temp.enable_animations then
      edge.render(1,1,mx, my, colors.black, colors.white, "", colors.black)
      sleep(0.1)
      edge.render(1,1,mx, my, colors.gray, colors.white, "", colors.black)
      sleep(0.1)
      edge.render(1,1,mx, my, colors.lightGray, colors.white, "", colors.black)
      sleep(0.1)
    end
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
    if hasRednet then
      -- Check signal strength?
      if rednetDist < 10 then
        edge.render(37,1,37,1,menubarColor,colors.cyan,"¤>>>" ,colors.gray,false)
      elseif rednetDist > 10 and rednetDist < 20 then
        edge.render(37,1,37,1,menubarColor,colors.cyan,"¤>>" ,colors.gray,false)
      elseif rednetDist > 20 and rednetDist < 100 then
        edge.render(37,1,37,1,menubarColor,colors.cyan,"¤>" ,colors.gray,false)
      elseif rednetDist > 100 and rednetDist < 200 then
        edge.render(37,1,37,1,menubarColor,colors.cyan,"¤" ,colors.gray,false)
      elseif rednetDist > 200 then
        edge.render(37,1,37,1,menubarColor,colors.cyan,"¤x",colors.gray,false)
      end
    else
      edge.render(37,1,37,1,menubarColor,colors.cyan,"¤x",colors.red,false)
    end
    -- if #alerts > 0 then
    --   edge.render(34,1,34+string.len("alerts"),1,colors.white,colors.cyan,tostring(#alerts).." Alerts",colors.green,false)
    -- else
    --   edge.render(34,1,34+string.len("alerts"),1,colors.white,colors.cyan,"0 Alerts",colors.gray,false)
    -- end
    if #apiErrors > 0 and not dismissed and apiErrors[1] ~= "Blacklist ignored." then
      if edge.windowAlert(25,10,"It appears that some APIs failed to load during boot. Would you like to open API settings?", false) then
        dismissed = true
        settings_new("api")
      else
        dismissed = true
        desktop()
      end
    end
    x_p = 4
    --edge.log(announcement)

      if not announcement == "none" then
        edge.window(1,2,mx,my-1,"Important announcement")
        term.setCursorPos(1,3)
        term.setBackgroundColor(colors.white)
        term.setTextColor(colors.black)
        print('"'..announcement..'"')
        while(true) do
          local event, button, x, y = os.pullEvent("mouse_click")
          if x == mx and y == 2 or event == "terminate" then
            announcement = "none"
            desktop()

          end
        end
      end

    --edge.render(1,18,1,1,colors.cyan,colors.cyan,demo,colors.white,false)
    --edge.render(2,2,2,2,colors.white,colors.cyan,": Home",colors.black)
    --edge.render(2,4,8,4,colors.white,colors.cyan,": Update",colors.black)
    local desktopFiles = oldFS.list("home/Desktop/")
    local offset = 0
    local width = 7
    if button then
      buttonapi.clear()
    end
    for k,v in ipairs(desktopFiles) do
      if string.len(v) > 6 then
        substring = string.sub(v,7)
        filename = string.gsub(v,substring,"..")
        --axiom.alert(filename)
      else
        filename = v
      end
      if oldFS.isDir("home/Desktop/"..v) then
        edge.render(2+(offset),3,9+(offset),7,colors.green,colors.cyan,"",colors.white,false)
        edge.render(2+(offset),9,9+(offset),9,colors.white,colors.cyan,filename,colors.gray,false)
      else
        edge.render(2+(offset),3,9+(offset),7,colors.cyan,colors.cyan,"",colors.white,false)
        edge.render(2+(offset),9,9+(offset),9,colors.white,colors.cyan,filename,colors.gray,false)
      end
      offset = (width + 2) * k
    end

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
        if edge.windowAlert(20,5, "Logout?",false) then
          state = "loginscreen"
          login_gui_unreleased()
        else
          desktop()

        end
      end

      if x >= 34 and x <= 34+string.len("alerts") and y == 1 and button == 1 then
        edge.render(33,1,34+string.len("alerts"),1,colors.lightGray,colors.cyan,"   Alerts",colors.gray,false)
        edge.render(1,2,mx,my,colors.white,colors.cyan,"",colors.white,false)
        edge.render(6,1,18,1,colors.white,colors.cyan,"Clear alerts",colors.gray,false)
        local ry = 3
        for k,v in pairs(alerts) do
          if v.severity > 2 then
              edge.render(1,ry,mx,ry,colors.red,colors.cyan,tostring("[syserror] "..v.text),colors.white,false)
          else
              edge.render(1,ry,mx,ry,colors.lightGray,colors.cyan,tostring(v.prefix).." "..tostring(v.text),colors.white,false)
          end


          ry = ry + 2
        end
        while(true) do
          local event, button, x, y = os.pullEvent("mouse_click")
          if button == 2 then
            desktop()
          end
          if x >= 6 and x <= 18 and y == 1 and button == 1 then
            for i = 1, #alerts do alerts[i]=nil end
            desktop()
          end
          if x >= 34 and x <= 34+string.len("alerts") and y == 1 and button == 1 then
            desktop()
          end
        end
      end
      if x >= 1 and x <= 4 and y == 1 and button == 1 then
        edge.render(1,1,4,1,colors.gray,colors.cyan," o*",colors.white,false)
        edge.render(1,2,10,10,menubarColor,colors.cyan,"",colors.white,true)

        edge.render(1,2,10,2,menubarColor,colors.cyan,"   Menu   ",colors.black,false)
        edge.render(1,3,10,3,menubarColor,colors.cyan,"Update",colors.black,false)
        if updating then edge.render(1,3,10,3,menubarColor,colors.cyan,"Updating..",colors.black,false) end
        edge.render(1,4,10,4,menubarColor,colors.cyan,"Settings",colors.black,false)
        edge.render(1,5,10,5,menubarColor,colors.cyan,"Files",colors.black,false)
        edge.render(1,6,10,5,menubarColor,colors.cyan,"Terminal  ",colors.black,false)
        edge.render(1,7,10,7,menubarColor,colors.cyan,"Logout",colors.black,false)
        edge.render(1,8,10,8,menubarColor,colors.cyan,"Reboot",colors.black,false)
        edge.render(1,9,10,9,menubarColor,colors.cyan,"Shut down",colors.black,false)
        edge.render(1,10,10,10,menubarColor,colors.cyan,"Programs >",colors.black,false)
        while(true) do
          local event, button, x, y = os.pullEvent("mouse_click")
          if event == "terminate" then
            if edge.windowAlert(20,5, "Logout?",false) then
              state = "loginscreen"
              login_gui_unreleased()
            else
              desktop()

            end
          end
          if x >= 10 and y >= 1 or x >= 1 and y >= 11 or x >= 1 and x <= 4 and y == 1 then
            desktop()
          end
          if event == "terminate" then
            desktop()
          end
          if x >= 1 and x <= 10 and y == 3 then
            edge.render(1,3,10,3,menubarColor,colors.cyan,"Updating..",colors.black,false)
            execUpd()
            edge.render(1,3,10,3,menubarColor,colors.cyan,"Updated!",colors.green,false)
          end
          if x >= 1 and x <= 10 and y == 4 then
            --next.newTask("Axiom/Programs >/settings")
            settings_new()
          end
          if x >= 1 and x <= 10 and y == 6 then
            terminal("/")
            desktop()
          end
          if x >= 1 and x <= 10 and y == 5 then
            files = setting.variables.users[currentUser].fexplore_startdir
            filebrowser(files)
          end
          if x >= 1 and x <= 10 and y == 7 then
            shell.run("clear")
            state = "loginscreen"
            login_gui_unreleased()
          end
          if x >= 1 and x <= 10 and y == 8 then
            if setting.variables.temp.first_update == false then
              setting.variables.temp.first_update = true
              edge.render(1,1,mx,19,colors.cyan,colors.cyan,"",colors.black,false)
              edge.render(16,7,34,12,colors.white,colors.cyan,"",colors.black,true)
              edge.render(17,8,34,8,colors.white,colors.cyan,productName.." is updating ",colors.black,false)
              edge.render(17,10,34,10,colors.white,colors.cyan,"  Please wait.",colors.black,false)
              execUpd()
              writesettings()
              os.reboot()
            end
            writesettings()
            sleep(0.5)
            os.reboot()
          end
          if x >= 1 and x <= 10 and y == 10 then
            sysInfo()
          end
          if x >= 1 and x <= 10 and y == 9 then
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

function sysInfo()
  edge.log("started sysinfo")
  state = "sysInfo"
  edge.log("getting free space")
  local currentFreeSpace = oldFS.getFreeSpace("/")
  local currentFreeSpaceKB = math.floor(currentFreeSpace/1024)
  menubarColor = colors.green
  edge.log("got free space")
  edge.render(1,1,mx,1,menubarColor,colors.cyan," o*",colors.gray,false)
  if hasRednet then
    -- Check signal strength?
    if rednetDist < 10 then
      edge.render(37,1,37,1,menubarColor,colors.cyan,"¤>>>" ,colors.gray,false)
    elseif rednetDist > 10 and rednetDist < 20 then
      edge.render(37,1,37,1,menubarColor,colors.cyan,"¤>>" ,colors.gray,false)
    elseif rednetDist > 20 and rednetDist < 100 then
      edge.render(37,1,37,1,menubarColor,colors.cyan,"¤>" ,colors.gray,false)
    elseif rednetDist > 100 and rednetDist < 200 then
      edge.render(37,1,37,1,menubarColor,colors.cyan,"¤" ,colors.gray,false)
    elseif rednetDist > 200 then
      edge.render(37,1,37,1,menubarColor,colors.cyan,"¤x",colors.gray,false)
    end
  else
    edge.render(37,1,37,1,menubarColor,colors.cyan,"¤x",colors.red,false)
  end
  edge.render(1,2,51,19,colors.white,colors.cyan,"",colors.black,false)
  edge.render(1,2,51,4,colors.lime,colors.cyan,"",colors.white,false)
  edge.render(1,3,51,4,colors.lime,colors.cyan,"                                                x",colors.white,false)
  edge.render(3,3,25,3,colors.lime,colors.cyan,"cache.discoverAppStore",colors.white,false)
  -- minumum render value: 5
  edge.log("rendered info")
  while(true) do
    sleep(0)
    edge.log("waiting for event")
    local event, button, x, y = os.pullEvent("mouse_click")
    edge.log("got event "..event..tostring(button))
    if button ~= nil and event == "mouse_click" then
      if x == 49 and y == 3 and button == 1 and event == "mouse_click" then
        menubarColor = colors.white
        disableclock = false
        tasks.clock = true
        parallel.waitForAll(desktop,clock)
      end
      if x >= 1 and x <= 4 and y == 1 and button == 1 and event == "mouse_click" then
        edge.render(1,1,4,1,colors.gray,colors.cyan," o*",colors.white,false)
        edge.render(1,2,10,10,menubarColor,colors.cyan,"",colors.white,true)

        edge.render(1,2,10,2,menubarColor,colors.cyan,"   Menu   ",colors.black,false)
        edge.render(1,3,10,3,menubarColor,colors.cyan,"Update",colors.black,false)
        edge.render(1,4,10,4,menubarColor,colors.cyan,"Settings",colors.black,false)
        edge.render(1,5,10,5,menubarColor,colors.cyan,"Files",colors.black,false)
        edge.render(1,6,10,5,menubarColor,colors.cyan,"Terminal  ",colors.black,false)
        edge.render(1,7,10,7,menubarColor,colors.cyan,"Logout",colors.black,false)
        edge.render(1,8,10,8,menubarColor,colors.cyan,"Reboot",colors.black,false)
        edge.render(1,9,10,9,menubarColor,colors.cyan,"Shut down",colors.black,false)
        edge.render(1,10,10,10,menubarColor,colors.cyan,"Programs >",colors.black,false)
        while(true) do
          local event, button, x, y = os.pullEvent("mouse_click")
          if x >= 10 and y >= 1 or x >= 1 and y >= 11 or x >= 1 and x <= 4 and y == 1 and event == "mouse_click" then
            sysInfo()
          end
          if event == "terminate" then
            disableclock = false
            tasks.clock = true
            parallel.waitForAll(desktop,clock)
          end
          if x >= 1 and x <= 10 and y == 3 and event == "mouse_click" then
            edge.render(1,3,10,3,menubarColor,colors.cyan,"Updating..",colors.black,false)
            execUpd()
            edge.render(1,3,10,3,menubarColor,colors.cyan,"Updated!",colors.green,false)
          end
          if x >= 1 and x <= 10 and y == 4 and event == "mouse_click" then
            --next.newTask("Axiom/Programs >/settings")
            settings_new()
          end
          if x >= 1 and x <= 10 and y == 6 and event == "mouse_click" then
            terminal("/")
            desktop()
          end
          if x >= 1 and x <= 10 and y == 5 and event == "mouse_click" then
            filebrowser()
          end
          if x >= 1 and x <= 10 and y == 7 and event == "mouse_click" then
            shell.run("clear")
            state = "loginscreen"
            login_gui_unreleased()
          end
          if x >= 1 and x <= 10 and y == 8 then
            if setting.variables.temp.first_update == false then
              setting.variables.temp.first_update = true
              edge.render(1,1,mx,19,colors.cyan,colors.cyan,"",colors.black,false)
              edge.render(16,7,34,12,colors.white,colors.cyan,"",colors.black,true)
              edge.render(17,8,34,8,colors.white,colors.cyan,productName.." is updating ",colors.black,false)
              edge.render(17,10,34,10,colors.white,colors.cyan,"  Please wait.",colors.black,false)
              execUpd()
              writesettings()
              os.reboot()
            end
            writesettings()
            sleep(0.5)
            os.reboot()
          end
          if x >= 1 and x <= 10 and y == 10 and event == "mouse_click" then
            sysInfo()
          end
          if x >= 1 and x <= 10 and y == 9 and event == "mouse_click" then
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
            if x >= 1 and x <= 10 and y == 8 then
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
              sleep(0.5)
              if hasRednet then
                rednet.close(detectedSide)
              end
              os.shutdown()
            end
          end
        end
      end
    end
    if event == "terminate" then
      menubarColor = colors.white
      disableclock = false
      tasks.clock = true
      parallel.waitForAll(desktop,clock)
    end
  end
end
function filebrowser(startDir,select)
  if fileselect == true then select = true end
  if not select then
    select = false
  end
  edge.log("file browser started with dir "..tostring(startDir))
  state = "filebrowser"
  tasks.filebrowser = true
  menubarColor = colors.green
  --files = setting.variables.users[currentUser].fexplore_startdir
  if setting.getVariable("Axiom/settings.0","licensed") == "false" or setting.getVariable("Axiom/settings.0","general_background_name") == "black" then
    edge.render(1,1,51,19,colors.black,colors.cyan,"",colors.black,false)
  else
    edge.image(1,1,setting.variables.users[currentUser].background ,colors.cyan)
  end
  edge.render(1,1,mx,1,menubarColor,colors.cyan," o*",colors.gray,false)
  if hasRednet then
    -- Check signal strength?
    if rednetDist < 10 then
      edge.render(37,1,37,1,menubarColor,colors.cyan,"¤>>>" ,colors.gray,false)
    elseif rednetDist > 10 and rednetDist < 20 then
      edge.render(37,1,37,1,menubarColor,colors.cyan,"¤>>" ,colors.gray,false)
    elseif rednetDist > 20 and rednetDist < 100 then
      edge.render(37,1,37,1,menubarColor,colors.cyan,"¤>" ,colors.gray,false)
    elseif rednetDist > 100 and rednetDist < 200 then
      edge.render(37,1,37,1,menubarColor,colors.cyan,"¤" ,colors.gray,false)
    elseif rednetDist > 200 then
      edge.render(37,1,37,1,menubarColor,colors.cyan,"¤x",colors.gray,false)
    end
  else
    edge.render(37,1,37,1,menubarColor,colors.cyan,"¤x",colors.red,false)
  end
  edge.render(1,2,51,2,colors.lime,colors.cyan,"                                          _ x",colors.black,false)
  edge.render(1,4,51,19,colors.white,colors.cyan,"",colors.black,true)
  edge.render(1,3,51,4,colors.lime,colors.cyan,"",colors.black,false)
  --edge.render(7,4,7,4,colors.white,colors.cyan,"Files: <Up>",colors.black)
  edge.render(7,3,39,3,colors.white,colors.cyan,os.getComputerID()..":"..files,colors.black)
  edge.render(41,3,41,3,colors.lime,colors.cyan," Back ",colors.black)
  edge.render(7,4,7,4,colors.lime,colors.cyan," New folder   New file   Delete ",colors.black)
  edge.render(2,5,7,5,colors.white,colors.cyan,"| Name |                     | Size |  | Type |",colors.lightGray)
  if not oldFS.exists(files) then
    f_file = oldFS.list("/home/")
  else
    if startDir then
      if oldFS.exists(startDir) then
        files = startDir
      end
    end
    f_file = oldFS.list(files)
  end


  fy = 6
  foy = 5
  edge.log("listing files")
  for i,v in ipairs(f_file) do

    if oldFS.isDir(files..f_file[i]) then
      if f_file[i] == "rom" then

      else
        local l = oldFS.list(files..f_file[i].."/")
        edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.blue,false)
        edge.render(42,fy,42,fy,colors.white,colors.cyan,"Folder",colors.black)
        edge.render(31,fy,41,fy,colors.white,colors.cyan,#l.." items",colors.black)
      end
      fy = fy +1
    else
      if f_file[i] == "edge" or f_file[i] == "next" or f_file[i] == "settings" or f_file[i] == "encryption" then

        edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
        edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(oldFS.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
        edge.render(40,fy,40,fy,colors.white,colors.cyan,"API",colors.orange)
      else
        if f_file[i] == "sys.axs" or f_file[i] == "settings.0" then
          edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
          edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(oldFS.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
          edge.render(42,fy,40,fy,colors.white,colors.cyan,"Sys",colors.red)
        elseif f_file[i] == "startup" then
          edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
          edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(oldFS.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
          edge.render(40,fy,40,fy,colors.white,colors.cyan,"Bootloader",colors.red)
        else
          if string.find(f_file[i],".lua",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(oldFS.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,40,fy,colors.white,colors.cyan,"Lua Script",colors.blue)
          elseif string.find(f_file[i],".js",string.len(f_file[i]) - 3) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(oldFS.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,40,fy,colors.white,colors.cyan,"JavaScript",colors.orange)
          elseif string.find(f_file[i],".cs",string.len(f_file[i]) - 3) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(oldFS.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,40,fy,colors.white,colors.cyan,"C# Script",colors.red)
          elseif string.find(f_file[i],".xml",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(oldFS.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,40,fy,colors.white,colors.cyan,"XML Config",colors.blue)
          elseif string.find(f_file[i],".nfp",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(oldFS.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,40,fy,colors.white,colors.cyan,"Image",colors.magenta)
          elseif string.find(f_file[i],".html",string.len(f_file[i]) - 5) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(oldFS.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,40,fy,colors.white,colors.cyan,"Webpage",colors.green)
          elseif string.find(f_file[i],".sys",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(oldFS.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,40,fy,colors.white,colors.cyan,"System File",colors.black)
          elseif string.find(f_file[i],".dll",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(oldFS.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(42,fy,40,fy,colors.white,colors.cyan,"DLL",colors.black)
          elseif string.find(f_file[i],".txt",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(oldFS.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,40,fy,colors.white,colors.cyan,"Text File",colors.green)
          elseif string.find(f_file[i],".log",string.len(f_file[i]) - 4) then
            if files..f_file[i] == "Axiom/stacktrace.log" then
              edge.render(20,fy,20,fy,colors.white,colors.cyan,"CRASH LOG",colors.red,false)
            end
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(oldFS.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,40,fy,colors.white,colors.cyan,"Log File",colors.green)
          elseif string.find(f_file[i],".cfg",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(oldFS.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,40,fy,colors.white,colors.cyan,"Config file",colors.blue)
          elseif string.find(f_file[i],".pref",string.len(f_file[i]) - 5) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(oldFS.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(41,fy,40,fy,colors.white,colors.cyan,"Pref",colors.black)
          elseif string.find(f_file[i],".axg",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(oldFS.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,40,fy,colors.white,colors.cyan,"Image",colors.magenta)
          elseif string.find(f_file[i],".jar",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(oldFS.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(42,fy,40,fy,colors.white,colors.cyan,"Jar",colors.black)
          elseif string.find(f_file[i],".py",string.len(f_file[i]) - 3) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(oldFS.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,40,fy,colors.white,colors.cyan,"Python Script",colors.black)
          elseif string.find(f_file[i],".hta",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(oldFS.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(42,fy,40,fy,colors.white,colors.cyan,"HTA",colors.black)
          elseif string.find(f_file[i],".cpp",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(oldFS.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,40,fy,colors.white,colors.cyan,"C++ Script",colors.black)
          elseif string.find(f_file[i],".app",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(oldFS.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,40,fy,colors.white,colors.cyan,"Program",colors.black)
          elseif string.find(f_file[i],".java",string.len(f_file[i]) - 5) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(oldFS.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,40,fy,colors.white,colors.cyan,"Java Class",colors.black)
          elseif string.find(f_file[i],".class",string.len(f_file[i]) - 6) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(oldFS.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,40,fy,colors.white,colors.cyan,"Java Class",colors.black)
          elseif string.find(f_file[i],".zip",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(oldFS.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,40,fy,colors.white,colors.cyan,"ZIP Archive",colors.black)
          elseif string.find(f_file[i],".axp",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(oldFS.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,40,fy,colors.white,colors.cyan,productName.." Program",colors.red)
          elseif string.find(f_file[i],".cmd",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(oldFS.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,40,fy,colors.white,colors.cyan,"Command",colors.green)
          elseif string.find(f_file[i],".axs",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(oldFS.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,40,fy,colors.white,colors.cyan,"Sys",colors.red)
          else
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(oldFS.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(42,fy,40,fy,colors.white,colors.cyan,"File",colors.black)
          end
        end
      end
      fy = fy+1
    end
    --edge.render(7,fy,7,fy,colors.white,colors.cyan,file[i],colors.black,false)
  end
  if fileselect then
    edge.render(1,19,51,19,colors.white,colors.cyan,"Right-click to select.",colors.black,false)
  end
  edge.log("listed files")
  while(true) do
    edge.log("waiting for event")
    event, button, x, y = os.pullEvent("mouse_click")
    edge.log("caught event")
    if x >= 1 and x <= 4 and y == 1 and button == 1 then
      edge.log("menu")
      edge.render(1,1,4,1,colors.gray,colors.cyan," o*",colors.white,false)
      edge.render(1,2,10,10,menubarColor,colors.cyan,"",colors.white,true)

      edge.render(1,2,10,2,menubarColor,colors.cyan,"   Menu   ",colors.black,false)
      edge.render(1,3,10,3,menubarColor,colors.cyan,"Update",colors.black,false)
      edge.render(1,4,10,4,menubarColor,colors.cyan,"Settings",colors.black,false)
      edge.render(1,5,10,5,menubarColor,colors.cyan,"Files",colors.black,false)
      edge.render(1,6,10,5,menubarColor,colors.cyan,"Terminal  ",colors.black,false)
      edge.render(1,7,10,7,menubarColor,colors.cyan,"Logout",colors.black,false)
      edge.render(1,8,10,8,menubarColor,colors.cyan,"Reboot",colors.black,false)
      edge.render(1,9,10,9,menubarColor,colors.cyan,"Shut down",colors.black,false)
      edge.render(1,10,10,10,menubarColor,colors.cyan,"Programs > >",colors.black,false)
      while(true) do
        local event, button, x, y = os.pullEvent("mouse_click")
        if x >= 10 and y >= 1 or x >= 1 and y >= 11 or x >= 1 and x <= 4 and y == 1 then
          files = setting.variables.users[currentUser].fexplore_startdir
          filebrowser(files)

        end
        if event == "terminate" then
          disableclock = false
          tasks.clock = true
          parallel.waitForAll(desktop,clock)
        end
        if x >= 1 and x <= 10 and y == 3 then
          edge.render(1,3,10,3,menubarColor,colors.cyan,"Updating..",colors.black,false)
          execUpd()
          edge.render(1,3,10,3,menubarColor,colors.cyan,"Updated!",colors.green,false)
        end
        if x >= 1 and x <= 10 and y == 4 then
          --next.newTask("Axiom/Programs > >/settings")
          settings_new()
        end
        if x >= 1 and x <= 10 and y == 6 then
          terminal("/")
          desktop()
        end
        if x >= 1 and x <= 10 and y == 5 then
          files = setting.variables.users[currentUser].fexplore_startdir
          filebrowser(files, fileselect)
        end
        if x >= 1 and x <= 10 and y == 7 then
          shell.run("clear")
          state = "loginscreen"
          login_gui_unreleased()
        end
        if x >= 1 and x <= 10 and y == 8 then
          if setting.variables.temp.first_update == false then
            setting.variables.temp.first_update = true
            edge.render(1,1,mx,19,colors.cyan,colors.cyan,"",colors.black,false)
            edge.render(16,7,34,12,colors.white,colors.cyan,"",colors.black,true)
            edge.render(17,8,34,8,colors.white,colors.cyan,productName.." is updating ",colors.black,false)
            edge.render(17,10,34,10,colors.white,colors.cyan,"  Please wait.",colors.black,false)
            execUpd()
            writesettings()
            os.reboot()
          end
          writesettings()
          sleep(0.5)
          os.reboot()
        end
        if x >= 1 and x <= 10 and y == 10 then
          sysInfo()
        end
        if x >= 1 and x <= 10 and y == 9 then
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
            sleep(0.5)
            if hasRednet then
              rednet.close(detectedSide)
            end
            os.shutdown()
          end
      end
    end
    if event == "terminate" then
      files = setting.variables.users[currentUser].fexplore_startdir
      tasks.filebrowser = false
      fileselect = false
      --menubarColor = colors.white
      disableclock = false
      tasks.clock = true
      parallel.waitForAll(desktop,clock)
    end
    if x == 45 and y == 2 and button == 1 then
      files = setting.variables.users[currentUser].fexplore_startdir
      tasks.filebrowser = false
      --menubarColor = colors.white
      disableclock = false
      tasks.clock = true
      fileselect = false
      parallel.waitForAll(desktop,clock)
    end
    if x == 43 and y == 2 and button == 1 then
      tasks.filebrowser = false
      --menubarColor = colors.white
      disableclock = false
      tasks.clock = true
      parallel.waitForAll(desktop,clock)
    end
    if x >= 42 and y == 3 and x <= 45 and y == 3 then
      edge.log("F:"..oldFS.getDir(files))
      if oldFS.getDir(files) == ".." then
      else
        files = "/"..oldFS.getDir(files).."/"
        filebrowser(files, fileselect)
      end
    end
    if x >= 7 and x <= 7+string.len("<New folder>") and y == 4 and button == 1 then
      tasks.settings_app = true
      term.setBackgroundColor(colors.blue)
      term.setTextColor(colors.black)
      edge.render(1,16,51,19,colors.white,colors.cyan,"Create folder:",colors.black,true)
      edge.render(1,17,51,19,colors.white,colors.lightGray,"(In current dir)",colors.lightGray)
      edge.render(2,18,50,18,colors.lightGray,colors.lightGray,"/",colors.black)
      term.setTextColor(colors.black)
      term.setCursorPos(3,18)

      local input = read()
      term.setBackgroundColor(colors.cyan)
      term.setTextColor(colors.white)
      tasks.settings_app = false
      if not oldFS.exists(files..input) then
        oldFS.makeDir(files..input)
        edge.log("Created folder: "..files..input)
      end
      filebrowser()
    end
    if x >= 19 and x <= 19+string.len("<New file>") and y == 4 and button == 1 then
      tasks.settings_app = true
      edge.render(1,16,51,19,colors.white,colors.cyan,"Create file:",colors.black,true)
      edge.render(1,17,51,19,colors.white,colors.lightGray,"(In current dir)",colors.lightGray)
      edge.render(2,18,50,18,colors.lightGray,colors.lightGray,"/",colors.black)
      term.setTextColor(colors.black)
      term.setCursorPos(3,18)

      local input = read()
      term.setBackgroundColor(colors.cyan)
      term.setTextColor(colors.white)
      if input == nil then
        filebrowser(files, fileselect)
      else
        if not oldFS.exists(files..input) then
          local a = oldFS.open(files..input,"w")
          a.close()
          edge.log("Created file: "..files..input)
          filebrowser(files, fileselect)
        else
          filebrowser(files, fileselect)
        end
      end
    end
    if x >= 30 and x <= 30+string.len("<Delete>") and y == 4 and button == 1 then
      tasks.settings_app = true
      edge.render(1,16,51,19,colors.white,colors.cyan,"Delete file:",colors.black,true)
      edge.render(1,17,51,19,colors.white,colors.lightGray,"(In current dir)",colors.lightGray)
      edge.render(2,18,50,18,colors.lightGray,colors.lightGray,"/",colors.black)
      term.setTextColor(colors.black)
      term.setCursorPos(3,18)

      local input = read()
      if not oldFS.exists(files..input) then
        return
      end
      if input ~= "" then
        if not string.find(input,".axs",string.len(input) - 4) or not string.find(input,".0",string.len(input) - 2) then
          if oldFS.exists(files..input) then
            term.setBackgroundColor(colors.cyan)
            term.setTextColor(colors.white)
            local ok = edge.windowAlert(15,5,"Delete "..files..input.."?")
            if ok then
              fs.delete(files..input)
              edge.log("Deleted file: "..files..input)
            else
              edge.log("Delete action cancelled by user ("..files..input..")")
            end
            edge.log("Deleted file: "..files..input)
          else
            edge.log("Delete failed: "..files..input.." does not exist!")
          end
        else
          edge.render(16,7,34,12,colors.lightGray,colors.cyan,"Unexpected error",colors.black,true)
          --edge.render(18,9,32,9,colors.white,colors.lightGray,"(In current dir)",colors.lightGray)
          edge.render(16,10,34,10,colors.lightGray,colors.lightGray,"File access denied.",colors.black)
          term.setTextColor(colors.black)
          sleep(5)
        end
      elseif input == "*" then
        local fl = oldFS.list(files.."/")
        for k,v in ipairs(fl) do
          if oldFS.exists(files..fl[k]) then
            local ok = edge.windowAlert(15,5,"Are you sure?")
            if ok then
              fs.delete(files..fl[k])
              edge.log("Deleted file: "..files..fl[k])
            else
              edge.log("Delete action cancelled by user ("..files..fl[k]..")")
            end
          else
            edge.log("Delete failed: "..files..input)
          end
        end
      else
        edge.log("User entered nothing")
      end
      filebrowser(files, fileselect)
    end
    if button == 1 and event == "mouse_click" then
      for i=1, #f_file do
        if x > 2 and x <= 23 and y == 5+i then
          if oldFS.isDir(files..f_file[i]) and f_file[i] ~= "rom" then
            previousDir = files
            files = files..""..f_file[i].."/"
            filebrowser(files, fileselect)
          else
            tasks.settings_app = true
            term.setBackgroundColor(colors.black)
            if not oldFS.exists("home/prg/luaide.app") then
              shell.run("edit "..files..f_file[i])
            else
              shell.run("home/prg/luaide.app "..files..f_file[i])
            end
            parallel.waitForAll(filebrowser,clock)
            tasks.settings_app = false
          end
        end
      end
    end
    if button == 2 and event == "mouse_click" then

      for i=1, #f_file do
        if x > 2 and x <= 20 and y == 5+i then
          edge.log(tostring(oldFS.isDir(files..f_file[i]))..":"..files..f_file[i])
          --print(files)
          --print(f_file[i])
          edge.log("File:"..files..f_file[i])
          if oldFS.isDir(files..f_file[i]) then
            if fileselect then

              return files_f_file[i]
            end
          else
            if fileselect then
              return files_f_file[i]
            else
              if files..f_file[i] == "startup" then
                error("An instance of "..productName" is already running")
              else
                if not oldFS.exists(files..f_file[i]) then
                  error("File not found")
                else
                  if string.find(files..f_file[i],".app",string.len(f_file[i]) - 4) or string.find(files..f_file[i],".lua",string.len(f_file[i]) - 4) or string.find(files..f_file[i],".cmd",string.len(f_file[i]) - 4) or string.find(files..f_file[i],".axp",string.len(f_file[i]) - 4) then
                    menubarColor = colors.white
                    local chkhash = oldFS.open(files..f_file[i],"r")
                    for k,v in ipairs(bannedHashes) do
                      if encryption.sha256(chkhash.readAll()) == v then
                        axiom.alert(productName.." has protected your PC.",3)
                        axiom.alert("Malware hash matched",3)
                        oldFS.delete(files..f_file[i])
                        chkhash.close()
                        filebrowser("/")
                      end
                    end
                    chkhash.close()

                    edge.render(1,1,51,1,menubarColor,colors.cyan," o*",colors.black,false)
                    edge.log("File:"..files..f_file[i])
                    local f = assert(loadfile(files..f_file[i]))
                    f()
                  end
                end
                filebrowser()
              end
            end
          end
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
    edge.render(3,5,3,5,colors.white,colors.cyan,olicense.readAll(),colors.lightGray)
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
    if adduser then
      setting.addUser(usr,encryption.sha256(pw.."QxLUF1bgIAdeQX"),usr)
    else
      setting.addUser(usr,encryption.sha256(pw.."QxLUF1bgIAdeQX"),usr,true)
    end
    setting.variables.temp.first_start = false
    sleep(3)
    writesettings()
    if not adduser then
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
      if not adduser then
        os.setComputerLabel("Axiom PC: "..username)
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
  if not oldFS.exists("Axiom/settings.0") then
    axiom.alert("FATAL ERROR, SETTINGS FILE NOT FOUND.",3)
    return false, "axiom/settings.0 could not be found."
  end
  print(tostring(setting.variables.temp.first_start))

  if setting.variables.temp.first_start == true or setting.variables.temp.first_start == nil  then
    setting.variables.temp.first_start = false
    setting.variables.temp.installDate = os.day()
    writesettings()
    firstTimeSetupNew()
  else
    edge.log("User already has account")
  end
  if setting.variables.temp.debugID == 0 or setting.variables.temp.debugID == 0  then
    setting.variables.temp.debugID = "user-"..math.random(100000,999999)
    writesettings()
  end
  --login_gui()
  parallel.waitForAll(login_gui_unreleased,keyStrokeHandler,modemHandler)
  --parallel.waitForAll(login_gui_unreleased,notifHandler,taskHandler,eventHandler)
end
function cprint( text, y )
  local x = term.getSize()
  local centerXPos = ( x - string.len(text) ) / 2
  term.setCursorPos( centerXPos, y )
  write( text )
end
function bootanimation()
  if not oldFS.exists("Axiom/libraries/edge") then
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
  tasks.kernel = true
  --print("edge")
  os.loadAPI("Axiom/libraries/edge")
  --print("setting")
  os.loadAPI("Axiom/libraries/setting")
  --print("encryption")
  os.loadAPI("Axiom/libraries/encryption")
  --print("loaded apis")
  if not edge then os.reboot() end
  if unreleased then
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.black)
  else
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
  end
  --sleep(10)
  shell.run("clear")
  if not setting.variables.users["KERNEL"].system_skipsys_scan then
    for k,v in ipairs(allfiles) do
      if oldFS.exists(allfiles[k]) then
        edge.log(allfiles[k].." OK")
      else
        sleep(0.1)
        edge.log(allfiles[k].." MISSING")
        fixNeeded = true
      end
    end
    latestversion = http.get("http://www.nothy.se/Axiom/CurrentUpdate")
    announcement = http.get("http://www.nothy.se/Axiom/Announcement")
    if announcement then
      announcement = tostring(announcement.readAll())
    end
  end
  local mx, my = term.getSize()

  if setting.variables.users["KERNEL"].allow_apis == true then
    local dir = setting.variables.temp.api_dir
    if setting.variables.temp.api_dir ~= nil then
      local fileList = oldFS.list(dir)
      local t = 0
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
          if not apil then
            os.unloadAPI(apil)
            --if err then print(err) sleep(3) end
            table.insert(apiErrors, api.." could not load")
          end
        else
          table.insert(apiErrors, api.." not loaded. (access denied)")
        end
        --sleep(0.2)
        --sleep(3)
      end
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
  edge.render(1,1,mx, my, colors.white, colors.white, "", colors.black)
  sleep(0.1)

  --log("settings "..tostring(sysSettings))
  if not setting.variables.temp.system_skipsys_scan then
    if oldFS.exists("Axiom/log.txt") then
      if oldFS.getSize("Axiom/log.txt") >= 12000 then
        oldFS.delete("Axiom/log.txt")
      end
    end
    local fileList = oldFS.list("/")
    local loaded = 0
    local toLoad = #fileList

    for _, file in ipairs(fileList) do
      if file == "rom" then
        log("SYSTEM: CraftOS System file detected '"..file.."'. Ignoring")
        --edge.render(midx - string.len("Disallowed file detected, removing") / 2,8,48,8,colors.white,colors.cyan,"Disallowed file detected, removing",colors.black)
      else
        if oldFS.isDir(file) then
          log("SYSTEM: Verified folder "..file.."/ and it's contents")
        else
          log("SYSTEM: Verified file "..file)

          term.setTextColor(colors.lightGray)

          if unreleased then
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
  while c ~= 2 do
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
  edge.render(1,1,mx, my, colors.white, colors.white, "", colors.black)
  sleep(0.1)
  edge.render(1,1,mx, my, colors.lightGray, colors.white, "", colors.black)
  sleep(0.1)
  edge.render(1,1,mx, my, colors.gray, colors.white, "", colors.black)
  sleep(0.1)
  edge.render(1,1,mx, my, colors.black, colors.white, "", colors.black)
  sleep(0.1)
  edge.log("Initializing")
  sleep(0.1)
  term.setCursorPos(1,1)
  initialize()
end
function safeBoot(force)
  if shell.getRunningProgram() == "startup" then
    error("Invalid session: cannot be run as startup")
  end
  if not oldFS.exists("Axiom/libraries/edge") then
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
  for k,v in ipairs(allfiles) do
    if oldFS.exists(allfiles[k]) then
      print(allfiles[k].. " OK")
      sleep(0.1)
    else
      if allfiles[k] ~= 12 then
        print("Missing file: "..allfiles[k])
        fixNeeded = true
        sleep(0.1)
      end
    end
  end
  tasks.kernel = true
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)
  os.loadAPI("Axiom/libraries/edge")
  print("LOADED: Edge")

  print("LOADED: Next")

  os.loadAPI("Axiom/libraries/setting")

  --files = setting.variables.users[currentUser].fexplore_startdir
  print("LOADED: settings")
  os.loadAPI("Axiom/libraries/encryption")
  print("LOADED: encryption")

  --cprint("A X I O M",9)

  print("Determining latest version.")
  latestversion = http.get("http://www.nothy.se/Axiom/CurrentUpdate")
  announcement = http.get("http://www.nothy.se/Axiom/Announcement")
  announcement = tostring(announcement.readAll())
  if latestversion == nil then
    print("Error determining version.")
    latestversion = version
  else
    print(latestversion.readAll())
  end
  if announcement == nil then
    print("Error finding announcement.")
    announcement = "-"
  end
  sleep(3)
  if not edge then
    error("AXIOM-EdgeNotLoaded")
  end
  if not settings then
    error("AXIOM-SettingsNotLoaded")
  end
  if not next then
    error("AXIOM-NextNotLoaded")
  end
  if setting.getVariable("Axiom/settings.0","system_skipsys_scan") == "false" then
    if oldFS.exists("Axiom/log.txt") then
      if oldFS.getSize("Axiom/log.txt") >= 12000 then
        oldFS.delete("Axiom/log.txt")
      end
    end
    local fileList = oldFS.list("/")
    local loaded = 0
    local toLoad = #fileList
    for _, file in ipairs(fileList) do
      if file == "rom" then
        log("SYSTEM: CraftOS System file detected '"..file.."'. Ignoring")
        --edge.render(midx - string.len("Disallowed file detected, removing") / 2,8,48,8,colors.white,colors.cyan,"Disallowed file detected, removing",colors.black)
      else
        if oldFS.isDir(file) then
          print("SYSTEM: Verified folder "..file.."/ and it's contents")
        else
          print("SYSTEM: Verified file "..file)
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
  term.setBackgroundColor(colors.cyan)
  print("Initializing")
  sleep(1)
  term.setCursorPos(1,1)
  if force == "desktop" then
    print("WARNING: MAY NOT WORK.")
    print("For security reasons you have to log in.")
    write("username:")
    username = read()
    write("password:")
    password = read("*")
    if encryption.sha256(username.."QxLUF1bgIAdeQX") == setting.getVariable("Axiom/settings.0","username") then
      if encryption.sha256(password.."QxLUF1bgIAdeQX") == setting.getVariable("Axiom/settings.0","password") then
          local ok, err = pcall(desktop)
          if not ok then
            print("Fatal error: "..err)
          end
      else
        print("Invalid password.")
        os.reboot()
      end
      print("Invalid username.")
      os.reboot()
    end


  end
  initialize()
end
function log(string)
  local time = os.clock()
  if not oldFS.exists("Axiom/log.txt") then
    logfile = oldFS.open("Axiom/log.txt","w")
    logfile.close()
  end
  logfile = oldFS.open("Axiom/log.txt","a")
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
if not term.isColor() then
  term.setTextColor(colors.white)
  term.setBackgroundColor(colors.black)
  shell.run("clear")
  os.loadAPI("Axiom/libraries/setting")
  log("SYSTEM: Computer is not color, starting shell.")
  print("Computer is not color, starting shell instead.")
  terminal("/")
  sleep(2)
  if hasRednet then
    rednet.close(detectedSide)
  end
  os.shutdown()
end
log("SYSTEM: Starting services..")
tasks.kernel = true
tasks.permngr = true
shell.run("clear")
if oldFS.exists("safeStart") then
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
  print("[ ] Shell")
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
      print("[ ] Shell")
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
      print("[ ] Shell")
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
      print("[+] Shell")
      print("")
      print("[Run] ")
    end
    if x >= 1 and x <= 5 and y == 10 then
      if safe == false and craftos == false then
        if oldFS.exists("Axiom/settings.0") and oldFS.exists("Axiom/backup/os/settings.0") then
          oldFS.delete("Axiom/settings.0")
          oldFS.move("Axiom/backup/os/settings.0","Axiom/settings.0")
        end
        oldFS.delete("safeStart")
        bootanimation()
      else
        if craftos == true then
          currentUser = "KERNEL"
          terminal("/")
          print("Goodbye!")
          if hasRednet then
            rednet.close(detectedSide)
          end
          os.shutdown()
        else
          print("Attempting to boot safely.")
          sleep(1)
          oldFS.delete("safeStart")

          safeBoot()
        end
      end
    end
  end
end


--sleep(1)
--print("Total space:"..totalused + oldFS.getFreeSpace("/"))
--print("Space used:"..totalused)
--print("Free space:"..oldFS.getFreeSpace("/"))
--sleep(5)
print("started "..productName.."v"..version)
if not oldFS.exists("Axiom/settings.0") then
  term.setTextColor(colors.white)
  term.setBackgroundColor(colors.black)
  if oldFS.exists("Axiom/backup/os/settings.0") then
    oldFS.copy("Axiom/backup/os/settings.0","Axiom/settings.0")
    print("Restored settings from backup.")
  else
    print("Settings file is missing or corrupt. System will reboot when repair is finished.")
    noapidl("https://www.dropbox.com/s/ynyrs22t1hh2mry/settings?dl=1","Axiom/settings.0")
    print("Repair finished. Rebooting into first time setup.")
    sleep(5)
    os.reboot()
  end
end
if oldFS.exists("Axiom/settings") == true and oldFS.exists("Axiom/settings.0") == false then
  oldFS.copy("Axiom/settings","Axiom/settings.0")
  oldFS.delete("Axiom/settings")
  print("Settings file has been updated to support "..version)
  sleep(1)
end
if oldFS.exists("firstBoot") then
  oldFS.delete("firstBoot")

  term.setBackgroundColor(colors.black)
  shell.run("clear")
  local ok, err = pcall(safeBoot)
  if err then
    errorMessager(err)
  end
else
  local ok, err = pcall(bootanimation)
  if err then
    errorMessager(err)
  end
  if edge then
    edge.windowAlert(21,6,productName.." has crashed.", true)
    os.shutdown()
  end

end
