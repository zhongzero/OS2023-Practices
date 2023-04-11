	.file	"coroutine.c"
	.text
	.local	co_arr
	.comm	co_arr,8,8
	.local	use
	.comm	use,128,32
	.local	current_id
	.comm	current_id,4,4
	.local	co_retans
	.comm	co_retans,512,32
	.globl	yield_given_id
	.data
	.align 4
	.type	yield_given_id, @object
	.size	yield_given_id, 4
yield_given_id:
	.long	-1
	.text
	.type	co_initial, @function
co_initial:
.LFB6:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	pushq	%rbx
	subq	$24, %rsp
	.cfi_offset 3, -24
	movl	$1024, %edi
	call	malloc@PLT
	movq	%rax, co_arr(%rip)
	movl	$0, -20(%rbp)
	jmp	.L2
.L3:
	movl	-20(%rbp), %eax
	cltq
	leaq	use(%rip), %rdx
	movb	$0, (%rax,%rdx)
	addl	$1, -20(%rbp)
.L2:
	cmpl	$127, -20(%rbp)
	jle	.L3
	movl	$127, current_id(%rip)
	movl	current_id(%rip), %eax
	cltq
	leaq	use(%rip), %rdx
	movb	$1, (%rax,%rdx)
	movq	co_arr(%rip), %rax
	movl	current_id(%rip), %edx
	movslq	%edx, %rdx
	salq	$3, %rdx
	leaq	(%rax,%rdx), %rbx
	movl	$262360, %edi
	call	malloc@PLT
	movq	%rax, (%rbx)
	movq	co_arr(%rip), %rax
	movl	current_id(%rip), %edx
	movslq	%edx, %rdx
	salq	$3, %rdx
	addq	%rdx, %rax
	movq	(%rax), %rax
	movq	$0, (%rax)
	movq	co_arr(%rip), %rax
	movl	current_id(%rip), %edx
	movslq	%edx, %rdx
	salq	$3, %rdx
	addq	%rdx, %rax
	movq	(%rax), %rax
	movl	$1, 12(%rax)
	movq	co_arr(%rip), %rax
	movl	current_id(%rip), %edx
	movslq	%edx, %rdx
	salq	$3, %rdx
	addq	%rdx, %rax
	movq	(%rax), %rax
	movl	$-1, 8(%rax)
	nop
	addq	$24, %rsp
	popq	%rbx
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE6:
	.size	co_initial, .-co_initial
	.section	.init_array,"aw"
	.align 8
	.quad	co_initial
	.text
	.type	co_finish, @function
co_finish:
.LFB7:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movl	$0, -4(%rbp)
	jmp	.L5
.L7:
	movl	-4(%rbp), %eax
	cltq
	leaq	use(%rip), %rdx
	movzbl	(%rax,%rdx), %eax
	testb	%al, %al
	je	.L6
	movq	co_arr(%rip), %rax
	movl	-4(%rbp), %edx
	movslq	%edx, %rdx
	salq	$3, %rdx
	addq	%rdx, %rax
	movq	(%rax), %rax
	movq	%rax, %rdi
	call	free@PLT
.L6:
	addl	$1, -4(%rbp)
.L5:
	cmpl	$127, -4(%rbp)
	jle	.L7
	movq	co_arr(%rip), %rax
	movq	%rax, %rdi
	call	free@PLT
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE7:
	.size	co_finish, .-co_finish
	.section	.fini_array,"aw"
	.align 8
	.quad	co_finish
	.text
	.type	Find_spare_cid, @function
Find_spare_cid:
.LFB8:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	$0, -4(%rbp)
	jmp	.L9
.L12:
	movl	-4(%rbp), %eax
	cltq
	leaq	use(%rip), %rdx
	movzbl	(%rax,%rdx), %eax
	xorl	$1, %eax
	testb	%al, %al
	je	.L10
	movl	-4(%rbp), %eax
	jmp	.L11
.L10:
	addl	$1, -4(%rbp)
.L9:
	cmpl	$127, -4(%rbp)
	jle	.L12
	movl	$-1, %eax
.L11:
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE8:
	.size	Find_spare_cid, .-Find_spare_cid
	.type	Find_other_co, @function
