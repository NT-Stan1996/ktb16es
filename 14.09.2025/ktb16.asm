; Kat#B16 MBR Boot Loader
; Carrega programas do drive A para 0x1000

[BITS 16]
[ORG 0x7C00]

start:
    ; Configurar segmentos
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    ; Limpar tela e definir cores (fundo vermelho, texto branco)
    mov ax, 0x0003
    int 0x10
    
    ; Definir cor de fundo vermelho (4) e texto branco (15)
    mov ax, 0x0600      ; Scroll up function
    mov bh, 0x4F        ; Fundo vermelho (4) + texto branco (15)
    mov cx, 0x0000      ; Upper left corner (0,0)
    mov dx, 0x184F      ; Lower right corner (24,79)
    int 0x10

    ; Exibir mensagem inicial
    mov si, msg_boot
    call print_string

    ; Loop principal
main_loop:
    mov si, msg_insert
    call print_string
    
    ; Aguardar tecla
    mov ah, 0x00
    int 0x16
    
    ; Verificar se é 'R' ou 'r' para restart
    cmp al, 'R'
    je restart
    cmp al, 'r'
    je restart
    
    ; Se ENTER, tentar carregar do drive A
    cmp al, 0x0D
    jne main_loop
    
    ; Nova linha
    call print_newline
    
    ; Verificar se drive A existe
    mov ah, 0x08        ; Get drive parameters
    mov dl, 0x00        ; Drive A
    int 0x13
    jc drive_error
    
    ; Carregar setor do disquete para 0x1000
    mov ax, 0x0100      ; ES = 0x0100 (0x1000 / 16)
    mov es, ax
    xor bx, bx          ; BX = 0 (offset)
    
    mov ah, 0x02        ; Função leitura
    mov al, 0x01        ; 1 setor
    mov ch, 0x00        ; Trilha 0
    mov cl, 0x01        ; Setor 1
    mov dh, 0x00        ; Cabeça 0
    mov dl, 0x00        ; Drive A
    int 0x13
    jc read_error
    
    ; Executar programa carregado
    jmp 0x0100:0x0000   ; Executar programa

read_error:
    push cs
    pop ds
    mov si, msg_read_error
    call print_string
    jmp main_loop

drive_error:
    push cs
    pop ds
    mov si, msg_drive_error
    call print_string
    jmp main_loop

restart:
    jmp 0xFFFF:0x0000   ; Cold boot

; Função para imprimir string (SI = ponteiro)
print_string:
    push ax
    push bx
    mov ah, 0x0E        ; Teletype output
    mov bx, 0x004F      ; Página 0, fundo vermelho + texto branco
print_loop:
    lodsb               ; AL = [SI], SI++
    test al, al
    jz print_done
    int 0x10
    jmp print_loop
print_done:
    pop bx
    pop ax
    ret

print_newline:
    push ax
    push bx
    mov ah, 0x0E
    mov bx, 0x004F      ; Página 0, fundo vermelho + texto branco
    mov al, 0x0D        ; CR
    int 0x10
    mov al, 0x0A        ; LF
    int 0x10
    pop bx
    pop ax
    ret

; Strings
msg_boot:
    db 'Kat#B16es', 0x0D, 0x0A
    db 'Build: 14.09.2025', 0x0D, 0x0A
    db '(C) 2024-2025 Neko Interactive Systems(TM)', 0x0D, 0x0A
    db 'Autor: StanoBemLoko', 0x0D, 0x0A, 0x0D, 0x0A, 0

msg_insert:
    db '==[i] Insira um disquete de jogo v', 0xA0, 'lido no drive A e pressione ENTER ====', 0x0D, 0x0A
    db '==[i] Pressione R para reiniciar caso aconte', 0x87, 'a um erro ====', 0x0D, 0x0A
    db ' ', 0x0D, 0x0A
    db '---', 0x0D, 0x0A
    db ' ', 0x0D, 0x0A, 0

msg_read_error:
    db '==[!] Erro de leitura. ====', 0x0D, 0x0A
    db ' ', 0x0D, 0x0A, 0

msg_drive_error:
    db '==[!] Drive A ausente. ====', 0x0D, 0x0A
    db '==[?] Ele existe neste comp.? ====', 0x0D, 0x0A
    db ' ', 0x0D, 0x0A, 0

; Preencher até o byte 510
times 510-($-$$) db 0

; Assinatura do MBR
dw 0xAA55