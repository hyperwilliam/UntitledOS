:: I Designed This Script To Run On Windows!
nasm -f bin src/bootloader/boot.asm -o build/boot.bin
i686-elf-gcc -ffreestanding -c -m32 -fno-stack-protector -fno-builtin src/kernel/kernel.c -o src/kernel/kernel.o
i686-elf-ld -T linker.ld -o build/kernel.bin src/kernel/kernel.o
fsutil file createnew build/disk.img 1474560
dd if=build/boot.bin of=build/disk.img bs=512 count=1 conv=notrunc
dd if=build/kernel.bin of=build/disk.img bs=512 count=16 seek=1 conv=notrunc
qemu-system-i386 -fda build/boot.bin