Find_other_co:
.LFB9:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	$0, -4(%rbp)
	jmp	.L14
.L19:
	movl	current_id(%rip), %eax
	cmpl	%eax, -4(%rbp)
	je	.L20
	movl	-4(%rbp), %eax
	cltq
	leaq	use(%rip), %rdx
	movzbl	(%rax,%rdx), %eax
	testb	%al, %al
	je	.L16
	movq	co_arr(%rip), %rax
	movl	-4(%rbp), %edx
	movslq	%edx, %rdx
	salq	$3, %rdx
	addq	%rdx, %rax
	movq	(%rax), %rax
	movl	12(%rax), %eax
	testl	%eax, %eax
	je	.L17
	movq	co_arr(%rip), %rax
	movl	-4(%rbp), %edx
	movslq	%edx, %rdx
	salq	$3, %rdx
	addq	%rdx, %rax
	movq	(%rax), %rax
	movl	12(%rax), %eax
	cmpl	$1, %eax
	jne	.L16
.L17:
	movl	-4(%rbp), %eax
	jmp	.L18
.L20:
	nop
.L16:
	addl	$1, -4(%rbp)
.L14:
	cmpl	$127, -4(%rbp)
	jle	.L19
	movl	$-1, %eax
.L18:
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE9:
	.size	Find_other_co, .-Find_other_co
	.type	IsAncestor, @function
IsAncestor:
.LFB10:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	%edi, -4(%rbp)
	movl	%esi, -8(%rbp)
	jmp	.L22
.L25:
	movl	-8(%rbp), %eax
	cmpl	-4(%rbp), %eax
	jne	.L23
	movl	$1, %eax
	jmp	.L24
.L23:
	movq	co_arr(%rip), %rax
	movl	-8(%rbp), %edx
	movslq	%edx, %rdx
	salq	$3, %rdx
	addq	%rdx, %rax
	movq	(%rax), %rax
	movl	8(%rax), %eax
	movl	%eax, -8(%rbp)
.L22:
	cmpl	$-1, -8(%rbp)
	jne	.L25
	movl	$0, %eax
.L24:
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE10:
	.size	IsAncestor, .-IsAncestor
	.section	.rodata
.LC0:
	.string	"co number is full!"
.LC1:
	.string	"coroutine.c"
.LC2:
	.string	"0"
.LC3:
	.string	"!!!co_start end"
	.text
	.globl	co_start
	.type	co_start, @function
co_start:
.LFB11:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	pushq	%rbx
	subq	$40, %rsp
	.cfi_offset 3, -24
	movq	%rdi, -40(%rbp)
	movl	$0, %eax
	call	Find_spare_cid
	movl	%eax, -20(%rbp)
	cmpl	$-1, -20(%rbp)
	jne	.L27
	leaq	.LC0(%rip), %rdi
	call	puts@PLT
	leaq	__PRETTY_FUNCTION__.2957(%rip), %rcx
	movl	$93, %edx
	leaq	.LC1(%rip), %rsi
	leaq	.LC2(%rip), %rdi
	call	__assert_fail@PLT
.L27:
	movl	-20(%rbp), %eax
	cltq
	leaq	use(%rip), %rdx
	movb	$1, (%rax,%rdx)
	movq	co_arr(%rip), %rax
	movl	-20(%rbp), %edx
	movslq	%edx, %rdx
	salq	$3, %rdx
	leaq	(%rax,%rdx), %rbx
	movl	$262360, %edi
	call	malloc@PLT
	movq	%rax, (%rbx)
	movq	co_arr(%rip), %rax
	movl	-20(%rbp), %edx
	movslq	%edx, %rdx
	salq	$3, %rdx
	addq	%rdx, %rax
	movq	(%rax), %rax
	movq	-40(%rbp), %rdx
	movq	%rdx, (%rax)
	movq	co_arr(%rip), %rax
	movl	-20(%rbp), %edx
	movslq	%edx, %rdx
	salq	$3, %rdx
	addq	%rdx, %rax
	movq	(%rax), %rax
	movl	$0, 12(%rax)
	movq	co_arr(%rip), %rax
	movl	-20(%rbp), %edx
	movslq	%edx, %rdx
	salq	$3, %rdx
	addq	%rdx, %rax
	movq	(%rax), %rax
	movl	current_id(%rip), %edx
	movl	%edx, 8(%rax)
	movl	-20(%rbp), %eax
	movl	%eax, yield_given_id(%rip)
	movl	$0, %eax
	call	co_yield
	leaq	.LC3(%rip), %rdi
	call	puts@PLT
	movl	-20(%rbp), %eax
	addq	$40, %rsp
	popq	%rbx
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE11:
	.size	co_start, .-co_start
	.globl	co_getid
	.type	co_getid, @function
