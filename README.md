# ![YATM Logo](logo.png) YATM

YATM - Yet Another Tech Mod.

While YATM was originally made as a minecraft mod, I never did enjoy working in Java, so I ported the (incomplete) mod over to minetest and lived happily ever after.

Check each mod for it's own README on what it does.

## Requirements

* Minetest 5.4.x (optinoally with LuaJIT for some mods (needed for bit and ffi modules))

## Dependencies

* [`foundation`](https://github.com/IceDragon200/mt-foundation)

## Optional

* `mesecons`

## Tests

You may notice a tests/ directory in some of the mod directories, this uses the 'Luna' test module that I originally wrote for a love2d game.
Luna was then ported to minetest (along with the Class modules).

It's a rather simple unit test framework that runs during startup, for now tests run on startup, and usually complete within milliseconds, but this will be toggable later once everything has stabilized.

## Installation

Grab the latest release or master, master tends to be playable.

Add `yatm_core` and `yatm_oku` to your trusted_mods list in minetest's settings.

Or you can just not add them, the mods will disable certain sections and post warnings in the logs.

Some sections will have slower fallback implementations while some features are just completely impossible.

__Why does yatm_core and yatm_oku require an insecure_environment?__

yatm_core needs bit and ffi, same with yatm_oku.

yatm_core needs it for it's binary buffers which is a faster alternative to its string buffers.
These buffers are used to load binary encoded files used by some of the other mods.

The bit module is needed for bit operations in various parts of the code especially in oku which needs to perform bit manipulation.

A lua implementation is provided for the bit module and will allow the binary buffer to exist, however it will be slower than a more native version.

I can promise the worse that will happen is minetest crashes due to a reading mistake.

## Game and Modpack creators

YATM has an optional dependency called `yatm_prelude`, which is purposely not present in this codebase.

It is intended to be used to preconfigure YATM for a game or modpack, simply create a `yatm_prelude` mod in the game or modpack's mods directory and add the configuration settings in the init.lua.

As of this writing YATM doesn't really have any settings that can be preconfigured to affects its behaviour

## `yatm_prelude` Configuration

This section will be populated when there are actual options to configure.
