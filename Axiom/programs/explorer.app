
os.loadAPI("Axiom/libraries/setting")
--os.loadAPI("Axiom/libraries/encryption")
local files = "home/"
local hideFiles = true
local previousDir = files
local mx, my = term.getSize()
local appversion = "1.2"
local changes = "Changes:\nHopefully fixed program refusing to exit"
local running = true
local args = {...}
function filebrowser(startDir,select)
  if args[1] ~= nil then
    if args[1] == "select" then
      if args[2] ~= nil then
        if(fs.exists(args[2])) then
          files = args[2]
        end
      end
    end
  end
  if fileselect == true then select = true end
  if not select then
    select = false
  end
  edge.log("file browser started with dir "..tostring(startDir))
  state = "filebrowser"
  menubarColor = colors.green
  --files = setting.variables.users[currentUser].fexplore_startdir
  edge.render(1,1,mx,1,menubarColor,colors.cyan," o*",colors.gray,false)
  edge.render(1,2,mx,2,colors.lime,colors.cyan,"                                          _ x",colors.black,false)
  edge.render(1,4,mx,my,colors.white,colors.cyan,"",colors.black,true)
  edge.render(1,3,mx,4,colors.lime,colors.cyan,"",colors.black,false)
  --edge.render(7,4,7,4,colors.white,colors.cyan,"Files: <Up>",colors.black)
  edge.render(7,3,39,3,colors.white,colors.cyan,os.getComputerID()..":"..files,colors.black)
  edge.render(41,3,41,3,colors.lime,colors.cyan," Back ",colors.black)
  edge.render(7,4,7,4,colors.lime,colors.cyan," New folder   New file   Delete ",colors.black)
  edge.render(2,5,7,5,colors.white,colors.cyan,"| Name |                     | Size |  | Type |",colors.lightGray)
  edge.render(2,3,5,3,colors.lime, colors.cyan,"[?]",colors.gray)
  if not fs.exists(files) then
    f_file = fs.list("/home/")
  else
    if startDir then
      if fs.exists(startDir) then
        files = startDir
      end
    end
    f_file = fs.list(files)
  end


  fy = 6
  foy = 5
  edge.log("listing files")
  for i,v in ipairs(f_file) do

    if fs.isDir(files..f_file[i]) then
      if f_file[i] == "rom" then

      else

        -- if f_file[i]:sub(1,1) == "." and hideFiles then
        --
        -- else
          local l = fs.list(files..f_file[i].."/")
          edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.blue,false)
          edge.render(42,fy,42,fy,colors.white,colors.cyan,"Folder",colors.black)
          edge.render(31,fy,41,fy,colors.white,colors.cyan,#l.." items",colors.black)
        -- end

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
          edge.render(42,fy,45,fy,colors.white,colors.white,"Sys",colors.red)
        elseif f_file[i] == "startup" then
          edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
          edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
          edge.render(40,fy,44,fy,colors.white,colors.cyan,"Bootloader",colors.red)
        else
          if string.find(f_file[i],".lua",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,45,fy,colors.white,colors.cyan,"Lua Script",colors.blue)
          elseif string.find(f_file[i],".js",string.len(f_file[i]) - 3) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,45,fy,colors.white,colors.cyan,"JavaScript",colors.orange)
          elseif string.find(f_file[i],".cs",string.len(f_file[i]) - 3) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,45,fy,colors.white,colors.cyan,"C# Script",colors.red)
          elseif string.find(f_file[i],".xml",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,45,fy,colors.white,colors.cyan,"XML Config",colors.blue)
          elseif string.find(f_file[i],".nfp",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,45,fy,colors.white,colors.cyan,"Image",colors.magenta)
          elseif string.find(f_file[i],".html",string.len(f_file[i]) - 5) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,45,fy,colors.white,colors.cyan,"Webpage",colors.green)
          elseif string.find(f_file[i],".sys",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,45,fy,colors.white,colors.cyan,"System File",colors.black)
          elseif string.find(f_file[i],".dll",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(42,fy,45,fy,colors.white,colors.cyan,"DLL",colors.black)
          elseif string.find(f_file[i],".txt",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,45,fy,colors.white,colors.cyan,"Text File",colors.green)
          elseif string.find(f_file[i],".log",string.len(f_file[i]) - 4) then
            if files..f_file[i] == "Axiom/stacktrace.log" then
              edge.render(20,fy,20,fy,colors.white,colors.cyan,"CRASH LOG",colors.red,false)
            end
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,45,fy,colors.white,colors.cyan,"Log File",colors.green)
          elseif string.find(f_file[i],".cfg",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,45,fy,colors.white,colors.cyan,"Config file",colors.blue)
          elseif string.find(f_file[i],".pref",string.len(f_file[i]) - 5) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(41,fy,45,fy,colors.white,colors.cyan,"Pref",colors.black)
          elseif string.find(f_file[i],".axg",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,45,fy,colors.white,colors.cyan,"Image",colors.magenta)
          elseif string.find(f_file[i],".jar",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(42,fy,45,fy,colors.white,colors.cyan,"Jar",colors.black)
          elseif string.find(f_file[i],".py",string.len(f_file[i]) - 3) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,45,fy,colors.white,colors.cyan,"Python Script",colors.black)
          elseif string.find(f_file[i],".hta",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(42,fy,45,fy,colors.white,colors.cyan,"HTA",colors.black)
          elseif string.find(f_file[i],".cpp",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,45,fy,colors.white,colors.cyan,"C++ Script",colors.black)
          elseif string.find(f_file[i],".app",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,45,fy,colors.white,colors.cyan,"Program",colors.black)
          elseif string.find(f_file[i],".java",string.len(f_file[i]) - 5) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,45,fy,colors.white,colors.cyan,"Java Class",colors.black)
          elseif string.find(f_file[i],".class",string.len(f_file[i]) - 6) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,45,fy,colors.white,colors.cyan,"Java Class",colors.black)
          elseif string.find(f_file[i],".zip",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,45,fy,colors.white,colors.cyan,"ZIP Archive",colors.black)
          elseif string.find(f_file[i],".axp",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,45,fy,colors.white,colors.cyan,productName.." Program",colors.red)
          elseif string.find(f_file[i],".cmd",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,45,fy,colors.white,colors.cyan,"Command",colors.green)
          elseif string.find(f_file[i],".axs",string.len(f_file[i]) - 4) then
            edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
            edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
            edge.render(40,fy,45,fy,colors.white,colors.cyan,"Sys",colors.red)
          else
            -- if not f_file[i]:sub(1,1) == "." and not hideFiles then
              edge.render(2,fy,7,fy,colors.white,colors.cyan,f_file[i],colors.black,false)
              edge.render(34,fy,34,fy,colors.white,colors.cyan,tostring(math.ceil(fs.getSize("/"..files..f_file[i])/1024)).."kb",colors.black)
              edge.render(42,fy,45,fy,colors.white,colors.white,"File",colors.black)
            -- end
          end
        end
      end
      fy = fy+1
    end
    --edge.render(7,fy,7,fy,colors.white,colors.cyan,file[i],colors.black,false)
  end
  if fileselect then
    edge.render(1,my,mx,my,colors.white,colors.cyan,"Right-click to select.",colors.black,false)
  end
  edge.log("listed files")
  while(true) do
    edge.log("waiting for event")
    event, button, x, y = os.pullEvent("mouse_click")
    edge.log("caught event")
    if event == "terminate" then
      return true
    end
    if x >= 2 and x <= 5 and y == 3 then
      edge.windowAlert(25,10,"App Version "..appversion.."\nOfficially packaged with Axiom.",true,colors.green)
      --filebrowser()
    end
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
          --filebrowser(files)

        end
        if event == "terminate" then
          disableclock = false

          return true
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
          --filebrowser(files, fileselect)
        end
        if x >= 1 and x <= 10 and y == 7 then
          shell.run("clear")
          state = "loginscreen"
          login_gui_unreleased()
        end
        if x >= 1 and x <= 10 and y == 8 then
          if setting.variables.temp.first_update == false then
            setting.variables.temp.first_update = true
            edge.render(1,1,mx,my,colors.cyan,colors.cyan,"",colors.black,false)
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
              edge.render(1,1,mx,my,colors.cyan,colors.cyan,"",colors.black,false)
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
      --files = setting.variables.users[currentUser].fexplore_startdir

      fileselect = false
      --menubarColor = colors.white
      disableclock = false

      break;
    end
    if x == 45 and y == 2 and button == 1 then
      --files = setting.variables.users[currentUser].fexplore_startdir

      --menubarColor = colors.white
      disableclock = false

      fileselect = false
      break;
      --parallel.waitForAll(desktop,clock)
    end
    if x == 43 and y == 2 and button == 1 then

      --menubarColor = colors.white
      disableclock = false

      return true
    end
    if x >= 42 and y == 3 and x <= 45 and y == 3 then
      edge.log("F:"..fs.getDir(files))
      if fs.getDir(files) == ".." then
	  	break
      else
        files = "/"..fs.getDir(files).."/"
        --filebrowser(files, fileselect)
      end
    end
    if x >= 7 and x <= 7+string.len("<New folder>") and y == 4 and button == 1 then

      term.setBackgroundColor(colors.blue)
      term.setTextColor(colors.black)
      edge.render(1,16,mx,my,colors.white,colors.cyan,"Create folder:",colors.black,true)
      edge.render(1,17,mx,my,colors.white,colors.lightGray,"(In current dir)",colors.lightGray)
      edge.render(2,my-1,mx-1,my-1,colors.lightGray,colors.lightGray,"/",colors.black)
      term.setTextColor(colors.black)
      term.setCursorPos(3,my-1)

      local input = read()
      term.setBackgroundColor(colors.cyan)
      term.setTextColor(colors.white)

      if not fs.exists(files..input) then
        fs.makeDir(files..input)
        edge.log("Created folder: "..files..input)
      end
      --filebrowser()
    end
    if x >= my and x <= my+string.len("<New file>") and y == 4 and button == 1 then

      edge.render(1,my-3,mx,my,colors.white,colors.cyan,"Create file:",colors.black,true)
      edge.render(1,my-2,mx,my,colors.white,colors.lightGray,"(In current dir)",colors.lightGray)
      edge.render(2,my-1,mx-1,my-1,colors.lightGray,colors.lightGray,"/",colors.black)
      term.setTextColor(colors.black)
      term.setCursorPos(3,my-1)

      local input = read()
      term.setBackgroundColor(colors.cyan)
      term.setTextColor(colors.white)
      if input == nil then
        filebrowser(files, fileselect)
      else
        if not fs.exists(files..input) then
          local a = fs.open(files..input,"w")
          a.close()
          edge.log("Created file: "..files..input)
          --filebrowser(files, fileselect)
        -- else
        --   filebrowser(files, fileselect)
        end
      end
    end
    if x >= 30 and x <= 30+string.len("<Delete>") and y == 4 and button == 1 then

      edge.render(1,16,mx,my,colors.white,colors.cyan,"Delete file:",colors.black,true)
      edge.render(1,17,mx,my,colors.white,colors.lightGray,"(In current dir)",colors.lightGray)
      edge.render(2,my-1,mx-1,my-1,colors.lightGray,colors.lightGray,"/",colors.black)
      term.setTextColor(colors.black)
      term.setCursorPos(3,my-1)

      local input = read()
      if not fs.exists(files..input) then
        return
      end
      if input ~= "" then
        if not string.find(input,".axs",string.len(input) - 4) or not string.find(input,".0",string.len(input) - 2) then
          if fs.exists(files..input) then
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
          --edge.render(my-1,9,32,9,colors.white,colors.lightGray,"(In current dir)",colors.lightGray)
          edge.render(16,10,34,10,colors.lightGray,colors.lightGray,"File access denied.",colors.black)
          term.setTextColor(colors.black)
          sleep(5)
        end
      elseif input == "*" then
        local fl = fs.list(files.."/")
        for k,v in ipairs(fl) do
          if fs.exists(files..fl[k]) then
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
      --filebrowser(files, fileselect)
    end
    if button == 1 and event == "mouse_click" then
      for i=1, #f_file do
        if x > 2 and x <= 23 and y == 5+i then
          if fs.isDir(files..f_file[i]) and f_file[i] ~= "rom" then
            previousDir = files
            files = files..""..f_file[i].."/"
            filebrowser(files, fileselect)
          else

            term.setBackgroundColor(colors.black)
            if not fs.exists("home/prg/luaide.app") then
              shell.run("edit "..files..f_file[i])
            else
              shell.run("home/prg/luaide.app "..files..f_file[i])
            end
            --parallel.waitForAll(filebrowser)
            break
          end
        end
      end
    end
    if button == 2 and event == "mouse_click" then

      for i=1, #f_file do
        if x > 2 and x <= 20 and y == 5+i then
          edge.log(tostring(fs.isDir(files..f_file[i]))..":"..files..f_file[i])
          --print(files)
          --print(f_file[i])
          edge.log("File:"..files..f_file[i])
          if fs.isDir(files..f_file[i]) then
            if fileselect then

              return files_f_file[i]
            end
          else
            if fileselect then
              return files_f_file[i]
            else
              if files..f_file[i] == "startup" then
                error("An instance of "..productName.." is already running")
              else
                if not fs.exists(files..f_file[i]) then
                  error("File not found")
                else
                  if string.find(files..f_file[i],".app",string.len(f_file[i]) - 4) or string.find(files..f_file[i],".lua",string.len(f_file[i]) - 4) or string.find(files..f_file[i],".cmd",string.len(f_file[i]) - 4) or string.find(files..f_file[i],".axp",string.len(f_file[i]) - 4) then
                    menubarColor = colors.white
                    edge.render(1,1,mx,1,menubarColor,colors.cyan," o*",colors.black,false)
                    edge.log("File:"..files..f_file[i])
                    local f = assert(loadfile(files..f_file[i]))
                    f()
                  end
                end
                --filebrowser()
              end
            end
          end
        end
      end
    end
  end
end
if #args > 0 then
  files = args[1]
  local doSelect = args[2] == "select"
  if not fs.exists(args[1]) then
    edge.windowAlert(20, 10, "Fatal error: Folder "..args[1].." does not exist.", true, colors.red)
    return false
  end
  filebrowser(files, doSelect)
else
  local ok, err = pcall(filebrowser)
  if not ok then
    edge.windowAlert(20,10,"Fatal error: "..err, true,colors.red)
  end
end