co_getid:
.LFB12:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	current_id(%rip), %eax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE12:
	.size	co_getid, .-co_getid
	.section	.rodata
	.align 8
.LC4:
	.string	"use[cid]==1&&co_arr[cid]->status==CO_DEAD"
	.text
	.globl	co_getret
	.type	co_getret, @function
co_getret:
.LFB13:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movl	%edi, -4(%rbp)
	movl	-4(%rbp), %eax
	cltq
	leaq	use(%rip), %rdx
	movzbl	(%rax,%rdx), %eax
	testb	%al, %al
	je	.L32
	movq	co_arr(%rip), %rax
	movl	-4(%rbp), %edx
	movslq	%edx, %rdx
	salq	$3, %rdx
	addq	%rdx, %rax
	movq	(%rax), %rax
	movl	12(%rax), %eax
	cmpl	$2, %eax
	je	.L35
.L32:
	leaq	__PRETTY_FUNCTION__.2963(%rip), %rcx
	movl	$109, %edx
	leaq	.LC1(%rip), %rsi
	leaq	.LC4(%rip), %rdi
	call	__assert_fail@PLT
.L35:
	movl	-4(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	leaq	co_retans(%rip), %rax
	movl	(%rdx,%rax), %eax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE13:
	.size	co_getret, .-co_getret
	.section	.rodata
.LC5:
	.string	"set: %d\n"
.LC6:
	.string	"yield %d ---> %d\n"
.LC7:
	.string	"co_arr[%d] -> co_arr[%d]\n"
.LC8:
	.string	"co_arr[%d] is dead\n"
.LC9:
	.string	"jump: %d\n"
.LC10:
	.string	"!!!co_yield end"
	.text
	.globl	co_yield
	.type	co_yield, @function
co_yield:
.LFB14:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%fs:40, %rax
	movq	%rax, -8(%rbp)
	xorl	%eax, %eax
	movq	$0, -16(%rbp)
	movq	co_arr(%rip), %rax
	movl	current_id(%rip), %edx
	movslq	%edx, %rdx
	salq	$3, %rdx
	addq	%rdx, %rax
	movq	(%rax), %rax
	addq	$16, %rax
	movq	%rax, %rdi
	call	_setjmp@PLT
	endbr64
	movl	%eax, -24(%rbp)
	cmpl	$0, -24(%rbp)
	jne	.L38
	movl	current_id(%rip), %eax
	movl	%eax, %esi
	leaq	.LC5(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	movl	yield_given_id(%rip), %eax
	cmpl	$-1, %eax
	jne	.L39
	movl	$0, %eax
	call	Find_other_co
	jmp	.L40
.L39:
	movl	yield_given_id(%rip), %eax
.L40:
	movl	%eax, -20(%rbp)
	movl	yield_given_id(%rip), %eax
	cmpl	$-1, %eax
	je	.L41
	movl	$-1, yield_given_id(%rip)
.L41:
	movl	current_id(%rip), %eax
	movl	-20(%rbp), %edx
	movl	%eax, %esi
	leaq	.LC6(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	cmpl	$-1, -20(%rbp)
	jne	.L42
	movl	$0, %eax
	jmp	.L46
.L42:
	movq	co_arr(%rip), %rax
	movl	-20(%rbp), %edx
	movslq	%edx, %rdx
	salq	$3, %rdx
	addq	%rdx, %rax
	movq	(%rax), %rax
	movl	12(%rax), %eax
	testl	%eax, %eax
	jne	.L44
	movl	current_id(%rip), %eax
	movl	-20(%rbp), %edx
	movl	%eax, %esi
	leaq	.LC7(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	movl	-20(%rbp), %eax
	movl	%eax, current_id(%rip)
	movq	co_arr(%rip), %rax
	movl	current_id(%rip), %edx
	movslq	%edx, %rdx
	salq	$3, %rdx
	addq	%rdx, %rax
	movq	(%rax), %rax
	movl	$1, 12(%rax)
	movl	$0, -28(%rbp)
	movq	co_arr(%rip), %rax
	movl	-20(%rbp), %edx
	movslq	%edx, %rdx
	salq	$3, %rdx
	addq	%rdx, %rax
	movq	(%rax), %rax
	addq	$216, %rax
	leaq	262144(%rax), %rdx
	movq	co_arr(%rip), %rax
	movl	-20(%rbp), %ecx
	movslq	%ecx, %rcx
	salq	$3, %rcx
	addq	%rcx, %rax
	movq	(%rax), %rax
	movq	(%rax), %rax
	movq	%rax, %rcx
#APP
# 159 "coroutine.c" 1
	leaq -0x20(%rdx), %rsp; call *%rcx; movl %eax,-28(%rbp);
# 0 "" 2
#NO_APP
	movl	current_id(%rip), %edx
	movl	-28(%rbp), %eax
	movslq	%edx, %rdx
	leaq	0(,%rdx,4), %rcx
	leaq	co_retans(%rip), %rdx
	movl	%eax, (%rcx,%rdx)
	movl	current_id(%rip), %eax
	movl	%eax, %esi
	leaq	.LC8(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	movq	co_arr(%rip), %rax
	movl	current_id(%rip), %edx
	movslq	%edx, %rdx
	salq	$3, %rdx
	addq	%rdx, %rax
	movq	(%rax), %rax
	movl	$2, 12(%rax)
	movl	$0, %eax
	call	co_yield
	jmp	.L45
.L44:
	movl	current_id(%rip), %eax
	movl	-20(%rbp), %edx
	movl	%eax, %esi
	leaq	.LC7(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	movl	-20(%rbp), %eax
	movl	%eax, current_id(%rip)
	movq	co_arr(%rip), %rax
	movl	-20(%rbp), %edx
	movslq	%edx, %rdx
	salq	$3, %rdx
	addq	%rdx, %rax
	movq	(%rax), %rax
	addq	$16, %rax
	movl	$1, %esi
	movq	%rax, %rdi
	call	longjmp@PLT
.L38:
	movl	current_id(%rip), %eax
	movl	%eax, %esi
	leaq	.LC9(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
.L45:
	leaq	.LC10(%rip), %rdi
	call	puts@PLT
#APP
# 187 "coroutine.c" 1
	movq %rsp, -16(%rbp);
# 0 "" 2
#NO_APP
	movl	$0, %eax
.L46:
	movq	-8(%rbp), %rsi
	xorq	%fs:40, %rsi
	je	.L47
	call	__stack_chk_fail@PLT
.L47:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE14:
	.size	co_yield, .-co_yield
	.globl	co_waitall
	.type	co_waitall, @function
co_waitall:
.LFB15:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
.L55:
	movb	$0, -5(%rbp)
	movl	$0, -4(%rbp)
	jmp	.L49
.L52:
	movl	current_id(%rip), %eax
	cmpl	%eax, -4(%rbp)
	je	.L50
	movl	-4(%rbp), %eax
	cltq
	leaq	use(%rip), %rdx
	movzbl	(%rax,%rdx), %eax
	testb	%al, %al
	je	.L50
	movq	co_arr(%rip), %rax
	movl	-4(%rbp), %edx
	movslq	%edx, %rdx
	salq	$3, %rdx
	addq	%rdx, %rax
	movq	(%rax), %rax
	movl	12(%rax), %eax
	cmpl	$2, %eax
	je	.L50
	movb	$1, -5(%rbp)
	jmp	.L51
.L50:
	addl	$1, -4(%rbp)
.L49:
	cmpl	$127, -4(%rbp)
	jle	.L52
.L51:
	movzbl	-5(%rbp), %eax
	xorl	$1, %eax
	testb	%al, %al
	jne	.L58
	movl	$0, %eax
	call	co_yield
	jmp	.L55
.L58:
	nop
	movl	$0, %eax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE15:
	.size	co_waitall, .-co_waitall
	.section	.rodata
.LC11:
	.string	"use[cid]==1"
	.text
	.globl	co_wait
	.type	co_wait, @function
co_wait:
.LFB16:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movl	%edi, -4(%rbp)
	movl	-4(%rbp), %eax
	cltq
	leaq	use(%rip), %rdx
	movzbl	(%rax,%rdx), %eax
	testb	%al, %al
	jne	.L61
	leaq	__PRETTY_FUNCTION__.2982(%rip), %rcx
	movl	$211, %edx
	leaq	.LC1(%rip), %rsi
	leaq	.LC11(%rip), %rdi
	call	__assert_fail@PLT
.L62:
	movl	-4(%rbp), %eax
	movl	%eax, yield_given_id(%rip)
	movl	$0, %eax
	call	co_yield
.L61:
	movq	co_arr(%rip), %rax
	movl	-4(%rbp), %edx
	movslq	%edx, %rdx
	salq	$3, %rdx
	addq	%rdx, %rax
	movq	(%rax), %rax
	movl	12(%rax), %eax
	cmpl	$2, %eax
	jne	.L62
	movl	$0, %eax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE16:
	.size	co_wait, .-co_wait
	.section	.rodata
.LC12:
	.string	"%d %d\n"
	.text
	.globl	co_status
	.type	co_status, @function
co_status:
.LFB17:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movl	%edi, -4(%rbp)
	movl	-4(%rbp), %eax
	cltq
	leaq	use(%rip), %rdx
	movzbl	(%rax,%rdx), %eax
	testb	%al, %al
	jne	.L65
	leaq	__PRETTY_FUNCTION__.2989(%rip), %rcx
	movl	$220, %edx
	leaq	.LC1(%rip), %rsi
	leaq	.LC11(%rip), %rdi
	call	__assert_fail@PLT
.L65:
	movl	current_id(%rip), %eax
	movl	-4(%rbp), %edx
	movl	%edx, %esi
	movl	%eax, %edi
	call	IsAncestor
	testb	%al, %al
	je	.L66
	movq	co_arr(%rip), %rax
	movl	-4(%rbp), %edx
	movslq	%edx, %rdx
	salq	$3, %rdx
	addq	%rdx, %rax
	movq	(%rax), %rax
	movl	12(%rax), %eax
	cmpl	$2, %eax
	jne	.L67
	movl	$2, %eax
	jmp	.L68
.L67:
	movq	co_arr(%rip), %rax
	movl	-4(%rbp), %edx
	movslq	%edx, %rdx
	salq	$3, %rdx
	addq	%rdx, %rax
	movq	(%rax), %rax
	movl	12(%rax), %edx
	movl	-4(%rbp), %eax
	movl	%eax, %esi
	leaq	.LC12(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	movl	$1, %eax
	jmp	.L68
.L66:
	movl	$-1, %eax
.L68:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE17:
	.size	co_status, .-co_status
	.section	.rodata
	.align 8
	.type	__PRETTY_FUNCTION__.2957, @object
	.size	__PRETTY_FUNCTION__.2957, 9
__PRETTY_FUNCTION__.2957:
	.string	"co_start"
	.align 8
	.type	__PRETTY_FUNCTION__.2963, @object
	.size	__PRETTY_FUNCTION__.2963, 10
__PRETTY_FUNCTION__.2963:
	.string	"co_getret"
	.align 8
	.type	__PRETTY_FUNCTION__.2982, @object
	.size	__PRETTY_FUNCTION__.2982, 8
__PRETTY_FUNCTION__.2982:
	.string	"co_wait"
	.align 8
	.type	__PRETTY_FUNCTION__.2989, @object
	.size	__PRETTY_FUNCTION__.2989, 10
__PRETTY_FUNCTION__.2989:
	.string	"co_status"
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
