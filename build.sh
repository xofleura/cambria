#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

echo "Building Cambria..."
SECONDS=0

nasm -f bin boot.asm -o cambria.img

size=$(stat -c %s cambria.img)

if [ "$size" -ne 512 ]; then
    echo "Error: expected 512 bytes, got $size"
    exit 1
fi

signature=$(od -An -tx1 -j510 -N2 cambria.img | tr -d ' \n')

if [ "$signature" != "55aa" ]; then
    echo "Error: bad BIOS: $signature"
    exit 1
fi

echo "Cambria assembled in $SECONDS seconds successfully!"
echo "Boot sector: $size bytes"
echo "BIOS signature: valid"
