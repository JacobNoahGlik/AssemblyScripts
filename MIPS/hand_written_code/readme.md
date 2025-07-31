# MIPS Assembly
##### Here are my scripts for MIPS

<br>

## Compiler
I used [MARS](https://dpetersanderson.github.io/download.html) a java based MIPS compiler

<br>

## Scripts
1. [square](square.asm) is a MIPS file that squares the user's input and displays it to the console
2. [order three numbers](order_three_numbers.asm) is a MIPS script that takes three numbers, displays them, orders them from largest to smallest, and displays the ordered result.
    - Sorting algorithm used: manual bubble sort
3. [sort an integer array of any size](sort_int_array.asm) is a MIPS script that sorts an integer array of a given size from largest to smallest or smallest to largest. It also displays the resulting array.
    - Sorting algorithm used: bubble sort
        - an outer loop (regiter `$t1`) and an inner loop (register `$t2`)
        - each inner loop compares `arr[j]` and `arr[j+1]`, and swaps if needed
        - On each outer loop iteration, the largest/smallest element "bubbles" to its correct position
