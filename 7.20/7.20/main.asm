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
Mainloop:			; This code converts single floating point to UQ16.16
					;
					; A warning is that it looses the least significant 7 bits of the number (a more
					; complicated coding routine should be able to retain them)
					;
					; floating point N = (-1)^S * 2^E * F
					; where S determines sign
					; E the exponent
					; F the fractional part
					; Single	Exponent bias: 127		bits for S: 1
					; bits for E: 8		bits for F: 10		bits total: 16
					;
					; UQ16.16
					; 16 bits for whole numbers
					; 16 bits for fractional part
				; setting initial numbers to be used
				; storing 255 in little endian (437F 0000)h
			mov #0x00000, &0x2400 		; 0000
			mov #0x0437F, &0x2402		; 437F

				; storing -255 in little endian (C37F 0000)h
			mov #0x04000,&0x2404		;
			mov #0x0C34F,&0x2406		;

			; storing random number
			mov #0x0000,&0x2408		;
			mov #0x0C57,&0x240A		;

			; storing random number
			mov #0x04000,&0x240C		;
			mov #0x0C34F,&0x240E		;


			clr	r12						; clearing r12 to use for counter
			clr r15						; using for cycle count

			mov #0x02400,r7				; storing values in r7 index
			mov #0x02500,r8				; storing write locations in r8 index

Conv:
			clrc						; clearing the carry bit
			mov.w @r7+,r6				; grabbing the LSB of first number
			mov.w @r7+,r4				; moving the MSB of first number to r4
			mov r4,r5					; hanging on to number
			rlc r5						; rotating r5 left
			jc	Cone					; jumping if carry bit set
			jmp Czero					; jumping if number is positive (c = 0)

Cone:	; for if the carry is 1 (neg. number)
			;insert code here for negative case
			rlc	r4						; removing the negative
			clrc 						; clearing carry
			rrc r4						; bringing in a 0 to replace the 1
			jmp Conv					; now treating like it is a positive number

Czero:	; for if the carry is 0 (pos. number)
			clrc						; clearing the carry
			rrc r5						; rotating r5 right (taking the last 7 bits (the rlc removed the 1st bit)
										; b/c 7 bits are used for the exponent in the single format)
			; need to rra 7 more times to remove the fractional part
			call  #Rrotate7
			sub.w #0x007F,r5			; subtracting the bias value of 127 (7F) from the Exponent value to
										; to get the actual exponent
			clrn						; playing it safe and clearing the N register
			call  #FractionRot			; calling
			clr   r12					; clearing counter to play it safe
			mov.w r5,r12				; setting the number of rotations for UQ16 (this is determined by
										; the exponent variable (number of integer digits)
			;sub.w #0x00001,r12			; now subtracting one because the code includes the 0th case

			mov.w r13,&0x02002			; backing up the fraction part to iodat (this is overwritten each run)
			clr   r14					; clearing r14 to take on Most Sig. part
			call  #UQ16					;
			jmp   Status				;

UQ16:
			clrc						; clearing carry
			rlc  r6						; moving the Most Sig. part to r14 (this does clear out r13)
			rlc  r14					; pulling carry to r14
			clrc						; clearing carry
			cmp  #0x00000,r12			; comparing zero to adjusted exponent value
			dec  r12					; decreasing coutner
			jge  UQ16					; looping
			clr  r12					; clearing counter
			mov.w r6,0(r8)				; sticking Least Sig. part in first memory slot (little ending style)
			incd r8						; incrementing r8 by two
			mov.w r14,0(r8)				; sticking Most Sig. part in second memory slot (little endian style)
			incd r8						; incrementing r8 by two
			ret

FractionRot:	; rotates the fractional right 7 times (looses the 7 Least Sig. bits, to combine the
				; 7 from the other half of the little endian)
			mov.w r4,r13				; Most Sig. part
				; r6 has the LS part
			clrc						; carry bit needs to be cleared
			;mov.w #0x0007,r12			; setting counter to rotate 7 times
			clr   r12					; zeroing counter (compared to  (0-6 < 7) in bitshuf)
			call  #bitshuf				; calling to drop last 7 bits and move other 7 in
			ret							; returning

bitshuf:		; actually shuffling the bits right (for FractionRot)
			rrc r13						; rotating r13 right and pushing to carry (converting r13 to reduced fractional part)
			rrc r6						; pulling carry value and rotating the LS part right (changing entire number to r13)
			clrc						; clearing carry
			inc r12						; incrementing r12
			cmp #0x0007,r12				; comparing count
			jl	bitshuf					; if conditions not met, loop
			clr  r12					; zeroing count register
			clrn						; clearing the N register (everything assumes a 0 starting state)
			setc						; compensating for the missing one frome 1.xx (before the fraction part)
			rrc r6						; pushing the one to r13
			clrc
			ret

Rrotate7:	; rotates right 7 times
			clrc						; don't want to include the carry
			rrc r5						; rotating r5
			inc r12						; incrementing count
			cmp #0x0007,r12				; comparing count
			jl	Rrotate7				; if conditions not met, loop
			clr r12						; zeroing count register
			clrn						; clearing the N register (everything assumes a 0 starting state)
			ret

Status:
			inc r15						; counting loops
			cmp #0x0004,r15				;
			jl Conv						; looping
			jmp $ 						; locking


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

