--[[
	STD Graphical User Interface! (STD-GUI)!
	Made by LDDestroier/EldidiStroyrr (same guy)
	Modified to be used in Axiom, specifically!
--]]

local tsv = term.current().setVisible --comment out if you are debugging

if not http then --why, you...
	return false, printError("HTTP must be enabled to use STD. Contact an administrator for assistance.")
else
	if not http.checkURL("http://pastebin.com") then
	    term.setBackgroundColor(colors.black)
		term.clear()
		term.setCursorPos(1, 1)
		return false, printError("For some reason, pastebin could not be reached.\nIt may be blacklisted.\nAlso try checking your internet connection.\nAbort."), sleep(3)
	end
end
local scr_x, scr_y = term.getSize()

local doDisplayTitle = false
local relativePath = false
local doColorize = true

if type(std) ~= "table" then std = {} end

local overrideNoOS = false --prevent SimSoft functions, even if it's installed
local isSimSoft = false --special integration into SimSoft!
local isAxiom = true --special integration into Axiom!
std.channel = "STD"
std.prevChannel = std.channel

std.channelURLs = { --special pastebin URLs for getting a list of files.
	["STD"] = "http://pastebin.com/raw/zVws7eLq", --default store list
	["Discover"] = "http://pastebin.com/raw/9bXfCz6M", --owned by dannysmc95
--	["OnlineAPPS"] = "http://pastebin.com/raw/g2EnDYLp", --owned by Twijn, but discontinued.
	["STD-Media"] = "https://pastebin.com/raw/3JZHXTGL", --list of pictures and music
}
local palate
palate = {
	pleasewait = {
		txt = colors.lightGray,
		bg = colors.black,
	},
	store = {
		bg = colors.black,
		txt = colors.white,
		bgchar = " ",
		entrybg = colors.gray,
		entrytxt = colors.white,
		entryasterisk = colors.lightGray,
		closetxt = colors.white,
		closebg = colors.red,
		previewtxt = colors.white,
		previewbg = colors.cyan,
		findbg = colors.white,
		findtxt = colors.black,
		indicatetxt = colors.black,
		indicatebg = colors.white,
		theendtxt = colors.gray,
		scrollbar = {
			knobbg = colors.black,
			knobtxt = colors.gray,
			knobchar = "|",
			barbg = colors.lightGray,
			bartxt = colors.gray,
			barchar = "|",
		}
	},
	item = {
		bg = colors.gray,
		txt = colors.white,
		specialtxt = colors.yellow,
		previewtxt = colors.white,
		previewbg = colors.black,
		forumtxt = colors.lightGray,
		forumbg = colors.gray,
		closetxt = colors.white,
		closebg = colors.red,
		runtxt = colors.white,
		runbg = colors.green,
		downloadtxt = colors.white,
		downloadbg = colors.green,
	},
	menubar = {
		bg = colors.black,
		categorytxt = colors.lightGray,
		categorybg = colors.black,
		channeltxt = colors.lightGray,
		channelbg = colors.black,
		hotkeytxt = colors.gray,
		categorymenu = {
			selecttxt = colors.lightGray,
			selectbg = colors.black,
			bg = colors.black,
			txt = colors.lightGray,
			orbtxt = colors.black,
			cursortxt = colors.black,
			cursorbg = colors.lightGray,
			borderbg = colors.black,
		},
		channelmenu = {
			selecttxt = colors.lightGray,
			selectbg = colors.black,
			bg = colors.lightGray,
			txt = colors.lightGray,
			orbtxt = colors.black,
			cursortxt = colors.black,
			cursorbg = colors.lightGray,
			borderbg = colors.black,
		}
	}
}

local getEvents = function(...)
	local arg, output = table.pack(...)
	while true do
		output = {os.pullEvent()}
		for a = 1, #arg do
			if type(arg[a]) == "boolean" then
				if doRender == arg[a] then
					return {}
				end
			elseif output[1] == arg[a] then
				return unpack(output)
			end
		end
	end
end

local charClear = function(char)
	local cx,cy = term.getCursorPos()
	for y = 1, scr_y do
		term.setCursorPos(1,y)
		term.write(char:sub(1,1):rep(scr_x))
	end
	term.setCursorPos(cx,cy)
end

std.channelNames = {}
for k,v in pairs(std.channelURLs) do
	table.insert(std.channelNames,k)
end

std.stdList = "."..std.channel:lower().."_list"
--I'm not in fucking SimSoft, look at the fucking URL you bungy fucking twatnose shitcunt
--if (fs.isDir("SimSoft/Data") and fs.isDir("SimSoft/SappS")) and (not overrideNoOS) then --checks if SimSoft is installed
--	isSimSoft = true
--elseif (fs.isDir("Axiom") and fs.exists("Axiom/sys.axs")) and (not overrideNoOS) then --checks if Axiom is installed
--	isAxiom = true
--end

