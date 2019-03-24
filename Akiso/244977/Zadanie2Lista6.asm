section .text
  global main
  extern printf

main:
mov eax, 0
mov ebx, 2
mov ecx, 2
mov edx, 0

jmp print

forloop:
  inc ebx
  cmp ebx, 10000
  jge endOfFile

prime:
  mov ecx, 2
secondForLoop:
  mov eax, ebx
  mov edx, 0

  cmp ecx, ebx
  jge print

  div ecx

  cmp edx, 0
  je forloop

  inc ecx
  jmp secondForLoop

print:
  push ebx
  push format
  call printf
  add esp, 4
  pop ebx
  jmp forloop


endOfFile:
  xor  eax,eax   ; EAX = 0
  ret

section .data
  format db "%d", 10, 0
