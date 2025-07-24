section .data
    prompt      db "Enter a number to square: ", 0
    result_msg  db " squared = ", 0
    newline     db 10, 0

    input_buf   times 16 db 0         ; buffer for reading user input
    output_buf  times 16 db 0         ; buffer for printing integer output

section .bss
    square_result resd 1     ; reserve 4 bytes for int result

section .text
    global _start

; === MAIN ===
_start:

    ; print prompt
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt
    mov edx, 25
    int 0x80

    ; read input
    mov eax, 3
    mov ebx, 0
    mov ecx, input_buf
    mov edx, 16
    int 0x80

    ; print newline
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; convert input string to int -> EAX
    call str_to_int
    mov ebx, eax        ; store original input

    ; call square
    mov eax, ebx
    call square
    ;mov esi, eax        ; store square result safely
    mov [square_result], eax     ; save to memory

    ; print original input
    mov eax, ebx
    mov edi, output_buf
    call int_to_str

    mov eax, 4
    mov ebx, 1
    mov ecx, output_buf
    mov edx, edi         ; edi contains length
    int 0x80

    ; print " squared = "
    mov eax, 4
    mov ebx, 1
    mov ecx, result_msg
    mov edx, 11
    int 0x80

    ; print square result
    mov eax, [square_result]     ; load square result
    mov edi, output_buf
    call int_to_str

    mov eax, 4
    mov ebx, 1
    mov ecx, output_buf
    mov edx, edi
    int 0x80

    ; print newline
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; exit
    mov eax, 1
    xor ebx, ebx
    int 0x80


; === square ===
; input: eax
; output: eax^2
square:
    imul eax, eax
    ret

; === str_to_int ===
; converts null-terminated string at input_buf to int in EAX
; ignores non-numeric chars, stops at newline
str_to_int:
    xor eax, eax        ; result
    xor ecx, ecx        ; index
.next_char:
    mov bl, [input_buf + ecx]
    cmp bl, 10          ; newline?
    je .done
    cmp bl, '0'
    jl .done
    cmp bl, '9'
    jg .done
    sub bl, '0'
    imul eax, eax, 10
    add eax, ebx
    inc ecx
    jmp .next_char
.done:
    ret

; === int_to_str ===
; input: EAX = number, EDI = buffer ptr
; output: buffer filled with ASCII digits, EDI = length
int_to_str:
    mov ecx, 10         ; divisor
    mov esi, edi        ; save original buffer ptr
    add edi, 15         ; write digits in reverse
    mov byte [edi], 0
    dec edi
    xor edx, edx
.convert:
    xor edx, edx
    div ecx             ; EAX / 10 -> EAX, remainder in EDX
    add dl, '0'
    mov [edi], dl
    dec edi
    test eax, eax
    jnz .convert
    inc edi             ; point to first digit
    ; shift result to beginning of output_buf
    mov ecx, 0
.shift:
    mov al, [edi + ecx]
    mov [esi + ecx], al
    cmp al, 0
    je .done
    inc ecx
    jmp .shift
.done:
    mov edi, ecx        ; length of string
    ret
