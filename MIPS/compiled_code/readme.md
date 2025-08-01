# Compiled `MIPS` Based on `C` Code
###### Compiled into `32-bit` `MIPS` code using `GCC`

This folder is created to better understand how compiled `MIPS` code is created from `C` code, how the stack is used to pass data values, and keep track of function calls.

This repo highlights the difference between [hand-written `MIPS`](../hand_written_code) created in the `MARS` emulator, which has several shortcomings due to its intended use in educational environments rather than actual `ASM` writing environments.

## 1. `Point.c` / `Point.s`
The `MIPS` code in [`Point.s`](/point.s) is created by running the following code in `WSL`

```bash
mips-linux-gnu-gcc -S -O0 -mfp32 -o point.s point.c
```

## Breaking down the functions:

### 1. `main()`
```c
int main() {
    Point* origin = new_point(0, 0);
    display_point(origin);
    free_point(origin);
    return 0;
}
```
This converts to:
```asm
main:
    .frame  $fp,40,$31         # stack frame = 40 bytes, $fp is the frame pointer, $31 is return address
    .mask   0xc0000000,-4      # save mask for $fp and $ra (bitmask)
    .fmask  0x00000000,0       # floating-point mask (unused here)
```
Notes:
- These are metadata directives used by debuggers and exception handling
- We will ignore them for the purposes of this repo

```asm
    addiu   $sp,$sp,-40        # allocate 40 bytes on the stack
    sw      $31,36($sp)        # save return address
    sw      $fp,32($sp)        # save previous frame pointer
    move    $fp,$sp            # set new frame pointer
```
Notes:
- This sets up the function prologue:
    - creates a stack frame
    - saves registers
    - establishes `$fp` so that offsets like `28($fp)` can refer to local variables (such as `Point* origin`)
```asm
    move    $5,$0              # move 0 into $a1 (second arg: y)
    move    $4,$0              # move 0 into $a0 (first arg: x)
```
Notes:
- Arguments for `new_point(0, 0)`:
    - `$a0` = `$4` -> first parameter (`x`)
    - `$a1` = `$5` -> second parameter (`y`)
```asm
    .option pic0
    jal     new_point
    nop
```
Notes:
- `jal new_point`: how `gcc` translates a function call
    - Return value will come back in `$2` (`$v0`)
    - Delay slot (the `nop`) is ignored here
```asm
    .option pic2
    sw      $2,28($fp)         # save result (Point* origin) into stack local variable at 28($fp)
```
Which is the same thing as `Point* origin = new_point(0, 0);` in `C`

```asm
    lw      $4,28($fp)         # load origin into $a0
    .option pic0
    jal     display_point
    nop
```
Notes:
- Passes `origin` to `display_point`:
    - `$a0` = `$4` -> pointer to `Point` struct
    - Function expects a pointer, and `display_point` dereferences it to access `.x` and `.y`
 
```asm
    .option pic2
    lw      $4,28($fp)         # load origin again into $a0
    .option pic0
    jal     free_point
    nop
```
Notes:
- Reuses the same pointer to free the memory previously allocated by `new_point`
```asm
    .option pic2
    move    $2,$0              # return 0 (i.e., `return 0;`)
```
Notes:
- Puts `0` into `$2` (`$v0`), which is the standard return value register

```asm
    move    $sp,$fp
    lw      $31,36($sp)
    lw      $fp,32($sp)
    addiu   $sp,$sp,40
    jr      $31
    nop
```
Notes:
- Standard function epilogue:
    - Restores `$ra` and `$fp`
    - Pops the stack frame
    - Jumps back to caller

<br>

### Stack Frame Map:
| Offset    | Purpose                  |
| --------- | ------------------------ |
| `36($fp)` | Return address `$ra`     |
| `32($fp)` | Old frame pointer `$fp`  |
| `28($fp)` | Local variable `origin`  |
| `...`     | Additional scratch space |

<br>

