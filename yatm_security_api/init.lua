--
-- YATM Security API
--
local mod = foundation.new_module("yatm_security_api", "0.0.2")

mod:require("api.lua")

mod:require("security_features.lua")

if foundation.com.Luna then
  mod:require("tests.lua")
end
