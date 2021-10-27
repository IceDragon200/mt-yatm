all:
	make -C yatm_oku

.PHONY : luacheck
luacheck:
	luacheck .
