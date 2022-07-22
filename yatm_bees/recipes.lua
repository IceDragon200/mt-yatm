local mod = assert(yatm_bees)
local bcr = assert(yatm.bees.bait_catches_registry)

-- Bee Queens are rare for bait based catches, it's easier to catch workers and (runaway) princesses
bcr:register_catch(mod:make_name("honey_drop"), mod:make_name("bee_gold_queen_default"), 1)
bcr:register_catch(mod:make_name("honey_drop"), mod:make_name("bee_gold_princess_default"), 3)

bcr:register_catch(mod:make_name("honey_drop"), mod:make_name("bee_silver_queen_default"), 5)
bcr:register_catch(mod:make_name("honey_drop"), mod:make_name("bee_silver_princess_default"), 10)

bcr:register_catch(mod:make_name("honey_drop"), mod:make_name("bee_worker_default"), 200)
