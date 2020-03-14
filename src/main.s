; ----------------------------------------------------------------------------
; ------------------------------- Hello World --------------------------------
; ----------------------------------------------------------------------------

; Include some helpful constants
.include "constants.s"

; Start the code for our program, no .org needed!
.code

; ----------------------------------------------------------------------------
; Main Routine
; ----------------------------------------------------------------------------

.proc main
	; Play audio forever.
	lda #$01		; enable pulse 1
	sta APUSTATUS
	lda #$05		; period
	sta $4002
	lda #$02
	sta $4003
	lda #$bf		; volume
	sta $4000
forever:
	stx 0
	inx 			; Increment the pitch
	stx $4002		; Set the pitch to the value in register x
	jmp forever
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
	stx PPUCTRL		; PPUCTRL = 0
	stx PPUMASK		; PPUMASK = 0
	stx APUSTATUS		; APUSTATUS = 0

	; PPU warmup, wait two frames, plus a third later.
	; http://forums.nesdev.com/viewtopic.php?f=2&t=3958
PPU1:	bit PPUSTATUS		; Test the PPU status
	bpl PPU1      		; Jump back if PPUStatus is 0 or negative
PPU2:	bit PPUSTATUS		; Test the PPU Status again
	bpl PPU2		; Same idea from before

	; Zero ram (not sure how this works yet)
	txa			; Transfer X's current value to A
	stx 0			; Explicitly initialize X to a 0 immediate value
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
	bne zero_ram		; Hows does BNE do anything here???

	; Final wait for PPU warmup.
finish:	bit PPUSTATUS		; Test the PPU status after the RAM is zeroed
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