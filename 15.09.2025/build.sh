rm *.bin *.img

nasm -f bin ktb16.asm -o ktb16.bin

dd if=/dev/zero of=ktb16.img bs=512 count=2880
dd if=ktb16.bin of=ktb16.img bs=512 count=1 conv=notrunc

nasm -f bin demo.asm -o demo.bin

dd if=/dev/zero of=demo.img bs=512 count=2880
dd if=demo.bin of=demo.img bs=512 count=1 conv=notrunc
