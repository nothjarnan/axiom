
  --Copyright 2016 Linus Ramneborg
  --All rights reserved.

os.pullEvent = os.pullEventRaw
if pocket then
  if fs.exists("Axiom/sys-pocket.axs") then
    fs.delete("startup")
    shell.run("Axiom/sys-pocket.axs")
  end
end
local mx, my = term.getSize()
fixNeeded = false
--se
--setting.set( "shell.allow_disk_startup", false)
local files = "home/"
local previousDir = files
local file = fs.list(files)
-- For making sure the files are A-OK
local allfiles = {
  "startup",
  "Axiom/sys.axs",
  "Axiom/images/default.axg",
  "Axiom/images/AX.nfp",
  "Axiom/images/axiom.axg",
  "Axiom/images/nature.axg",
  "Axiom/libraries/settings",
  "Axiom/libraries/edge",
  "Axiom/libraries/encryption",
  "Axiom/settings.0",
  "Axiom/libraries/next",
}
events = true
disableclock = true
updating = false
version = "v1.0"
version_sub = "server"
unreleased = false
latestversion = version
announcement = ""
state = ""
tasks = {kernel=false,settings_app=false,permngr=false,clock=false,filebrowser=false}
demo = "Server 2018"
frames_rendered = 1
menubarColor = colors.white
menuBarColor_Dark = colors.gray
nightmode = false
when = "never"
delay = 20
if unreleased == true then
  edition = "AXu"
else
  edition = "AXs"
end
local editing = false
local settings_tips = {"Made by Nothy"}
--local settings_tips = {"Unreleased"}
function errorMessager(errmsg)
  if setting.getVariable("Axiom/settings.0","system_skip_error") == "true" then
    if state == "loginscreen" then
      login_gui()
    else
      main_gui()
    end
  end
  fs.delete("Axiom/log.txt")
  if err == nil then
    edge.log("System crash! : Unknown error occured")
  else
    edge.log("System crash! : "..err)
  end

  edge.log("Version: "..version.." "..demo)
  edge.log("Shell version: "..os.version())
  if fs.exists("Axiom/stacktrace.log") then
    fs.delete("Axiom/stacktrace.log")
    fs.move("Axiom/log.txt","Axiom/stacktrace.log")
  end

  if fs.exists("Axiom/backup/os/settings.0") then
    fs.delete("Axiom/backup/os/settings.0")
  end
  if fs.exists("Axiom/settings.0") then
    fs.copy("Axiom/settings.0","Axiom/backup/os/settings.0")
  end
  setting.setVariable("Axiom/settings.0","system_skipsys_scan","false")
  setting.setVariable("Axiom/settings.0","system_allow_apis","false")
  setting.setVariable("Axiom/settings.0","general_background_name","default.axg")
  fs.makeDir("safeStart")
  edge.render(1,1,51,19,colors.cyan,colors.cyan,"",colors.black,false)
  if setting.getVariable("Axiom/settings.0","licensed") == "false" or setting.getVariable("Axiom/settings.0","general_background_name") == "black" then
    edge.render(1,1,51,19,colors.black,colors.cyan,"",colors.black,false)
  else
    edge.image(1,1,setting.getVariable("Axiom/settings.0","general_background_name"),colors.cyan)
  end
  edge.render(1,1,mx,1,colors.white,colors.cyan,"O",colors.black,false)
  if setting.getVariable("Axiom/settings.0","dev") == "true" then
    edge.xprint("Axiom",2,17,colors.white)

  end
  if errmsg then
    if string.find(errmsg,"System repair") then
      edge.render(1,3,mx,7,colors.white,colors.cyan,"System Self Repair: Message",colors.black,false)
      edge.render(1,5,mx,5,colors.white,colors.cyan,"System is currently repairing.",colors.black,false)
      edge.render(1,7,mx,7,colors.gray,colors.cyan,"(Click here for more information.)",colors.white,false)
    else
      edge.render(1,3,mx,7,colors.white,colors.cyan,"Application crashed unexpectedly!",colors.black,false)
      edge.render(1,5,mx,5,colors.white,colors.cyan,"Fear not, everything's totally fine.",colors.black,false)
      edge.render(1,7,mx,7,colors.gray,colors.cyan,"(Click here for more information.)",colors.white,false)
    end

    while(true) do
      local event, button, x, y = os.pullEvent("mouse_click")
      if event == "terminate" then
        main_gui()
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
          login_gui()
        else
          main_gui()
        end
      else
        if state == "loginscreen" then
          login_gui()
        else
          main_gui()
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
    login_gui()
  else
    main_gui()
  end
end

function errorHandler(err)
  fs.delete("Axiom/log.txt")
  edge.log("System crash! : "..tostring(err))
  edge.log("Version: "..version.." "..demo)
  edge.log("Shell version: "..os.version())
  if fs.exists("Axiom/stacktrace.log") then
    fs.delete("Axiom/stacktrace.log")
  end
  fs.move("Axiom/log.txt","Axiom/stacktrace.log")
  if fs.exists("Axiom/backup/os/settings.0") then
    fs.delete("Axiom/backup/os/settings.0")
  end
  if fs.exists("Axiom/settings.0") then
    fs.copy("Axiom/settings.0","Axiom/backup/os/settings.0")
  end
  setting.setVariable("Axiom/settings.0","system_skipsys_scan","false")
  setting.setVariable("Axiom/settings.0","system_allow_apis","false")
  setting.setVariable("Axiom/settings.0","general_background_name","default.axg")
  fs.makeDir("safeStart")
  if setting.getVariable("Axiom/settings.0","system_skip_error") == "true" then
    initialize()
  end
  count = 10
  wait = 5
  wait_count = 0.1
  local time = textutils.formatTime( os.time(), false )
  x, y = term.getSize()
  midx = x / 2
  shell.run("clear")
  if setting.getVariable("Axiom/settings.0","system_boot_error_animation") == "true" then
    cprint("A X I O M",9)
    cprint(".        ",10)
    sleep(0.1)
    cprint(" .       ",10)
    sleep(0.1)
    cprint("  .      ",10)
    sleep(0.1)
    cprint("   .     ",10)
    sleep(0.1)
    cprint("    .    ",10)
    sleep(0.1)
    cprint("     .   ",10)
    sleep(0.1)
    cprint("      .  ",10)
    sleep(0.1)
    cprint("       . ",10)
    sleep(0.1)
    cprint("        .",10)
    sleep(0.1)
    cprint(".       .",10)
    sleep(0.2)
    cprint("  .   .  ",10)
    sleep(0.2)
    cprint("    .    ",10)
    sleep(0.3)
    cprint("    R    ",10) -- CRASH
    sleep(0.2)
    cprint("  R R O  ",10)
    sleep(0.2)
    cprint("E R R O R",10)
    sleep(0.2)
    cprint("A X I O M",9)
    cprint("E R R O R",10)
    sleep(2)
  end
  term.setBackgroundColor(colors.gray)
  term.setTextColor(colors.lightGray)
  shell.run("clear")
  print("Axiom ran into an unexpected error and was forced to shut down to prevent damage.")
  print("Kernel Version: "..version)
  print("Error thrown: "..err)
  print("A detailed error log can be found in Axiom/stacktrace.log")
  tasks.kernel = true
  tasks.permngr = false
  tasks.clock = false
  sleep(wait)
  while(true) do
    edge.render(1,7,1,7,colors.gray,colors.cyan,"Restarting in "..count.." seconds    ",colors.green)
    count = count - 0.1

    sleep(wait_count)
    if count <= 0 then
      os.reboot()
    end
  end
end
function checkForUpdates()
  updated = false
  if not when then
    when = "always"
  end
  if not delay then
    delay = 120.5
  end
    edge.log("Checking for updates! (Mode: "..when..")")
    setting.setVariable("Axiom/settings.0","system_last_updatecheck",os.day().." @ "..edge.c())
    if updated == true and setting.getVariable("Axiom/settings.0","dev") == "true" then
      edge.render(mx-9,1,mx-9,1,colors.red,colors.cyan,"X",colors.white)
    end

    sleep(delay)
    setting.setVariable("Axiom/settings.0","system_last_update",os.day().." @ "..edge.c())
    if updated == false then
      if setting.getVariable("Axiom/settings.0","dev") == "true" then
        edge.render(mx-9,1,mx-9,1,menubarColor,colors.cyan,"U",colors.green)
      end
      if when == "onReboot" then
        local event = os.pullEvent()
        edge.log("Caught event: "..event)
        if event == "reboot" then
          if setting.getVariable("Axiom/settings.0","dev") == "true" then
            edge.render(mx-9,1,mx-9,1,menubarColor,colors.cyan,"VC",colors.green)
          end
          versionCheck = http.get("http://www.nothy.se/Axiom/CurrentUpdate")
          edge.log("latest: "..versionCheck.readAll())
          if not versionCheck then
            edge.log("Error: Could not connect to server: http://www.nothy.se/ ! (FATAL)")
            if setting.getVariable("Axiom/settings.0","dev") == "true" then
              edge.render(mx-9,1,mx-9,1,menubarColor,colors.cyan,"VCx",colors.red)
            end
           else
             if versionCheck.readAll() ~= version then
               edge.log("Update available")
               updated = true
               if setting.getVariable("Axiom/settings.0","dev") == "true" then
                 edge.render(mx-9,1,mx-9,1,menubarColor,colors.cyan,"DL",colors.green)
               end
               if setting.getVariable("Axiom/settings.0","first_update") == "false" then
                 setting.setVariable("Axiom/settings.0","first_update","true")
               end
               if fs.exists("Axiom/backup/os/settings.0") then
                 fs.delete("Axiom/backup/os/settings.0")
                 fs.copy("Axiom/settings.0","Axiom/backup/os/settings.0")
               else
                 fs.copy("Axiom/settings.0","Axiom/backup/os/settings.0")
               end
               if not fs.exists("home/prg/luaide.app") then
                 shell.run("pastebin get vyAZc6tJ home/prg/luaide.app")
               end
               download("https://www.dropbox.com/s/a7fp2jo6tgm7xsy/startup?dl=1","startup")
               sleep(0.1)
               download("https://www.dropbox.com/s/67dycd81yukawnc/sys-server.axs?dl=1","Axiom/sys.axs")
               sleep(0.1)
               download("https://www.dropbox.com/s/hbmt6bf1tjl8z4z/settings?dl=1","Axiom/libraries/settings")
               sleep(0.1)
               download("https://www.dropbox.com/s/a5kxzjl6122uti2/edge?dl=1","Axiom/libraries/edge")
               sleep(0.1)
               download("https://www.dropbox.com/s/p3kgkzhe27vr9lj/encryption?dl=1","Axiom/libraries/encryption")
               if not fs.exists("Axiom/settings.0") then
                 download("https://www.dropbox.com/s/ynyrs22t1hh2mry/settings?dl=1","Axiom/settings.0")
                 sleep(0.1)
               end

               download("https://www.dropbox.com/s/t40vz4gvmyrcjv4/background.axg?dl=1","Axiom/images/default.axg")
               download("https://www.dropbox.com/s/cjahddofwhja8og/axiom.axg?dl=1","Axiom/images/axiom.axg")
               download("https://www.dropbox.com/s/osz72e1rnvt5opl/nature.axg?dl=1","Axiom/images/nature.axg")
               download("https://www.dropbox.com/s/wi4n0j98d82256f/AX.nfp?dl=1","Axiom/images/AX.nfp")
               sleep(0.1)
             end
           end

      end
      if when == "always" then
        if setting.getVariable("Axiom/settings.0","dev") == "true" then
          edge.render(mx-9,1,mx-9,1,menubarColor,colors.cyan,"VC",colors.green)
        end
        versionCheck = http.get("http://www.nothy.se/Axiom/CurrentUpdate")
        edge.log("latest: "..versionCheck.readAll())
        if not versionCheck then
          edge.log("Error: Could not connect to server: http://www.nothy.se/ ! (FATAL)")
          if setting.getVariable("Axiom/settings.0","dev") == "true" then
            edge.render(mx-9,1,mx-9,1,menubarColor,colors.cyan,"VCx",colors.green)
          end
        else
          if versionCheck.readAll() ~= version then
            notifContent = [[
            render(3,6,28,9,colors.white,colors.cyan,"",colors.black,false)
            render(4,6,28,6,colors.white,colors.cyan,"An update is about to install!",colors.black,false)
            sleep(3.6)
            ]]
            --edge.notify(notifContent)
            updated = true
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
            if setting.getVariable("Axiom/settings.0","dev") == "true" then
              edge.render(mx-9,1,mx-9,1,menubarColor,colors.cyan,"DL",colors.green)
            end
            if not fs.exists("home/prg/luaide.app") then
              shell.run("pastebin get vyAZc6tJ home/prg/luaide.app")
            end
            download("https://www.dropbox.com/s/a7fp2jo6tgm7xsy/startup?dl=1","startup")
            sleep(0.1)
            if unreleased == false then
              download("https://www.dropbox.com/s/67dycd81yukawnc/sys-server.axs?dl=1","Axiom/sys.axs")
            else
              download("https://www.dropbox.com/s/5v2amjjmw08n9yz/sys-latest.axs?dl=1","Axiom/sys.axs")
            end
            sleep(0.1)
            download("https://www.dropbox.com/s/hbmt6bf1tjl8z4z/settings?dl=1","Axiom/libraries/settings")
            sleep(0.1)
            download("https://www.dropbox.com/s/a5kxzjl6122uti2/edge?dl=1","Axiom/libraries/edge")
            sleep(0.1)
            download("https://www.dropbox.com/s/p3kgkzhe27vr9lj/encryption?dl=1","Axiom/libraries/encryption")
            if not fs.exists("Axiom/settings.0") then
              download("https://www.dropbox.com/s/ynyrs22t1hh2mry/settings?dl=1","Axiom/settings.0")
              sleep(0.1)
            end

            download("https://www.dropbox.com/s/t40vz4gvmyrcjv4/background.axg?dl=1","Axiom/images/default.axg")
            download("https://www.dropbox.com/s/cjahddofwhja8og/axiom.axg?dl=1","Axiom/images/axiom.axg")
            download("https://www.dropbox.com/s/osz72e1rnvt5opl/nature.axg?dl=1","Axiom/images/nature.axg")
            download("https://www.dropbox.com/s/wi4n0j98d82256f/AX.nfp?dl=1","Axiom/images/AX.nfp")
            sleep(0.1)
          end
        end
      end
    end
  end
