--[[	        Copyright © 2015 Ysovuka/Kzisor	             ]]
--[[	Copyright © 2016 Edits and additions by Afetogbo	 ]]
local require = GLOBAL.require
local Layouts = require("map/layouts").Layouts
local StaticLayouts = require("map/static_layout")
require("map/level")
local LEVELTYPE = GLOBAL.LEVELTYPE
LEVELTYPE.ALL = "ALL"

local function AddLayout(name)
	Layouts[name] = StaticLayouts.Get("map/static_layout/"..name)
	return name, Layouts[name]
end

local function AddSetPiece(levelid, layout_name, count, tasks, chance)
	chance = chance or 100
	if levelid == LEVELTYPE.ALL then
		AddLevelPreInitAny(function(level)
			if not level.set_pieces then
				level.set_pieces = {}
			end
			level.set_pieces[layout_name] = { count = 0, tasks = tasks }
			for i = 1, count do
				if chance >= math.random(1, 100) then
					level.set_pieces[layout_name].count = level.set_pieces[layout_name].count + 1
				end
			end
		end)

	else 
		AddLevelPreInit(levelid, function(level)
			if not level.set_pieces then
				level.set_pieces = {}
			end
			level.set_pieces[layout_name] = { count = 0, tasks = tasks }
			for i = 1, count do
				if chance >= math.random(1, 100) then
					level.set_pieces[layout_name].count = level.set_pieces[layout_name].count + 1
				end
			end
		end)
	end
end

AddTaskSetPreInitAny(function(task_set_data)
    local task_names = task_set_data.tasks
if GetModConfigData("bluester_config") then
local blue_layout_name, example_layout = AddLayout("blue_chester_set_piece")
AddSetPiece(LEVELTYPE.ALL, blue_layout_name, 1, task_names, 100)
    if GetModConfigData("force_bluester") then
        local function Requirebluester(level)	
            table.insert(level.required_prefabs, "bluechester_eyebone")
        end
        AddLevelPreInit("SURVIVAL_TOGETHER", Requirebluester)
    end
end

if GetModConfigData("daddy_config") then
local bdaddy_layout_name, example_layout = AddLayout("bdaddy_set_piece")
AddSetPiece(LEVELTYPE.ALL, bdaddy_layout_name, 1, task_names, 100)
    if GetModConfigData("force_daddy") then
        local function Requiredaddy(level)	
            table.insert(level.required_prefabs, "bigdaddy_eyebone")
        end
        AddLevelPreInit("SURVIVAL_TOGETHER", Requiredaddy)
    end
end

if GetModConfigData("dubster_config") then
local party_layout_name, example_layout = AddLayout("partylayout")
AddSetPiece(LEVELTYPE.ALL, party_layout_name, 1, task_names, 100)
    if GetModConfigData("force_dubster") then
        local function Requiredubster(level)	
            table.insert(level.required_prefabs, "partybone")
        end
        AddLevelPreInit("SURVIVAL_TOGETHER", Requiredubster)
    end
end

if GetModConfigData("afester_config") then
local afester_layout_name, example_layout = AddLayout("afestertoy")
AddSetPiece(LEVELTYPE.ALL, afester_layout_name, 1, task_names, 100)
    if GetModConfigData("force_afester") then
        local function Requireafester(level)	
            table.insert(level.required_prefabs, "afestertoy")
        end
        AddLevelPreInit("SURVIVAL_TOGETHER", Requireafester)
    end
end

if GetModConfigData("cavester_config") then
local afester_layout_name, example_layout = AddLayout("cavester_set_piece")
AddSetPiece(LEVELTYPE.ALL, afester_layout_name, 1, task_names, 100)
    if GetModConfigData("force_cavester") then
        local function Requirecavester(level)	
            table.insert(level.required_prefabs, "glowbone")
        end
        AddLevelPreInit("SURVIVAL_TOGETHER", Requirecavester)
    end
end

if GetModConfigData("stovester_config") then
local afester_layout_name, example_layout = AddLayout("ladle_set_piece")
AddSetPiece(LEVELTYPE.ALL, afester_layout_name, 1, task_names, 100)
    if GetModConfigData("force_stovester") then
        local function Requirestovester(level)	
            table.insert(level.required_prefabs, "ladle")
        end
        AddLevelPreInit("SURVIVAL_TOGETHER", Requirestovester)
    end
end
end)



