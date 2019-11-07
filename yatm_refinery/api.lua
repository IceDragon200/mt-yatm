local VapourRegistry = assert(yatm_refinery.VapourRegistry)
local DistillationRegistry = assert(yatm_refinery.DistillationRegistry)

yatm.refinery = {
  vapour_registry = VapourRegistry:new(),
  distillation_registry = DistillationRegistry:new(),
}
