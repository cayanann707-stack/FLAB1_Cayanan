section .data
    prompt_name    db "Enter full name: ", 0
    len_name       equ $ - prompt_name

    prompt_age     db "Enter age: ", 0
    len_age        equ $ - prompt_age

    prompt_gender  db "Enter gender (M/F): ", 0
    len_gender     equ $ - prompt_gender

    lbl_hello      db "Hello ", 0
    len_lbl_hello  equ $ - lbl_hello

    lbl_age1       db "You are ", 0
    len_lbl_age1   equ $ - lbl_age1

    lbl_age2       db " years old", 10, 0
    len_lbl_age2   equ $ - lbl_age2

    out_m          db "Hello", 10, 0
    len_out_m      equ $ - out_m

    out_f          db "World", 10, 0
    len_out_f      equ $ - out_f

    out_invalid    db "INVALID", 10, 0
    len_out_invalid equ $ - out_invalid

    newline        db 10

section .bss
    buf_name   resb 100
    buf_age    resb 16
    buf_gender resb 4
    
    ; Variable to store lengths after stripping newlines
    name_len   resd 1
    age_len    resd 1

section .text
    global _start

_start:
    ; 1. Prompt and read Name
    mov ecx, prompt_name
    mov edx, len_name
    call print_string

    mov ecx, buf_name
    mov edx, 100
    call read_input
    
    mov ecx, buf_name
    call strip_newline
    mov [name_len], eax

    ; 2. Prompt and read Age
    mov ecx, prompt_age
    mov edx, len_age
    call print_string

    mov ecx, buf_age
    mov edx, 16
    call read_input

    mov ecx, buf_age
    call strip_newline
    mov [age_len], eax
    
    ; Validate that age contains only numbers
    mov ecx, buf_age
    mov edx, [age_len]
    call validate_numeric

    ; 3. Prompt and read Gender
    mov ecx, prompt_gender
    mov edx, len_gender
    call print_string

    mov ecx, buf_gender
    mov edx, 4
    call read_input

    ; 4. Output: "Hello <name>"
    mov ecx, lbl_hello
    mov edx, len_lbl_hello
    call print_string

    mov ecx, buf_name
    mov edx, [name_len]
    call print_string
    
    mov ecx, newline
    mov edx, 1
    call print_string

    ; 5. Output: "You are <age> years old"
    mov ecx, lbl_age1
    mov edx, len_lbl_age1
    call print_string

    mov ecx, buf_age
    mov edx, [age_len]
    call print_string

    mov ecx, lbl_age2
    mov edx, len_lbl_age2
    call print_string

    ; 6. Check Gender & Output appropriate message
    mov al, [buf_gender]
    
    cmp al, 'M'
    je case_m
    cmp al, 'm'
    je case_m
    
    cmp al, 'F'
    je case_f
    cmp al, 'f'
    je case_f
    
    jmp case_invalid

case_m:
    mov ecx, out_m
    mov edx, len_out_m
    call print_string
    jmp exit_program

case_f:
    mov ecx, out_f
    mov edx, len_out_f
    call print_string
    jmp exit_program

case_invalid:
    mov ecx, out_invalid
    mov edx, len_out_invalid
    call print_string
    jmp exit_program

exit_program:
    mov eax, 1          ; sys_exit
    xor ebx, ebx        ; exit code 0
    int 0x80

; --- PROCEDURES ---

; Prints string: ECX = buffer pointer, EDX = length
print_string:
    mov eax, 4          ; sys_write
    mov ebx, 1          ; stdout
    int 0x80
    ret

; Reads input: ECX = buffer pointer, EDX = max length
read_input:
    mov eax, 3          ; sys_read
    mov ebx, 0          ; stdin
    int 0x80
    ret

; Strips trailing newline (\n or \r)
; Input: ECX = buffer pointer
; Output: EAX = actual string length excluding newline
strip_newline:
    push ebx
    xor eax, eax
.loop:
    mov bl, [ecx + eax]
    cmp bl, 0
    je .done
    cmp bl, 10          ; '\n'
    je .strip
    cmp bl, 13          ; '\r'
    je .strip
    inc eax
    jmp .loop
.strip:
    mov byte [ecx + eax], 0
.done:
    pop ebx
    ret

; Basic validation to ensure the string input contains only numeric digits
; Input: ECX = buffer pointer, EDX = string length
validate_numeric:
    push eax
    push ebx
    xor eax, eax
    test edx, edx
    jz .invalid_age    ; Empty input is invalid
.val_loop:
    cmp eax, edx
    je .val_done
    mov bl, [ecx + eax]
    cmp bl, '0'
    jl .invalid_age
    cmp bl, '9'
    jg .invalid_age
    inc eax
    jmp .val_loop
.invalid_age:
    ; Overwrite age with standard "unknown" or zero to prevent formatting crash
    mov byte [ecx], '0'
    mov byte [ecx+1], 0
    mov dword [age_len], 1
.val_done:
    pop ebx
    pop eax
    ret
