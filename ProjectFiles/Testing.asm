
_main:

;Testing.c,1 :: 		void main(){
;Testing.c,2 :: 		TRISB = 0x00;
	CLRF       TRISB+0
;Testing.c,3 :: 		PORTB = 0x01;
	MOVLW      1
	MOVWF      PORTB+0
;Testing.c,4 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
