:: You Might Need MSYS For this
mkdir build
nasm -f bin src/bootloader/boot.asm -o build/boot.bin
nasm -f bin src/kernel/kernel.asm -o build/kernel.bin
dd if=/dev/zero of=build/kernel.img bs=512 count=2880
dd if=build/boot.bin of=build/kernel.img conv=notrunc
dd if=build/kernel.bin of=build/kernel.img seek=1 conv=notrunc
qemu-system-i386 -fda kernel.img
