-- Shared stub file to satisfy DarkRP modification loader when group chats are disabled.
-- Keeping this file non-empty prevents "Not running script ... it's too short" warnings.

if SERVER then
	AddCSLuaFile()
end

DarkRP = DarkRP or {}
DarkRP.CustomGroupChats = DarkRP.CustomGroupChats or {}
