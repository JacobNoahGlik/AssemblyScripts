## Setup
```bash
sudo apt update
sudo apt install gcc-arm-linux-gnueabi qemu-user
```

This installs:
- `arm-linux-gnueabi-gcc`: cross-compiling C and linking assembly
- `arm-linux-gnueabi-as`: assembler
- `arm-linux-gnueabi-ld`: linker
- `qemu-arm`: to run ARM binaries on `x86` (emulates a `32-bit` `ARM` CPU)

## Compile and Run:
```
arm-linux-gnueabi-gcc -static -o square.elf square.s
qemu-arm ./square.elf
```

### Compile and run the calculator the same way:
```
arm-linux-gnueabi-gcc -static -o calculator.elf calculator.s
qemu-arm ./calculator.elf
```
This is what it should look like:
```
/arm# qemu-arm ./calculator.elf
> 9 + 7
       = 16
> 26/13
       = 2
> 91 * 46 - 300
               = 3886
>
/arm# 
```
