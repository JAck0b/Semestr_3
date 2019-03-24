section .text
global main
extern printf
extern scanf

main:
  finit
  push helloMessage
  call printf
  add esp, 4

  push number2
  push operator
  push number1
  push formatScanf
  call scanf
  add esp, 16

  fld qword [number1]

  cmp byte [operator], '+'
  je addition

  cmp byte [operator], '-'
  je subtraction

  cmp byte [operator], '*'
  je multiplication

  cmp byte [operator], '/'
  je division

  jmp end


addition:
  fadd qword [number2]
  jmp print

subtraction:
  fsub qword [number2]
  jmp print

multiplication:
  fmul qword [number2]
  jmp print

division:
  fdiv qword [number2]
  jmp print

print:
  fstp qword [result]
  push dword [result+4]
  push dword [result]
  push formatPrintf
  call printf
  add esp, 12
  jmp end

end:
  xor eax, eax
  ret

section .bss
  operator resb 1
  number1 resq 2
  number2 resq 2
  result resq 2

section .data
  formatScanf: db "%lf %c %lf", 0
  formatPrintf: db "%lf", 10, 0
  formatPrintf2: db "%s", 10, 0
  helloMessage: db "Hello, enter your expresion. You can use +, -, *, /.", 10, 0
