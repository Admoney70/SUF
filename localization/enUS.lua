local ShadowUF = select(2, ...)
local L = {}
--@localization(locale="enUS", format="lua_additive_table")@

-- The English strings are the keys themselves, so anything the localization
-- table doesn't carry falls back to the key rather than being nil. This also
-- keeps a packaged build working when it was built without the localization
-- data, which would otherwise leave every string empty.
ShadowUF.L = setmetatable(L, {
	__index = function(tbl, value)
		rawset(tbl, value, value)
		return value
	end,
})
