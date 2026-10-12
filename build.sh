
#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

echo "Building Cambria..."

nasm -f bin stage1.asm -o stage1.bin
nasm -f bin stage2.asm -o stage2.bin

stage1_size=$(stat -c %s stage1.bin)
stage2_size=$(stat -c %s stage2.bin)

if (( stage1_size != 512 )); then
    echo "Error: stage 1 must be 512 bytes, got $stage1_size"
    exit 1
fi

if (( stage2_size == 0 || stage2_size > 4096 )); then
    echo "Error: stage 2 must fit within 8 sectors, got $stage2_size bytes"
    exit 1
fi

signature=$(od -An -tx1 -j510 -N2 stage1.bin | tr -d ' \n')

if [[ "$signature" != "55aa" ]]; then
    echo "Error: invalid BIOS boot signature"
    exit 1
fi

truncate -s 0 cambria.img
truncate -s 1474560 cambria.img

dd if=stage1.bin of=cambria.img conv=notrunc status=none
dd if=stage2.bin of=cambria.img bs=512 seek=1 \
    conv=notrunc status=none

echo "Cambria built successfully."
echo "Stage 1: $stage1_size bytes"
echo "Stage 2: $stage2_size bytes"
echo "BIOS signature: valid"

