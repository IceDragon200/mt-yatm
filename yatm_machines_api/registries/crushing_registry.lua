-- TODO: work on this registry
local CrushingRegistry = foundation.com.Class:extends("yatm_machines.CrushingRegistry")
local ic = CrushingRegistry.instance_class

function ic:initialize()
end

yatm_machines_api.CrushingRegistry = CrushingRegistry
