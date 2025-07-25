.data
start_msg:   .asciiz "Starting Array:    "
lth_msg:     .asciiz "Low-to-High Array: "
htl_msg:     .asciiz "High-to-Low Array: "
space:       .asciiz " "
comma_space: .asciiz ", "
newline:     .asciiz "\n"
array:       .word 19, 4, 27, 11, 8
array_size:  .word 5

.text
.globl main

# === main ===
main:
    # ##########
    # show starting array:
    la   $a0, start_msg  # prefix
    la   $a1, array      # array pointer
    lw   $a2, array_size # array size
    jal print_array
    

    # ##########
    # order a given array from lowest to highest
    la   $a0, array      # array pointer
    lw   $a1, array_size # array size
    li   $a2, 0          # 0 = increasing order
    jal order
    
    # ##########
    # print out result:
    la   $a0, lth_msg    # prefix
    la   $a1, array      # array pointer
    lw   $a2, array_size # array size
    jal print_array
    
    # ##########
    # order a given array from highest to lowest
    la   $a0, array      # array pointer
    lw   $a1, array_size # array size
    li   $a2, 1          # 1 = decreasing order
    jal order
    
    # ##########
    # print out result:
    la   $a0, htl_msg    # prefix
    la   $a1, array      # array pointer
    lw   $a2, array_size # array size
    jal print_array
   
    # ##########
    # Exit
    li $v0, 10
    syscall
    

# === order ===
# Sorts an array of integers in-place
# Input:
#   $a0 = base address of array
#   $a1 = size of array (n)
#   $a2 = direction flag (0 = ascending, 1 = descending)
# Output:
#   array is modified in-place
order:
    # Save $ra
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    move $t0, $a0       # base address
    move $t5, $a2       # direction flag (0 or 1)

    addi $t8, $a1, -1   # outer loop upper bound: n - 1
    li   $t1, 0         # i = 0

outer_loop:
    bge  $t1, $t8, done

    li   $t2, 0         # j = 0

inner_loop:
    sub  $t9, $a1, $t1
    addi $t9, $t9, -1   # n - i - 1
    bge  $t2, $t9, end_inner

    # Load current and next elements
    mul  $t6, $t2, 4
    add  $t6, $t6, $t0
    lw   $t3, 0($t6)        # arr[j]
    lw   $t4, 4($t6)        # arr[j+1]

    # Determine if we should swap based on direction
    beq  $t5, 0, check_increasing
    # Direction == 1 -> decreasing
    blt  $t3, $t4, do_swap
    j    skip_swap

check_increasing:
    bgt  $t3, $t4, do_swap
    j    skip_swap

do_swap:
    # Swap arr[j] and arr[j+1]
    sw   $t4, 0($t6)
    sw   $t3, 4($t6)

skip_swap:
    addi $t2, $t2, 1
    j    inner_loop

end_inner:
    addi $t1, $t1, 1
    j    outer_loop

done:
    # Restore $ra and return
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra
    


# === print_array ===
# Input:
#   $a0 = prefix string
#   $a1 = array pointer
#   $a2 = array size (n)
print_array:
    # Prologue
    addi $sp, $sp, -8
    sw   $ra, 4($sp)
    sw   $s0, 0($sp)

    # Print prefix
    li   $v0, 4
    syscall

    li   $t0, 0          # i = 0
    move $s0, $a1        # $s0 = base address of array

print_loop:
    bge  $t0, $a2, end_print

    # Load arr[i] into $t3 and print it
    mul  $t1, $t0, 4
    add  $t1, $s0, $t1
    lw   $t3, 0($t1)     # store value in $t3
    move $a0, $t3
    li   $v0, 1
    syscall

    # Check if this is the last element
    addi $t5, $t0, 1
    bge  $t5, $a2, print_newline  # if i+1 >= size, skip comma

    # Print comma-space
    la   $a0, comma_space
    li   $v0, 4
    syscall

    # If printed value < 10, print extra space
    li   $t4, 10
    blt  $t3, $t4, print_align_space

skip_align_space:
    addi $t0, $t0, 1
    j    print_loop

print_align_space:
    la   $a0, space
    li   $v0, 4
    syscall
    j skip_align_space

print_newline:
    la   $a0, newline
    li   $v0, 4
    syscall

end_print:
    # Epilogue
    lw   $ra, 4($sp)
    lw   $s0, 0($sp)
    addi $sp, $sp, 8
    jr   $ra

