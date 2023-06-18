    ; 87-91 inclusive
    LDA >#(LUT_START + (87*4))
    STA src_pointer+1
    LDA <#(LUT_START + (87*4))
    STA src_pointer
    LDA #4; Cycle length
    JSR CycleColors

    ; 98-102 inclusive
    LDA >#(LUT_START + (98*4))
    STA src_pointer+1
    LDA <#(LUT_START + (98*4))
    STA src_pointer
    LDA #4; Cycle length
    JSR CycleColors

    ; 160-164 inclusive
    LDA >#(LUT_START + (160*4))
    STA src_pointer+1
    LDA <#(LUT_START + (160*4))
    STA src_pointer
    LDA #4; Cycle length
    JSR CycleColors

    ; 104-111 inclusive
    LDA >#(LUT_START + (104*4))
    STA src_pointer+1
    LDA <#(LUT_START + (104*4))
    STA src_pointer
    LDA #7; Cycle length
    JSR CycleColors

    ; 92-97 inclusive
    LDA >#(LUT_START + (92*4))
    STA src_pointer+1
    LDA <#(LUT_START + (92*4))
    STA src_pointer
    LDA #5; Cycle length
    JSR CycleColors

    ; 165-169 inclusive
    LDA >#(LUT_START + (165*4))
    STA src_pointer+1
    LDA <#(LUT_START + (165*4))
    STA src_pointer
    LDA #4; Cycle length
    JSR CycleColors

    ; 112-119 inclusive
    LDA >#(LUT_START + (112*4))
    STA src_pointer+1
    LDA <#(LUT_START + (112*4))
    STA src_pointer
    LDA #7; Cycle length
    JSR CycleColors

    ; 120-127 inclusive
    LDA >#(LUT_START + (120*4))
    STA src_pointer+1
    LDA <#(LUT_START + (120*4))
    STA src_pointer
    LDA #7; Cycle length
    JSR CycleColors

    ; 128-135 inclusive
    LDA >#(LUT_START + (128*4))
    STA src_pointer+1
    LDA <#(LUT_START + (128*4))
    STA src_pointer
    LDA #7; Cycle length
    JSR CycleColors

    ; 170-174 inclusive
    LDA >#(LUT_START + (170*4))
    STA src_pointer+1
    LDA <#(LUT_START + (170*4))
    STA src_pointer
    LDA #4; Cycle length
    JSR CycleColors

    ; 176-180 inclusive
    LDA >#(LUT_START + (176*4))
    STA src_pointer+1
    LDA <#(LUT_START + (176*4))
    STA src_pointer
    LDA #4; Cycle length
    JSR CycleColors

    ; 181-185 inclusive
    LDA >#(LUT_START + (181*4))
    STA src_pointer+1
    LDA <#(LUT_START + (181*4))
    STA src_pointer
    LDA #4; Cycle length
    JSR CycleColors

    ; 192-199 inclusive
    LDA >#(LUT_START + (192*4))
    STA src_pointer+1
    LDA <#(LUT_START + (192*4))
    STA src_pointer
    LDA #7; Cycle length
    JSR CycleColors

    ; 200-207 inclusive
    LDA >#(LUT_START + (200*4))
    STA src_pointer+1
    LDA <#(LUT_START + (200*4))
    STA src_pointer
    LDA #7; Cycle length
    JSR CycleColors

    ; 208-215 inclusive
    LDA >#(LUT_START + (208*4))
    STA src_pointer+1
    LDA <#(LUT_START + (208*4))
    STA src_pointer
    LDA #7; Cycle length
    JSR CycleColors

    ; 186-190 inclusive
    LDA >#(LUT_START + (186*4))
    STA src_pointer+1
    LDA <#(LUT_START + (186*4))
    STA src_pointer
    LDA #4; Cycle length
    JSR CycleColors

