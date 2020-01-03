
--local apiErrors = {}

local appversion = "1.1"
local theme_topbar = colors.green -- green
local theme_ui = colors.lime --lime
local allow_background_change = true
local scales = {0.5,1,1.5,2,2.5,3,3.5,4,4.5,5}
local sides = {"front","back","left","right","top","bottom"}
local currentUser = _G.currentUser
local selectedScale = edge.getScaleIndex()
local selectedScale_emu = 4
-- if os.version() == "CraftOS 1.8" and not setting then
--   appversion = appversion.." (CC 1.8 mode)"
--   productName = "Axiom UI"
--   version = "4.0"
--   version_sub = "nightly "
--
--   apiErrors = {}
--   os.loadAPI("Axiom/libraries/setting")
--
--   setting.loadsettings("Axiom/settings.0")
--   for k,v in pairs(setting.variables.users) do
--     if k ~= "KERNEL" then
--       currentUser = k
--       break
--     end
--   end
--   -- Forcibly load settings from file
-- end
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
    setting.writesettings()
    if not adduser then
      if not fs.exists("home/Desktop/files.lnk") then
        edge.render(1,b-1,1,b-1,colors.white,colors.cyan,"Creating additional desktop icons.. 1/3",colors.lightGray)
        local fh = fs.open("home/Desktop/files.lnk","w")
        fh.write("Axiom/programs/explorer.app")
        fh.close()
        edge.render(1,b-1,1,b-1,colors.white,colors.cyan,"Creating additional desktop icons.. 2/3",colors.lightGray)
        local fh2 = fs.open("home/Desktop/settings.lnk","w")
        fh2.write("Axiom/programs/settings.app")
        fh2.close()
        edge.render(1,b-1,1,b-1,colors.white,colors.cyan,"Creating additional desktop icons.. 3/3",colors.lightGray)
        local fh2 = fs.open("home/Desktop/store.lnk","w")
        fh2.write("Axiom/programs/stdgui.app")
        fh2.close()
        edge.render(1,b-1,1,b-1,colors.white,colors.cyan,"Creating additional desktop icons.. OK ",colors.lightGray)
        sleep(1)
        local mx = term.getSize()
        edge.render(1,b-1,mx,b-1,colors.white,colors.cyan,"",colors.lightGray)
        local fmsg = "Fetching additional files..                    "
        edge.render(1,b-1,1,b-1,colors.white,colors.cyan,fmsg,colors.lightGray)
        execUpd()
      end
      os.reboot()
    end
    return true
  end
end
function writesettings()
  local vars = setting.variables
  --print(textutils.serialise(vars))
  local s = textutils.serialise(vars)
  local fh = fs.open("Axiom/settings.bak","w")
  fh.write(s)
  fh.close()
