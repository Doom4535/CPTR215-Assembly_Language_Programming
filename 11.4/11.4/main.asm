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


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
Mainloop:
			bis.b	BIT7, P4DIR				; enabling p4.7 as output (green led)
			bis.b	BIT0, P1OUT				; enabling p1.0 as output (red led)
			bic.b	BIT1, P1IN				; enabling p1.1 (right button) as input
			bis.b	#BIT1, &P1REN 			; Set pull up for switch on P1.1
			bis.b	#BIT1, &P1OUT		 	; Make the pull up pull up not down.forever

			clr		r7						; clearing r7 for counter
			;clr		r8						; clearing r8 for sleep loop
				; testing lights
			bis.b	BIT7, P4OUT				; setting p4.7 (green led) out
			bis.b	BIT0, P1OUT				; setting p1.0 (red led) out
			bic.b	BIT7, P4OUT				; setting p4.7 (green led) out
			bic.b	BIT0, P1OUT				; setting p1.0 (red led) out

				; interupt stuff
			bis.b   #BIT1, &P1IE			; enabling p1.1 interupt
			bis.b	#BIT1, &P1IES			; p1.1 high/low edge
			bic.b	#BIT1, &P1IFG			; p1.1 ifg cleared

			; Battery is connected to p6.4 and ground
			; (this is instead of p1.1 and ground)
			; The defined voltage to compare against is 0.25 * Vcc

			; This makes it sound like CBCTL needs to be used
			; http://www.ti.com/lit/ug/slau408d/slau408d.pdf
			; and here: http://www.digchip.com/datasheets/parts/datasheet/477/MSP430F5529-pdf.php
			; unsure

			; changing code to use ADC12 (not 10)
			;bis.b	BIT4, P6DIR				; setting p6.4 as input

			mov.w	#ADC12SHT_2+ADC10ON+ADC12IE,ADC12CTL0
			mov.w	#INCH1, ADC12CTL1
			bis.b	#0x02,	ADC12AE0
			bis.b	BIT4,	P6DIR			; selecting input

Code:
			nop
			bis.w	#GIE,SR					; enabling all interupts
			nop

control:
				; check the voltage of the battery
			bit.b	#CBOUT,CBCTL2				; checking output voltage
			jnz		green						; battery fine
			jz		red							; battery below
			ret

;press:
			;bit.b	#BIT1, &P1IN 			; Check if the button is pressed
			;jnz		press					; looping if not pressed
			;ret

green:
			bis.b	#BIT7, P4OUT			; turning green LED on
			bic.b	#BIT0, P1OUT			; turning red LED off
			ret

red:
			bis.b	#BIT0, P1OUT			; turning red LED on
			bic.b	#BIT7, P4OUT			; turning green LED off
			ret

P1_ISR:
				; button interrupt
			call	#b_press				; double check for button press
			call	#release				; checking for ghost presses
			call	#release
			call	#sleep
			call	#release
			call	#sleep
			call	#release
			call	#control				; performing action
			bic.b	#BIT1,	&P1IFG			; clear p1.1 ifg
			reti							; returning

release:
				; check for button release
			bit.b	#BIT1, &P1IN			; checking button press
			jz		release					; testing release
			ret
											; returning
sleep:
			inc		r7						; counting loops
			cmp		#0xFFFF, r7				; comparing loops
			jl		sleep					; looping if propper conditions met
			clr		r7						; clearing counter
			ret								; returning


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
            .sect 	P1_ISR		; setting up interupt for p1
            .short	P1_ISR		; setting up interupt for p1
            
