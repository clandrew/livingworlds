    ; 104-111 inclusive
    LDA >#(LUT_START17 + (104 * 4))
    STA src_pointer+1
    LDA <#(LUT_START17 + (104*4))
    STA src_pointer
    LDA #7; Cycle length
    JSR CycleColors

    ; 92-97 inclusive
    LDA >#(LUT_START17 + (92 * 4))
    STA src_pointer+1
    LDA <#(LUT_START17 + (92*4))
    STA src_pointer
    LDA #5; Cycle length
    JSR CycleColors

    ; 98-103 inclusive
    LDA >#(LUT_START17 + (98 * 4))
    STA src_pointer+1
    LDA <#(LUT_START17 + (98*4))
    STA src_pointer
    LDA #5; Cycle length
    JSR CycleColors

    ; 112-119 inclusive
    LDA >#(LUT_START17 + (112 * 4))
    STA src_pointer+1
    LDA <#(LUT_START17 + (112*4))
    STA src_pointer
    LDA #7; Cycle length
    JSR CycleColors

    ; 120-127 inclusive
    LDA >#(LUT_START17 + (120 * 4))
    STA src_pointer+1
    LDA <#(LUT_START17 + (120*4))
    STA src_pointer
    LDA #7; Cycle length
    JSR CycleColors

    ; 128-135 inclusive
    LDA >#(LUT_START17 + (128 * 4))
    STA src_pointer+1
    LDA <#(LUT_START17 + (128*4))
    STA src_pointer
    LDA #7; Cycle length
    JSR CycleColors

    ; 136-143 inclusive
    LDA >#(LUT_START17 + (136 * 4))
    STA src_pointer+1
    LDA <#(LUT_START17 + (136*4))
    STA src_pointer
    LDA #7; Cycle length
    JSR CycleColors

    ; 144-151 inclusive
    LDA >#(LUT_START17 + (144 * 4))
    STA src_pointer+1
    LDA <#(LUT_START17 + (144*4))
    STA src_pointer
    LDA #7; Cycle length
    JSR CycleColors

    ; 152-159 inclusive
    LDA >#(LUT_START17 + (152 * 4))
    STA src_pointer+1
    LDA <#(LUT_START17 + (152*4))
    STA src_pointer
    LDA #7; Cycle length
    JSR CycleColors

    ; 192-199 inclusive
    LDA >#(LUT_START17 + (192 * 4))
    STA src_pointer+1
    LDA <#(LUT_START17 + (192*4))
    STA src_pointer
    LDA #7; Cycle length
    JSR CycleColors

    ; 200-207 inclusive
    LDA >#(LUT_START17 + (200 * 4))
    STA src_pointer+1
    LDA <#(LUT_START17 + (200*4))
    STA src_pointer
    LDA #7; Cycle length
    JSR CycleColors

    ; 208-215 inclusive
    LDA >#(LUT_START17 + (208 * 4))
    STA src_pointer+1
    LDA <#(LUT_START17 + (208*4))
    STA src_pointer
    LDA #7; Cycle length
    JSR CycleColors

    ; 216-223 inclusive
    LDA >#(LUT_START17 + (216 * 4))
    STA src_pointer+1
    LDA <#(LUT_START17 + (216*4))
    STA src_pointer
    LDA #7; Cycle length
    JSR CycleColors