end
function firstTimeSetupNew(adduser)
  if not adduser then adduser = false end

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
        edge.windowAlert(20,10, "Error: Username too short.", true, colors.red)
        edge.render(1,4,a,b,colors.white,colors.cyan,"",colors.white)
        edge.render(15,8,a-15,8,colors.lightGray,colors.lightGray,""..username,colors.gray)
        username = read()
      end
      while(string.lower(username) == "kernel" or setting.variables.users[username] ~= nil) do 

          edge.windowAlert(20,10, "Error: Username unavailable.", true, colors.red)
          edge.render(1,4,a,b,colors.white,colors.cyan,"",colors.white)
          -- pick username(?)
          edge.render(12,6,a,6,colors.white,colors.cyan,"Enter your desired username ",colors.gray)
          edge.render(15,8,a-15,8,colors.lightGray,colors.lightGray,""..username,colors.gray)
          username = read()
  
      end
      if not adduser then
        if unreleased then
          os.setComputerLabel("Axiom "..version.." "..version_sub)
        else
          os.setComputerLabel("Axiom PC: "..username)
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
function settings_draw(page)
  if not page then
    page = "main"
  end
  local mx, my = term.getSize()
  local categories = {         -- Network (formerly)
    "General", "Account", "Edge","Updates","API","About"
  }
  --edge.render(1,2,mx,2,theme_ui,colors.cyan,page,colors.white)
  local curX = 2
  edge.render(1,3,mx,3,theme_ui,colors.cyan,"",colors.black)
  edge.render(1,4,2,4,theme_ui,colors.cyan,"",colors.gray)
  local character = "|"
  for k,v in ipairs(categories) do
    edge.render(curX,4,curX+string.len(v),4,theme_ui,colors.cyan,v.." "..character.." ",colors.gray)
    curX = curX + string.len(v)+3
  end
  edge.render(mx,4,mx,4,theme_ui,colors.cyan,"",colors.black)
  --edge.render(10, 4,10+string.len("Account"),4,theme_ui,colors.cyan,"Account",colors.white)
  if page == "main" then
    local warnText = "  "
    edge.render((mx/2)-(string.len(productName)/2),my/2,(mx/2)-(string.len(productName)/2),my/2,colors.white,colors.cyan,productName,colors.gray)
    if os.version() == "CraftOS 1.8" then
      edge.render((mx/2)-(string.len(warnText)/2),(my/2)+1,(mx/2)-(string.len(warnText)/2),(my/2)+1,colors.white,colors.cyan,warnText,colors.red)
    end
  end

  if page == "general" then
    local bg = fs.list(edge.imageDir)
    local bg_y = 6
    edge.render(1,5,mx,my,colors.white,colors.cyan,"",colors.white)
    edge.render(1,4,8,4,theme_topbar,colors.cyan," General ",colors.white)
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
    --edge.render(2,bg_y+5,24,bg_y+5,colors.white,colors.cyan,"(Feature is work in progress)",colors.gray,false)
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
    edge.render(11,4,19,4,theme_topbar,colors.cyan," Account ",colors.white)
    if setting.variables.users[currentUser].superuser == true or hasRootAccess then
      edge.render(3,6,15,6,colors.white,colors.cyan,"Add new user account",colors.gray)
    else
      edge.render(3,6,15,6,colors.white,colors.cyan,"Add new user account",colors.lightGray)
    end
    if setting.variables.users[currentUser].superuser == true or hasRootAccess then
      if setting.variables.temp.restore_legacy_login then
        edge.render(3,8,15,8,colors.green,colors.cyan,"Restore legacy login",colors.white)
      else
        edge.render(3,8,15,8,colors.white,colors.cyan,"Restore legacy login",colors.gray)
      end
    end
    if setting.variables.users[currentUser].superuser == true or hasRootAccess then
      if setting.variables.temp.enable_guest_login then
        edge.render(3,10,15,10,colors.green,colors.cyan,"Enable guest account",colors.white)
      else
        edge.render(3,10,15,10,colors.white,colors.cyan,"Enable guest account",colors.gray)
      end
    end
    edge.render(27,5,50,5,colors.white,colors.cyan,"Modify users:",colors.gray)
    if setting.variables.users[currentUser].superuser == true or hasRootAccess then
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
    local explabel = "Prototype"
    edge.render(1,5,mx,my,colors.white,colors.cyan,"",colors.white)
    edge.render(21,4,26,4,theme_topbar,colors.cyan," "..categories[3].." ",colors.white)
    edge.render((mx/2)-(string.len(explabel)/2),5,(mx/2)-(string.len(explabel)/2),5,colors.white,colors.cyan,explabel,colors.red)
    if edge.hasScreen() then
      edge.render(2,6,2+string.len("Screen settings"),6,colors.white, colors.white, "Screen settings",colors.gray,false)
    else
      edge.render(2,6,2+string.len("no screen connected"),6,colors.white, colors.white, "No screen connected",colors.lightGray,false)
    end

    edge.render(2,9,2+string.len("Screen scale"),9,colors.white,colors.white,"Screen scale", colors.gray,false)
    edge.render(3,10,2+string.len(" -      + "),10, colors.lightGray,colors.lightGray," -      + ",colors.black)
    if cclite then
      edge.render(20,9,20+string.len("Emulator Window Scale"),9,colors.white,colors.white,"Emulator Window Scale", colors.gray,false)
      edge.render(21,10,21+string.len(" -      + "),10, colors.lightGray,colors.lightGray," -      + ",colors.black)
    end
    if string.len(scales[selectedScale]) < 2 then
      edge.render(8,10,8+string.len(scales[selectedScale]),10,colors.lightGray,colors.lightGray,scales[selectedScale],colors.black)
    else
      edge.render(6,10,6+string.len(scales[selectedScale]),10,colors.lightGray,colors.lightGray,scales[selectedScale],colors.black)
    end

    if edge.getScreen() == nil then
      edge.render(2,14,2+string.len("Available screens"),14, colors.white, colors.gray,"Available screens",colors.gray)
      local success = false
      local c = 0
      for k,v in ipairs(sides) do
        if peripheral.isPresent(v) then
          if peripheral.getType(v) == "monitor" then
            success = true
            edge.render(2,15+c,2+string.len(k.." "..v),15+c,colors.white,colors.white,"[#"..k.."] "..v,colors.black)
            edge.render(20,15+c,20+string.len(" Connect"),15+c,colors.lime,colors.white," Connect",colors.white)
            c = c + 1
          end
        end
      end
      if not success then
        edge.render(2,16,2+string.len("None available"),16,colors.white,colors.white, "None available",colors.black)
      end
    else
      edge.render(2,12,2+string.len("Disconnect screen"),12,colors.lightGray, colors.gray,"Disconnect screen", colors.gray)
    end

  end
  if page == "updates" then
    edge.render(1,5,mx,my,colors.white,colors.cyan,"",colors.white)
    edge.render(28,4,36,4,theme_topbar,colors.cyan," Updates ",colors.white)
    if setting.variables.temp.autoupdate == true then
      edge.render(2,6, 17, 6, colors.green, colors.cyan, " Auto update", colors.white)
    else
      edge.render(2,6,17,6,colors.white,colors.cyan, " Auto update", colors.black)
    end

  end
  if page == "api" then
    edge.render(1,5,mx,my,colors.white,colors.cyan,"",colors.white)
    edge.render(38,4,42,4,theme_topbar,colors.cyan," API ",colors.white)
    --edge.render((mx/2)-(string.len("Feel free to suggest what to put here!")/2),my/2,(mx/2)-(string.len("Feel free to suggest what to put here!")/2),my/2,colors.white,colors.cyan,"Feel free to suggest what to put here!",colors.lightGray)
    if setting.variables.users["KERNEL"].allow_apis then
      edge.render(27,6,45,6,colors.green,colors.cyan,"Allow custom APIs",colors.white ,false)
      edge.render(mx-string.len("Located in: "..setting.variables.temp.api_dir),7,45,7,colors.white,colors.cyan,"Located in: "..setting.variables.temp.api_dir,colors.lightGray)
      edge.render(27,8,45,8,colors.white,colors.cyan,"Get APIs from Pastebin",colors.gray)
      if not fs.exists(setting.variables.temp.api_dir) then
        fs.makeDir(setting.variables.temp.api_dir)
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
      	for _, file in ipairs(fs.list(path)) do
      		local path = fs.combine(path, file)
      		if (file ~= thisProgram) and (not fs.isReadOnly(file)) then
      			local guud = true
      			for a = 1, #excludeFiles do
      				if excludeFiles[a] == file then
      					guud = false
      					break
      				end
      			end
      			if guud then
      				if fs.isDir(path) then
      					listAll(path, files, noredundant, excludeFiles)
      				else
      					table.insert(files, path)
      				end
      			end
      		end
      	end
      	if noredundant then
      		for a = 1, #files do
      			if fs.isDir(tostring(files[a])) then
      				if #fs.list(tostring(files[a])) ~= 0 then
      					table.remove(files,a)
      				end
      			end
      		end
      	end
      	return files
      end


    local  function getAllSpace(path)
      local freespace = fs.getFreeSpace(path or "")
      local filetree = listAll(path or "",{},false,ignoreFolders)
      for a = 1, #filetree do
        if not fs.isDir(filetree[a]) then
          freespace = freespace + fs.getSize(filetree[a])
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
    edge.render(44,4,50,4,theme_topbar,colors.cyan," About ",colors.white)
    edge.render(2,6,mx-2,6,colors.white,colors.cyan,productName.." "..version.." "..version_sub,colors.gray)
    edge.render(2,7,mx-2,7,colors.white,colors.cyan,"Current user: "..setting.variables.users[currentUser].displayName.." debugID: "..setting.variables.temp.debugID,colors.gray)
    edge.render(2,8,mx-2,8,colors.white,colors.cyan,"App Version "..appversion,colors.gray)
    if setting.variables.temp.installDate ~= nil then
      -- if os.day()-setting.variables.temp.installDate > 31 then
      --   edge.render(2,8,mx-2,8,colors.white,colors.cyan,"LunarOS Available.",colors.green)
      --   edge.render(2,9,13,9,colors.lightGray,colors.cyan," Learn More",colors.gray)
      -- else
      --   edge.render(2,8,mx-2,8, colors.white, colors.cyan, "ip: "..ip_processed, colors.gray)
      -- end
    else
      setting.variables.temp.installDate = os.day()
      setting.writesettings()
      --edge.render(2,8,mx-2,8,colors.white,colors.cyan,"Not elegible for LunarOS TESTING",colors.gray)
    end

    edge.render(2,10,2,10,colors.white,colors.cyan,"Storage devices",colors.lightGray)
    edge.render(2,12,mx-2,12,colors.lightGray,colors.cyan,"",colors.white)
    local f = fs.list("/")
    local freeSpace = fs.getFreeSpace("/")
    local totalSize = 0
    for k,v in ipairs(f) do
      totalSize = totalSize + fs.getSize(v)
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
          local f = fs.list(disk.getMountPath(b))
          local freeSpace = fs.getFreeSpace(disk.getMountPath(b))
          local totalSize = 0
          for k,v in ipairs(f) do
            totalSize = totalSize + fs.getSize(disk.getMountPath(b).."/"..v)
          end
          totalSize = getAllSpace(disk.getMountPath(b))
          local percentUsed = ((totalSize-freeSpace)/totalSize)
          local label = disk.getLabel(b)
          local bootStatus = ""
          if fs.exists(disk.getMountPath(b).."/startup") then bootStatus = "(Bootable)" end
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
  -- if page == "about-mt" then
  --   local function textCenter(y, text)
  --     local tLength = string.len(text)
  --     local tLengthHalf = tLength/2
  --     local mx,my = term.getSize()
  --     edge.render((mx/2)-(tLengthHalf),y,(mx/2)+(tLengthHalf),y,colors.white,colors.white,text,colors.black,false)
  --   end
  --   local function textCenterButton(y, text,padding)
  --     local tLength = string.len(text)
  --     local tLengthHalf = tLength/2
  --     local mx,my = term.getSize()
  --     local tOffset = mx-(padding*2)
  --     edge.render(15,y,mx-15,y,colors.lightGray,colors.white,string.rep(" ",math.floor((tOffset/2)-tLengthHalf)+1)..text..string.rep(" ",math.floor((tOffset/2)-tLengthHalf)),colors.gray,false)
  --
  --   end
  --   edge.render(1,5,mx,my,colors.white,colors.cyan,"",colors.white)
  --   term.setBackgroundColor(colors.white)
  --   term.setTextColor(colors.gray)
  --   textCenter(6,"What is LunarOS?")
  --   term.setCursorPos(2,8)
  --   term.setBackgroundColor(colors.white)
  --   term.setTextColor(colors.gray)
  --   write("LunarOS is a Multitasking Beta test that you\n are now elegible to use.\n This means that you will be able to take part in\n testing multitasking for LunarOS.")
  --   textCenter(13,"How much does it cost?")
  --   term.setCursorPos(2,14)
  --   term.setBackgroundColor(colors.white)
  --   term.setTextColor(colors.gray)
  --   write("It's free! All you have to do is click the\n download button below.")
  --
  --   textCenterButton(17,"Download",15)
  --   edge.render(2,18,2,18,colors.white,colors.white," (LunarOS collects data for debugging. By downloading you agree with uploading debug data.)",colors.lightGray)
  -- end
