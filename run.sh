#!/usr/bin/bash

# /home/cutiedeng/Downloads/qemu-5.0.0/riscv64-linux-user/qemu-riscv64 zig-out/bin/zig-core

/home/cutiedeng/Downloads/qemu-5.0.0/riscv64-softmmu/qemu-system-riscv64 \
-machine virt \
-nographic \
-bios rustsbi-qemu.bin \
-device loader,file=zig-out/bin/out.bin,addr=0x80200000 $*