section .data
    p_name        db "Enter account name: ", 0
    l_name        equ $ - p_name
    p_pin         db "Enter PIN: ", 0
    l_pin         equ $ - p_pin
    p_amount      db "Enter withdrawal amount: ", 0
    l_amount      equ $ - p_amount

    msg_granted   db "ACCESS GRANTED", 10, 0
    l_granted     equ $ - msg_granted
    msg_denied    db "ACCESS DENIED", 10, 0
    l_denied      equ $ - msg_denied

    lbl_bal       db "Current Balance: PHP ", 0
    l_lbl_bal     equ $ - lbl_bal
    lbl_rem       db "Remaining Balance: PHP ", 0
    l_lbl_rem     equ $ - lbl_rem

    msg_success   db "WITHDRAWAL SUCCESSFUL", 10, 0
    l_success     equ $ - msg_success
    lbl_withdrawn db "Amount Withdrawn: PHP ", 0
    l_withdrawn   equ $ - lbl_withdrawn

    err_invalid   db "INVALID AMOUNT", 10, 0
    l_err_invalid equ $ - err_invalid
    err_funds     db "INSUFFICIENT FUNDS", 10, 0
    l_err_funds   equ $ - err_funds
    err_mult100   db "AMOUNT MUST BE A MULTIPLE OF 100", 10, 0
    l_err_mult100 equ $ - err_mult100

    newline       db 10

    target_pin    db "1234", 0

section .bss
    buf_name      resb 100
    buf_pin       resb 16
    buf_amount    resb 32
    
    len_amount    resd 1
    balance       resd 1
    amt_withdrawn resd 1
    buf_num       resb 32

section .text
    global _start

_start:
    mov dword [balance], 10000

    mov ecx, p_name
    mov edx, l_name
    call print_string

    mov ecx, buf_name
    mov edx, 100
    call read_input

    mov ecx, p_pin
    mov edx, l_pin
    call print_string

    mov ecx, buf_pin
    mov edx, 16
    call read_input
    mov ecx, buf_pin
    call strip_newline

    mov esi, buf_pin
    mov edi, target_pin
    mov ecx, 4
    repe cmpsb
    jne handle_denied

    mov ecx, msg_granted
    mov edx, l_granted
    call print_string

    mov ecx, lbl_bal
    mov edx, l_lbl_bal
    call print_string
    mov eax, [balance]
    call print_number

    mov ecx, p_amount
    mov edx, l_amount
    call print_string

    mov ecx, buf_amount
    mov edx, 32
    call read_input
    mov ecx, buf_amount
    call strip_newline
    mov [len_amount], eax

    mov ecx, buf_amount
    mov edx, [len_amount]
    call ascii_to_int
    cmp eax, -1
    je handle_invalid
    cmp eax, 0
    jle handle_invalid
    mov [amt_withdrawn], eax

    mov ebx, [balance]
    cmp eax, ebx
    jg handle_insufficient

    xor edx, edx
    mov ecx, 100
    div ecx
    test edx, edx
    jnz handle_multiple

    mov eax, [balance]
    sub eax, [amt_withdrawn]
    mov [balance], eax

    mov ecx, msg_success
    mov edx, l_success
    call print_string

    mov ecx, lbl_withdrawn
    mov edx, l_withdrawn
    call print_string
    mov eax, [amt_withdrawn]
    call print_number

    mov ecx, lbl_rem
    mov edx, l_lbl_rem
    call print_string
    mov eax, [balance]
    call print_number
    jmp exit_program

handle_denied:
    mov ecx, msg_denied
    mov edx, l_denied
    call print_string
    jmp exit_program

handle_invalid:
    mov ecx, err_invalid
    mov edx, l_err_invalid
    call print_string
    jmp exit_program

handle_insufficient:
    mov ecx, err_funds
    mov edx, l_err_funds
    call print_string
    jmp exit_program

handle_multiple:
    mov ecx, err_mult100
    mov edx, l_err_mult100
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

print_number:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    mov ecx, 10
    mov esi, buf_num
    add esi, 31
    mov byte [esi], 10
.convert_loop:
    xor edx, edx
    div ecx
    add dl, '0'
    dec esi
    mov [esi], dl
    test eax, eax
    jnz .convert_loop
    mov ecx, buf_num
    add ecx, 32
    sub ecx, esi
    mov edx, ecx
    mov ecx, esi
    mov eax, 4
    mov ebx, 1
    int 0x80
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
