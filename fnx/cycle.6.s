    ; 218-223 inclusive
    LDA >#(LUT_START6 + (218 * 4))
    STA src_pointer+1
    LDA <#(LUT_START6 + (218*4))
    STA src_pointer
    LDA #5; Cycle length
    JSR CycleColors

    ; 212-217 inclusive
    LDA >#(LUT_START6 + (212 * 4))
    STA src_pointer+1
    LDA <#(LUT_START6 + (212*4))
    STA src_pointer
    LDA #5; Cycle length
    JSR CycleColors

    ; 206-211 inclusive
    LDA >#(LUT_START6 + (206 * 4))
    STA src_pointer+1
    LDA <#(LUT_START6 + (206*4))
    STA src_pointer
    LDA #5; Cycle length
    JSR CycleColors

    ; 200-205 inclusive
    LDA >#(LUT_START6 + (200 * 4))
    STA src_pointer+1
    LDA <#(LUT_START6 + (200*4))
    STA src_pointer
    LDA #5; Cycle length
    JSR CycleColors

    ; 192-199 inclusive
    LDA >#(LUT_START6 + (192 * 4))
    STA src_pointer+1
    LDA <#(LUT_START6 + (192*4))
    STA src_pointer
    LDA #7; Cycle length
    JSR CycleColors

    ; 152-159 inclusive
    LDA >#(LUT_START6 + (152 * 4))
    STA src_pointer+1
    LDA <#(LUT_START6 + (152*4))
    STA src_pointer
    LDA #7; Cycle length
    JSR CycleColors

    ; 146-151 inclusive
    LDA >#(LUT_START6 + (146 * 4))
    STA src_pointer+1
    LDA <#(LUT_START6 + (146*4))
    STA src_pointer
    LDA #5; Cycle length
    JSR CycleColors

    ; 141-145 inclusive
    LDA >#(LUT_START6 + (141 * 4))
    STA src_pointer+1
    LDA <#(LUT_START6 + (141*4))
    STA src_pointer
    LDA #4; Cycle length
    JSR CycleColors

    ; 135-140 inclusive
    LDA >#(LUT_START6 + (135 * 4))
    STA src_pointer+1
    LDA <#(LUT_START6 + (135*4))
    STA src_pointer
    LDA #5; Cycle length
    JSR CycleColors

    ; 129-134 inclusive
    LDA >#(LUT_START6 + (129 * 4))
    STA src_pointer+1
    LDA <#(LUT_START6 + (129*4))
    STA src_pointer
    LDA #5; Cycle length
    JSR CycleColors

    ; 123-128 inclusive
    LDA >#(LUT_START6 + (123 * 4))
    STA src_pointer+1
    LDA <#(LUT_START6 + (123*4))
    STA src_pointer
    LDA #5; Cycle length
    JSR CycleColors

    ; 119-122 inclusive
    LDA >#(LUT_START6 + (119 * 4))
    STA src_pointer+1
    LDA <#(LUT_START6 + (119*4))
    STA src_pointer
    LDA #3; Cycle length
    JSR CycleColors

    ; 113-118 inclusive
    LDA >#(LUT_START6 + (113 * 4))
    STA src_pointer+1
    LDA <#(LUT_START6 + (113*4))
    STA src_pointer
    LDA #5; Cycle length
    JSR CycleColors

