/* ANSI concatenation macros.  */
#define CONCAT1(a, b) CONCAT2(a, b)
#define CONCAT2(a, b) a ## b
/* Use the right prefix for global labels.  */
#define SYM(x) CONCAT1 (__USER_LABEL_PREFIX__, x)

;
; stencil_body
;
; implements a 20xN stencil code, using a "stride" of 5 clocks per register access
; does a 5-point "star" using FMADDs to maximise Flop counts.
;
; written by Robert (bob) Edwards <bob@cs.anu.edu.au>, Oct 2013
; Licence: GPL V3
;
; regs:
;  r0 - pointer to data grid
;  r1 - pointer to "inner column boundary"
;  r2 - counter numrows / 2
;  r3 - pointer to co-efficients array, then first co-efficient
;  r4 - r7: other four co-efficients
;  r8 - r12: intermediate results
;  r13 - stack pointer
;  r14 - unused...
;  r15 - r19: intermediate results
;  r20 - r41 - "row 1" grid points
;  r42 - r63 - "row 2" grid points

	.file	"stencil20_5_star.S"
	.section	.text
	.balign	4
	.global	SYM(stencil_20n)
    .set stride, 62

    .macro dogrid0 a0,a1,a2,a3,a4,b0,b1,b2,b3,b4,b5,b6,o0,o1,o2,o3,o4,i0,i1,i2,i3,i4
    fmadd r15,r\a0,r3
	str r8,[r0,#\o0]
    fmadd r16,r\a1,r3
	str r9,[r0,#\o1]
    fmadd r17,r\a2,r3
	str r10,[r0,#\o2]
    fmadd r18,r\a3,r3
	str r11,[r0,#\o3]
    fmadd r19,r\a4,r3
	str r14,[r0,#\o4]
	fmadd r15,r\b0,r4
	fmadd r16,r\b1,r4
	fmadd r17,r\b2,r4
	fmadd r18,r\b3,r4
	fmadd r19,r\b4,r4
	fmadd r15,r\b1,r5
	ldr	r\a0,[r0,#\i0 + stride]
	fmadd r16,r\b2,r5
	ldr	r\a1,[r0,#\i1 + stride]
	fmadd r17,r\b3,r5
	ldr	r\a2,[r0,#\i2 + stride]
	fmadd r18,r\b4,r5
	ldr	r\a3,[r0,#\i3 + stride]
	fmadd r19,r\b5,r5
	ldr	r\a4,[r0,#\i4 + stride]
	fmadd r15,r\b2,r6
    eor r8,r8,r8
	fmadd r16,r\b3,r6
    eor r9,r9,r9
	fmadd r17,r\b4,r6
    eor r10,r10,r10
	fmadd r18,r\b5,r6
    eor r11,r11,r11
	fmadd r19,r\b6,r6
    eor r14,r14,r14
	fmadd r15,r\a0,r7
	fmadd r16,r\a1,r7
	fmadd r17,r\a2,r7
	fmadd r18,r\a3,r7
	fmadd r19,r\a4,r7
    .endm

    .macro dogrid1 a0,a1,a2,a3,a4,b0,b1,b2,b3,b4,b5,b6,o0,o1,o2,o3,o4,i0,i1,i2,i3,i4
    fmadd r8,r\a0,r3
	str r15,[r0,#\o0]
    fmadd r9,r\a1,r3
	str r16,[r0,#\o1]
    fmadd r10,r\a2,r3
	str r17,[r0,#\o2]
    fmadd r11,r\a3,r3
	str r18,[r0,#\o3]
    fmadd r14,r\a4,r3
	str r19,[r0,#\o4]
	fmadd r8,r\b0,r4
	fmadd r9,r\b1,r4
	fmadd r10,r\b2,r4
	fmadd r11,r\b3,r4
	fmadd r14,r\b4,r4
	fmadd r8,r\b1,r5
	ldr	r\a0,[r0,#\i0 + stride]
	fmadd r9,r\b2,r5
	ldr	r\a1,[r0,#\i1 + stride]
	fmadd r10,r\b3,r5
	ldr	r\a2,[r0,#\i2 + stride]
	fmadd r11,r\b4,r5
	ldr	r\a3,[r0,#\i3 + stride]
	fmadd r14,r\b5,r5
	ldr	r\a4,[r0,#\i4 + stride]
	fmadd r8,r\b2,r6
    eor r15,r15,r15
	fmadd r9,r\b3,r6
    eor r16,r16,r16
	fmadd r10,r\b4,r6
    eor r17,r17,r17
	fmadd r11,r\b5,r6
    eor r18,r18,r18
	fmadd r14,r\b6,r6
    eor r19,r19,r19
	fmadd r8,r\a0,r7
	fmadd r9,r\a1,r7
	fmadd r10,r\a2,r7
	fmadd r11,r\a3,r7
	fmadd r14,r\a4,r7
    .endm

SYM(stencil_20n):
; save the 26 registers (13 dual) we are using that need callee saving
	add	sp,sp,#-104
	strd r4,[sp,#0]
	strd r6,[sp,#1]
	strd r8,[sp,#2]
	strd r10,[sp,#3]
	strd r14,[sp,#4]
	strd r28,[sp,#5]
	strd r30,[sp,#6]
	strd r32,[sp,#7]
	strd r34,[sp,#8]
	strd r36,[sp,#9]
	strd r38,[sp,#10]
	strd r40,[sp,#11]
	strd r42,[sp,#12]
; load the co-efficients
    ldr r14,[r3,#5]
    ldr r7,[r3,#4]
    ldr r6,[r3,#3]
    ldr r5,[r3,#2]
    ldr r4,[r3,#1]
    ldr r3,[r3,#0]
    nop
; preload the first two rows
	ldrd r20,[r0,#0]
	ldrd r22,[r0,#1]
	ldrd r24,[r0,#2]
	ldrd r26,[r0,#3]
	ldrd r28,[r0,#4]
	ldrd r30,[r0,#5]
	ldrd r32,[r0,#6]
	ldrd r34,[r0,#7]
	ldrd r36,[r0,#8]
	ldrd r38,[r0,#9]
	ldrd r40,[r0,#10]
; row 2
    add r0,r0,#(stride * 4)
	ldrd r42,[r0,#0]
	ldrd r44,[r0,#1]
	ldrd r46,[r0,#2]
	ldrd r48,[r0,#3]
	ldrd r50,[r0,#4]
	ldrd r52,[r0,#5]
	ldrd r54,[r0,#6]
	ldrd r56,[r0,#7]
	ldrd r58,[r0,#8]
	ldrd r60,[r0,#9]
	ldrd r62,[r0,#10]
    add r1,r1,#(stride * 4)
; clear first 5 results
    eor r15,r15,r15
    eor r16,r16,r16
    eor r17,r17,r17
    eor r18,r18,r18
    eor r19,r19,r19
    .ifdef _righty
    ldr r63,[r1,#0]
    str r43,[r1],#stride
    .else
    ldr r42,[r1,#0]         ; reload "old" left-hand value
    str r62,[r1],#stride    ; save right-hand value to left
    .endif
; do first 5 points, saving junk
    dogrid0 21,22,23,24,25,42,43,44,45,46,47,48, 1, 1, 1, 1, 1, 1, 2, 3, 4, 5
.Lb:
    dogrid1 26,27,28,29,30,47,48,49,50,51,52,53, 1, 2, 3, 4, 5, 6, 7, 8, 9,10 
    .ifdef _righty
    ldr r20,[r0,#0 + stride]
    .else
	ldr	r20,[r1,#0]         ; load in "old" left-hand value
    .endif
    dogrid0 31,32,33,34,35,52,53,54,55,56,57,58, 6, 7, 8, 9,10,11,12,13,14,15
    .ifdef _righty
	ldr	r41,[r1,#0]
    .else
	ldr	r41,[r0,#21 + stride]
    .endif
    dogrid1 36,37,38,39,40,57,58,59,60,61,62,63,11,12,13,14,15,16,17,18,19,20
    .ifdef _righty
    str r21,[r1],#stride
    .else
    str r40,[r1],#stride    ; save right-hand value to left
    .endif
; 2nd row
    dogrid0 43,44,45,46,47,20,21,22,23,24,25,26,16,17,18,19,20,1+stride,2+stride,3+stride,4+stride,5+stride
    add r0,r0,#(stride * 4)
    dogrid1 48,49,50,51,52,25,26,27,28,29,30,31, 1, 2, 3, 4, 5, 6, 7, 8, 9,10
    .ifdef _righty
    ldr r42,[r0,#stride]
    .else
	ldr	r42,[r1,#0]         ; load in "old" left-hand value
    .endif
    dogrid0 53,54,55,56,57,30,31,32,33,34,35,36, 6, 7, 8, 9,10,11,12,13,14,15
    .ifdef _righty
    ldr r63,[r1,#0]
    .else
	ldr	r63,[r0,#21 + stride]
    .endif
    dogrid1 58,59,60,61,62,35,36,37,38,39,40,41,11,12,13,14,15,16,17,18,19,20
    .ifdef _righty
    str r43,[r1],#stride
    .else
    str r62,[r1],#stride    ; save right-hand value to left
    .endif
; 1st row
    dogrid0 21,22,23,24,25,42,43,44,45,46,47,48,16,17,18,19,20,1+stride,2+stride,3+stride,4+stride,5+stride
	add	r0,r0,#(stride * 4)
	sub r2,r2,#1
    nop
	bne .Lb

; restore 26 saved registers
	ldrd r4,[sp,#0]
	ldrd r6,[sp,#1]
	ldrd r8,[sp,#2]
	ldrd r10,[sp,#3]
	ldrd r14,[sp,#4]
	ldrd r28,[sp,#5]
	ldrd r30,[sp,#6]
	ldrd r32,[sp,#7]
	ldrd r34,[sp,#8]
	ldrd r36,[sp,#9]
	ldrd r38,[sp,#10]
	ldrd r40,[sp,#11]
	ldrd r42,[sp,#12]
;    ldr r11,[sp,#7]
	add	sp,sp,#104
	rts
	.size	SYM(stencil_20n), .-SYM(stencil_20n)
	.ident	"Bob the Assembler, v0.1"
    .end

