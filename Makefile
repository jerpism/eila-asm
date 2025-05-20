NASM_SOURCES = $(wildcard kernel/*.s drivers/*.s)
OBJ = ${NASM_SOURCES:.s=.o}

all: os-image kernel.elf

run: all
	qemu-system-i386 -s os-image

os-image: boot/boot.bin kernel.bin
	cat $^ > os-image

kernel.elf : kernel/entry.o ${OBJ}
	ld -m elf_i386 -o $@ -Ttext 0x1000 $^ 
	objcopy --only-keep-debug $@ kernel.sym

kernel.bin : kernel.elf
	objcopy -O binary $< $@


%.o : %.s
	nasm $< -g -f elf32 -o $@

%.bin : %.s
	nasm $< -g -f bin -o $@

boot.bin : boot.s
	nasm $< -f bin -o $@


clean:
	rm -rf *.bin *.o *.dis *.map os-image
	rm -rf kernel/*.o boot/*.bin
