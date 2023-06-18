    ; 171-176 inclusive
    LDA >#(LUT_START3 + (171 * 4))
    STA src_pointer+1
    LDA <#(LUT_START3 + (171*4))
    STA src_pointer
    LDA #5; Cycle length
    JSR CycleColors

    ; 163-170 inclusive
    LDA >#(LUT_START3 + (163 * 4))
    STA src_pointer+1
    LDA <#(LUT_START3 + (163*4))
    STA src_pointer
    LDA #7; Cycle length
    JSR CycleColors

    ; 155-162 inclusive
    LDA >#(LUT_START3 + (155 * 4))
    STA src_pointer+1
    LDA <#(LUT_START3 + (155*4))
    STA src_pointer
    LDA #7; Cycle length
    JSR CycleColors

    ; 146-153 inclusive
    LDA >#(LUT_START3 + (146 * 4))
    STA src_pointer+1
    LDA <#(LUT_START3 + (146*4))
    STA src_pointer
    LDA #7; Cycle length
    JSR CycleColors

    ; 137-144 inclusive
    LDA >#(LUT_START3 + (137 * 4))
    STA src_pointer+1
    LDA <#(LUT_START3 + (137*4))
    STA src_pointer
    LDA #7; Cycle length
    JSR CycleColors

    ; 128-135 inclusive
    LDA >#(LUT_START3 + (128 * 4))
    STA src_pointer+1
    LDA <#(LUT_START3 + (128*4))
    STA src_pointer
    LDA #7; Cycle length
    JSR CycleColors

    ; 113-117 inclusive
    LDA >#(LUT_START3 + (113 * 4))
    STA src_pointer+1
    LDA <#(LUT_START3 + (113*4))
    STA src_pointer
    LDA #4; Cycle length
    JSR CycleColors

    ; 103-110 inclusive
    LDA >#(LUT_START3 + (103 * 4))
    STA src_pointer+1
    LDA <#(LUT_START3 + (103*4))
    STA src_pointer
    LDA #7; Cycle length
    JSR CycleColors

    ; 95-102 inclusive
    LDA >#(LUT_START3 + (95 * 4))
    STA src_pointer+1
    LDA <#(LUT_START3 + (95*4))
    STA src_pointer
    LDA #7; Cycle length
    JSR CycleColors

    ; 87-94 inclusive
    LDA >#(LUT_START3 + (87 * 4))
    STA src_pointer+1
    LDA <#(LUT_START3 + (87*4))
    STA src_pointer
    LDA #7; Cycle length
    JSR CycleColors

    ; 73-80 inclusive
    LDA >#(LUT_START3 + (73 * 4))
    STA src_pointer+1
    LDA <#(LUT_START3 + (73*4))
    STA src_pointer
    LDA #7; Cycle length
    JSR CycleColors

    ; 56-63 inclusive
    LDA >#(LUT_START3 + (56 * 4))
    STA src_pointer+1
    LDA <#(LUT_START3 + (56*4))
    STA src_pointer
    LDA #7; Cycle length
    JSR CycleColors

    ; 48-55 inclusive
    LDA >#(LUT_START3 + (48 * 4))
    STA src_pointer+1
    LDA <#(LUT_START3 + (48*4))
    STA src_pointer
    LDA #7; Cycle length
    JSR CycleColors

    ; 32-47 inclusive
    LDA >#(LUT_START3 + (32 * 4))
    STA src_pointer+1
    LDA <#(LUT_START3 + (32*4))
    STA src_pointer
    LDA #15; Cycle length
    JSR CycleColors

    ; 16-31 inclusive
    LDA >#(LUT_START3 + (16 * 4))
    STA src_pointer+1
    LDA <#(LUT_START3 + (16*4))
    STA src_pointer
    LDA #15; Cycle length
    JSR CycleColors

