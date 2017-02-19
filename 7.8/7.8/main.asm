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
Mainloop:				; this program calculates the first ten elements in a Fibonacci series
						; the implementation isn't the prettiest, currently the only part that is self incrementing
						; is the calculations part.  It could use a method to increment the writes to memory,
						; afterwards the total code size could be shrunk down by using a jump statement.

			mov.w	#0x0000,&0x2000			; moving the 1st value to the beginning of the array
			mov.w	#0x0001,&0x2002			; second value
			mov.w  	@r7+,r5					; indexing the array
			mov.w 	#0x0000,r10				; zero'ing r10
			mov.w	#0x0000,r11				; zero'ing r11
			mov.w	#0x2000,r5				; starting an array at r5 (keeps track of where the output is stored)
			add.w	@r5+,r10				; adding first memory value, incrementing
			add.w	@r5,r10					; adding second value, not incrementing
			mov.w	r10,r6					; moving the value to another register (this may or may not
											; come in handy for managing future jumps)
			mov.w	r10,&0x2004				; moving the computed value to memory

			; computations for next sequence
			mov.w	@r5+,r10				; incrementing, and moving number
			add.w	@r5,r10
			mov.w	r10,r6					; moving the value to another register
			mov.w	r10,&0x2006
			; computations for next sequence
			mov.w	@r5+,r10				; incrementing, and moving number
			add.w	@r5,r10
			mov.w	r10,r6					; moving the value to another register
			mov.w	r10,&0x2008
			; computations for next sequence
			mov.w	@r5+,r10				; incrementing, and moving number
			add.w	@r5,r10
			mov.w	r10,r6					; moving the value to another register
			mov.w	r10,&0x200A
			; computations for next sequence
			mov.w	@r5+,r10				; incrementing, and moving number
			add.w	@r5,r10
			mov.w	r10,r6					; moving the value to another register
			mov.w	r10,&0x200C
			; computations for next sequence
			mov.w	@r5+,r10				; incrementing, and moving number
			add.w	@r5,r10
			mov.w	r10,r6					; moving the value to another register
			mov.w	r10,&0x200E
			; computations for next sequence
			mov.w	@r5+,r10				; incrementing, and moving number
			add.w	@r5,r10
			mov.w	r10,r6					; moving the value to another register
			mov.w	r10,&0x2010
			; computations for next sequence
			mov.w	@r5+,r10				; incrementing, and moving number
			add.w	@r5,r10
			mov.w	r10,r6					; moving the value to another register
			mov.w	r10,&0x2012

			jmp Mainloop


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

