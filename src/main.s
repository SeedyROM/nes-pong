; ----------------------------------------------------------------------------
; ------------------------------- Hello World --------------------------------
; ----------------------------------------------------------------------------

; Include some helpful constants
.include "constants.s"

; Start the code for our program, no .org needed!
.code

; ----------------------------------------------------------------------------
; Data Structures
; ----------------------------------------------------------------------------

.struct Player
	x_position 	.word
	y_position 	.word
	score      	.word
.endstruct

; ----------------------------------------------------------------------------
; Main Routine
; ----------------------------------------------------------------------------

counter 	= $00
counter2 	= $01

.proc main
	; Play audio forever.
	lda #$01		; Enable pulse channel 1
	sta APU_STATUS

	lda #$05		; Set the period / frequency
	sta APU_PULSE1_ENVELOPE

	lda #$02		; Set the duration?
	sta APU_PULSE1_SWEEP

	lda #%11100000		; Set the volume
	sta $4000

	ldx #$00		; Setup our counter for pitch
forever:
	stx APU_PULSE1_ENVELOPE ; Set the pitch to 0
loop:	
	inc counter		; Increment the counter variable by 1
	cmp counter		; 
	bne loop		; See if the counter has wrapped to 0
	inx			; Increment the counter, which changes the pitch
	jmp forever		; Start again
.endproc

; ----------------------------------------------------------------------------
; Setup Routine
; ----------------------------------------------------------------------------

.proc setup
	sei			; Disable interrupts (TODO: Remove this later)
	cld			; Clear decimal mode
	ldx #$ff
	txs			; Initialize SP = $FF
	inx
	stx PPU_CONTROL		; PPU_CONTROL = 0
	stx PPU_MASK_BITS		; PPU_MASK_BITS = 0
	stx APU_STATUS		; APU_STATUS = 0

	; PPU warmup, wait two frames, plus a third later.
	; http://forums.nesdev.com/viewtopic.php?f=2&t=3958
PPU1:	bit PPU_STATUS		; Test the PPU status
	bpl PPU1      		; Jump back if PPU_STATUS is 0 or negative
PPU2:	bit PPU_STATUS		; Test the PPU Status again
	bpl PPU2		; Same idea from before

	; Zero ram (not sure how this works yet)
	ldx #$00		; Explicitly initialize X to a 0 immediate value
zero_ram:
	sta $000, x		; Iterate X until it wraps back around to 0
	sta $100, x		; AKA Clear from $0000, $07FF
	sta $200, x
	sta $300, x
	sta $400, x
	sta $500, x
	sta $600, x
	sta $700, x
	inx
	cpx #$00		; Iterate until overflow
	bne zero_ram		; Hows does BNE do anything here???

	; Final wait for PPU warmup.
finish:	bit PPU_STATUS		; Test the PPU status after the RAM is zeroed
	bpl finish		; Same as before

	jsr main		; Jump into the main game loop
.endproc

; ----------------------------------------------------------------------------
; Reset / start handler
; When the machine starts up the reset interrupt is called and thus our 
; setup and main subroutines get run.
; ----------------------------------------------------------------------------

.proc reset
	jsr setup
.endproc

; ----------------------------------------------------------------------------
; NMI (vertical blank) handler
; ----------------------------------------------------------------------------

.proc nmi
	rti
.endproc

; ----------------------------------------------------------------------------
; IRQ handler
; ----------------------------------------------------------------------------

.proc irq
	rti
.endproc

; ----------------------------------------------------------------------------
; Vector table
; ----------------------------------------------------------------------------

.segment "VECTOR"
.addr nmi
.addr reset
.addr irq

; ----------------------------------------------------------------------------
; Empty CHR data, for now
; ----------------------------------------------------------------------------

.segment "CHR0a"
.segment "CHR0b"