local assets={ 
    Asset("ANIM", "anim/daisyhat.zip"),
    Asset("ANIM", "anim/daisyhat_swap.zip"), 

    Asset("ATLAS", "images/inventoryimages/daisyhat.xml"),
    Asset("IMAGE", "images/inventoryimages/daisyhat.tex"),
}

local prefabs = 
{
}

local function daisyhat_disable(inst)
    if inst.updatetask then
        inst.updatetask:Cancel()
        inst.updatetask = nil
    end

end

local banddt = 1

local function pigqueen_update( inst )
    local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
	
    if owner and owner.components.leader then
        local x,y,z = owner.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x,y,z, TUNING.ONEMANBAND_RANGE, {"pig"}, {'werepig'})
        for k,v in pairs(ents) do
            if v.components.follower and not v.components.follower.leader  and not owner.components.leader:IsFollower(v) and owner.components.leader.numfollowers < 10 then
                owner.components.leader:AddFollower(v)

            end
        end
		
        for k,v in pairs(owner.components.leader.followers) do
            if k:HasTag("pig") and k.components.follower then
                k.components.follower:AddLoyaltyTime(0.2)
            end
        end	
    else
        local x,y,z = inst.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x,y,z, TUNING.ONEMANBAND_RANGE, {"pig"}, {'werepig'})
        for k,v in pairs(ents) do
            if v.components.follower and not v.components.follower.leader  and not inst.components.leader:IsFollower(v) and inst.components.leader.numfollowers < 10 then
                inst.components.leader:AddFollower(v)

            end
        end
        for k,v in pairs(inst.components.leader.followers) do
            if k:HasTag("pig") and k.components.follower then
                k.components.follower:AddLoyaltyTime(0.2)
            end
        end

    end
end

local function daisyhat_enable(inst)
    inst.updatetask = inst:DoPeriodicTask(banddt, pigqueen_update, 1)
end

local function OnEquip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_hat", "daisyhat_swap", "swap_hat")
        owner.AnimState:Show("HAT")
        owner.AnimState:Hide("HAT_HAIR")
        owner.AnimState:Hide("HAIR_NOHAT")
        owner.AnimState:Show("HAIR")

		daisyhat_enable(inst)	
	
		inst.isWeared = true
		inst.isDropped = false

	
end

local function OnUnequip(inst, owner) 
        owner.AnimState:Hide("HAT")
        owner.AnimState:Hide("HAT_HAIR")
        owner.AnimState:Show("HAIR_NOHAT")
        owner.AnimState:Show("HAIR")
		daisyhat_disable(inst)
		inst.isWeared = false
		inst.isDropped = false

	end
	
	

local function fn(Sim)

    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
	inst.entity:AddNetwork()      
	
	inst:AddTag("hat")
    
    anim:SetBank("daisyhat")
    anim:SetBuild("daisyhat")
    anim:PlayAnimation("idle")
	
	if not TheWorld.ismastersim then
        return inst
    end
    

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/daisyhat.xml"
    
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)

	inst.components.inventoryitem.keepondeath = true



    return inst
end

return  Prefab("daisyhat", fn, assets, prefabs)