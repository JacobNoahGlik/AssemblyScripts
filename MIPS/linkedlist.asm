# GOAL: LinkedList
# struct Node {
#     int value;       // 4 bytes
#     Node* next;      // 4 bytes (pointer to next node)
# }

.data
newline:        .asciiz "\n"
space:          .asciiz " "
prompt_msg:     .asciiz "Linked list values: "
input_prompt:   .asciiz "Enter a number (or press Enter to finish): "
input_buffer:   .space 16

# === Global Head Pointer ===
head: .word 0

.text
.globl main

main:
    # Initialize list head to NULL
    li   $t0, 0
    la   $t1, head
    sw   $t0, 0($t1)

    # Call request_numbers_from_user
    la   $a0, head
    jal  request_numbers_from_user

    # Print prompt
    la   $a0, prompt_msg
    li   $v0, 4
    syscall

    # Print list
    lw   $a0, head
    jal  print_list

    # Exit
    li $v0, 10
    syscall



# === request_numbers_from_user ===
# Input:
#   $a0 = address of head pointer (e.g., &head)
# Output:
#   None (adds to linked list in-place)

request_numbers_from_user:
    # Save $ra and head pointer address
    addi $sp, $sp, -8
    sw   $ra, 4($sp)
    sw   $a0, 0($sp)       # save address of head

user_input_loop:
    # Print prompt
    la   $a0, input_prompt
    li   $v0, 4
    syscall

    # Read string into buffer
    la   $a0, input_buffer
    li   $a1, 16           # max length
    li   $v0, 8            # syscall 8 = read_string
    syscall

    # Check if first byte is just newline => end input
    lb   $t0, input_buffer
    li   $t1, 0x0A         # '\n' = 10
    beq  $t0, $t1, end_input

    # === Parse input_buffer into integer manually ===
    la   $t3, input_buffer # pointer to string
    li   $t2, 0            # result = 0

parse_loop:
    lb   $t4, 0($t3)       # char = *p
    li   $t5, 10           # newline
    beq  $t4, $t5, parse_done

    li   $t5, 0            # null terminator
    beq  $t4, $t5, parse_done

    li   $t6, 48           # ASCII '0'
    sub  $t4, $t4, $t6     # digit = char - '0'
    mul  $t2, $t2, 10
    add  $t2, $t2, $t4

    addi $t3, $t3, 1
    j    parse_loop

parse_done:
    # $t2 now contains parsed integer

    # Restore head pointer address
    lw   $a0, 0($sp)       # address of head
    move $a1, $t2          # value to insert
    jal  add_node

    j user_input_loop      # repeat

end_input:
    # Restore $ra and return
    lw   $ra, 4($sp)
    addi $sp, $sp, 8
    jr   $ra




# === add_node ===
# Input:
#   $a0 = address of head pointer (e.g., &head)
#   $a1 = value to insert
# Output: none
add_node:
    # Save head address input (caller wants to pass &head via $a0)
    move $t4, $a0        # $t4 = address of head pointer
    move $t5, $a1        # $t5 = value to store

    # Allocate 8 bytes
    li   $a0, 8
    li   $v0, 9
    syscall
    move $t0, $v0        # $t0 = new node address

    # Set node->value = val
    sw   $t5, 0($t0)

    # Set node->next = NULL
    li   $t1, 0
    sw   $t1, 4($t0)

    # Get *head
    lw   $t2, 0($t4)
    beq  $t2, $zero, set_head

    # Traverse to end
traverse:
    lw   $t3, 4($t2)
    beq  $t3, $zero, insert
    move $t2, $t3
    j traverse

insert:
    sw   $t0, 4($t2)
    jr   $ra

set_head:
    sw   $t0, 0($t4)
    jr   $ra
    
    
# === print_list ===
# Input:
#   $a0 = head pointer
# Output:
#   Prints values with newline
print_list:
    beq  $a0, $zero, done_print

    move $t1, $a0     # $t1 = current node pointer

loop:
    lw   $t0, 0($t1)  # value = node->value
    move $a0, $t0
    li   $v0, 1
    syscall

    # Print space
    la   $a0, space
    li   $v0, 4
    syscall

    lw   $t1, 4($t1)  # $t1 = node->next
    bne  $t1, $zero, loop

done_print:
    la   $a0, newline
    li   $v0, 4
    syscall
    jr   $ra
