; v - co się dzieje w programie krok po kroku
; m - memory (b - początek, e - koniec)
                opt f-g-h+l+o+
                org $1000

start           equ *

                lda <text ; niższy bit do akumulatora
                sta $80 ; akumulator do pamięci
                lda >text ; wyższy bit do akumulatora
                sta $81 ; akumulator do pamięci
                ldy #1 ; licznik ustawiony na 1
                lda #%00011111 ; liczba do konwersji
                jsr phex ; skok do procedury

                lda <text ; łądowanie niższego bitu do akumulatora
                ldx >text ; ładowanie wyższego bitu do rejestru x
                jsr $ff80 ; wypisywanie do stdout
                brk ; koniec

phex            pha
                jsr pxdig
                pla
                lsr @ ; przesuwanie w prawo
                lsr @
                lsr @
                lsr @
pxdig           and #%00001111 ; czyszczenie pierwszych czterech bitów
                ora #'0' ; 0011 0000
                cmp #'9'+1 ; sprawdzanie czy jest większe of 1010 (A)
                bcc pr ; czy a < m
                adc #'A'-'9'-2 ; sprywne zauważanie, że trzeba dodać 0000 0111
pr              sta ($80),y ; zapisywanie do pamięci
                dey ; zmniejszanie wagi wypisywaniej cyfry
                rts

                org $2000 ; pointer na 2000
text            equ *
                dta b(0),b(0) ; dwa kolejne bajty będą nullem
                dta b(10) ; '\n'
                dta b(0) ; koniec stringa

                org $2E0 ; rozpoczęcie działania programu
                dta a(start)

                end of file
