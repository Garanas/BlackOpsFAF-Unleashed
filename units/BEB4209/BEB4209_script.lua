-----------------------------------------------------------------
-- File     :  /cdimage/units/XEB4309/XEB4309_script.lua
-- Author(s):  David Tomandl, Jessica St. Croix
-- Summary  :  UEF Radar Jammer Script
-- Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------

local TStructureUnit = import('/lua/terranunits.lua').TStructureUnit

BEB4209 = Class(TStructureUnit) {
    AntiTeleport = {
        '/effects/emitters/seraphim_shield_generator_t3_03_emit.bp',
        '/effects/emitters/seraphim_shield_generator_t2_03_emit.bp',
    },

    OnStopBeingBuilt = function(self,builder,layer)
        TStructureUnit.OnStopBeingBuilt(self,builder,layer)
        self:SetScriptBit('RULEUTC_ShieldToggle', true)
        self:DisableUnitIntel('unitScript', 'CloakField') -- Used to show anti-tele range
        self.antiteleportEmitterTable = {}
        self.AntiTeleportBag = {}
        self:ForkThread(self.ResourceThread)
    end,

    OnScriptBitSet = function(self, bit)
        TStructureUnit.OnScriptBitSet(self, bit)
        if bit == 0 then
        self:ForkThread(self.antiteleportEmitter)
        self:SetMaintenanceConsumptionActive()

        if not self.Rotator2 then
            self.Rotator2 = CreateRotator(self, 'Spinner_middle', 'y')
            self.Trash:Add(self.Rotator2)
        end
            self.Rotator2:SetTargetSpeed(500)
            self.Rotator2:SetAccel(100)
        end
    end,

    AntiteleportEffects = function(self)
        if self.AntiTeleportBag then
            for k, v in self.AntiTeleportBag do
                v:Destroy()
            end
            self.AntiTeleportBag = {}
        end
        for k, v in self.AntiTeleport do
            table.insert(self.AntiTeleportBag, CreateAttachedEmitter(self, 'Effect01', self:GetArmy(), v):ScaleEmitter(0.1))
            table.insert(self.AntiTeleportBag, CreateAttachedEmitter(self, 'Effect01', self:GetArmy(), v):ScaleEmitter(0.1):OffsetEmitter(0, -0.5, 0))
            table.insert(self.AntiTeleportBag, CreateAttachedEmitter(self, 'Effect01', self:GetArmy(), v):ScaleEmitter(0.1):OffsetEmitter(0, 0.5, 0))
            table.insert(self.AntiTeleportBag, CreateAttachedEmitter(self, 'Effect02', self:GetArmy(), v):ScaleEmitter(0.1))
            table.insert(self.AntiTeleportBag, CreateAttachedEmitter(self, 'Effect02', self:GetArmy(), v):ScaleEmitter(0.1):OffsetEmitter(0, -0.5, 0))
            table.insert(self.AntiTeleportBag, CreateAttachedEmitter(self, 'Effect02', self:GetArmy(), v):ScaleEmitter(0.1):OffsetEmitter(0, 0.5, 0))
            table.insert(self.AntiTeleportBag, CreateAttachedEmitter(self, 'Effect03', self:GetArmy(), v):ScaleEmitter(0.1))
            table.insert(self.AntiTeleportBag, CreateAttachedEmitter(self, 'Effect03', self:GetArmy(), v):ScaleEmitter(0.1):OffsetEmitter(0, 0.5, 0))
            table.insert(self.AntiTeleportBag, CreateAttachedEmitter(self, 'Effect04', self:GetArmy(), v):ScaleEmitter(0.1))
            table.insert(self.AntiTeleportBag, CreateAttachedEmitter(self, 'Effect04', self:GetArmy(), v):ScaleEmitter(0.1):OffsetEmitter(0, -0.5, 0))
            table.insert(self.AntiTeleportBag, CreateAttachedEmitter(self, 'Effect05', self:GetArmy(), v):ScaleEmitter(0.1))
            table.insert(self.AntiTeleportBag, CreateAttachedEmitter(self, 'Effect05', self:GetArmy(), v):ScaleEmitter(0.1):OffsetEmitter(0, 0.5, 0))
            table.insert(self.AntiTeleportBag, CreateAttachedEmitter(self, 'Effect06', self:GetArmy(), v):ScaleEmitter(0.1))
            table.insert(self.AntiTeleportBag, CreateAttachedEmitter(self, 'Effect06', self:GetArmy(), v):ScaleEmitter(0.1):OffsetEmitter(0, -0.5, 0))
        end
    end,

    OnScriptBitClear = function(self, bit)
        TStructureUnit.OnScriptBitClear(self, bit)
        if bit == 0 then
        self:ForkThread(self.KillantiteleportEmitter)
        self:SetMaintenanceConsumptionInactive()

            if not self.Rotator2 then
                self.Rotator2 = CreateRotator(self, 'Spinner_middle', 'y')
                self.Trash:Add(self.Rotator2)
            end
            self.Rotator2:SetTargetSpeed(0)
            self.Rotator2:SetAccel(100)
        end
    end,

    antiteleportEmitter = function(self)
        if not self.Dead then
            WaitSeconds(0.5)
            if not self.Dead then
                -- Gets the platforms current orientation
                local platOrient = self:GetOrientation()

                -- Gets the current position of the platform in the game world
                local location = self:GetPosition('BEB4209')

                -- Creates our antiteleportEmitter over the platform with a ranomly generated Orientation
                local antiteleportEmitter = CreateUnit('beb0004', self:GetArmy(), location[1], location[2], location[3], platOrient[1], platOrient[2], platOrient[3], platOrient[4], 'Land')

                -- Adds the newly created antiteleportEmitter to the parent platforms antiteleportEmitter table
                table.insert (self.antiteleportEmitterTable, antiteleportEmitter)

                -- Sets the platform unit as the antiteleportEmitter parent
                antiteleportEmitter:SetParent(self, 'beb4209')
                antiteleportEmitter:SetCreator(self)
                self.Trash:Add(antiteleportEmitter)
            end
        end
    end,

    KillantiteleportEmitter = function(self, instigator, type, overkillRatio)
        -- Small bit of table manipulation to sort thru all of the avalible rebulder bots and remove them after the platform is dead
        if table.getn({self.antiteleportEmitterTable}) > 0 then
            for k, v in self.antiteleportEmitterTable do
                IssueClearCommands({self.antiteleportEmitterTable[k]})
                IssueKillSelf({self.antiteleportEmitterTable[k]})
            end
        end
    end,

    ResourceThread = function(self)
        if not self.Dead then
            local energy = self:GetAIBrain():GetEconomyStored('Energy')

            -- Check to see if the player has enough mass / energy
            if  energy <= 10 then
                self:SetScriptBit('RULEUTC_ShieldToggle', false)
                self:ForkThread(self.ResourceThread2)
            else
                self:ForkThread(self.EconomyWaitUnit)
            end
        end
    end,

    EconomyWaitUnit = function(self)
        if not self.Dead then
        WaitSeconds(2)
            if not self.Dead then
                self:ForkThread(self.ResourceThread)
            end
        end
    end,

    ResourceThread2 = function(self)
        if not self.Dead then
            local energy = self:GetAIBrain():GetEconomyStored('Energy')
            if  energy >= 3000 then
                self:SetScriptBit('RULEUTC_ShieldToggle', true)
                self:ForkThread(self.ResourceThread)
            else
                self:ForkThread(self.EconomyWaitUnit2)
            end
        end
    end,

    EconomyWaitUnit2 = function(self)
        if not self.Dead then
        WaitSeconds(2)
            if not self.Dead then
                self:ForkThread(self.ResourceThread2)
            end
        end
    end,
}

TypeClass = BEB4209
