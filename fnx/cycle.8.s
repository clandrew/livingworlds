    ; 202-207 inclusive
    LDA >#(LUT_START + (202*4))
    STA src_pointer+1
    LDA <#(LUT_START + (202*4))
    STA src_pointer
    LDA #5; Cycle length
    JSR CycleColors

    ; 196-201 inclusive
    LDA >#(LUT_START + (196*4))
    STA src_pointer+1
    LDA <#(LUT_START + (196*4))
    STA src_pointer
    LDA #5; Cycle length
    JSR CycleColors

    ; 208-215 inclusive
    LDA >#(LUT_START + (208*4))
    STA src_pointer+1
    LDA <#(LUT_START + (208*4))
    STA src_pointer
    LDA #7; Cycle length
    JSR CycleColors

    ; 216-223 inclusive
    LDA >#(LUT_START + (216*4))
    STA src_pointer+1
    LDA <#(LUT_START + (216*4))
    STA src_pointer
    LDA #7; Cycle length
    JSR CycleColors