end
function clock()

  count = 0
  while(tasks.clock == true or disableclock == false) do
    sleep(0)
    frames_rendered = frames_rendered + 1
    local time = textutils.formatTime( os.time(), false )
    if state == "main_gui" then
      if not tasks.settings_app == true then
        if string.find(time, "AM") then
          nightmode = true
        else
          nightmode = false
        end
        if string.find(time,"10:") or string.find(time,"11:") or string.find(time,"12:") then
          edge.render(mx-7,1,mx-7,1,menubarColor,colors.cyan,time,colors.black,false)
        else
          edge.render(mx-7,1,mx-7,1,menubarColor,colors.cyan,"",colors.black,false)
          edge.render(mx-6,1,mx-6,1,menubarColor,colors.cyan,time,colors.black,false)
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
      if not fs.exists(shell.getRunningProgram()) then
        term.setCursorPos(1,1)
        fs.delete("Axiom/log.txt")
        edge.log("!!! KERNEL PANIC !!!")
        edge.log("Version: "..version.." "..demo)
        edge.log("Shell version: "..os.version())
        edge.log("!!! END OF STACKTRACE !!!")
        if fs.exists("Axiom/stacktrace.log") then
          fs.delete("Axiom/stacktrace.log")
        end
        fs.move("Axiom/log.txt","Axiom/stacktrace.log")
        sleep(3)
        print("[ UNRECOVERABLE ERROR ]")
        print("!!! KERNEL PANIC !!!")
        print("Kernel Version: "..version)
        for k,v in ipairs(allfiles) do
          if fs.exists(allfiles[k]) then

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
        os.shutdown()
      end
    end
  end
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
function download(url, file)
  --edge.xprint("Downloading "..file.."..",2,18,colors.white)
  --edge.render(1,18,1,18,colors.cyan,colors.cyan,"Downloading "..file.."..",colors.white)
  edge.log("Downloading from "..url..", saving to "..file)
  if fs.getFreeSpace("/") <= 1024 then
    --edge.render(1,18,1,18,colors.cyan,colors.cyan,"Warning: Low space on disk!",colors.orange)
    edge.xprint("Warning: Low space on disk! "..fs.getFreeSpace("/") / 1024 .."kb",1,18,colors.orange)
  end
  if not http then
    edge.render(16,7,34,12,colors.white,colors.cyan,"",colors.black,true)
    --edge.render(17,8,34,8,colors.white,colors.cyan,"Welcome to Axiom!",colors.black,false)
    edge.render(17,9,34,9,colors.white,colors.cyan," (!) Fatal error",colors.red,false)
    edge.render(16,10,34,10,colors.white,colors.cyan,"CODE: HTTP_DISABLED",colors.orange,false)
  else
    if setting.getVariable("Axiom/settings.0","http_disable_dl") == "deprecated" then
      fdl = http.get(url)
    else
        edge.xprint("Warning: Downloads are disabled.",1,18,colors.orange)
        --edge.render(1,18,1,18,colors.cyan,colors.cyan,"Warning: Downloads are disabled.",colors.orange)
    end
    if not fdl then
      sleep(1)
    end
    if fs.exists("Axiom/backup/"..file) then
      fs.delete("Axiom/backup/"..file)
      if not fs.exists(file) then
        edge.log(file.. " - does not exist")
      else
        fs.copy(file,"Axiom/backup/"..file)
      end
    else
      if fs.exists(file) then
        fs.copy(file,"Axiom/backup/"..file)
      end
    end
    if fs.getFreeSpace("/") <= 10 then
      error("No space left")
    end
    --if not args[1] == "silent" and args[1] == nil then
    --print("Opening file "..file)
    if setting.getVariable("Axiom/settings.0","http_disable_dl") == "deprecated" then
      f = fs.open(file,"w")
      f.write(fdl.readAll())
      f.close()
      --edge.xprint(" Done",1+string.len("Downloading "..file..".."),18,colors.white)
      --edge.render(2+string.len("Downloading "..file..".."),18,2+string.len("Downloading "..file.."..")+3,18,colors.cyan,colors.cyan,"Done ",colors.white)
      sleep(1)
      --edge.xprint("                                                  ",1,18,colors.white)
    end
    edge.log("Done updating. "..file)
  end
end
function execUpd()
  setting.setVariable("Axiom/settings.0","system_last_update","Day "..os.day().." @ "..edge.c())
  if setting.getVariable("Axiom/settings.0","first_update") == "false" then
    setting.setVariable("Axiom/settings.0","first_update","true")
  end
  if fs.exists("Axiom/backup/os/settings.0") then
    fs.delete("Axiom/backup/os/settings.0")
    fs.copy("Axiom/settings.0","Axiom/backup/os/settings.0")
  else
    fs.copy("Axiom/settings.0","Axiom/backup/os/settinGgs.0")
  end
  if not fs.exists("home/prg/luaide.app") then
    shell.run("pastebin get vyAZc6tJ home/prg/luaide.app")
  end
  download("https://www.dropbox.com/s/a7fp2jo6tgm7xsy/startup?dl=1","startup")
  sleep(0.1)
  if unreleased == false then
    download("https://www.dropbox.com/s/67dycd81yukawnc/sys-server.axs?dl=1","Axiom/sys.axs")
  else
    download("https://www.dropbox.com/s/67dycd81yukawnc/sys-server.axs?dl=1","Axiom/sys.axs")
  end
  sleep(0.1)
  download("https://www.dropbox.com/s/hbmt6bf1tjl8z4z/settings?dl=1","Axiom/libraries/settings")
  sleep(0.1)
  download("https://www.dropbox.com/s/a5kxzjl6122uti2/edge?dl=1","Axiom/libraries/edge")
  sleep(0.1)
  download("https://www.dropbox.com/s/p3kgkzhe27vr9lj/encryption?dl=1","Axiom/libraries/encryption")
  if not fs.exists("Axiom/settings.0") then
    download("https://www.dropbox.com/s/ynyrs22t1hh2mry/settings?dl=1","Axiom/settings.0")
    sleep(0.1)
  end

  download("https://www.dropbox.com/s/t40vz4gvmyrcjv4/background.axg?dl=1","Axiom/images/default.axg")
  download("https://www.dropbox.com/s/cjahddofwhja8og/axiom.axg?dl=1","Axiom/images/axiom.axg")
  download("https://www.dropbox.com/s/osz72e1rnvt5opl/nature.axg?dl=1","Axiom/images/nature.axg")
  download("https://www.dropbox.com/s/wi4n0j98d82256f/AX.nfp?dl=1","Axiom/images/AX.nfp")
  sleep(0.1)
end
function login_gui()
  local ok, val = pcall(parallel.waitForAll(main_gui,clock,checkForUpdates))
  if not ok then
    print(val)
  end
end
function settings_gui_general()
  tasks.settings_app_http = false
  tasks.settings_app_account = false
  tasks.settings_app_boot = false
  tasks.settings_app_system = false
  tasks.settings_app_general = true
  if tasks.settings_app == true then
    edge.render(17,3,45,16,colors.white,colors.cyan,"  General settings          x",colors.black,false)
    --edge.render(19,6,35,6,colors.lightGray,colors.cyan,"'"..setting.getVariable("Axiom/settings.0","general_background_name").."'",colors.black,false)
    edge.render(19,6,40,6,colors.lightGray,colors.cyan,"'"..setting.getVariable("Axiom/settings.0","general_background_name").."'",colors.black,false)
    while true do
      edge.render(18,5,35,5,colors.white,colors.cyan,"Background image",colors.black)
      local event, button, x, y = os.pullEvent("mouse_click")
      if event == "terminate" then
        parallel.waitForAll(main_gui,clock)
      end
      if x >= 18 and x <= 35 and y == 6 then
        edge.render(19,6,40,6,colors.lightGray,colors.cyan,"",colors.black,false)
        term.setCursorPos(20,6)
        term.setBackgroundColor(colors.lightGray)
        term.setTextColor(colors.black)
        bgimg = io.read()
        if fs.exists(edge.imageDir..bgimg) then
          setting.setVariable("Axiom/settings.0","general_background_name",bgimg)
          edge.render(19,6,40,6,colors.lightGray,colors.cyan,"'"..setting.getVariable("Axiom/settings.0","general_background_name").."'",colors.black,false)
        else
          edge.render(19,6,40,6,colors.lightGray,colors.cyan,"'"..setting.getVariable("Axiom/settings.0","general_background_name").."'",colors.red,false)
        end
      end
      if x == 45 and y == 3 then
        tasks.settings_app = false
        parallel.waitForAll(main_gui,clock)
      end
      if x == 45 and y == 3 then
        tasks.settings_app = false
        tasks.settings_app_http = false
        tasks.settings_app_account = false
        tasks.settings_app_boot = false
        tasks.settings_app_system = false
        tasks.settings_app_general = false
        main_gui()
      end
      if x >= 6 and x <= 14 and y == 10 then
        tasks.settings_app_http = true
        tasks.settings_app_account = false
        tasks.settings_app_boot = false
        tasks.settings_app_system = false
        tasks.settings_app_general = false
        parallel.waitForAny(settings_gui_http)
        tasks.settings_app_http = false
        tasks.settings_app_account = false
        tasks.settings_app_boot = false
        tasks.settings_app_system = false
      end
      if x >= 6 and x <= 14 and y == 4 then
        tasks.settings_app_http = false
        tasks.settings_app_account = true
        tasks.settings_app_boot = false
        tasks.settings_app_system = false
        tasks.settings_app_general = false
        parallel.waitForAny(settings_gui_account)
        tasks.settings_app_http = false
        tasks.settings_app_account = false
        tasks.settings_app_boot = false
        tasks.settings_app_system = false
      end
      if x >= 6 and x <= 14 and y == 6 then
        tasks.settings_app_http = false
        tasks.settings_app_account = false
        tasks.settings_app_boot = true
        tasks.settings_app_system = false
        tasks.settings_app_general = false
        parallel.waitForAny(settings_gui_boot)
        tasks.settings_app_http = false
        tasks.settings_app_account = false
        tasks.settings_app_boot = false
        tasks.settings_app_system = false
      end
      if x >= 6 and x <= 14 and y == 16 then
        tasks.settings_app_http = false
        tasks.settings_app_account = false
        tasks.settings_app_boot = false
        tasks.settings_app_system = true
        tasks.settings_app_general = false
        parallel.waitForAny(settings_gui_system)
        tasks.settings_app_http = false
        tasks.settings_app_account = false
        tasks.settings_app_boot = false
        tasks.settings_app_system = false
        tasks.settings_app_general = false
      end
      if x >= 6 and x <= 14 and y == 14 then
        tasks.settings_app_http = false
        tasks.settings_app_account = false
        tasks.settings_app_boot = true
        tasks.settings_app_system = false
        parallel.waitForAny(settings_gui_updates)
        tasks.settings_app_http = false
        tasks.settings_app_account = false
        tasks.settings_app_boot = false
        tasks.settings_app_system = false
      end
    end
  end
