--
-- YATM Security API
--
local mod = foundation.new_module("yatm_security_api", "0.0.2")

mod:require("api.lua")

mod:require("security_features.lua")

mod:require("tests.lua")
