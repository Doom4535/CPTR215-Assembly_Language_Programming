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

Mainloop:		; this program combines 7.5 parts a and b (no seperate 7.5-a and 7.5-b)
		mov.w   P1IN,R9			; moves the input from port p1 into register r9

		mov.w   R9,R8			; copying r9 to r8
		rla     R8				; rolling left one (this is a binary shift (so it is moving 1 bit (1 or 0), not hex, character)
		mov.w	#0x0000,R5		; moving 0 to r5 so that cmp can be used differently
		;mov.w   #0x0001,R8      ; used to debug (this creates a negative, the pin (at least during developement)
								 ; was giving a negative number, which then subtracted from zero always skipped
								 ; the loop
		cmp     R8,R5			; comparing 0 to r8 ( 0 - r8), this way jl can be used to avoid the zero case
								; remember cmp is src,dst (which does dst - src)
		jl		less			; jumping to the less loop (a little missleading since the arithmetic is backwards)
		jmp		end				; preventing the default of contining the program (only go to the less section
								; if the less condition is met, there for jumping to the end)

less:
		mov.w	#0xFFFF,R10		; moving 0xFFFF to r10 if jl conditions met (see above)

end:

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
