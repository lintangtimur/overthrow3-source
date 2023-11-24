function GameMode:SpawnOrbDrop(spawn_point, orb_type, should_launch, on_destroyed_callback)
	EmitGlobalSound("Item.PickUpGemWorld")

	local capture_point = CreateUnitByName("npc_dummy_capture", spawn_point, false, nil, nil, DOTA_TEAM_NEUTRALS)
	capture_point:SetAbsOrigin(spawn_point)
	capture_point:AddNewModifier(capture_point, nil, "capture_point_area", { orb_type = orb_type, should_launch = should_launch })
	capture_point.on_destroyed_callback = on_destroyed_callback

	local particle_name = "particles/orb_common.vpcf"
	if orb_type == UPGRADE_RARITY_RARE then
		particle_name = "particles/orb_rare.vpcf"
	end
	if orb_type == UPGRADE_RARITY_EPIC then
		particle_name = "particles/orb_epic.vpcf"
	end

	if SeasonalEvents:IsChristmas() then particle_name = "particles/orb_christmas.vpcf" end

	capture_point.orb_fx = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, capture_point)

	return capture_point
end

-- models/props_winter/present.vmdl
