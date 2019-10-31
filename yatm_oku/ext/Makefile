.PHONY : default_target
default_target: all

%.o: %.c
	gcc -fPIC -Wall -Werror -c $< -o $@

%.so: %.o
	gcc -fPIC -shared -Wall -Werror -lc $< -o $@

.PHONY : all
all: oku_6502.so oku_riscv_rv32i.so oku_8086.so
