	.file	"main.c"
	.text
	.section	.rodata
	.align 8
.LC0:
	.string	"[x] Test failed at %s: %d: %s\n"
	.text
	.globl	fail
	.type	fail, @function
fail:
.LFB6:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%rdi, -8(%rbp)
	movq	%rsi, -16(%rbp)
	movl	%edx, -20(%rbp)
	movq	-8(%rbp), %rcx
	movl	-20(%rbp), %edx
	movq	-16(%rbp), %rax
	movq	%rax, %rsi
	leaq	.LC0(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	movl	$-1, %edi
	call	exit@PLT
	.cfi_endproc
.LFE6:
	.size	fail, .-fail
	.globl	getid_val
	.data
	.align 8
	.type	getid_val, @object
	.size	getid_val, 8
getid_val:
	.quad	-1
	.section	.rodata
.LC1:
	.string	"Hello World!"
	.text
	.globl	test_costart
	.type	test_costart, @function
test_costart:
.LFB7:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	leaq	.LC1(%rip), %rdi
	call	puts@PLT
	movl	$100, %eax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE7:
	.size	test_costart, .-test_costart
	.section	.rodata
.LC2:
	.string	"Nested creation failed"
	.text
	.globl	nested_costart
	.type	nested_costart, @function
nested_costart:
.LFB8:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	leaq	test_costart(%rip), %rdi
	call	co_start@PLT
	cltq
	movq	%rax, -8(%rbp)
	cmpq	$0, -8(%rbp)
	jns	.L5
	movl	$14, %edx
	leaq	__func__.3462(%rip), %rsi
	leaq	.LC2(%rip), %rdi
	call	fail
.L5:
	movq	-8(%rbp), %rax
	movl	%eax, %edi
	call	co_wait@PLT
	movl	$200, %eax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE8:
	.size	nested_costart, .-nested_costart
	.section	.rodata
.LC3:
	.string	"Coroutine #1 before yield."
.LC4:
	.string	"Coroutine #1 after yield."
	.text
	.globl	test_yield1
	.type	test_yield1, @function
test_yield1:
.LFB9:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	leaq	.LC3(%rip), %rdi
	call	puts@PLT
	movl	$0, %eax
	call	co_yield@PLT
	leaq	.LC4(%rip), %rdi
	call	puts@PLT
	movl	$0, %eax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE9:
	.size	test_yield1, .-test_yield1
	.section	.rodata
.LC5:
	.string	"Coroutine #2 before yield."
.LC6:
	.string	"Coroutine #2 after yield."
	.text
	.globl	test_yield2
	.type	test_yield2, @function
test_yield2:
.LFB10:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	leaq	.LC5(%rip), %rdi
	call	puts@PLT
	movl	$0, %eax
	call	co_yield@PLT
	leaq	.LC6(%rip), %rdi
	call	puts@PLT
	movl	$0, %eax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE10:
	.size	test_yield2, .-test_yield2
	.globl	test_dummy
	.type	test_dummy, @function
test_dummy:
.LFB11:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	$0, %eax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE11:
	.size	test_dummy, .-test_dummy
	.globl	test_getid
	.type	test_getid, @function
test_getid:
.LFB12:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	$0, %eax
	call	co_getid@PLT
	cltq
	movq	%rax, getid_val(%rip)
	movq	getid_val(%rip), %rax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE12:
	.size	test_getid, .-test_getid
	.globl	F
	.type	F, @function
F:
.LFB13:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	leaq	test_yield2(%rip), %rdi
	call	co_start@PLT
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE13:
	.size	F, .-F
	.section	.rodata
.LC7:
	.string	"!!! sp=%lx\n"
.LC8:
	.string	"Main: after co_start"
	.align 8
.LC9:
	.string	"Main: after 2 coroutine yields."
.LC10:
	.string	"@@@ sp=%lx\n"
	.text
	.globl	main
	.type	main, @function
main:
.LFB14:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$832, %rsp
	movq	%fs:40, %rax
	movq	%rax, -8(%rbp)
	xorl	%eax, %eax
#APP
# 48 "main.c" 1
	movq %rsp, -824(%rbp);
# 0 "" 2
#NO_APP
	movq	-824(%rbp), %rax
	movq	%rax, %rsi
	leaq	.LC7(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	movl	$0, %edi
	call	srand@PLT
	leaq	test_yield1(%rip), %rdi
	call	co_start@PLT
	cltq
	movq	%rax, -816(%rbp)
	leaq	.LC8(%rip), %rdi
	call	puts@PLT
	movl	$0, %eax
	call	F
	cltq
	movq	%rax, -808(%rbp)
	movl	$0, -828(%rbp)
	jmp	.L18
.L20:
	movl	$0, %eax
	call	co_yield@PLT
.L19:
	movl	-828(%rbp), %eax
	cltq
	movq	-816(%rbp,%rax,8), %rax
	movl	%eax, %edi
	call	co_status@PLT
	cmpl	$2, %eax
	jne	.L20
	addl	$1, -828(%rbp)
.L18:
	cmpl	$1, -828(%rbp)
	jle	.L19
	leaq	.LC9(%rip), %rdi
	call	puts@PLT
#APP
# 90 "main.c" 1
	movq %rsp, -824(%rbp);
# 0 "" 2
#NO_APP
	movq	-824(%rbp), %rax
	movq	%rax, %rsi
	leaq	.LC10(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	movl	$0, %eax
	movq	-8(%rbp), %rdx
	xorq	%fs:40, %rdx
	je	.L23
	call	__stack_chk_fail@PLT
.L23:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE14:
	.size	main, .-main
	.section	.rodata
	.align 8
	.type	__func__.3462, @object
	.size	__func__.3462, 15
__func__.3462:
	.string	"nested_costart"
	.ident	"GCC: (Ubuntu 9.4.0-1ubuntu1~20.04.1) 9.4.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	 1f - 0f
	.long	 4f - 1f
	.long	 5
0:
	.string	 "GNU"
1:
	.align 8
	.long	 0xc0000002
	.long	 3f - 2f
2:
	.long	 0x3
3:
	.align 8
4:
