.cpu "65816"                        ; Tell 64TASS that we are using a 65816

.include "includes/TinyVicky_Def.asm"
.include "includes/interrupt_def.asm"
.include "includes/f256jr_registers.asm"
.include "includes/f256k_registers.asm"
.include "includes/macros.s"

dst_pointer = $30
src_pointer = $32
right_arrow_cur = $34
right_arrow_next = $35
left_arrow_cur = $36
left_arrow_next = $37
scene_index = $38
fade_index = $39
current_lut_pointer = $3A
lineNumber = $40

; Scene index 0 - 13
; Scene index 1 - 8
; Scene index 2 - 16

; Code
* = $000000 
        .byte 0

; This program uses bank 1 (2000-4000) to be a memory window into image data -
; see "bank_loop" for info on that. Therefore, don't put program code in
; bank 1. And bank 0 (0000-2000) has a bunch of reserved stuff in it. Therefore,
; put the program in bank 2 starting at 4000. Besides bank_loop's partying,
; this program sets its MLUT to point to sequential system memory.
* = $4000
.logical $4000

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

    ; Turn off the border
    STZ VKY_BRDR_CTRL
    
    STZ TyVKY_BM1_CTRL_REG ; Make sure bitmap 1 is turned off
    STZ TyVKY_BM2_CTRL_REG ; Make sure bitmap 2 is turned off    
    LDA #$01 
    STA TyVKY_BM0_CTRL_REG ; Make sure bitmap 0 is turned on. Setting no more bits leaves LUT selection to 0
    
    ; Initialize matrix keyboard
    LDA #$FF
    STA VIA1_DDRA
    LDA #$00
    STA VIA1_DDRB

    STZ VIA1_PRB
    STZ VIA1_PRA
    
    LDA #$7F
    STA VIA0_DDRA
    STA VIA0_PRA
    STZ VIA0_PRB
    
    STZ right_arrow_cur
    STZ right_arrow_next

    STZ fade_index
    STZ scene_index
    JSR InitializeScene
    
    JSR CopyBitmapLutToDevice

    JSR Init_IRQHandler    

Lock
    JSR UpdateLut

    LDA fade_index
    CMP #$00
    BNE Fading

PollKeyboard
    JSR PollLeftArrow
    JSR PollRightArrow
    BRA WaitFor

Fading
    DEC fade_index

WaitFor
    WAI
    WAI
    WAI
    WAI
    WAI
    WAI
    JMP Lock

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PollLeftArrow
    LDA #(1 << 0 ^ $FF)
    STA VIA1_PRA
    LDA VIA1_PRB
    CMP #(1 << 2 ^ $FF)
    BNE LeftArrow_NotPressed

LeftArrow_Pressed
    LDA #$FF
    STA left_arrow_next
    BRA LeftArrow_DonePoll

LeftArrow_NotPressed
    LDA #$00
    STA left_arrow_next

LeftArrow_DonePoll
    LDA left_arrow_next
    CMP #$00
    BNE LeftArrow_DoneAll

    LDA left_arrow_cur
    CMP #$FF
    BNE LeftArrow_DoneAll

    ; Advance to next scene here
    LDA scene_index
    CMP #0 ; limit
    BEQ LeftArrow_Wraparound
    DEC scene_index
    BRA LeftArrow_InitializeScene
LeftArrow_Wraparound
    LDA #(3-1)
    STA scene_index
LeftArrow_InitializeScene
    JSR InitializeScene
    
LeftArrow_DoneAll
    LDA left_arrow_next
    STA left_arrow_cur
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PollRightArrow
    LDA #(1 << 6 ^ $FF)
    STA VIA1_PRA
    LDA VIA0_PRB
    CMP #(1 << 7 ^ $FF)
    BNE RightArrow_NotPressed

RightArrow_Pressed
    LDA #$FF
    STA right_arrow_next
    BRA RightArrow_DonePoll

RightArrow_NotPressed
    LDA #$00
    STA right_arrow_next

RightArrow_DonePoll
    LDA right_arrow_next
    CMP #$00
    BNE RightArrow_DoneAll

    LDA right_arrow_cur
    CMP #$FF
    BNE RightArrow_DoneAll

    ; Advance to next scene here
    LDA scene_index
    CMP #(3-1) ; limit
    BEQ RightArrow_Wraparound
    INC scene_index
    BRA RightArrow_InitializeScene
RightArrow_Wraparound
    STZ scene_index
RightArrow_InitializeScene
    JSR InitializeScene
    
RightArrow_DoneAll
    LDA right_arrow_next
    STA right_arrow_cur

    RTS
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
InitScene0 
    LDA #<LUT_START13
    STA current_lut_pointer
    LDA #>LUT_START13
    STA current_lut_pointer+1
    
    ; Now copy graphics data
    lda #<IMG_START13 ; Set the low byte of the bitmap’s address
    sta TyVKY_BM0_START_ADDY_L
    lda #>IMG_START13 ; Set the middle byte of the bitmap’s address
    sta TyVKY_BM0_START_ADDY_M
    lda #`IMG_START13 ; Set the upper two bits of the address
    and #$03
    sta TyVKY_BM0_START_ADDY_H
    RTS   

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
InitScene1
    LDA #<LUT_START8
    STA current_lut_pointer
    LDA #>LUT_START8
    STA current_lut_pointer+1

    ; Now copy graphics data
    lda #<IMG_START8 ; Set the low byte of the bitmap’s address
    sta TyVKY_BM0_START_ADDY_L
    lda #>IMG_START8 ; Set the middle byte of the bitmap’s address
    sta TyVKY_BM0_START_ADDY_M
    lda #`IMG_START8 ; Set the upper two bits of the address
    and #$03
    sta TyVKY_BM0_START_ADDY_H    
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
InitScene2
    LDA #<LUT_START16
    STA current_lut_pointer
    LDA #>LUT_START16
    STA current_lut_pointer+1

    ; Now copy graphics data
    lda #<IMG_START16 ; Set the low byte of the bitmap’s address
    sta TyVKY_BM0_START_ADDY_L
    lda #>IMG_START16 ; Set the middle byte of the bitmap’s address
    sta TyVKY_BM0_START_ADDY_M
    lda #`IMG_START16 ; Set the upper two bits of the address
    and #$03
    sta TyVKY_BM0_START_ADDY_H    
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

