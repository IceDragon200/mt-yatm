--
-- YATM Radio Network
--

--- @namespace yatm_radio_network
local mod = foundation.new_module("yatm_radio_network", "0.3.0")

yatm = rawget(_G, "yatm") or {}

mod:require("radio_network.lua")
mod:require("api.lua")

if foundation.com.Luna then
  mod:require("tests/radio_network_test.lua")
end