end
function settings_gui_system()
  tasks.settings_app_http = false
  tasks.settings_app_account = false
  tasks.settings_app_boot = false
  tasks.settings_app_system = true
  tasks.settings_app_general = false
  local c = math.random(1,#settings_tips)
  if tasks.settings_app == true then
    --edge.render(5,1,5+string.len("settings"),1,colors.lightGray,colors.cyan,"Settings",colors.black,false)
    --edge.render(5,3,45,17,colors.white,colors.cyan,"                                        x",colors.black,true)
    --edge.render(26,9,28,9,colors.white,colors.cyan,"A X I O M",colors.black)
    --edge.render(17,17,45,17,colors.white,colors.cyan,version.." | "..settings_tips[c],colors.lightGray,false)
    --edge.render(5,3,15,17,colors.lightGray,colors.cyan,"",colors.black,false)
    --edge.render(6,4,14,4,colors.lightGray,colors.cyan,"Account",colors.black,false)
    --edge.render(6,6,14,6,colors.lightGray,colors.cyan,"Boot",colors.black,false)
    --edge.render(6,8,14,8,colors.lightGray,colors.cyan,"General",colors.black,false)
    --edge.render(6,10,14,10,colors.lightGray,colors.cyan,"HTTP",colors.black,false)
    --edge.render(6,12,14,12,colors.lightGray,colors.cyan,"Tasks",colors.black,false)
    --edge.render(6,14,14,14,colors.lightGray,colors.cyan,"Updates",colors.black,false)
    --edge.render(6,16,14,16,colors.lightGray,colors.cyan,"System",colors.black,false)
    -- separator
    edge.render(17,3,45,16,colors.white,colors.cyan,"   System settings          x",colors.black,false)
    if setting.getVariable("Axiom/settings.0","system_skipsys_scan") == "true" then
      edge.render(18,5,45,5,colors.white,colors.cyan,"[+] Skip system scan",colors.black,false)
    else
      edge.render(18,5,45,5,colors.white,colors.cyan,"[ ] Skip system scan",colors.black,false)
    end
    if setting.getVariable("Axiom/settings.0","system_skip_error") == "true" then
      edge.render(18,7,45,7,colors.white,colors.cyan,"[+] Skip error screens",colors.black,false)
    else
      edge.render(18,7,45,7,colors.white,colors.cyan,"[ ] Skip error screens",colors.black,false)
    end
    if setting.getVariable("Axiom/settings.0","system_allow_apis") == "true" then
      edge.render(18,9,45,9,colors.white,colors.cyan,"[+] Allow custom APIs",colors.black,false)
      edge.render(18,10,45,10,colors.white,colors.cyan,"Located in: "..setting.getVariable("Axiom/settings.0","api_dir"),colors.lightGray)
      edge.render(18,11,45,11,colors.white,colors.cyan,"Get APIs from Pastebin",colors.black)
      if not fs.exists(setting.getVariable("Axiom/settings.0","api_dir")) then
        fs.makeDir(setting.getVariable("Axiom/settings.0","api_dir"))
      end
    else
      edge.render(18,9,45,9,colors.white,colors.cyan,"[ ] Allow custom APIs",colors.black,false)
      edge.render(18,10,45,10,colors.white,colors.cyan,"",colors.lightGray)
      edge.render(18,11,45,11,colors.white,colors.cyan,"",colors.white)
    end
    edge.render(18,14,45,14,colors.white,colors.cyan,"Uninstall Axiom",colors.red,false)
    --edge.render(19,6,40,6,colors.lightGray,colors.cyan,setting.getVariable("Axiom/settings.0","api_dir"),colors.gray,false)
    --edge.render(18,7,45,7,colors.white,colors.cyan,"Boot arguments:",colors.black,false)
    --edge.render(19,8,40,8,colors.lightGray,colors.cyan,setting.getVariable("Axiom/settings.0","boot_args"),colors.gray,false)
    while(tasks.settings_app_system == true) do

      if setting.getVariable("Axiom/settings.0","system_skipsys_scan") == "true" then
        edge.render(18,5,45,5,colors.white,colors.cyan,"[+] Skip system scan",colors.black,false)
      else
        edge.render(18,5,45,5,colors.white,colors.cyan,"[ ] Skip system scan",colors.black,false)
      end
      if setting.getVariable("Axiom/settings.0","system_skip_error") == "true" then
        edge.render(18,7,45,7,colors.white,colors.cyan,"[+] Skip error screens",colors.black,false)
      else
        edge.render(18,7,45,7,colors.white,colors.cyan,"[ ] Skip error screens",colors.black,false)
      end
      if setting.getVariable("Axiom/settings.0","system_allow_apis") == "true" then
        edge.render(18,9,45,9,colors.white,colors.cyan,"[+] Allow custom APIs",colors.black,false)
        edge.render(18,10,45,10,colors.white,colors.cyan,"Located in: "..setting.getVariable("Axiom/settings.0","api_dir"),colors.lightGray)
        edge.render(18,11,45,11,colors.white,colors.cyan,"Get APIs",colors.black)
      else
        edge.render(18,9,45,9,colors.white,colors.cyan,"[ ] Allow custom APIs",colors.black,false)
        edge.render(18,10,45,10,colors.white,colors.cyan,"",colors.lightGray)
        edge.render(18,11,45,11,colors.white,colors.cyan,"",colors.black)
      end
      local event, button, x, y = os.pullEvent("mouse_click")
      if event == "terminate" then
        parallel.waitForAll(main_gui,clock)
      end
      if x >= 18 and x <= 31 and y == 5 then
        if setting.getVariable("Axiom/settings.0","system_skipsys_scan") == "true" then
          setting.setVariable("Axiom/settings.0","system_skipsys_scan","false")
        else
          setting.setVariable("Axiom/settings.0","system_skipsys_scan","true")
        end
      end
      if x >= 18 and x <= 31 and y == 7 then
        if setting.getVariable("Axiom/settings.0","system_skip_error") == "true" then
          setting.setVariable("Axiom/settings.0","system_skip_error","false")
        else
          setting.setVariable("Axiom/settings.0","system_skip_error","true")
        end
      end
      if x >= 18 and x <= 31 and y == 11 and setting.getVariable("Axiom/settings.0","system_allow_apis") == "true" then
        edge.render(18,11,40,11,colors.gray,colors.cyan,"Pastebin Code",colors.lightGray)
        term.setCursorPos(18,11)
        term.setBackgroundColor(colors.gray)
        term.setTextColor(colors.white)
        local pbc = io.read()
        if pbc == nil or pbc == "" then
          tasks.settings_app_http = false
          tasks.settings_app_account = false
          tasks.settings_app_boot = false
          tasks.settings_app_system = true
          tasks.settings_app_general = false
          parallel.waitForAny(settings_gui_system)
          tasks.settings_app_http = false
          tasks.settings_app_account = false
          tasks.settings_app_boot = false
          tasks.settings_app_system = false
          tasks.settings_app_general = false
        end
        edge.render(18,11,40,11,colors.gray,colors.cyan,"API name",colors.lightGray)
        term.setCursorPos(18,11)
        term.setBackgroundColor(colors.gray)
        term.setTextColor(colors.white)
        local apin = io.read()
        edge.render(18,11,40,11,colors.gray,colors.cyan,"Installing..",colors.lightGray)
        local pbdl = http.get("http://www.pastebin.com/raw/"..pbc)
        local f = fs.open(setting.getVariable("Axiom/settings.0","api_dir").."/"..apin,"w")
        f.write(pbdl.readAll())
        f.close()
        edge.render(18,11,40,11,colors.gray,colors.cyan,"Installed",colors.green)
      end
      if x >= 18 and x <= 31 and y == 9 then
        if setting.getVariable("Axiom/settings.0","system_allow_apis") == "true" then
          setting.setVariable("Axiom/settings.0","system_allow_apis","false")
        else
          setting.setVariable("Axiom/settings.0","system_allow_apis","true")
        end
      end
      if x >= 18 and x <= 33 and y == 14 then
        fh = fs.open("Axiom/sys.axs","w")
        fh.close()
        fs.delete("Axiom")
        fs.delete("users")
        fs.delete("startup")
        fs.move("home","old_user_files")
        os.reboot()
      end
      if x == 45 and y == 3 then
        tasks.settings_app = false
        main_gui()
      end
      if x == 45 and y == 3 then
        tasks.settings_app = false
        tasks.settings_app_http = false
        tasks.settings_app_account = false
        tasks.settings_app_boot = false
        tasks.settings_app_system = false
        tasks.settings_app_general = false
        main_gui()
      end
      if x >= 6 and x <= 14 and y == 8 then
        tasks.settings_app_http = true
        tasks.settings_app_account = false
        tasks.settings_app_boot = false
        tasks.settings_app_system = false
        tasks.settings_app_general = false
        parallel.waitForAny(settings_gui_general)
      end
      if x >= 6 and x <= 14 and y == 10 then
        tasks.settings_app_http = true
        tasks.settings_app_account = false
        tasks.settings_app_boot = false
        tasks.settings_app_system = false
        tasks.settings_app_general = false
        parallel.waitForAny(settings_gui_http)
        tasks.settings_app_http = false
        tasks.settings_app_account = false
        tasks.settings_app_boot = false
        tasks.settings_app_system = false
      end
      if x >= 6 and x <= 14 and y == 4 then
        tasks.settings_app_http = false
        tasks.settings_app_account = true
        tasks.settings_app_boot = false
        tasks.settings_app_system = false
        tasks.settings_app_general = false
        parallel.waitForAny(settings_gui_account)
        tasks.settings_app_http = false
        tasks.settings_app_account = false
        tasks.settings_app_boot = false
        tasks.settings_app_system = false
      end
      if x >= 6 and x <= 14 and y == 14 then
        tasks.settings_app_http = false
        tasks.settings_app_account = false
        tasks.settings_app_boot = true
        tasks.settings_app_system = false
        parallel.waitForAny(settings_gui_updates)
        tasks.settings_app_http = false
        tasks.settings_app_account = false
        tasks.settings_app_boot = false
        tasks.settings_app_system = false
      end
      if x >= 6 and x <= 14 and y == 6 then
        tasks.settings_app_http = false
        tasks.settings_app_account = false
        tasks.settings_app_boot = true
        tasks.settings_app_system = false
        tasks.settings_app_general = false
        parallel.waitForAny(settings_gui_boot)
        tasks.settings_app_http = false
        tasks.settings_app_account = false
        tasks.settings_app_boot = false
        tasks.settings_app_system = false
      end
      if x >= 6 and x <= 14 and y == 16 then
        tasks.settings_app_http = false
        tasks.settings_app_account = false
        tasks.settings_app_boot = false
        tasks.settings_app_system = true
        tasks.settings_app_general = false
        parallel.waitForAny(settings_gui_system)
        tasks.settings_app_http = false
        tasks.settings_app_account = false
        tasks.settings_app_boot = false
        tasks.settings_app_system = false
        tasks.settings_app_general = false
      end
    end
  else
    return false
  end

end
function settings_gui_http()
  tasks.settings_app_http = true
  tasks.settings_app_account = false
  tasks.settings_app_boot = false
  tasks.settings_app_system = false
    local c = math.random(1,#settings_tips)
    if tasks.settings_app == true then
      --edge.render(5,1,5+string.len("settings"),1,colors.lightGray,colors.cyan,"Settings",colors.black,false)
      --edge.render(5,3,45,17,colors.white,colors.cyan,"                                        x",colors.black,true)
      --edge.render(26,9,28,9,colors.white,colors.cyan,"A X I O M",colors.black)
      --edge.render(17,17,45,17,colors.white,colors.cyan,version.." | "..settings_tips[c],colors.lightGray,false)
      --edge.render(5,3,15,17,colors.lightGray,colors.cyan,"",colors.black,false)
      --edge.render(6,4,14,4,colors.lightGray,colors.cyan,"Account",colors.black,false)
      --edge.render(6,6,14,6,colors.lightGray,colors.cyan,"Boot",colors.black,false)
      --edge.render(6,8,14,8,colors.lightGray,colors.cyan,"General",colors.black,false)
      --edge.render(6,10,14,10,colors.lightGray,colors.cyan,"HTTP",colors.black,false)
      --edge.render(6,12,14,12,colors.lightGray,colors.cyan,"Tasks",colors.black,false)
      --edge.render(6,14,14,14,colors.lightGray,colors.cyan,"Updates",colors.black,false)
      --edge.render(6,16,14,16,colors.lightGray,colors.cyan,"System",colors.black,false)
      -- separator
      edge.render(17,3,45,16,colors.white,colors.cyan,"   HTTP settings            x",colors.black,false)
      if setting.getVariable("Axiom/settings.0","http_safe_conn") == "true" then
        edge.render(18,5,45,5,colors.white,colors.cyan,"[+] Safe HTTP",colors.black,false)
      else
        edge.render(18,5,45,5,colors.white,colors.cyan,"[ ] Safe HTTP",colors.black,false)
      end
      edge.render(18,7,45,7,colors.white,colors.cyan,"[ ] ax_force_conn",colors.black,false)
      --edge.render(18,9,45,9,colors.white,colors.cyan,"[ ] Allow downloads",colors.black,false)
      if setting.getVariable("Axiom/settings.0","http_disable_dl") == "false" then
        edge.render(18,9,45,9,colors.white,colors.cyan,"[+] Allow downloads",colors.black,false)
      else
        edge.render(18,9,45,9,colors.white,colors.cyan,"[ ] Allow downloads",colors.black,false)
      end
      --edge.render(19,6,40,6,colors.lightGray,colors.cyan,setting.getVariable("Axiom/settings.0","api_dir"),colors.gray,false)
      --edge.render(18,7,45,7,colors.white,colors.cyan,"Boot arguments:",colors.black,false)
      --edge.render(19,8,40,8,colors.lightGray,colors.cyan,setting.getVariable("Axiom/settings.0","boot_args"),colors.gray,false)
      while(tasks.settings_app_http == true) do

        if setting.getVariable("Axiom/settings.0","http_safe_conn") == "true" then
          edge.render(18,5,45,5,colors.white,colors.cyan,"[+] Safe HTTP",colors.black,false)
        else
          edge.render(18,5,45,5,colors.white,colors.cyan,"[ ] Safe HTTP",colors.black,false)
        end
        if setting.getVariable("Axiom/settings.0","http_disable_dl") == "false" then
          edge.render(18,9,45,9,colors.white,colors.cyan,"[+] Allow downloads",colors.black,false)
        else
          edge.render(18,9,45,9,colors.white,colors.cyan,"[ ] Allow downloads",colors.black,false)
        end
        local event, button, x, y = os.pullEvent("mouse_click")
        if event == "terminate" then
          parallel.waitForAll(main_gui,clock)
        end
        if x >= 18 and x <= 31 and y == 5 then
          if setting.getVariable("Axiom/settings.0","http_safe_conn") == "true" then
            setting.setVariable("Axiom/settings.0","http_safe_conn","false")
          else
            setting.setVariable("Axiom/settings.0","http_safe_conn","true")
          end
        end
        if x >= 18 and x <= 31 and y == 9 then
          if setting.getVariable("Axiom/settings.0","http_disable_dl") == "false" then
            setting.setVariable("Axiom/settings.0","http_disable_dl","true")
          else
            setting.setVariable("Axiom/settings.0","http_disable_dl","false")
          end
        end
        if x == 45 and y == 3 then
          tasks.settings_app = false
          main_gui()
        end
        if x == 45 and y == 3 then
          tasks.settings_app = false
          tasks.settings_app_http = false
          tasks.settings_app_account = false
          tasks.settings_app_boot = false
          tasks.settings_app_system = false
          main_gui()
        end
        if x >= 6 and x <= 14 and y == 8 then
          tasks.settings_app_http = true
          tasks.settings_app_account = false
          tasks.settings_app_boot = false
          tasks.settings_app_system = false
          tasks.settings_app_general = false
          parallel.waitForAny(settings_gui_general)
        end
        if x >= 6 and x <= 14 and y == 10 then
          tasks.settings_app_http = true
          tasks.settings_app_account = false
          tasks.settings_app_boot = false
          tasks.settings_app_system = false
          parallel.waitForAny(settings_gui_http)
          tasks.settings_app_http = false
          tasks.settings_app_account = false
          tasks.settings_app_boot = false
          tasks.settings_app_system = false
        end
        if x >= 6 and x <= 14 and y == 4 then
          tasks.settings_app_http = false
          tasks.settings_app_account = true
          tasks.settings_app_boot = false
          tasks.settings_app_system = false
          parallel.waitForAny(settings_gui_account)
          tasks.settings_app_http = false
          tasks.settings_app_account = false
          tasks.settings_app_boot = false
          tasks.settings_app_system = false
        end
        if x >= 6 and x <= 14 and y == 6 then
          tasks.settings_app_http = false
          tasks.settings_app_account = false
          tasks.settings_app_boot = true
          tasks.settings_app_system = false
          parallel.waitForAny(settings_gui_boot)
          tasks.settings_app_http = false
          tasks.settings_app_account = false
          tasks.settings_app_boot = false
          tasks.settings_app_system = false
        end
        if x >= 6 and x <= 14 and y == 12 then
          tasks.settings_app_http = false
          tasks.settings_app_account = false
          tasks.settings_app_boot = true
          tasks.settings_app_system = false
          parallel.waitForAny(settings_gui_programs)
          tasks.settings_app_http = false
          tasks.settings_app_account = false
          tasks.settings_app_boot = false
          tasks.settings_app_system = false
        end
        if x >= 6 and x <= 14 and y == 14 then
          tasks.settings_app_http = false
          tasks.settings_app_account = false
          tasks.settings_app_boot = true
          tasks.settings_app_system = false
          parallel.waitForAny(settings_gui_updates)
          tasks.settings_app_http = false
          tasks.settings_app_account = false
          tasks.settings_app_boot = false
          tasks.settings_app_system = false
        end
        if x >= 6 and x <= 14 and y == 16 then
          tasks.settings_app_http = false
          tasks.settings_app_account = false
          tasks.settings_app_boot = false
          tasks.settings_app_system = true
          parallel.waitForAny(settings_gui_system)
          tasks.settings_app_http = false
          tasks.settings_app_account = false
          tasks.settings_app_boot = false
          tasks.settings_app_system = false
        end
      end
    else
      return false
    end

end
function settings_gui_programs()
    tasks.settings_app_http = false
    tasks.settings_app_account = false
    tasks.settings_app_boot = true
    tasks.settings_app_system = false
    local c = math.random(1,#settings_tips)
    if tasks.settings_app == true then
      -- separator
      edge.render(17,3,45,16,colors.white,colors.cyan,"   Program settings         x",colors.black,false)
      edge.render(18,5,45,5,colors.white,colors.cyan,"  There is nothing here!",colors.lightGray,false)
        local event, button, x, y = os.pullEvent("mouse_click")
        if event == "terminate" then
          main_gui()
        end
        if x == 45 and y == 3 then
          tasks.settings_app = false
          main_gui()
        end
        if x == 45 and y == 3 then
          tasks.settings_app = false
          tasks.settings_app_http = false
          tasks.settings_app_account = false
          tasks.settings_app_boot = false
          tasks.settings_app_system = false
          main_gui()
        end
        if x >= 6 and x <= 14 and y == 8 then
          tasks.settings_app_http = true
          tasks.settings_app_account = false
          tasks.settings_app_boot = false
          tasks.settings_app_system = false
          tasks.settings_app_general = false
          parallel.waitForAny(settings_gui_general)
        end
        if x >= 6 and x <= 14 and y == 10 then
          tasks.settings_app_http = true
          tasks.settings_app_account = false
          tasks.settings_app_boot = false
          tasks.settings_app_system = false
          parallel.waitForAny(settings_gui_http)
          tasks.settings_app_http = false
          tasks.settings_app_account = false
          tasks.settings_app_boot = false
          tasks.settings_app_system = false
        end
        if x >= 6 and x <= 14 and y == 4 then
          tasks.settings_app_http = false
          tasks.settings_app_account = true
          tasks.settings_app_boot = false
          tasks.settings_app_system = false
          parallel.waitForAny(settings_gui_account)
          tasks.settings_app_http = false
          tasks.settings_app_account = false
          tasks.settings_app_boot = false
          tasks.settings_app_system = false
        end
        if x >= 6 and x <= 14 and y == 6 then
          tasks.settings_app_http = false
          tasks.settings_app_account = false
          tasks.settings_app_boot = true
          tasks.settings_app_system = false
          parallel.waitForAny(settings_gui_boot)
          tasks.settings_app_http = false
          tasks.settings_app_account = false
          tasks.settings_app_boot = false
          tasks.settings_app_system = false
        end
        if x >= 6 and x <= 14 and y == 12 then
          tasks.settings_app_http = false
          tasks.settings_app_account = false
          tasks.settings_app_boot = true
          tasks.settings_app_system = false
          parallel.waitForAny(settings_gui_programs)
          tasks.settings_app_http = false
          tasks.settings_app_account = false
          tasks.settings_app_boot = false
          tasks.settings_app_system = false
        end
        if x >= 6 and x <= 14 and y == 14 then
          tasks.settings_app_http = false
          tasks.settings_app_account = false
          tasks.settings_app_boot = true
          tasks.settings_app_system = false
          parallel.waitForAny(settings_gui_updates)
          tasks.settings_app_http = false
          tasks.settings_app_account = false
          tasks.settings_app_boot = false
          tasks.settings_app_system = false
        end
        if x >= 6 and x <= 14 and y == 16 then
          tasks.settings_app_http = false
          tasks.settings_app_account = false
          tasks.settings_app_boot = false
          tasks.settings_app_system = true
          parallel.waitForAny(settings_gui_system)
          tasks.settings_app_http = false
          tasks.settings_app_account = false
          tasks.settings_app_boot = false
          tasks.settings_app_system = false
        end
    else
      return false
    end
  end
function settings_gui_updates()
    tasks.settings_app_http = false
    tasks.settings_app_account = false
    tasks.settings_app_boot = true
    tasks.settings_app_system = false
    local c = math.random(1,#settings_tips)
    if tasks.settings_app == true then
      -- separator
      edge.render(17,3,45,16,colors.white,colors.cyan,"   Update settings          x",colors.black,false)
      edge.render(18,5,45,5,colors.white,colors.cyan,"  There is nothing here!",colors.lightGray,false)
        local event, button, x, y = os.pullEvent("mouse_click")
        if event == "terminate" then
          main_gui()
        end
        if x == 45 and y == 3 then
          tasks.settings_app = false
          main_gui()
        end
        if x == 45 and y == 3 then
          tasks.settings_app = false
          tasks.settings_app_http = false
          tasks.settings_app_account = false
          tasks.settings_app_boot = false
          tasks.settings_app_system = false
          main_gui()
        end
        if x >= 6 and x <= 14 and y == 8 then
          tasks.settings_app_http = true
          tasks.settings_app_account = false
          tasks.settings_app_boot = false
          tasks.settings_app_system = false
          tasks.settings_app_general = false
          parallel.waitForAny(settings_gui_general)
        end
        if x >= 6 and x <= 14 and y == 10 then
          tasks.settings_app_http = true
          tasks.settings_app_account = false
          tasks.settings_app_boot = false
          tasks.settings_app_system = false
          parallel.waitForAny(settings_gui_http)
          tasks.settings_app_http = false
          tasks.settings_app_account = false
          tasks.settings_app_boot = false
          tasks.settings_app_system = false
        end
        if x >= 6 and x <= 14 and y == 4 then
          tasks.settings_app_http = false
          tasks.settings_app_account = true
          tasks.settings_app_boot = false
          tasks.settings_app_system = false
          parallel.waitForAny(settings_gui_account)
          tasks.settings_app_http = false
          tasks.settings_app_account = false
          tasks.settings_app_boot = false
          tasks.settings_app_system = false
        end
        if x >= 6 and x <= 14 and y == 6 then
          tasks.settings_app_http = false
          tasks.settings_app_account = false
          tasks.settings_app_boot = true
          tasks.settings_app_system = false
          parallel.waitForAny(settings_gui_boot)
          tasks.settings_app_http = false
          tasks.settings_app_account = false
          tasks.settings_app_boot = false
          tasks.settings_app_system = false
        end
        if x >= 6 and x <= 14 and y == 12 then
          tasks.settings_app_http = false
          tasks.settings_app_account = false
          tasks.settings_app_boot = true
          tasks.settings_app_system = false
          parallel.waitForAny(settings_gui_programs)
          tasks.settings_app_http = false
          tasks.settings_app_account = false
          tasks.settings_app_boot = false
          tasks.settings_app_system = false
        end
        if x >= 6 and x <= 14 and y == 14 then
          tasks.settings_app_http = false
          tasks.settings_app_account = false
          tasks.settings_app_boot = true
          tasks.settings_app_system = false
          parallel.waitForAny(settings_gui_updates)
          tasks.settings_app_http = false
          tasks.settings_app_account = false
          tasks.settings_app_boot = false
          tasks.settings_app_system = false
        end
        if x >= 6 and x <= 14 and y == 16 then
          tasks.settings_app_http = false
          tasks.settings_app_account = false
          tasks.settings_app_boot = false
          tasks.settings_app_system = true
          parallel.waitForAny(settings_gui_system)
          tasks.settings_app_http = false
          tasks.settings_app_account = false
          tasks.settings_app_boot = false
          tasks.settings_app_system = false
        end
    else
      return false
    end
  end
function settings_gui_boot()
  tasks.settings_app_http = false
  tasks.settings_app_account = false
  tasks.settings_app_boot = true
  tasks.settings_app_system = false
  local c = math.random(1,#settings_tips)
  if tasks.settings_app == true then
    --edge.render(5,1,5+string.len("settings"),1,colors.lightGray,colors.cyan,"Settings",colors.black,false)
    --edge.render(5,3,45,17,colors.white,colors.cyan,"                                        x",colors.black,true)
    --edge.render(26,9,28,9,colors.white,colors.cyan,"A X I O M",colors.black)
    --edge.render(17,17,45,17,colors.white,colors.cyan,version.." | "..settings_tips[c],colors.lightGray,false)
    --edge.render(5,3,15,17,colors.lightGray,colors.cyan,"",colors.black,false)
    --edge.render(6,4,14,4,colors.lightGray,colors.cyan,"Account",colors.black,false)
    --edge.render(6,6,14,6,colors.lightGray,colors.cyan,"Boot",colors.black,false)
    --edge.render(6,8,14,8,colors.lightGray,colors.cyan,"General",colors.black,false)
    --edge.render(6,10,14,10,colors.lightGray,colors.cyan,"HTTP",colors.black,false)
    --edge.render(6,12,14,12,colors.lightGray,colors.cyan,"Tasks",colors.black,false)
    --edge.render(6,14,14,14,colors.lightGray,colors.cyan,"Updates",colors.black,false)
    --edge.render(6,16,14,16,colors.lightGray,colors.cyan,"System",colors.black,false)
    -- separator
    edge.render(17,3,45,16,colors.white,colors.cyan,"   Boot settings            x",colors.black,false)
    edge.render(18,5,45,5,colors.white,colors.cyan,"Custom API dir:",colors.black,false)
    edge.render(19,6,40,6,colors.lightGray,colors.cyan,setting.getVariable("Axiom/settings.0","api_dir"),colors.gray,false)
    edge.render(18,7,45,7,colors.white,colors.cyan,"Explorer start dir:",colors.black,false)
    edge.render(19,8,40,8,colors.lightGray,colors.cyan,setting.getVariable("Axiom/settings.0","fexplore_startdir"),colors.gray,false)
    if setting.getVariable("Axiom/settings.0","system_skipsys_scan") == "true" then
      edge.render(18,10,45,10,colors.white,colors.cyan,"[+] Skip system scan",colors.black,false)
    else
      edge.render(18,10,45,10,colors.white,colors.cyan,"[ ] Skip system scan",colors.black,false)
    end
    while(tasks.settings_app_boot == true) do
      if tasks.settings_app_boot == false then
        break
      end
      if setting.getVariable("Axiom/settings.0","system_skipsys_scan") == "true" then
        edge.render(18,10,21,10,colors.white,colors.cyan,"[+]",colors.black,false)
      else
        edge.render(18,10,21,10,colors.white,colors.cyan,"[ ]",colors.black,false)
      end
      local event, button, x, y = os.pullEvent("mouse_click")
      if event == "terminate" then
        main_gui()
      end
      if x == 45 and y == 3 then
        tasks.settings_app = false
        main_gui()
      end
      if x >= 19 and x <= 38 and y == 6 then
        edge.render(19,6,40,6,colors.lightGray,colors.cyan,"                     ",colors.white,false)
        term.setCursorPos(19,6)
        term.setBackgroundColor(colors.lightGray)
        local input = io.read()
        term.setBackgroundColor(colors.cyan)
        setting.setVariable("Axiom/settings.0","api_dir",input)
        edge.render(19,6,40,6,colors.lightGray,colors.cyan,setting.getVariable("Axiom/settings.0","api_dir"),colors.gray,false)
        fs.makeDir(input)
      end
      if x >= 19 and x <= 38 and y == 8 then
        edge.render(19,8,40,8,colors.lightGray,colors.cyan,"                     ",colors.white,false)
        term.setCursorPos(19,8)
        term.setBackgroundColor(colors.lightGray)
        local input = io.read()
        term.setBackgroundColor(colors.cyan)
        if fs.exists(input) then
          setting.setVariable("Axiom/settings.0","fexplore_startdir",input)
          files = input
        else
          edge.render(19,8,40,8,colors.lightGray,colors.cyan,"Not a dir!",colors.red,false)
          sleep(1.5)
        end
        edge.render(19,8,40,8,colors.lightGray,colors.cyan,setting.getVariable("Axiom/settings.0","fexplore_startdir"),colors.gray,false)
      end
      if x >= 18 and x <= 38 and y == 9+1 then
        if setting.getVariable("Axiom/settings.0","system_skipsys_scan") == "true" then
          setting.setVariable("Axiom/settings.0","system_skipsys_scan","false")
        else
          setting.setVariable("Axiom/settings.0","system_skipsys_scan","true")
        end
      end
      if x == 45 and y == 3 then
        tasks.settings_app = false
        tasks.settings_app_http = false
        tasks.settings_app_account = false
        tasks.settings_app_boot = false
        tasks.settings_app_system = false
        main_gui()
      end
      if x >= 6 and x <= 14 and y == 8 then
        tasks.settings_app_http = true
        tasks.settings_app_account = false
        tasks.settings_app_boot = false
        tasks.settings_app_system = false
        tasks.settings_app_general = false
        parallel.waitForAny(settings_gui_general)
      end
      if x >= 6 and x <= 14 and y == 10 then
        tasks.settings_app_http = true
        tasks.settings_app_account = false
        tasks.settings_app_boot = false
        tasks.settings_app_system = false
        parallel.waitForAny(settings_gui_http)
        tasks.settings_app_http = false
        tasks.settings_app_account = false
        tasks.settings_app_boot = false
        tasks.settings_app_system = false
      end
      if x >= 6 and x <= 14 and y == 4 then
        tasks.settings_app_http = false
        tasks.settings_app_account = true
        tasks.settings_app_boot = false
        tasks.settings_app_system = false
        parallel.waitForAny(settings_gui_account)
        tasks.settings_app_http = false
        tasks.settings_app_account = false
        tasks.settings_app_boot = false
        tasks.settings_app_system = false
      end
      if x >= 6 and x <= 14 and y == 6 then
        tasks.settings_app_http = false
        tasks.settings_app_account = false
        tasks.settings_app_boot = true
        tasks.settings_app_system = false
        parallel.waitForAny(settings_gui_boot)
        tasks.settings_app_http = false
        tasks.settings_app_account = false
        tasks.settings_app_boot = false
        tasks.settings_app_system = false
      end
      if x >= 6 and x <= 14 and y == 12 then
        tasks.settings_app_http = false
        tasks.settings_app_account = false
        tasks.settings_app_boot = true
        tasks.settings_app_system = false
        parallel.waitForAny(settings_gui_programs)
        tasks.settings_app_http = false
        tasks.settings_app_account = false
        tasks.settings_app_boot = false
        tasks.settings_app_system = false
      end
      if x >= 6 and x <= 14 and y == 14 then
        tasks.settings_app_http = false
        tasks.settings_app_account = false
        tasks.settings_app_boot = true
        tasks.settings_app_system = false
        parallel.waitForAny(settings_gui_updates)
        tasks.settings_app_http = false
        tasks.settings_app_account = false
        tasks.settings_app_boot = false
        tasks.settings_app_system = false
      end
      if x >= 6 and x <= 14 and y == 16 then
        tasks.settings_app_http = false
        tasks.settings_app_account = false
        tasks.settings_app_boot = false
        tasks.settings_app_system = true
        parallel.waitForAny(settings_gui_system)
        tasks.settings_app_http = false
        tasks.settings_app_account = false
        tasks.settings_app_boot = false
        tasks.settings_app_system = false
      end
    end
  else
    return false
  end
end
function settings_gui_account()
  tasks.settings_app_http = false
  tasks.settings_app_account = true
  tasks.settings_app_boot = false
  tasks.settings_app_system = false
  local c = math.random(1,#settings_tips)
  if tasks.settings_app == true then
    --edge.render(5,1,5+string.len("settings"),1,colors.lightGray,colors.cyan,"Settings",colors.black,false)
    --edge.render(5,3,45,17,colors.white,colors.cyan,"                                        x",colors.black,true)
    --edge.render(26,9,28,9,colors.white,colors.cyan,"A X I O M",colors.black)
    --edge.render(17,17,45,17,colors.white,colors.cyan,version.." | "..settings_tips[c],colors.lightGray,false)
    --edge.render(5,3,15,17,colors.lightGray,colors.cyan,"",colors.black,false)
    --edge.render(6,4,14,4,colors.lightGray,colors.cyan,"Account",colors.black,false)
    --edge.render(6,6,14,6,colors.lightGray,colors.cyan,"Boot",colors.black,false)
    --edge.render(6,8,14,8,colors.lightGray,colors.cyan,"General",colors.black,false)
    --edge.render(6,10,14,10,colors.lightGray,colors.cyan,"HTTP",colors.black,false)
    --edge.render(6,12,14,12,colors.lightGray,colors.cyan,"Tasks",colors.black,false)
    --edge.render(6,14,14,14,colors.lightGray,colors.cyan,"Updates",colors.black,false)
    --edge.render(6,16,14,16,colors.lightGray,colors.cyan,"System",colors.black,false)
    -- separator
    edge.render(17,3,45,16,colors.white,colors.cyan,"   Account settings         x",colors.black,false)
    edge.render(17,17,45,17,colors.white,colors.cyan,version,colors.lightGray,false)
    edge.render(18,5,45,5,colors.white,colors.cyan,"  Change username",colors.gray,false)
    edge.render(18,7,45,7,colors.white,colors.cyan,"  Change password",colors.gray,false)
    --edge.render(18,9,45,9,colors.white,colors.cyan,"See license agreement",colors.black,false)
    edge.render(18,9,45,9,colors.white,colors.cyan,"Re-configure account",colors.black,false)
    while(tasks.settings_app_account == true) do
      if tasks.settings_app == false then
        break
      end
      local event, button, x, y = os.pullEvent("mouse_click")
      if event == "terminate" then
        parallel.waitForAll(main_gui,clock)
      end
      if x == 45 and y == 3 then
        tasks.settings_app = false
        main_gui()
      end
      if x >= 18 and x <= 36 and y == 9 then
        setting.setVariable("Axiom/settings.0","first_update","false")
        setting.setVariable("Axiom/settings.0","username","nil")
        setting.setVariable("Axiom/settings.0","password","nil")
        setting.setVariable("Axiom/settings.0","licensed","false")
        tasks.settings_app = false
        tasks.settings_app_http = false
        tasks.settings_app_account = false
        tasks.settings_app_boot = false
        tasks.settings_app_system = false
        firstTimeSetup()
      end
      if x >= 21 and x <= 36 and y == 5 then
        edge.render(20,5,35,5,colors.lightGray,colors.cyan,"",colors.black,false)
        term.setCursorPos(21,5)
        term.setBackgroundColor(colors.lightGray)
        local newUsr = io.read()
        term.setBackgroundColor(colors.cyan)
        setting.setVariable("Axiom/settings.0","username",encryption.sha256(newUsr))
        edge.render(18,5,45,5,colors.white,colors.cyan,"  Changed username",colors.gray,false)
        newUsr = nil
      end
      if x >= 21 and x <= 36 and y == 7 then
        edge.render(20,7,35,7,colors.lightGray,colors.cyan,"",colors.black,false)
        term.setCursorPos(21,7)
        term.setBackgroundColor(colors.lightGray)
        local newPass = read("*")
        term.setBackgroundColor(colors.cyan)
        setting.setVariable("Axiom/settings.0","password",encryption.sha256(newPass))
        edge.render(18,7,45,7,colors.white,colors.cyan,"  Changed password",colors.gray,false)
        newPass = nil
      end
      if x == 45 and y == 3 then
        tasks.settings_app = false
        tasks.settings_app_http = false
        tasks.settings_app_account = false
        tasks.settings_app_boot = false
        tasks.settings_app_system = false
        main_gui()
      end
      if x >= 6 and x <= 14 and y == 8 then
        tasks.settings_app_http = true
        tasks.settings_app_account = false
        tasks.settings_app_boot = false
        tasks.settings_app_system = false
        tasks.settings_app_general = false
        parallel.waitForAny(settings_gui_general)
      end
      if x >= 6 and x <= 14 and y == 10 then
        tasks.settings_app_http = true
        tasks.settings_app_account = false
        tasks.settings_app_boot = false
        tasks.settings_app_system = false
        parallel.waitForAny(settings_gui_http)
        tasks.settings_app_http = false
        tasks.settings_app_account = false
        tasks.settings_app_boot = false
        tasks.settings_app_system = false
      end
      if x >= 6 and x <= 14 and y == 4 then
        tasks.settings_app_http = false
        tasks.settings_app_account = true
        tasks.settings_app_boot = false
        tasks.settings_app_system = false
        parallel.waitForAny(settings_gui_account)
        tasks.settings_app_http = false
        tasks.settings_app_account = false
        tasks.settings_app_boot = false
        tasks.settings_app_system = false
      end
      if x >= 6 and x <= 14 and y == 6 then
        tasks.settings_app_http = false
        tasks.settings_app_account = false
        tasks.settings_app_boot = true
        tasks.settings_app_system = false
        parallel.waitForAny(settings_gui_boot)
        tasks.settings_app_http = false
        tasks.settings_app_account = false
        tasks.settings_app_boot = false
        tasks.settings_app_system = false
      end
      if x >= 6 and x <= 14 and y == 12 then
        tasks.settings_app_http = false
        tasks.settings_app_account = false
        tasks.settings_app_boot = true
        tasks.settings_app_system = false
        parallel.waitForAny(settings_gui_programs)
        tasks.settings_app_http = false
        tasks.settings_app_account = false
        tasks.settings_app_boot = false
        tasks.settings_app_system = false
      end
      if x >= 6 and x <= 14 and y == 14 then
        tasks.settings_app_http = false
        tasks.settings_app_account = false
        tasks.settings_app_boot = true
        tasks.settings_app_system = false
        parallel.waitForAny(settings_gui_updates)
        tasks.settings_app_http = false
        tasks.settings_app_account = false
        tasks.settings_app_boot = false
        tasks.settings_app_system = false
      end
      if x >= 6 and x <= 14 and y == 16 then
        tasks.settings_app_http = false
        tasks.settings_app_account = false
        tasks.settings_app_boot = false
        tasks.settings_app_system = true
        parallel.waitForAny(settings_gui_system)
        tasks.settings_app_http = false
        tasks.settings_app_account = false
        tasks.settings_app_boot = false
        tasks.settings_app_system = false
      end
    end
  else
    return false
  end
end
function settings_gui()
  local c = math.random(1,#settings_tips)
  tasks.settings_app = true
  --print("tasks.."..tasks[1]) ABCDEFGHIJKLMNOPQRSTUVXYZ
  edge.render(5,1,5+string.len("settings"),1,colors.lightGray,colors.cyan,"Settings",colors.black,false)
  edge.render(5,3,45,17,colors.white,colors.cyan,"                                        x",colors.black,true)
  edge.render(26,9,28,9,colors.white,colors.cyan,"A X I O M",colors.black)
  --edge.render(17,16,45,16,colors.white,colors.cyan,"Warn: You may have to click twice",colors.lightGray,false)
  edge.render(17,17,45,17,colors.white,colors.cyan,version.." (Server) | "..settings_tips[c],colors.lightGray,false)
  edge.render(5,3,15,17,colors.lightGray,colors.cyan,"",colors.black,false)
  edge.render(6,4,14,4,colors.lightGray,colors.cyan,"Account",colors.black,false)
  edge.render(6,6,14,6,colors.lightGray,colors.cyan,"Boot",colors.black,false)
  edge.render(6,8,14,8,colors.lightGray,colors.cyan,"General",colors.black,false)
  edge.render(6,10,14,10,colors.lightGray,colors.cyan,"HTTP",colors.black,false)
  edge.render(6,12,14,12,colors.lightGray,colors.cyan,"Programs",colors.black,false)
  edge.render(6,14,14,14,colors.lightGray,colors.cyan,"Updates",colors.black,false)
  edge.render(6,16,14,16,colors.lightGray,colors.cyan,"System",colors.black,false)
  while(tasks.settings_app == true) do
    local event, button, x, y = os.pullEvent("mouse_click")
    --print(x..y)
    if event == "terminate" then
      main_gui()
    end
    if x == 45 and y == 3 then
      tasks.settings_app = false
      tasks.settings_app_http = false
      tasks.settings_app_account = false
      tasks.settings_app_boot = false
      tasks.settings_app_system = false
      main_gui()
    end
    if x >= 6 and x <= 13 and y == 8 and setting.getVariable("Axiom/settings.0","licensed") == "true" then
      tasks.settings_app_http = true
      tasks.settings_app_account = false
      tasks.settings_app_boot = false
      tasks.settings_app_system = false
      tasks.settings_app_general = false
      parallel.waitForAny(settings_gui_general)
    end
    if x >= 6 and x <= 14 and y == 10 and setting.getVariable("Axiom/settings.0","licensed") == "true" then
      tasks.settings_app_http = true
      tasks.settings_app_account = false
      tasks.settings_app_boot = false
      tasks.settings_app_system = false
      tasks.settings_app_general = false
      parallel.waitForAny(settings_gui_http)
      tasks.settings_app_http = false
      tasks.settings_app_account = false
      tasks.settings_app_boot = false
      tasks.settings_app_system = false
      tasks.settings_app_general = false
    end
    if x >= 6 and x <= 14 and y == 14 then
      tasks.settings_app_http = false
      tasks.settings_app_account = false
      tasks.settings_app_boot = true
      tasks.settings_app_system = false
      parallel.waitForAny(settings_gui_updates)
      tasks.settings_app_http = false
      tasks.settings_app_account = false
      tasks.settings_app_boot = false
      tasks.settings_app_system = false
    end
    if x >= 6 and x <= 14 and y == 4 then
      tasks.settings_app_http = false
      tasks.settings_app_account = true
      tasks.settings_app_boot = false
      tasks.settings_app_system = false
      tasks.settings_app_general = false
      parallel.waitForAny(settings_gui_account)
      tasks.settings_app_http = false
      tasks.settings_app_account = false
      tasks.settings_app_boot = false
      tasks.settings_app_system = false
      tasks.settings_app_general = false
    end
    if x >= 6 and x <= 14 and y == 6 and setting.getVariable("Axiom/settings.0","licensed") == "true" then
      tasks.settings_app_http = false
      tasks.settings_app_account = false
      tasks.settings_app_boot = true
      tasks.settings_app_system = false
      parallel.waitForAny(settings_gui_boot)
      tasks.settings_app_http = false
      tasks.settings_app_account = false
      tasks.settings_app_boot = false
      tasks.settings_app_system = false
      tasks.settings_app_general = false
    end
    if x >= 6 and x <= 14 and y == 14 and setting.getVariable("Axiom/settings.0","licensed") == "true" then
      tasks.settings_app_http = false
      tasks.settings_app_account = false
      tasks.settings_app_boot = true
      tasks.settings_app_system = false
      parallel.waitForAny(settings_gui_updates)
      tasks.settings_app_http = false
      tasks.settings_app_account = false
      tasks.settings_app_boot = false
      tasks.settings_app_system = false
      tasks.settings_app_general = false
    end
    if x >= 6 and x <= 14 and y == 12 and setting.getVariable("Axiom/settings.0","licensed") == "true" then
      tasks.settings_app_http = false
      tasks.settings_app_account = false
      tasks.settings_app_boot = true
      tasks.settings_app_system = false
      parallel.waitForAny(settings_gui_programs)
      tasks.settings_app_http = false
      tasks.settings_app_account = false
      tasks.settings_app_boot = false
      tasks.settings_app_system = false
      tasks.settings_app_general = false
    end
    if x >= 6 and x <= 14 and y == 16 and setting.getVariable("Axiom/settings.0","licensed") == "true" then
      tasks.settings_app_http = false
      tasks.settings_app_account = false
      tasks.settings_app_boot = false
      tasks.settings_app_system = true
      parallel.waitForAny(settings_gui_system)
      tasks.settings_app_http = false
      tasks.settings_app_account = false
      tasks.settings_app_boot = false
      tasks.settings_app_system = false
      tasks.settings_app_general = false
    end
  end
end
function main_gui(errmsg)

  if nightmode == true then
    menubarColor = colors.white
  else
    menubarColor = colors.white
  end
  state = "main_gui"
  local x_p = 4
  if setting.getVariable("Axiom/settings.0","first_update") == "false" and updnotif == false then
    edge.render(16,7,34,12,colors.white,colors.cyan,"Alert             x",colors.black,true)
    edge.render(17,9,34,9,colors.white,colors.cyan," Please reboot to ",colors.black,false)
    edge.render(16,10,34,10,colors.white,colors.cyan,"complete the setup.",colors.black,false)
    updnotif = true
    while(true) do
      local event, button, x, y = os.pullEvent("mouse_click")
      if x == 16 + 18 and y == 7 then
        main_gui()
      end
    end
  end
  edge.render(1,1,mx,19,colors.black,colors.cyan,"",colors.black,false)
  edge.render(1,1,mx,1,menubarColor,colors.cyan,"O",colors.black,false)
  x_p = 4
  if setting.getVariable("Axiom/settings.0","dev") == "true" then
    edge.xprint("Axiom",2,17,colors.white)
  end
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
          main_gui()

        end
      end
    end

  --edge.render(1,18,1,1,colors.cyan,colors.cyan,demo,colors.white,false)
  --edge.render(2,2,2,2,colors.white,colors.cyan,": Home",colors.black)
  --edge.render(2,4,8,4,colors.white,colors.cyan,": Update",colors.black)
  while(true) do

    local event, button, x, y = os.pullEvent("mouse_click")
    if nightmode == true then
      menubarColor = colors.white
    else
      menubarColor = colors.white
    end

    x_p = 4
    if event == "terminate" then
      error("Main process was terminated.")
    end
    if x >= 1 and x <= 4 and y == 1 and button == 1 then
      edge.render(1,1,4,1,colors.gray,colors.cyan,"O",colors.white,false)
      edge.render(1,2,10,10,menubarColor,colors.cyan,"",colors.white,true)

      edge.render(1,2,10,2,menubarColor,colors.cyan,"   Menu   ",colors.black,false)
      edge.render(1,3,10,3,menubarColor,colors.cyan,"Update",colors.black,false)
      edge.render(1,4,10,4,menubarColor,colors.cyan,"Settings",colors.black,false)
      edge.render(1,5,10,5,menubarColor,colors.cyan,"Files",colors.black,false)
      edge.render(1,6,10,5,menubarColor,colors.cyan,"Terminal",colors.black,false)
      edge.render(1,7,10,7,menubarColor,colors.cyan,"Logout",colors.black,false)
      edge.render(1,8,10,8,menubarColor,colors.cyan,"Reboot",colors.black,false)
      edge.render(1,9,10,9,menubarColor,colors.cyan,"Shut down",colors.black,false)
      edge.render(1,10,10,10,menubarColor,colors.cyan,"About",colors.black,false)
      while(true) do
        local event, button, x, y = os.pullEvent("mouse_click")
        if x >= 10 and y >= 1 or x >= 1 and y >= 11 or x >= 1 and x <= 4 and y == 1 then
          main_gui()
        end
        if event == "terminate" then
          main_gui()
        end
        if x >= 1 and x <= 10 and y == 3 then
          edge.render(1,3,10,3,menubarColor,colors.cyan,"Updating..",colors.black,false)
          execUpd()
        end
        if x >= 1 and x <= 10 and y == 4 then
          --next.newTask("Axiom/programs/settings")
          settings_gui()
        end
        if x >= 1 and x <= 10 and y == 6 then
          fs.delete("safeStart")
          fs.move("startup","ax")
          a = fs.open("startup","w")
          a.writeLine("print('Type ax to go back to Axiom')")
          a.close()
          os.reboot()
        end
        if x >= 1 and x <= 10 and y == 5 then
          files = setting.getVariable("Axiom/settings.0","fexplore_startdir")
          filebrowser()
        end
        if x >= 1 and x <= 10 and y == 7 then
          shell.run("clear")
          state = "loginscreen"
          login_gui()
        end
        if x >= 1 and x <= 10 and y == 8 then
          if setting.getVariable("Axiom/settings.0","first_update") == "false" and setting.getVariable("Axiom/settings.0","licensed") == "true" then
            setting.setVariable("Axiom/settings.0","first_update","true")
            edge.render(1,1,mx,19,colors.cyan,colors.cyan,"",colors.black,false)
            edge.render(16,7,34,12,colors.white,colors.cyan,"",colors.black,true)
            edge.render(17,8,34,8,colors.white,colors.cyan,"Axiom is updating ",colors.black,false)
            edge.render(17,10,34,10,colors.white,colors.cyan,"  Please wait.",colors.black,false)
            execUpd()
            os.reboot()
          end
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
          if setting.getVariable("Axiom/settings.0","first_update") == "false" and setting.getVariable("Axiom/settings.0","licensed") == "true" then
            setting.setVariable("Axiom/settings.0","first_update","true")
            edge.render(1,1,mx,19,colors.cyan,colors.cyan,"",colors.black,false)
            edge.render(16,7,34,12,colors.white,colors.cyan,"",colors.black,true)
            edge.render(17,8,34,8,colors.white,colors.cyan,"Axiom is updating ",colors.black,false)
            edge.render(17,10,34,10,colors.white,colors.cyan,"  Please wait.",colors.black,false)
            execUpd()
            os.shutdown()
          end
          os.shutdown()
        end
      end
    end
  end
end
function sysInfo()
  local currentFreeSpace = fs.getFreeSpace("/")
  local currentFreeSpaceKB = math.floor(currentFreeSpace/1024)
  menubarColor = colors.green
  edge.render(1,1,mx,1,menubarColor,colors.cyan,"O",colors.black,false)
  edge.render(1,2,51,19,colors.white,colors.cyan,"",colors.black,false)
  edge.render(1,2,51,4,colors.lime,colors.cyan,"",colors.white,false)
  edge.render(1,3,51,4,colors.lime,colors.cyan,"                                                x",colors.white,false)
  edge.render(3,3,25,3,colors.lime,colors.cyan,"System Info",colors.white,false)
  -- minumum render value: 5

  edge.render(2,6,9,10,colors.cyan,colors.cyan,"",colors.white,false)
  edge.render(3,8,9,10,colors.cyan,colors.cyan,"  "..edition,colors.white,false)
  edge.render(11,7,11,7,colors.white,colors.cyan,"Axiom System "..version.." "..demo.." "..version_sub,colors.black,false)
  edge.render(11,8,11,8,colors.white,colors.cyan,"Free space: "..currentFreeSpaceKB.." KB",colors.black,false)
  edge.render(11,9,11,9,colors.white,colors.cyan,"Computer ID & Name: "..os.getComputerID() .. ":"..os.getComputerLabel(),colors.black,false)
  edge.render(11,10,11,10,colors.white,colors.cyan,"Edge version: "..edge.version,colors.black,false)
  edge.render(2,13,2,13,colors.white,colors.cyan,"Automatic update mode: "..when..":"..delay.."s delay",colors.black,false)
  edge.render(2,14,2,14,colors.white,colors.cyan,"Last update: "..tostring(setting.getVariable("Axiom/settings.0","system_last_update")),colors.black,false)
  edge.render(2,15,2,15,colors.white,colors.cyan,"Checked for updates: Day "..tostring(setting.getVariable("Axiom/settings.0","system_last_updatecheck")),colors.black,false)
  while(true) do
    sleep(0)
    local event, button, x, y = os.pullEvent("mouse_click")
    if x == 49 and y == 3 and button == 1 then
      menubarColor = colors.white
      main_gui()
    end
    if x >= 1 and x <= 4 and y == 1 and button == 1 then
      edge.render(1,1,4,1,colors.gray,colors.cyan,"O",colors.white,false)
      edge.render(1,2,10,10,menubarColor,colors.cyan,"",colors.white,true)

      edge.render(1,2,10,2,menubarColor,colors.cyan,"   Menu   ",colors.black,false)
      edge.render(1,3,10,3,menubarColor,colors.cyan,"Update",colors.black,false)
      edge.render(1,4,10,4,menubarColor,colors.cyan,"Settings",colors.black,false)
      edge.render(1,5,10,5,menubarColor,colors.cyan,"Files",colors.black,false)
      edge.render(1,6,10,5,menubarColor,colors.cyan,"Terminal",colors.black,false)
      edge.render(1,7,10,7,menubarColor,colors.cyan,"Logout",colors.black,false)
      edge.render(1,8,10,8,menubarColor,colors.cyan,"Reboot",colors.black,false)
      edge.render(1,9,10,9,menubarColor,colors.cyan,"Shut down",colors.black,false)
      edge.render(1,10,10,10,menubarColor,colors.cyan,"About",colors.black,false)
      while(true) do
        local event, button, x, y = os.pullEvent("mouse_click")
        if x >= 10 and y >= 1 or x >= 1 and y >= 11 or x >= 1 and x <= 4 and y == 1 then
          sysInfo()
        end
        if event == "terminate" then
          main_gui()
        end
        if x >= 1 and x <= 10 and y == 3 then
          edge.render(1,3,10,3,menubarColor,colors.cyan,"Updating..",colors.black,false)
          execUpd()
        end
        if x >= 1 and x <= 10 and y == 4 then
          --next.newTask("Axiom/programs/settings")
          settings_gui()
        end
        if x >= 1 and x <= 10 and y == 6 then
          fs.delete("safeStart")
          fs.move("startup","ax")
          a = fs.open("startup","w")
          a.writeLine("shell.run('clear')")
          a.writeLine("print('Type ax to go back to Axiom')")
          a.close()
          os.reboot()
        end
        if x >= 1 and x <= 10 and y == 5 then
          filebrowser()
        end
        if x >= 1 and x <= 10 and y == 7 then
          shell.run("clear")
          state = "loginscreen"
          login_gui()
        end
        if x >= 1 and x <= 10 and y == 8 then
          if setting.getVariable("Axiom/settings.0","first_update") == "false" and setting.getVariable("Axiom/settings.0","licensed") == "true" then
            setting.setVariable("Axiom/settings.0","first_update","true")
            edge.render(1,1,mx,19,colors.cyan,colors.cyan,"",colors.black,false)
            edge.render(16,7,34,12,colors.white,colors.cyan,"",colors.black,true)
            edge.render(17,8,34,8,colors.white,colors.cyan,"Axiom is updating ",colors.black,false)
            edge.render(17,10,34,10,colors.white,colors.cyan,"  Please wait.",colors.black,false)
            execUpd()
            os.reboot()
          end
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
          if setting.getVariable("Axiom/settings.0","first_update") == "false" and setting.getVariable("Axiom/settings.0","licensed") == "true" then
            setting.setVariable("Axiom/settings.0","first_update","true")
            edge.render(1,1,mx,19,colors.cyan,colors.cyan,"",colors.black,false)
            edge.render(16,7,34,12,colors.white,colors.cyan,"",colors.black,true)
            edge.render(17,8,34,8,colors.white,colors.cyan,"Axiom is updating ",colors.black,false)
            edge.render(17,10,34,10,colors.white,colors.cyan,"  Please wait.",colors.black,false)
            execUpd()
            os.shutdown()
          end
          os.shutdown()
        end
      end
    end
    if event == "terminate" then
      menubarColor = colors.white
      main_gui()
    end
  end
end
function filebrowser()
  tasks.filebrowser = true
  menubarColor = colors.green
  --files = setting.getVariable("Axiom/settings.0","fexplore_startdir")
  if setting.getVariable("Axiom/settings.0","licensed") == "false" or setting.getVariable("Axiom/settings.0","general_background_name") == "black" then
    edge.render(1,1,51,19,colors.black,colors.cyan,"",colors.black,false)
  else
    edge.image(1,1,setting.getVariable("Axiom/settings.0","general_background_name"),colors.cyan)
  end
  edge.render(1,1,mx,1,menubarColor,colors.cyan,"O",colors.black,false)
  edge.render(1,2,51,2,colors.lime,colors.cyan,"                                          _ x",colors.black,false)
  edge.render(1,4,51,19,colors.white,colors.cyan,"",colors.black,true)
  edge.render(1,3,51,4,colors.lime,colors.cyan,"",colors.black,false)
  --edge.render(7,4,7,4,colors.white,colors.cyan,"Files: <Up>",colors.black)
  edge.render(7,3,39,3,colors.white,colors.cyan,os.getComputerID()..":"..files,colors.black)
  edge.render(41,3,41,3,colors.lime,colors.cyan,"<Back>",colors.black)
  edge.render(7,4,7,4,colors.lime,colors.cyan,"<New folder> <New file> <Delete>",colors.black)
  edge.render(2,5,7,5,colors.white,colors.cyan,"| Name |                     | Size |  | Type |",colors.lightGray)
  if not fs.exists(files) then
    f_file = fs.list("/")
  else
    f_file = fs.list("/")
  end
  fy = 6
  foy = 5
  for i,v in ipairs(f_file) do

    if fs.isDir(files..f_file[i]) then
      if f_file[i] == "rom" then

      else
        local l = fs.list(files..f_file[i].."/")
        edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.blue,false)
        edge.render(42,fy,42,fy,colors.white,colors.cyan,"Folder",colors.black)
        edge.render(31,fy,41,fy,colors.white,colors.cyan,#l.." items",colors.black)
      end
      fy = fy +1
    else
      if f_file[i] == "edge" or f_file[i] == "next" or f_file[i] == "settings" or f_file[i] == "encryption" then

        edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
        edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
        edge.render(40,fy,40,fy,colors.white,colors.cyan,"API",colors.orange)
      else
        if f_file[i] == "sys.axs" or f_file[i] == "settings.0" then
          edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
          edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
          edge.render(42,fy,40,fy,colors.white,colors.cyan,"Sys",colors.red)
        elseif f_file[i] == "startup" then
          edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
          edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
          edge.render(40,fy,40,fy,colors.white,colors.cyan,"Bootloader",colors.red)
        else
          if string.find(f_file[i],".lua",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,40,fy,colors.white,colors.cyan,"Lua Script",colors.blue)
          elseif string.find(f_file[i],".js",string.len(f_file[i]) - 3) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,40,fy,colors.white,colors.cyan,"JavaScript",colors.orange)
          elseif string.find(f_file[i],".cs",string.len(f_file[i]) - 3) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,40,fy,colors.white,colors.cyan,"C# Script",colors.red)
          elseif string.find(f_file[i],".xml",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,40,fy,colors.white,colors.cyan,"XML Config",colors.blue)
          elseif string.find(f_file[i],".nfp",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,40,fy,colors.white,colors.cyan,"Image",colors.magenta)
          elseif string.find(f_file[i],".html",string.len(f_file[i]) - 5) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,40,fy,colors.white,colors.cyan,"Webpage",colors.green)
          elseif string.find(f_file[i],".sys",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,40,fy,colors.white,colors.cyan,"System File",colors.black)
          elseif string.find(f_file[i],".dll",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(42,fy,40,fy,colors.white,colors.cyan,"DLL",colors.black)
          elseif string.find(f_file[i],".txt",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,40,fy,colors.white,colors.cyan,"Text File",colors.green)
          elseif string.find(f_file[i],".log",string.len(f_file[i]) - 4) then
            if files..f_file[i] == "Axiom/stacktrace.log" then
              edge.render(20,fy,20,fy,colors.white,colors.cyan,"CRASH LOG",colors.red,false)
            end
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,40,fy,colors.white,colors.cyan,"Log File",colors.green)
          elseif string.find(f_file[i],".cfg",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,40,fy,colors.white,colors.cyan,"Config file",colors.blue)
          elseif string.find(f_file[i],".pref",string.len(f_file[i]) - 5) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(41,fy,40,fy,colors.white,colors.cyan,"Pref",colors.black)
          elseif string.find(f_file[i],".axg",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,40,fy,colors.white,colors.cyan,"Image",colors.magenta)
          elseif string.find(f_file[i],".jar",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(42,fy,40,fy,colors.white,colors.cyan,"Jar",colors.black)
          elseif string.find(f_file[i],".py",string.len(f_file[i]) - 3) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,40,fy,colors.white,colors.cyan,"Python Script",colors.black)
          elseif string.find(f_file[i],".hta",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(42,fy,40,fy,colors.white,colors.cyan,"HTA",colors.black)
          elseif string.find(f_file[i],".cpp",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,40,fy,colors.white,colors.cyan,"C++ Script",colors.black)
          elseif string.find(f_file[i],".app",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,40,fy,colors.white,colors.cyan,"Program",colors.black)
          elseif string.find(f_file[i],".java",string.len(f_file[i]) - 5) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,40,fy,colors.white,colors.cyan,"Java Class",colors.black)
          elseif string.find(f_file[i],".class",string.len(f_file[i]) - 6) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,40,fy,colors.white,colors.cyan,"Java Class",colors.black)
          elseif string.find(f_file[i],".zip",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,40,fy,colors.white,colors.cyan,"ZIP Archive",colors.black)
          elseif string.find(f_file[i],".axp",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,40,fy,colors.white,colors.cyan,"Axiom Program",colors.red)
          elseif string.find(f_file[i],".cmd",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,40,fy,colors.white,colors.cyan,"Command",colors.green)
          elseif string.find(f_file[i],".axs",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,40,fy,colors.white,colors.cyan,"Sys",colors.red)
          else
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            --Fedge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(42,fy,40,fy,colors.white,colors.cyan,"File",colors.black)
          end
        end
      end
      fy = fy+1
    end
    --edge.render(7,fy,7,fy,colors.white,colors.cyan,file[i],colors.black,false)
  end

  while(true) do
    --for i=1, #file do
      --edge.render(5,fy,5,fy,colors.white,colors.cyan,file[i],colors.black,false)
    --  fy = fy+1
  --  end
    event, button, x, y = os.pullEvent("mouse_click")

    if x >= 1 and x <= 4 and y == 1 and button == 1 then
      edge.render(1,1,4,1,colors.gray,colors.cyan,"O",colors.white,false)
      edge.render(1,2,10,10,menubarColor,colors.cyan,"",colors.white,true)

      edge.render(1,2,10,2,menubarColor,colors.cyan,"   Menu   ",colors.black,false)
      edge.render(1,3,10,3,menubarColor,colors.cyan,"Update",colors.black,false)
      edge.render(1,4,10,4,menubarColor,colors.cyan,"Settings",colors.black,false)
      edge.render(1,5,10,5,menubarColor,colors.cyan,"Files",colors.black,false)
      edge.render(1,6,10,5,menubarColor,colors.cyan,"Terminal",colors.black,false)
      edge.render(1,7,10,7,menubarColor,colors.cyan,"Logout",colors.black,false)
      edge.render(1,8,10,8,menubarColor,colors.cyan,"Reboot",colors.black,false)
      edge.render(1,9,10,9,menubarColor,colors.cyan,"Shut down",colors.black,false)
      edge.render(1,10,10,10,menubarColor,colors.cyan,"About",colors.black,false)
      while(true) do
        local event, button, x, y = os.pullEvent("mouse_click")
        if x >= 10 and y >= 1 or x >= 1 and y >= 11 or x >= 1 and x <= 4 and y == 1 then
          files = setting.getVariable("Axiom/settings.0","fexplore_startdir")
          filebrowser()

        end
        if event == "terminate" then
          main_gui()
        end
        if x >= 1 and x <= 10 and y == 3 then
          edge.render(1,3,10,3,menubarColor,colors.cyan,"Updating..",colors.black,false)
          execUpd()
        end
        if x >= 1 and x <= 10 and y == 4 then
          --next.newTask("Axiom/programs/settings")
          settings_gui()
        end
        if x >= 1 and x <= 10 and y == 6 then
          fs.delete("safeStart")
          fs.move("startup","ax")
          a = fs.open("startup","w")
          a.writeLine("shell.run('clear')")
          a.writeLine("print('Type ax to go back to Axiom')")
          a.close()
          os.reboot()
        end
        if x >= 1 and x <= 10 and y == 5 then
          files = setting.getVariable("Axiom/settings.0","fexplore_startdir")
          filebrowser()
        end
        if x >= 1 and x <= 10 and y == 7 then
          shell.run("clear")
          state = "loginscreen"
          login_gui()
        end
        if x >= 1 and x <= 10 and y == 8 then
          if setting.getVariable("Axiom/settings.0","first_update") == "false" and setting.getVariable("Axiom/settings.0","licensed") == "true" then
            setting.setVariable("Axiom/settings.0","first_update","true")
            edge.render(1,1,mx,19,colors.cyan,colors.cyan,"",colors.black,false)
            edge.render(16,7,34,12,colors.white,colors.cyan,"",colors.black,true)
            edge.render(17,8,34,8,colors.white,colors.cyan,"Axiom is updating ",colors.black,false)
            edge.render(17,10,34,10,colors.white,colors.cyan,"  Please wait.",colors.black,false)
            execUpd()
            os.reboot()
          end
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
          if setting.getVariable("Axiom/settings.0","first_update") == "false" and setting.getVariable("Axiom/settings.0","licensed") == "true" then
            setting.setVariable("Axiom/settings.0","first_update","true")
            edge.render(1,1,mx,19,colors.cyan,colors.cyan,"",colors.black,false)
            edge.render(16,7,34,12,colors.white,colors.cyan,"",colors.black,true)
            edge.render(17,8,34,8,colors.white,colors.cyan,"Axiom is updating ",colors.black,false)
            edge.render(17,10,34,10,colors.white,colors.cyan,"  Please wait.",colors.black,false)
            execUpd()
            os.shutdown()
          end
          os.shutdown()
        end
      end
    end
    if event == "terminate" then
      files = setting.getVariable("Axiom/settings.0","fexplore_startdir")
      tasks.filebrowser = false
      --menubarColor = colors.white
      main_gui()
    end
    if x == 45 and y == 2 and button == 1 then
      files = setting.getVariable("Axiom/settings.0","fexplore_startdir")
      tasks.filebrowser = false
      --menubarColor = colors.white
      main_gui()
    end
    if x == 43 and y == 2 and button == 1 then
      tasks.filebrowser = false
      --menubarColor = colors.white
      main_gui()
    end
    if x >= 42 and y == 3 and x <= 45 and y == 3 then
      edge.log("F:"..fs.getDir(files))
      if fs.getDir(files) == ".." then
      else
        files = "/"..fs.getDir(files).."/"
        filebrowser()
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
      if not fs.exists(files..input) then
        fs.makeDir(files..input)
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
        filebrowser()
      else
        if not fs.exists(files..input) then
          local a = fs.open(files..input,"w")
          a.close()
          edge.log("Created file: "..files..input)
          filebrowser()
        else
          filebrowser()
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
      if not fs.exists(files..input) then
        filebrowser()
      end
      if input ~= "" then
        if not string.find(input,".axs",string.len(input) - 4) or not string.find(input,".0",string.len(input) - 2) then
          if fs.exists(files..input) then
            term.setBackgroundColor(colors.cyan)
            term.setTextColor(colors.white)
            fs.delete(files..input)
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
        local fl = fs.list(files.."/")
        for k,v in ipairs(fl) do
          if fs.exists(files..fl[k]) then
            fs.delete(files..fl[k])
            edge.log("Deleted file: "..files..fl[k])
          else
            edge.log("Delete failed: "..files..input)
          end
        end
      else
        edge.log("User entered nothing")
      end
      filebrowser()
    end
    if button == 1 and event == "mouse_click" then
      for i=1, #f_file do
        if x > 2 and x <= 23 and y == 5+i then
          if fs.isDir(files..f_file[i]) and f_file[i] ~= "rom" then
            previousDir = files
            files = files..""..f_file[i].."/"
            filebrowser()
          else
            tasks.settings_app = true
            term.setBackgroundColor(colors.black)
            if not fs.exists("home/prg/luaide.app") then
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
          --print(tostring(fs.isDir(files..f_file[i]))..":"..files..f_file[i])
          --print(files)
          --print(f_file[i])
          if fs.isDir(files..f_file[i]) then

          else
            if files..f_file[i] == "startup" then
              error("An instance of Axiom is already running")
            else
              if not fs.exists(files..f_file[i]) then
                error("File not found")
              else
                if string.find(files..f_file[i],".app",string.len(f_file[i]) - 4) or string.find(files..f_file[i],".lua",string.len(f_file[i]) - 4) or string.find(files..f_file[i],".cmd",string.len(f_file[i]) - 4) or string.find(files..f_file[i],".axp",string.len(f_file[i]) - 4) then
                  menubarColor = colors.white
                  edge.render(1,1,51,1,menubarColor,colors.cyan,"O",colors.black,false)
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
function firstTimeSetup()
  tasks.clock = false
  edge.render(1,1,mx,19,colors.cyan,colors.cyan,"",colors.black,false)
  edge.render(16,7,34,12,colors.white,colors.cyan,"",colors.black,true)
  edge.render(17,8,34,8,colors.white,colors.cyan,"Welcome to Axiom!",colors.black,false)
  edge.render(17,10,34,10,colors.white,colors.cyan,"  Please wait..",colors.black,false)
  if http then
    olicense = http.get("http://www.pastebin.com/raw/RYKHrp1c")
  else
    olicense = [[By using this software you agree to:
  - Not modify the operating system
  - Under no circumstances what so ever;
    Redistribute the system files or any contents
    of the system.
  - Not using any parts of the system in
    assistance to create malicious software.
  - Full license can be found on the computercraft
    forum page.
  - Have a good time with Axiom
  ]]
  end
  sleep(1)
  edge.render(1,1,mx,19,colors.white,colors.cyan,"",colors.black,false)
  --edge.render(4,2,48,17,colors.white,colors.cyan,"",colors.black,false)
  edge.render(4,3,4,3,colors.white,colors.cyan,"Axiom Setup: Step 1 of 4",colors.black,false)
  edge.render(4,5,48,15,colors.white,colors.cyan,olicense.readAll(),colors.black)
  sleep(6)
  edge.render(6,18,48,18,colors.white,colors.cyan,"Left click: Agree, Right click: Disagree",colors.black)
  local event, button, x, y = os.pullEvent("mouse_click")
  if button == 1 then
    setting.setVariable("Axiom/settings.0","licensed","true")
    edge.render(1,1,mx,19,colors.cyan,colors.cyan,"",colors.black,false)
    sleep(1)
    edge.render(4,2,48,17,colors.white,colors.cyan,"",colors.black,true)
    edge.render(4,3,4,3,colors.white,colors.cyan,"Axiom Setup: Step 2 of 4",colors.black,false)
    edge.render(7,6,48,6,colors.white,colors.cyan,"Verifying the file system, please wait.",colors.black)
    local fileList = fs.list("/")
    local loaded = 0
    local toLoad = #fileList
    for _, file in ipairs(fileList) do
      if file == "virus" or file == "installer" or file == "override" or file == "construct.lua" or file == "format" or file == "system" or file == "installLog.txt" then
        fs.delete(file)
        edge.render(4,2,48,17,colors.white,colors.cyan,"",colors.black,true)
        edge.render(4,3,4,3,colors.white,colors.cyan,"Axiom Setup: Step 2 of 4",colors.black,false)
        edge.render(7,6,48,6,colors.white,colors.cyan,"Verifying the file system, please wait.",colors.black)
        --edge.render(midx - string.len("Disallowed file detected, removing") / 2,8,48,8,colors.white,colors.cyan,"Disallowed file detected, removing",colors.orange)
        edge.render(midx - string.len("File"..loaded.." of "..toLoad.." verified.") / 2,8,48,8,colors.white,colors.cyan,"File "..loaded.." of "..toLoad.." verified.",colors.black)
      else
        x, y = term.getSize()
        midx = x / 2
        --edge.render(4,2,48,17,colors.white,colors.cyan,"",colors.black,true)
        --edge.render(4,3,4,3,colors.white,colors.cyan,"Axiom Setup: Step 1 of 3",colors.black,false)
        --edge.render(7,6,48,6,colors.white,colors.cyan,"Verifying the file system, please wait.",colors.black)
        edge.render(midx - string.len("File"..loaded.." of "..toLoad.." verified.") / 2,8,48,8,colors.white,colors.cyan,"File "..loaded.." of "..toLoad.." verified.",colors.black)
        loaded = loaded + 1
        sleep(0.12)
      end
      --print("Loaded: os/libraries/"..file)
    end
    edge.render(4,2,48,17,colors.white,colors.cyan,"",colors.black,true)
    edge.render(4,3,4,3,colors.white,colors.cyan,"Axiom Setup: Step 3 of 4",colors.black,false)
    edge.render(5,6,48,6,colors.white,colors.cyan,"            What is your name?",colors.black)
    edge.render(20,9,30,9,colors.lightGray,colors.cyan,"",colors.gray)
    term.setTextColor(colors.black)
    term.setBackgroundColor(colors.lightGray)
    term.setCursorPos(20,9)
    local newUsername = io.read()
    edge.render(4,3,4,3,colors.white,colors.cyan,"Axiom Setup: Final step ",colors.black,false)
    edge.render(5,6,48,6,colors.white,colors.cyan,"         Now, enter a good password!",colors.black)
    edge.render(20,9,30,9,colors.lightGray,colors.cyan,"",colors.gray)
    term.setTextColor(colors.black)
    term.setBackgroundColor(colors.lightGray)
    term.setCursorPos(20,9)
    local newPassword = read("*")
    if newPassword == "" or newPassword == nil then
      newPassword = "nopass"
    end
    fs.makeDir("/users/apis")
    setting.setVariable("Axiom/settings.0","username",encryption.sha256(newUsername.."QxLUF1bgIAdeQX"))
    setting.setVariable("Axiom/settings.0","password",encryption.sha256(newPassword.."QxLUF1bgIAdeQX"))
    l = fs.open("/users/"..newUsername,"w")
    l.writeLine(encryption.sha256(newPassword .."QxLUF1bgIAdeQX"))
    l.close()
    os.setComputerLabel(newUsername)
    newPassword = nil
    newUsername = nil
    term.setBackgroundColor(colors.cyan)
    os.reboot()
  else
    local list = fs.list("/")
    for _, file in ipairs(list) do
      if file == "rom" then

      else
        if not file == "Axiom" or file ~= "startup" then

        else
          fs.delete(file)
        end
      end
    end
    os.reboot()
  end
end
function initialize()
  log("usr "..tostring(setting.getVariable("Axiom/setting.8","username")))
  if setting.getVariable("Axiom/settings.0","username") == false then
    firstTimeSetup()
  else
    edge.log("User already has account")
  end

  login_gui()
  --parallel.waitForAll(login_gui,notifHandler,taskHandler,eventHandler)
end
function cprint( text, y )
  local x = term.getSize()
  local centerXPos = ( x - string.len(text) ) / 2
  term.setCursorPos( centerXPos, y )
  write( text )
end
function safeboot()
  if shell.getRunningProgram() == "startup" then
    error("Invalid session: cannot be run as startup")
  end
  tasks.kernel = true

  os.loadAPI("Axiom/libraries/edge")

  os.loadAPI("Axiom/libraries/next")
  os.loadAPI("Axiom/libraries/setting")
  os.loadAPI("Axiom/libraries/encryption")
  if setting.getVariable("Axiom/settings.0","dev") == "true" then
    term.setBackgroundColor(colors.white)
    term.setTextColor(colors.black)
  else
    term.setBackgroundColor(colors.cyan)
    term.setTextColor(colors.white)
  end
  shell.run("clear")
  if setting.getVariable("Axiom/settings.0","system_skipsys_scan") == "false" then
    for k,v in ipairs(allfiles) do
      if fs.exists(allfiles[k]) then
        edge.log(allfiles[k].." OK")
      else
        sleep(0.1)
        edge.log(allfiles[k].." MISSING")
        fixNeeded = true
      end
    end
  end
  local http_safe_conn = setting.getVariable("Axiom/settings.0","http_safe_conn")
  if http_safe_conn == "true" then
    httpsec = "https"
  else
    httpsec = "http"
  end
  if not fs.exists("Axiom/images/"..setting.getVariable("Axiom/settings.0","general_background_name")..".axg") then
    if not setting.getVariable("Axiom/settings.0","general_background_name") == "black" then
      setting.setVariable("Axiom/settings.0","general_background_name","default")
    end
  end
  --cprint("A X I O M",9)
  cprint(".        ",(my/2)+1)
  sleep(0.1)
  cprint(" .       ",(my/2)+1)
  sleep(0.1)
  cprint("  .      ",(my/2)+1)
  sleep(0.1)
  cprint("   .     ",(my/2)+1)
  sleep(0.1)
  cprint("    .    ",(my/2)+1)
  sleep(0.1)
  cprint("     .   ",(my/2)+1)
  sleep(0.1)
  cprint("      .  ",(my/2)+1)
  sleep(0.1)
  cprint("       . ",(my/2)+1)
  sleep(0.1)
  cprint("        .",(my/2)+1)
  sleep(0.1)
  cprint(".       .",(my/2)+1)
  sleep(0.2)
  cprint("  .   .  ",(my/2)+1)
  sleep(0.2)
  cprint("    .    ",(my/2)+1)
  sleep(0.3)
  cprint("    I    ",(my/2))
  cprint("    .    ",(my/2)+1)
  sleep(0.2)
  cprint("  X I O  ",my/2)
  cprint("  . . .  ",(my/2)+1)
  sleep(0.2)
  cprint("A X I O M",my/2)
  cprint(". . . . .",(my/2)+1)
  sleep(0.2)
  cprint("A X I O M",my/2)
  cprint(". . . . .",(my/2)+1)
  if setting.getVariable("Axiom/settings.0","system_allow_apis") == "true" then
    local dir = setting.getVariable("Axiom/settings.0","api_dir")
    local fileList = fs.list(setting.getVariable("Axiom/settings.0","api_dir"))
    for _, api in ipairs(fileList) do
      edge.log("Loaded api: "..api.. " from "..dir)
      os.loadAPI(dir.."/"..api)
      sleep(0.2)
    end
    edge.log("Loaded custom apis.")
  end
  latestversion = http.get("http://www.nothy.se/Axiom/CurrentUpdate")
  announcement = http.get("http://www.nothy.se/Axiom/Announcement")
  announcement = tostring(announcement.readAll())
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
  sleep(0.2)
  cprint("  X I O  ",my/2)
  cprint("  . . .  ",(my/2)+1)
  sleep(0.2)
  cprint("    I    ",my/2)
  cprint("    .    ",(my/2)+1)
  sleep(0.2)
  cprint("         ",my/2)
  cprint("         ",(my/2)+1)
  edge.log("Initializing")
  sleep(0.1)
  term.setCursorPos(1,1)
  initialize()
end
function bootanimation()
  shell.run("clear")
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)
  if shell.getRunningProgram() == "startup" then
    error("Invalid session: cannot be run as startup")
  end
  if not fs.exists("Axiom/libraries/edge") then
    print("ERROR: Edge Graphics not found. Are you sure you have installed Axiom properly?")
    print("How to install Axiom:")
    print("- Run the following command: pastebin run 2nLQRsSd")
    print("- And wait as Axiom installs.")
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
    if fs.exists(allfiles[k]) then
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

  os.loadAPI("Axiom/libraries/edge")
  print("LOADED: Edge")

  os.loadAPI("Axiom/libraries/next")
  print("LOADED: Next")

  os.loadAPI("Axiom/libraries/setting")
  files = setting.getVariable("Axiom/settings.0","fexplore_startdir")
  print("LOADED: settings")
  os.loadAPI("Axiom/libraries/encryption")
  print("LOADED: encryption")
  print("READING SETTINGS")
  local http_safe_conn = setting.getVariable("Axiom/settings.0","http_safe_conn")
  if http_safe_conn == "true" then
    httpsec = "https"
  else
    httpsec = "http"
  end
  if not fs.exists("Axiom/images/"..setting.getVariable("Axiom/settings.0","general_background_name")..".axg") then
    if not setting.getVariable("Axiom/settings.0","general_background_name") == "black" then
      setting.setVariable("Axiom/settings.0","general_background_name","default")
    end
  end
  --cprint("A X I O M",9)
  if setting.getVariable("Axiom/settings.0","system_allow_apis") == "true" then
    local dir = setting.getVariable("Axiom/settings.0","api_dir")
    local fileList = fs.list(setting.getVariable("Axiom/settings.0","api_dir"))
    for _, api in ipairs(fileList) do
      print("LOADED: "..dir.."/"..api)
      os.loadAPI(dir.."/"..api)
      sleep(0.2)
    end
    print("Loaded custom apis.")
  end
  print("Determining latest version.")
  if latestversion == nil then
    print("Error determining version.")
    latestversion = version
  else
    print("Server cannot determine version")
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
  print("Initializing Axiom Server 2016")
  sleep(1)
  term.setCursorPos(1,1)
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
log("SYSTEM: Starting services..")
tasks.kernel = true
tasks.permngr = true
shell.run("clear")
if fs.exists("safeStart") then
  safe = false
  term.setBackgroundColor(colors.black)
  shell.run("clear")
  term.setTextColor(colors.white)
  --paintutils.drawLine(1,my/2,mx,my/2,colors.blue)
  term.setBackgroundColor(colors.blue)
  term.setCursorPos(1,1)
  print("[AXIOM BOOT MANAGER]")
  term.setBackgroundColor(colors.black)
  print("Please select a mode for Axiom to run in")
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
        if fs.exists("Axiom/settings.0") and fs.exists("Axiom/backup/os/settings.0") then
          fs.delete("Axiom/settings.0")
          fs.move("Axiom/backup/os/settings.0","Axiom/settings.0")
        end
        fs.delete("safeStart")
        bootanimation()
      else
        if craftos == true then
          fs.delete("safeStart")
          fs.move("startup","ax")
          a = fs.open("startup","w")
          a.writeLine("print('Type ax to go back to Axiom')")
          a.close()
          os.reboot()
        else
          print("Attempting to boot safely.")
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
if fs.exists("Axiom/.devmode") and unreleased == true then
  term.setTextColor(colors.white)
  shell.run("clear")
  sleep(0.2)
  print("Axiom developer mode enabled")
  print("Unreleased features enabled")
end
if fs.exists("Axiom/settings") == true and fs.exists("Axiom/settings.0") == false then
  fs.copy("Axiom/settings","Axiom/settings.0")
  fs.delete("Axiom/settings")
  print("Settings file has been updated to support "..version)
  sleep(1)
end
if fs.exists("firstBoot") then
  fs.delete("firstBoot")
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
end
