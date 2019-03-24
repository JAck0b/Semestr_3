; nasm -fbin boot.asm
; qemu-system-i386 -drive format=raw,file=boot

bits 16
org 0x7c00

boot:
  mov ax, 0x2401
  int 0x15
  mov ax, 0x13        ; wlaczenie trybu graficznego 320x200
  int 0x10
  cli
  lgdt [gdt_pointer]  ; ustawienie tablicy GDT
  mov eax, cr0        ; wlaczenie trybu chronionego
  or eax,0x1
  mov cr0, eax
  jmp CODE_SEG:boot2
gdt_start:              ; tablica GDT
  dq 0x0
gdt_code:
  dw 0xFFFF
  dw 0x0
  db 0x0
  db 10011010b
  db 11001111b
  db 0x0
gdt_data:
  dw 0xFFFF
  dw 0x0
  db 0x0
  db 10010010b
  db 11001111b
  db 0x0
gdt_end:
gdt_pointer:
  dw gdt_end - gdt_start
  dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

bits 32
boot2:
  mov ax, DATA_SEG
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ss, ax

  mov edi,0xa0000 ; Wczytanie ekranu do rejestru
  ;   Ustawienie początkowe liczników. Odpowiedzialne za fragment fraktala który widziany jest na ekranie.
  mov dword [CntrA],-510*256
  mov word [X],0
@@LoopHoriz:
  mov dword [CntrB],-270*256
  mov word [Y],200
@@LoopVert:
;   wyliczanie fraktala według wzorów iteracyjnych:
;       x -> x^2 - y^2 + C*
;       y -> 2*x*y + C

  xor ecx,ecx     ;x = 0
  xor edx,edx     ;y = 0
  mov si,32-1     ;kolor
@@LoopFractal:
  mov eax,ecx
  imul eax,eax        ;x^2
  mov ebx,edx
  imul ebx,ebx        ;y^2
  sub eax,ebx         ;x^2 - y^2
  add eax,dword [CntrA]   ;x^2 - y^2 + C
  mov ebx,ecx
  imul ebx,edx    ;x*y
  sal ebx,1       ;2*x*y
  add ebx,dword [CntrB]   ;;2 * x * y + C
  sar eax,8
  sar ebx,8
  mov ecx,eax
  mov edx,ebx
  imul eax,eax        ;x^2
  imul ebx,ebx        ;y^2
  add eax,ebx          ;x^2 + y^2
  sar eax,8
  cmp eax,1024        ;if (x^2 + y^2) > 1024 then
  jg  Break           ; break
  dec si              ;kolor--
  jnz @@LoopFractal

;   Liczba iteracji powyższego wzoru oznacza numer koloru jaki zostanie nadany pikselowi.

Break:
  mov ax,si
  mov byte [edi],al ; czy nie trzeba zmienić na eax?

  add dword [CntrB],720
  add edi,320
  dec word [Y]
  jnz @@LoopVert
  add dword [CntrA],568
  inc word [X]
  mov edi,0xa0000
  add edi, dword [X]
  cmp word [X],320
  jnz @@LoopHoriz

halt: ; wyświetlanie na monitorze i zawieszanie
  cli
  hlt

  CntrA dd 0
  CntrB dd 0
  X dd 0
  Y dd 0

times 510 - ($-$$) db 0
dw 0xaa55
