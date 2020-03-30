.text
; CI instructions
ci8 $r0, 0x25
cii $r0, 0x4
cup $r0, 0x99
; Adds
ci8 $r0, 0x25
ci8 $r1, -10
addi $r0, $r1
cii $r0, 0x4
cii $r1, 0x1
addii $r0, $r1
cii $r0, 0x3
cii $r1, 0x8
addii $r0, $r1
cii $r0, 0x1
ci8 $r1, 0x2
addii $r0, $r1
cii $r0, 0x4
cii $r1, 0x1
addpp $r0, $r1
cii $r0, 0x3
cii $r1, 0x8
addpp $r0, $r1
cii $r0, 0x1
ci8 $r1, 0x2
addpp $r0, $r1
ci8 $r0, 0x25
ci8 $r1, -10
addp $r0, $r1

; Multiplies
ci8 $r0, 0x4
ci8 $r1, 0x2
muli $r0, $r1
ci8 $r0, 0x4
mulp $r0, $r1
cii $r0, 0x4
cii $r1, 0x2
mulii $r0, $r1
cii $r0, 0x4
mulpp $r0, $r1

; Shifts
ci8 $r0, 0x4
ci8 $r1, 0x2
shi $r0, $r1
ci8 $r0, 0x8
ci8 $r1, 0xFE
shi $r0, $r1
cii $r0, 0x4
cii $r1, 0x2
shii $r0, $r1
cii $r0, 0x8
cii $r1, 0xFE
shii $r0, $r1

; Negs
ci8 $r0, 2
negi $r0
cii $r0, 2
negii $r0

; Any
ci8 $r0, 1
anyi $r0
ci8 $r0, 0
anyi $r0
cii $r0, 3
anyii $r0
ci8 $r0, 1
anyii $r0 

; Load/Store
ci8 $r1, 0
ld $r0, $r1
ci8 $r1, 1
ld $r0, $r1
ci8 $r1, 2
ld $r0, $r1
ci8 $r1, 0
cii $r0, 0x69
st $r0, $r1
ci8 $r1, 1
st $r0, $r1
ci8 $r2, 2
st $r0, $r1


; Set Less Than
ci8 $r0, 1
ci8 $r1, 2
slti $r0, $r1
ci8 $r0, 2
ci8 $r1, 1
slti $r0, $r1
cii $r0, 1
cii $r1, 1
sltii $r0, $r1
cii $r0, 2
ci8 $r1, 3
sltii $r0, $r1

;And, Xor, Or, Not (Bitwise)
cii $r0, 0x10
not $r0
cii $r0, 0xff
cii $r1, 0x11
and $r0, $r1
cii $r0, 0x11
cii $r0, 0x22
or $r0, $r1
cii $r0, 0xf0
cii $r1, 0xff
xor $r0, $r1

; i2p, ii2pp, p2i, pp2ii, invp, invpp
ci8 $r0, 0x5
i2p $r0
cii $r0, 0x2
ii2pp $r0
cii $r0, 0x8
p2i $r0
cii $r0, 0x2
pp2ii $r0
ci8 $r0, 0x3
invp $r0
ci8 $r0, 0x2
invpp $r0
ci8 $r0, 0x1
invp $r0
invpp $r0
cii $r0, 0x01
invpp $r0

ci8 $r0, 0x1
bz $r0, label
cii $r0, 0xff
bnz $r0, label
cii $r0, 0x11
ci8 $r0, 0x0
ci8 $r0, 0x1
label: 
ci8 $r0, 0x2
ci8 $r0, 0x3
ci8 $r0, 0x0
bz $r0, label2
cii $r0, 0xff
bnz $r0, label2
cii $r0, 0x11
label2:

ci8 $r0, 131
jr $r0

	
.data
.word 0x9999
.word 0x3493
.word 0x0000
.word 0x0001
.word 0x0003
.word 0x0006
