CFLAGS=-std=gnu11 -O2 -mssse3 -Wall -Wextra -Wpedantic -no-pie -g

.PHONY: all clean
all: main
main: main.c bmpOpt.S bmp.S 
	$(CC) $(CFLAGS) -o $@ $^
clean:
	rm -f main
