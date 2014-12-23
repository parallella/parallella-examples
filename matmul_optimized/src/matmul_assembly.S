; Per-core Matrix multiplication
; Author: Anish Varghese <anish.varghese@anu.edu.au>, May 2014
; License: GPL v3
; r0: pointer to A;
; r1: pointer to B;
; r2: pointer to C;
; r3: N;
; r11,r12,r14,r15 - 4 points of matrix a
; r7 - value 0
; r13: stack pointer;
; r16 - r23: 8 points of Matrix B
; r32 - r63: intermediate results for Matrix C;

    .file   "matmul_assembly.S"
    .section    .text
    .balign 4
    .global _matmul_assembly
    .set stride, 32 

    .macro doMult areg,index,aprev,inc
    fmadd r32,r\areg,r16
    ldrd r22,[r1,#\index + 3]
    fmadd r33,r\areg,r17
    ldr r\aprev,[r0,#\inc]  
    fmadd r34,r\areg,r18
    fmadd r35,r\areg,r19
    fmadd r36,r\areg,r20
    fmadd r37,r\areg,r21
    ldrd r16,[r1,#\index + 4]
    fmadd r38,r\areg,r22
    ldrd r18,[r1,#\index + 5]
    fmadd r39,r\areg,r23
    ldrd r20,[r1,#\index + 6]
    fmadd r40,r\areg,r16
    ldrd r22,[r1,#\index + 7]
    fmadd r41,r\areg,r17
    fmadd r42,r\areg,r18
    fmadd r43,r\areg,r19
    fmadd r44,r\areg,r20
    fmadd r45,r\areg,r21
    ldrd r16,[r1,#\index + 8]
    fmadd r46,r\areg,r22
    ldrd r18,[r1,#\index + 9]
    fmadd r47,r\areg,r23
    ldrd r20,[r1,#\index + 10]
    fmadd r48,r\areg,r16
    ldrd r22,[r1,#\index + 11]
    fmadd r49,r\areg,r17
    fmadd r50,r\areg,r18
    fmadd r51,r\areg,r19
    fmadd r52,r\areg,r20
    fmadd r53,r\areg,r21
    ldrd r16,[r1,#\index + 12]
    fmadd r54,r\areg,r22
    ldrd r18,[r1,#\index + 13]
    fmadd r55,r\areg,r23
    ldrd r20,[r1,#\index + 14]
    fmadd r56,r\areg,r16
    ldrd r22,[r1,#\index + 15]
    fmadd r57,r\areg,r17
    fmadd r58,r\areg,r18
    fmadd r59,r\areg,r19
    fmadd r60,r\areg,r20
    fmadd r61,r\areg,r21
    ldrd r16,[r1,#\index + 16]
    fmadd r62,r\areg,r22
    ldrd r18,[r1,#\index + 17]
    fmadd r63,r\areg,r23
    ldrd r20,[r1,#\index + 18]
    .endm

    .macro doMultend areg,index,aprev,inc
    fmadd r32,r\areg,r16
    ldrd r22,[r1,#\index + 3]
    fmadd r33,r\areg,r17
    ldr r\aprev,[r0,#\inc]  
    fmadd r34,r\areg,r18
    fmadd r35,r\areg,r19
    fmadd r36,r\areg,r20
    fmadd r37,r\areg,r21
    ldrd r16,[r1,#\index + 4]
    fmadd r38,r\areg,r22
    ldrd r18,[r1,#\index + 5]
    fmadd r39,r\areg,r23
    ldrd r20,[r1,#\index + 6]
    fmadd r40,r\areg,r16
    ldrd r22,[r1,#\index + 7]
    fmadd r41,r\areg,r17
    fmadd r42,r\areg,r18
    fmadd r43,r\areg,r19
    fmadd r44,r\areg,r20
    fmadd r45,r\areg,r21
    ldrd r16,[r1,#\index + 8]
    fmadd r46,r\areg,r22
    ldrd r18,[r1,#\index + 9]
    fmadd r47,r\areg,r23
    ldrd r20,[r1,#\index + 10]
    fmadd r48,r\areg,r16
    ldrd r22,[r1,#\index + 11]
    fmadd r49,r\areg,r17
    fmadd r50,r\areg,r18
    fmadd r51,r\areg,r19
    fmadd r52,r\areg,r20
    fmadd r53,r\areg,r21
    ldrd r16,[r1,#\index + 12]
    fmadd r54,r\areg,r22
    ldrd r18,[r1,#\index + 13]
    fmadd r55,r\areg,r23
    ldrd r20,[r1,#\index + 14]
    fmadd r56,r\areg,r16
    ldrd r22,[r1,#\index + 15]
    fmadd r57,r\areg,r17
    fmadd r58,r\areg,r18
    fmadd r59,r\areg,r19
    fmadd r60,r\areg,r20
    fmadd r61,r\areg,r21
    ;Changes here to point back to first row
    ldrd r16,[r1,#0]
    fmadd r62,r\areg,r22
    ldrd r18,[r1,#1]
    fmadd r63,r\areg,r23
    ldrd r20,[r1,#2]
    .endm

    .macro doMultincr areg,index,aprev,inc
    fmadd r32,r\areg,r16
    ldrd r22,[r1,#\index + 3]
    fmadd r33,r\areg,r17
    ldr r\aprev,[r0,#\inc]  
    fmadd r34,r\areg,r18
    ;Move r0 to point to next row of Matrix A - only change
    add r0,r0,#(stride * 4)
    fmadd r35,r\areg,r19
    fmadd r36,r\areg,r20
    fmadd r37,r\areg,r21
    ldrd r16,[r1,#\index + 4]
    fmadd r38,r\areg,r22
    ldrd r18,[r1,#\index + 5]
    fmadd r39,r\areg,r23
    ldrd r20,[r1,#\index + 6]
    fmadd r40,r\areg,r16
    ldrd r22,[r1,#\index + 7]
    fmadd r41,r\areg,r17
    fmadd r42,r\areg,r18
    fmadd r43,r\areg,r19
    fmadd r44,r\areg,r20
    fmadd r45,r\areg,r21
    ldrd r16,[r1,#\index + 8]
    fmadd r46,r\areg,r22
    ldrd r18,[r1,#\index + 9]
    fmadd r47,r\areg,r23
    ldrd r20,[r1,#\index + 10]
    fmadd r48,r\areg,r16
    ldrd r22,[r1,#\index + 11]
    fmadd r49,r\areg,r17
    fmadd r50,r\areg,r18
    fmadd r51,r\areg,r19
    fmadd r52,r\areg,r20
    fmadd r53,r\areg,r21
    ldrd r16,[r1,#\index + 12]
    fmadd r54,r\areg,r22
    ldrd r18,[r1,#\index + 13]
    fmadd r55,r\areg,r23
    ldrd r20,[r1,#\index + 14]
    fmadd r56,r\areg,r16
    ldrd r22,[r1,#\index + 15]
    fmadd r57,r\areg,r17
    fmadd r58,r\areg,r18
    fmadd r59,r\areg,r19
    fmadd r60,r\areg,r20
    fmadd r61,r\areg,r21
    ldrd r16,[r1,#\index + 16]
    fmadd r62,r\areg,r22
    ldrd r18,[r1,#\index + 17]
    fmadd r63,r\areg,r23
    ldrd r20,[r1,#\index + 18]
    .endm


_matmul_assembly:
; save the 26 registers (13 dual) we are using that need callee saving
    add sp,sp,#-120
    strd r0,[sp,#0]
    strd r2,[sp,#1]
    strd r4,[sp,#2]
    strd r6,[sp,#3]
    strd r8,[sp,#4]
    strd r10,[sp,#5]
    strd r14,[sp,#6]
    strd r28,[sp,#7]
    strd r30,[sp,#8]
    strd r32,[sp,#9]
    strd r34,[sp,#10]
    strd r36,[sp,#11]
    strd r38,[sp,#12]
    strd r40,[sp,#13]
    strd r42,[sp,#14]

    ;preload the first row and first row of A and B
    ;Matrix A
    ldr r11,[r0,#0]
    ldr r12,[r0,#1]
    ldr r14,[r0,#2]
    ;ldr r15,[r0,#3]

    nop
    nop
    ;mov r7,#0

    ;Matrix B
    ldrd r16,[r1,#0]
    ldrd r18,[r1,#1]
    ldrd r20,[r1,#2]
    ;ldrd r22,[r1,#3]
    ;ldrd r24,[r1,#4]
    ;ldrd r26,[r1,#5]
    ;ldrd r28,[r1,#6]
    ;ldrd r30,[r1,#7]
    ;ldrd r32,[r1,#8]
    ;ldrd r34,[r1,#9]
    ;ldrd r36,[r1,#10]
    ;ldrd r38,[r1,#11]

    ;Matrix C - Reading first row of Intermediate result Matrix C 
    ldrd r32,[r2,#0]
    ldrd r34,[r2,#1]
    ldrd r36,[r2,#2]
    ldrd r38,[r2,#3]
    ldrd r40,[r2,#4]
    ldrd r42,[r2,#5]
    ldrd r44,[r2,#6]
    ldrd r46,[r2,#7]
    ldrd r48,[r2,#8]
    ldrd r50,[r2,#9]
    ldrd r52,[r2,#10]
    ldrd r54,[r2,#11]
    ldrd r56,[r2,#12]
    ldrd r58,[r2,#13]
    ldrd r60,[r2,#14]
    ldrd r62,[r2,#15]

    ;Matrix C - Setting values of intermediate C to 0 
    ;Commented to accomodate multicore version
    ;mov r32,#0
    ;mov r33,#0
    ;mov r34,#0
    ;mov r35,#0
    ;mov r36,#0
    ;mov r37,#0
    ;mov r38,#0
    ;mov r39,#0
    ;mov r40,#0
    ;mov r41,#0
    ;mov r42,#0
    ;mov r43,#0
    ;mov r44,#0
    ;mov r45,#0
    ;mov r46,#0
    ;mov r47,#0
    ;mov r48,#0
    ;mov r49,#0
    ;mov r50,#0
    ;mov r51,#0
    ;mov r52,#0
    ;mov r53,#0
    ;mov r54,#0
    ;mov r55,#0
    ;mov r56,#0
    ;mov r57,#0
    ;mov r58,#0
    ;mov r59,#0
    ;mov r60,#0
    ;mov r61,#0
    ;mov r62,#0
    ;mov r63,#0

.Lb:
    ;Start accumulating
    ;Move r0 to point to next row of Matrix A
    ;add r0,r0,#stride
    ;ldr r15,[r0,#3]
    doMult 11,0,15,3
    ;Start loading next row of Matrix A into r11,r12... for the next iteration
    ;ldr r11,[r0,#4]  
    doMult 12,1 * stride/2,11,4
    ;ldr r12,[r0,#5]  
    doMult 14,2 * stride/2,12,5
    ;ldr r14,[r0,#6]
    doMult 15,3 * stride/2,14,6
    ;ldr r15,[r0,#7]
    doMult 11,4 * stride/2,15,7
    ;ldr r11,[r0,#8]
    doMult 12,5 * stride/2,11,8
    ;ldr r12,[r0,#9]
    doMult 14,6 * stride/2,12,9
    ;ldr r14,[r0,#10]
    doMult 15,7 * stride/2,14,10
    ;ldr r15,[r0,#11]
    doMult 11,8 * stride/2,15,11
    ;ldr r11,[r0,#12]
    doMult 12,9 * stride/2,11,12
    ;ldr r12,[r0,#13]
    doMult 14,10 * stride/2,12,13
    ;ldr r14,[r0,#14]
    doMult 15,11 * stride/2,14,14
    ;ldr r15,[r0,#15]
    doMult 11,12 * stride/2,15,15
    ;ldr r11,[r0,#16]
    doMult 12,13 * stride/2,11,16
    ;ldr r12,[r0,#17]
    doMult 14,14 * stride/2,12,17
    ;ldr r14,[r0,#18]
    doMult 15,15 * stride/2,14,18
    ;ldr r15,[r0,#19]
    doMult 11,16 * stride/2,15,19
    ;ldr r11,[r0,#20]
    doMult 12,17 * stride/2,11,20
    ;ldr r12,[r0,#21]
    doMult 14,18 * stride/2,12,21
    ;ldr r14,[r0,#22]
    doMult 15,19 * stride/2,14,22
    ;ldr r15,[r0,#23]
    doMult 11,20 * stride/2,15,23
    ;ldr r11,[r0,#24]
    doMult 12,21 * stride/2,11,24
    ;ldr r12,[r0,#25]
    doMult 14,22 * stride/2,12,25
    ;ldr r14,[r0,#26]
    doMult 15,23 * stride/2,14,26
    ;ldr r15,[r0,#27]
    doMult 11,24 * stride/2,15,27
    ;ldr r11,[r0,#28]
    doMult 12,25 * stride/2,11,28
    ;ldr r12,[r0,#29]
    doMult 14,26 * stride/2,12,29
    ;ldr r14,[r0,#30]
    doMult 15,27 * stride/2,14,30
    ;ldr r15,[r0,#31]
 ;Move r0 to point to next row of Matrix A
    ;add r0,r0,#(stride * 4)
    doMultincr 11,28 * stride/2,15,31
    ;ldr r11,[r0,#0]
    doMult 12,29 * stride/2,11,0
    ;ldr r12,[r0,#1]
    doMult 14,30 * stride/2,12,1
    ;ldr r14,[r0,#2]
    doMultend 15,31 * stride/2,14,2
    ;ldr r15,[r0,#3]

    ;Start writing out results into C and read next row of intermediate result C 
    strd r32,[r2,#0]
    ldrd r32,[r2,#16 + 0]
    ;fmul r32,r7,r7
    strd r34,[r2,#1]
    ldrd r34,[r2,#16 + 1]
    ;fmul r33,r7,r7
    strd r36,[r2,#2]
    ldrd r36,[r2,#16 + 2]
    ;fmul r34,r7,r7
    strd r38,[r2,#3]
    ldrd r38,[r2,#16 + 3]
    ;fmul r35,r7,r7
    strd r40,[r2,#4]
    ldrd r40,[r2,#16 + 4]
    ;fmul r36,r7,r7
    strd r42,[r2,#5]
    ldrd r42,[r2,#16 + 5]
    ;fmul r37,r7,r7
    strd r44,[r2,#6]
    ldrd r44,[r2,#16 + 6]
    ;fmul r38,r7,r7
    strd r46,[r2,#7]
    ldrd r46,[r2,#16 + 7]
    ;fmul r39,r7,r7
    strd r48,[r2,#8]
    ldrd r48,[r2,#16 + 8]
    ;fmul r40,r7,r7
    strd r50,[r2,#9]
    ldrd r50,[r2,#16 + 9]
    ;fmul r41,r7,r7
    strd r52,[r2,#10]
    ldrd r52,[r2,#16 + 10]
    ;fmul r42,r7,r7
    strd r54,[r2,#11]
    ldrd r54,[r2,#16 + 11]
    ;fmul r43,r7,r7
    strd r56,[r2,#12]
    ldrd r56,[r2,#16 + 12]
    ;fmul r44,r7,r7
    strd r58,[r2,#13]
    ldrd r58,[r2,#16 + 13]
    ;fmul r45,r7,r7
    strd r60,[r2,#14]
    ldrd r60,[r2,#16 + 14]
    ;fmul r46,r7,r7
    strd r62,[r2,#15]
    ldrd r62,[r2,#16 + 15]
    ;fmul r47,r7,r7
    ;Point to next row of Matrix C
    add r2,r2,#(stride * 4)
    ;fmul r48,r7,r7
    ;fmul r49,r7,r7
    ;fmul r50,r7,r7
    ;fmul r51,r7,r7
    ;fmul r52,r7,r7
    ;fmul r53,r7,r7
    ;fmul r54,r7,r7
    ;fmul r55,r7,r7
    ;fmul r56,r7,r7
    ;fmul r57,r7,r7
    ;fmul r58,r7,r7
    ;fmul r59,r7,r7
    ;fmul r60,r7,r7
    ;fmul r61,r7,r7
    ;fmul r62,r7,r7
    ;fmul r63,r7,r7


    ;Now loop back
    sub r3,r3,#1
    nop
    bne .Lb
     
; restore 26 saved registers
    ldrd r0,[sp,#0]
    ldrd r2,[sp,#1]
    ldrd r4,[sp,#2]
    ldrd r6,[sp,#3]
    ldrd r8,[sp,#4]
    ldrd r10,[sp,#5]
    ldrd r14,[sp,#6]
    ldrd r28,[sp,#7]
    ldrd r30,[sp,#8]
    ldrd r32,[sp,#9]
    ldrd r34,[sp,#10]
    ldrd r36,[sp,#11]
    ldrd r38,[sp,#12]
    ldrd r40,[sp,#13]
    ldrd r42,[sp,#14]
    add sp,sp,#120
    rts
    .size   _matmul_assembly, .-_matmul_assembly
    .ident  "Anish V, v0.1"
    .end

