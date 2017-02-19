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
			clr	r5							; using for array x[n]
			clr	r6							; using for array y[n]

			bic.b	#BIT1, &P1DIR			; setting p1.1 (right button) as input
			bis.b	#BIT1, &P1REN 			; Set pull up for switch on P1.1
			bis.b	#BIT1, &P1OUT		 	; Make the pull up pull up not down.forever

			bis.b   #BIT1, &P1IE			; enabling p1.1 interupt
			bis.b	#BIT1, &P1IES			; p1.1 high/low edge
			bic.b	#BIT1, &P1IFG			; p1.1 ifg cleared

			call #initialize				; used to initialize the x[n] array

			nop
			bis.w	#GIE,SR					; enabling all interupts
			nop

			jmp		$

Code:
			mov.w	#0x2500,r6				; using for the y[n] starting location
			push	r5						; backing up x[n] start location
			push	r6						; temporarily storing the y[n] start location on the stack
			;add.w	#0x0001,r7	; testing
			call	#clear_array			; zero'ing array so straight add can be used
			clr		r9						; loop counter
			pop		r6						; popping back the y[n] start location
			push	r5						; backing up x[n] start location
			call	#Y_arr					; calling code to generate y[n] array
			pop		r5						; restoring  the x[n] start location to r5
			jmp		P1_ISR_ret



Y_arr:				; this holds the y[n] code (defined as y[n] = 2 * x[n] - x[n-1])
			add.w	@r5,0(r6)				; adding once
			add.w	@r5,0(r6)				; second addition (for x2 effect)
			decd	r5						; decrementing to get x[n-1] (yes this will reach outside of the array)
			sub.w	@r5+,0(r6)				; subtracting value and incrementing once (increment again below)
			incd	r5						; incrementing to skip ahead
			incd	r6						; incrementing write destination
			inc		r9						; counting loops
			cmp		r7,r9					; checking size of array
			jl		Y_arr					; looping
			ret



initialize:
			clr		r9						; using for loop counter
			mov.w	#0x000C,r7				; size of array
			mov.w	#0x2400,r5				; setting the x[n] starting location
			mov.w	#0x0056,&0x2400			; starting values
			mov.w	#0x0234,&0x2402
			mov.w	#0x0001,&0x2404
			mov.w	#0x0504,&0x2406
			mov.w	#0x45F0,&0x2408
			mov.w	#0xF731,&0x240A
			mov.w	#0x0FF1,&0x240C
			mov.w	#0x0001,&0x240E
			mov.w	#0x0001,&0x2410
			mov.w	#0x0001,&0x2412
			mov.w	#0x0002,&0x2414
			mov.w	#0x0003,&0x2416
			ret								; returning

clear_array:		; clears an array (currently hardcoded to a specific start point by register)
			mov.w	#0x0000,0(r6)			; clearing array
			incd	r6						; incrementing to next spot
			inc		r9						; counting clears
			cmp		r7,r9					; determining if all values have been cleared
			jl		clear_array				; looping if conditions met

			ret

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
			inc		r10
			cmp		#0xFFFF,r10
			jl		sleep
			clr		r10
			inc		r9
			cmp		#0x0F50,r9
			jl		sleep
			clr		r9
			ret

P1_ISR:				; Button S2 subroutine
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
			jmp		Code
P1_ISR_ret:
			reti							; returning from isr



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
            .sect	PORT1_VECTOR
            .short	P1_ISR
            .end

