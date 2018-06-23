-- Requires PeripheralsPlusOne to function

local isRaining = false
local isSnow = false
local temp = "0"
local envscanner = nil
local sides = {"front","back","left","right","top","bottom"}
local rainTips = {"Better grab a jacket!","Hope you have an umbrella","Better stay inside!","Nothing like a little refreshing rain!"}
local snowTips = {"Brr, freezing."}


for k,v in ipairs(sides) do
  if peripheral.isPresent(v) then
    if peripheral.getType(v) == "environmentScanner" then
      envscanner = v
    end
  end

end

local function click(x, y)

end

local function draw()
  if temp ~= nil then
    print(temp.."°C")
    if isRaining then
      print(rainTips[math.random(1,#rainTips)])
    end
    if isSnow then
      print(snowTips[math.random(1,#snowTips)])
    end
  end
end

local function getWeather()
  if envscanner then
    temp = envscanner.getTemperature()
    isRaining = envscanner.isRaining()
    isSnow = envscanner.isSnow()
  end
end
