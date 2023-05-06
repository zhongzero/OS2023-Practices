	.file	"main.c"
	.text
	.section	.rodata
	.align 8
.LC0:
	.string	"[x] Test failed at %s: %d: %s\n"
	.text
	.type	fail, @function
fail:
.LFB6:
	.cfi_startproc
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
	movl	$18, %edx
	leaq	__func__.4014(%rip), %rsi
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
	movl	$1, %eax
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
	.globl	total_coroutine_count
	.bss
	.align 4
	.type	total_coroutine_count, @object
	.size	total_coroutine_count, 4
total_coroutine_count:
	.zero	4
	.text
	.globl	test_multithread_coroutine_inner
	.type	test_multithread_coroutine_inner, @function
test_multithread_coroutine_inner:
.LFB13:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movq	%fs:40, %rax
	movq	%rax, -8(%rbp)
	xorl	%eax, %eax
	movl	$1, -16(%rbp)
	movl	-16(%rbp), %eax
	lock xaddl	%eax, total_coroutine_count(%rip)
	movl	%eax, -12(%rbp)
	movl	$1, %eax
	movq	-8(%rbp), %rdx
	xorq	%fs:40, %rdx
	je	.L17
	call	__stack_chk_fail@PLT
.L17:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE13:
	.size	test_multithread_coroutine_inner, .-test_multithread_coroutine_inner
	.section	.rodata
.LC7:
	.string	"Running: %d, thread: %ld\n"
.LC8:
	.string	"main.c"
	.align 8
.LC9:
	.string	"co_status(coroutine[i - 1]) == FINISHED"
	.align 8
.LC10:
	.string	"co_status(co_getid()) == RUNNING"
	.align 8
.LC11:
	.string	"co_status(coroutine[CNT - 1]) == FINISHED"
.LC12:
	.string	"Coroutine finished: %d\n"
	.text
	.globl	test_multithread_coroutine
	.type	test_multithread_coroutine, @function
