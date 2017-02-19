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


							; count the size of the array and count the number of 1's in the array

Mainloop:					;
			mov.w	#0x02400,r4			; setting r4 to hold an array
			clr		r5					; clearing r5 to use for addition
			clr		r6					; clearing r6 to use for the counter
			mov.w   #0x00007,r7			; setting r7 to hold the size of the array (randomly chose an array of size 8)
										; remember to change line 51 to reflect half this value if changed)

					; initializing array values
			mov.w	#0x00001,&0x2400	; setting initial values
			mov.w	#0x00000,&0x2402	; could technically store as bytes and use the memory more efficiently
			mov.w	#0x00001,&0x2404
			mov.w	#0x00001,&0x2406
			mov.w	#0x00000,&0x2408
			mov.w	#0x00001,&0x240A
			mov.w	#0x00001,&0x240C
			mov.w	#0x00001,&0x240E

			P1DIR = 0x0F				; not sure what to put here (ultimately trying to enable lights)

Code:
			add.w	@r4+,r5				; adding the value at r4 to r5 and incrementing
			inc		r6					; incrementing the counter
			cmp		r7,r6				; controlling loop
			jl		Code				; looping
			cmp 	#0x0004,r5			; comparing sum of array to 4 (1/2 of the maximum value of the array)
			jge		Green				; if the value is = or greater than 1/2 the max, move to green
			jmp     Red					; else go red

Red:
			P1OUT = 0x0000;			; turning on red led
			jmp $						; locking
Green:
			P1OUT = 0x0007;				; turning on the green led
			jmp $						; locking



                                            

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
            