end
function getUserIndex(uname)
  local index = 1
  for k,v in pairs(setting.variables.users) do 
    if v.displayName == uname then 
      return index
    else 
      index = index + 1
    end
  end
  
end
function settings_new(startpage)
  local users = {}
  local count = 0
  for k,v in pairs(setting.variables.users) do
    if k ~= "KERNEL" then
      table.insert(users, {
        by = 6+count,
        confirmC = false,
        uname = k,
      })
      count = count +1
    end

  end
  local mx, my = term.getSize()
  local currentpage = "main"
  if startpage then
    currentpage = startpage
  end
  menubarColor = theme_topbar
  edge.render(1,1,mx,1,theme_topbar,colors.cyan," o*",colors.gray,false)
  -- if hasRednet then
  --   -- Check signal strength?
  --   if rednetDist < 10 then
  --     edge.render(37,1,37,1,menubarColor,colors.cyan,"¤>>>" ,colors.gray,false)
  --   elseif rednetDist > 10 and rednetDist < 20 then
  --     edge.render(37,1,37,1,menubarColor,colors.cyan,"¤>>" ,colors.gray,false)
  --   elseif rednetDist > 20 and rednetDist < 100 then
  --     edge.render(37,1,37,1,menubarColor,colors.cyan,"¤>" ,colors.gray,false)
  --   elseif rednetDist > 100 and rednetDist < 200 then
  --     edge.render(37,1,37,1,menubarColor,colors.cyan,"¤" ,colors.gray,false)
  --   elseif rednetDist > 200 then
  --     edge.render(37,1,37,1,menubarColor,colors.cyan,"¤x",colors.gray,false)
  --   end
  -- else
  --   edge.render(37,1,37,1,menubarColor,colors.cyan,"¤x",colors.red,false)
  -- end
  edge.render(1,2,mx,my,colors.white,colors.cyan,"",colors.black)
  edge.render(1,2,mx,4,theme_ui,colors.cyan,"",colors.black)
  edge.render(mx-2,2,mx-2,2,theme_ui,colors.cyan,"x",colors.red)
  settings_draw(currentpage)
  while true do

    local event, button, x,y = os.pullEvent("mouse_click")
    if x == mx-2 and y == 2 or event == "terminate" then
      setting.writesettings()
      break
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

      if setting.variables.users[currentUser].superuser or hasRootAccess then
        edge.render(3,6,15,6,colors.white,colors.cyan,"Add new user account",colors.gray)
        if x >= 3 and x <= 15 and y == 6 then
          firstTimeSetupNew(true)
          edge.render(1,1,mx,1,menubarColor,colors.cyan," o*",colors.gray,false)
          --edge.render(1,2,mx,my,colors.white,colors.cyan,"",colors.black)
          edge.render(1,2,mx,4,colors.lime,colors.cyan,"",colors.black)
          edge.render(mx-2,2,mx-2,2,colors.lime,colors.cyan,"x",colors.red)
          setting.variables = setting.loadsettings("Axiom/settings.bak")
          settings_draw(currentpage)
        end

      else
        edge.render(3,6,15,6,colors.white,colors.cyan,"Add new user account",colors.lightGray)
        if x >= 3 and x <= 15 and y == 6 then
          edge.render(3,7,15,7,colors.white,colors.cyan,"SU required.",colors.red)

        end
      end
      if setting.variables.users[currentUser].superuser or hasRootAccess then
        if x >= 41 and x <= 42  then
          for k,v in pairs(users) do
            if y == users[k].by+1 then
              if users[k] ~= currentUser and users[k] ~= nil  then
                setting.variables.users[v.uname].superuser = not setting.variables.users[v.uname].superuser
                if setting.variables.users[v.uname].superuser then
                  edge.render(41,users[k].by+1,42,users[k].by+1,colors.green,colors.cyan,"SU",colors.white)
                else
                  edge.render(41,users[k].by+1,42,users[k].by+1,colors.red,colors.cyan,"SU",colors.white)
                end
              end
            end

          end

        end
        if x >= 44 and x <= 49 then
          --users = setting.variables.users
          for k,v in pairs(users) do -- TODO: unfuck
            
            if v ~= nil then
              if y == v.by+1 then
                if users[k] ~= currentUser and users[k] ~= nil then
                  if users[k].confirmC == true then
                    edge.render(44,users[k].by+1,49,users[k].by+1,colors.red,colors.cyan,"DELETED",colors.white)              
                    setting.deleteUser(v.uname)
                    local ok = edge.windowAlert(20,10,"A reboot may be required to apply these changes.",true,colors.orange)
                    setting.variables = setting.loadsettings("Axiom/settings.bak")
                    settings_draw(currentpage)
                    -- if not ok then
                    --   sleep(0.2)
                    --   edge.windowAlert(20,10, "You think you can get away that easy? I'll reboot anyway for you :)", true, colors.red)
                    -- end
                    -- edge.render(1,1,mx,my,colors.white,colors.cyan,"",colors.white)
                    -- sleep(0.1)
                    -- edge.render(1,1,mx,my,colors.lightGray,colors.cyan,"",colors.white)
                    -- sleep(0.1)
                    -- edge.render(1,1,mx,my,colors.gray,colors.cyan,"",colors.white)
                    -- sleep(0.1)
                    -- edge.render(1,1,mx,my,colors.black,colors.cyan,"",colors.white)
                    -- sleep(0.1)
                    -- os.reboot()
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
      if edge.aabb(x,y,3,8,20,8) then
        setting.variables.temp.restore_legacy_login = not setting.variables.temp.restore_legacy_login
        if setting.variables.temp.restore_legacy_login then
          edge.render(3,8,15,8,colors.green,colors.cyan,"Restore legacy login",colors.white)
        else
          edge.render(3,8,15,8,colors.white,colors.cyan,"Restore legacy login",colors.gray)
        end
      end
      if edge.aabb(x,y,3,10,20,10) then
        if setting.variables.users[currentUser].superuser then
          setting.variables.temp.enable_guest_login = not setting.variables.temp.enable_guest_login
          if setting.variables.users["GUEST"] == nil then
            setting.addUser("GUEST",encryption.sha256("nopassQxLUF1bgIAdeQX"),"Guest",false)
            setting.writesettings()
          end
          if setting.variables.temp.enable_guest_login then
            edge.render(3,10,15,10,colors.green,colors.cyan,"Enable guest account",colors.white)
          else
            edge.render(3,10,15,10,colors.white,colors.cyan,"Enable guest account",colors.gray)
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
    if currentpage == "boot" then
      if x >= 2 and x <= 19 and y == 12 then
        if edge.windowAlert(20,10,"Are you sure?",false,colors.red) then
          edge.setScreen(nil)
          settings_draw(currentpage)
        end
      end
      if x >= 2 and x <= 4 and y == 10 then
        if selectedScale > 1 then
          selectedScale = selectedScale - 1
          edge.setScale(scales[selectedScale])
          edge.setScaleIndex(selectedScale)
          edge.render(3,10,2+string.len(" -      + "),10, colors.lightGray,colors.lightGray," -      + ",colors.black)
          if string.len(scales[selectedScale]) < 2 then
            edge.render(8,10,8+string.len(scales[selectedScale]),10,colors.lightGray,colors.lightGray,scales[selectedScale],colors.black)
          else
            edge.render(6,10,6+string.len(scales[selectedScale]),10,colors.lightGray,colors.lightGray,scales[selectedScale],colors.black)
          end
        end
      end
      if x >= 9 and x <= 11 and y == 10 then
        if selectedScale < #scales then
          selectedScale = selectedScale + 1
          edge.setScale(scales[selectedScale])
          edge.setScaleIndex(selectedScale)
          edge.render(3,10,2+string.len(" -      + "),10, colors.lightGray,colors.lightGray," -      + ",colors.black)
          if string.len(scales[selectedScale]) < 2 then
            edge.render(8,10,8+string.len(scales[selectedScale]),10,colors.lightGray,colors.lightGray,scales[selectedScale],colors.black)
          else
            edge.render(6,10,6+string.len(scales[selectedScale]),10,colors.lightGray,colors.lightGray,scales[selectedScale],colors.black)
          end

        end
      end
      if cclite then
        if x >= 20 and x <= 20+4 and y == 10 then
          if selectedScale_emu > 1 then
            selectedScale_emu = selectedScale_emu - 1
            cclite.setScale(scales[selectedScale_emu])
            --edge.setScaleIndex(selectedScale_emu)
            edge.render(20,10,20+string.len(" -      + "),10, colors.lightGray,colors.lightGray," -      + ",colors.black)
            if string.len(scales[selectedScale_emu]) < 2 then
              edge.render(20+5,10,20+8+string.len(scales[selectedScale_emu]),10,colors.lightGray,colors.lightGray,scales[selectedScale_emu],colors.black)
            else
              edge.render(20+5,10,20+6+string.len(scales[selectedScale_emu]),10,colors.lightGray,colors.lightGray,scales[selectedScale_emu],colors.black)
            end
          end
        end
        if x >= 20+9 and x <= 20+11 and y == 10 then
          if selectedScale_emu < #scales then
            selectedScale_emu = selectedScale_emu + 1
            cclite.setScale(scales[selectedScale_emu])
            --edge.setScaleIndex(selectedScale_emu)
            edge.render(20,10,20+string.len(" -      + "),10, colors.lightGray,colors.lightGray," -      + ",colors.black)
            if string.len(scales[selectedScale_emu]) < 2 then
              edge.render(20+5,10,20+5+string.len(scales[selectedScale_emu]),10,colors.lightGray,colors.lightGray,scales[selectedScale_emu],colors.black)
            else
              edge.render(20+5,10,20+5+string.len(scales[selectedScale_emu]),10,colors.lightGray,colors.lightGray,scales[selectedScale_emu],colors.black)
            end

          end
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
          if not fs.exists(setting.variables.temp.api_dir) then
            fs.makeDir(setting.variables.temp.api_dir)
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
      local bg = fs.list(edge.imageDir)
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
      -- if x >= 2 and x <= 24 and y == bg_y+8 then
      --   axiom.alert("debug "..tostring(edge.getOverlay()))
      --   if edge.toggleOverlay() then
      --
      --     edge.render(2,bg_y+8,24,bg_y+8,colors.green,colors.cyan,"Debug overlay enabled",colors.white,false)
      --     edge.debugSay("Enabled debug")
      --   else
      --     axiom.alert("debug "..tostring(edge.getOverlay()))
      --     edge.render(2,bg_y+8,24,bg_y+8,colors.red,colors.cyan,"Debug overlay disabled",colors.white,false)
      --     edge.debugSay("Disabled debug")
      --   end
      --   --axiom.alert("debug "..tostring(edge.getOverlay()))
      --   -- if edge.getOverlay() == true then
      --   --   edge.render(2,bg_y+4,24,bg_y+4,colors.green,colors.cyan,"Debug enabled",colors.white,false)
      --   --   edge.debugSay("Enabled debug")
      --   -- else
      --   --   edge.render(2,bg_y+4,24,bg_y+4,colors.red,colors.cyan,"Debug disabled",colors.black,false)
      --   --   edge.debugSay("Disabled debug")
      --   -- end
      -- end
      if x >= 25 and x <= 45 and y == 6 and button == 1 then

        if setting.variables.temp.system_skipsys_scan == true and setting.variables.users[currentUser].superuser then
          setting.variables.temp.system_skipsys_scan = false
        else
          setting.variables.temp.system_skipsys_scan = true
        end
        if setting.variables.temp.system_skipsys_scan then
          if setting.variables.users[currentUser].superuser or hasRootAccess then
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
        edge.windowAlert(25,12, "Telemetry is deprecated. All previous data no longer exists.", true)
        settings_draw(currentpage)
      end
      if x >= 46 and x <= 50 and y == 12 and button == 1 then
        edge.windowAlert(25,12, "Animations are just a nice touch to "..productName..". Disabling animations is a good idea when on a server.", true)
        settings_draw(currentpage)
      end
      if pStat == "forcedOff" and setting.variables.temp.enable_telemetry ~= "forcedOff" then
        setting.variables.temp.enable_telemetry = "forcedOff"
        setting.writesettings()
      end
    end
    if currentpage == "about" then
      if os.day()-setting.variables.temp.installDate > 31 then
        if x >= 2 and x <= 13 and y == 9 then
          currentpage = "about"
          settings_draw(currentpage)
        end
      end
    end
    if currentpage == "about-mt-" then
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
          sleep(0.5)
          textCenterButton(17,"Installing..",padding)
          unreleased = true
          execUpd()
          textCenterButton(17,"Installed.",padding)
        else
          textCenterButton(17,"Connection failed.",padding)
        end
      --textCenterButton(17,"Not yet released",padding)
      end
    end
  end
end
local ok, err = pcall(settings_new)
if not ok then edge.windowAlert(20,10,"Fatal error: "..err,true,colors.red) end