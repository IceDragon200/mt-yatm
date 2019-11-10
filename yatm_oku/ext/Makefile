INCLUDE_DIRS=-Iinclude -I.

.PHONY : default_target
default_target: all

%.o: %.c
	gcc $(INCLUDE_DIRS) -fPIC -Wall -Werror -O3 -c $< -o $@

%.so: %.o
	gcc -fPIC -shared -Wall -Werror -lc $< -o $@

.PHONY : all
all: oku_6502.so oku_sm6502.so oku_65816.so oku_8086.so oku_riscv_rv32i.so

clean:
	rm -v *.so
