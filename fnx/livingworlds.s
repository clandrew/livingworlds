.cpu "65816"                        ; Tell 64TASS that we are using a 65816

.include "includes/TinyVicky_Def.asm"
.include "includes/interrupt_def.asm"
.include "includes/f256jr_registers.asm"
.include "includes/macros.s"

dst_pointer = $30
src_pointer = $32
column = $34
bm_bank = $35
TextLength = $36
text_memory_pointer = $38
AnimationCounter = $37
line = $40

; Code
* = $000000 
        .byte 0

.if TARGETFMT = "hex"
* = $00E000
.endif
.if TARGETFMT = "bin"
* = $00E000-$800
.endif
.logical $E000

tmpr .byte ?            ; A backed-up-and-restored color
tmpg .byte ?            
tmpb .byte ?
iter_i .byte ?          ; Couple counters
iter_j .byte ?
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

F256_RESET
    CLC     ; disable interrupts
    SEI
    LDX #$FF
    TXS     ; initialize stack

    ; initialize mmu
    STZ MMU_MEM_CTRL
    LDA MMU_MEM_CTRL
    ORA #MMU_EDIT_EN

    ; enable mmu edit, edit mmu lut 0, activate mmu lut 0
    STA MMU_MEM_CTRL
    STZ MMU_IO_CTRL

    LDA #$00
    STA MMU_MEM_BANK_0 ; map $000000 to bank 0
    INA
    STA MMU_MEM_BANK_1 ; map $002000 to bank 1
    INA
    STA MMU_MEM_BANK_2 ; map $004000 to bank 2
    INA
    STA MMU_MEM_BANK_3 ; map $006000 to bank 3
    INA
    STA MMU_MEM_BANK_4 ; map $008000 to bank 4
    INA
    STA MMU_MEM_BANK_5 ; map $00a000 to bank 5
    INA
    STA MMU_MEM_BANK_6 ; map $00c000 to bank 6
    INA
    STA MMU_MEM_BANK_7 ; map $00e000 to bank 7
    LDA MMU_MEM_CTRL
    AND #~(MMU_EDIT_EN)
    STA MMU_MEM_CTRL  ; disable mmu edit, use mmu lut 0

                        ; initialize interrupts
    LDA #$FF            ; mask off all interrupts
    STA INT_EDGE_REG0
    STA INT_EDGE_REG1
    STA INT_MASK_REG0
    STA INT_MASK_REG1

    LDA INT_PENDING_REG0 ; clear all existing interrupts
    STA INT_PENDING_REG0
    LDA INT_PENDING_REG1
    STA INT_PENDING_REG1

    CLI ; Enable interrupts
    JMP MAIN

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ClearScreen
    LDA MMU_IO_CTRL ; Back up I/O page
    PHA
    
    LDA #$02 ; Set I/O page to 2
    STA MMU_IO_CTRL
    
    STZ dst_pointer
    LDA #$C0
    STA dst_pointer+1

ClearScreen_ForEach
    LDA #32 ; Character 0
    STA (dst_pointer)
        
    CLC
    LDA dst_pointer
    ADC #$01
    STA dst_pointer
    LDA dst_pointer+1
    ADC #$00 ; Add carry
    STA dst_pointer+1

    CMP #$C5
    BNE ClearScreen_ForEach
    
    PLA
    STA MMU_IO_CTRL ; Restore I/O page
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

