.global main
.extern printf, fgets, sscanf, strcmp, stdin

.data
prompt:     .asciz "> "
input_buf:  .space 128
result_fmt: .asciz " = %d\n"
newline:    .asciz "\n"
hello_msg:  .asciz "Hello, world!\n"
debug_fmt: .asciz "\nr0=%d r1=%d r2=%d r3=%d r4=%d\n"

.text
main:
    push {lr}

loop:
    ldr r0, =prompt
    bl  printf

    ldr r0, =input_buf     @ char *fgets(char *str, int n, FILE *stream)
    mov r1, #128
    ldr r2, =stdin
    ldr r2, [r2]           @ r2 = FILE* (dereference symbol pointer)
    bl fgets

    ldr r0, =input_buf
    bl  is_empty_input     @ returns 1 if input is empty
    cmp r0, #1
    beq exit

    ldr r0, =input_buf
    bl  get_result         @ r0 = result
    mov r1, r0             @ r1 = result

    ldr r2, =input_buf     @ r2 = input_buf
    mov r5, r1             @ r5 = result
    bl  print_padded_result

    b loop

exit:
    pop {lr}
    bx lr


@ === print_padded_result ===
@ r5 = result to print
@ r2 = pointer to input string
print_padded_result:
    push {r0-r4, lr}

    mov r3, r2          @ r3 = original pointer to input
    mov r4, #0          @ r4 = length counter

    mov r6, r3          @ use r6 for iteration so r3 stays intact
count_loop:
    ldrb r0, [r6], #1
    cmp r0, #'\n'
    beq count_done
    cmp r0, #0
    beq count_done
    add r4, r4, #1
    b count_loop

count_done:
    add r4, r4, #2      @ account for "> " prompt

    mov r0, #' '        @ r0 = space char
    mov r7, #0          @ r7 = loop counter

pad_loop:
    cmp r7, r4
    bge print_result
    bl putchar
    add r7, r7, #1
    b pad_loop

print_result:
    ldr r0, =result_fmt     @ r0 = format string "= %d\n"
    mov r1, r5              @ r1 = result
    bl printf

    pop {r0-r4, lr}
    bx lr



@ === debug_regs ===
@ r1 = r0
@ r2 = r1
@ r3 = r2
@ r6 = r3
@ r7 = r4
debug_regs:
    push {lr}
    mov r0, r0  @ format string already in r0
    mov r1, r1
    mov r2, r2
    mov r3, r3
    mov r4, r6  @ r4 = r3
    mov r5, r7  @ r5 = r4
    bl printf
    pop {lr}
    bx lr



@ === is_empty_input ===
@ r0 = pointer to input string
@ return r0 = 1 if empty, 0 otherwise
is_empty_input:
    push {lr}

    ldrb r1, [r0]      @ load first char
    cmp r1, #'\n'
    moveq r0, #1       @ return 1 if newline
    movne r0, #0

    pop {lr}
    bx lr


@ === parse_number ===
@ r0 = pointer to string
@ returns:
@   r0 = updated pointer (after number)
@   r1 = parsed integer
parse_number:
    push {r4-r7, lr}

    mov r1, #0          @ result
parse_loop:
    ldrb r2, [r0]       @ get char
    cmp r2, #'0'
    blt parse_done
    cmp r2, #'9'
    bgt parse_done

    sub r2, r2, #'0'    @ char to int

    mov r3, #10
    mul r1, r3, r1
    add r1, r1, r2
    add r0, r0, #1
    b parse_loop

parse_done:
    pop {r4-r7, lr}
    bx lr



@ === math helper functions ===
add:
    push {r2, lr}
    add r2, r0, r1
    mov r0, r2
    pop {r2, lr}
    bx lr

sub:
    push {r2, lr}
    sub r2, r0, r1
    mov r0, r2
    pop {r2, lr}
    bx lr

mul:
    push {r2, lr}
    mul r2, r0, r1    @ r2 = r0 * r1
    mov r0, r2        @ store result back in r0
    pop {r2, lr}
    bx lr

@ === div: r0 = r0 / r1 ===
div:
    push {r2-r4, lr}

    mov r2, r0      @ dividend
    mov r3, r1      @ divisor
    mov r0, #0      @ result = 0

    cmp r3, #0
    beq div_by_zero

div_loop:
    cmp r2, r3
    blt div_done
    sub r2, r2, r3
    add r0, r0, #1
    b div_loop

div_done:
    pop {r2-r4, lr}
    bx lr

div_by_zero:
    mov r0, #-1     @ Return -1 to indicate div by zero
    pop {r2-r4, lr}
    bx lr



@ === get_result ===
@ r0 = pointer to input string
@ returns: r0 = final result
get_result:
    push {r4-r7, lr}

    mov r4, r0          @ r4 = current pointer
    mov r0, r4
    bl  parse_number    @ r1 = first number, r0 = new ptr
    mov r4, r0          @ r4 = updated pointer after number
    mov r5, r1          @ r5 = running result

parse_next_op:
    ldrb r6, [r4]       @ r6 = current char
    cmp r6, #'\n'
    beq return_result

    @ skip spaces
    cmp r6, #' '
    beq skip_and_continue

    @ identify operator
    mov r7, r6          @ r7 = operator
    add r4, r4, #1      @ advance past operator

    mov r0, r4
    b skip_spaces2

skip_spaces2:
    ldrb r6, [r4]
    cmp r6, #' '
    bne parse_number_start
    add r4, r4, #1
    b skip_spaces2

parse_number_start:
    mov r0, r4
    bl parse_number
    mov r4, r0          @ update current pointer

    mov r6, r1          @ r6 = right operand
    mov r1, r6          @ r1 = right operand
    mov r0, r5          @ r0 = left operand

    cmp r7, #'+'        
    beq do_add
    cmp r7, #'-'
    beq do_sub
    cmp r7, #'*'
    beq do_mul
    cmp r7, #'/'
    beq do_div
    b   return_result   @ unknown operator, return what we have

do_add:
    bl add
    b store_result
do_sub:
    bl sub
    b store_result
do_mul:
    bl mul
    b store_result
do_div:
    bl div
    b store_result

store_result:
    mov r5, r0          @ store result for next operation
    b parse_next_op

skip_and_continue:
    add r4, r4, #1
    b parse_next_op

return_result:
    mov r0, r5
    pop {r4-r7, lr}
    bx lr
