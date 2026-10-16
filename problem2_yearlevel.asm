section .data
    prompt_name       db "What is your name? ", 0
    len_name          equ $ - prompt_name

    prompt_age        db "How old are you? ", 0
    len_age           equ $ - prompt_age

    prompt_year       db "What is your year level? ", 0
    len_year          equ $ - prompt_year

    lbl_hello         db "Hello ", 0
    len_lbl_hello     equ $ - lbl_hello

    lbl_age1          db "You are ", 0
    len_lbl_age1      equ $ - lbl_age1

    lbl_age2          db " years old", 10, 0
    len_lbl_age2      equ $ - lbl_age2

    class_1           db "Freshman", 10, 0
    len_class_1       equ $ - class_1

    class_2           db "Sophomore", 10, 0
    len_class_2       equ $ - class_2

    class_3           db "Junior", 10, 0
    len_class_3       equ $ - class_3

    class_4           db "Senior", 10, 0
    len_class_4       equ $ - class_4

    class_invalid     db "INVALID YEAR LEVEL", 10, 0
    len_class_invalid equ $ - class_invalid

    newline           db 10

section .bss
    buf_name    resb 100
    buf_age     resb 16
    buf_year    resb 8
    
    name_len    resd 1
    age_len     resd 1

section .text
    global _start

_start:
    mov ecx, prompt_name
    mov edx, len_name
    call print_string

    mov ecx, buf_name
    mov edx, 100
    call read_input
    
    mov ecx, buf_name
    call strip_newline
    mov [name_len], eax

    mov ecx, prompt_age
    mov edx, len_age
    call print_string

    mov ecx, buf_age
    mov edx, 16
    call read_input

    mov ecx, buf_age
    call strip_newline
    mov [age_len], eax

    mov ecx, prompt_year
    mov edx, len_year
    call print_string

    mov ecx, buf_year
    mov edx, 8
    call read_input

    mov ecx, lbl_hello
    mov edx, len_lbl_hello
    call print_string

    mov ecx, buf_name
    mov edx, [name_len]
    call print_string
    
    mov ecx, newline
    mov edx, 1
    call print_string

    mov ecx, lbl_age1
    mov edx, len_lbl_age1
    call print_string

    mov ecx, buf_age
    mov edx, [age_len]
    call print_string

    mov ecx, lbl_age2
    mov edx, len_lbl_age2
    call print_string

    mov al, [buf_year]

    cmp al, '1'
    je case_freshman
    cmp al, '2'
    je case_sophomore
    cmp al, '3'
    je case_junior
    cmp al, '4'
    je case_senior
    
    jmp case_invalid_year

case_freshman:
    mov ecx, class_1
    mov edx, len_class_1
    call print_string
    jmp exit_program

case_sophomore:
    mov ecx, class_2
    mov edx, len_class_2
    call print_string
    jmp exit_program

case_junior:
    mov ecx, class_3
    mov edx, len_class_3
    call print_string
    jmp exit_program

case_senior:
    mov ecx, class_4
    mov edx, len_class_4
    call print_string
    jmp exit_program

case_invalid_year:
    mov ecx, class_invalid
    mov edx, len_class_invalid
    call print_string
    jmp exit_program

exit_program:
    mov eax, 1
    xor ebx, ebx
    int 0x80

print_string:
    mov eax, 4
    mov ebx, 1
    int 0x80
    ret

read_input:
    mov eax, 3
    mov ebx, 0
    int 0x80
    ret

strip_newline:
    push ebx
    xor eax, eax
.loop:
    mov bl, [ecx + eax]
    cmp bl, 0
    je .done
    cmp bl, 10
    je .strip
    cmp bl, 13
    je .strip
    inc eax
    jmp .loop
.strip:
    mov byte [ecx + eax], 0
.done:
    pop ebx
    ret
