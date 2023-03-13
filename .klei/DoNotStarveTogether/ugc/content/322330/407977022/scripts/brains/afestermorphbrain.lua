require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/wander"
require "behaviours/doaction"
require "behaviours/useshield"
require "behaviours/follow"

local RUN_AWAY_DIST = 10
local SEE_TARGET_DIST = 6

local MIN_FOLLOW_DIST = 0
local TARGET_FOLLOW_DIST = 3
local MAX_FOLLOW_DIST = 12

local MAX_CHASE_DIST = 7
local MAX_CHASE_TIME = 8
local MAX_WANDER_DIST = 3

local START_RUN_DIST = 8
local STOP_RUN_DIST = 12

local DAMAGE_UNTIL_SHIELD = 150
local SHIELD_TIME = 3
local AVOID_PROJECTILE_ATTACKS = false

local afestermorphBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function GetFaceTargetFn(inst)
    return inst.components.follower.leader
end

local function KeepFaceTargetFn(inst, target)
    return inst.components.follower.leader == target
end

function afestermorphBrain:OnStart()
    local root =
        PriorityNode(
        {
            WhileNode( function() return self.inst.components.hauntable and self.inst.components.hauntable.panic end, "PanicHaunted", Panic(self.inst)),
            WhileNode( function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),
            IfNode(function() return self.inst:HasTag("spister") end, "IsHider", 
                UseShield(self.inst, DAMAGE_UNTIL_SHIELD, SHIELD_TIME, AVOID_PROJECTILE_ATTACKS)),
            ChaseAndAttack(self.inst, MAX_CHASE_TIME),
            Follow(self.inst, function() return self.inst.components.follower.leader end, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),
            IfNode(function() return self.inst.components.follower.leader ~= nil end, "HasLeader",
				FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn )),
            Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, MAX_WANDER_DIST)            
        },1)
    
    
    self.bt = BT(self.inst, root)
    
         
end

return afestermorphBrain