UpdateLut
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

    ; Put rotation code here
    ; Cycles: 
    ; 196-201 inclusive
    ; 202-207 inclusive
    ; 208-215 inclusive
    ; 216-223 inclusive
    ; LUT_START is at $E1C4

    CLC     ; disable interrupts
    SEI
    
    CLC ; Try entering native mode
    XCE ; xxx

    .as
    .xl
    SEP #$20
    REP #$10
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; 196-201 inclusive
    LDX #201*4
    LDA LUT_START,X
    STA tmpb
    INX
    LDA LUT_START,X
    STA tmpg
    INX
    LDA LUT_START,X
    STA tmpr

    LDX #200*4
    LDY #201*4
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y
    

    LDX #199*4
    LDY #200*4
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y

    LDX #198*4
    LDY #199*4
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y

    LDX #197*4
    LDY #198*4
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y

    LDX #196*4
    LDY #197*4
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y

    LDY #196*4
    LDA tmpb
    STA LUT_START,Y
    INY
    LDA tmpg
    STA LUT_START,Y
    INY
    LDA tmpr
    STA LUT_START,Y

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ; 202-207 inclusive
    LDX #207*4
    LDA LUT_START,X
    STA tmpb
    INX
    LDA LUT_START,X
    STA tmpg
    INX
    LDA LUT_START,X
    STA tmpr

    LDX #206*4
    LDY #207*4
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y
    
    
    LDX #205*4
    LDY #206*4
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y
    
    LDX #204*4
    LDY #205*4
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y
    
    LDX #203*4
    LDY #204*4
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y
    
    LDX #202*4
    LDY #203*4
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y

    LDY #202*4
    LDA tmpb
    STA LUT_START,Y
    INY
    LDA tmpg
    STA LUT_START,Y
    INY
    LDA tmpr
    STA LUT_START,Y

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ; 208-215 inclusive
    
    LDX #215*4
    LDA LUT_START,X
    STA tmpb
    INX
    LDA LUT_START,X
    STA tmpg
    INX
    LDA LUT_START,X
    STA tmpr

    LDX #214*4
    LDY #215*4
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y    
    
    LDX #213*4
    LDY #214*4
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y
    
    LDX #212*4
    LDY #213*4
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y
    
    LDX #211*4
    LDY #212*4
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y
    
    LDX #210*4
    LDY #211*4
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y
    
    LDX #209*4
    LDY #210*4
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y
    
    LDX #208*4
    LDY #209*4
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y

    LDY #208*4
    LDA tmpb
    STA LUT_START,Y
    INY
    LDA tmpg
    STA LUT_START,Y
    INY
    LDA tmpr
    STA LUT_START,Y

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; 216-223 inclusive
    
    LDX #223*4
    LDA LUT_START,X
    STA tmpb
    INX
    LDA LUT_START,X
    STA tmpg
    INX
    LDA LUT_START,X
    STA tmpr

    LDX #222*4
    LDY #223*4
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y    
    
    LDX #221*4
    LDY #222*4
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y
    
    LDX #220*4
    LDY #221*4
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y
    
    LDX #219*4
    LDY #220*4
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y
    
    LDX #218*4
    LDY #219*4
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y
    
    LDX #217*4
    LDY #218*4
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y
    
    LDX #216*4
    LDY #217*4
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y
    INX
    INY
    LDA LUT_START,X
    STA LUT_START,Y

    LDY #216*4
    LDA tmpb
    STA LUT_START,Y
    INY
    LDA tmpg
    STA LUT_START,Y
    INY
    LDA tmpr
    STA LUT_START,Y

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    .as
    .xs
    REP #$20 ; Need to do this
    SEC      ; Go back to emulation mode
    XCE
    
    CLI ; Enable interrupts again
    
UpdateLutDone
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

IRQ_Handler
    PHP
    PHA
    PHX
    PHY
    
    ; Save the I/O page
    LDA MMU_IO_CTRL
    PHA

    ; Switch to I/O page 0
    STZ MMU_IO_CTRL

    ; Check for start-of-frame flag
    LDA #JR0_INT00_SOF
    BIT INT_PENDING_REG0
    BEQ IRQ_Handler_Done
    
    ; Clear the flag for start-of-frame
    STA INT_PENDING_REG0        

    JSR CopyBitmapLutToDevice

IRQ_Handler_Done
    ; Restore the I/O page
    PLA
    STA MMU_IO_CTRL
    
    PLY
    PLX
    PLA
    PLP
    RTI

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Init_IRQHandler
    ; Back up I/O state
    LDA MMU_IO_CTRL
    PHA        

    ; Disable IRQ handling
    SEI

    ; Load our interrupt handler. Should probably back up the old one oh well
    LDA #<IRQ_Handler
    STA $FFFE ; VECTOR_IRQ
    LDA #>IRQ_Handler
    STA $FFFF ; (VECTOR_IRQ)+1

    ; Mask off all but start-of-frame
    LDA #$FF
    STA INT_MASK_REG1
    AND #~(JR0_INT00_SOF)
    STA INT_MASK_REG0

    ; Re-enable interrupt handling    
    CLI
    PLA ; Restore I/O state
    STA MMU_IO_CTRL 
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.include "rsrc/colors.s"
.include "rsrc/textcolors.s"

MAIN
    LDA #MMU_EDIT_EN
    STA MMU_MEM_CTRL
    STZ MMU_IO_CTRL 
    STZ MMU_MEM_CTRL    
    LDA #(Mstr_Ctrl_Text_Mode_En|Mstr_Ctrl_Text_Overlay|Mstr_Ctrl_Graph_Mode_En|Mstr_Ctrl_Bitmap_En)
    STA @w MASTER_CTRL_REG_L 
    LDA #(Mstr_Ctrl_Text_XDouble|Mstr_Ctrl_Text_YDouble)
    STA @w MASTER_CTRL_REG_H

    ; Disable the cursor
    LDA VKY_TXT_CURSOR_CTRL_REG
    AND #$FE
    STA VKY_TXT_CURSOR_CTRL_REG
    
    JSR ClearScreen        
             
    ; Clear to black
    LDA #$00
    STA $D00D ; Background red channel
    LDA #$00
    STA $D00E ; Background green channel
    LDA #$00
    STA $D00F ; Background blue channel
    
    STZ TyVKY_BM1_CTRL_REG ; Make sure bitmap 1 is turned off
    STZ TyVKY_BM2_CTRL_REG ; Make sure bitmap 2 is turned off    
    LDA #$01 
    STA TyVKY_BM0_CTRL_REG ; Make sure bitmap 0 is turned on. Setting no more bits leaves LUT selection to 0
    
    JSR CopyBitmapLutToDevice

    ; Now copy graphics data
    lda #<IMG_START ; Set the low byte of the bitmap’s address
    sta $D101
    lda #>IMG_START ; Set the middle byte of the bitmap’s address
    sta $D102
    lda #`IMG_START ; Set the upper two bits of the address
    and #$03
    sta $D103

    ;;;;;;;;;;;;;;;

    ; Set the line number to 0
    stz line

    ; Calculate the bank number for the bitmap
    lda #(IMG_START >> 13)
    sta bm_bank
