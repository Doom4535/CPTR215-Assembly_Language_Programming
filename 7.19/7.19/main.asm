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
Mainloop:					; playing around with arrays, this usage is not the most efficient; but works
			mov.w #0x02400,r6				; creating array for the initialization of memory locations
			mov.w #0x0000,r4				; using r4 for count and setting to 0
			call  #Init						; calling initialization subroutine (stores memory values)

			;mov.w #0x0002,&0x02402
			;mov.w #0x0003,&0x02404
			;mov.w #0x0004,&0x02406
			mov.w #0x0000,r4				; using r4 for count and setting to 0 (again, reusing this register
											; since it is no longer needed for the #Init)
			mov.w #0x02400,r7				; starting an array to keep track of values
			clr   r5						; zero'ing out the register to be used for addition

			call #Code						; calling code subroutine
			jmp $							; locking in loop

Code:
			add.w @r7+,r5
			inc r4							; incrementing the count variable
			cmp #0004,r4					; checking count variable
			jl  Code						; if conditions not met (r4 less than 4), looping
			ret								; returning once conditions met

Init:
			mov.w #0x0006,0(r6)				; storing initial values with array
			inc r4							; incrementing the count variable
			incd r6							; incrementing r6 to move to the next memory location
											; (using incd for +2 for word support)
			;cmp #0004,r4					; checking count variable
			mov.w #0x000A,0(r6)				; storing initial values with array
			inc r4							; incrementing the count variable
			incd r6							; incrementing r6 to move to the next memory location
											; (using incd for +2 for word support)
			;cmp #0004,r4					; checking count variable
			mov.w #0x0014,0(r6)				; storing initial values with array
			inc r4							; incrementing the count variable
			incd r6							; incrementing r6 to move to the next memory location
											; (using incd for +2 for word support)
			;cmp #0004,r4					; checking count variable
			mov.w #0x000D,0(r6)				; storing initial values with array
			inc r4							; incrementing the count variable
			incd r6							; incrementing r6 to move to the next memory location
											; (using incd for +2 for word support)
			cmp #0004,r4					; checking count variable
			;jl  Init						; if conditions not met (r4 less than 4), looping
			ret

			; old section that is no longer needed
			;mov.w #0x0006,&0x02400			; storing initial values
			;mov.w #0x000A,&0x02402
			;mov.w #0x0014,&0x02404
			;mov.w #0x000D,&0x02406

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
            
