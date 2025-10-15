:: You Might Need MSYS For this
nasm -f bin boot.asm -o boot.bin
nasm -f bin kernel.asm -o kernel.bin
dd if=/dev/zero of=kernel.img bs=512 count=2880
dd if=boot.bin of=kernel.img conv=notrunc
dd if=kernel.bin of=kernel.img seek=1 conv=notrunc
qemu-system-i386 -fda kernel.img
