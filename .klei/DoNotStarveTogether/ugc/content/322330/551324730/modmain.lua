-- GLOBAL.CHEATS_ENABLED = true
-- GLOBAL.require('debugkeys')

for _,v in pairs(GLOBAL.AllRecipes) do
   v.min_spacing = 1
end

AddPrefabPostInit("dug_berrybush", function(inst)
    if inst.components.deployable then
        inst.components.deployable:SetDeploySpacing(GLOBAL.DEPLOYSPACING.MEDIUM)
    end
end)
