;================================================
; module  : lab2.asm
; created : Frederick Richard Wallace-Tarry
; This code used an 8255 to write to a display buttons pressed on keypad
;================================================

;some useful bit address equates
RDpin equ 0B3h
WRpin equ 0B2h
A0pin equ 0B5h
A1pin equ 0B4h

;lookup table for keypad values
org 8000h

KCODE0: db 06h,5Bh,4Fh,71h
KCODE1: db 66h,6Dh,7Dh,79h
KCODE2: db 07h,7Fh,67h,5Eh
KCODE3: db 77H,3Fh,7Ch,58h

;start address for program
org 8100h

start:
	   ;configure 8255 control register
setb A0pin ;The Control Register (CR) is accessible when the device’s a1 and a0 are set to “11”
setb A1pin 
;set port A and B to output
;set port CU output and CL as input
mov a, #81h 
mov P1, a ;Port 1 is the port through which the 8255 and 8051 communicate
lcall write

; clear digit registers (just to be on safe side)
RegisterReset:
mov R0,#00h ;Digit 1
mov R1,#00h ;Digit 2
mov R2,#00h ;Digit 3
mov R3,#00h ;Digit 4
mov R5,#00h ;Used for delay
mov R6,#00h ;Column number
mov R7,#00h ;Number coming in
;------- Start Keypad Loop ---------

KLoop:
;Test to see if keypad pressed – skip ahead
;to display call if no key pressed
;A0=0 A1=1 selects port C
clr A0PIN
setb A1PIN
mov a,#0FFh 			;send all 'ones' to C_output
mov P1, a
lcall write
lcall read
anl a,#0Fh 			;we are masking upper nibble
cjne a,#00h,CHECKBUTTON 	;if key is being pressed jump to CHECKBUTTON	
aftercheck:
acall Display
ljmp KLoop 			;return to start of loop
;------- End Keypad Loop ---------


;Only jump here if a button is being pressed
;Establish which key has been pressed (explained step by step)
;Remember,this is not a subroutince,hence once I'm done I have to jump back into loop
CHECKBUTTON:
;First I check what column is being pressed
jb a.0,COLUMN0
jb a.1,COLUMN1
jb a.2,COLUMN2
jb a.3,COLUMN3

;I am storing column number in R6
COLUMN0:
mov R6,#0
sjmp CHECKROW
COLUMN1:
mov R6,#1
sjmp CHECKROW
COLUMN2:
mov R6,#2
sjmp CHECKROW
COLUMN3:
mov R6,#3
sjmp CHECKROW

CHECKROW:
;A0=0 A1=1 selects port C
clr A0PIN
setb A1PIN

mov dptr, #KCODE0 ;Load datapointer accordingly
mov a,#1Fh	  ;check if its ROW1
mov P1,a
lcall write
lcall read
anl a,#0Fh
cjne a,#00h,UPDATENUMBERS

mov dptr, #KCODE1
mov a,#2Fh 	   ;check if its ROW2
mov P1,a
lcall write
lcall read
anl a,#0Fh
cjne a,#00h,UPDATENUMBERS

mov dptr, #KCODE2
mov a,#4Fh	   ;check if its ROW3
mov P1,a
lcall write
lcall read
anl a,#0Fh
cjne a,#00h,UPDATENUMBERS

mov dptr, #KCODE3
mov a,#8Fh	   ;check if its ROW4
mov P1,a 
lcall write
lcall read
anl a,#0Fh
cjne a,#00h,UPDATENUMBERS

;First I have to update dptr depending on what column is being pressed
;Then I check for F
;then I can shift digits and insert new one
UPDATENUMBERS:
mov a,R6		;move column into accululator
jz shiftdigits	        ;if it's first column skip updatepointer
ljmp updatepointer      ;otherwise update pointer

shiftdigits:
movc a,@a+dptr		;move into accumulator the correct pointer
cjne a,#71h,continue	;If its not F skip ahead
lcall timerdelay	;delay for a bit,as we are going back into loop
ajmp start		;jump back to start

continue:
mov R7,a		;move button pressed into R7
mov a,R2 		;move R2 into accumulator
mov R3,a		;shift it to R3
mov a,R1		;repeat
mov R2,a
mov a,R0
mov R1,a
mov a,R7 		;new number is stored in R7
mov R0,a		;it is then shifted to R0

lcall TIMERDELAY	;calls a longer delay
ajmp aftercheck		;once delay is complete continue to display


;jumps in when column not 1 and leaves once pointer is updated
updatepointer:
inc dptr		;increment pointer
djnz a, updatepointer	;decrement a,and break once its 0
sjmp shiftdigits

;The display subroutine uses the concept of persistance of vision as mentioned in report
;I display one digit at a time, and use a small delay to avoid flickering
Display: 
;A0=0,A1=0 selects port A
    clr A0pin
    clr A1PIN
    mov a, R3 ;right most digit is stored in R3
    mov P1, a
    lcall write
;A0=1,A1=0 selects port B (which we use to select digit)
    setb A0PIN
    clr A1PIN
    mov a, #01h	;selects right most digit
    mov P1, a
    lcall write
    
    lcall delay
    
 ;I'll do the same for the other 3 Digits
 
    clr A0pin
    clr A1PIN
    mov a, R2 ;third digit(we are reading from left to right) stored in R2
    mov P1, a
    lcall write
    setb A0PIN
    clr A1PIN
    mov a, #02h
    mov p1, a
    lcall write
    lcall delay

    clr A0pin
    clr A1PIN
    mov a, R1 ;second digit is stored in R1
    mov P1, a
    lcall write
    setb A0PIN
    clr A1PIN
    mov a,#04h
    mov p1, a
    lcall write
    lcall delay

    clr A0pin
    clr A1PIN
    mov a, R0 ;first digit is stored in R0
    mov P1, a
    lcall write
    setb A0PIN
    clr A1PIN
    mov a, #08h
    mov p1, a
    lcall write
    lcall delay

    mov a,#00h		;When I am not In delay subroutine I don't want any digit to be lit up.
    mov P1,a		;This solved the problem I mentioned in Lab report!
    lcall write
    ret
    
;used once address and data lines setup
write:  
    clr  WRpin
    nop
    setb WRpin
    nop
    ret
    
;used once address and data lines setup
;similar to read,but i also move the value red from Port 1 to accumulator
read:
    clr RDpin	;Clearing RDpin
    nop		;No Operation
    setb RDpin
    mov a, P1	;Load the contents of P1 into the accumulator
    nop		;No Operation
    ret		;Return from subroutine

;Simple delay subroutine
delay:
mov R5,#0FFh
loop: djnz R5,loop
ret

;longer delay using timers
;I use this after detecting a button press, hence it is used for debouncing
timerdelay:
mov R5,#04h
again:mov TMOD,#10h		;Timer 1/Mod1(16 bit)/clock mode
mov TH1,#06h		
mov TL1,#00h
setB TR1		;start timer
back: jnb TF1,back	;continue timer untill it rolls over
clr TR1			;switch timer off
clr TF1			;clear carry
djnz R5,again
ret			;once it has rolled over 5 times return

END
;================================================

;updates number if a key has been pressed
