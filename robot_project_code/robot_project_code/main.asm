;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file

;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer

		; useful info, the app sends information in the format: 's,left,right'
		; where s stands for set, and the left/right values can range from -100 to 100 (left/right
		; wheel speed control in percent)
		; example: s,-100,100
		; also may send: 'r' where r overrides all and resets (halts everything)

		; this code currently is for testing lights (then mod if this works)

		; from book
		; this section seems to be putting the system into some kind of Low power mode
;			mov.b		&CAL_BC1_1MHZ,BCSCTL1			; adjusting the clock
;			mov.b		&CALDCO_1MHZ,CDOCTL

				; modifing here for msp430 f5529
			bis.b		#BIT0, P1DIR					; enabling red led
			bis.b		#BIT7, P4DIR					; enabling green led
			clr.b		P1OUT							; starting turned off
			clr.b		P4OUT							; ^

			mov.b		#6h, P1SEL						; adjust pins
			mov.b		#6h, P1SEL2

			bis.b		#UCSWRST+UCSSEL_2, UCA0CTL1		; Adjust the UART mode
				; enable SW reset, use SMCLK
			mov.b		#68h, UCA0BR0					; Low bit of UCBRx is 104
			mov.b		#0h, UCA0BR1					; High bit of UCBRx is 0
			mov.b		#UCBRS_1, UCA0MCTL
				; Second modulation stage select is 1
				; Baud Rate = 9600
			bic.b		#UCSWRST, UCA0CTL1
				; clear SW reset, resume operation
			;bis.b		#UCA0RXIE, IE2					; Enable RX interupt
			;bis.b		#UCA0RXIE, SFRIE1					; Enable RX interupt
			bis.b		#UCA0IE, SFRIE1
			nop
			bis.w		#GIE+LPM0, SR
			nop

				; minor modifications start here
;-------------------------------------------------------------------------------
USCIAB0RX_ISR
;-------------------------------------------------------------------------------

		; might change this to check for 's' and then to remove the following comma,
		; take the next value (left wheel speed), drop the following comma and take
		; the next value (right wheel speed), then look
		; for end line and repeat.  If an 'r' is recieved it halts.
		; the values could be moved to say registers r14 (left) and r15 (right) and
		; then converted to pwm and pushed out to the two motors
		; the comma's could be used to 'synchronize' the data (or serve as data quality
		; checkpoints) by having it check for a comma when one is expected

			cmp.b		#'r', UCA0RXBUF
				; checking if the recieved character is 'r' (for red led)
			jne			Second
				; if not jump
			bis.b		#BIT0, &P1OUT
				; if it is 'r' turn on red led
			jmp EndISR
Second:
			cmp.b		#'g', UCA0RXBUF
				; check if the received character is 'g'
			jne Third
				; if not jump
			bis.b		#BIT7, &P4OUT
				; if it  is 'g' turn on green led
			jmp EndISR
Third:
			cmp.b		#'b', UCA0RXBUF					; checking for 'b' which is for both led's
			jne	Fourth									; if not jump
			bis.b		#BIT0, P1OUT					; red led
			bis.b		#BIT7, P4OUT					; green led
			jmp	EndISR
Fourth:
			bic.b		#BIT0, P1OUT					; clearing all outputs if input not 'r' or 'g'
			bic.b		#BIT7, P4OUT					; ^
EndISR:
			reti
;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack

;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
            .sect	USIAB0RX_VECTOR
            .short	USCIAB0RX_ISR
