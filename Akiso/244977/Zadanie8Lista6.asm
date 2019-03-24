section .text
global main
extern printf
extern scanf

main:

  push message
  call printf
  add esp, 4

  push x
  push option
  push formatScanf
  call scanf
  add esp, 12

  cmp byte [option], 's'
  je sinh

  cmp byte [option], 'a'
  je arcsinh

  jmp end

sinh:
  finit
  fld qword [x]
  fldl2e ; log2(e)
  fmulp st1, st0
  fstp qword [result]
  fld1
  fld qword [result]
  fprem ; remaider
  f2xm1 ; 2^remaider -1
  faddp st1, st0 ; 2^remainder
  fld qword [result]
  fld st1
  fscale ; 2^xlog2(e)
  fstp qword [result]
  fld qword [result]

  fld1
  fdiv st0, st1 ; 2^(-x)log2(e)

  fld qword [result]
  fsub st0, st1
  fstp qword [result] ; all numerator
  fld1
  fld st0
  faddp st1, st0 ; all denominator
  fld qword [result]
  fdiv st0, st1 ; all fraction
  jmp print

arcsinh:
  finit
  fld qword [x]
  fld st0
  fmulp st1, st0 ; x*x
  fld1
  faddp st1, st0 ;x*x + 1
  fsqrt ;sqrt(x*x + 1)
  fld qword [x]
  faddp st1, st0 ;x + sqrt(x*x + 1)
  fstp qword [result]
  fld1
  fld qword [result]
  fyl2x ; log2(x + sqrt (x*x + 1))
  fldl2e
  fdivp st1, st0
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
  x resq 2
  option resb 1
  result resq 2

section .data
  formatScanf: db "%c %lf", 0
  formatPrintf: db "%lf", 10, 0
  message: db "option x (option = a(acrsinh) or s(sinh), -1 <= x < 1=)", 10, 0
  two: dq 2.0