### Main Summary:
| Concept                     | Implementation                                  |
| --------------------------- | ----------------------------------------------- |
| Function arguments          | Passed via `$a0`, `$a1` (`move $4`, `move $5`)  |
| Return value from function  | In `$v0` / `$2` -> saved to stack               |
| Stack-based local variables | Stored at `28($fp)`                             |
| Struct pointer usage        | Stored on stack and passed as a pointer         |
| Function call/return        | Standard `jal`, `$ra`, `jr $ra`, `move $sp,$fp` |



<br>

<br>


### 2. `new_point(int,int)`
```c
Point* new_point(int x, int y) {
    Point* temp = (Point*)malloc(sizeof(Point));
    temp->x = x;
    temp->y = y;
    return temp;
}
```

Overview: Arguments passed in `$a0/$a1`, struct created on heap, fields written via offset, return via `$v0`. Here's the `ASM` code breakdown:

```asm
new_point:
    addiu $sp,$sp,-40        # allocate 40 bytes on the stack
    sw    $31,36($sp)        # save return address
    sw    $fp,32($sp)        # save old frame pointer
    move  $fp,$sp            # set up new frame pointer

    lui   $28,%hi(__gnu_local_gp)
    addiu $28,$28,%lo(__gnu_local_gp)
    .cprestore 16            # store $gp at 16($sp) for global access

    sw    $4,40($fp)         # save argument x to stack
    sw    $5,44($fp)         # save argument y to stack
```
Notes:
- Arguments are initially passed in `$4` and `$5` (`$a0`, `$a1`), but are saved to the stack for later access
- `$fp` is used to reference stack variables consistently

```asm
    li    $4,8               # malloc(8) -> 8 bytes for struct Point
    lw    $2,%call16(malloc)($28)
    move  $25,$2
    .reloc 1f,R_MIPS_JALR,malloc
1:  jalr  $25                # call malloc
    nop
```
Notes:
- This section calls `malloc(8)`
- `$25` holds the target function address (`malloc`), which is part of the `MIPS` calling convention
- `$2` holds the result from `malloc` (the `Point*`)

```asm
    lw    $28,16($fp)        # restore $gp
    sw    $2,28($fp)         # save malloc result (Point* temp) to stack
```
```asm
    lw    $2,28($fp)         # load temp
    lw    $3,40($fp)         # load x
    sw    $3,0($2)           # temp->x = x

    lw    $2,28($fp)         # load temp
    lw    $3,44($fp)         # load y
    sw    $3,4($2)           # temp->y = y
```
Notes:
- This is how struct fields are accessed: `x` is at offset `0`, and `y` is at offset `4`

```asm
    lw    $2,28($fp)         # return temp (in $v0)
    move  $sp,$fp
    lw    $31,36($sp)
    lw    $fp,32($sp)
    addiu $sp,$sp,40
    jr    $31
    nop
```
Notes:
- Return via `$2` (`$v0`), which is the standard function return register in `MIPS:32`

<br>

<br>

### 3. `display_point(const Point*)`

```c
void display_point(const Point* point) {
    printf("Point(%d, %d)\n", point->x, point->y);
}
```

Overview: Uses `lw` to dereference the pointer and extract `x/y`, passes them as arguments to `printf()`

```asm
display_point:
    addiu $sp,$sp,-32
    sw    $31,28($sp)
    sw    $fp,24($sp)
    move  $fp,$sp

    lui   $28,%hi(__gnu_local_gp)
    addiu $28,$28,%lo(__gnu_local_gp)
    .cprestore 16

    sw    $4,32($fp)          # save argument `point` to stack
```
Notes:
- Here `$a0` is the pointer to the struct and is saved to the stack

