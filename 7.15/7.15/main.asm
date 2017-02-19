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
Mainloop:		; This code outputs the the division result to r5 and the remainder to r6
			mov		#0x00FF,&0x002000		; Numerator (doesn't really matter what number is used)
			mov		#0x0002,r4				; Denominator (two in this case for divide by 2)
			mov		#0x0000,r5				; counting subtractions

Code:
			mov		&0x002000,r6			; using this to hold the number to be divided
			call 	#Divide
			jmp		$

Divide:
			sub		r4,r6					;
			inc		r5						; increment r5 (counting loops)
			cmp		r4,r6					; seeing if division still possible
			jge		Divide					; looping
			ret


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
            
