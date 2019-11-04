# ![YATM Logo](logo.png) YATM

YATM - Yet Another Tech Mod.

While YATM was originally made as a minecraft mod, I never did enjoy working in Java, so I ported the (incomplete) mod over to minetest and lived happily ever after.

Check each mod for it's own README on what it does.

## Requirements

* Minetest 5.x.x with LuaJIT (bit and ffi modules)

## Optional

* `mesecons`

## Tests

You may notice a tests/ directory in some of the mod directories, this uses the 'Luna' test module that I originally wrote for a love2d game ported over to minetest (along with the Class module).

It's a rather simple unit test framework that runs during startup, for now tests run on startup, and usually complete within milliseconds, but this will be toggable later.

## Installation

Grab the latest release or master, master tends to be playable.

Add yatm_core and yatm_oku to your trusted_mods list.

Or you can just not add them, the mods will disable certain sections and post warnings in the logs.

__Why does yatm_core and yatm_oku require an insecure_environment?__

yatm_core needs bit and ffi, same with yatm_oku.

yatm_core needs it for it's binary buffers which is a faster alternative to it's string buffers.
These buffers are used to load binary encoded files used by some of the other mods.

The bit module is needed for bit operations in various parts of the code especially in oku which needs to perform bit manipulation.

I can promise the worse that will happen is minetest crashes due to a reading mistake.
