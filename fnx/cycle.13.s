    ; 32-47 inclusive
    LDA >#(LUT_START13 + (32 * 4))
    STA src_pointer+1
    LDA <#(LUT_START13 + (32*4))
    STA src_pointer
    LDA #15; Cycle length
    JSR CycleColors

    ; 48-63 inclusive
    LDA >#(LUT_START13 + (48 * 4))
    STA src_pointer+1
    LDA <#(LUT_START13 + (48*4))
    STA src_pointer
    LDA #15; Cycle length
    JSR CycleColors

    ; 64-79 inclusive
    LDA >#(LUT_START13 + (64 * 4))
    STA src_pointer+1
    LDA <#(LUT_START13 + (64*4))
    STA src_pointer
    LDA #15; Cycle length
    JSR CycleColors

    ; 80-95 inclusive
    LDA >#(LUT_START13 + (80 * 4))
    STA src_pointer+1
    LDA <#(LUT_START13 + (80*4))
    STA src_pointer
    LDA #15; Cycle length
    JSR CycleColors

    ; 96-103 inclusive
    LDA >#(LUT_START13 + (96 * 4))
    STA src_pointer+1
    LDA <#(LUT_START13 + (96*4))
    STA src_pointer
    LDA #7; Cycle length
    JSR CycleColors

    ; 128-143 inclusive
    LDA >#(LUT_START13 + (128 * 4))
    STA src_pointer+1
    LDA <#(LUT_START13 + (128*4))
    STA src_pointer
    LDA #15; Cycle length
    JSR CycleColors

    ; 22-31 inclusive
    LDA >#(LUT_START13 + (22 * 4))
    STA src_pointer+1
    LDA <#(LUT_START13 + (22*4))
    STA src_pointer
    LDA #9; Cycle length
    JSR CycleColors

