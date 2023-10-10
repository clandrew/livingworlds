.cpu "65816"                        ; Tell 64TASS that we are using a 65816

.include "includes/TinyVicky_Def.asm"
.include "includes/interrupt_def.asm"
.include "includes/f256jr_registers.asm"
.include "includes/f256k_registers.asm"
.include "includes/macros.s"
.include "includes/api.asm"

dst_pointer = $30
src_pointer = $32
right_arrow_cur = $34
right_arrow_next = $35
left_arrow_cur = $36
left_arrow_next = $37
scene_index = $38
fade_in_index = $39
current_lut_pointer = $3A
fade_out_index = $3C
next_scene_index = $3D
fade_key = $3E
animation_index = $3F

; Scene index 0 - 13
; Scene index 1 - 8
; Scene index 2 - 16
; Scene index 3 - 17
; Scene index 4 - 18

; Code  
.if TARGETFMT = "bin" || TARGETFMT = "hex"
* = $000000 
        .byte 0

* = $4000
.endif

.if TARGETFMT = "pgz"
; Main segment metadata
* =  0

                ; Place the one-byte PGZ signature before the code section
                .text "Z"           
                .long MAIN_SEGMENT_START               
                
                ; Three-byte segment size. Make sure the size DOESN'T include this metadata.
                .long MAIN_SEGMENT_END - MAIN_SEGMENT_START 

                ; Note that when your executable is loaded, *only* the data segment after the metadata is loaded into memory. 
                ; The 'Z' signature above, and the metadata isn't loaded into memory.
.endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.logical $4000
MAIN_SEGMENT_START

tmpr .byte ?            ; A backed-up-and-restored color
tmpg .byte ?            
tmpb .byte ?
iter_i .byte ?          ; Couple counters
iter_j .byte ?
event       .dstruct    kernel.event.event_t
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

F256_RESET
ENTRYPOINT
    
.if TARGETFMT = "bin" || TARGETFMT = "hex"
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

.endif
    STZ MMU_IO_CTRL
    
.if TARGETFMT = "bin" || TARGETFMT = "hex"
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
.endif

    JMP MAIN

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MAIN

.if TARGETFMT = "bin" || TARGETFMT = "hex"
    LDA #MMU_EDIT_EN
    STA MMU_MEM_CTRL
    STZ MMU_IO_CTRL 
    STZ MMU_MEM_CTRL    
.endif

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

    STZ fade_in_index
    STZ fade_out_index
    STZ fade_key
    STZ scene_index
    STZ animation_index
    JSR InitializeScene
    
    JSR CopyBitmapLutToDevice
    
.if TARGETFMT = "bin" || TARGETFMT = "hex"
    JSR Init_IRQHandler     
.endif

    ; Schedule the first frame event.
    lda     #kernel.args.timer.FRAMES | kernel.args.timer.QUERY
    sta     kernel.args.timer.units
    jsr     kernel.Clock.SetTimer
    sta     animation_index
    jsr     timer_schedule

Lock

.if TARGETFMT = "bin" || TARGETFMT = "hex"

    ; SOF handler will update animation_index behind the scenes.
    LDA animation_index
    BNE Lock

    ; Unblocked. Reset for next frame
    LDA #$5
    STA animation_index
.endif

.if TARGETFMT = "pgz"
    ; Request a frame notification from kernel
    lda #kernel.args.timer.FRAMES   ; Choose frames, not seconds
    sta kernel.args.timer.units

    lda animation_index ; Specify dest frame index
    sta kernel.args.timer.absolute

    LDA #$01 ; Number to use as an event handle
    STA kernel.args.timer.cookie

    jsr kernel.Clock.SetTimer

    LDA #<event
    STA kernel.args.events.dest+0
    LDA #>event
    STA kernel.args.events.dest+1

WaitForKernelEvent
    inc     $c001
    bit     kernel.args.events.pending
    JSR kernel.NextEvent
    BCC DoneWaitForKernelEvent
    JSR kernel.Yield
    BRA WaitForKernelEvent
DoneWaitForKernelEvent

    INC animation_index
    
.endif

    ; Update fade
    LDA fade_in_index
    CMP #$00
    BNE ApplyFadeIn
    
    LDA fade_out_index
    CMP #$00
    BNE ApplyFadeOut

    ; No fade
    JSR UpdateLut
    JSR CopyBitmapLutToDevice   
    BRA PollKeyboard

ApplyFadeIn
    DEC fade_in_index
    DEC fade_key 
    JSR CopyBitmapLutToDevice
    BRA Lock

ApplyFadeOut
    INC fade_out_index
    INC fade_key
    JSR CopyBitmapLutToDevice   
    LDA fade_key
    CMP #7
    BNE WaitFor
    ; Advance to the next scene
    STZ fade_out_index
    LDA next_scene_index
    STA scene_index
    JSR InitializeScene
    JSR CopyBitmapLutToDevice
    BRA Lock

