.intel_syntax noprefix
.global _start

_start:
    mov rax, 41
    mov rdi, 2
    mov rsi, 1
    xor rdx, rdx
    syscall

    mov rbx, rax

    sub rsp, 16
    mov word ptr [rsp], 2
    mov word ptr [rsp+2], 0x5000
    mov dword ptr [rsp+4], 0
    mov qword ptr [rsp+8], 0

    mov rax, 49
    mov rdi, rbx
    mov rsi, rsp
    mov rdx, 16
    syscall

    mov rax, 50
    mov rdi, rbx
    xor rsi, rsi
    syscall

server_loop:

    mov rax, 43
    mov rdi, rbx
    xor rsi, rsi
    xor rdx, rdx
    syscall

    mov r12, rax

    mov rax , 57
    syscall

    cmp rax, 0
    je child_process

    
    mov rax, 3
    mov rdi, r12            
    syscall

    jmp server_loop

child_process:
    mov rax, 3
    mov rdi, rbx
    syscall

    sub rsp, 1024

    xor rax, rax
    mov rdi, r12
    mov rsi, rsp
    mov rdx, 1024
    syscall

    mov r8, rax
    
    cmp byte ptr [rsp], 'G'
    je handle_get

    cmp byte ptr [rsp], 'P'
    je handle_post

    jne send_response

handle_get:
    lea r14, [rsp+4]
    find_space_get:
        mov al, [r14]
        cmp al, ' '
        je terminate_get
        inc r14
        jmp find_space_get
    terminate_get:
        mov byte ptr [r14], 0
        lea r13, [rsp+4]
    
    mov rax, 2
    mov rdi, r13
    xor rsi, rsi
    xor rdx, rdx
    syscall

    mov r15, rax

    xor rax, rax
    mov rdi, r15
    mov rsi, rsp
    mov rdx, 1024
    syscall

    mov r14, rax

    mov rax, 3
    mov rdi, r15
    syscall

    mov rax, 1
    mov rdi, r12
    lea rsi, [rip + response]
    mov rdx, 19
    syscall

    mov rax, 1
    mov rdi, r12
    mov rsi, rsp
    mov rdx, r14
    syscall

    jmp send_response

handle_post:
    lea r14, [rsp+5]
    find_space_post:
        mov al, [r14]
        cmp al, ' '
        je terminate_post
        inc r14
        jmp find_space_post
    terminate_post:
        mov byte ptr [r14], 0
        lea r13, [rsp+5]
    
    mov rax, 2
    mov rdi, r13
    mov rsi, 0101
    mov rdx, 0777
    syscall

    mov r15, rax

        mov r10, rsp

find_body_post:
    cmp byte ptr [r10], 13
    jne next_byte
    cmp byte ptr [r10+1], 10
    jne next_byte
    cmp byte ptr [r10+2], 13
    jne next_byte
    cmp byte ptr [r10+3], 10
    jne next_byte

    add r10, 4

    mov rdx, r10
    sub rdx, rsp
    mov rcx, r8
    sub rcx, rdx
    mov r9, rcx

    jmp body_found

next_byte:
    inc r10
    jmp find_body_post

body_found:

    mov rax, 1
    mov rdi, r15
    mov rsi, r10
    mov rdx, r9
    syscall

    mov rax, 1
    mov rdi, r12
    lea rsi, [rip + response]
    mov rdx, 19
    syscall

    mov rax, 3
    mov rdi, r15
    syscall


    jmp send_response

send_response:

    mov rax, 3
    mov rdi, r12
    syscall

    mov rax, 60
    xor rdi, rdi
    syscall


response:
    .ascii "HTTP/1.0 200 OK\r\n\r\n"
