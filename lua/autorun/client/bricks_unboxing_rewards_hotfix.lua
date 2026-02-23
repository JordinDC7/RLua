-- Hotfix for Bricks Unboxing rewards panel nil-button runtime error.
-- This patch wraps only the affected Refresh implementation and logs structured failures.

local HOTFIX_TAG = "[RLua][BricksUnboxingHotfix]"
local TARGET_SOURCE = "bricks_server_unboxingmenu_rewards.lua"

--- Detects whether an error matches the known nil button failures in the rewards panel.
--- @param errorMessage string
--- @return boolean
local function isNilButtonError(errorMessage)
	errorMessage = string.lower(tostring(errorMessage or ""))

	if string.find(errorMessage, "field 'button'", 1, true) then
		return true
	end

	if not string.find(errorMessage, "button", 1, true) then
		return false
	end

	return string.find(errorMessage, "nil value", 1, true) ~= nil
end

--- Emits a structured log entry for the hotfix.
--- @param level string
--- @param message string
--- @param context table|nil
local function log(level, message, context)
	context = context or {}
	local payload = "{}"
	if util and util.TableToJSON then
		payload = util.TableToJSON(context) or "{}"
	end
	MsgC(Color(120, 210, 255), string.format("%s[%s] %s %s\n", HOTFIX_TAG, level, message, payload))
end

--- Tries to patch the Bricks rewards panel Refresh method once available.
--- @return boolean
local function applyPatch()
	if not vgui or not vgui.GetControlTable or not debug or not debug.getinfo then
		return false
	end

	for _, panelName in ipairs(vgui.GetControlTableNames() or {}) do
		local controlTable = vgui.GetControlTable(panelName)
		if controlTable and isfunction(controlTable.Refresh) and not controlTable.__rluaRewardsPatched then
			local info = debug.getinfo(controlTable.Refresh, "S") or {}
			local source = tostring(info.short_src or info.source or "")
			if string.find(source, TARGET_SOURCE, 1, true) then
				local original = controlTable.Refresh
				controlTable.Refresh = function(self, ...)
					local ok, result = xpcall(function()
						return original(self, ...)
					end, debug.traceback)

					if ok then
						return result
					end

					if isNilButtonError(result) then
						log("warn", "Suppressed nil button error in rewards panel Refresh", {
							panel = panelName,
							error = result
						})
						return
					end

					error(result)
				end

				controlTable.__rluaRewardsPatched = true
				log("info", "Patched rewards panel Refresh", { panel = panelName, source = source })
				return true
			end
		end
	end

	return false
end

if not applyPatch() then
	hook.Add("InitPostEntity", "RLua.BricksUnboxingRewardsPatch", function()
		if applyPatch() then
			hook.Remove("InitPostEntity", "RLua.BricksUnboxingRewardsPatch")
		end
	end)
end
