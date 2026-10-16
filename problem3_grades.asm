section .data
    p_name        db "Enter student name: ", 0
    l_name        equ $ - p_name
    p_id          db "Enter student ID: ", 0
    l_id          equ $ - p_id
    p_grade       db "Enter grade: ", 0
    l_grade       equ $ - p_grade

    lbl_name      db "Student Name: ", 0
    lbl_id        db "Student ID: ", 0
    lbl_grade     db "Grade: ", 0
    lbl_class     db "Classification: ", 0

    c_excellent   db "Excellent", 10, 0
    l_excellent   equ $ - c_excellent
    c_vgood       db "Very Good", 10, 0
    l_vgood       equ $ - c_vgood
    c_good        db "Good", 10, 0
    l_good        equ $ - c_good
    c_passed      db "Passed", 10, 0
    l_passed      equ $ - c_passed
    c_failed      db "Failed", 10, 0
    l_failed      equ $ - c_failed
    c_invalid     db "INVALID GRADE", 10, 0
    l_invalid     equ $ - c_invalid

    newline       db 10

section .bss
    buf_name      resb 100
    buf_id        resb 32
    buf_grade     resb 16
    
    len_name_actual resd 1
    len_id_actual   resd 1
    len_grade_actual resd 1
    int_grade     resd 1

section .text
    global _start

_start:
    mov ecx, p_name
    mov edx, l_name
    call print_string

    mov ecx, buf_name
    mov edx, 100
    call read_input
    mov ecx, buf_name
    call strip_newline
    mov [len_name_actual], eax

    mov ecx, p_id
    mov edx, l_id
    call print_string

    mov ecx, buf_id
    mov edx, 32
    call read_input
    mov ecx, buf_id
    call strip_newline
    mov [len_id_actual], eax

    mov ecx, p_grade
    mov edx, l_grade
    call print_string

    mov ecx, buf_grade
    mov edx, 16
    call read_input
    mov ecx, buf_grade
    call strip_newline
    mov [len_grade_actual], eax

    mov ecx, buf_grade
    mov edx, [len_grade_actual]
    call ascii_to_int
    cmp eax, -1
    je handle_invalid
    mov [int_grade], eax

    cmp eax, 0
    jl handle_invalid
    cmp eax, 100
    jg handle_invalid

    mov ecx, lbl_name
    mov edx, 14
    call print_string
    mov ecx, buf_name
    mov edx, [len_name_actual]
    call print_string
    mov ecx, newline
    mov edx, 1
    call print_string

    mov ecx, lbl_id
    mov edx, 12
    call print_string
    mov ecx, buf_id
    mov edx, [len_id_actual]
    call print_string
    mov ecx, newline
    mov edx, 1
    call print_string

    mov ecx, lbl_grade
    mov edx, 7
    call print_string
    mov ecx, buf_grade
    mov edx, [len_grade_actual]
    call print_string
    mov ecx, newline
    mov edx, 1
    call print_string

    mov ecx, lbl_class
    mov edx, 16
    call print_string

    mov eax, [int_grade]

    cmp eax, 90
    jge case_excellent
    cmp eax, 85
    jge case_vgood
    cmp eax, 80
    jge case_good
    cmp eax, 75
    jge case_passed
    jmp case_failed

case_excellent:
    mov ecx, c_excellent
    mov edx, l_excellent
    call print_string
    jmp exit_program

case_vgood:
    mov ecx, c_vgood
    mov edx, l_vgood
    call print_string
    jmp exit_program

case_good:
    mov ecx, c_good
    mov edx, l_good
    call print_string
    jmp exit_program

case_passed:
    mov ecx, c_passed
    mov edx, l_passed
    call print_string
    jmp exit_program

case_failed:
    mov ecx, c_failed
    mov edx, l_failed
    call print_string
    jmp exit_program

handle_invalid:
    mov ecx, lbl_name
    mov edx, 14
    call print_string
    mov ecx, buf_name
    mov edx, [len_name_actual]
    call print_string
    mov ecx, newline
    mov edx, 1
    call print_string

    mov ecx, lbl_id
    mov edx, 12
    call print_string
    mov ecx, buf_id
    mov edx, [len_id_actual]
    call print_string
    mov ecx, newline
    mov edx, 1
    call print_string

    mov ecx, lbl_grade
    mov edx, 7
    call print_string
    mov ecx, buf_grade
    mov edx, [len_grade_actual]
    call print_string
    mov ecx, newline
    mov edx, 1
    call print_string

    mov ecx, lbl_class
    mov edx, 16
    call print_string

    mov ecx, c_invalid
    mov edx, l_invalid
    call print_string

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

ascii_to_int:
    push ebx
    push esi
    mov esi, ecx
    mov ecx, edx
    xor eax, eax
    xor ebx, ebx
    test ecx, ecx
    jz .error
.loop:
    mov bl, [esi]
    cmp bl, '0'
    jl .error
    cmp bl, '9'
    jg .error
    sub bl, '0'
    imul eax, 10
    add eax, ebx
    inc esi
    loop .loop
    jmp .done
.error:
    mov eax, -1
.done:
    pop esi
    pop ebx
    ret
