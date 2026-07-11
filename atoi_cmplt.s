.intel_syntax noprefix

.global _start

_start:
    mov rdi, [rsp+16]
    call atoi

    mov rdi, rax
    mov rax, 60
    syscall

atoi:
    mov rax, 0

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
    ret
