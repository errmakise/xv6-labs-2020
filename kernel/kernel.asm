
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	92013103          	ld	sp,-1760(sp) # 80008920 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	070000ef          	jal	ra,80000086 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    80000026:	0037969b          	slliw	a3,a5,0x3
    8000002a:	02004737          	lui	a4,0x2004
    8000002e:	96ba                	add	a3,a3,a4
    80000030:	0200c737          	lui	a4,0x200c
    80000034:	ff873603          	ld	a2,-8(a4) # 200bff8 <_entry-0x7dff4008>
    80000038:	000f4737          	lui	a4,0xf4
    8000003c:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000040:	963a                	add	a2,a2,a4
    80000042:	e290                	sd	a2,0(a3)

  // prepare information in scratch[] for timervec.
  // scratch[0..3] : space for timervec to save registers.
  // scratch[4] : address of CLINT MTIMECMP register.
  // scratch[5] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &mscratch0[32 * id];
    80000044:	0057979b          	slliw	a5,a5,0x5
    80000048:	078e                	slli	a5,a5,0x3
    8000004a:	00009617          	auipc	a2,0x9
    8000004e:	fe660613          	addi	a2,a2,-26 # 80009030 <mscratch0>
    80000052:	97b2                	add	a5,a5,a2
  scratch[4] = CLINT_MTIMECMP(id);
    80000054:	f394                	sd	a3,32(a5)
  scratch[5] = interval;
    80000056:	f798                	sd	a4,40(a5)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000058:	34079073          	csrw	mscratch,a5
  asm volatile("csrw mtvec, %0" : : "r" (x));
    8000005c:	00006797          	auipc	a5,0x6
    80000060:	df478793          	addi	a5,a5,-524 # 80005e50 <timervec>
    80000064:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    8000006c:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000070:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000074:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000078:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    8000007c:	30479073          	csrw	mie,a5
}
    80000080:	6422                	ld	s0,8(sp)
    80000082:	0141                	addi	sp,sp,16
    80000084:	8082                	ret

0000000080000086 <start>:
{
    80000086:	1141                	addi	sp,sp,-16
    80000088:	e406                	sd	ra,8(sp)
    8000008a:	e022                	sd	s0,0(sp)
    8000008c:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000008e:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000092:	7779                	lui	a4,0xffffe
    80000094:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd77df>
    80000098:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000009a:	6705                	lui	a4,0x1
    8000009c:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a2:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000a6:	00001797          	auipc	a5,0x1
    800000aa:	e3278793          	addi	a5,a5,-462 # 80000ed8 <main>
    800000ae:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b2:	4781                	li	a5,0
    800000b4:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000b8:	67c1                	lui	a5,0x10
    800000ba:	17fd                	addi	a5,a5,-1
    800000bc:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c0:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000c4:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000c8:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000cc:	10479073          	csrw	sie,a5
  timerinit();
    800000d0:	00000097          	auipc	ra,0x0
    800000d4:	f4c080e7          	jalr	-180(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000d8:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000dc:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000de:	823e                	mv	tp,a5
  asm volatile("mret");
    800000e0:	30200073          	mret
}
    800000e4:	60a2                	ld	ra,8(sp)
    800000e6:	6402                	ld	s0,0(sp)
    800000e8:	0141                	addi	sp,sp,16
    800000ea:	8082                	ret

00000000800000ec <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000ec:	715d                	addi	sp,sp,-80
    800000ee:	e486                	sd	ra,72(sp)
    800000f0:	e0a2                	sd	s0,64(sp)
    800000f2:	fc26                	sd	s1,56(sp)
    800000f4:	f84a                	sd	s2,48(sp)
    800000f6:	f44e                	sd	s3,40(sp)
    800000f8:	f052                	sd	s4,32(sp)
    800000fa:	ec56                	sd	s5,24(sp)
    800000fc:	0880                	addi	s0,sp,80
    800000fe:	8a2a                	mv	s4,a0
    80000100:	84ae                	mv	s1,a1
    80000102:	89b2                	mv	s3,a2
  int i;

  acquire(&cons.lock);
    80000104:	00011517          	auipc	a0,0x11
    80000108:	72c50513          	addi	a0,a0,1836 # 80011830 <cons>
    8000010c:	00001097          	auipc	ra,0x1
    80000110:	b1e080e7          	jalr	-1250(ra) # 80000c2a <acquire>
  for(i = 0; i < n; i++){
    80000114:	05305b63          	blez	s3,8000016a <consolewrite+0x7e>
    80000118:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011a:	5afd                	li	s5,-1
    8000011c:	4685                	li	a3,1
    8000011e:	8626                	mv	a2,s1
    80000120:	85d2                	mv	a1,s4
    80000122:	fbf40513          	addi	a0,s0,-65
    80000126:	00002097          	auipc	ra,0x2
    8000012a:	5cc080e7          	jalr	1484(ra) # 800026f2 <either_copyin>
    8000012e:	01550c63          	beq	a0,s5,80000146 <consolewrite+0x5a>
      break;
    uartputc(c);
    80000132:	fbf44503          	lbu	a0,-65(s0)
    80000136:	00000097          	auipc	ra,0x0
    8000013a:	7aa080e7          	jalr	1962(ra) # 800008e0 <uartputc>
  for(i = 0; i < n; i++){
    8000013e:	2905                	addiw	s2,s2,1
    80000140:	0485                	addi	s1,s1,1
    80000142:	fd299de3          	bne	s3,s2,8000011c <consolewrite+0x30>
  }
  release(&cons.lock);
    80000146:	00011517          	auipc	a0,0x11
    8000014a:	6ea50513          	addi	a0,a0,1770 # 80011830 <cons>
    8000014e:	00001097          	auipc	ra,0x1
    80000152:	b90080e7          	jalr	-1136(ra) # 80000cde <release>

  return i;
}
    80000156:	854a                	mv	a0,s2
    80000158:	60a6                	ld	ra,72(sp)
    8000015a:	6406                	ld	s0,64(sp)
    8000015c:	74e2                	ld	s1,56(sp)
    8000015e:	7942                	ld	s2,48(sp)
    80000160:	79a2                	ld	s3,40(sp)
    80000162:	7a02                	ld	s4,32(sp)
    80000164:	6ae2                	ld	s5,24(sp)
    80000166:	6161                	addi	sp,sp,80
    80000168:	8082                	ret
  for(i = 0; i < n; i++){
    8000016a:	4901                	li	s2,0
    8000016c:	bfe9                	j	80000146 <consolewrite+0x5a>

000000008000016e <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000016e:	7119                	addi	sp,sp,-128
    80000170:	fc86                	sd	ra,120(sp)
    80000172:	f8a2                	sd	s0,112(sp)
    80000174:	f4a6                	sd	s1,104(sp)
    80000176:	f0ca                	sd	s2,96(sp)
    80000178:	ecce                	sd	s3,88(sp)
    8000017a:	e8d2                	sd	s4,80(sp)
    8000017c:	e4d6                	sd	s5,72(sp)
    8000017e:	e0da                	sd	s6,64(sp)
    80000180:	fc5e                	sd	s7,56(sp)
    80000182:	f862                	sd	s8,48(sp)
    80000184:	f466                	sd	s9,40(sp)
    80000186:	f06a                	sd	s10,32(sp)
    80000188:	ec6e                	sd	s11,24(sp)
    8000018a:	0100                	addi	s0,sp,128
    8000018c:	8b2a                	mv	s6,a0
    8000018e:	8aae                	mv	s5,a1
    80000190:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000192:	00060b9b          	sext.w	s7,a2
  acquire(&cons.lock);
    80000196:	00011517          	auipc	a0,0x11
    8000019a:	69a50513          	addi	a0,a0,1690 # 80011830 <cons>
    8000019e:	00001097          	auipc	ra,0x1
    800001a2:	a8c080e7          	jalr	-1396(ra) # 80000c2a <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    800001a6:	00011497          	auipc	s1,0x11
    800001aa:	68a48493          	addi	s1,s1,1674 # 80011830 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001ae:	89a6                	mv	s3,s1
    800001b0:	00011917          	auipc	s2,0x11
    800001b4:	71890913          	addi	s2,s2,1816 # 800118c8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    800001b8:	4c91                	li	s9,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ba:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001bc:	4da9                	li	s11,10
  while(n > 0){
    800001be:	07405863          	blez	s4,8000022e <consoleread+0xc0>
    while(cons.r == cons.w){
    800001c2:	0984a783          	lw	a5,152(s1)
    800001c6:	09c4a703          	lw	a4,156(s1)
    800001ca:	02f71463          	bne	a4,a5,800001f2 <consoleread+0x84>
      if(myproc()->killed){
    800001ce:	00002097          	auipc	ra,0x2
    800001d2:	944080e7          	jalr	-1724(ra) # 80001b12 <myproc>
    800001d6:	591c                	lw	a5,48(a0)
    800001d8:	e7b5                	bnez	a5,80000244 <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    800001da:	85ce                	mv	a1,s3
    800001dc:	854a                	mv	a0,s2
    800001de:	00002097          	auipc	ra,0x2
    800001e2:	25c080e7          	jalr	604(ra) # 8000243a <sleep>
    while(cons.r == cons.w){
    800001e6:	0984a783          	lw	a5,152(s1)
    800001ea:	09c4a703          	lw	a4,156(s1)
    800001ee:	fef700e3          	beq	a4,a5,800001ce <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001f2:	0017871b          	addiw	a4,a5,1
    800001f6:	08e4ac23          	sw	a4,152(s1)
    800001fa:	07f7f713          	andi	a4,a5,127
    800001fe:	9726                	add	a4,a4,s1
    80000200:	01874703          	lbu	a4,24(a4)
    80000204:	00070c1b          	sext.w	s8,a4
    if(c == C('D')){  // end-of-file
    80000208:	079c0663          	beq	s8,s9,80000274 <consoleread+0x106>
    cbuf = c;
    8000020c:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000210:	4685                	li	a3,1
    80000212:	f8f40613          	addi	a2,s0,-113
    80000216:	85d6                	mv	a1,s5
    80000218:	855a                	mv	a0,s6
    8000021a:	00002097          	auipc	ra,0x2
    8000021e:	482080e7          	jalr	1154(ra) # 8000269c <either_copyout>
    80000222:	01a50663          	beq	a0,s10,8000022e <consoleread+0xc0>
    dst++;
    80000226:	0a85                	addi	s5,s5,1
    --n;
    80000228:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    8000022a:	f9bc1ae3          	bne	s8,s11,800001be <consoleread+0x50>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    8000022e:	00011517          	auipc	a0,0x11
    80000232:	60250513          	addi	a0,a0,1538 # 80011830 <cons>
    80000236:	00001097          	auipc	ra,0x1
    8000023a:	aa8080e7          	jalr	-1368(ra) # 80000cde <release>

  return target - n;
    8000023e:	414b853b          	subw	a0,s7,s4
    80000242:	a811                	j	80000256 <consoleread+0xe8>
        release(&cons.lock);
    80000244:	00011517          	auipc	a0,0x11
    80000248:	5ec50513          	addi	a0,a0,1516 # 80011830 <cons>
    8000024c:	00001097          	auipc	ra,0x1
    80000250:	a92080e7          	jalr	-1390(ra) # 80000cde <release>
        return -1;
    80000254:	557d                	li	a0,-1
}
    80000256:	70e6                	ld	ra,120(sp)
    80000258:	7446                	ld	s0,112(sp)
    8000025a:	74a6                	ld	s1,104(sp)
    8000025c:	7906                	ld	s2,96(sp)
    8000025e:	69e6                	ld	s3,88(sp)
    80000260:	6a46                	ld	s4,80(sp)
    80000262:	6aa6                	ld	s5,72(sp)
    80000264:	6b06                	ld	s6,64(sp)
    80000266:	7be2                	ld	s7,56(sp)
    80000268:	7c42                	ld	s8,48(sp)
    8000026a:	7ca2                	ld	s9,40(sp)
    8000026c:	7d02                	ld	s10,32(sp)
    8000026e:	6de2                	ld	s11,24(sp)
    80000270:	6109                	addi	sp,sp,128
    80000272:	8082                	ret
      if(n < target){
    80000274:	000a071b          	sext.w	a4,s4
    80000278:	fb777be3          	bgeu	a4,s7,8000022e <consoleread+0xc0>
        cons.r--;
    8000027c:	00011717          	auipc	a4,0x11
    80000280:	64f72623          	sw	a5,1612(a4) # 800118c8 <cons+0x98>
    80000284:	b76d                	j	8000022e <consoleread+0xc0>

0000000080000286 <consputc>:
{
    80000286:	1141                	addi	sp,sp,-16
    80000288:	e406                	sd	ra,8(sp)
    8000028a:	e022                	sd	s0,0(sp)
    8000028c:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000028e:	10000793          	li	a5,256
    80000292:	00f50a63          	beq	a0,a5,800002a6 <consputc+0x20>
    uartputc_sync(c);
    80000296:	00000097          	auipc	ra,0x0
    8000029a:	564080e7          	jalr	1380(ra) # 800007fa <uartputc_sync>
}
    8000029e:	60a2                	ld	ra,8(sp)
    800002a0:	6402                	ld	s0,0(sp)
    800002a2:	0141                	addi	sp,sp,16
    800002a4:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002a6:	4521                	li	a0,8
    800002a8:	00000097          	auipc	ra,0x0
    800002ac:	552080e7          	jalr	1362(ra) # 800007fa <uartputc_sync>
    800002b0:	02000513          	li	a0,32
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	546080e7          	jalr	1350(ra) # 800007fa <uartputc_sync>
    800002bc:	4521                	li	a0,8
    800002be:	00000097          	auipc	ra,0x0
    800002c2:	53c080e7          	jalr	1340(ra) # 800007fa <uartputc_sync>
    800002c6:	bfe1                	j	8000029e <consputc+0x18>

00000000800002c8 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002c8:	1101                	addi	sp,sp,-32
    800002ca:	ec06                	sd	ra,24(sp)
    800002cc:	e822                	sd	s0,16(sp)
    800002ce:	e426                	sd	s1,8(sp)
    800002d0:	e04a                	sd	s2,0(sp)
    800002d2:	1000                	addi	s0,sp,32
    800002d4:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002d6:	00011517          	auipc	a0,0x11
    800002da:	55a50513          	addi	a0,a0,1370 # 80011830 <cons>
    800002de:	00001097          	auipc	ra,0x1
    800002e2:	94c080e7          	jalr	-1716(ra) # 80000c2a <acquire>

  switch(c){
    800002e6:	47d5                	li	a5,21
    800002e8:	0af48663          	beq	s1,a5,80000394 <consoleintr+0xcc>
    800002ec:	0297ca63          	blt	a5,s1,80000320 <consoleintr+0x58>
    800002f0:	47a1                	li	a5,8
    800002f2:	0ef48763          	beq	s1,a5,800003e0 <consoleintr+0x118>
    800002f6:	47c1                	li	a5,16
    800002f8:	10f49a63          	bne	s1,a5,8000040c <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002fc:	00002097          	auipc	ra,0x2
    80000300:	44c080e7          	jalr	1100(ra) # 80002748 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000304:	00011517          	auipc	a0,0x11
    80000308:	52c50513          	addi	a0,a0,1324 # 80011830 <cons>
    8000030c:	00001097          	auipc	ra,0x1
    80000310:	9d2080e7          	jalr	-1582(ra) # 80000cde <release>
}
    80000314:	60e2                	ld	ra,24(sp)
    80000316:	6442                	ld	s0,16(sp)
    80000318:	64a2                	ld	s1,8(sp)
    8000031a:	6902                	ld	s2,0(sp)
    8000031c:	6105                	addi	sp,sp,32
    8000031e:	8082                	ret
  switch(c){
    80000320:	07f00793          	li	a5,127
    80000324:	0af48e63          	beq	s1,a5,800003e0 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000328:	00011717          	auipc	a4,0x11
    8000032c:	50870713          	addi	a4,a4,1288 # 80011830 <cons>
    80000330:	0a072783          	lw	a5,160(a4)
    80000334:	09872703          	lw	a4,152(a4)
    80000338:	9f99                	subw	a5,a5,a4
    8000033a:	07f00713          	li	a4,127
    8000033e:	fcf763e3          	bltu	a4,a5,80000304 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000342:	47b5                	li	a5,13
    80000344:	0cf48763          	beq	s1,a5,80000412 <consoleintr+0x14a>
      consputc(c);
    80000348:	8526                	mv	a0,s1
    8000034a:	00000097          	auipc	ra,0x0
    8000034e:	f3c080e7          	jalr	-196(ra) # 80000286 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000352:	00011797          	auipc	a5,0x11
    80000356:	4de78793          	addi	a5,a5,1246 # 80011830 <cons>
    8000035a:	0a07a703          	lw	a4,160(a5)
    8000035e:	0017069b          	addiw	a3,a4,1
    80000362:	0006861b          	sext.w	a2,a3
    80000366:	0ad7a023          	sw	a3,160(a5)
    8000036a:	07f77713          	andi	a4,a4,127
    8000036e:	97ba                	add	a5,a5,a4
    80000370:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000374:	47a9                	li	a5,10
    80000376:	0cf48563          	beq	s1,a5,80000440 <consoleintr+0x178>
    8000037a:	4791                	li	a5,4
    8000037c:	0cf48263          	beq	s1,a5,80000440 <consoleintr+0x178>
    80000380:	00011797          	auipc	a5,0x11
    80000384:	5487a783          	lw	a5,1352(a5) # 800118c8 <cons+0x98>
    80000388:	0807879b          	addiw	a5,a5,128
    8000038c:	f6f61ce3          	bne	a2,a5,80000304 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000390:	863e                	mv	a2,a5
    80000392:	a07d                	j	80000440 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000394:	00011717          	auipc	a4,0x11
    80000398:	49c70713          	addi	a4,a4,1180 # 80011830 <cons>
    8000039c:	0a072783          	lw	a5,160(a4)
    800003a0:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003a4:	00011497          	auipc	s1,0x11
    800003a8:	48c48493          	addi	s1,s1,1164 # 80011830 <cons>
    while(cons.e != cons.w &&
    800003ac:	4929                	li	s2,10
    800003ae:	f4f70be3          	beq	a4,a5,80000304 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003b2:	37fd                	addiw	a5,a5,-1
    800003b4:	07f7f713          	andi	a4,a5,127
    800003b8:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003ba:	01874703          	lbu	a4,24(a4)
    800003be:	f52703e3          	beq	a4,s2,80000304 <consoleintr+0x3c>
      cons.e--;
    800003c2:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003c6:	10000513          	li	a0,256
    800003ca:	00000097          	auipc	ra,0x0
    800003ce:	ebc080e7          	jalr	-324(ra) # 80000286 <consputc>
    while(cons.e != cons.w &&
    800003d2:	0a04a783          	lw	a5,160(s1)
    800003d6:	09c4a703          	lw	a4,156(s1)
    800003da:	fcf71ce3          	bne	a4,a5,800003b2 <consoleintr+0xea>
    800003de:	b71d                	j	80000304 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003e0:	00011717          	auipc	a4,0x11
    800003e4:	45070713          	addi	a4,a4,1104 # 80011830 <cons>
    800003e8:	0a072783          	lw	a5,160(a4)
    800003ec:	09c72703          	lw	a4,156(a4)
    800003f0:	f0f70ae3          	beq	a4,a5,80000304 <consoleintr+0x3c>
      cons.e--;
    800003f4:	37fd                	addiw	a5,a5,-1
    800003f6:	00011717          	auipc	a4,0x11
    800003fa:	4cf72d23          	sw	a5,1242(a4) # 800118d0 <cons+0xa0>
      consputc(BACKSPACE);
    800003fe:	10000513          	li	a0,256
    80000402:	00000097          	auipc	ra,0x0
    80000406:	e84080e7          	jalr	-380(ra) # 80000286 <consputc>
    8000040a:	bded                	j	80000304 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000040c:	ee048ce3          	beqz	s1,80000304 <consoleintr+0x3c>
    80000410:	bf21                	j	80000328 <consoleintr+0x60>
      consputc(c);
    80000412:	4529                	li	a0,10
    80000414:	00000097          	auipc	ra,0x0
    80000418:	e72080e7          	jalr	-398(ra) # 80000286 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000041c:	00011797          	auipc	a5,0x11
    80000420:	41478793          	addi	a5,a5,1044 # 80011830 <cons>
    80000424:	0a07a703          	lw	a4,160(a5)
    80000428:	0017069b          	addiw	a3,a4,1
    8000042c:	0006861b          	sext.w	a2,a3
    80000430:	0ad7a023          	sw	a3,160(a5)
    80000434:	07f77713          	andi	a4,a4,127
    80000438:	97ba                	add	a5,a5,a4
    8000043a:	4729                	li	a4,10
    8000043c:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000440:	00011797          	auipc	a5,0x11
    80000444:	48c7a623          	sw	a2,1164(a5) # 800118cc <cons+0x9c>
        wakeup(&cons.r);
    80000448:	00011517          	auipc	a0,0x11
    8000044c:	48050513          	addi	a0,a0,1152 # 800118c8 <cons+0x98>
    80000450:	00002097          	auipc	ra,0x2
    80000454:	170080e7          	jalr	368(ra) # 800025c0 <wakeup>
    80000458:	b575                	j	80000304 <consoleintr+0x3c>

000000008000045a <consoleinit>:

void
consoleinit(void)
{
    8000045a:	1141                	addi	sp,sp,-16
    8000045c:	e406                	sd	ra,8(sp)
    8000045e:	e022                	sd	s0,0(sp)
    80000460:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000462:	00008597          	auipc	a1,0x8
    80000466:	b9e58593          	addi	a1,a1,-1122 # 80008000 <etext>
    8000046a:	00011517          	auipc	a0,0x11
    8000046e:	3c650513          	addi	a0,a0,966 # 80011830 <cons>
    80000472:	00000097          	auipc	ra,0x0
    80000476:	728080e7          	jalr	1832(ra) # 80000b9a <initlock>

  uartinit();
    8000047a:	00000097          	auipc	ra,0x0
    8000047e:	330080e7          	jalr	816(ra) # 800007aa <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000482:	00021797          	auipc	a5,0x21
    80000486:	72e78793          	addi	a5,a5,1838 # 80021bb0 <devsw>
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	ce470713          	addi	a4,a4,-796 # 8000016e <consoleread>
    80000492:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000494:	00000717          	auipc	a4,0x0
    80000498:	c5870713          	addi	a4,a4,-936 # 800000ec <consolewrite>
    8000049c:	ef98                	sd	a4,24(a5)
}
    8000049e:	60a2                	ld	ra,8(sp)
    800004a0:	6402                	ld	s0,0(sp)
    800004a2:	0141                	addi	sp,sp,16
    800004a4:	8082                	ret

00000000800004a6 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004a6:	7179                	addi	sp,sp,-48
    800004a8:	f406                	sd	ra,40(sp)
    800004aa:	f022                	sd	s0,32(sp)
    800004ac:	ec26                	sd	s1,24(sp)
    800004ae:	e84a                	sd	s2,16(sp)
    800004b0:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004b2:	c219                	beqz	a2,800004b8 <printint+0x12>
    800004b4:	08054663          	bltz	a0,80000540 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004b8:	2501                	sext.w	a0,a0
    800004ba:	4881                	li	a7,0
    800004bc:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004c0:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004c2:	2581                	sext.w	a1,a1
    800004c4:	00008617          	auipc	a2,0x8
    800004c8:	b6c60613          	addi	a2,a2,-1172 # 80008030 <digits>
    800004cc:	883a                	mv	a6,a4
    800004ce:	2705                	addiw	a4,a4,1
    800004d0:	02b577bb          	remuw	a5,a0,a1
    800004d4:	1782                	slli	a5,a5,0x20
    800004d6:	9381                	srli	a5,a5,0x20
    800004d8:	97b2                	add	a5,a5,a2
    800004da:	0007c783          	lbu	a5,0(a5)
    800004de:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004e2:	0005079b          	sext.w	a5,a0
    800004e6:	02b5553b          	divuw	a0,a0,a1
    800004ea:	0685                	addi	a3,a3,1
    800004ec:	feb7f0e3          	bgeu	a5,a1,800004cc <printint+0x26>

  if(sign)
    800004f0:	00088b63          	beqz	a7,80000506 <printint+0x60>
    buf[i++] = '-';
    800004f4:	fe040793          	addi	a5,s0,-32
    800004f8:	973e                	add	a4,a4,a5
    800004fa:	02d00793          	li	a5,45
    800004fe:	fef70823          	sb	a5,-16(a4)
    80000502:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    80000506:	02e05763          	blez	a4,80000534 <printint+0x8e>
    8000050a:	fd040793          	addi	a5,s0,-48
    8000050e:	00e784b3          	add	s1,a5,a4
    80000512:	fff78913          	addi	s2,a5,-1
    80000516:	993a                	add	s2,s2,a4
    80000518:	377d                	addiw	a4,a4,-1
    8000051a:	1702                	slli	a4,a4,0x20
    8000051c:	9301                	srli	a4,a4,0x20
    8000051e:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000522:	fff4c503          	lbu	a0,-1(s1)
    80000526:	00000097          	auipc	ra,0x0
    8000052a:	d60080e7          	jalr	-672(ra) # 80000286 <consputc>
  while(--i >= 0)
    8000052e:	14fd                	addi	s1,s1,-1
    80000530:	ff2499e3          	bne	s1,s2,80000522 <printint+0x7c>
}
    80000534:	70a2                	ld	ra,40(sp)
    80000536:	7402                	ld	s0,32(sp)
    80000538:	64e2                	ld	s1,24(sp)
    8000053a:	6942                	ld	s2,16(sp)
    8000053c:	6145                	addi	sp,sp,48
    8000053e:	8082                	ret
    x = -xx;
    80000540:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000544:	4885                	li	a7,1
    x = -xx;
    80000546:	bf9d                	j	800004bc <printint+0x16>

0000000080000548 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000548:	1101                	addi	sp,sp,-32
    8000054a:	ec06                	sd	ra,24(sp)
    8000054c:	e822                	sd	s0,16(sp)
    8000054e:	e426                	sd	s1,8(sp)
    80000550:	1000                	addi	s0,sp,32
    80000552:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000554:	00011797          	auipc	a5,0x11
    80000558:	3807ae23          	sw	zero,924(a5) # 800118f0 <pr+0x18>
  printf("panic: ");
    8000055c:	00008517          	auipc	a0,0x8
    80000560:	aac50513          	addi	a0,a0,-1364 # 80008008 <etext+0x8>
    80000564:	00000097          	auipc	ra,0x0
    80000568:	02e080e7          	jalr	46(ra) # 80000592 <printf>
  printf(s);
    8000056c:	8526                	mv	a0,s1
    8000056e:	00000097          	auipc	ra,0x0
    80000572:	024080e7          	jalr	36(ra) # 80000592 <printf>
  printf("\n");
    80000576:	00008517          	auipc	a0,0x8
    8000057a:	b5250513          	addi	a0,a0,-1198 # 800080c8 <digits+0x98>
    8000057e:	00000097          	auipc	ra,0x0
    80000582:	014080e7          	jalr	20(ra) # 80000592 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000586:	4785                	li	a5,1
    80000588:	00009717          	auipc	a4,0x9
    8000058c:	a6f72c23          	sw	a5,-1416(a4) # 80009000 <panicked>
  for(;;)
    80000590:	a001                	j	80000590 <panic+0x48>

0000000080000592 <printf>:
{
    80000592:	7131                	addi	sp,sp,-192
    80000594:	fc86                	sd	ra,120(sp)
    80000596:	f8a2                	sd	s0,112(sp)
    80000598:	f4a6                	sd	s1,104(sp)
    8000059a:	f0ca                	sd	s2,96(sp)
    8000059c:	ecce                	sd	s3,88(sp)
    8000059e:	e8d2                	sd	s4,80(sp)
    800005a0:	e4d6                	sd	s5,72(sp)
    800005a2:	e0da                	sd	s6,64(sp)
    800005a4:	fc5e                	sd	s7,56(sp)
    800005a6:	f862                	sd	s8,48(sp)
    800005a8:	f466                	sd	s9,40(sp)
    800005aa:	f06a                	sd	s10,32(sp)
    800005ac:	ec6e                	sd	s11,24(sp)
    800005ae:	0100                	addi	s0,sp,128
    800005b0:	8a2a                	mv	s4,a0
    800005b2:	e40c                	sd	a1,8(s0)
    800005b4:	e810                	sd	a2,16(s0)
    800005b6:	ec14                	sd	a3,24(s0)
    800005b8:	f018                	sd	a4,32(s0)
    800005ba:	f41c                	sd	a5,40(s0)
    800005bc:	03043823          	sd	a6,48(s0)
    800005c0:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005c4:	00011d97          	auipc	s11,0x11
    800005c8:	32cdad83          	lw	s11,812(s11) # 800118f0 <pr+0x18>
  if(locking)
    800005cc:	020d9b63          	bnez	s11,80000602 <printf+0x70>
  if (fmt == 0)
    800005d0:	040a0263          	beqz	s4,80000614 <printf+0x82>
  va_start(ap, fmt);
    800005d4:	00840793          	addi	a5,s0,8
    800005d8:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005dc:	000a4503          	lbu	a0,0(s4)
    800005e0:	16050263          	beqz	a0,80000744 <printf+0x1b2>
    800005e4:	4481                	li	s1,0
    if(c != '%'){
    800005e6:	02500a93          	li	s5,37
    switch(c){
    800005ea:	07000b13          	li	s6,112
  consputc('x');
    800005ee:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005f0:	00008b97          	auipc	s7,0x8
    800005f4:	a40b8b93          	addi	s7,s7,-1472 # 80008030 <digits>
    switch(c){
    800005f8:	07300c93          	li	s9,115
    800005fc:	06400c13          	li	s8,100
    80000600:	a82d                	j	8000063a <printf+0xa8>
    acquire(&pr.lock);
    80000602:	00011517          	auipc	a0,0x11
    80000606:	2d650513          	addi	a0,a0,726 # 800118d8 <pr>
    8000060a:	00000097          	auipc	ra,0x0
    8000060e:	620080e7          	jalr	1568(ra) # 80000c2a <acquire>
    80000612:	bf7d                	j	800005d0 <printf+0x3e>
    panic("null fmt");
    80000614:	00008517          	auipc	a0,0x8
    80000618:	a0450513          	addi	a0,a0,-1532 # 80008018 <etext+0x18>
    8000061c:	00000097          	auipc	ra,0x0
    80000620:	f2c080e7          	jalr	-212(ra) # 80000548 <panic>
      consputc(c);
    80000624:	00000097          	auipc	ra,0x0
    80000628:	c62080e7          	jalr	-926(ra) # 80000286 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    8000062c:	2485                	addiw	s1,s1,1
    8000062e:	009a07b3          	add	a5,s4,s1
    80000632:	0007c503          	lbu	a0,0(a5)
    80000636:	10050763          	beqz	a0,80000744 <printf+0x1b2>
    if(c != '%'){
    8000063a:	ff5515e3          	bne	a0,s5,80000624 <printf+0x92>
    c = fmt[++i] & 0xff;
    8000063e:	2485                	addiw	s1,s1,1
    80000640:	009a07b3          	add	a5,s4,s1
    80000644:	0007c783          	lbu	a5,0(a5)
    80000648:	0007891b          	sext.w	s2,a5
    if(c == 0)
    8000064c:	cfe5                	beqz	a5,80000744 <printf+0x1b2>
    switch(c){
    8000064e:	05678a63          	beq	a5,s6,800006a2 <printf+0x110>
    80000652:	02fb7663          	bgeu	s6,a5,8000067e <printf+0xec>
    80000656:	09978963          	beq	a5,s9,800006e8 <printf+0x156>
    8000065a:	07800713          	li	a4,120
    8000065e:	0ce79863          	bne	a5,a4,8000072e <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    80000662:	f8843783          	ld	a5,-120(s0)
    80000666:	00878713          	addi	a4,a5,8
    8000066a:	f8e43423          	sd	a4,-120(s0)
    8000066e:	4605                	li	a2,1
    80000670:	85ea                	mv	a1,s10
    80000672:	4388                	lw	a0,0(a5)
    80000674:	00000097          	auipc	ra,0x0
    80000678:	e32080e7          	jalr	-462(ra) # 800004a6 <printint>
      break;
    8000067c:	bf45                	j	8000062c <printf+0x9a>
    switch(c){
    8000067e:	0b578263          	beq	a5,s5,80000722 <printf+0x190>
    80000682:	0b879663          	bne	a5,s8,8000072e <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    80000686:	f8843783          	ld	a5,-120(s0)
    8000068a:	00878713          	addi	a4,a5,8
    8000068e:	f8e43423          	sd	a4,-120(s0)
    80000692:	4605                	li	a2,1
    80000694:	45a9                	li	a1,10
    80000696:	4388                	lw	a0,0(a5)
    80000698:	00000097          	auipc	ra,0x0
    8000069c:	e0e080e7          	jalr	-498(ra) # 800004a6 <printint>
      break;
    800006a0:	b771                	j	8000062c <printf+0x9a>
      printptr(va_arg(ap, uint64));
    800006a2:	f8843783          	ld	a5,-120(s0)
    800006a6:	00878713          	addi	a4,a5,8
    800006aa:	f8e43423          	sd	a4,-120(s0)
    800006ae:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006b2:	03000513          	li	a0,48
    800006b6:	00000097          	auipc	ra,0x0
    800006ba:	bd0080e7          	jalr	-1072(ra) # 80000286 <consputc>
  consputc('x');
    800006be:	07800513          	li	a0,120
    800006c2:	00000097          	auipc	ra,0x0
    800006c6:	bc4080e7          	jalr	-1084(ra) # 80000286 <consputc>
    800006ca:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006cc:	03c9d793          	srli	a5,s3,0x3c
    800006d0:	97de                	add	a5,a5,s7
    800006d2:	0007c503          	lbu	a0,0(a5)
    800006d6:	00000097          	auipc	ra,0x0
    800006da:	bb0080e7          	jalr	-1104(ra) # 80000286 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006de:	0992                	slli	s3,s3,0x4
    800006e0:	397d                	addiw	s2,s2,-1
    800006e2:	fe0915e3          	bnez	s2,800006cc <printf+0x13a>
    800006e6:	b799                	j	8000062c <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006e8:	f8843783          	ld	a5,-120(s0)
    800006ec:	00878713          	addi	a4,a5,8
    800006f0:	f8e43423          	sd	a4,-120(s0)
    800006f4:	0007b903          	ld	s2,0(a5)
    800006f8:	00090e63          	beqz	s2,80000714 <printf+0x182>
      for(; *s; s++)
    800006fc:	00094503          	lbu	a0,0(s2)
    80000700:	d515                	beqz	a0,8000062c <printf+0x9a>
        consputc(*s);
    80000702:	00000097          	auipc	ra,0x0
    80000706:	b84080e7          	jalr	-1148(ra) # 80000286 <consputc>
      for(; *s; s++)
    8000070a:	0905                	addi	s2,s2,1
    8000070c:	00094503          	lbu	a0,0(s2)
    80000710:	f96d                	bnez	a0,80000702 <printf+0x170>
    80000712:	bf29                	j	8000062c <printf+0x9a>
        s = "(null)";
    80000714:	00008917          	auipc	s2,0x8
    80000718:	8fc90913          	addi	s2,s2,-1796 # 80008010 <etext+0x10>
      for(; *s; s++)
    8000071c:	02800513          	li	a0,40
    80000720:	b7cd                	j	80000702 <printf+0x170>
      consputc('%');
    80000722:	8556                	mv	a0,s5
    80000724:	00000097          	auipc	ra,0x0
    80000728:	b62080e7          	jalr	-1182(ra) # 80000286 <consputc>
      break;
    8000072c:	b701                	j	8000062c <printf+0x9a>
      consputc('%');
    8000072e:	8556                	mv	a0,s5
    80000730:	00000097          	auipc	ra,0x0
    80000734:	b56080e7          	jalr	-1194(ra) # 80000286 <consputc>
      consputc(c);
    80000738:	854a                	mv	a0,s2
    8000073a:	00000097          	auipc	ra,0x0
    8000073e:	b4c080e7          	jalr	-1204(ra) # 80000286 <consputc>
      break;
    80000742:	b5ed                	j	8000062c <printf+0x9a>
  if(locking)
    80000744:	020d9163          	bnez	s11,80000766 <printf+0x1d4>
}
    80000748:	70e6                	ld	ra,120(sp)
    8000074a:	7446                	ld	s0,112(sp)
    8000074c:	74a6                	ld	s1,104(sp)
    8000074e:	7906                	ld	s2,96(sp)
    80000750:	69e6                	ld	s3,88(sp)
    80000752:	6a46                	ld	s4,80(sp)
    80000754:	6aa6                	ld	s5,72(sp)
    80000756:	6b06                	ld	s6,64(sp)
    80000758:	7be2                	ld	s7,56(sp)
    8000075a:	7c42                	ld	s8,48(sp)
    8000075c:	7ca2                	ld	s9,40(sp)
    8000075e:	7d02                	ld	s10,32(sp)
    80000760:	6de2                	ld	s11,24(sp)
    80000762:	6129                	addi	sp,sp,192
    80000764:	8082                	ret
    release(&pr.lock);
    80000766:	00011517          	auipc	a0,0x11
    8000076a:	17250513          	addi	a0,a0,370 # 800118d8 <pr>
    8000076e:	00000097          	auipc	ra,0x0
    80000772:	570080e7          	jalr	1392(ra) # 80000cde <release>
}
    80000776:	bfc9                	j	80000748 <printf+0x1b6>

0000000080000778 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000778:	1101                	addi	sp,sp,-32
    8000077a:	ec06                	sd	ra,24(sp)
    8000077c:	e822                	sd	s0,16(sp)
    8000077e:	e426                	sd	s1,8(sp)
    80000780:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000782:	00011497          	auipc	s1,0x11
    80000786:	15648493          	addi	s1,s1,342 # 800118d8 <pr>
    8000078a:	00008597          	auipc	a1,0x8
    8000078e:	89e58593          	addi	a1,a1,-1890 # 80008028 <etext+0x28>
    80000792:	8526                	mv	a0,s1
    80000794:	00000097          	auipc	ra,0x0
    80000798:	406080e7          	jalr	1030(ra) # 80000b9a <initlock>
  pr.locking = 1;
    8000079c:	4785                	li	a5,1
    8000079e:	cc9c                	sw	a5,24(s1)
}
    800007a0:	60e2                	ld	ra,24(sp)
    800007a2:	6442                	ld	s0,16(sp)
    800007a4:	64a2                	ld	s1,8(sp)
    800007a6:	6105                	addi	sp,sp,32
    800007a8:	8082                	ret

00000000800007aa <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007aa:	1141                	addi	sp,sp,-16
    800007ac:	e406                	sd	ra,8(sp)
    800007ae:	e022                	sd	s0,0(sp)
    800007b0:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007b2:	100007b7          	lui	a5,0x10000
    800007b6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007ba:	f8000713          	li	a4,-128
    800007be:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007c2:	470d                	li	a4,3
    800007c4:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007c8:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007cc:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007d0:	469d                	li	a3,7
    800007d2:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007d6:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007da:	00008597          	auipc	a1,0x8
    800007de:	86e58593          	addi	a1,a1,-1938 # 80008048 <digits+0x18>
    800007e2:	00011517          	auipc	a0,0x11
    800007e6:	11650513          	addi	a0,a0,278 # 800118f8 <uart_tx_lock>
    800007ea:	00000097          	auipc	ra,0x0
    800007ee:	3b0080e7          	jalr	944(ra) # 80000b9a <initlock>
}
    800007f2:	60a2                	ld	ra,8(sp)
    800007f4:	6402                	ld	s0,0(sp)
    800007f6:	0141                	addi	sp,sp,16
    800007f8:	8082                	ret

00000000800007fa <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007fa:	1101                	addi	sp,sp,-32
    800007fc:	ec06                	sd	ra,24(sp)
    800007fe:	e822                	sd	s0,16(sp)
    80000800:	e426                	sd	s1,8(sp)
    80000802:	1000                	addi	s0,sp,32
    80000804:	84aa                	mv	s1,a0
  push_off();
    80000806:	00000097          	auipc	ra,0x0
    8000080a:	3d8080e7          	jalr	984(ra) # 80000bde <push_off>

  if(panicked){
    8000080e:	00008797          	auipc	a5,0x8
    80000812:	7f27a783          	lw	a5,2034(a5) # 80009000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000816:	10000737          	lui	a4,0x10000
  if(panicked){
    8000081a:	c391                	beqz	a5,8000081e <uartputc_sync+0x24>
    for(;;)
    8000081c:	a001                	j	8000081c <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000081e:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000822:	0ff7f793          	andi	a5,a5,255
    80000826:	0207f793          	andi	a5,a5,32
    8000082a:	dbf5                	beqz	a5,8000081e <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000082c:	0ff4f793          	andi	a5,s1,255
    80000830:	10000737          	lui	a4,0x10000
    80000834:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    80000838:	00000097          	auipc	ra,0x0
    8000083c:	446080e7          	jalr	1094(ra) # 80000c7e <pop_off>
}
    80000840:	60e2                	ld	ra,24(sp)
    80000842:	6442                	ld	s0,16(sp)
    80000844:	64a2                	ld	s1,8(sp)
    80000846:	6105                	addi	sp,sp,32
    80000848:	8082                	ret

000000008000084a <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000084a:	00008797          	auipc	a5,0x8
    8000084e:	7ba7a783          	lw	a5,1978(a5) # 80009004 <uart_tx_r>
    80000852:	00008717          	auipc	a4,0x8
    80000856:	7b672703          	lw	a4,1974(a4) # 80009008 <uart_tx_w>
    8000085a:	08f70263          	beq	a4,a5,800008de <uartstart+0x94>
{
    8000085e:	7139                	addi	sp,sp,-64
    80000860:	fc06                	sd	ra,56(sp)
    80000862:	f822                	sd	s0,48(sp)
    80000864:	f426                	sd	s1,40(sp)
    80000866:	f04a                	sd	s2,32(sp)
    80000868:	ec4e                	sd	s3,24(sp)
    8000086a:	e852                	sd	s4,16(sp)
    8000086c:	e456                	sd	s5,8(sp)
    8000086e:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000870:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r];
    80000874:	00011a17          	auipc	s4,0x11
    80000878:	084a0a13          	addi	s4,s4,132 # 800118f8 <uart_tx_lock>
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    8000087c:	00008497          	auipc	s1,0x8
    80000880:	78848493          	addi	s1,s1,1928 # 80009004 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000884:	00008997          	auipc	s3,0x8
    80000888:	78498993          	addi	s3,s3,1924 # 80009008 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000088c:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000890:	0ff77713          	andi	a4,a4,255
    80000894:	02077713          	andi	a4,a4,32
    80000898:	cb15                	beqz	a4,800008cc <uartstart+0x82>
    int c = uart_tx_buf[uart_tx_r];
    8000089a:	00fa0733          	add	a4,s4,a5
    8000089e:	01874a83          	lbu	s5,24(a4)
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    800008a2:	2785                	addiw	a5,a5,1
    800008a4:	41f7d71b          	sraiw	a4,a5,0x1f
    800008a8:	01b7571b          	srliw	a4,a4,0x1b
    800008ac:	9fb9                	addw	a5,a5,a4
    800008ae:	8bfd                	andi	a5,a5,31
    800008b0:	9f99                	subw	a5,a5,a4
    800008b2:	c09c                	sw	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    800008b4:	8526                	mv	a0,s1
    800008b6:	00002097          	auipc	ra,0x2
    800008ba:	d0a080e7          	jalr	-758(ra) # 800025c0 <wakeup>
    
    WriteReg(THR, c);
    800008be:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008c2:	409c                	lw	a5,0(s1)
    800008c4:	0009a703          	lw	a4,0(s3)
    800008c8:	fcf712e3          	bne	a4,a5,8000088c <uartstart+0x42>
  }
}
    800008cc:	70e2                	ld	ra,56(sp)
    800008ce:	7442                	ld	s0,48(sp)
    800008d0:	74a2                	ld	s1,40(sp)
    800008d2:	7902                	ld	s2,32(sp)
    800008d4:	69e2                	ld	s3,24(sp)
    800008d6:	6a42                	ld	s4,16(sp)
    800008d8:	6aa2                	ld	s5,8(sp)
    800008da:	6121                	addi	sp,sp,64
    800008dc:	8082                	ret
    800008de:	8082                	ret

00000000800008e0 <uartputc>:
{
    800008e0:	7179                	addi	sp,sp,-48
    800008e2:	f406                	sd	ra,40(sp)
    800008e4:	f022                	sd	s0,32(sp)
    800008e6:	ec26                	sd	s1,24(sp)
    800008e8:	e84a                	sd	s2,16(sp)
    800008ea:	e44e                	sd	s3,8(sp)
    800008ec:	e052                	sd	s4,0(sp)
    800008ee:	1800                	addi	s0,sp,48
    800008f0:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    800008f2:	00011517          	auipc	a0,0x11
    800008f6:	00650513          	addi	a0,a0,6 # 800118f8 <uart_tx_lock>
    800008fa:	00000097          	auipc	ra,0x0
    800008fe:	330080e7          	jalr	816(ra) # 80000c2a <acquire>
  if(panicked){
    80000902:	00008797          	auipc	a5,0x8
    80000906:	6fe7a783          	lw	a5,1790(a5) # 80009000 <panicked>
    8000090a:	c391                	beqz	a5,8000090e <uartputc+0x2e>
    for(;;)
    8000090c:	a001                	j	8000090c <uartputc+0x2c>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    8000090e:	00008717          	auipc	a4,0x8
    80000912:	6fa72703          	lw	a4,1786(a4) # 80009008 <uart_tx_w>
    80000916:	0017079b          	addiw	a5,a4,1
    8000091a:	41f7d69b          	sraiw	a3,a5,0x1f
    8000091e:	01b6d69b          	srliw	a3,a3,0x1b
    80000922:	9fb5                	addw	a5,a5,a3
    80000924:	8bfd                	andi	a5,a5,31
    80000926:	9f95                	subw	a5,a5,a3
    80000928:	00008697          	auipc	a3,0x8
    8000092c:	6dc6a683          	lw	a3,1756(a3) # 80009004 <uart_tx_r>
    80000930:	04f69263          	bne	a3,a5,80000974 <uartputc+0x94>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000934:	00011a17          	auipc	s4,0x11
    80000938:	fc4a0a13          	addi	s4,s4,-60 # 800118f8 <uart_tx_lock>
    8000093c:	00008497          	auipc	s1,0x8
    80000940:	6c848493          	addi	s1,s1,1736 # 80009004 <uart_tx_r>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000944:	00008917          	auipc	s2,0x8
    80000948:	6c490913          	addi	s2,s2,1732 # 80009008 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    8000094c:	85d2                	mv	a1,s4
    8000094e:	8526                	mv	a0,s1
    80000950:	00002097          	auipc	ra,0x2
    80000954:	aea080e7          	jalr	-1302(ra) # 8000243a <sleep>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000958:	00092703          	lw	a4,0(s2)
    8000095c:	0017079b          	addiw	a5,a4,1
    80000960:	41f7d69b          	sraiw	a3,a5,0x1f
    80000964:	01b6d69b          	srliw	a3,a3,0x1b
    80000968:	9fb5                	addw	a5,a5,a3
    8000096a:	8bfd                	andi	a5,a5,31
    8000096c:	9f95                	subw	a5,a5,a3
    8000096e:	4094                	lw	a3,0(s1)
    80000970:	fcf68ee3          	beq	a3,a5,8000094c <uartputc+0x6c>
      uart_tx_buf[uart_tx_w] = c;
    80000974:	00011497          	auipc	s1,0x11
    80000978:	f8448493          	addi	s1,s1,-124 # 800118f8 <uart_tx_lock>
    8000097c:	9726                	add	a4,a4,s1
    8000097e:	01370c23          	sb	s3,24(a4)
      uart_tx_w = (uart_tx_w + 1) % UART_TX_BUF_SIZE;
    80000982:	00008717          	auipc	a4,0x8
    80000986:	68f72323          	sw	a5,1670(a4) # 80009008 <uart_tx_w>
      uartstart();
    8000098a:	00000097          	auipc	ra,0x0
    8000098e:	ec0080e7          	jalr	-320(ra) # 8000084a <uartstart>
      release(&uart_tx_lock);
    80000992:	8526                	mv	a0,s1
    80000994:	00000097          	auipc	ra,0x0
    80000998:	34a080e7          	jalr	842(ra) # 80000cde <release>
}
    8000099c:	70a2                	ld	ra,40(sp)
    8000099e:	7402                	ld	s0,32(sp)
    800009a0:	64e2                	ld	s1,24(sp)
    800009a2:	6942                	ld	s2,16(sp)
    800009a4:	69a2                	ld	s3,8(sp)
    800009a6:	6a02                	ld	s4,0(sp)
    800009a8:	6145                	addi	sp,sp,48
    800009aa:	8082                	ret

00000000800009ac <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009ac:	1141                	addi	sp,sp,-16
    800009ae:	e422                	sd	s0,8(sp)
    800009b0:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009b2:	100007b7          	lui	a5,0x10000
    800009b6:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009ba:	8b85                	andi	a5,a5,1
    800009bc:	cb91                	beqz	a5,800009d0 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800009be:	100007b7          	lui	a5,0x10000
    800009c2:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    800009c6:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    800009ca:	6422                	ld	s0,8(sp)
    800009cc:	0141                	addi	sp,sp,16
    800009ce:	8082                	ret
    return -1;
    800009d0:	557d                	li	a0,-1
    800009d2:	bfe5                	j	800009ca <uartgetc+0x1e>

00000000800009d4 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    800009d4:	1101                	addi	sp,sp,-32
    800009d6:	ec06                	sd	ra,24(sp)
    800009d8:	e822                	sd	s0,16(sp)
    800009da:	e426                	sd	s1,8(sp)
    800009dc:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009de:	54fd                	li	s1,-1
    int c = uartgetc();
    800009e0:	00000097          	auipc	ra,0x0
    800009e4:	fcc080e7          	jalr	-52(ra) # 800009ac <uartgetc>
    if(c == -1)
    800009e8:	00950763          	beq	a0,s1,800009f6 <uartintr+0x22>
      break;
    consoleintr(c);
    800009ec:	00000097          	auipc	ra,0x0
    800009f0:	8dc080e7          	jalr	-1828(ra) # 800002c8 <consoleintr>
  while(1){
    800009f4:	b7f5                	j	800009e0 <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009f6:	00011497          	auipc	s1,0x11
    800009fa:	f0248493          	addi	s1,s1,-254 # 800118f8 <uart_tx_lock>
    800009fe:	8526                	mv	a0,s1
    80000a00:	00000097          	auipc	ra,0x0
    80000a04:	22a080e7          	jalr	554(ra) # 80000c2a <acquire>
  uartstart();
    80000a08:	00000097          	auipc	ra,0x0
    80000a0c:	e42080e7          	jalr	-446(ra) # 8000084a <uartstart>
  release(&uart_tx_lock);
    80000a10:	8526                	mv	a0,s1
    80000a12:	00000097          	auipc	ra,0x0
    80000a16:	2cc080e7          	jalr	716(ra) # 80000cde <release>
}
    80000a1a:	60e2                	ld	ra,24(sp)
    80000a1c:	6442                	ld	s0,16(sp)
    80000a1e:	64a2                	ld	s1,8(sp)
    80000a20:	6105                	addi	sp,sp,32
    80000a22:	8082                	ret

0000000080000a24 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a24:	1101                	addi	sp,sp,-32
    80000a26:	ec06                	sd	ra,24(sp)
    80000a28:	e822                	sd	s0,16(sp)
    80000a2a:	e426                	sd	s1,8(sp)
    80000a2c:	e04a                	sd	s2,0(sp)
    80000a2e:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a30:	03451793          	slli	a5,a0,0x34
    80000a34:	ebb9                	bnez	a5,80000a8a <kfree+0x66>
    80000a36:	84aa                	mv	s1,a0
    80000a38:	00026797          	auipc	a5,0x26
    80000a3c:	5e878793          	addi	a5,a5,1512 # 80027020 <end>
    80000a40:	04f56563          	bltu	a0,a5,80000a8a <kfree+0x66>
    80000a44:	47c5                	li	a5,17
    80000a46:	07ee                	slli	a5,a5,0x1b
    80000a48:	04f57163          	bgeu	a0,a5,80000a8a <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a4c:	6605                	lui	a2,0x1
    80000a4e:	4585                	li	a1,1
    80000a50:	00000097          	auipc	ra,0x0
    80000a54:	2d6080e7          	jalr	726(ra) # 80000d26 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a58:	00011917          	auipc	s2,0x11
    80000a5c:	ed890913          	addi	s2,s2,-296 # 80011930 <kmem>
    80000a60:	854a                	mv	a0,s2
    80000a62:	00000097          	auipc	ra,0x0
    80000a66:	1c8080e7          	jalr	456(ra) # 80000c2a <acquire>
  r->next = kmem.freelist;
    80000a6a:	01893783          	ld	a5,24(s2)
    80000a6e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a70:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a74:	854a                	mv	a0,s2
    80000a76:	00000097          	auipc	ra,0x0
    80000a7a:	268080e7          	jalr	616(ra) # 80000cde <release>
}
    80000a7e:	60e2                	ld	ra,24(sp)
    80000a80:	6442                	ld	s0,16(sp)
    80000a82:	64a2                	ld	s1,8(sp)
    80000a84:	6902                	ld	s2,0(sp)
    80000a86:	6105                	addi	sp,sp,32
    80000a88:	8082                	ret
    panic("kfree");
    80000a8a:	00007517          	auipc	a0,0x7
    80000a8e:	5c650513          	addi	a0,a0,1478 # 80008050 <digits+0x20>
    80000a92:	00000097          	auipc	ra,0x0
    80000a96:	ab6080e7          	jalr	-1354(ra) # 80000548 <panic>

0000000080000a9a <freerange>:
{
    80000a9a:	7179                	addi	sp,sp,-48
    80000a9c:	f406                	sd	ra,40(sp)
    80000a9e:	f022                	sd	s0,32(sp)
    80000aa0:	ec26                	sd	s1,24(sp)
    80000aa2:	e84a                	sd	s2,16(sp)
    80000aa4:	e44e                	sd	s3,8(sp)
    80000aa6:	e052                	sd	s4,0(sp)
    80000aa8:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000aaa:	6785                	lui	a5,0x1
    80000aac:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000ab0:	94aa                	add	s1,s1,a0
    80000ab2:	757d                	lui	a0,0xfffff
    80000ab4:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ab6:	94be                	add	s1,s1,a5
    80000ab8:	0095ee63          	bltu	a1,s1,80000ad4 <freerange+0x3a>
    80000abc:	892e                	mv	s2,a1
    kfree(p);
    80000abe:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ac0:	6985                	lui	s3,0x1
    kfree(p);
    80000ac2:	01448533          	add	a0,s1,s4
    80000ac6:	00000097          	auipc	ra,0x0
    80000aca:	f5e080e7          	jalr	-162(ra) # 80000a24 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ace:	94ce                	add	s1,s1,s3
    80000ad0:	fe9979e3          	bgeu	s2,s1,80000ac2 <freerange+0x28>
}
    80000ad4:	70a2                	ld	ra,40(sp)
    80000ad6:	7402                	ld	s0,32(sp)
    80000ad8:	64e2                	ld	s1,24(sp)
    80000ada:	6942                	ld	s2,16(sp)
    80000adc:	69a2                	ld	s3,8(sp)
    80000ade:	6a02                	ld	s4,0(sp)
    80000ae0:	6145                	addi	sp,sp,48
    80000ae2:	8082                	ret

0000000080000ae4 <kinit>:
{
    80000ae4:	1101                	addi	sp,sp,-32
    80000ae6:	ec06                	sd	ra,24(sp)
    80000ae8:	e822                	sd	s0,16(sp)
    80000aea:	e426                	sd	s1,8(sp)
    80000aec:	1000                	addi	s0,sp,32
  initlock(&kmem.lock, "kmem");
    80000aee:	00007597          	auipc	a1,0x7
    80000af2:	56a58593          	addi	a1,a1,1386 # 80008058 <digits+0x28>
    80000af6:	00011517          	auipc	a0,0x11
    80000afa:	e3a50513          	addi	a0,a0,-454 # 80011930 <kmem>
    80000afe:	00000097          	auipc	ra,0x0
    80000b02:	09c080e7          	jalr	156(ra) # 80000b9a <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b06:	44c5                	li	s1,17
    80000b08:	01b49593          	slli	a1,s1,0x1b
    80000b0c:	00026517          	auipc	a0,0x26
    80000b10:	51450513          	addi	a0,a0,1300 # 80027020 <end>
    80000b14:	00000097          	auipc	ra,0x0
    80000b18:	f86080e7          	jalr	-122(ra) # 80000a9a <freerange>
  printf("PHYSTOP is %p\n", PHYSTOP);
    80000b1c:	01b49593          	slli	a1,s1,0x1b
    80000b20:	00007517          	auipc	a0,0x7
    80000b24:	54050513          	addi	a0,a0,1344 # 80008060 <digits+0x30>
    80000b28:	00000097          	auipc	ra,0x0
    80000b2c:	a6a080e7          	jalr	-1430(ra) # 80000592 <printf>
}
    80000b30:	60e2                	ld	ra,24(sp)
    80000b32:	6442                	ld	s0,16(sp)
    80000b34:	64a2                	ld	s1,8(sp)
    80000b36:	6105                	addi	sp,sp,32
    80000b38:	8082                	ret

0000000080000b3a <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b3a:	1101                	addi	sp,sp,-32
    80000b3c:	ec06                	sd	ra,24(sp)
    80000b3e:	e822                	sd	s0,16(sp)
    80000b40:	e426                	sd	s1,8(sp)
    80000b42:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b44:	00011497          	auipc	s1,0x11
    80000b48:	dec48493          	addi	s1,s1,-532 # 80011930 <kmem>
    80000b4c:	8526                	mv	a0,s1
    80000b4e:	00000097          	auipc	ra,0x0
    80000b52:	0dc080e7          	jalr	220(ra) # 80000c2a <acquire>
  r = kmem.freelist;
    80000b56:	6c84                	ld	s1,24(s1)
  if(r)
    80000b58:	c885                	beqz	s1,80000b88 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b5a:	609c                	ld	a5,0(s1)
    80000b5c:	00011517          	auipc	a0,0x11
    80000b60:	dd450513          	addi	a0,a0,-556 # 80011930 <kmem>
    80000b64:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b66:	00000097          	auipc	ra,0x0
    80000b6a:	178080e7          	jalr	376(ra) # 80000cde <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b6e:	6605                	lui	a2,0x1
    80000b70:	4595                	li	a1,5
    80000b72:	8526                	mv	a0,s1
    80000b74:	00000097          	auipc	ra,0x0
    80000b78:	1b2080e7          	jalr	434(ra) # 80000d26 <memset>
  return (void*)r;
}
    80000b7c:	8526                	mv	a0,s1
    80000b7e:	60e2                	ld	ra,24(sp)
    80000b80:	6442                	ld	s0,16(sp)
    80000b82:	64a2                	ld	s1,8(sp)
    80000b84:	6105                	addi	sp,sp,32
    80000b86:	8082                	ret
  release(&kmem.lock);
    80000b88:	00011517          	auipc	a0,0x11
    80000b8c:	da850513          	addi	a0,a0,-600 # 80011930 <kmem>
    80000b90:	00000097          	auipc	ra,0x0
    80000b94:	14e080e7          	jalr	334(ra) # 80000cde <release>
  if(r)
    80000b98:	b7d5                	j	80000b7c <kalloc+0x42>

0000000080000b9a <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b9a:	1141                	addi	sp,sp,-16
    80000b9c:	e422                	sd	s0,8(sp)
    80000b9e:	0800                	addi	s0,sp,16
  lk->name = name;
    80000ba0:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000ba2:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000ba6:	00053823          	sd	zero,16(a0)
}
    80000baa:	6422                	ld	s0,8(sp)
    80000bac:	0141                	addi	sp,sp,16
    80000bae:	8082                	ret

0000000080000bb0 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bb0:	411c                	lw	a5,0(a0)
    80000bb2:	e399                	bnez	a5,80000bb8 <holding+0x8>
    80000bb4:	4501                	li	a0,0
  return r;
}
    80000bb6:	8082                	ret
{
    80000bb8:	1101                	addi	sp,sp,-32
    80000bba:	ec06                	sd	ra,24(sp)
    80000bbc:	e822                	sd	s0,16(sp)
    80000bbe:	e426                	sd	s1,8(sp)
    80000bc0:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000bc2:	6904                	ld	s1,16(a0)
    80000bc4:	00001097          	auipc	ra,0x1
    80000bc8:	f32080e7          	jalr	-206(ra) # 80001af6 <mycpu>
    80000bcc:	40a48533          	sub	a0,s1,a0
    80000bd0:	00153513          	seqz	a0,a0
}
    80000bd4:	60e2                	ld	ra,24(sp)
    80000bd6:	6442                	ld	s0,16(sp)
    80000bd8:	64a2                	ld	s1,8(sp)
    80000bda:	6105                	addi	sp,sp,32
    80000bdc:	8082                	ret

0000000080000bde <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bde:	1101                	addi	sp,sp,-32
    80000be0:	ec06                	sd	ra,24(sp)
    80000be2:	e822                	sd	s0,16(sp)
    80000be4:	e426                	sd	s1,8(sp)
    80000be6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000be8:	100024f3          	csrr	s1,sstatus
    80000bec:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bf0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bf2:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bf6:	00001097          	auipc	ra,0x1
    80000bfa:	f00080e7          	jalr	-256(ra) # 80001af6 <mycpu>
    80000bfe:	5d3c                	lw	a5,120(a0)
    80000c00:	cf89                	beqz	a5,80000c1a <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c02:	00001097          	auipc	ra,0x1
    80000c06:	ef4080e7          	jalr	-268(ra) # 80001af6 <mycpu>
    80000c0a:	5d3c                	lw	a5,120(a0)
    80000c0c:	2785                	addiw	a5,a5,1
    80000c0e:	dd3c                	sw	a5,120(a0)
}
    80000c10:	60e2                	ld	ra,24(sp)
    80000c12:	6442                	ld	s0,16(sp)
    80000c14:	64a2                	ld	s1,8(sp)
    80000c16:	6105                	addi	sp,sp,32
    80000c18:	8082                	ret
    mycpu()->intena = old;
    80000c1a:	00001097          	auipc	ra,0x1
    80000c1e:	edc080e7          	jalr	-292(ra) # 80001af6 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c22:	8085                	srli	s1,s1,0x1
    80000c24:	8885                	andi	s1,s1,1
    80000c26:	dd64                	sw	s1,124(a0)
    80000c28:	bfe9                	j	80000c02 <push_off+0x24>

0000000080000c2a <acquire>:
{
    80000c2a:	1101                	addi	sp,sp,-32
    80000c2c:	ec06                	sd	ra,24(sp)
    80000c2e:	e822                	sd	s0,16(sp)
    80000c30:	e426                	sd	s1,8(sp)
    80000c32:	1000                	addi	s0,sp,32
    80000c34:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c36:	00000097          	auipc	ra,0x0
    80000c3a:	fa8080e7          	jalr	-88(ra) # 80000bde <push_off>
  if(holding(lk))
    80000c3e:	8526                	mv	a0,s1
    80000c40:	00000097          	auipc	ra,0x0
    80000c44:	f70080e7          	jalr	-144(ra) # 80000bb0 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c48:	4705                	li	a4,1
  if(holding(lk))
    80000c4a:	e115                	bnez	a0,80000c6e <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c4c:	87ba                	mv	a5,a4
    80000c4e:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c52:	2781                	sext.w	a5,a5
    80000c54:	ffe5                	bnez	a5,80000c4c <acquire+0x22>
  __sync_synchronize();
    80000c56:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c5a:	00001097          	auipc	ra,0x1
    80000c5e:	e9c080e7          	jalr	-356(ra) # 80001af6 <mycpu>
    80000c62:	e888                	sd	a0,16(s1)
}
    80000c64:	60e2                	ld	ra,24(sp)
    80000c66:	6442                	ld	s0,16(sp)
    80000c68:	64a2                	ld	s1,8(sp)
    80000c6a:	6105                	addi	sp,sp,32
    80000c6c:	8082                	ret
    panic("acquire");
    80000c6e:	00007517          	auipc	a0,0x7
    80000c72:	40250513          	addi	a0,a0,1026 # 80008070 <digits+0x40>
    80000c76:	00000097          	auipc	ra,0x0
    80000c7a:	8d2080e7          	jalr	-1838(ra) # 80000548 <panic>

0000000080000c7e <pop_off>:

void
pop_off(void)
{
    80000c7e:	1141                	addi	sp,sp,-16
    80000c80:	e406                	sd	ra,8(sp)
    80000c82:	e022                	sd	s0,0(sp)
    80000c84:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c86:	00001097          	auipc	ra,0x1
    80000c8a:	e70080e7          	jalr	-400(ra) # 80001af6 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c8e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c92:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c94:	e78d                	bnez	a5,80000cbe <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c96:	5d3c                	lw	a5,120(a0)
    80000c98:	02f05b63          	blez	a5,80000cce <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c9c:	37fd                	addiw	a5,a5,-1
    80000c9e:	0007871b          	sext.w	a4,a5
    80000ca2:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000ca4:	eb09                	bnez	a4,80000cb6 <pop_off+0x38>
    80000ca6:	5d7c                	lw	a5,124(a0)
    80000ca8:	c799                	beqz	a5,80000cb6 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000caa:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000cae:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000cb2:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000cb6:	60a2                	ld	ra,8(sp)
    80000cb8:	6402                	ld	s0,0(sp)
    80000cba:	0141                	addi	sp,sp,16
    80000cbc:	8082                	ret
    panic("pop_off - interruptible");
    80000cbe:	00007517          	auipc	a0,0x7
    80000cc2:	3ba50513          	addi	a0,a0,954 # 80008078 <digits+0x48>
    80000cc6:	00000097          	auipc	ra,0x0
    80000cca:	882080e7          	jalr	-1918(ra) # 80000548 <panic>
    panic("pop_off");
    80000cce:	00007517          	auipc	a0,0x7
    80000cd2:	3c250513          	addi	a0,a0,962 # 80008090 <digits+0x60>
    80000cd6:	00000097          	auipc	ra,0x0
    80000cda:	872080e7          	jalr	-1934(ra) # 80000548 <panic>

0000000080000cde <release>:
{
    80000cde:	1101                	addi	sp,sp,-32
    80000ce0:	ec06                	sd	ra,24(sp)
    80000ce2:	e822                	sd	s0,16(sp)
    80000ce4:	e426                	sd	s1,8(sp)
    80000ce6:	1000                	addi	s0,sp,32
    80000ce8:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000cea:	00000097          	auipc	ra,0x0
    80000cee:	ec6080e7          	jalr	-314(ra) # 80000bb0 <holding>
    80000cf2:	c115                	beqz	a0,80000d16 <release+0x38>
  lk->cpu = 0;
    80000cf4:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000cf8:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000cfc:	0f50000f          	fence	iorw,ow
    80000d00:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000d04:	00000097          	auipc	ra,0x0
    80000d08:	f7a080e7          	jalr	-134(ra) # 80000c7e <pop_off>
}
    80000d0c:	60e2                	ld	ra,24(sp)
    80000d0e:	6442                	ld	s0,16(sp)
    80000d10:	64a2                	ld	s1,8(sp)
    80000d12:	6105                	addi	sp,sp,32
    80000d14:	8082                	ret
    panic("release");
    80000d16:	00007517          	auipc	a0,0x7
    80000d1a:	38250513          	addi	a0,a0,898 # 80008098 <digits+0x68>
    80000d1e:	00000097          	auipc	ra,0x0
    80000d22:	82a080e7          	jalr	-2006(ra) # 80000548 <panic>

0000000080000d26 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d26:	1141                	addi	sp,sp,-16
    80000d28:	e422                	sd	s0,8(sp)
    80000d2a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d2c:	ce09                	beqz	a2,80000d46 <memset+0x20>
    80000d2e:	87aa                	mv	a5,a0
    80000d30:	fff6071b          	addiw	a4,a2,-1
    80000d34:	1702                	slli	a4,a4,0x20
    80000d36:	9301                	srli	a4,a4,0x20
    80000d38:	0705                	addi	a4,a4,1
    80000d3a:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000d3c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d40:	0785                	addi	a5,a5,1
    80000d42:	fee79de3          	bne	a5,a4,80000d3c <memset+0x16>
  }
  return dst;
}
    80000d46:	6422                	ld	s0,8(sp)
    80000d48:	0141                	addi	sp,sp,16
    80000d4a:	8082                	ret

0000000080000d4c <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d4c:	1141                	addi	sp,sp,-16
    80000d4e:	e422                	sd	s0,8(sp)
    80000d50:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d52:	ca05                	beqz	a2,80000d82 <memcmp+0x36>
    80000d54:	fff6069b          	addiw	a3,a2,-1
    80000d58:	1682                	slli	a3,a3,0x20
    80000d5a:	9281                	srli	a3,a3,0x20
    80000d5c:	0685                	addi	a3,a3,1
    80000d5e:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d60:	00054783          	lbu	a5,0(a0)
    80000d64:	0005c703          	lbu	a4,0(a1)
    80000d68:	00e79863          	bne	a5,a4,80000d78 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d6c:	0505                	addi	a0,a0,1
    80000d6e:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d70:	fed518e3          	bne	a0,a3,80000d60 <memcmp+0x14>
  }

  return 0;
    80000d74:	4501                	li	a0,0
    80000d76:	a019                	j	80000d7c <memcmp+0x30>
      return *s1 - *s2;
    80000d78:	40e7853b          	subw	a0,a5,a4
}
    80000d7c:	6422                	ld	s0,8(sp)
    80000d7e:	0141                	addi	sp,sp,16
    80000d80:	8082                	ret
  return 0;
    80000d82:	4501                	li	a0,0
    80000d84:	bfe5                	j	80000d7c <memcmp+0x30>

0000000080000d86 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d86:	1141                	addi	sp,sp,-16
    80000d88:	e422                	sd	s0,8(sp)
    80000d8a:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d8c:	00a5f963          	bgeu	a1,a0,80000d9e <memmove+0x18>
    80000d90:	02061713          	slli	a4,a2,0x20
    80000d94:	9301                	srli	a4,a4,0x20
    80000d96:	00e587b3          	add	a5,a1,a4
    80000d9a:	02f56563          	bltu	a0,a5,80000dc4 <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d9e:	fff6069b          	addiw	a3,a2,-1
    80000da2:	ce11                	beqz	a2,80000dbe <memmove+0x38>
    80000da4:	1682                	slli	a3,a3,0x20
    80000da6:	9281                	srli	a3,a3,0x20
    80000da8:	0685                	addi	a3,a3,1
    80000daa:	96ae                	add	a3,a3,a1
    80000dac:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000dae:	0585                	addi	a1,a1,1
    80000db0:	0785                	addi	a5,a5,1
    80000db2:	fff5c703          	lbu	a4,-1(a1)
    80000db6:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000dba:	fed59ae3          	bne	a1,a3,80000dae <memmove+0x28>

  return dst;
}
    80000dbe:	6422                	ld	s0,8(sp)
    80000dc0:	0141                	addi	sp,sp,16
    80000dc2:	8082                	ret
    d += n;
    80000dc4:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000dc6:	fff6069b          	addiw	a3,a2,-1
    80000dca:	da75                	beqz	a2,80000dbe <memmove+0x38>
    80000dcc:	02069613          	slli	a2,a3,0x20
    80000dd0:	9201                	srli	a2,a2,0x20
    80000dd2:	fff64613          	not	a2,a2
    80000dd6:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000dd8:	17fd                	addi	a5,a5,-1
    80000dda:	177d                	addi	a4,a4,-1
    80000ddc:	0007c683          	lbu	a3,0(a5)
    80000de0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000de4:	fec79ae3          	bne	a5,a2,80000dd8 <memmove+0x52>
    80000de8:	bfd9                	j	80000dbe <memmove+0x38>

0000000080000dea <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000dea:	1141                	addi	sp,sp,-16
    80000dec:	e406                	sd	ra,8(sp)
    80000dee:	e022                	sd	s0,0(sp)
    80000df0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000df2:	00000097          	auipc	ra,0x0
    80000df6:	f94080e7          	jalr	-108(ra) # 80000d86 <memmove>
}
    80000dfa:	60a2                	ld	ra,8(sp)
    80000dfc:	6402                	ld	s0,0(sp)
    80000dfe:	0141                	addi	sp,sp,16
    80000e00:	8082                	ret

0000000080000e02 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e02:	1141                	addi	sp,sp,-16
    80000e04:	e422                	sd	s0,8(sp)
    80000e06:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e08:	ce11                	beqz	a2,80000e24 <strncmp+0x22>
    80000e0a:	00054783          	lbu	a5,0(a0)
    80000e0e:	cf89                	beqz	a5,80000e28 <strncmp+0x26>
    80000e10:	0005c703          	lbu	a4,0(a1)
    80000e14:	00f71a63          	bne	a4,a5,80000e28 <strncmp+0x26>
    n--, p++, q++;
    80000e18:	367d                	addiw	a2,a2,-1
    80000e1a:	0505                	addi	a0,a0,1
    80000e1c:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e1e:	f675                	bnez	a2,80000e0a <strncmp+0x8>
  if(n == 0)
    return 0;
    80000e20:	4501                	li	a0,0
    80000e22:	a809                	j	80000e34 <strncmp+0x32>
    80000e24:	4501                	li	a0,0
    80000e26:	a039                	j	80000e34 <strncmp+0x32>
  if(n == 0)
    80000e28:	ca09                	beqz	a2,80000e3a <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000e2a:	00054503          	lbu	a0,0(a0)
    80000e2e:	0005c783          	lbu	a5,0(a1)
    80000e32:	9d1d                	subw	a0,a0,a5
}
    80000e34:	6422                	ld	s0,8(sp)
    80000e36:	0141                	addi	sp,sp,16
    80000e38:	8082                	ret
    return 0;
    80000e3a:	4501                	li	a0,0
    80000e3c:	bfe5                	j	80000e34 <strncmp+0x32>

0000000080000e3e <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e3e:	1141                	addi	sp,sp,-16
    80000e40:	e422                	sd	s0,8(sp)
    80000e42:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e44:	872a                	mv	a4,a0
    80000e46:	8832                	mv	a6,a2
    80000e48:	367d                	addiw	a2,a2,-1
    80000e4a:	01005963          	blez	a6,80000e5c <strncpy+0x1e>
    80000e4e:	0705                	addi	a4,a4,1
    80000e50:	0005c783          	lbu	a5,0(a1)
    80000e54:	fef70fa3          	sb	a5,-1(a4)
    80000e58:	0585                	addi	a1,a1,1
    80000e5a:	f7f5                	bnez	a5,80000e46 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e5c:	00c05d63          	blez	a2,80000e76 <strncpy+0x38>
    80000e60:	86ba                	mv	a3,a4
    *s++ = 0;
    80000e62:	0685                	addi	a3,a3,1
    80000e64:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e68:	fff6c793          	not	a5,a3
    80000e6c:	9fb9                	addw	a5,a5,a4
    80000e6e:	010787bb          	addw	a5,a5,a6
    80000e72:	fef048e3          	bgtz	a5,80000e62 <strncpy+0x24>
  return os;
}
    80000e76:	6422                	ld	s0,8(sp)
    80000e78:	0141                	addi	sp,sp,16
    80000e7a:	8082                	ret

0000000080000e7c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e7c:	1141                	addi	sp,sp,-16
    80000e7e:	e422                	sd	s0,8(sp)
    80000e80:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e82:	02c05363          	blez	a2,80000ea8 <safestrcpy+0x2c>
    80000e86:	fff6069b          	addiw	a3,a2,-1
    80000e8a:	1682                	slli	a3,a3,0x20
    80000e8c:	9281                	srli	a3,a3,0x20
    80000e8e:	96ae                	add	a3,a3,a1
    80000e90:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e92:	00d58963          	beq	a1,a3,80000ea4 <safestrcpy+0x28>
    80000e96:	0585                	addi	a1,a1,1
    80000e98:	0785                	addi	a5,a5,1
    80000e9a:	fff5c703          	lbu	a4,-1(a1)
    80000e9e:	fee78fa3          	sb	a4,-1(a5)
    80000ea2:	fb65                	bnez	a4,80000e92 <safestrcpy+0x16>
    ;
  *s = 0;
    80000ea4:	00078023          	sb	zero,0(a5)
  return os;
}
    80000ea8:	6422                	ld	s0,8(sp)
    80000eaa:	0141                	addi	sp,sp,16
    80000eac:	8082                	ret

0000000080000eae <strlen>:

int
strlen(const char *s)
{
    80000eae:	1141                	addi	sp,sp,-16
    80000eb0:	e422                	sd	s0,8(sp)
    80000eb2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000eb4:	00054783          	lbu	a5,0(a0)
    80000eb8:	cf91                	beqz	a5,80000ed4 <strlen+0x26>
    80000eba:	0505                	addi	a0,a0,1
    80000ebc:	87aa                	mv	a5,a0
    80000ebe:	4685                	li	a3,1
    80000ec0:	9e89                	subw	a3,a3,a0
    80000ec2:	00f6853b          	addw	a0,a3,a5
    80000ec6:	0785                	addi	a5,a5,1
    80000ec8:	fff7c703          	lbu	a4,-1(a5)
    80000ecc:	fb7d                	bnez	a4,80000ec2 <strlen+0x14>
    ;
  return n;
}
    80000ece:	6422                	ld	s0,8(sp)
    80000ed0:	0141                	addi	sp,sp,16
    80000ed2:	8082                	ret
  for(n = 0; s[n]; n++)
    80000ed4:	4501                	li	a0,0
    80000ed6:	bfe5                	j	80000ece <strlen+0x20>

0000000080000ed8 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000ed8:	1141                	addi	sp,sp,-16
    80000eda:	e406                	sd	ra,8(sp)
    80000edc:	e022                	sd	s0,0(sp)
    80000ede:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000ee0:	00001097          	auipc	ra,0x1
    80000ee4:	c06080e7          	jalr	-1018(ra) # 80001ae6 <cpuid>
#endif    
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000ee8:	00008717          	auipc	a4,0x8
    80000eec:	12470713          	addi	a4,a4,292 # 8000900c <started>
  if(cpuid() == 0){
    80000ef0:	c139                	beqz	a0,80000f36 <main+0x5e>
    while(started == 0)
    80000ef2:	431c                	lw	a5,0(a4)
    80000ef4:	2781                	sext.w	a5,a5
    80000ef6:	dff5                	beqz	a5,80000ef2 <main+0x1a>
      ;
    __sync_synchronize();
    80000ef8:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000efc:	00001097          	auipc	ra,0x1
    80000f00:	bea080e7          	jalr	-1046(ra) # 80001ae6 <cpuid>
    80000f04:	85aa                	mv	a1,a0
    80000f06:	00007517          	auipc	a0,0x7
    80000f0a:	1b250513          	addi	a0,a0,434 # 800080b8 <digits+0x88>
    80000f0e:	fffff097          	auipc	ra,0xfffff
    80000f12:	684080e7          	jalr	1668(ra) # 80000592 <printf>
    kvminithart();    // turn on paging
    80000f16:	00000097          	auipc	ra,0x0
    80000f1a:	0e0080e7          	jalr	224(ra) # 80000ff6 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f1e:	00002097          	auipc	ra,0x2
    80000f22:	96a080e7          	jalr	-1686(ra) # 80002888 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f26:	00005097          	auipc	ra,0x5
    80000f2a:	f6a080e7          	jalr	-150(ra) # 80005e90 <plicinithart>
  }

  scheduler();        
    80000f2e:	00001097          	auipc	ra,0x1
    80000f32:	214080e7          	jalr	532(ra) # 80002142 <scheduler>
    consoleinit();
    80000f36:	fffff097          	auipc	ra,0xfffff
    80000f3a:	524080e7          	jalr	1316(ra) # 8000045a <consoleinit>
    statsinit();
    80000f3e:	00005097          	auipc	ra,0x5
    80000f42:	720080e7          	jalr	1824(ra) # 8000665e <statsinit>
    printfinit();
    80000f46:	00000097          	auipc	ra,0x0
    80000f4a:	832080e7          	jalr	-1998(ra) # 80000778 <printfinit>
    printf("\n");
    80000f4e:	00007517          	auipc	a0,0x7
    80000f52:	17a50513          	addi	a0,a0,378 # 800080c8 <digits+0x98>
    80000f56:	fffff097          	auipc	ra,0xfffff
    80000f5a:	63c080e7          	jalr	1596(ra) # 80000592 <printf>
    printf("xv6 kernel is booting\n");
    80000f5e:	00007517          	auipc	a0,0x7
    80000f62:	14250513          	addi	a0,a0,322 # 800080a0 <digits+0x70>
    80000f66:	fffff097          	auipc	ra,0xfffff
    80000f6a:	62c080e7          	jalr	1580(ra) # 80000592 <printf>
    printf("\n");
    80000f6e:	00007517          	auipc	a0,0x7
    80000f72:	15a50513          	addi	a0,a0,346 # 800080c8 <digits+0x98>
    80000f76:	fffff097          	auipc	ra,0xfffff
    80000f7a:	61c080e7          	jalr	1564(ra) # 80000592 <printf>
    kinit();         // physical page allocator
    80000f7e:	00000097          	auipc	ra,0x0
    80000f82:	b66080e7          	jalr	-1178(ra) # 80000ae4 <kinit>
    kvminit();       // create kernel page table
    80000f86:	00000097          	auipc	ra,0x0
    80000f8a:	37a080e7          	jalr	890(ra) # 80001300 <kvminit>
    kvminithart();   // turn on paging
    80000f8e:	00000097          	auipc	ra,0x0
    80000f92:	068080e7          	jalr	104(ra) # 80000ff6 <kvminithart>
    procinit();      // process table
    80000f96:	00001097          	auipc	ra,0x1
    80000f9a:	ae8080e7          	jalr	-1304(ra) # 80001a7e <procinit>
    trapinit();      // trap vectors
    80000f9e:	00002097          	auipc	ra,0x2
    80000fa2:	8c2080e7          	jalr	-1854(ra) # 80002860 <trapinit>
    trapinithart();  // install kernel trap vector
    80000fa6:	00002097          	auipc	ra,0x2
    80000faa:	8e2080e7          	jalr	-1822(ra) # 80002888 <trapinithart>
    plicinit();      // set up interrupt controller
    80000fae:	00005097          	auipc	ra,0x5
    80000fb2:	ecc080e7          	jalr	-308(ra) # 80005e7a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fb6:	00005097          	auipc	ra,0x5
    80000fba:	eda080e7          	jalr	-294(ra) # 80005e90 <plicinithart>
    binit();         // buffer cache
    80000fbe:	00002097          	auipc	ra,0x2
    80000fc2:	00c080e7          	jalr	12(ra) # 80002fca <binit>
    iinit();         // inode cache
    80000fc6:	00002097          	auipc	ra,0x2
    80000fca:	69c080e7          	jalr	1692(ra) # 80003662 <iinit>
    fileinit();      // file table
    80000fce:	00003097          	auipc	ra,0x3
    80000fd2:	636080e7          	jalr	1590(ra) # 80004604 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fd6:	00005097          	auipc	ra,0x5
    80000fda:	fc2080e7          	jalr	-62(ra) # 80005f98 <virtio_disk_init>
    userinit();      // first user process
    80000fde:	00001097          	auipc	ra,0x1
    80000fe2:	e70080e7          	jalr	-400(ra) # 80001e4e <userinit>
    __sync_synchronize();
    80000fe6:	0ff0000f          	fence
    started = 1;
    80000fea:	4785                	li	a5,1
    80000fec:	00008717          	auipc	a4,0x8
    80000ff0:	02f72023          	sw	a5,32(a4) # 8000900c <started>
    80000ff4:	bf2d                	j	80000f2e <main+0x56>

0000000080000ff6 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000ff6:	1141                	addi	sp,sp,-16
    80000ff8:	e422                	sd	s0,8(sp)
    80000ffa:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000ffc:	00008797          	auipc	a5,0x8
    80001000:	0147b783          	ld	a5,20(a5) # 80009010 <kernel_pagetable>
    80001004:	83b1                	srli	a5,a5,0xc
    80001006:	577d                	li	a4,-1
    80001008:	177e                	slli	a4,a4,0x3f
    8000100a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    8000100c:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80001010:	12000073          	sfence.vma
  sfence_vma();
}
    80001014:	6422                	ld	s0,8(sp)
    80001016:	0141                	addi	sp,sp,16
    80001018:	8082                	ret

000000008000101a <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    8000101a:	7139                	addi	sp,sp,-64
    8000101c:	fc06                	sd	ra,56(sp)
    8000101e:	f822                	sd	s0,48(sp)
    80001020:	f426                	sd	s1,40(sp)
    80001022:	f04a                	sd	s2,32(sp)
    80001024:	ec4e                	sd	s3,24(sp)
    80001026:	e852                	sd	s4,16(sp)
    80001028:	e456                	sd	s5,8(sp)
    8000102a:	e05a                	sd	s6,0(sp)
    8000102c:	0080                	addi	s0,sp,64
    8000102e:	84aa                	mv	s1,a0
    80001030:	89ae                	mv	s3,a1
    80001032:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001034:	57fd                	li	a5,-1
    80001036:	83e9                	srli	a5,a5,0x1a
    80001038:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    8000103a:	4b31                	li	s6,12
  if(va >= MAXVA)
    8000103c:	04b7f263          	bgeu	a5,a1,80001080 <walk+0x66>
    panic("walk");
    80001040:	00007517          	auipc	a0,0x7
    80001044:	09050513          	addi	a0,a0,144 # 800080d0 <digits+0xa0>
    80001048:	fffff097          	auipc	ra,0xfffff
    8000104c:	500080e7          	jalr	1280(ra) # 80000548 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0) {
    80001050:	060a8663          	beqz	s5,800010bc <walk+0xa2>
    80001054:	00000097          	auipc	ra,0x0
    80001058:	ae6080e7          	jalr	-1306(ra) # 80000b3a <kalloc>
    8000105c:	84aa                	mv	s1,a0
    8000105e:	c529                	beqz	a0,800010a8 <walk+0x8e>
        if(alloc && pagetable == 0) {
          // printf("trace: failed kalloc, freelist: %p\n", kget_freelist());
        }
        return 0;
      }
      memset(pagetable, 0, PGSIZE);
    80001060:	6605                	lui	a2,0x1
    80001062:	4581                	li	a1,0
    80001064:	00000097          	auipc	ra,0x0
    80001068:	cc2080e7          	jalr	-830(ra) # 80000d26 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000106c:	00c4d793          	srli	a5,s1,0xc
    80001070:	07aa                	slli	a5,a5,0xa
    80001072:	0017e793          	ori	a5,a5,1
    80001076:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    8000107a:	3a5d                	addiw	s4,s4,-9
    8000107c:	036a0063          	beq	s4,s6,8000109c <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001080:	0149d933          	srl	s2,s3,s4
    80001084:	1ff97913          	andi	s2,s2,511
    80001088:	090e                	slli	s2,s2,0x3
    8000108a:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000108c:	00093483          	ld	s1,0(s2)
    80001090:	0014f793          	andi	a5,s1,1
    80001094:	dfd5                	beqz	a5,80001050 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001096:	80a9                	srli	s1,s1,0xa
    80001098:	04b2                	slli	s1,s1,0xc
    8000109a:	b7c5                	j	8000107a <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000109c:	00c9d513          	srli	a0,s3,0xc
    800010a0:	1ff57513          	andi	a0,a0,511
    800010a4:	050e                	slli	a0,a0,0x3
    800010a6:	9526                	add	a0,a0,s1
}
    800010a8:	70e2                	ld	ra,56(sp)
    800010aa:	7442                	ld	s0,48(sp)
    800010ac:	74a2                	ld	s1,40(sp)
    800010ae:	7902                	ld	s2,32(sp)
    800010b0:	69e2                	ld	s3,24(sp)
    800010b2:	6a42                	ld	s4,16(sp)
    800010b4:	6aa2                	ld	s5,8(sp)
    800010b6:	6b02                	ld	s6,0(sp)
    800010b8:	6121                	addi	sp,sp,64
    800010ba:	8082                	ret
        return 0;
    800010bc:	4501                	li	a0,0
    800010be:	b7ed                	j	800010a8 <walk+0x8e>

00000000800010c0 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800010c0:	57fd                	li	a5,-1
    800010c2:	83e9                	srli	a5,a5,0x1a
    800010c4:	00b7f463          	bgeu	a5,a1,800010cc <walkaddr+0xc>
    return 0;
    800010c8:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800010ca:	8082                	ret
{
    800010cc:	1141                	addi	sp,sp,-16
    800010ce:	e406                	sd	ra,8(sp)
    800010d0:	e022                	sd	s0,0(sp)
    800010d2:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800010d4:	4601                	li	a2,0
    800010d6:	00000097          	auipc	ra,0x0
    800010da:	f44080e7          	jalr	-188(ra) # 8000101a <walk>
  if(pte == 0)
    800010de:	c105                	beqz	a0,800010fe <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800010e0:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800010e2:	0117f693          	andi	a3,a5,17
    800010e6:	4745                	li	a4,17
    return 0;
    800010e8:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010ea:	00e68663          	beq	a3,a4,800010f6 <walkaddr+0x36>
}
    800010ee:	60a2                	ld	ra,8(sp)
    800010f0:	6402                	ld	s0,0(sp)
    800010f2:	0141                	addi	sp,sp,16
    800010f4:	8082                	ret
  pa = PTE2PA(*pte);
    800010f6:	00a7d513          	srli	a0,a5,0xa
    800010fa:	0532                	slli	a0,a0,0xc
  return pa;
    800010fc:	bfcd                	j	800010ee <walkaddr+0x2e>
    return 0;
    800010fe:	4501                	li	a0,0
    80001100:	b7fd                	j	800010ee <walkaddr+0x2e>

0000000080001102 <kvmpa>:
// a physical address. only needed for
// addresses on the stack.
// assumes va is page aligned.
uint64
kvmpa(pagetable_t kernelpgtbl, uint64 va)
{
    80001102:	1101                	addi	sp,sp,-32
    80001104:	ec06                	sd	ra,24(sp)
    80001106:	e822                	sd	s0,16(sp)
    80001108:	e426                	sd	s1,8(sp)
    8000110a:	1000                	addi	s0,sp,32
  uint64 off = va % PGSIZE;
    8000110c:	03459793          	slli	a5,a1,0x34
    80001110:	0347d493          	srli	s1,a5,0x34
  pte_t *pte;
  uint64 pa;

  pte = walk(kernelpgtbl, va, 0); // read from the process-specific kernel pagetable instead
    80001114:	4601                	li	a2,0
    80001116:	00000097          	auipc	ra,0x0
    8000111a:	f04080e7          	jalr	-252(ra) # 8000101a <walk>
  if(pte == 0)
    8000111e:	cd09                	beqz	a0,80001138 <kvmpa+0x36>
    panic("kvmpa");
  if((*pte & PTE_V) == 0)
    80001120:	6108                	ld	a0,0(a0)
    80001122:	00157793          	andi	a5,a0,1
    80001126:	c38d                	beqz	a5,80001148 <kvmpa+0x46>
    panic("kvmpa");
  pa = PTE2PA(*pte);
    80001128:	8129                	srli	a0,a0,0xa
    8000112a:	0532                	slli	a0,a0,0xc
  return pa+off;
}
    8000112c:	9526                	add	a0,a0,s1
    8000112e:	60e2                	ld	ra,24(sp)
    80001130:	6442                	ld	s0,16(sp)
    80001132:	64a2                	ld	s1,8(sp)
    80001134:	6105                	addi	sp,sp,32
    80001136:	8082                	ret
    panic("kvmpa");
    80001138:	00007517          	auipc	a0,0x7
    8000113c:	fa050513          	addi	a0,a0,-96 # 800080d8 <digits+0xa8>
    80001140:	fffff097          	auipc	ra,0xfffff
    80001144:	408080e7          	jalr	1032(ra) # 80000548 <panic>
    panic("kvmpa");
    80001148:	00007517          	auipc	a0,0x7
    8000114c:	f9050513          	addi	a0,a0,-112 # 800080d8 <digits+0xa8>
    80001150:	fffff097          	auipc	ra,0xfffff
    80001154:	3f8080e7          	jalr	1016(ra) # 80000548 <panic>

0000000080001158 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001158:	715d                	addi	sp,sp,-80
    8000115a:	e486                	sd	ra,72(sp)
    8000115c:	e0a2                	sd	s0,64(sp)
    8000115e:	fc26                	sd	s1,56(sp)
    80001160:	f84a                	sd	s2,48(sp)
    80001162:	f44e                	sd	s3,40(sp)
    80001164:	f052                	sd	s4,32(sp)
    80001166:	ec56                	sd	s5,24(sp)
    80001168:	e85a                	sd	s6,16(sp)
    8000116a:	e45e                	sd	s7,8(sp)
    8000116c:	0880                	addi	s0,sp,80
    8000116e:	8aaa                	mv	s5,a0
    80001170:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    80001172:	777d                	lui	a4,0xfffff
    80001174:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001178:	167d                	addi	a2,a2,-1
    8000117a:	00b609b3          	add	s3,a2,a1
    8000117e:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    80001182:	893e                	mv	s2,a5
    80001184:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001188:	6b85                	lui	s7,0x1
    8000118a:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    8000118e:	4605                	li	a2,1
    80001190:	85ca                	mv	a1,s2
    80001192:	8556                	mv	a0,s5
    80001194:	00000097          	auipc	ra,0x0
    80001198:	e86080e7          	jalr	-378(ra) # 8000101a <walk>
    8000119c:	c51d                	beqz	a0,800011ca <mappages+0x72>
    if(*pte & PTE_V)
    8000119e:	611c                	ld	a5,0(a0)
    800011a0:	8b85                	andi	a5,a5,1
    800011a2:	ef81                	bnez	a5,800011ba <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800011a4:	80b1                	srli	s1,s1,0xc
    800011a6:	04aa                	slli	s1,s1,0xa
    800011a8:	0164e4b3          	or	s1,s1,s6
    800011ac:	0014e493          	ori	s1,s1,1
    800011b0:	e104                	sd	s1,0(a0)
    if(a == last)
    800011b2:	03390863          	beq	s2,s3,800011e2 <mappages+0x8a>
    a += PGSIZE;
    800011b6:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800011b8:	bfc9                	j	8000118a <mappages+0x32>
      panic("remap");
    800011ba:	00007517          	auipc	a0,0x7
    800011be:	f2650513          	addi	a0,a0,-218 # 800080e0 <digits+0xb0>
    800011c2:	fffff097          	auipc	ra,0xfffff
    800011c6:	386080e7          	jalr	902(ra) # 80000548 <panic>
      return -1;
    800011ca:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800011cc:	60a6                	ld	ra,72(sp)
    800011ce:	6406                	ld	s0,64(sp)
    800011d0:	74e2                	ld	s1,56(sp)
    800011d2:	7942                	ld	s2,48(sp)
    800011d4:	79a2                	ld	s3,40(sp)
    800011d6:	7a02                	ld	s4,32(sp)
    800011d8:	6ae2                	ld	s5,24(sp)
    800011da:	6b42                	ld	s6,16(sp)
    800011dc:	6ba2                	ld	s7,8(sp)
    800011de:	6161                	addi	sp,sp,80
    800011e0:	8082                	ret
  return 0;
    800011e2:	4501                	li	a0,0
    800011e4:	b7e5                	j	800011cc <mappages+0x74>

00000000800011e6 <kvmmap>:
{
    800011e6:	1141                	addi	sp,sp,-16
    800011e8:	e406                	sd	ra,8(sp)
    800011ea:	e022                	sd	s0,0(sp)
    800011ec:	0800                	addi	s0,sp,16
    800011ee:	87b6                	mv	a5,a3
  if(mappages(pgtbl, va, sz, pa, perm) != 0)
    800011f0:	86b2                	mv	a3,a2
    800011f2:	863e                	mv	a2,a5
    800011f4:	00000097          	auipc	ra,0x0
    800011f8:	f64080e7          	jalr	-156(ra) # 80001158 <mappages>
    800011fc:	e509                	bnez	a0,80001206 <kvmmap+0x20>
}
    800011fe:	60a2                	ld	ra,8(sp)
    80001200:	6402                	ld	s0,0(sp)
    80001202:	0141                	addi	sp,sp,16
    80001204:	8082                	ret
    panic("kvmmap");
    80001206:	00007517          	auipc	a0,0x7
    8000120a:	ee250513          	addi	a0,a0,-286 # 800080e8 <digits+0xb8>
    8000120e:	fffff097          	auipc	ra,0xfffff
    80001212:	33a080e7          	jalr	826(ra) # 80000548 <panic>

0000000080001216 <kvm_map_pagetable>:
void kvm_map_pagetable(pagetable_t pgtbl) {
    80001216:	1101                	addi	sp,sp,-32
    80001218:	ec06                	sd	ra,24(sp)
    8000121a:	e822                	sd	s0,16(sp)
    8000121c:	e426                	sd	s1,8(sp)
    8000121e:	e04a                	sd	s2,0(sp)
    80001220:	1000                	addi	s0,sp,32
    80001222:	84aa                	mv	s1,a0
  kvmmap(pgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001224:	4719                	li	a4,6
    80001226:	6685                	lui	a3,0x1
    80001228:	10000637          	lui	a2,0x10000
    8000122c:	100005b7          	lui	a1,0x10000
    80001230:	00000097          	auipc	ra,0x0
    80001234:	fb6080e7          	jalr	-74(ra) # 800011e6 <kvmmap>
  kvmmap(pgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001238:	4719                	li	a4,6
    8000123a:	6685                	lui	a3,0x1
    8000123c:	10001637          	lui	a2,0x10001
    80001240:	100015b7          	lui	a1,0x10001
    80001244:	8526                	mv	a0,s1
    80001246:	00000097          	auipc	ra,0x0
    8000124a:	fa0080e7          	jalr	-96(ra) # 800011e6 <kvmmap>
  kvmmap(pgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000124e:	4719                	li	a4,6
    80001250:	004006b7          	lui	a3,0x400
    80001254:	0c000637          	lui	a2,0xc000
    80001258:	0c0005b7          	lui	a1,0xc000
    8000125c:	8526                	mv	a0,s1
    8000125e:	00000097          	auipc	ra,0x0
    80001262:	f88080e7          	jalr	-120(ra) # 800011e6 <kvmmap>
  kvmmap(pgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001266:	00007917          	auipc	s2,0x7
    8000126a:	d9a90913          	addi	s2,s2,-614 # 80008000 <etext>
    8000126e:	4729                	li	a4,10
    80001270:	80007697          	auipc	a3,0x80007
    80001274:	d9068693          	addi	a3,a3,-624 # 8000 <_entry-0x7fff8000>
    80001278:	4605                	li	a2,1
    8000127a:	067e                	slli	a2,a2,0x1f
    8000127c:	85b2                	mv	a1,a2
    8000127e:	8526                	mv	a0,s1
    80001280:	00000097          	auipc	ra,0x0
    80001284:	f66080e7          	jalr	-154(ra) # 800011e6 <kvmmap>
  kvmmap(pgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001288:	4719                	li	a4,6
    8000128a:	46c5                	li	a3,17
    8000128c:	06ee                	slli	a3,a3,0x1b
    8000128e:	412686b3          	sub	a3,a3,s2
    80001292:	864a                	mv	a2,s2
    80001294:	85ca                	mv	a1,s2
    80001296:	8526                	mv	a0,s1
    80001298:	00000097          	auipc	ra,0x0
    8000129c:	f4e080e7          	jalr	-178(ra) # 800011e6 <kvmmap>
  kvmmap(pgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800012a0:	4729                	li	a4,10
    800012a2:	6685                	lui	a3,0x1
    800012a4:	00006617          	auipc	a2,0x6
    800012a8:	d5c60613          	addi	a2,a2,-676 # 80007000 <_trampoline>
    800012ac:	040005b7          	lui	a1,0x4000
    800012b0:	15fd                	addi	a1,a1,-1
    800012b2:	05b2                	slli	a1,a1,0xc
    800012b4:	8526                	mv	a0,s1
    800012b6:	00000097          	auipc	ra,0x0
    800012ba:	f30080e7          	jalr	-208(ra) # 800011e6 <kvmmap>
}
    800012be:	60e2                	ld	ra,24(sp)
    800012c0:	6442                	ld	s0,16(sp)
    800012c2:	64a2                	ld	s1,8(sp)
    800012c4:	6902                	ld	s2,0(sp)
    800012c6:	6105                	addi	sp,sp,32
    800012c8:	8082                	ret

00000000800012ca <kvminit_newpgtbl>:
{
    800012ca:	1101                	addi	sp,sp,-32
    800012cc:	ec06                	sd	ra,24(sp)
    800012ce:	e822                	sd	s0,16(sp)
    800012d0:	e426                	sd	s1,8(sp)
    800012d2:	1000                	addi	s0,sp,32
  pagetable_t pgtbl = (pagetable_t) kalloc();
    800012d4:	00000097          	auipc	ra,0x0
    800012d8:	866080e7          	jalr	-1946(ra) # 80000b3a <kalloc>
    800012dc:	84aa                	mv	s1,a0
  memset(pgtbl, 0, PGSIZE);
    800012de:	6605                	lui	a2,0x1
    800012e0:	4581                	li	a1,0
    800012e2:	00000097          	auipc	ra,0x0
    800012e6:	a44080e7          	jalr	-1468(ra) # 80000d26 <memset>
  kvm_map_pagetable(pgtbl);
    800012ea:	8526                	mv	a0,s1
    800012ec:	00000097          	auipc	ra,0x0
    800012f0:	f2a080e7          	jalr	-214(ra) # 80001216 <kvm_map_pagetable>
}
    800012f4:	8526                	mv	a0,s1
    800012f6:	60e2                	ld	ra,24(sp)
    800012f8:	6442                	ld	s0,16(sp)
    800012fa:	64a2                	ld	s1,8(sp)
    800012fc:	6105                	addi	sp,sp,32
    800012fe:	8082                	ret

0000000080001300 <kvminit>:
{
    80001300:	1141                	addi	sp,sp,-16
    80001302:	e406                	sd	ra,8(sp)
    80001304:	e022                	sd	s0,0(sp)
    80001306:	0800                	addi	s0,sp,16
  kernel_pagetable = kvminit_newpgtbl();
    80001308:	00000097          	auipc	ra,0x0
    8000130c:	fc2080e7          	jalr	-62(ra) # 800012ca <kvminit_newpgtbl>
    80001310:	00008797          	auipc	a5,0x8
    80001314:	d0a7b023          	sd	a0,-768(a5) # 80009010 <kernel_pagetable>
  kvmmap(kernel_pagetable, CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    80001318:	4719                	li	a4,6
    8000131a:	66c1                	lui	a3,0x10
    8000131c:	02000637          	lui	a2,0x2000
    80001320:	020005b7          	lui	a1,0x2000
    80001324:	00000097          	auipc	ra,0x0
    80001328:	ec2080e7          	jalr	-318(ra) # 800011e6 <kvmmap>
}
    8000132c:	60a2                	ld	ra,8(sp)
    8000132e:	6402                	ld	s0,0(sp)
    80001330:	0141                	addi	sp,sp,16
    80001332:	8082                	ret

0000000080001334 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001334:	715d                	addi	sp,sp,-80
    80001336:	e486                	sd	ra,72(sp)
    80001338:	e0a2                	sd	s0,64(sp)
    8000133a:	fc26                	sd	s1,56(sp)
    8000133c:	f84a                	sd	s2,48(sp)
    8000133e:	f44e                	sd	s3,40(sp)
    80001340:	f052                	sd	s4,32(sp)
    80001342:	ec56                	sd	s5,24(sp)
    80001344:	e85a                	sd	s6,16(sp)
    80001346:	e45e                	sd	s7,8(sp)
    80001348:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000134a:	03459793          	slli	a5,a1,0x34
    8000134e:	e795                	bnez	a5,8000137a <uvmunmap+0x46>
    80001350:	8a2a                	mv	s4,a0
    80001352:	892e                	mv	s2,a1
    80001354:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001356:	0632                	slli	a2,a2,0xc
    80001358:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000135c:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000135e:	6b05                	lui	s6,0x1
    80001360:	0735e863          	bltu	a1,s3,800013d0 <uvmunmap+0x9c>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001364:	60a6                	ld	ra,72(sp)
    80001366:	6406                	ld	s0,64(sp)
    80001368:	74e2                	ld	s1,56(sp)
    8000136a:	7942                	ld	s2,48(sp)
    8000136c:	79a2                	ld	s3,40(sp)
    8000136e:	7a02                	ld	s4,32(sp)
    80001370:	6ae2                	ld	s5,24(sp)
    80001372:	6b42                	ld	s6,16(sp)
    80001374:	6ba2                	ld	s7,8(sp)
    80001376:	6161                	addi	sp,sp,80
    80001378:	8082                	ret
    panic("uvmunmap: not aligned");
    8000137a:	00007517          	auipc	a0,0x7
    8000137e:	d7650513          	addi	a0,a0,-650 # 800080f0 <digits+0xc0>
    80001382:	fffff097          	auipc	ra,0xfffff
    80001386:	1c6080e7          	jalr	454(ra) # 80000548 <panic>
      panic("uvmunmap: walk");
    8000138a:	00007517          	auipc	a0,0x7
    8000138e:	d7e50513          	addi	a0,a0,-642 # 80008108 <digits+0xd8>
    80001392:	fffff097          	auipc	ra,0xfffff
    80001396:	1b6080e7          	jalr	438(ra) # 80000548 <panic>
      panic("uvmunmap: not mapped");
    8000139a:	00007517          	auipc	a0,0x7
    8000139e:	d7e50513          	addi	a0,a0,-642 # 80008118 <digits+0xe8>
    800013a2:	fffff097          	auipc	ra,0xfffff
    800013a6:	1a6080e7          	jalr	422(ra) # 80000548 <panic>
      panic("uvmunmap: not a leaf");
    800013aa:	00007517          	auipc	a0,0x7
    800013ae:	d8650513          	addi	a0,a0,-634 # 80008130 <digits+0x100>
    800013b2:	fffff097          	auipc	ra,0xfffff
    800013b6:	196080e7          	jalr	406(ra) # 80000548 <panic>
      uint64 pa = PTE2PA(*pte);
    800013ba:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800013bc:	0532                	slli	a0,a0,0xc
    800013be:	fffff097          	auipc	ra,0xfffff
    800013c2:	666080e7          	jalr	1638(ra) # 80000a24 <kfree>
    *pte = 0;
    800013c6:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800013ca:	995a                	add	s2,s2,s6
    800013cc:	f9397ce3          	bgeu	s2,s3,80001364 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800013d0:	4601                	li	a2,0
    800013d2:	85ca                	mv	a1,s2
    800013d4:	8552                	mv	a0,s4
    800013d6:	00000097          	auipc	ra,0x0
    800013da:	c44080e7          	jalr	-956(ra) # 8000101a <walk>
    800013de:	84aa                	mv	s1,a0
    800013e0:	d54d                	beqz	a0,8000138a <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800013e2:	6108                	ld	a0,0(a0)
    800013e4:	00157793          	andi	a5,a0,1
    800013e8:	dbcd                	beqz	a5,8000139a <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    800013ea:	3ff57793          	andi	a5,a0,1023
    800013ee:	fb778ee3          	beq	a5,s7,800013aa <uvmunmap+0x76>
    if(do_free){
    800013f2:	fc0a8ae3          	beqz	s5,800013c6 <uvmunmap+0x92>
    800013f6:	b7d1                	j	800013ba <uvmunmap+0x86>

00000000800013f8 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800013f8:	1101                	addi	sp,sp,-32
    800013fa:	ec06                	sd	ra,24(sp)
    800013fc:	e822                	sd	s0,16(sp)
    800013fe:	e426                	sd	s1,8(sp)
    80001400:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001402:	fffff097          	auipc	ra,0xfffff
    80001406:	738080e7          	jalr	1848(ra) # 80000b3a <kalloc>
    8000140a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000140c:	c519                	beqz	a0,8000141a <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000140e:	6605                	lui	a2,0x1
    80001410:	4581                	li	a1,0
    80001412:	00000097          	auipc	ra,0x0
    80001416:	914080e7          	jalr	-1772(ra) # 80000d26 <memset>
  return pagetable;
}
    8000141a:	8526                	mv	a0,s1
    8000141c:	60e2                	ld	ra,24(sp)
    8000141e:	6442                	ld	s0,16(sp)
    80001420:	64a2                	ld	s1,8(sp)
    80001422:	6105                	addi	sp,sp,32
    80001424:	8082                	ret

0000000080001426 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    80001426:	7179                	addi	sp,sp,-48
    80001428:	f406                	sd	ra,40(sp)
    8000142a:	f022                	sd	s0,32(sp)
    8000142c:	ec26                	sd	s1,24(sp)
    8000142e:	e84a                	sd	s2,16(sp)
    80001430:	e44e                	sd	s3,8(sp)
    80001432:	e052                	sd	s4,0(sp)
    80001434:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001436:	6785                	lui	a5,0x1
    80001438:	04f67863          	bgeu	a2,a5,80001488 <uvminit+0x62>
    8000143c:	8a2a                	mv	s4,a0
    8000143e:	89ae                	mv	s3,a1
    80001440:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80001442:	fffff097          	auipc	ra,0xfffff
    80001446:	6f8080e7          	jalr	1784(ra) # 80000b3a <kalloc>
    8000144a:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000144c:	6605                	lui	a2,0x1
    8000144e:	4581                	li	a1,0
    80001450:	00000097          	auipc	ra,0x0
    80001454:	8d6080e7          	jalr	-1834(ra) # 80000d26 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001458:	4779                	li	a4,30
    8000145a:	86ca                	mv	a3,s2
    8000145c:	6605                	lui	a2,0x1
    8000145e:	4581                	li	a1,0
    80001460:	8552                	mv	a0,s4
    80001462:	00000097          	auipc	ra,0x0
    80001466:	cf6080e7          	jalr	-778(ra) # 80001158 <mappages>
  memmove(mem, src, sz);
    8000146a:	8626                	mv	a2,s1
    8000146c:	85ce                	mv	a1,s3
    8000146e:	854a                	mv	a0,s2
    80001470:	00000097          	auipc	ra,0x0
    80001474:	916080e7          	jalr	-1770(ra) # 80000d86 <memmove>
}
    80001478:	70a2                	ld	ra,40(sp)
    8000147a:	7402                	ld	s0,32(sp)
    8000147c:	64e2                	ld	s1,24(sp)
    8000147e:	6942                	ld	s2,16(sp)
    80001480:	69a2                	ld	s3,8(sp)
    80001482:	6a02                	ld	s4,0(sp)
    80001484:	6145                	addi	sp,sp,48
    80001486:	8082                	ret
    panic("inituvm: more than a page");
    80001488:	00007517          	auipc	a0,0x7
    8000148c:	cc050513          	addi	a0,a0,-832 # 80008148 <digits+0x118>
    80001490:	fffff097          	auipc	ra,0xfffff
    80001494:	0b8080e7          	jalr	184(ra) # 80000548 <panic>

0000000080001498 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001498:	1101                	addi	sp,sp,-32
    8000149a:	ec06                	sd	ra,24(sp)
    8000149c:	e822                	sd	s0,16(sp)
    8000149e:	e426                	sd	s1,8(sp)
    800014a0:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800014a2:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800014a4:	00b67d63          	bgeu	a2,a1,800014be <uvmdealloc+0x26>
    800014a8:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800014aa:	6785                	lui	a5,0x1
    800014ac:	17fd                	addi	a5,a5,-1
    800014ae:	00f60733          	add	a4,a2,a5
    800014b2:	767d                	lui	a2,0xfffff
    800014b4:	8f71                	and	a4,a4,a2
    800014b6:	97ae                	add	a5,a5,a1
    800014b8:	8ff1                	and	a5,a5,a2
    800014ba:	00f76863          	bltu	a4,a5,800014ca <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800014be:	8526                	mv	a0,s1
    800014c0:	60e2                	ld	ra,24(sp)
    800014c2:	6442                	ld	s0,16(sp)
    800014c4:	64a2                	ld	s1,8(sp)
    800014c6:	6105                	addi	sp,sp,32
    800014c8:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800014ca:	8f99                	sub	a5,a5,a4
    800014cc:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800014ce:	4685                	li	a3,1
    800014d0:	0007861b          	sext.w	a2,a5
    800014d4:	85ba                	mv	a1,a4
    800014d6:	00000097          	auipc	ra,0x0
    800014da:	e5e080e7          	jalr	-418(ra) # 80001334 <uvmunmap>
    800014de:	b7c5                	j	800014be <uvmdealloc+0x26>

00000000800014e0 <uvmalloc>:
  if(newsz < oldsz)
    800014e0:	0ab66163          	bltu	a2,a1,80001582 <uvmalloc+0xa2>
{
    800014e4:	7139                	addi	sp,sp,-64
    800014e6:	fc06                	sd	ra,56(sp)
    800014e8:	f822                	sd	s0,48(sp)
    800014ea:	f426                	sd	s1,40(sp)
    800014ec:	f04a                	sd	s2,32(sp)
    800014ee:	ec4e                	sd	s3,24(sp)
    800014f0:	e852                	sd	s4,16(sp)
    800014f2:	e456                	sd	s5,8(sp)
    800014f4:	0080                	addi	s0,sp,64
    800014f6:	8aaa                	mv	s5,a0
    800014f8:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800014fa:	6985                	lui	s3,0x1
    800014fc:	19fd                	addi	s3,s3,-1
    800014fe:	95ce                	add	a1,a1,s3
    80001500:	79fd                	lui	s3,0xfffff
    80001502:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001506:	08c9f063          	bgeu	s3,a2,80001586 <uvmalloc+0xa6>
    8000150a:	894e                	mv	s2,s3
    mem = kalloc();
    8000150c:	fffff097          	auipc	ra,0xfffff
    80001510:	62e080e7          	jalr	1582(ra) # 80000b3a <kalloc>
    80001514:	84aa                	mv	s1,a0
    if(mem == 0){
    80001516:	c51d                	beqz	a0,80001544 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001518:	6605                	lui	a2,0x1
    8000151a:	4581                	li	a1,0
    8000151c:	00000097          	auipc	ra,0x0
    80001520:	80a080e7          	jalr	-2038(ra) # 80000d26 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001524:	4779                	li	a4,30
    80001526:	86a6                	mv	a3,s1
    80001528:	6605                	lui	a2,0x1
    8000152a:	85ca                	mv	a1,s2
    8000152c:	8556                	mv	a0,s5
    8000152e:	00000097          	auipc	ra,0x0
    80001532:	c2a080e7          	jalr	-982(ra) # 80001158 <mappages>
    80001536:	e905                	bnez	a0,80001566 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001538:	6785                	lui	a5,0x1
    8000153a:	993e                	add	s2,s2,a5
    8000153c:	fd4968e3          	bltu	s2,s4,8000150c <uvmalloc+0x2c>
  return newsz;
    80001540:	8552                	mv	a0,s4
    80001542:	a809                	j	80001554 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80001544:	864e                	mv	a2,s3
    80001546:	85ca                	mv	a1,s2
    80001548:	8556                	mv	a0,s5
    8000154a:	00000097          	auipc	ra,0x0
    8000154e:	f4e080e7          	jalr	-178(ra) # 80001498 <uvmdealloc>
      return 0;
    80001552:	4501                	li	a0,0
}
    80001554:	70e2                	ld	ra,56(sp)
    80001556:	7442                	ld	s0,48(sp)
    80001558:	74a2                	ld	s1,40(sp)
    8000155a:	7902                	ld	s2,32(sp)
    8000155c:	69e2                	ld	s3,24(sp)
    8000155e:	6a42                	ld	s4,16(sp)
    80001560:	6aa2                	ld	s5,8(sp)
    80001562:	6121                	addi	sp,sp,64
    80001564:	8082                	ret
      kfree(mem);
    80001566:	8526                	mv	a0,s1
    80001568:	fffff097          	auipc	ra,0xfffff
    8000156c:	4bc080e7          	jalr	1212(ra) # 80000a24 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001570:	864e                	mv	a2,s3
    80001572:	85ca                	mv	a1,s2
    80001574:	8556                	mv	a0,s5
    80001576:	00000097          	auipc	ra,0x0
    8000157a:	f22080e7          	jalr	-222(ra) # 80001498 <uvmdealloc>
      return 0;
    8000157e:	4501                	li	a0,0
    80001580:	bfd1                	j	80001554 <uvmalloc+0x74>
    return oldsz;
    80001582:	852e                	mv	a0,a1
}
    80001584:	8082                	ret
  return newsz;
    80001586:	8532                	mv	a0,a2
    80001588:	b7f1                	j	80001554 <uvmalloc+0x74>

000000008000158a <kvmdealloc>:

// Just like uvmdealloc, but without freeing the memory.
// Used for syncing up kernel page-table's mapping of user memory.
uint64
kvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000158a:	1101                	addi	sp,sp,-32
    8000158c:	ec06                	sd	ra,24(sp)
    8000158e:	e822                	sd	s0,16(sp)
    80001590:	e426                	sd	s1,8(sp)
    80001592:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001594:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001596:	00b67d63          	bgeu	a2,a1,800015b0 <kvmdealloc+0x26>
    8000159a:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000159c:	6785                	lui	a5,0x1
    8000159e:	17fd                	addi	a5,a5,-1
    800015a0:	00f60733          	add	a4,a2,a5
    800015a4:	767d                	lui	a2,0xfffff
    800015a6:	8f71                	and	a4,a4,a2
    800015a8:	97ae                	add	a5,a5,a1
    800015aa:	8ff1                	and	a5,a5,a2
    800015ac:	00f76863          	bltu	a4,a5,800015bc <kvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 0);
  }

  return newsz;
}
    800015b0:	8526                	mv	a0,s1
    800015b2:	60e2                	ld	ra,24(sp)
    800015b4:	6442                	ld	s0,16(sp)
    800015b6:	64a2                	ld	s1,8(sp)
    800015b8:	6105                	addi	sp,sp,32
    800015ba:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800015bc:	8f99                	sub	a5,a5,a4
    800015be:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 0);
    800015c0:	4681                	li	a3,0
    800015c2:	0007861b          	sext.w	a2,a5
    800015c6:	85ba                	mv	a1,a4
    800015c8:	00000097          	auipc	ra,0x0
    800015cc:	d6c080e7          	jalr	-660(ra) # 80001334 <uvmunmap>
    800015d0:	b7c5                	j	800015b0 <kvmdealloc+0x26>

00000000800015d2 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800015d2:	7179                	addi	sp,sp,-48
    800015d4:	f406                	sd	ra,40(sp)
    800015d6:	f022                	sd	s0,32(sp)
    800015d8:	ec26                	sd	s1,24(sp)
    800015da:	e84a                	sd	s2,16(sp)
    800015dc:	e44e                	sd	s3,8(sp)
    800015de:	e052                	sd	s4,0(sp)
    800015e0:	1800                	addi	s0,sp,48
    800015e2:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800015e4:	84aa                	mv	s1,a0
    800015e6:	6905                	lui	s2,0x1
    800015e8:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800015ea:	4985                	li	s3,1
    800015ec:	a821                	j	80001604 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800015ee:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800015f0:	0532                	slli	a0,a0,0xc
    800015f2:	00000097          	auipc	ra,0x0
    800015f6:	fe0080e7          	jalr	-32(ra) # 800015d2 <freewalk>
      pagetable[i] = 0;
    800015fa:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800015fe:	04a1                	addi	s1,s1,8
    80001600:	03248163          	beq	s1,s2,80001622 <freewalk+0x50>
    pte_t pte = pagetable[i];
    80001604:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001606:	00f57793          	andi	a5,a0,15
    8000160a:	ff3782e3          	beq	a5,s3,800015ee <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000160e:	8905                	andi	a0,a0,1
    80001610:	d57d                	beqz	a0,800015fe <freewalk+0x2c>
      panic("freewalk: leaf");
    80001612:	00007517          	auipc	a0,0x7
    80001616:	b5650513          	addi	a0,a0,-1194 # 80008168 <digits+0x138>
    8000161a:	fffff097          	auipc	ra,0xfffff
    8000161e:	f2e080e7          	jalr	-210(ra) # 80000548 <panic>
    }
  }
  kfree((void*)pagetable);
    80001622:	8552                	mv	a0,s4
    80001624:	fffff097          	auipc	ra,0xfffff
    80001628:	400080e7          	jalr	1024(ra) # 80000a24 <kfree>
}
    8000162c:	70a2                	ld	ra,40(sp)
    8000162e:	7402                	ld	s0,32(sp)
    80001630:	64e2                	ld	s1,24(sp)
    80001632:	6942                	ld	s2,16(sp)
    80001634:	69a2                	ld	s3,8(sp)
    80001636:	6a02                	ld	s4,0(sp)
    80001638:	6145                	addi	sp,sp,48
    8000163a:	8082                	ret

000000008000163c <kvm_free_kernelpgtbl>:

// Free a process-specific kernel page-table,
// without freeing the underlying physical memory
void
kvm_free_kernelpgtbl(pagetable_t pagetable)
{
    8000163c:	7179                	addi	sp,sp,-48
    8000163e:	f406                	sd	ra,40(sp)
    80001640:	f022                	sd	s0,32(sp)
    80001642:	ec26                	sd	s1,24(sp)
    80001644:	e84a                	sd	s2,16(sp)
    80001646:	e44e                	sd	s3,8(sp)
    80001648:	e052                	sd	s4,0(sp)
    8000164a:	1800                	addi	s0,sp,48
    8000164c:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000164e:	84aa                	mv	s1,a0
    80001650:	6905                	lui	s2,0x1
    80001652:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    uint64 child = PTE2PA(pte);
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001654:	4985                	li	s3,1
    80001656:	a821                	j	8000166e <kvm_free_kernelpgtbl+0x32>
    uint64 child = PTE2PA(pte);
    80001658:	8129                	srli	a0,a0,0xa
      // this PTE points to a lower-level page table.
      kvm_free_kernelpgtbl((pagetable_t)child);
    8000165a:	0532                	slli	a0,a0,0xc
    8000165c:	00000097          	auipc	ra,0x0
    80001660:	fe0080e7          	jalr	-32(ra) # 8000163c <kvm_free_kernelpgtbl>
      pagetable[i] = 0;
    80001664:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001668:	04a1                	addi	s1,s1,8
    8000166a:	01248863          	beq	s1,s2,8000167a <kvm_free_kernelpgtbl+0x3e>
    pte_t pte = pagetable[i];
    8000166e:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001670:	00f57793          	andi	a5,a0,15
    80001674:	ff379ae3          	bne	a5,s3,80001668 <kvm_free_kernelpgtbl+0x2c>
    80001678:	b7c5                	j	80001658 <kvm_free_kernelpgtbl+0x1c>
    }
  }
  kfree((void*)pagetable);
    8000167a:	8552                	mv	a0,s4
    8000167c:	fffff097          	auipc	ra,0xfffff
    80001680:	3a8080e7          	jalr	936(ra) # 80000a24 <kfree>
}
    80001684:	70a2                	ld	ra,40(sp)
    80001686:	7402                	ld	s0,32(sp)
    80001688:	64e2                	ld	s1,24(sp)
    8000168a:	6942                	ld	s2,16(sp)
    8000168c:	69a2                	ld	s3,8(sp)
    8000168e:	6a02                	ld	s4,0(sp)
    80001690:	6145                	addi	sp,sp,48
    80001692:	8082                	ret

0000000080001694 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001694:	1101                	addi	sp,sp,-32
    80001696:	ec06                	sd	ra,24(sp)
    80001698:	e822                	sd	s0,16(sp)
    8000169a:	e426                	sd	s1,8(sp)
    8000169c:	1000                	addi	s0,sp,32
    8000169e:	84aa                	mv	s1,a0
  if(sz > 0)
    800016a0:	e999                	bnez	a1,800016b6 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800016a2:	8526                	mv	a0,s1
    800016a4:	00000097          	auipc	ra,0x0
    800016a8:	f2e080e7          	jalr	-210(ra) # 800015d2 <freewalk>
}
    800016ac:	60e2                	ld	ra,24(sp)
    800016ae:	6442                	ld	s0,16(sp)
    800016b0:	64a2                	ld	s1,8(sp)
    800016b2:	6105                	addi	sp,sp,32
    800016b4:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800016b6:	6605                	lui	a2,0x1
    800016b8:	167d                	addi	a2,a2,-1
    800016ba:	962e                	add	a2,a2,a1
    800016bc:	4685                	li	a3,1
    800016be:	8231                	srli	a2,a2,0xc
    800016c0:	4581                	li	a1,0
    800016c2:	00000097          	auipc	ra,0x0
    800016c6:	c72080e7          	jalr	-910(ra) # 80001334 <uvmunmap>
    800016ca:	bfe1                	j	800016a2 <uvmfree+0xe>

00000000800016cc <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800016cc:	c679                	beqz	a2,8000179a <uvmcopy+0xce>
{
    800016ce:	715d                	addi	sp,sp,-80
    800016d0:	e486                	sd	ra,72(sp)
    800016d2:	e0a2                	sd	s0,64(sp)
    800016d4:	fc26                	sd	s1,56(sp)
    800016d6:	f84a                	sd	s2,48(sp)
    800016d8:	f44e                	sd	s3,40(sp)
    800016da:	f052                	sd	s4,32(sp)
    800016dc:	ec56                	sd	s5,24(sp)
    800016de:	e85a                	sd	s6,16(sp)
    800016e0:	e45e                	sd	s7,8(sp)
    800016e2:	0880                	addi	s0,sp,80
    800016e4:	8b2a                	mv	s6,a0
    800016e6:	8aae                	mv	s5,a1
    800016e8:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800016ea:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    800016ec:	4601                	li	a2,0
    800016ee:	85ce                	mv	a1,s3
    800016f0:	855a                	mv	a0,s6
    800016f2:	00000097          	auipc	ra,0x0
    800016f6:	928080e7          	jalr	-1752(ra) # 8000101a <walk>
    800016fa:	c531                	beqz	a0,80001746 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800016fc:	6118                	ld	a4,0(a0)
    800016fe:	00177793          	andi	a5,a4,1
    80001702:	cbb1                	beqz	a5,80001756 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001704:	00a75593          	srli	a1,a4,0xa
    80001708:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000170c:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001710:	fffff097          	auipc	ra,0xfffff
    80001714:	42a080e7          	jalr	1066(ra) # 80000b3a <kalloc>
    80001718:	892a                	mv	s2,a0
    8000171a:	c939                	beqz	a0,80001770 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000171c:	6605                	lui	a2,0x1
    8000171e:	85de                	mv	a1,s7
    80001720:	fffff097          	auipc	ra,0xfffff
    80001724:	666080e7          	jalr	1638(ra) # 80000d86 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001728:	8726                	mv	a4,s1
    8000172a:	86ca                	mv	a3,s2
    8000172c:	6605                	lui	a2,0x1
    8000172e:	85ce                	mv	a1,s3
    80001730:	8556                	mv	a0,s5
    80001732:	00000097          	auipc	ra,0x0
    80001736:	a26080e7          	jalr	-1498(ra) # 80001158 <mappages>
    8000173a:	e515                	bnez	a0,80001766 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    8000173c:	6785                	lui	a5,0x1
    8000173e:	99be                	add	s3,s3,a5
    80001740:	fb49e6e3          	bltu	s3,s4,800016ec <uvmcopy+0x20>
    80001744:	a081                	j	80001784 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    80001746:	00007517          	auipc	a0,0x7
    8000174a:	a3250513          	addi	a0,a0,-1486 # 80008178 <digits+0x148>
    8000174e:	fffff097          	auipc	ra,0xfffff
    80001752:	dfa080e7          	jalr	-518(ra) # 80000548 <panic>
      panic("uvmcopy: page not present");
    80001756:	00007517          	auipc	a0,0x7
    8000175a:	a4250513          	addi	a0,a0,-1470 # 80008198 <digits+0x168>
    8000175e:	fffff097          	auipc	ra,0xfffff
    80001762:	dea080e7          	jalr	-534(ra) # 80000548 <panic>
      kfree(mem);
    80001766:	854a                	mv	a0,s2
    80001768:	fffff097          	auipc	ra,0xfffff
    8000176c:	2bc080e7          	jalr	700(ra) # 80000a24 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001770:	4685                	li	a3,1
    80001772:	00c9d613          	srli	a2,s3,0xc
    80001776:	4581                	li	a1,0
    80001778:	8556                	mv	a0,s5
    8000177a:	00000097          	auipc	ra,0x0
    8000177e:	bba080e7          	jalr	-1094(ra) # 80001334 <uvmunmap>
  return -1;
    80001782:	557d                	li	a0,-1
}
    80001784:	60a6                	ld	ra,72(sp)
    80001786:	6406                	ld	s0,64(sp)
    80001788:	74e2                	ld	s1,56(sp)
    8000178a:	7942                	ld	s2,48(sp)
    8000178c:	79a2                	ld	s3,40(sp)
    8000178e:	7a02                	ld	s4,32(sp)
    80001790:	6ae2                	ld	s5,24(sp)
    80001792:	6b42                	ld	s6,16(sp)
    80001794:	6ba2                	ld	s7,8(sp)
    80001796:	6161                	addi	sp,sp,80
    80001798:	8082                	ret
  return 0;
    8000179a:	4501                	li	a0,0
}
    8000179c:	8082                	ret

000000008000179e <kvmcopymappings>:
// Copy some of the mappings from src into dst.
// Only copies the page table and not the physical memory.
// returns 0 on success, -1 on failure.
int
kvmcopymappings(pagetable_t src, pagetable_t dst, uint64 start, uint64 sz)
{
    8000179e:	7139                	addi	sp,sp,-64
    800017a0:	fc06                	sd	ra,56(sp)
    800017a2:	f822                	sd	s0,48(sp)
    800017a4:	f426                	sd	s1,40(sp)
    800017a6:	f04a                	sd	s2,32(sp)
    800017a8:	ec4e                	sd	s3,24(sp)
    800017aa:	e852                	sd	s4,16(sp)
    800017ac:	e456                	sd	s5,8(sp)
    800017ae:	0080                	addi	s0,sp,64
  pte_t *pte;
  uint64 pa, i;
  uint flags;

  // PGROUNDUP: prevent re-mapping already mapped pages (eg. when doing growproc)
  for(i = PGROUNDUP(start); i < start + sz; i += PGSIZE){
    800017b0:	6a05                	lui	s4,0x1
    800017b2:	1a7d                	addi	s4,s4,-1
    800017b4:	9a32                	add	s4,s4,a2
    800017b6:	77fd                	lui	a5,0xfffff
    800017b8:	00fa7a33          	and	s4,s4,a5
    800017bc:	00d60933          	add	s2,a2,a3
    800017c0:	092a7763          	bgeu	s4,s2,8000184e <kvmcopymappings+0xb0>
    800017c4:	8aaa                	mv	s5,a0
    800017c6:	89ae                	mv	s3,a1
    800017c8:	84d2                	mv	s1,s4
    if((pte = walk(src, i, 0)) == 0)
    800017ca:	4601                	li	a2,0
    800017cc:	85a6                	mv	a1,s1
    800017ce:	8556                	mv	a0,s5
    800017d0:	00000097          	auipc	ra,0x0
    800017d4:	84a080e7          	jalr	-1974(ra) # 8000101a <walk>
    800017d8:	c51d                	beqz	a0,80001806 <kvmcopymappings+0x68>
      panic("kvmcopymappings: pte should exist");
    if((*pte & PTE_V) == 0)
    800017da:	6118                	ld	a4,0(a0)
    800017dc:	00177793          	andi	a5,a4,1
    800017e0:	cb9d                	beqz	a5,80001816 <kvmcopymappings+0x78>
      panic("kvmcopymappings: page not present");
    pa = PTE2PA(*pte);
    800017e2:	00a75693          	srli	a3,a4,0xa
    flags = PTE_FLAGS(*pte);
    // `& ~PTE_U` marks the page as kernel page and not user page.
    // Required or else kernel can not access these pages.
    if(mappages(dst, i, PGSIZE, pa, flags & ~PTE_U) != 0){
    800017e6:	3ef77713          	andi	a4,a4,1007
    800017ea:	06b2                	slli	a3,a3,0xc
    800017ec:	6605                	lui	a2,0x1
    800017ee:	85a6                	mv	a1,s1
    800017f0:	854e                	mv	a0,s3
    800017f2:	00000097          	auipc	ra,0x0
    800017f6:	966080e7          	jalr	-1690(ra) # 80001158 <mappages>
    800017fa:	e515                	bnez	a0,80001826 <kvmcopymappings+0x88>
  for(i = PGROUNDUP(start); i < start + sz; i += PGSIZE){
    800017fc:	6785                	lui	a5,0x1
    800017fe:	94be                	add	s1,s1,a5
    80001800:	fd24e5e3          	bltu	s1,s2,800017ca <kvmcopymappings+0x2c>
    80001804:	a825                	j	8000183c <kvmcopymappings+0x9e>
      panic("kvmcopymappings: pte should exist");
    80001806:	00007517          	auipc	a0,0x7
    8000180a:	9b250513          	addi	a0,a0,-1614 # 800081b8 <digits+0x188>
    8000180e:	fffff097          	auipc	ra,0xfffff
    80001812:	d3a080e7          	jalr	-710(ra) # 80000548 <panic>
      panic("kvmcopymappings: page not present");
    80001816:	00007517          	auipc	a0,0x7
    8000181a:	9ca50513          	addi	a0,a0,-1590 # 800081e0 <digits+0x1b0>
    8000181e:	fffff097          	auipc	ra,0xfffff
    80001822:	d2a080e7          	jalr	-726(ra) # 80000548 <panic>
  }

  return 0;

 err:
  uvmunmap(dst, PGROUNDUP(start), (i - PGROUNDUP(start)) / PGSIZE, 0);
    80001826:	41448633          	sub	a2,s1,s4
    8000182a:	4681                	li	a3,0
    8000182c:	8231                	srli	a2,a2,0xc
    8000182e:	85d2                	mv	a1,s4
    80001830:	854e                	mv	a0,s3
    80001832:	00000097          	auipc	ra,0x0
    80001836:	b02080e7          	jalr	-1278(ra) # 80001334 <uvmunmap>
  return -1;
    8000183a:	557d                	li	a0,-1
}
    8000183c:	70e2                	ld	ra,56(sp)
    8000183e:	7442                	ld	s0,48(sp)
    80001840:	74a2                	ld	s1,40(sp)
    80001842:	7902                	ld	s2,32(sp)
    80001844:	69e2                	ld	s3,24(sp)
    80001846:	6a42                	ld	s4,16(sp)
    80001848:	6aa2                	ld	s5,8(sp)
    8000184a:	6121                	addi	sp,sp,64
    8000184c:	8082                	ret
  return 0;
    8000184e:	4501                	li	a0,0
    80001850:	b7f5                	j	8000183c <kvmcopymappings+0x9e>

0000000080001852 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001852:	1141                	addi	sp,sp,-16
    80001854:	e406                	sd	ra,8(sp)
    80001856:	e022                	sd	s0,0(sp)
    80001858:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000185a:	4601                	li	a2,0
    8000185c:	fffff097          	auipc	ra,0xfffff
    80001860:	7be080e7          	jalr	1982(ra) # 8000101a <walk>
  if(pte == 0)
    80001864:	c901                	beqz	a0,80001874 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001866:	611c                	ld	a5,0(a0)
    80001868:	9bbd                	andi	a5,a5,-17
    8000186a:	e11c                	sd	a5,0(a0)
}
    8000186c:	60a2                	ld	ra,8(sp)
    8000186e:	6402                	ld	s0,0(sp)
    80001870:	0141                	addi	sp,sp,16
    80001872:	8082                	ret
    panic("uvmclear");
    80001874:	00007517          	auipc	a0,0x7
    80001878:	99450513          	addi	a0,a0,-1644 # 80008208 <digits+0x1d8>
    8000187c:	fffff097          	auipc	ra,0xfffff
    80001880:	ccc080e7          	jalr	-820(ra) # 80000548 <panic>

0000000080001884 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001884:	c6bd                	beqz	a3,800018f2 <copyout+0x6e>
{
    80001886:	715d                	addi	sp,sp,-80
    80001888:	e486                	sd	ra,72(sp)
    8000188a:	e0a2                	sd	s0,64(sp)
    8000188c:	fc26                	sd	s1,56(sp)
    8000188e:	f84a                	sd	s2,48(sp)
    80001890:	f44e                	sd	s3,40(sp)
    80001892:	f052                	sd	s4,32(sp)
    80001894:	ec56                	sd	s5,24(sp)
    80001896:	e85a                	sd	s6,16(sp)
    80001898:	e45e                	sd	s7,8(sp)
    8000189a:	e062                	sd	s8,0(sp)
    8000189c:	0880                	addi	s0,sp,80
    8000189e:	8b2a                	mv	s6,a0
    800018a0:	8c2e                	mv	s8,a1
    800018a2:	8a32                	mv	s4,a2
    800018a4:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800018a6:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    800018a8:	6a85                	lui	s5,0x1
    800018aa:	a015                	j	800018ce <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800018ac:	9562                	add	a0,a0,s8
    800018ae:	0004861b          	sext.w	a2,s1
    800018b2:	85d2                	mv	a1,s4
    800018b4:	41250533          	sub	a0,a0,s2
    800018b8:	fffff097          	auipc	ra,0xfffff
    800018bc:	4ce080e7          	jalr	1230(ra) # 80000d86 <memmove>

    len -= n;
    800018c0:	409989b3          	sub	s3,s3,s1
    src += n;
    800018c4:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800018c6:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800018ca:	02098263          	beqz	s3,800018ee <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800018ce:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800018d2:	85ca                	mv	a1,s2
    800018d4:	855a                	mv	a0,s6
    800018d6:	fffff097          	auipc	ra,0xfffff
    800018da:	7ea080e7          	jalr	2026(ra) # 800010c0 <walkaddr>
    if(pa0 == 0)
    800018de:	cd01                	beqz	a0,800018f6 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800018e0:	418904b3          	sub	s1,s2,s8
    800018e4:	94d6                	add	s1,s1,s5
    if(n > len)
    800018e6:	fc99f3e3          	bgeu	s3,s1,800018ac <copyout+0x28>
    800018ea:	84ce                	mv	s1,s3
    800018ec:	b7c1                	j	800018ac <copyout+0x28>
  }
  return 0;
    800018ee:	4501                	li	a0,0
    800018f0:	a021                	j	800018f8 <copyout+0x74>
    800018f2:	4501                	li	a0,0
}
    800018f4:	8082                	ret
      return -1;
    800018f6:	557d                	li	a0,-1
}
    800018f8:	60a6                	ld	ra,72(sp)
    800018fa:	6406                	ld	s0,64(sp)
    800018fc:	74e2                	ld	s1,56(sp)
    800018fe:	7942                	ld	s2,48(sp)
    80001900:	79a2                	ld	s3,40(sp)
    80001902:	7a02                	ld	s4,32(sp)
    80001904:	6ae2                	ld	s5,24(sp)
    80001906:	6b42                	ld	s6,16(sp)
    80001908:	6ba2                	ld	s7,8(sp)
    8000190a:	6c02                	ld	s8,0(sp)
    8000190c:	6161                	addi	sp,sp,80
    8000190e:	8082                	ret

0000000080001910 <copyin>:
// Copy from user to kernel.
// Copy len bytes to dst from virtual address srcva in a given page table.
// Return 0 on success, -1 on error.
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
    80001910:	1141                	addi	sp,sp,-16
    80001912:	e406                	sd	ra,8(sp)
    80001914:	e022                	sd	s0,0(sp)
    80001916:	0800                	addi	s0,sp,16
  // printf("trace: copyin1 %p\n", *walk(pagetable, srcva, 0));
  // printf("trace: copyin2 %p\n", *walk(myproc()->kernelpgtbl, srcva, 0));
  // printf("trace: copyin3 %p\n", *(uint64*)srcva);
  return copyin_new(pagetable, dst, srcva, len);
    80001918:	00005097          	auipc	ra,0x5
    8000191c:	b94080e7          	jalr	-1132(ra) # 800064ac <copyin_new>
}
    80001920:	60a2                	ld	ra,8(sp)
    80001922:	6402                	ld	s0,0(sp)
    80001924:	0141                	addi	sp,sp,16
    80001926:	8082                	ret

0000000080001928 <copyinstr>:
// Copy bytes to dst from virtual address srcva in a given page table,
// until a '\0', or max.
// Return 0 on success, -1 on error.
int
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
    80001928:	1141                	addi	sp,sp,-16
    8000192a:	e406                	sd	ra,8(sp)
    8000192c:	e022                	sd	s0,0(sp)
    8000192e:	0800                	addi	s0,sp,16
  // printf("trace: copyinstr %p\n", walk(pagetable, srcva, 0));
  return copyinstr_new(pagetable, dst, srcva, max);
    80001930:	00005097          	auipc	ra,0x5
    80001934:	be4080e7          	jalr	-1052(ra) # 80006514 <copyinstr_new>
}
    80001938:	60a2                	ld	ra,8(sp)
    8000193a:	6402                	ld	s0,0(sp)
    8000193c:	0141                	addi	sp,sp,16
    8000193e:	8082                	ret

0000000080001940 <pgtblprint>:

int pgtblprint(pagetable_t pagetable, int depth) {
    80001940:	7159                	addi	sp,sp,-112
    80001942:	f486                	sd	ra,104(sp)
    80001944:	f0a2                	sd	s0,96(sp)
    80001946:	eca6                	sd	s1,88(sp)
    80001948:	e8ca                	sd	s2,80(sp)
    8000194a:	e4ce                	sd	s3,72(sp)
    8000194c:	e0d2                	sd	s4,64(sp)
    8000194e:	fc56                	sd	s5,56(sp)
    80001950:	f85a                	sd	s6,48(sp)
    80001952:	f45e                	sd	s7,40(sp)
    80001954:	f062                	sd	s8,32(sp)
    80001956:	ec66                	sd	s9,24(sp)
    80001958:	e86a                	sd	s10,16(sp)
    8000195a:	e46e                	sd	s11,8(sp)
    8000195c:	1880                	addi	s0,sp,112
    8000195e:	8aae                	mv	s5,a1
    // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001960:	89aa                	mv	s3,a0
    80001962:	4901                	li	s2,0
    pte_t pte = pagetable[i];
    if(pte & PTE_V) {
      // print
      printf("..");
    80001964:	00007c97          	auipc	s9,0x7
    80001968:	8b4c8c93          	addi	s9,s9,-1868 # 80008218 <digits+0x1e8>
      for(int j=0;j<depth;j++) {
        printf(" ..");
      }
      printf("%d: pte %p pa %p\n", i, pte, PTE2PA(pte));
    8000196c:	00007c17          	auipc	s8,0x7
    80001970:	8bcc0c13          	addi	s8,s8,-1860 # 80008228 <digits+0x1f8>

      // if not a leaf page table, recursively print out the child table
      if((pte & (PTE_R|PTE_W|PTE_X)) == 0){
        // this PTE points to a lower-level page table.
        uint64 child = PTE2PA(pte);
        pgtblprint((pagetable_t)child,depth+1);
    80001974:	00158d9b          	addiw	s11,a1,1
      for(int j=0;j<depth;j++) {
    80001978:	4d01                	li	s10,0
        printf(" ..");
    8000197a:	00007b17          	auipc	s6,0x7
    8000197e:	8a6b0b13          	addi	s6,s6,-1882 # 80008220 <digits+0x1f0>
  for(int i = 0; i < 512; i++){
    80001982:	20000b93          	li	s7,512
    80001986:	a029                	j	80001990 <pgtblprint+0x50>
    80001988:	2905                	addiw	s2,s2,1
    8000198a:	09a1                	addi	s3,s3,8
    8000198c:	05790d63          	beq	s2,s7,800019e6 <pgtblprint+0xa6>
    pte_t pte = pagetable[i];
    80001990:	0009ba03          	ld	s4,0(s3) # fffffffffffff000 <end+0xffffffff7ffd7fe0>
    if(pte & PTE_V) {
    80001994:	001a7793          	andi	a5,s4,1
    80001998:	dbe5                	beqz	a5,80001988 <pgtblprint+0x48>
      printf("..");
    8000199a:	8566                	mv	a0,s9
    8000199c:	fffff097          	auipc	ra,0xfffff
    800019a0:	bf6080e7          	jalr	-1034(ra) # 80000592 <printf>
      for(int j=0;j<depth;j++) {
    800019a4:	01505b63          	blez	s5,800019ba <pgtblprint+0x7a>
    800019a8:	84ea                	mv	s1,s10
        printf(" ..");
    800019aa:	855a                	mv	a0,s6
    800019ac:	fffff097          	auipc	ra,0xfffff
    800019b0:	be6080e7          	jalr	-1050(ra) # 80000592 <printf>
      for(int j=0;j<depth;j++) {
    800019b4:	2485                	addiw	s1,s1,1
    800019b6:	fe9a9ae3          	bne	s5,s1,800019aa <pgtblprint+0x6a>
      printf("%d: pte %p pa %p\n", i, pte, PTE2PA(pte));
    800019ba:	00aa5493          	srli	s1,s4,0xa
    800019be:	04b2                	slli	s1,s1,0xc
    800019c0:	86a6                	mv	a3,s1
    800019c2:	8652                	mv	a2,s4
    800019c4:	85ca                	mv	a1,s2
    800019c6:	8562                	mv	a0,s8
    800019c8:	fffff097          	auipc	ra,0xfffff
    800019cc:	bca080e7          	jalr	-1078(ra) # 80000592 <printf>
      if((pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800019d0:	00ea7a13          	andi	s4,s4,14
    800019d4:	fa0a1ae3          	bnez	s4,80001988 <pgtblprint+0x48>
        pgtblprint((pagetable_t)child,depth+1);
    800019d8:	85ee                	mv	a1,s11
    800019da:	8526                	mv	a0,s1
    800019dc:	00000097          	auipc	ra,0x0
    800019e0:	f64080e7          	jalr	-156(ra) # 80001940 <pgtblprint>
    800019e4:	b755                	j	80001988 <pgtblprint+0x48>
      }
    }
  }
  return 0;
}
    800019e6:	4501                	li	a0,0
    800019e8:	70a6                	ld	ra,104(sp)
    800019ea:	7406                	ld	s0,96(sp)
    800019ec:	64e6                	ld	s1,88(sp)
    800019ee:	6946                	ld	s2,80(sp)
    800019f0:	69a6                	ld	s3,72(sp)
    800019f2:	6a06                	ld	s4,64(sp)
    800019f4:	7ae2                	ld	s5,56(sp)
    800019f6:	7b42                	ld	s6,48(sp)
    800019f8:	7ba2                	ld	s7,40(sp)
    800019fa:	7c02                	ld	s8,32(sp)
    800019fc:	6ce2                	ld	s9,24(sp)
    800019fe:	6d42                	ld	s10,16(sp)
    80001a00:	6da2                	ld	s11,8(sp)
    80001a02:	6165                	addi	sp,sp,112
    80001a04:	8082                	ret

0000000080001a06 <vmprint>:

int vmprint(pagetable_t pagetable) {
    80001a06:	1101                	addi	sp,sp,-32
    80001a08:	ec06                	sd	ra,24(sp)
    80001a0a:	e822                	sd	s0,16(sp)
    80001a0c:	e426                	sd	s1,8(sp)
    80001a0e:	1000                	addi	s0,sp,32
    80001a10:	84aa                	mv	s1,a0
  printf("page table %p\n", pagetable);
    80001a12:	85aa                	mv	a1,a0
    80001a14:	00007517          	auipc	a0,0x7
    80001a18:	82c50513          	addi	a0,a0,-2004 # 80008240 <digits+0x210>
    80001a1c:	fffff097          	auipc	ra,0xfffff
    80001a20:	b76080e7          	jalr	-1162(ra) # 80000592 <printf>
  return pgtblprint(pagetable, 0);
    80001a24:	4581                	li	a1,0
    80001a26:	8526                	mv	a0,s1
    80001a28:	00000097          	auipc	ra,0x0
    80001a2c:	f18080e7          	jalr	-232(ra) # 80001940 <pgtblprint>
    80001a30:	60e2                	ld	ra,24(sp)
    80001a32:	6442                	ld	s0,16(sp)
    80001a34:	64a2                	ld	s1,8(sp)
    80001a36:	6105                	addi	sp,sp,32
    80001a38:	8082                	ret

0000000080001a3a <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    80001a3a:	1101                	addi	sp,sp,-32
    80001a3c:	ec06                	sd	ra,24(sp)
    80001a3e:	e822                	sd	s0,16(sp)
    80001a40:	e426                	sd	s1,8(sp)
    80001a42:	1000                	addi	s0,sp,32
    80001a44:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001a46:	fffff097          	auipc	ra,0xfffff
    80001a4a:	16a080e7          	jalr	362(ra) # 80000bb0 <holding>
    80001a4e:	c909                	beqz	a0,80001a60 <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    80001a50:	749c                	ld	a5,40(s1)
    80001a52:	00978f63          	beq	a5,s1,80001a70 <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    80001a56:	60e2                	ld	ra,24(sp)
    80001a58:	6442                	ld	s0,16(sp)
    80001a5a:	64a2                	ld	s1,8(sp)
    80001a5c:	6105                	addi	sp,sp,32
    80001a5e:	8082                	ret
    panic("wakeup1");
    80001a60:	00006517          	auipc	a0,0x6
    80001a64:	7f050513          	addi	a0,a0,2032 # 80008250 <digits+0x220>
    80001a68:	fffff097          	auipc	ra,0xfffff
    80001a6c:	ae0080e7          	jalr	-1312(ra) # 80000548 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    80001a70:	4c98                	lw	a4,24(s1)
    80001a72:	4785                	li	a5,1
    80001a74:	fef711e3          	bne	a4,a5,80001a56 <wakeup1+0x1c>
    p->state = RUNNABLE;
    80001a78:	4789                	li	a5,2
    80001a7a:	cc9c                	sw	a5,24(s1)
}
    80001a7c:	bfe9                	j	80001a56 <wakeup1+0x1c>

0000000080001a7e <procinit>:
{
    80001a7e:	7179                	addi	sp,sp,-48
    80001a80:	f406                	sd	ra,40(sp)
    80001a82:	f022                	sd	s0,32(sp)
    80001a84:	ec26                	sd	s1,24(sp)
    80001a86:	e84a                	sd	s2,16(sp)
    80001a88:	e44e                	sd	s3,8(sp)
    80001a8a:	1800                	addi	s0,sp,48
  initlock(&pid_lock, "nextpid");
    80001a8c:	00006597          	auipc	a1,0x6
    80001a90:	7cc58593          	addi	a1,a1,1996 # 80008258 <digits+0x228>
    80001a94:	00010517          	auipc	a0,0x10
    80001a98:	ebc50513          	addi	a0,a0,-324 # 80011950 <pid_lock>
    80001a9c:	fffff097          	auipc	ra,0xfffff
    80001aa0:	0fe080e7          	jalr	254(ra) # 80000b9a <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001aa4:	00010497          	auipc	s1,0x10
    80001aa8:	2c448493          	addi	s1,s1,708 # 80011d68 <proc>
      initlock(&p->lock, "proc");
    80001aac:	00006997          	auipc	s3,0x6
    80001ab0:	7b498993          	addi	s3,s3,1972 # 80008260 <digits+0x230>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ab4:	00016917          	auipc	s2,0x16
    80001ab8:	eb490913          	addi	s2,s2,-332 # 80017968 <tickslock>
      initlock(&p->lock, "proc");
    80001abc:	85ce                	mv	a1,s3
    80001abe:	8526                	mv	a0,s1
    80001ac0:	fffff097          	auipc	ra,0xfffff
    80001ac4:	0da080e7          	jalr	218(ra) # 80000b9a <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ac8:	17048493          	addi	s1,s1,368
    80001acc:	ff2498e3          	bne	s1,s2,80001abc <procinit+0x3e>
  kvminithart();
    80001ad0:	fffff097          	auipc	ra,0xfffff
    80001ad4:	526080e7          	jalr	1318(ra) # 80000ff6 <kvminithart>
}
    80001ad8:	70a2                	ld	ra,40(sp)
    80001ada:	7402                	ld	s0,32(sp)
    80001adc:	64e2                	ld	s1,24(sp)
    80001ade:	6942                	ld	s2,16(sp)
    80001ae0:	69a2                	ld	s3,8(sp)
    80001ae2:	6145                	addi	sp,sp,48
    80001ae4:	8082                	ret

0000000080001ae6 <cpuid>:
{
    80001ae6:	1141                	addi	sp,sp,-16
    80001ae8:	e422                	sd	s0,8(sp)
    80001aea:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001aec:	8512                	mv	a0,tp
}
    80001aee:	2501                	sext.w	a0,a0
    80001af0:	6422                	ld	s0,8(sp)
    80001af2:	0141                	addi	sp,sp,16
    80001af4:	8082                	ret

0000000080001af6 <mycpu>:
mycpu(void) {
    80001af6:	1141                	addi	sp,sp,-16
    80001af8:	e422                	sd	s0,8(sp)
    80001afa:	0800                	addi	s0,sp,16
    80001afc:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001afe:	2781                	sext.w	a5,a5
    80001b00:	079e                	slli	a5,a5,0x7
}
    80001b02:	00010517          	auipc	a0,0x10
    80001b06:	e6650513          	addi	a0,a0,-410 # 80011968 <cpus>
    80001b0a:	953e                	add	a0,a0,a5
    80001b0c:	6422                	ld	s0,8(sp)
    80001b0e:	0141                	addi	sp,sp,16
    80001b10:	8082                	ret

0000000080001b12 <myproc>:
myproc(void) {
    80001b12:	1101                	addi	sp,sp,-32
    80001b14:	ec06                	sd	ra,24(sp)
    80001b16:	e822                	sd	s0,16(sp)
    80001b18:	e426                	sd	s1,8(sp)
    80001b1a:	1000                	addi	s0,sp,32
  push_off();
    80001b1c:	fffff097          	auipc	ra,0xfffff
    80001b20:	0c2080e7          	jalr	194(ra) # 80000bde <push_off>
    80001b24:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001b26:	2781                	sext.w	a5,a5
    80001b28:	079e                	slli	a5,a5,0x7
    80001b2a:	00010717          	auipc	a4,0x10
    80001b2e:	e2670713          	addi	a4,a4,-474 # 80011950 <pid_lock>
    80001b32:	97ba                	add	a5,a5,a4
    80001b34:	6f84                	ld	s1,24(a5)
  pop_off();
    80001b36:	fffff097          	auipc	ra,0xfffff
    80001b3a:	148080e7          	jalr	328(ra) # 80000c7e <pop_off>
}
    80001b3e:	8526                	mv	a0,s1
    80001b40:	60e2                	ld	ra,24(sp)
    80001b42:	6442                	ld	s0,16(sp)
    80001b44:	64a2                	ld	s1,8(sp)
    80001b46:	6105                	addi	sp,sp,32
    80001b48:	8082                	ret

0000000080001b4a <forkret>:
{
    80001b4a:	1141                	addi	sp,sp,-16
    80001b4c:	e406                	sd	ra,8(sp)
    80001b4e:	e022                	sd	s0,0(sp)
    80001b50:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001b52:	00000097          	auipc	ra,0x0
    80001b56:	fc0080e7          	jalr	-64(ra) # 80001b12 <myproc>
    80001b5a:	fffff097          	auipc	ra,0xfffff
    80001b5e:	184080e7          	jalr	388(ra) # 80000cde <release>
  if (first) {
    80001b62:	00007797          	auipc	a5,0x7
    80001b66:	d6e7a783          	lw	a5,-658(a5) # 800088d0 <first.1690>
    80001b6a:	eb89                	bnez	a5,80001b7c <forkret+0x32>
  usertrapret();
    80001b6c:	00001097          	auipc	ra,0x1
    80001b70:	d34080e7          	jalr	-716(ra) # 800028a0 <usertrapret>
}
    80001b74:	60a2                	ld	ra,8(sp)
    80001b76:	6402                	ld	s0,0(sp)
    80001b78:	0141                	addi	sp,sp,16
    80001b7a:	8082                	ret
    first = 0;
    80001b7c:	00007797          	auipc	a5,0x7
    80001b80:	d407aa23          	sw	zero,-684(a5) # 800088d0 <first.1690>
    fsinit(ROOTDEV);
    80001b84:	4505                	li	a0,1
    80001b86:	00002097          	auipc	ra,0x2
    80001b8a:	a5c080e7          	jalr	-1444(ra) # 800035e2 <fsinit>
    80001b8e:	bff9                	j	80001b6c <forkret+0x22>

0000000080001b90 <allocpid>:
allocpid() {
    80001b90:	1101                	addi	sp,sp,-32
    80001b92:	ec06                	sd	ra,24(sp)
    80001b94:	e822                	sd	s0,16(sp)
    80001b96:	e426                	sd	s1,8(sp)
    80001b98:	e04a                	sd	s2,0(sp)
    80001b9a:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001b9c:	00010917          	auipc	s2,0x10
    80001ba0:	db490913          	addi	s2,s2,-588 # 80011950 <pid_lock>
    80001ba4:	854a                	mv	a0,s2
    80001ba6:	fffff097          	auipc	ra,0xfffff
    80001baa:	084080e7          	jalr	132(ra) # 80000c2a <acquire>
  pid = nextpid;
    80001bae:	00007797          	auipc	a5,0x7
    80001bb2:	d2678793          	addi	a5,a5,-730 # 800088d4 <nextpid>
    80001bb6:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001bb8:	0014871b          	addiw	a4,s1,1
    80001bbc:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001bbe:	854a                	mv	a0,s2
    80001bc0:	fffff097          	auipc	ra,0xfffff
    80001bc4:	11e080e7          	jalr	286(ra) # 80000cde <release>
}
    80001bc8:	8526                	mv	a0,s1
    80001bca:	60e2                	ld	ra,24(sp)
    80001bcc:	6442                	ld	s0,16(sp)
    80001bce:	64a2                	ld	s1,8(sp)
    80001bd0:	6902                	ld	s2,0(sp)
    80001bd2:	6105                	addi	sp,sp,32
    80001bd4:	8082                	ret

0000000080001bd6 <proc_pagetable>:
{
    80001bd6:	1101                	addi	sp,sp,-32
    80001bd8:	ec06                	sd	ra,24(sp)
    80001bda:	e822                	sd	s0,16(sp)
    80001bdc:	e426                	sd	s1,8(sp)
    80001bde:	e04a                	sd	s2,0(sp)
    80001be0:	1000                	addi	s0,sp,32
    80001be2:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001be4:	00000097          	auipc	ra,0x0
    80001be8:	814080e7          	jalr	-2028(ra) # 800013f8 <uvmcreate>
    80001bec:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001bee:	c121                	beqz	a0,80001c2e <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001bf0:	4729                	li	a4,10
    80001bf2:	00005697          	auipc	a3,0x5
    80001bf6:	40e68693          	addi	a3,a3,1038 # 80007000 <_trampoline>
    80001bfa:	6605                	lui	a2,0x1
    80001bfc:	040005b7          	lui	a1,0x4000
    80001c00:	15fd                	addi	a1,a1,-1
    80001c02:	05b2                	slli	a1,a1,0xc
    80001c04:	fffff097          	auipc	ra,0xfffff
    80001c08:	554080e7          	jalr	1364(ra) # 80001158 <mappages>
    80001c0c:	02054863          	bltz	a0,80001c3c <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001c10:	4719                	li	a4,6
    80001c12:	05893683          	ld	a3,88(s2)
    80001c16:	6605                	lui	a2,0x1
    80001c18:	020005b7          	lui	a1,0x2000
    80001c1c:	15fd                	addi	a1,a1,-1
    80001c1e:	05b6                	slli	a1,a1,0xd
    80001c20:	8526                	mv	a0,s1
    80001c22:	fffff097          	auipc	ra,0xfffff
    80001c26:	536080e7          	jalr	1334(ra) # 80001158 <mappages>
    80001c2a:	02054163          	bltz	a0,80001c4c <proc_pagetable+0x76>
}
    80001c2e:	8526                	mv	a0,s1
    80001c30:	60e2                	ld	ra,24(sp)
    80001c32:	6442                	ld	s0,16(sp)
    80001c34:	64a2                	ld	s1,8(sp)
    80001c36:	6902                	ld	s2,0(sp)
    80001c38:	6105                	addi	sp,sp,32
    80001c3a:	8082                	ret
    uvmfree(pagetable, 0);
    80001c3c:	4581                	li	a1,0
    80001c3e:	8526                	mv	a0,s1
    80001c40:	00000097          	auipc	ra,0x0
    80001c44:	a54080e7          	jalr	-1452(ra) # 80001694 <uvmfree>
    return 0;
    80001c48:	4481                	li	s1,0
    80001c4a:	b7d5                	j	80001c2e <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c4c:	4681                	li	a3,0
    80001c4e:	4605                	li	a2,1
    80001c50:	040005b7          	lui	a1,0x4000
    80001c54:	15fd                	addi	a1,a1,-1
    80001c56:	05b2                	slli	a1,a1,0xc
    80001c58:	8526                	mv	a0,s1
    80001c5a:	fffff097          	auipc	ra,0xfffff
    80001c5e:	6da080e7          	jalr	1754(ra) # 80001334 <uvmunmap>
    uvmfree(pagetable, 0);
    80001c62:	4581                	li	a1,0
    80001c64:	8526                	mv	a0,s1
    80001c66:	00000097          	auipc	ra,0x0
    80001c6a:	a2e080e7          	jalr	-1490(ra) # 80001694 <uvmfree>
    return 0;
    80001c6e:	4481                	li	s1,0
    80001c70:	bf7d                	j	80001c2e <proc_pagetable+0x58>

0000000080001c72 <proc_freepagetable>:
{
    80001c72:	1101                	addi	sp,sp,-32
    80001c74:	ec06                	sd	ra,24(sp)
    80001c76:	e822                	sd	s0,16(sp)
    80001c78:	e426                	sd	s1,8(sp)
    80001c7a:	e04a                	sd	s2,0(sp)
    80001c7c:	1000                	addi	s0,sp,32
    80001c7e:	84aa                	mv	s1,a0
    80001c80:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c82:	4681                	li	a3,0
    80001c84:	4605                	li	a2,1
    80001c86:	040005b7          	lui	a1,0x4000
    80001c8a:	15fd                	addi	a1,a1,-1
    80001c8c:	05b2                	slli	a1,a1,0xc
    80001c8e:	fffff097          	auipc	ra,0xfffff
    80001c92:	6a6080e7          	jalr	1702(ra) # 80001334 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001c96:	4681                	li	a3,0
    80001c98:	4605                	li	a2,1
    80001c9a:	020005b7          	lui	a1,0x2000
    80001c9e:	15fd                	addi	a1,a1,-1
    80001ca0:	05b6                	slli	a1,a1,0xd
    80001ca2:	8526                	mv	a0,s1
    80001ca4:	fffff097          	auipc	ra,0xfffff
    80001ca8:	690080e7          	jalr	1680(ra) # 80001334 <uvmunmap>
  uvmfree(pagetable, sz);
    80001cac:	85ca                	mv	a1,s2
    80001cae:	8526                	mv	a0,s1
    80001cb0:	00000097          	auipc	ra,0x0
    80001cb4:	9e4080e7          	jalr	-1564(ra) # 80001694 <uvmfree>
}
    80001cb8:	60e2                	ld	ra,24(sp)
    80001cba:	6442                	ld	s0,16(sp)
    80001cbc:	64a2                	ld	s1,8(sp)
    80001cbe:	6902                	ld	s2,0(sp)
    80001cc0:	6105                	addi	sp,sp,32
    80001cc2:	8082                	ret

0000000080001cc4 <freeproc>:
{
    80001cc4:	1101                	addi	sp,sp,-32
    80001cc6:	ec06                	sd	ra,24(sp)
    80001cc8:	e822                	sd	s0,16(sp)
    80001cca:	e426                	sd	s1,8(sp)
    80001ccc:	1000                	addi	s0,sp,32
    80001cce:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001cd0:	6d28                	ld	a0,88(a0)
    80001cd2:	c509                	beqz	a0,80001cdc <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001cd4:	fffff097          	auipc	ra,0xfffff
    80001cd8:	d50080e7          	jalr	-688(ra) # 80000a24 <kfree>
  p->trapframe = 0;
    80001cdc:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001ce0:	68a8                	ld	a0,80(s1)
    80001ce2:	c511                	beqz	a0,80001cee <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001ce4:	64ac                	ld	a1,72(s1)
    80001ce6:	00000097          	auipc	ra,0x0
    80001cea:	f8c080e7          	jalr	-116(ra) # 80001c72 <proc_freepagetable>
  p->pagetable = 0;
    80001cee:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001cf2:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001cf6:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80001cfa:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80001cfe:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001d02:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001d06:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80001d0a:	0204aa23          	sw	zero,52(s1)
  void *kstack_pa = (void *)kvmpa(p->kernelpgtbl, p->kstack);
    80001d0e:	60ac                	ld	a1,64(s1)
    80001d10:	1684b503          	ld	a0,360(s1)
    80001d14:	fffff097          	auipc	ra,0xfffff
    80001d18:	3ee080e7          	jalr	1006(ra) # 80001102 <kvmpa>
  kfree(kstack_pa);
    80001d1c:	fffff097          	auipc	ra,0xfffff
    80001d20:	d08080e7          	jalr	-760(ra) # 80000a24 <kfree>
  p->kstack = 0;
    80001d24:	0404b023          	sd	zero,64(s1)
  kvm_free_kernelpgtbl(p->kernelpgtbl);
    80001d28:	1684b503          	ld	a0,360(s1)
    80001d2c:	00000097          	auipc	ra,0x0
    80001d30:	910080e7          	jalr	-1776(ra) # 8000163c <kvm_free_kernelpgtbl>
  p->kernelpgtbl = 0;
    80001d34:	1604b423          	sd	zero,360(s1)
  p->state = UNUSED;
    80001d38:	0004ac23          	sw	zero,24(s1)
}
    80001d3c:	60e2                	ld	ra,24(sp)
    80001d3e:	6442                	ld	s0,16(sp)
    80001d40:	64a2                	ld	s1,8(sp)
    80001d42:	6105                	addi	sp,sp,32
    80001d44:	8082                	ret

0000000080001d46 <allocproc>:
{
    80001d46:	1101                	addi	sp,sp,-32
    80001d48:	ec06                	sd	ra,24(sp)
    80001d4a:	e822                	sd	s0,16(sp)
    80001d4c:	e426                	sd	s1,8(sp)
    80001d4e:	e04a                	sd	s2,0(sp)
    80001d50:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d52:	00010497          	auipc	s1,0x10
    80001d56:	01648493          	addi	s1,s1,22 # 80011d68 <proc>
    80001d5a:	00016917          	auipc	s2,0x16
    80001d5e:	c0e90913          	addi	s2,s2,-1010 # 80017968 <tickslock>
    acquire(&p->lock);
    80001d62:	8526                	mv	a0,s1
    80001d64:	fffff097          	auipc	ra,0xfffff
    80001d68:	ec6080e7          	jalr	-314(ra) # 80000c2a <acquire>
    if(p->state == UNUSED) {
    80001d6c:	4c9c                	lw	a5,24(s1)
    80001d6e:	cf81                	beqz	a5,80001d86 <allocproc+0x40>
      release(&p->lock);
    80001d70:	8526                	mv	a0,s1
    80001d72:	fffff097          	auipc	ra,0xfffff
    80001d76:	f6c080e7          	jalr	-148(ra) # 80000cde <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d7a:	17048493          	addi	s1,s1,368
    80001d7e:	ff2492e3          	bne	s1,s2,80001d62 <allocproc+0x1c>
  return 0;
    80001d82:	4481                	li	s1,0
    80001d84:	a059                	j	80001e0a <allocproc+0xc4>
  p->pid = allocpid();
    80001d86:	00000097          	auipc	ra,0x0
    80001d8a:	e0a080e7          	jalr	-502(ra) # 80001b90 <allocpid>
    80001d8e:	dc88                	sw	a0,56(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001d90:	fffff097          	auipc	ra,0xfffff
    80001d94:	daa080e7          	jalr	-598(ra) # 80000b3a <kalloc>
    80001d98:	892a                	mv	s2,a0
    80001d9a:	eca8                	sd	a0,88(s1)
    80001d9c:	cd35                	beqz	a0,80001e18 <allocproc+0xd2>
  p->pagetable = proc_pagetable(p);
    80001d9e:	8526                	mv	a0,s1
    80001da0:	00000097          	auipc	ra,0x0
    80001da4:	e36080e7          	jalr	-458(ra) # 80001bd6 <proc_pagetable>
    80001da8:	892a                	mv	s2,a0
    80001daa:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001dac:	cd2d                	beqz	a0,80001e26 <allocproc+0xe0>
  p->kernelpgtbl = kvminit_newpgtbl();
    80001dae:	fffff097          	auipc	ra,0xfffff
    80001db2:	51c080e7          	jalr	1308(ra) # 800012ca <kvminit_newpgtbl>
    80001db6:	16a4b423          	sd	a0,360(s1)
  char *pa = kalloc();
    80001dba:	fffff097          	auipc	ra,0xfffff
    80001dbe:	d80080e7          	jalr	-640(ra) # 80000b3a <kalloc>
    80001dc2:	862a                	mv	a2,a0
  if(pa == 0)
    80001dc4:	cd2d                	beqz	a0,80001e3e <allocproc+0xf8>
  kvmmap(p->kernelpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001dc6:	4719                	li	a4,6
    80001dc8:	6685                	lui	a3,0x1
    80001dca:	04000937          	lui	s2,0x4000
    80001dce:	1975                	addi	s2,s2,-3
    80001dd0:	00c91593          	slli	a1,s2,0xc
    80001dd4:	1684b503          	ld	a0,360(s1)
    80001dd8:	fffff097          	auipc	ra,0xfffff
    80001ddc:	40e080e7          	jalr	1038(ra) # 800011e6 <kvmmap>
  p->kstack = va;
    80001de0:	0932                	slli	s2,s2,0xc
    80001de2:	0524b023          	sd	s2,64(s1)
  memset(&p->context, 0, sizeof(p->context));
    80001de6:	07000613          	li	a2,112
    80001dea:	4581                	li	a1,0
    80001dec:	06048513          	addi	a0,s1,96
    80001df0:	fffff097          	auipc	ra,0xfffff
    80001df4:	f36080e7          	jalr	-202(ra) # 80000d26 <memset>
  p->context.ra = (uint64)forkret;
    80001df8:	00000797          	auipc	a5,0x0
    80001dfc:	d5278793          	addi	a5,a5,-686 # 80001b4a <forkret>
    80001e00:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001e02:	60bc                	ld	a5,64(s1)
    80001e04:	6705                	lui	a4,0x1
    80001e06:	97ba                	add	a5,a5,a4
    80001e08:	f4bc                	sd	a5,104(s1)
}
    80001e0a:	8526                	mv	a0,s1
    80001e0c:	60e2                	ld	ra,24(sp)
    80001e0e:	6442                	ld	s0,16(sp)
    80001e10:	64a2                	ld	s1,8(sp)
    80001e12:	6902                	ld	s2,0(sp)
    80001e14:	6105                	addi	sp,sp,32
    80001e16:	8082                	ret
    release(&p->lock);
    80001e18:	8526                	mv	a0,s1
    80001e1a:	fffff097          	auipc	ra,0xfffff
    80001e1e:	ec4080e7          	jalr	-316(ra) # 80000cde <release>
    return 0;
    80001e22:	84ca                	mv	s1,s2
    80001e24:	b7dd                	j	80001e0a <allocproc+0xc4>
    freeproc(p);
    80001e26:	8526                	mv	a0,s1
    80001e28:	00000097          	auipc	ra,0x0
    80001e2c:	e9c080e7          	jalr	-356(ra) # 80001cc4 <freeproc>
    release(&p->lock);
    80001e30:	8526                	mv	a0,s1
    80001e32:	fffff097          	auipc	ra,0xfffff
    80001e36:	eac080e7          	jalr	-340(ra) # 80000cde <release>
    return 0;
    80001e3a:	84ca                	mv	s1,s2
    80001e3c:	b7f9                	j	80001e0a <allocproc+0xc4>
    panic("kalloc");
    80001e3e:	00006517          	auipc	a0,0x6
    80001e42:	42a50513          	addi	a0,a0,1066 # 80008268 <digits+0x238>
    80001e46:	ffffe097          	auipc	ra,0xffffe
    80001e4a:	702080e7          	jalr	1794(ra) # 80000548 <panic>

0000000080001e4e <userinit>:
{
    80001e4e:	1101                	addi	sp,sp,-32
    80001e50:	ec06                	sd	ra,24(sp)
    80001e52:	e822                	sd	s0,16(sp)
    80001e54:	e426                	sd	s1,8(sp)
    80001e56:	e04a                	sd	s2,0(sp)
    80001e58:	1000                	addi	s0,sp,32
  p = allocproc();
    80001e5a:	00000097          	auipc	ra,0x0
    80001e5e:	eec080e7          	jalr	-276(ra) # 80001d46 <allocproc>
    80001e62:	84aa                	mv	s1,a0
  initproc = p;
    80001e64:	00007797          	auipc	a5,0x7
    80001e68:	1aa7ba23          	sd	a0,436(a5) # 80009018 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001e6c:	03400613          	li	a2,52
    80001e70:	00007597          	auipc	a1,0x7
    80001e74:	a7058593          	addi	a1,a1,-1424 # 800088e0 <initcode>
    80001e78:	6928                	ld	a0,80(a0)
    80001e7a:	fffff097          	auipc	ra,0xfffff
    80001e7e:	5ac080e7          	jalr	1452(ra) # 80001426 <uvminit>
  p->sz = PGSIZE;
    80001e82:	6905                	lui	s2,0x1
    80001e84:	0524b423          	sd	s2,72(s1)
  kvmcopymappings(p->pagetable, p->kernelpgtbl, 0, p->sz);
    80001e88:	6685                	lui	a3,0x1
    80001e8a:	4601                	li	a2,0
    80001e8c:	1684b583          	ld	a1,360(s1)
    80001e90:	68a8                	ld	a0,80(s1)
    80001e92:	00000097          	auipc	ra,0x0
    80001e96:	90c080e7          	jalr	-1780(ra) # 8000179e <kvmcopymappings>
  p->trapframe->epc = 0;      // user program counter
    80001e9a:	6cbc                	ld	a5,88(s1)
    80001e9c:	0007bc23          	sd	zero,24(a5)
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001ea0:	6cbc                	ld	a5,88(s1)
    80001ea2:	0327b823          	sd	s2,48(a5)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001ea6:	4641                	li	a2,16
    80001ea8:	00006597          	auipc	a1,0x6
    80001eac:	3c858593          	addi	a1,a1,968 # 80008270 <digits+0x240>
    80001eb0:	15848513          	addi	a0,s1,344
    80001eb4:	fffff097          	auipc	ra,0xfffff
    80001eb8:	fc8080e7          	jalr	-56(ra) # 80000e7c <safestrcpy>
  p->cwd = namei("/");
    80001ebc:	00006517          	auipc	a0,0x6
    80001ec0:	3c450513          	addi	a0,a0,964 # 80008280 <digits+0x250>
    80001ec4:	00002097          	auipc	ra,0x2
    80001ec8:	146080e7          	jalr	326(ra) # 8000400a <namei>
    80001ecc:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001ed0:	4789                	li	a5,2
    80001ed2:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001ed4:	8526                	mv	a0,s1
    80001ed6:	fffff097          	auipc	ra,0xfffff
    80001eda:	e08080e7          	jalr	-504(ra) # 80000cde <release>
}
    80001ede:	60e2                	ld	ra,24(sp)
    80001ee0:	6442                	ld	s0,16(sp)
    80001ee2:	64a2                	ld	s1,8(sp)
    80001ee4:	6902                	ld	s2,0(sp)
    80001ee6:	6105                	addi	sp,sp,32
    80001ee8:	8082                	ret

0000000080001eea <growproc>:
{
    80001eea:	7179                	addi	sp,sp,-48
    80001eec:	f406                	sd	ra,40(sp)
    80001eee:	f022                	sd	s0,32(sp)
    80001ef0:	ec26                	sd	s1,24(sp)
    80001ef2:	e84a                	sd	s2,16(sp)
    80001ef4:	e44e                	sd	s3,8(sp)
    80001ef6:	e052                	sd	s4,0(sp)
    80001ef8:	1800                	addi	s0,sp,48
    80001efa:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001efc:	00000097          	auipc	ra,0x0
    80001f00:	c16080e7          	jalr	-1002(ra) # 80001b12 <myproc>
    80001f04:	84aa                	mv	s1,a0
  sz = p->sz;
    80001f06:	652c                	ld	a1,72(a0)
    80001f08:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001f0c:	03204363          	bgtz	s2,80001f32 <growproc+0x48>
  } else if(n < 0){
    80001f10:	06094663          	bltz	s2,80001f7c <growproc+0x92>
  p->sz = sz;
    80001f14:	02061913          	slli	s2,a2,0x20
    80001f18:	02095913          	srli	s2,s2,0x20
    80001f1c:	0524b423          	sd	s2,72(s1)
  return 0;
    80001f20:	4501                	li	a0,0
}
    80001f22:	70a2                	ld	ra,40(sp)
    80001f24:	7402                	ld	s0,32(sp)
    80001f26:	64e2                	ld	s1,24(sp)
    80001f28:	6942                	ld	s2,16(sp)
    80001f2a:	69a2                	ld	s3,8(sp)
    80001f2c:	6a02                	ld	s4,0(sp)
    80001f2e:	6145                	addi	sp,sp,48
    80001f30:	8082                	ret
    if((newsz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001f32:	02059993          	slli	s3,a1,0x20
    80001f36:	0209d993          	srli	s3,s3,0x20
    80001f3a:	00c9063b          	addw	a2,s2,a2
    80001f3e:	1602                	slli	a2,a2,0x20
    80001f40:	9201                	srli	a2,a2,0x20
    80001f42:	85ce                	mv	a1,s3
    80001f44:	6928                	ld	a0,80(a0)
    80001f46:	fffff097          	auipc	ra,0xfffff
    80001f4a:	59a080e7          	jalr	1434(ra) # 800014e0 <uvmalloc>
    80001f4e:	8a2a                	mv	s4,a0
    80001f50:	c12d                	beqz	a0,80001fb2 <growproc+0xc8>
    if(kvmcopymappings(p->pagetable, p->kernelpgtbl, sz, n) != 0) {
    80001f52:	86ca                	mv	a3,s2
    80001f54:	864e                	mv	a2,s3
    80001f56:	1684b583          	ld	a1,360(s1)
    80001f5a:	68a8                	ld	a0,80(s1)
    80001f5c:	00000097          	auipc	ra,0x0
    80001f60:	842080e7          	jalr	-1982(ra) # 8000179e <kvmcopymappings>
    sz = newsz;
    80001f64:	000a061b          	sext.w	a2,s4
    if(kvmcopymappings(p->pagetable, p->kernelpgtbl, sz, n) != 0) {
    80001f68:	d555                	beqz	a0,80001f14 <growproc+0x2a>
      uvmdealloc(p->pagetable, newsz, sz);
    80001f6a:	864e                	mv	a2,s3
    80001f6c:	85d2                	mv	a1,s4
    80001f6e:	68a8                	ld	a0,80(s1)
    80001f70:	fffff097          	auipc	ra,0xfffff
    80001f74:	528080e7          	jalr	1320(ra) # 80001498 <uvmdealloc>
      return -1;
    80001f78:	557d                	li	a0,-1
    80001f7a:	b765                	j	80001f22 <growproc+0x38>
    uvmdealloc(p->pagetable, sz, sz + n);
    80001f7c:	02059993          	slli	s3,a1,0x20
    80001f80:	0209d993          	srli	s3,s3,0x20
    80001f84:	00c9093b          	addw	s2,s2,a2
    80001f88:	1902                	slli	s2,s2,0x20
    80001f8a:	02095913          	srli	s2,s2,0x20
    80001f8e:	864a                	mv	a2,s2
    80001f90:	85ce                	mv	a1,s3
    80001f92:	6928                	ld	a0,80(a0)
    80001f94:	fffff097          	auipc	ra,0xfffff
    80001f98:	504080e7          	jalr	1284(ra) # 80001498 <uvmdealloc>
    sz = kvmdealloc(p->kernelpgtbl, sz, sz + n);
    80001f9c:	864a                	mv	a2,s2
    80001f9e:	85ce                	mv	a1,s3
    80001fa0:	1684b503          	ld	a0,360(s1)
    80001fa4:	fffff097          	auipc	ra,0xfffff
    80001fa8:	5e6080e7          	jalr	1510(ra) # 8000158a <kvmdealloc>
    80001fac:	0005061b          	sext.w	a2,a0
    80001fb0:	b795                	j	80001f14 <growproc+0x2a>
      return -1;
    80001fb2:	557d                	li	a0,-1
    80001fb4:	b7bd                	j	80001f22 <growproc+0x38>

0000000080001fb6 <fork>:
{
    80001fb6:	7179                	addi	sp,sp,-48
    80001fb8:	f406                	sd	ra,40(sp)
    80001fba:	f022                	sd	s0,32(sp)
    80001fbc:	ec26                	sd	s1,24(sp)
    80001fbe:	e84a                	sd	s2,16(sp)
    80001fc0:	e44e                	sd	s3,8(sp)
    80001fc2:	e052                	sd	s4,0(sp)
    80001fc4:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001fc6:	00000097          	auipc	ra,0x0
    80001fca:	b4c080e7          	jalr	-1204(ra) # 80001b12 <myproc>
    80001fce:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80001fd0:	00000097          	auipc	ra,0x0
    80001fd4:	d76080e7          	jalr	-650(ra) # 80001d46 <allocproc>
    80001fd8:	10050063          	beqz	a0,800020d8 <fork+0x122>
    80001fdc:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0 ||
    80001fde:	04893603          	ld	a2,72(s2) # 1048 <_entry-0x7fffefb8>
    80001fe2:	692c                	ld	a1,80(a0)
    80001fe4:	05093503          	ld	a0,80(s2)
    80001fe8:	fffff097          	auipc	ra,0xfffff
    80001fec:	6e4080e7          	jalr	1764(ra) # 800016cc <uvmcopy>
    80001ff0:	06054563          	bltz	a0,8000205a <fork+0xa4>
     kvmcopymappings(np->pagetable, np->kernelpgtbl, 0, p->sz) < 0){
    80001ff4:	04893683          	ld	a3,72(s2)
    80001ff8:	4601                	li	a2,0
    80001ffa:	1689b583          	ld	a1,360(s3)
    80001ffe:	0509b503          	ld	a0,80(s3)
    80002002:	fffff097          	auipc	ra,0xfffff
    80002006:	79c080e7          	jalr	1948(ra) # 8000179e <kvmcopymappings>
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0 ||
    8000200a:	04054863          	bltz	a0,8000205a <fork+0xa4>
  np->sz = p->sz;
    8000200e:	04893783          	ld	a5,72(s2)
    80002012:	04f9b423          	sd	a5,72(s3)
  np->parent = p;
    80002016:	0329b023          	sd	s2,32(s3)
  *(np->trapframe) = *(p->trapframe);
    8000201a:	05893683          	ld	a3,88(s2)
    8000201e:	87b6                	mv	a5,a3
    80002020:	0589b703          	ld	a4,88(s3)
    80002024:	12068693          	addi	a3,a3,288 # 1120 <_entry-0x7fffeee0>
    80002028:	0007b803          	ld	a6,0(a5)
    8000202c:	6788                	ld	a0,8(a5)
    8000202e:	6b8c                	ld	a1,16(a5)
    80002030:	6f90                	ld	a2,24(a5)
    80002032:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80002036:	e708                	sd	a0,8(a4)
    80002038:	eb0c                	sd	a1,16(a4)
    8000203a:	ef10                	sd	a2,24(a4)
    8000203c:	02078793          	addi	a5,a5,32
    80002040:	02070713          	addi	a4,a4,32
    80002044:	fed792e3          	bne	a5,a3,80002028 <fork+0x72>
  np->trapframe->a0 = 0;
    80002048:	0589b783          	ld	a5,88(s3)
    8000204c:	0607b823          	sd	zero,112(a5)
    80002050:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    80002054:	15000a13          	li	s4,336
    80002058:	a03d                	j	80002086 <fork+0xd0>
    freeproc(np);
    8000205a:	854e                	mv	a0,s3
    8000205c:	00000097          	auipc	ra,0x0
    80002060:	c68080e7          	jalr	-920(ra) # 80001cc4 <freeproc>
    release(&np->lock);
    80002064:	854e                	mv	a0,s3
    80002066:	fffff097          	auipc	ra,0xfffff
    8000206a:	c78080e7          	jalr	-904(ra) # 80000cde <release>
    return -1;
    8000206e:	54fd                	li	s1,-1
    80002070:	a899                	j	800020c6 <fork+0x110>
      np->ofile[i] = filedup(p->ofile[i]);
    80002072:	00002097          	auipc	ra,0x2
    80002076:	624080e7          	jalr	1572(ra) # 80004696 <filedup>
    8000207a:	009987b3          	add	a5,s3,s1
    8000207e:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80002080:	04a1                	addi	s1,s1,8
    80002082:	01448763          	beq	s1,s4,80002090 <fork+0xda>
    if(p->ofile[i])
    80002086:	009907b3          	add	a5,s2,s1
    8000208a:	6388                	ld	a0,0(a5)
    8000208c:	f17d                	bnez	a0,80002072 <fork+0xbc>
    8000208e:	bfcd                	j	80002080 <fork+0xca>
  np->cwd = idup(p->cwd);
    80002090:	15093503          	ld	a0,336(s2)
    80002094:	00001097          	auipc	ra,0x1
    80002098:	788080e7          	jalr	1928(ra) # 8000381c <idup>
    8000209c:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800020a0:	4641                	li	a2,16
    800020a2:	15890593          	addi	a1,s2,344
    800020a6:	15898513          	addi	a0,s3,344
    800020aa:	fffff097          	auipc	ra,0xfffff
    800020ae:	dd2080e7          	jalr	-558(ra) # 80000e7c <safestrcpy>
  pid = np->pid;
    800020b2:	0389a483          	lw	s1,56(s3)
  np->state = RUNNABLE;
    800020b6:	4789                	li	a5,2
    800020b8:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    800020bc:	854e                	mv	a0,s3
    800020be:	fffff097          	auipc	ra,0xfffff
    800020c2:	c20080e7          	jalr	-992(ra) # 80000cde <release>
}
    800020c6:	8526                	mv	a0,s1
    800020c8:	70a2                	ld	ra,40(sp)
    800020ca:	7402                	ld	s0,32(sp)
    800020cc:	64e2                	ld	s1,24(sp)
    800020ce:	6942                	ld	s2,16(sp)
    800020d0:	69a2                	ld	s3,8(sp)
    800020d2:	6a02                	ld	s4,0(sp)
    800020d4:	6145                	addi	sp,sp,48
    800020d6:	8082                	ret
    return -1;
    800020d8:	54fd                	li	s1,-1
    800020da:	b7f5                	j	800020c6 <fork+0x110>

00000000800020dc <reparent>:
{
    800020dc:	7179                	addi	sp,sp,-48
    800020de:	f406                	sd	ra,40(sp)
    800020e0:	f022                	sd	s0,32(sp)
    800020e2:	ec26                	sd	s1,24(sp)
    800020e4:	e84a                	sd	s2,16(sp)
    800020e6:	e44e                	sd	s3,8(sp)
    800020e8:	e052                	sd	s4,0(sp)
    800020ea:	1800                	addi	s0,sp,48
    800020ec:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800020ee:	00010497          	auipc	s1,0x10
    800020f2:	c7a48493          	addi	s1,s1,-902 # 80011d68 <proc>
      pp->parent = initproc;
    800020f6:	00007a17          	auipc	s4,0x7
    800020fa:	f22a0a13          	addi	s4,s4,-222 # 80009018 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800020fe:	00016997          	auipc	s3,0x16
    80002102:	86a98993          	addi	s3,s3,-1942 # 80017968 <tickslock>
    80002106:	a029                	j	80002110 <reparent+0x34>
    80002108:	17048493          	addi	s1,s1,368
    8000210c:	03348363          	beq	s1,s3,80002132 <reparent+0x56>
    if(pp->parent == p){
    80002110:	709c                	ld	a5,32(s1)
    80002112:	ff279be3          	bne	a5,s2,80002108 <reparent+0x2c>
      acquire(&pp->lock);
    80002116:	8526                	mv	a0,s1
    80002118:	fffff097          	auipc	ra,0xfffff
    8000211c:	b12080e7          	jalr	-1262(ra) # 80000c2a <acquire>
      pp->parent = initproc;
    80002120:	000a3783          	ld	a5,0(s4)
    80002124:	f09c                	sd	a5,32(s1)
      release(&pp->lock);
    80002126:	8526                	mv	a0,s1
    80002128:	fffff097          	auipc	ra,0xfffff
    8000212c:	bb6080e7          	jalr	-1098(ra) # 80000cde <release>
    80002130:	bfe1                	j	80002108 <reparent+0x2c>
}
    80002132:	70a2                	ld	ra,40(sp)
    80002134:	7402                	ld	s0,32(sp)
    80002136:	64e2                	ld	s1,24(sp)
    80002138:	6942                	ld	s2,16(sp)
    8000213a:	69a2                	ld	s3,8(sp)
    8000213c:	6a02                	ld	s4,0(sp)
    8000213e:	6145                	addi	sp,sp,48
    80002140:	8082                	ret

0000000080002142 <scheduler>:
{
    80002142:	715d                	addi	sp,sp,-80
    80002144:	e486                	sd	ra,72(sp)
    80002146:	e0a2                	sd	s0,64(sp)
    80002148:	fc26                	sd	s1,56(sp)
    8000214a:	f84a                	sd	s2,48(sp)
    8000214c:	f44e                	sd	s3,40(sp)
    8000214e:	f052                	sd	s4,32(sp)
    80002150:	ec56                	sd	s5,24(sp)
    80002152:	e85a                	sd	s6,16(sp)
    80002154:	e45e                	sd	s7,8(sp)
    80002156:	e062                	sd	s8,0(sp)
    80002158:	0880                	addi	s0,sp,80
    8000215a:	8792                	mv	a5,tp
  int id = r_tp();
    8000215c:	2781                	sext.w	a5,a5
  c->proc = 0;
    8000215e:	00779b13          	slli	s6,a5,0x7
    80002162:	0000f717          	auipc	a4,0xf
    80002166:	7ee70713          	addi	a4,a4,2030 # 80011950 <pid_lock>
    8000216a:	975a                	add	a4,a4,s6
    8000216c:	00073c23          	sd	zero,24(a4)
        swtch(&c->context, &p->context);
    80002170:	00010717          	auipc	a4,0x10
    80002174:	80070713          	addi	a4,a4,-2048 # 80011970 <cpus+0x8>
    80002178:	9b3a                	add	s6,s6,a4
        c->proc = p;
    8000217a:	079e                	slli	a5,a5,0x7
    8000217c:	0000fa17          	auipc	s4,0xf
    80002180:	7d4a0a13          	addi	s4,s4,2004 # 80011950 <pid_lock>
    80002184:	9a3e                	add	s4,s4,a5
        w_satp(MAKE_SATP(p->kernelpgtbl));
    80002186:	5bfd                	li	s7,-1
    80002188:	1bfe                	slli	s7,s7,0x3f
    for(p = proc; p < &proc[NPROC]; p++) {
    8000218a:	00015997          	auipc	s3,0x15
    8000218e:	7de98993          	addi	s3,s3,2014 # 80017968 <tickslock>
    80002192:	a885                	j	80002202 <scheduler+0xc0>
        p->state = RUNNING;
    80002194:	0154ac23          	sw	s5,24(s1)
        c->proc = p;
    80002198:	009a3c23          	sd	s1,24(s4)
        w_satp(MAKE_SATP(p->kernelpgtbl));
    8000219c:	1684b783          	ld	a5,360(s1)
    800021a0:	83b1                	srli	a5,a5,0xc
    800021a2:	0177e7b3          	or	a5,a5,s7
  asm volatile("csrw satp, %0" : : "r" (x));
    800021a6:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    800021aa:	12000073          	sfence.vma
        swtch(&c->context, &p->context);
    800021ae:	06048593          	addi	a1,s1,96
    800021b2:	855a                	mv	a0,s6
    800021b4:	00000097          	auipc	ra,0x0
    800021b8:	642080e7          	jalr	1602(ra) # 800027f6 <swtch>
        kvminithart();
    800021bc:	fffff097          	auipc	ra,0xfffff
    800021c0:	e3a080e7          	jalr	-454(ra) # 80000ff6 <kvminithart>
        c->proc = 0;
    800021c4:	000a3c23          	sd	zero,24(s4)
        found = 1;
    800021c8:	4c05                	li	s8,1
      release(&p->lock);
    800021ca:	8526                	mv	a0,s1
    800021cc:	fffff097          	auipc	ra,0xfffff
    800021d0:	b12080e7          	jalr	-1262(ra) # 80000cde <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800021d4:	17048493          	addi	s1,s1,368
    800021d8:	01348b63          	beq	s1,s3,800021ee <scheduler+0xac>
      acquire(&p->lock);
    800021dc:	8526                	mv	a0,s1
    800021de:	fffff097          	auipc	ra,0xfffff
    800021e2:	a4c080e7          	jalr	-1460(ra) # 80000c2a <acquire>
      if(p->state == RUNNABLE) {
    800021e6:	4c9c                	lw	a5,24(s1)
    800021e8:	ff2791e3          	bne	a5,s2,800021ca <scheduler+0x88>
    800021ec:	b765                	j	80002194 <scheduler+0x52>
    if(found == 0) {
    800021ee:	000c1a63          	bnez	s8,80002202 <scheduler+0xc0>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800021f2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800021f6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800021fa:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    800021fe:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002202:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002206:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000220a:	10079073          	csrw	sstatus,a5
    int found = 0;
    8000220e:	4c01                	li	s8,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80002210:	00010497          	auipc	s1,0x10
    80002214:	b5848493          	addi	s1,s1,-1192 # 80011d68 <proc>
      if(p->state == RUNNABLE) {
    80002218:	4909                	li	s2,2
        p->state = RUNNING;
    8000221a:	4a8d                	li	s5,3
    8000221c:	b7c1                	j	800021dc <scheduler+0x9a>

000000008000221e <sched>:
{
    8000221e:	7179                	addi	sp,sp,-48
    80002220:	f406                	sd	ra,40(sp)
    80002222:	f022                	sd	s0,32(sp)
    80002224:	ec26                	sd	s1,24(sp)
    80002226:	e84a                	sd	s2,16(sp)
    80002228:	e44e                	sd	s3,8(sp)
    8000222a:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000222c:	00000097          	auipc	ra,0x0
    80002230:	8e6080e7          	jalr	-1818(ra) # 80001b12 <myproc>
    80002234:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002236:	fffff097          	auipc	ra,0xfffff
    8000223a:	97a080e7          	jalr	-1670(ra) # 80000bb0 <holding>
    8000223e:	c93d                	beqz	a0,800022b4 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002240:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002242:	2781                	sext.w	a5,a5
    80002244:	079e                	slli	a5,a5,0x7
    80002246:	0000f717          	auipc	a4,0xf
    8000224a:	70a70713          	addi	a4,a4,1802 # 80011950 <pid_lock>
    8000224e:	97ba                	add	a5,a5,a4
    80002250:	0907a703          	lw	a4,144(a5)
    80002254:	4785                	li	a5,1
    80002256:	06f71763          	bne	a4,a5,800022c4 <sched+0xa6>
  if(p->state == RUNNING)
    8000225a:	4c98                	lw	a4,24(s1)
    8000225c:	478d                	li	a5,3
    8000225e:	06f70b63          	beq	a4,a5,800022d4 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002262:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002266:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002268:	efb5                	bnez	a5,800022e4 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000226a:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000226c:	0000f917          	auipc	s2,0xf
    80002270:	6e490913          	addi	s2,s2,1764 # 80011950 <pid_lock>
    80002274:	2781                	sext.w	a5,a5
    80002276:	079e                	slli	a5,a5,0x7
    80002278:	97ca                	add	a5,a5,s2
    8000227a:	0947a983          	lw	s3,148(a5)
    8000227e:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002280:	2781                	sext.w	a5,a5
    80002282:	079e                	slli	a5,a5,0x7
    80002284:	0000f597          	auipc	a1,0xf
    80002288:	6ec58593          	addi	a1,a1,1772 # 80011970 <cpus+0x8>
    8000228c:	95be                	add	a1,a1,a5
    8000228e:	06048513          	addi	a0,s1,96
    80002292:	00000097          	auipc	ra,0x0
    80002296:	564080e7          	jalr	1380(ra) # 800027f6 <swtch>
    8000229a:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000229c:	2781                	sext.w	a5,a5
    8000229e:	079e                	slli	a5,a5,0x7
    800022a0:	97ca                	add	a5,a5,s2
    800022a2:	0937aa23          	sw	s3,148(a5)
}
    800022a6:	70a2                	ld	ra,40(sp)
    800022a8:	7402                	ld	s0,32(sp)
    800022aa:	64e2                	ld	s1,24(sp)
    800022ac:	6942                	ld	s2,16(sp)
    800022ae:	69a2                	ld	s3,8(sp)
    800022b0:	6145                	addi	sp,sp,48
    800022b2:	8082                	ret
    panic("sched p->lock");
    800022b4:	00006517          	auipc	a0,0x6
    800022b8:	fd450513          	addi	a0,a0,-44 # 80008288 <digits+0x258>
    800022bc:	ffffe097          	auipc	ra,0xffffe
    800022c0:	28c080e7          	jalr	652(ra) # 80000548 <panic>
    panic("sched locks");
    800022c4:	00006517          	auipc	a0,0x6
    800022c8:	fd450513          	addi	a0,a0,-44 # 80008298 <digits+0x268>
    800022cc:	ffffe097          	auipc	ra,0xffffe
    800022d0:	27c080e7          	jalr	636(ra) # 80000548 <panic>
    panic("sched running");
    800022d4:	00006517          	auipc	a0,0x6
    800022d8:	fd450513          	addi	a0,a0,-44 # 800082a8 <digits+0x278>
    800022dc:	ffffe097          	auipc	ra,0xffffe
    800022e0:	26c080e7          	jalr	620(ra) # 80000548 <panic>
    panic("sched interruptible");
    800022e4:	00006517          	auipc	a0,0x6
    800022e8:	fd450513          	addi	a0,a0,-44 # 800082b8 <digits+0x288>
    800022ec:	ffffe097          	auipc	ra,0xffffe
    800022f0:	25c080e7          	jalr	604(ra) # 80000548 <panic>

00000000800022f4 <exit>:
{
    800022f4:	7179                	addi	sp,sp,-48
    800022f6:	f406                	sd	ra,40(sp)
    800022f8:	f022                	sd	s0,32(sp)
    800022fa:	ec26                	sd	s1,24(sp)
    800022fc:	e84a                	sd	s2,16(sp)
    800022fe:	e44e                	sd	s3,8(sp)
    80002300:	e052                	sd	s4,0(sp)
    80002302:	1800                	addi	s0,sp,48
    80002304:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002306:	00000097          	auipc	ra,0x0
    8000230a:	80c080e7          	jalr	-2036(ra) # 80001b12 <myproc>
    8000230e:	89aa                	mv	s3,a0
  if(p == initproc)
    80002310:	00007797          	auipc	a5,0x7
    80002314:	d087b783          	ld	a5,-760(a5) # 80009018 <initproc>
    80002318:	0d050493          	addi	s1,a0,208
    8000231c:	15050913          	addi	s2,a0,336
    80002320:	02a79363          	bne	a5,a0,80002346 <exit+0x52>
    panic("init exiting");
    80002324:	00006517          	auipc	a0,0x6
    80002328:	fac50513          	addi	a0,a0,-84 # 800082d0 <digits+0x2a0>
    8000232c:	ffffe097          	auipc	ra,0xffffe
    80002330:	21c080e7          	jalr	540(ra) # 80000548 <panic>
      fileclose(f);
    80002334:	00002097          	auipc	ra,0x2
    80002338:	3b4080e7          	jalr	948(ra) # 800046e8 <fileclose>
      p->ofile[fd] = 0;
    8000233c:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002340:	04a1                	addi	s1,s1,8
    80002342:	01248563          	beq	s1,s2,8000234c <exit+0x58>
    if(p->ofile[fd]){
    80002346:	6088                	ld	a0,0(s1)
    80002348:	f575                	bnez	a0,80002334 <exit+0x40>
    8000234a:	bfdd                	j	80002340 <exit+0x4c>
  begin_op();
    8000234c:	00002097          	auipc	ra,0x2
    80002350:	eca080e7          	jalr	-310(ra) # 80004216 <begin_op>
  iput(p->cwd);
    80002354:	1509b503          	ld	a0,336(s3)
    80002358:	00001097          	auipc	ra,0x1
    8000235c:	6bc080e7          	jalr	1724(ra) # 80003a14 <iput>
  end_op();
    80002360:	00002097          	auipc	ra,0x2
    80002364:	f36080e7          	jalr	-202(ra) # 80004296 <end_op>
  p->cwd = 0;
    80002368:	1409b823          	sd	zero,336(s3)
  acquire(&initproc->lock);
    8000236c:	00007497          	auipc	s1,0x7
    80002370:	cac48493          	addi	s1,s1,-852 # 80009018 <initproc>
    80002374:	6088                	ld	a0,0(s1)
    80002376:	fffff097          	auipc	ra,0xfffff
    8000237a:	8b4080e7          	jalr	-1868(ra) # 80000c2a <acquire>
  wakeup1(initproc);
    8000237e:	6088                	ld	a0,0(s1)
    80002380:	fffff097          	auipc	ra,0xfffff
    80002384:	6ba080e7          	jalr	1722(ra) # 80001a3a <wakeup1>
  release(&initproc->lock);
    80002388:	6088                	ld	a0,0(s1)
    8000238a:	fffff097          	auipc	ra,0xfffff
    8000238e:	954080e7          	jalr	-1708(ra) # 80000cde <release>
  acquire(&p->lock);
    80002392:	854e                	mv	a0,s3
    80002394:	fffff097          	auipc	ra,0xfffff
    80002398:	896080e7          	jalr	-1898(ra) # 80000c2a <acquire>
  struct proc *original_parent = p->parent;
    8000239c:	0209b483          	ld	s1,32(s3)
  release(&p->lock);
    800023a0:	854e                	mv	a0,s3
    800023a2:	fffff097          	auipc	ra,0xfffff
    800023a6:	93c080e7          	jalr	-1732(ra) # 80000cde <release>
  acquire(&original_parent->lock);
    800023aa:	8526                	mv	a0,s1
    800023ac:	fffff097          	auipc	ra,0xfffff
    800023b0:	87e080e7          	jalr	-1922(ra) # 80000c2a <acquire>
  acquire(&p->lock);
    800023b4:	854e                	mv	a0,s3
    800023b6:	fffff097          	auipc	ra,0xfffff
    800023ba:	874080e7          	jalr	-1932(ra) # 80000c2a <acquire>
  reparent(p);
    800023be:	854e                	mv	a0,s3
    800023c0:	00000097          	auipc	ra,0x0
    800023c4:	d1c080e7          	jalr	-740(ra) # 800020dc <reparent>
  wakeup1(original_parent);
    800023c8:	8526                	mv	a0,s1
    800023ca:	fffff097          	auipc	ra,0xfffff
    800023ce:	670080e7          	jalr	1648(ra) # 80001a3a <wakeup1>
  p->xstate = status;
    800023d2:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    800023d6:	4791                	li	a5,4
    800023d8:	00f9ac23          	sw	a5,24(s3)
  release(&original_parent->lock);
    800023dc:	8526                	mv	a0,s1
    800023de:	fffff097          	auipc	ra,0xfffff
    800023e2:	900080e7          	jalr	-1792(ra) # 80000cde <release>
  sched();
    800023e6:	00000097          	auipc	ra,0x0
    800023ea:	e38080e7          	jalr	-456(ra) # 8000221e <sched>
  panic("zombie exit");
    800023ee:	00006517          	auipc	a0,0x6
    800023f2:	ef250513          	addi	a0,a0,-270 # 800082e0 <digits+0x2b0>
    800023f6:	ffffe097          	auipc	ra,0xffffe
    800023fa:	152080e7          	jalr	338(ra) # 80000548 <panic>

00000000800023fe <yield>:
{
    800023fe:	1101                	addi	sp,sp,-32
    80002400:	ec06                	sd	ra,24(sp)
    80002402:	e822                	sd	s0,16(sp)
    80002404:	e426                	sd	s1,8(sp)
    80002406:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002408:	fffff097          	auipc	ra,0xfffff
    8000240c:	70a080e7          	jalr	1802(ra) # 80001b12 <myproc>
    80002410:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002412:	fffff097          	auipc	ra,0xfffff
    80002416:	818080e7          	jalr	-2024(ra) # 80000c2a <acquire>
  p->state = RUNNABLE;
    8000241a:	4789                	li	a5,2
    8000241c:	cc9c                	sw	a5,24(s1)
  sched();
    8000241e:	00000097          	auipc	ra,0x0
    80002422:	e00080e7          	jalr	-512(ra) # 8000221e <sched>
  release(&p->lock);
    80002426:	8526                	mv	a0,s1
    80002428:	fffff097          	auipc	ra,0xfffff
    8000242c:	8b6080e7          	jalr	-1866(ra) # 80000cde <release>
}
    80002430:	60e2                	ld	ra,24(sp)
    80002432:	6442                	ld	s0,16(sp)
    80002434:	64a2                	ld	s1,8(sp)
    80002436:	6105                	addi	sp,sp,32
    80002438:	8082                	ret

000000008000243a <sleep>:
{
    8000243a:	7179                	addi	sp,sp,-48
    8000243c:	f406                	sd	ra,40(sp)
    8000243e:	f022                	sd	s0,32(sp)
    80002440:	ec26                	sd	s1,24(sp)
    80002442:	e84a                	sd	s2,16(sp)
    80002444:	e44e                	sd	s3,8(sp)
    80002446:	1800                	addi	s0,sp,48
    80002448:	89aa                	mv	s3,a0
    8000244a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000244c:	fffff097          	auipc	ra,0xfffff
    80002450:	6c6080e7          	jalr	1734(ra) # 80001b12 <myproc>
    80002454:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    80002456:	05250663          	beq	a0,s2,800024a2 <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    8000245a:	ffffe097          	auipc	ra,0xffffe
    8000245e:	7d0080e7          	jalr	2000(ra) # 80000c2a <acquire>
    release(lk);
    80002462:	854a                	mv	a0,s2
    80002464:	fffff097          	auipc	ra,0xfffff
    80002468:	87a080e7          	jalr	-1926(ra) # 80000cde <release>
  p->chan = chan;
    8000246c:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    80002470:	4785                	li	a5,1
    80002472:	cc9c                	sw	a5,24(s1)
  sched();
    80002474:	00000097          	auipc	ra,0x0
    80002478:	daa080e7          	jalr	-598(ra) # 8000221e <sched>
  p->chan = 0;
    8000247c:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    80002480:	8526                	mv	a0,s1
    80002482:	fffff097          	auipc	ra,0xfffff
    80002486:	85c080e7          	jalr	-1956(ra) # 80000cde <release>
    acquire(lk);
    8000248a:	854a                	mv	a0,s2
    8000248c:	ffffe097          	auipc	ra,0xffffe
    80002490:	79e080e7          	jalr	1950(ra) # 80000c2a <acquire>
}
    80002494:	70a2                	ld	ra,40(sp)
    80002496:	7402                	ld	s0,32(sp)
    80002498:	64e2                	ld	s1,24(sp)
    8000249a:	6942                	ld	s2,16(sp)
    8000249c:	69a2                	ld	s3,8(sp)
    8000249e:	6145                	addi	sp,sp,48
    800024a0:	8082                	ret
  p->chan = chan;
    800024a2:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    800024a6:	4785                	li	a5,1
    800024a8:	cd1c                	sw	a5,24(a0)
  sched();
    800024aa:	00000097          	auipc	ra,0x0
    800024ae:	d74080e7          	jalr	-652(ra) # 8000221e <sched>
  p->chan = 0;
    800024b2:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    800024b6:	bff9                	j	80002494 <sleep+0x5a>

00000000800024b8 <wait>:
{
    800024b8:	715d                	addi	sp,sp,-80
    800024ba:	e486                	sd	ra,72(sp)
    800024bc:	e0a2                	sd	s0,64(sp)
    800024be:	fc26                	sd	s1,56(sp)
    800024c0:	f84a                	sd	s2,48(sp)
    800024c2:	f44e                	sd	s3,40(sp)
    800024c4:	f052                	sd	s4,32(sp)
    800024c6:	ec56                	sd	s5,24(sp)
    800024c8:	e85a                	sd	s6,16(sp)
    800024ca:	e45e                	sd	s7,8(sp)
    800024cc:	e062                	sd	s8,0(sp)
    800024ce:	0880                	addi	s0,sp,80
    800024d0:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800024d2:	fffff097          	auipc	ra,0xfffff
    800024d6:	640080e7          	jalr	1600(ra) # 80001b12 <myproc>
    800024da:	892a                	mv	s2,a0
  acquire(&p->lock);
    800024dc:	8c2a                	mv	s8,a0
    800024de:	ffffe097          	auipc	ra,0xffffe
    800024e2:	74c080e7          	jalr	1868(ra) # 80000c2a <acquire>
    havekids = 0;
    800024e6:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    800024e8:	4a11                	li	s4,4
    for(np = proc; np < &proc[NPROC]; np++){
    800024ea:	00015997          	auipc	s3,0x15
    800024ee:	47e98993          	addi	s3,s3,1150 # 80017968 <tickslock>
        havekids = 1;
    800024f2:	4a85                	li	s5,1
    havekids = 0;
    800024f4:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    800024f6:	00010497          	auipc	s1,0x10
    800024fa:	87248493          	addi	s1,s1,-1934 # 80011d68 <proc>
    800024fe:	a08d                	j	80002560 <wait+0xa8>
          pid = np->pid;
    80002500:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002504:	000b0e63          	beqz	s6,80002520 <wait+0x68>
    80002508:	4691                	li	a3,4
    8000250a:	03448613          	addi	a2,s1,52
    8000250e:	85da                	mv	a1,s6
    80002510:	05093503          	ld	a0,80(s2)
    80002514:	fffff097          	auipc	ra,0xfffff
    80002518:	370080e7          	jalr	880(ra) # 80001884 <copyout>
    8000251c:	02054263          	bltz	a0,80002540 <wait+0x88>
          freeproc(np);
    80002520:	8526                	mv	a0,s1
    80002522:	fffff097          	auipc	ra,0xfffff
    80002526:	7a2080e7          	jalr	1954(ra) # 80001cc4 <freeproc>
          release(&np->lock);
    8000252a:	8526                	mv	a0,s1
    8000252c:	ffffe097          	auipc	ra,0xffffe
    80002530:	7b2080e7          	jalr	1970(ra) # 80000cde <release>
          release(&p->lock);
    80002534:	854a                	mv	a0,s2
    80002536:	ffffe097          	auipc	ra,0xffffe
    8000253a:	7a8080e7          	jalr	1960(ra) # 80000cde <release>
          return pid;
    8000253e:	a8a9                	j	80002598 <wait+0xe0>
            release(&np->lock);
    80002540:	8526                	mv	a0,s1
    80002542:	ffffe097          	auipc	ra,0xffffe
    80002546:	79c080e7          	jalr	1948(ra) # 80000cde <release>
            release(&p->lock);
    8000254a:	854a                	mv	a0,s2
    8000254c:	ffffe097          	auipc	ra,0xffffe
    80002550:	792080e7          	jalr	1938(ra) # 80000cde <release>
            return -1;
    80002554:	59fd                	li	s3,-1
    80002556:	a089                	j	80002598 <wait+0xe0>
    for(np = proc; np < &proc[NPROC]; np++){
    80002558:	17048493          	addi	s1,s1,368
    8000255c:	03348463          	beq	s1,s3,80002584 <wait+0xcc>
      if(np->parent == p){
    80002560:	709c                	ld	a5,32(s1)
    80002562:	ff279be3          	bne	a5,s2,80002558 <wait+0xa0>
        acquire(&np->lock);
    80002566:	8526                	mv	a0,s1
    80002568:	ffffe097          	auipc	ra,0xffffe
    8000256c:	6c2080e7          	jalr	1730(ra) # 80000c2a <acquire>
        if(np->state == ZOMBIE){
    80002570:	4c9c                	lw	a5,24(s1)
    80002572:	f94787e3          	beq	a5,s4,80002500 <wait+0x48>
        release(&np->lock);
    80002576:	8526                	mv	a0,s1
    80002578:	ffffe097          	auipc	ra,0xffffe
    8000257c:	766080e7          	jalr	1894(ra) # 80000cde <release>
        havekids = 1;
    80002580:	8756                	mv	a4,s5
    80002582:	bfd9                	j	80002558 <wait+0xa0>
    if(!havekids || p->killed){
    80002584:	c701                	beqz	a4,8000258c <wait+0xd4>
    80002586:	03092783          	lw	a5,48(s2)
    8000258a:	c785                	beqz	a5,800025b2 <wait+0xfa>
      release(&p->lock);
    8000258c:	854a                	mv	a0,s2
    8000258e:	ffffe097          	auipc	ra,0xffffe
    80002592:	750080e7          	jalr	1872(ra) # 80000cde <release>
      return -1;
    80002596:	59fd                	li	s3,-1
}
    80002598:	854e                	mv	a0,s3
    8000259a:	60a6                	ld	ra,72(sp)
    8000259c:	6406                	ld	s0,64(sp)
    8000259e:	74e2                	ld	s1,56(sp)
    800025a0:	7942                	ld	s2,48(sp)
    800025a2:	79a2                	ld	s3,40(sp)
    800025a4:	7a02                	ld	s4,32(sp)
    800025a6:	6ae2                	ld	s5,24(sp)
    800025a8:	6b42                	ld	s6,16(sp)
    800025aa:	6ba2                	ld	s7,8(sp)
    800025ac:	6c02                	ld	s8,0(sp)
    800025ae:	6161                	addi	sp,sp,80
    800025b0:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    800025b2:	85e2                	mv	a1,s8
    800025b4:	854a                	mv	a0,s2
    800025b6:	00000097          	auipc	ra,0x0
    800025ba:	e84080e7          	jalr	-380(ra) # 8000243a <sleep>
    havekids = 0;
    800025be:	bf1d                	j	800024f4 <wait+0x3c>

00000000800025c0 <wakeup>:
{
    800025c0:	7139                	addi	sp,sp,-64
    800025c2:	fc06                	sd	ra,56(sp)
    800025c4:	f822                	sd	s0,48(sp)
    800025c6:	f426                	sd	s1,40(sp)
    800025c8:	f04a                	sd	s2,32(sp)
    800025ca:	ec4e                	sd	s3,24(sp)
    800025cc:	e852                	sd	s4,16(sp)
    800025ce:	e456                	sd	s5,8(sp)
    800025d0:	0080                	addi	s0,sp,64
    800025d2:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    800025d4:	0000f497          	auipc	s1,0xf
    800025d8:	79448493          	addi	s1,s1,1940 # 80011d68 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    800025dc:	4985                	li	s3,1
      p->state = RUNNABLE;
    800025de:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    800025e0:	00015917          	auipc	s2,0x15
    800025e4:	38890913          	addi	s2,s2,904 # 80017968 <tickslock>
    800025e8:	a821                	j	80002600 <wakeup+0x40>
      p->state = RUNNABLE;
    800025ea:	0154ac23          	sw	s5,24(s1)
    release(&p->lock);
    800025ee:	8526                	mv	a0,s1
    800025f0:	ffffe097          	auipc	ra,0xffffe
    800025f4:	6ee080e7          	jalr	1774(ra) # 80000cde <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800025f8:	17048493          	addi	s1,s1,368
    800025fc:	01248e63          	beq	s1,s2,80002618 <wakeup+0x58>
    acquire(&p->lock);
    80002600:	8526                	mv	a0,s1
    80002602:	ffffe097          	auipc	ra,0xffffe
    80002606:	628080e7          	jalr	1576(ra) # 80000c2a <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    8000260a:	4c9c                	lw	a5,24(s1)
    8000260c:	ff3791e3          	bne	a5,s3,800025ee <wakeup+0x2e>
    80002610:	749c                	ld	a5,40(s1)
    80002612:	fd479ee3          	bne	a5,s4,800025ee <wakeup+0x2e>
    80002616:	bfd1                	j	800025ea <wakeup+0x2a>
}
    80002618:	70e2                	ld	ra,56(sp)
    8000261a:	7442                	ld	s0,48(sp)
    8000261c:	74a2                	ld	s1,40(sp)
    8000261e:	7902                	ld	s2,32(sp)
    80002620:	69e2                	ld	s3,24(sp)
    80002622:	6a42                	ld	s4,16(sp)
    80002624:	6aa2                	ld	s5,8(sp)
    80002626:	6121                	addi	sp,sp,64
    80002628:	8082                	ret

000000008000262a <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000262a:	7179                	addi	sp,sp,-48
    8000262c:	f406                	sd	ra,40(sp)
    8000262e:	f022                	sd	s0,32(sp)
    80002630:	ec26                	sd	s1,24(sp)
    80002632:	e84a                	sd	s2,16(sp)
    80002634:	e44e                	sd	s3,8(sp)
    80002636:	1800                	addi	s0,sp,48
    80002638:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000263a:	0000f497          	auipc	s1,0xf
    8000263e:	72e48493          	addi	s1,s1,1838 # 80011d68 <proc>
    80002642:	00015997          	auipc	s3,0x15
    80002646:	32698993          	addi	s3,s3,806 # 80017968 <tickslock>
    acquire(&p->lock);
    8000264a:	8526                	mv	a0,s1
    8000264c:	ffffe097          	auipc	ra,0xffffe
    80002650:	5de080e7          	jalr	1502(ra) # 80000c2a <acquire>
    if(p->pid == pid){
    80002654:	5c9c                	lw	a5,56(s1)
    80002656:	01278d63          	beq	a5,s2,80002670 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000265a:	8526                	mv	a0,s1
    8000265c:	ffffe097          	auipc	ra,0xffffe
    80002660:	682080e7          	jalr	1666(ra) # 80000cde <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002664:	17048493          	addi	s1,s1,368
    80002668:	ff3491e3          	bne	s1,s3,8000264a <kill+0x20>
  }
  return -1;
    8000266c:	557d                	li	a0,-1
    8000266e:	a829                	j	80002688 <kill+0x5e>
      p->killed = 1;
    80002670:	4785                	li	a5,1
    80002672:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    80002674:	4c98                	lw	a4,24(s1)
    80002676:	4785                	li	a5,1
    80002678:	00f70f63          	beq	a4,a5,80002696 <kill+0x6c>
      release(&p->lock);
    8000267c:	8526                	mv	a0,s1
    8000267e:	ffffe097          	auipc	ra,0xffffe
    80002682:	660080e7          	jalr	1632(ra) # 80000cde <release>
      return 0;
    80002686:	4501                	li	a0,0
}
    80002688:	70a2                	ld	ra,40(sp)
    8000268a:	7402                	ld	s0,32(sp)
    8000268c:	64e2                	ld	s1,24(sp)
    8000268e:	6942                	ld	s2,16(sp)
    80002690:	69a2                	ld	s3,8(sp)
    80002692:	6145                	addi	sp,sp,48
    80002694:	8082                	ret
        p->state = RUNNABLE;
    80002696:	4789                	li	a5,2
    80002698:	cc9c                	sw	a5,24(s1)
    8000269a:	b7cd                	j	8000267c <kill+0x52>

000000008000269c <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000269c:	7179                	addi	sp,sp,-48
    8000269e:	f406                	sd	ra,40(sp)
    800026a0:	f022                	sd	s0,32(sp)
    800026a2:	ec26                	sd	s1,24(sp)
    800026a4:	e84a                	sd	s2,16(sp)
    800026a6:	e44e                	sd	s3,8(sp)
    800026a8:	e052                	sd	s4,0(sp)
    800026aa:	1800                	addi	s0,sp,48
    800026ac:	84aa                	mv	s1,a0
    800026ae:	892e                	mv	s2,a1
    800026b0:	89b2                	mv	s3,a2
    800026b2:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800026b4:	fffff097          	auipc	ra,0xfffff
    800026b8:	45e080e7          	jalr	1118(ra) # 80001b12 <myproc>
  if(user_dst){
    800026bc:	c08d                	beqz	s1,800026de <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800026be:	86d2                	mv	a3,s4
    800026c0:	864e                	mv	a2,s3
    800026c2:	85ca                	mv	a1,s2
    800026c4:	6928                	ld	a0,80(a0)
    800026c6:	fffff097          	auipc	ra,0xfffff
    800026ca:	1be080e7          	jalr	446(ra) # 80001884 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800026ce:	70a2                	ld	ra,40(sp)
    800026d0:	7402                	ld	s0,32(sp)
    800026d2:	64e2                	ld	s1,24(sp)
    800026d4:	6942                	ld	s2,16(sp)
    800026d6:	69a2                	ld	s3,8(sp)
    800026d8:	6a02                	ld	s4,0(sp)
    800026da:	6145                	addi	sp,sp,48
    800026dc:	8082                	ret
    memmove((char *)dst, src, len);
    800026de:	000a061b          	sext.w	a2,s4
    800026e2:	85ce                	mv	a1,s3
    800026e4:	854a                	mv	a0,s2
    800026e6:	ffffe097          	auipc	ra,0xffffe
    800026ea:	6a0080e7          	jalr	1696(ra) # 80000d86 <memmove>
    return 0;
    800026ee:	8526                	mv	a0,s1
    800026f0:	bff9                	j	800026ce <either_copyout+0x32>

00000000800026f2 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800026f2:	7179                	addi	sp,sp,-48
    800026f4:	f406                	sd	ra,40(sp)
    800026f6:	f022                	sd	s0,32(sp)
    800026f8:	ec26                	sd	s1,24(sp)
    800026fa:	e84a                	sd	s2,16(sp)
    800026fc:	e44e                	sd	s3,8(sp)
    800026fe:	e052                	sd	s4,0(sp)
    80002700:	1800                	addi	s0,sp,48
    80002702:	892a                	mv	s2,a0
    80002704:	84ae                	mv	s1,a1
    80002706:	89b2                	mv	s3,a2
    80002708:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000270a:	fffff097          	auipc	ra,0xfffff
    8000270e:	408080e7          	jalr	1032(ra) # 80001b12 <myproc>
  if(user_src){
    80002712:	c08d                	beqz	s1,80002734 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002714:	86d2                	mv	a3,s4
    80002716:	864e                	mv	a2,s3
    80002718:	85ca                	mv	a1,s2
    8000271a:	6928                	ld	a0,80(a0)
    8000271c:	fffff097          	auipc	ra,0xfffff
    80002720:	1f4080e7          	jalr	500(ra) # 80001910 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002724:	70a2                	ld	ra,40(sp)
    80002726:	7402                	ld	s0,32(sp)
    80002728:	64e2                	ld	s1,24(sp)
    8000272a:	6942                	ld	s2,16(sp)
    8000272c:	69a2                	ld	s3,8(sp)
    8000272e:	6a02                	ld	s4,0(sp)
    80002730:	6145                	addi	sp,sp,48
    80002732:	8082                	ret
    memmove(dst, (char*)src, len);
    80002734:	000a061b          	sext.w	a2,s4
    80002738:	85ce                	mv	a1,s3
    8000273a:	854a                	mv	a0,s2
    8000273c:	ffffe097          	auipc	ra,0xffffe
    80002740:	64a080e7          	jalr	1610(ra) # 80000d86 <memmove>
    return 0;
    80002744:	8526                	mv	a0,s1
    80002746:	bff9                	j	80002724 <either_copyin+0x32>

0000000080002748 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002748:	715d                	addi	sp,sp,-80
    8000274a:	e486                	sd	ra,72(sp)
    8000274c:	e0a2                	sd	s0,64(sp)
    8000274e:	fc26                	sd	s1,56(sp)
    80002750:	f84a                	sd	s2,48(sp)
    80002752:	f44e                	sd	s3,40(sp)
    80002754:	f052                	sd	s4,32(sp)
    80002756:	ec56                	sd	s5,24(sp)
    80002758:	e85a                	sd	s6,16(sp)
    8000275a:	e45e                	sd	s7,8(sp)
    8000275c:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000275e:	00006517          	auipc	a0,0x6
    80002762:	96a50513          	addi	a0,a0,-1686 # 800080c8 <digits+0x98>
    80002766:	ffffe097          	auipc	ra,0xffffe
    8000276a:	e2c080e7          	jalr	-468(ra) # 80000592 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000276e:	0000f497          	auipc	s1,0xf
    80002772:	75248493          	addi	s1,s1,1874 # 80011ec0 <proc+0x158>
    80002776:	00015917          	auipc	s2,0x15
    8000277a:	34a90913          	addi	s2,s2,842 # 80017ac0 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000277e:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    80002780:	00006997          	auipc	s3,0x6
    80002784:	b7098993          	addi	s3,s3,-1168 # 800082f0 <digits+0x2c0>
    printf("%d %s %s", p->pid, state, p->name);
    80002788:	00006a97          	auipc	s5,0x6
    8000278c:	b70a8a93          	addi	s5,s5,-1168 # 800082f8 <digits+0x2c8>
    printf("\n");
    80002790:	00006a17          	auipc	s4,0x6
    80002794:	938a0a13          	addi	s4,s4,-1736 # 800080c8 <digits+0x98>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002798:	00006b97          	auipc	s7,0x6
    8000279c:	b98b8b93          	addi	s7,s7,-1128 # 80008330 <states.1730>
    800027a0:	a00d                	j	800027c2 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800027a2:	ee06a583          	lw	a1,-288(a3)
    800027a6:	8556                	mv	a0,s5
    800027a8:	ffffe097          	auipc	ra,0xffffe
    800027ac:	dea080e7          	jalr	-534(ra) # 80000592 <printf>
    printf("\n");
    800027b0:	8552                	mv	a0,s4
    800027b2:	ffffe097          	auipc	ra,0xffffe
    800027b6:	de0080e7          	jalr	-544(ra) # 80000592 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800027ba:	17048493          	addi	s1,s1,368
    800027be:	03248163          	beq	s1,s2,800027e0 <procdump+0x98>
    if(p->state == UNUSED)
    800027c2:	86a6                	mv	a3,s1
    800027c4:	ec04a783          	lw	a5,-320(s1)
    800027c8:	dbed                	beqz	a5,800027ba <procdump+0x72>
      state = "???";
    800027ca:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800027cc:	fcfb6be3          	bltu	s6,a5,800027a2 <procdump+0x5a>
    800027d0:	1782                	slli	a5,a5,0x20
    800027d2:	9381                	srli	a5,a5,0x20
    800027d4:	078e                	slli	a5,a5,0x3
    800027d6:	97de                	add	a5,a5,s7
    800027d8:	6390                	ld	a2,0(a5)
    800027da:	f661                	bnez	a2,800027a2 <procdump+0x5a>
      state = "???";
    800027dc:	864e                	mv	a2,s3
    800027de:	b7d1                	j	800027a2 <procdump+0x5a>
  }
}
    800027e0:	60a6                	ld	ra,72(sp)
    800027e2:	6406                	ld	s0,64(sp)
    800027e4:	74e2                	ld	s1,56(sp)
    800027e6:	7942                	ld	s2,48(sp)
    800027e8:	79a2                	ld	s3,40(sp)
    800027ea:	7a02                	ld	s4,32(sp)
    800027ec:	6ae2                	ld	s5,24(sp)
    800027ee:	6b42                	ld	s6,16(sp)
    800027f0:	6ba2                	ld	s7,8(sp)
    800027f2:	6161                	addi	sp,sp,80
    800027f4:	8082                	ret

00000000800027f6 <swtch>:
    800027f6:	00153023          	sd	ra,0(a0)
    800027fa:	00253423          	sd	sp,8(a0)
    800027fe:	e900                	sd	s0,16(a0)
    80002800:	ed04                	sd	s1,24(a0)
    80002802:	03253023          	sd	s2,32(a0)
    80002806:	03353423          	sd	s3,40(a0)
    8000280a:	03453823          	sd	s4,48(a0)
    8000280e:	03553c23          	sd	s5,56(a0)
    80002812:	05653023          	sd	s6,64(a0)
    80002816:	05753423          	sd	s7,72(a0)
    8000281a:	05853823          	sd	s8,80(a0)
    8000281e:	05953c23          	sd	s9,88(a0)
    80002822:	07a53023          	sd	s10,96(a0)
    80002826:	07b53423          	sd	s11,104(a0)
    8000282a:	0005b083          	ld	ra,0(a1)
    8000282e:	0085b103          	ld	sp,8(a1)
    80002832:	6980                	ld	s0,16(a1)
    80002834:	6d84                	ld	s1,24(a1)
    80002836:	0205b903          	ld	s2,32(a1)
    8000283a:	0285b983          	ld	s3,40(a1)
    8000283e:	0305ba03          	ld	s4,48(a1)
    80002842:	0385ba83          	ld	s5,56(a1)
    80002846:	0405bb03          	ld	s6,64(a1)
    8000284a:	0485bb83          	ld	s7,72(a1)
    8000284e:	0505bc03          	ld	s8,80(a1)
    80002852:	0585bc83          	ld	s9,88(a1)
    80002856:	0605bd03          	ld	s10,96(a1)
    8000285a:	0685bd83          	ld	s11,104(a1)
    8000285e:	8082                	ret

0000000080002860 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002860:	1141                	addi	sp,sp,-16
    80002862:	e406                	sd	ra,8(sp)
    80002864:	e022                	sd	s0,0(sp)
    80002866:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002868:	00006597          	auipc	a1,0x6
    8000286c:	af058593          	addi	a1,a1,-1296 # 80008358 <states.1730+0x28>
    80002870:	00015517          	auipc	a0,0x15
    80002874:	0f850513          	addi	a0,a0,248 # 80017968 <tickslock>
    80002878:	ffffe097          	auipc	ra,0xffffe
    8000287c:	322080e7          	jalr	802(ra) # 80000b9a <initlock>
}
    80002880:	60a2                	ld	ra,8(sp)
    80002882:	6402                	ld	s0,0(sp)
    80002884:	0141                	addi	sp,sp,16
    80002886:	8082                	ret

0000000080002888 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002888:	1141                	addi	sp,sp,-16
    8000288a:	e422                	sd	s0,8(sp)
    8000288c:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000288e:	00003797          	auipc	a5,0x3
    80002892:	53278793          	addi	a5,a5,1330 # 80005dc0 <kernelvec>
    80002896:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000289a:	6422                	ld	s0,8(sp)
    8000289c:	0141                	addi	sp,sp,16
    8000289e:	8082                	ret

00000000800028a0 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800028a0:	1141                	addi	sp,sp,-16
    800028a2:	e406                	sd	ra,8(sp)
    800028a4:	e022                	sd	s0,0(sp)
    800028a6:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800028a8:	fffff097          	auipc	ra,0xfffff
    800028ac:	26a080e7          	jalr	618(ra) # 80001b12 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028b0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800028b4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028b6:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    800028ba:	00004617          	auipc	a2,0x4
    800028be:	74660613          	addi	a2,a2,1862 # 80007000 <_trampoline>
    800028c2:	00004697          	auipc	a3,0x4
    800028c6:	73e68693          	addi	a3,a3,1854 # 80007000 <_trampoline>
    800028ca:	8e91                	sub	a3,a3,a2
    800028cc:	040007b7          	lui	a5,0x4000
    800028d0:	17fd                	addi	a5,a5,-1
    800028d2:	07b2                	slli	a5,a5,0xc
    800028d4:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028d6:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800028da:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800028dc:	180026f3          	csrr	a3,satp
    800028e0:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800028e2:	6d38                	ld	a4,88(a0)
    800028e4:	6134                	ld	a3,64(a0)
    800028e6:	6585                	lui	a1,0x1
    800028e8:	96ae                	add	a3,a3,a1
    800028ea:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800028ec:	6d38                	ld	a4,88(a0)
    800028ee:	00000697          	auipc	a3,0x0
    800028f2:	13868693          	addi	a3,a3,312 # 80002a26 <usertrap>
    800028f6:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800028f8:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800028fa:	8692                	mv	a3,tp
    800028fc:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028fe:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002902:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002906:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000290a:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000290e:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002910:	6f18                	ld	a4,24(a4)
    80002912:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002916:	692c                	ld	a1,80(a0)
    80002918:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    8000291a:	00004717          	auipc	a4,0x4
    8000291e:	77670713          	addi	a4,a4,1910 # 80007090 <userret>
    80002922:	8f11                	sub	a4,a4,a2
    80002924:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002926:	577d                	li	a4,-1
    80002928:	177e                	slli	a4,a4,0x3f
    8000292a:	8dd9                	or	a1,a1,a4
    8000292c:	02000537          	lui	a0,0x2000
    80002930:	157d                	addi	a0,a0,-1
    80002932:	0536                	slli	a0,a0,0xd
    80002934:	9782                	jalr	a5
}
    80002936:	60a2                	ld	ra,8(sp)
    80002938:	6402                	ld	s0,0(sp)
    8000293a:	0141                	addi	sp,sp,16
    8000293c:	8082                	ret

000000008000293e <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000293e:	1101                	addi	sp,sp,-32
    80002940:	ec06                	sd	ra,24(sp)
    80002942:	e822                	sd	s0,16(sp)
    80002944:	e426                	sd	s1,8(sp)
    80002946:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002948:	00015497          	auipc	s1,0x15
    8000294c:	02048493          	addi	s1,s1,32 # 80017968 <tickslock>
    80002950:	8526                	mv	a0,s1
    80002952:	ffffe097          	auipc	ra,0xffffe
    80002956:	2d8080e7          	jalr	728(ra) # 80000c2a <acquire>
  ticks++;
    8000295a:	00006517          	auipc	a0,0x6
    8000295e:	6c650513          	addi	a0,a0,1734 # 80009020 <ticks>
    80002962:	411c                	lw	a5,0(a0)
    80002964:	2785                	addiw	a5,a5,1
    80002966:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002968:	00000097          	auipc	ra,0x0
    8000296c:	c58080e7          	jalr	-936(ra) # 800025c0 <wakeup>
  release(&tickslock);
    80002970:	8526                	mv	a0,s1
    80002972:	ffffe097          	auipc	ra,0xffffe
    80002976:	36c080e7          	jalr	876(ra) # 80000cde <release>
}
    8000297a:	60e2                	ld	ra,24(sp)
    8000297c:	6442                	ld	s0,16(sp)
    8000297e:	64a2                	ld	s1,8(sp)
    80002980:	6105                	addi	sp,sp,32
    80002982:	8082                	ret

0000000080002984 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002984:	1101                	addi	sp,sp,-32
    80002986:	ec06                	sd	ra,24(sp)
    80002988:	e822                	sd	s0,16(sp)
    8000298a:	e426                	sd	s1,8(sp)
    8000298c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000298e:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002992:	00074d63          	bltz	a4,800029ac <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002996:	57fd                	li	a5,-1
    80002998:	17fe                	slli	a5,a5,0x3f
    8000299a:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    8000299c:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    8000299e:	06f70363          	beq	a4,a5,80002a04 <devintr+0x80>
  }
}
    800029a2:	60e2                	ld	ra,24(sp)
    800029a4:	6442                	ld	s0,16(sp)
    800029a6:	64a2                	ld	s1,8(sp)
    800029a8:	6105                	addi	sp,sp,32
    800029aa:	8082                	ret
     (scause & 0xff) == 9){
    800029ac:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    800029b0:	46a5                	li	a3,9
    800029b2:	fed792e3          	bne	a5,a3,80002996 <devintr+0x12>
    int irq = plic_claim();
    800029b6:	00003097          	auipc	ra,0x3
    800029ba:	512080e7          	jalr	1298(ra) # 80005ec8 <plic_claim>
    800029be:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800029c0:	47a9                	li	a5,10
    800029c2:	02f50763          	beq	a0,a5,800029f0 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    800029c6:	4785                	li	a5,1
    800029c8:	02f50963          	beq	a0,a5,800029fa <devintr+0x76>
    return 1;
    800029cc:	4505                	li	a0,1
    } else if(irq){
    800029ce:	d8f1                	beqz	s1,800029a2 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    800029d0:	85a6                	mv	a1,s1
    800029d2:	00006517          	auipc	a0,0x6
    800029d6:	98e50513          	addi	a0,a0,-1650 # 80008360 <states.1730+0x30>
    800029da:	ffffe097          	auipc	ra,0xffffe
    800029de:	bb8080e7          	jalr	-1096(ra) # 80000592 <printf>
      plic_complete(irq);
    800029e2:	8526                	mv	a0,s1
    800029e4:	00003097          	auipc	ra,0x3
    800029e8:	508080e7          	jalr	1288(ra) # 80005eec <plic_complete>
    return 1;
    800029ec:	4505                	li	a0,1
    800029ee:	bf55                	j	800029a2 <devintr+0x1e>
      uartintr();
    800029f0:	ffffe097          	auipc	ra,0xffffe
    800029f4:	fe4080e7          	jalr	-28(ra) # 800009d4 <uartintr>
    800029f8:	b7ed                	j	800029e2 <devintr+0x5e>
      virtio_disk_intr();
    800029fa:	00004097          	auipc	ra,0x4
    800029fe:	998080e7          	jalr	-1640(ra) # 80006392 <virtio_disk_intr>
    80002a02:	b7c5                	j	800029e2 <devintr+0x5e>
    if(cpuid() == 0){
    80002a04:	fffff097          	auipc	ra,0xfffff
    80002a08:	0e2080e7          	jalr	226(ra) # 80001ae6 <cpuid>
    80002a0c:	c901                	beqz	a0,80002a1c <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002a0e:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002a12:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002a14:	14479073          	csrw	sip,a5
    return 2;
    80002a18:	4509                	li	a0,2
    80002a1a:	b761                	j	800029a2 <devintr+0x1e>
      clockintr();
    80002a1c:	00000097          	auipc	ra,0x0
    80002a20:	f22080e7          	jalr	-222(ra) # 8000293e <clockintr>
    80002a24:	b7ed                	j	80002a0e <devintr+0x8a>

0000000080002a26 <usertrap>:
{
    80002a26:	1101                	addi	sp,sp,-32
    80002a28:	ec06                	sd	ra,24(sp)
    80002a2a:	e822                	sd	s0,16(sp)
    80002a2c:	e426                	sd	s1,8(sp)
    80002a2e:	e04a                	sd	s2,0(sp)
    80002a30:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a32:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002a36:	1007f793          	andi	a5,a5,256
    80002a3a:	e3ad                	bnez	a5,80002a9c <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a3c:	00003797          	auipc	a5,0x3
    80002a40:	38478793          	addi	a5,a5,900 # 80005dc0 <kernelvec>
    80002a44:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002a48:	fffff097          	auipc	ra,0xfffff
    80002a4c:	0ca080e7          	jalr	202(ra) # 80001b12 <myproc>
    80002a50:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002a52:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a54:	14102773          	csrr	a4,sepc
    80002a58:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a5a:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002a5e:	47a1                	li	a5,8
    80002a60:	04f71c63          	bne	a4,a5,80002ab8 <usertrap+0x92>
    if(p->killed)
    80002a64:	591c                	lw	a5,48(a0)
    80002a66:	e3b9                	bnez	a5,80002aac <usertrap+0x86>
    p->trapframe->epc += 4;
    80002a68:	6cb8                	ld	a4,88(s1)
    80002a6a:	6f1c                	ld	a5,24(a4)
    80002a6c:	0791                	addi	a5,a5,4
    80002a6e:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a70:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002a74:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a78:	10079073          	csrw	sstatus,a5
    syscall();
    80002a7c:	00000097          	auipc	ra,0x0
    80002a80:	2e0080e7          	jalr	736(ra) # 80002d5c <syscall>
  if(p->killed)
    80002a84:	589c                	lw	a5,48(s1)
    80002a86:	ebc1                	bnez	a5,80002b16 <usertrap+0xf0>
  usertrapret();
    80002a88:	00000097          	auipc	ra,0x0
    80002a8c:	e18080e7          	jalr	-488(ra) # 800028a0 <usertrapret>
}
    80002a90:	60e2                	ld	ra,24(sp)
    80002a92:	6442                	ld	s0,16(sp)
    80002a94:	64a2                	ld	s1,8(sp)
    80002a96:	6902                	ld	s2,0(sp)
    80002a98:	6105                	addi	sp,sp,32
    80002a9a:	8082                	ret
    panic("usertrap: not from user mode");
    80002a9c:	00006517          	auipc	a0,0x6
    80002aa0:	8e450513          	addi	a0,a0,-1820 # 80008380 <states.1730+0x50>
    80002aa4:	ffffe097          	auipc	ra,0xffffe
    80002aa8:	aa4080e7          	jalr	-1372(ra) # 80000548 <panic>
      exit(-1);
    80002aac:	557d                	li	a0,-1
    80002aae:	00000097          	auipc	ra,0x0
    80002ab2:	846080e7          	jalr	-1978(ra) # 800022f4 <exit>
    80002ab6:	bf4d                	j	80002a68 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002ab8:	00000097          	auipc	ra,0x0
    80002abc:	ecc080e7          	jalr	-308(ra) # 80002984 <devintr>
    80002ac0:	892a                	mv	s2,a0
    80002ac2:	c501                	beqz	a0,80002aca <usertrap+0xa4>
  if(p->killed)
    80002ac4:	589c                	lw	a5,48(s1)
    80002ac6:	c3a1                	beqz	a5,80002b06 <usertrap+0xe0>
    80002ac8:	a815                	j	80002afc <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002aca:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002ace:	5c90                	lw	a2,56(s1)
    80002ad0:	00006517          	auipc	a0,0x6
    80002ad4:	8d050513          	addi	a0,a0,-1840 # 800083a0 <states.1730+0x70>
    80002ad8:	ffffe097          	auipc	ra,0xffffe
    80002adc:	aba080e7          	jalr	-1350(ra) # 80000592 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ae0:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002ae4:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002ae8:	00006517          	auipc	a0,0x6
    80002aec:	8e850513          	addi	a0,a0,-1816 # 800083d0 <states.1730+0xa0>
    80002af0:	ffffe097          	auipc	ra,0xffffe
    80002af4:	aa2080e7          	jalr	-1374(ra) # 80000592 <printf>
    p->killed = 1;
    80002af8:	4785                	li	a5,1
    80002afa:	d89c                	sw	a5,48(s1)
    exit(-1);
    80002afc:	557d                	li	a0,-1
    80002afe:	fffff097          	auipc	ra,0xfffff
    80002b02:	7f6080e7          	jalr	2038(ra) # 800022f4 <exit>
  if(which_dev == 2)
    80002b06:	4789                	li	a5,2
    80002b08:	f8f910e3          	bne	s2,a5,80002a88 <usertrap+0x62>
    yield();
    80002b0c:	00000097          	auipc	ra,0x0
    80002b10:	8f2080e7          	jalr	-1806(ra) # 800023fe <yield>
    80002b14:	bf95                	j	80002a88 <usertrap+0x62>
  int which_dev = 0;
    80002b16:	4901                	li	s2,0
    80002b18:	b7d5                	j	80002afc <usertrap+0xd6>

0000000080002b1a <kerneltrap>:
{
    80002b1a:	7179                	addi	sp,sp,-48
    80002b1c:	f406                	sd	ra,40(sp)
    80002b1e:	f022                	sd	s0,32(sp)
    80002b20:	ec26                	sd	s1,24(sp)
    80002b22:	e84a                	sd	s2,16(sp)
    80002b24:	e44e                	sd	s3,8(sp)
    80002b26:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b28:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b2c:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b30:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002b34:	1004f793          	andi	a5,s1,256
    80002b38:	cb85                	beqz	a5,80002b68 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b3a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002b3e:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002b40:	ef85                	bnez	a5,80002b78 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002b42:	00000097          	auipc	ra,0x0
    80002b46:	e42080e7          	jalr	-446(ra) # 80002984 <devintr>
    80002b4a:	cd1d                	beqz	a0,80002b88 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002b4c:	4789                	li	a5,2
    80002b4e:	06f50a63          	beq	a0,a5,80002bc2 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002b52:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b56:	10049073          	csrw	sstatus,s1
}
    80002b5a:	70a2                	ld	ra,40(sp)
    80002b5c:	7402                	ld	s0,32(sp)
    80002b5e:	64e2                	ld	s1,24(sp)
    80002b60:	6942                	ld	s2,16(sp)
    80002b62:	69a2                	ld	s3,8(sp)
    80002b64:	6145                	addi	sp,sp,48
    80002b66:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002b68:	00006517          	auipc	a0,0x6
    80002b6c:	88850513          	addi	a0,a0,-1912 # 800083f0 <states.1730+0xc0>
    80002b70:	ffffe097          	auipc	ra,0xffffe
    80002b74:	9d8080e7          	jalr	-1576(ra) # 80000548 <panic>
    panic("kerneltrap: interrupts enabled");
    80002b78:	00006517          	auipc	a0,0x6
    80002b7c:	8a050513          	addi	a0,a0,-1888 # 80008418 <states.1730+0xe8>
    80002b80:	ffffe097          	auipc	ra,0xffffe
    80002b84:	9c8080e7          	jalr	-1592(ra) # 80000548 <panic>
    printf("scause %p\n", scause);
    80002b88:	85ce                	mv	a1,s3
    80002b8a:	00006517          	auipc	a0,0x6
    80002b8e:	8ae50513          	addi	a0,a0,-1874 # 80008438 <states.1730+0x108>
    80002b92:	ffffe097          	auipc	ra,0xffffe
    80002b96:	a00080e7          	jalr	-1536(ra) # 80000592 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b9a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b9e:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002ba2:	00006517          	auipc	a0,0x6
    80002ba6:	8a650513          	addi	a0,a0,-1882 # 80008448 <states.1730+0x118>
    80002baa:	ffffe097          	auipc	ra,0xffffe
    80002bae:	9e8080e7          	jalr	-1560(ra) # 80000592 <printf>
    panic("kerneltrap");
    80002bb2:	00006517          	auipc	a0,0x6
    80002bb6:	8ae50513          	addi	a0,a0,-1874 # 80008460 <states.1730+0x130>
    80002bba:	ffffe097          	auipc	ra,0xffffe
    80002bbe:	98e080e7          	jalr	-1650(ra) # 80000548 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002bc2:	fffff097          	auipc	ra,0xfffff
    80002bc6:	f50080e7          	jalr	-176(ra) # 80001b12 <myproc>
    80002bca:	d541                	beqz	a0,80002b52 <kerneltrap+0x38>
    80002bcc:	fffff097          	auipc	ra,0xfffff
    80002bd0:	f46080e7          	jalr	-186(ra) # 80001b12 <myproc>
    80002bd4:	4d18                	lw	a4,24(a0)
    80002bd6:	478d                	li	a5,3
    80002bd8:	f6f71de3          	bne	a4,a5,80002b52 <kerneltrap+0x38>
    yield();
    80002bdc:	00000097          	auipc	ra,0x0
    80002be0:	822080e7          	jalr	-2014(ra) # 800023fe <yield>
    80002be4:	b7bd                	j	80002b52 <kerneltrap+0x38>

0000000080002be6 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002be6:	1101                	addi	sp,sp,-32
    80002be8:	ec06                	sd	ra,24(sp)
    80002bea:	e822                	sd	s0,16(sp)
    80002bec:	e426                	sd	s1,8(sp)
    80002bee:	1000                	addi	s0,sp,32
    80002bf0:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002bf2:	fffff097          	auipc	ra,0xfffff
    80002bf6:	f20080e7          	jalr	-224(ra) # 80001b12 <myproc>
  switch (n) {
    80002bfa:	4795                	li	a5,5
    80002bfc:	0497e163          	bltu	a5,s1,80002c3e <argraw+0x58>
    80002c00:	048a                	slli	s1,s1,0x2
    80002c02:	00006717          	auipc	a4,0x6
    80002c06:	89670713          	addi	a4,a4,-1898 # 80008498 <states.1730+0x168>
    80002c0a:	94ba                	add	s1,s1,a4
    80002c0c:	409c                	lw	a5,0(s1)
    80002c0e:	97ba                	add	a5,a5,a4
    80002c10:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002c12:	6d3c                	ld	a5,88(a0)
    80002c14:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002c16:	60e2                	ld	ra,24(sp)
    80002c18:	6442                	ld	s0,16(sp)
    80002c1a:	64a2                	ld	s1,8(sp)
    80002c1c:	6105                	addi	sp,sp,32
    80002c1e:	8082                	ret
    return p->trapframe->a1;
    80002c20:	6d3c                	ld	a5,88(a0)
    80002c22:	7fa8                	ld	a0,120(a5)
    80002c24:	bfcd                	j	80002c16 <argraw+0x30>
    return p->trapframe->a2;
    80002c26:	6d3c                	ld	a5,88(a0)
    80002c28:	63c8                	ld	a0,128(a5)
    80002c2a:	b7f5                	j	80002c16 <argraw+0x30>
    return p->trapframe->a3;
    80002c2c:	6d3c                	ld	a5,88(a0)
    80002c2e:	67c8                	ld	a0,136(a5)
    80002c30:	b7dd                	j	80002c16 <argraw+0x30>
    return p->trapframe->a4;
    80002c32:	6d3c                	ld	a5,88(a0)
    80002c34:	6bc8                	ld	a0,144(a5)
    80002c36:	b7c5                	j	80002c16 <argraw+0x30>
    return p->trapframe->a5;
    80002c38:	6d3c                	ld	a5,88(a0)
    80002c3a:	6fc8                	ld	a0,152(a5)
    80002c3c:	bfe9                	j	80002c16 <argraw+0x30>
  panic("argraw");
    80002c3e:	00006517          	auipc	a0,0x6
    80002c42:	83250513          	addi	a0,a0,-1998 # 80008470 <states.1730+0x140>
    80002c46:	ffffe097          	auipc	ra,0xffffe
    80002c4a:	902080e7          	jalr	-1790(ra) # 80000548 <panic>

0000000080002c4e <fetchaddr>:
{
    80002c4e:	1101                	addi	sp,sp,-32
    80002c50:	ec06                	sd	ra,24(sp)
    80002c52:	e822                	sd	s0,16(sp)
    80002c54:	e426                	sd	s1,8(sp)
    80002c56:	e04a                	sd	s2,0(sp)
    80002c58:	1000                	addi	s0,sp,32
    80002c5a:	84aa                	mv	s1,a0
    80002c5c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002c5e:	fffff097          	auipc	ra,0xfffff
    80002c62:	eb4080e7          	jalr	-332(ra) # 80001b12 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002c66:	653c                	ld	a5,72(a0)
    80002c68:	02f4f863          	bgeu	s1,a5,80002c98 <fetchaddr+0x4a>
    80002c6c:	00848713          	addi	a4,s1,8
    80002c70:	02e7e663          	bltu	a5,a4,80002c9c <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002c74:	46a1                	li	a3,8
    80002c76:	8626                	mv	a2,s1
    80002c78:	85ca                	mv	a1,s2
    80002c7a:	6928                	ld	a0,80(a0)
    80002c7c:	fffff097          	auipc	ra,0xfffff
    80002c80:	c94080e7          	jalr	-876(ra) # 80001910 <copyin>
    80002c84:	00a03533          	snez	a0,a0
    80002c88:	40a00533          	neg	a0,a0
}
    80002c8c:	60e2                	ld	ra,24(sp)
    80002c8e:	6442                	ld	s0,16(sp)
    80002c90:	64a2                	ld	s1,8(sp)
    80002c92:	6902                	ld	s2,0(sp)
    80002c94:	6105                	addi	sp,sp,32
    80002c96:	8082                	ret
    return -1;
    80002c98:	557d                	li	a0,-1
    80002c9a:	bfcd                	j	80002c8c <fetchaddr+0x3e>
    80002c9c:	557d                	li	a0,-1
    80002c9e:	b7fd                	j	80002c8c <fetchaddr+0x3e>

0000000080002ca0 <fetchstr>:
{
    80002ca0:	7179                	addi	sp,sp,-48
    80002ca2:	f406                	sd	ra,40(sp)
    80002ca4:	f022                	sd	s0,32(sp)
    80002ca6:	ec26                	sd	s1,24(sp)
    80002ca8:	e84a                	sd	s2,16(sp)
    80002caa:	e44e                	sd	s3,8(sp)
    80002cac:	1800                	addi	s0,sp,48
    80002cae:	892a                	mv	s2,a0
    80002cb0:	84ae                	mv	s1,a1
    80002cb2:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002cb4:	fffff097          	auipc	ra,0xfffff
    80002cb8:	e5e080e7          	jalr	-418(ra) # 80001b12 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002cbc:	86ce                	mv	a3,s3
    80002cbe:	864a                	mv	a2,s2
    80002cc0:	85a6                	mv	a1,s1
    80002cc2:	6928                	ld	a0,80(a0)
    80002cc4:	fffff097          	auipc	ra,0xfffff
    80002cc8:	c64080e7          	jalr	-924(ra) # 80001928 <copyinstr>
  if(err < 0)
    80002ccc:	00054763          	bltz	a0,80002cda <fetchstr+0x3a>
  return strlen(buf);
    80002cd0:	8526                	mv	a0,s1
    80002cd2:	ffffe097          	auipc	ra,0xffffe
    80002cd6:	1dc080e7          	jalr	476(ra) # 80000eae <strlen>
}
    80002cda:	70a2                	ld	ra,40(sp)
    80002cdc:	7402                	ld	s0,32(sp)
    80002cde:	64e2                	ld	s1,24(sp)
    80002ce0:	6942                	ld	s2,16(sp)
    80002ce2:	69a2                	ld	s3,8(sp)
    80002ce4:	6145                	addi	sp,sp,48
    80002ce6:	8082                	ret

0000000080002ce8 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002ce8:	1101                	addi	sp,sp,-32
    80002cea:	ec06                	sd	ra,24(sp)
    80002cec:	e822                	sd	s0,16(sp)
    80002cee:	e426                	sd	s1,8(sp)
    80002cf0:	1000                	addi	s0,sp,32
    80002cf2:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002cf4:	00000097          	auipc	ra,0x0
    80002cf8:	ef2080e7          	jalr	-270(ra) # 80002be6 <argraw>
    80002cfc:	c088                	sw	a0,0(s1)
  return 0;
}
    80002cfe:	4501                	li	a0,0
    80002d00:	60e2                	ld	ra,24(sp)
    80002d02:	6442                	ld	s0,16(sp)
    80002d04:	64a2                	ld	s1,8(sp)
    80002d06:	6105                	addi	sp,sp,32
    80002d08:	8082                	ret

0000000080002d0a <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002d0a:	1101                	addi	sp,sp,-32
    80002d0c:	ec06                	sd	ra,24(sp)
    80002d0e:	e822                	sd	s0,16(sp)
    80002d10:	e426                	sd	s1,8(sp)
    80002d12:	1000                	addi	s0,sp,32
    80002d14:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d16:	00000097          	auipc	ra,0x0
    80002d1a:	ed0080e7          	jalr	-304(ra) # 80002be6 <argraw>
    80002d1e:	e088                	sd	a0,0(s1)
  return 0;
}
    80002d20:	4501                	li	a0,0
    80002d22:	60e2                	ld	ra,24(sp)
    80002d24:	6442                	ld	s0,16(sp)
    80002d26:	64a2                	ld	s1,8(sp)
    80002d28:	6105                	addi	sp,sp,32
    80002d2a:	8082                	ret

0000000080002d2c <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002d2c:	1101                	addi	sp,sp,-32
    80002d2e:	ec06                	sd	ra,24(sp)
    80002d30:	e822                	sd	s0,16(sp)
    80002d32:	e426                	sd	s1,8(sp)
    80002d34:	e04a                	sd	s2,0(sp)
    80002d36:	1000                	addi	s0,sp,32
    80002d38:	84ae                	mv	s1,a1
    80002d3a:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002d3c:	00000097          	auipc	ra,0x0
    80002d40:	eaa080e7          	jalr	-342(ra) # 80002be6 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002d44:	864a                	mv	a2,s2
    80002d46:	85a6                	mv	a1,s1
    80002d48:	00000097          	auipc	ra,0x0
    80002d4c:	f58080e7          	jalr	-168(ra) # 80002ca0 <fetchstr>
}
    80002d50:	60e2                	ld	ra,24(sp)
    80002d52:	6442                	ld	s0,16(sp)
    80002d54:	64a2                	ld	s1,8(sp)
    80002d56:	6902                	ld	s2,0(sp)
    80002d58:	6105                	addi	sp,sp,32
    80002d5a:	8082                	ret

0000000080002d5c <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002d5c:	1101                	addi	sp,sp,-32
    80002d5e:	ec06                	sd	ra,24(sp)
    80002d60:	e822                	sd	s0,16(sp)
    80002d62:	e426                	sd	s1,8(sp)
    80002d64:	e04a                	sd	s2,0(sp)
    80002d66:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002d68:	fffff097          	auipc	ra,0xfffff
    80002d6c:	daa080e7          	jalr	-598(ra) # 80001b12 <myproc>
    80002d70:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002d72:	05853903          	ld	s2,88(a0)
    80002d76:	0a893783          	ld	a5,168(s2)
    80002d7a:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002d7e:	37fd                	addiw	a5,a5,-1
    80002d80:	4751                	li	a4,20
    80002d82:	00f76f63          	bltu	a4,a5,80002da0 <syscall+0x44>
    80002d86:	00369713          	slli	a4,a3,0x3
    80002d8a:	00005797          	auipc	a5,0x5
    80002d8e:	72678793          	addi	a5,a5,1830 # 800084b0 <syscalls>
    80002d92:	97ba                	add	a5,a5,a4
    80002d94:	639c                	ld	a5,0(a5)
    80002d96:	c789                	beqz	a5,80002da0 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002d98:	9782                	jalr	a5
    80002d9a:	06a93823          	sd	a0,112(s2)
    80002d9e:	a839                	j	80002dbc <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002da0:	15848613          	addi	a2,s1,344
    80002da4:	5c8c                	lw	a1,56(s1)
    80002da6:	00005517          	auipc	a0,0x5
    80002daa:	6d250513          	addi	a0,a0,1746 # 80008478 <states.1730+0x148>
    80002dae:	ffffd097          	auipc	ra,0xffffd
    80002db2:	7e4080e7          	jalr	2020(ra) # 80000592 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002db6:	6cbc                	ld	a5,88(s1)
    80002db8:	577d                	li	a4,-1
    80002dba:	fbb8                	sd	a4,112(a5)
  }
}
    80002dbc:	60e2                	ld	ra,24(sp)
    80002dbe:	6442                	ld	s0,16(sp)
    80002dc0:	64a2                	ld	s1,8(sp)
    80002dc2:	6902                	ld	s2,0(sp)
    80002dc4:	6105                	addi	sp,sp,32
    80002dc6:	8082                	ret

0000000080002dc8 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002dc8:	1101                	addi	sp,sp,-32
    80002dca:	ec06                	sd	ra,24(sp)
    80002dcc:	e822                	sd	s0,16(sp)
    80002dce:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002dd0:	fec40593          	addi	a1,s0,-20
    80002dd4:	4501                	li	a0,0
    80002dd6:	00000097          	auipc	ra,0x0
    80002dda:	f12080e7          	jalr	-238(ra) # 80002ce8 <argint>
    return -1;
    80002dde:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002de0:	00054963          	bltz	a0,80002df2 <sys_exit+0x2a>
  exit(n);
    80002de4:	fec42503          	lw	a0,-20(s0)
    80002de8:	fffff097          	auipc	ra,0xfffff
    80002dec:	50c080e7          	jalr	1292(ra) # 800022f4 <exit>
  return 0;  // not reached
    80002df0:	4781                	li	a5,0
}
    80002df2:	853e                	mv	a0,a5
    80002df4:	60e2                	ld	ra,24(sp)
    80002df6:	6442                	ld	s0,16(sp)
    80002df8:	6105                	addi	sp,sp,32
    80002dfa:	8082                	ret

0000000080002dfc <sys_getpid>:

uint64
sys_getpid(void)
{
    80002dfc:	1141                	addi	sp,sp,-16
    80002dfe:	e406                	sd	ra,8(sp)
    80002e00:	e022                	sd	s0,0(sp)
    80002e02:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002e04:	fffff097          	auipc	ra,0xfffff
    80002e08:	d0e080e7          	jalr	-754(ra) # 80001b12 <myproc>
}
    80002e0c:	5d08                	lw	a0,56(a0)
    80002e0e:	60a2                	ld	ra,8(sp)
    80002e10:	6402                	ld	s0,0(sp)
    80002e12:	0141                	addi	sp,sp,16
    80002e14:	8082                	ret

0000000080002e16 <sys_fork>:

uint64
sys_fork(void)
{
    80002e16:	1141                	addi	sp,sp,-16
    80002e18:	e406                	sd	ra,8(sp)
    80002e1a:	e022                	sd	s0,0(sp)
    80002e1c:	0800                	addi	s0,sp,16
  return fork();
    80002e1e:	fffff097          	auipc	ra,0xfffff
    80002e22:	198080e7          	jalr	408(ra) # 80001fb6 <fork>
}
    80002e26:	60a2                	ld	ra,8(sp)
    80002e28:	6402                	ld	s0,0(sp)
    80002e2a:	0141                	addi	sp,sp,16
    80002e2c:	8082                	ret

0000000080002e2e <sys_wait>:

uint64
sys_wait(void)
{
    80002e2e:	1101                	addi	sp,sp,-32
    80002e30:	ec06                	sd	ra,24(sp)
    80002e32:	e822                	sd	s0,16(sp)
    80002e34:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002e36:	fe840593          	addi	a1,s0,-24
    80002e3a:	4501                	li	a0,0
    80002e3c:	00000097          	auipc	ra,0x0
    80002e40:	ece080e7          	jalr	-306(ra) # 80002d0a <argaddr>
    80002e44:	87aa                	mv	a5,a0
    return -1;
    80002e46:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002e48:	0007c863          	bltz	a5,80002e58 <sys_wait+0x2a>
  return wait(p);
    80002e4c:	fe843503          	ld	a0,-24(s0)
    80002e50:	fffff097          	auipc	ra,0xfffff
    80002e54:	668080e7          	jalr	1640(ra) # 800024b8 <wait>
}
    80002e58:	60e2                	ld	ra,24(sp)
    80002e5a:	6442                	ld	s0,16(sp)
    80002e5c:	6105                	addi	sp,sp,32
    80002e5e:	8082                	ret

0000000080002e60 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002e60:	7179                	addi	sp,sp,-48
    80002e62:	f406                	sd	ra,40(sp)
    80002e64:	f022                	sd	s0,32(sp)
    80002e66:	ec26                	sd	s1,24(sp)
    80002e68:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002e6a:	fdc40593          	addi	a1,s0,-36
    80002e6e:	4501                	li	a0,0
    80002e70:	00000097          	auipc	ra,0x0
    80002e74:	e78080e7          	jalr	-392(ra) # 80002ce8 <argint>
    80002e78:	87aa                	mv	a5,a0
    return -1;
    80002e7a:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80002e7c:	0207c063          	bltz	a5,80002e9c <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80002e80:	fffff097          	auipc	ra,0xfffff
    80002e84:	c92080e7          	jalr	-878(ra) # 80001b12 <myproc>
    80002e88:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002e8a:	fdc42503          	lw	a0,-36(s0)
    80002e8e:	fffff097          	auipc	ra,0xfffff
    80002e92:	05c080e7          	jalr	92(ra) # 80001eea <growproc>
    80002e96:	00054863          	bltz	a0,80002ea6 <sys_sbrk+0x46>
    return -1;
  return addr;
    80002e9a:	8526                	mv	a0,s1
}
    80002e9c:	70a2                	ld	ra,40(sp)
    80002e9e:	7402                	ld	s0,32(sp)
    80002ea0:	64e2                	ld	s1,24(sp)
    80002ea2:	6145                	addi	sp,sp,48
    80002ea4:	8082                	ret
    return -1;
    80002ea6:	557d                	li	a0,-1
    80002ea8:	bfd5                	j	80002e9c <sys_sbrk+0x3c>

0000000080002eaa <sys_sleep>:

uint64
sys_sleep(void)
{
    80002eaa:	7139                	addi	sp,sp,-64
    80002eac:	fc06                	sd	ra,56(sp)
    80002eae:	f822                	sd	s0,48(sp)
    80002eb0:	f426                	sd	s1,40(sp)
    80002eb2:	f04a                	sd	s2,32(sp)
    80002eb4:	ec4e                	sd	s3,24(sp)
    80002eb6:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002eb8:	fcc40593          	addi	a1,s0,-52
    80002ebc:	4501                	li	a0,0
    80002ebe:	00000097          	auipc	ra,0x0
    80002ec2:	e2a080e7          	jalr	-470(ra) # 80002ce8 <argint>
    return -1;
    80002ec6:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002ec8:	06054563          	bltz	a0,80002f32 <sys_sleep+0x88>
  acquire(&tickslock);
    80002ecc:	00015517          	auipc	a0,0x15
    80002ed0:	a9c50513          	addi	a0,a0,-1380 # 80017968 <tickslock>
    80002ed4:	ffffe097          	auipc	ra,0xffffe
    80002ed8:	d56080e7          	jalr	-682(ra) # 80000c2a <acquire>
  ticks0 = ticks;
    80002edc:	00006917          	auipc	s2,0x6
    80002ee0:	14492903          	lw	s2,324(s2) # 80009020 <ticks>
  while(ticks - ticks0 < n){
    80002ee4:	fcc42783          	lw	a5,-52(s0)
    80002ee8:	cf85                	beqz	a5,80002f20 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002eea:	00015997          	auipc	s3,0x15
    80002eee:	a7e98993          	addi	s3,s3,-1410 # 80017968 <tickslock>
    80002ef2:	00006497          	auipc	s1,0x6
    80002ef6:	12e48493          	addi	s1,s1,302 # 80009020 <ticks>
    if(myproc()->killed){
    80002efa:	fffff097          	auipc	ra,0xfffff
    80002efe:	c18080e7          	jalr	-1000(ra) # 80001b12 <myproc>
    80002f02:	591c                	lw	a5,48(a0)
    80002f04:	ef9d                	bnez	a5,80002f42 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002f06:	85ce                	mv	a1,s3
    80002f08:	8526                	mv	a0,s1
    80002f0a:	fffff097          	auipc	ra,0xfffff
    80002f0e:	530080e7          	jalr	1328(ra) # 8000243a <sleep>
  while(ticks - ticks0 < n){
    80002f12:	409c                	lw	a5,0(s1)
    80002f14:	412787bb          	subw	a5,a5,s2
    80002f18:	fcc42703          	lw	a4,-52(s0)
    80002f1c:	fce7efe3          	bltu	a5,a4,80002efa <sys_sleep+0x50>
  }
  release(&tickslock);
    80002f20:	00015517          	auipc	a0,0x15
    80002f24:	a4850513          	addi	a0,a0,-1464 # 80017968 <tickslock>
    80002f28:	ffffe097          	auipc	ra,0xffffe
    80002f2c:	db6080e7          	jalr	-586(ra) # 80000cde <release>
  return 0;
    80002f30:	4781                	li	a5,0
}
    80002f32:	853e                	mv	a0,a5
    80002f34:	70e2                	ld	ra,56(sp)
    80002f36:	7442                	ld	s0,48(sp)
    80002f38:	74a2                	ld	s1,40(sp)
    80002f3a:	7902                	ld	s2,32(sp)
    80002f3c:	69e2                	ld	s3,24(sp)
    80002f3e:	6121                	addi	sp,sp,64
    80002f40:	8082                	ret
      release(&tickslock);
    80002f42:	00015517          	auipc	a0,0x15
    80002f46:	a2650513          	addi	a0,a0,-1498 # 80017968 <tickslock>
    80002f4a:	ffffe097          	auipc	ra,0xffffe
    80002f4e:	d94080e7          	jalr	-620(ra) # 80000cde <release>
      return -1;
    80002f52:	57fd                	li	a5,-1
    80002f54:	bff9                	j	80002f32 <sys_sleep+0x88>

0000000080002f56 <sys_kill>:

uint64
sys_kill(void)
{
    80002f56:	1101                	addi	sp,sp,-32
    80002f58:	ec06                	sd	ra,24(sp)
    80002f5a:	e822                	sd	s0,16(sp)
    80002f5c:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002f5e:	fec40593          	addi	a1,s0,-20
    80002f62:	4501                	li	a0,0
    80002f64:	00000097          	auipc	ra,0x0
    80002f68:	d84080e7          	jalr	-636(ra) # 80002ce8 <argint>
    80002f6c:	87aa                	mv	a5,a0
    return -1;
    80002f6e:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002f70:	0007c863          	bltz	a5,80002f80 <sys_kill+0x2a>
  return kill(pid);
    80002f74:	fec42503          	lw	a0,-20(s0)
    80002f78:	fffff097          	auipc	ra,0xfffff
    80002f7c:	6b2080e7          	jalr	1714(ra) # 8000262a <kill>
}
    80002f80:	60e2                	ld	ra,24(sp)
    80002f82:	6442                	ld	s0,16(sp)
    80002f84:	6105                	addi	sp,sp,32
    80002f86:	8082                	ret

0000000080002f88 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002f88:	1101                	addi	sp,sp,-32
    80002f8a:	ec06                	sd	ra,24(sp)
    80002f8c:	e822                	sd	s0,16(sp)
    80002f8e:	e426                	sd	s1,8(sp)
    80002f90:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002f92:	00015517          	auipc	a0,0x15
    80002f96:	9d650513          	addi	a0,a0,-1578 # 80017968 <tickslock>
    80002f9a:	ffffe097          	auipc	ra,0xffffe
    80002f9e:	c90080e7          	jalr	-880(ra) # 80000c2a <acquire>
  xticks = ticks;
    80002fa2:	00006497          	auipc	s1,0x6
    80002fa6:	07e4a483          	lw	s1,126(s1) # 80009020 <ticks>
  release(&tickslock);
    80002faa:	00015517          	auipc	a0,0x15
    80002fae:	9be50513          	addi	a0,a0,-1602 # 80017968 <tickslock>
    80002fb2:	ffffe097          	auipc	ra,0xffffe
    80002fb6:	d2c080e7          	jalr	-724(ra) # 80000cde <release>
  return xticks;
}
    80002fba:	02049513          	slli	a0,s1,0x20
    80002fbe:	9101                	srli	a0,a0,0x20
    80002fc0:	60e2                	ld	ra,24(sp)
    80002fc2:	6442                	ld	s0,16(sp)
    80002fc4:	64a2                	ld	s1,8(sp)
    80002fc6:	6105                	addi	sp,sp,32
    80002fc8:	8082                	ret

0000000080002fca <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002fca:	7179                	addi	sp,sp,-48
    80002fcc:	f406                	sd	ra,40(sp)
    80002fce:	f022                	sd	s0,32(sp)
    80002fd0:	ec26                	sd	s1,24(sp)
    80002fd2:	e84a                	sd	s2,16(sp)
    80002fd4:	e44e                	sd	s3,8(sp)
    80002fd6:	e052                	sd	s4,0(sp)
    80002fd8:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002fda:	00005597          	auipc	a1,0x5
    80002fde:	58658593          	addi	a1,a1,1414 # 80008560 <syscalls+0xb0>
    80002fe2:	00015517          	auipc	a0,0x15
    80002fe6:	99e50513          	addi	a0,a0,-1634 # 80017980 <bcache>
    80002fea:	ffffe097          	auipc	ra,0xffffe
    80002fee:	bb0080e7          	jalr	-1104(ra) # 80000b9a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002ff2:	0001d797          	auipc	a5,0x1d
    80002ff6:	98e78793          	addi	a5,a5,-1650 # 8001f980 <bcache+0x8000>
    80002ffa:	0001d717          	auipc	a4,0x1d
    80002ffe:	bee70713          	addi	a4,a4,-1042 # 8001fbe8 <bcache+0x8268>
    80003002:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003006:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000300a:	00015497          	auipc	s1,0x15
    8000300e:	98e48493          	addi	s1,s1,-1650 # 80017998 <bcache+0x18>
    b->next = bcache.head.next;
    80003012:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003014:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003016:	00005a17          	auipc	s4,0x5
    8000301a:	552a0a13          	addi	s4,s4,1362 # 80008568 <syscalls+0xb8>
    b->next = bcache.head.next;
    8000301e:	2b893783          	ld	a5,696(s2)
    80003022:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003024:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003028:	85d2                	mv	a1,s4
    8000302a:	01048513          	addi	a0,s1,16
    8000302e:	00001097          	auipc	ra,0x1
    80003032:	4ac080e7          	jalr	1196(ra) # 800044da <initsleeplock>
    bcache.head.next->prev = b;
    80003036:	2b893783          	ld	a5,696(s2)
    8000303a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000303c:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003040:	45848493          	addi	s1,s1,1112
    80003044:	fd349de3          	bne	s1,s3,8000301e <binit+0x54>
  }
}
    80003048:	70a2                	ld	ra,40(sp)
    8000304a:	7402                	ld	s0,32(sp)
    8000304c:	64e2                	ld	s1,24(sp)
    8000304e:	6942                	ld	s2,16(sp)
    80003050:	69a2                	ld	s3,8(sp)
    80003052:	6a02                	ld	s4,0(sp)
    80003054:	6145                	addi	sp,sp,48
    80003056:	8082                	ret

0000000080003058 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003058:	7179                	addi	sp,sp,-48
    8000305a:	f406                	sd	ra,40(sp)
    8000305c:	f022                	sd	s0,32(sp)
    8000305e:	ec26                	sd	s1,24(sp)
    80003060:	e84a                	sd	s2,16(sp)
    80003062:	e44e                	sd	s3,8(sp)
    80003064:	1800                	addi	s0,sp,48
    80003066:	89aa                	mv	s3,a0
    80003068:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    8000306a:	00015517          	auipc	a0,0x15
    8000306e:	91650513          	addi	a0,a0,-1770 # 80017980 <bcache>
    80003072:	ffffe097          	auipc	ra,0xffffe
    80003076:	bb8080e7          	jalr	-1096(ra) # 80000c2a <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000307a:	0001d497          	auipc	s1,0x1d
    8000307e:	bbe4b483          	ld	s1,-1090(s1) # 8001fc38 <bcache+0x82b8>
    80003082:	0001d797          	auipc	a5,0x1d
    80003086:	b6678793          	addi	a5,a5,-1178 # 8001fbe8 <bcache+0x8268>
    8000308a:	02f48f63          	beq	s1,a5,800030c8 <bread+0x70>
    8000308e:	873e                	mv	a4,a5
    80003090:	a021                	j	80003098 <bread+0x40>
    80003092:	68a4                	ld	s1,80(s1)
    80003094:	02e48a63          	beq	s1,a4,800030c8 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003098:	449c                	lw	a5,8(s1)
    8000309a:	ff379ce3          	bne	a5,s3,80003092 <bread+0x3a>
    8000309e:	44dc                	lw	a5,12(s1)
    800030a0:	ff2799e3          	bne	a5,s2,80003092 <bread+0x3a>
      b->refcnt++;
    800030a4:	40bc                	lw	a5,64(s1)
    800030a6:	2785                	addiw	a5,a5,1
    800030a8:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800030aa:	00015517          	auipc	a0,0x15
    800030ae:	8d650513          	addi	a0,a0,-1834 # 80017980 <bcache>
    800030b2:	ffffe097          	auipc	ra,0xffffe
    800030b6:	c2c080e7          	jalr	-980(ra) # 80000cde <release>
      acquiresleep(&b->lock);
    800030ba:	01048513          	addi	a0,s1,16
    800030be:	00001097          	auipc	ra,0x1
    800030c2:	456080e7          	jalr	1110(ra) # 80004514 <acquiresleep>
      return b;
    800030c6:	a8b9                	j	80003124 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800030c8:	0001d497          	auipc	s1,0x1d
    800030cc:	b684b483          	ld	s1,-1176(s1) # 8001fc30 <bcache+0x82b0>
    800030d0:	0001d797          	auipc	a5,0x1d
    800030d4:	b1878793          	addi	a5,a5,-1256 # 8001fbe8 <bcache+0x8268>
    800030d8:	00f48863          	beq	s1,a5,800030e8 <bread+0x90>
    800030dc:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800030de:	40bc                	lw	a5,64(s1)
    800030e0:	cf81                	beqz	a5,800030f8 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800030e2:	64a4                	ld	s1,72(s1)
    800030e4:	fee49de3          	bne	s1,a4,800030de <bread+0x86>
  panic("bget: no buffers");
    800030e8:	00005517          	auipc	a0,0x5
    800030ec:	48850513          	addi	a0,a0,1160 # 80008570 <syscalls+0xc0>
    800030f0:	ffffd097          	auipc	ra,0xffffd
    800030f4:	458080e7          	jalr	1112(ra) # 80000548 <panic>
      b->dev = dev;
    800030f8:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    800030fc:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80003100:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003104:	4785                	li	a5,1
    80003106:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003108:	00015517          	auipc	a0,0x15
    8000310c:	87850513          	addi	a0,a0,-1928 # 80017980 <bcache>
    80003110:	ffffe097          	auipc	ra,0xffffe
    80003114:	bce080e7          	jalr	-1074(ra) # 80000cde <release>
      acquiresleep(&b->lock);
    80003118:	01048513          	addi	a0,s1,16
    8000311c:	00001097          	auipc	ra,0x1
    80003120:	3f8080e7          	jalr	1016(ra) # 80004514 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003124:	409c                	lw	a5,0(s1)
    80003126:	cb89                	beqz	a5,80003138 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003128:	8526                	mv	a0,s1
    8000312a:	70a2                	ld	ra,40(sp)
    8000312c:	7402                	ld	s0,32(sp)
    8000312e:	64e2                	ld	s1,24(sp)
    80003130:	6942                	ld	s2,16(sp)
    80003132:	69a2                	ld	s3,8(sp)
    80003134:	6145                	addi	sp,sp,48
    80003136:	8082                	ret
    virtio_disk_rw(b, 0);
    80003138:	4581                	li	a1,0
    8000313a:	8526                	mv	a0,s1
    8000313c:	00003097          	auipc	ra,0x3
    80003140:	fa0080e7          	jalr	-96(ra) # 800060dc <virtio_disk_rw>
    b->valid = 1;
    80003144:	4785                	li	a5,1
    80003146:	c09c                	sw	a5,0(s1)
  return b;
    80003148:	b7c5                	j	80003128 <bread+0xd0>

000000008000314a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000314a:	1101                	addi	sp,sp,-32
    8000314c:	ec06                	sd	ra,24(sp)
    8000314e:	e822                	sd	s0,16(sp)
    80003150:	e426                	sd	s1,8(sp)
    80003152:	1000                	addi	s0,sp,32
    80003154:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003156:	0541                	addi	a0,a0,16
    80003158:	00001097          	auipc	ra,0x1
    8000315c:	456080e7          	jalr	1110(ra) # 800045ae <holdingsleep>
    80003160:	cd01                	beqz	a0,80003178 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003162:	4585                	li	a1,1
    80003164:	8526                	mv	a0,s1
    80003166:	00003097          	auipc	ra,0x3
    8000316a:	f76080e7          	jalr	-138(ra) # 800060dc <virtio_disk_rw>
}
    8000316e:	60e2                	ld	ra,24(sp)
    80003170:	6442                	ld	s0,16(sp)
    80003172:	64a2                	ld	s1,8(sp)
    80003174:	6105                	addi	sp,sp,32
    80003176:	8082                	ret
    panic("bwrite");
    80003178:	00005517          	auipc	a0,0x5
    8000317c:	41050513          	addi	a0,a0,1040 # 80008588 <syscalls+0xd8>
    80003180:	ffffd097          	auipc	ra,0xffffd
    80003184:	3c8080e7          	jalr	968(ra) # 80000548 <panic>

0000000080003188 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003188:	1101                	addi	sp,sp,-32
    8000318a:	ec06                	sd	ra,24(sp)
    8000318c:	e822                	sd	s0,16(sp)
    8000318e:	e426                	sd	s1,8(sp)
    80003190:	e04a                	sd	s2,0(sp)
    80003192:	1000                	addi	s0,sp,32
    80003194:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003196:	01050913          	addi	s2,a0,16
    8000319a:	854a                	mv	a0,s2
    8000319c:	00001097          	auipc	ra,0x1
    800031a0:	412080e7          	jalr	1042(ra) # 800045ae <holdingsleep>
    800031a4:	c92d                	beqz	a0,80003216 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800031a6:	854a                	mv	a0,s2
    800031a8:	00001097          	auipc	ra,0x1
    800031ac:	3c2080e7          	jalr	962(ra) # 8000456a <releasesleep>

  acquire(&bcache.lock);
    800031b0:	00014517          	auipc	a0,0x14
    800031b4:	7d050513          	addi	a0,a0,2000 # 80017980 <bcache>
    800031b8:	ffffe097          	auipc	ra,0xffffe
    800031bc:	a72080e7          	jalr	-1422(ra) # 80000c2a <acquire>
  b->refcnt--;
    800031c0:	40bc                	lw	a5,64(s1)
    800031c2:	37fd                	addiw	a5,a5,-1
    800031c4:	0007871b          	sext.w	a4,a5
    800031c8:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800031ca:	eb05                	bnez	a4,800031fa <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800031cc:	68bc                	ld	a5,80(s1)
    800031ce:	64b8                	ld	a4,72(s1)
    800031d0:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800031d2:	64bc                	ld	a5,72(s1)
    800031d4:	68b8                	ld	a4,80(s1)
    800031d6:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800031d8:	0001c797          	auipc	a5,0x1c
    800031dc:	7a878793          	addi	a5,a5,1960 # 8001f980 <bcache+0x8000>
    800031e0:	2b87b703          	ld	a4,696(a5)
    800031e4:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800031e6:	0001d717          	auipc	a4,0x1d
    800031ea:	a0270713          	addi	a4,a4,-1534 # 8001fbe8 <bcache+0x8268>
    800031ee:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800031f0:	2b87b703          	ld	a4,696(a5)
    800031f4:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800031f6:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800031fa:	00014517          	auipc	a0,0x14
    800031fe:	78650513          	addi	a0,a0,1926 # 80017980 <bcache>
    80003202:	ffffe097          	auipc	ra,0xffffe
    80003206:	adc080e7          	jalr	-1316(ra) # 80000cde <release>
}
    8000320a:	60e2                	ld	ra,24(sp)
    8000320c:	6442                	ld	s0,16(sp)
    8000320e:	64a2                	ld	s1,8(sp)
    80003210:	6902                	ld	s2,0(sp)
    80003212:	6105                	addi	sp,sp,32
    80003214:	8082                	ret
    panic("brelse");
    80003216:	00005517          	auipc	a0,0x5
    8000321a:	37a50513          	addi	a0,a0,890 # 80008590 <syscalls+0xe0>
    8000321e:	ffffd097          	auipc	ra,0xffffd
    80003222:	32a080e7          	jalr	810(ra) # 80000548 <panic>

0000000080003226 <bpin>:

void
bpin(struct buf *b) {
    80003226:	1101                	addi	sp,sp,-32
    80003228:	ec06                	sd	ra,24(sp)
    8000322a:	e822                	sd	s0,16(sp)
    8000322c:	e426                	sd	s1,8(sp)
    8000322e:	1000                	addi	s0,sp,32
    80003230:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003232:	00014517          	auipc	a0,0x14
    80003236:	74e50513          	addi	a0,a0,1870 # 80017980 <bcache>
    8000323a:	ffffe097          	auipc	ra,0xffffe
    8000323e:	9f0080e7          	jalr	-1552(ra) # 80000c2a <acquire>
  b->refcnt++;
    80003242:	40bc                	lw	a5,64(s1)
    80003244:	2785                	addiw	a5,a5,1
    80003246:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003248:	00014517          	auipc	a0,0x14
    8000324c:	73850513          	addi	a0,a0,1848 # 80017980 <bcache>
    80003250:	ffffe097          	auipc	ra,0xffffe
    80003254:	a8e080e7          	jalr	-1394(ra) # 80000cde <release>
}
    80003258:	60e2                	ld	ra,24(sp)
    8000325a:	6442                	ld	s0,16(sp)
    8000325c:	64a2                	ld	s1,8(sp)
    8000325e:	6105                	addi	sp,sp,32
    80003260:	8082                	ret

0000000080003262 <bunpin>:

void
bunpin(struct buf *b) {
    80003262:	1101                	addi	sp,sp,-32
    80003264:	ec06                	sd	ra,24(sp)
    80003266:	e822                	sd	s0,16(sp)
    80003268:	e426                	sd	s1,8(sp)
    8000326a:	1000                	addi	s0,sp,32
    8000326c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000326e:	00014517          	auipc	a0,0x14
    80003272:	71250513          	addi	a0,a0,1810 # 80017980 <bcache>
    80003276:	ffffe097          	auipc	ra,0xffffe
    8000327a:	9b4080e7          	jalr	-1612(ra) # 80000c2a <acquire>
  b->refcnt--;
    8000327e:	40bc                	lw	a5,64(s1)
    80003280:	37fd                	addiw	a5,a5,-1
    80003282:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003284:	00014517          	auipc	a0,0x14
    80003288:	6fc50513          	addi	a0,a0,1788 # 80017980 <bcache>
    8000328c:	ffffe097          	auipc	ra,0xffffe
    80003290:	a52080e7          	jalr	-1454(ra) # 80000cde <release>
}
    80003294:	60e2                	ld	ra,24(sp)
    80003296:	6442                	ld	s0,16(sp)
    80003298:	64a2                	ld	s1,8(sp)
    8000329a:	6105                	addi	sp,sp,32
    8000329c:	8082                	ret

000000008000329e <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000329e:	1101                	addi	sp,sp,-32
    800032a0:	ec06                	sd	ra,24(sp)
    800032a2:	e822                	sd	s0,16(sp)
    800032a4:	e426                	sd	s1,8(sp)
    800032a6:	e04a                	sd	s2,0(sp)
    800032a8:	1000                	addi	s0,sp,32
    800032aa:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800032ac:	00d5d59b          	srliw	a1,a1,0xd
    800032b0:	0001d797          	auipc	a5,0x1d
    800032b4:	dac7a783          	lw	a5,-596(a5) # 8002005c <sb+0x1c>
    800032b8:	9dbd                	addw	a1,a1,a5
    800032ba:	00000097          	auipc	ra,0x0
    800032be:	d9e080e7          	jalr	-610(ra) # 80003058 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800032c2:	0074f713          	andi	a4,s1,7
    800032c6:	4785                	li	a5,1
    800032c8:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800032cc:	14ce                	slli	s1,s1,0x33
    800032ce:	90d9                	srli	s1,s1,0x36
    800032d0:	00950733          	add	a4,a0,s1
    800032d4:	05874703          	lbu	a4,88(a4)
    800032d8:	00e7f6b3          	and	a3,a5,a4
    800032dc:	c69d                	beqz	a3,8000330a <bfree+0x6c>
    800032de:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800032e0:	94aa                	add	s1,s1,a0
    800032e2:	fff7c793          	not	a5,a5
    800032e6:	8ff9                	and	a5,a5,a4
    800032e8:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800032ec:	00001097          	auipc	ra,0x1
    800032f0:	100080e7          	jalr	256(ra) # 800043ec <log_write>
  brelse(bp);
    800032f4:	854a                	mv	a0,s2
    800032f6:	00000097          	auipc	ra,0x0
    800032fa:	e92080e7          	jalr	-366(ra) # 80003188 <brelse>
}
    800032fe:	60e2                	ld	ra,24(sp)
    80003300:	6442                	ld	s0,16(sp)
    80003302:	64a2                	ld	s1,8(sp)
    80003304:	6902                	ld	s2,0(sp)
    80003306:	6105                	addi	sp,sp,32
    80003308:	8082                	ret
    panic("freeing free block");
    8000330a:	00005517          	auipc	a0,0x5
    8000330e:	28e50513          	addi	a0,a0,654 # 80008598 <syscalls+0xe8>
    80003312:	ffffd097          	auipc	ra,0xffffd
    80003316:	236080e7          	jalr	566(ra) # 80000548 <panic>

000000008000331a <balloc>:
{
    8000331a:	711d                	addi	sp,sp,-96
    8000331c:	ec86                	sd	ra,88(sp)
    8000331e:	e8a2                	sd	s0,80(sp)
    80003320:	e4a6                	sd	s1,72(sp)
    80003322:	e0ca                	sd	s2,64(sp)
    80003324:	fc4e                	sd	s3,56(sp)
    80003326:	f852                	sd	s4,48(sp)
    80003328:	f456                	sd	s5,40(sp)
    8000332a:	f05a                	sd	s6,32(sp)
    8000332c:	ec5e                	sd	s7,24(sp)
    8000332e:	e862                	sd	s8,16(sp)
    80003330:	e466                	sd	s9,8(sp)
    80003332:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003334:	0001d797          	auipc	a5,0x1d
    80003338:	d107a783          	lw	a5,-752(a5) # 80020044 <sb+0x4>
    8000333c:	cbd1                	beqz	a5,800033d0 <balloc+0xb6>
    8000333e:	8baa                	mv	s7,a0
    80003340:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003342:	0001db17          	auipc	s6,0x1d
    80003346:	cfeb0b13          	addi	s6,s6,-770 # 80020040 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000334a:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000334c:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000334e:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003350:	6c89                	lui	s9,0x2
    80003352:	a831                	j	8000336e <balloc+0x54>
    brelse(bp);
    80003354:	854a                	mv	a0,s2
    80003356:	00000097          	auipc	ra,0x0
    8000335a:	e32080e7          	jalr	-462(ra) # 80003188 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000335e:	015c87bb          	addw	a5,s9,s5
    80003362:	00078a9b          	sext.w	s5,a5
    80003366:	004b2703          	lw	a4,4(s6)
    8000336a:	06eaf363          	bgeu	s5,a4,800033d0 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    8000336e:	41fad79b          	sraiw	a5,s5,0x1f
    80003372:	0137d79b          	srliw	a5,a5,0x13
    80003376:	015787bb          	addw	a5,a5,s5
    8000337a:	40d7d79b          	sraiw	a5,a5,0xd
    8000337e:	01cb2583          	lw	a1,28(s6)
    80003382:	9dbd                	addw	a1,a1,a5
    80003384:	855e                	mv	a0,s7
    80003386:	00000097          	auipc	ra,0x0
    8000338a:	cd2080e7          	jalr	-814(ra) # 80003058 <bread>
    8000338e:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003390:	004b2503          	lw	a0,4(s6)
    80003394:	000a849b          	sext.w	s1,s5
    80003398:	8662                	mv	a2,s8
    8000339a:	faa4fde3          	bgeu	s1,a0,80003354 <balloc+0x3a>
      m = 1 << (bi % 8);
    8000339e:	41f6579b          	sraiw	a5,a2,0x1f
    800033a2:	01d7d69b          	srliw	a3,a5,0x1d
    800033a6:	00c6873b          	addw	a4,a3,a2
    800033aa:	00777793          	andi	a5,a4,7
    800033ae:	9f95                	subw	a5,a5,a3
    800033b0:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800033b4:	4037571b          	sraiw	a4,a4,0x3
    800033b8:	00e906b3          	add	a3,s2,a4
    800033bc:	0586c683          	lbu	a3,88(a3)
    800033c0:	00d7f5b3          	and	a1,a5,a3
    800033c4:	cd91                	beqz	a1,800033e0 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033c6:	2605                	addiw	a2,a2,1
    800033c8:	2485                	addiw	s1,s1,1
    800033ca:	fd4618e3          	bne	a2,s4,8000339a <balloc+0x80>
    800033ce:	b759                	j	80003354 <balloc+0x3a>
  panic("balloc: out of blocks");
    800033d0:	00005517          	auipc	a0,0x5
    800033d4:	1e050513          	addi	a0,a0,480 # 800085b0 <syscalls+0x100>
    800033d8:	ffffd097          	auipc	ra,0xffffd
    800033dc:	170080e7          	jalr	368(ra) # 80000548 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800033e0:	974a                	add	a4,a4,s2
    800033e2:	8fd5                	or	a5,a5,a3
    800033e4:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800033e8:	854a                	mv	a0,s2
    800033ea:	00001097          	auipc	ra,0x1
    800033ee:	002080e7          	jalr	2(ra) # 800043ec <log_write>
        brelse(bp);
    800033f2:	854a                	mv	a0,s2
    800033f4:	00000097          	auipc	ra,0x0
    800033f8:	d94080e7          	jalr	-620(ra) # 80003188 <brelse>
  bp = bread(dev, bno);
    800033fc:	85a6                	mv	a1,s1
    800033fe:	855e                	mv	a0,s7
    80003400:	00000097          	auipc	ra,0x0
    80003404:	c58080e7          	jalr	-936(ra) # 80003058 <bread>
    80003408:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000340a:	40000613          	li	a2,1024
    8000340e:	4581                	li	a1,0
    80003410:	05850513          	addi	a0,a0,88
    80003414:	ffffe097          	auipc	ra,0xffffe
    80003418:	912080e7          	jalr	-1774(ra) # 80000d26 <memset>
  log_write(bp);
    8000341c:	854a                	mv	a0,s2
    8000341e:	00001097          	auipc	ra,0x1
    80003422:	fce080e7          	jalr	-50(ra) # 800043ec <log_write>
  brelse(bp);
    80003426:	854a                	mv	a0,s2
    80003428:	00000097          	auipc	ra,0x0
    8000342c:	d60080e7          	jalr	-672(ra) # 80003188 <brelse>
}
    80003430:	8526                	mv	a0,s1
    80003432:	60e6                	ld	ra,88(sp)
    80003434:	6446                	ld	s0,80(sp)
    80003436:	64a6                	ld	s1,72(sp)
    80003438:	6906                	ld	s2,64(sp)
    8000343a:	79e2                	ld	s3,56(sp)
    8000343c:	7a42                	ld	s4,48(sp)
    8000343e:	7aa2                	ld	s5,40(sp)
    80003440:	7b02                	ld	s6,32(sp)
    80003442:	6be2                	ld	s7,24(sp)
    80003444:	6c42                	ld	s8,16(sp)
    80003446:	6ca2                	ld	s9,8(sp)
    80003448:	6125                	addi	sp,sp,96
    8000344a:	8082                	ret

000000008000344c <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    8000344c:	7179                	addi	sp,sp,-48
    8000344e:	f406                	sd	ra,40(sp)
    80003450:	f022                	sd	s0,32(sp)
    80003452:	ec26                	sd	s1,24(sp)
    80003454:	e84a                	sd	s2,16(sp)
    80003456:	e44e                	sd	s3,8(sp)
    80003458:	e052                	sd	s4,0(sp)
    8000345a:	1800                	addi	s0,sp,48
    8000345c:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000345e:	47ad                	li	a5,11
    80003460:	04b7fe63          	bgeu	a5,a1,800034bc <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003464:	ff45849b          	addiw	s1,a1,-12
    80003468:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000346c:	0ff00793          	li	a5,255
    80003470:	0ae7e363          	bltu	a5,a4,80003516 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003474:	08052583          	lw	a1,128(a0)
    80003478:	c5ad                	beqz	a1,800034e2 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    8000347a:	00092503          	lw	a0,0(s2)
    8000347e:	00000097          	auipc	ra,0x0
    80003482:	bda080e7          	jalr	-1062(ra) # 80003058 <bread>
    80003486:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003488:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000348c:	02049593          	slli	a1,s1,0x20
    80003490:	9181                	srli	a1,a1,0x20
    80003492:	058a                	slli	a1,a1,0x2
    80003494:	00b784b3          	add	s1,a5,a1
    80003498:	0004a983          	lw	s3,0(s1)
    8000349c:	04098d63          	beqz	s3,800034f6 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800034a0:	8552                	mv	a0,s4
    800034a2:	00000097          	auipc	ra,0x0
    800034a6:	ce6080e7          	jalr	-794(ra) # 80003188 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800034aa:	854e                	mv	a0,s3
    800034ac:	70a2                	ld	ra,40(sp)
    800034ae:	7402                	ld	s0,32(sp)
    800034b0:	64e2                	ld	s1,24(sp)
    800034b2:	6942                	ld	s2,16(sp)
    800034b4:	69a2                	ld	s3,8(sp)
    800034b6:	6a02                	ld	s4,0(sp)
    800034b8:	6145                	addi	sp,sp,48
    800034ba:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800034bc:	02059493          	slli	s1,a1,0x20
    800034c0:	9081                	srli	s1,s1,0x20
    800034c2:	048a                	slli	s1,s1,0x2
    800034c4:	94aa                	add	s1,s1,a0
    800034c6:	0504a983          	lw	s3,80(s1)
    800034ca:	fe0990e3          	bnez	s3,800034aa <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800034ce:	4108                	lw	a0,0(a0)
    800034d0:	00000097          	auipc	ra,0x0
    800034d4:	e4a080e7          	jalr	-438(ra) # 8000331a <balloc>
    800034d8:	0005099b          	sext.w	s3,a0
    800034dc:	0534a823          	sw	s3,80(s1)
    800034e0:	b7e9                	j	800034aa <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800034e2:	4108                	lw	a0,0(a0)
    800034e4:	00000097          	auipc	ra,0x0
    800034e8:	e36080e7          	jalr	-458(ra) # 8000331a <balloc>
    800034ec:	0005059b          	sext.w	a1,a0
    800034f0:	08b92023          	sw	a1,128(s2)
    800034f4:	b759                	j	8000347a <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    800034f6:	00092503          	lw	a0,0(s2)
    800034fa:	00000097          	auipc	ra,0x0
    800034fe:	e20080e7          	jalr	-480(ra) # 8000331a <balloc>
    80003502:	0005099b          	sext.w	s3,a0
    80003506:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    8000350a:	8552                	mv	a0,s4
    8000350c:	00001097          	auipc	ra,0x1
    80003510:	ee0080e7          	jalr	-288(ra) # 800043ec <log_write>
    80003514:	b771                	j	800034a0 <bmap+0x54>
  panic("bmap: out of range");
    80003516:	00005517          	auipc	a0,0x5
    8000351a:	0b250513          	addi	a0,a0,178 # 800085c8 <syscalls+0x118>
    8000351e:	ffffd097          	auipc	ra,0xffffd
    80003522:	02a080e7          	jalr	42(ra) # 80000548 <panic>

0000000080003526 <iget>:
{
    80003526:	7179                	addi	sp,sp,-48
    80003528:	f406                	sd	ra,40(sp)
    8000352a:	f022                	sd	s0,32(sp)
    8000352c:	ec26                	sd	s1,24(sp)
    8000352e:	e84a                	sd	s2,16(sp)
    80003530:	e44e                	sd	s3,8(sp)
    80003532:	e052                	sd	s4,0(sp)
    80003534:	1800                	addi	s0,sp,48
    80003536:	89aa                	mv	s3,a0
    80003538:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    8000353a:	0001d517          	auipc	a0,0x1d
    8000353e:	b2650513          	addi	a0,a0,-1242 # 80020060 <icache>
    80003542:	ffffd097          	auipc	ra,0xffffd
    80003546:	6e8080e7          	jalr	1768(ra) # 80000c2a <acquire>
  empty = 0;
    8000354a:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    8000354c:	0001d497          	auipc	s1,0x1d
    80003550:	b2c48493          	addi	s1,s1,-1236 # 80020078 <icache+0x18>
    80003554:	0001e697          	auipc	a3,0x1e
    80003558:	5b468693          	addi	a3,a3,1460 # 80021b08 <log>
    8000355c:	a039                	j	8000356a <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000355e:	02090b63          	beqz	s2,80003594 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003562:	08848493          	addi	s1,s1,136
    80003566:	02d48a63          	beq	s1,a3,8000359a <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000356a:	449c                	lw	a5,8(s1)
    8000356c:	fef059e3          	blez	a5,8000355e <iget+0x38>
    80003570:	4098                	lw	a4,0(s1)
    80003572:	ff3716e3          	bne	a4,s3,8000355e <iget+0x38>
    80003576:	40d8                	lw	a4,4(s1)
    80003578:	ff4713e3          	bne	a4,s4,8000355e <iget+0x38>
      ip->ref++;
    8000357c:	2785                	addiw	a5,a5,1
    8000357e:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    80003580:	0001d517          	auipc	a0,0x1d
    80003584:	ae050513          	addi	a0,a0,-1312 # 80020060 <icache>
    80003588:	ffffd097          	auipc	ra,0xffffd
    8000358c:	756080e7          	jalr	1878(ra) # 80000cde <release>
      return ip;
    80003590:	8926                	mv	s2,s1
    80003592:	a03d                	j	800035c0 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003594:	f7f9                	bnez	a5,80003562 <iget+0x3c>
    80003596:	8926                	mv	s2,s1
    80003598:	b7e9                	j	80003562 <iget+0x3c>
  if(empty == 0)
    8000359a:	02090c63          	beqz	s2,800035d2 <iget+0xac>
  ip->dev = dev;
    8000359e:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800035a2:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800035a6:	4785                	li	a5,1
    800035a8:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800035ac:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    800035b0:	0001d517          	auipc	a0,0x1d
    800035b4:	ab050513          	addi	a0,a0,-1360 # 80020060 <icache>
    800035b8:	ffffd097          	auipc	ra,0xffffd
    800035bc:	726080e7          	jalr	1830(ra) # 80000cde <release>
}
    800035c0:	854a                	mv	a0,s2
    800035c2:	70a2                	ld	ra,40(sp)
    800035c4:	7402                	ld	s0,32(sp)
    800035c6:	64e2                	ld	s1,24(sp)
    800035c8:	6942                	ld	s2,16(sp)
    800035ca:	69a2                	ld	s3,8(sp)
    800035cc:	6a02                	ld	s4,0(sp)
    800035ce:	6145                	addi	sp,sp,48
    800035d0:	8082                	ret
    panic("iget: no inodes");
    800035d2:	00005517          	auipc	a0,0x5
    800035d6:	00e50513          	addi	a0,a0,14 # 800085e0 <syscalls+0x130>
    800035da:	ffffd097          	auipc	ra,0xffffd
    800035de:	f6e080e7          	jalr	-146(ra) # 80000548 <panic>

00000000800035e2 <fsinit>:
fsinit(int dev) {
    800035e2:	7179                	addi	sp,sp,-48
    800035e4:	f406                	sd	ra,40(sp)
    800035e6:	f022                	sd	s0,32(sp)
    800035e8:	ec26                	sd	s1,24(sp)
    800035ea:	e84a                	sd	s2,16(sp)
    800035ec:	e44e                	sd	s3,8(sp)
    800035ee:	1800                	addi	s0,sp,48
    800035f0:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800035f2:	4585                	li	a1,1
    800035f4:	00000097          	auipc	ra,0x0
    800035f8:	a64080e7          	jalr	-1436(ra) # 80003058 <bread>
    800035fc:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800035fe:	0001d997          	auipc	s3,0x1d
    80003602:	a4298993          	addi	s3,s3,-1470 # 80020040 <sb>
    80003606:	02000613          	li	a2,32
    8000360a:	05850593          	addi	a1,a0,88
    8000360e:	854e                	mv	a0,s3
    80003610:	ffffd097          	auipc	ra,0xffffd
    80003614:	776080e7          	jalr	1910(ra) # 80000d86 <memmove>
  brelse(bp);
    80003618:	8526                	mv	a0,s1
    8000361a:	00000097          	auipc	ra,0x0
    8000361e:	b6e080e7          	jalr	-1170(ra) # 80003188 <brelse>
  if(sb.magic != FSMAGIC)
    80003622:	0009a703          	lw	a4,0(s3)
    80003626:	102037b7          	lui	a5,0x10203
    8000362a:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000362e:	02f71263          	bne	a4,a5,80003652 <fsinit+0x70>
  initlog(dev, &sb);
    80003632:	0001d597          	auipc	a1,0x1d
    80003636:	a0e58593          	addi	a1,a1,-1522 # 80020040 <sb>
    8000363a:	854a                	mv	a0,s2
    8000363c:	00001097          	auipc	ra,0x1
    80003640:	b38080e7          	jalr	-1224(ra) # 80004174 <initlog>
}
    80003644:	70a2                	ld	ra,40(sp)
    80003646:	7402                	ld	s0,32(sp)
    80003648:	64e2                	ld	s1,24(sp)
    8000364a:	6942                	ld	s2,16(sp)
    8000364c:	69a2                	ld	s3,8(sp)
    8000364e:	6145                	addi	sp,sp,48
    80003650:	8082                	ret
    panic("invalid file system");
    80003652:	00005517          	auipc	a0,0x5
    80003656:	f9e50513          	addi	a0,a0,-98 # 800085f0 <syscalls+0x140>
    8000365a:	ffffd097          	auipc	ra,0xffffd
    8000365e:	eee080e7          	jalr	-274(ra) # 80000548 <panic>

0000000080003662 <iinit>:
{
    80003662:	7179                	addi	sp,sp,-48
    80003664:	f406                	sd	ra,40(sp)
    80003666:	f022                	sd	s0,32(sp)
    80003668:	ec26                	sd	s1,24(sp)
    8000366a:	e84a                	sd	s2,16(sp)
    8000366c:	e44e                	sd	s3,8(sp)
    8000366e:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    80003670:	00005597          	auipc	a1,0x5
    80003674:	f9858593          	addi	a1,a1,-104 # 80008608 <syscalls+0x158>
    80003678:	0001d517          	auipc	a0,0x1d
    8000367c:	9e850513          	addi	a0,a0,-1560 # 80020060 <icache>
    80003680:	ffffd097          	auipc	ra,0xffffd
    80003684:	51a080e7          	jalr	1306(ra) # 80000b9a <initlock>
  for(i = 0; i < NINODE; i++) {
    80003688:	0001d497          	auipc	s1,0x1d
    8000368c:	a0048493          	addi	s1,s1,-1536 # 80020088 <icache+0x28>
    80003690:	0001e997          	auipc	s3,0x1e
    80003694:	48898993          	addi	s3,s3,1160 # 80021b18 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    80003698:	00005917          	auipc	s2,0x5
    8000369c:	f7890913          	addi	s2,s2,-136 # 80008610 <syscalls+0x160>
    800036a0:	85ca                	mv	a1,s2
    800036a2:	8526                	mv	a0,s1
    800036a4:	00001097          	auipc	ra,0x1
    800036a8:	e36080e7          	jalr	-458(ra) # 800044da <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800036ac:	08848493          	addi	s1,s1,136
    800036b0:	ff3498e3          	bne	s1,s3,800036a0 <iinit+0x3e>
}
    800036b4:	70a2                	ld	ra,40(sp)
    800036b6:	7402                	ld	s0,32(sp)
    800036b8:	64e2                	ld	s1,24(sp)
    800036ba:	6942                	ld	s2,16(sp)
    800036bc:	69a2                	ld	s3,8(sp)
    800036be:	6145                	addi	sp,sp,48
    800036c0:	8082                	ret

00000000800036c2 <ialloc>:
{
    800036c2:	715d                	addi	sp,sp,-80
    800036c4:	e486                	sd	ra,72(sp)
    800036c6:	e0a2                	sd	s0,64(sp)
    800036c8:	fc26                	sd	s1,56(sp)
    800036ca:	f84a                	sd	s2,48(sp)
    800036cc:	f44e                	sd	s3,40(sp)
    800036ce:	f052                	sd	s4,32(sp)
    800036d0:	ec56                	sd	s5,24(sp)
    800036d2:	e85a                	sd	s6,16(sp)
    800036d4:	e45e                	sd	s7,8(sp)
    800036d6:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800036d8:	0001d717          	auipc	a4,0x1d
    800036dc:	97472703          	lw	a4,-1676(a4) # 8002004c <sb+0xc>
    800036e0:	4785                	li	a5,1
    800036e2:	04e7fa63          	bgeu	a5,a4,80003736 <ialloc+0x74>
    800036e6:	8aaa                	mv	s5,a0
    800036e8:	8bae                	mv	s7,a1
    800036ea:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800036ec:	0001da17          	auipc	s4,0x1d
    800036f0:	954a0a13          	addi	s4,s4,-1708 # 80020040 <sb>
    800036f4:	00048b1b          	sext.w	s6,s1
    800036f8:	0044d593          	srli	a1,s1,0x4
    800036fc:	018a2783          	lw	a5,24(s4)
    80003700:	9dbd                	addw	a1,a1,a5
    80003702:	8556                	mv	a0,s5
    80003704:	00000097          	auipc	ra,0x0
    80003708:	954080e7          	jalr	-1708(ra) # 80003058 <bread>
    8000370c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000370e:	05850993          	addi	s3,a0,88
    80003712:	00f4f793          	andi	a5,s1,15
    80003716:	079a                	slli	a5,a5,0x6
    80003718:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000371a:	00099783          	lh	a5,0(s3)
    8000371e:	c785                	beqz	a5,80003746 <ialloc+0x84>
    brelse(bp);
    80003720:	00000097          	auipc	ra,0x0
    80003724:	a68080e7          	jalr	-1432(ra) # 80003188 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003728:	0485                	addi	s1,s1,1
    8000372a:	00ca2703          	lw	a4,12(s4)
    8000372e:	0004879b          	sext.w	a5,s1
    80003732:	fce7e1e3          	bltu	a5,a4,800036f4 <ialloc+0x32>
  panic("ialloc: no inodes");
    80003736:	00005517          	auipc	a0,0x5
    8000373a:	ee250513          	addi	a0,a0,-286 # 80008618 <syscalls+0x168>
    8000373e:	ffffd097          	auipc	ra,0xffffd
    80003742:	e0a080e7          	jalr	-502(ra) # 80000548 <panic>
      memset(dip, 0, sizeof(*dip));
    80003746:	04000613          	li	a2,64
    8000374a:	4581                	li	a1,0
    8000374c:	854e                	mv	a0,s3
    8000374e:	ffffd097          	auipc	ra,0xffffd
    80003752:	5d8080e7          	jalr	1496(ra) # 80000d26 <memset>
      dip->type = type;
    80003756:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000375a:	854a                	mv	a0,s2
    8000375c:	00001097          	auipc	ra,0x1
    80003760:	c90080e7          	jalr	-880(ra) # 800043ec <log_write>
      brelse(bp);
    80003764:	854a                	mv	a0,s2
    80003766:	00000097          	auipc	ra,0x0
    8000376a:	a22080e7          	jalr	-1502(ra) # 80003188 <brelse>
      return iget(dev, inum);
    8000376e:	85da                	mv	a1,s6
    80003770:	8556                	mv	a0,s5
    80003772:	00000097          	auipc	ra,0x0
    80003776:	db4080e7          	jalr	-588(ra) # 80003526 <iget>
}
    8000377a:	60a6                	ld	ra,72(sp)
    8000377c:	6406                	ld	s0,64(sp)
    8000377e:	74e2                	ld	s1,56(sp)
    80003780:	7942                	ld	s2,48(sp)
    80003782:	79a2                	ld	s3,40(sp)
    80003784:	7a02                	ld	s4,32(sp)
    80003786:	6ae2                	ld	s5,24(sp)
    80003788:	6b42                	ld	s6,16(sp)
    8000378a:	6ba2                	ld	s7,8(sp)
    8000378c:	6161                	addi	sp,sp,80
    8000378e:	8082                	ret

0000000080003790 <iupdate>:
{
    80003790:	1101                	addi	sp,sp,-32
    80003792:	ec06                	sd	ra,24(sp)
    80003794:	e822                	sd	s0,16(sp)
    80003796:	e426                	sd	s1,8(sp)
    80003798:	e04a                	sd	s2,0(sp)
    8000379a:	1000                	addi	s0,sp,32
    8000379c:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000379e:	415c                	lw	a5,4(a0)
    800037a0:	0047d79b          	srliw	a5,a5,0x4
    800037a4:	0001d597          	auipc	a1,0x1d
    800037a8:	8b45a583          	lw	a1,-1868(a1) # 80020058 <sb+0x18>
    800037ac:	9dbd                	addw	a1,a1,a5
    800037ae:	4108                	lw	a0,0(a0)
    800037b0:	00000097          	auipc	ra,0x0
    800037b4:	8a8080e7          	jalr	-1880(ra) # 80003058 <bread>
    800037b8:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800037ba:	05850793          	addi	a5,a0,88
    800037be:	40c8                	lw	a0,4(s1)
    800037c0:	893d                	andi	a0,a0,15
    800037c2:	051a                	slli	a0,a0,0x6
    800037c4:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    800037c6:	04449703          	lh	a4,68(s1)
    800037ca:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    800037ce:	04649703          	lh	a4,70(s1)
    800037d2:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    800037d6:	04849703          	lh	a4,72(s1)
    800037da:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    800037de:	04a49703          	lh	a4,74(s1)
    800037e2:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    800037e6:	44f8                	lw	a4,76(s1)
    800037e8:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800037ea:	03400613          	li	a2,52
    800037ee:	05048593          	addi	a1,s1,80
    800037f2:	0531                	addi	a0,a0,12
    800037f4:	ffffd097          	auipc	ra,0xffffd
    800037f8:	592080e7          	jalr	1426(ra) # 80000d86 <memmove>
  log_write(bp);
    800037fc:	854a                	mv	a0,s2
    800037fe:	00001097          	auipc	ra,0x1
    80003802:	bee080e7          	jalr	-1042(ra) # 800043ec <log_write>
  brelse(bp);
    80003806:	854a                	mv	a0,s2
    80003808:	00000097          	auipc	ra,0x0
    8000380c:	980080e7          	jalr	-1664(ra) # 80003188 <brelse>
}
    80003810:	60e2                	ld	ra,24(sp)
    80003812:	6442                	ld	s0,16(sp)
    80003814:	64a2                	ld	s1,8(sp)
    80003816:	6902                	ld	s2,0(sp)
    80003818:	6105                	addi	sp,sp,32
    8000381a:	8082                	ret

000000008000381c <idup>:
{
    8000381c:	1101                	addi	sp,sp,-32
    8000381e:	ec06                	sd	ra,24(sp)
    80003820:	e822                	sd	s0,16(sp)
    80003822:	e426                	sd	s1,8(sp)
    80003824:	1000                	addi	s0,sp,32
    80003826:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003828:	0001d517          	auipc	a0,0x1d
    8000382c:	83850513          	addi	a0,a0,-1992 # 80020060 <icache>
    80003830:	ffffd097          	auipc	ra,0xffffd
    80003834:	3fa080e7          	jalr	1018(ra) # 80000c2a <acquire>
  ip->ref++;
    80003838:	449c                	lw	a5,8(s1)
    8000383a:	2785                	addiw	a5,a5,1
    8000383c:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    8000383e:	0001d517          	auipc	a0,0x1d
    80003842:	82250513          	addi	a0,a0,-2014 # 80020060 <icache>
    80003846:	ffffd097          	auipc	ra,0xffffd
    8000384a:	498080e7          	jalr	1176(ra) # 80000cde <release>
}
    8000384e:	8526                	mv	a0,s1
    80003850:	60e2                	ld	ra,24(sp)
    80003852:	6442                	ld	s0,16(sp)
    80003854:	64a2                	ld	s1,8(sp)
    80003856:	6105                	addi	sp,sp,32
    80003858:	8082                	ret

000000008000385a <ilock>:
{
    8000385a:	1101                	addi	sp,sp,-32
    8000385c:	ec06                	sd	ra,24(sp)
    8000385e:	e822                	sd	s0,16(sp)
    80003860:	e426                	sd	s1,8(sp)
    80003862:	e04a                	sd	s2,0(sp)
    80003864:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003866:	c115                	beqz	a0,8000388a <ilock+0x30>
    80003868:	84aa                	mv	s1,a0
    8000386a:	451c                	lw	a5,8(a0)
    8000386c:	00f05f63          	blez	a5,8000388a <ilock+0x30>
  acquiresleep(&ip->lock);
    80003870:	0541                	addi	a0,a0,16
    80003872:	00001097          	auipc	ra,0x1
    80003876:	ca2080e7          	jalr	-862(ra) # 80004514 <acquiresleep>
  if(ip->valid == 0){
    8000387a:	40bc                	lw	a5,64(s1)
    8000387c:	cf99                	beqz	a5,8000389a <ilock+0x40>
}
    8000387e:	60e2                	ld	ra,24(sp)
    80003880:	6442                	ld	s0,16(sp)
    80003882:	64a2                	ld	s1,8(sp)
    80003884:	6902                	ld	s2,0(sp)
    80003886:	6105                	addi	sp,sp,32
    80003888:	8082                	ret
    panic("ilock");
    8000388a:	00005517          	auipc	a0,0x5
    8000388e:	da650513          	addi	a0,a0,-602 # 80008630 <syscalls+0x180>
    80003892:	ffffd097          	auipc	ra,0xffffd
    80003896:	cb6080e7          	jalr	-842(ra) # 80000548 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000389a:	40dc                	lw	a5,4(s1)
    8000389c:	0047d79b          	srliw	a5,a5,0x4
    800038a0:	0001c597          	auipc	a1,0x1c
    800038a4:	7b85a583          	lw	a1,1976(a1) # 80020058 <sb+0x18>
    800038a8:	9dbd                	addw	a1,a1,a5
    800038aa:	4088                	lw	a0,0(s1)
    800038ac:	fffff097          	auipc	ra,0xfffff
    800038b0:	7ac080e7          	jalr	1964(ra) # 80003058 <bread>
    800038b4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800038b6:	05850593          	addi	a1,a0,88
    800038ba:	40dc                	lw	a5,4(s1)
    800038bc:	8bbd                	andi	a5,a5,15
    800038be:	079a                	slli	a5,a5,0x6
    800038c0:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800038c2:	00059783          	lh	a5,0(a1)
    800038c6:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800038ca:	00259783          	lh	a5,2(a1)
    800038ce:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800038d2:	00459783          	lh	a5,4(a1)
    800038d6:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800038da:	00659783          	lh	a5,6(a1)
    800038de:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800038e2:	459c                	lw	a5,8(a1)
    800038e4:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800038e6:	03400613          	li	a2,52
    800038ea:	05b1                	addi	a1,a1,12
    800038ec:	05048513          	addi	a0,s1,80
    800038f0:	ffffd097          	auipc	ra,0xffffd
    800038f4:	496080e7          	jalr	1174(ra) # 80000d86 <memmove>
    brelse(bp);
    800038f8:	854a                	mv	a0,s2
    800038fa:	00000097          	auipc	ra,0x0
    800038fe:	88e080e7          	jalr	-1906(ra) # 80003188 <brelse>
    ip->valid = 1;
    80003902:	4785                	li	a5,1
    80003904:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003906:	04449783          	lh	a5,68(s1)
    8000390a:	fbb5                	bnez	a5,8000387e <ilock+0x24>
      panic("ilock: no type");
    8000390c:	00005517          	auipc	a0,0x5
    80003910:	d2c50513          	addi	a0,a0,-724 # 80008638 <syscalls+0x188>
    80003914:	ffffd097          	auipc	ra,0xffffd
    80003918:	c34080e7          	jalr	-972(ra) # 80000548 <panic>

000000008000391c <iunlock>:
{
    8000391c:	1101                	addi	sp,sp,-32
    8000391e:	ec06                	sd	ra,24(sp)
    80003920:	e822                	sd	s0,16(sp)
    80003922:	e426                	sd	s1,8(sp)
    80003924:	e04a                	sd	s2,0(sp)
    80003926:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003928:	c905                	beqz	a0,80003958 <iunlock+0x3c>
    8000392a:	84aa                	mv	s1,a0
    8000392c:	01050913          	addi	s2,a0,16
    80003930:	854a                	mv	a0,s2
    80003932:	00001097          	auipc	ra,0x1
    80003936:	c7c080e7          	jalr	-900(ra) # 800045ae <holdingsleep>
    8000393a:	cd19                	beqz	a0,80003958 <iunlock+0x3c>
    8000393c:	449c                	lw	a5,8(s1)
    8000393e:	00f05d63          	blez	a5,80003958 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003942:	854a                	mv	a0,s2
    80003944:	00001097          	auipc	ra,0x1
    80003948:	c26080e7          	jalr	-986(ra) # 8000456a <releasesleep>
}
    8000394c:	60e2                	ld	ra,24(sp)
    8000394e:	6442                	ld	s0,16(sp)
    80003950:	64a2                	ld	s1,8(sp)
    80003952:	6902                	ld	s2,0(sp)
    80003954:	6105                	addi	sp,sp,32
    80003956:	8082                	ret
    panic("iunlock");
    80003958:	00005517          	auipc	a0,0x5
    8000395c:	cf050513          	addi	a0,a0,-784 # 80008648 <syscalls+0x198>
    80003960:	ffffd097          	auipc	ra,0xffffd
    80003964:	be8080e7          	jalr	-1048(ra) # 80000548 <panic>

0000000080003968 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003968:	7179                	addi	sp,sp,-48
    8000396a:	f406                	sd	ra,40(sp)
    8000396c:	f022                	sd	s0,32(sp)
    8000396e:	ec26                	sd	s1,24(sp)
    80003970:	e84a                	sd	s2,16(sp)
    80003972:	e44e                	sd	s3,8(sp)
    80003974:	e052                	sd	s4,0(sp)
    80003976:	1800                	addi	s0,sp,48
    80003978:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000397a:	05050493          	addi	s1,a0,80
    8000397e:	08050913          	addi	s2,a0,128
    80003982:	a021                	j	8000398a <itrunc+0x22>
    80003984:	0491                	addi	s1,s1,4
    80003986:	01248d63          	beq	s1,s2,800039a0 <itrunc+0x38>
    if(ip->addrs[i]){
    8000398a:	408c                	lw	a1,0(s1)
    8000398c:	dde5                	beqz	a1,80003984 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    8000398e:	0009a503          	lw	a0,0(s3)
    80003992:	00000097          	auipc	ra,0x0
    80003996:	90c080e7          	jalr	-1780(ra) # 8000329e <bfree>
      ip->addrs[i] = 0;
    8000399a:	0004a023          	sw	zero,0(s1)
    8000399e:	b7dd                	j	80003984 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800039a0:	0809a583          	lw	a1,128(s3)
    800039a4:	e185                	bnez	a1,800039c4 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800039a6:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800039aa:	854e                	mv	a0,s3
    800039ac:	00000097          	auipc	ra,0x0
    800039b0:	de4080e7          	jalr	-540(ra) # 80003790 <iupdate>
}
    800039b4:	70a2                	ld	ra,40(sp)
    800039b6:	7402                	ld	s0,32(sp)
    800039b8:	64e2                	ld	s1,24(sp)
    800039ba:	6942                	ld	s2,16(sp)
    800039bc:	69a2                	ld	s3,8(sp)
    800039be:	6a02                	ld	s4,0(sp)
    800039c0:	6145                	addi	sp,sp,48
    800039c2:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800039c4:	0009a503          	lw	a0,0(s3)
    800039c8:	fffff097          	auipc	ra,0xfffff
    800039cc:	690080e7          	jalr	1680(ra) # 80003058 <bread>
    800039d0:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800039d2:	05850493          	addi	s1,a0,88
    800039d6:	45850913          	addi	s2,a0,1112
    800039da:	a811                	j	800039ee <itrunc+0x86>
        bfree(ip->dev, a[j]);
    800039dc:	0009a503          	lw	a0,0(s3)
    800039e0:	00000097          	auipc	ra,0x0
    800039e4:	8be080e7          	jalr	-1858(ra) # 8000329e <bfree>
    for(j = 0; j < NINDIRECT; j++){
    800039e8:	0491                	addi	s1,s1,4
    800039ea:	01248563          	beq	s1,s2,800039f4 <itrunc+0x8c>
      if(a[j])
    800039ee:	408c                	lw	a1,0(s1)
    800039f0:	dde5                	beqz	a1,800039e8 <itrunc+0x80>
    800039f2:	b7ed                	j	800039dc <itrunc+0x74>
    brelse(bp);
    800039f4:	8552                	mv	a0,s4
    800039f6:	fffff097          	auipc	ra,0xfffff
    800039fa:	792080e7          	jalr	1938(ra) # 80003188 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800039fe:	0809a583          	lw	a1,128(s3)
    80003a02:	0009a503          	lw	a0,0(s3)
    80003a06:	00000097          	auipc	ra,0x0
    80003a0a:	898080e7          	jalr	-1896(ra) # 8000329e <bfree>
    ip->addrs[NDIRECT] = 0;
    80003a0e:	0809a023          	sw	zero,128(s3)
    80003a12:	bf51                	j	800039a6 <itrunc+0x3e>

0000000080003a14 <iput>:
{
    80003a14:	1101                	addi	sp,sp,-32
    80003a16:	ec06                	sd	ra,24(sp)
    80003a18:	e822                	sd	s0,16(sp)
    80003a1a:	e426                	sd	s1,8(sp)
    80003a1c:	e04a                	sd	s2,0(sp)
    80003a1e:	1000                	addi	s0,sp,32
    80003a20:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003a22:	0001c517          	auipc	a0,0x1c
    80003a26:	63e50513          	addi	a0,a0,1598 # 80020060 <icache>
    80003a2a:	ffffd097          	auipc	ra,0xffffd
    80003a2e:	200080e7          	jalr	512(ra) # 80000c2a <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a32:	4498                	lw	a4,8(s1)
    80003a34:	4785                	li	a5,1
    80003a36:	02f70363          	beq	a4,a5,80003a5c <iput+0x48>
  ip->ref--;
    80003a3a:	449c                	lw	a5,8(s1)
    80003a3c:	37fd                	addiw	a5,a5,-1
    80003a3e:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003a40:	0001c517          	auipc	a0,0x1c
    80003a44:	62050513          	addi	a0,a0,1568 # 80020060 <icache>
    80003a48:	ffffd097          	auipc	ra,0xffffd
    80003a4c:	296080e7          	jalr	662(ra) # 80000cde <release>
}
    80003a50:	60e2                	ld	ra,24(sp)
    80003a52:	6442                	ld	s0,16(sp)
    80003a54:	64a2                	ld	s1,8(sp)
    80003a56:	6902                	ld	s2,0(sp)
    80003a58:	6105                	addi	sp,sp,32
    80003a5a:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a5c:	40bc                	lw	a5,64(s1)
    80003a5e:	dff1                	beqz	a5,80003a3a <iput+0x26>
    80003a60:	04a49783          	lh	a5,74(s1)
    80003a64:	fbf9                	bnez	a5,80003a3a <iput+0x26>
    acquiresleep(&ip->lock);
    80003a66:	01048913          	addi	s2,s1,16
    80003a6a:	854a                	mv	a0,s2
    80003a6c:	00001097          	auipc	ra,0x1
    80003a70:	aa8080e7          	jalr	-1368(ra) # 80004514 <acquiresleep>
    release(&icache.lock);
    80003a74:	0001c517          	auipc	a0,0x1c
    80003a78:	5ec50513          	addi	a0,a0,1516 # 80020060 <icache>
    80003a7c:	ffffd097          	auipc	ra,0xffffd
    80003a80:	262080e7          	jalr	610(ra) # 80000cde <release>
    itrunc(ip);
    80003a84:	8526                	mv	a0,s1
    80003a86:	00000097          	auipc	ra,0x0
    80003a8a:	ee2080e7          	jalr	-286(ra) # 80003968 <itrunc>
    ip->type = 0;
    80003a8e:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003a92:	8526                	mv	a0,s1
    80003a94:	00000097          	auipc	ra,0x0
    80003a98:	cfc080e7          	jalr	-772(ra) # 80003790 <iupdate>
    ip->valid = 0;
    80003a9c:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003aa0:	854a                	mv	a0,s2
    80003aa2:	00001097          	auipc	ra,0x1
    80003aa6:	ac8080e7          	jalr	-1336(ra) # 8000456a <releasesleep>
    acquire(&icache.lock);
    80003aaa:	0001c517          	auipc	a0,0x1c
    80003aae:	5b650513          	addi	a0,a0,1462 # 80020060 <icache>
    80003ab2:	ffffd097          	auipc	ra,0xffffd
    80003ab6:	178080e7          	jalr	376(ra) # 80000c2a <acquire>
    80003aba:	b741                	j	80003a3a <iput+0x26>

0000000080003abc <iunlockput>:
{
    80003abc:	1101                	addi	sp,sp,-32
    80003abe:	ec06                	sd	ra,24(sp)
    80003ac0:	e822                	sd	s0,16(sp)
    80003ac2:	e426                	sd	s1,8(sp)
    80003ac4:	1000                	addi	s0,sp,32
    80003ac6:	84aa                	mv	s1,a0
  iunlock(ip);
    80003ac8:	00000097          	auipc	ra,0x0
    80003acc:	e54080e7          	jalr	-428(ra) # 8000391c <iunlock>
  iput(ip);
    80003ad0:	8526                	mv	a0,s1
    80003ad2:	00000097          	auipc	ra,0x0
    80003ad6:	f42080e7          	jalr	-190(ra) # 80003a14 <iput>
}
    80003ada:	60e2                	ld	ra,24(sp)
    80003adc:	6442                	ld	s0,16(sp)
    80003ade:	64a2                	ld	s1,8(sp)
    80003ae0:	6105                	addi	sp,sp,32
    80003ae2:	8082                	ret

0000000080003ae4 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003ae4:	1141                	addi	sp,sp,-16
    80003ae6:	e422                	sd	s0,8(sp)
    80003ae8:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003aea:	411c                	lw	a5,0(a0)
    80003aec:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003aee:	415c                	lw	a5,4(a0)
    80003af0:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003af2:	04451783          	lh	a5,68(a0)
    80003af6:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003afa:	04a51783          	lh	a5,74(a0)
    80003afe:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003b02:	04c56783          	lwu	a5,76(a0)
    80003b06:	e99c                	sd	a5,16(a1)
}
    80003b08:	6422                	ld	s0,8(sp)
    80003b0a:	0141                	addi	sp,sp,16
    80003b0c:	8082                	ret

0000000080003b0e <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b0e:	457c                	lw	a5,76(a0)
    80003b10:	0ed7e863          	bltu	a5,a3,80003c00 <readi+0xf2>
{
    80003b14:	7159                	addi	sp,sp,-112
    80003b16:	f486                	sd	ra,104(sp)
    80003b18:	f0a2                	sd	s0,96(sp)
    80003b1a:	eca6                	sd	s1,88(sp)
    80003b1c:	e8ca                	sd	s2,80(sp)
    80003b1e:	e4ce                	sd	s3,72(sp)
    80003b20:	e0d2                	sd	s4,64(sp)
    80003b22:	fc56                	sd	s5,56(sp)
    80003b24:	f85a                	sd	s6,48(sp)
    80003b26:	f45e                	sd	s7,40(sp)
    80003b28:	f062                	sd	s8,32(sp)
    80003b2a:	ec66                	sd	s9,24(sp)
    80003b2c:	e86a                	sd	s10,16(sp)
    80003b2e:	e46e                	sd	s11,8(sp)
    80003b30:	1880                	addi	s0,sp,112
    80003b32:	8baa                	mv	s7,a0
    80003b34:	8c2e                	mv	s8,a1
    80003b36:	8ab2                	mv	s5,a2
    80003b38:	84b6                	mv	s1,a3
    80003b3a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003b3c:	9f35                	addw	a4,a4,a3
    return 0;
    80003b3e:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003b40:	08d76f63          	bltu	a4,a3,80003bde <readi+0xd0>
  if(off + n > ip->size)
    80003b44:	00e7f463          	bgeu	a5,a4,80003b4c <readi+0x3e>
    n = ip->size - off;
    80003b48:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b4c:	0a0b0863          	beqz	s6,80003bfc <readi+0xee>
    80003b50:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b52:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003b56:	5cfd                	li	s9,-1
    80003b58:	a82d                	j	80003b92 <readi+0x84>
    80003b5a:	020a1d93          	slli	s11,s4,0x20
    80003b5e:	020ddd93          	srli	s11,s11,0x20
    80003b62:	05890613          	addi	a2,s2,88
    80003b66:	86ee                	mv	a3,s11
    80003b68:	963a                	add	a2,a2,a4
    80003b6a:	85d6                	mv	a1,s5
    80003b6c:	8562                	mv	a0,s8
    80003b6e:	fffff097          	auipc	ra,0xfffff
    80003b72:	b2e080e7          	jalr	-1234(ra) # 8000269c <either_copyout>
    80003b76:	05950d63          	beq	a0,s9,80003bd0 <readi+0xc2>
      brelse(bp);
      break;
    }
    brelse(bp);
    80003b7a:	854a                	mv	a0,s2
    80003b7c:	fffff097          	auipc	ra,0xfffff
    80003b80:	60c080e7          	jalr	1548(ra) # 80003188 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b84:	013a09bb          	addw	s3,s4,s3
    80003b88:	009a04bb          	addw	s1,s4,s1
    80003b8c:	9aee                	add	s5,s5,s11
    80003b8e:	0569f663          	bgeu	s3,s6,80003bda <readi+0xcc>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003b92:	000ba903          	lw	s2,0(s7)
    80003b96:	00a4d59b          	srliw	a1,s1,0xa
    80003b9a:	855e                	mv	a0,s7
    80003b9c:	00000097          	auipc	ra,0x0
    80003ba0:	8b0080e7          	jalr	-1872(ra) # 8000344c <bmap>
    80003ba4:	0005059b          	sext.w	a1,a0
    80003ba8:	854a                	mv	a0,s2
    80003baa:	fffff097          	auipc	ra,0xfffff
    80003bae:	4ae080e7          	jalr	1198(ra) # 80003058 <bread>
    80003bb2:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bb4:	3ff4f713          	andi	a4,s1,1023
    80003bb8:	40ed07bb          	subw	a5,s10,a4
    80003bbc:	413b06bb          	subw	a3,s6,s3
    80003bc0:	8a3e                	mv	s4,a5
    80003bc2:	2781                	sext.w	a5,a5
    80003bc4:	0006861b          	sext.w	a2,a3
    80003bc8:	f8f679e3          	bgeu	a2,a5,80003b5a <readi+0x4c>
    80003bcc:	8a36                	mv	s4,a3
    80003bce:	b771                	j	80003b5a <readi+0x4c>
      brelse(bp);
    80003bd0:	854a                	mv	a0,s2
    80003bd2:	fffff097          	auipc	ra,0xfffff
    80003bd6:	5b6080e7          	jalr	1462(ra) # 80003188 <brelse>
  }
  return tot;
    80003bda:	0009851b          	sext.w	a0,s3
}
    80003bde:	70a6                	ld	ra,104(sp)
    80003be0:	7406                	ld	s0,96(sp)
    80003be2:	64e6                	ld	s1,88(sp)
    80003be4:	6946                	ld	s2,80(sp)
    80003be6:	69a6                	ld	s3,72(sp)
    80003be8:	6a06                	ld	s4,64(sp)
    80003bea:	7ae2                	ld	s5,56(sp)
    80003bec:	7b42                	ld	s6,48(sp)
    80003bee:	7ba2                	ld	s7,40(sp)
    80003bf0:	7c02                	ld	s8,32(sp)
    80003bf2:	6ce2                	ld	s9,24(sp)
    80003bf4:	6d42                	ld	s10,16(sp)
    80003bf6:	6da2                	ld	s11,8(sp)
    80003bf8:	6165                	addi	sp,sp,112
    80003bfa:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003bfc:	89da                	mv	s3,s6
    80003bfe:	bff1                	j	80003bda <readi+0xcc>
    return 0;
    80003c00:	4501                	li	a0,0
}
    80003c02:	8082                	ret

0000000080003c04 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c04:	457c                	lw	a5,76(a0)
    80003c06:	10d7e663          	bltu	a5,a3,80003d12 <writei+0x10e>
{
    80003c0a:	7159                	addi	sp,sp,-112
    80003c0c:	f486                	sd	ra,104(sp)
    80003c0e:	f0a2                	sd	s0,96(sp)
    80003c10:	eca6                	sd	s1,88(sp)
    80003c12:	e8ca                	sd	s2,80(sp)
    80003c14:	e4ce                	sd	s3,72(sp)
    80003c16:	e0d2                	sd	s4,64(sp)
    80003c18:	fc56                	sd	s5,56(sp)
    80003c1a:	f85a                	sd	s6,48(sp)
    80003c1c:	f45e                	sd	s7,40(sp)
    80003c1e:	f062                	sd	s8,32(sp)
    80003c20:	ec66                	sd	s9,24(sp)
    80003c22:	e86a                	sd	s10,16(sp)
    80003c24:	e46e                	sd	s11,8(sp)
    80003c26:	1880                	addi	s0,sp,112
    80003c28:	8baa                	mv	s7,a0
    80003c2a:	8c2e                	mv	s8,a1
    80003c2c:	8ab2                	mv	s5,a2
    80003c2e:	8936                	mv	s2,a3
    80003c30:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003c32:	00e687bb          	addw	a5,a3,a4
    80003c36:	0ed7e063          	bltu	a5,a3,80003d16 <writei+0x112>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003c3a:	00043737          	lui	a4,0x43
    80003c3e:	0cf76e63          	bltu	a4,a5,80003d1a <writei+0x116>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c42:	0a0b0763          	beqz	s6,80003cf0 <writei+0xec>
    80003c46:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c48:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003c4c:	5cfd                	li	s9,-1
    80003c4e:	a091                	j	80003c92 <writei+0x8e>
    80003c50:	02099d93          	slli	s11,s3,0x20
    80003c54:	020ddd93          	srli	s11,s11,0x20
    80003c58:	05848513          	addi	a0,s1,88
    80003c5c:	86ee                	mv	a3,s11
    80003c5e:	8656                	mv	a2,s5
    80003c60:	85e2                	mv	a1,s8
    80003c62:	953a                	add	a0,a0,a4
    80003c64:	fffff097          	auipc	ra,0xfffff
    80003c68:	a8e080e7          	jalr	-1394(ra) # 800026f2 <either_copyin>
    80003c6c:	07950263          	beq	a0,s9,80003cd0 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003c70:	8526                	mv	a0,s1
    80003c72:	00000097          	auipc	ra,0x0
    80003c76:	77a080e7          	jalr	1914(ra) # 800043ec <log_write>
    brelse(bp);
    80003c7a:	8526                	mv	a0,s1
    80003c7c:	fffff097          	auipc	ra,0xfffff
    80003c80:	50c080e7          	jalr	1292(ra) # 80003188 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c84:	01498a3b          	addw	s4,s3,s4
    80003c88:	0129893b          	addw	s2,s3,s2
    80003c8c:	9aee                	add	s5,s5,s11
    80003c8e:	056a7663          	bgeu	s4,s6,80003cda <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003c92:	000ba483          	lw	s1,0(s7)
    80003c96:	00a9559b          	srliw	a1,s2,0xa
    80003c9a:	855e                	mv	a0,s7
    80003c9c:	fffff097          	auipc	ra,0xfffff
    80003ca0:	7b0080e7          	jalr	1968(ra) # 8000344c <bmap>
    80003ca4:	0005059b          	sext.w	a1,a0
    80003ca8:	8526                	mv	a0,s1
    80003caa:	fffff097          	auipc	ra,0xfffff
    80003cae:	3ae080e7          	jalr	942(ra) # 80003058 <bread>
    80003cb2:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cb4:	3ff97713          	andi	a4,s2,1023
    80003cb8:	40ed07bb          	subw	a5,s10,a4
    80003cbc:	414b06bb          	subw	a3,s6,s4
    80003cc0:	89be                	mv	s3,a5
    80003cc2:	2781                	sext.w	a5,a5
    80003cc4:	0006861b          	sext.w	a2,a3
    80003cc8:	f8f674e3          	bgeu	a2,a5,80003c50 <writei+0x4c>
    80003ccc:	89b6                	mv	s3,a3
    80003cce:	b749                	j	80003c50 <writei+0x4c>
      brelse(bp);
    80003cd0:	8526                	mv	a0,s1
    80003cd2:	fffff097          	auipc	ra,0xfffff
    80003cd6:	4b6080e7          	jalr	1206(ra) # 80003188 <brelse>
  }

  if(n > 0){
    if(off > ip->size)
    80003cda:	04cba783          	lw	a5,76(s7)
    80003cde:	0127f463          	bgeu	a5,s2,80003ce6 <writei+0xe2>
      ip->size = off;
    80003ce2:	052ba623          	sw	s2,76(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003ce6:	855e                	mv	a0,s7
    80003ce8:	00000097          	auipc	ra,0x0
    80003cec:	aa8080e7          	jalr	-1368(ra) # 80003790 <iupdate>
  }

  return n;
    80003cf0:	000b051b          	sext.w	a0,s6
}
    80003cf4:	70a6                	ld	ra,104(sp)
    80003cf6:	7406                	ld	s0,96(sp)
    80003cf8:	64e6                	ld	s1,88(sp)
    80003cfa:	6946                	ld	s2,80(sp)
    80003cfc:	69a6                	ld	s3,72(sp)
    80003cfe:	6a06                	ld	s4,64(sp)
    80003d00:	7ae2                	ld	s5,56(sp)
    80003d02:	7b42                	ld	s6,48(sp)
    80003d04:	7ba2                	ld	s7,40(sp)
    80003d06:	7c02                	ld	s8,32(sp)
    80003d08:	6ce2                	ld	s9,24(sp)
    80003d0a:	6d42                	ld	s10,16(sp)
    80003d0c:	6da2                	ld	s11,8(sp)
    80003d0e:	6165                	addi	sp,sp,112
    80003d10:	8082                	ret
    return -1;
    80003d12:	557d                	li	a0,-1
}
    80003d14:	8082                	ret
    return -1;
    80003d16:	557d                	li	a0,-1
    80003d18:	bff1                	j	80003cf4 <writei+0xf0>
    return -1;
    80003d1a:	557d                	li	a0,-1
    80003d1c:	bfe1                	j	80003cf4 <writei+0xf0>

0000000080003d1e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003d1e:	1141                	addi	sp,sp,-16
    80003d20:	e406                	sd	ra,8(sp)
    80003d22:	e022                	sd	s0,0(sp)
    80003d24:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003d26:	4639                	li	a2,14
    80003d28:	ffffd097          	auipc	ra,0xffffd
    80003d2c:	0da080e7          	jalr	218(ra) # 80000e02 <strncmp>
}
    80003d30:	60a2                	ld	ra,8(sp)
    80003d32:	6402                	ld	s0,0(sp)
    80003d34:	0141                	addi	sp,sp,16
    80003d36:	8082                	ret

0000000080003d38 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003d38:	7139                	addi	sp,sp,-64
    80003d3a:	fc06                	sd	ra,56(sp)
    80003d3c:	f822                	sd	s0,48(sp)
    80003d3e:	f426                	sd	s1,40(sp)
    80003d40:	f04a                	sd	s2,32(sp)
    80003d42:	ec4e                	sd	s3,24(sp)
    80003d44:	e852                	sd	s4,16(sp)
    80003d46:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003d48:	04451703          	lh	a4,68(a0)
    80003d4c:	4785                	li	a5,1
    80003d4e:	00f71a63          	bne	a4,a5,80003d62 <dirlookup+0x2a>
    80003d52:	892a                	mv	s2,a0
    80003d54:	89ae                	mv	s3,a1
    80003d56:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d58:	457c                	lw	a5,76(a0)
    80003d5a:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003d5c:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d5e:	e79d                	bnez	a5,80003d8c <dirlookup+0x54>
    80003d60:	a8a5                	j	80003dd8 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003d62:	00005517          	auipc	a0,0x5
    80003d66:	8ee50513          	addi	a0,a0,-1810 # 80008650 <syscalls+0x1a0>
    80003d6a:	ffffc097          	auipc	ra,0xffffc
    80003d6e:	7de080e7          	jalr	2014(ra) # 80000548 <panic>
      panic("dirlookup read");
    80003d72:	00005517          	auipc	a0,0x5
    80003d76:	8f650513          	addi	a0,a0,-1802 # 80008668 <syscalls+0x1b8>
    80003d7a:	ffffc097          	auipc	ra,0xffffc
    80003d7e:	7ce080e7          	jalr	1998(ra) # 80000548 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d82:	24c1                	addiw	s1,s1,16
    80003d84:	04c92783          	lw	a5,76(s2)
    80003d88:	04f4f763          	bgeu	s1,a5,80003dd6 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d8c:	4741                	li	a4,16
    80003d8e:	86a6                	mv	a3,s1
    80003d90:	fc040613          	addi	a2,s0,-64
    80003d94:	4581                	li	a1,0
    80003d96:	854a                	mv	a0,s2
    80003d98:	00000097          	auipc	ra,0x0
    80003d9c:	d76080e7          	jalr	-650(ra) # 80003b0e <readi>
    80003da0:	47c1                	li	a5,16
    80003da2:	fcf518e3          	bne	a0,a5,80003d72 <dirlookup+0x3a>
    if(de.inum == 0)
    80003da6:	fc045783          	lhu	a5,-64(s0)
    80003daa:	dfe1                	beqz	a5,80003d82 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003dac:	fc240593          	addi	a1,s0,-62
    80003db0:	854e                	mv	a0,s3
    80003db2:	00000097          	auipc	ra,0x0
    80003db6:	f6c080e7          	jalr	-148(ra) # 80003d1e <namecmp>
    80003dba:	f561                	bnez	a0,80003d82 <dirlookup+0x4a>
      if(poff)
    80003dbc:	000a0463          	beqz	s4,80003dc4 <dirlookup+0x8c>
        *poff = off;
    80003dc0:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003dc4:	fc045583          	lhu	a1,-64(s0)
    80003dc8:	00092503          	lw	a0,0(s2)
    80003dcc:	fffff097          	auipc	ra,0xfffff
    80003dd0:	75a080e7          	jalr	1882(ra) # 80003526 <iget>
    80003dd4:	a011                	j	80003dd8 <dirlookup+0xa0>
  return 0;
    80003dd6:	4501                	li	a0,0
}
    80003dd8:	70e2                	ld	ra,56(sp)
    80003dda:	7442                	ld	s0,48(sp)
    80003ddc:	74a2                	ld	s1,40(sp)
    80003dde:	7902                	ld	s2,32(sp)
    80003de0:	69e2                	ld	s3,24(sp)
    80003de2:	6a42                	ld	s4,16(sp)
    80003de4:	6121                	addi	sp,sp,64
    80003de6:	8082                	ret

0000000080003de8 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003de8:	711d                	addi	sp,sp,-96
    80003dea:	ec86                	sd	ra,88(sp)
    80003dec:	e8a2                	sd	s0,80(sp)
    80003dee:	e4a6                	sd	s1,72(sp)
    80003df0:	e0ca                	sd	s2,64(sp)
    80003df2:	fc4e                	sd	s3,56(sp)
    80003df4:	f852                	sd	s4,48(sp)
    80003df6:	f456                	sd	s5,40(sp)
    80003df8:	f05a                	sd	s6,32(sp)
    80003dfa:	ec5e                	sd	s7,24(sp)
    80003dfc:	e862                	sd	s8,16(sp)
    80003dfe:	e466                	sd	s9,8(sp)
    80003e00:	1080                	addi	s0,sp,96
    80003e02:	84aa                	mv	s1,a0
    80003e04:	8b2e                	mv	s6,a1
    80003e06:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003e08:	00054703          	lbu	a4,0(a0)
    80003e0c:	02f00793          	li	a5,47
    80003e10:	02f70363          	beq	a4,a5,80003e36 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003e14:	ffffe097          	auipc	ra,0xffffe
    80003e18:	cfe080e7          	jalr	-770(ra) # 80001b12 <myproc>
    80003e1c:	15053503          	ld	a0,336(a0)
    80003e20:	00000097          	auipc	ra,0x0
    80003e24:	9fc080e7          	jalr	-1540(ra) # 8000381c <idup>
    80003e28:	89aa                	mv	s3,a0
  while(*path == '/')
    80003e2a:	02f00913          	li	s2,47
  len = path - s;
    80003e2e:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80003e30:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003e32:	4c05                	li	s8,1
    80003e34:	a865                	j	80003eec <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003e36:	4585                	li	a1,1
    80003e38:	4505                	li	a0,1
    80003e3a:	fffff097          	auipc	ra,0xfffff
    80003e3e:	6ec080e7          	jalr	1772(ra) # 80003526 <iget>
    80003e42:	89aa                	mv	s3,a0
    80003e44:	b7dd                	j	80003e2a <namex+0x42>
      iunlockput(ip);
    80003e46:	854e                	mv	a0,s3
    80003e48:	00000097          	auipc	ra,0x0
    80003e4c:	c74080e7          	jalr	-908(ra) # 80003abc <iunlockput>
      return 0;
    80003e50:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003e52:	854e                	mv	a0,s3
    80003e54:	60e6                	ld	ra,88(sp)
    80003e56:	6446                	ld	s0,80(sp)
    80003e58:	64a6                	ld	s1,72(sp)
    80003e5a:	6906                	ld	s2,64(sp)
    80003e5c:	79e2                	ld	s3,56(sp)
    80003e5e:	7a42                	ld	s4,48(sp)
    80003e60:	7aa2                	ld	s5,40(sp)
    80003e62:	7b02                	ld	s6,32(sp)
    80003e64:	6be2                	ld	s7,24(sp)
    80003e66:	6c42                	ld	s8,16(sp)
    80003e68:	6ca2                	ld	s9,8(sp)
    80003e6a:	6125                	addi	sp,sp,96
    80003e6c:	8082                	ret
      iunlock(ip);
    80003e6e:	854e                	mv	a0,s3
    80003e70:	00000097          	auipc	ra,0x0
    80003e74:	aac080e7          	jalr	-1364(ra) # 8000391c <iunlock>
      return ip;
    80003e78:	bfe9                	j	80003e52 <namex+0x6a>
      iunlockput(ip);
    80003e7a:	854e                	mv	a0,s3
    80003e7c:	00000097          	auipc	ra,0x0
    80003e80:	c40080e7          	jalr	-960(ra) # 80003abc <iunlockput>
      return 0;
    80003e84:	89d2                	mv	s3,s4
    80003e86:	b7f1                	j	80003e52 <namex+0x6a>
  len = path - s;
    80003e88:	40b48633          	sub	a2,s1,a1
    80003e8c:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80003e90:	094cd463          	bge	s9,s4,80003f18 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003e94:	4639                	li	a2,14
    80003e96:	8556                	mv	a0,s5
    80003e98:	ffffd097          	auipc	ra,0xffffd
    80003e9c:	eee080e7          	jalr	-274(ra) # 80000d86 <memmove>
  while(*path == '/')
    80003ea0:	0004c783          	lbu	a5,0(s1)
    80003ea4:	01279763          	bne	a5,s2,80003eb2 <namex+0xca>
    path++;
    80003ea8:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003eaa:	0004c783          	lbu	a5,0(s1)
    80003eae:	ff278de3          	beq	a5,s2,80003ea8 <namex+0xc0>
    ilock(ip);
    80003eb2:	854e                	mv	a0,s3
    80003eb4:	00000097          	auipc	ra,0x0
    80003eb8:	9a6080e7          	jalr	-1626(ra) # 8000385a <ilock>
    if(ip->type != T_DIR){
    80003ebc:	04499783          	lh	a5,68(s3)
    80003ec0:	f98793e3          	bne	a5,s8,80003e46 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003ec4:	000b0563          	beqz	s6,80003ece <namex+0xe6>
    80003ec8:	0004c783          	lbu	a5,0(s1)
    80003ecc:	d3cd                	beqz	a5,80003e6e <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003ece:	865e                	mv	a2,s7
    80003ed0:	85d6                	mv	a1,s5
    80003ed2:	854e                	mv	a0,s3
    80003ed4:	00000097          	auipc	ra,0x0
    80003ed8:	e64080e7          	jalr	-412(ra) # 80003d38 <dirlookup>
    80003edc:	8a2a                	mv	s4,a0
    80003ede:	dd51                	beqz	a0,80003e7a <namex+0x92>
    iunlockput(ip);
    80003ee0:	854e                	mv	a0,s3
    80003ee2:	00000097          	auipc	ra,0x0
    80003ee6:	bda080e7          	jalr	-1062(ra) # 80003abc <iunlockput>
    ip = next;
    80003eea:	89d2                	mv	s3,s4
  while(*path == '/')
    80003eec:	0004c783          	lbu	a5,0(s1)
    80003ef0:	05279763          	bne	a5,s2,80003f3e <namex+0x156>
    path++;
    80003ef4:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003ef6:	0004c783          	lbu	a5,0(s1)
    80003efa:	ff278de3          	beq	a5,s2,80003ef4 <namex+0x10c>
  if(*path == 0)
    80003efe:	c79d                	beqz	a5,80003f2c <namex+0x144>
    path++;
    80003f00:	85a6                	mv	a1,s1
  len = path - s;
    80003f02:	8a5e                	mv	s4,s7
    80003f04:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003f06:	01278963          	beq	a5,s2,80003f18 <namex+0x130>
    80003f0a:	dfbd                	beqz	a5,80003e88 <namex+0xa0>
    path++;
    80003f0c:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003f0e:	0004c783          	lbu	a5,0(s1)
    80003f12:	ff279ce3          	bne	a5,s2,80003f0a <namex+0x122>
    80003f16:	bf8d                	j	80003e88 <namex+0xa0>
    memmove(name, s, len);
    80003f18:	2601                	sext.w	a2,a2
    80003f1a:	8556                	mv	a0,s5
    80003f1c:	ffffd097          	auipc	ra,0xffffd
    80003f20:	e6a080e7          	jalr	-406(ra) # 80000d86 <memmove>
    name[len] = 0;
    80003f24:	9a56                	add	s4,s4,s5
    80003f26:	000a0023          	sb	zero,0(s4)
    80003f2a:	bf9d                	j	80003ea0 <namex+0xb8>
  if(nameiparent){
    80003f2c:	f20b03e3          	beqz	s6,80003e52 <namex+0x6a>
    iput(ip);
    80003f30:	854e                	mv	a0,s3
    80003f32:	00000097          	auipc	ra,0x0
    80003f36:	ae2080e7          	jalr	-1310(ra) # 80003a14 <iput>
    return 0;
    80003f3a:	4981                	li	s3,0
    80003f3c:	bf19                	j	80003e52 <namex+0x6a>
  if(*path == 0)
    80003f3e:	d7fd                	beqz	a5,80003f2c <namex+0x144>
  while(*path != '/' && *path != 0)
    80003f40:	0004c783          	lbu	a5,0(s1)
    80003f44:	85a6                	mv	a1,s1
    80003f46:	b7d1                	j	80003f0a <namex+0x122>

0000000080003f48 <dirlink>:
{
    80003f48:	7139                	addi	sp,sp,-64
    80003f4a:	fc06                	sd	ra,56(sp)
    80003f4c:	f822                	sd	s0,48(sp)
    80003f4e:	f426                	sd	s1,40(sp)
    80003f50:	f04a                	sd	s2,32(sp)
    80003f52:	ec4e                	sd	s3,24(sp)
    80003f54:	e852                	sd	s4,16(sp)
    80003f56:	0080                	addi	s0,sp,64
    80003f58:	892a                	mv	s2,a0
    80003f5a:	8a2e                	mv	s4,a1
    80003f5c:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003f5e:	4601                	li	a2,0
    80003f60:	00000097          	auipc	ra,0x0
    80003f64:	dd8080e7          	jalr	-552(ra) # 80003d38 <dirlookup>
    80003f68:	e93d                	bnez	a0,80003fde <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f6a:	04c92483          	lw	s1,76(s2)
    80003f6e:	c49d                	beqz	s1,80003f9c <dirlink+0x54>
    80003f70:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f72:	4741                	li	a4,16
    80003f74:	86a6                	mv	a3,s1
    80003f76:	fc040613          	addi	a2,s0,-64
    80003f7a:	4581                	li	a1,0
    80003f7c:	854a                	mv	a0,s2
    80003f7e:	00000097          	auipc	ra,0x0
    80003f82:	b90080e7          	jalr	-1136(ra) # 80003b0e <readi>
    80003f86:	47c1                	li	a5,16
    80003f88:	06f51163          	bne	a0,a5,80003fea <dirlink+0xa2>
    if(de.inum == 0)
    80003f8c:	fc045783          	lhu	a5,-64(s0)
    80003f90:	c791                	beqz	a5,80003f9c <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f92:	24c1                	addiw	s1,s1,16
    80003f94:	04c92783          	lw	a5,76(s2)
    80003f98:	fcf4ede3          	bltu	s1,a5,80003f72 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003f9c:	4639                	li	a2,14
    80003f9e:	85d2                	mv	a1,s4
    80003fa0:	fc240513          	addi	a0,s0,-62
    80003fa4:	ffffd097          	auipc	ra,0xffffd
    80003fa8:	e9a080e7          	jalr	-358(ra) # 80000e3e <strncpy>
  de.inum = inum;
    80003fac:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003fb0:	4741                	li	a4,16
    80003fb2:	86a6                	mv	a3,s1
    80003fb4:	fc040613          	addi	a2,s0,-64
    80003fb8:	4581                	li	a1,0
    80003fba:	854a                	mv	a0,s2
    80003fbc:	00000097          	auipc	ra,0x0
    80003fc0:	c48080e7          	jalr	-952(ra) # 80003c04 <writei>
    80003fc4:	872a                	mv	a4,a0
    80003fc6:	47c1                	li	a5,16
  return 0;
    80003fc8:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003fca:	02f71863          	bne	a4,a5,80003ffa <dirlink+0xb2>
}
    80003fce:	70e2                	ld	ra,56(sp)
    80003fd0:	7442                	ld	s0,48(sp)
    80003fd2:	74a2                	ld	s1,40(sp)
    80003fd4:	7902                	ld	s2,32(sp)
    80003fd6:	69e2                	ld	s3,24(sp)
    80003fd8:	6a42                	ld	s4,16(sp)
    80003fda:	6121                	addi	sp,sp,64
    80003fdc:	8082                	ret
    iput(ip);
    80003fde:	00000097          	auipc	ra,0x0
    80003fe2:	a36080e7          	jalr	-1482(ra) # 80003a14 <iput>
    return -1;
    80003fe6:	557d                	li	a0,-1
    80003fe8:	b7dd                	j	80003fce <dirlink+0x86>
      panic("dirlink read");
    80003fea:	00004517          	auipc	a0,0x4
    80003fee:	68e50513          	addi	a0,a0,1678 # 80008678 <syscalls+0x1c8>
    80003ff2:	ffffc097          	auipc	ra,0xffffc
    80003ff6:	556080e7          	jalr	1366(ra) # 80000548 <panic>
    panic("dirlink");
    80003ffa:	00004517          	auipc	a0,0x4
    80003ffe:	79650513          	addi	a0,a0,1942 # 80008790 <syscalls+0x2e0>
    80004002:	ffffc097          	auipc	ra,0xffffc
    80004006:	546080e7          	jalr	1350(ra) # 80000548 <panic>

000000008000400a <namei>:

struct inode*
namei(char *path)
{
    8000400a:	1101                	addi	sp,sp,-32
    8000400c:	ec06                	sd	ra,24(sp)
    8000400e:	e822                	sd	s0,16(sp)
    80004010:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004012:	fe040613          	addi	a2,s0,-32
    80004016:	4581                	li	a1,0
    80004018:	00000097          	auipc	ra,0x0
    8000401c:	dd0080e7          	jalr	-560(ra) # 80003de8 <namex>
}
    80004020:	60e2                	ld	ra,24(sp)
    80004022:	6442                	ld	s0,16(sp)
    80004024:	6105                	addi	sp,sp,32
    80004026:	8082                	ret

0000000080004028 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004028:	1141                	addi	sp,sp,-16
    8000402a:	e406                	sd	ra,8(sp)
    8000402c:	e022                	sd	s0,0(sp)
    8000402e:	0800                	addi	s0,sp,16
    80004030:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004032:	4585                	li	a1,1
    80004034:	00000097          	auipc	ra,0x0
    80004038:	db4080e7          	jalr	-588(ra) # 80003de8 <namex>
}
    8000403c:	60a2                	ld	ra,8(sp)
    8000403e:	6402                	ld	s0,0(sp)
    80004040:	0141                	addi	sp,sp,16
    80004042:	8082                	ret

0000000080004044 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004044:	1101                	addi	sp,sp,-32
    80004046:	ec06                	sd	ra,24(sp)
    80004048:	e822                	sd	s0,16(sp)
    8000404a:	e426                	sd	s1,8(sp)
    8000404c:	e04a                	sd	s2,0(sp)
    8000404e:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004050:	0001e917          	auipc	s2,0x1e
    80004054:	ab890913          	addi	s2,s2,-1352 # 80021b08 <log>
    80004058:	01892583          	lw	a1,24(s2)
    8000405c:	02892503          	lw	a0,40(s2)
    80004060:	fffff097          	auipc	ra,0xfffff
    80004064:	ff8080e7          	jalr	-8(ra) # 80003058 <bread>
    80004068:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000406a:	02c92683          	lw	a3,44(s2)
    8000406e:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004070:	02d05763          	blez	a3,8000409e <write_head+0x5a>
    80004074:	0001e797          	auipc	a5,0x1e
    80004078:	ac478793          	addi	a5,a5,-1340 # 80021b38 <log+0x30>
    8000407c:	05c50713          	addi	a4,a0,92
    80004080:	36fd                	addiw	a3,a3,-1
    80004082:	1682                	slli	a3,a3,0x20
    80004084:	9281                	srli	a3,a3,0x20
    80004086:	068a                	slli	a3,a3,0x2
    80004088:	0001e617          	auipc	a2,0x1e
    8000408c:	ab460613          	addi	a2,a2,-1356 # 80021b3c <log+0x34>
    80004090:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004092:	4390                	lw	a2,0(a5)
    80004094:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004096:	0791                	addi	a5,a5,4
    80004098:	0711                	addi	a4,a4,4
    8000409a:	fed79ce3          	bne	a5,a3,80004092 <write_head+0x4e>
  }
  bwrite(buf);
    8000409e:	8526                	mv	a0,s1
    800040a0:	fffff097          	auipc	ra,0xfffff
    800040a4:	0aa080e7          	jalr	170(ra) # 8000314a <bwrite>
  brelse(buf);
    800040a8:	8526                	mv	a0,s1
    800040aa:	fffff097          	auipc	ra,0xfffff
    800040ae:	0de080e7          	jalr	222(ra) # 80003188 <brelse>
}
    800040b2:	60e2                	ld	ra,24(sp)
    800040b4:	6442                	ld	s0,16(sp)
    800040b6:	64a2                	ld	s1,8(sp)
    800040b8:	6902                	ld	s2,0(sp)
    800040ba:	6105                	addi	sp,sp,32
    800040bc:	8082                	ret

00000000800040be <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800040be:	0001e797          	auipc	a5,0x1e
    800040c2:	a767a783          	lw	a5,-1418(a5) # 80021b34 <log+0x2c>
    800040c6:	0af05663          	blez	a5,80004172 <install_trans+0xb4>
{
    800040ca:	7139                	addi	sp,sp,-64
    800040cc:	fc06                	sd	ra,56(sp)
    800040ce:	f822                	sd	s0,48(sp)
    800040d0:	f426                	sd	s1,40(sp)
    800040d2:	f04a                	sd	s2,32(sp)
    800040d4:	ec4e                	sd	s3,24(sp)
    800040d6:	e852                	sd	s4,16(sp)
    800040d8:	e456                	sd	s5,8(sp)
    800040da:	0080                	addi	s0,sp,64
    800040dc:	0001ea97          	auipc	s5,0x1e
    800040e0:	a5ca8a93          	addi	s5,s5,-1444 # 80021b38 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800040e4:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800040e6:	0001e997          	auipc	s3,0x1e
    800040ea:	a2298993          	addi	s3,s3,-1502 # 80021b08 <log>
    800040ee:	0189a583          	lw	a1,24(s3)
    800040f2:	014585bb          	addw	a1,a1,s4
    800040f6:	2585                	addiw	a1,a1,1
    800040f8:	0289a503          	lw	a0,40(s3)
    800040fc:	fffff097          	auipc	ra,0xfffff
    80004100:	f5c080e7          	jalr	-164(ra) # 80003058 <bread>
    80004104:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004106:	000aa583          	lw	a1,0(s5)
    8000410a:	0289a503          	lw	a0,40(s3)
    8000410e:	fffff097          	auipc	ra,0xfffff
    80004112:	f4a080e7          	jalr	-182(ra) # 80003058 <bread>
    80004116:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004118:	40000613          	li	a2,1024
    8000411c:	05890593          	addi	a1,s2,88
    80004120:	05850513          	addi	a0,a0,88
    80004124:	ffffd097          	auipc	ra,0xffffd
    80004128:	c62080e7          	jalr	-926(ra) # 80000d86 <memmove>
    bwrite(dbuf);  // write dst to disk
    8000412c:	8526                	mv	a0,s1
    8000412e:	fffff097          	auipc	ra,0xfffff
    80004132:	01c080e7          	jalr	28(ra) # 8000314a <bwrite>
    bunpin(dbuf);
    80004136:	8526                	mv	a0,s1
    80004138:	fffff097          	auipc	ra,0xfffff
    8000413c:	12a080e7          	jalr	298(ra) # 80003262 <bunpin>
    brelse(lbuf);
    80004140:	854a                	mv	a0,s2
    80004142:	fffff097          	auipc	ra,0xfffff
    80004146:	046080e7          	jalr	70(ra) # 80003188 <brelse>
    brelse(dbuf);
    8000414a:	8526                	mv	a0,s1
    8000414c:	fffff097          	auipc	ra,0xfffff
    80004150:	03c080e7          	jalr	60(ra) # 80003188 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004154:	2a05                	addiw	s4,s4,1
    80004156:	0a91                	addi	s5,s5,4
    80004158:	02c9a783          	lw	a5,44(s3)
    8000415c:	f8fa49e3          	blt	s4,a5,800040ee <install_trans+0x30>
}
    80004160:	70e2                	ld	ra,56(sp)
    80004162:	7442                	ld	s0,48(sp)
    80004164:	74a2                	ld	s1,40(sp)
    80004166:	7902                	ld	s2,32(sp)
    80004168:	69e2                	ld	s3,24(sp)
    8000416a:	6a42                	ld	s4,16(sp)
    8000416c:	6aa2                	ld	s5,8(sp)
    8000416e:	6121                	addi	sp,sp,64
    80004170:	8082                	ret
    80004172:	8082                	ret

0000000080004174 <initlog>:
{
    80004174:	7179                	addi	sp,sp,-48
    80004176:	f406                	sd	ra,40(sp)
    80004178:	f022                	sd	s0,32(sp)
    8000417a:	ec26                	sd	s1,24(sp)
    8000417c:	e84a                	sd	s2,16(sp)
    8000417e:	e44e                	sd	s3,8(sp)
    80004180:	1800                	addi	s0,sp,48
    80004182:	892a                	mv	s2,a0
    80004184:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004186:	0001e497          	auipc	s1,0x1e
    8000418a:	98248493          	addi	s1,s1,-1662 # 80021b08 <log>
    8000418e:	00004597          	auipc	a1,0x4
    80004192:	4fa58593          	addi	a1,a1,1274 # 80008688 <syscalls+0x1d8>
    80004196:	8526                	mv	a0,s1
    80004198:	ffffd097          	auipc	ra,0xffffd
    8000419c:	a02080e7          	jalr	-1534(ra) # 80000b9a <initlock>
  log.start = sb->logstart;
    800041a0:	0149a583          	lw	a1,20(s3)
    800041a4:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800041a6:	0109a783          	lw	a5,16(s3)
    800041aa:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800041ac:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800041b0:	854a                	mv	a0,s2
    800041b2:	fffff097          	auipc	ra,0xfffff
    800041b6:	ea6080e7          	jalr	-346(ra) # 80003058 <bread>
  log.lh.n = lh->n;
    800041ba:	4d3c                	lw	a5,88(a0)
    800041bc:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800041be:	02f05563          	blez	a5,800041e8 <initlog+0x74>
    800041c2:	05c50713          	addi	a4,a0,92
    800041c6:	0001e697          	auipc	a3,0x1e
    800041ca:	97268693          	addi	a3,a3,-1678 # 80021b38 <log+0x30>
    800041ce:	37fd                	addiw	a5,a5,-1
    800041d0:	1782                	slli	a5,a5,0x20
    800041d2:	9381                	srli	a5,a5,0x20
    800041d4:	078a                	slli	a5,a5,0x2
    800041d6:	06050613          	addi	a2,a0,96
    800041da:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    800041dc:	4310                	lw	a2,0(a4)
    800041de:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    800041e0:	0711                	addi	a4,a4,4
    800041e2:	0691                	addi	a3,a3,4
    800041e4:	fef71ce3          	bne	a4,a5,800041dc <initlog+0x68>
  brelse(buf);
    800041e8:	fffff097          	auipc	ra,0xfffff
    800041ec:	fa0080e7          	jalr	-96(ra) # 80003188 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
    800041f0:	00000097          	auipc	ra,0x0
    800041f4:	ece080e7          	jalr	-306(ra) # 800040be <install_trans>
  log.lh.n = 0;
    800041f8:	0001e797          	auipc	a5,0x1e
    800041fc:	9207ae23          	sw	zero,-1732(a5) # 80021b34 <log+0x2c>
  write_head(); // clear the log
    80004200:	00000097          	auipc	ra,0x0
    80004204:	e44080e7          	jalr	-444(ra) # 80004044 <write_head>
}
    80004208:	70a2                	ld	ra,40(sp)
    8000420a:	7402                	ld	s0,32(sp)
    8000420c:	64e2                	ld	s1,24(sp)
    8000420e:	6942                	ld	s2,16(sp)
    80004210:	69a2                	ld	s3,8(sp)
    80004212:	6145                	addi	sp,sp,48
    80004214:	8082                	ret

0000000080004216 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004216:	1101                	addi	sp,sp,-32
    80004218:	ec06                	sd	ra,24(sp)
    8000421a:	e822                	sd	s0,16(sp)
    8000421c:	e426                	sd	s1,8(sp)
    8000421e:	e04a                	sd	s2,0(sp)
    80004220:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004222:	0001e517          	auipc	a0,0x1e
    80004226:	8e650513          	addi	a0,a0,-1818 # 80021b08 <log>
    8000422a:	ffffd097          	auipc	ra,0xffffd
    8000422e:	a00080e7          	jalr	-1536(ra) # 80000c2a <acquire>
  while(1){
    if(log.committing){
    80004232:	0001e497          	auipc	s1,0x1e
    80004236:	8d648493          	addi	s1,s1,-1834 # 80021b08 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000423a:	4979                	li	s2,30
    8000423c:	a039                	j	8000424a <begin_op+0x34>
      sleep(&log, &log.lock);
    8000423e:	85a6                	mv	a1,s1
    80004240:	8526                	mv	a0,s1
    80004242:	ffffe097          	auipc	ra,0xffffe
    80004246:	1f8080e7          	jalr	504(ra) # 8000243a <sleep>
    if(log.committing){
    8000424a:	50dc                	lw	a5,36(s1)
    8000424c:	fbed                	bnez	a5,8000423e <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000424e:	509c                	lw	a5,32(s1)
    80004250:	0017871b          	addiw	a4,a5,1
    80004254:	0007069b          	sext.w	a3,a4
    80004258:	0027179b          	slliw	a5,a4,0x2
    8000425c:	9fb9                	addw	a5,a5,a4
    8000425e:	0017979b          	slliw	a5,a5,0x1
    80004262:	54d8                	lw	a4,44(s1)
    80004264:	9fb9                	addw	a5,a5,a4
    80004266:	00f95963          	bge	s2,a5,80004278 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000426a:	85a6                	mv	a1,s1
    8000426c:	8526                	mv	a0,s1
    8000426e:	ffffe097          	auipc	ra,0xffffe
    80004272:	1cc080e7          	jalr	460(ra) # 8000243a <sleep>
    80004276:	bfd1                	j	8000424a <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004278:	0001e517          	auipc	a0,0x1e
    8000427c:	89050513          	addi	a0,a0,-1904 # 80021b08 <log>
    80004280:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004282:	ffffd097          	auipc	ra,0xffffd
    80004286:	a5c080e7          	jalr	-1444(ra) # 80000cde <release>
      break;
    }
  }
}
    8000428a:	60e2                	ld	ra,24(sp)
    8000428c:	6442                	ld	s0,16(sp)
    8000428e:	64a2                	ld	s1,8(sp)
    80004290:	6902                	ld	s2,0(sp)
    80004292:	6105                	addi	sp,sp,32
    80004294:	8082                	ret

0000000080004296 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004296:	7139                	addi	sp,sp,-64
    80004298:	fc06                	sd	ra,56(sp)
    8000429a:	f822                	sd	s0,48(sp)
    8000429c:	f426                	sd	s1,40(sp)
    8000429e:	f04a                	sd	s2,32(sp)
    800042a0:	ec4e                	sd	s3,24(sp)
    800042a2:	e852                	sd	s4,16(sp)
    800042a4:	e456                	sd	s5,8(sp)
    800042a6:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800042a8:	0001e497          	auipc	s1,0x1e
    800042ac:	86048493          	addi	s1,s1,-1952 # 80021b08 <log>
    800042b0:	8526                	mv	a0,s1
    800042b2:	ffffd097          	auipc	ra,0xffffd
    800042b6:	978080e7          	jalr	-1672(ra) # 80000c2a <acquire>
  log.outstanding -= 1;
    800042ba:	509c                	lw	a5,32(s1)
    800042bc:	37fd                	addiw	a5,a5,-1
    800042be:	0007891b          	sext.w	s2,a5
    800042c2:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800042c4:	50dc                	lw	a5,36(s1)
    800042c6:	efb9                	bnez	a5,80004324 <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    800042c8:	06091663          	bnez	s2,80004334 <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    800042cc:	0001e497          	auipc	s1,0x1e
    800042d0:	83c48493          	addi	s1,s1,-1988 # 80021b08 <log>
    800042d4:	4785                	li	a5,1
    800042d6:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800042d8:	8526                	mv	a0,s1
    800042da:	ffffd097          	auipc	ra,0xffffd
    800042de:	a04080e7          	jalr	-1532(ra) # 80000cde <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800042e2:	54dc                	lw	a5,44(s1)
    800042e4:	06f04763          	bgtz	a5,80004352 <end_op+0xbc>
    acquire(&log.lock);
    800042e8:	0001e497          	auipc	s1,0x1e
    800042ec:	82048493          	addi	s1,s1,-2016 # 80021b08 <log>
    800042f0:	8526                	mv	a0,s1
    800042f2:	ffffd097          	auipc	ra,0xffffd
    800042f6:	938080e7          	jalr	-1736(ra) # 80000c2a <acquire>
    log.committing = 0;
    800042fa:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800042fe:	8526                	mv	a0,s1
    80004300:	ffffe097          	auipc	ra,0xffffe
    80004304:	2c0080e7          	jalr	704(ra) # 800025c0 <wakeup>
    release(&log.lock);
    80004308:	8526                	mv	a0,s1
    8000430a:	ffffd097          	auipc	ra,0xffffd
    8000430e:	9d4080e7          	jalr	-1580(ra) # 80000cde <release>
}
    80004312:	70e2                	ld	ra,56(sp)
    80004314:	7442                	ld	s0,48(sp)
    80004316:	74a2                	ld	s1,40(sp)
    80004318:	7902                	ld	s2,32(sp)
    8000431a:	69e2                	ld	s3,24(sp)
    8000431c:	6a42                	ld	s4,16(sp)
    8000431e:	6aa2                	ld	s5,8(sp)
    80004320:	6121                	addi	sp,sp,64
    80004322:	8082                	ret
    panic("log.committing");
    80004324:	00004517          	auipc	a0,0x4
    80004328:	36c50513          	addi	a0,a0,876 # 80008690 <syscalls+0x1e0>
    8000432c:	ffffc097          	auipc	ra,0xffffc
    80004330:	21c080e7          	jalr	540(ra) # 80000548 <panic>
    wakeup(&log);
    80004334:	0001d497          	auipc	s1,0x1d
    80004338:	7d448493          	addi	s1,s1,2004 # 80021b08 <log>
    8000433c:	8526                	mv	a0,s1
    8000433e:	ffffe097          	auipc	ra,0xffffe
    80004342:	282080e7          	jalr	642(ra) # 800025c0 <wakeup>
  release(&log.lock);
    80004346:	8526                	mv	a0,s1
    80004348:	ffffd097          	auipc	ra,0xffffd
    8000434c:	996080e7          	jalr	-1642(ra) # 80000cde <release>
  if(do_commit){
    80004350:	b7c9                	j	80004312 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004352:	0001da97          	auipc	s5,0x1d
    80004356:	7e6a8a93          	addi	s5,s5,2022 # 80021b38 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000435a:	0001da17          	auipc	s4,0x1d
    8000435e:	7aea0a13          	addi	s4,s4,1966 # 80021b08 <log>
    80004362:	018a2583          	lw	a1,24(s4)
    80004366:	012585bb          	addw	a1,a1,s2
    8000436a:	2585                	addiw	a1,a1,1
    8000436c:	028a2503          	lw	a0,40(s4)
    80004370:	fffff097          	auipc	ra,0xfffff
    80004374:	ce8080e7          	jalr	-792(ra) # 80003058 <bread>
    80004378:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000437a:	000aa583          	lw	a1,0(s5)
    8000437e:	028a2503          	lw	a0,40(s4)
    80004382:	fffff097          	auipc	ra,0xfffff
    80004386:	cd6080e7          	jalr	-810(ra) # 80003058 <bread>
    8000438a:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000438c:	40000613          	li	a2,1024
    80004390:	05850593          	addi	a1,a0,88
    80004394:	05848513          	addi	a0,s1,88
    80004398:	ffffd097          	auipc	ra,0xffffd
    8000439c:	9ee080e7          	jalr	-1554(ra) # 80000d86 <memmove>
    bwrite(to);  // write the log
    800043a0:	8526                	mv	a0,s1
    800043a2:	fffff097          	auipc	ra,0xfffff
    800043a6:	da8080e7          	jalr	-600(ra) # 8000314a <bwrite>
    brelse(from);
    800043aa:	854e                	mv	a0,s3
    800043ac:	fffff097          	auipc	ra,0xfffff
    800043b0:	ddc080e7          	jalr	-548(ra) # 80003188 <brelse>
    brelse(to);
    800043b4:	8526                	mv	a0,s1
    800043b6:	fffff097          	auipc	ra,0xfffff
    800043ba:	dd2080e7          	jalr	-558(ra) # 80003188 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800043be:	2905                	addiw	s2,s2,1
    800043c0:	0a91                	addi	s5,s5,4
    800043c2:	02ca2783          	lw	a5,44(s4)
    800043c6:	f8f94ee3          	blt	s2,a5,80004362 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800043ca:	00000097          	auipc	ra,0x0
    800043ce:	c7a080e7          	jalr	-902(ra) # 80004044 <write_head>
    install_trans(); // Now install writes to home locations
    800043d2:	00000097          	auipc	ra,0x0
    800043d6:	cec080e7          	jalr	-788(ra) # 800040be <install_trans>
    log.lh.n = 0;
    800043da:	0001d797          	auipc	a5,0x1d
    800043de:	7407ad23          	sw	zero,1882(a5) # 80021b34 <log+0x2c>
    write_head();    // Erase the transaction from the log
    800043e2:	00000097          	auipc	ra,0x0
    800043e6:	c62080e7          	jalr	-926(ra) # 80004044 <write_head>
    800043ea:	bdfd                	j	800042e8 <end_op+0x52>

00000000800043ec <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800043ec:	1101                	addi	sp,sp,-32
    800043ee:	ec06                	sd	ra,24(sp)
    800043f0:	e822                	sd	s0,16(sp)
    800043f2:	e426                	sd	s1,8(sp)
    800043f4:	e04a                	sd	s2,0(sp)
    800043f6:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800043f8:	0001d717          	auipc	a4,0x1d
    800043fc:	73c72703          	lw	a4,1852(a4) # 80021b34 <log+0x2c>
    80004400:	47f5                	li	a5,29
    80004402:	08e7c063          	blt	a5,a4,80004482 <log_write+0x96>
    80004406:	84aa                	mv	s1,a0
    80004408:	0001d797          	auipc	a5,0x1d
    8000440c:	71c7a783          	lw	a5,1820(a5) # 80021b24 <log+0x1c>
    80004410:	37fd                	addiw	a5,a5,-1
    80004412:	06f75863          	bge	a4,a5,80004482 <log_write+0x96>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004416:	0001d797          	auipc	a5,0x1d
    8000441a:	7127a783          	lw	a5,1810(a5) # 80021b28 <log+0x20>
    8000441e:	06f05a63          	blez	a5,80004492 <log_write+0xa6>
    panic("log_write outside of trans");

  acquire(&log.lock);
    80004422:	0001d917          	auipc	s2,0x1d
    80004426:	6e690913          	addi	s2,s2,1766 # 80021b08 <log>
    8000442a:	854a                	mv	a0,s2
    8000442c:	ffffc097          	auipc	ra,0xffffc
    80004430:	7fe080e7          	jalr	2046(ra) # 80000c2a <acquire>
  for (i = 0; i < log.lh.n; i++) {
    80004434:	02c92603          	lw	a2,44(s2)
    80004438:	06c05563          	blez	a2,800044a2 <log_write+0xb6>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    8000443c:	44cc                	lw	a1,12(s1)
    8000443e:	0001d717          	auipc	a4,0x1d
    80004442:	6fa70713          	addi	a4,a4,1786 # 80021b38 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004446:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004448:	4314                	lw	a3,0(a4)
    8000444a:	04b68d63          	beq	a3,a1,800044a4 <log_write+0xb8>
  for (i = 0; i < log.lh.n; i++) {
    8000444e:	2785                	addiw	a5,a5,1
    80004450:	0711                	addi	a4,a4,4
    80004452:	fec79be3          	bne	a5,a2,80004448 <log_write+0x5c>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004456:	0621                	addi	a2,a2,8
    80004458:	060a                	slli	a2,a2,0x2
    8000445a:	0001d797          	auipc	a5,0x1d
    8000445e:	6ae78793          	addi	a5,a5,1710 # 80021b08 <log>
    80004462:	963e                	add	a2,a2,a5
    80004464:	44dc                	lw	a5,12(s1)
    80004466:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004468:	8526                	mv	a0,s1
    8000446a:	fffff097          	auipc	ra,0xfffff
    8000446e:	dbc080e7          	jalr	-580(ra) # 80003226 <bpin>
    log.lh.n++;
    80004472:	0001d717          	auipc	a4,0x1d
    80004476:	69670713          	addi	a4,a4,1686 # 80021b08 <log>
    8000447a:	575c                	lw	a5,44(a4)
    8000447c:	2785                	addiw	a5,a5,1
    8000447e:	d75c                	sw	a5,44(a4)
    80004480:	a83d                	j	800044be <log_write+0xd2>
    panic("too big a transaction");
    80004482:	00004517          	auipc	a0,0x4
    80004486:	21e50513          	addi	a0,a0,542 # 800086a0 <syscalls+0x1f0>
    8000448a:	ffffc097          	auipc	ra,0xffffc
    8000448e:	0be080e7          	jalr	190(ra) # 80000548 <panic>
    panic("log_write outside of trans");
    80004492:	00004517          	auipc	a0,0x4
    80004496:	22650513          	addi	a0,a0,550 # 800086b8 <syscalls+0x208>
    8000449a:	ffffc097          	auipc	ra,0xffffc
    8000449e:	0ae080e7          	jalr	174(ra) # 80000548 <panic>
  for (i = 0; i < log.lh.n; i++) {
    800044a2:	4781                	li	a5,0
  log.lh.block[i] = b->blockno;
    800044a4:	00878713          	addi	a4,a5,8
    800044a8:	00271693          	slli	a3,a4,0x2
    800044ac:	0001d717          	auipc	a4,0x1d
    800044b0:	65c70713          	addi	a4,a4,1628 # 80021b08 <log>
    800044b4:	9736                	add	a4,a4,a3
    800044b6:	44d4                	lw	a3,12(s1)
    800044b8:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800044ba:	faf607e3          	beq	a2,a5,80004468 <log_write+0x7c>
  }
  release(&log.lock);
    800044be:	0001d517          	auipc	a0,0x1d
    800044c2:	64a50513          	addi	a0,a0,1610 # 80021b08 <log>
    800044c6:	ffffd097          	auipc	ra,0xffffd
    800044ca:	818080e7          	jalr	-2024(ra) # 80000cde <release>
}
    800044ce:	60e2                	ld	ra,24(sp)
    800044d0:	6442                	ld	s0,16(sp)
    800044d2:	64a2                	ld	s1,8(sp)
    800044d4:	6902                	ld	s2,0(sp)
    800044d6:	6105                	addi	sp,sp,32
    800044d8:	8082                	ret

00000000800044da <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800044da:	1101                	addi	sp,sp,-32
    800044dc:	ec06                	sd	ra,24(sp)
    800044de:	e822                	sd	s0,16(sp)
    800044e0:	e426                	sd	s1,8(sp)
    800044e2:	e04a                	sd	s2,0(sp)
    800044e4:	1000                	addi	s0,sp,32
    800044e6:	84aa                	mv	s1,a0
    800044e8:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800044ea:	00004597          	auipc	a1,0x4
    800044ee:	1ee58593          	addi	a1,a1,494 # 800086d8 <syscalls+0x228>
    800044f2:	0521                	addi	a0,a0,8
    800044f4:	ffffc097          	auipc	ra,0xffffc
    800044f8:	6a6080e7          	jalr	1702(ra) # 80000b9a <initlock>
  lk->name = name;
    800044fc:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004500:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004504:	0204a423          	sw	zero,40(s1)
}
    80004508:	60e2                	ld	ra,24(sp)
    8000450a:	6442                	ld	s0,16(sp)
    8000450c:	64a2                	ld	s1,8(sp)
    8000450e:	6902                	ld	s2,0(sp)
    80004510:	6105                	addi	sp,sp,32
    80004512:	8082                	ret

0000000080004514 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004514:	1101                	addi	sp,sp,-32
    80004516:	ec06                	sd	ra,24(sp)
    80004518:	e822                	sd	s0,16(sp)
    8000451a:	e426                	sd	s1,8(sp)
    8000451c:	e04a                	sd	s2,0(sp)
    8000451e:	1000                	addi	s0,sp,32
    80004520:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004522:	00850913          	addi	s2,a0,8
    80004526:	854a                	mv	a0,s2
    80004528:	ffffc097          	auipc	ra,0xffffc
    8000452c:	702080e7          	jalr	1794(ra) # 80000c2a <acquire>
  while (lk->locked) {
    80004530:	409c                	lw	a5,0(s1)
    80004532:	cb89                	beqz	a5,80004544 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004534:	85ca                	mv	a1,s2
    80004536:	8526                	mv	a0,s1
    80004538:	ffffe097          	auipc	ra,0xffffe
    8000453c:	f02080e7          	jalr	-254(ra) # 8000243a <sleep>
  while (lk->locked) {
    80004540:	409c                	lw	a5,0(s1)
    80004542:	fbed                	bnez	a5,80004534 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004544:	4785                	li	a5,1
    80004546:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004548:	ffffd097          	auipc	ra,0xffffd
    8000454c:	5ca080e7          	jalr	1482(ra) # 80001b12 <myproc>
    80004550:	5d1c                	lw	a5,56(a0)
    80004552:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004554:	854a                	mv	a0,s2
    80004556:	ffffc097          	auipc	ra,0xffffc
    8000455a:	788080e7          	jalr	1928(ra) # 80000cde <release>
}
    8000455e:	60e2                	ld	ra,24(sp)
    80004560:	6442                	ld	s0,16(sp)
    80004562:	64a2                	ld	s1,8(sp)
    80004564:	6902                	ld	s2,0(sp)
    80004566:	6105                	addi	sp,sp,32
    80004568:	8082                	ret

000000008000456a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000456a:	1101                	addi	sp,sp,-32
    8000456c:	ec06                	sd	ra,24(sp)
    8000456e:	e822                	sd	s0,16(sp)
    80004570:	e426                	sd	s1,8(sp)
    80004572:	e04a                	sd	s2,0(sp)
    80004574:	1000                	addi	s0,sp,32
    80004576:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004578:	00850913          	addi	s2,a0,8
    8000457c:	854a                	mv	a0,s2
    8000457e:	ffffc097          	auipc	ra,0xffffc
    80004582:	6ac080e7          	jalr	1708(ra) # 80000c2a <acquire>
  lk->locked = 0;
    80004586:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000458a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000458e:	8526                	mv	a0,s1
    80004590:	ffffe097          	auipc	ra,0xffffe
    80004594:	030080e7          	jalr	48(ra) # 800025c0 <wakeup>
  release(&lk->lk);
    80004598:	854a                	mv	a0,s2
    8000459a:	ffffc097          	auipc	ra,0xffffc
    8000459e:	744080e7          	jalr	1860(ra) # 80000cde <release>
}
    800045a2:	60e2                	ld	ra,24(sp)
    800045a4:	6442                	ld	s0,16(sp)
    800045a6:	64a2                	ld	s1,8(sp)
    800045a8:	6902                	ld	s2,0(sp)
    800045aa:	6105                	addi	sp,sp,32
    800045ac:	8082                	ret

00000000800045ae <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800045ae:	7179                	addi	sp,sp,-48
    800045b0:	f406                	sd	ra,40(sp)
    800045b2:	f022                	sd	s0,32(sp)
    800045b4:	ec26                	sd	s1,24(sp)
    800045b6:	e84a                	sd	s2,16(sp)
    800045b8:	e44e                	sd	s3,8(sp)
    800045ba:	1800                	addi	s0,sp,48
    800045bc:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800045be:	00850913          	addi	s2,a0,8
    800045c2:	854a                	mv	a0,s2
    800045c4:	ffffc097          	auipc	ra,0xffffc
    800045c8:	666080e7          	jalr	1638(ra) # 80000c2a <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800045cc:	409c                	lw	a5,0(s1)
    800045ce:	ef99                	bnez	a5,800045ec <holdingsleep+0x3e>
    800045d0:	4481                	li	s1,0
  release(&lk->lk);
    800045d2:	854a                	mv	a0,s2
    800045d4:	ffffc097          	auipc	ra,0xffffc
    800045d8:	70a080e7          	jalr	1802(ra) # 80000cde <release>
  return r;
}
    800045dc:	8526                	mv	a0,s1
    800045de:	70a2                	ld	ra,40(sp)
    800045e0:	7402                	ld	s0,32(sp)
    800045e2:	64e2                	ld	s1,24(sp)
    800045e4:	6942                	ld	s2,16(sp)
    800045e6:	69a2                	ld	s3,8(sp)
    800045e8:	6145                	addi	sp,sp,48
    800045ea:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800045ec:	0284a983          	lw	s3,40(s1)
    800045f0:	ffffd097          	auipc	ra,0xffffd
    800045f4:	522080e7          	jalr	1314(ra) # 80001b12 <myproc>
    800045f8:	5d04                	lw	s1,56(a0)
    800045fa:	413484b3          	sub	s1,s1,s3
    800045fe:	0014b493          	seqz	s1,s1
    80004602:	bfc1                	j	800045d2 <holdingsleep+0x24>

0000000080004604 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004604:	1141                	addi	sp,sp,-16
    80004606:	e406                	sd	ra,8(sp)
    80004608:	e022                	sd	s0,0(sp)
    8000460a:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000460c:	00004597          	auipc	a1,0x4
    80004610:	0dc58593          	addi	a1,a1,220 # 800086e8 <syscalls+0x238>
    80004614:	0001d517          	auipc	a0,0x1d
    80004618:	63c50513          	addi	a0,a0,1596 # 80021c50 <ftable>
    8000461c:	ffffc097          	auipc	ra,0xffffc
    80004620:	57e080e7          	jalr	1406(ra) # 80000b9a <initlock>
}
    80004624:	60a2                	ld	ra,8(sp)
    80004626:	6402                	ld	s0,0(sp)
    80004628:	0141                	addi	sp,sp,16
    8000462a:	8082                	ret

000000008000462c <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000462c:	1101                	addi	sp,sp,-32
    8000462e:	ec06                	sd	ra,24(sp)
    80004630:	e822                	sd	s0,16(sp)
    80004632:	e426                	sd	s1,8(sp)
    80004634:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004636:	0001d517          	auipc	a0,0x1d
    8000463a:	61a50513          	addi	a0,a0,1562 # 80021c50 <ftable>
    8000463e:	ffffc097          	auipc	ra,0xffffc
    80004642:	5ec080e7          	jalr	1516(ra) # 80000c2a <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004646:	0001d497          	auipc	s1,0x1d
    8000464a:	62248493          	addi	s1,s1,1570 # 80021c68 <ftable+0x18>
    8000464e:	0001e717          	auipc	a4,0x1e
    80004652:	5ba70713          	addi	a4,a4,1466 # 80022c08 <ftable+0xfb8>
    if(f->ref == 0){
    80004656:	40dc                	lw	a5,4(s1)
    80004658:	cf99                	beqz	a5,80004676 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000465a:	02848493          	addi	s1,s1,40
    8000465e:	fee49ce3          	bne	s1,a4,80004656 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004662:	0001d517          	auipc	a0,0x1d
    80004666:	5ee50513          	addi	a0,a0,1518 # 80021c50 <ftable>
    8000466a:	ffffc097          	auipc	ra,0xffffc
    8000466e:	674080e7          	jalr	1652(ra) # 80000cde <release>
  return 0;
    80004672:	4481                	li	s1,0
    80004674:	a819                	j	8000468a <filealloc+0x5e>
      f->ref = 1;
    80004676:	4785                	li	a5,1
    80004678:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000467a:	0001d517          	auipc	a0,0x1d
    8000467e:	5d650513          	addi	a0,a0,1494 # 80021c50 <ftable>
    80004682:	ffffc097          	auipc	ra,0xffffc
    80004686:	65c080e7          	jalr	1628(ra) # 80000cde <release>
}
    8000468a:	8526                	mv	a0,s1
    8000468c:	60e2                	ld	ra,24(sp)
    8000468e:	6442                	ld	s0,16(sp)
    80004690:	64a2                	ld	s1,8(sp)
    80004692:	6105                	addi	sp,sp,32
    80004694:	8082                	ret

0000000080004696 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004696:	1101                	addi	sp,sp,-32
    80004698:	ec06                	sd	ra,24(sp)
    8000469a:	e822                	sd	s0,16(sp)
    8000469c:	e426                	sd	s1,8(sp)
    8000469e:	1000                	addi	s0,sp,32
    800046a0:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800046a2:	0001d517          	auipc	a0,0x1d
    800046a6:	5ae50513          	addi	a0,a0,1454 # 80021c50 <ftable>
    800046aa:	ffffc097          	auipc	ra,0xffffc
    800046ae:	580080e7          	jalr	1408(ra) # 80000c2a <acquire>
  if(f->ref < 1)
    800046b2:	40dc                	lw	a5,4(s1)
    800046b4:	02f05263          	blez	a5,800046d8 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800046b8:	2785                	addiw	a5,a5,1
    800046ba:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800046bc:	0001d517          	auipc	a0,0x1d
    800046c0:	59450513          	addi	a0,a0,1428 # 80021c50 <ftable>
    800046c4:	ffffc097          	auipc	ra,0xffffc
    800046c8:	61a080e7          	jalr	1562(ra) # 80000cde <release>
  return f;
}
    800046cc:	8526                	mv	a0,s1
    800046ce:	60e2                	ld	ra,24(sp)
    800046d0:	6442                	ld	s0,16(sp)
    800046d2:	64a2                	ld	s1,8(sp)
    800046d4:	6105                	addi	sp,sp,32
    800046d6:	8082                	ret
    panic("filedup");
    800046d8:	00004517          	auipc	a0,0x4
    800046dc:	01850513          	addi	a0,a0,24 # 800086f0 <syscalls+0x240>
    800046e0:	ffffc097          	auipc	ra,0xffffc
    800046e4:	e68080e7          	jalr	-408(ra) # 80000548 <panic>

00000000800046e8 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800046e8:	7139                	addi	sp,sp,-64
    800046ea:	fc06                	sd	ra,56(sp)
    800046ec:	f822                	sd	s0,48(sp)
    800046ee:	f426                	sd	s1,40(sp)
    800046f0:	f04a                	sd	s2,32(sp)
    800046f2:	ec4e                	sd	s3,24(sp)
    800046f4:	e852                	sd	s4,16(sp)
    800046f6:	e456                	sd	s5,8(sp)
    800046f8:	0080                	addi	s0,sp,64
    800046fa:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800046fc:	0001d517          	auipc	a0,0x1d
    80004700:	55450513          	addi	a0,a0,1364 # 80021c50 <ftable>
    80004704:	ffffc097          	auipc	ra,0xffffc
    80004708:	526080e7          	jalr	1318(ra) # 80000c2a <acquire>
  if(f->ref < 1)
    8000470c:	40dc                	lw	a5,4(s1)
    8000470e:	06f05163          	blez	a5,80004770 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004712:	37fd                	addiw	a5,a5,-1
    80004714:	0007871b          	sext.w	a4,a5
    80004718:	c0dc                	sw	a5,4(s1)
    8000471a:	06e04363          	bgtz	a4,80004780 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000471e:	0004a903          	lw	s2,0(s1)
    80004722:	0094ca83          	lbu	s5,9(s1)
    80004726:	0104ba03          	ld	s4,16(s1)
    8000472a:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000472e:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004732:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004736:	0001d517          	auipc	a0,0x1d
    8000473a:	51a50513          	addi	a0,a0,1306 # 80021c50 <ftable>
    8000473e:	ffffc097          	auipc	ra,0xffffc
    80004742:	5a0080e7          	jalr	1440(ra) # 80000cde <release>

  if(ff.type == FD_PIPE){
    80004746:	4785                	li	a5,1
    80004748:	04f90d63          	beq	s2,a5,800047a2 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000474c:	3979                	addiw	s2,s2,-2
    8000474e:	4785                	li	a5,1
    80004750:	0527e063          	bltu	a5,s2,80004790 <fileclose+0xa8>
    begin_op();
    80004754:	00000097          	auipc	ra,0x0
    80004758:	ac2080e7          	jalr	-1342(ra) # 80004216 <begin_op>
    iput(ff.ip);
    8000475c:	854e                	mv	a0,s3
    8000475e:	fffff097          	auipc	ra,0xfffff
    80004762:	2b6080e7          	jalr	694(ra) # 80003a14 <iput>
    end_op();
    80004766:	00000097          	auipc	ra,0x0
    8000476a:	b30080e7          	jalr	-1232(ra) # 80004296 <end_op>
    8000476e:	a00d                	j	80004790 <fileclose+0xa8>
    panic("fileclose");
    80004770:	00004517          	auipc	a0,0x4
    80004774:	f8850513          	addi	a0,a0,-120 # 800086f8 <syscalls+0x248>
    80004778:	ffffc097          	auipc	ra,0xffffc
    8000477c:	dd0080e7          	jalr	-560(ra) # 80000548 <panic>
    release(&ftable.lock);
    80004780:	0001d517          	auipc	a0,0x1d
    80004784:	4d050513          	addi	a0,a0,1232 # 80021c50 <ftable>
    80004788:	ffffc097          	auipc	ra,0xffffc
    8000478c:	556080e7          	jalr	1366(ra) # 80000cde <release>
  }
}
    80004790:	70e2                	ld	ra,56(sp)
    80004792:	7442                	ld	s0,48(sp)
    80004794:	74a2                	ld	s1,40(sp)
    80004796:	7902                	ld	s2,32(sp)
    80004798:	69e2                	ld	s3,24(sp)
    8000479a:	6a42                	ld	s4,16(sp)
    8000479c:	6aa2                	ld	s5,8(sp)
    8000479e:	6121                	addi	sp,sp,64
    800047a0:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800047a2:	85d6                	mv	a1,s5
    800047a4:	8552                	mv	a0,s4
    800047a6:	00000097          	auipc	ra,0x0
    800047aa:	372080e7          	jalr	882(ra) # 80004b18 <pipeclose>
    800047ae:	b7cd                	j	80004790 <fileclose+0xa8>

00000000800047b0 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800047b0:	715d                	addi	sp,sp,-80
    800047b2:	e486                	sd	ra,72(sp)
    800047b4:	e0a2                	sd	s0,64(sp)
    800047b6:	fc26                	sd	s1,56(sp)
    800047b8:	f84a                	sd	s2,48(sp)
    800047ba:	f44e                	sd	s3,40(sp)
    800047bc:	0880                	addi	s0,sp,80
    800047be:	84aa                	mv	s1,a0
    800047c0:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800047c2:	ffffd097          	auipc	ra,0xffffd
    800047c6:	350080e7          	jalr	848(ra) # 80001b12 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800047ca:	409c                	lw	a5,0(s1)
    800047cc:	37f9                	addiw	a5,a5,-2
    800047ce:	4705                	li	a4,1
    800047d0:	04f76763          	bltu	a4,a5,8000481e <filestat+0x6e>
    800047d4:	892a                	mv	s2,a0
    ilock(f->ip);
    800047d6:	6c88                	ld	a0,24(s1)
    800047d8:	fffff097          	auipc	ra,0xfffff
    800047dc:	082080e7          	jalr	130(ra) # 8000385a <ilock>
    stati(f->ip, &st);
    800047e0:	fb840593          	addi	a1,s0,-72
    800047e4:	6c88                	ld	a0,24(s1)
    800047e6:	fffff097          	auipc	ra,0xfffff
    800047ea:	2fe080e7          	jalr	766(ra) # 80003ae4 <stati>
    iunlock(f->ip);
    800047ee:	6c88                	ld	a0,24(s1)
    800047f0:	fffff097          	auipc	ra,0xfffff
    800047f4:	12c080e7          	jalr	300(ra) # 8000391c <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800047f8:	46e1                	li	a3,24
    800047fa:	fb840613          	addi	a2,s0,-72
    800047fe:	85ce                	mv	a1,s3
    80004800:	05093503          	ld	a0,80(s2)
    80004804:	ffffd097          	auipc	ra,0xffffd
    80004808:	080080e7          	jalr	128(ra) # 80001884 <copyout>
    8000480c:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004810:	60a6                	ld	ra,72(sp)
    80004812:	6406                	ld	s0,64(sp)
    80004814:	74e2                	ld	s1,56(sp)
    80004816:	7942                	ld	s2,48(sp)
    80004818:	79a2                	ld	s3,40(sp)
    8000481a:	6161                	addi	sp,sp,80
    8000481c:	8082                	ret
  return -1;
    8000481e:	557d                	li	a0,-1
    80004820:	bfc5                	j	80004810 <filestat+0x60>

0000000080004822 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004822:	7179                	addi	sp,sp,-48
    80004824:	f406                	sd	ra,40(sp)
    80004826:	f022                	sd	s0,32(sp)
    80004828:	ec26                	sd	s1,24(sp)
    8000482a:	e84a                	sd	s2,16(sp)
    8000482c:	e44e                	sd	s3,8(sp)
    8000482e:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004830:	00854783          	lbu	a5,8(a0)
    80004834:	c3d5                	beqz	a5,800048d8 <fileread+0xb6>
    80004836:	84aa                	mv	s1,a0
    80004838:	89ae                	mv	s3,a1
    8000483a:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000483c:	411c                	lw	a5,0(a0)
    8000483e:	4705                	li	a4,1
    80004840:	04e78963          	beq	a5,a4,80004892 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004844:	470d                	li	a4,3
    80004846:	04e78d63          	beq	a5,a4,800048a0 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000484a:	4709                	li	a4,2
    8000484c:	06e79e63          	bne	a5,a4,800048c8 <fileread+0xa6>
    ilock(f->ip);
    80004850:	6d08                	ld	a0,24(a0)
    80004852:	fffff097          	auipc	ra,0xfffff
    80004856:	008080e7          	jalr	8(ra) # 8000385a <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000485a:	874a                	mv	a4,s2
    8000485c:	5094                	lw	a3,32(s1)
    8000485e:	864e                	mv	a2,s3
    80004860:	4585                	li	a1,1
    80004862:	6c88                	ld	a0,24(s1)
    80004864:	fffff097          	auipc	ra,0xfffff
    80004868:	2aa080e7          	jalr	682(ra) # 80003b0e <readi>
    8000486c:	892a                	mv	s2,a0
    8000486e:	00a05563          	blez	a0,80004878 <fileread+0x56>
      f->off += r;
    80004872:	509c                	lw	a5,32(s1)
    80004874:	9fa9                	addw	a5,a5,a0
    80004876:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004878:	6c88                	ld	a0,24(s1)
    8000487a:	fffff097          	auipc	ra,0xfffff
    8000487e:	0a2080e7          	jalr	162(ra) # 8000391c <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004882:	854a                	mv	a0,s2
    80004884:	70a2                	ld	ra,40(sp)
    80004886:	7402                	ld	s0,32(sp)
    80004888:	64e2                	ld	s1,24(sp)
    8000488a:	6942                	ld	s2,16(sp)
    8000488c:	69a2                	ld	s3,8(sp)
    8000488e:	6145                	addi	sp,sp,48
    80004890:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004892:	6908                	ld	a0,16(a0)
    80004894:	00000097          	auipc	ra,0x0
    80004898:	418080e7          	jalr	1048(ra) # 80004cac <piperead>
    8000489c:	892a                	mv	s2,a0
    8000489e:	b7d5                	j	80004882 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800048a0:	02451783          	lh	a5,36(a0)
    800048a4:	03079693          	slli	a3,a5,0x30
    800048a8:	92c1                	srli	a3,a3,0x30
    800048aa:	4725                	li	a4,9
    800048ac:	02d76863          	bltu	a4,a3,800048dc <fileread+0xba>
    800048b0:	0792                	slli	a5,a5,0x4
    800048b2:	0001d717          	auipc	a4,0x1d
    800048b6:	2fe70713          	addi	a4,a4,766 # 80021bb0 <devsw>
    800048ba:	97ba                	add	a5,a5,a4
    800048bc:	639c                	ld	a5,0(a5)
    800048be:	c38d                	beqz	a5,800048e0 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800048c0:	4505                	li	a0,1
    800048c2:	9782                	jalr	a5
    800048c4:	892a                	mv	s2,a0
    800048c6:	bf75                	j	80004882 <fileread+0x60>
    panic("fileread");
    800048c8:	00004517          	auipc	a0,0x4
    800048cc:	e4050513          	addi	a0,a0,-448 # 80008708 <syscalls+0x258>
    800048d0:	ffffc097          	auipc	ra,0xffffc
    800048d4:	c78080e7          	jalr	-904(ra) # 80000548 <panic>
    return -1;
    800048d8:	597d                	li	s2,-1
    800048da:	b765                	j	80004882 <fileread+0x60>
      return -1;
    800048dc:	597d                	li	s2,-1
    800048de:	b755                	j	80004882 <fileread+0x60>
    800048e0:	597d                	li	s2,-1
    800048e2:	b745                	j	80004882 <fileread+0x60>

00000000800048e4 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800048e4:	00954783          	lbu	a5,9(a0)
    800048e8:	14078563          	beqz	a5,80004a32 <filewrite+0x14e>
{
    800048ec:	715d                	addi	sp,sp,-80
    800048ee:	e486                	sd	ra,72(sp)
    800048f0:	e0a2                	sd	s0,64(sp)
    800048f2:	fc26                	sd	s1,56(sp)
    800048f4:	f84a                	sd	s2,48(sp)
    800048f6:	f44e                	sd	s3,40(sp)
    800048f8:	f052                	sd	s4,32(sp)
    800048fa:	ec56                	sd	s5,24(sp)
    800048fc:	e85a                	sd	s6,16(sp)
    800048fe:	e45e                	sd	s7,8(sp)
    80004900:	e062                	sd	s8,0(sp)
    80004902:	0880                	addi	s0,sp,80
    80004904:	892a                	mv	s2,a0
    80004906:	8aae                	mv	s5,a1
    80004908:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000490a:	411c                	lw	a5,0(a0)
    8000490c:	4705                	li	a4,1
    8000490e:	02e78263          	beq	a5,a4,80004932 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004912:	470d                	li	a4,3
    80004914:	02e78563          	beq	a5,a4,8000493e <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004918:	4709                	li	a4,2
    8000491a:	10e79463          	bne	a5,a4,80004a22 <filewrite+0x13e>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000491e:	0ec05e63          	blez	a2,80004a1a <filewrite+0x136>
    int i = 0;
    80004922:	4981                	li	s3,0
    80004924:	6b05                	lui	s6,0x1
    80004926:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    8000492a:	6b85                	lui	s7,0x1
    8000492c:	c00b8b9b          	addiw	s7,s7,-1024
    80004930:	a851                	j	800049c4 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004932:	6908                	ld	a0,16(a0)
    80004934:	00000097          	auipc	ra,0x0
    80004938:	254080e7          	jalr	596(ra) # 80004b88 <pipewrite>
    8000493c:	a85d                	j	800049f2 <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000493e:	02451783          	lh	a5,36(a0)
    80004942:	03079693          	slli	a3,a5,0x30
    80004946:	92c1                	srli	a3,a3,0x30
    80004948:	4725                	li	a4,9
    8000494a:	0ed76663          	bltu	a4,a3,80004a36 <filewrite+0x152>
    8000494e:	0792                	slli	a5,a5,0x4
    80004950:	0001d717          	auipc	a4,0x1d
    80004954:	26070713          	addi	a4,a4,608 # 80021bb0 <devsw>
    80004958:	97ba                	add	a5,a5,a4
    8000495a:	679c                	ld	a5,8(a5)
    8000495c:	cff9                	beqz	a5,80004a3a <filewrite+0x156>
    ret = devsw[f->major].write(1, addr, n);
    8000495e:	4505                	li	a0,1
    80004960:	9782                	jalr	a5
    80004962:	a841                	j	800049f2 <filewrite+0x10e>
    80004964:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004968:	00000097          	auipc	ra,0x0
    8000496c:	8ae080e7          	jalr	-1874(ra) # 80004216 <begin_op>
      ilock(f->ip);
    80004970:	01893503          	ld	a0,24(s2)
    80004974:	fffff097          	auipc	ra,0xfffff
    80004978:	ee6080e7          	jalr	-282(ra) # 8000385a <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000497c:	8762                	mv	a4,s8
    8000497e:	02092683          	lw	a3,32(s2)
    80004982:	01598633          	add	a2,s3,s5
    80004986:	4585                	li	a1,1
    80004988:	01893503          	ld	a0,24(s2)
    8000498c:	fffff097          	auipc	ra,0xfffff
    80004990:	278080e7          	jalr	632(ra) # 80003c04 <writei>
    80004994:	84aa                	mv	s1,a0
    80004996:	02a05f63          	blez	a0,800049d4 <filewrite+0xf0>
        f->off += r;
    8000499a:	02092783          	lw	a5,32(s2)
    8000499e:	9fa9                	addw	a5,a5,a0
    800049a0:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800049a4:	01893503          	ld	a0,24(s2)
    800049a8:	fffff097          	auipc	ra,0xfffff
    800049ac:	f74080e7          	jalr	-140(ra) # 8000391c <iunlock>
      end_op();
    800049b0:	00000097          	auipc	ra,0x0
    800049b4:	8e6080e7          	jalr	-1818(ra) # 80004296 <end_op>

      if(r < 0)
        break;
      if(r != n1)
    800049b8:	049c1963          	bne	s8,s1,80004a0a <filewrite+0x126>
        panic("short filewrite");
      i += r;
    800049bc:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800049c0:	0349d663          	bge	s3,s4,800049ec <filewrite+0x108>
      int n1 = n - i;
    800049c4:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    800049c8:	84be                	mv	s1,a5
    800049ca:	2781                	sext.w	a5,a5
    800049cc:	f8fb5ce3          	bge	s6,a5,80004964 <filewrite+0x80>
    800049d0:	84de                	mv	s1,s7
    800049d2:	bf49                	j	80004964 <filewrite+0x80>
      iunlock(f->ip);
    800049d4:	01893503          	ld	a0,24(s2)
    800049d8:	fffff097          	auipc	ra,0xfffff
    800049dc:	f44080e7          	jalr	-188(ra) # 8000391c <iunlock>
      end_op();
    800049e0:	00000097          	auipc	ra,0x0
    800049e4:	8b6080e7          	jalr	-1866(ra) # 80004296 <end_op>
      if(r < 0)
    800049e8:	fc04d8e3          	bgez	s1,800049b8 <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    800049ec:	8552                	mv	a0,s4
    800049ee:	033a1863          	bne	s4,s3,80004a1e <filewrite+0x13a>
  } else {
    panic("filewrite");
  }

  return ret;
}
    800049f2:	60a6                	ld	ra,72(sp)
    800049f4:	6406                	ld	s0,64(sp)
    800049f6:	74e2                	ld	s1,56(sp)
    800049f8:	7942                	ld	s2,48(sp)
    800049fa:	79a2                	ld	s3,40(sp)
    800049fc:	7a02                	ld	s4,32(sp)
    800049fe:	6ae2                	ld	s5,24(sp)
    80004a00:	6b42                	ld	s6,16(sp)
    80004a02:	6ba2                	ld	s7,8(sp)
    80004a04:	6c02                	ld	s8,0(sp)
    80004a06:	6161                	addi	sp,sp,80
    80004a08:	8082                	ret
        panic("short filewrite");
    80004a0a:	00004517          	auipc	a0,0x4
    80004a0e:	d0e50513          	addi	a0,a0,-754 # 80008718 <syscalls+0x268>
    80004a12:	ffffc097          	auipc	ra,0xffffc
    80004a16:	b36080e7          	jalr	-1226(ra) # 80000548 <panic>
    int i = 0;
    80004a1a:	4981                	li	s3,0
    80004a1c:	bfc1                	j	800049ec <filewrite+0x108>
    ret = (i == n ? n : -1);
    80004a1e:	557d                	li	a0,-1
    80004a20:	bfc9                	j	800049f2 <filewrite+0x10e>
    panic("filewrite");
    80004a22:	00004517          	auipc	a0,0x4
    80004a26:	d0650513          	addi	a0,a0,-762 # 80008728 <syscalls+0x278>
    80004a2a:	ffffc097          	auipc	ra,0xffffc
    80004a2e:	b1e080e7          	jalr	-1250(ra) # 80000548 <panic>
    return -1;
    80004a32:	557d                	li	a0,-1
}
    80004a34:	8082                	ret
      return -1;
    80004a36:	557d                	li	a0,-1
    80004a38:	bf6d                	j	800049f2 <filewrite+0x10e>
    80004a3a:	557d                	li	a0,-1
    80004a3c:	bf5d                	j	800049f2 <filewrite+0x10e>

0000000080004a3e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004a3e:	7179                	addi	sp,sp,-48
    80004a40:	f406                	sd	ra,40(sp)
    80004a42:	f022                	sd	s0,32(sp)
    80004a44:	ec26                	sd	s1,24(sp)
    80004a46:	e84a                	sd	s2,16(sp)
    80004a48:	e44e                	sd	s3,8(sp)
    80004a4a:	e052                	sd	s4,0(sp)
    80004a4c:	1800                	addi	s0,sp,48
    80004a4e:	84aa                	mv	s1,a0
    80004a50:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004a52:	0005b023          	sd	zero,0(a1)
    80004a56:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004a5a:	00000097          	auipc	ra,0x0
    80004a5e:	bd2080e7          	jalr	-1070(ra) # 8000462c <filealloc>
    80004a62:	e088                	sd	a0,0(s1)
    80004a64:	c551                	beqz	a0,80004af0 <pipealloc+0xb2>
    80004a66:	00000097          	auipc	ra,0x0
    80004a6a:	bc6080e7          	jalr	-1082(ra) # 8000462c <filealloc>
    80004a6e:	00aa3023          	sd	a0,0(s4)
    80004a72:	c92d                	beqz	a0,80004ae4 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004a74:	ffffc097          	auipc	ra,0xffffc
    80004a78:	0c6080e7          	jalr	198(ra) # 80000b3a <kalloc>
    80004a7c:	892a                	mv	s2,a0
    80004a7e:	c125                	beqz	a0,80004ade <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004a80:	4985                	li	s3,1
    80004a82:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004a86:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004a8a:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004a8e:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004a92:	00004597          	auipc	a1,0x4
    80004a96:	ca658593          	addi	a1,a1,-858 # 80008738 <syscalls+0x288>
    80004a9a:	ffffc097          	auipc	ra,0xffffc
    80004a9e:	100080e7          	jalr	256(ra) # 80000b9a <initlock>
  (*f0)->type = FD_PIPE;
    80004aa2:	609c                	ld	a5,0(s1)
    80004aa4:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004aa8:	609c                	ld	a5,0(s1)
    80004aaa:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004aae:	609c                	ld	a5,0(s1)
    80004ab0:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004ab4:	609c                	ld	a5,0(s1)
    80004ab6:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004aba:	000a3783          	ld	a5,0(s4)
    80004abe:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004ac2:	000a3783          	ld	a5,0(s4)
    80004ac6:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004aca:	000a3783          	ld	a5,0(s4)
    80004ace:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004ad2:	000a3783          	ld	a5,0(s4)
    80004ad6:	0127b823          	sd	s2,16(a5)
  return 0;
    80004ada:	4501                	li	a0,0
    80004adc:	a025                	j	80004b04 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004ade:	6088                	ld	a0,0(s1)
    80004ae0:	e501                	bnez	a0,80004ae8 <pipealloc+0xaa>
    80004ae2:	a039                	j	80004af0 <pipealloc+0xb2>
    80004ae4:	6088                	ld	a0,0(s1)
    80004ae6:	c51d                	beqz	a0,80004b14 <pipealloc+0xd6>
    fileclose(*f0);
    80004ae8:	00000097          	auipc	ra,0x0
    80004aec:	c00080e7          	jalr	-1024(ra) # 800046e8 <fileclose>
  if(*f1)
    80004af0:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004af4:	557d                	li	a0,-1
  if(*f1)
    80004af6:	c799                	beqz	a5,80004b04 <pipealloc+0xc6>
    fileclose(*f1);
    80004af8:	853e                	mv	a0,a5
    80004afa:	00000097          	auipc	ra,0x0
    80004afe:	bee080e7          	jalr	-1042(ra) # 800046e8 <fileclose>
  return -1;
    80004b02:	557d                	li	a0,-1
}
    80004b04:	70a2                	ld	ra,40(sp)
    80004b06:	7402                	ld	s0,32(sp)
    80004b08:	64e2                	ld	s1,24(sp)
    80004b0a:	6942                	ld	s2,16(sp)
    80004b0c:	69a2                	ld	s3,8(sp)
    80004b0e:	6a02                	ld	s4,0(sp)
    80004b10:	6145                	addi	sp,sp,48
    80004b12:	8082                	ret
  return -1;
    80004b14:	557d                	li	a0,-1
    80004b16:	b7fd                	j	80004b04 <pipealloc+0xc6>

0000000080004b18 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004b18:	1101                	addi	sp,sp,-32
    80004b1a:	ec06                	sd	ra,24(sp)
    80004b1c:	e822                	sd	s0,16(sp)
    80004b1e:	e426                	sd	s1,8(sp)
    80004b20:	e04a                	sd	s2,0(sp)
    80004b22:	1000                	addi	s0,sp,32
    80004b24:	84aa                	mv	s1,a0
    80004b26:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004b28:	ffffc097          	auipc	ra,0xffffc
    80004b2c:	102080e7          	jalr	258(ra) # 80000c2a <acquire>
  if(writable){
    80004b30:	02090d63          	beqz	s2,80004b6a <pipeclose+0x52>
    pi->writeopen = 0;
    80004b34:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004b38:	21848513          	addi	a0,s1,536
    80004b3c:	ffffe097          	auipc	ra,0xffffe
    80004b40:	a84080e7          	jalr	-1404(ra) # 800025c0 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004b44:	2204b783          	ld	a5,544(s1)
    80004b48:	eb95                	bnez	a5,80004b7c <pipeclose+0x64>
    release(&pi->lock);
    80004b4a:	8526                	mv	a0,s1
    80004b4c:	ffffc097          	auipc	ra,0xffffc
    80004b50:	192080e7          	jalr	402(ra) # 80000cde <release>
    kfree((char*)pi);
    80004b54:	8526                	mv	a0,s1
    80004b56:	ffffc097          	auipc	ra,0xffffc
    80004b5a:	ece080e7          	jalr	-306(ra) # 80000a24 <kfree>
  } else
    release(&pi->lock);
}
    80004b5e:	60e2                	ld	ra,24(sp)
    80004b60:	6442                	ld	s0,16(sp)
    80004b62:	64a2                	ld	s1,8(sp)
    80004b64:	6902                	ld	s2,0(sp)
    80004b66:	6105                	addi	sp,sp,32
    80004b68:	8082                	ret
    pi->readopen = 0;
    80004b6a:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004b6e:	21c48513          	addi	a0,s1,540
    80004b72:	ffffe097          	auipc	ra,0xffffe
    80004b76:	a4e080e7          	jalr	-1458(ra) # 800025c0 <wakeup>
    80004b7a:	b7e9                	j	80004b44 <pipeclose+0x2c>
    release(&pi->lock);
    80004b7c:	8526                	mv	a0,s1
    80004b7e:	ffffc097          	auipc	ra,0xffffc
    80004b82:	160080e7          	jalr	352(ra) # 80000cde <release>
}
    80004b86:	bfe1                	j	80004b5e <pipeclose+0x46>

0000000080004b88 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004b88:	7119                	addi	sp,sp,-128
    80004b8a:	fc86                	sd	ra,120(sp)
    80004b8c:	f8a2                	sd	s0,112(sp)
    80004b8e:	f4a6                	sd	s1,104(sp)
    80004b90:	f0ca                	sd	s2,96(sp)
    80004b92:	ecce                	sd	s3,88(sp)
    80004b94:	e8d2                	sd	s4,80(sp)
    80004b96:	e4d6                	sd	s5,72(sp)
    80004b98:	e0da                	sd	s6,64(sp)
    80004b9a:	fc5e                	sd	s7,56(sp)
    80004b9c:	f862                	sd	s8,48(sp)
    80004b9e:	f466                	sd	s9,40(sp)
    80004ba0:	f06a                	sd	s10,32(sp)
    80004ba2:	ec6e                	sd	s11,24(sp)
    80004ba4:	0100                	addi	s0,sp,128
    80004ba6:	84aa                	mv	s1,a0
    80004ba8:	8cae                	mv	s9,a1
    80004baa:	8b32                	mv	s6,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004bac:	ffffd097          	auipc	ra,0xffffd
    80004bb0:	f66080e7          	jalr	-154(ra) # 80001b12 <myproc>
    80004bb4:	892a                	mv	s2,a0

  acquire(&pi->lock);
    80004bb6:	8526                	mv	a0,s1
    80004bb8:	ffffc097          	auipc	ra,0xffffc
    80004bbc:	072080e7          	jalr	114(ra) # 80000c2a <acquire>
  for(i = 0; i < n; i++){
    80004bc0:	0d605963          	blez	s6,80004c92 <pipewrite+0x10a>
    80004bc4:	89a6                	mv	s3,s1
    80004bc6:	3b7d                	addiw	s6,s6,-1
    80004bc8:	1b02                	slli	s6,s6,0x20
    80004bca:	020b5b13          	srli	s6,s6,0x20
    80004bce:	4b81                	li	s7,0
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || pr->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004bd0:	21848a93          	addi	s5,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004bd4:	21c48a13          	addi	s4,s1,540
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004bd8:	5dfd                	li	s11,-1
    80004bda:	000b8d1b          	sext.w	s10,s7
    80004bde:	8c6a                	mv	s8,s10
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004be0:	2184a783          	lw	a5,536(s1)
    80004be4:	21c4a703          	lw	a4,540(s1)
    80004be8:	2007879b          	addiw	a5,a5,512
    80004bec:	02f71b63          	bne	a4,a5,80004c22 <pipewrite+0x9a>
      if(pi->readopen == 0 || pr->killed){
    80004bf0:	2204a783          	lw	a5,544(s1)
    80004bf4:	cbad                	beqz	a5,80004c66 <pipewrite+0xde>
    80004bf6:	03092783          	lw	a5,48(s2)
    80004bfa:	e7b5                	bnez	a5,80004c66 <pipewrite+0xde>
      wakeup(&pi->nread);
    80004bfc:	8556                	mv	a0,s5
    80004bfe:	ffffe097          	auipc	ra,0xffffe
    80004c02:	9c2080e7          	jalr	-1598(ra) # 800025c0 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004c06:	85ce                	mv	a1,s3
    80004c08:	8552                	mv	a0,s4
    80004c0a:	ffffe097          	auipc	ra,0xffffe
    80004c0e:	830080e7          	jalr	-2000(ra) # 8000243a <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004c12:	2184a783          	lw	a5,536(s1)
    80004c16:	21c4a703          	lw	a4,540(s1)
    80004c1a:	2007879b          	addiw	a5,a5,512
    80004c1e:	fcf709e3          	beq	a4,a5,80004bf0 <pipewrite+0x68>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c22:	4685                	li	a3,1
    80004c24:	019b8633          	add	a2,s7,s9
    80004c28:	f8f40593          	addi	a1,s0,-113
    80004c2c:	05093503          	ld	a0,80(s2)
    80004c30:	ffffd097          	auipc	ra,0xffffd
    80004c34:	ce0080e7          	jalr	-800(ra) # 80001910 <copyin>
    80004c38:	05b50e63          	beq	a0,s11,80004c94 <pipewrite+0x10c>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004c3c:	21c4a783          	lw	a5,540(s1)
    80004c40:	0017871b          	addiw	a4,a5,1
    80004c44:	20e4ae23          	sw	a4,540(s1)
    80004c48:	1ff7f793          	andi	a5,a5,511
    80004c4c:	97a6                	add	a5,a5,s1
    80004c4e:	f8f44703          	lbu	a4,-113(s0)
    80004c52:	00e78c23          	sb	a4,24(a5)
  for(i = 0; i < n; i++){
    80004c56:	001d0c1b          	addiw	s8,s10,1
    80004c5a:	001b8793          	addi	a5,s7,1 # 1001 <_entry-0x7fffefff>
    80004c5e:	036b8b63          	beq	s7,s6,80004c94 <pipewrite+0x10c>
    80004c62:	8bbe                	mv	s7,a5
    80004c64:	bf9d                	j	80004bda <pipewrite+0x52>
        release(&pi->lock);
    80004c66:	8526                	mv	a0,s1
    80004c68:	ffffc097          	auipc	ra,0xffffc
    80004c6c:	076080e7          	jalr	118(ra) # 80000cde <release>
        return -1;
    80004c70:	5c7d                	li	s8,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);
  return i;
}
    80004c72:	8562                	mv	a0,s8
    80004c74:	70e6                	ld	ra,120(sp)
    80004c76:	7446                	ld	s0,112(sp)
    80004c78:	74a6                	ld	s1,104(sp)
    80004c7a:	7906                	ld	s2,96(sp)
    80004c7c:	69e6                	ld	s3,88(sp)
    80004c7e:	6a46                	ld	s4,80(sp)
    80004c80:	6aa6                	ld	s5,72(sp)
    80004c82:	6b06                	ld	s6,64(sp)
    80004c84:	7be2                	ld	s7,56(sp)
    80004c86:	7c42                	ld	s8,48(sp)
    80004c88:	7ca2                	ld	s9,40(sp)
    80004c8a:	7d02                	ld	s10,32(sp)
    80004c8c:	6de2                	ld	s11,24(sp)
    80004c8e:	6109                	addi	sp,sp,128
    80004c90:	8082                	ret
  for(i = 0; i < n; i++){
    80004c92:	4c01                	li	s8,0
  wakeup(&pi->nread);
    80004c94:	21848513          	addi	a0,s1,536
    80004c98:	ffffe097          	auipc	ra,0xffffe
    80004c9c:	928080e7          	jalr	-1752(ra) # 800025c0 <wakeup>
  release(&pi->lock);
    80004ca0:	8526                	mv	a0,s1
    80004ca2:	ffffc097          	auipc	ra,0xffffc
    80004ca6:	03c080e7          	jalr	60(ra) # 80000cde <release>
  return i;
    80004caa:	b7e1                	j	80004c72 <pipewrite+0xea>

0000000080004cac <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004cac:	715d                	addi	sp,sp,-80
    80004cae:	e486                	sd	ra,72(sp)
    80004cb0:	e0a2                	sd	s0,64(sp)
    80004cb2:	fc26                	sd	s1,56(sp)
    80004cb4:	f84a                	sd	s2,48(sp)
    80004cb6:	f44e                	sd	s3,40(sp)
    80004cb8:	f052                	sd	s4,32(sp)
    80004cba:	ec56                	sd	s5,24(sp)
    80004cbc:	e85a                	sd	s6,16(sp)
    80004cbe:	0880                	addi	s0,sp,80
    80004cc0:	84aa                	mv	s1,a0
    80004cc2:	892e                	mv	s2,a1
    80004cc4:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004cc6:	ffffd097          	auipc	ra,0xffffd
    80004cca:	e4c080e7          	jalr	-436(ra) # 80001b12 <myproc>
    80004cce:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004cd0:	8b26                	mv	s6,s1
    80004cd2:	8526                	mv	a0,s1
    80004cd4:	ffffc097          	auipc	ra,0xffffc
    80004cd8:	f56080e7          	jalr	-170(ra) # 80000c2a <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004cdc:	2184a703          	lw	a4,536(s1)
    80004ce0:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004ce4:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004ce8:	02f71463          	bne	a4,a5,80004d10 <piperead+0x64>
    80004cec:	2244a783          	lw	a5,548(s1)
    80004cf0:	c385                	beqz	a5,80004d10 <piperead+0x64>
    if(pr->killed){
    80004cf2:	030a2783          	lw	a5,48(s4)
    80004cf6:	ebc1                	bnez	a5,80004d86 <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004cf8:	85da                	mv	a1,s6
    80004cfa:	854e                	mv	a0,s3
    80004cfc:	ffffd097          	auipc	ra,0xffffd
    80004d00:	73e080e7          	jalr	1854(ra) # 8000243a <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d04:	2184a703          	lw	a4,536(s1)
    80004d08:	21c4a783          	lw	a5,540(s1)
    80004d0c:	fef700e3          	beq	a4,a5,80004cec <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d10:	09505263          	blez	s5,80004d94 <piperead+0xe8>
    80004d14:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d16:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80004d18:	2184a783          	lw	a5,536(s1)
    80004d1c:	21c4a703          	lw	a4,540(s1)
    80004d20:	02f70d63          	beq	a4,a5,80004d5a <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004d24:	0017871b          	addiw	a4,a5,1
    80004d28:	20e4ac23          	sw	a4,536(s1)
    80004d2c:	1ff7f793          	andi	a5,a5,511
    80004d30:	97a6                	add	a5,a5,s1
    80004d32:	0187c783          	lbu	a5,24(a5)
    80004d36:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d3a:	4685                	li	a3,1
    80004d3c:	fbf40613          	addi	a2,s0,-65
    80004d40:	85ca                	mv	a1,s2
    80004d42:	050a3503          	ld	a0,80(s4)
    80004d46:	ffffd097          	auipc	ra,0xffffd
    80004d4a:	b3e080e7          	jalr	-1218(ra) # 80001884 <copyout>
    80004d4e:	01650663          	beq	a0,s6,80004d5a <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d52:	2985                	addiw	s3,s3,1
    80004d54:	0905                	addi	s2,s2,1
    80004d56:	fd3a91e3          	bne	s5,s3,80004d18 <piperead+0x6c>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004d5a:	21c48513          	addi	a0,s1,540
    80004d5e:	ffffe097          	auipc	ra,0xffffe
    80004d62:	862080e7          	jalr	-1950(ra) # 800025c0 <wakeup>
  release(&pi->lock);
    80004d66:	8526                	mv	a0,s1
    80004d68:	ffffc097          	auipc	ra,0xffffc
    80004d6c:	f76080e7          	jalr	-138(ra) # 80000cde <release>
  return i;
}
    80004d70:	854e                	mv	a0,s3
    80004d72:	60a6                	ld	ra,72(sp)
    80004d74:	6406                	ld	s0,64(sp)
    80004d76:	74e2                	ld	s1,56(sp)
    80004d78:	7942                	ld	s2,48(sp)
    80004d7a:	79a2                	ld	s3,40(sp)
    80004d7c:	7a02                	ld	s4,32(sp)
    80004d7e:	6ae2                	ld	s5,24(sp)
    80004d80:	6b42                	ld	s6,16(sp)
    80004d82:	6161                	addi	sp,sp,80
    80004d84:	8082                	ret
      release(&pi->lock);
    80004d86:	8526                	mv	a0,s1
    80004d88:	ffffc097          	auipc	ra,0xffffc
    80004d8c:	f56080e7          	jalr	-170(ra) # 80000cde <release>
      return -1;
    80004d90:	59fd                	li	s3,-1
    80004d92:	bff9                	j	80004d70 <piperead+0xc4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d94:	4981                	li	s3,0
    80004d96:	b7d1                	j	80004d5a <piperead+0xae>

0000000080004d98 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004d98:	de010113          	addi	sp,sp,-544
    80004d9c:	20113c23          	sd	ra,536(sp)
    80004da0:	20813823          	sd	s0,528(sp)
    80004da4:	20913423          	sd	s1,520(sp)
    80004da8:	21213023          	sd	s2,512(sp)
    80004dac:	ffce                	sd	s3,504(sp)
    80004dae:	fbd2                	sd	s4,496(sp)
    80004db0:	f7d6                	sd	s5,488(sp)
    80004db2:	f3da                	sd	s6,480(sp)
    80004db4:	efde                	sd	s7,472(sp)
    80004db6:	ebe2                	sd	s8,464(sp)
    80004db8:	e7e6                	sd	s9,456(sp)
    80004dba:	e3ea                	sd	s10,448(sp)
    80004dbc:	ff6e                	sd	s11,440(sp)
    80004dbe:	1400                	addi	s0,sp,544
    80004dc0:	84aa                	mv	s1,a0
    80004dc2:	dea43823          	sd	a0,-528(s0)
    80004dc6:	deb43c23          	sd	a1,-520(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004dca:	ffffd097          	auipc	ra,0xffffd
    80004dce:	d48080e7          	jalr	-696(ra) # 80001b12 <myproc>
    80004dd2:	892a                	mv	s2,a0

  begin_op();
    80004dd4:	fffff097          	auipc	ra,0xfffff
    80004dd8:	442080e7          	jalr	1090(ra) # 80004216 <begin_op>

  if((ip = namei(path)) == 0){
    80004ddc:	8526                	mv	a0,s1
    80004dde:	fffff097          	auipc	ra,0xfffff
    80004de2:	22c080e7          	jalr	556(ra) # 8000400a <namei>
    80004de6:	c93d                	beqz	a0,80004e5c <exec+0xc4>
    80004de8:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004dea:	fffff097          	auipc	ra,0xfffff
    80004dee:	a70080e7          	jalr	-1424(ra) # 8000385a <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004df2:	04000713          	li	a4,64
    80004df6:	4681                	li	a3,0
    80004df8:	e4840613          	addi	a2,s0,-440
    80004dfc:	4581                	li	a1,0
    80004dfe:	8526                	mv	a0,s1
    80004e00:	fffff097          	auipc	ra,0xfffff
    80004e04:	d0e080e7          	jalr	-754(ra) # 80003b0e <readi>
    80004e08:	04000793          	li	a5,64
    80004e0c:	00f51a63          	bne	a0,a5,80004e20 <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004e10:	e4842703          	lw	a4,-440(s0)
    80004e14:	464c47b7          	lui	a5,0x464c4
    80004e18:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004e1c:	04f70663          	beq	a4,a5,80004e68 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004e20:	8526                	mv	a0,s1
    80004e22:	fffff097          	auipc	ra,0xfffff
    80004e26:	c9a080e7          	jalr	-870(ra) # 80003abc <iunlockput>
    end_op();
    80004e2a:	fffff097          	auipc	ra,0xfffff
    80004e2e:	46c080e7          	jalr	1132(ra) # 80004296 <end_op>
  }
  return -1;
    80004e32:	557d                	li	a0,-1
}
    80004e34:	21813083          	ld	ra,536(sp)
    80004e38:	21013403          	ld	s0,528(sp)
    80004e3c:	20813483          	ld	s1,520(sp)
    80004e40:	20013903          	ld	s2,512(sp)
    80004e44:	79fe                	ld	s3,504(sp)
    80004e46:	7a5e                	ld	s4,496(sp)
    80004e48:	7abe                	ld	s5,488(sp)
    80004e4a:	7b1e                	ld	s6,480(sp)
    80004e4c:	6bfe                	ld	s7,472(sp)
    80004e4e:	6c5e                	ld	s8,464(sp)
    80004e50:	6cbe                	ld	s9,456(sp)
    80004e52:	6d1e                	ld	s10,448(sp)
    80004e54:	7dfa                	ld	s11,440(sp)
    80004e56:	22010113          	addi	sp,sp,544
    80004e5a:	8082                	ret
    end_op();
    80004e5c:	fffff097          	auipc	ra,0xfffff
    80004e60:	43a080e7          	jalr	1082(ra) # 80004296 <end_op>
    return -1;
    80004e64:	557d                	li	a0,-1
    80004e66:	b7f9                	j	80004e34 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004e68:	854a                	mv	a0,s2
    80004e6a:	ffffd097          	auipc	ra,0xffffd
    80004e6e:	d6c080e7          	jalr	-660(ra) # 80001bd6 <proc_pagetable>
    80004e72:	e0a43423          	sd	a0,-504(s0)
    80004e76:	d54d                	beqz	a0,80004e20 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e78:	e6842983          	lw	s3,-408(s0)
    80004e7c:	e8045783          	lhu	a5,-384(s0)
    80004e80:	cbb5                	beqz	a5,80004ef4 <exec+0x15c>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004e82:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e84:	4b01                	li	s6,0
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004e86:	0c0007b7          	lui	a5,0xc000
    80004e8a:	17f9                	addi	a5,a5,-2
    80004e8c:	def43423          	sd	a5,-536(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004e90:	6b85                	lui	s7,0x1
    80004e92:	fffb8793          	addi	a5,s7,-1 # fff <_entry-0x7ffff001>
    80004e96:	def43023          	sd	a5,-544(s0)
    80004e9a:	a4bd                	j	80005108 <exec+0x370>
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004e9c:	00004517          	auipc	a0,0x4
    80004ea0:	8a450513          	addi	a0,a0,-1884 # 80008740 <syscalls+0x290>
    80004ea4:	ffffb097          	auipc	ra,0xffffb
    80004ea8:	6a4080e7          	jalr	1700(ra) # 80000548 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004eac:	8756                	mv	a4,s5
    80004eae:	012d06bb          	addw	a3,s10,s2
    80004eb2:	4581                	li	a1,0
    80004eb4:	8526                	mv	a0,s1
    80004eb6:	fffff097          	auipc	ra,0xfffff
    80004eba:	c58080e7          	jalr	-936(ra) # 80003b0e <readi>
    80004ebe:	2501                	sext.w	a0,a0
    80004ec0:	1eaa9a63          	bne	s5,a0,800050b4 <exec+0x31c>
  for(i = 0; i < sz; i += PGSIZE){
    80004ec4:	6785                	lui	a5,0x1
    80004ec6:	0127893b          	addw	s2,a5,s2
    80004eca:	014d8a3b          	addw	s4,s11,s4
    80004ece:	23897463          	bgeu	s2,s8,800050f6 <exec+0x35e>
    pa = walkaddr(pagetable, va + i);
    80004ed2:	02091593          	slli	a1,s2,0x20
    80004ed6:	9181                	srli	a1,a1,0x20
    80004ed8:	95e6                	add	a1,a1,s9
    80004eda:	e0843503          	ld	a0,-504(s0)
    80004ede:	ffffc097          	auipc	ra,0xffffc
    80004ee2:	1e2080e7          	jalr	482(ra) # 800010c0 <walkaddr>
    80004ee6:	862a                	mv	a2,a0
    if(pa == 0)
    80004ee8:	d955                	beqz	a0,80004e9c <exec+0x104>
      n = PGSIZE;
    80004eea:	8ade                	mv	s5,s7
    if(sz - i < PGSIZE)
    80004eec:	fd7a70e3          	bgeu	s4,s7,80004eac <exec+0x114>
      n = sz - i;
    80004ef0:	8ad2                	mv	s5,s4
    80004ef2:	bf6d                	j	80004eac <exec+0x114>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004ef4:	4901                	li	s2,0
  iunlockput(ip);
    80004ef6:	8526                	mv	a0,s1
    80004ef8:	fffff097          	auipc	ra,0xfffff
    80004efc:	bc4080e7          	jalr	-1084(ra) # 80003abc <iunlockput>
  end_op();
    80004f00:	fffff097          	auipc	ra,0xfffff
    80004f04:	396080e7          	jalr	918(ra) # 80004296 <end_op>
  p = myproc();
    80004f08:	ffffd097          	auipc	ra,0xffffd
    80004f0c:	c0a080e7          	jalr	-1014(ra) # 80001b12 <myproc>
    80004f10:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004f12:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004f16:	6785                	lui	a5,0x1
    80004f18:	17fd                	addi	a5,a5,-1
    80004f1a:	993e                	add	s2,s2,a5
    80004f1c:	757d                	lui	a0,0xfffff
    80004f1e:	00a977b3          	and	a5,s2,a0
    80004f22:	e0f43023          	sd	a5,-512(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004f26:	6609                	lui	a2,0x2
    80004f28:	963e                	add	a2,a2,a5
    80004f2a:	85be                	mv	a1,a5
    80004f2c:	e0843903          	ld	s2,-504(s0)
    80004f30:	854a                	mv	a0,s2
    80004f32:	ffffc097          	auipc	ra,0xffffc
    80004f36:	5ae080e7          	jalr	1454(ra) # 800014e0 <uvmalloc>
    80004f3a:	8b2a                	mv	s6,a0
  ip = 0;
    80004f3c:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004f3e:	16050b63          	beqz	a0,800050b4 <exec+0x31c>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004f42:	75f9                	lui	a1,0xffffe
    80004f44:	95aa                	add	a1,a1,a0
    80004f46:	854a                	mv	a0,s2
    80004f48:	ffffd097          	auipc	ra,0xffffd
    80004f4c:	90a080e7          	jalr	-1782(ra) # 80001852 <uvmclear>
  stackbase = sp - PGSIZE;
    80004f50:	7c7d                	lui	s8,0xfffff
    80004f52:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    80004f54:	df843783          	ld	a5,-520(s0)
    80004f58:	6388                	ld	a0,0(a5)
    80004f5a:	c53d                	beqz	a0,80004fc8 <exec+0x230>
    80004f5c:	e8840993          	addi	s3,s0,-376
    80004f60:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80004f64:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80004f66:	ffffc097          	auipc	ra,0xffffc
    80004f6a:	f48080e7          	jalr	-184(ra) # 80000eae <strlen>
    80004f6e:	2505                	addiw	a0,a0,1
    80004f70:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004f74:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004f78:	17896363          	bltu	s2,s8,800050de <exec+0x346>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004f7c:	df843b83          	ld	s7,-520(s0)
    80004f80:	000bba03          	ld	s4,0(s7)
    80004f84:	8552                	mv	a0,s4
    80004f86:	ffffc097          	auipc	ra,0xffffc
    80004f8a:	f28080e7          	jalr	-216(ra) # 80000eae <strlen>
    80004f8e:	0015069b          	addiw	a3,a0,1
    80004f92:	8652                	mv	a2,s4
    80004f94:	85ca                	mv	a1,s2
    80004f96:	e0843503          	ld	a0,-504(s0)
    80004f9a:	ffffd097          	auipc	ra,0xffffd
    80004f9e:	8ea080e7          	jalr	-1814(ra) # 80001884 <copyout>
    80004fa2:	14054263          	bltz	a0,800050e6 <exec+0x34e>
    ustack[argc] = sp;
    80004fa6:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004faa:	0485                	addi	s1,s1,1
    80004fac:	008b8793          	addi	a5,s7,8
    80004fb0:	def43c23          	sd	a5,-520(s0)
    80004fb4:	008bb503          	ld	a0,8(s7)
    80004fb8:	c911                	beqz	a0,80004fcc <exec+0x234>
    if(argc >= MAXARG)
    80004fba:	09a1                	addi	s3,s3,8
    80004fbc:	fb3c95e3          	bne	s9,s3,80004f66 <exec+0x1ce>
  sz = sz1;
    80004fc0:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    80004fc4:	4481                	li	s1,0
    80004fc6:	a0fd                	j	800050b4 <exec+0x31c>
  sp = sz;
    80004fc8:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80004fca:	4481                	li	s1,0
  ustack[argc] = 0;
    80004fcc:	00349793          	slli	a5,s1,0x3
    80004fd0:	f9040713          	addi	a4,s0,-112
    80004fd4:	97ba                	add	a5,a5,a4
    80004fd6:	ee07bc23          	sd	zero,-264(a5) # ef8 <_entry-0x7ffff108>
  sp -= (argc+1) * sizeof(uint64);
    80004fda:	00148693          	addi	a3,s1,1
    80004fde:	068e                	slli	a3,a3,0x3
    80004fe0:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004fe4:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004fe8:	01897663          	bgeu	s2,s8,80004ff4 <exec+0x25c>
  sz = sz1;
    80004fec:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    80004ff0:	4481                	li	s1,0
    80004ff2:	a0c9                	j	800050b4 <exec+0x31c>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004ff4:	e8840613          	addi	a2,s0,-376
    80004ff8:	85ca                	mv	a1,s2
    80004ffa:	e0843503          	ld	a0,-504(s0)
    80004ffe:	ffffd097          	auipc	ra,0xffffd
    80005002:	886080e7          	jalr	-1914(ra) # 80001884 <copyout>
    80005006:	0e054463          	bltz	a0,800050ee <exec+0x356>
  p->trapframe->a1 = sp;
    8000500a:	058ab783          	ld	a5,88(s5)
    8000500e:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005012:	df043783          	ld	a5,-528(s0)
    80005016:	0007c703          	lbu	a4,0(a5)
    8000501a:	cf11                	beqz	a4,80005036 <exec+0x29e>
    8000501c:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000501e:	02f00693          	li	a3,47
    80005022:	a039                	j	80005030 <exec+0x298>
      last = s+1;
    80005024:	def43823          	sd	a5,-528(s0)
  for(last=s=path; *s; s++)
    80005028:	0785                	addi	a5,a5,1
    8000502a:	fff7c703          	lbu	a4,-1(a5)
    8000502e:	c701                	beqz	a4,80005036 <exec+0x29e>
    if(*s == '/')
    80005030:	fed71ce3          	bne	a4,a3,80005028 <exec+0x290>
    80005034:	bfc5                	j	80005024 <exec+0x28c>
  safestrcpy(p->name, last, sizeof(p->name));
    80005036:	4641                	li	a2,16
    80005038:	df043583          	ld	a1,-528(s0)
    8000503c:	158a8513          	addi	a0,s5,344
    80005040:	ffffc097          	auipc	ra,0xffffc
    80005044:	e3c080e7          	jalr	-452(ra) # 80000e7c <safestrcpy>
  uvmunmap(p->kernelpgtbl, 0, PGROUNDUP(oldsz)/PGSIZE, 0);
    80005048:	6605                	lui	a2,0x1
    8000504a:	167d                	addi	a2,a2,-1
    8000504c:	966a                	add	a2,a2,s10
    8000504e:	4681                	li	a3,0
    80005050:	8231                	srli	a2,a2,0xc
    80005052:	4581                	li	a1,0
    80005054:	168ab503          	ld	a0,360(s5)
    80005058:	ffffc097          	auipc	ra,0xffffc
    8000505c:	2dc080e7          	jalr	732(ra) # 80001334 <uvmunmap>
  kvmcopymappings(pagetable, p->kernelpgtbl, 0, sz);
    80005060:	86da                	mv	a3,s6
    80005062:	4601                	li	a2,0
    80005064:	168ab583          	ld	a1,360(s5)
    80005068:	e0843983          	ld	s3,-504(s0)
    8000506c:	854e                	mv	a0,s3
    8000506e:	ffffc097          	auipc	ra,0xffffc
    80005072:	730080e7          	jalr	1840(ra) # 8000179e <kvmcopymappings>
  oldpagetable = p->pagetable;
    80005076:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    8000507a:	053ab823          	sd	s3,80(s5)
  p->sz = sz;
    8000507e:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005082:	058ab783          	ld	a5,88(s5)
    80005086:	e6043703          	ld	a4,-416(s0)
    8000508a:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000508c:	058ab783          	ld	a5,88(s5)
    80005090:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005094:	85ea                	mv	a1,s10
    80005096:	ffffd097          	auipc	ra,0xffffd
    8000509a:	bdc080e7          	jalr	-1060(ra) # 80001c72 <proc_freepagetable>
  vmprint(p->pagetable);
    8000509e:	050ab503          	ld	a0,80(s5)
    800050a2:	ffffd097          	auipc	ra,0xffffd
    800050a6:	964080e7          	jalr	-1692(ra) # 80001a06 <vmprint>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800050aa:	0004851b          	sext.w	a0,s1
    800050ae:	b359                	j	80004e34 <exec+0x9c>
    800050b0:	e1243023          	sd	s2,-512(s0)
    proc_freepagetable(pagetable, sz);
    800050b4:	e0043583          	ld	a1,-512(s0)
    800050b8:	e0843503          	ld	a0,-504(s0)
    800050bc:	ffffd097          	auipc	ra,0xffffd
    800050c0:	bb6080e7          	jalr	-1098(ra) # 80001c72 <proc_freepagetable>
  if(ip){
    800050c4:	d4049ee3          	bnez	s1,80004e20 <exec+0x88>
  return -1;
    800050c8:	557d                	li	a0,-1
    800050ca:	b3ad                	j	80004e34 <exec+0x9c>
    800050cc:	e1243023          	sd	s2,-512(s0)
    800050d0:	b7d5                	j	800050b4 <exec+0x31c>
    800050d2:	e1243023          	sd	s2,-512(s0)
    800050d6:	bff9                	j	800050b4 <exec+0x31c>
    800050d8:	e1243023          	sd	s2,-512(s0)
    800050dc:	bfe1                	j	800050b4 <exec+0x31c>
  sz = sz1;
    800050de:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    800050e2:	4481                	li	s1,0
    800050e4:	bfc1                	j	800050b4 <exec+0x31c>
  sz = sz1;
    800050e6:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    800050ea:	4481                	li	s1,0
    800050ec:	b7e1                	j	800050b4 <exec+0x31c>
  sz = sz1;
    800050ee:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    800050f2:	4481                	li	s1,0
    800050f4:	b7c1                	j	800050b4 <exec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800050f6:	e0043903          	ld	s2,-512(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800050fa:	2b05                	addiw	s6,s6,1
    800050fc:	0389899b          	addiw	s3,s3,56
    80005100:	e8045783          	lhu	a5,-384(s0)
    80005104:	defb59e3          	bge	s6,a5,80004ef6 <exec+0x15e>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005108:	2981                	sext.w	s3,s3
    8000510a:	03800713          	li	a4,56
    8000510e:	86ce                	mv	a3,s3
    80005110:	e1040613          	addi	a2,s0,-496
    80005114:	4581                	li	a1,0
    80005116:	8526                	mv	a0,s1
    80005118:	fffff097          	auipc	ra,0xfffff
    8000511c:	9f6080e7          	jalr	-1546(ra) # 80003b0e <readi>
    80005120:	03800793          	li	a5,56
    80005124:	f8f516e3          	bne	a0,a5,800050b0 <exec+0x318>
    if(ph.type != ELF_PROG_LOAD)
    80005128:	e1042783          	lw	a5,-496(s0)
    8000512c:	4705                	li	a4,1
    8000512e:	fce796e3          	bne	a5,a4,800050fa <exec+0x362>
    if(ph.memsz < ph.filesz)
    80005132:	e3843603          	ld	a2,-456(s0)
    80005136:	e3043783          	ld	a5,-464(s0)
    8000513a:	f8f669e3          	bltu	a2,a5,800050cc <exec+0x334>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000513e:	e2043783          	ld	a5,-480(s0)
    80005142:	963e                	add	a2,a2,a5
    80005144:	f8f667e3          	bltu	a2,a5,800050d2 <exec+0x33a>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005148:	85ca                	mv	a1,s2
    8000514a:	e0843503          	ld	a0,-504(s0)
    8000514e:	ffffc097          	auipc	ra,0xffffc
    80005152:	392080e7          	jalr	914(ra) # 800014e0 <uvmalloc>
    80005156:	e0a43023          	sd	a0,-512(s0)
    8000515a:	fff50793          	addi	a5,a0,-1 # ffffffffffffefff <end+0xffffffff7ffd7fdf>
    8000515e:	de843703          	ld	a4,-536(s0)
    80005162:	f6f76be3          	bltu	a4,a5,800050d8 <exec+0x340>
    if(ph.vaddr % PGSIZE != 0)
    80005166:	e2043c83          	ld	s9,-480(s0)
    8000516a:	de043783          	ld	a5,-544(s0)
    8000516e:	00fcf7b3          	and	a5,s9,a5
    80005172:	f3a9                	bnez	a5,800050b4 <exec+0x31c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005174:	e1842d03          	lw	s10,-488(s0)
    80005178:	e3042c03          	lw	s8,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000517c:	f60c0de3          	beqz	s8,800050f6 <exec+0x35e>
    80005180:	8a62                	mv	s4,s8
    80005182:	4901                	li	s2,0
    80005184:	7dfd                	lui	s11,0xfffff
    80005186:	b3b1                	j	80004ed2 <exec+0x13a>

0000000080005188 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005188:	7179                	addi	sp,sp,-48
    8000518a:	f406                	sd	ra,40(sp)
    8000518c:	f022                	sd	s0,32(sp)
    8000518e:	ec26                	sd	s1,24(sp)
    80005190:	e84a                	sd	s2,16(sp)
    80005192:	1800                	addi	s0,sp,48
    80005194:	892e                	mv	s2,a1
    80005196:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005198:	fdc40593          	addi	a1,s0,-36
    8000519c:	ffffe097          	auipc	ra,0xffffe
    800051a0:	b4c080e7          	jalr	-1204(ra) # 80002ce8 <argint>
    800051a4:	04054063          	bltz	a0,800051e4 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800051a8:	fdc42703          	lw	a4,-36(s0)
    800051ac:	47bd                	li	a5,15
    800051ae:	02e7ed63          	bltu	a5,a4,800051e8 <argfd+0x60>
    800051b2:	ffffd097          	auipc	ra,0xffffd
    800051b6:	960080e7          	jalr	-1696(ra) # 80001b12 <myproc>
    800051ba:	fdc42703          	lw	a4,-36(s0)
    800051be:	01a70793          	addi	a5,a4,26
    800051c2:	078e                	slli	a5,a5,0x3
    800051c4:	953e                	add	a0,a0,a5
    800051c6:	611c                	ld	a5,0(a0)
    800051c8:	c395                	beqz	a5,800051ec <argfd+0x64>
    return -1;
  if(pfd)
    800051ca:	00090463          	beqz	s2,800051d2 <argfd+0x4a>
    *pfd = fd;
    800051ce:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800051d2:	4501                	li	a0,0
  if(pf)
    800051d4:	c091                	beqz	s1,800051d8 <argfd+0x50>
    *pf = f;
    800051d6:	e09c                	sd	a5,0(s1)
}
    800051d8:	70a2                	ld	ra,40(sp)
    800051da:	7402                	ld	s0,32(sp)
    800051dc:	64e2                	ld	s1,24(sp)
    800051de:	6942                	ld	s2,16(sp)
    800051e0:	6145                	addi	sp,sp,48
    800051e2:	8082                	ret
    return -1;
    800051e4:	557d                	li	a0,-1
    800051e6:	bfcd                	j	800051d8 <argfd+0x50>
    return -1;
    800051e8:	557d                	li	a0,-1
    800051ea:	b7fd                	j	800051d8 <argfd+0x50>
    800051ec:	557d                	li	a0,-1
    800051ee:	b7ed                	j	800051d8 <argfd+0x50>

00000000800051f0 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800051f0:	1101                	addi	sp,sp,-32
    800051f2:	ec06                	sd	ra,24(sp)
    800051f4:	e822                	sd	s0,16(sp)
    800051f6:	e426                	sd	s1,8(sp)
    800051f8:	1000                	addi	s0,sp,32
    800051fa:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800051fc:	ffffd097          	auipc	ra,0xffffd
    80005200:	916080e7          	jalr	-1770(ra) # 80001b12 <myproc>
    80005204:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005206:	0d050793          	addi	a5,a0,208
    8000520a:	4501                	li	a0,0
    8000520c:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000520e:	6398                	ld	a4,0(a5)
    80005210:	cb19                	beqz	a4,80005226 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005212:	2505                	addiw	a0,a0,1
    80005214:	07a1                	addi	a5,a5,8
    80005216:	fed51ce3          	bne	a0,a3,8000520e <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000521a:	557d                	li	a0,-1
}
    8000521c:	60e2                	ld	ra,24(sp)
    8000521e:	6442                	ld	s0,16(sp)
    80005220:	64a2                	ld	s1,8(sp)
    80005222:	6105                	addi	sp,sp,32
    80005224:	8082                	ret
      p->ofile[fd] = f;
    80005226:	01a50793          	addi	a5,a0,26
    8000522a:	078e                	slli	a5,a5,0x3
    8000522c:	963e                	add	a2,a2,a5
    8000522e:	e204                	sd	s1,0(a2)
      return fd;
    80005230:	b7f5                	j	8000521c <fdalloc+0x2c>

0000000080005232 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005232:	715d                	addi	sp,sp,-80
    80005234:	e486                	sd	ra,72(sp)
    80005236:	e0a2                	sd	s0,64(sp)
    80005238:	fc26                	sd	s1,56(sp)
    8000523a:	f84a                	sd	s2,48(sp)
    8000523c:	f44e                	sd	s3,40(sp)
    8000523e:	f052                	sd	s4,32(sp)
    80005240:	ec56                	sd	s5,24(sp)
    80005242:	0880                	addi	s0,sp,80
    80005244:	89ae                	mv	s3,a1
    80005246:	8ab2                	mv	s5,a2
    80005248:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000524a:	fb040593          	addi	a1,s0,-80
    8000524e:	fffff097          	auipc	ra,0xfffff
    80005252:	dda080e7          	jalr	-550(ra) # 80004028 <nameiparent>
    80005256:	892a                	mv	s2,a0
    80005258:	12050f63          	beqz	a0,80005396 <create+0x164>
    return 0;

  ilock(dp);
    8000525c:	ffffe097          	auipc	ra,0xffffe
    80005260:	5fe080e7          	jalr	1534(ra) # 8000385a <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005264:	4601                	li	a2,0
    80005266:	fb040593          	addi	a1,s0,-80
    8000526a:	854a                	mv	a0,s2
    8000526c:	fffff097          	auipc	ra,0xfffff
    80005270:	acc080e7          	jalr	-1332(ra) # 80003d38 <dirlookup>
    80005274:	84aa                	mv	s1,a0
    80005276:	c921                	beqz	a0,800052c6 <create+0x94>
    iunlockput(dp);
    80005278:	854a                	mv	a0,s2
    8000527a:	fffff097          	auipc	ra,0xfffff
    8000527e:	842080e7          	jalr	-1982(ra) # 80003abc <iunlockput>
    ilock(ip);
    80005282:	8526                	mv	a0,s1
    80005284:	ffffe097          	auipc	ra,0xffffe
    80005288:	5d6080e7          	jalr	1494(ra) # 8000385a <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000528c:	2981                	sext.w	s3,s3
    8000528e:	4789                	li	a5,2
    80005290:	02f99463          	bne	s3,a5,800052b8 <create+0x86>
    80005294:	0444d783          	lhu	a5,68(s1)
    80005298:	37f9                	addiw	a5,a5,-2
    8000529a:	17c2                	slli	a5,a5,0x30
    8000529c:	93c1                	srli	a5,a5,0x30
    8000529e:	4705                	li	a4,1
    800052a0:	00f76c63          	bltu	a4,a5,800052b8 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800052a4:	8526                	mv	a0,s1
    800052a6:	60a6                	ld	ra,72(sp)
    800052a8:	6406                	ld	s0,64(sp)
    800052aa:	74e2                	ld	s1,56(sp)
    800052ac:	7942                	ld	s2,48(sp)
    800052ae:	79a2                	ld	s3,40(sp)
    800052b0:	7a02                	ld	s4,32(sp)
    800052b2:	6ae2                	ld	s5,24(sp)
    800052b4:	6161                	addi	sp,sp,80
    800052b6:	8082                	ret
    iunlockput(ip);
    800052b8:	8526                	mv	a0,s1
    800052ba:	fffff097          	auipc	ra,0xfffff
    800052be:	802080e7          	jalr	-2046(ra) # 80003abc <iunlockput>
    return 0;
    800052c2:	4481                	li	s1,0
    800052c4:	b7c5                	j	800052a4 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800052c6:	85ce                	mv	a1,s3
    800052c8:	00092503          	lw	a0,0(s2)
    800052cc:	ffffe097          	auipc	ra,0xffffe
    800052d0:	3f6080e7          	jalr	1014(ra) # 800036c2 <ialloc>
    800052d4:	84aa                	mv	s1,a0
    800052d6:	c529                	beqz	a0,80005320 <create+0xee>
  ilock(ip);
    800052d8:	ffffe097          	auipc	ra,0xffffe
    800052dc:	582080e7          	jalr	1410(ra) # 8000385a <ilock>
  ip->major = major;
    800052e0:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    800052e4:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    800052e8:	4785                	li	a5,1
    800052ea:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800052ee:	8526                	mv	a0,s1
    800052f0:	ffffe097          	auipc	ra,0xffffe
    800052f4:	4a0080e7          	jalr	1184(ra) # 80003790 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800052f8:	2981                	sext.w	s3,s3
    800052fa:	4785                	li	a5,1
    800052fc:	02f98a63          	beq	s3,a5,80005330 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    80005300:	40d0                	lw	a2,4(s1)
    80005302:	fb040593          	addi	a1,s0,-80
    80005306:	854a                	mv	a0,s2
    80005308:	fffff097          	auipc	ra,0xfffff
    8000530c:	c40080e7          	jalr	-960(ra) # 80003f48 <dirlink>
    80005310:	06054b63          	bltz	a0,80005386 <create+0x154>
  iunlockput(dp);
    80005314:	854a                	mv	a0,s2
    80005316:	ffffe097          	auipc	ra,0xffffe
    8000531a:	7a6080e7          	jalr	1958(ra) # 80003abc <iunlockput>
  return ip;
    8000531e:	b759                	j	800052a4 <create+0x72>
    panic("create: ialloc");
    80005320:	00003517          	auipc	a0,0x3
    80005324:	44050513          	addi	a0,a0,1088 # 80008760 <syscalls+0x2b0>
    80005328:	ffffb097          	auipc	ra,0xffffb
    8000532c:	220080e7          	jalr	544(ra) # 80000548 <panic>
    dp->nlink++;  // for ".."
    80005330:	04a95783          	lhu	a5,74(s2)
    80005334:	2785                	addiw	a5,a5,1
    80005336:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    8000533a:	854a                	mv	a0,s2
    8000533c:	ffffe097          	auipc	ra,0xffffe
    80005340:	454080e7          	jalr	1108(ra) # 80003790 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005344:	40d0                	lw	a2,4(s1)
    80005346:	00003597          	auipc	a1,0x3
    8000534a:	42a58593          	addi	a1,a1,1066 # 80008770 <syscalls+0x2c0>
    8000534e:	8526                	mv	a0,s1
    80005350:	fffff097          	auipc	ra,0xfffff
    80005354:	bf8080e7          	jalr	-1032(ra) # 80003f48 <dirlink>
    80005358:	00054f63          	bltz	a0,80005376 <create+0x144>
    8000535c:	00492603          	lw	a2,4(s2)
    80005360:	00003597          	auipc	a1,0x3
    80005364:	eb858593          	addi	a1,a1,-328 # 80008218 <digits+0x1e8>
    80005368:	8526                	mv	a0,s1
    8000536a:	fffff097          	auipc	ra,0xfffff
    8000536e:	bde080e7          	jalr	-1058(ra) # 80003f48 <dirlink>
    80005372:	f80557e3          	bgez	a0,80005300 <create+0xce>
      panic("create dots");
    80005376:	00003517          	auipc	a0,0x3
    8000537a:	40250513          	addi	a0,a0,1026 # 80008778 <syscalls+0x2c8>
    8000537e:	ffffb097          	auipc	ra,0xffffb
    80005382:	1ca080e7          	jalr	458(ra) # 80000548 <panic>
    panic("create: dirlink");
    80005386:	00003517          	auipc	a0,0x3
    8000538a:	40250513          	addi	a0,a0,1026 # 80008788 <syscalls+0x2d8>
    8000538e:	ffffb097          	auipc	ra,0xffffb
    80005392:	1ba080e7          	jalr	442(ra) # 80000548 <panic>
    return 0;
    80005396:	84aa                	mv	s1,a0
    80005398:	b731                	j	800052a4 <create+0x72>

000000008000539a <sys_dup>:
{
    8000539a:	7179                	addi	sp,sp,-48
    8000539c:	f406                	sd	ra,40(sp)
    8000539e:	f022                	sd	s0,32(sp)
    800053a0:	ec26                	sd	s1,24(sp)
    800053a2:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800053a4:	fd840613          	addi	a2,s0,-40
    800053a8:	4581                	li	a1,0
    800053aa:	4501                	li	a0,0
    800053ac:	00000097          	auipc	ra,0x0
    800053b0:	ddc080e7          	jalr	-548(ra) # 80005188 <argfd>
    return -1;
    800053b4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800053b6:	02054363          	bltz	a0,800053dc <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800053ba:	fd843503          	ld	a0,-40(s0)
    800053be:	00000097          	auipc	ra,0x0
    800053c2:	e32080e7          	jalr	-462(ra) # 800051f0 <fdalloc>
    800053c6:	84aa                	mv	s1,a0
    return -1;
    800053c8:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800053ca:	00054963          	bltz	a0,800053dc <sys_dup+0x42>
  filedup(f);
    800053ce:	fd843503          	ld	a0,-40(s0)
    800053d2:	fffff097          	auipc	ra,0xfffff
    800053d6:	2c4080e7          	jalr	708(ra) # 80004696 <filedup>
  return fd;
    800053da:	87a6                	mv	a5,s1
}
    800053dc:	853e                	mv	a0,a5
    800053de:	70a2                	ld	ra,40(sp)
    800053e0:	7402                	ld	s0,32(sp)
    800053e2:	64e2                	ld	s1,24(sp)
    800053e4:	6145                	addi	sp,sp,48
    800053e6:	8082                	ret

00000000800053e8 <sys_read>:
{
    800053e8:	7179                	addi	sp,sp,-48
    800053ea:	f406                	sd	ra,40(sp)
    800053ec:	f022                	sd	s0,32(sp)
    800053ee:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800053f0:	fe840613          	addi	a2,s0,-24
    800053f4:	4581                	li	a1,0
    800053f6:	4501                	li	a0,0
    800053f8:	00000097          	auipc	ra,0x0
    800053fc:	d90080e7          	jalr	-624(ra) # 80005188 <argfd>
    return -1;
    80005400:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005402:	04054163          	bltz	a0,80005444 <sys_read+0x5c>
    80005406:	fe440593          	addi	a1,s0,-28
    8000540a:	4509                	li	a0,2
    8000540c:	ffffe097          	auipc	ra,0xffffe
    80005410:	8dc080e7          	jalr	-1828(ra) # 80002ce8 <argint>
    return -1;
    80005414:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005416:	02054763          	bltz	a0,80005444 <sys_read+0x5c>
    8000541a:	fd840593          	addi	a1,s0,-40
    8000541e:	4505                	li	a0,1
    80005420:	ffffe097          	auipc	ra,0xffffe
    80005424:	8ea080e7          	jalr	-1814(ra) # 80002d0a <argaddr>
    return -1;
    80005428:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000542a:	00054d63          	bltz	a0,80005444 <sys_read+0x5c>
  return fileread(f, p, n);
    8000542e:	fe442603          	lw	a2,-28(s0)
    80005432:	fd843583          	ld	a1,-40(s0)
    80005436:	fe843503          	ld	a0,-24(s0)
    8000543a:	fffff097          	auipc	ra,0xfffff
    8000543e:	3e8080e7          	jalr	1000(ra) # 80004822 <fileread>
    80005442:	87aa                	mv	a5,a0
}
    80005444:	853e                	mv	a0,a5
    80005446:	70a2                	ld	ra,40(sp)
    80005448:	7402                	ld	s0,32(sp)
    8000544a:	6145                	addi	sp,sp,48
    8000544c:	8082                	ret

000000008000544e <sys_write>:
{
    8000544e:	7179                	addi	sp,sp,-48
    80005450:	f406                	sd	ra,40(sp)
    80005452:	f022                	sd	s0,32(sp)
    80005454:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005456:	fe840613          	addi	a2,s0,-24
    8000545a:	4581                	li	a1,0
    8000545c:	4501                	li	a0,0
    8000545e:	00000097          	auipc	ra,0x0
    80005462:	d2a080e7          	jalr	-726(ra) # 80005188 <argfd>
    return -1;
    80005466:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005468:	04054163          	bltz	a0,800054aa <sys_write+0x5c>
    8000546c:	fe440593          	addi	a1,s0,-28
    80005470:	4509                	li	a0,2
    80005472:	ffffe097          	auipc	ra,0xffffe
    80005476:	876080e7          	jalr	-1930(ra) # 80002ce8 <argint>
    return -1;
    8000547a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000547c:	02054763          	bltz	a0,800054aa <sys_write+0x5c>
    80005480:	fd840593          	addi	a1,s0,-40
    80005484:	4505                	li	a0,1
    80005486:	ffffe097          	auipc	ra,0xffffe
    8000548a:	884080e7          	jalr	-1916(ra) # 80002d0a <argaddr>
    return -1;
    8000548e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005490:	00054d63          	bltz	a0,800054aa <sys_write+0x5c>
  return filewrite(f, p, n);
    80005494:	fe442603          	lw	a2,-28(s0)
    80005498:	fd843583          	ld	a1,-40(s0)
    8000549c:	fe843503          	ld	a0,-24(s0)
    800054a0:	fffff097          	auipc	ra,0xfffff
    800054a4:	444080e7          	jalr	1092(ra) # 800048e4 <filewrite>
    800054a8:	87aa                	mv	a5,a0
}
    800054aa:	853e                	mv	a0,a5
    800054ac:	70a2                	ld	ra,40(sp)
    800054ae:	7402                	ld	s0,32(sp)
    800054b0:	6145                	addi	sp,sp,48
    800054b2:	8082                	ret

00000000800054b4 <sys_close>:
{
    800054b4:	1101                	addi	sp,sp,-32
    800054b6:	ec06                	sd	ra,24(sp)
    800054b8:	e822                	sd	s0,16(sp)
    800054ba:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800054bc:	fe040613          	addi	a2,s0,-32
    800054c0:	fec40593          	addi	a1,s0,-20
    800054c4:	4501                	li	a0,0
    800054c6:	00000097          	auipc	ra,0x0
    800054ca:	cc2080e7          	jalr	-830(ra) # 80005188 <argfd>
    return -1;
    800054ce:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800054d0:	02054463          	bltz	a0,800054f8 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800054d4:	ffffc097          	auipc	ra,0xffffc
    800054d8:	63e080e7          	jalr	1598(ra) # 80001b12 <myproc>
    800054dc:	fec42783          	lw	a5,-20(s0)
    800054e0:	07e9                	addi	a5,a5,26
    800054e2:	078e                	slli	a5,a5,0x3
    800054e4:	97aa                	add	a5,a5,a0
    800054e6:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800054ea:	fe043503          	ld	a0,-32(s0)
    800054ee:	fffff097          	auipc	ra,0xfffff
    800054f2:	1fa080e7          	jalr	506(ra) # 800046e8 <fileclose>
  return 0;
    800054f6:	4781                	li	a5,0
}
    800054f8:	853e                	mv	a0,a5
    800054fa:	60e2                	ld	ra,24(sp)
    800054fc:	6442                	ld	s0,16(sp)
    800054fe:	6105                	addi	sp,sp,32
    80005500:	8082                	ret

0000000080005502 <sys_fstat>:
{
    80005502:	1101                	addi	sp,sp,-32
    80005504:	ec06                	sd	ra,24(sp)
    80005506:	e822                	sd	s0,16(sp)
    80005508:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000550a:	fe840613          	addi	a2,s0,-24
    8000550e:	4581                	li	a1,0
    80005510:	4501                	li	a0,0
    80005512:	00000097          	auipc	ra,0x0
    80005516:	c76080e7          	jalr	-906(ra) # 80005188 <argfd>
    return -1;
    8000551a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000551c:	02054563          	bltz	a0,80005546 <sys_fstat+0x44>
    80005520:	fe040593          	addi	a1,s0,-32
    80005524:	4505                	li	a0,1
    80005526:	ffffd097          	auipc	ra,0xffffd
    8000552a:	7e4080e7          	jalr	2020(ra) # 80002d0a <argaddr>
    return -1;
    8000552e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005530:	00054b63          	bltz	a0,80005546 <sys_fstat+0x44>
  return filestat(f, st);
    80005534:	fe043583          	ld	a1,-32(s0)
    80005538:	fe843503          	ld	a0,-24(s0)
    8000553c:	fffff097          	auipc	ra,0xfffff
    80005540:	274080e7          	jalr	628(ra) # 800047b0 <filestat>
    80005544:	87aa                	mv	a5,a0
}
    80005546:	853e                	mv	a0,a5
    80005548:	60e2                	ld	ra,24(sp)
    8000554a:	6442                	ld	s0,16(sp)
    8000554c:	6105                	addi	sp,sp,32
    8000554e:	8082                	ret

0000000080005550 <sys_link>:
{
    80005550:	7169                	addi	sp,sp,-304
    80005552:	f606                	sd	ra,296(sp)
    80005554:	f222                	sd	s0,288(sp)
    80005556:	ee26                	sd	s1,280(sp)
    80005558:	ea4a                	sd	s2,272(sp)
    8000555a:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000555c:	08000613          	li	a2,128
    80005560:	ed040593          	addi	a1,s0,-304
    80005564:	4501                	li	a0,0
    80005566:	ffffd097          	auipc	ra,0xffffd
    8000556a:	7c6080e7          	jalr	1990(ra) # 80002d2c <argstr>
    return -1;
    8000556e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005570:	10054e63          	bltz	a0,8000568c <sys_link+0x13c>
    80005574:	08000613          	li	a2,128
    80005578:	f5040593          	addi	a1,s0,-176
    8000557c:	4505                	li	a0,1
    8000557e:	ffffd097          	auipc	ra,0xffffd
    80005582:	7ae080e7          	jalr	1966(ra) # 80002d2c <argstr>
    return -1;
    80005586:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005588:	10054263          	bltz	a0,8000568c <sys_link+0x13c>
  begin_op();
    8000558c:	fffff097          	auipc	ra,0xfffff
    80005590:	c8a080e7          	jalr	-886(ra) # 80004216 <begin_op>
  if((ip = namei(old)) == 0){
    80005594:	ed040513          	addi	a0,s0,-304
    80005598:	fffff097          	auipc	ra,0xfffff
    8000559c:	a72080e7          	jalr	-1422(ra) # 8000400a <namei>
    800055a0:	84aa                	mv	s1,a0
    800055a2:	c551                	beqz	a0,8000562e <sys_link+0xde>
  ilock(ip);
    800055a4:	ffffe097          	auipc	ra,0xffffe
    800055a8:	2b6080e7          	jalr	694(ra) # 8000385a <ilock>
  if(ip->type == T_DIR){
    800055ac:	04449703          	lh	a4,68(s1)
    800055b0:	4785                	li	a5,1
    800055b2:	08f70463          	beq	a4,a5,8000563a <sys_link+0xea>
  ip->nlink++;
    800055b6:	04a4d783          	lhu	a5,74(s1)
    800055ba:	2785                	addiw	a5,a5,1
    800055bc:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800055c0:	8526                	mv	a0,s1
    800055c2:	ffffe097          	auipc	ra,0xffffe
    800055c6:	1ce080e7          	jalr	462(ra) # 80003790 <iupdate>
  iunlock(ip);
    800055ca:	8526                	mv	a0,s1
    800055cc:	ffffe097          	auipc	ra,0xffffe
    800055d0:	350080e7          	jalr	848(ra) # 8000391c <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800055d4:	fd040593          	addi	a1,s0,-48
    800055d8:	f5040513          	addi	a0,s0,-176
    800055dc:	fffff097          	auipc	ra,0xfffff
    800055e0:	a4c080e7          	jalr	-1460(ra) # 80004028 <nameiparent>
    800055e4:	892a                	mv	s2,a0
    800055e6:	c935                	beqz	a0,8000565a <sys_link+0x10a>
  ilock(dp);
    800055e8:	ffffe097          	auipc	ra,0xffffe
    800055ec:	272080e7          	jalr	626(ra) # 8000385a <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800055f0:	00092703          	lw	a4,0(s2)
    800055f4:	409c                	lw	a5,0(s1)
    800055f6:	04f71d63          	bne	a4,a5,80005650 <sys_link+0x100>
    800055fa:	40d0                	lw	a2,4(s1)
    800055fc:	fd040593          	addi	a1,s0,-48
    80005600:	854a                	mv	a0,s2
    80005602:	fffff097          	auipc	ra,0xfffff
    80005606:	946080e7          	jalr	-1722(ra) # 80003f48 <dirlink>
    8000560a:	04054363          	bltz	a0,80005650 <sys_link+0x100>
  iunlockput(dp);
    8000560e:	854a                	mv	a0,s2
    80005610:	ffffe097          	auipc	ra,0xffffe
    80005614:	4ac080e7          	jalr	1196(ra) # 80003abc <iunlockput>
  iput(ip);
    80005618:	8526                	mv	a0,s1
    8000561a:	ffffe097          	auipc	ra,0xffffe
    8000561e:	3fa080e7          	jalr	1018(ra) # 80003a14 <iput>
  end_op();
    80005622:	fffff097          	auipc	ra,0xfffff
    80005626:	c74080e7          	jalr	-908(ra) # 80004296 <end_op>
  return 0;
    8000562a:	4781                	li	a5,0
    8000562c:	a085                	j	8000568c <sys_link+0x13c>
    end_op();
    8000562e:	fffff097          	auipc	ra,0xfffff
    80005632:	c68080e7          	jalr	-920(ra) # 80004296 <end_op>
    return -1;
    80005636:	57fd                	li	a5,-1
    80005638:	a891                	j	8000568c <sys_link+0x13c>
    iunlockput(ip);
    8000563a:	8526                	mv	a0,s1
    8000563c:	ffffe097          	auipc	ra,0xffffe
    80005640:	480080e7          	jalr	1152(ra) # 80003abc <iunlockput>
    end_op();
    80005644:	fffff097          	auipc	ra,0xfffff
    80005648:	c52080e7          	jalr	-942(ra) # 80004296 <end_op>
    return -1;
    8000564c:	57fd                	li	a5,-1
    8000564e:	a83d                	j	8000568c <sys_link+0x13c>
    iunlockput(dp);
    80005650:	854a                	mv	a0,s2
    80005652:	ffffe097          	auipc	ra,0xffffe
    80005656:	46a080e7          	jalr	1130(ra) # 80003abc <iunlockput>
  ilock(ip);
    8000565a:	8526                	mv	a0,s1
    8000565c:	ffffe097          	auipc	ra,0xffffe
    80005660:	1fe080e7          	jalr	510(ra) # 8000385a <ilock>
  ip->nlink--;
    80005664:	04a4d783          	lhu	a5,74(s1)
    80005668:	37fd                	addiw	a5,a5,-1
    8000566a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000566e:	8526                	mv	a0,s1
    80005670:	ffffe097          	auipc	ra,0xffffe
    80005674:	120080e7          	jalr	288(ra) # 80003790 <iupdate>
  iunlockput(ip);
    80005678:	8526                	mv	a0,s1
    8000567a:	ffffe097          	auipc	ra,0xffffe
    8000567e:	442080e7          	jalr	1090(ra) # 80003abc <iunlockput>
  end_op();
    80005682:	fffff097          	auipc	ra,0xfffff
    80005686:	c14080e7          	jalr	-1004(ra) # 80004296 <end_op>
  return -1;
    8000568a:	57fd                	li	a5,-1
}
    8000568c:	853e                	mv	a0,a5
    8000568e:	70b2                	ld	ra,296(sp)
    80005690:	7412                	ld	s0,288(sp)
    80005692:	64f2                	ld	s1,280(sp)
    80005694:	6952                	ld	s2,272(sp)
    80005696:	6155                	addi	sp,sp,304
    80005698:	8082                	ret

000000008000569a <sys_unlink>:
{
    8000569a:	7151                	addi	sp,sp,-240
    8000569c:	f586                	sd	ra,232(sp)
    8000569e:	f1a2                	sd	s0,224(sp)
    800056a0:	eda6                	sd	s1,216(sp)
    800056a2:	e9ca                	sd	s2,208(sp)
    800056a4:	e5ce                	sd	s3,200(sp)
    800056a6:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800056a8:	08000613          	li	a2,128
    800056ac:	f3040593          	addi	a1,s0,-208
    800056b0:	4501                	li	a0,0
    800056b2:	ffffd097          	auipc	ra,0xffffd
    800056b6:	67a080e7          	jalr	1658(ra) # 80002d2c <argstr>
    800056ba:	18054163          	bltz	a0,8000583c <sys_unlink+0x1a2>
  begin_op();
    800056be:	fffff097          	auipc	ra,0xfffff
    800056c2:	b58080e7          	jalr	-1192(ra) # 80004216 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800056c6:	fb040593          	addi	a1,s0,-80
    800056ca:	f3040513          	addi	a0,s0,-208
    800056ce:	fffff097          	auipc	ra,0xfffff
    800056d2:	95a080e7          	jalr	-1702(ra) # 80004028 <nameiparent>
    800056d6:	84aa                	mv	s1,a0
    800056d8:	c979                	beqz	a0,800057ae <sys_unlink+0x114>
  ilock(dp);
    800056da:	ffffe097          	auipc	ra,0xffffe
    800056de:	180080e7          	jalr	384(ra) # 8000385a <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800056e2:	00003597          	auipc	a1,0x3
    800056e6:	08e58593          	addi	a1,a1,142 # 80008770 <syscalls+0x2c0>
    800056ea:	fb040513          	addi	a0,s0,-80
    800056ee:	ffffe097          	auipc	ra,0xffffe
    800056f2:	630080e7          	jalr	1584(ra) # 80003d1e <namecmp>
    800056f6:	14050a63          	beqz	a0,8000584a <sys_unlink+0x1b0>
    800056fa:	00003597          	auipc	a1,0x3
    800056fe:	b1e58593          	addi	a1,a1,-1250 # 80008218 <digits+0x1e8>
    80005702:	fb040513          	addi	a0,s0,-80
    80005706:	ffffe097          	auipc	ra,0xffffe
    8000570a:	618080e7          	jalr	1560(ra) # 80003d1e <namecmp>
    8000570e:	12050e63          	beqz	a0,8000584a <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005712:	f2c40613          	addi	a2,s0,-212
    80005716:	fb040593          	addi	a1,s0,-80
    8000571a:	8526                	mv	a0,s1
    8000571c:	ffffe097          	auipc	ra,0xffffe
    80005720:	61c080e7          	jalr	1564(ra) # 80003d38 <dirlookup>
    80005724:	892a                	mv	s2,a0
    80005726:	12050263          	beqz	a0,8000584a <sys_unlink+0x1b0>
  ilock(ip);
    8000572a:	ffffe097          	auipc	ra,0xffffe
    8000572e:	130080e7          	jalr	304(ra) # 8000385a <ilock>
  if(ip->nlink < 1)
    80005732:	04a91783          	lh	a5,74(s2)
    80005736:	08f05263          	blez	a5,800057ba <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000573a:	04491703          	lh	a4,68(s2)
    8000573e:	4785                	li	a5,1
    80005740:	08f70563          	beq	a4,a5,800057ca <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005744:	4641                	li	a2,16
    80005746:	4581                	li	a1,0
    80005748:	fc040513          	addi	a0,s0,-64
    8000574c:	ffffb097          	auipc	ra,0xffffb
    80005750:	5da080e7          	jalr	1498(ra) # 80000d26 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005754:	4741                	li	a4,16
    80005756:	f2c42683          	lw	a3,-212(s0)
    8000575a:	fc040613          	addi	a2,s0,-64
    8000575e:	4581                	li	a1,0
    80005760:	8526                	mv	a0,s1
    80005762:	ffffe097          	auipc	ra,0xffffe
    80005766:	4a2080e7          	jalr	1186(ra) # 80003c04 <writei>
    8000576a:	47c1                	li	a5,16
    8000576c:	0af51563          	bne	a0,a5,80005816 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005770:	04491703          	lh	a4,68(s2)
    80005774:	4785                	li	a5,1
    80005776:	0af70863          	beq	a4,a5,80005826 <sys_unlink+0x18c>
  iunlockput(dp);
    8000577a:	8526                	mv	a0,s1
    8000577c:	ffffe097          	auipc	ra,0xffffe
    80005780:	340080e7          	jalr	832(ra) # 80003abc <iunlockput>
  ip->nlink--;
    80005784:	04a95783          	lhu	a5,74(s2)
    80005788:	37fd                	addiw	a5,a5,-1
    8000578a:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000578e:	854a                	mv	a0,s2
    80005790:	ffffe097          	auipc	ra,0xffffe
    80005794:	000080e7          	jalr	ra # 80003790 <iupdate>
  iunlockput(ip);
    80005798:	854a                	mv	a0,s2
    8000579a:	ffffe097          	auipc	ra,0xffffe
    8000579e:	322080e7          	jalr	802(ra) # 80003abc <iunlockput>
  end_op();
    800057a2:	fffff097          	auipc	ra,0xfffff
    800057a6:	af4080e7          	jalr	-1292(ra) # 80004296 <end_op>
  return 0;
    800057aa:	4501                	li	a0,0
    800057ac:	a84d                	j	8000585e <sys_unlink+0x1c4>
    end_op();
    800057ae:	fffff097          	auipc	ra,0xfffff
    800057b2:	ae8080e7          	jalr	-1304(ra) # 80004296 <end_op>
    return -1;
    800057b6:	557d                	li	a0,-1
    800057b8:	a05d                	j	8000585e <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800057ba:	00003517          	auipc	a0,0x3
    800057be:	fde50513          	addi	a0,a0,-34 # 80008798 <syscalls+0x2e8>
    800057c2:	ffffb097          	auipc	ra,0xffffb
    800057c6:	d86080e7          	jalr	-634(ra) # 80000548 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800057ca:	04c92703          	lw	a4,76(s2)
    800057ce:	02000793          	li	a5,32
    800057d2:	f6e7f9e3          	bgeu	a5,a4,80005744 <sys_unlink+0xaa>
    800057d6:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800057da:	4741                	li	a4,16
    800057dc:	86ce                	mv	a3,s3
    800057de:	f1840613          	addi	a2,s0,-232
    800057e2:	4581                	li	a1,0
    800057e4:	854a                	mv	a0,s2
    800057e6:	ffffe097          	auipc	ra,0xffffe
    800057ea:	328080e7          	jalr	808(ra) # 80003b0e <readi>
    800057ee:	47c1                	li	a5,16
    800057f0:	00f51b63          	bne	a0,a5,80005806 <sys_unlink+0x16c>
    if(de.inum != 0)
    800057f4:	f1845783          	lhu	a5,-232(s0)
    800057f8:	e7a1                	bnez	a5,80005840 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800057fa:	29c1                	addiw	s3,s3,16
    800057fc:	04c92783          	lw	a5,76(s2)
    80005800:	fcf9ede3          	bltu	s3,a5,800057da <sys_unlink+0x140>
    80005804:	b781                	j	80005744 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005806:	00003517          	auipc	a0,0x3
    8000580a:	faa50513          	addi	a0,a0,-86 # 800087b0 <syscalls+0x300>
    8000580e:	ffffb097          	auipc	ra,0xffffb
    80005812:	d3a080e7          	jalr	-710(ra) # 80000548 <panic>
    panic("unlink: writei");
    80005816:	00003517          	auipc	a0,0x3
    8000581a:	fb250513          	addi	a0,a0,-78 # 800087c8 <syscalls+0x318>
    8000581e:	ffffb097          	auipc	ra,0xffffb
    80005822:	d2a080e7          	jalr	-726(ra) # 80000548 <panic>
    dp->nlink--;
    80005826:	04a4d783          	lhu	a5,74(s1)
    8000582a:	37fd                	addiw	a5,a5,-1
    8000582c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005830:	8526                	mv	a0,s1
    80005832:	ffffe097          	auipc	ra,0xffffe
    80005836:	f5e080e7          	jalr	-162(ra) # 80003790 <iupdate>
    8000583a:	b781                	j	8000577a <sys_unlink+0xe0>
    return -1;
    8000583c:	557d                	li	a0,-1
    8000583e:	a005                	j	8000585e <sys_unlink+0x1c4>
    iunlockput(ip);
    80005840:	854a                	mv	a0,s2
    80005842:	ffffe097          	auipc	ra,0xffffe
    80005846:	27a080e7          	jalr	634(ra) # 80003abc <iunlockput>
  iunlockput(dp);
    8000584a:	8526                	mv	a0,s1
    8000584c:	ffffe097          	auipc	ra,0xffffe
    80005850:	270080e7          	jalr	624(ra) # 80003abc <iunlockput>
  end_op();
    80005854:	fffff097          	auipc	ra,0xfffff
    80005858:	a42080e7          	jalr	-1470(ra) # 80004296 <end_op>
  return -1;
    8000585c:	557d                	li	a0,-1
}
    8000585e:	70ae                	ld	ra,232(sp)
    80005860:	740e                	ld	s0,224(sp)
    80005862:	64ee                	ld	s1,216(sp)
    80005864:	694e                	ld	s2,208(sp)
    80005866:	69ae                	ld	s3,200(sp)
    80005868:	616d                	addi	sp,sp,240
    8000586a:	8082                	ret

000000008000586c <sys_open>:

uint64
sys_open(void)
{
    8000586c:	7131                	addi	sp,sp,-192
    8000586e:	fd06                	sd	ra,184(sp)
    80005870:	f922                	sd	s0,176(sp)
    80005872:	f526                	sd	s1,168(sp)
    80005874:	f14a                	sd	s2,160(sp)
    80005876:	ed4e                	sd	s3,152(sp)
    80005878:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    8000587a:	08000613          	li	a2,128
    8000587e:	f5040593          	addi	a1,s0,-176
    80005882:	4501                	li	a0,0
    80005884:	ffffd097          	auipc	ra,0xffffd
    80005888:	4a8080e7          	jalr	1192(ra) # 80002d2c <argstr>
    return -1;
    8000588c:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    8000588e:	0c054163          	bltz	a0,80005950 <sys_open+0xe4>
    80005892:	f4c40593          	addi	a1,s0,-180
    80005896:	4505                	li	a0,1
    80005898:	ffffd097          	auipc	ra,0xffffd
    8000589c:	450080e7          	jalr	1104(ra) # 80002ce8 <argint>
    800058a0:	0a054863          	bltz	a0,80005950 <sys_open+0xe4>

  begin_op();
    800058a4:	fffff097          	auipc	ra,0xfffff
    800058a8:	972080e7          	jalr	-1678(ra) # 80004216 <begin_op>

  if(omode & O_CREATE){
    800058ac:	f4c42783          	lw	a5,-180(s0)
    800058b0:	2007f793          	andi	a5,a5,512
    800058b4:	cbdd                	beqz	a5,8000596a <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800058b6:	4681                	li	a3,0
    800058b8:	4601                	li	a2,0
    800058ba:	4589                	li	a1,2
    800058bc:	f5040513          	addi	a0,s0,-176
    800058c0:	00000097          	auipc	ra,0x0
    800058c4:	972080e7          	jalr	-1678(ra) # 80005232 <create>
    800058c8:	892a                	mv	s2,a0
    if(ip == 0){
    800058ca:	c959                	beqz	a0,80005960 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800058cc:	04491703          	lh	a4,68(s2)
    800058d0:	478d                	li	a5,3
    800058d2:	00f71763          	bne	a4,a5,800058e0 <sys_open+0x74>
    800058d6:	04695703          	lhu	a4,70(s2)
    800058da:	47a5                	li	a5,9
    800058dc:	0ce7ec63          	bltu	a5,a4,800059b4 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800058e0:	fffff097          	auipc	ra,0xfffff
    800058e4:	d4c080e7          	jalr	-692(ra) # 8000462c <filealloc>
    800058e8:	89aa                	mv	s3,a0
    800058ea:	10050263          	beqz	a0,800059ee <sys_open+0x182>
    800058ee:	00000097          	auipc	ra,0x0
    800058f2:	902080e7          	jalr	-1790(ra) # 800051f0 <fdalloc>
    800058f6:	84aa                	mv	s1,a0
    800058f8:	0e054663          	bltz	a0,800059e4 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800058fc:	04491703          	lh	a4,68(s2)
    80005900:	478d                	li	a5,3
    80005902:	0cf70463          	beq	a4,a5,800059ca <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005906:	4789                	li	a5,2
    80005908:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    8000590c:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005910:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005914:	f4c42783          	lw	a5,-180(s0)
    80005918:	0017c713          	xori	a4,a5,1
    8000591c:	8b05                	andi	a4,a4,1
    8000591e:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005922:	0037f713          	andi	a4,a5,3
    80005926:	00e03733          	snez	a4,a4
    8000592a:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000592e:	4007f793          	andi	a5,a5,1024
    80005932:	c791                	beqz	a5,8000593e <sys_open+0xd2>
    80005934:	04491703          	lh	a4,68(s2)
    80005938:	4789                	li	a5,2
    8000593a:	08f70f63          	beq	a4,a5,800059d8 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    8000593e:	854a                	mv	a0,s2
    80005940:	ffffe097          	auipc	ra,0xffffe
    80005944:	fdc080e7          	jalr	-36(ra) # 8000391c <iunlock>
  end_op();
    80005948:	fffff097          	auipc	ra,0xfffff
    8000594c:	94e080e7          	jalr	-1714(ra) # 80004296 <end_op>

  return fd;
}
    80005950:	8526                	mv	a0,s1
    80005952:	70ea                	ld	ra,184(sp)
    80005954:	744a                	ld	s0,176(sp)
    80005956:	74aa                	ld	s1,168(sp)
    80005958:	790a                	ld	s2,160(sp)
    8000595a:	69ea                	ld	s3,152(sp)
    8000595c:	6129                	addi	sp,sp,192
    8000595e:	8082                	ret
      end_op();
    80005960:	fffff097          	auipc	ra,0xfffff
    80005964:	936080e7          	jalr	-1738(ra) # 80004296 <end_op>
      return -1;
    80005968:	b7e5                	j	80005950 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    8000596a:	f5040513          	addi	a0,s0,-176
    8000596e:	ffffe097          	auipc	ra,0xffffe
    80005972:	69c080e7          	jalr	1692(ra) # 8000400a <namei>
    80005976:	892a                	mv	s2,a0
    80005978:	c905                	beqz	a0,800059a8 <sys_open+0x13c>
    ilock(ip);
    8000597a:	ffffe097          	auipc	ra,0xffffe
    8000597e:	ee0080e7          	jalr	-288(ra) # 8000385a <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005982:	04491703          	lh	a4,68(s2)
    80005986:	4785                	li	a5,1
    80005988:	f4f712e3          	bne	a4,a5,800058cc <sys_open+0x60>
    8000598c:	f4c42783          	lw	a5,-180(s0)
    80005990:	dba1                	beqz	a5,800058e0 <sys_open+0x74>
      iunlockput(ip);
    80005992:	854a                	mv	a0,s2
    80005994:	ffffe097          	auipc	ra,0xffffe
    80005998:	128080e7          	jalr	296(ra) # 80003abc <iunlockput>
      end_op();
    8000599c:	fffff097          	auipc	ra,0xfffff
    800059a0:	8fa080e7          	jalr	-1798(ra) # 80004296 <end_op>
      return -1;
    800059a4:	54fd                	li	s1,-1
    800059a6:	b76d                	j	80005950 <sys_open+0xe4>
      end_op();
    800059a8:	fffff097          	auipc	ra,0xfffff
    800059ac:	8ee080e7          	jalr	-1810(ra) # 80004296 <end_op>
      return -1;
    800059b0:	54fd                	li	s1,-1
    800059b2:	bf79                	j	80005950 <sys_open+0xe4>
    iunlockput(ip);
    800059b4:	854a                	mv	a0,s2
    800059b6:	ffffe097          	auipc	ra,0xffffe
    800059ba:	106080e7          	jalr	262(ra) # 80003abc <iunlockput>
    end_op();
    800059be:	fffff097          	auipc	ra,0xfffff
    800059c2:	8d8080e7          	jalr	-1832(ra) # 80004296 <end_op>
    return -1;
    800059c6:	54fd                	li	s1,-1
    800059c8:	b761                	j	80005950 <sys_open+0xe4>
    f->type = FD_DEVICE;
    800059ca:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800059ce:	04691783          	lh	a5,70(s2)
    800059d2:	02f99223          	sh	a5,36(s3)
    800059d6:	bf2d                	j	80005910 <sys_open+0xa4>
    itrunc(ip);
    800059d8:	854a                	mv	a0,s2
    800059da:	ffffe097          	auipc	ra,0xffffe
    800059de:	f8e080e7          	jalr	-114(ra) # 80003968 <itrunc>
    800059e2:	bfb1                	j	8000593e <sys_open+0xd2>
      fileclose(f);
    800059e4:	854e                	mv	a0,s3
    800059e6:	fffff097          	auipc	ra,0xfffff
    800059ea:	d02080e7          	jalr	-766(ra) # 800046e8 <fileclose>
    iunlockput(ip);
    800059ee:	854a                	mv	a0,s2
    800059f0:	ffffe097          	auipc	ra,0xffffe
    800059f4:	0cc080e7          	jalr	204(ra) # 80003abc <iunlockput>
    end_op();
    800059f8:	fffff097          	auipc	ra,0xfffff
    800059fc:	89e080e7          	jalr	-1890(ra) # 80004296 <end_op>
    return -1;
    80005a00:	54fd                	li	s1,-1
    80005a02:	b7b9                	j	80005950 <sys_open+0xe4>

0000000080005a04 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005a04:	7175                	addi	sp,sp,-144
    80005a06:	e506                	sd	ra,136(sp)
    80005a08:	e122                	sd	s0,128(sp)
    80005a0a:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005a0c:	fffff097          	auipc	ra,0xfffff
    80005a10:	80a080e7          	jalr	-2038(ra) # 80004216 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005a14:	08000613          	li	a2,128
    80005a18:	f7040593          	addi	a1,s0,-144
    80005a1c:	4501                	li	a0,0
    80005a1e:	ffffd097          	auipc	ra,0xffffd
    80005a22:	30e080e7          	jalr	782(ra) # 80002d2c <argstr>
    80005a26:	02054963          	bltz	a0,80005a58 <sys_mkdir+0x54>
    80005a2a:	4681                	li	a3,0
    80005a2c:	4601                	li	a2,0
    80005a2e:	4585                	li	a1,1
    80005a30:	f7040513          	addi	a0,s0,-144
    80005a34:	fffff097          	auipc	ra,0xfffff
    80005a38:	7fe080e7          	jalr	2046(ra) # 80005232 <create>
    80005a3c:	cd11                	beqz	a0,80005a58 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005a3e:	ffffe097          	auipc	ra,0xffffe
    80005a42:	07e080e7          	jalr	126(ra) # 80003abc <iunlockput>
  end_op();
    80005a46:	fffff097          	auipc	ra,0xfffff
    80005a4a:	850080e7          	jalr	-1968(ra) # 80004296 <end_op>
  return 0;
    80005a4e:	4501                	li	a0,0
}
    80005a50:	60aa                	ld	ra,136(sp)
    80005a52:	640a                	ld	s0,128(sp)
    80005a54:	6149                	addi	sp,sp,144
    80005a56:	8082                	ret
    end_op();
    80005a58:	fffff097          	auipc	ra,0xfffff
    80005a5c:	83e080e7          	jalr	-1986(ra) # 80004296 <end_op>
    return -1;
    80005a60:	557d                	li	a0,-1
    80005a62:	b7fd                	j	80005a50 <sys_mkdir+0x4c>

0000000080005a64 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005a64:	7135                	addi	sp,sp,-160
    80005a66:	ed06                	sd	ra,152(sp)
    80005a68:	e922                	sd	s0,144(sp)
    80005a6a:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005a6c:	ffffe097          	auipc	ra,0xffffe
    80005a70:	7aa080e7          	jalr	1962(ra) # 80004216 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005a74:	08000613          	li	a2,128
    80005a78:	f7040593          	addi	a1,s0,-144
    80005a7c:	4501                	li	a0,0
    80005a7e:	ffffd097          	auipc	ra,0xffffd
    80005a82:	2ae080e7          	jalr	686(ra) # 80002d2c <argstr>
    80005a86:	04054a63          	bltz	a0,80005ada <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005a8a:	f6c40593          	addi	a1,s0,-148
    80005a8e:	4505                	li	a0,1
    80005a90:	ffffd097          	auipc	ra,0xffffd
    80005a94:	258080e7          	jalr	600(ra) # 80002ce8 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005a98:	04054163          	bltz	a0,80005ada <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005a9c:	f6840593          	addi	a1,s0,-152
    80005aa0:	4509                	li	a0,2
    80005aa2:	ffffd097          	auipc	ra,0xffffd
    80005aa6:	246080e7          	jalr	582(ra) # 80002ce8 <argint>
     argint(1, &major) < 0 ||
    80005aaa:	02054863          	bltz	a0,80005ada <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005aae:	f6841683          	lh	a3,-152(s0)
    80005ab2:	f6c41603          	lh	a2,-148(s0)
    80005ab6:	458d                	li	a1,3
    80005ab8:	f7040513          	addi	a0,s0,-144
    80005abc:	fffff097          	auipc	ra,0xfffff
    80005ac0:	776080e7          	jalr	1910(ra) # 80005232 <create>
     argint(2, &minor) < 0 ||
    80005ac4:	c919                	beqz	a0,80005ada <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005ac6:	ffffe097          	auipc	ra,0xffffe
    80005aca:	ff6080e7          	jalr	-10(ra) # 80003abc <iunlockput>
  end_op();
    80005ace:	ffffe097          	auipc	ra,0xffffe
    80005ad2:	7c8080e7          	jalr	1992(ra) # 80004296 <end_op>
  return 0;
    80005ad6:	4501                	li	a0,0
    80005ad8:	a031                	j	80005ae4 <sys_mknod+0x80>
    end_op();
    80005ada:	ffffe097          	auipc	ra,0xffffe
    80005ade:	7bc080e7          	jalr	1980(ra) # 80004296 <end_op>
    return -1;
    80005ae2:	557d                	li	a0,-1
}
    80005ae4:	60ea                	ld	ra,152(sp)
    80005ae6:	644a                	ld	s0,144(sp)
    80005ae8:	610d                	addi	sp,sp,160
    80005aea:	8082                	ret

0000000080005aec <sys_chdir>:

uint64
sys_chdir(void)
{
    80005aec:	7135                	addi	sp,sp,-160
    80005aee:	ed06                	sd	ra,152(sp)
    80005af0:	e922                	sd	s0,144(sp)
    80005af2:	e526                	sd	s1,136(sp)
    80005af4:	e14a                	sd	s2,128(sp)
    80005af6:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005af8:	ffffc097          	auipc	ra,0xffffc
    80005afc:	01a080e7          	jalr	26(ra) # 80001b12 <myproc>
    80005b00:	892a                	mv	s2,a0
  
  begin_op();
    80005b02:	ffffe097          	auipc	ra,0xffffe
    80005b06:	714080e7          	jalr	1812(ra) # 80004216 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005b0a:	08000613          	li	a2,128
    80005b0e:	f6040593          	addi	a1,s0,-160
    80005b12:	4501                	li	a0,0
    80005b14:	ffffd097          	auipc	ra,0xffffd
    80005b18:	218080e7          	jalr	536(ra) # 80002d2c <argstr>
    80005b1c:	04054b63          	bltz	a0,80005b72 <sys_chdir+0x86>
    80005b20:	f6040513          	addi	a0,s0,-160
    80005b24:	ffffe097          	auipc	ra,0xffffe
    80005b28:	4e6080e7          	jalr	1254(ra) # 8000400a <namei>
    80005b2c:	84aa                	mv	s1,a0
    80005b2e:	c131                	beqz	a0,80005b72 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005b30:	ffffe097          	auipc	ra,0xffffe
    80005b34:	d2a080e7          	jalr	-726(ra) # 8000385a <ilock>
  if(ip->type != T_DIR){
    80005b38:	04449703          	lh	a4,68(s1)
    80005b3c:	4785                	li	a5,1
    80005b3e:	04f71063          	bne	a4,a5,80005b7e <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005b42:	8526                	mv	a0,s1
    80005b44:	ffffe097          	auipc	ra,0xffffe
    80005b48:	dd8080e7          	jalr	-552(ra) # 8000391c <iunlock>
  iput(p->cwd);
    80005b4c:	15093503          	ld	a0,336(s2)
    80005b50:	ffffe097          	auipc	ra,0xffffe
    80005b54:	ec4080e7          	jalr	-316(ra) # 80003a14 <iput>
  end_op();
    80005b58:	ffffe097          	auipc	ra,0xffffe
    80005b5c:	73e080e7          	jalr	1854(ra) # 80004296 <end_op>
  p->cwd = ip;
    80005b60:	14993823          	sd	s1,336(s2)
  return 0;
    80005b64:	4501                	li	a0,0
}
    80005b66:	60ea                	ld	ra,152(sp)
    80005b68:	644a                	ld	s0,144(sp)
    80005b6a:	64aa                	ld	s1,136(sp)
    80005b6c:	690a                	ld	s2,128(sp)
    80005b6e:	610d                	addi	sp,sp,160
    80005b70:	8082                	ret
    end_op();
    80005b72:	ffffe097          	auipc	ra,0xffffe
    80005b76:	724080e7          	jalr	1828(ra) # 80004296 <end_op>
    return -1;
    80005b7a:	557d                	li	a0,-1
    80005b7c:	b7ed                	j	80005b66 <sys_chdir+0x7a>
    iunlockput(ip);
    80005b7e:	8526                	mv	a0,s1
    80005b80:	ffffe097          	auipc	ra,0xffffe
    80005b84:	f3c080e7          	jalr	-196(ra) # 80003abc <iunlockput>
    end_op();
    80005b88:	ffffe097          	auipc	ra,0xffffe
    80005b8c:	70e080e7          	jalr	1806(ra) # 80004296 <end_op>
    return -1;
    80005b90:	557d                	li	a0,-1
    80005b92:	bfd1                	j	80005b66 <sys_chdir+0x7a>

0000000080005b94 <sys_exec>:

uint64
sys_exec(void)
{
    80005b94:	7145                	addi	sp,sp,-464
    80005b96:	e786                	sd	ra,456(sp)
    80005b98:	e3a2                	sd	s0,448(sp)
    80005b9a:	ff26                	sd	s1,440(sp)
    80005b9c:	fb4a                	sd	s2,432(sp)
    80005b9e:	f74e                	sd	s3,424(sp)
    80005ba0:	f352                	sd	s4,416(sp)
    80005ba2:	ef56                	sd	s5,408(sp)
    80005ba4:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005ba6:	08000613          	li	a2,128
    80005baa:	f4040593          	addi	a1,s0,-192
    80005bae:	4501                	li	a0,0
    80005bb0:	ffffd097          	auipc	ra,0xffffd
    80005bb4:	17c080e7          	jalr	380(ra) # 80002d2c <argstr>
    return -1;
    80005bb8:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005bba:	0c054a63          	bltz	a0,80005c8e <sys_exec+0xfa>
    80005bbe:	e3840593          	addi	a1,s0,-456
    80005bc2:	4505                	li	a0,1
    80005bc4:	ffffd097          	auipc	ra,0xffffd
    80005bc8:	146080e7          	jalr	326(ra) # 80002d0a <argaddr>
    80005bcc:	0c054163          	bltz	a0,80005c8e <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005bd0:	10000613          	li	a2,256
    80005bd4:	4581                	li	a1,0
    80005bd6:	e4040513          	addi	a0,s0,-448
    80005bda:	ffffb097          	auipc	ra,0xffffb
    80005bde:	14c080e7          	jalr	332(ra) # 80000d26 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005be2:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005be6:	89a6                	mv	s3,s1
    80005be8:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005bea:	02000a13          	li	s4,32
    80005bee:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005bf2:	00391513          	slli	a0,s2,0x3
    80005bf6:	e3040593          	addi	a1,s0,-464
    80005bfa:	e3843783          	ld	a5,-456(s0)
    80005bfe:	953e                	add	a0,a0,a5
    80005c00:	ffffd097          	auipc	ra,0xffffd
    80005c04:	04e080e7          	jalr	78(ra) # 80002c4e <fetchaddr>
    80005c08:	02054a63          	bltz	a0,80005c3c <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005c0c:	e3043783          	ld	a5,-464(s0)
    80005c10:	c3b9                	beqz	a5,80005c56 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005c12:	ffffb097          	auipc	ra,0xffffb
    80005c16:	f28080e7          	jalr	-216(ra) # 80000b3a <kalloc>
    80005c1a:	85aa                	mv	a1,a0
    80005c1c:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005c20:	cd11                	beqz	a0,80005c3c <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005c22:	6605                	lui	a2,0x1
    80005c24:	e3043503          	ld	a0,-464(s0)
    80005c28:	ffffd097          	auipc	ra,0xffffd
    80005c2c:	078080e7          	jalr	120(ra) # 80002ca0 <fetchstr>
    80005c30:	00054663          	bltz	a0,80005c3c <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005c34:	0905                	addi	s2,s2,1
    80005c36:	09a1                	addi	s3,s3,8
    80005c38:	fb491be3          	bne	s2,s4,80005bee <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c3c:	10048913          	addi	s2,s1,256
    80005c40:	6088                	ld	a0,0(s1)
    80005c42:	c529                	beqz	a0,80005c8c <sys_exec+0xf8>
    kfree(argv[i]);
    80005c44:	ffffb097          	auipc	ra,0xffffb
    80005c48:	de0080e7          	jalr	-544(ra) # 80000a24 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c4c:	04a1                	addi	s1,s1,8
    80005c4e:	ff2499e3          	bne	s1,s2,80005c40 <sys_exec+0xac>
  return -1;
    80005c52:	597d                	li	s2,-1
    80005c54:	a82d                	j	80005c8e <sys_exec+0xfa>
      argv[i] = 0;
    80005c56:	0a8e                	slli	s5,s5,0x3
    80005c58:	fc040793          	addi	a5,s0,-64
    80005c5c:	9abe                	add	s5,s5,a5
    80005c5e:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005c62:	e4040593          	addi	a1,s0,-448
    80005c66:	f4040513          	addi	a0,s0,-192
    80005c6a:	fffff097          	auipc	ra,0xfffff
    80005c6e:	12e080e7          	jalr	302(ra) # 80004d98 <exec>
    80005c72:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c74:	10048993          	addi	s3,s1,256
    80005c78:	6088                	ld	a0,0(s1)
    80005c7a:	c911                	beqz	a0,80005c8e <sys_exec+0xfa>
    kfree(argv[i]);
    80005c7c:	ffffb097          	auipc	ra,0xffffb
    80005c80:	da8080e7          	jalr	-600(ra) # 80000a24 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c84:	04a1                	addi	s1,s1,8
    80005c86:	ff3499e3          	bne	s1,s3,80005c78 <sys_exec+0xe4>
    80005c8a:	a011                	j	80005c8e <sys_exec+0xfa>
  return -1;
    80005c8c:	597d                	li	s2,-1
}
    80005c8e:	854a                	mv	a0,s2
    80005c90:	60be                	ld	ra,456(sp)
    80005c92:	641e                	ld	s0,448(sp)
    80005c94:	74fa                	ld	s1,440(sp)
    80005c96:	795a                	ld	s2,432(sp)
    80005c98:	79ba                	ld	s3,424(sp)
    80005c9a:	7a1a                	ld	s4,416(sp)
    80005c9c:	6afa                	ld	s5,408(sp)
    80005c9e:	6179                	addi	sp,sp,464
    80005ca0:	8082                	ret

0000000080005ca2 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005ca2:	7139                	addi	sp,sp,-64
    80005ca4:	fc06                	sd	ra,56(sp)
    80005ca6:	f822                	sd	s0,48(sp)
    80005ca8:	f426                	sd	s1,40(sp)
    80005caa:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005cac:	ffffc097          	auipc	ra,0xffffc
    80005cb0:	e66080e7          	jalr	-410(ra) # 80001b12 <myproc>
    80005cb4:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005cb6:	fd840593          	addi	a1,s0,-40
    80005cba:	4501                	li	a0,0
    80005cbc:	ffffd097          	auipc	ra,0xffffd
    80005cc0:	04e080e7          	jalr	78(ra) # 80002d0a <argaddr>
    return -1;
    80005cc4:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005cc6:	0e054063          	bltz	a0,80005da6 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005cca:	fc840593          	addi	a1,s0,-56
    80005cce:	fd040513          	addi	a0,s0,-48
    80005cd2:	fffff097          	auipc	ra,0xfffff
    80005cd6:	d6c080e7          	jalr	-660(ra) # 80004a3e <pipealloc>
    return -1;
    80005cda:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005cdc:	0c054563          	bltz	a0,80005da6 <sys_pipe+0x104>
  fd0 = -1;
    80005ce0:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005ce4:	fd043503          	ld	a0,-48(s0)
    80005ce8:	fffff097          	auipc	ra,0xfffff
    80005cec:	508080e7          	jalr	1288(ra) # 800051f0 <fdalloc>
    80005cf0:	fca42223          	sw	a0,-60(s0)
    80005cf4:	08054c63          	bltz	a0,80005d8c <sys_pipe+0xea>
    80005cf8:	fc843503          	ld	a0,-56(s0)
    80005cfc:	fffff097          	auipc	ra,0xfffff
    80005d00:	4f4080e7          	jalr	1268(ra) # 800051f0 <fdalloc>
    80005d04:	fca42023          	sw	a0,-64(s0)
    80005d08:	06054863          	bltz	a0,80005d78 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d0c:	4691                	li	a3,4
    80005d0e:	fc440613          	addi	a2,s0,-60
    80005d12:	fd843583          	ld	a1,-40(s0)
    80005d16:	68a8                	ld	a0,80(s1)
    80005d18:	ffffc097          	auipc	ra,0xffffc
    80005d1c:	b6c080e7          	jalr	-1172(ra) # 80001884 <copyout>
    80005d20:	02054063          	bltz	a0,80005d40 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005d24:	4691                	li	a3,4
    80005d26:	fc040613          	addi	a2,s0,-64
    80005d2a:	fd843583          	ld	a1,-40(s0)
    80005d2e:	0591                	addi	a1,a1,4
    80005d30:	68a8                	ld	a0,80(s1)
    80005d32:	ffffc097          	auipc	ra,0xffffc
    80005d36:	b52080e7          	jalr	-1198(ra) # 80001884 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005d3a:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d3c:	06055563          	bgez	a0,80005da6 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005d40:	fc442783          	lw	a5,-60(s0)
    80005d44:	07e9                	addi	a5,a5,26
    80005d46:	078e                	slli	a5,a5,0x3
    80005d48:	97a6                	add	a5,a5,s1
    80005d4a:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005d4e:	fc042503          	lw	a0,-64(s0)
    80005d52:	0569                	addi	a0,a0,26
    80005d54:	050e                	slli	a0,a0,0x3
    80005d56:	9526                	add	a0,a0,s1
    80005d58:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005d5c:	fd043503          	ld	a0,-48(s0)
    80005d60:	fffff097          	auipc	ra,0xfffff
    80005d64:	988080e7          	jalr	-1656(ra) # 800046e8 <fileclose>
    fileclose(wf);
    80005d68:	fc843503          	ld	a0,-56(s0)
    80005d6c:	fffff097          	auipc	ra,0xfffff
    80005d70:	97c080e7          	jalr	-1668(ra) # 800046e8 <fileclose>
    return -1;
    80005d74:	57fd                	li	a5,-1
    80005d76:	a805                	j	80005da6 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005d78:	fc442783          	lw	a5,-60(s0)
    80005d7c:	0007c863          	bltz	a5,80005d8c <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005d80:	01a78513          	addi	a0,a5,26
    80005d84:	050e                	slli	a0,a0,0x3
    80005d86:	9526                	add	a0,a0,s1
    80005d88:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005d8c:	fd043503          	ld	a0,-48(s0)
    80005d90:	fffff097          	auipc	ra,0xfffff
    80005d94:	958080e7          	jalr	-1704(ra) # 800046e8 <fileclose>
    fileclose(wf);
    80005d98:	fc843503          	ld	a0,-56(s0)
    80005d9c:	fffff097          	auipc	ra,0xfffff
    80005da0:	94c080e7          	jalr	-1716(ra) # 800046e8 <fileclose>
    return -1;
    80005da4:	57fd                	li	a5,-1
}
    80005da6:	853e                	mv	a0,a5
    80005da8:	70e2                	ld	ra,56(sp)
    80005daa:	7442                	ld	s0,48(sp)
    80005dac:	74a2                	ld	s1,40(sp)
    80005dae:	6121                	addi	sp,sp,64
    80005db0:	8082                	ret
	...

0000000080005dc0 <kernelvec>:
    80005dc0:	7111                	addi	sp,sp,-256
    80005dc2:	e006                	sd	ra,0(sp)
    80005dc4:	e40a                	sd	sp,8(sp)
    80005dc6:	e80e                	sd	gp,16(sp)
    80005dc8:	ec12                	sd	tp,24(sp)
    80005dca:	f016                	sd	t0,32(sp)
    80005dcc:	f41a                	sd	t1,40(sp)
    80005dce:	f81e                	sd	t2,48(sp)
    80005dd0:	fc22                	sd	s0,56(sp)
    80005dd2:	e0a6                	sd	s1,64(sp)
    80005dd4:	e4aa                	sd	a0,72(sp)
    80005dd6:	e8ae                	sd	a1,80(sp)
    80005dd8:	ecb2                	sd	a2,88(sp)
    80005dda:	f0b6                	sd	a3,96(sp)
    80005ddc:	f4ba                	sd	a4,104(sp)
    80005dde:	f8be                	sd	a5,112(sp)
    80005de0:	fcc2                	sd	a6,120(sp)
    80005de2:	e146                	sd	a7,128(sp)
    80005de4:	e54a                	sd	s2,136(sp)
    80005de6:	e94e                	sd	s3,144(sp)
    80005de8:	ed52                	sd	s4,152(sp)
    80005dea:	f156                	sd	s5,160(sp)
    80005dec:	f55a                	sd	s6,168(sp)
    80005dee:	f95e                	sd	s7,176(sp)
    80005df0:	fd62                	sd	s8,184(sp)
    80005df2:	e1e6                	sd	s9,192(sp)
    80005df4:	e5ea                	sd	s10,200(sp)
    80005df6:	e9ee                	sd	s11,208(sp)
    80005df8:	edf2                	sd	t3,216(sp)
    80005dfa:	f1f6                	sd	t4,224(sp)
    80005dfc:	f5fa                	sd	t5,232(sp)
    80005dfe:	f9fe                	sd	t6,240(sp)
    80005e00:	d1bfc0ef          	jal	ra,80002b1a <kerneltrap>
    80005e04:	6082                	ld	ra,0(sp)
    80005e06:	6122                	ld	sp,8(sp)
    80005e08:	61c2                	ld	gp,16(sp)
    80005e0a:	7282                	ld	t0,32(sp)
    80005e0c:	7322                	ld	t1,40(sp)
    80005e0e:	73c2                	ld	t2,48(sp)
    80005e10:	7462                	ld	s0,56(sp)
    80005e12:	6486                	ld	s1,64(sp)
    80005e14:	6526                	ld	a0,72(sp)
    80005e16:	65c6                	ld	a1,80(sp)
    80005e18:	6666                	ld	a2,88(sp)
    80005e1a:	7686                	ld	a3,96(sp)
    80005e1c:	7726                	ld	a4,104(sp)
    80005e1e:	77c6                	ld	a5,112(sp)
    80005e20:	7866                	ld	a6,120(sp)
    80005e22:	688a                	ld	a7,128(sp)
    80005e24:	692a                	ld	s2,136(sp)
    80005e26:	69ca                	ld	s3,144(sp)
    80005e28:	6a6a                	ld	s4,152(sp)
    80005e2a:	7a8a                	ld	s5,160(sp)
    80005e2c:	7b2a                	ld	s6,168(sp)
    80005e2e:	7bca                	ld	s7,176(sp)
    80005e30:	7c6a                	ld	s8,184(sp)
    80005e32:	6c8e                	ld	s9,192(sp)
    80005e34:	6d2e                	ld	s10,200(sp)
    80005e36:	6dce                	ld	s11,208(sp)
    80005e38:	6e6e                	ld	t3,216(sp)
    80005e3a:	7e8e                	ld	t4,224(sp)
    80005e3c:	7f2e                	ld	t5,232(sp)
    80005e3e:	7fce                	ld	t6,240(sp)
    80005e40:	6111                	addi	sp,sp,256
    80005e42:	10200073          	sret
    80005e46:	00000013          	nop
    80005e4a:	00000013          	nop
    80005e4e:	0001                	nop

0000000080005e50 <timervec>:
    80005e50:	34051573          	csrrw	a0,mscratch,a0
    80005e54:	e10c                	sd	a1,0(a0)
    80005e56:	e510                	sd	a2,8(a0)
    80005e58:	e914                	sd	a3,16(a0)
    80005e5a:	710c                	ld	a1,32(a0)
    80005e5c:	7510                	ld	a2,40(a0)
    80005e5e:	6194                	ld	a3,0(a1)
    80005e60:	96b2                	add	a3,a3,a2
    80005e62:	e194                	sd	a3,0(a1)
    80005e64:	4589                	li	a1,2
    80005e66:	14459073          	csrw	sip,a1
    80005e6a:	6914                	ld	a3,16(a0)
    80005e6c:	6510                	ld	a2,8(a0)
    80005e6e:	610c                	ld	a1,0(a0)
    80005e70:	34051573          	csrrw	a0,mscratch,a0
    80005e74:	30200073          	mret
	...

0000000080005e7a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005e7a:	1141                	addi	sp,sp,-16
    80005e7c:	e422                	sd	s0,8(sp)
    80005e7e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005e80:	0c0007b7          	lui	a5,0xc000
    80005e84:	4705                	li	a4,1
    80005e86:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005e88:	c3d8                	sw	a4,4(a5)
}
    80005e8a:	6422                	ld	s0,8(sp)
    80005e8c:	0141                	addi	sp,sp,16
    80005e8e:	8082                	ret

0000000080005e90 <plicinithart>:

void
plicinithart(void)
{
    80005e90:	1141                	addi	sp,sp,-16
    80005e92:	e406                	sd	ra,8(sp)
    80005e94:	e022                	sd	s0,0(sp)
    80005e96:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005e98:	ffffc097          	auipc	ra,0xffffc
    80005e9c:	c4e080e7          	jalr	-946(ra) # 80001ae6 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005ea0:	0085171b          	slliw	a4,a0,0x8
    80005ea4:	0c0027b7          	lui	a5,0xc002
    80005ea8:	97ba                	add	a5,a5,a4
    80005eaa:	40200713          	li	a4,1026
    80005eae:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005eb2:	00d5151b          	slliw	a0,a0,0xd
    80005eb6:	0c2017b7          	lui	a5,0xc201
    80005eba:	953e                	add	a0,a0,a5
    80005ebc:	00052023          	sw	zero,0(a0)
}
    80005ec0:	60a2                	ld	ra,8(sp)
    80005ec2:	6402                	ld	s0,0(sp)
    80005ec4:	0141                	addi	sp,sp,16
    80005ec6:	8082                	ret

0000000080005ec8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005ec8:	1141                	addi	sp,sp,-16
    80005eca:	e406                	sd	ra,8(sp)
    80005ecc:	e022                	sd	s0,0(sp)
    80005ece:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005ed0:	ffffc097          	auipc	ra,0xffffc
    80005ed4:	c16080e7          	jalr	-1002(ra) # 80001ae6 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005ed8:	00d5179b          	slliw	a5,a0,0xd
    80005edc:	0c201537          	lui	a0,0xc201
    80005ee0:	953e                	add	a0,a0,a5
  return irq;
}
    80005ee2:	4148                	lw	a0,4(a0)
    80005ee4:	60a2                	ld	ra,8(sp)
    80005ee6:	6402                	ld	s0,0(sp)
    80005ee8:	0141                	addi	sp,sp,16
    80005eea:	8082                	ret

0000000080005eec <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005eec:	1101                	addi	sp,sp,-32
    80005eee:	ec06                	sd	ra,24(sp)
    80005ef0:	e822                	sd	s0,16(sp)
    80005ef2:	e426                	sd	s1,8(sp)
    80005ef4:	1000                	addi	s0,sp,32
    80005ef6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005ef8:	ffffc097          	auipc	ra,0xffffc
    80005efc:	bee080e7          	jalr	-1042(ra) # 80001ae6 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005f00:	00d5151b          	slliw	a0,a0,0xd
    80005f04:	0c2017b7          	lui	a5,0xc201
    80005f08:	97aa                	add	a5,a5,a0
    80005f0a:	c3c4                	sw	s1,4(a5)
}
    80005f0c:	60e2                	ld	ra,24(sp)
    80005f0e:	6442                	ld	s0,16(sp)
    80005f10:	64a2                	ld	s1,8(sp)
    80005f12:	6105                	addi	sp,sp,32
    80005f14:	8082                	ret

0000000080005f16 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005f16:	1141                	addi	sp,sp,-16
    80005f18:	e406                	sd	ra,8(sp)
    80005f1a:	e022                	sd	s0,0(sp)
    80005f1c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005f1e:	479d                	li	a5,7
    80005f20:	04a7cc63          	blt	a5,a0,80005f78 <free_desc+0x62>
    panic("virtio_disk_intr 1");
  if(disk.free[i])
    80005f24:	0001d797          	auipc	a5,0x1d
    80005f28:	0dc78793          	addi	a5,a5,220 # 80023000 <disk>
    80005f2c:	00a78733          	add	a4,a5,a0
    80005f30:	6789                	lui	a5,0x2
    80005f32:	97ba                	add	a5,a5,a4
    80005f34:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005f38:	eba1                	bnez	a5,80005f88 <free_desc+0x72>
    panic("virtio_disk_intr 2");
  disk.desc[i].addr = 0;
    80005f3a:	00451713          	slli	a4,a0,0x4
    80005f3e:	0001f797          	auipc	a5,0x1f
    80005f42:	0c27b783          	ld	a5,194(a5) # 80025000 <disk+0x2000>
    80005f46:	97ba                	add	a5,a5,a4
    80005f48:	0007b023          	sd	zero,0(a5)
  disk.free[i] = 1;
    80005f4c:	0001d797          	auipc	a5,0x1d
    80005f50:	0b478793          	addi	a5,a5,180 # 80023000 <disk>
    80005f54:	97aa                	add	a5,a5,a0
    80005f56:	6509                	lui	a0,0x2
    80005f58:	953e                	add	a0,a0,a5
    80005f5a:	4785                	li	a5,1
    80005f5c:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005f60:	0001f517          	auipc	a0,0x1f
    80005f64:	0b850513          	addi	a0,a0,184 # 80025018 <disk+0x2018>
    80005f68:	ffffc097          	auipc	ra,0xffffc
    80005f6c:	658080e7          	jalr	1624(ra) # 800025c0 <wakeup>
}
    80005f70:	60a2                	ld	ra,8(sp)
    80005f72:	6402                	ld	s0,0(sp)
    80005f74:	0141                	addi	sp,sp,16
    80005f76:	8082                	ret
    panic("virtio_disk_intr 1");
    80005f78:	00003517          	auipc	a0,0x3
    80005f7c:	86050513          	addi	a0,a0,-1952 # 800087d8 <syscalls+0x328>
    80005f80:	ffffa097          	auipc	ra,0xffffa
    80005f84:	5c8080e7          	jalr	1480(ra) # 80000548 <panic>
    panic("virtio_disk_intr 2");
    80005f88:	00003517          	auipc	a0,0x3
    80005f8c:	86850513          	addi	a0,a0,-1944 # 800087f0 <syscalls+0x340>
    80005f90:	ffffa097          	auipc	ra,0xffffa
    80005f94:	5b8080e7          	jalr	1464(ra) # 80000548 <panic>

0000000080005f98 <virtio_disk_init>:
{
    80005f98:	1101                	addi	sp,sp,-32
    80005f9a:	ec06                	sd	ra,24(sp)
    80005f9c:	e822                	sd	s0,16(sp)
    80005f9e:	e426                	sd	s1,8(sp)
    80005fa0:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005fa2:	00003597          	auipc	a1,0x3
    80005fa6:	86658593          	addi	a1,a1,-1946 # 80008808 <syscalls+0x358>
    80005faa:	0001f517          	auipc	a0,0x1f
    80005fae:	0fe50513          	addi	a0,a0,254 # 800250a8 <disk+0x20a8>
    80005fb2:	ffffb097          	auipc	ra,0xffffb
    80005fb6:	be8080e7          	jalr	-1048(ra) # 80000b9a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005fba:	100017b7          	lui	a5,0x10001
    80005fbe:	4398                	lw	a4,0(a5)
    80005fc0:	2701                	sext.w	a4,a4
    80005fc2:	747277b7          	lui	a5,0x74727
    80005fc6:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005fca:	0ef71163          	bne	a4,a5,800060ac <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005fce:	100017b7          	lui	a5,0x10001
    80005fd2:	43dc                	lw	a5,4(a5)
    80005fd4:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005fd6:	4705                	li	a4,1
    80005fd8:	0ce79a63          	bne	a5,a4,800060ac <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005fdc:	100017b7          	lui	a5,0x10001
    80005fe0:	479c                	lw	a5,8(a5)
    80005fe2:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005fe4:	4709                	li	a4,2
    80005fe6:	0ce79363          	bne	a5,a4,800060ac <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005fea:	100017b7          	lui	a5,0x10001
    80005fee:	47d8                	lw	a4,12(a5)
    80005ff0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005ff2:	554d47b7          	lui	a5,0x554d4
    80005ff6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005ffa:	0af71963          	bne	a4,a5,800060ac <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ffe:	100017b7          	lui	a5,0x10001
    80006002:	4705                	li	a4,1
    80006004:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006006:	470d                	li	a4,3
    80006008:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000600a:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    8000600c:	c7ffe737          	lui	a4,0xc7ffe
    80006010:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd773f>
    80006014:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006016:	2701                	sext.w	a4,a4
    80006018:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000601a:	472d                	li	a4,11
    8000601c:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000601e:	473d                	li	a4,15
    80006020:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006022:	6705                	lui	a4,0x1
    80006024:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006026:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000602a:	5bdc                	lw	a5,52(a5)
    8000602c:	2781                	sext.w	a5,a5
  if(max == 0)
    8000602e:	c7d9                	beqz	a5,800060bc <virtio_disk_init+0x124>
  if(max < NUM)
    80006030:	471d                	li	a4,7
    80006032:	08f77d63          	bgeu	a4,a5,800060cc <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006036:	100014b7          	lui	s1,0x10001
    8000603a:	47a1                	li	a5,8
    8000603c:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    8000603e:	6609                	lui	a2,0x2
    80006040:	4581                	li	a1,0
    80006042:	0001d517          	auipc	a0,0x1d
    80006046:	fbe50513          	addi	a0,a0,-66 # 80023000 <disk>
    8000604a:	ffffb097          	auipc	ra,0xffffb
    8000604e:	cdc080e7          	jalr	-804(ra) # 80000d26 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80006052:	0001d717          	auipc	a4,0x1d
    80006056:	fae70713          	addi	a4,a4,-82 # 80023000 <disk>
    8000605a:	00c75793          	srli	a5,a4,0xc
    8000605e:	2781                	sext.w	a5,a5
    80006060:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct VRingDesc *) disk.pages;
    80006062:	0001f797          	auipc	a5,0x1f
    80006066:	f9e78793          	addi	a5,a5,-98 # 80025000 <disk+0x2000>
    8000606a:	e398                	sd	a4,0(a5)
  disk.avail = (uint16*)(((char*)disk.desc) + NUM*sizeof(struct VRingDesc));
    8000606c:	0001d717          	auipc	a4,0x1d
    80006070:	01470713          	addi	a4,a4,20 # 80023080 <disk+0x80>
    80006074:	e798                	sd	a4,8(a5)
  disk.used = (struct UsedArea *) (disk.pages + PGSIZE);
    80006076:	0001e717          	auipc	a4,0x1e
    8000607a:	f8a70713          	addi	a4,a4,-118 # 80024000 <disk+0x1000>
    8000607e:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80006080:	4705                	li	a4,1
    80006082:	00e78c23          	sb	a4,24(a5)
    80006086:	00e78ca3          	sb	a4,25(a5)
    8000608a:	00e78d23          	sb	a4,26(a5)
    8000608e:	00e78da3          	sb	a4,27(a5)
    80006092:	00e78e23          	sb	a4,28(a5)
    80006096:	00e78ea3          	sb	a4,29(a5)
    8000609a:	00e78f23          	sb	a4,30(a5)
    8000609e:	00e78fa3          	sb	a4,31(a5)
}
    800060a2:	60e2                	ld	ra,24(sp)
    800060a4:	6442                	ld	s0,16(sp)
    800060a6:	64a2                	ld	s1,8(sp)
    800060a8:	6105                	addi	sp,sp,32
    800060aa:	8082                	ret
    panic("could not find virtio disk");
    800060ac:	00002517          	auipc	a0,0x2
    800060b0:	76c50513          	addi	a0,a0,1900 # 80008818 <syscalls+0x368>
    800060b4:	ffffa097          	auipc	ra,0xffffa
    800060b8:	494080e7          	jalr	1172(ra) # 80000548 <panic>
    panic("virtio disk has no queue 0");
    800060bc:	00002517          	auipc	a0,0x2
    800060c0:	77c50513          	addi	a0,a0,1916 # 80008838 <syscalls+0x388>
    800060c4:	ffffa097          	auipc	ra,0xffffa
    800060c8:	484080e7          	jalr	1156(ra) # 80000548 <panic>
    panic("virtio disk max queue too short");
    800060cc:	00002517          	auipc	a0,0x2
    800060d0:	78c50513          	addi	a0,a0,1932 # 80008858 <syscalls+0x3a8>
    800060d4:	ffffa097          	auipc	ra,0xffffa
    800060d8:	474080e7          	jalr	1140(ra) # 80000548 <panic>

00000000800060dc <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800060dc:	7119                	addi	sp,sp,-128
    800060de:	fc86                	sd	ra,120(sp)
    800060e0:	f8a2                	sd	s0,112(sp)
    800060e2:	f4a6                	sd	s1,104(sp)
    800060e4:	f0ca                	sd	s2,96(sp)
    800060e6:	ecce                	sd	s3,88(sp)
    800060e8:	e8d2                	sd	s4,80(sp)
    800060ea:	e4d6                	sd	s5,72(sp)
    800060ec:	e0da                	sd	s6,64(sp)
    800060ee:	fc5e                	sd	s7,56(sp)
    800060f0:	f862                	sd	s8,48(sp)
    800060f2:	f466                	sd	s9,40(sp)
    800060f4:	f06a                	sd	s10,32(sp)
    800060f6:	0100                	addi	s0,sp,128
    800060f8:	892a                	mv	s2,a0
    800060fa:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800060fc:	00c52c83          	lw	s9,12(a0)
    80006100:	001c9c9b          	slliw	s9,s9,0x1
    80006104:	1c82                	slli	s9,s9,0x20
    80006106:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    8000610a:	0001f517          	auipc	a0,0x1f
    8000610e:	f9e50513          	addi	a0,a0,-98 # 800250a8 <disk+0x20a8>
    80006112:	ffffb097          	auipc	ra,0xffffb
    80006116:	b18080e7          	jalr	-1256(ra) # 80000c2a <acquire>
  for(int i = 0; i < 3; i++){
    8000611a:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000611c:	4c21                	li	s8,8
      disk.free[i] = 0;
    8000611e:	0001db97          	auipc	s7,0x1d
    80006122:	ee2b8b93          	addi	s7,s7,-286 # 80023000 <disk>
    80006126:	6b09                	lui	s6,0x2
  for(int i = 0; i < 3; i++){
    80006128:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    8000612a:	8a4e                	mv	s4,s3
    8000612c:	a051                	j	800061b0 <virtio_disk_rw+0xd4>
      disk.free[i] = 0;
    8000612e:	00fb86b3          	add	a3,s7,a5
    80006132:	96da                	add	a3,a3,s6
    80006134:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80006138:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    8000613a:	0207c563          	bltz	a5,80006164 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    8000613e:	2485                	addiw	s1,s1,1
    80006140:	0711                	addi	a4,a4,4
    80006142:	25548363          	beq	s1,s5,80006388 <virtio_disk_rw+0x2ac>
    idx[i] = alloc_desc();
    80006146:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80006148:	0001f697          	auipc	a3,0x1f
    8000614c:	ed068693          	addi	a3,a3,-304 # 80025018 <disk+0x2018>
    80006150:	87d2                	mv	a5,s4
    if(disk.free[i]){
    80006152:	0006c583          	lbu	a1,0(a3)
    80006156:	fde1                	bnez	a1,8000612e <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006158:	2785                	addiw	a5,a5,1
    8000615a:	0685                	addi	a3,a3,1
    8000615c:	ff879be3          	bne	a5,s8,80006152 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80006160:	57fd                	li	a5,-1
    80006162:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    80006164:	02905a63          	blez	s1,80006198 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80006168:	f9042503          	lw	a0,-112(s0)
    8000616c:	00000097          	auipc	ra,0x0
    80006170:	daa080e7          	jalr	-598(ra) # 80005f16 <free_desc>
      for(int j = 0; j < i; j++)
    80006174:	4785                	li	a5,1
    80006176:	0297d163          	bge	a5,s1,80006198 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    8000617a:	f9442503          	lw	a0,-108(s0)
    8000617e:	00000097          	auipc	ra,0x0
    80006182:	d98080e7          	jalr	-616(ra) # 80005f16 <free_desc>
      for(int j = 0; j < i; j++)
    80006186:	4789                	li	a5,2
    80006188:	0097d863          	bge	a5,s1,80006198 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    8000618c:	f9842503          	lw	a0,-104(s0)
    80006190:	00000097          	auipc	ra,0x0
    80006194:	d86080e7          	jalr	-634(ra) # 80005f16 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006198:	0001f597          	auipc	a1,0x1f
    8000619c:	f1058593          	addi	a1,a1,-240 # 800250a8 <disk+0x20a8>
    800061a0:	0001f517          	auipc	a0,0x1f
    800061a4:	e7850513          	addi	a0,a0,-392 # 80025018 <disk+0x2018>
    800061a8:	ffffc097          	auipc	ra,0xffffc
    800061ac:	292080e7          	jalr	658(ra) # 8000243a <sleep>
  for(int i = 0; i < 3; i++){
    800061b0:	f9040713          	addi	a4,s0,-112
    800061b4:	84ce                	mv	s1,s3
    800061b6:	bf41                	j	80006146 <virtio_disk_rw+0x6a>
    uint32 reserved;
    uint64 sector;
  } buf0;

  if(write)
    buf0.type = VIRTIO_BLK_T_OUT; // write the disk
    800061b8:	4785                	li	a5,1
    800061ba:	f8f42023          	sw	a5,-128(s0)
  else
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
  buf0.reserved = 0;
    800061be:	f8042223          	sw	zero,-124(s0)
  buf0.sector = sector;
    800061c2:	f9943423          	sd	s9,-120(s0)

  // buf0 is on a kernel stack, which is not direct mapped,
  // thus the call to kvmpa().
  disk.desc[idx[0]].addr = (uint64) kvmpa(myproc()->kernelpgtbl, (uint64) &buf0);
    800061c6:	ffffc097          	auipc	ra,0xffffc
    800061ca:	94c080e7          	jalr	-1716(ra) # 80001b12 <myproc>
    800061ce:	f9042983          	lw	s3,-112(s0)
    800061d2:	00499493          	slli	s1,s3,0x4
    800061d6:	0001fa17          	auipc	s4,0x1f
    800061da:	e2aa0a13          	addi	s4,s4,-470 # 80025000 <disk+0x2000>
    800061de:	000a3a83          	ld	s5,0(s4)
    800061e2:	9aa6                	add	s5,s5,s1
    800061e4:	f8040593          	addi	a1,s0,-128
    800061e8:	16853503          	ld	a0,360(a0)
    800061ec:	ffffb097          	auipc	ra,0xffffb
    800061f0:	f16080e7          	jalr	-234(ra) # 80001102 <kvmpa>
    800061f4:	00aab023          	sd	a0,0(s5)
  disk.desc[idx[0]].len = sizeof(buf0);
    800061f8:	000a3783          	ld	a5,0(s4)
    800061fc:	97a6                	add	a5,a5,s1
    800061fe:	4741                	li	a4,16
    80006200:	c798                	sw	a4,8(a5)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006202:	000a3783          	ld	a5,0(s4)
    80006206:	97a6                	add	a5,a5,s1
    80006208:	4705                	li	a4,1
    8000620a:	00e79623          	sh	a4,12(a5)
  disk.desc[idx[0]].next = idx[1];
    8000620e:	f9442703          	lw	a4,-108(s0)
    80006212:	000a3783          	ld	a5,0(s4)
    80006216:	97a6                	add	a5,a5,s1
    80006218:	00e79723          	sh	a4,14(a5)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000621c:	0712                	slli	a4,a4,0x4
    8000621e:	000a3783          	ld	a5,0(s4)
    80006222:	97ba                	add	a5,a5,a4
    80006224:	05890693          	addi	a3,s2,88
    80006228:	e394                	sd	a3,0(a5)
  disk.desc[idx[1]].len = BSIZE;
    8000622a:	000a3783          	ld	a5,0(s4)
    8000622e:	97ba                	add	a5,a5,a4
    80006230:	40000693          	li	a3,1024
    80006234:	c794                	sw	a3,8(a5)
  if(write)
    80006236:	100d0a63          	beqz	s10,8000634a <virtio_disk_rw+0x26e>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    8000623a:	0001f797          	auipc	a5,0x1f
    8000623e:	dc67b783          	ld	a5,-570(a5) # 80025000 <disk+0x2000>
    80006242:	97ba                	add	a5,a5,a4
    80006244:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006248:	0001d517          	auipc	a0,0x1d
    8000624c:	db850513          	addi	a0,a0,-584 # 80023000 <disk>
    80006250:	0001f797          	auipc	a5,0x1f
    80006254:	db078793          	addi	a5,a5,-592 # 80025000 <disk+0x2000>
    80006258:	6394                	ld	a3,0(a5)
    8000625a:	96ba                	add	a3,a3,a4
    8000625c:	00c6d603          	lhu	a2,12(a3)
    80006260:	00166613          	ori	a2,a2,1
    80006264:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80006268:	f9842683          	lw	a3,-104(s0)
    8000626c:	6390                	ld	a2,0(a5)
    8000626e:	9732                	add	a4,a4,a2
    80006270:	00d71723          	sh	a3,14(a4)

  disk.info[idx[0]].status = 0;
    80006274:	20098613          	addi	a2,s3,512
    80006278:	0612                	slli	a2,a2,0x4
    8000627a:	962a                	add	a2,a2,a0
    8000627c:	02060823          	sb	zero,48(a2) # 2030 <_entry-0x7fffdfd0>
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006280:	00469713          	slli	a4,a3,0x4
    80006284:	6394                	ld	a3,0(a5)
    80006286:	96ba                	add	a3,a3,a4
    80006288:	6589                	lui	a1,0x2
    8000628a:	03058593          	addi	a1,a1,48 # 2030 <_entry-0x7fffdfd0>
    8000628e:	94ae                	add	s1,s1,a1
    80006290:	94aa                	add	s1,s1,a0
    80006292:	e284                	sd	s1,0(a3)
  disk.desc[idx[2]].len = 1;
    80006294:	6394                	ld	a3,0(a5)
    80006296:	96ba                	add	a3,a3,a4
    80006298:	4585                	li	a1,1
    8000629a:	c68c                	sw	a1,8(a3)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000629c:	6394                	ld	a3,0(a5)
    8000629e:	96ba                	add	a3,a3,a4
    800062a0:	4509                	li	a0,2
    800062a2:	00a69623          	sh	a0,12(a3)
  disk.desc[idx[2]].next = 0;
    800062a6:	6394                	ld	a3,0(a5)
    800062a8:	9736                	add	a4,a4,a3
    800062aa:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800062ae:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    800062b2:	03263423          	sd	s2,40(a2)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk.avail[2 + (disk.avail[1] % NUM)] = idx[0];
    800062b6:	6794                	ld	a3,8(a5)
    800062b8:	0026d703          	lhu	a4,2(a3)
    800062bc:	8b1d                	andi	a4,a4,7
    800062be:	2709                	addiw	a4,a4,2
    800062c0:	0706                	slli	a4,a4,0x1
    800062c2:	9736                	add	a4,a4,a3
    800062c4:	01371023          	sh	s3,0(a4)
  __sync_synchronize();
    800062c8:	0ff0000f          	fence
  disk.avail[1] = disk.avail[1] + 1;
    800062cc:	6798                	ld	a4,8(a5)
    800062ce:	00275783          	lhu	a5,2(a4)
    800062d2:	2785                	addiw	a5,a5,1
    800062d4:	00f71123          	sh	a5,2(a4)

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800062d8:	100017b7          	lui	a5,0x10001
    800062dc:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800062e0:	00492703          	lw	a4,4(s2)
    800062e4:	4785                	li	a5,1
    800062e6:	02f71163          	bne	a4,a5,80006308 <virtio_disk_rw+0x22c>
    sleep(b, &disk.vdisk_lock);
    800062ea:	0001f997          	auipc	s3,0x1f
    800062ee:	dbe98993          	addi	s3,s3,-578 # 800250a8 <disk+0x20a8>
  while(b->disk == 1) {
    800062f2:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800062f4:	85ce                	mv	a1,s3
    800062f6:	854a                	mv	a0,s2
    800062f8:	ffffc097          	auipc	ra,0xffffc
    800062fc:	142080e7          	jalr	322(ra) # 8000243a <sleep>
  while(b->disk == 1) {
    80006300:	00492783          	lw	a5,4(s2)
    80006304:	fe9788e3          	beq	a5,s1,800062f4 <virtio_disk_rw+0x218>
  }

  disk.info[idx[0]].b = 0;
    80006308:	f9042483          	lw	s1,-112(s0)
    8000630c:	20048793          	addi	a5,s1,512 # 10001200 <_entry-0x6fffee00>
    80006310:	00479713          	slli	a4,a5,0x4
    80006314:	0001d797          	auipc	a5,0x1d
    80006318:	cec78793          	addi	a5,a5,-788 # 80023000 <disk>
    8000631c:	97ba                	add	a5,a5,a4
    8000631e:	0207b423          	sd	zero,40(a5)
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    80006322:	0001f917          	auipc	s2,0x1f
    80006326:	cde90913          	addi	s2,s2,-802 # 80025000 <disk+0x2000>
    free_desc(i);
    8000632a:	8526                	mv	a0,s1
    8000632c:	00000097          	auipc	ra,0x0
    80006330:	bea080e7          	jalr	-1046(ra) # 80005f16 <free_desc>
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    80006334:	0492                	slli	s1,s1,0x4
    80006336:	00093783          	ld	a5,0(s2)
    8000633a:	94be                	add	s1,s1,a5
    8000633c:	00c4d783          	lhu	a5,12(s1)
    80006340:	8b85                	andi	a5,a5,1
    80006342:	cf89                	beqz	a5,8000635c <virtio_disk_rw+0x280>
      i = disk.desc[i].next;
    80006344:	00e4d483          	lhu	s1,14(s1)
    free_desc(i);
    80006348:	b7cd                	j	8000632a <virtio_disk_rw+0x24e>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000634a:	0001f797          	auipc	a5,0x1f
    8000634e:	cb67b783          	ld	a5,-842(a5) # 80025000 <disk+0x2000>
    80006352:	97ba                	add	a5,a5,a4
    80006354:	4689                	li	a3,2
    80006356:	00d79623          	sh	a3,12(a5)
    8000635a:	b5fd                	j	80006248 <virtio_disk_rw+0x16c>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000635c:	0001f517          	auipc	a0,0x1f
    80006360:	d4c50513          	addi	a0,a0,-692 # 800250a8 <disk+0x20a8>
    80006364:	ffffb097          	auipc	ra,0xffffb
    80006368:	97a080e7          	jalr	-1670(ra) # 80000cde <release>
}
    8000636c:	70e6                	ld	ra,120(sp)
    8000636e:	7446                	ld	s0,112(sp)
    80006370:	74a6                	ld	s1,104(sp)
    80006372:	7906                	ld	s2,96(sp)
    80006374:	69e6                	ld	s3,88(sp)
    80006376:	6a46                	ld	s4,80(sp)
    80006378:	6aa6                	ld	s5,72(sp)
    8000637a:	6b06                	ld	s6,64(sp)
    8000637c:	7be2                	ld	s7,56(sp)
    8000637e:	7c42                	ld	s8,48(sp)
    80006380:	7ca2                	ld	s9,40(sp)
    80006382:	7d02                	ld	s10,32(sp)
    80006384:	6109                	addi	sp,sp,128
    80006386:	8082                	ret
  if(write)
    80006388:	e20d18e3          	bnez	s10,800061b8 <virtio_disk_rw+0xdc>
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
    8000638c:	f8042023          	sw	zero,-128(s0)
    80006390:	b53d                	j	800061be <virtio_disk_rw+0xe2>

0000000080006392 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006392:	1101                	addi	sp,sp,-32
    80006394:	ec06                	sd	ra,24(sp)
    80006396:	e822                	sd	s0,16(sp)
    80006398:	e426                	sd	s1,8(sp)
    8000639a:	e04a                	sd	s2,0(sp)
    8000639c:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000639e:	0001f517          	auipc	a0,0x1f
    800063a2:	d0a50513          	addi	a0,a0,-758 # 800250a8 <disk+0x20a8>
    800063a6:	ffffb097          	auipc	ra,0xffffb
    800063aa:	884080e7          	jalr	-1916(ra) # 80000c2a <acquire>

  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    800063ae:	0001f717          	auipc	a4,0x1f
    800063b2:	c5270713          	addi	a4,a4,-942 # 80025000 <disk+0x2000>
    800063b6:	02075783          	lhu	a5,32(a4)
    800063ba:	6b18                	ld	a4,16(a4)
    800063bc:	00275683          	lhu	a3,2(a4)
    800063c0:	8ebd                	xor	a3,a3,a5
    800063c2:	8a9d                	andi	a3,a3,7
    800063c4:	cab9                	beqz	a3,8000641a <virtio_disk_intr+0x88>
    int id = disk.used->elems[disk.used_idx].id;

    if(disk.info[id].status != 0)
    800063c6:	0001d917          	auipc	s2,0x1d
    800063ca:	c3a90913          	addi	s2,s2,-966 # 80023000 <disk>
      panic("virtio_disk_intr status");
    
    disk.info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk.info[id].b);

    disk.used_idx = (disk.used_idx + 1) % NUM;
    800063ce:	0001f497          	auipc	s1,0x1f
    800063d2:	c3248493          	addi	s1,s1,-974 # 80025000 <disk+0x2000>
    int id = disk.used->elems[disk.used_idx].id;
    800063d6:	078e                	slli	a5,a5,0x3
    800063d8:	97ba                	add	a5,a5,a4
    800063da:	43dc                	lw	a5,4(a5)
    if(disk.info[id].status != 0)
    800063dc:	20078713          	addi	a4,a5,512
    800063e0:	0712                	slli	a4,a4,0x4
    800063e2:	974a                	add	a4,a4,s2
    800063e4:	03074703          	lbu	a4,48(a4)
    800063e8:	ef21                	bnez	a4,80006440 <virtio_disk_intr+0xae>
    disk.info[id].b->disk = 0;   // disk is done with buf
    800063ea:	20078793          	addi	a5,a5,512
    800063ee:	0792                	slli	a5,a5,0x4
    800063f0:	97ca                	add	a5,a5,s2
    800063f2:	7798                	ld	a4,40(a5)
    800063f4:	00072223          	sw	zero,4(a4)
    wakeup(disk.info[id].b);
    800063f8:	7788                	ld	a0,40(a5)
    800063fa:	ffffc097          	auipc	ra,0xffffc
    800063fe:	1c6080e7          	jalr	454(ra) # 800025c0 <wakeup>
    disk.used_idx = (disk.used_idx + 1) % NUM;
    80006402:	0204d783          	lhu	a5,32(s1)
    80006406:	2785                	addiw	a5,a5,1
    80006408:	8b9d                	andi	a5,a5,7
    8000640a:	02f49023          	sh	a5,32(s1)
  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    8000640e:	6898                	ld	a4,16(s1)
    80006410:	00275683          	lhu	a3,2(a4)
    80006414:	8a9d                	andi	a3,a3,7
    80006416:	fcf690e3          	bne	a3,a5,800063d6 <virtio_disk_intr+0x44>
  }
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000641a:	10001737          	lui	a4,0x10001
    8000641e:	533c                	lw	a5,96(a4)
    80006420:	8b8d                	andi	a5,a5,3
    80006422:	d37c                	sw	a5,100(a4)

  release(&disk.vdisk_lock);
    80006424:	0001f517          	auipc	a0,0x1f
    80006428:	c8450513          	addi	a0,a0,-892 # 800250a8 <disk+0x20a8>
    8000642c:	ffffb097          	auipc	ra,0xffffb
    80006430:	8b2080e7          	jalr	-1870(ra) # 80000cde <release>
}
    80006434:	60e2                	ld	ra,24(sp)
    80006436:	6442                	ld	s0,16(sp)
    80006438:	64a2                	ld	s1,8(sp)
    8000643a:	6902                	ld	s2,0(sp)
    8000643c:	6105                	addi	sp,sp,32
    8000643e:	8082                	ret
      panic("virtio_disk_intr status");
    80006440:	00002517          	auipc	a0,0x2
    80006444:	43850513          	addi	a0,a0,1080 # 80008878 <syscalls+0x3c8>
    80006448:	ffffa097          	auipc	ra,0xffffa
    8000644c:	100080e7          	jalr	256(ra) # 80000548 <panic>

0000000080006450 <statscopyin>:
  int ncopyin;
  int ncopyinstr;
} stats;

int
statscopyin(char *buf, int sz) {
    80006450:	7179                	addi	sp,sp,-48
    80006452:	f406                	sd	ra,40(sp)
    80006454:	f022                	sd	s0,32(sp)
    80006456:	ec26                	sd	s1,24(sp)
    80006458:	e84a                	sd	s2,16(sp)
    8000645a:	e44e                	sd	s3,8(sp)
    8000645c:	e052                	sd	s4,0(sp)
    8000645e:	1800                	addi	s0,sp,48
    80006460:	892a                	mv	s2,a0
    80006462:	89ae                	mv	s3,a1
  int n;
  n = snprintf(buf, sz, "copyin: %d\n", stats.ncopyin);
    80006464:	00003a17          	auipc	s4,0x3
    80006468:	bc4a0a13          	addi	s4,s4,-1084 # 80009028 <stats>
    8000646c:	000a2683          	lw	a3,0(s4)
    80006470:	00002617          	auipc	a2,0x2
    80006474:	42060613          	addi	a2,a2,1056 # 80008890 <syscalls+0x3e0>
    80006478:	00000097          	auipc	ra,0x0
    8000647c:	2c2080e7          	jalr	706(ra) # 8000673a <snprintf>
    80006480:	84aa                	mv	s1,a0
  n += snprintf(buf+n, sz, "copyinstr: %d\n", stats.ncopyinstr);
    80006482:	004a2683          	lw	a3,4(s4)
    80006486:	00002617          	auipc	a2,0x2
    8000648a:	41a60613          	addi	a2,a2,1050 # 800088a0 <syscalls+0x3f0>
    8000648e:	85ce                	mv	a1,s3
    80006490:	954a                	add	a0,a0,s2
    80006492:	00000097          	auipc	ra,0x0
    80006496:	2a8080e7          	jalr	680(ra) # 8000673a <snprintf>
  return n;
}
    8000649a:	9d25                	addw	a0,a0,s1
    8000649c:	70a2                	ld	ra,40(sp)
    8000649e:	7402                	ld	s0,32(sp)
    800064a0:	64e2                	ld	s1,24(sp)
    800064a2:	6942                	ld	s2,16(sp)
    800064a4:	69a2                	ld	s3,8(sp)
    800064a6:	6a02                	ld	s4,0(sp)
    800064a8:	6145                	addi	sp,sp,48
    800064aa:	8082                	ret

00000000800064ac <copyin_new>:
// Copy from user to kernel.
// Copy len bytes to dst from virtual address srcva in a given page table.
// Return 0 on success, -1 on error.
int
copyin_new(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
    800064ac:	7179                	addi	sp,sp,-48
    800064ae:	f406                	sd	ra,40(sp)
    800064b0:	f022                	sd	s0,32(sp)
    800064b2:	ec26                	sd	s1,24(sp)
    800064b4:	e84a                	sd	s2,16(sp)
    800064b6:	e44e                	sd	s3,8(sp)
    800064b8:	1800                	addi	s0,sp,48
    800064ba:	89ae                	mv	s3,a1
    800064bc:	84b2                	mv	s1,a2
    800064be:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800064c0:	ffffb097          	auipc	ra,0xffffb
    800064c4:	652080e7          	jalr	1618(ra) # 80001b12 <myproc>
  // printf("trace: copyin_new %p, %p, %p, %d\n", r_satp(), dst, srcva, len);
  if (srcva >= p->sz || srcva+len >= p->sz || srcva+len < srcva)
    800064c8:	653c                	ld	a5,72(a0)
    800064ca:	02f4ff63          	bgeu	s1,a5,80006508 <copyin_new+0x5c>
    800064ce:	01248733          	add	a4,s1,s2
    800064d2:	02f77d63          	bgeu	a4,a5,8000650c <copyin_new+0x60>
    800064d6:	02976d63          	bltu	a4,s1,80006510 <copyin_new+0x64>
    return -1;
  memmove((void *) dst, (void *)srcva, len);
    800064da:	0009061b          	sext.w	a2,s2
    800064de:	85a6                	mv	a1,s1
    800064e0:	854e                	mv	a0,s3
    800064e2:	ffffb097          	auipc	ra,0xffffb
    800064e6:	8a4080e7          	jalr	-1884(ra) # 80000d86 <memmove>
  stats.ncopyin++;   // XXX lock
    800064ea:	00003717          	auipc	a4,0x3
    800064ee:	b3e70713          	addi	a4,a4,-1218 # 80009028 <stats>
    800064f2:	431c                	lw	a5,0(a4)
    800064f4:	2785                	addiw	a5,a5,1
    800064f6:	c31c                	sw	a5,0(a4)
  return 0;
    800064f8:	4501                	li	a0,0
}
    800064fa:	70a2                	ld	ra,40(sp)
    800064fc:	7402                	ld	s0,32(sp)
    800064fe:	64e2                	ld	s1,24(sp)
    80006500:	6942                	ld	s2,16(sp)
    80006502:	69a2                	ld	s3,8(sp)
    80006504:	6145                	addi	sp,sp,48
    80006506:	8082                	ret
    return -1;
    80006508:	557d                	li	a0,-1
    8000650a:	bfc5                	j	800064fa <copyin_new+0x4e>
    8000650c:	557d                	li	a0,-1
    8000650e:	b7f5                	j	800064fa <copyin_new+0x4e>
    80006510:	557d                	li	a0,-1
    80006512:	b7e5                	j	800064fa <copyin_new+0x4e>

0000000080006514 <copyinstr_new>:
// Copy bytes to dst from virtual address srcva in a given page table,
// until a '\0', or max.
// Return 0 on success, -1 on error.
int
copyinstr_new(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
    80006514:	7179                	addi	sp,sp,-48
    80006516:	f406                	sd	ra,40(sp)
    80006518:	f022                	sd	s0,32(sp)
    8000651a:	ec26                	sd	s1,24(sp)
    8000651c:	e84a                	sd	s2,16(sp)
    8000651e:	e44e                	sd	s3,8(sp)
    80006520:	1800                	addi	s0,sp,48
    80006522:	89ae                	mv	s3,a1
    80006524:	8932                	mv	s2,a2
    80006526:	84b6                	mv	s1,a3
  // printf("trace: copyinstr_new %p, %p, %p, %d\n", r_satp(), dst, srcva, max);
  struct proc *p = myproc();
    80006528:	ffffb097          	auipc	ra,0xffffb
    8000652c:	5ea080e7          	jalr	1514(ra) # 80001b12 <myproc>
  char *s = (char *) srcva;
  
  stats.ncopyinstr++;   // XXX lock
    80006530:	00003717          	auipc	a4,0x3
    80006534:	af870713          	addi	a4,a4,-1288 # 80009028 <stats>
    80006538:	435c                	lw	a5,4(a4)
    8000653a:	2785                	addiw	a5,a5,1
    8000653c:	c35c                	sw	a5,4(a4)
  for(int i = 0; i < max && srcva + i < p->sz; i++){
    8000653e:	cc85                	beqz	s1,80006576 <copyinstr_new+0x62>
    80006540:	00990833          	add	a6,s2,s1
    80006544:	87ca                	mv	a5,s2
    80006546:	6538                	ld	a4,72(a0)
    80006548:	00e7ff63          	bgeu	a5,a4,80006566 <copyinstr_new+0x52>
    dst[i] = s[i];
    8000654c:	0007c683          	lbu	a3,0(a5)
    80006550:	41278733          	sub	a4,a5,s2
    80006554:	974e                	add	a4,a4,s3
    80006556:	00d70023          	sb	a3,0(a4)
    if(s[i] == '\0')
    8000655a:	c285                	beqz	a3,8000657a <copyinstr_new+0x66>
  for(int i = 0; i < max && srcva + i < p->sz; i++){
    8000655c:	0785                	addi	a5,a5,1
    8000655e:	ff0794e3          	bne	a5,a6,80006546 <copyinstr_new+0x32>
      return 0;
  }
  return -1;
    80006562:	557d                	li	a0,-1
    80006564:	a011                	j	80006568 <copyinstr_new+0x54>
    80006566:	557d                	li	a0,-1
}
    80006568:	70a2                	ld	ra,40(sp)
    8000656a:	7402                	ld	s0,32(sp)
    8000656c:	64e2                	ld	s1,24(sp)
    8000656e:	6942                	ld	s2,16(sp)
    80006570:	69a2                	ld	s3,8(sp)
    80006572:	6145                	addi	sp,sp,48
    80006574:	8082                	ret
  return -1;
    80006576:	557d                	li	a0,-1
    80006578:	bfc5                	j	80006568 <copyinstr_new+0x54>
      return 0;
    8000657a:	4501                	li	a0,0
    8000657c:	b7f5                	j	80006568 <copyinstr_new+0x54>

000000008000657e <statswrite>:
int statscopyin(char*, int);
int statslock(char*, int);
  
int
statswrite(int user_src, uint64 src, int n)
{
    8000657e:	1141                	addi	sp,sp,-16
    80006580:	e422                	sd	s0,8(sp)
    80006582:	0800                	addi	s0,sp,16
  return -1;
}
    80006584:	557d                	li	a0,-1
    80006586:	6422                	ld	s0,8(sp)
    80006588:	0141                	addi	sp,sp,16
    8000658a:	8082                	ret

000000008000658c <statsread>:

int
statsread(int user_dst, uint64 dst, int n)
{
    8000658c:	7179                	addi	sp,sp,-48
    8000658e:	f406                	sd	ra,40(sp)
    80006590:	f022                	sd	s0,32(sp)
    80006592:	ec26                	sd	s1,24(sp)
    80006594:	e84a                	sd	s2,16(sp)
    80006596:	e44e                	sd	s3,8(sp)
    80006598:	e052                	sd	s4,0(sp)
    8000659a:	1800                	addi	s0,sp,48
    8000659c:	892a                	mv	s2,a0
    8000659e:	89ae                	mv	s3,a1
    800065a0:	84b2                	mv	s1,a2
  int m;

  acquire(&stats.lock);
    800065a2:	00020517          	auipc	a0,0x20
    800065a6:	a5e50513          	addi	a0,a0,-1442 # 80026000 <stats>
    800065aa:	ffffa097          	auipc	ra,0xffffa
    800065ae:	680080e7          	jalr	1664(ra) # 80000c2a <acquire>

  if(stats.sz == 0) {
    800065b2:	00021797          	auipc	a5,0x21
    800065b6:	a667a783          	lw	a5,-1434(a5) # 80027018 <stats+0x1018>
    800065ba:	cbb5                	beqz	a5,8000662e <statsread+0xa2>
#endif
#ifdef LAB_LOCK
    stats.sz = statslock(stats.buf, BUFSZ);
#endif
  }
  m = stats.sz - stats.off;
    800065bc:	00021797          	auipc	a5,0x21
    800065c0:	a4478793          	addi	a5,a5,-1468 # 80027000 <stats+0x1000>
    800065c4:	4fd8                	lw	a4,28(a5)
    800065c6:	4f9c                	lw	a5,24(a5)
    800065c8:	9f99                	subw	a5,a5,a4
    800065ca:	0007869b          	sext.w	a3,a5

  if (m > 0) {
    800065ce:	06d05e63          	blez	a3,8000664a <statsread+0xbe>
    if(m > n)
    800065d2:	8a3e                	mv	s4,a5
    800065d4:	00d4d363          	bge	s1,a3,800065da <statsread+0x4e>
    800065d8:	8a26                	mv	s4,s1
    800065da:	000a049b          	sext.w	s1,s4
      m  = n;
    if(either_copyout(user_dst, dst, stats.buf+stats.off, m) != -1) {
    800065de:	86a6                	mv	a3,s1
    800065e0:	00020617          	auipc	a2,0x20
    800065e4:	a3860613          	addi	a2,a2,-1480 # 80026018 <stats+0x18>
    800065e8:	963a                	add	a2,a2,a4
    800065ea:	85ce                	mv	a1,s3
    800065ec:	854a                	mv	a0,s2
    800065ee:	ffffc097          	auipc	ra,0xffffc
    800065f2:	0ae080e7          	jalr	174(ra) # 8000269c <either_copyout>
    800065f6:	57fd                	li	a5,-1
    800065f8:	00f50a63          	beq	a0,a5,8000660c <statsread+0x80>
      stats.off += m;
    800065fc:	00021717          	auipc	a4,0x21
    80006600:	a0470713          	addi	a4,a4,-1532 # 80027000 <stats+0x1000>
    80006604:	4f5c                	lw	a5,28(a4)
    80006606:	014787bb          	addw	a5,a5,s4
    8000660a:	cf5c                	sw	a5,28(a4)
  } else {
    m = -1;
    stats.sz = 0;
    stats.off = 0;
  }
  release(&stats.lock);
    8000660c:	00020517          	auipc	a0,0x20
    80006610:	9f450513          	addi	a0,a0,-1548 # 80026000 <stats>
    80006614:	ffffa097          	auipc	ra,0xffffa
    80006618:	6ca080e7          	jalr	1738(ra) # 80000cde <release>
  return m;
}
    8000661c:	8526                	mv	a0,s1
    8000661e:	70a2                	ld	ra,40(sp)
    80006620:	7402                	ld	s0,32(sp)
    80006622:	64e2                	ld	s1,24(sp)
    80006624:	6942                	ld	s2,16(sp)
    80006626:	69a2                	ld	s3,8(sp)
    80006628:	6a02                	ld	s4,0(sp)
    8000662a:	6145                	addi	sp,sp,48
    8000662c:	8082                	ret
    stats.sz = statscopyin(stats.buf, BUFSZ);
    8000662e:	6585                	lui	a1,0x1
    80006630:	00020517          	auipc	a0,0x20
    80006634:	9e850513          	addi	a0,a0,-1560 # 80026018 <stats+0x18>
    80006638:	00000097          	auipc	ra,0x0
    8000663c:	e18080e7          	jalr	-488(ra) # 80006450 <statscopyin>
    80006640:	00021797          	auipc	a5,0x21
    80006644:	9ca7ac23          	sw	a0,-1576(a5) # 80027018 <stats+0x1018>
    80006648:	bf95                	j	800065bc <statsread+0x30>
    stats.sz = 0;
    8000664a:	00021797          	auipc	a5,0x21
    8000664e:	9b678793          	addi	a5,a5,-1610 # 80027000 <stats+0x1000>
    80006652:	0007ac23          	sw	zero,24(a5)
    stats.off = 0;
    80006656:	0007ae23          	sw	zero,28(a5)
    m = -1;
    8000665a:	54fd                	li	s1,-1
    8000665c:	bf45                	j	8000660c <statsread+0x80>

000000008000665e <statsinit>:

void
statsinit(void)
{
    8000665e:	1141                	addi	sp,sp,-16
    80006660:	e406                	sd	ra,8(sp)
    80006662:	e022                	sd	s0,0(sp)
    80006664:	0800                	addi	s0,sp,16
  initlock(&stats.lock, "stats");
    80006666:	00002597          	auipc	a1,0x2
    8000666a:	24a58593          	addi	a1,a1,586 # 800088b0 <syscalls+0x400>
    8000666e:	00020517          	auipc	a0,0x20
    80006672:	99250513          	addi	a0,a0,-1646 # 80026000 <stats>
    80006676:	ffffa097          	auipc	ra,0xffffa
    8000667a:	524080e7          	jalr	1316(ra) # 80000b9a <initlock>

  devsw[STATS].read = statsread;
    8000667e:	0001b797          	auipc	a5,0x1b
    80006682:	53278793          	addi	a5,a5,1330 # 80021bb0 <devsw>
    80006686:	00000717          	auipc	a4,0x0
    8000668a:	f0670713          	addi	a4,a4,-250 # 8000658c <statsread>
    8000668e:	f398                	sd	a4,32(a5)
  devsw[STATS].write = statswrite;
    80006690:	00000717          	auipc	a4,0x0
    80006694:	eee70713          	addi	a4,a4,-274 # 8000657e <statswrite>
    80006698:	f798                	sd	a4,40(a5)
}
    8000669a:	60a2                	ld	ra,8(sp)
    8000669c:	6402                	ld	s0,0(sp)
    8000669e:	0141                	addi	sp,sp,16
    800066a0:	8082                	ret

00000000800066a2 <sprintint>:
  return 1;
}

static int
sprintint(char *s, int xx, int base, int sign)
{
    800066a2:	1101                	addi	sp,sp,-32
    800066a4:	ec22                	sd	s0,24(sp)
    800066a6:	1000                	addi	s0,sp,32
    800066a8:	882a                	mv	a6,a0
  char buf[16];
  int i, n;
  uint x;

  if(sign && (sign = xx < 0))
    800066aa:	c299                	beqz	a3,800066b0 <sprintint+0xe>
    800066ac:	0805c163          	bltz	a1,8000672e <sprintint+0x8c>
    x = -xx;
  else
    x = xx;
    800066b0:	2581                	sext.w	a1,a1
    800066b2:	4301                	li	t1,0

  i = 0;
    800066b4:	fe040713          	addi	a4,s0,-32
    800066b8:	4501                	li	a0,0
  do {
    buf[i++] = digits[x % base];
    800066ba:	2601                	sext.w	a2,a2
    800066bc:	00002697          	auipc	a3,0x2
    800066c0:	1fc68693          	addi	a3,a3,508 # 800088b8 <digits>
    800066c4:	88aa                	mv	a7,a0
    800066c6:	2505                	addiw	a0,a0,1
    800066c8:	02c5f7bb          	remuw	a5,a1,a2
    800066cc:	1782                	slli	a5,a5,0x20
    800066ce:	9381                	srli	a5,a5,0x20
    800066d0:	97b6                	add	a5,a5,a3
    800066d2:	0007c783          	lbu	a5,0(a5)
    800066d6:	00f70023          	sb	a5,0(a4)
  } while((x /= base) != 0);
    800066da:	0005879b          	sext.w	a5,a1
    800066de:	02c5d5bb          	divuw	a1,a1,a2
    800066e2:	0705                	addi	a4,a4,1
    800066e4:	fec7f0e3          	bgeu	a5,a2,800066c4 <sprintint+0x22>

  if(sign)
    800066e8:	00030b63          	beqz	t1,800066fe <sprintint+0x5c>
    buf[i++] = '-';
    800066ec:	ff040793          	addi	a5,s0,-16
    800066f0:	97aa                	add	a5,a5,a0
    800066f2:	02d00713          	li	a4,45
    800066f6:	fee78823          	sb	a4,-16(a5)
    800066fa:	0028851b          	addiw	a0,a7,2

  n = 0;
  while(--i >= 0)
    800066fe:	02a05c63          	blez	a0,80006736 <sprintint+0x94>
    80006702:	fe040793          	addi	a5,s0,-32
    80006706:	00a78733          	add	a4,a5,a0
    8000670a:	87c2                	mv	a5,a6
    8000670c:	0805                	addi	a6,a6,1
    8000670e:	fff5061b          	addiw	a2,a0,-1
    80006712:	1602                	slli	a2,a2,0x20
    80006714:	9201                	srli	a2,a2,0x20
    80006716:	9642                	add	a2,a2,a6
  *s = c;
    80006718:	fff74683          	lbu	a3,-1(a4)
    8000671c:	00d78023          	sb	a3,0(a5)
  while(--i >= 0)
    80006720:	177d                	addi	a4,a4,-1
    80006722:	0785                	addi	a5,a5,1
    80006724:	fec79ae3          	bne	a5,a2,80006718 <sprintint+0x76>
    n += sputc(s+n, buf[i]);
  return n;
}
    80006728:	6462                	ld	s0,24(sp)
    8000672a:	6105                	addi	sp,sp,32
    8000672c:	8082                	ret
    x = -xx;
    8000672e:	40b005bb          	negw	a1,a1
  if(sign && (sign = xx < 0))
    80006732:	4305                	li	t1,1
    x = -xx;
    80006734:	b741                	j	800066b4 <sprintint+0x12>
  while(--i >= 0)
    80006736:	4501                	li	a0,0
    80006738:	bfc5                	j	80006728 <sprintint+0x86>

000000008000673a <snprintf>:

int
snprintf(char *buf, int sz, char *fmt, ...)
{
    8000673a:	7171                	addi	sp,sp,-176
    8000673c:	fc86                	sd	ra,120(sp)
    8000673e:	f8a2                	sd	s0,112(sp)
    80006740:	f4a6                	sd	s1,104(sp)
    80006742:	f0ca                	sd	s2,96(sp)
    80006744:	ecce                	sd	s3,88(sp)
    80006746:	e8d2                	sd	s4,80(sp)
    80006748:	e4d6                	sd	s5,72(sp)
    8000674a:	e0da                	sd	s6,64(sp)
    8000674c:	fc5e                	sd	s7,56(sp)
    8000674e:	f862                	sd	s8,48(sp)
    80006750:	f466                	sd	s9,40(sp)
    80006752:	f06a                	sd	s10,32(sp)
    80006754:	ec6e                	sd	s11,24(sp)
    80006756:	0100                	addi	s0,sp,128
    80006758:	e414                	sd	a3,8(s0)
    8000675a:	e818                	sd	a4,16(s0)
    8000675c:	ec1c                	sd	a5,24(s0)
    8000675e:	03043023          	sd	a6,32(s0)
    80006762:	03143423          	sd	a7,40(s0)
  va_list ap;
  int i, c;
  int off = 0;
  char *s;

  if (fmt == 0)
    80006766:	ca0d                	beqz	a2,80006798 <snprintf+0x5e>
    80006768:	8baa                	mv	s7,a0
    8000676a:	89ae                	mv	s3,a1
    8000676c:	8a32                	mv	s4,a2
    panic("null fmt");

  va_start(ap, fmt);
    8000676e:	00840793          	addi	a5,s0,8
    80006772:	f8f43423          	sd	a5,-120(s0)
  int off = 0;
    80006776:	4481                	li	s1,0
  for(i = 0; off < sz && (c = fmt[i] & 0xff) != 0; i++){
    80006778:	4901                	li	s2,0
    8000677a:	02b05763          	blez	a1,800067a8 <snprintf+0x6e>
    if(c != '%'){
    8000677e:	02500a93          	li	s5,37
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
    switch(c){
    80006782:	07300b13          	li	s6,115
      off += sprintint(buf+off, va_arg(ap, int), 16, 1);
      break;
    case 's':
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s && off < sz; s++)
    80006786:	02800d93          	li	s11,40
  *s = c;
    8000678a:	02500d13          	li	s10,37
    switch(c){
    8000678e:	07800c93          	li	s9,120
    80006792:	06400c13          	li	s8,100
    80006796:	a01d                	j	800067bc <snprintf+0x82>
    panic("null fmt");
    80006798:	00002517          	auipc	a0,0x2
    8000679c:	88050513          	addi	a0,a0,-1920 # 80008018 <etext+0x18>
    800067a0:	ffffa097          	auipc	ra,0xffffa
    800067a4:	da8080e7          	jalr	-600(ra) # 80000548 <panic>
  int off = 0;
    800067a8:	4481                	li	s1,0
    800067aa:	a86d                	j	80006864 <snprintf+0x12a>
  *s = c;
    800067ac:	009b8733          	add	a4,s7,s1
    800067b0:	00f70023          	sb	a5,0(a4)
      off += sputc(buf+off, c);
    800067b4:	2485                	addiw	s1,s1,1
  for(i = 0; off < sz && (c = fmt[i] & 0xff) != 0; i++){
    800067b6:	2905                	addiw	s2,s2,1
    800067b8:	0b34d663          	bge	s1,s3,80006864 <snprintf+0x12a>
    800067bc:	012a07b3          	add	a5,s4,s2
    800067c0:	0007c783          	lbu	a5,0(a5)
    800067c4:	0007871b          	sext.w	a4,a5
    800067c8:	cfd1                	beqz	a5,80006864 <snprintf+0x12a>
    if(c != '%'){
    800067ca:	ff5711e3          	bne	a4,s5,800067ac <snprintf+0x72>
    c = fmt[++i] & 0xff;
    800067ce:	2905                	addiw	s2,s2,1
    800067d0:	012a07b3          	add	a5,s4,s2
    800067d4:	0007c783          	lbu	a5,0(a5)
    if(c == 0)
    800067d8:	c7d1                	beqz	a5,80006864 <snprintf+0x12a>
    switch(c){
    800067da:	05678c63          	beq	a5,s6,80006832 <snprintf+0xf8>
    800067de:	02fb6763          	bltu	s6,a5,8000680c <snprintf+0xd2>
    800067e2:	0b578763          	beq	a5,s5,80006890 <snprintf+0x156>
    800067e6:	0b879b63          	bne	a5,s8,8000689c <snprintf+0x162>
      off += sprintint(buf+off, va_arg(ap, int), 10, 1);
    800067ea:	f8843783          	ld	a5,-120(s0)
    800067ee:	00878713          	addi	a4,a5,8
    800067f2:	f8e43423          	sd	a4,-120(s0)
    800067f6:	4685                	li	a3,1
    800067f8:	4629                	li	a2,10
    800067fa:	438c                	lw	a1,0(a5)
    800067fc:	009b8533          	add	a0,s7,s1
    80006800:	00000097          	auipc	ra,0x0
    80006804:	ea2080e7          	jalr	-350(ra) # 800066a2 <sprintint>
    80006808:	9ca9                	addw	s1,s1,a0
      break;
    8000680a:	b775                	j	800067b6 <snprintf+0x7c>
    switch(c){
    8000680c:	09979863          	bne	a5,s9,8000689c <snprintf+0x162>
      off += sprintint(buf+off, va_arg(ap, int), 16, 1);
    80006810:	f8843783          	ld	a5,-120(s0)
    80006814:	00878713          	addi	a4,a5,8
    80006818:	f8e43423          	sd	a4,-120(s0)
    8000681c:	4685                	li	a3,1
    8000681e:	4641                	li	a2,16
    80006820:	438c                	lw	a1,0(a5)
    80006822:	009b8533          	add	a0,s7,s1
    80006826:	00000097          	auipc	ra,0x0
    8000682a:	e7c080e7          	jalr	-388(ra) # 800066a2 <sprintint>
    8000682e:	9ca9                	addw	s1,s1,a0
      break;
    80006830:	b759                	j	800067b6 <snprintf+0x7c>
      if((s = va_arg(ap, char*)) == 0)
    80006832:	f8843783          	ld	a5,-120(s0)
    80006836:	00878713          	addi	a4,a5,8
    8000683a:	f8e43423          	sd	a4,-120(s0)
    8000683e:	639c                	ld	a5,0(a5)
    80006840:	c3b1                	beqz	a5,80006884 <snprintf+0x14a>
      for(; *s && off < sz; s++)
    80006842:	0007c703          	lbu	a4,0(a5)
    80006846:	db25                	beqz	a4,800067b6 <snprintf+0x7c>
    80006848:	0134de63          	bge	s1,s3,80006864 <snprintf+0x12a>
    8000684c:	009b86b3          	add	a3,s7,s1
  *s = c;
    80006850:	00e68023          	sb	a4,0(a3)
        off += sputc(buf+off, *s);
    80006854:	2485                	addiw	s1,s1,1
      for(; *s && off < sz; s++)
    80006856:	0785                	addi	a5,a5,1
    80006858:	0007c703          	lbu	a4,0(a5)
    8000685c:	df29                	beqz	a4,800067b6 <snprintf+0x7c>
    8000685e:	0685                	addi	a3,a3,1
    80006860:	fe9998e3          	bne	s3,s1,80006850 <snprintf+0x116>
      off += sputc(buf+off, c);
      break;
    }
  }
  return off;
}
    80006864:	8526                	mv	a0,s1
    80006866:	70e6                	ld	ra,120(sp)
    80006868:	7446                	ld	s0,112(sp)
    8000686a:	74a6                	ld	s1,104(sp)
    8000686c:	7906                	ld	s2,96(sp)
    8000686e:	69e6                	ld	s3,88(sp)
    80006870:	6a46                	ld	s4,80(sp)
    80006872:	6aa6                	ld	s5,72(sp)
    80006874:	6b06                	ld	s6,64(sp)
    80006876:	7be2                	ld	s7,56(sp)
    80006878:	7c42                	ld	s8,48(sp)
    8000687a:	7ca2                	ld	s9,40(sp)
    8000687c:	7d02                	ld	s10,32(sp)
    8000687e:	6de2                	ld	s11,24(sp)
    80006880:	614d                	addi	sp,sp,176
    80006882:	8082                	ret
        s = "(null)";
    80006884:	00001797          	auipc	a5,0x1
    80006888:	78c78793          	addi	a5,a5,1932 # 80008010 <etext+0x10>
      for(; *s && off < sz; s++)
    8000688c:	876e                	mv	a4,s11
    8000688e:	bf6d                	j	80006848 <snprintf+0x10e>
  *s = c;
    80006890:	009b87b3          	add	a5,s7,s1
    80006894:	01a78023          	sb	s10,0(a5)
      off += sputc(buf+off, '%');
    80006898:	2485                	addiw	s1,s1,1
      break;
    8000689a:	bf31                	j	800067b6 <snprintf+0x7c>
  *s = c;
    8000689c:	009b8733          	add	a4,s7,s1
    800068a0:	01a70023          	sb	s10,0(a4)
      off += sputc(buf+off, c);
    800068a4:	0014871b          	addiw	a4,s1,1
  *s = c;
    800068a8:	975e                	add	a4,a4,s7
    800068aa:	00f70023          	sb	a5,0(a4)
      off += sputc(buf+off, c);
    800068ae:	2489                	addiw	s1,s1,2
      break;
    800068b0:	b719                	j	800067b6 <snprintf+0x7c>
	...

0000000080007000 <_trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
	...
