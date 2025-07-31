.data
prompt_msg:  .asciiz "Enter a number to square: "
result_msg:  .asciiz " squared = "
newline:     .asciiz "\n"

.text
.globl main

# === main ===
main:
    # Call input(prompt_msg)
    la $a0, prompt_msg
    jal input              # result in $v0
    move $t0, $v0          # Save input in $t0

    # Call square($t0)
    move $a0, $t0
    jal square
    move $t1, $v0          # Save result in $t1

    # Print input
    move $a0, $t0
    li $v0, 1
    syscall

    # Print " squared = "
    la $a0, result_msg
    li $v0, 4
    syscall

    # Print result
    move $a0, $t1
    li $v0, 1
    syscall

    # Print newline
    la $a0, newline
    li $v0, 4
    syscall

    # Exit
    li $v0, 10
    syscall


# === input(prompt_str) ===
# $a0 = pointer to prompt string
# returns: $v0 = integer input
input:
    li $v0, 4              # print_string
    syscall

    li $v0, 5              # read_int
    syscall                # result in $v0
    jr $ra


# === square(n) ===
# $a0 = input number
# returns: $v0 = a0 * a0
square:
    mul $v0, $a0, $a0
    jr $ra
