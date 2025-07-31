.data
first_msg:   .asciiz "Values are: "
space:       .asciiz " "
comma_space: .asciiz ", "
newline:     .asciiz "\n"
ordered_msg: .asciiz "Ordered values are: "
end_of_p:    .asciiz "END OF PROGRAM\n"

.text
.globl main

# === main ===
main:

    # set values for 3 numbers
    li $t0, 19
    li $t1, 27
    li $t2, 4
    
    # display starting position
    move $a1, $t0
    move $a2, $t1
    move $a3, $t2
    la $a0, first_msg
    jal display_values
    
    jal order_numbers
    
    # display ordered position
    move $a1, $t0
    move $a2, $t1
    move $a3, $t2
    la $a0, ordered_msg
    jal display_values
    
    # Exit
    li $v0, 10
    syscall
    
# === order_numbers(%d, %d, %d) ===
# **USES $t0, $t1, $t2, $a0, $a1, $a2**
# takes 3 numbers and reorderes them by size
# param::0-2 numbers ($t0, $t1, $t2)
# return ($t0, $t1, $t2) where $t0 > $t1 > $t2
order_numbers:
    # save return address and any necessary registers
    addi $sp, $sp, -4
    sw   $ra, 0($sp)
    
    # order numbers (swap1-3)
    move $a0, $t0
    move $a1, $t1
    # swap1
    jal swap_numbers_ge
    move $t0, $a0
    move $a0, $a1
    move $a1, $t2
    # swap2
    jal swap_numbers_ge
    move $t1, $a0
    move $a2, $a1
    move $a1, $t0
    # swap3
    jal swap_numbers_ge
    move $t0, $a0
    move $t1, $a1
    
    # restore return address
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    
    # return to caller
    jr $ra



# === swap_numbers_ge ===
# **USES $a0, $a1, $a2**
# takes $a0, $a1
# returns ($a0, $a1), where $a0 > $a1
swap_numbers_ge:
    blt $a0, $a1, swap_needed
    jr $ra
swap_needed:
    move $a2, $a1
    move $a1, $a0
    move $a0, $a2
    jr $ra

# === display_values ===
# prints a string and three values
# arg0::%s ($a0) -> string to print
# arg1::%d ($a1) -> first value 
# arg1::%d ($a2) -> second value 
# arg1::%d ($a3) -> third value 
display_values:
    # save return address and any necessary registers
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    # string already in $a0
    jal print_string
    # print first number
    move $a0, $a1
    jal print_number
    # print comma space
    la $a0, comma_space
    jal print_string
    # print next number
    move $a0, $a2
    jal print_number
    # print comma space
    la $a0, comma_space
    jal print_string
    # print last number
    move $a0, $a3
    jal print_number
    # print newline
    la $a0, newline
    jal print_string
    
    # restore return address
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    
    # return to caller
    jr $ra
    

# === print_string(%s) ===
# prints a string to the console
# $a0 -> a string to display
print_string:
    li $v0, 4
    syscall
    jr $ra


# === print_number(%d) ===
# prints a number to the console
# $a0 -> a number to print to the console
print_number:
    li $v0, 1
    syscall
    jr $ra
