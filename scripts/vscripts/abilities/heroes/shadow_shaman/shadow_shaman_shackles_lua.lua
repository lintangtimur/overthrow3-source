shadow_shaman_shackles_lua = class({})
LinkLuaModifier("modifier_shadow_shaman_serpent_ward_chc", "abilities/heroes/shadow_shaman/modifier_shadow_shaman_serpent_ward_chc", LUA_MODIFIER_MOTION_NONE)

function shadow_shaman_shackles_lua:GetAssociatedSecondaryAbilities()
	return "shadow_shaman_mass_serpent_ward_lua"
end

function shadow_shaman_shackles_lua:GetChannelTime()
	self.duration = self:GetSpecialValueFor("channel_time")

	if IsClient() then
		return self.duration
	end

	if IsValidEntity(self.shackle_target) then
		return self.duration * (1 - self.shackle_target:GetStatusResistance())
	end

	return 0
end

function shadow_shaman_shackles_lua:OnSpellStart()
	-- unit identifier
	local target = self:GetCursorTarget()
	local caster = self:GetCaster()
	self.shackle_target = target

	-- cancel if linken
	if target:TriggerSpellAbsorb(self) then
		Timers:CreateTimer(0.01, function()
			if not IsValidEntity(self) then return end
			self:EndChannel(true)
		end)
		return
	end

	local duration = self:GetSpecialValueFor("channel_time")

	-- Total Damage and tick damage is calculated in the modifier
	target:AddNewModifier(caster, self, "modifier_shadow_shaman_shackles", {duration = duration})

	--Summon Shard Serpent Wards
	local msw_ability = caster:FindAbilityByName("shadow_shaman_mass_serpent_ward_lua")
	if msw_ability and msw_ability:IsTrained() then
		local ward_count = self:GetSpecialValueFor("ward_count")
		local ward_duration = self:GetSpecialValueFor("ward_duration")
		local ward_spawn_radius = self:GetSpecialValueFor("ward_spawn_radius")

		msw_ability:SummonWards(target:GetAbsOrigin(), ward_count, ward_duration, ward_spawn_radius, target)
	end

	-- Particles
	EmitSoundOn("Hero_ShadowShaman.shackles.Cast", caster)

	self.shackles_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_shadowshaman/shadowshaman_shackle.vpcf", PATTACH_POINT_FOLLOW, target)
	ParticleManager:SetParticleControlEnt(self.shackles_pfx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.shackles_pfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.shackles_pfx, 3, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.shackles_pfx, 4, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)

	ParticleManager:SetParticleControlEnt(self.shackles_pfx, 5, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.shackles_pfx, 6, caster, PATTACH_POINT_FOLLOW, "attach_attack2", caster:GetAbsOrigin(), true)
end

function shadow_shaman_shackles_lua:OnChannelFinish()
	StopSoundOn("Hero_ShadowShaman.Shackles", self:GetCaster())
	if self.shackles_pfx then
		ParticleManager:DestroyParticle(self.shackles_pfx, false)
		ParticleManager:ReleaseParticleIndex(self.shackles_pfx)
	end
end
