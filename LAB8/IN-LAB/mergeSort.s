# Eza Rasheed
# er6qt
# 03-26-19
# mergeSort.s

; University of Virginia
; CS 2150 In-Lab 8
; Spring 2018
; mergeSort.s	

	global mergeSort
	global merge

	section .text


; Parameter 1 is a pointer to the int array 
; Parameter 2 is the left index in the array 
; Parameter 3 is the right index in the array
; Return type is void 

;TA HELP
mergeSort:
	; Implement mergeSort here
	cmp rsi, rdx	; compare start(rsi) with end(rdx)
	jge done		; if start >= end, done
	push rdi
	push rsi		; push to store start
	push rdx		; push to store end
	add rdx, rsi	; add start + end and store in rdx
	;push r10
    shr rdx, 1      ; mid = start + end / 2
	push rdx        ; push to store mid in param 3
	;mov r10, rdx   ; move start + end into r10
	;shr r10, 1		; mid = start + end / 2
    ;push r10		; store mid
    ;mov rdx, r10   ; mov mid into 3rd param
	call mergeSort	; merge 1st part mergeSort(A, start, mid)
	;pop r10
	pop rsi         ; pop off value into 2nd param
	pop rdx         ; pop off value in 3rd param
	inc rsi         ; add 1 to mid (mid + 1) in param 2
	push rdx        ; push to store end
	call mergeSort  ; merge 2nd part mergeSort(A, mid+1, end)
	pop rdx         ; end(rdx) goes back to original
	pop rsi         ; start(rsi) goes back to original
	push r11        ; push to store temp for end
	push rcx        ; push to store end
	mov r11, rdx    ; move end into temp param r11
	mov rcx, r11    ; move end into parameter 4(rcx)
	add rdx, rsi 
	shr rdx, 1      ; get mid
	call merge      ; merge(A, start, mid, end)
	pop rcx
	pop r11
	pop rdi
done:
	ret

; Parameter 1 is a pointer to the int array 
; Parameter 2 is the left index in the array
; Parameter 3 is the middle index in the array 
; Parameter 4 is the right index in the array
; Return type is void 
merge:
	; Save callee-save registers
	; Store local variables 
	push rbx			; int i
	push r12			; int j
	push r13			; int k
	push r14			; int n1
	push r15			; int n2
	
	mov r14, rdx			; n1 = mid - left + 1
	sub r14, rsi
	inc r14

	mov r15, rcx			; n2 = right - mid 
	sub r15, rdx

	lea r11, [r14+r15]		; r11 = rsp offset = 4(n1 + n2)
	lea r11, [4*r11]		
	sub rsp, r11			; allocate space for temp arrays

	mov rbx, 0			; i = 0
	mov r12, 0			; j = 0
	
; Copy elements of arr[] into L[]	
copyLloop:
	cmp rbx, r14			; is i >= n1?
	jge copyRloop
					; L[i] = arr[left + i]
	lea r10, [rsi+rbx]		
	mov r10d, DWORD [rdi+4*r10]	; r10 = arr[left + i]
	mov DWORD [rsp+4*rbx], r10d	; L[i] = r10
	inc rbx				; i++
	jmp copyLloop

; Copy elements of arr[] into R[]
copyRloop:
	cmp r12, r15			; is j >= n2?
	jge endcopyR
 					; R[j] = arr[mid + 1 + j]
	lea r10, [rdx+r12+1]	
	mov r10d, DWORD [rdi+4*r10]	; r10 = arr[mid + 1 + j]
	lea rax, [r12+r14]		
	mov DWORD [rsp+4*rax], r10d	; R[j] = r10
	inc r12				; j++
	jmp copyRloop

endcopyR:	
	mov rbx, 0			; i = 0
	mov r12, 0			; j = 0
	mov r13, rsi			; k = left

; Merge L[] and R[] into arr[]
mergeLoop:
	cmp rbx, r14			; is i >= n1 or j >= n2?
	jge loopL
	cmp r12, r15
	jge loopL
	lea r10, [r12+r14]
	mov r10d, DWORD [rsp+4*r10] 	; r10d = R[j]
	cmp DWORD [rsp+4*rbx], r10d	; is L[i] <= R[j]?
	jle if
	mov DWORD [rdi+4*r13], r10d	; arr[k] = R[j]
	inc r12				; j++
	jmp endif 
if:
	mov r10d, DWORD [rsp+4*rbx] 
	mov DWORD [rdi+4*r13], r10d	; arr[k] = L[i] 
	inc rbx				; i++
endif:	
	inc r13				; k++	
	jmp mergeLoop
	
; Copy elements of L[] into arr[]
loopL:				
	cmp rbx, r14			; is i >= n1?
	jge loopR
	mov r10d, DWORD [rsp+4*rbx] 
	mov DWORD [rdi+4*r13], r10d	; arr[k] = L[i]
	inc rbx				; i++
	inc r13				; k++
	jmp loopL

; Copy elements of R[] into arr[]
loopR:	
	cmp r12, r15			; is j >= n2?
	jge endR
	lea r10, [r12+r14]
	mov r10d, DWORD [rsp+4*r10] 	
	mov DWORD [rdi+4*r13], r10d	; arr[k] = R[j]

	inc r12				; j++
	inc r13				; k++
	jmp loopR
	
endR:
	; deallocate temp arrays
	; restore callee-save registers
	add rsp, r11	
	pop r15			
	pop r14
	pop r13
	pop r12
	pop rbx
	ret