test_multithread_coroutine:
.LFB14:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	pushq	%r15
	pushq	%r14
	pushq	%r12
	pushq	%rbx
	subq	$48, %rsp
	.cfi_offset 15, -24
	.cfi_offset 14, -32
	.cfi_offset 12, -40
	.cfi_offset 3, -48
	movq	%fs:40, %rax
	movq	%rax, -40(%rbp)
	xorl	%eax, %eax
	movq	%rsp, %rax
	movq	%rax, %r12
	call	pthread_self@PLT
	movq	%rax, %rbx
	movl	$0, %eax
	call	co_getid@PLT
	movq	%rbx, %rdx
	movl	%eax, %esi
	leaq	.LC7(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	movl	$1, -60(%rbp)
	movl	-60(%rbp), %eax
	cltq
	subq	$1, %rax
	movq	%rax, -56(%rbp)
	movl	-60(%rbp), %eax
	cltq
	movq	%rax, -80(%rbp)
	movq	$0, -72(%rbp)
	movl	-60(%rbp), %eax
	cltq
	movq	%rax, %r14
	movl	$0, %r15d
	movl	-60(%rbp), %eax
	cltq
	leaq	0(,%rax,8), %rdx
	movl	$16, %eax
	subq	$1, %rax
	addq	%rdx, %rax
	movl	$16, %esi
	movl	$0, %edx
	divq	%rsi
	imulq	$16, %rax, %rax
	movq	%rax, %rdx
	andq	$-4096, %rdx
	movq	%rsp, %rbx
	subq	%rdx, %rbx
	movq	%rbx, %rdx
.L19:
	cmpq	%rdx, %rsp
	je	.L20
	subq	$4096, %rsp
	orq	$0, 4088(%rsp)
	jmp	.L19
.L20:
	movq	%rax, %rdx
	andl	$4095, %edx
	subq	%rdx, %rsp
	movq	%rax, %rdx
	andl	$4095, %edx
	testq	%rdx, %rdx
	je	.L21
	andl	$4095, %eax
	subq	$8, %rax
	addq	%rsp, %rax
	orq	$0, (%rax)
.L21:
	movq	%rsp, %rax
	addq	$7, %rax
	shrq	$3, %rax
	salq	$3, %rax
	movq	%rax, -48(%rbp)
	movl	$0, -64(%rbp)
	jmp	.L22
.L25:
	leaq	test_multithread_coroutine_inner(%rip), %rdi
	call	co_start@PLT
	movslq	%eax, %rcx
	movq	-48(%rbp), %rax
	movl	-64(%rbp), %edx
	movslq	%edx, %rdx
	movq	%rcx, (%rax,%rdx,8)
	movl	$0, %eax
	call	co_yield@PLT
	cmpl	$1, -64(%rbp)
	jle	.L23
	movl	-64(%rbp), %eax
	leal	-1(%rax), %edx
	movq	-48(%rbp), %rax
	movslq	%edx, %rdx
	movq	(%rax,%rdx,8), %rax
	movl	%eax, %edi
	call	co_wait@PLT
	movl	-64(%rbp), %eax
	leal	-1(%rax), %edx
	movq	-48(%rbp), %rax
	movslq	%edx, %rdx
	movq	(%rax,%rdx,8), %rax
	movl	%eax, %edi
	call	co_status@PLT
	cmpl	$2, %eax
	je	.L23
	leaq	__PRETTY_FUNCTION__.4037(%rip), %rcx
	movl	$63, %edx
	leaq	.LC8(%rip), %rsi
	leaq	.LC9(%rip), %rdi
	call	__assert_fail@PLT
.L23:
	movl	$0, %eax
	call	co_yield@PLT
	movl	$0, %eax
	call	co_getid@PLT
	movl	%eax, %edi
	call	co_status@PLT
	cmpl	$1, %eax
	je	.L24
	leaq	__PRETTY_FUNCTION__.4037(%rip), %rcx
	movl	$66, %edx
	leaq	.LC8(%rip), %rsi
	leaq	.LC10(%rip), %rdi
	call	__assert_fail@PLT
.L24:
	movl	$0, %eax
	call	co_yield@PLT
	addl	$1, -64(%rbp)
.L22:
	movl	-64(%rbp), %eax
	cmpl	-60(%rbp), %eax
	jl	.L25
	movl	-60(%rbp), %eax
	leal	-1(%rax), %edx
	movq	-48(%rbp), %rax
	movslq	%edx, %rdx
	movq	(%rax,%rdx,8), %rax
	movl	%eax, %edi
	call	co_wait@PLT
	movl	-60(%rbp), %eax
	leal	-1(%rax), %edx
	movq	-48(%rbp), %rax
	movslq	%edx, %rdx
	movq	(%rax,%rdx,8), %rax
	movl	%eax, %edi
	call	co_status@PLT
	cmpl	$2, %eax
	je	.L26
	leaq	__PRETTY_FUNCTION__.4037(%rip), %rcx
	movl	$70, %edx
	leaq	.LC8(%rip), %rsi
	leaq	.LC11(%rip), %rdi
	call	__assert_fail@PLT
.L26:
	movl	$0, %eax
	call	co_getid@PLT
	movl	%eax, %esi
	leaq	.LC12(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	movl	$1, %eax
	movq	%r12, %rsp
	movq	-40(%rbp), %rcx
	xorq	%fs:40, %rcx
	je	.L28
	call	__stack_chk_fail@PLT
.L28:
	leaq	-32(%rbp), %rsp
	popq	%rbx
	popq	%r12
	popq	%r14
	popq	%r15
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE14:
	.size	test_multithread_coroutine, .-test_multithread_coroutine
	.section	.rodata
.LC13:
	.string	"Thread: %ld\n"
.LC14:
	.string	"co_getret(coroutine[i]) == 1"
	.align 8
.LC15:
	.string	"co_status(coroutine[i]) == FINISHED"
.LC16:
	.string	"Thread finished: %ld\n"
	.text
	.globl	test_multithread_thread
	.type	test_multithread_thread, @function
test_multithread_thread:
.LFB15:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$72, %rsp
	.cfi_offset 15, -24
	.cfi_offset 14, -32
	.cfi_offset 13, -40
	.cfi_offset 12, -48
	.cfi_offset 3, -56
	movq	%rdi, -104(%rbp)
	movq	%fs:40, %rax
	movq	%rax, -56(%rbp)
	xorl	%eax, %eax
	movq	%rsp, %rax
	movq	%rax, %rbx
	call	pthread_self@PLT
	movq	%rax, %rsi
	leaq	.LC13(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	movl	$1, -76(%rbp)
	movl	-76(%rbp), %eax
	cltq
	subq	$1, %rax
	movq	%rax, -72(%rbp)
	movl	-76(%rbp), %eax
	cltq
	movq	%rax, %r14
	movl	$0, %r15d
	movl	-76(%rbp), %eax
	cltq
	movq	%rax, %r12
	movl	$0, %r13d
	movl	-76(%rbp), %eax
	cltq
	leaq	0(,%rax,8), %rdx
	movl	$16, %eax
	subq	$1, %rax
	addq	%rdx, %rax
	movl	$16, %esi
	movl	$0, %edx
	divq	%rsi
	imulq	$16, %rax, %rax
	movq	%rax, %rdx
	andq	$-4096, %rdx
	movq	%rsp, %rcx
	subq	%rdx, %rcx
	movq	%rcx, %rdx
.L30:
	cmpq	%rdx, %rsp
	je	.L31
	subq	$4096, %rsp
	orq	$0, 4088(%rsp)
	jmp	.L30
.L31:
	movq	%rax, %rdx
	andl	$4095, %edx
	subq	%rdx, %rsp
	movq	%rax, %rdx
	andl	$4095, %edx
	testq	%rdx, %rdx
	je	.L32
	andl	$4095, %eax
	subq	$8, %rax
	addq	%rsp, %rax
	orq	$0, (%rax)
.L32:
	movq	%rsp, %rax
	addq	$7, %rax
	shrq	$3, %rax
	salq	$3, %rax
	movq	%rax, -64(%rbp)
	movl	$0, -80(%rbp)
	jmp	.L33
.L34:
	leaq	test_multithread_coroutine(%rip), %rdi
	call	co_start@PLT
	movslq	%eax, %rcx
	movq	-64(%rbp), %rax
	movl	-80(%rbp), %edx
	movslq	%edx, %rdx
	movq	%rcx, (%rax,%rdx,8)
	addl	$1, -80(%rbp)
.L33:
	movl	-80(%rbp), %eax
	cmpl	-76(%rbp), %eax
	jl	.L34
	movl	$0, -84(%rbp)
	jmp	.L35
.L38:
	movq	-64(%rbp), %rax
	movl	-84(%rbp), %edx
	movslq	%edx, %rdx
	movq	(%rax,%rdx,8), %rax
	movl	%eax, %edi
	call	co_getret@PLT
	cmpl	$1, %eax
	je	.L36
	leaq	__PRETTY_FUNCTION__.4051(%rip), %rcx
	movl	$83, %edx
	leaq	.LC8(%rip), %rsi
	leaq	.LC14(%rip), %rdi
	call	__assert_fail@PLT
.L36:
	movq	-64(%rbp), %rax
	movl	-84(%rbp), %edx
	movslq	%edx, %rdx
	movq	(%rax,%rdx,8), %rax
	movl	%eax, %edi
	call	co_status@PLT
	cmpl	$2, %eax
	je	.L37
	leaq	__PRETTY_FUNCTION__.4051(%rip), %rcx
	movl	$84, %edx
	leaq	.LC8(%rip), %rsi
	leaq	.LC15(%rip), %rdi
	call	__assert_fail@PLT
.L37:
	addl	$1, -84(%rbp)
.L35:
	movl	-84(%rbp), %eax
	cmpl	-76(%rbp), %eax
	jl	.L38
	call	pthread_self@PLT
	movq	%rax, %rsi
	leaq	.LC16(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	movq	%rbx, %rsp
	nop
	movq	-56(%rbp), %rbx
	xorq	%fs:40, %rbx
	je	.L39
	call	__stack_chk_fail@PLT
.L39:
	leaq	-40(%rbp), %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE15:
	.size	test_multithread_thread, .-test_multithread_thread
	.globl	test_multithread
	.type	test_multithread, @function
test_multithread:
.LFB16:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	pushq	%rbx
	subq	$56, %rsp
	.cfi_offset 3, -24
	movq	%fs:40, %rax
	movq	%rax, -24(%rbp)
	xorl	%eax, %eax
	movq	%rsp, %rax
	movq	%rax, %rbx
	movl	$2, -48(%rbp)
	movl	-48(%rbp), %eax
	cltq
	subq	$1, %rax
	movq	%rax, -40(%rbp)
	movl	-48(%rbp), %eax
	cltq
	movq	%rax, %r8
	movl	$0, %r9d
	movl	-48(%rbp), %eax
	cltq
	movq	%rax, %rsi
	movl	$0, %edi
	movl	-48(%rbp), %eax
	cltq
	leaq	0(,%rax,8), %rdx
	movl	$16, %eax
	subq	$1, %rax
	addq	%rdx, %rax
	movl	$16, %edi
	movl	$0, %edx
	divq	%rdi
	imulq	$16, %rax, %rax
	movq	%rax, %rdx
	andq	$-4096, %rdx
	movq	%rsp, %rcx
	subq	%rdx, %rcx
	movq	%rcx, %rdx
.L41:
	cmpq	%rdx, %rsp
	je	.L42
	subq	$4096, %rsp
	orq	$0, 4088(%rsp)
	jmp	.L41
.L42:
	movq	%rax, %rdx
	andl	$4095, %edx
	subq	%rdx, %rsp
	movq	%rax, %rdx
	andl	$4095, %edx
	testq	%rdx, %rdx
	je	.L43
	andl	$4095, %eax
	subq	$8, %rax
	addq	%rsp, %rax
	orq	$0, (%rax)
.L43:
	movq	%rsp, %rax
	addq	$7, %rax
	shrq	$3, %rax
	salq	$3, %rax
	movq	%rax, -32(%rbp)
	movl	$0, -60(%rbp)
	movl	-60(%rbp), %eax
	movl	%eax, total_coroutine_count(%rip)
	mfence
	movl	$0, -52(%rbp)
	jmp	.L44
.L45:
	movl	-52(%rbp), %eax
	cltq
	leaq	0(,%rax,8), %rdx
	movq	-32(%rbp), %rax
	addq	%rdx, %rax
	movl	$0, %ecx
	leaq	test_multithread_thread(%rip), %rdx
	movl	$0, %esi
	movq	%rax, %rdi
	call	pthread_create@PLT
	movl	%eax, -44(%rbp)
	addl	$1, -52(%rbp)
.L44:
	movl	-52(%rbp), %eax
	cmpl	-48(%rbp), %eax
	jl	.L45
	movl	$0, -56(%rbp)
	jmp	.L46
.L47:
	movq	-32(%rbp), %rax
	movl	-56(%rbp), %edx
	movslq	%edx, %rdx
	movq	(%rax,%rdx,8), %rax
	movl	$0, %esi
	movq	%rax, %rdi
	call	pthread_join@PLT
	addl	$1, -56(%rbp)
.L46:
	movl	-56(%rbp), %eax
	cmpl	-48(%rbp), %eax
	jl	.L47
	movl	$0, %eax
	movq	%rbx, %rsp
	movq	-24(%rbp), %rdi
	xorq	%fs:40, %rdi
	je	.L49
	call	__stack_chk_fail@PLT
.L49:
	movq	-8(%rbp), %rbx
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE16:
	.size	test_multithread, .-test_multithread
	.section	.rodata
.LC18:
	.string	"Multithread time: %lf ms\n"
	.text
	.globl	test_multithread_timer
	.type	test_multithread_timer, @function
test_multithread_timer:
.LFB17:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$48, %rsp
	movq	%fs:40, %rax
	movq	%rax, -8(%rbp)
	xorl	%eax, %eax
	leaq	-32(%rbp), %rax
	movl	$0, %esi
	movq	%rax, %rdi
	call	gettimeofday@PLT
	movl	$0, %eax
	call	test_multithread
	leaq	-48(%rbp), %rax
	movl	$0, %esi
	movq	%rax, %rdi
	call	gettimeofday@PLT
	movq	-48(%rbp), %rdx
	movq	-32(%rbp), %rax
	subq	%rax, %rdx
	movq	%rdx, %rax
	imulq	$1000, %rax, %rax
	cvtsi2sdq	%rax, %xmm1
	movq	-40(%rbp), %rdx
	movq	-24(%rbp), %rax
	subq	%rax, %rdx
	movq	%rdx, %rax
	cvtsi2sdq	%rax, %xmm0
	movsd	.LC17(%rip), %xmm2
	divsd	%xmm2, %xmm0
	addsd	%xmm1, %xmm0
	leaq	.LC18(%rip), %rdi
	movl	$1, %eax
	call	printf@PLT
	nop
	movq	-8(%rbp), %rcx
	xorq	%fs:40, %rcx
	je	.L51
	call	__stack_chk_fail@PLT
.L51:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE17:
	.size	test_multithread_timer, .-test_multithread_timer
	.section	.rodata
.LC19:
	.string	"%ld\n"
.LC20:
	.string	"Coroutine ID not equal"
.LC21:
	.string	"Coroutine return value failed"
.LC22:
	.string	"Nested coroutine ID not equal"
	.align 8
.LC23:
	.string	"Nested coroutine return value failed"
	.align 8
.LC24:
	.string	"Coroutine failed at status error"
.LC25:
	.string	"Main: after co_start"
	.align 8
.LC26:
	.string	"Main: after 2 coroutine yields."
	.align 8
.LC27:
	.string	"Get ID differs from internal getid"
	.align 8
.LC28:
	.string	"Get ID differs from internal return value"
.LC29:
	.string	"Main: test getid finished."
.LC30:
	.string	"Finish running."
	.text
	.globl	main
	.type	main, @function
main:
.LFB18:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	pushq	%rbx
	subq	$216, %rsp
	.cfi_offset 3, -24
	movq	%fs:40, %rax
	movq	%rax, -24(%rbp)
	xorl	%eax, %eax
	call	pthread_self@PLT
	movq	%rax, %rsi
	leaq	.LC19(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	movl	$0, %edi
	call	srand@PLT
	movl	$0, -212(%rbp)
	jmp	.L53
.L55:
	leaq	test_costart(%rip), %rdi
	call	co_start@PLT
	movslq	%eax, %rdx
	movl	-212(%rbp), %eax
	cltq
	movq	%rdx, -192(%rbp,%rax,8)
	movl	-212(%rbp), %eax
	cltq
	movq	-192(%rbp,%rax,8), %rdx
	movl	-212(%rbp), %eax
	cltq
	cmpq	%rax, %rdx
	je	.L54
	movl	$120, %edx
	leaq	__func__.4077(%rip), %rsi
	leaq	.LC20(%rip), %rdi
	call	fail
.L54:
	addl	$1, -212(%rbp)
.L53:
	cmpl	$9, -212(%rbp)
	jle	.L55
	movl	$0, %eax
	call	co_waitall@PLT
	movl	$0, -208(%rbp)
	jmp	.L56
.L58:
	movl	-208(%rbp), %eax
	cltq
	movq	-192(%rbp,%rax,8), %rax
	movl	%eax, %edi
	call	co_getret@PLT
	cmpl	$100, %eax
	je	.L57
	movl	$126, %edx
	leaq	__func__.4077(%rip), %rsi
	leaq	.LC21(%rip), %rdi
	call	fail
.L57:
	addl	$1, -208(%rbp)
.L56:
	cmpl	$9, -208(%rbp)
	jle	.L58
	leaq	nested_costart(%rip), %rdi
	call	co_start@PLT
	cltq
	movq	%rax, -192(%rbp)
	movq	-192(%rbp), %rax
	cmpq	$10, %rax
	je	.L59
	movl	$130, %edx
	leaq	__func__.4077(%rip), %rsi
	leaq	.LC22(%rip), %rdi
	call	fail
.L59:
	movq	-192(%rbp), %rax
	movl	%eax, %edi
	call	co_getret@PLT
	cmpl	$200, %eax
	je	.L60
	movl	$131, %edx
	leaq	__func__.4077(%rip), %rsi
	leaq	.LC23(%rip), %rdi
	call	fail
.L60:
	movl	$0, -204(%rbp)
	jmp	.L61
.L63:
	movl	-204(%rbp), %eax
	movl	%eax, %edi
	call	co_status@PLT
	cmpl	$2, %eax
	je	.L62
	movl	$133, %edx
	leaq	__func__.4077(%rip), %rsi
	leaq	.LC24(%rip), %rdi
	call	fail
.L62:
	addl	$1, -204(%rbp)
.L61:
	cmpl	$11, -204(%rbp)
	jle	.L63
	leaq	test_yield1(%rip), %rdi
	call	co_start@PLT
	cltq
	movq	%rax, -192(%rbp)
	leaq	.LC25(%rip), %rdi
	call	puts@PLT
	leaq	test_yield2(%rip), %rdi
	call	co_start@PLT
	cltq
	movq	%rax, -184(%rbp)
	movl	$0, -200(%rbp)
	jmp	.L64
.L66:
	movl	$0, %eax
	call	co_yield@PLT
.L65:
	movl	-200(%rbp), %eax
	cltq
	movq	-192(%rbp,%rax,8), %rax
	movl	%eax, %edi
	call	co_status@PLT
	cmpl	$2, %eax
	jne	.L66
	addl	$1, -200(%rbp)
.L64:
	cmpl	$1, -200(%rbp)
	jle	.L65
	leaq	.LC26(%rip), %rdi
	call	puts@PLT
	movl	$0, -196(%rbp)
	jmp	.L68
.L69:
	leaq	test_dummy(%rip), %rdi
	call	co_start@PLT
	movslq	%eax, %rdx
	movl	-196(%rbp), %eax
	cltq
	movq	%rdx, -192(%rbp,%rax,8)
	addl	$1, -196(%rbp)
.L68:
	cmpl	$9, -196(%rbp)
	jle	.L69
	movl	$0, %eax
	call	co_waitall@PLT
	leaq	test_getid(%rip), %rdi
	call	co_start@PLT
	cltq
	movq	%rax, -192(%rbp)
	movq	-192(%rbp), %rax
	movl	%eax, %edi
	call	co_wait@PLT
	movq	-192(%rbp), %rdx
	movq	getid_val(%rip), %rax
	cmpq	%rax, %rdx
	je	.L70
	movl	$145, %edx
	leaq	__func__.4077(%rip), %rsi
	leaq	.LC27(%rip), %rdi
	call	fail
.L70:
	movq	-192(%rbp), %rbx
	movq	getid_val(%rip), %rax
	movl	%eax, %edi
	call	co_getret@PLT
	cltq
	cmpq	%rax, %rbx
	je	.L71
	movl	$146, %edx
	leaq	__func__.4077(%rip), %rsi
	leaq	.LC28(%rip), %rdi
	call	fail
.L71:
	leaq	.LC29(%rip), %rdi
	call	puts@PLT
	leaq	.LC30(%rip), %rdi
	call	puts@PLT
	movl	$0, %eax
	movq	-24(%rbp), %rcx
	xorq	%fs:40, %rcx
	je	.L73
	call	__stack_chk_fail@PLT
.L73:
	addq	$216, %rsp
	popq	%rbx
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE18:
	.size	main, .-main
	.section	.rodata
	.align 8
	.type	__func__.4014, @object
	.size	__func__.4014, 15
__func__.4014:
	.string	"nested_costart"
	.align 16
	.type	__PRETTY_FUNCTION__.4037, @object
	.size	__PRETTY_FUNCTION__.4037, 27
__PRETTY_FUNCTION__.4037:
	.string	"test_multithread_coroutine"
	.align 16
	.type	__PRETTY_FUNCTION__.4051, @object
	.size	__PRETTY_FUNCTION__.4051, 24
__PRETTY_FUNCTION__.4051:
	.string	"test_multithread_thread"
	.type	__func__.4077, @object
	.size	__func__.4077, 5
__func__.4077:
	.string	"main"
	.align 8
.LC17:
	.long	0
	.long	1083129856
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
