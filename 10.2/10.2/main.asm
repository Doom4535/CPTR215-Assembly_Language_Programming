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
			mov.w	#LFXT1S_2,&BCSCTL3 ; 12 Khz VLO as ACLK source

				; warning about all the sleep and release calls
				; the button on my board is terrible (the other
				; button is even worse) and this seems to catch
				; most of the ghost presses, but no guarantees
			bis.b	#BIT0, &P1DIR			; setting P1.0 as output for red led
			bic.b	#BIT1, &P1DIR			; setting p1.1 (right button) as input
			bis.b	#BIT7, &P4DIR			; setting p4.7 as output for green led
			bis.b	#BIT1, &P1REN 			; Set pull up for switch on P1.1
			bis.b	#BIT1, &P1OUT		 	; Make the pull up pull up not down.forever

			bis.b	#BIT7,P4OUT				; enabling green led initially

			mov.w	#CCIE,TA0CCTL0			; TACCR0 interrupt enabled
			mov.w	#999d,TA0CCR0			; TACCR0 counts to 1000
			mov.w	#TASSEL_+MC_1,TA0CTL	; ACLK, upmode

			bis.w	#LPM1+GIE,SR			; LPM1, enable interrupts

			nop
	    	bis.w	#LPM3|GIE, SR			; Put the processor in Low Power Mode 3 (ACLK still active) & Enable Interrupts.
	    	nop

TA0_ISR
			xor.b	#BIT0,P1OUT				; toggling red light
			xor.b	#BIT7,P4OUT				; toggling green light

;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack
            
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   RESET_VECTOR
            .short  RESET
            .sect   TIMER0_A0_VECTOR
            .short  TA0_ISR
            .end
