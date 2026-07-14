.intel_syntax noprefix

.global _start

_start:
    mov rax, [rsp]

    cmp rax, 4
    je binary

    cmp rax, 3
    je unary

    jmp error

binary:
    mov rdi, [rsp+24]
    mov al, [rdi]

    cmp al, '+'
    je do_add

    cmp al, '-'
    je do_sub

    cmp al, '*'
    je do_mul

    cmp al, '^'
    je do_xor

    cmp al, '|'
    je do_or

    cmp al, '&'
    je do_and

    jmp error

unary:
    mov rdi, [rsp+16]
    mov al, [rdi]

    cmp al, '-'
    je do_neg

    cmp al, '~'
    je do_not

    jmp error

do_add:
    mov rdi, [rsp+16]
    call atoi
    mov rbx, rax

    mov rdi, [rsp+32]
    call atoi

    add rax, rbx
    jmp output

do_sub:
    mov rdi, [rsp+16]
    call atoi
    mov rbx, rax

    mov rdi, [rsp+32]
    call atoi

    mov rcx, rax
    mov rax, rbx
    sub rax, rcx

    jmp output

do_mul:
    mov rdi, [rsp+16]
    call atoi
    mov rbx, rax

    mov rdi, [rsp+32]
    call atoi

    imul rax, rbx

    jmp output

do_xor:
    mov rdi, [rsp+16]
    call atoi
    mov rbx, rax

    mov rdi, [rsp+32]
    call atoi

    xor rax, rbx

    jmp output

do_or:
    mov rdi, [rsp+16]
    call atoi
    mov rbx, rax

    mov rdi, [rsp+32]
    call atoi

    or rax, rbx

    jmp output

do_and:
    mov rdi, [rsp+16]
    call atoi
    mov rbx, rax

    mov rdi, [rsp+32]
    call atoi

    and rax, rbx

    jmp output

do_neg:
    mov rdi, [rsp+24]
    call atoi

    neg rax

    jmp output

do_not:
    mov rdi, [rsp+24]
    call atoi

    not rax

    jmp output

output:
    sub rsp, 0x80

    mov rdi, rax
    mov rsi, rsp
    call itoa

    mov rdx, rax
    mov rsi, rsp
    mov rdi, 1
    mov rax, 1
    syscall

    add rsp, 0x80

    xor rdi, rdi
    mov rax, 60
    syscall

error:
    mov rdi, 1
    mov rax, 60
    syscall

atoi:
    mov rax, 0
    mov r8, 0

    mov cl, [rdi]
    cmp cl, '-'
    jne loop_start

    mov r8, 1
    inc rdi

loop_start:
    mov cl, [rdi]
    sub cl, '0'
    cmp cl, 9
    ja done

    imul rax, 10
    movzx rcx, cl
    add rax, rcx

    inc rdi
    jmp loop_start

done:
    cmp r8, 0
    je finish

    neg rax

finish:
    ret

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
