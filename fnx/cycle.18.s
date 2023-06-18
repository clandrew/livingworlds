    ; 135-143 inclusive
    LDA >#(LUT_START + (135*4))
    STA src_pointer+1
    LDA <#(LUT_START + (135*4))
    STA src_pointer
    LDA #8; Cycle length
    JSR CycleColors

    ; 127-134 inclusive
    LDA >#(LUT_START + (127*4))
    STA src_pointer+1
    LDA <#(LUT_START + (127*4))
    STA src_pointer
    LDA #7; Cycle length
    JSR CycleColors

    ; 119-126 inclusive
    LDA >#(LUT_START + (119*4))
    STA src_pointer+1
    LDA <#(LUT_START + (119*4))
    STA src_pointer
    LDA #7; Cycle length
    JSR CycleColors

    ; 217-223 inclusive
    LDA >#(LUT_START + (217*4))
    STA src_pointer+1
    LDA <#(LUT_START + (217*4))
    STA src_pointer
    LDA #6; Cycle length
    JSR CycleColors

    ; 210-216 inclusive
    LDA >#(LUT_START + (210*4))
    STA src_pointer+1
    LDA <#(LUT_START + (210*4))
    STA src_pointer
    LDA #6; Cycle length
    JSR CycleColors

    ; 203-209 inclusive
    LDA >#(LUT_START + (203*4))
    STA src_pointer+1
    LDA <#(LUT_START + (203*4))
    STA src_pointer
    LDA #6; Cycle length
    JSR CycleColors

    ; 196-202 inclusive
    LDA >#(LUT_START + (196*4))
    STA src_pointer+1
    LDA <#(LUT_START + (196*4))
    STA src_pointer
    LDA #6; Cycle length
    JSR CycleColors

    ; 189-195 inclusive
    LDA >#(LUT_START + (189*4))
    STA src_pointer+1
    LDA <#(LUT_START + (189*4))
    STA src_pointer
    LDA #6; Cycle length
    JSR CycleColors

    ; 182-188 inclusive
    LDA >#(LUT_START + (182*4))
    STA src_pointer+1
    LDA <#(LUT_START + (182*4))
    STA src_pointer
    LDA #6; Cycle length
    JSR CycleColors

    ; 175-181 inclusive
    LDA >#(LUT_START + (175*4))
    STA src_pointer+1
    LDA <#(LUT_START + (175*4))
    STA src_pointer
    LDA #6; Cycle length
    JSR CycleColors

