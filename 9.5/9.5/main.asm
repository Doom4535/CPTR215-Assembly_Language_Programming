;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
   .cdecls C,LIST,"msp430.h"       ; Include device header file

;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory
            .global RESET					; Remember to set linker option to enter at RESET.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section
            .retainrefs                     ; Additionally retain any sections
                                            ; that have references to current
                                            ; section
;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer

;-------------------------------------------------------------------------------
                                            ; Main loop here
;-------------------------------------------------------------------------------
		; warning about all the sleep and release calls
		; the button on my board is terrible (the other
		; button is even worse) and this seems to catch
		; most of the ghost presses, but no guarantees
			bis.b	#BIT0, &P1DIR			; setting P1.0 as output for red led
			bic.b	#BIT1, &P1DIR			; setting p1.1 (right button) as input
			bis.b	#BIT7, &P4DIR			; setting p4.7 as output for green led
			bis.b	#BIT1, &P1REN 			; Set pull up for switch on P1.1
			bis.b	#BIT1, &P1OUT		 	; Make the pull up pull up not down.forever


			bis.b	#BIT7, &P4OUT
			;bic.b	#BIT0, &P1OUT

Mainloop:
			bis.b   #BIT1, &P1IE			; enabling p1.1 interupt
			bis.b	#BIT1, &P1IES			; p1.1 high/low edge
			bic.b	#BIT1, &P1IFG			; p1.1 ifg cleared
			clr 	r5						; using r5 for count
			clr		r6						; used to determine if green light is toggled

			nop
			bis.w	#GIE,SR					; enabling all interupts
			nop

			jmp		$						; infinite loop

P1_ISR:				; Toggle P1.0     Output
			inc		r5						; increase button press count
			inc		r6						; ^
			call	#release				; checking if released
			call	#sleep					; checking for ghosts
			call    #release				; ^
			call	#release				; ^
			call    #release				; ^
			call	#sleep					; ^
			call	#release				; ^
			call	#sleep					; checking for ghosts
			call    #release				; ^
			call	#release				;
			call	#release
			bic.b	#BIT1,	&P1IFG			; clear p1.1 ifg
			cmp		#0x0005, r6				; checking to see if 5 iterations have run
			jge		Green					; if ^ met jump to green
P1_ISR_ret:
			reti							; returning from isr

press:
			bit.b	#BIT1, &P1IN 			; Check if the button is pressed
			jnz		press					; looping if not pressed
			ret
release:
			bit.b	#BIT1, &P1IN 			; Check if the button is released
			jz		release					; looping if pressed
			call 	#sleep					; trying to filter out ghost bounces
			ret
sleep:
			inc		r8
			cmp		#0xFFFF,r8
			jl		sleep
			clr		r8
			inc		r9
			cmp		#0x0F50,r9
			jl		sleep
			ret

Green:
			XOR.b	#BIT7, &P4OUT			; toggling p4.7
			clr		r6						; reseting green toggle count
			jmp   	P1_ISR_ret 				; returning

;-------------------------------------------------------------------------------
;           Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect 	.stack

;-------------------------------------------------------------------------------
;           Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect	RESET_VECTOR
            .short	RESET
            .sect	PORT1_VECTOR
            .short	P1_ISR
            .end
