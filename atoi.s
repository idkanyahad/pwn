.intel_syntax noprefix

.global atoi

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
