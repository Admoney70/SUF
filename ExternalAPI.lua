--[[
	API overrides from external addons that augment the data missing in the Classic API
]]
ShadowUF = select(2, ...)
ShadowUF.API = {}

-- Threat colors
function ShadowUF.API.GetThreatStatusColor(state)
	if( state == 3 ) then
		return 1, 0, 0
	elseif( state == 2 ) then
		return 1, 0.6, 0
	elseif( state == 1 ) then
		return 1, 1, 0.47
	else
		return 0.69, 0.69, 0.69
	end
end

--[[
	Compatibility shims for APIs that are being phased out across the Classic clients.

	The C_Spell/C_UnitAuras namespaces have been rolled out to the Classic clients, while the old
	global functions are deprecated and disappear one flavor at a time. Everything below prefers the
	new API when the client offers it and falls back to the old global otherwise, so the addon keeps
	working on every Classic flavor (Classic Era, Anniversary and MoP Classic).
]]
local C_Spell = C_Spell
local C_UnitAuras = C_UnitAuras

-- Spell information
function ShadowUF.API.GetSpellName(spell)
	if( not spell or spell == "" ) then return nil end
	if( C_Spell and C_Spell.GetSpellName ) then
		return C_Spell.GetSpellName(spell)
	end

	return (GetSpellInfo(spell))
end

function ShadowUF.API.GetSpellTexture(spell)
	if( not spell or spell == "" ) then return nil end
	if( C_Spell and C_Spell.GetSpellTexture ) then
		return C_Spell.GetSpellTexture(spell)
	end

	return (select(3, GetSpellInfo(spell)))
end

function ShadowUF.API.GetSpellNameAndTexture(spell)
	if( not spell or spell == "" ) then return nil end
	if( C_Spell and C_Spell.GetSpellInfo ) then
		local info = C_Spell.GetSpellInfo(spell)
		if( not info ) then return nil end
		return info.name, info.iconID
	end

	local name, _, texture = GetSpellInfo(spell)
	return name, texture
end

function ShadowUF.API.IsSpellUsable(spell)
	if( not spell or spell == "" ) then return false end
	if( C_Spell and C_Spell.IsSpellUsable ) then
		return (C_Spell.IsSpellUsable(spell))
	end

	return (IsUsableSpell(spell))
end

-- Auras, the old UnitAura global is gone on the newer clients and replaced by aura data tables
local function unpackAuraData(aura)
	if( not aura ) then return nil end
	if( AuraUtil and AuraUtil.UnpackAuraData ) then
		return AuraUtil.UnpackAuraData(aura)
	end

	return aura.name, aura.icon, aura.applications, aura.dispelName, aura.duration, aura.expirationTime,
		aura.sourceUnit, aura.isStealable, aura.nameplateShowPersonal, aura.spellId, aura.canApplyAura,
		aura.isBossAura, aura.isFromPlayerOrPlayerPet, aura.nameplateShowAll, aura.timeMod
end

ShadowUF.API.UnpackAuraData = unpackAuraData

if( C_UnitAuras and C_UnitAuras.GetAuraDataByIndex ) then
	function ShadowUF.API.UnitAura(unit, index, filter)
		return unpackAuraData(C_UnitAuras.GetAuraDataByIndex(unit, index, filter))
	end
else
	function ShadowUF.API.UnitAura(unit, index, filter)
		return UnitAura(unit, index, filter)
	end
end

-- Phasing, UnitInPhase is being replaced by UnitPhaseReason.
-- Defined as a global on purpose, the config mode swaps the function environment of the modules to
-- fake unit data, which only works for globals.
if( not UnitInPhase and UnitPhaseReason ) then
	function UnitInPhase(unit)
		return not UnitPhaseReason(unit)
	end
elseif( not UnitInPhase ) then
	function UnitInPhase(unit)
		return true
	end
end

-- Not every event exists on every client, UNIT_HEALTH_FREQUENT for example was folded back into
-- UNIT_HEALTH. Registering an unknown event throws an error, so let the callers check first.
local validEvents = {}
local eventValidationFrame

function ShadowUF.API.IsEventValid(event)
	if( validEvents[event] == nil ) then
		if( C_EventUtils and C_EventUtils.IsEventValid ) then
			validEvents[event] = C_EventUtils.IsEventValid(event) and true or false
		else
			eventValidationFrame = eventValidationFrame or CreateFrame("Frame")

			local valid = pcall(eventValidationFrame.RegisterEvent, eventValidationFrame, event)
			if( valid ) then
				eventValidationFrame:UnregisterEvent(event)
			end

			validEvents[event] = valid
		end
	end

	return validEvents[event]
end
