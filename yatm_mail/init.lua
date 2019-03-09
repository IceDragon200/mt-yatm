--[[
YATM Mail, offers simple mailboxes for dropping off letters and packages.

And yes, it also provides the letters and packages.
]]
yatm_mail = rawget(_G, "yatm_mail") or {}
yatm_mail.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_mail.modpath .. "/util.lua")
dofile(yatm_mail.modpath .. "/nodes.lua")
dofile(yatm_mail.modpath .. "/items.lua")