InitializeScene
    LDA #6
    STA fade_index

    LDA scene_index
    CMP #$0
    BEQ LInitScene0
    
    CMP #$1
    BEQ LInitScene1
    
    CMP #$2
    BEQ LInitScene2

    RTS

LInitScene0
    JSR InitScene0
    RTS

LInitScene1
    JSR InitScene1
    RTS

LInitScene2
    JSR InitScene2
    RTS

;;;;;;;;;;;;

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
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Fade
    PHX

    ; Input in A
    ; Output in A
    LDX fade_index
    CPX #0
    BEQ Fade0
    CPX #1
    BEQ Fade1
    CPX #2
    BEQ Fade2
    CPX #3
    BEQ Fade3
    CPX #4
    BEQ Fade4
    CPX #5
    BEQ Fade5

Fade6
    LSR
Fade5
    LSR
Fade4
    LSR
Fade3
    LSR
Fade2
    LSR
Fade1
    LSR
Fade0
    PLX
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CopyBitmapLutToDevice
    ; Called on startup and every frame during VBLANK.

    ; Switch to page 1 because the lut lives there
    LDA #1
    STA MMU_IO_CTRL

    ; Store a dest pointer in $30-$31
    LDA #<VKY_GR_CLUT_0
    STA dst_pointer
    LDA #>VKY_GR_CLUT_0
    STA dst_pointer+1

    ; Store a source pointer
    LDA current_lut_pointer
    STA src_pointer
    LDA current_lut_pointer+1
    STA src_pointer+1

    LDX #$00

LutLoop
    LDY #$0
    
    LDA (src_pointer),Y
    JSR Fade
    STA (dst_pointer),Y
    INY
    LDA (src_pointer),Y
    JSR Fade
    STA (dst_pointer),Y
    INY
    LDA (src_pointer),Y
    JSR Fade
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CycleColors
    ; Precondition: Cycle length in A
    ;               src_pointer initialized to the beginning of changed palette
    STA iter_i

    ASL; Bake y based on length of cycle
    ASL
    DEC A
    DEC A    
    TAY    

    ; Set dst_pointer = src_pointer + 4    
    CLC
    LDA src_pointer
    ADC #$04
    STA dst_pointer
    LDA src_pointer+1
    ADC #$00 ; Add carry
    STA dst_pointer+1

    ; Back up edge of cycle
    PHY
    LDA (dst_pointer),Y
    STA tmpb
    DEY
    LDA (dst_pointer),Y
    STA tmpg
    DEY
    LDA (dst_pointer),Y
    STA tmpr    
    PLY

CycleColors_Loop
    LDA (src_pointer),Y
    STA (dst_pointer),Y
    DEY
    LDA (src_pointer),Y
    STA (dst_pointer),Y
    DEY
    LDA (src_pointer),Y
    STA (dst_pointer),Y
    DEY
    DEY
    DEC iter_i
    BNE CycleColors_Loop

    LDY #2

    ; Complete edge from backup
    LDA tmpb
    STA (src_pointer),Y
    DEY
    LDA tmpg
    STA (src_pointer),Y
    DEY
    LDA tmpr
    STA (src_pointer),Y

    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Cycle13
.include "cycle.13.s"
    RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Cycle8
.include "cycle.8.s"
    RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Cycle16
.include "cycle.16.s"
    RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

UpdateLut
    LDA scene_index
    CMP #0
    BEQ UpdateLutScene0
    CMP #1
    BEQ UpdateLutScene1
    CMP #2
    BEQ UpdateLutScene2
    RTS
   
UpdateLutScene0
    JSR Cycle13
    RTS

UpdateLutScene1
    JSR Cycle8
    RTS

UpdateLutScene2
    JSR Cycle16
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.align 4, $EA 
.include "rsrc/colors.8.s"
.align 4, $EA ; Align, padding with nops
.include "rsrc/colors.13.s"
.align 4, $EA 
.include "rsrc/colors.16.s"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.endlogical

; Emitted with 
;     D:\repos\fnxapp\BitmapEmbedder\x64\Release\BitmapEmbedder.exe D:\repos\fnxapp\livingworlds\tinyvicky\rsrc\livingworlds.bmp D:\repos\fnxapp\livingworlds\tinyvicky\rsrc\colors.s D:\repos\fnxapp\livingworlds\tinyvicky\rsrc\pixmap.s --halfsize

* = $010000
.logical $10000
.include "rsrc/pixmap.8.s"
.include "rsrc/pixmap.13.s"
.include "rsrc/pixmap.16.s"
.endlogical

; Write the system vectors
* = $00FFF8
.logical $FFF8
.byte $00
F256_DUMMYIRQ       ; Abort vector
    RTI

.word F256_DUMMYIRQ ; nmi
.word F256_RESET    ; reset
.word F256_DUMMYIRQ ; irq
.endlogical