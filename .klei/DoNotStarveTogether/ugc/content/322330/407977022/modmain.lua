--[[	           Copyright © 2016 Afetogbo	             ]]
local require = GLOBAL.require
local containers = require "containers"
local container_params = containers.params
local STRINGS = GLOBAL.STRINGS
PrefabFiles = {
    "family_commands"
}

if GetModConfigData("bluester_config") then
    table.insert(PrefabFiles, "bluechester")
    table.insert(PrefabFiles, "bluechester_eyebone")

    STRINGS.NAMES.BLUECHESTER = "Bluster"
    STRINGS.CHARACTERS.GENERIC.DESCRIBE.BLUECHESTER = "It should be BLUE!"
    GLOBAL.chilltime = GetModConfigData("chilltime")

    STRINGS.NAMES.BLUECHESTER_EYEBONE = "Bluish Eyebone"
    STRINGS.CHARACTERS.GENERIC.DESCRIBE.BLUECHESTER_EYEBONE = "If I eat this would it still follow me?"
end

container_params.afester = GLOBAL.deepcopy(container_params.chester)
container_params.bigdaddy = GLOBAL.deepcopy(container_params.shadowchester)
container_params.bluechester = GLOBAL.deepcopy(container_params.chester)
container_params.cavester = GLOBAL.deepcopy(container_params.shadowchester)
container_params.partychester = GLOBAL.deepcopy(container_params.shadowchester)
container_params.stovester = GLOBAL.deepcopy(container_params.shadowchester)


if GetModConfigData("daddy_config") then
    table.insert(PrefabFiles, "bigdaddy")
    table.insert(PrefabFiles, "bigdaddy_eyebone")

    GLOBAL.STRINGS.NAMES.BIGDADDY = "Big Daddy"
    GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.BIGDADDY = "This guy is huge!"

    GLOBAL.STRINGS.NAMES.BIGDADDY_EYEBONE = "Daddybone"
    GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.BIGDADDY_EYEBONE = "Daddys got a bone."

    

local params={} 

params.daddysbelly =
{
    widget =
    {
        slotpos = {},
        pos = GLOBAL.Vector3(0, 200, 0),
        side_align_tip = 160,
    },
    type = "chest",
}

for y = 3, 0, -1 do
    for x = -1, 3 do
        table.insert(params.daddysbelly.widget.slotpos, GLOBAL.Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 80, 0))
    end
end

local containers = require "containers"
containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, params.daddysbelly.widget.slotpos ~= nil and #params.daddysbelly.widget.slotpos or 0)
local old_widgetsetup = containers.widgetsetup
function containers.widgetsetup(container, prefab, data)
        local pref = prefab or container.inst.prefab
        if pref == "daddysbelly" then
                local t = params[pref]
                if t ~= nil then
                        for k, v in pairs(t) do
                                container[k] = v
                        end
                        container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
                end
        else
                return old_widgetsetup(container, prefab)
        end
    end
end
    --[[
    local old_widgetsetup = containers.widgetsetup
    function containers.widgetsetup(container, prefab, data)
        local pref = prefab or container.inst.prefab
        if pref == "daddysbelly" then
            local t = params[pref]
            if t ~= nil then
                for k, v in pairs(t) do
                    container[k] = v
                end
                container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
            end
        else
            return old_widgetsetup(container, prefab)
        end
    end
    --]]

if GetModConfigData("dubster_config") then
    table.insert(PrefabFiles, "partychester")
    table.insert(PrefabFiles, "partybone")

    GLOBAL.STRINGS.NAMES.PARTYCHESTER = "Dubster"
    GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.PARTYCHESTER = "I either want to feed him or hit him in the face!"

    GLOBAL.STRINGS.NAMES.PARTYBONE = "partystick"
    GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.PARTYBONE = "I could start a party with this stick."
end

if GetModConfigData("afester_config") then
    Assets = {
        Asset("IMAGE", "minimap/afester.tex"),
        Asset("ATLAS", "minimap/afester.xml")
    }
    AddMinimapAtlas("minimap/afester.xml")

    table.insert(PrefabFiles, "afester")
    table.insert(PrefabFiles, "afestertoy")

    STRINGS.NAMES.AFESTER = "Afester"
    STRINGS.CHARACTERS.GENERIC.DESCRIBE.AFESTER = "Well that's different!"

    STRINGS.NAMES.AFESTERTOY = "Afesters Rope"
    STRINGS.CHARACTERS.GENERIC.DESCRIBE.AFESTERTOY = "Ewww... slobber!"
end

if GetModConfigData("cavester_config") then
    table.insert(PrefabFiles, "cavester")
    table.insert(PrefabFiles, "glowbone")

    STRINGS.NAMES.CAVESTER = "Cavester"
    STRINGS.CHARACTERS.GENERIC.DESCRIBE.CAVESTER = "It looks dirty!"

    STRINGS.NAMES.GLOWBONE = "Cavesters Glowstick"
    STRINGS.CHARACTERS.GENERIC.DESCRIBE.GLOWBONE = "How does it glow?"
end

if GetModConfigData("stovester_config") then
    table.insert(PrefabFiles, "stovester")
    table.insert(PrefabFiles, "ladle")

    STRINGS.NAMES.STOVESTER = "Stovester"
    STRINGS.CHARACTERS.GENERIC.DESCRIBE.STOVESTER = "I smell something cooking!"

    STRINGS.NAMES.LADLE = "A Ladle"
    STRINGS.CHARACTERS.GENERIC.DESCRIBE.LADLE = "Stovester keeps eyeballing it!"
end

--STRINGS.NAMES.DUMSTER = "dumster"
--STRINGS.CHARACTERS.GENERIC.DESCRIBE.BLUECHESTER = "I think he feels sick"

--STRINGS.NAMES.DUMSTER_EYEBONE = "dumster Eyebone"
--STRINGS.CHARACTERS.GENERIC.DESCRIBE.BLUECHESTER_EYEBONE = "If I feed this to him will he feel better?"
