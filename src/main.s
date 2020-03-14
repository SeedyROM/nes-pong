; ----------------------------------------------------------------------------
; ------------------------------- Hello World --------------------------------
; ----------------------------------------------------------------------------

.include "constants.s"

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
	stx $4002		; Set the pitch to the value in register a
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
	txa			; Transfer X to A
	stx 0			; Explicitly initialize x to a 0 immediate value
zero_ram:
	sta $000, x		; Block magic? (TODO: Understand this better)
	sta $100, x
	sta $200, x
	sta $300, x
	sta $400, x
	sta $500, x
	sta $600, x
	sta $700, x
	inx			; Increment x
	bne zero_ram		; Hows does BNE do anything here???

	; Final wait for PPU warmup.
final:	bit PPUSTATUS		; Test the PPU status after the RAM is zeroed
	bpl final		; Same as before

	jsr main
.endproc

; ----------------------------------------------------------------------------
; Reset handler
; ----------------------------------------------------------------------------

.proc reset
	; Setup the hardware
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