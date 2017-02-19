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
Mainloop:		; this code currently uses the memory from 0x2100 to 0x2108 (technically 2109)
				; to store the 5 output values from either greater or less, they will overwrite each
				; other when run (staying upto date)
				; it would be nice to make an array to manage this
			call #Initialize				; initializing
Code:										; code controll loop
			mov.w	#0x0004,r11				; looping/counter register
			cmp		r5,r4					; comparing r4 and r5 (r4-r5)
			jl		Less					; jumping to less if r4-r5 is negative
			cmp		r4,r5					; comparing r5 and r4 (r5-r4)
			jl		Greater					; jumping to Greater if r5-r4 is negative (r5 greater than r4)
			jmp		Equal					; else jump to equal

Less:
			;mov.w  	@r6+,@r6				; navigating the less value array
			; The following section uses manual code to write to memory blocks
			; would be nice to figure out how to implement this in an array
			mov.w	@r6+,&0x2100				; starting output storage at memory location 0x2100
			mov.w	@r6+,&0x2102
			mov.w	@r6+,&0x2104
			mov.w	@r6+,&0x2106
			mov.w	@r6+,&0x2108
			;dec		r11						; decrementing r11 to control loop count
			;cmp		#0x0000,r11				; comparing r11 to determine if the loop breaks
			;jge		Less					; looping if r11 greater than or equal to zero
			dec		r4						; decrementing r4 by 1
			mov.w	&0x2000,r6				; resetting less value array
			jmp		Code				; looping back to begining

Greater:
			;mov.w  	@r7+,&					; navigating the greater value array
			mov.w	@r7+,&0x2100				; starting output storage at memory location 0x2100
			mov.w	@r7+,&0x2102
			mov.w	@r7+,&0x2104
			mov.w	@r7+,&0x2106
			mov.w	@r7+,&0x2108
			;mov.w	r9,&0x2032
			;dec		r11						; decrementing r11 to control loop count
			;cmp		#0x0000,r11				; comparing r11 to determine if the loop breaks
			;jge		Less					; looping if r11 greater than or equal to zero
			dec		r4
			mov.w	&0x200A,r7					; resetting greater value array
			jmp		Code				; looping back to begining

Equal:
       		jmp		Code				; looping back to complete infinite loop

Initialize:		; initializes everything
			mov.w	#0x0020,r4				; initializing r4
			mov.w	#0x0023,r5				; initializing r5

			mov.w	#0x02000,r7				; started array for Less values here (memory 2000h-2008h)
			;mov.w	@r6,r11					; indexing
			mov.w	#0x0001,&0x2000			; initializing memory
			mov.w	#0x0002,&0x2002			; initializing memory
			mov.w	#0x0003,&0x2004			; initializing memory
			mov.w	#0x0004,&0x2006			; initializing memory
			mov.w	#0x0005,&0x2008			; initializing memory

			mov.w	#0x0200A,r6				; started array for Greater values here (memory 200Ah-2012h)
			;mov.w	@r7,r12					; indexing
			mov.w	#0x000A,&0x200A			; initializing memory
			mov.w	#0x0009,&0x200C			; initializing memory
			mov.w	#0x0008,&0x200E			; initializing memory
			mov.w	#0x0007,&0x2010			; initializing memory
			mov.w	#0x0006,&0x2012			; initializing memory
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

