------------------------------------------------------
-- MetaHunt: Hunter's Toolkit Addon
-- A unified addon merging FeedOMatic, Tooltips, and zhunter
-- Modern modular architecture with legacy addon support
--
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- TARGET RUNTIME: LUA 5.0 (WoW 1.12 / Turtle-WoW)
--   - Max 32 upvalues per function
--   - No # operator (use table.getn)
--   - No string.gmatch (use string.gfind)
--   - NEVER validate with Lua 5.1+ tools (false passes)
--   - Errors: check Logs/FrameXML.log first
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
------------------------------------------------------

-- Initialize beast database after all files loaded
if MTH_DS_OnLoad then
	MTH_DS_OnLoad()
end