```asm
    lw    $2,32($fp)          # load Point* into $2
    lw    $3,0($2)            # load point->x into $3
    lw    $2,32($fp)          # reload Point* into $2
    lw    $2,4($2)            # load point->y into $2

    move  $6,$2               # y -> $a2
    move  $5,$3               # x -> $a1
```
Notes:
- Parameters for `printf()`: format string in `$a0`, then args in `$a1/$a2`
- This follows the [`MIPS` calling convention](https://devblogs.microsoft.com/oldnewthing/20180417-00/?p=98525) for [variadic functions](https://www.geeksforgeeks.org/c/variadic-functions-in-c/)

```asm
    lui   $2,%hi($LC0)
    addiu $4,$2,%lo($LC0)     # $a0 = format string
    lw    $2,%call16(printf)($28)
    move  $25,$2
1:  jalr  $25
    nop
```

<br>

<br>

### 4. `free_point(Point*)`

```c
void free_point(Point* point) {
    free(point);
}
```

Overview: basic wrapper around `free()`, passing the pointer via `$a0`

```asm
free_point:
    addiu $sp,$sp,-32
    sw    $31,28($sp)
    sw    $fp,24($sp)
    move  $fp,$sp

    lui   $28,%hi(__gnu_local_gp)
    addiu $28,$28,%lo(__gnu_local_gp)
    .cprestore 16

    sw    $4,32($fp)         # save pointer to stack
    lw    $4,32($fp)         # load pointer into $a0
```
Notes:
- Standard function opening
- Pass pointer to free
```asm
    lw    $2,%call16(free)($28)
    move  $25,$2
1:  jalr  $25
    nop
```

<br>

<br>

| Function        | Params (via) | Stack Use        | Struct Access        | Return |
| --------------- | ------------ | ---------------- | -------------------- | ------ |
| `new_point`     | `$a0/$a1`    | Store x/y & temp | `sw $val, 0/4($ptr)` | `$v0`  |
| `display_point` | `$a0` (ptr)  | Save ptr         | `lw 0/4($ptr)`       | void   |
| `free_point`    | `$a0` (ptr)  | Save ptr         | none                 | void   |



<br>

<br>

<br>

## Realocation Macros:

In compiled code, you'll see a lot of reallocation macros when calling a function or loading large values (16-bit+) into a register.

| Macro               | Meaning                                                                      |
| ------------------- | ---------------------------------------------------------------------------- |
| `%hi(symbol)`       | Upper 16 bits of symbol’s address (for use with `lui`)                       |
| `%lo(symbol)`       | Lower 16 bits of symbol’s address (used after `lui`)                         |
| `%got(symbol)`      | Offset to symbol’s address **in the GOT** (Global Offset Table)              |
| `%call16(symbol)`   | Address of external function **via GOT**, used with `jalr`                   |
| `%gp_rel(symbol)`   | Offset of symbol **relative to `$gp`**, for fast data access                 |
| `%hiadj(symbol)`    | Like `%hi`, but adjusts for negative `%lo` overflow (rarely needed manually) |
| `%tlsgd(symbol)`    | Thread-local storage (TLS) GOT entry (used in multithreaded code)            |
| `%tlsldm(symbol)`   | TLS local dynamic model (also threading-related)                             |
| `%got_disp(symbol)` | Like `%got`, used in newer ABI models                                        |

<br>

`%hi` and `%lo` (not to be confused with `$hi` and `$lo`) are usually used in tandem when copying a value larger than 16 bits into a 32-bit register as instructions like `addiu`, `lw`, `ori`, etc... are only capable of moving 16 bits. To copy all 32 bits of a larger pointer (like one from the `$gp` table) you'd need to do it in two steps:
```asm
lui  $t0, %hi(symbol)        # upper 16 bits
addiu $t0, $t0, %lo(symbol)  # lower 16 bits
```

`%got` and `%call16` are the next most common, used when accessing library / external functions like `printf`, `malloc`, etc. Sample usage:
```asm
lw   $t0, %got(counter)($gp)     # Loads address of counter into $t0
lw   $v0, 0($t0)                 # Loads value of counter
```
```asm
lw   $t9, %call16(malloc)($gp)   # Load address of malloc into $t9
jalr $t9                         # Call it
```


