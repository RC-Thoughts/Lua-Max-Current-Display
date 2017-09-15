--[[
	---------------------------------------------------------
	Max Current is Lua application enabling user with small
    telemetry-window showing max current.
    
	Settings: Select sensor and reset-switch. Reset only
    works when current-value is zero or sensor is not 
    connected. (For example power off in model)
    
	Localisation-file has to be as /Apps/Lang/RCT-MaxC.jsn
    
	---------------------------------------------------------
	Max Current is a part of RC-Thoughts Jeti Tools.
	---------------------------------------------------------
	Released under MIT-license by Tero @ RC-Thoughts.com 2016
	---------------------------------------------------------
--]]
collectgarbage()
----------------------------------------------------------------------
-- Locals for the application
local senso, senid, sid, sparam, senpa, switch
local curCurrent, maxCurrent = 0, 0
local sensoLalist = {"..."}
local sensoIdlist = {"..."}
local sensoPalist = {"..."}
local repeatlist = {}
----------------------------------------------------------------------
-- Read translations
local function setLanguage()
    local lng=system.getLocale()
    local file = io.readall("Apps/Lang/RCT-MaxC.jsn")
    local obj = json.decode(file)
    if(obj) then
        trans12 = obj[lng] or obj[obj.default]
    end
end
--------------------------------------------------------------------------------
-- Draw telemetry-window
local function printMaxCurrent()
	lcd.drawText(145 - lcd.getTextWidth(FONT_BIG,string.format("%.0f", maxCurrent)),0,string.format("%.0f", maxCurrent),FONT_BIG)
end
--------------------------------------------------------------------------------
-- Read available sensors for user to select
local sensors = system.getSensors()
for i,sensor in ipairs(sensors) do
	if (sensor.label ~= "") then
		table.insert(sensoLalist, string.format("%s", sensor.label))
		table.insert(sensoIdlist, string.format("%s", sensor.id))
		table.insert(sensoPalist, string.format("%s", sensor.param))
    end
end
----------------------------------------------------------------------
-- Store settings when changed by user
local function sensorChanged(value)
	senso=value
	senid=value
	senpa=value
	system.pSave("senso",value)
	system.pSave("senid",value)
	system.pSave("senpa",value)
	sid = string.format("%s", sensoIdlist[senid])
	sparam = string.format("%s", sensoPalist[senpa])
	if (sid == "...") then
		sid = 0
		sparam = 0
    end
	system.pSave("sid", sid)
	system.pSave("sparam", sparam)
end

local function switchChanged(value)
	switch = value
	system.pSave("switch",value)
end
----------------------------------------------------------------------
-- Draw the main form (Application inteface)
local function initForm()
	form.addRow(1)
	form.addLabel({label="---     RC-Thoughts Jeti Tools      ---",font=FONT_BIG})
    
	-- Battery 1
	form.addRow(1)
	form.addLabel({label=trans12.appName,font=FONT_BOLD})
    
	form.addRow(2)
	form.addLabel({label=trans12.selSensor})
	form.addSelectbox(sensoLalist,senso,true,sensorChanged)
    
	form.addRow(2)
	form.addLabel({label=trans12.selSwitch})
	form.addInputbox(switch, true, switchChanged)
    
	form.addRow(1)
	form.addLabel({label="Powered by RC-Thoughts.com - v."..maxcVersion.." ",font=FONT_MINI, alignRight=true})
    collectgarbage()
end
----------------------------------------------------------------------
-- Runtime functions
local function loop()
	local sense = system.getSensorByID(sid, sparam)
    local switch = system.getInputsVal(switch)
	if(sense and sense.valid) then
        if (sense.value > maxCurrent) then
            maxCurrent = sense.value
        end
        if (switch == 1 and sense.value == 0) then
            maxCurrent = 0
        end
    else
        if (switch == 1) then
            maxCurrent = 0
        end
    end
    collectgarbage()
end
----------------------------------------------------------------------
-- Application initialization
local function init()
	system.registerForm(1,MENU_APPS,trans12.appName,initForm)
	senso = system.pLoad("senso",0)
	senid = system.pLoad("senid",0)
	senpa = system.pLoad("senpa",0)
	sid = system.pLoad("sid",0)
	sparam = system.pLoad("sparam",0)
	switch = system.pLoad("switch")
    system.registerTelemetry(1,trans12.winLabel,1,printMaxCurrent)
    collectgarbage()
end
----------------------------------------------------------------------
maxcVersion = "1.0"
setLanguage()
collectgarbage()
return {init=init, loop=loop, author="RC-Thoughts", version=maxcVersion, name=trans12.appName}