local cprint = function(txt,y)
	local cX,cY = term.getCursorPos()
	term.setCursorPos(math.ceil(scr_x/2)-math.floor(#txt/2),y or cY)
	term.write(txt)
end

local scroll = 1 --one is the loneliest number...weaboo
local scrollX = 1 --to view longer program names
local maxScroll
std.std_version = 101 --to prevent updating to std command line

local setMaxScroll = function(catagory)
	local output = 0
	for k,v in pairs(std.storeURLs) do
		if (v.catagory == catagory) or catagory == 0 then
			output = output + 1
		end
	end
	return (output*4)-(scr_y-4)
end
local catag = 0

local pleaseWait = function(text)
	term.setBackgroundColor(palate.pleasewait.bg)
	term.setTextColor(palate.pleasewait.txt)
	term.clear()
	cprint(text or "Getting list...please wait",scr_y/2)
end

local coolPleaseWait = function()
	local scr_x, scr_y = term.getSize()
	local cols = "f7"
	local length = scr_x/2
	local render = function(col1,col2,prog,forwards)
	    term.setCursorPos(1,1)
	    local screen = (col1:rep(prog)..col2:rep(length-prog)):rep(scr_x*scr_y):sub(1,(scr_x*scr_y))
	    local line
	    for a = forwards and 1 or scr_y, forwards and scr_y or 1, forwards and 1 or -1 do
	        line = screen:sub((a-1)*scr_x+1,a*scr_x)
	        term.setCursorPos(1,a)
	        term.blit(("L"):rep(#line),line,line)
	    end
	end
	local pos1 = 2
	local pos2 = pos1 - 1
	local forwards = true
	local reverse = false
	while true do
	    for a = reverse and length or 1, reverse and 1 or length, reverse and -1 or 1 do
	        render(cols:sub(pos1,pos1),cols:sub(pos2,pos2),a,forwards)
	        sleep(0.0)
	    end
		   forwards = not forwards
	   	reverse = not reverse
	    pos1 = (pos1 + 1)
	    pos2 = (pos2 + 1)
	    if pos1 > #cols then pos1 = 1 end
	    if pos2 > #cols then pos2 = 1 end
	end
end

local setDefaultColors = function()
	term.setBackgroundColor(palate.store.bg)
	term.setTextColor(palate.store.txt)
end

local displayHelp = function(cli)
	local helptext = [[
This is a graphical interface to the STD downloader program.
Use 'stdgui update' to update the list, or use 'F5'.
If you want your program on it, PM LDDestroier on the CC forums.
Hotkeys:
	'Q' quit or back
	'F5' refresh
	'F1' set category
	'F3' set channel
	'F' or 'F6' search
	'F12' update STDGUI
	if normal computer, press 0-9 to select store item
]]
	if cli then
		return print(helptext)
	else
		setDefaultColors()
		term.clear()
		term.setCursorPos(2,2)
		print(helptext)
		sleep(0)
		print("\nPress a key to go back.")
		os.pullEvent("key")
		return
	end
end

local getTableSize = function(tbl)
	local amnt = 0
	for k,v in pairs(tbl) do
		amnt = amnt + 1
	end
	return amnt
end

local colors_names = {
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

local blit_names = {}
for k,v in pairs(colors_names) do
	blit_names[v] = k
end

local codeNames = { --just for checking, not for any translation
	["r"] = "reset",
	["{"] = "stopFormatting",
	["}"] = "startFormatting",
}

local explode = function(div,str)
	if (div=='') then return false end
	local pos,arr = 0,{}
	for st,sp in function() return string.find(str,div,pos,true) end do
		table.insert(arr,string.sub(str,pos,st-1))
		pos = sp + 1
	end
	table.insert(arr,string.sub(str,pos))
	return arr
end

local blitWrap = function(text,txt,bg)
	local allIssues = ""
	if not text then allIssues = allIssues.."no text, " end
	if not txt then allIssues = allIssues.."no txt, " end
	if not bg then allIssues = allIssues.."no bg, " end
	if not (#text == #txt and #txt == #bg) then allIssues = allIssues.."incongruent lengths" end
	if #allIssues > 0 then error(allIssues) end
	local wordNo = 1
	local words = explode(" ",text)
	local lines = 0
	local scr_x, scr_y = term.getSize()
	local cx,cy
	for a = 1, #text do
		cx,cy = term.getCursorPos()
		if text:sub(a,a) == " " and text:sub(a-1,a-1) ~= " " and a > 1 then
			wordNo = wordNo + 1
			if cx + #words[wordNo] > scr_x then
				term.setCursorPos(1,cy+1)
				lines = lines + 1
			end
		end
		cx,cy = term.getCursorPos()
		if text:sub(a,a) == "\n" then
			term.setCursorPos(1,cy+1)
			lines = lines + 1
		elseif not (cx == 1 and text:sub(a,a) == " ") then
			term.blit(text:sub(a,a),txt:sub(a,a),bg:sub(a,a))
		end
		if cx == scr_x then
			term.setCursorPos(1,cy+1)
			lines = lines + 1
		end
	end
	return lines
end

local moveOn, textToBlit
textToBlit = function(str,substart,substop)
	local p = 1
	local output = ""
	local txcolorout = ""
	local bgcolorout = ""
	local txcode = "&"
	local bgcode = "~"
	local doFormatting = true
	local usedformats = {}
	local txcol,bgcol = blit_names[term.getTextColor()], blit_names[term.getBackgroundColor()]
	local origTX,origBG = blit_names[term.getTextColor()], blit_names[term.getBackgroundColor()]
	local cx,cy,barestr
	substart = substart or 0
	substop = substop or #str
	if not (substart == 0 and substop == #str) then
		barestr = textToBlit(str)
	else
		if substart < 0 then
			substart = #realstr - substart
		end
		if substop < 0 then
			substop = #realstr - substop
		end
	end
	moveOn = function(tx,bg)
		if p >= substart and p <= substop then
			output = output..str:sub(p,p)
			txcolorout = txcolorout..tx
			bgcolorout = bgcolorout..bg
		end
	end
	while p <= #str do
		if str:sub(p,p) == txcode then
			if colors_names[str:sub(p+1,p+1)] and doFormatting then
				txcol = str:sub(p+1,p+1)
				usedformats.txcol = true
				p = p + 1
			elseif codeNames[str:sub(p+1,p+1)] then
				if str:sub(p+1,p+1) == "r" and doFormatting then
					txcol = blit_names[term.getTextColor()]
					p = p + 1
				elseif str:sub(p+1,p+1) == "{" and doFormatting then
					doFormatting = false
					p = p + 1
				elseif str:sub(p+1,p+1) == "}" and (not doFormatting) then
					doFormatting = true
					p = p + 1
				else
					moveOn(txcol,bgcol)
				end
			else
				moveOn(txcol,bgcol)
			end
			p = p + 1
		elseif str:sub(p,p) == bgcode then
			if colors_names[str:sub(p+1,p+1)] and doFormatting then
				bgcol = str:sub(p+1,p+1)
				usedformats.bgcol = true
				p = p + 1
			elseif codeNames[str:sub(p+1,p+1)] and (str:sub(p+1,p+1) == "r") and doFormatting then
				bgcol = blit_names[term.getBackgroundColor()]
				p = p + 1
			else
				moveOn(txcol,bgcol)
			end
			p = p + 1
		else
			moveOn(txcol,bgcol)
			p = p + 1
		end
	end
	return output, txcolorout, bgcolorout, usedformats
end

local writef = function(txt,noWrite,substart,substop)
	if doColorize then
		local text, textCol, bgCol, usedformats = textToBlit(txt,substart,substop)
		local out = blitWrap(text,textCol,bgCol,noWrite)
		return out, #text, usedformats
	else
		if noWrite then
			local cx,cy = term.getCursorPos()
			return math.floor((cx+#cf(txt))/scr_x), #cf(txt), {} --this is approximate, and might mess up with multiline strings
		else
			return write(txt), #txt, {}
		end
	end
end

local printf = function(txt,noWrite)
	return writef(tostring(txt.."\n"),noWrite)
end

local runURL = function(url, ...)
	local program = http.get(url)
	if not program then return false end
	program = program.readAll()
	local func = load(program)
	setfenv(func, getfenv())
	return func(...)
end

local bow = function()
	term.setBackgroundColor(palate.store.findbg)
	term.setTextColor(palate.store.findtxt)
end

local strless = function(str,txt,bg)
	local x,y = 0,0
	local shiftDown = false
	local str = explode("\n",str or "")
	local render = function()
		term.setBackgroundColor(bg)
		term.setTextColor(txt)
		for i = y+1, (scr_y+y)-1 do
			term.setCursorPos(math.max(1,-x),i-y)
			term.clearLine()
			if str[i] then
				term.write(str[i]:sub(math.max(1,x+1)))
			end
		end
		term.setCursorPos(1,scr_y)
		term.setBackgroundColor(colors.gray)
		term.setTextColor(colors.white)
		term.clearLine()
		term.write("(Q)uit, Goto (L)ine")
		local ting = "Ln."..math.min(math.max(y+1,0),#str)
		term.setCursorPos((scr_x-#ting)+1,scr_y)
		term.write(ting)
	end
	render()
	maxY = (#str-scr_y)+1
	while true do
		local evt, key, mx, my = os.pullEvent()
		local oldY = y
		local oldX = x
		if evt == "key" then
			if key == keys.leftShift then
				shiftDown = true
			elseif key == keys.up then
				y = y-1
			elseif key == keys.down then
				y = y+1
			elseif key == keys.pageUp then
				y = y-(scr_y-1)
			elseif key == keys.pageDown then
				y = y+(scr_y-1)
			elseif key == keys.left then
				x = x-1
			elseif key == keys.right then
				x = x+1
			elseif key == keys.home then
				y = 0
			elseif key == keys["end"] then
				y = maxY
			elseif (key == keys.q) or (key == keys.x) then
				sleep(0)
				break
			elseif (key == keys.l) then
				term.setCursorPos(1,scr_y)
				term.setBackgroundColor(colors.gray)
				term.setTextColor(colors.white)
				term.clearLine()
				term.write("Line #:")
				sleep(0)
				y = (tonumber(read()) or (y+1)) - 1
			end
		elseif evt == "key_up" then
			if key == keys.leftShift then
				shiftDown = false
			end
		elseif evt == "mouse_scroll" then
			if shiftDown then
				x = x + key
			else
				y = y + key
			end
		elseif evt == "mouse_click" and key == 1 then
			if my == scr_y and (mx >= 1 and mx <= 11) then
				sleep(0)
				break
			end
		end
		if x < 0 then x = 0 end
		if y < 0 then y = 0 end
		if y > maxY then y = maxY end
		if (x ~= oldX) or (y ~= oldY) or (key == keys.l) then
            render()
        end
    end
end
local contentsFile = function(url)
	local prog = http.get(url)
	if prog then return prog.readAll()
	else return false, "could not connect" end
end
local getFile = function(filename,url)
	if fs.isReadOnly(filename) then
		return false, "access denied"
	end
	local prog
	if type(url) == "table" then
		prog = std.contextualGet(url[1])
	else
		prog = http.get(url)
	end
	if not prog then
		return false, "could not connect"
	end
	prog = prog.readAll()
	local fyle = fs.open(filename,"w")
	fyle.write(prog)
	fyle.close()
	return true, fs.getSize(filename)
end
local runFile = function(path, ...)
	if not fs.exists(path) then
		return false, "No such file!"
	end
	local file = fs.open(path,"r")
	local contents = file.readAll()
	file.close()
	local func = loadstring(contents)
	setfenv(func, getfenv())
	return func(...)
end
std.getSTDList = function(prevChannel)
	catag = 0
	local url = std.channelURLs[std.channel] --URL of URL list for whatever channel you have selected.
	pleaseWait()
	local contents = http.get(url)
	if not contents then
		if shell then
			print("Couldn't update list!")
		end
		return false, "Couldn't update list!"
	else
		local uut
		if fs.exists(std.stdList) then
			uut = runFile(std.stdList, "storelengthcheck")
		end
		if not uut then std.storeURLs = {} end
		local beforeSize = getTableSize(std.storeURLs or {})
		local outcome
		if not fs.isReadOnly(std.stdList) then
			local program = contents.readAll()
			local file = fs.open(std.stdList,"w")
			file.writeLine(program)
			file.close()
			outcome = runFile(std.stdList)
		else
			outcome = runURL(url)
		end
		if outcome == false then
			term.setBackgroundColor(colors.black)
			term.setTextColor(term.isColor() and colors.red or colors.lightGray)
			term.clear()
			cprint("STD channel \""..std.channel.."\" is down right now.",2)
			term.setTextColor(colors.white)
			cprint("Either try again later,",4)
			cprint("contact LDDestroier on the CC forums,",5)
			cprint("or tell the owner of the channel.",6)
			cprint("Press a key to go back.",8)
			term.setTextColor(colors.gray)
			cprint("Sorry bout that!",scr_y)
			std.channel = prevChannel
			sleep(0.1)
			os.pullEvent("char")
			pleaseWait("Changing list...please wait...")
			return std.getSTDList("STD")
		end
		local afterSize = getTableSize(std.storeURLs or {})
		local diff = afterSize-beforeSize
		local output
		if not fs.isReadOnly(std.stdList) then
			output = "Downloaded to "..std.stdList
		else
			output = "Got store codes."
		end
		if diff > 0 then
			output = output.." (got "..diff.." new store entries)"
		end
		maxScroll = setMaxScroll(catag)
		for k, v in pairs(std.storeCatagoryNames) do
			if v == "Operating System" then
				table.remove(std.storeCatagoryNames, k)
				table.remove(std.storeCatagoryColors, k)
				for k2, v2 in pairs(std.storeURLs) do
					if v2.category == k then
						table.remove(std.storeURLs, k2)
					end
				end
				for k2, v2 in pairs(std.storeURLs) do
					if v2.catagory > k then
						std.storeURLs[k2].catagory = v2.catagory - 1
					end
				end
				break
			end
		end
		return true, output
	end
end

local cisf = function(str,fin)
	fin = fin:gsub("%[","%%["):gsub("%(","%%("):gsub("%]","%%]"):gsub("%)","%%)")
	return string.find(str:lower(),fin:lower())
end

local clearMostline = function(length,char)
	local pX,pY = term.getCursorPos()
	term.setCursorPos(1,pY)
	term.write(string.rep(char or " ",length or (scr_x-1)))
	term.setCursorPos(pX,pY)
end

local dotY
local doScrollBar = false

local renderStore = function(list,filter,scrollY,namescroll,fixedDotY,buttonIndicate)
	local fullrend = {}
	local visiblerend = {}
	local amnt = 0
	local output = {}
	local colors_output = {}
	local num = 0
	if tsv then tsv(false) end
	for k,v in pairs(list) do
		if (v.catagory == filter) or filter == 0 then
			table.insert(fullrend,{" &"..blit_names[palate.store.entryasterisk].."*&"..blit_names[palate.store.entrytxt]..v.title,v})
			table.insert(fullrend,{" by &r"..v.creator,v})
			table.insert(fullrend,{" Category: "..std.storeCatagoryNames[v.catagory],v,v.catagory})
			table.insert(fullrend,"nilline")
		end
	end
	table.insert(fullrend,"")
	dotY = fixedDotY or math.floor((scr_y-2)*((scroll-1)/(maxScroll-1)))+2
	for a = scrollY, (scr_y+scrollY)-1 do
		if type(fullrend[a]) == "table" then
			table.insert(visiblerend,fullrend[a][1])
			table.insert(output,fullrend[a][2])
			if fullrend[a][3] then
				table.insert(colors_output,fullrend[a][3])
			else
				table.insert(colors_output,false)
			end
		else
			table.insert(visiblerend,fullrend[a])
			table.insert(output,{})
			table.insert(colors_output,false)
		end
	end
	setDefaultColors()
	charClear(palate.store.bgchar)
	for a = 1, #visiblerend do
		term.setCursorPos(2-namescroll,a+1)
		if visiblerend[a] == "nilline" then
			setDefaultColors()
			clearMostline()
		else
			if a < #visiblerend then
				if term.isColor() then
					if colors_output[a] then
						term.setBackgroundColor(std.storeCatagoryColors[colors_output[a]].bg)
						term.setTextColor(std.storeCatagoryColors[colors_output[a]].txt)
					else
						term.setBackgroundColor(palate.store.entrybg)
						term.setTextColor(palate.store.entrytxt)
					end
				else
					term.setBackgroundColor(colors.gray)
					term.setTextColor(colors.white)
				end
				clearMostline()
				writef(visiblerend[a])
			else
				term.setBackgroundColor(palate.store.bg)
				term.setTextColor(palate.store.theendtxt)
				cprint("That's them all!")
			end
		end
	end
	local b
	for a = 2, scr_y do
		term.setCursorPos(scr_x,a)
		if a == dotY then
			term.setTextColor(palate.store.scrollbar.knobtxt)
			term.setBackgroundColor(palate.store.scrollbar.knobbg)
			term.write(palate.store.scrollbar.knobchar)
		else
			term.setTextColor(palate.store.scrollbar.bartxt)
			term.setBackgroundColor(palate.store.scrollbar.barbg)
			term.write(palate.store.scrollbar.barchar)
		end
		if buttonIndicate then
			term.setCursorPos(scr_x-4,a)
			term.setBackgroundColor(palate.store.indicatebg)
			term.setTextColor(palate.store.indicatetxt)
			b = (a+1)/4
			if (b == math.floor(b)) and (visiblerend[a] and visiblerend[a] ~= "nilline") then
				term.write(" "..tostring(b):sub(#tostring(b)).." ")
			end
		end
	end
	if tsv then tsv(true) end
	return output
end

local simSoftInstall = function(obj,objname,appname)
	local installSystemName = "STD App Distribution (sad...)"
	appname = appname or objname
	local getFromURL = function(url)
		local cunt
		if type(url) == "table" then
			cunt = std.contextualGet(url[1])
		else
			cunt = http.get(url)
		end
		if not cunt then
			return shit
		else
			if type(url) == "table" then
				return cunt.readAll(), false
			else
				return cunt.readAll(), (string.find(url,"://pastebin.com/raw/") and (url:sub(-9):gsub("/","")) or false)
			end
		end
	end
	local mainpath = fs.combine("/SimSoft/SappS",objname)
	local cont,pbcode = getFromURL(obj.url)
	local file = fs.open("\""..fs.combine(mainpath,pbcode or "program").."\"","w")
	file.write(cont)
	file.close()
	local file = fs.open(fs.combine(mainpath,"SappS"),"w")
	file.writeLine(installSystemName)
	file.writeLine("\""..fs.combine(mainpath,pbcode or "program").."\"")
	file.writeLine(appname:sub(1,9))
	file.close()
	return true, "Installed!"
end

local getFindList = function(name)
	local output = {}
	for k,v in pairs(std.storeURLs) do
		if cisf(k,name) or cisf(textToBlit(v.title),name) or cisf(textToBlit(v.creator),name) then
			output[k] = v
		end
		if output[k] ~= v and v.keywords then
			for a = 1, #v.keywords do
				if cisf(v.keywords[a],name) then
					output[k] = v
					break
				end
			end
		end
	end
	return output
end

local doFindFunc = function(name)
	scroll = 1
	maxScroll = setMaxScroll(catag)
	renderStore(getFindList(name),catag,scroll,scrollX,_,not term.isColor())
	term.setCursorPos(1,1)
	bow()
	term.clearLine()
	write("Find: ")
end

local funcread = function(repchar,rHistory,doFunc,noNewLine)
	local scr_x,scr_y = term.getSize()
	local sx,sy = term.getCursorPos()
	local cursor = 1
	rHistory = rHistory or {}
	local rCursor = #rHistory+1
	local output = ""
	term.setCursorBlink(true)
	while true do
		local evt,key = os.pullEvent()
		local cx,cy = term.getCursorPos()
		if evt == "key" then
			if key == keys.enter then
				if not noNewLine then
					write("\n")
				end
				term.setCursorBlink(false)
				return output
			elseif key == keys.left then
				if cursor-1 >= 1 then
					cursor = cursor - 1
				end
			elseif key == keys.right then
				if cursor <= #output then
					cursor = cursor + 1
				end
			elseif key == keys.up then
				if rCursor > 1 then
					rCursor = rCursor - 1
					term.setCursorPos(sx,sy)
					term.write((" "):rep(#output))
					output = rHistory[rCursor] or ""
					cursor = #output+1
					pleaseDoFunc = true
				end
			elseif key == keys.down then
				term.setCursorPos(sx,sy)
				term.write((" "):rep(#output))
				if rCursor < #rHistory then
					rCursor = rCursor + 1
					output = rHistory[rCursor] or ""
					cursor = #output+1
					pleaseDoFunc = true
				else
					rCursor = #rHistory+1
					output = ""
					cursor = 1
				end
			elseif key == keys.backspace then
				if cursor > 1 and #output > 0 then
					output = output:sub(1,cursor-2)..output:sub(cursor)
					cursor = cursor - 1
					pleaseDoFunc = true
				end
			elseif key == keys.delete then
				if #output:sub(cursor,cursor) == 1 then
					output = output:sub(1,cursor-1)..output:sub(cursor+1)
					pleaseDoFunc = true
				end
			end
		elseif evt == "char" or evt == "paste" then
			output = output:sub(1,cursor-1)..key..output:sub(cursor+(#key-1))
			cursor = cursor + #key
			pleaseDoFunc = true
		end
		if pleaseDoFunc then
			pleaseDoFunc = false
			if type(doFunc) == "function" then
				doFunc(output)
			end
			term.setCursorPos(sx,sy)
			local pOut = output
			if #output >= scr_x-(sx-2) then
				pOut = output:sub((#output+(sx))-scr_x)
			end
			if repchar then
				term.write(repchar:sub(1,1):rep(#pOut).." ")
			else
				term.write(pOut.." ")
			end
			local cx,cy = term.getCursorPos()
		end
		term.setCursorPos(sx+cursor-1,cy)
	end
end

local prevList
local findPrompt = function()
	local cX,cY = term.getCursorPos()
	sleep(0)
	if prevList then std.storeURLs = prevList end
	doFindFunc("")
	prevList = std.storeURLs
	std.storeURLs = getFindList(funcread(nil,{},doFindFunc,false))
	term.setCursorBlink(false)
	maxScroll = setMaxScroll(catag)
end

local displayTitle = function()
	local title = {{},{},{},{},{0,0,0,0,0,1,1,1,1,1,0,0,2,2,2,2,2,2,2,0,2,2,2,2,0,0,32768,},{0,0,0,0,1,1,0,0,0,1,1,0,0,0,0,2,0,0,0,0,0,2,0,2,2,0,32768,},{0,0,0,0,1,0,0,0,0,0,1,0,0,0,2,2,0,0,0,0,2,2,0,0,2,0,32768,},{0,0,0,0,1,1,0,0,0,0,0,0,0,0,2,0,0,0,0,0,2,0,0,0,2,0,32768,},{0,0,0,0,0,1,1,1,1,1,0,0,0,0,2,0,0,0,0,2,2,0,0,2,2,0,32768,},{0,0,0,0,0,0,0,0,0,1,0,0,0,2,2,0,0,0,2,2,0,0,2,2,0,0,32768,},{0,0,0,1,1,0,0,0,1,1,0,0,2,2,0,0,0,2,2,0,0,2,2,0,0,32768,1,},{0,0,0,0,1,1,1,1,1,0,0,0,2,0,0,0,2,2,2,2,2,2,0,0,32768,1,1,},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,32768,1,1,1,},{0,0,0,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,32768,1,1,1,1}}
	setDefaultColors()
	term.clear()
	paintutils.drawImage(title,-1,1)
	setDefaultColors()
	term.setCursorPos(4,16)
	term.write("STD-GUI ")
	sleep(0)
	local evt
	repeat
		evt = os.pullEvent()
	until evt == "mouse_click" or evt == "key"
	sleep(0)
end

local fixDotY

local renderStoreItem = function(obj) --now being experimented on...
	if not obj.title then return false end
	local showPostURL = false
	local bruffer
	local scroll = 1
	local doRedraw = true
	local extraLines
	while true do
		bruffer = {
			"",
			" &"..blit_names[palate.item.specialtxt]..obj.title,
			" &"..blit_names[palate.item.txt].."by &"..blit_names[palate.item.specialtxt]..obj.creator,
			" &"..blit_names[palate.item.txt].."Category: "..std.storeCatagoryNames[obj.catagory],
			"",
			"&"..blit_names[palate.item.txt]..obj.description,
		}
		if showPostURL and obj.forumPost then
			local post = " &"..blit_names[palate.item.forumtxt].."~"..blit_names[palate.item.forumbg]..obj.forumPost:gsub("http://www.",""):sub(1,-2)
			table.insert(bruffer,"&8Forum URL: "..post)
		end
		if doRedraw then
			term.setBackgroundColor(palate.item.bg)
			term.clear()
			term.setCursorPos(1,(-scroll)+2)
			extraLines = 0
			for y = 1, #bruffer do
				if not bruffer[y] then break end
				extraLines = extraLines + printf(bruffer[y])
			end

			term.setCursorPos(1,scr_y)
			if term.isColor() then
				term.setTextColor(palate.item.closetxt)
				term.setBackgroundColor(palate.item.closebg)
			else
				term.setTextColor(colors.black)
				term.setBackgroundColor(colors.white)
			end
			term.clearLine()
			if term.isColor() then
				term.write("CLOSE")
			else
				term.write("(Q) to CLOSE")
			end
			if term.isColor() then
				term.setTextColor(palate.store.previewtxt)
				term.setBackgroundColor(palate.store.previewbg)
				term.setCursorPos((scr_x-16),scr_y)
				term.write("VIEW")
				term.setTextColor(palate.item.runtxt)
				term.setBackgroundColor(palate.item.runbg)
				term.setCursorPos((scr_x-11),scr_y)
				term.write("RUN")
			else
				term.setTextColor(colors.black)
				term.setBackgroundColor(colors.white)
				term.setCursorPos((scr_x-22),scr_y)
				term.write("(V)IEW")
				term.setTextColor(colors.black)
				term.setBackgroundColor(colors.white)
				term.setCursorPos((scr_x-15),scr_y)
				term.write("(R)UN")
			end
			local txt
			if isSimSoft or isAxiom then
				if term.isColor() then --yeah yeah, simsoft can't run on normal computers, but axiom can, so shut your cunting trap
					term.setTextColor(palate.item.downloadtxt)
					term.setBackgroundColor(palate.item.downloadbg)
					txt = "INSTALL!"
				else
					txt = "(I)NSTALL"
				end
			else
				if term.isColor() then
					term.setTextColor(palate.item.downloadtxt)
					term.setBackgroundColor(palate.item.downloadbg)
					txt = "DOWNLOAD"
				else
					txt = "(D)OWNLOAD"
				end
			end
			term.setCursorPos((scr_x-(#txt-1)),scr_y)
			term.write(txt)
			doRedraw = false
		end
		local evt = {getEvents("key","mouse_click","mouse_scroll","term_resize")}
		if evt[1] == "key" then
			if evt[2] == keys.f then
				showPostURL = not showPostURL
				doRedraw = true
			elseif evt[2] == keys.d or evt[2] == keys.i or evt[2] == keys.r or evt[2] == keys.q or evt[2] == keys.v then
				return unpack(evt)
			end
		elseif evt[1] == "mouse_click" then
			if evt[4] == scr_y then
				return unpack(evt)
			end
		elseif evt[1] == "mouse_scroll" then
			if scroll+evt[2] >= 1 and scroll+evt[2] <= (#bruffer+extraLines)-(scr_y-8) then
				scroll = scroll + evt[2]
				doRedraw = true
			end
		elseif evt[1] == "term_resize" then
			doRedraw = true
			scr_x,scr_y = term.getSize()
		end
	end
end

local renderCatagoryMenu = function(expanded,cursor)
	if expanded then
		term.setCursorPos(1,1)
		term.setBackgroundColor(palate.menubar.bg)
		term.clearLine()
		term.setBackgroundColor(palate.menubar.categorymenu.selectbg)
		term.setTextColor(palate.menubar.categorymenu.selecttxt)
		if term.isColor() then
			if cursor == 0 then
				term.setTextColor(palate.menubar.categorymenu.txt)
				term.write(" No category")
			else
				term.write("Select category:")
			end
		else
			term.setCursorPos(1,1)
			if cursor == 0 then
				term.setTextColor(palate.menubar.categorymenu.txt)
				term.write(" No category")
			else
				term.write(" Pick category with up/down:")
			end
		end
		term.setTextColor(palate.menubar.categorymenu.txt)
		term.setBackgroundColor(palate.menubar.categorymenu.bg)
		local yposes = {}
		local longestLen = 0
		for a = 1, #std.storeCatagoryNames do
			if #std.storeCatagoryNames[a]+2 > longestLen then
				longestLen = #std.storeCatagoryNames[a]+2
			end
		end
		longestLen = longestLen+1
		for a = 0, #std.storeCatagoryNames do
			term.setCursorPos(1,a+1)
			if term.isColor() then
				term.setTextColor(palate.menubar.categorymenu.orbtxt)
				term.setBackgroundColor(palate.menubar.categorymenu.bg)
				if type(std.storeCatagoryColors) == "table" then
					if std.storeCatagoryColors[a] then
						term.setTextColor(std.storeCatagoryColors[a].txt)
						term.setBackgroundColor(std.storeCatagoryColors[a].bg)
					end
				end
			else
				term.setTextColor(colors.black)
				term.setBackgroundColor(colors.lightGray)
			end
			if a > 0 then
				clearMostline(longestLen+2)
			end
			if a == cursor then
				if type(std.storeCatagoryColors) ~= "table" then
					if term.isColor() then
						if cursor == 0 then
							term.setTextColor(palate.menubar.categorymenu.txt)
							term.setBackgroundColor(palate.menubar.categorymenu.bg)
						else
							term.setTextColor(palate.menubar.categorymenu.cursortxt)
							term.setBackgroundColor(palate.menubar.categorymenu.cursorbg)
						end
					else
						term.setTextColor(colors.black)
						term.setBackgroundColor(colors.lightGray)
					end
				elseif cursor == 0 then
					term.setBackgroundColor(colors.black)
				end
				write(">")
			elseif a > 0 then
				write(" ")
			end
			if a > 0 then
				if type(std.storeCatagoryColors) ~= "table" then
					term.setTextColor(palate.menubar.categorymenu.orbtxt)
					term.setBackgroundColor(palate.menubar.categorymenu.bg)
				end
				if a == catag then
					write("@ ")
				else
					write("O ")
				end
				write(std.storeCatagoryNames[a])
				if term.isColor() then
					term.setBackgroundColor(palate.menubar.categorymenu.borderbg)
				else
					term.setBackgroundColor(colors.black)
				end
				term.setCursorPos(longestLen+2,a+1)
				term.write(" ")
				table.insert(yposes,a+1)
			end
		end
		term.setCursorPos(1,#std.storeCatagoryNames+2)
		term.write((" "):rep(longestLen+2))
		return yposes,longestLen+2
	else
		term.setCursorPos(1,1)
		term.setBackgroundColor(palate.menubar.bg)
		term.clearLine()
		term.setTextColor(palate.menubar.categorytxt)
		term.setBackgroundColor(palate.menubar.categorybg)
		term.write("Cat.")
		term.setTextColor(palate.menubar.hotkeytxt)
		term.write("F1")
		term.setCursorPos(8,1)
		term.setTextColor(palate.menubar.channeltxt)
		term.setBackgroundColor(palate.menubar.channelbg)
		term.write("Chan.")
		term.setTextColor(palate.menubar.hotkeytxt)
		term.write("F3")
		--writef("~f&8Cat.&7F1~r&r ~f&8Chan.&7F3")
	end
	if term.isColor() then
		term.setCursorPos(scr_x-4,1)
		term.setBackgroundColor(palate.store.closebg)
		term.setTextColor(palate.store.closetxt)
		term.write("CLOSE")
	else
		term.setCursorPos(scr_x-11,1)
		term.setBackgroundColor(colors.black)
		term.setTextColor(colors.white)
		term.write("'Q' to CLOSE")
	end
	setDefaultColors()
end

local renderChannelMenu = function(cursor)
	term.setCursorPos(1,1)
	term.setBackgroundColor(palate.menubar.bg)
	term.clearLine()
	term.setBackgroundColor(palate.menubar.channelmenu.selectbg)
	term.setTextColor(palate.menubar.channelmenu.selecttxt)
	term.write("Select channel:")
	term.setTextColor(palate.menubar.channelmenu.txt)
	term.setBackgroundColor(palate.menubar.channelmenu.bg)
	local yposes = {}
	local longestLen = 0
	for a = 1, #std.channelNames do
		if #std.channelNames[a] > longestLen then
			longestLen = #std.channelNames[a]
		end
	end
	longestLen = longestLen + 4
	for a = 1, #std.channelNames do
		term.setBackgroundColor(palate.menubar.channelmenu.bg)
		term.setCursorPos(1,a+1)
		clearMostline(longestLen+2)
		if a == cursor then
			term.setTextColor(palate.menubar.channelmenu.cursortxt)
			term.setBackgroundColor(palate.menubar.channelmenu.cursorbg)
			write(">")
		else
			write(" ")
		end
		term.setTextColor(palate.menubar.channelmenu.orbtxt)
		term.setBackgroundColor(palate.menubar.channelmenu.bg)
		if std.channel == std.channelNames[a] then
			write("@ ")
		else
			write("O ")
		end
		term.write(" "..std.channelNames[a])
		if term.isColor() then
			term.setBackgroundColor(palate.menubar.channelmenu.borderbg)
		else
			term.setBackgroundColor(colors.black)
		end
		term.setCursorPos(longestLen+2,a+1)
		term.write(" ")
		table.insert(yposes,{a+1,std.channelNames[a],std.channelURLs[std.channelNames[a]]})
	end
	term.setCursorPos(1,#std.channelNames+2)
	term.write((" "):rep(longestLen+2))
	return yposes,longestLen+2
end

local tArg = {...}

if tArg[1] == "help" then
	return displayHelp(true)
elseif tArg[1] == "upgrade" then
	local updateURL = "https://github.com/nothjarnan/axiom/raw/master/Axiom/programs/stdgui.app"
	local res, outcome = getFile(shell.getRunningProgram(),updateURL)
	if not res then
		error(outcome)
	else
		print("Updated STD-GUI to latest version".." ("..outcome.." bytes)")
		return
	end
end

local res, outcome
if tArg[1] == "update" then
	res, outcome = std.getSTDList(std.prevChannel)
	print(outcome)
	return
else
	pleaseWait() --he said please
	res, outcome = std.getSTDList(std.prevChannel)
end


local cleanExit = function()
	term.setTextColor(colors.white)
	term.setBackgroundColor(colors.black)
	term.clear()
	local out
	if pocket then
		out = "Thanks for using STD!"
	else
		out = "Thank you for using STD-GUI!"
	end
	if isSimSoft or isAxiom then
		term.setCursorBlink(false)
	end
--	cprint(out,scr_y/2)
	term.setCursorPos(1,scr_y)
	sleep(0)
	return true, "This shouldn't be an error."
end
local STDdownloadPrompt = function(item)
	term.setCursorPos(1,scr_y)
	for k,v in pairs(std.storeURLs) do
		if item.url == v.url then
			itname = k
			break
		end
	end
	local savepath
	if isAxiom then
		if std.channel == "STD-Media" then
			if (std.storeURLs[itname].catagory == 2) or (std.storeURLs[itname].catagory == 3) then --if nfp or nft
				savepath = fs.combine("Axiom/images",itname)
			else
				savepath = fs.combine("home/".._G.currentUser,itname)
			end
		else
			if std.storeURLs[itname].catagory == 8 then --if an API
				savepath = fs.combine("/home/APIs",itname)
			else
				savepath = fs.combine("/Axiom/programs",itname)..".app"
			end
		end
	else
		bow()
		term.clearLine()
		write("Save as: ")
		savepath = funcread(nil,{},nil,true)
		term.setCursorBlink(false)
	end
	if savepath:gsub(" ","") == "" then
		sleep(0)
		return
	else
		if relativePath then
			savepath = fs.combine(shell.dir(),savepath)
		end
		if fs.exists(savepath) then
			term.setCursorPos(1,scr_y)
			term.clearLine()
			write("Overwrite? (Y/N)")
			local key
			repeat
				_,key = os.pullEvent("char")
			until string.find("yn",key)
			if key == "n" then
				sleep(0)
				return
			end
		end
		term.setCursorPos(1,scr_y)
		term.clearLine()
		term.write("Downloading...")
		local res, outcome = getFile(savepath,item.url)
		term.setCursorPos(1,scr_y)
		term.clearLine()
		if not res then
			term.write(outcome)
			sleep(0.6)
		else
			if isAxiom then
				if (std.storeURLs[itname].catagory ~= 8) and (std.channel ~= "STD-Media") then --no need for an icon for an api, wouldn't you say
					local file = fs.open( fs.combine("home/".._G.currentUser.."/Desktop",itname)..".lnk" , "w")
					file.write(savepath)
					file.close()
				end
			end
			term.write("Downloaded! ("..outcome.." bytes)")
			sleep(0.7)
		end
	end
	return
end

SimSoftDownloadPrompt = function(object)
	local itname
	for k,v in pairs(std.storeURLs) do
		if object.url == v.url then
			itname = k
			break
		end
	end
	term.setCursorPos(1,scr_y)
	bow()
	term.clearLine()
	write("Label?:")
	local custLabel = funcread(_,_,_,true)
	if #custLabel:gsub("%s","") == 0 then
		custLabel = nil
	else
		custLabel = custLabel:sub(1,9)
	end
	term.setCursorPos(1,scr_y)
	term.clearLine()
	term.write("Downloading...")
	local res, outcome = simSoftInstall(object,itname or object.title:gsub(" ","-"),custLabel)
	term.setCursorPos(1,scr_y)
	term.clearLine()
	term.write(outcome)
	sleep(#outcome/13)
end

local doCategoryMenu = function()
	local mcursor = catag --(not term.isColor()) and (catag or 0) or false
	local cats,longth = renderCatagoryMenu(true,mcursor)
	local evt,butt,x,y
	while true do
		local evt,butt,x,y = os.pullEvent()
		if evt == "mouse_click" or (evt == "mouse_up" and y ~= 1) then
			doRedraw = true
			if y == 1 then
				catag = 0
				break
			else
				for a = 1, #cats do
					if cats[a] == y and x <= longth then
						catag = a
						scroll = 1
					end
				end
				break
			end
		elseif evt == "key" then
			if butt == keys.f1 then
				break
			elseif mcursor then
				if (butt == keys.up) and (mcursor > 0) then
					mcursor = mcursor - 1
					doRedraw = true
				elseif (butt == keys.down) and (mcursor < #std.storeCatagoryNames) then
					mcursor = mcursor + 1
					doRedraw = true
				elseif (butt == keys.enter) or (butt == keys.space) then
					os.queueEvent("mouse_click",1,2,mcursor+1)
				end
			end
		end
		if doRedraw then
			renderCatagoryMenu(true,mcursor)
			doRedraw = false
		end
	end
	maxScroll = setMaxScroll(catag)
end

local doChannelMenu = function()
	local mcursor = 1 --(not term.isColor()) and 1 or false
	local yposes, longth = renderChannelMenu(mcursor)
	local evt,butt,x,y
	while true do
		local evt,butt,x,y = os.pullEvent()
		if evt == "mouse_click" or (evt == "mouse_up" and y ~= 1) then
			if y == 1 then break else
				for a = 1, #yposes do
					if (yposes[a][1] == y) and (x <= longth) then
							if std.channel ~= yposes[a][2] then
							std.prevChannel = std.channel
							std.channel = yposes[a][2]
							scroll = 1
							std.getSTDList(std.prevChannel)
						end
						break
					end
				end
				break
			end
		elseif evt == "key" then
			if butt == keys.f3 then
				break
			elseif mcursor then
				if (butt == keys.up) and (mcursor > 1) then
					mcursor = mcursor - 1
				elseif (butt == keys.down) and (mcursor < #std.channelNames) then
					mcursor = mcursor + 1
				elseif (butt == keys.enter) or (butt == keys.space) then
					os.queueEvent("mouse_click",1,2,mcursor+1)
				end
			end
		end
		renderChannelMenu(mcursor)
	end
	maxScroll = setMaxScroll(catag)
end

local STDViewEntry = function(url)
	local contents, outcome = contentsFile(url)
	if not contents then
		term.write(outcome)
		sleep(0.6)
		return
	else
		strless(contents,palate.item.previewtxt,palate.item.previewbg)
	end
end

local doEverything = function() --do I have to do EVERYTHING?
	if fs.exists(std.stdList) then
		shell.run(std.stdList)
	else
		if not std.storeURLs then
			pleaseWait()
			std.getSTDList(std.prevChannel)
		end
	end
	maxScroll = setMaxScroll(catag)
	local yposes
	while true do
		if scroll > maxScroll then
			scroll = maxScroll
		end
		if scroll < 1 then
			scroll = 1
		end
		if (scroll-1 % 4 ~= 0) and (not term.isColor()) then
			scroll = scroll - ((scroll-1) % 4)
		end
		local mcursor = (not term.isColor()) and 1 or false
		yposes = renderStore(std.storeURLs,catag,scroll,scrollX,fixDotY,not term.isColor())
		renderCatagoryMenu(false,mcursor)
		local evt = {getEvents("mouse_scroll","mouse_click","mouse_up","key","mouse_drag","char")}
		scr_x, scr_y = term.getSize()
		if evt[1] == "mouse_scroll" then
			if scroll+evt[2] >= 1 and scroll+evt[2] <= maxScroll then
				scroll = scroll+evt[2]
				doRedraw = true
			end
		elseif evt[1] == "mouse_click" and (evt[2] == 1) and (evt[4] <= scr_y) and (evt[4] >= 1) then --left click only! must deport right mouse buttons!
			if evt[3] == scr_x and evt[4] == math.floor(dotY) then
				doScrollBar = true
			end
			if evt[4] == 1 then
				if evt[3] >= scr_x-4 then
					return cleanExit()
				else
					if evt[3] >= 1 and evt[3] <= 6 then
						doCategoryMenu()
					elseif evt[3] >= 8 and evt[3] <= 14 then
						doChannelMenu()
					end
				end
			elseif yposes[evt[4]-1] and evt[3] ~= scr_x then
				local y = evt[4]-1
				local showPostURL = false
				local guud = yposes[y].title
				scrollX = 1
				while true do
					if not guud then break end
					local event,butt,cx,cy = renderStoreItem(yposes[y],showPostURL)
					if event == "key" then
						if butt == keys.q then
							sleep(0)
							break
						elseif butt == keys.d then --hehe
							sleep(0)
							STDdownloadPrompt(yposes[y])
							--break
						elseif butt == keys.v then
							sleep(0)
							STDViewEntry(yposes[y].url)
							--break
						elseif (butt == keys.i) then
							sleep(0)
							if isSimSoft then
								SimSoftDownloadPrompt(yposes[y])
							elseif isAxiom then
								STDdownloadPrompt(yposes[y]) --axiom only changes the
							end
							--break
						end
					elseif event == "mouse_click" then
						if cy == scr_y then
							if (cx < scr_x-7) or (cx > scr_x) then
								if cx >= scr_x-11 and cx < scr_x-8 then
									term.setCursorPos(1,scr_y)
									bow()
									term.clearLine()
									if pocket or turtle then
										write("Args.: ")
									else
										write("Arguments:")
									end
									local arguments = explode(" ",funcread(nil,{},nil,true)) or {}
									term.setTextColor(colors.white)
									term.setBackgroundColor(colors.black)
									term.clear()
									term.setCursorPos(1,1)
									local oldcpath
									if shell then
										oldcpath = shell.dir()
										shell.setDir("")
									end
									if #arguments == 0 then
										runURL(yposes[y].url)
									else
										runURL(yposes[y].url,unpack(arguments))
									end
									if shell then
										shell.setDir(oldcpath or "")
									end
									sleep(0)
									write("[press a key]")
									os.pullEvent("key")
								elseif cx >= scr_x-16 and cx < scr_x-12 then
									STDViewEntry(yposes[y].url)
								end
								sleep(0)
								break
							else
								term.setCursorPos(1,scr_y)
								bow()
								term.clearLine()
								if isSimSoft then
									SimSoftDownloadPrompt(yposes[y])
									break
								else
									STDdownloadPrompt(yposes[y])
									break
								end
							end
						end
					end
				end
			end
		elseif evt[1] == "mouse_up" then
			doScrollBar = false
			fixDotY = nil
		elseif evt[1] == "mouse_drag" then
			if doScrollBar then
				local my = evt[4]
				if my > scr_y then --operating systems might allow this to be true
					my = scr_y
				elseif my < 1 then --this too
					my = 1
				end
				if my > 1 then
					scroll = math.floor( (my-2)/(scr_y-2) * (maxScroll)) + 1
					fixDotY = my
				end
			end
		elseif evt[1] == "key" then
			if evt[2] == keys.q then
				return cleanExit()
			elseif evt[2] == keys.down then
				scroll = scroll + 4
			elseif evt[2] == keys.up then
				scroll = scroll - 4
			elseif evt[2] == keys.pageDown then
				scroll = scroll + (scr_y-1)
			elseif evt[2] == keys.pageUp then
				scroll = scroll - (scr_y-1)
			elseif evt[2] == keys.home then
				scroll = 1
			elseif evt[2] == keys['end'] then
				scroll = maxScroll
			elseif evt[2] == keys.h then --help screen!
				displayHelp(false)
			elseif evt[2] == keys.right then
				scrollX = scrollX + 1
			elseif evt[2] == keys.left then
				if scrollX > 1 then
					scrollX = scrollX - 1
				end
			elseif (evt[2] == keys.numPadAdd) or (evt[2] == keys.rightBracket) then
				catag = catag + 1
				if catag > #std.storeCatagoryNames then
					catag = 0
				end
				scroll = 1
				maxScroll = setMaxScroll(catag)
			elseif (evt[2] == keys.minus) or (evt[2] == keys.leftBracket) then
				catag = catag - 1
				if catag < 0 then
					catag = #std.storeCatagoryNames
				end
				scroll = 1
				maxScroll = setMaxScroll(catag)
			elseif evt[2] == keys.f5 then
				pleaseWait()
				std.getSTDList(std.prevChannel)
			elseif (evt[2] == keys.f12) and (not isSimSoft) then
				local updateURL = "https://github.com/nothjarnan/axiom/raw/master/Axiom/programs/stdgui.app"
				getFile(shell.getRunningProgram(),updateURL)
				local flashes = {
					colors.black,
					colors.white,
					colors.lightGray,
					colors.gray,
					colors.black,
				}
				for a = 1, #flashes do
					term.setBackgroundColor(flashes[a])
					term.clear()
					sleep(0)
				end
				return
			elseif evt[2] == keys.f1 then
				doCategoryMenu()
			elseif evt[2] == keys.f or evt[2] == keys.f6 then
				--runFile(std.stdList)
				findPrompt()
			elseif evt[2] == keys.f3 then
				doChannelMenu()
			end
		elseif evt[1] == "char" then
			if tonumber(evt[2]) then
				local a = tonumber(evt[2]) ~= "0" and tonumber(evt[2]) or "10"
				local b = (a*4)-1
				os.queueEvent("mouse_click",1,scr_x-3,b)
			end
		end
	end
end

if doDisplayTitle then
	displayTitle()
end

if std.storeURLs then std.storeURLs = getFindList("") end

local errorHandler = function()
	local success, message = pcall(doEverything)
	if success then
		return true
	end
	if message == "Terminated" then
		term.setBackgroundColor(colors.black)
		term.scroll(2)
		term.setCursorPos(1, scr_y-1)
		printError(message)
		return false, message
	else
		term.setBackgroundColor(colors.white)
		for a = 1, math.ceil(scr_y/2) do
			term.scroll(2)
		end
		term.setTextColor(colors.black)
		cprint("STD-GUI has encountered an error!",2)
		term.setCursorPos(1,4)
		term.setTextColor(term.isColor() and colors.red or colors.gray)
		print(message or "".."\n")
		term.setTextColor(colors.black)
		print(" Please contact LDDestroier on either the ComputerCraft forums, or through Discord. (@LDDestroier#2901)")
		sleep(0.5)
		print("\nPush a key.")
		os.pullEvent("key")
		term.setCursorPos(1,scr_y)
		term.setBackgroundColor(colors.black)
		term.setTextColor(colors.white)
		term.clearLine()
		return false, message
	end
end

return errorHandler()