PollKeyboard
    JSR PollLeftArrow
    JSR PollRightArrow
    BRA WaitFor

WaitFor

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
    STA next_scene_index
    CMP #0 ; limit
    BEQ LeftArrow_Wraparound
    DEC next_scene_index
    BRA LeftArrow_InitializeScene
LeftArrow_Wraparound
    LDA #(5-1)
    STA next_scene_index
LeftArrow_InitializeScene
    LDA #1
    STA fade_out_index
    STA fade_key
    
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
    STA next_scene_index
    CMP #(5-1) ; limit
    BEQ RightArrow_Wraparound
    INC next_scene_index
    BRA RightArrow_InitializeScene
RightArrow_Wraparound
    STZ next_scene_index
RightArrow_InitializeScene
    LDA #1
    STA fade_out_index
    STA fade_key
    
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
    lda #`IMG_START13
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
    lda #`IMG_START8 
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
    lda #`IMG_START16
    sta TyVKY_BM0_START_ADDY_H    
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
InitScene3
    LDA #<LUT_START17
    STA current_lut_pointer
    LDA #>LUT_START17
    STA current_lut_pointer+1

    ; Now copy graphics data
    lda #<IMG_START17 ; Set the low byte of the bitmap’s address
    sta TyVKY_BM0_START_ADDY_L
    lda #>IMG_START17 ; Set the middle byte of the bitmap’s address
    sta TyVKY_BM0_START_ADDY_M
    lda #`IMG_START17
    sta TyVKY_BM0_START_ADDY_H    
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
InitScene4
    LDA #<LUT_START18
    STA current_lut_pointer
    LDA #>LUT_START18
    STA current_lut_pointer+1

    ; Now copy graphics data
    lda #<IMG_START18 ; Set the low byte of the bitmap’s address
    sta TyVKY_BM0_START_ADDY_L
    lda #>IMG_START18 ; Set the middle byte of the bitmap’s address
    sta TyVKY_BM0_START_ADDY_M
    lda #`IMG_START18
    sta TyVKY_BM0_START_ADDY_H    
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

InitializeScene
    LDA #6
    STA fade_in_index
    STA fade_key
    
    LDA scene_index
    CMP #$0
    BEQ LInitScene0
    
    CMP #$1
    BEQ LInitScene1
    
    CMP #$2
    BEQ LInitScene2
    
    CMP #$3
    BEQ LInitScene3
    
    CMP #$4
    BEQ LInitScene4

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

LInitScene3
    JSR InitScene3
    RTS

LInitScene4
    JSR InitScene4
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

    ; Advance frame
    LDA animation_index
    BEQ IRQ_Handler_Done
    DEC A
    STA animation_index

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

;Init_KernelTimer

    ;RTS

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
    LDX fade_key
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
    LDA fade_key
    BEQ LutLoopTestNoFade

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

LutLoopTestNoFade
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
    BRA LutLoopTestNoFade
    
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
Cycle17
.include "cycle.17.s"
    RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Cycle18
.include "cycle.18.s"
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
    CMP #3
    BEQ UpdateLutScene3
    CMP #4
    BEQ UpdateLutScene4
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

UpdateLutScene3
    JSR Cycle17
    RTS

UpdateLutScene4
    JSR Cycle18
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.align 4, $EA 
.include "rsrc/colors.8.s"
.align 4, $EA ; Align, padding with nops
.include "rsrc/colors.13.s"
.align 4, $EA 
.include "rsrc/colors.16.s"
.align 4, $EA 
.include "rsrc/colors.17.s"
.align 4, $EA 
.include "rsrc/colors.18.s"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MAIN_SEGMENT_END
.endlogical

.if TARGETFMT = "pgz"
; Data segment metadata
                .long DATA_SEGMENT_START
                .long DATA_SEGMENT_END-DATA_SEGMENT_START
.endif

; Emitted with 
;     D:\repos\fnxapp \BitmapEmbedder\x64\Release\BitmapEmbedder.exe D:\repos\fnxapp\livingworlds\tinyvicky\rsrc\livingworlds.bmp D:\repos\fnxapp\livingworlds\tinyvicky\rsrc\colors.s D:\repos\fnxapp\livingworlds\tinyvicky\rsrc\pixmap.s --halfsize

.if TARGETFMT = "bin" || TARGETFMT = "hex"
* = $010000
.endif
.logical $10000
DATA_SEGMENT_START
.include "rsrc/pixmap.8.s"
.include "rsrc/pixmap.13.s"
.include "rsrc/pixmap.16.s"
.include "rsrc/pixmap.17.s"
.include "rsrc/pixmap.18.s"
DATA_SEGMENT_END
.endlogical

.if TARGETFMT = "bin" || TARGETFMT = "hex"
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
.endif

.if TARGETFMT = "pgz"
; Entrypoint segment metadata
                .long ENTRYPOINT
                .long 0       ; Dummy value to indicate this segment is for declaring the entrypoint.
.endif