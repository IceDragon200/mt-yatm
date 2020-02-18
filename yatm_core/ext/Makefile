INCLUDE_DIRS=-I./include/ -I.

.PHONY : default_target
default_target: all

%.o: %.c
	gcc $(INCLUDE_DIRS) -fPIC -Wall -Werror -O3 -c $< -o $@

%.so: %.o
	gcc $(INCLUDE_DIRS) -fPIC -shared -Wall -Werror -lc $< -o $@

.PHONY : all
all: yatm_core_utils.so

clean:
	rm -v *.so
