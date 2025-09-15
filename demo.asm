; KTB16 Demo - Amogus
; Demo para ser carregada pelo boot loader Kat#B16 em 0x1000
; Exibe "amogus" centralizado em fundo branco com texto preto

[BITS 16]
[ORG 0x1000]

; Assinatura obrigatória para o boot loader (não mais, no meio do desenvolvimento isso foi removido, mas talvez eu traga de volta nas próximas versões)
signature:
    db 'KTB16'

start:
    ; Configurar segmentos
    cli
    mov ax, cs
    mov ds, ax
    mov es, ax
    sti

    ; Limpar tela e definir modo de vídeo
    mov ax, 0x0003      ; Modo texto 80x25
    int 0x10

    ; Definir cor de fundo branco (7) e texto preto (0)
    mov ax, 0x0600      ; Scroll up function para limpar
    mov bh, 0x70        ; Fundo branco (7) + texto preto (0)
    mov cx, 0x0000      ; Upper left corner (0,0)
    mov dx, 0x184F      ; Lower right corner (24,79)
    int 0x10

    ; Posicionar cursor no centro da tela
    ; Linha 12 (centro vertical), coluna 38 (centro horizontal para "amogus")
    mov ah, 0x02        ; Set cursor position
    mov bh, 0x00        ; Page 0
    mov dh, 12          ; Row 12 (centro)
    mov dl, 38          ; Column 38 (centro para 6 caracteres)
    int 0x10

    ; Exibir "amogus" com atributo correto
    mov si, msg_amogus
    call print_string

    ; Loop infinito para manter a demo rodando
    ; Aguarda qualquer tecla para sair
main_loop:
    mov ah, 0x00        ; Wait for keypress
    int 0x16
    
    ; Qualquer tecla pressionada sai da demo
    ; (Na prática, vai travar o sistema, mas é só uma demo)
    cli
    hlt

; Função para imprimir string com cor específica
print_string:
    push ax
    push bx
    push cx
print_loop:
    lodsb               ; AL = [SI], SI++
    test al, al
    jz print_done
    
    ; Usar função que permite definir atributo
    mov ah, 0x09        ; Write character and attribute
    mov bh, 0x00        ; Page 0
    mov bl, 0x1F        ; Fundo azul + texto branco (igual à tela)
    mov cx, 0x01        ; Write 1 character
    int 0x10
    
    ; Avançar cursor manualmente
    mov ah, 0x03        ; Get cursor position
    mov bh, 0x00        ; Page 0
    int 0x10
    
    inc dl              ; Next column
    mov ah, 0x02        ; Set cursor position
    mov bh, 0x00        ; Page 0
    int 0x10
    
    jmp print_loop

print_done:
    pop cx
    pop bx
    pop ax
    ret

; Mensagem
msg_amogus:
    db 'amogus', 0

; Não precisa preencher - o boot loader carrega 512 bytes automaticamente
; O programa pode ser menor que isso