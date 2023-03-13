require("stategraphs/commonstates")

local actionhandlers = 
{
}

local events=
{
    CommonHandlers.OnStep(),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnLocomote(false,true),
    EventHandler("attacked", function(inst)
        if inst.components.health and not inst.components.health:IsDead() then
            inst.sg:GoToState("hit")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/chester/hurt")
        end
    end),
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
    EventHandler("entershield", function(inst) inst.sg:GoToState("shield") end),
    EventHandler("exitshield", function(inst) inst.sg:GoToState("shield_end") end),
    EventHandler("attacked", function(inst) 
        if not inst.components.health:IsDead() then 
            if inst:HasTag("spitster") then
                if not inst.sg:HasStateTag("attack") then 
                    inst.sg:GoToState("hit")
                end
            elseif not inst.sg:HasStateTag("shield") then
                inst.sg:GoToState("hit")
            end
        end 
    end),
    EventHandler("doattack", function(inst, data) 
        if not inst.components.health:IsDead() and not inst.sg:HasStateTag("busy") then 
            if inst:HasTag("spister") then
                inst.sg:GoToState("attack", data.target) 
            elseif inst:HasTag("spitster") and
                data.target:IsValid() and
                inst:GetDistanceSqToInst(data.target) > TUNING.SPIDER_SPITTER_MELEE_RANGE*TUNING.SPIDER_SPITTER_MELEE_RANGE then
                --Do spit attack
                inst.sg:GoToState("spitter_attack", data.target)
            end
        end 
    end),
}

local states=
{
    State{
        name = "idle",
        tags = {"idle", "canrotate"},
        
        onenter = function(inst, pushanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle_loop")
            
            if not inst.sg.mem.pant_ducking or inst.sg:InNewState() then
				inst.sg.mem.pant_ducking = 1
			end
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },

        timeline=
        {
            TimeEvent(7*FRAMES, function(inst) 
				inst.sg.mem.pant_ducking = inst.sg.mem.pant_ducking or 1
				inst.SoundEmitter:PlaySound("dontstarve/creatures/chester/pant", nil, inst.sg.mem.pant_ducking) 
				if inst.sg.mem.pant_ducking and inst.sg.mem.pant_ducking > .35 then
					inst.sg.mem.pant_ducking = inst.sg.mem.pant_ducking - .05
				end
			end),
        },        
   },
   
    State{
        name = "death",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.components.container:Close()
            inst.components.container:DropEverything()
            inst.SoundEmitter:PlaySound("dontstarve/creatures/chester/death")
            inst.AnimState:PlayAnimation("death")
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)            
        end,
    },
    

    State{
        name = "open",
        tags = {"busy", "open"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.components.sleeper:WakeUp()
            inst.AnimState:PlayAnimation("open")
        end,

        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("open_idle") end ),
        },

        timeline=
        {
            TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/chester/open") end),
        },        
    },

    State{
        name = "open_idle",
        tags = {"busy", "open"},
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle_loop_open")
            
            if not inst.sg.mem.pant_ducking or inst.sg:InNewState() then
				inst.sg.mem.pant_ducking = 1
			end
            
        end,

        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("open_idle") end ),
        },

        timeline=
        {
        
        
            TimeEvent(3*FRAMES, function(inst) 
				inst.sg.mem.pant_ducking = inst.sg.mem.pant_ducking or 1
				inst.SoundEmitter:PlaySound("dontstarve/creatures/chester/pant", nil, inst.sg.mem.pant_ducking) 
				if inst.sg.mem.pant_ducking and inst.sg.mem.pant_ducking > .35 then
					inst.sg.mem.pant_ducking = inst.sg.mem.pant_ducking - .05
				end
			end),
        },        
    },

    State{
        name = "close",
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("closed")
        end,

        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },

        timeline=
        {
            TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/chester/close") end),
        },
	},
    
    State{
        name = "attack",
        tags = {"attack", "busy"},
        
        onenter = function(inst, target)
            inst.Physics:Stop()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("atk")
            inst.sg.statemem.target = target
        end,
        
        timeline=
        {
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spider/Attack") end),
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spider/attack_grunt") end),
            TimeEvent(25*FRAMES, function(inst) inst.components.combat:DoAttack(inst.sg.statemem.target) end),
        },
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "spitter_attack",
        tags = {"attack", "canrotate", "busy", "spitting"},

        onenter = function(inst, target)
            if inst.weapon and inst.components.inventory then 
                inst.components.inventory:Equip(inst.weapon)
            end
            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("spit")
        end,

        onexit = function(inst)
            if inst.components.inventory then
                inst.components.inventory:Unequip(EQUIPSLOTS.HANDS)
            end
        end,

        timeline =
        {
            TimeEvent(17*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/wilson/blowdart_shoot") end),
            TimeEvent(20*FRAMES, function(inst) inst.components.combat:DoAttack() end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    }, 

    State{
        name = "shield",
        tags = {"busy", "shield"},

        onenter = function(inst)
            --If taking fire damage, spawn fire effect. 
            inst.components.health:SetAbsorptionAmount(TUNING.ROCKY_ABSORB)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("hide")
            inst.AnimState:PushAnimation("hide_loop")
        end,

        onexit = function(inst)
            inst.components.health:SetAbsorptionAmount(0)
        end,
    },

    State{
        name = "shield_end",
        tags = {"busy", "shield"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("unhide")            
        end,

        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },
	
    State{
        name = "transition",
        tags = {"busy"},
        onenter = function(inst)
            inst.Physics:Stop()

            --Remove ability to open chester for short time.
            inst.components.container:Close()
            inst.components.container.canbeopened = false

            inst.SoundEmitter:PlaySound("dontstarve/creatures/chester/raise")

            inst.AnimState:PlayAnimation("idle_loop")
            inst.AnimState:PushAnimation("idle_loop")
            inst.AnimState:PushAnimation("idle_loop")
            inst.AnimState:PushAnimation("transition", false)
        end,

        onexit = function(inst)
            --Add ability to open chester again.
            inst.components.container.canbeopened = true
            --Remove light shaft
            if inst.sg.statemem.light then
                inst.sg.statemem.light:TurnOff()
            end
        end,

        timeline = 
        {
            TimeEvent(56*FRAMES, function(inst) 
                local x, y, z = inst.Transform:GetWorldPosition()
                SpawnPrefab("chester_transform_fx").Transform:SetPosition(x, y + 1, z)
            end),
            TimeEvent(60*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/chester/pop")
                if inst.MorphAfester ~= nil then
                    inst:MorphAfester()
                end
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },
    State{
        name = "hit",
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("hit")
            inst.Physics:Stop()            
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },  
}

CommonStates.AddWalkStates(states, {
    walktimeline = 
    { 
        --TimeEvent(0*FRAMES, function(inst)  end),
        TimeEvent(1*FRAMES, function(inst) 
            inst.SoundEmitter:PlaySound("dontstarve/creatures/chester/boing")
            inst.components.locomotor:RunForward() 
        end),
        --TimeEvent(12*FRAMES, function(inst) PlayFootstep(inst) end),
        TimeEvent(14*FRAMES, function(inst) 
            PlayFootstep(inst)
            inst.components.locomotor:WalkForward()
        end),
    }
}, nil, true)

CommonStates.AddSleepStates(states,
{
    starttimeline = 
    {
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/chester/close") end)
    },
    waketimeline = 
    {
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/chester/open") end)
    },
})

CommonStates.AddSimpleState(states, "hit", "hit", {"busy"})


return StateGraph("SGafestermorph", states, events, "idle", actionhandlers)

