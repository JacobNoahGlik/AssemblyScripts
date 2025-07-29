.global main
.extern printf
.extern scanf

.data
input_fmt:   .asciz "%d"
result_fmt:  .asciz "Result: %d\n"
prompt:      .asciz "Enter a number to square: "
input_val:   .word 0

.text

main:
    push {lr}

    bl read_input_and_square

    pop {lr}
    bx lr

# === Function: read_input_and_square ===
read_input_and_square:
    push {lr}

    ldr r0, =prompt
    bl printf                   @ Print the prompt

    ldr r0, =input_fmt          @ Format string "%d"
    ldr r1, =input_val          @ Address to store input
    bl scanf                    @ Read user input into input_val

    ldr r0, =input_val
    ldr r0, [r0]                @ Load the entered number into r0
    bl square                   @ Square it (result in r0)

    mov r1, r0                  @ Move result to r1 (for printf)
    ldr r0, =result_fmt         @ Load result format
    bl printf                   @ Print result

    pop {lr}
    bx lr

# === Function: square ===
# Input: r0
# Output: r0 squared
square:
    mov r1, r0
    mul r0, r1, r0
    bx lr
