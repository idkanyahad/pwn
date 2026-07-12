.intel_syntax noprefix
.global itoa

itoa:
    mov r8, rsi
    xor r10, r10
    mov rax, rdi

    cmp rax, 0
    jge check_zero

    mov byte ptr [r8], '-'
    inc r8
    neg rax
    mov r10, 1

check_zero:
    cmp rax, 0
    jne convert

    mov byte ptr [r8], '0'
    mov rax, 1
    add rax, r10
    ret

convert:
    xor rcx, rcx

loop_div:
    xor rdx, rdx
    mov r9, 10
    div r9
    add dl, '0'
    push rdx
    inc rcx
    cmp rax, 0
    jne loop_div

write_digits:
    pop rdx
    mov [r8], dl
    inc r8
    dec rcx
    cmp rcx, 0
    jne write_digits

    mov rax, r8
    sub rax, rsi
    ret
