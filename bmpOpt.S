.intel_syntax noprefix
.global bmp_rld_assembly_opt

.text

// void bmp_rld(const uint8_t *rle_data, size_t len, size_t width, size_t height, uint8_t *img)
// parameters = rdi, rsi , rdx, rcx, r8 
// rdi = rle_data 
// rsi = len 
// rdx = width 
// rcx = height 
// r8 = img 
// al = first byte 
// cl = second byte 
// rbx = line counter
// r12 = line padd
// r11 = width
//r13 = jmp variable

bmp_rld_assembly_opt:
push rbx
push r12
push r13
push r14
xor rbx,rbx
mov r9,0
mov r10,0
mov r11,rdx
xor rcx,rcx
xor rax,rax
pxor xmm1,xmm1

mov r12,4
and rdx,3
sub r12, rdx
and r12,3

main: 
xor r13,r13
xor rax,rax
cmp r9, rsi  
je end 
mov al, [rdi+r9] // first byte 
inc r9
mov cl, [rdi+r9] // second byte 
mov r14, rax
cmp ax, 0
je AbsOrEsc


encoded:
cmp rax,16
jl normalEncode
movq xmm0, rcx
pshufb xmm0,xmm1
encodedLoop:
cmp rax,16
jl normalEncode
movups [r8+r10], xmm0
add r10,16
sub rax,16
jmp encodedLoop
normalEncode:
cmp ax, 0
je endEncoded 
mov [r8+r10], cl 
inc r10
dec ax
jmp encoded
endEncoded:
cmp r13,1
je endLinebreak
cmp r13,2
je end
cmp r13,3
je endDelta
add rbx, r14
inc r9 // rle_data + 2
jmp main 



AbsOrEsc:
cmp cx, 3 
jl escape 
mov al, cl
// absolute mode  
inc r9 // rle_data + 2

absLoop:
cmp cx, 16
jl normalAbsLoop
movups xmm2, [rdi+r9]
movups [r8+r10], xmm2
add r9, 16
add r10,16
sub cx,16
jmp absLoop
normalAbsLoop:
cmp cx, 0
je endAbs
mov dl, [rdi+r9]
mov [r8+r10], dl 
inc r10 // increment img ptr 
dec cx // decrement pixel count 
inc r9 // increment rle_data ptr 
jmp normalAbsLoop
endAbs:
add rbx,rax //addint to lieCounter
test ax,1
jz even
inc r9
even:
jmp main 

escape: 
cmp cx, 1 // end of bitmap 
jne cont
mov rax,r11
sub rax,rbx //pass
xor rcx,rcx
mov r13,2
jmp encoded 

cont:
cmp cx, 2 // delta 
je delta 

// linebreak 
inc r9
mov rax,r11
sub rax,rbx
xor rcx,rcx
mov r13,1
jmp encoded
endLinebreak:
add r10,r12
xor rbx, rbx
jmp main 

delta:
xor rax, rax
mov al, [rdi+r9+1] //right
add rbx,rax
mov cl, [rdi+r9+2]  //up
imul rcx,r11  //up*width
add rax,rcx   //right+up*width
xor rcx,rcx
mov cl, [rdi+r9+2]
imul rcx,r12  //up*linePadd
add rax,rcx //pass
xor rcx,rcx
mov r13,3
jmp encoded
endDelta:
add r9,3
jmp main 


end:
pop r14
pop r13
pop r12
pop rbx
ret