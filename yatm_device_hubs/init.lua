--
-- YATM Device Hubs
--
-- Hubs are attachments that can be placed in the network to enable certain
-- functions for that network.
--
-- For example, attaching a wireless hub allows a network to communicate with another
-- yatm network for sharing information.
--
local mod = foundation.new_module("yatm_device_hubs", "0.1.0")

mod:require("api.lua")

mod:require("nodes.lua")
