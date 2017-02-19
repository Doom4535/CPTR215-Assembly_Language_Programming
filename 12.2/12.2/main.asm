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

		; from book
			mov.b		&CALBC1_1MHZ,BCSCTL1			; adjusting the clock
			mov.b		&CALDCO_1MHZ,CDOCTL

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
			bic.b		#UCSWRTST, UCA0CTL1
				; clear SW reset, resume operation
			bis.b		#UCA0RXIE, IE2					; Enable RX interupt
			bis.w		#GIE+LPM0, SR

				; minor modifications start here
;-------------------------------------------------------------------------------
USCIAB0RX_ISR
;-------------------------------------------------------------------------------
			cmp.b		#'r', UCA0RXBUF
				; checking if the recieved character is 'r' (for red led)
			jne			Second
				; if not jump
			bis.b		#BIT0, &P1OUT
				; if it is 'r' turn on red led
			jmp ENDISR
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
ENDISR:
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