bank_loop: 
    stz dst_pointer ; Set the pointer to start of the current bank
    lda #$20
    sta dst_pointer+1
    ; Set the column to 0
    stz column
    stz column+1
    ; Alter the LUT entries for $2000 -> $bfff

    lda #$80 ; Turn on editing of MMU LUT #0, and use #0
    sta MMU_MEM_CTRL
    lda bm_bank
    sta MMU_MEM_BANK_1 ; Set the bank we will map to $2000 - $3fff
    stz MMU_MEM_CTRL ; Turn off editing of MMU LUT #0

    ; Fill the line with the color..
loop2_fillLine
    lda line ; The line number is the color of the line

    sta (dst_pointer)
    inc_column: inc column ; Increment the column number
    bne chk_col
    inc column+1
    chk_col: lda column ; Check to see if we have finished the row
    cmp #<320
    bne inc_point
    lda column+1
    cmp #>320
    bne inc_point

    LDA line ; If so, increment the line number
    inc a
    STA line
    cmp #240 ; If line = 240, we’re done
    beq Done_Init

    stz column ; Set the column to 0
    stz column+1
    inc_point: inc dst_pointer ; Increment pointer
    bne loop2_fillLine ; If < $4000, keep looping
    inc dst_pointer+1
    lda dst_pointer+1
    cmp #$40
    bne loop2_fillLine
    inc bm_bank ; Move to the next bank
    bra bank_loop ; And start filling it

Done_Init

    JSR Init_IRQHandler
    
    LDA #$01
    STA AnimationCounter

Lock
    JSR UpdateLut
    WAI
    WAI
    WAI
    WAI
    WAI
    WAI
    JMP Lock
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CopyBitmapLutToDevice
    ; Switch to page 1 because the lut lives there
    LDA #1
    STA MMU_IO_CTRL

    ; Store a dest pointer in $30-$31
    LDA #<VKY_GR_CLUT_0
    STA dst_pointer
    LDA #>VKY_GR_CLUT_0
    STA dst_pointer+1

    ; Store a source pointer
    LDA #<LUT_START
    STA src_pointer
    LDA #>LUT_START
    STA src_pointer+1

    LDX #$00

LutLoop
    LDY #$0
    
    LDA (src_pointer),Y
    STA (dst_pointer),Y
    INY
    LDA (src_pointer),Y
    STA (dst_pointer),Y
    INY
    LDA (src_pointer),Y
    STA (dst_pointer),Y

    INX
    BEQ LutDone     ; When X overflows, exit

    CLC
    LDA dst_pointer
    ADC #$04
    STA dst_pointer
    LDA dst_pointer+1
    ADC #$00 ; Add carry
    STA dst_pointer+1
    
    CLC
    LDA src_pointer
    ADC #$04
    STA src_pointer
    LDA src_pointer+1
    ADC #$00 ; Add carry
    STA src_pointer+1
    BRA LutLoop
    
LutDone
    ; Go back to I/O page 0
    STZ MMU_IO_CTRL 

    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.endlogical

; Emitted with 
;     D:\repos\fnxapp\BitmapEmbedder\x64\Release\BitmapEmbedder.exe D:\repos\fnxapp\livingworlds\tinyvicky\rsrc\livingworlds.bmp D:\repos\fnxapp\livingworlds\tinyvicky\rsrc\colors.s D:\repos\fnxapp\livingworlds\tinyvicky\rsrc\pixmap.s --halfsize

.if TARGETFMT = "hex"
* = $010000
.endif
.if TARGETFMT = "bin"
* = $010000-$800
.endif
.logical $10000
.include "rsrc/pixmap.s"
.endlogical

; Write the system vectors
.if TARGETFMT = "hex"
* = $00FFF8
.endif
.if TARGETFMT = "bin"
* = $00FFF8-$800
.endif
.logical $FFF8
.byte $00
F256_DUMMYIRQ       ; Abort vector
    RTI

.word F256_DUMMYIRQ ; nmi
.word F256_RESET    ; reset
.word F256_DUMMYIRQ ; irq
.endlogical