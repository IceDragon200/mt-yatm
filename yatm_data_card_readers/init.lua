--
-- YATM Data Card Readers
-- This was split from mesecon locks with the data-only card readers
--
local mod = foundation.new_module("yatm_data_card_readers", "1.0.0")

mod:require("api.lua")

mod:require("nodes.lua")
mod:require("items.lua")

mod:require("migrations.lua")
