if yatm_machines then
  local compacting_registry = assert(yatm.compacting.compacting_registry)
  local reg = compacting_registry:method("register_compacting_recipe")

  reg(
    "yatm_woodcraft:compact_saw_dust",
    -- It requires 4x more sawdust to make a packed sawdust block
    ItemStack("yatm_woodcraft:sawdust 36"),
    ItemStack("yatm_woodcraft:packed_sawdust_block 1"),
    5.0
  )
else
  print("yatm_woodcraft: skipping compacting recipes")
end
