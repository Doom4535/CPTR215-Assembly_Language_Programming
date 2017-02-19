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
			mov.w	#0x0000,r10				; setting fail bit (using r10) to 0
			mov.w	#0x0002,r4				; Writing initial value
			mov.w	#0x0002,r5				; Writing initial value
			rrc.w	r4						; rotating r4 write and saving last value to carry
			jc		Reg5					; if carry is set continue to evaluate next register
			mov.w	#0x0002,r10				; using this to determine if a register failed
			;jmp		fail				; if carry is not set, fail check and end

Reg5:
			rrc.w	r5						; rotating r5 write and saving carry
			jc		Success					; if carry is set, jump to execute conditions
			cmp		#0x0001,r10				; checking to see if fail bit in r3 is set
			jl		partial					; if fail bit is set jump to partial
			jmp		fail					; if carry is not set, fail check and end

Success:
			cmp		#0x0001,r10				; checking to see if fail bit in r3 is set
			jge		partial					; if the fail bit was set moving to partial
			mov.w	#0x0FF0,r9				; setting r9 to value specified if conditions met
			jmp		end						; ending program

partial:
			mov.w	#0x0FF0,r9				; setting this value here because the book wants some, unspecified value inverted...
			inv		r9						; inverting r9
fail:										; ending here

end:
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

