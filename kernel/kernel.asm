
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	93013103          	ld	sp,-1744(sp) # 80008930 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	3c7050ef          	jal	ra,80005bdc <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    8000001c:	7139                	addi	sp,sp,-64
    8000001e:	fc06                	sd	ra,56(sp)
    80000020:	f822                	sd	s0,48(sp)
    80000022:	f426                	sd	s1,40(sp)
    80000024:	f04a                	sd	s2,32(sp)
    80000026:	ec4e                	sd	s3,24(sp)
    80000028:	e852                	sd	s4,16(sp)
    8000002a:	e456                	sd	s5,8(sp)
    8000002c:	0080                	addi	s0,sp,64
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    8000002e:	03451793          	slli	a5,a0,0x34
    80000032:	e3c9                	bnez	a5,800000b4 <kfree+0x98>
    80000034:	84aa                	mv	s1,a0
    80000036:	0002b797          	auipc	a5,0x2b
    8000003a:	21278793          	addi	a5,a5,530 # 8002b248 <end>
    8000003e:	06f56b63          	bltu	a0,a5,800000b4 <kfree+0x98>
    80000042:	47c5                	li	a5,17
    80000044:	07ee                	slli	a5,a5,0x1b
    80000046:	06f57763          	bgeu	a0,a5,800000b4 <kfree+0x98>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    8000004a:	6605                	lui	a2,0x1
    8000004c:	4585                	li	a1,1
    8000004e:	00000097          	auipc	ra,0x0
    80000052:	276080e7          	jalr	630(ra) # 800002c4 <memset>

  r = (struct run*)pa;

  // Ensure not interrupted while getting the CPU ID
  push_off();
    80000056:	00006097          	auipc	ra,0x6
    8000005a:	51e080e7          	jalr	1310(ra) # 80006574 <push_off>
  // Get the ID of the current CPU
  int cpu = cpuid();
    8000005e:	00001097          	auipc	ra,0x1
    80000062:	f1a080e7          	jalr	-230(ra) # 80000f78 <cpuid>
    80000066:	8a2a                	mv	s4,a0
  pop_off();
    80000068:	00006097          	auipc	ra,0x6
    8000006c:	5c8080e7          	jalr	1480(ra) # 80006630 <pop_off>

  acquire(&kmem[cpu].lock);
    80000070:	00009a97          	auipc	s5,0x9
    80000074:	fc0a8a93          	addi	s5,s5,-64 # 80009030 <kmem>
    80000078:	002a1993          	slli	s3,s4,0x2
    8000007c:	01498933          	add	s2,s3,s4
    80000080:	090e                	slli	s2,s2,0x3
    80000082:	9956                	add	s2,s2,s5
    80000084:	854a                	mv	a0,s2
    80000086:	00006097          	auipc	ra,0x6
    8000008a:	53a080e7          	jalr	1338(ra) # 800065c0 <acquire>
  r->next = kmem[cpu].freelist;
    8000008e:	02093783          	ld	a5,32(s2)
    80000092:	e09c                	sd	a5,0(s1)
  kmem[cpu].freelist = r;
    80000094:	02993023          	sd	s1,32(s2)
  release(&kmem[cpu].lock);
    80000098:	854a                	mv	a0,s2
    8000009a:	00006097          	auipc	ra,0x6
    8000009e:	5f6080e7          	jalr	1526(ra) # 80006690 <release>
}
    800000a2:	70e2                	ld	ra,56(sp)
    800000a4:	7442                	ld	s0,48(sp)
    800000a6:	74a2                	ld	s1,40(sp)
    800000a8:	7902                	ld	s2,32(sp)
    800000aa:	69e2                	ld	s3,24(sp)
    800000ac:	6a42                	ld	s4,16(sp)
    800000ae:	6aa2                	ld	s5,8(sp)
    800000b0:	6121                	addi	sp,sp,64
    800000b2:	8082                	ret
    panic("kfree");
    800000b4:	00008517          	auipc	a0,0x8
    800000b8:	f5c50513          	addi	a0,a0,-164 # 80008010 <etext+0x10>
    800000bc:	00006097          	auipc	ra,0x6
    800000c0:	fd0080e7          	jalr	-48(ra) # 8000608c <panic>

00000000800000c4 <freerange>:
{
    800000c4:	7179                	addi	sp,sp,-48
    800000c6:	f406                	sd	ra,40(sp)
    800000c8:	f022                	sd	s0,32(sp)
    800000ca:	ec26                	sd	s1,24(sp)
    800000cc:	e84a                	sd	s2,16(sp)
    800000ce:	e44e                	sd	s3,8(sp)
    800000d0:	e052                	sd	s4,0(sp)
    800000d2:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    800000d4:	6785                	lui	a5,0x1
    800000d6:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    800000da:	94aa                	add	s1,s1,a0
    800000dc:	757d                	lui	a0,0xfffff
    800000de:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800000e0:	94be                	add	s1,s1,a5
    800000e2:	0095ee63          	bltu	a1,s1,800000fe <freerange+0x3a>
    800000e6:	892e                	mv	s2,a1
    kfree(p);
    800000e8:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800000ea:	6985                	lui	s3,0x1
    kfree(p);
    800000ec:	01448533          	add	a0,s1,s4
    800000f0:	00000097          	auipc	ra,0x0
    800000f4:	f2c080e7          	jalr	-212(ra) # 8000001c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800000f8:	94ce                	add	s1,s1,s3
    800000fa:	fe9979e3          	bgeu	s2,s1,800000ec <freerange+0x28>
}
    800000fe:	70a2                	ld	ra,40(sp)
    80000100:	7402                	ld	s0,32(sp)
    80000102:	64e2                	ld	s1,24(sp)
    80000104:	6942                	ld	s2,16(sp)
    80000106:	69a2                	ld	s3,8(sp)
    80000108:	6a02                	ld	s4,0(sp)
    8000010a:	6145                	addi	sp,sp,48
    8000010c:	8082                	ret

000000008000010e <kinit>:
{
    8000010e:	7139                	addi	sp,sp,-64
    80000110:	fc06                	sd	ra,56(sp)
    80000112:	f822                	sd	s0,48(sp)
    80000114:	f426                	sd	s1,40(sp)
    80000116:	f04a                	sd	s2,32(sp)
    80000118:	ec4e                	sd	s3,24(sp)
    8000011a:	e852                	sd	s4,16(sp)
    8000011c:	0080                	addi	s0,sp,64
  for (int i = 0; i < NCPU; i++)
    8000011e:	00009917          	auipc	s2,0x9
    80000122:	f1290913          	addi	s2,s2,-238 # 80009030 <kmem>
    80000126:	4481                	li	s1,0
    snprintf(buf, 10, "kmem_CPU%d", i);
    80000128:	00008a17          	auipc	s4,0x8
    8000012c:	ef0a0a13          	addi	s4,s4,-272 # 80008018 <etext+0x18>
  for (int i = 0; i < NCPU; i++)
    80000130:	49a1                	li	s3,8
    snprintf(buf, 10, "kmem_CPU%d", i);
    80000132:	86a6                	mv	a3,s1
    80000134:	8652                	mv	a2,s4
    80000136:	45a9                	li	a1,10
    80000138:	fc040513          	addi	a0,s0,-64
    8000013c:	00006097          	auipc	ra,0x6
    80000140:	8b6080e7          	jalr	-1866(ra) # 800059f2 <snprintf>
    initlock(&kmem[i].lock, buf);
    80000144:	fc040593          	addi	a1,s0,-64
    80000148:	854a                	mv	a0,s2
    8000014a:	00006097          	auipc	ra,0x6
    8000014e:	5f2080e7          	jalr	1522(ra) # 8000673c <initlock>
  for (int i = 0; i < NCPU; i++)
    80000152:	2485                	addiw	s1,s1,1
    80000154:	02890913          	addi	s2,s2,40
    80000158:	fd349de3          	bne	s1,s3,80000132 <kinit+0x24>
  freerange(end, (void*)PHYSTOP);
    8000015c:	45c5                	li	a1,17
    8000015e:	05ee                	slli	a1,a1,0x1b
    80000160:	0002b517          	auipc	a0,0x2b
    80000164:	0e850513          	addi	a0,a0,232 # 8002b248 <end>
    80000168:	00000097          	auipc	ra,0x0
    8000016c:	f5c080e7          	jalr	-164(ra) # 800000c4 <freerange>
}
    80000170:	70e2                	ld	ra,56(sp)
    80000172:	7442                	ld	s0,48(sp)
    80000174:	74a2                	ld	s1,40(sp)
    80000176:	7902                	ld	s2,32(sp)
    80000178:	69e2                	ld	s3,24(sp)
    8000017a:	6a42                	ld	s4,16(sp)
    8000017c:	6121                	addi	sp,sp,64
    8000017e:	8082                	ret

0000000080000180 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000180:	7139                	addi	sp,sp,-64
    80000182:	fc06                	sd	ra,56(sp)
    80000184:	f822                	sd	s0,48(sp)
    80000186:	f426                	sd	s1,40(sp)
    80000188:	f04a                	sd	s2,32(sp)
    8000018a:	ec4e                	sd	s3,24(sp)
    8000018c:	e852                	sd	s4,16(sp)
    8000018e:	e456                	sd	s5,8(sp)
    80000190:	e05a                	sd	s6,0(sp)
    80000192:	0080                	addi	s0,sp,64
  struct run *r;

  push_off();
    80000194:	00006097          	auipc	ra,0x6
    80000198:	3e0080e7          	jalr	992(ra) # 80006574 <push_off>
  int cpu = cpuid();
    8000019c:	00001097          	auipc	ra,0x1
    800001a0:	ddc080e7          	jalr	-548(ra) # 80000f78 <cpuid>
    800001a4:	84aa                	mv	s1,a0
  pop_off();
    800001a6:	00006097          	auipc	ra,0x6
    800001aa:	48a080e7          	jalr	1162(ra) # 80006630 <pop_off>

  acquire(&kmem[cpu].lock);
    800001ae:	00249793          	slli	a5,s1,0x2
    800001b2:	97a6                	add	a5,a5,s1
    800001b4:	078e                	slli	a5,a5,0x3
    800001b6:	00009917          	auipc	s2,0x9
    800001ba:	e7a90913          	addi	s2,s2,-390 # 80009030 <kmem>
    800001be:	993e                	add	s2,s2,a5
    800001c0:	854a                	mv	a0,s2
    800001c2:	00006097          	auipc	ra,0x6
    800001c6:	3fe080e7          	jalr	1022(ra) # 800065c0 <acquire>
  r = kmem[cpu].freelist;
    800001ca:	02093983          	ld	s3,32(s2)
  if(r)
    800001ce:	02098d63          	beqz	s3,80000208 <kalloc+0x88>
    kmem[cpu].freelist = r->next;
    800001d2:	0009b703          	ld	a4,0(s3) # 1000 <_entry-0x7ffff000>
    800001d6:	02e93023          	sd	a4,32(s2)
    }
    r = kmem[cpu].freelist;
    if (r)
      kmem[cpu].freelist = r->next;
  } // end steal page from other CPU
  release(&kmem[cpu].lock);
    800001da:	854a                	mv	a0,s2
    800001dc:	00006097          	auipc	ra,0x6
    800001e0:	4b4080e7          	jalr	1204(ra) # 80006690 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    800001e4:	6605                	lui	a2,0x1
    800001e6:	4595                	li	a1,5
    800001e8:	854e                	mv	a0,s3
    800001ea:	00000097          	auipc	ra,0x0
    800001ee:	0da080e7          	jalr	218(ra) # 800002c4 <memset>
  return (void*)r;
}
    800001f2:	854e                	mv	a0,s3
    800001f4:	70e2                	ld	ra,56(sp)
    800001f6:	7442                	ld	s0,48(sp)
    800001f8:	74a2                	ld	s1,40(sp)
    800001fa:	7902                	ld	s2,32(sp)
    800001fc:	69e2                	ld	s3,24(sp)
    800001fe:	6a42                	ld	s4,16(sp)
    80000200:	6aa2                	ld	s5,8(sp)
    80000202:	6b02                	ld	s6,0(sp)
    80000204:	6121                	addi	sp,sp,64
    80000206:	8082                	ret
    80000208:	00009a97          	auipc	s5,0x9
    8000020c:	e28a8a93          	addi	s5,s5,-472 # 80009030 <kmem>
    for (int i = 0; i < NCPU; ++i)
    80000210:	4981                	li	s3,0
    80000212:	4b21                	li	s6,8
      if (i == cpu) // can't be itself
    80000214:	09348c63          	beq	s1,s3,800002ac <kalloc+0x12c>
      acquire(&kmem[i].lock);
    80000218:	8a56                	mv	s4,s5
    8000021a:	8556                	mv	a0,s5
    8000021c:	00006097          	auipc	ra,0x6
    80000220:	3a4080e7          	jalr	932(ra) # 800065c0 <acquire>
      tmp = kmem[i].freelist;
    80000224:	020ab603          	ld	a2,32(s5)
      if (tmp == 0) {
    80000228:	ce2d                	beqz	a2,800002a2 <kalloc+0x122>
      tmp = kmem[i].freelist;
    8000022a:	87b2                	mv	a5,a2
    8000022c:	40000713          	li	a4,1024
          if (tmp->next)
    80000230:	86be                	mv	a3,a5
    80000232:	639c                	ld	a5,0(a5)
    80000234:	c781                	beqz	a5,8000023c <kalloc+0xbc>
        for (int j = 0; j < 1024; j++) {
    80000236:	377d                	addiw	a4,a4,-1
    80000238:	ff65                	bnez	a4,80000230 <kalloc+0xb0>
          if (tmp->next)
    8000023a:	86be                	mv	a3,a5
        kmem[cpu].freelist = kmem[i].freelist;
    8000023c:	00009717          	auipc	a4,0x9
    80000240:	df470713          	addi	a4,a4,-524 # 80009030 <kmem>
    80000244:	00249793          	slli	a5,s1,0x2
    80000248:	97a6                	add	a5,a5,s1
    8000024a:	078e                	slli	a5,a5,0x3
    8000024c:	97ba                	add	a5,a5,a4
    8000024e:	f390                	sd	a2,32(a5)
        kmem[i].freelist = tmp->next;
    80000250:	6290                	ld	a2,0(a3)
    80000252:	00299793          	slli	a5,s3,0x2
    80000256:	99be                	add	s3,s3,a5
    80000258:	098e                	slli	s3,s3,0x3
    8000025a:	99ba                	add	s3,s3,a4
    8000025c:	02c9b023          	sd	a2,32(s3)
        tmp->next = 0;
    80000260:	0006b023          	sd	zero,0(a3)
        release(&kmem[i].lock);
    80000264:	8552                	mv	a0,s4
    80000266:	00006097          	auipc	ra,0x6
    8000026a:	42a080e7          	jalr	1066(ra) # 80006690 <release>
    r = kmem[cpu].freelist;
    8000026e:	00249793          	slli	a5,s1,0x2
    80000272:	97a6                	add	a5,a5,s1
    80000274:	078e                	slli	a5,a5,0x3
    80000276:	00009717          	auipc	a4,0x9
    8000027a:	dba70713          	addi	a4,a4,-582 # 80009030 <kmem>
    8000027e:	97ba                	add	a5,a5,a4
    80000280:	0207b983          	ld	s3,32(a5)
    if (r)
    80000284:	02098a63          	beqz	s3,800002b8 <kalloc+0x138>
      kmem[cpu].freelist = r->next;
    80000288:	0009b703          	ld	a4,0(s3)
    8000028c:	00249793          	slli	a5,s1,0x2
    80000290:	94be                	add	s1,s1,a5
    80000292:	048e                	slli	s1,s1,0x3
    80000294:	00009797          	auipc	a5,0x9
    80000298:	d9c78793          	addi	a5,a5,-612 # 80009030 <kmem>
    8000029c:	94be                	add	s1,s1,a5
    8000029e:	f098                	sd	a4,32(s1)
    800002a0:	bf2d                	j	800001da <kalloc+0x5a>
        release(&kmem[i].lock);
    800002a2:	8556                	mv	a0,s5
    800002a4:	00006097          	auipc	ra,0x6
    800002a8:	3ec080e7          	jalr	1004(ra) # 80006690 <release>
    for (int i = 0; i < NCPU; ++i)
    800002ac:	2985                	addiw	s3,s3,1
    800002ae:	028a8a93          	addi	s5,s5,40
    800002b2:	f76991e3          	bne	s3,s6,80000214 <kalloc+0x94>
    800002b6:	bf65                	j	8000026e <kalloc+0xee>
  release(&kmem[cpu].lock);
    800002b8:	854a                	mv	a0,s2
    800002ba:	00006097          	auipc	ra,0x6
    800002be:	3d6080e7          	jalr	982(ra) # 80006690 <release>
  if(r)
    800002c2:	bf05                	j	800001f2 <kalloc+0x72>

00000000800002c4 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    800002c4:	1141                	addi	sp,sp,-16
    800002c6:	e422                	sd	s0,8(sp)
    800002c8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    800002ca:	ce09                	beqz	a2,800002e4 <memset+0x20>
    800002cc:	87aa                	mv	a5,a0
    800002ce:	fff6071b          	addiw	a4,a2,-1
    800002d2:	1702                	slli	a4,a4,0x20
    800002d4:	9301                	srli	a4,a4,0x20
    800002d6:	0705                	addi	a4,a4,1
    800002d8:	972a                	add	a4,a4,a0
    cdst[i] = c;
    800002da:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    800002de:	0785                	addi	a5,a5,1
    800002e0:	fee79de3          	bne	a5,a4,800002da <memset+0x16>
  }
  return dst;
}
    800002e4:	6422                	ld	s0,8(sp)
    800002e6:	0141                	addi	sp,sp,16
    800002e8:	8082                	ret

00000000800002ea <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    800002ea:	1141                	addi	sp,sp,-16
    800002ec:	e422                	sd	s0,8(sp)
    800002ee:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    800002f0:	ca05                	beqz	a2,80000320 <memcmp+0x36>
    800002f2:	fff6069b          	addiw	a3,a2,-1
    800002f6:	1682                	slli	a3,a3,0x20
    800002f8:	9281                	srli	a3,a3,0x20
    800002fa:	0685                	addi	a3,a3,1
    800002fc:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    800002fe:	00054783          	lbu	a5,0(a0)
    80000302:	0005c703          	lbu	a4,0(a1)
    80000306:	00e79863          	bne	a5,a4,80000316 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    8000030a:	0505                	addi	a0,a0,1
    8000030c:	0585                	addi	a1,a1,1
  while(n-- > 0){
    8000030e:	fed518e3          	bne	a0,a3,800002fe <memcmp+0x14>
  }

  return 0;
    80000312:	4501                	li	a0,0
    80000314:	a019                	j	8000031a <memcmp+0x30>
      return *s1 - *s2;
    80000316:	40e7853b          	subw	a0,a5,a4
}
    8000031a:	6422                	ld	s0,8(sp)
    8000031c:	0141                	addi	sp,sp,16
    8000031e:	8082                	ret
  return 0;
    80000320:	4501                	li	a0,0
    80000322:	bfe5                	j	8000031a <memcmp+0x30>

0000000080000324 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000324:	1141                	addi	sp,sp,-16
    80000326:	e422                	sd	s0,8(sp)
    80000328:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    8000032a:	ca0d                	beqz	a2,8000035c <memmove+0x38>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    8000032c:	00a5f963          	bgeu	a1,a0,8000033e <memmove+0x1a>
    80000330:	02061693          	slli	a3,a2,0x20
    80000334:	9281                	srli	a3,a3,0x20
    80000336:	00d58733          	add	a4,a1,a3
    8000033a:	02e56463          	bltu	a0,a4,80000362 <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    8000033e:	fff6079b          	addiw	a5,a2,-1
    80000342:	1782                	slli	a5,a5,0x20
    80000344:	9381                	srli	a5,a5,0x20
    80000346:	0785                	addi	a5,a5,1
    80000348:	97ae                	add	a5,a5,a1
    8000034a:	872a                	mv	a4,a0
      *d++ = *s++;
    8000034c:	0585                	addi	a1,a1,1
    8000034e:	0705                	addi	a4,a4,1
    80000350:	fff5c683          	lbu	a3,-1(a1)
    80000354:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000358:	fef59ae3          	bne	a1,a5,8000034c <memmove+0x28>

  return dst;
}
    8000035c:	6422                	ld	s0,8(sp)
    8000035e:	0141                	addi	sp,sp,16
    80000360:	8082                	ret
    d += n;
    80000362:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000364:	fff6079b          	addiw	a5,a2,-1
    80000368:	1782                	slli	a5,a5,0x20
    8000036a:	9381                	srli	a5,a5,0x20
    8000036c:	fff7c793          	not	a5,a5
    80000370:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000372:	177d                	addi	a4,a4,-1
    80000374:	16fd                	addi	a3,a3,-1
    80000376:	00074603          	lbu	a2,0(a4)
    8000037a:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    8000037e:	fef71ae3          	bne	a4,a5,80000372 <memmove+0x4e>
    80000382:	bfe9                	j	8000035c <memmove+0x38>

0000000080000384 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000384:	1141                	addi	sp,sp,-16
    80000386:	e406                	sd	ra,8(sp)
    80000388:	e022                	sd	s0,0(sp)
    8000038a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    8000038c:	00000097          	auipc	ra,0x0
    80000390:	f98080e7          	jalr	-104(ra) # 80000324 <memmove>
}
    80000394:	60a2                	ld	ra,8(sp)
    80000396:	6402                	ld	s0,0(sp)
    80000398:	0141                	addi	sp,sp,16
    8000039a:	8082                	ret

000000008000039c <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    8000039c:	1141                	addi	sp,sp,-16
    8000039e:	e422                	sd	s0,8(sp)
    800003a0:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    800003a2:	ce11                	beqz	a2,800003be <strncmp+0x22>
    800003a4:	00054783          	lbu	a5,0(a0)
    800003a8:	cf89                	beqz	a5,800003c2 <strncmp+0x26>
    800003aa:	0005c703          	lbu	a4,0(a1)
    800003ae:	00f71a63          	bne	a4,a5,800003c2 <strncmp+0x26>
    n--, p++, q++;
    800003b2:	367d                	addiw	a2,a2,-1
    800003b4:	0505                	addi	a0,a0,1
    800003b6:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    800003b8:	f675                	bnez	a2,800003a4 <strncmp+0x8>
  if(n == 0)
    return 0;
    800003ba:	4501                	li	a0,0
    800003bc:	a809                	j	800003ce <strncmp+0x32>
    800003be:	4501                	li	a0,0
    800003c0:	a039                	j	800003ce <strncmp+0x32>
  if(n == 0)
    800003c2:	ca09                	beqz	a2,800003d4 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    800003c4:	00054503          	lbu	a0,0(a0)
    800003c8:	0005c783          	lbu	a5,0(a1)
    800003cc:	9d1d                	subw	a0,a0,a5
}
    800003ce:	6422                	ld	s0,8(sp)
    800003d0:	0141                	addi	sp,sp,16
    800003d2:	8082                	ret
    return 0;
    800003d4:	4501                	li	a0,0
    800003d6:	bfe5                	j	800003ce <strncmp+0x32>

00000000800003d8 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    800003d8:	1141                	addi	sp,sp,-16
    800003da:	e422                	sd	s0,8(sp)
    800003dc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    800003de:	872a                	mv	a4,a0
    800003e0:	8832                	mv	a6,a2
    800003e2:	367d                	addiw	a2,a2,-1
    800003e4:	01005963          	blez	a6,800003f6 <strncpy+0x1e>
    800003e8:	0705                	addi	a4,a4,1
    800003ea:	0005c783          	lbu	a5,0(a1)
    800003ee:	fef70fa3          	sb	a5,-1(a4)
    800003f2:	0585                	addi	a1,a1,1
    800003f4:	f7f5                	bnez	a5,800003e0 <strncpy+0x8>
    ;
  while(n-- > 0)
    800003f6:	00c05d63          	blez	a2,80000410 <strncpy+0x38>
    800003fa:	86ba                	mv	a3,a4
    *s++ = 0;
    800003fc:	0685                	addi	a3,a3,1
    800003fe:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000402:	fff6c793          	not	a5,a3
    80000406:	9fb9                	addw	a5,a5,a4
    80000408:	010787bb          	addw	a5,a5,a6
    8000040c:	fef048e3          	bgtz	a5,800003fc <strncpy+0x24>
  return os;
}
    80000410:	6422                	ld	s0,8(sp)
    80000412:	0141                	addi	sp,sp,16
    80000414:	8082                	ret

0000000080000416 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000416:	1141                	addi	sp,sp,-16
    80000418:	e422                	sd	s0,8(sp)
    8000041a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    8000041c:	02c05363          	blez	a2,80000442 <safestrcpy+0x2c>
    80000420:	fff6069b          	addiw	a3,a2,-1
    80000424:	1682                	slli	a3,a3,0x20
    80000426:	9281                	srli	a3,a3,0x20
    80000428:	96ae                	add	a3,a3,a1
    8000042a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    8000042c:	00d58963          	beq	a1,a3,8000043e <safestrcpy+0x28>
    80000430:	0585                	addi	a1,a1,1
    80000432:	0785                	addi	a5,a5,1
    80000434:	fff5c703          	lbu	a4,-1(a1)
    80000438:	fee78fa3          	sb	a4,-1(a5)
    8000043c:	fb65                	bnez	a4,8000042c <safestrcpy+0x16>
    ;
  *s = 0;
    8000043e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000442:	6422                	ld	s0,8(sp)
    80000444:	0141                	addi	sp,sp,16
    80000446:	8082                	ret

0000000080000448 <strlen>:

int
strlen(const char *s)
{
    80000448:	1141                	addi	sp,sp,-16
    8000044a:	e422                	sd	s0,8(sp)
    8000044c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    8000044e:	00054783          	lbu	a5,0(a0)
    80000452:	cf91                	beqz	a5,8000046e <strlen+0x26>
    80000454:	0505                	addi	a0,a0,1
    80000456:	87aa                	mv	a5,a0
    80000458:	4685                	li	a3,1
    8000045a:	9e89                	subw	a3,a3,a0
    8000045c:	00f6853b          	addw	a0,a3,a5
    80000460:	0785                	addi	a5,a5,1
    80000462:	fff7c703          	lbu	a4,-1(a5)
    80000466:	fb7d                	bnez	a4,8000045c <strlen+0x14>
    ;
  return n;
}
    80000468:	6422                	ld	s0,8(sp)
    8000046a:	0141                	addi	sp,sp,16
    8000046c:	8082                	ret
  for(n = 0; s[n]; n++)
    8000046e:	4501                	li	a0,0
    80000470:	bfe5                	j	80000468 <strlen+0x20>

0000000080000472 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000472:	1101                	addi	sp,sp,-32
    80000474:	ec06                	sd	ra,24(sp)
    80000476:	e822                	sd	s0,16(sp)
    80000478:	e426                	sd	s1,8(sp)
    8000047a:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    8000047c:	00001097          	auipc	ra,0x1
    80000480:	afc080e7          	jalr	-1284(ra) # 80000f78 <cpuid>
    kcsaninit();
#endif
    __sync_synchronize();
    started = 1;
  } else {
    while(lockfree_read4((int *) &started) == 0)
    80000484:	00009497          	auipc	s1,0x9
    80000488:	b7c48493          	addi	s1,s1,-1156 # 80009000 <started>
  if(cpuid() == 0){
    8000048c:	c531                	beqz	a0,800004d8 <main+0x66>
    while(lockfree_read4((int *) &started) == 0)
    8000048e:	8526                	mv	a0,s1
    80000490:	00006097          	auipc	ra,0x6
    80000494:	342080e7          	jalr	834(ra) # 800067d2 <lockfree_read4>
    80000498:	d97d                	beqz	a0,8000048e <main+0x1c>
      ;
    __sync_synchronize();
    8000049a:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    8000049e:	00001097          	auipc	ra,0x1
    800004a2:	ada080e7          	jalr	-1318(ra) # 80000f78 <cpuid>
    800004a6:	85aa                	mv	a1,a0
    800004a8:	00008517          	auipc	a0,0x8
    800004ac:	b9850513          	addi	a0,a0,-1128 # 80008040 <etext+0x40>
    800004b0:	00006097          	auipc	ra,0x6
    800004b4:	c26080e7          	jalr	-986(ra) # 800060d6 <printf>
    kvminithart();    // turn on paging
    800004b8:	00000097          	auipc	ra,0x0
    800004bc:	0e0080e7          	jalr	224(ra) # 80000598 <kvminithart>
    trapinithart();   // install kernel trap vector
    800004c0:	00001097          	auipc	ra,0x1
    800004c4:	730080e7          	jalr	1840(ra) # 80001bf0 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    800004c8:	00005097          	auipc	ra,0x5
    800004cc:	d68080e7          	jalr	-664(ra) # 80005230 <plicinithart>
  }

  scheduler();        
    800004d0:	00001097          	auipc	ra,0x1
    800004d4:	fde080e7          	jalr	-34(ra) # 800014ae <scheduler>
    consoleinit();
    800004d8:	00006097          	auipc	ra,0x6
    800004dc:	ac6080e7          	jalr	-1338(ra) # 80005f9e <consoleinit>
    statsinit();
    800004e0:	00005097          	auipc	ra,0x5
    800004e4:	436080e7          	jalr	1078(ra) # 80005916 <statsinit>
    printfinit();
    800004e8:	00006097          	auipc	ra,0x6
    800004ec:	dd4080e7          	jalr	-556(ra) # 800062bc <printfinit>
    printf("\n");
    800004f0:	00008517          	auipc	a0,0x8
    800004f4:	38850513          	addi	a0,a0,904 # 80008878 <digits+0x88>
    800004f8:	00006097          	auipc	ra,0x6
    800004fc:	bde080e7          	jalr	-1058(ra) # 800060d6 <printf>
    printf("xv6 kernel is booting\n");
    80000500:	00008517          	auipc	a0,0x8
    80000504:	b2850513          	addi	a0,a0,-1240 # 80008028 <etext+0x28>
    80000508:	00006097          	auipc	ra,0x6
    8000050c:	bce080e7          	jalr	-1074(ra) # 800060d6 <printf>
    printf("\n");
    80000510:	00008517          	auipc	a0,0x8
    80000514:	36850513          	addi	a0,a0,872 # 80008878 <digits+0x88>
    80000518:	00006097          	auipc	ra,0x6
    8000051c:	bbe080e7          	jalr	-1090(ra) # 800060d6 <printf>
    kinit();         // physical page allocator
    80000520:	00000097          	auipc	ra,0x0
    80000524:	bee080e7          	jalr	-1042(ra) # 8000010e <kinit>
    kvminit();       // create kernel page table
    80000528:	00000097          	auipc	ra,0x0
    8000052c:	322080e7          	jalr	802(ra) # 8000084a <kvminit>
    kvminithart();   // turn on paging
    80000530:	00000097          	auipc	ra,0x0
    80000534:	068080e7          	jalr	104(ra) # 80000598 <kvminithart>
    procinit();      // process table
    80000538:	00001097          	auipc	ra,0x1
    8000053c:	990080e7          	jalr	-1648(ra) # 80000ec8 <procinit>
    trapinit();      // trap vectors
    80000540:	00001097          	auipc	ra,0x1
    80000544:	688080e7          	jalr	1672(ra) # 80001bc8 <trapinit>
    trapinithart();  // install kernel trap vector
    80000548:	00001097          	auipc	ra,0x1
    8000054c:	6a8080e7          	jalr	1704(ra) # 80001bf0 <trapinithart>
    plicinit();      // set up interrupt controller
    80000550:	00005097          	auipc	ra,0x5
    80000554:	cca080e7          	jalr	-822(ra) # 8000521a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000558:	00005097          	auipc	ra,0x5
    8000055c:	cd8080e7          	jalr	-808(ra) # 80005230 <plicinithart>
    binit();         // buffer cache
    80000560:	00002097          	auipc	ra,0x2
    80000564:	dd2080e7          	jalr	-558(ra) # 80002332 <binit>
    iinit();         // inode table
    80000568:	00002097          	auipc	ra,0x2
    8000056c:	53a080e7          	jalr	1338(ra) # 80002aa2 <iinit>
    fileinit();      // file table
    80000570:	00003097          	auipc	ra,0x3
    80000574:	4e4080e7          	jalr	1252(ra) # 80003a54 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000578:	00005097          	auipc	ra,0x5
    8000057c:	dda080e7          	jalr	-550(ra) # 80005352 <virtio_disk_init>
    userinit();      // first user process
    80000580:	00001097          	auipc	ra,0x1
    80000584:	cfc080e7          	jalr	-772(ra) # 8000127c <userinit>
    __sync_synchronize();
    80000588:	0ff0000f          	fence
    started = 1;
    8000058c:	4785                	li	a5,1
    8000058e:	00009717          	auipc	a4,0x9
    80000592:	a6f72923          	sw	a5,-1422(a4) # 80009000 <started>
    80000596:	bf2d                	j	800004d0 <main+0x5e>

0000000080000598 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000598:	1141                	addi	sp,sp,-16
    8000059a:	e422                	sd	s0,8(sp)
    8000059c:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    8000059e:	00009797          	auipc	a5,0x9
    800005a2:	a6a7b783          	ld	a5,-1430(a5) # 80009008 <kernel_pagetable>
    800005a6:	83b1                	srli	a5,a5,0xc
    800005a8:	577d                	li	a4,-1
    800005aa:	177e                	slli	a4,a4,0x3f
    800005ac:	8fd9                	or	a5,a5,a4
// supervisor address translation and protection;
// holds the address of the page table.
static inline void 
w_satp(uint64 x)
{
  asm volatile("csrw satp, %0" : : "r" (x));
    800005ae:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    800005b2:	12000073          	sfence.vma
  sfence_vma();
}
    800005b6:	6422                	ld	s0,8(sp)
    800005b8:	0141                	addi	sp,sp,16
    800005ba:	8082                	ret

00000000800005bc <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    800005bc:	7139                	addi	sp,sp,-64
    800005be:	fc06                	sd	ra,56(sp)
    800005c0:	f822                	sd	s0,48(sp)
    800005c2:	f426                	sd	s1,40(sp)
    800005c4:	f04a                	sd	s2,32(sp)
    800005c6:	ec4e                	sd	s3,24(sp)
    800005c8:	e852                	sd	s4,16(sp)
    800005ca:	e456                	sd	s5,8(sp)
    800005cc:	e05a                	sd	s6,0(sp)
    800005ce:	0080                	addi	s0,sp,64
    800005d0:	84aa                	mv	s1,a0
    800005d2:	89ae                	mv	s3,a1
    800005d4:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    800005d6:	57fd                	li	a5,-1
    800005d8:	83e9                	srli	a5,a5,0x1a
    800005da:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    800005dc:	4b31                	li	s6,12
  if(va >= MAXVA)
    800005de:	04b7f263          	bgeu	a5,a1,80000622 <walk+0x66>
    panic("walk");
    800005e2:	00008517          	auipc	a0,0x8
    800005e6:	a7650513          	addi	a0,a0,-1418 # 80008058 <etext+0x58>
    800005ea:	00006097          	auipc	ra,0x6
    800005ee:	aa2080e7          	jalr	-1374(ra) # 8000608c <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    800005f2:	060a8663          	beqz	s5,8000065e <walk+0xa2>
    800005f6:	00000097          	auipc	ra,0x0
    800005fa:	b8a080e7          	jalr	-1142(ra) # 80000180 <kalloc>
    800005fe:	84aa                	mv	s1,a0
    80000600:	c529                	beqz	a0,8000064a <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000602:	6605                	lui	a2,0x1
    80000604:	4581                	li	a1,0
    80000606:	00000097          	auipc	ra,0x0
    8000060a:	cbe080e7          	jalr	-834(ra) # 800002c4 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000060e:	00c4d793          	srli	a5,s1,0xc
    80000612:	07aa                	slli	a5,a5,0xa
    80000614:	0017e793          	ori	a5,a5,1
    80000618:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    8000061c:	3a5d                	addiw	s4,s4,-9
    8000061e:	036a0063          	beq	s4,s6,8000063e <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80000622:	0149d933          	srl	s2,s3,s4
    80000626:	1ff97913          	andi	s2,s2,511
    8000062a:	090e                	slli	s2,s2,0x3
    8000062c:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000062e:	00093483          	ld	s1,0(s2)
    80000632:	0014f793          	andi	a5,s1,1
    80000636:	dfd5                	beqz	a5,800005f2 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000638:	80a9                	srli	s1,s1,0xa
    8000063a:	04b2                	slli	s1,s1,0xc
    8000063c:	b7c5                	j	8000061c <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000063e:	00c9d513          	srli	a0,s3,0xc
    80000642:	1ff57513          	andi	a0,a0,511
    80000646:	050e                	slli	a0,a0,0x3
    80000648:	9526                	add	a0,a0,s1
}
    8000064a:	70e2                	ld	ra,56(sp)
    8000064c:	7442                	ld	s0,48(sp)
    8000064e:	74a2                	ld	s1,40(sp)
    80000650:	7902                	ld	s2,32(sp)
    80000652:	69e2                	ld	s3,24(sp)
    80000654:	6a42                	ld	s4,16(sp)
    80000656:	6aa2                	ld	s5,8(sp)
    80000658:	6b02                	ld	s6,0(sp)
    8000065a:	6121                	addi	sp,sp,64
    8000065c:	8082                	ret
        return 0;
    8000065e:	4501                	li	a0,0
    80000660:	b7ed                	j	8000064a <walk+0x8e>

0000000080000662 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000662:	57fd                	li	a5,-1
    80000664:	83e9                	srli	a5,a5,0x1a
    80000666:	00b7f463          	bgeu	a5,a1,8000066e <walkaddr+0xc>
    return 0;
    8000066a:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000066c:	8082                	ret
{
    8000066e:	1141                	addi	sp,sp,-16
    80000670:	e406                	sd	ra,8(sp)
    80000672:	e022                	sd	s0,0(sp)
    80000674:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000676:	4601                	li	a2,0
    80000678:	00000097          	auipc	ra,0x0
    8000067c:	f44080e7          	jalr	-188(ra) # 800005bc <walk>
  if(pte == 0)
    80000680:	c105                	beqz	a0,800006a0 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80000682:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000684:	0117f693          	andi	a3,a5,17
    80000688:	4745                	li	a4,17
    return 0;
    8000068a:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000068c:	00e68663          	beq	a3,a4,80000698 <walkaddr+0x36>
}
    80000690:	60a2                	ld	ra,8(sp)
    80000692:	6402                	ld	s0,0(sp)
    80000694:	0141                	addi	sp,sp,16
    80000696:	8082                	ret
  pa = PTE2PA(*pte);
    80000698:	00a7d513          	srli	a0,a5,0xa
    8000069c:	0532                	slli	a0,a0,0xc
  return pa;
    8000069e:	bfcd                	j	80000690 <walkaddr+0x2e>
    return 0;
    800006a0:	4501                	li	a0,0
    800006a2:	b7fd                	j	80000690 <walkaddr+0x2e>

00000000800006a4 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800006a4:	715d                	addi	sp,sp,-80
    800006a6:	e486                	sd	ra,72(sp)
    800006a8:	e0a2                	sd	s0,64(sp)
    800006aa:	fc26                	sd	s1,56(sp)
    800006ac:	f84a                	sd	s2,48(sp)
    800006ae:	f44e                	sd	s3,40(sp)
    800006b0:	f052                	sd	s4,32(sp)
    800006b2:	ec56                	sd	s5,24(sp)
    800006b4:	e85a                	sd	s6,16(sp)
    800006b6:	e45e                	sd	s7,8(sp)
    800006b8:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800006ba:	c205                	beqz	a2,800006da <mappages+0x36>
    800006bc:	8aaa                	mv	s5,a0
    800006be:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800006c0:	77fd                	lui	a5,0xfffff
    800006c2:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800006c6:	15fd                	addi	a1,a1,-1
    800006c8:	00c589b3          	add	s3,a1,a2
    800006cc:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    800006d0:	8952                	mv	s2,s4
    800006d2:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800006d6:	6b85                	lui	s7,0x1
    800006d8:	a015                	j	800006fc <mappages+0x58>
    panic("mappages: size");
    800006da:	00008517          	auipc	a0,0x8
    800006de:	98650513          	addi	a0,a0,-1658 # 80008060 <etext+0x60>
    800006e2:	00006097          	auipc	ra,0x6
    800006e6:	9aa080e7          	jalr	-1622(ra) # 8000608c <panic>
      panic("mappages: remap");
    800006ea:	00008517          	auipc	a0,0x8
    800006ee:	98650513          	addi	a0,a0,-1658 # 80008070 <etext+0x70>
    800006f2:	00006097          	auipc	ra,0x6
    800006f6:	99a080e7          	jalr	-1638(ra) # 8000608c <panic>
    a += PGSIZE;
    800006fa:	995e                	add	s2,s2,s7
  for(;;){
    800006fc:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80000700:	4605                	li	a2,1
    80000702:	85ca                	mv	a1,s2
    80000704:	8556                	mv	a0,s5
    80000706:	00000097          	auipc	ra,0x0
    8000070a:	eb6080e7          	jalr	-330(ra) # 800005bc <walk>
    8000070e:	cd19                	beqz	a0,8000072c <mappages+0x88>
    if(*pte & PTE_V)
    80000710:	611c                	ld	a5,0(a0)
    80000712:	8b85                	andi	a5,a5,1
    80000714:	fbf9                	bnez	a5,800006ea <mappages+0x46>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80000716:	80b1                	srli	s1,s1,0xc
    80000718:	04aa                	slli	s1,s1,0xa
    8000071a:	0164e4b3          	or	s1,s1,s6
    8000071e:	0014e493          	ori	s1,s1,1
    80000722:	e104                	sd	s1,0(a0)
    if(a == last)
    80000724:	fd391be3          	bne	s2,s3,800006fa <mappages+0x56>
    pa += PGSIZE;
  }
  return 0;
    80000728:	4501                	li	a0,0
    8000072a:	a011                	j	8000072e <mappages+0x8a>
      return -1;
    8000072c:	557d                	li	a0,-1
}
    8000072e:	60a6                	ld	ra,72(sp)
    80000730:	6406                	ld	s0,64(sp)
    80000732:	74e2                	ld	s1,56(sp)
    80000734:	7942                	ld	s2,48(sp)
    80000736:	79a2                	ld	s3,40(sp)
    80000738:	7a02                	ld	s4,32(sp)
    8000073a:	6ae2                	ld	s5,24(sp)
    8000073c:	6b42                	ld	s6,16(sp)
    8000073e:	6ba2                	ld	s7,8(sp)
    80000740:	6161                	addi	sp,sp,80
    80000742:	8082                	ret

0000000080000744 <kvmmap>:
{
    80000744:	1141                	addi	sp,sp,-16
    80000746:	e406                	sd	ra,8(sp)
    80000748:	e022                	sd	s0,0(sp)
    8000074a:	0800                	addi	s0,sp,16
    8000074c:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000074e:	86b2                	mv	a3,a2
    80000750:	863e                	mv	a2,a5
    80000752:	00000097          	auipc	ra,0x0
    80000756:	f52080e7          	jalr	-174(ra) # 800006a4 <mappages>
    8000075a:	e509                	bnez	a0,80000764 <kvmmap+0x20>
}
    8000075c:	60a2                	ld	ra,8(sp)
    8000075e:	6402                	ld	s0,0(sp)
    80000760:	0141                	addi	sp,sp,16
    80000762:	8082                	ret
    panic("kvmmap");
    80000764:	00008517          	auipc	a0,0x8
    80000768:	91c50513          	addi	a0,a0,-1764 # 80008080 <etext+0x80>
    8000076c:	00006097          	auipc	ra,0x6
    80000770:	920080e7          	jalr	-1760(ra) # 8000608c <panic>

0000000080000774 <kvmmake>:
{
    80000774:	1101                	addi	sp,sp,-32
    80000776:	ec06                	sd	ra,24(sp)
    80000778:	e822                	sd	s0,16(sp)
    8000077a:	e426                	sd	s1,8(sp)
    8000077c:	e04a                	sd	s2,0(sp)
    8000077e:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80000780:	00000097          	auipc	ra,0x0
    80000784:	a00080e7          	jalr	-1536(ra) # 80000180 <kalloc>
    80000788:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000078a:	6605                	lui	a2,0x1
    8000078c:	4581                	li	a1,0
    8000078e:	00000097          	auipc	ra,0x0
    80000792:	b36080e7          	jalr	-1226(ra) # 800002c4 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80000796:	4719                	li	a4,6
    80000798:	6685                	lui	a3,0x1
    8000079a:	10000637          	lui	a2,0x10000
    8000079e:	100005b7          	lui	a1,0x10000
    800007a2:	8526                	mv	a0,s1
    800007a4:	00000097          	auipc	ra,0x0
    800007a8:	fa0080e7          	jalr	-96(ra) # 80000744 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800007ac:	4719                	li	a4,6
    800007ae:	6685                	lui	a3,0x1
    800007b0:	10001637          	lui	a2,0x10001
    800007b4:	100015b7          	lui	a1,0x10001
    800007b8:	8526                	mv	a0,s1
    800007ba:	00000097          	auipc	ra,0x0
    800007be:	f8a080e7          	jalr	-118(ra) # 80000744 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800007c2:	4719                	li	a4,6
    800007c4:	004006b7          	lui	a3,0x400
    800007c8:	0c000637          	lui	a2,0xc000
    800007cc:	0c0005b7          	lui	a1,0xc000
    800007d0:	8526                	mv	a0,s1
    800007d2:	00000097          	auipc	ra,0x0
    800007d6:	f72080e7          	jalr	-142(ra) # 80000744 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800007da:	00008917          	auipc	s2,0x8
    800007de:	82690913          	addi	s2,s2,-2010 # 80008000 <etext>
    800007e2:	4729                	li	a4,10
    800007e4:	80008697          	auipc	a3,0x80008
    800007e8:	81c68693          	addi	a3,a3,-2020 # 8000 <_entry-0x7fff8000>
    800007ec:	4605                	li	a2,1
    800007ee:	067e                	slli	a2,a2,0x1f
    800007f0:	85b2                	mv	a1,a2
    800007f2:	8526                	mv	a0,s1
    800007f4:	00000097          	auipc	ra,0x0
    800007f8:	f50080e7          	jalr	-176(ra) # 80000744 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800007fc:	4719                	li	a4,6
    800007fe:	46c5                	li	a3,17
    80000800:	06ee                	slli	a3,a3,0x1b
    80000802:	412686b3          	sub	a3,a3,s2
    80000806:	864a                	mv	a2,s2
    80000808:	85ca                	mv	a1,s2
    8000080a:	8526                	mv	a0,s1
    8000080c:	00000097          	auipc	ra,0x0
    80000810:	f38080e7          	jalr	-200(ra) # 80000744 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80000814:	4729                	li	a4,10
    80000816:	6685                	lui	a3,0x1
    80000818:	00006617          	auipc	a2,0x6
    8000081c:	7e860613          	addi	a2,a2,2024 # 80007000 <_trampoline>
    80000820:	040005b7          	lui	a1,0x4000
    80000824:	15fd                	addi	a1,a1,-1
    80000826:	05b2                	slli	a1,a1,0xc
    80000828:	8526                	mv	a0,s1
    8000082a:	00000097          	auipc	ra,0x0
    8000082e:	f1a080e7          	jalr	-230(ra) # 80000744 <kvmmap>
  proc_mapstacks(kpgtbl);
    80000832:	8526                	mv	a0,s1
    80000834:	00000097          	auipc	ra,0x0
    80000838:	5fe080e7          	jalr	1534(ra) # 80000e32 <proc_mapstacks>
}
    8000083c:	8526                	mv	a0,s1
    8000083e:	60e2                	ld	ra,24(sp)
    80000840:	6442                	ld	s0,16(sp)
    80000842:	64a2                	ld	s1,8(sp)
    80000844:	6902                	ld	s2,0(sp)
    80000846:	6105                	addi	sp,sp,32
    80000848:	8082                	ret

000000008000084a <kvminit>:
{
    8000084a:	1141                	addi	sp,sp,-16
    8000084c:	e406                	sd	ra,8(sp)
    8000084e:	e022                	sd	s0,0(sp)
    80000850:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80000852:	00000097          	auipc	ra,0x0
    80000856:	f22080e7          	jalr	-222(ra) # 80000774 <kvmmake>
    8000085a:	00008797          	auipc	a5,0x8
    8000085e:	7aa7b723          	sd	a0,1966(a5) # 80009008 <kernel_pagetable>
}
    80000862:	60a2                	ld	ra,8(sp)
    80000864:	6402                	ld	s0,0(sp)
    80000866:	0141                	addi	sp,sp,16
    80000868:	8082                	ret

000000008000086a <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000086a:	715d                	addi	sp,sp,-80
    8000086c:	e486                	sd	ra,72(sp)
    8000086e:	e0a2                	sd	s0,64(sp)
    80000870:	fc26                	sd	s1,56(sp)
    80000872:	f84a                	sd	s2,48(sp)
    80000874:	f44e                	sd	s3,40(sp)
    80000876:	f052                	sd	s4,32(sp)
    80000878:	ec56                	sd	s5,24(sp)
    8000087a:	e85a                	sd	s6,16(sp)
    8000087c:	e45e                	sd	s7,8(sp)
    8000087e:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80000880:	03459793          	slli	a5,a1,0x34
    80000884:	e795                	bnez	a5,800008b0 <uvmunmap+0x46>
    80000886:	8a2a                	mv	s4,a0
    80000888:	892e                	mv	s2,a1
    8000088a:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000088c:	0632                	slli	a2,a2,0xc
    8000088e:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80000892:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80000894:	6b05                	lui	s6,0x1
    80000896:	0735e863          	bltu	a1,s3,80000906 <uvmunmap+0x9c>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000089a:	60a6                	ld	ra,72(sp)
    8000089c:	6406                	ld	s0,64(sp)
    8000089e:	74e2                	ld	s1,56(sp)
    800008a0:	7942                	ld	s2,48(sp)
    800008a2:	79a2                	ld	s3,40(sp)
    800008a4:	7a02                	ld	s4,32(sp)
    800008a6:	6ae2                	ld	s5,24(sp)
    800008a8:	6b42                	ld	s6,16(sp)
    800008aa:	6ba2                	ld	s7,8(sp)
    800008ac:	6161                	addi	sp,sp,80
    800008ae:	8082                	ret
    panic("uvmunmap: not aligned");
    800008b0:	00007517          	auipc	a0,0x7
    800008b4:	7d850513          	addi	a0,a0,2008 # 80008088 <etext+0x88>
    800008b8:	00005097          	auipc	ra,0x5
    800008bc:	7d4080e7          	jalr	2004(ra) # 8000608c <panic>
      panic("uvmunmap: walk");
    800008c0:	00007517          	auipc	a0,0x7
    800008c4:	7e050513          	addi	a0,a0,2016 # 800080a0 <etext+0xa0>
    800008c8:	00005097          	auipc	ra,0x5
    800008cc:	7c4080e7          	jalr	1988(ra) # 8000608c <panic>
      panic("uvmunmap: not mapped");
    800008d0:	00007517          	auipc	a0,0x7
    800008d4:	7e050513          	addi	a0,a0,2016 # 800080b0 <etext+0xb0>
    800008d8:	00005097          	auipc	ra,0x5
    800008dc:	7b4080e7          	jalr	1972(ra) # 8000608c <panic>
      panic("uvmunmap: not a leaf");
    800008e0:	00007517          	auipc	a0,0x7
    800008e4:	7e850513          	addi	a0,a0,2024 # 800080c8 <etext+0xc8>
    800008e8:	00005097          	auipc	ra,0x5
    800008ec:	7a4080e7          	jalr	1956(ra) # 8000608c <panic>
      uint64 pa = PTE2PA(*pte);
    800008f0:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800008f2:	0532                	slli	a0,a0,0xc
    800008f4:	fffff097          	auipc	ra,0xfffff
    800008f8:	728080e7          	jalr	1832(ra) # 8000001c <kfree>
    *pte = 0;
    800008fc:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80000900:	995a                	add	s2,s2,s6
    80000902:	f9397ce3          	bgeu	s2,s3,8000089a <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    80000906:	4601                	li	a2,0
    80000908:	85ca                	mv	a1,s2
    8000090a:	8552                	mv	a0,s4
    8000090c:	00000097          	auipc	ra,0x0
    80000910:	cb0080e7          	jalr	-848(ra) # 800005bc <walk>
    80000914:	84aa                	mv	s1,a0
    80000916:	d54d                	beqz	a0,800008c0 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80000918:	6108                	ld	a0,0(a0)
    8000091a:	00157793          	andi	a5,a0,1
    8000091e:	dbcd                	beqz	a5,800008d0 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80000920:	3ff57793          	andi	a5,a0,1023
    80000924:	fb778ee3          	beq	a5,s7,800008e0 <uvmunmap+0x76>
    if(do_free){
    80000928:	fc0a8ae3          	beqz	s5,800008fc <uvmunmap+0x92>
    8000092c:	b7d1                	j	800008f0 <uvmunmap+0x86>

000000008000092e <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000092e:	1101                	addi	sp,sp,-32
    80000930:	ec06                	sd	ra,24(sp)
    80000932:	e822                	sd	s0,16(sp)
    80000934:	e426                	sd	s1,8(sp)
    80000936:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80000938:	00000097          	auipc	ra,0x0
    8000093c:	848080e7          	jalr	-1976(ra) # 80000180 <kalloc>
    80000940:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80000942:	c519                	beqz	a0,80000950 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80000944:	6605                	lui	a2,0x1
    80000946:	4581                	li	a1,0
    80000948:	00000097          	auipc	ra,0x0
    8000094c:	97c080e7          	jalr	-1668(ra) # 800002c4 <memset>
  return pagetable;
}
    80000950:	8526                	mv	a0,s1
    80000952:	60e2                	ld	ra,24(sp)
    80000954:	6442                	ld	s0,16(sp)
    80000956:	64a2                	ld	s1,8(sp)
    80000958:	6105                	addi	sp,sp,32
    8000095a:	8082                	ret

000000008000095c <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    8000095c:	7179                	addi	sp,sp,-48
    8000095e:	f406                	sd	ra,40(sp)
    80000960:	f022                	sd	s0,32(sp)
    80000962:	ec26                	sd	s1,24(sp)
    80000964:	e84a                	sd	s2,16(sp)
    80000966:	e44e                	sd	s3,8(sp)
    80000968:	e052                	sd	s4,0(sp)
    8000096a:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000096c:	6785                	lui	a5,0x1
    8000096e:	04f67863          	bgeu	a2,a5,800009be <uvminit+0x62>
    80000972:	8a2a                	mv	s4,a0
    80000974:	89ae                	mv	s3,a1
    80000976:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80000978:	00000097          	auipc	ra,0x0
    8000097c:	808080e7          	jalr	-2040(ra) # 80000180 <kalloc>
    80000980:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80000982:	6605                	lui	a2,0x1
    80000984:	4581                	li	a1,0
    80000986:	00000097          	auipc	ra,0x0
    8000098a:	93e080e7          	jalr	-1730(ra) # 800002c4 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000098e:	4779                	li	a4,30
    80000990:	86ca                	mv	a3,s2
    80000992:	6605                	lui	a2,0x1
    80000994:	4581                	li	a1,0
    80000996:	8552                	mv	a0,s4
    80000998:	00000097          	auipc	ra,0x0
    8000099c:	d0c080e7          	jalr	-756(ra) # 800006a4 <mappages>
  memmove(mem, src, sz);
    800009a0:	8626                	mv	a2,s1
    800009a2:	85ce                	mv	a1,s3
    800009a4:	854a                	mv	a0,s2
    800009a6:	00000097          	auipc	ra,0x0
    800009aa:	97e080e7          	jalr	-1666(ra) # 80000324 <memmove>
}
    800009ae:	70a2                	ld	ra,40(sp)
    800009b0:	7402                	ld	s0,32(sp)
    800009b2:	64e2                	ld	s1,24(sp)
    800009b4:	6942                	ld	s2,16(sp)
    800009b6:	69a2                	ld	s3,8(sp)
    800009b8:	6a02                	ld	s4,0(sp)
    800009ba:	6145                	addi	sp,sp,48
    800009bc:	8082                	ret
    panic("inituvm: more than a page");
    800009be:	00007517          	auipc	a0,0x7
    800009c2:	72250513          	addi	a0,a0,1826 # 800080e0 <etext+0xe0>
    800009c6:	00005097          	auipc	ra,0x5
    800009ca:	6c6080e7          	jalr	1734(ra) # 8000608c <panic>

00000000800009ce <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800009ce:	1101                	addi	sp,sp,-32
    800009d0:	ec06                	sd	ra,24(sp)
    800009d2:	e822                	sd	s0,16(sp)
    800009d4:	e426                	sd	s1,8(sp)
    800009d6:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800009d8:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800009da:	00b67d63          	bgeu	a2,a1,800009f4 <uvmdealloc+0x26>
    800009de:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800009e0:	6785                	lui	a5,0x1
    800009e2:	17fd                	addi	a5,a5,-1
    800009e4:	00f60733          	add	a4,a2,a5
    800009e8:	767d                	lui	a2,0xfffff
    800009ea:	8f71                	and	a4,a4,a2
    800009ec:	97ae                	add	a5,a5,a1
    800009ee:	8ff1                	and	a5,a5,a2
    800009f0:	00f76863          	bltu	a4,a5,80000a00 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800009f4:	8526                	mv	a0,s1
    800009f6:	60e2                	ld	ra,24(sp)
    800009f8:	6442                	ld	s0,16(sp)
    800009fa:	64a2                	ld	s1,8(sp)
    800009fc:	6105                	addi	sp,sp,32
    800009fe:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80000a00:	8f99                	sub	a5,a5,a4
    80000a02:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80000a04:	4685                	li	a3,1
    80000a06:	0007861b          	sext.w	a2,a5
    80000a0a:	85ba                	mv	a1,a4
    80000a0c:	00000097          	auipc	ra,0x0
    80000a10:	e5e080e7          	jalr	-418(ra) # 8000086a <uvmunmap>
    80000a14:	b7c5                	j	800009f4 <uvmdealloc+0x26>

0000000080000a16 <uvmalloc>:
  if(newsz < oldsz)
    80000a16:	0ab66163          	bltu	a2,a1,80000ab8 <uvmalloc+0xa2>
{
    80000a1a:	7139                	addi	sp,sp,-64
    80000a1c:	fc06                	sd	ra,56(sp)
    80000a1e:	f822                	sd	s0,48(sp)
    80000a20:	f426                	sd	s1,40(sp)
    80000a22:	f04a                	sd	s2,32(sp)
    80000a24:	ec4e                	sd	s3,24(sp)
    80000a26:	e852                	sd	s4,16(sp)
    80000a28:	e456                	sd	s5,8(sp)
    80000a2a:	0080                	addi	s0,sp,64
    80000a2c:	8aaa                	mv	s5,a0
    80000a2e:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80000a30:	6985                	lui	s3,0x1
    80000a32:	19fd                	addi	s3,s3,-1
    80000a34:	95ce                	add	a1,a1,s3
    80000a36:	79fd                	lui	s3,0xfffff
    80000a38:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80000a3c:	08c9f063          	bgeu	s3,a2,80000abc <uvmalloc+0xa6>
    80000a40:	894e                	mv	s2,s3
    mem = kalloc();
    80000a42:	fffff097          	auipc	ra,0xfffff
    80000a46:	73e080e7          	jalr	1854(ra) # 80000180 <kalloc>
    80000a4a:	84aa                	mv	s1,a0
    if(mem == 0){
    80000a4c:	c51d                	beqz	a0,80000a7a <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80000a4e:	6605                	lui	a2,0x1
    80000a50:	4581                	li	a1,0
    80000a52:	00000097          	auipc	ra,0x0
    80000a56:	872080e7          	jalr	-1934(ra) # 800002c4 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80000a5a:	4779                	li	a4,30
    80000a5c:	86a6                	mv	a3,s1
    80000a5e:	6605                	lui	a2,0x1
    80000a60:	85ca                	mv	a1,s2
    80000a62:	8556                	mv	a0,s5
    80000a64:	00000097          	auipc	ra,0x0
    80000a68:	c40080e7          	jalr	-960(ra) # 800006a4 <mappages>
    80000a6c:	e905                	bnez	a0,80000a9c <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80000a6e:	6785                	lui	a5,0x1
    80000a70:	993e                	add	s2,s2,a5
    80000a72:	fd4968e3          	bltu	s2,s4,80000a42 <uvmalloc+0x2c>
  return newsz;
    80000a76:	8552                	mv	a0,s4
    80000a78:	a809                	j	80000a8a <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80000a7a:	864e                	mv	a2,s3
    80000a7c:	85ca                	mv	a1,s2
    80000a7e:	8556                	mv	a0,s5
    80000a80:	00000097          	auipc	ra,0x0
    80000a84:	f4e080e7          	jalr	-178(ra) # 800009ce <uvmdealloc>
      return 0;
    80000a88:	4501                	li	a0,0
}
    80000a8a:	70e2                	ld	ra,56(sp)
    80000a8c:	7442                	ld	s0,48(sp)
    80000a8e:	74a2                	ld	s1,40(sp)
    80000a90:	7902                	ld	s2,32(sp)
    80000a92:	69e2                	ld	s3,24(sp)
    80000a94:	6a42                	ld	s4,16(sp)
    80000a96:	6aa2                	ld	s5,8(sp)
    80000a98:	6121                	addi	sp,sp,64
    80000a9a:	8082                	ret
      kfree(mem);
    80000a9c:	8526                	mv	a0,s1
    80000a9e:	fffff097          	auipc	ra,0xfffff
    80000aa2:	57e080e7          	jalr	1406(ra) # 8000001c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80000aa6:	864e                	mv	a2,s3
    80000aa8:	85ca                	mv	a1,s2
    80000aaa:	8556                	mv	a0,s5
    80000aac:	00000097          	auipc	ra,0x0
    80000ab0:	f22080e7          	jalr	-222(ra) # 800009ce <uvmdealloc>
      return 0;
    80000ab4:	4501                	li	a0,0
    80000ab6:	bfd1                	j	80000a8a <uvmalloc+0x74>
    return oldsz;
    80000ab8:	852e                	mv	a0,a1
}
    80000aba:	8082                	ret
  return newsz;
    80000abc:	8532                	mv	a0,a2
    80000abe:	b7f1                	j	80000a8a <uvmalloc+0x74>

0000000080000ac0 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80000ac0:	7179                	addi	sp,sp,-48
    80000ac2:	f406                	sd	ra,40(sp)
    80000ac4:	f022                	sd	s0,32(sp)
    80000ac6:	ec26                	sd	s1,24(sp)
    80000ac8:	e84a                	sd	s2,16(sp)
    80000aca:	e44e                	sd	s3,8(sp)
    80000acc:	e052                	sd	s4,0(sp)
    80000ace:	1800                	addi	s0,sp,48
    80000ad0:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80000ad2:	84aa                	mv	s1,a0
    80000ad4:	6905                	lui	s2,0x1
    80000ad6:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80000ad8:	4985                	li	s3,1
    80000ada:	a821                	j	80000af2 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80000adc:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80000ade:	0532                	slli	a0,a0,0xc
    80000ae0:	00000097          	auipc	ra,0x0
    80000ae4:	fe0080e7          	jalr	-32(ra) # 80000ac0 <freewalk>
      pagetable[i] = 0;
    80000ae8:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80000aec:	04a1                	addi	s1,s1,8
    80000aee:	03248163          	beq	s1,s2,80000b10 <freewalk+0x50>
    pte_t pte = pagetable[i];
    80000af2:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80000af4:	00f57793          	andi	a5,a0,15
    80000af8:	ff3782e3          	beq	a5,s3,80000adc <freewalk+0x1c>
    } else if(pte & PTE_V){
    80000afc:	8905                	andi	a0,a0,1
    80000afe:	d57d                	beqz	a0,80000aec <freewalk+0x2c>
      panic("freewalk: leaf");
    80000b00:	00007517          	auipc	a0,0x7
    80000b04:	60050513          	addi	a0,a0,1536 # 80008100 <etext+0x100>
    80000b08:	00005097          	auipc	ra,0x5
    80000b0c:	584080e7          	jalr	1412(ra) # 8000608c <panic>
    }
  }
  kfree((void*)pagetable);
    80000b10:	8552                	mv	a0,s4
    80000b12:	fffff097          	auipc	ra,0xfffff
    80000b16:	50a080e7          	jalr	1290(ra) # 8000001c <kfree>
}
    80000b1a:	70a2                	ld	ra,40(sp)
    80000b1c:	7402                	ld	s0,32(sp)
    80000b1e:	64e2                	ld	s1,24(sp)
    80000b20:	6942                	ld	s2,16(sp)
    80000b22:	69a2                	ld	s3,8(sp)
    80000b24:	6a02                	ld	s4,0(sp)
    80000b26:	6145                	addi	sp,sp,48
    80000b28:	8082                	ret

0000000080000b2a <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80000b2a:	1101                	addi	sp,sp,-32
    80000b2c:	ec06                	sd	ra,24(sp)
    80000b2e:	e822                	sd	s0,16(sp)
    80000b30:	e426                	sd	s1,8(sp)
    80000b32:	1000                	addi	s0,sp,32
    80000b34:	84aa                	mv	s1,a0
  if(sz > 0)
    80000b36:	e999                	bnez	a1,80000b4c <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80000b38:	8526                	mv	a0,s1
    80000b3a:	00000097          	auipc	ra,0x0
    80000b3e:	f86080e7          	jalr	-122(ra) # 80000ac0 <freewalk>
}
    80000b42:	60e2                	ld	ra,24(sp)
    80000b44:	6442                	ld	s0,16(sp)
    80000b46:	64a2                	ld	s1,8(sp)
    80000b48:	6105                	addi	sp,sp,32
    80000b4a:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80000b4c:	6605                	lui	a2,0x1
    80000b4e:	167d                	addi	a2,a2,-1
    80000b50:	962e                	add	a2,a2,a1
    80000b52:	4685                	li	a3,1
    80000b54:	8231                	srli	a2,a2,0xc
    80000b56:	4581                	li	a1,0
    80000b58:	00000097          	auipc	ra,0x0
    80000b5c:	d12080e7          	jalr	-750(ra) # 8000086a <uvmunmap>
    80000b60:	bfe1                	j	80000b38 <uvmfree+0xe>

0000000080000b62 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80000b62:	c679                	beqz	a2,80000c30 <uvmcopy+0xce>
{
    80000b64:	715d                	addi	sp,sp,-80
    80000b66:	e486                	sd	ra,72(sp)
    80000b68:	e0a2                	sd	s0,64(sp)
    80000b6a:	fc26                	sd	s1,56(sp)
    80000b6c:	f84a                	sd	s2,48(sp)
    80000b6e:	f44e                	sd	s3,40(sp)
    80000b70:	f052                	sd	s4,32(sp)
    80000b72:	ec56                	sd	s5,24(sp)
    80000b74:	e85a                	sd	s6,16(sp)
    80000b76:	e45e                	sd	s7,8(sp)
    80000b78:	0880                	addi	s0,sp,80
    80000b7a:	8b2a                	mv	s6,a0
    80000b7c:	8aae                	mv	s5,a1
    80000b7e:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80000b80:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80000b82:	4601                	li	a2,0
    80000b84:	85ce                	mv	a1,s3
    80000b86:	855a                	mv	a0,s6
    80000b88:	00000097          	auipc	ra,0x0
    80000b8c:	a34080e7          	jalr	-1484(ra) # 800005bc <walk>
    80000b90:	c531                	beqz	a0,80000bdc <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80000b92:	6118                	ld	a4,0(a0)
    80000b94:	00177793          	andi	a5,a4,1
    80000b98:	cbb1                	beqz	a5,80000bec <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80000b9a:	00a75593          	srli	a1,a4,0xa
    80000b9e:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80000ba2:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80000ba6:	fffff097          	auipc	ra,0xfffff
    80000baa:	5da080e7          	jalr	1498(ra) # 80000180 <kalloc>
    80000bae:	892a                	mv	s2,a0
    80000bb0:	c939                	beqz	a0,80000c06 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80000bb2:	6605                	lui	a2,0x1
    80000bb4:	85de                	mv	a1,s7
    80000bb6:	fffff097          	auipc	ra,0xfffff
    80000bba:	76e080e7          	jalr	1902(ra) # 80000324 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80000bbe:	8726                	mv	a4,s1
    80000bc0:	86ca                	mv	a3,s2
    80000bc2:	6605                	lui	a2,0x1
    80000bc4:	85ce                	mv	a1,s3
    80000bc6:	8556                	mv	a0,s5
    80000bc8:	00000097          	auipc	ra,0x0
    80000bcc:	adc080e7          	jalr	-1316(ra) # 800006a4 <mappages>
    80000bd0:	e515                	bnez	a0,80000bfc <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    80000bd2:	6785                	lui	a5,0x1
    80000bd4:	99be                	add	s3,s3,a5
    80000bd6:	fb49e6e3          	bltu	s3,s4,80000b82 <uvmcopy+0x20>
    80000bda:	a081                	j	80000c1a <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    80000bdc:	00007517          	auipc	a0,0x7
    80000be0:	53450513          	addi	a0,a0,1332 # 80008110 <etext+0x110>
    80000be4:	00005097          	auipc	ra,0x5
    80000be8:	4a8080e7          	jalr	1192(ra) # 8000608c <panic>
      panic("uvmcopy: page not present");
    80000bec:	00007517          	auipc	a0,0x7
    80000bf0:	54450513          	addi	a0,a0,1348 # 80008130 <etext+0x130>
    80000bf4:	00005097          	auipc	ra,0x5
    80000bf8:	498080e7          	jalr	1176(ra) # 8000608c <panic>
      kfree(mem);
    80000bfc:	854a                	mv	a0,s2
    80000bfe:	fffff097          	auipc	ra,0xfffff
    80000c02:	41e080e7          	jalr	1054(ra) # 8000001c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80000c06:	4685                	li	a3,1
    80000c08:	00c9d613          	srli	a2,s3,0xc
    80000c0c:	4581                	li	a1,0
    80000c0e:	8556                	mv	a0,s5
    80000c10:	00000097          	auipc	ra,0x0
    80000c14:	c5a080e7          	jalr	-934(ra) # 8000086a <uvmunmap>
  return -1;
    80000c18:	557d                	li	a0,-1
}
    80000c1a:	60a6                	ld	ra,72(sp)
    80000c1c:	6406                	ld	s0,64(sp)
    80000c1e:	74e2                	ld	s1,56(sp)
    80000c20:	7942                	ld	s2,48(sp)
    80000c22:	79a2                	ld	s3,40(sp)
    80000c24:	7a02                	ld	s4,32(sp)
    80000c26:	6ae2                	ld	s5,24(sp)
    80000c28:	6b42                	ld	s6,16(sp)
    80000c2a:	6ba2                	ld	s7,8(sp)
    80000c2c:	6161                	addi	sp,sp,80
    80000c2e:	8082                	ret
  return 0;
    80000c30:	4501                	li	a0,0
}
    80000c32:	8082                	ret

0000000080000c34 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80000c34:	1141                	addi	sp,sp,-16
    80000c36:	e406                	sd	ra,8(sp)
    80000c38:	e022                	sd	s0,0(sp)
    80000c3a:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80000c3c:	4601                	li	a2,0
    80000c3e:	00000097          	auipc	ra,0x0
    80000c42:	97e080e7          	jalr	-1666(ra) # 800005bc <walk>
  if(pte == 0)
    80000c46:	c901                	beqz	a0,80000c56 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80000c48:	611c                	ld	a5,0(a0)
    80000c4a:	9bbd                	andi	a5,a5,-17
    80000c4c:	e11c                	sd	a5,0(a0)
}
    80000c4e:	60a2                	ld	ra,8(sp)
    80000c50:	6402                	ld	s0,0(sp)
    80000c52:	0141                	addi	sp,sp,16
    80000c54:	8082                	ret
    panic("uvmclear");
    80000c56:	00007517          	auipc	a0,0x7
    80000c5a:	4fa50513          	addi	a0,a0,1274 # 80008150 <etext+0x150>
    80000c5e:	00005097          	auipc	ra,0x5
    80000c62:	42e080e7          	jalr	1070(ra) # 8000608c <panic>

0000000080000c66 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80000c66:	c6bd                	beqz	a3,80000cd4 <copyout+0x6e>
{
    80000c68:	715d                	addi	sp,sp,-80
    80000c6a:	e486                	sd	ra,72(sp)
    80000c6c:	e0a2                	sd	s0,64(sp)
    80000c6e:	fc26                	sd	s1,56(sp)
    80000c70:	f84a                	sd	s2,48(sp)
    80000c72:	f44e                	sd	s3,40(sp)
    80000c74:	f052                	sd	s4,32(sp)
    80000c76:	ec56                	sd	s5,24(sp)
    80000c78:	e85a                	sd	s6,16(sp)
    80000c7a:	e45e                	sd	s7,8(sp)
    80000c7c:	e062                	sd	s8,0(sp)
    80000c7e:	0880                	addi	s0,sp,80
    80000c80:	8b2a                	mv	s6,a0
    80000c82:	8c2e                	mv	s8,a1
    80000c84:	8a32                	mv	s4,a2
    80000c86:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80000c88:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80000c8a:	6a85                	lui	s5,0x1
    80000c8c:	a015                	j	80000cb0 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80000c8e:	9562                	add	a0,a0,s8
    80000c90:	0004861b          	sext.w	a2,s1
    80000c94:	85d2                	mv	a1,s4
    80000c96:	41250533          	sub	a0,a0,s2
    80000c9a:	fffff097          	auipc	ra,0xfffff
    80000c9e:	68a080e7          	jalr	1674(ra) # 80000324 <memmove>

    len -= n;
    80000ca2:	409989b3          	sub	s3,s3,s1
    src += n;
    80000ca6:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80000ca8:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80000cac:	02098263          	beqz	s3,80000cd0 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80000cb0:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80000cb4:	85ca                	mv	a1,s2
    80000cb6:	855a                	mv	a0,s6
    80000cb8:	00000097          	auipc	ra,0x0
    80000cbc:	9aa080e7          	jalr	-1622(ra) # 80000662 <walkaddr>
    if(pa0 == 0)
    80000cc0:	cd01                	beqz	a0,80000cd8 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80000cc2:	418904b3          	sub	s1,s2,s8
    80000cc6:	94d6                	add	s1,s1,s5
    if(n > len)
    80000cc8:	fc99f3e3          	bgeu	s3,s1,80000c8e <copyout+0x28>
    80000ccc:	84ce                	mv	s1,s3
    80000cce:	b7c1                	j	80000c8e <copyout+0x28>
  }
  return 0;
    80000cd0:	4501                	li	a0,0
    80000cd2:	a021                	j	80000cda <copyout+0x74>
    80000cd4:	4501                	li	a0,0
}
    80000cd6:	8082                	ret
      return -1;
    80000cd8:	557d                	li	a0,-1
}
    80000cda:	60a6                	ld	ra,72(sp)
    80000cdc:	6406                	ld	s0,64(sp)
    80000cde:	74e2                	ld	s1,56(sp)
    80000ce0:	7942                	ld	s2,48(sp)
    80000ce2:	79a2                	ld	s3,40(sp)
    80000ce4:	7a02                	ld	s4,32(sp)
    80000ce6:	6ae2                	ld	s5,24(sp)
    80000ce8:	6b42                	ld	s6,16(sp)
    80000cea:	6ba2                	ld	s7,8(sp)
    80000cec:	6c02                	ld	s8,0(sp)
    80000cee:	6161                	addi	sp,sp,80
    80000cf0:	8082                	ret

0000000080000cf2 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80000cf2:	c6bd                	beqz	a3,80000d60 <copyin+0x6e>
{
    80000cf4:	715d                	addi	sp,sp,-80
    80000cf6:	e486                	sd	ra,72(sp)
    80000cf8:	e0a2                	sd	s0,64(sp)
    80000cfa:	fc26                	sd	s1,56(sp)
    80000cfc:	f84a                	sd	s2,48(sp)
    80000cfe:	f44e                	sd	s3,40(sp)
    80000d00:	f052                	sd	s4,32(sp)
    80000d02:	ec56                	sd	s5,24(sp)
    80000d04:	e85a                	sd	s6,16(sp)
    80000d06:	e45e                	sd	s7,8(sp)
    80000d08:	e062                	sd	s8,0(sp)
    80000d0a:	0880                	addi	s0,sp,80
    80000d0c:	8b2a                	mv	s6,a0
    80000d0e:	8a2e                	mv	s4,a1
    80000d10:	8c32                	mv	s8,a2
    80000d12:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80000d14:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000d16:	6a85                	lui	s5,0x1
    80000d18:	a015                	j	80000d3c <copyin+0x4a>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80000d1a:	9562                	add	a0,a0,s8
    80000d1c:	0004861b          	sext.w	a2,s1
    80000d20:	412505b3          	sub	a1,a0,s2
    80000d24:	8552                	mv	a0,s4
    80000d26:	fffff097          	auipc	ra,0xfffff
    80000d2a:	5fe080e7          	jalr	1534(ra) # 80000324 <memmove>

    len -= n;
    80000d2e:	409989b3          	sub	s3,s3,s1
    dst += n;
    80000d32:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80000d34:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80000d38:	02098263          	beqz	s3,80000d5c <copyin+0x6a>
    va0 = PGROUNDDOWN(srcva);
    80000d3c:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80000d40:	85ca                	mv	a1,s2
    80000d42:	855a                	mv	a0,s6
    80000d44:	00000097          	auipc	ra,0x0
    80000d48:	91e080e7          	jalr	-1762(ra) # 80000662 <walkaddr>
    if(pa0 == 0)
    80000d4c:	cd01                	beqz	a0,80000d64 <copyin+0x72>
    n = PGSIZE - (srcva - va0);
    80000d4e:	418904b3          	sub	s1,s2,s8
    80000d52:	94d6                	add	s1,s1,s5
    if(n > len)
    80000d54:	fc99f3e3          	bgeu	s3,s1,80000d1a <copyin+0x28>
    80000d58:	84ce                	mv	s1,s3
    80000d5a:	b7c1                	j	80000d1a <copyin+0x28>
  }
  return 0;
    80000d5c:	4501                	li	a0,0
    80000d5e:	a021                	j	80000d66 <copyin+0x74>
    80000d60:	4501                	li	a0,0
}
    80000d62:	8082                	ret
      return -1;
    80000d64:	557d                	li	a0,-1
}
    80000d66:	60a6                	ld	ra,72(sp)
    80000d68:	6406                	ld	s0,64(sp)
    80000d6a:	74e2                	ld	s1,56(sp)
    80000d6c:	7942                	ld	s2,48(sp)
    80000d6e:	79a2                	ld	s3,40(sp)
    80000d70:	7a02                	ld	s4,32(sp)
    80000d72:	6ae2                	ld	s5,24(sp)
    80000d74:	6b42                	ld	s6,16(sp)
    80000d76:	6ba2                	ld	s7,8(sp)
    80000d78:	6c02                	ld	s8,0(sp)
    80000d7a:	6161                	addi	sp,sp,80
    80000d7c:	8082                	ret

0000000080000d7e <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80000d7e:	c6c5                	beqz	a3,80000e26 <copyinstr+0xa8>
{
    80000d80:	715d                	addi	sp,sp,-80
    80000d82:	e486                	sd	ra,72(sp)
    80000d84:	e0a2                	sd	s0,64(sp)
    80000d86:	fc26                	sd	s1,56(sp)
    80000d88:	f84a                	sd	s2,48(sp)
    80000d8a:	f44e                	sd	s3,40(sp)
    80000d8c:	f052                	sd	s4,32(sp)
    80000d8e:	ec56                	sd	s5,24(sp)
    80000d90:	e85a                	sd	s6,16(sp)
    80000d92:	e45e                	sd	s7,8(sp)
    80000d94:	0880                	addi	s0,sp,80
    80000d96:	8a2a                	mv	s4,a0
    80000d98:	8b2e                	mv	s6,a1
    80000d9a:	8bb2                	mv	s7,a2
    80000d9c:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80000d9e:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000da0:	6985                	lui	s3,0x1
    80000da2:	a035                	j	80000dce <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80000da4:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80000da8:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80000daa:	0017b793          	seqz	a5,a5
    80000dae:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80000db2:	60a6                	ld	ra,72(sp)
    80000db4:	6406                	ld	s0,64(sp)
    80000db6:	74e2                	ld	s1,56(sp)
    80000db8:	7942                	ld	s2,48(sp)
    80000dba:	79a2                	ld	s3,40(sp)
    80000dbc:	7a02                	ld	s4,32(sp)
    80000dbe:	6ae2                	ld	s5,24(sp)
    80000dc0:	6b42                	ld	s6,16(sp)
    80000dc2:	6ba2                	ld	s7,8(sp)
    80000dc4:	6161                	addi	sp,sp,80
    80000dc6:	8082                	ret
    srcva = va0 + PGSIZE;
    80000dc8:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80000dcc:	c8a9                	beqz	s1,80000e1e <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    80000dce:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80000dd2:	85ca                	mv	a1,s2
    80000dd4:	8552                	mv	a0,s4
    80000dd6:	00000097          	auipc	ra,0x0
    80000dda:	88c080e7          	jalr	-1908(ra) # 80000662 <walkaddr>
    if(pa0 == 0)
    80000dde:	c131                	beqz	a0,80000e22 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80000de0:	41790833          	sub	a6,s2,s7
    80000de4:	984e                	add	a6,a6,s3
    if(n > max)
    80000de6:	0104f363          	bgeu	s1,a6,80000dec <copyinstr+0x6e>
    80000dea:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80000dec:	955e                	add	a0,a0,s7
    80000dee:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80000df2:	fc080be3          	beqz	a6,80000dc8 <copyinstr+0x4a>
    80000df6:	985a                	add	a6,a6,s6
    80000df8:	87da                	mv	a5,s6
      if(*p == '\0'){
    80000dfa:	41650633          	sub	a2,a0,s6
    80000dfe:	14fd                	addi	s1,s1,-1
    80000e00:	9b26                	add	s6,s6,s1
    80000e02:	00f60733          	add	a4,a2,a5
    80000e06:	00074703          	lbu	a4,0(a4)
    80000e0a:	df49                	beqz	a4,80000da4 <copyinstr+0x26>
        *dst = *p;
    80000e0c:	00e78023          	sb	a4,0(a5)
      --max;
    80000e10:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80000e14:	0785                	addi	a5,a5,1
    while(n > 0){
    80000e16:	ff0796e3          	bne	a5,a6,80000e02 <copyinstr+0x84>
      dst++;
    80000e1a:	8b42                	mv	s6,a6
    80000e1c:	b775                	j	80000dc8 <copyinstr+0x4a>
    80000e1e:	4781                	li	a5,0
    80000e20:	b769                	j	80000daa <copyinstr+0x2c>
      return -1;
    80000e22:	557d                	li	a0,-1
    80000e24:	b779                	j	80000db2 <copyinstr+0x34>
  int got_null = 0;
    80000e26:	4781                	li	a5,0
  if(got_null){
    80000e28:	0017b793          	seqz	a5,a5
    80000e2c:	40f00533          	neg	a0,a5
}
    80000e30:	8082                	ret

0000000080000e32 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    80000e32:	7139                	addi	sp,sp,-64
    80000e34:	fc06                	sd	ra,56(sp)
    80000e36:	f822                	sd	s0,48(sp)
    80000e38:	f426                	sd	s1,40(sp)
    80000e3a:	f04a                	sd	s2,32(sp)
    80000e3c:	ec4e                	sd	s3,24(sp)
    80000e3e:	e852                	sd	s4,16(sp)
    80000e40:	e456                	sd	s5,8(sp)
    80000e42:	e05a                	sd	s6,0(sp)
    80000e44:	0080                	addi	s0,sp,64
    80000e46:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80000e48:	00008497          	auipc	s1,0x8
    80000e4c:	76848493          	addi	s1,s1,1896 # 800095b0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80000e50:	8b26                	mv	s6,s1
    80000e52:	00007a97          	auipc	s5,0x7
    80000e56:	1aea8a93          	addi	s5,s5,430 # 80008000 <etext>
    80000e5a:	04000937          	lui	s2,0x4000
    80000e5e:	197d                	addi	s2,s2,-1
    80000e60:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000e62:	0000ea17          	auipc	s4,0xe
    80000e66:	34ea0a13          	addi	s4,s4,846 # 8000f1b0 <tickslock>
    char *pa = kalloc();
    80000e6a:	fffff097          	auipc	ra,0xfffff
    80000e6e:	316080e7          	jalr	790(ra) # 80000180 <kalloc>
    80000e72:	862a                	mv	a2,a0
    if(pa == 0)
    80000e74:	c131                	beqz	a0,80000eb8 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80000e76:	416485b3          	sub	a1,s1,s6
    80000e7a:	8591                	srai	a1,a1,0x4
    80000e7c:	000ab783          	ld	a5,0(s5)
    80000e80:	02f585b3          	mul	a1,a1,a5
    80000e84:	2585                	addiw	a1,a1,1
    80000e86:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80000e8a:	4719                	li	a4,6
    80000e8c:	6685                	lui	a3,0x1
    80000e8e:	40b905b3          	sub	a1,s2,a1
    80000e92:	854e                	mv	a0,s3
    80000e94:	00000097          	auipc	ra,0x0
    80000e98:	8b0080e7          	jalr	-1872(ra) # 80000744 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000e9c:	17048493          	addi	s1,s1,368
    80000ea0:	fd4495e3          	bne	s1,s4,80000e6a <proc_mapstacks+0x38>
  }
}
    80000ea4:	70e2                	ld	ra,56(sp)
    80000ea6:	7442                	ld	s0,48(sp)
    80000ea8:	74a2                	ld	s1,40(sp)
    80000eaa:	7902                	ld	s2,32(sp)
    80000eac:	69e2                	ld	s3,24(sp)
    80000eae:	6a42                	ld	s4,16(sp)
    80000eb0:	6aa2                	ld	s5,8(sp)
    80000eb2:	6b02                	ld	s6,0(sp)
    80000eb4:	6121                	addi	sp,sp,64
    80000eb6:	8082                	ret
      panic("kalloc");
    80000eb8:	00007517          	auipc	a0,0x7
    80000ebc:	2a850513          	addi	a0,a0,680 # 80008160 <etext+0x160>
    80000ec0:	00005097          	auipc	ra,0x5
    80000ec4:	1cc080e7          	jalr	460(ra) # 8000608c <panic>

0000000080000ec8 <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    80000ec8:	7139                	addi	sp,sp,-64
    80000eca:	fc06                	sd	ra,56(sp)
    80000ecc:	f822                	sd	s0,48(sp)
    80000ece:	f426                	sd	s1,40(sp)
    80000ed0:	f04a                	sd	s2,32(sp)
    80000ed2:	ec4e                	sd	s3,24(sp)
    80000ed4:	e852                	sd	s4,16(sp)
    80000ed6:	e456                	sd	s5,8(sp)
    80000ed8:	e05a                	sd	s6,0(sp)
    80000eda:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80000edc:	00007597          	auipc	a1,0x7
    80000ee0:	28c58593          	addi	a1,a1,652 # 80008168 <etext+0x168>
    80000ee4:	00008517          	auipc	a0,0x8
    80000ee8:	28c50513          	addi	a0,a0,652 # 80009170 <pid_lock>
    80000eec:	00006097          	auipc	ra,0x6
    80000ef0:	850080e7          	jalr	-1968(ra) # 8000673c <initlock>
  initlock(&wait_lock, "wait_lock");
    80000ef4:	00007597          	auipc	a1,0x7
    80000ef8:	27c58593          	addi	a1,a1,636 # 80008170 <etext+0x170>
    80000efc:	00008517          	auipc	a0,0x8
    80000f00:	29450513          	addi	a0,a0,660 # 80009190 <wait_lock>
    80000f04:	00006097          	auipc	ra,0x6
    80000f08:	838080e7          	jalr	-1992(ra) # 8000673c <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000f0c:	00008497          	auipc	s1,0x8
    80000f10:	6a448493          	addi	s1,s1,1700 # 800095b0 <proc>
      initlock(&p->lock, "proc");
    80000f14:	00007b17          	auipc	s6,0x7
    80000f18:	26cb0b13          	addi	s6,s6,620 # 80008180 <etext+0x180>
      p->kstack = KSTACK((int) (p - proc));
    80000f1c:	8aa6                	mv	s5,s1
    80000f1e:	00007a17          	auipc	s4,0x7
    80000f22:	0e2a0a13          	addi	s4,s4,226 # 80008000 <etext>
    80000f26:	04000937          	lui	s2,0x4000
    80000f2a:	197d                	addi	s2,s2,-1
    80000f2c:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000f2e:	0000e997          	auipc	s3,0xe
    80000f32:	28298993          	addi	s3,s3,642 # 8000f1b0 <tickslock>
      initlock(&p->lock, "proc");
    80000f36:	85da                	mv	a1,s6
    80000f38:	8526                	mv	a0,s1
    80000f3a:	00006097          	auipc	ra,0x6
    80000f3e:	802080e7          	jalr	-2046(ra) # 8000673c <initlock>
      p->kstack = KSTACK((int) (p - proc));
    80000f42:	415487b3          	sub	a5,s1,s5
    80000f46:	8791                	srai	a5,a5,0x4
    80000f48:	000a3703          	ld	a4,0(s4)
    80000f4c:	02e787b3          	mul	a5,a5,a4
    80000f50:	2785                	addiw	a5,a5,1
    80000f52:	00d7979b          	slliw	a5,a5,0xd
    80000f56:	40f907b3          	sub	a5,s2,a5
    80000f5a:	e4bc                	sd	a5,72(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80000f5c:	17048493          	addi	s1,s1,368
    80000f60:	fd349be3          	bne	s1,s3,80000f36 <procinit+0x6e>
  }
}
    80000f64:	70e2                	ld	ra,56(sp)
    80000f66:	7442                	ld	s0,48(sp)
    80000f68:	74a2                	ld	s1,40(sp)
    80000f6a:	7902                	ld	s2,32(sp)
    80000f6c:	69e2                	ld	s3,24(sp)
    80000f6e:	6a42                	ld	s4,16(sp)
    80000f70:	6aa2                	ld	s5,8(sp)
    80000f72:	6b02                	ld	s6,0(sp)
    80000f74:	6121                	addi	sp,sp,64
    80000f76:	8082                	ret

0000000080000f78 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80000f78:	1141                	addi	sp,sp,-16
    80000f7a:	e422                	sd	s0,8(sp)
    80000f7c:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80000f7e:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80000f80:	2501                	sext.w	a0,a0
    80000f82:	6422                	ld	s0,8(sp)
    80000f84:	0141                	addi	sp,sp,16
    80000f86:	8082                	ret

0000000080000f88 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    80000f88:	1141                	addi	sp,sp,-16
    80000f8a:	e422                	sd	s0,8(sp)
    80000f8c:	0800                	addi	s0,sp,16
    80000f8e:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80000f90:	2781                	sext.w	a5,a5
    80000f92:	079e                	slli	a5,a5,0x7
  return c;
}
    80000f94:	00008517          	auipc	a0,0x8
    80000f98:	21c50513          	addi	a0,a0,540 # 800091b0 <cpus>
    80000f9c:	953e                	add	a0,a0,a5
    80000f9e:	6422                	ld	s0,8(sp)
    80000fa0:	0141                	addi	sp,sp,16
    80000fa2:	8082                	ret

0000000080000fa4 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    80000fa4:	1101                	addi	sp,sp,-32
    80000fa6:	ec06                	sd	ra,24(sp)
    80000fa8:	e822                	sd	s0,16(sp)
    80000faa:	e426                	sd	s1,8(sp)
    80000fac:	1000                	addi	s0,sp,32
  push_off();
    80000fae:	00005097          	auipc	ra,0x5
    80000fb2:	5c6080e7          	jalr	1478(ra) # 80006574 <push_off>
    80000fb6:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80000fb8:	2781                	sext.w	a5,a5
    80000fba:	079e                	slli	a5,a5,0x7
    80000fbc:	00008717          	auipc	a4,0x8
    80000fc0:	1b470713          	addi	a4,a4,436 # 80009170 <pid_lock>
    80000fc4:	97ba                	add	a5,a5,a4
    80000fc6:	63a4                	ld	s1,64(a5)
  pop_off();
    80000fc8:	00005097          	auipc	ra,0x5
    80000fcc:	668080e7          	jalr	1640(ra) # 80006630 <pop_off>
  return p;
}
    80000fd0:	8526                	mv	a0,s1
    80000fd2:	60e2                	ld	ra,24(sp)
    80000fd4:	6442                	ld	s0,16(sp)
    80000fd6:	64a2                	ld	s1,8(sp)
    80000fd8:	6105                	addi	sp,sp,32
    80000fda:	8082                	ret

0000000080000fdc <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80000fdc:	1141                	addi	sp,sp,-16
    80000fde:	e406                	sd	ra,8(sp)
    80000fe0:	e022                	sd	s0,0(sp)
    80000fe2:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80000fe4:	00000097          	auipc	ra,0x0
    80000fe8:	fc0080e7          	jalr	-64(ra) # 80000fa4 <myproc>
    80000fec:	00005097          	auipc	ra,0x5
    80000ff0:	6a4080e7          	jalr	1700(ra) # 80006690 <release>

  if (first) {
    80000ff4:	00008797          	auipc	a5,0x8
    80000ff8:	8ec7a783          	lw	a5,-1812(a5) # 800088e0 <first.1688>
    80000ffc:	eb89                	bnez	a5,8000100e <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80000ffe:	00001097          	auipc	ra,0x1
    80001002:	c0a080e7          	jalr	-1014(ra) # 80001c08 <usertrapret>
}
    80001006:	60a2                	ld	ra,8(sp)
    80001008:	6402                	ld	s0,0(sp)
    8000100a:	0141                	addi	sp,sp,16
    8000100c:	8082                	ret
    first = 0;
    8000100e:	00008797          	auipc	a5,0x8
    80001012:	8c07a923          	sw	zero,-1838(a5) # 800088e0 <first.1688>
    fsinit(ROOTDEV);
    80001016:	4505                	li	a0,1
    80001018:	00002097          	auipc	ra,0x2
    8000101c:	a0a080e7          	jalr	-1526(ra) # 80002a22 <fsinit>
    80001020:	bff9                	j	80000ffe <forkret+0x22>

0000000080001022 <allocpid>:
allocpid() {
    80001022:	1101                	addi	sp,sp,-32
    80001024:	ec06                	sd	ra,24(sp)
    80001026:	e822                	sd	s0,16(sp)
    80001028:	e426                	sd	s1,8(sp)
    8000102a:	e04a                	sd	s2,0(sp)
    8000102c:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    8000102e:	00008917          	auipc	s2,0x8
    80001032:	14290913          	addi	s2,s2,322 # 80009170 <pid_lock>
    80001036:	854a                	mv	a0,s2
    80001038:	00005097          	auipc	ra,0x5
    8000103c:	588080e7          	jalr	1416(ra) # 800065c0 <acquire>
  pid = nextpid;
    80001040:	00008797          	auipc	a5,0x8
    80001044:	8a478793          	addi	a5,a5,-1884 # 800088e4 <nextpid>
    80001048:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    8000104a:	0014871b          	addiw	a4,s1,1
    8000104e:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001050:	854a                	mv	a0,s2
    80001052:	00005097          	auipc	ra,0x5
    80001056:	63e080e7          	jalr	1598(ra) # 80006690 <release>
}
    8000105a:	8526                	mv	a0,s1
    8000105c:	60e2                	ld	ra,24(sp)
    8000105e:	6442                	ld	s0,16(sp)
    80001060:	64a2                	ld	s1,8(sp)
    80001062:	6902                	ld	s2,0(sp)
    80001064:	6105                	addi	sp,sp,32
    80001066:	8082                	ret

0000000080001068 <proc_pagetable>:
{
    80001068:	1101                	addi	sp,sp,-32
    8000106a:	ec06                	sd	ra,24(sp)
    8000106c:	e822                	sd	s0,16(sp)
    8000106e:	e426                	sd	s1,8(sp)
    80001070:	e04a                	sd	s2,0(sp)
    80001072:	1000                	addi	s0,sp,32
    80001074:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001076:	00000097          	auipc	ra,0x0
    8000107a:	8b8080e7          	jalr	-1864(ra) # 8000092e <uvmcreate>
    8000107e:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001080:	c121                	beqz	a0,800010c0 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001082:	4729                	li	a4,10
    80001084:	00006697          	auipc	a3,0x6
    80001088:	f7c68693          	addi	a3,a3,-132 # 80007000 <_trampoline>
    8000108c:	6605                	lui	a2,0x1
    8000108e:	040005b7          	lui	a1,0x4000
    80001092:	15fd                	addi	a1,a1,-1
    80001094:	05b2                	slli	a1,a1,0xc
    80001096:	fffff097          	auipc	ra,0xfffff
    8000109a:	60e080e7          	jalr	1550(ra) # 800006a4 <mappages>
    8000109e:	02054863          	bltz	a0,800010ce <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    800010a2:	4719                	li	a4,6
    800010a4:	06093683          	ld	a3,96(s2)
    800010a8:	6605                	lui	a2,0x1
    800010aa:	020005b7          	lui	a1,0x2000
    800010ae:	15fd                	addi	a1,a1,-1
    800010b0:	05b6                	slli	a1,a1,0xd
    800010b2:	8526                	mv	a0,s1
    800010b4:	fffff097          	auipc	ra,0xfffff
    800010b8:	5f0080e7          	jalr	1520(ra) # 800006a4 <mappages>
    800010bc:	02054163          	bltz	a0,800010de <proc_pagetable+0x76>
}
    800010c0:	8526                	mv	a0,s1
    800010c2:	60e2                	ld	ra,24(sp)
    800010c4:	6442                	ld	s0,16(sp)
    800010c6:	64a2                	ld	s1,8(sp)
    800010c8:	6902                	ld	s2,0(sp)
    800010ca:	6105                	addi	sp,sp,32
    800010cc:	8082                	ret
    uvmfree(pagetable, 0);
    800010ce:	4581                	li	a1,0
    800010d0:	8526                	mv	a0,s1
    800010d2:	00000097          	auipc	ra,0x0
    800010d6:	a58080e7          	jalr	-1448(ra) # 80000b2a <uvmfree>
    return 0;
    800010da:	4481                	li	s1,0
    800010dc:	b7d5                	j	800010c0 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    800010de:	4681                	li	a3,0
    800010e0:	4605                	li	a2,1
    800010e2:	040005b7          	lui	a1,0x4000
    800010e6:	15fd                	addi	a1,a1,-1
    800010e8:	05b2                	slli	a1,a1,0xc
    800010ea:	8526                	mv	a0,s1
    800010ec:	fffff097          	auipc	ra,0xfffff
    800010f0:	77e080e7          	jalr	1918(ra) # 8000086a <uvmunmap>
    uvmfree(pagetable, 0);
    800010f4:	4581                	li	a1,0
    800010f6:	8526                	mv	a0,s1
    800010f8:	00000097          	auipc	ra,0x0
    800010fc:	a32080e7          	jalr	-1486(ra) # 80000b2a <uvmfree>
    return 0;
    80001100:	4481                	li	s1,0
    80001102:	bf7d                	j	800010c0 <proc_pagetable+0x58>

0000000080001104 <proc_freepagetable>:
{
    80001104:	1101                	addi	sp,sp,-32
    80001106:	ec06                	sd	ra,24(sp)
    80001108:	e822                	sd	s0,16(sp)
    8000110a:	e426                	sd	s1,8(sp)
    8000110c:	e04a                	sd	s2,0(sp)
    8000110e:	1000                	addi	s0,sp,32
    80001110:	84aa                	mv	s1,a0
    80001112:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001114:	4681                	li	a3,0
    80001116:	4605                	li	a2,1
    80001118:	040005b7          	lui	a1,0x4000
    8000111c:	15fd                	addi	a1,a1,-1
    8000111e:	05b2                	slli	a1,a1,0xc
    80001120:	fffff097          	auipc	ra,0xfffff
    80001124:	74a080e7          	jalr	1866(ra) # 8000086a <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001128:	4681                	li	a3,0
    8000112a:	4605                	li	a2,1
    8000112c:	020005b7          	lui	a1,0x2000
    80001130:	15fd                	addi	a1,a1,-1
    80001132:	05b6                	slli	a1,a1,0xd
    80001134:	8526                	mv	a0,s1
    80001136:	fffff097          	auipc	ra,0xfffff
    8000113a:	734080e7          	jalr	1844(ra) # 8000086a <uvmunmap>
  uvmfree(pagetable, sz);
    8000113e:	85ca                	mv	a1,s2
    80001140:	8526                	mv	a0,s1
    80001142:	00000097          	auipc	ra,0x0
    80001146:	9e8080e7          	jalr	-1560(ra) # 80000b2a <uvmfree>
}
    8000114a:	60e2                	ld	ra,24(sp)
    8000114c:	6442                	ld	s0,16(sp)
    8000114e:	64a2                	ld	s1,8(sp)
    80001150:	6902                	ld	s2,0(sp)
    80001152:	6105                	addi	sp,sp,32
    80001154:	8082                	ret

0000000080001156 <freeproc>:
{
    80001156:	1101                	addi	sp,sp,-32
    80001158:	ec06                	sd	ra,24(sp)
    8000115a:	e822                	sd	s0,16(sp)
    8000115c:	e426                	sd	s1,8(sp)
    8000115e:	1000                	addi	s0,sp,32
    80001160:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001162:	7128                	ld	a0,96(a0)
    80001164:	c509                	beqz	a0,8000116e <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001166:	fffff097          	auipc	ra,0xfffff
    8000116a:	eb6080e7          	jalr	-330(ra) # 8000001c <kfree>
  p->trapframe = 0;
    8000116e:	0604b023          	sd	zero,96(s1)
  if(p->pagetable)
    80001172:	6ca8                	ld	a0,88(s1)
    80001174:	c511                	beqz	a0,80001180 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001176:	68ac                	ld	a1,80(s1)
    80001178:	00000097          	auipc	ra,0x0
    8000117c:	f8c080e7          	jalr	-116(ra) # 80001104 <proc_freepagetable>
  p->pagetable = 0;
    80001180:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    80001184:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    80001188:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    8000118c:	0404b023          	sd	zero,64(s1)
  p->name[0] = 0;
    80001190:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001194:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001198:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    8000119c:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    800011a0:	0204a023          	sw	zero,32(s1)
}
    800011a4:	60e2                	ld	ra,24(sp)
    800011a6:	6442                	ld	s0,16(sp)
    800011a8:	64a2                	ld	s1,8(sp)
    800011aa:	6105                	addi	sp,sp,32
    800011ac:	8082                	ret

00000000800011ae <allocproc>:
{
    800011ae:	1101                	addi	sp,sp,-32
    800011b0:	ec06                	sd	ra,24(sp)
    800011b2:	e822                	sd	s0,16(sp)
    800011b4:	e426                	sd	s1,8(sp)
    800011b6:	e04a                	sd	s2,0(sp)
    800011b8:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    800011ba:	00008497          	auipc	s1,0x8
    800011be:	3f648493          	addi	s1,s1,1014 # 800095b0 <proc>
    800011c2:	0000e917          	auipc	s2,0xe
    800011c6:	fee90913          	addi	s2,s2,-18 # 8000f1b0 <tickslock>
    acquire(&p->lock);
    800011ca:	8526                	mv	a0,s1
    800011cc:	00005097          	auipc	ra,0x5
    800011d0:	3f4080e7          	jalr	1012(ra) # 800065c0 <acquire>
    if(p->state == UNUSED) {
    800011d4:	509c                	lw	a5,32(s1)
    800011d6:	cf81                	beqz	a5,800011ee <allocproc+0x40>
      release(&p->lock);
    800011d8:	8526                	mv	a0,s1
    800011da:	00005097          	auipc	ra,0x5
    800011de:	4b6080e7          	jalr	1206(ra) # 80006690 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800011e2:	17048493          	addi	s1,s1,368
    800011e6:	ff2492e3          	bne	s1,s2,800011ca <allocproc+0x1c>
  return 0;
    800011ea:	4481                	li	s1,0
    800011ec:	a889                	j	8000123e <allocproc+0x90>
  p->pid = allocpid();
    800011ee:	00000097          	auipc	ra,0x0
    800011f2:	e34080e7          	jalr	-460(ra) # 80001022 <allocpid>
    800011f6:	dc88                	sw	a0,56(s1)
  p->state = USED;
    800011f8:	4785                	li	a5,1
    800011fa:	d09c                	sw	a5,32(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    800011fc:	fffff097          	auipc	ra,0xfffff
    80001200:	f84080e7          	jalr	-124(ra) # 80000180 <kalloc>
    80001204:	892a                	mv	s2,a0
    80001206:	f0a8                	sd	a0,96(s1)
    80001208:	c131                	beqz	a0,8000124c <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    8000120a:	8526                	mv	a0,s1
    8000120c:	00000097          	auipc	ra,0x0
    80001210:	e5c080e7          	jalr	-420(ra) # 80001068 <proc_pagetable>
    80001214:	892a                	mv	s2,a0
    80001216:	eca8                	sd	a0,88(s1)
  if(p->pagetable == 0){
    80001218:	c531                	beqz	a0,80001264 <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    8000121a:	07000613          	li	a2,112
    8000121e:	4581                	li	a1,0
    80001220:	06848513          	addi	a0,s1,104
    80001224:	fffff097          	auipc	ra,0xfffff
    80001228:	0a0080e7          	jalr	160(ra) # 800002c4 <memset>
  p->context.ra = (uint64)forkret;
    8000122c:	00000797          	auipc	a5,0x0
    80001230:	db078793          	addi	a5,a5,-592 # 80000fdc <forkret>
    80001234:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001236:	64bc                	ld	a5,72(s1)
    80001238:	6705                	lui	a4,0x1
    8000123a:	97ba                	add	a5,a5,a4
    8000123c:	f8bc                	sd	a5,112(s1)
}
    8000123e:	8526                	mv	a0,s1
    80001240:	60e2                	ld	ra,24(sp)
    80001242:	6442                	ld	s0,16(sp)
    80001244:	64a2                	ld	s1,8(sp)
    80001246:	6902                	ld	s2,0(sp)
    80001248:	6105                	addi	sp,sp,32
    8000124a:	8082                	ret
    freeproc(p);
    8000124c:	8526                	mv	a0,s1
    8000124e:	00000097          	auipc	ra,0x0
    80001252:	f08080e7          	jalr	-248(ra) # 80001156 <freeproc>
    release(&p->lock);
    80001256:	8526                	mv	a0,s1
    80001258:	00005097          	auipc	ra,0x5
    8000125c:	438080e7          	jalr	1080(ra) # 80006690 <release>
    return 0;
    80001260:	84ca                	mv	s1,s2
    80001262:	bff1                	j	8000123e <allocproc+0x90>
    freeproc(p);
    80001264:	8526                	mv	a0,s1
    80001266:	00000097          	auipc	ra,0x0
    8000126a:	ef0080e7          	jalr	-272(ra) # 80001156 <freeproc>
    release(&p->lock);
    8000126e:	8526                	mv	a0,s1
    80001270:	00005097          	auipc	ra,0x5
    80001274:	420080e7          	jalr	1056(ra) # 80006690 <release>
    return 0;
    80001278:	84ca                	mv	s1,s2
    8000127a:	b7d1                	j	8000123e <allocproc+0x90>

000000008000127c <userinit>:
{
    8000127c:	1101                	addi	sp,sp,-32
    8000127e:	ec06                	sd	ra,24(sp)
    80001280:	e822                	sd	s0,16(sp)
    80001282:	e426                	sd	s1,8(sp)
    80001284:	1000                	addi	s0,sp,32
  p = allocproc();
    80001286:	00000097          	auipc	ra,0x0
    8000128a:	f28080e7          	jalr	-216(ra) # 800011ae <allocproc>
    8000128e:	84aa                	mv	s1,a0
  initproc = p;
    80001290:	00008797          	auipc	a5,0x8
    80001294:	d8a7b023          	sd	a0,-640(a5) # 80009010 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001298:	03400613          	li	a2,52
    8000129c:	00007597          	auipc	a1,0x7
    800012a0:	65458593          	addi	a1,a1,1620 # 800088f0 <initcode>
    800012a4:	6d28                	ld	a0,88(a0)
    800012a6:	fffff097          	auipc	ra,0xfffff
    800012aa:	6b6080e7          	jalr	1718(ra) # 8000095c <uvminit>
  p->sz = PGSIZE;
    800012ae:	6785                	lui	a5,0x1
    800012b0:	e8bc                	sd	a5,80(s1)
  p->trapframe->epc = 0;      // user program counter
    800012b2:	70b8                	ld	a4,96(s1)
    800012b4:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    800012b8:	70b8                	ld	a4,96(s1)
    800012ba:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    800012bc:	4641                	li	a2,16
    800012be:	00007597          	auipc	a1,0x7
    800012c2:	eca58593          	addi	a1,a1,-310 # 80008188 <etext+0x188>
    800012c6:	16048513          	addi	a0,s1,352
    800012ca:	fffff097          	auipc	ra,0xfffff
    800012ce:	14c080e7          	jalr	332(ra) # 80000416 <safestrcpy>
  p->cwd = namei("/");
    800012d2:	00007517          	auipc	a0,0x7
    800012d6:	ec650513          	addi	a0,a0,-314 # 80008198 <etext+0x198>
    800012da:	00002097          	auipc	ra,0x2
    800012de:	176080e7          	jalr	374(ra) # 80003450 <namei>
    800012e2:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    800012e6:	478d                	li	a5,3
    800012e8:	d09c                	sw	a5,32(s1)
  release(&p->lock);
    800012ea:	8526                	mv	a0,s1
    800012ec:	00005097          	auipc	ra,0x5
    800012f0:	3a4080e7          	jalr	932(ra) # 80006690 <release>
}
    800012f4:	60e2                	ld	ra,24(sp)
    800012f6:	6442                	ld	s0,16(sp)
    800012f8:	64a2                	ld	s1,8(sp)
    800012fa:	6105                	addi	sp,sp,32
    800012fc:	8082                	ret

00000000800012fe <growproc>:
{
    800012fe:	1101                	addi	sp,sp,-32
    80001300:	ec06                	sd	ra,24(sp)
    80001302:	e822                	sd	s0,16(sp)
    80001304:	e426                	sd	s1,8(sp)
    80001306:	e04a                	sd	s2,0(sp)
    80001308:	1000                	addi	s0,sp,32
    8000130a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000130c:	00000097          	auipc	ra,0x0
    80001310:	c98080e7          	jalr	-872(ra) # 80000fa4 <myproc>
    80001314:	892a                	mv	s2,a0
  sz = p->sz;
    80001316:	692c                	ld	a1,80(a0)
    80001318:	0005861b          	sext.w	a2,a1
  if(n > 0){
    8000131c:	00904f63          	bgtz	s1,8000133a <growproc+0x3c>
  } else if(n < 0){
    80001320:	0204cc63          	bltz	s1,80001358 <growproc+0x5a>
  p->sz = sz;
    80001324:	1602                	slli	a2,a2,0x20
    80001326:	9201                	srli	a2,a2,0x20
    80001328:	04c93823          	sd	a2,80(s2)
  return 0;
    8000132c:	4501                	li	a0,0
}
    8000132e:	60e2                	ld	ra,24(sp)
    80001330:	6442                	ld	s0,16(sp)
    80001332:	64a2                	ld	s1,8(sp)
    80001334:	6902                	ld	s2,0(sp)
    80001336:	6105                	addi	sp,sp,32
    80001338:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    8000133a:	9e25                	addw	a2,a2,s1
    8000133c:	1602                	slli	a2,a2,0x20
    8000133e:	9201                	srli	a2,a2,0x20
    80001340:	1582                	slli	a1,a1,0x20
    80001342:	9181                	srli	a1,a1,0x20
    80001344:	6d28                	ld	a0,88(a0)
    80001346:	fffff097          	auipc	ra,0xfffff
    8000134a:	6d0080e7          	jalr	1744(ra) # 80000a16 <uvmalloc>
    8000134e:	0005061b          	sext.w	a2,a0
    80001352:	fa69                	bnez	a2,80001324 <growproc+0x26>
      return -1;
    80001354:	557d                	li	a0,-1
    80001356:	bfe1                	j	8000132e <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001358:	9e25                	addw	a2,a2,s1
    8000135a:	1602                	slli	a2,a2,0x20
    8000135c:	9201                	srli	a2,a2,0x20
    8000135e:	1582                	slli	a1,a1,0x20
    80001360:	9181                	srli	a1,a1,0x20
    80001362:	6d28                	ld	a0,88(a0)
    80001364:	fffff097          	auipc	ra,0xfffff
    80001368:	66a080e7          	jalr	1642(ra) # 800009ce <uvmdealloc>
    8000136c:	0005061b          	sext.w	a2,a0
    80001370:	bf55                	j	80001324 <growproc+0x26>

0000000080001372 <fork>:
{
    80001372:	7179                	addi	sp,sp,-48
    80001374:	f406                	sd	ra,40(sp)
    80001376:	f022                	sd	s0,32(sp)
    80001378:	ec26                	sd	s1,24(sp)
    8000137a:	e84a                	sd	s2,16(sp)
    8000137c:	e44e                	sd	s3,8(sp)
    8000137e:	e052                	sd	s4,0(sp)
    80001380:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001382:	00000097          	auipc	ra,0x0
    80001386:	c22080e7          	jalr	-990(ra) # 80000fa4 <myproc>
    8000138a:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    8000138c:	00000097          	auipc	ra,0x0
    80001390:	e22080e7          	jalr	-478(ra) # 800011ae <allocproc>
    80001394:	10050b63          	beqz	a0,800014aa <fork+0x138>
    80001398:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    8000139a:	05093603          	ld	a2,80(s2)
    8000139e:	6d2c                	ld	a1,88(a0)
    800013a0:	05893503          	ld	a0,88(s2)
    800013a4:	fffff097          	auipc	ra,0xfffff
    800013a8:	7be080e7          	jalr	1982(ra) # 80000b62 <uvmcopy>
    800013ac:	04054663          	bltz	a0,800013f8 <fork+0x86>
  np->sz = p->sz;
    800013b0:	05093783          	ld	a5,80(s2)
    800013b4:	04f9b823          	sd	a5,80(s3)
  *(np->trapframe) = *(p->trapframe);
    800013b8:	06093683          	ld	a3,96(s2)
    800013bc:	87b6                	mv	a5,a3
    800013be:	0609b703          	ld	a4,96(s3)
    800013c2:	12068693          	addi	a3,a3,288
    800013c6:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    800013ca:	6788                	ld	a0,8(a5)
    800013cc:	6b8c                	ld	a1,16(a5)
    800013ce:	6f90                	ld	a2,24(a5)
    800013d0:	01073023          	sd	a6,0(a4)
    800013d4:	e708                	sd	a0,8(a4)
    800013d6:	eb0c                	sd	a1,16(a4)
    800013d8:	ef10                	sd	a2,24(a4)
    800013da:	02078793          	addi	a5,a5,32
    800013de:	02070713          	addi	a4,a4,32
    800013e2:	fed792e3          	bne	a5,a3,800013c6 <fork+0x54>
  np->trapframe->a0 = 0;
    800013e6:	0609b783          	ld	a5,96(s3)
    800013ea:	0607b823          	sd	zero,112(a5)
    800013ee:	0d800493          	li	s1,216
  for(i = 0; i < NOFILE; i++)
    800013f2:	15800a13          	li	s4,344
    800013f6:	a03d                	j	80001424 <fork+0xb2>
    freeproc(np);
    800013f8:	854e                	mv	a0,s3
    800013fa:	00000097          	auipc	ra,0x0
    800013fe:	d5c080e7          	jalr	-676(ra) # 80001156 <freeproc>
    release(&np->lock);
    80001402:	854e                	mv	a0,s3
    80001404:	00005097          	auipc	ra,0x5
    80001408:	28c080e7          	jalr	652(ra) # 80006690 <release>
    return -1;
    8000140c:	5a7d                	li	s4,-1
    8000140e:	a069                	j	80001498 <fork+0x126>
      np->ofile[i] = filedup(p->ofile[i]);
    80001410:	00002097          	auipc	ra,0x2
    80001414:	6d6080e7          	jalr	1750(ra) # 80003ae6 <filedup>
    80001418:	009987b3          	add	a5,s3,s1
    8000141c:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    8000141e:	04a1                	addi	s1,s1,8
    80001420:	01448763          	beq	s1,s4,8000142e <fork+0xbc>
    if(p->ofile[i])
    80001424:	009907b3          	add	a5,s2,s1
    80001428:	6388                	ld	a0,0(a5)
    8000142a:	f17d                	bnez	a0,80001410 <fork+0x9e>
    8000142c:	bfcd                	j	8000141e <fork+0xac>
  np->cwd = idup(p->cwd);
    8000142e:	15893503          	ld	a0,344(s2)
    80001432:	00002097          	auipc	ra,0x2
    80001436:	82a080e7          	jalr	-2006(ra) # 80002c5c <idup>
    8000143a:	14a9bc23          	sd	a0,344(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    8000143e:	4641                	li	a2,16
    80001440:	16090593          	addi	a1,s2,352
    80001444:	16098513          	addi	a0,s3,352
    80001448:	fffff097          	auipc	ra,0xfffff
    8000144c:	fce080e7          	jalr	-50(ra) # 80000416 <safestrcpy>
  pid = np->pid;
    80001450:	0389aa03          	lw	s4,56(s3)
  release(&np->lock);
    80001454:	854e                	mv	a0,s3
    80001456:	00005097          	auipc	ra,0x5
    8000145a:	23a080e7          	jalr	570(ra) # 80006690 <release>
  acquire(&wait_lock);
    8000145e:	00008497          	auipc	s1,0x8
    80001462:	d3248493          	addi	s1,s1,-718 # 80009190 <wait_lock>
    80001466:	8526                	mv	a0,s1
    80001468:	00005097          	auipc	ra,0x5
    8000146c:	158080e7          	jalr	344(ra) # 800065c0 <acquire>
  np->parent = p;
    80001470:	0529b023          	sd	s2,64(s3)
  release(&wait_lock);
    80001474:	8526                	mv	a0,s1
    80001476:	00005097          	auipc	ra,0x5
    8000147a:	21a080e7          	jalr	538(ra) # 80006690 <release>
  acquire(&np->lock);
    8000147e:	854e                	mv	a0,s3
    80001480:	00005097          	auipc	ra,0x5
    80001484:	140080e7          	jalr	320(ra) # 800065c0 <acquire>
  np->state = RUNNABLE;
    80001488:	478d                	li	a5,3
    8000148a:	02f9a023          	sw	a5,32(s3)
  release(&np->lock);
    8000148e:	854e                	mv	a0,s3
    80001490:	00005097          	auipc	ra,0x5
    80001494:	200080e7          	jalr	512(ra) # 80006690 <release>
}
    80001498:	8552                	mv	a0,s4
    8000149a:	70a2                	ld	ra,40(sp)
    8000149c:	7402                	ld	s0,32(sp)
    8000149e:	64e2                	ld	s1,24(sp)
    800014a0:	6942                	ld	s2,16(sp)
    800014a2:	69a2                	ld	s3,8(sp)
    800014a4:	6a02                	ld	s4,0(sp)
    800014a6:	6145                	addi	sp,sp,48
    800014a8:	8082                	ret
    return -1;
    800014aa:	5a7d                	li	s4,-1
    800014ac:	b7f5                	j	80001498 <fork+0x126>

00000000800014ae <scheduler>:
{
    800014ae:	7139                	addi	sp,sp,-64
    800014b0:	fc06                	sd	ra,56(sp)
    800014b2:	f822                	sd	s0,48(sp)
    800014b4:	f426                	sd	s1,40(sp)
    800014b6:	f04a                	sd	s2,32(sp)
    800014b8:	ec4e                	sd	s3,24(sp)
    800014ba:	e852                	sd	s4,16(sp)
    800014bc:	e456                	sd	s5,8(sp)
    800014be:	e05a                	sd	s6,0(sp)
    800014c0:	0080                	addi	s0,sp,64
    800014c2:	8792                	mv	a5,tp
  int id = r_tp();
    800014c4:	2781                	sext.w	a5,a5
  c->proc = 0;
    800014c6:	00779a93          	slli	s5,a5,0x7
    800014ca:	00008717          	auipc	a4,0x8
    800014ce:	ca670713          	addi	a4,a4,-858 # 80009170 <pid_lock>
    800014d2:	9756                	add	a4,a4,s5
    800014d4:	04073023          	sd	zero,64(a4)
        swtch(&c->context, &p->context);
    800014d8:	00008717          	auipc	a4,0x8
    800014dc:	ce070713          	addi	a4,a4,-800 # 800091b8 <cpus+0x8>
    800014e0:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    800014e2:	498d                	li	s3,3
        p->state = RUNNING;
    800014e4:	4b11                	li	s6,4
        c->proc = p;
    800014e6:	079e                	slli	a5,a5,0x7
    800014e8:	00008a17          	auipc	s4,0x8
    800014ec:	c88a0a13          	addi	s4,s4,-888 # 80009170 <pid_lock>
    800014f0:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    800014f2:	0000e917          	auipc	s2,0xe
    800014f6:	cbe90913          	addi	s2,s2,-834 # 8000f1b0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800014fa:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800014fe:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001502:	10079073          	csrw	sstatus,a5
    80001506:	00008497          	auipc	s1,0x8
    8000150a:	0aa48493          	addi	s1,s1,170 # 800095b0 <proc>
    8000150e:	a03d                	j	8000153c <scheduler+0x8e>
        p->state = RUNNING;
    80001510:	0364a023          	sw	s6,32(s1)
        c->proc = p;
    80001514:	049a3023          	sd	s1,64(s4)
        swtch(&c->context, &p->context);
    80001518:	06848593          	addi	a1,s1,104
    8000151c:	8556                	mv	a0,s5
    8000151e:	00000097          	auipc	ra,0x0
    80001522:	640080e7          	jalr	1600(ra) # 80001b5e <swtch>
        c->proc = 0;
    80001526:	040a3023          	sd	zero,64(s4)
      release(&p->lock);
    8000152a:	8526                	mv	a0,s1
    8000152c:	00005097          	auipc	ra,0x5
    80001530:	164080e7          	jalr	356(ra) # 80006690 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001534:	17048493          	addi	s1,s1,368
    80001538:	fd2481e3          	beq	s1,s2,800014fa <scheduler+0x4c>
      acquire(&p->lock);
    8000153c:	8526                	mv	a0,s1
    8000153e:	00005097          	auipc	ra,0x5
    80001542:	082080e7          	jalr	130(ra) # 800065c0 <acquire>
      if(p->state == RUNNABLE) {
    80001546:	509c                	lw	a5,32(s1)
    80001548:	ff3791e3          	bne	a5,s3,8000152a <scheduler+0x7c>
    8000154c:	b7d1                	j	80001510 <scheduler+0x62>

000000008000154e <sched>:
{
    8000154e:	7179                	addi	sp,sp,-48
    80001550:	f406                	sd	ra,40(sp)
    80001552:	f022                	sd	s0,32(sp)
    80001554:	ec26                	sd	s1,24(sp)
    80001556:	e84a                	sd	s2,16(sp)
    80001558:	e44e                	sd	s3,8(sp)
    8000155a:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000155c:	00000097          	auipc	ra,0x0
    80001560:	a48080e7          	jalr	-1464(ra) # 80000fa4 <myproc>
    80001564:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001566:	00005097          	auipc	ra,0x5
    8000156a:	fe0080e7          	jalr	-32(ra) # 80006546 <holding>
    8000156e:	c93d                	beqz	a0,800015e4 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001570:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001572:	2781                	sext.w	a5,a5
    80001574:	079e                	slli	a5,a5,0x7
    80001576:	00008717          	auipc	a4,0x8
    8000157a:	bfa70713          	addi	a4,a4,-1030 # 80009170 <pid_lock>
    8000157e:	97ba                	add	a5,a5,a4
    80001580:	0b87a703          	lw	a4,184(a5)
    80001584:	4785                	li	a5,1
    80001586:	06f71763          	bne	a4,a5,800015f4 <sched+0xa6>
  if(p->state == RUNNING)
    8000158a:	5098                	lw	a4,32(s1)
    8000158c:	4791                	li	a5,4
    8000158e:	06f70b63          	beq	a4,a5,80001604 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001592:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001596:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001598:	efb5                	bnez	a5,80001614 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000159a:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000159c:	00008917          	auipc	s2,0x8
    800015a0:	bd490913          	addi	s2,s2,-1068 # 80009170 <pid_lock>
    800015a4:	2781                	sext.w	a5,a5
    800015a6:	079e                	slli	a5,a5,0x7
    800015a8:	97ca                	add	a5,a5,s2
    800015aa:	0bc7a983          	lw	s3,188(a5)
    800015ae:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800015b0:	2781                	sext.w	a5,a5
    800015b2:	079e                	slli	a5,a5,0x7
    800015b4:	00008597          	auipc	a1,0x8
    800015b8:	c0458593          	addi	a1,a1,-1020 # 800091b8 <cpus+0x8>
    800015bc:	95be                	add	a1,a1,a5
    800015be:	06848513          	addi	a0,s1,104
    800015c2:	00000097          	auipc	ra,0x0
    800015c6:	59c080e7          	jalr	1436(ra) # 80001b5e <swtch>
    800015ca:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800015cc:	2781                	sext.w	a5,a5
    800015ce:	079e                	slli	a5,a5,0x7
    800015d0:	97ca                	add	a5,a5,s2
    800015d2:	0b37ae23          	sw	s3,188(a5)
}
    800015d6:	70a2                	ld	ra,40(sp)
    800015d8:	7402                	ld	s0,32(sp)
    800015da:	64e2                	ld	s1,24(sp)
    800015dc:	6942                	ld	s2,16(sp)
    800015de:	69a2                	ld	s3,8(sp)
    800015e0:	6145                	addi	sp,sp,48
    800015e2:	8082                	ret
    panic("sched p->lock");
    800015e4:	00007517          	auipc	a0,0x7
    800015e8:	bbc50513          	addi	a0,a0,-1092 # 800081a0 <etext+0x1a0>
    800015ec:	00005097          	auipc	ra,0x5
    800015f0:	aa0080e7          	jalr	-1376(ra) # 8000608c <panic>
    panic("sched locks");
    800015f4:	00007517          	auipc	a0,0x7
    800015f8:	bbc50513          	addi	a0,a0,-1092 # 800081b0 <etext+0x1b0>
    800015fc:	00005097          	auipc	ra,0x5
    80001600:	a90080e7          	jalr	-1392(ra) # 8000608c <panic>
    panic("sched running");
    80001604:	00007517          	auipc	a0,0x7
    80001608:	bbc50513          	addi	a0,a0,-1092 # 800081c0 <etext+0x1c0>
    8000160c:	00005097          	auipc	ra,0x5
    80001610:	a80080e7          	jalr	-1408(ra) # 8000608c <panic>
    panic("sched interruptible");
    80001614:	00007517          	auipc	a0,0x7
    80001618:	bbc50513          	addi	a0,a0,-1092 # 800081d0 <etext+0x1d0>
    8000161c:	00005097          	auipc	ra,0x5
    80001620:	a70080e7          	jalr	-1424(ra) # 8000608c <panic>

0000000080001624 <yield>:
{
    80001624:	1101                	addi	sp,sp,-32
    80001626:	ec06                	sd	ra,24(sp)
    80001628:	e822                	sd	s0,16(sp)
    8000162a:	e426                	sd	s1,8(sp)
    8000162c:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000162e:	00000097          	auipc	ra,0x0
    80001632:	976080e7          	jalr	-1674(ra) # 80000fa4 <myproc>
    80001636:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001638:	00005097          	auipc	ra,0x5
    8000163c:	f88080e7          	jalr	-120(ra) # 800065c0 <acquire>
  p->state = RUNNABLE;
    80001640:	478d                	li	a5,3
    80001642:	d09c                	sw	a5,32(s1)
  sched();
    80001644:	00000097          	auipc	ra,0x0
    80001648:	f0a080e7          	jalr	-246(ra) # 8000154e <sched>
  release(&p->lock);
    8000164c:	8526                	mv	a0,s1
    8000164e:	00005097          	auipc	ra,0x5
    80001652:	042080e7          	jalr	66(ra) # 80006690 <release>
}
    80001656:	60e2                	ld	ra,24(sp)
    80001658:	6442                	ld	s0,16(sp)
    8000165a:	64a2                	ld	s1,8(sp)
    8000165c:	6105                	addi	sp,sp,32
    8000165e:	8082                	ret

0000000080001660 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001660:	7179                	addi	sp,sp,-48
    80001662:	f406                	sd	ra,40(sp)
    80001664:	f022                	sd	s0,32(sp)
    80001666:	ec26                	sd	s1,24(sp)
    80001668:	e84a                	sd	s2,16(sp)
    8000166a:	e44e                	sd	s3,8(sp)
    8000166c:	1800                	addi	s0,sp,48
    8000166e:	89aa                	mv	s3,a0
    80001670:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001672:	00000097          	auipc	ra,0x0
    80001676:	932080e7          	jalr	-1742(ra) # 80000fa4 <myproc>
    8000167a:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000167c:	00005097          	auipc	ra,0x5
    80001680:	f44080e7          	jalr	-188(ra) # 800065c0 <acquire>
  release(lk);
    80001684:	854a                	mv	a0,s2
    80001686:	00005097          	auipc	ra,0x5
    8000168a:	00a080e7          	jalr	10(ra) # 80006690 <release>

  // Go to sleep.
  p->chan = chan;
    8000168e:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    80001692:	4789                	li	a5,2
    80001694:	d09c                	sw	a5,32(s1)

  sched();
    80001696:	00000097          	auipc	ra,0x0
    8000169a:	eb8080e7          	jalr	-328(ra) # 8000154e <sched>

  // Tidy up.
  p->chan = 0;
    8000169e:	0204b423          	sd	zero,40(s1)

  // Reacquire original lock.
  release(&p->lock);
    800016a2:	8526                	mv	a0,s1
    800016a4:	00005097          	auipc	ra,0x5
    800016a8:	fec080e7          	jalr	-20(ra) # 80006690 <release>
  acquire(lk);
    800016ac:	854a                	mv	a0,s2
    800016ae:	00005097          	auipc	ra,0x5
    800016b2:	f12080e7          	jalr	-238(ra) # 800065c0 <acquire>
}
    800016b6:	70a2                	ld	ra,40(sp)
    800016b8:	7402                	ld	s0,32(sp)
    800016ba:	64e2                	ld	s1,24(sp)
    800016bc:	6942                	ld	s2,16(sp)
    800016be:	69a2                	ld	s3,8(sp)
    800016c0:	6145                	addi	sp,sp,48
    800016c2:	8082                	ret

00000000800016c4 <wait>:
{
    800016c4:	715d                	addi	sp,sp,-80
    800016c6:	e486                	sd	ra,72(sp)
    800016c8:	e0a2                	sd	s0,64(sp)
    800016ca:	fc26                	sd	s1,56(sp)
    800016cc:	f84a                	sd	s2,48(sp)
    800016ce:	f44e                	sd	s3,40(sp)
    800016d0:	f052                	sd	s4,32(sp)
    800016d2:	ec56                	sd	s5,24(sp)
    800016d4:	e85a                	sd	s6,16(sp)
    800016d6:	e45e                	sd	s7,8(sp)
    800016d8:	e062                	sd	s8,0(sp)
    800016da:	0880                	addi	s0,sp,80
    800016dc:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800016de:	00000097          	auipc	ra,0x0
    800016e2:	8c6080e7          	jalr	-1850(ra) # 80000fa4 <myproc>
    800016e6:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800016e8:	00008517          	auipc	a0,0x8
    800016ec:	aa850513          	addi	a0,a0,-1368 # 80009190 <wait_lock>
    800016f0:	00005097          	auipc	ra,0x5
    800016f4:	ed0080e7          	jalr	-304(ra) # 800065c0 <acquire>
    havekids = 0;
    800016f8:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    800016fa:	4a15                	li	s4,5
    for(np = proc; np < &proc[NPROC]; np++){
    800016fc:	0000e997          	auipc	s3,0xe
    80001700:	ab498993          	addi	s3,s3,-1356 # 8000f1b0 <tickslock>
        havekids = 1;
    80001704:	4a85                	li	s5,1
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80001706:	00008c17          	auipc	s8,0x8
    8000170a:	a8ac0c13          	addi	s8,s8,-1398 # 80009190 <wait_lock>
    havekids = 0;
    8000170e:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80001710:	00008497          	auipc	s1,0x8
    80001714:	ea048493          	addi	s1,s1,-352 # 800095b0 <proc>
    80001718:	a0bd                	j	80001786 <wait+0xc2>
          pid = np->pid;
    8000171a:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000171e:	000b0e63          	beqz	s6,8000173a <wait+0x76>
    80001722:	4691                	li	a3,4
    80001724:	03448613          	addi	a2,s1,52
    80001728:	85da                	mv	a1,s6
    8000172a:	05893503          	ld	a0,88(s2)
    8000172e:	fffff097          	auipc	ra,0xfffff
    80001732:	538080e7          	jalr	1336(ra) # 80000c66 <copyout>
    80001736:	02054563          	bltz	a0,80001760 <wait+0x9c>
          freeproc(np);
    8000173a:	8526                	mv	a0,s1
    8000173c:	00000097          	auipc	ra,0x0
    80001740:	a1a080e7          	jalr	-1510(ra) # 80001156 <freeproc>
          release(&np->lock);
    80001744:	8526                	mv	a0,s1
    80001746:	00005097          	auipc	ra,0x5
    8000174a:	f4a080e7          	jalr	-182(ra) # 80006690 <release>
          release(&wait_lock);
    8000174e:	00008517          	auipc	a0,0x8
    80001752:	a4250513          	addi	a0,a0,-1470 # 80009190 <wait_lock>
    80001756:	00005097          	auipc	ra,0x5
    8000175a:	f3a080e7          	jalr	-198(ra) # 80006690 <release>
          return pid;
    8000175e:	a09d                	j	800017c4 <wait+0x100>
            release(&np->lock);
    80001760:	8526                	mv	a0,s1
    80001762:	00005097          	auipc	ra,0x5
    80001766:	f2e080e7          	jalr	-210(ra) # 80006690 <release>
            release(&wait_lock);
    8000176a:	00008517          	auipc	a0,0x8
    8000176e:	a2650513          	addi	a0,a0,-1498 # 80009190 <wait_lock>
    80001772:	00005097          	auipc	ra,0x5
    80001776:	f1e080e7          	jalr	-226(ra) # 80006690 <release>
            return -1;
    8000177a:	59fd                	li	s3,-1
    8000177c:	a0a1                	j	800017c4 <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    8000177e:	17048493          	addi	s1,s1,368
    80001782:	03348463          	beq	s1,s3,800017aa <wait+0xe6>
      if(np->parent == p){
    80001786:	60bc                	ld	a5,64(s1)
    80001788:	ff279be3          	bne	a5,s2,8000177e <wait+0xba>
        acquire(&np->lock);
    8000178c:	8526                	mv	a0,s1
    8000178e:	00005097          	auipc	ra,0x5
    80001792:	e32080e7          	jalr	-462(ra) # 800065c0 <acquire>
        if(np->state == ZOMBIE){
    80001796:	509c                	lw	a5,32(s1)
    80001798:	f94781e3          	beq	a5,s4,8000171a <wait+0x56>
        release(&np->lock);
    8000179c:	8526                	mv	a0,s1
    8000179e:	00005097          	auipc	ra,0x5
    800017a2:	ef2080e7          	jalr	-270(ra) # 80006690 <release>
        havekids = 1;
    800017a6:	8756                	mv	a4,s5
    800017a8:	bfd9                	j	8000177e <wait+0xba>
    if(!havekids || p->killed){
    800017aa:	c701                	beqz	a4,800017b2 <wait+0xee>
    800017ac:	03092783          	lw	a5,48(s2)
    800017b0:	c79d                	beqz	a5,800017de <wait+0x11a>
      release(&wait_lock);
    800017b2:	00008517          	auipc	a0,0x8
    800017b6:	9de50513          	addi	a0,a0,-1570 # 80009190 <wait_lock>
    800017ba:	00005097          	auipc	ra,0x5
    800017be:	ed6080e7          	jalr	-298(ra) # 80006690 <release>
      return -1;
    800017c2:	59fd                	li	s3,-1
}
    800017c4:	854e                	mv	a0,s3
    800017c6:	60a6                	ld	ra,72(sp)
    800017c8:	6406                	ld	s0,64(sp)
    800017ca:	74e2                	ld	s1,56(sp)
    800017cc:	7942                	ld	s2,48(sp)
    800017ce:	79a2                	ld	s3,40(sp)
    800017d0:	7a02                	ld	s4,32(sp)
    800017d2:	6ae2                	ld	s5,24(sp)
    800017d4:	6b42                	ld	s6,16(sp)
    800017d6:	6ba2                	ld	s7,8(sp)
    800017d8:	6c02                	ld	s8,0(sp)
    800017da:	6161                	addi	sp,sp,80
    800017dc:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800017de:	85e2                	mv	a1,s8
    800017e0:	854a                	mv	a0,s2
    800017e2:	00000097          	auipc	ra,0x0
    800017e6:	e7e080e7          	jalr	-386(ra) # 80001660 <sleep>
    havekids = 0;
    800017ea:	b715                	j	8000170e <wait+0x4a>

00000000800017ec <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800017ec:	7139                	addi	sp,sp,-64
    800017ee:	fc06                	sd	ra,56(sp)
    800017f0:	f822                	sd	s0,48(sp)
    800017f2:	f426                	sd	s1,40(sp)
    800017f4:	f04a                	sd	s2,32(sp)
    800017f6:	ec4e                	sd	s3,24(sp)
    800017f8:	e852                	sd	s4,16(sp)
    800017fa:	e456                	sd	s5,8(sp)
    800017fc:	0080                	addi	s0,sp,64
    800017fe:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001800:	00008497          	auipc	s1,0x8
    80001804:	db048493          	addi	s1,s1,-592 # 800095b0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001808:	4989                	li	s3,2
        p->state = RUNNABLE;
    8000180a:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    8000180c:	0000e917          	auipc	s2,0xe
    80001810:	9a490913          	addi	s2,s2,-1628 # 8000f1b0 <tickslock>
    80001814:	a821                	j	8000182c <wakeup+0x40>
        p->state = RUNNABLE;
    80001816:	0354a023          	sw	s5,32(s1)
      }
      release(&p->lock);
    8000181a:	8526                	mv	a0,s1
    8000181c:	00005097          	auipc	ra,0x5
    80001820:	e74080e7          	jalr	-396(ra) # 80006690 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001824:	17048493          	addi	s1,s1,368
    80001828:	03248463          	beq	s1,s2,80001850 <wakeup+0x64>
    if(p != myproc()){
    8000182c:	fffff097          	auipc	ra,0xfffff
    80001830:	778080e7          	jalr	1912(ra) # 80000fa4 <myproc>
    80001834:	fea488e3          	beq	s1,a0,80001824 <wakeup+0x38>
      acquire(&p->lock);
    80001838:	8526                	mv	a0,s1
    8000183a:	00005097          	auipc	ra,0x5
    8000183e:	d86080e7          	jalr	-634(ra) # 800065c0 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001842:	509c                	lw	a5,32(s1)
    80001844:	fd379be3          	bne	a5,s3,8000181a <wakeup+0x2e>
    80001848:	749c                	ld	a5,40(s1)
    8000184a:	fd4798e3          	bne	a5,s4,8000181a <wakeup+0x2e>
    8000184e:	b7e1                	j	80001816 <wakeup+0x2a>
    }
  }
}
    80001850:	70e2                	ld	ra,56(sp)
    80001852:	7442                	ld	s0,48(sp)
    80001854:	74a2                	ld	s1,40(sp)
    80001856:	7902                	ld	s2,32(sp)
    80001858:	69e2                	ld	s3,24(sp)
    8000185a:	6a42                	ld	s4,16(sp)
    8000185c:	6aa2                	ld	s5,8(sp)
    8000185e:	6121                	addi	sp,sp,64
    80001860:	8082                	ret

0000000080001862 <reparent>:
{
    80001862:	7179                	addi	sp,sp,-48
    80001864:	f406                	sd	ra,40(sp)
    80001866:	f022                	sd	s0,32(sp)
    80001868:	ec26                	sd	s1,24(sp)
    8000186a:	e84a                	sd	s2,16(sp)
    8000186c:	e44e                	sd	s3,8(sp)
    8000186e:	e052                	sd	s4,0(sp)
    80001870:	1800                	addi	s0,sp,48
    80001872:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001874:	00008497          	auipc	s1,0x8
    80001878:	d3c48493          	addi	s1,s1,-708 # 800095b0 <proc>
      pp->parent = initproc;
    8000187c:	00007a17          	auipc	s4,0x7
    80001880:	794a0a13          	addi	s4,s4,1940 # 80009010 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001884:	0000e997          	auipc	s3,0xe
    80001888:	92c98993          	addi	s3,s3,-1748 # 8000f1b0 <tickslock>
    8000188c:	a029                	j	80001896 <reparent+0x34>
    8000188e:	17048493          	addi	s1,s1,368
    80001892:	01348d63          	beq	s1,s3,800018ac <reparent+0x4a>
    if(pp->parent == p){
    80001896:	60bc                	ld	a5,64(s1)
    80001898:	ff279be3          	bne	a5,s2,8000188e <reparent+0x2c>
      pp->parent = initproc;
    8000189c:	000a3503          	ld	a0,0(s4)
    800018a0:	e0a8                	sd	a0,64(s1)
      wakeup(initproc);
    800018a2:	00000097          	auipc	ra,0x0
    800018a6:	f4a080e7          	jalr	-182(ra) # 800017ec <wakeup>
    800018aa:	b7d5                	j	8000188e <reparent+0x2c>
}
    800018ac:	70a2                	ld	ra,40(sp)
    800018ae:	7402                	ld	s0,32(sp)
    800018b0:	64e2                	ld	s1,24(sp)
    800018b2:	6942                	ld	s2,16(sp)
    800018b4:	69a2                	ld	s3,8(sp)
    800018b6:	6a02                	ld	s4,0(sp)
    800018b8:	6145                	addi	sp,sp,48
    800018ba:	8082                	ret

00000000800018bc <exit>:
{
    800018bc:	7179                	addi	sp,sp,-48
    800018be:	f406                	sd	ra,40(sp)
    800018c0:	f022                	sd	s0,32(sp)
    800018c2:	ec26                	sd	s1,24(sp)
    800018c4:	e84a                	sd	s2,16(sp)
    800018c6:	e44e                	sd	s3,8(sp)
    800018c8:	e052                	sd	s4,0(sp)
    800018ca:	1800                	addi	s0,sp,48
    800018cc:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800018ce:	fffff097          	auipc	ra,0xfffff
    800018d2:	6d6080e7          	jalr	1750(ra) # 80000fa4 <myproc>
    800018d6:	89aa                	mv	s3,a0
  if(p == initproc)
    800018d8:	00007797          	auipc	a5,0x7
    800018dc:	7387b783          	ld	a5,1848(a5) # 80009010 <initproc>
    800018e0:	0d850493          	addi	s1,a0,216
    800018e4:	15850913          	addi	s2,a0,344
    800018e8:	02a79363          	bne	a5,a0,8000190e <exit+0x52>
    panic("init exiting");
    800018ec:	00007517          	auipc	a0,0x7
    800018f0:	8fc50513          	addi	a0,a0,-1796 # 800081e8 <etext+0x1e8>
    800018f4:	00004097          	auipc	ra,0x4
    800018f8:	798080e7          	jalr	1944(ra) # 8000608c <panic>
      fileclose(f);
    800018fc:	00002097          	auipc	ra,0x2
    80001900:	23c080e7          	jalr	572(ra) # 80003b38 <fileclose>
      p->ofile[fd] = 0;
    80001904:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80001908:	04a1                	addi	s1,s1,8
    8000190a:	01248563          	beq	s1,s2,80001914 <exit+0x58>
    if(p->ofile[fd]){
    8000190e:	6088                	ld	a0,0(s1)
    80001910:	f575                	bnez	a0,800018fc <exit+0x40>
    80001912:	bfdd                	j	80001908 <exit+0x4c>
  begin_op();
    80001914:	00002097          	auipc	ra,0x2
    80001918:	d58080e7          	jalr	-680(ra) # 8000366c <begin_op>
  iput(p->cwd);
    8000191c:	1589b503          	ld	a0,344(s3)
    80001920:	00001097          	auipc	ra,0x1
    80001924:	534080e7          	jalr	1332(ra) # 80002e54 <iput>
  end_op();
    80001928:	00002097          	auipc	ra,0x2
    8000192c:	dc4080e7          	jalr	-572(ra) # 800036ec <end_op>
  p->cwd = 0;
    80001930:	1409bc23          	sd	zero,344(s3)
  acquire(&wait_lock);
    80001934:	00008497          	auipc	s1,0x8
    80001938:	85c48493          	addi	s1,s1,-1956 # 80009190 <wait_lock>
    8000193c:	8526                	mv	a0,s1
    8000193e:	00005097          	auipc	ra,0x5
    80001942:	c82080e7          	jalr	-894(ra) # 800065c0 <acquire>
  reparent(p);
    80001946:	854e                	mv	a0,s3
    80001948:	00000097          	auipc	ra,0x0
    8000194c:	f1a080e7          	jalr	-230(ra) # 80001862 <reparent>
  wakeup(p->parent);
    80001950:	0409b503          	ld	a0,64(s3)
    80001954:	00000097          	auipc	ra,0x0
    80001958:	e98080e7          	jalr	-360(ra) # 800017ec <wakeup>
  acquire(&p->lock);
    8000195c:	854e                	mv	a0,s3
    8000195e:	00005097          	auipc	ra,0x5
    80001962:	c62080e7          	jalr	-926(ra) # 800065c0 <acquire>
  p->xstate = status;
    80001966:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    8000196a:	4795                	li	a5,5
    8000196c:	02f9a023          	sw	a5,32(s3)
  release(&wait_lock);
    80001970:	8526                	mv	a0,s1
    80001972:	00005097          	auipc	ra,0x5
    80001976:	d1e080e7          	jalr	-738(ra) # 80006690 <release>
  sched();
    8000197a:	00000097          	auipc	ra,0x0
    8000197e:	bd4080e7          	jalr	-1068(ra) # 8000154e <sched>
  panic("zombie exit");
    80001982:	00007517          	auipc	a0,0x7
    80001986:	87650513          	addi	a0,a0,-1930 # 800081f8 <etext+0x1f8>
    8000198a:	00004097          	auipc	ra,0x4
    8000198e:	702080e7          	jalr	1794(ra) # 8000608c <panic>

0000000080001992 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80001992:	7179                	addi	sp,sp,-48
    80001994:	f406                	sd	ra,40(sp)
    80001996:	f022                	sd	s0,32(sp)
    80001998:	ec26                	sd	s1,24(sp)
    8000199a:	e84a                	sd	s2,16(sp)
    8000199c:	e44e                	sd	s3,8(sp)
    8000199e:	1800                	addi	s0,sp,48
    800019a0:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800019a2:	00008497          	auipc	s1,0x8
    800019a6:	c0e48493          	addi	s1,s1,-1010 # 800095b0 <proc>
    800019aa:	0000e997          	auipc	s3,0xe
    800019ae:	80698993          	addi	s3,s3,-2042 # 8000f1b0 <tickslock>
    acquire(&p->lock);
    800019b2:	8526                	mv	a0,s1
    800019b4:	00005097          	auipc	ra,0x5
    800019b8:	c0c080e7          	jalr	-1012(ra) # 800065c0 <acquire>
    if(p->pid == pid){
    800019bc:	5c9c                	lw	a5,56(s1)
    800019be:	01278d63          	beq	a5,s2,800019d8 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800019c2:	8526                	mv	a0,s1
    800019c4:	00005097          	auipc	ra,0x5
    800019c8:	ccc080e7          	jalr	-820(ra) # 80006690 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800019cc:	17048493          	addi	s1,s1,368
    800019d0:	ff3491e3          	bne	s1,s3,800019b2 <kill+0x20>
  }
  return -1;
    800019d4:	557d                	li	a0,-1
    800019d6:	a829                	j	800019f0 <kill+0x5e>
      p->killed = 1;
    800019d8:	4785                	li	a5,1
    800019da:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    800019dc:	5098                	lw	a4,32(s1)
    800019de:	4789                	li	a5,2
    800019e0:	00f70f63          	beq	a4,a5,800019fe <kill+0x6c>
      release(&p->lock);
    800019e4:	8526                	mv	a0,s1
    800019e6:	00005097          	auipc	ra,0x5
    800019ea:	caa080e7          	jalr	-854(ra) # 80006690 <release>
      return 0;
    800019ee:	4501                	li	a0,0
}
    800019f0:	70a2                	ld	ra,40(sp)
    800019f2:	7402                	ld	s0,32(sp)
    800019f4:	64e2                	ld	s1,24(sp)
    800019f6:	6942                	ld	s2,16(sp)
    800019f8:	69a2                	ld	s3,8(sp)
    800019fa:	6145                	addi	sp,sp,48
    800019fc:	8082                	ret
        p->state = RUNNABLE;
    800019fe:	478d                	li	a5,3
    80001a00:	d09c                	sw	a5,32(s1)
    80001a02:	b7cd                	j	800019e4 <kill+0x52>

0000000080001a04 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80001a04:	7179                	addi	sp,sp,-48
    80001a06:	f406                	sd	ra,40(sp)
    80001a08:	f022                	sd	s0,32(sp)
    80001a0a:	ec26                	sd	s1,24(sp)
    80001a0c:	e84a                	sd	s2,16(sp)
    80001a0e:	e44e                	sd	s3,8(sp)
    80001a10:	e052                	sd	s4,0(sp)
    80001a12:	1800                	addi	s0,sp,48
    80001a14:	84aa                	mv	s1,a0
    80001a16:	892e                	mv	s2,a1
    80001a18:	89b2                	mv	s3,a2
    80001a1a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80001a1c:	fffff097          	auipc	ra,0xfffff
    80001a20:	588080e7          	jalr	1416(ra) # 80000fa4 <myproc>
  if(user_dst){
    80001a24:	c08d                	beqz	s1,80001a46 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80001a26:	86d2                	mv	a3,s4
    80001a28:	864e                	mv	a2,s3
    80001a2a:	85ca                	mv	a1,s2
    80001a2c:	6d28                	ld	a0,88(a0)
    80001a2e:	fffff097          	auipc	ra,0xfffff
    80001a32:	238080e7          	jalr	568(ra) # 80000c66 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80001a36:	70a2                	ld	ra,40(sp)
    80001a38:	7402                	ld	s0,32(sp)
    80001a3a:	64e2                	ld	s1,24(sp)
    80001a3c:	6942                	ld	s2,16(sp)
    80001a3e:	69a2                	ld	s3,8(sp)
    80001a40:	6a02                	ld	s4,0(sp)
    80001a42:	6145                	addi	sp,sp,48
    80001a44:	8082                	ret
    memmove((char *)dst, src, len);
    80001a46:	000a061b          	sext.w	a2,s4
    80001a4a:	85ce                	mv	a1,s3
    80001a4c:	854a                	mv	a0,s2
    80001a4e:	fffff097          	auipc	ra,0xfffff
    80001a52:	8d6080e7          	jalr	-1834(ra) # 80000324 <memmove>
    return 0;
    80001a56:	8526                	mv	a0,s1
    80001a58:	bff9                	j	80001a36 <either_copyout+0x32>

0000000080001a5a <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80001a5a:	7179                	addi	sp,sp,-48
    80001a5c:	f406                	sd	ra,40(sp)
    80001a5e:	f022                	sd	s0,32(sp)
    80001a60:	ec26                	sd	s1,24(sp)
    80001a62:	e84a                	sd	s2,16(sp)
    80001a64:	e44e                	sd	s3,8(sp)
    80001a66:	e052                	sd	s4,0(sp)
    80001a68:	1800                	addi	s0,sp,48
    80001a6a:	892a                	mv	s2,a0
    80001a6c:	84ae                	mv	s1,a1
    80001a6e:	89b2                	mv	s3,a2
    80001a70:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80001a72:	fffff097          	auipc	ra,0xfffff
    80001a76:	532080e7          	jalr	1330(ra) # 80000fa4 <myproc>
  if(user_src){
    80001a7a:	c08d                	beqz	s1,80001a9c <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80001a7c:	86d2                	mv	a3,s4
    80001a7e:	864e                	mv	a2,s3
    80001a80:	85ca                	mv	a1,s2
    80001a82:	6d28                	ld	a0,88(a0)
    80001a84:	fffff097          	auipc	ra,0xfffff
    80001a88:	26e080e7          	jalr	622(ra) # 80000cf2 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80001a8c:	70a2                	ld	ra,40(sp)
    80001a8e:	7402                	ld	s0,32(sp)
    80001a90:	64e2                	ld	s1,24(sp)
    80001a92:	6942                	ld	s2,16(sp)
    80001a94:	69a2                	ld	s3,8(sp)
    80001a96:	6a02                	ld	s4,0(sp)
    80001a98:	6145                	addi	sp,sp,48
    80001a9a:	8082                	ret
    memmove(dst, (char*)src, len);
    80001a9c:	000a061b          	sext.w	a2,s4
    80001aa0:	85ce                	mv	a1,s3
    80001aa2:	854a                	mv	a0,s2
    80001aa4:	fffff097          	auipc	ra,0xfffff
    80001aa8:	880080e7          	jalr	-1920(ra) # 80000324 <memmove>
    return 0;
    80001aac:	8526                	mv	a0,s1
    80001aae:	bff9                	j	80001a8c <either_copyin+0x32>

0000000080001ab0 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80001ab0:	715d                	addi	sp,sp,-80
    80001ab2:	e486                	sd	ra,72(sp)
    80001ab4:	e0a2                	sd	s0,64(sp)
    80001ab6:	fc26                	sd	s1,56(sp)
    80001ab8:	f84a                	sd	s2,48(sp)
    80001aba:	f44e                	sd	s3,40(sp)
    80001abc:	f052                	sd	s4,32(sp)
    80001abe:	ec56                	sd	s5,24(sp)
    80001ac0:	e85a                	sd	s6,16(sp)
    80001ac2:	e45e                	sd	s7,8(sp)
    80001ac4:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80001ac6:	00007517          	auipc	a0,0x7
    80001aca:	db250513          	addi	a0,a0,-590 # 80008878 <digits+0x88>
    80001ace:	00004097          	auipc	ra,0x4
    80001ad2:	608080e7          	jalr	1544(ra) # 800060d6 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001ad6:	00008497          	auipc	s1,0x8
    80001ada:	c3a48493          	addi	s1,s1,-966 # 80009710 <proc+0x160>
    80001ade:	0000e917          	auipc	s2,0xe
    80001ae2:	83290913          	addi	s2,s2,-1998 # 8000f310 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001ae6:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80001ae8:	00006997          	auipc	s3,0x6
    80001aec:	72098993          	addi	s3,s3,1824 # 80008208 <etext+0x208>
    printf("%d %s %s", p->pid, state, p->name);
    80001af0:	00006a97          	auipc	s5,0x6
    80001af4:	720a8a93          	addi	s5,s5,1824 # 80008210 <etext+0x210>
    printf("\n");
    80001af8:	00007a17          	auipc	s4,0x7
    80001afc:	d80a0a13          	addi	s4,s4,-640 # 80008878 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001b00:	00006b97          	auipc	s7,0x6
    80001b04:	748b8b93          	addi	s7,s7,1864 # 80008248 <states.1725>
    80001b08:	a00d                	j	80001b2a <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80001b0a:	ed86a583          	lw	a1,-296(a3)
    80001b0e:	8556                	mv	a0,s5
    80001b10:	00004097          	auipc	ra,0x4
    80001b14:	5c6080e7          	jalr	1478(ra) # 800060d6 <printf>
    printf("\n");
    80001b18:	8552                	mv	a0,s4
    80001b1a:	00004097          	auipc	ra,0x4
    80001b1e:	5bc080e7          	jalr	1468(ra) # 800060d6 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001b22:	17048493          	addi	s1,s1,368
    80001b26:	03248163          	beq	s1,s2,80001b48 <procdump+0x98>
    if(p->state == UNUSED)
    80001b2a:	86a6                	mv	a3,s1
    80001b2c:	ec04a783          	lw	a5,-320(s1)
    80001b30:	dbed                	beqz	a5,80001b22 <procdump+0x72>
      state = "???";
    80001b32:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001b34:	fcfb6be3          	bltu	s6,a5,80001b0a <procdump+0x5a>
    80001b38:	1782                	slli	a5,a5,0x20
    80001b3a:	9381                	srli	a5,a5,0x20
    80001b3c:	078e                	slli	a5,a5,0x3
    80001b3e:	97de                	add	a5,a5,s7
    80001b40:	6390                	ld	a2,0(a5)
    80001b42:	f661                	bnez	a2,80001b0a <procdump+0x5a>
      state = "???";
    80001b44:	864e                	mv	a2,s3
    80001b46:	b7d1                	j	80001b0a <procdump+0x5a>
  }
}
    80001b48:	60a6                	ld	ra,72(sp)
    80001b4a:	6406                	ld	s0,64(sp)
    80001b4c:	74e2                	ld	s1,56(sp)
    80001b4e:	7942                	ld	s2,48(sp)
    80001b50:	79a2                	ld	s3,40(sp)
    80001b52:	7a02                	ld	s4,32(sp)
    80001b54:	6ae2                	ld	s5,24(sp)
    80001b56:	6b42                	ld	s6,16(sp)
    80001b58:	6ba2                	ld	s7,8(sp)
    80001b5a:	6161                	addi	sp,sp,80
    80001b5c:	8082                	ret

0000000080001b5e <swtch>:
    80001b5e:	00153023          	sd	ra,0(a0)
    80001b62:	00253423          	sd	sp,8(a0)
    80001b66:	e900                	sd	s0,16(a0)
    80001b68:	ed04                	sd	s1,24(a0)
    80001b6a:	03253023          	sd	s2,32(a0)
    80001b6e:	03353423          	sd	s3,40(a0)
    80001b72:	03453823          	sd	s4,48(a0)
    80001b76:	03553c23          	sd	s5,56(a0)
    80001b7a:	05653023          	sd	s6,64(a0)
    80001b7e:	05753423          	sd	s7,72(a0)
    80001b82:	05853823          	sd	s8,80(a0)
    80001b86:	05953c23          	sd	s9,88(a0)
    80001b8a:	07a53023          	sd	s10,96(a0)
    80001b8e:	07b53423          	sd	s11,104(a0)
    80001b92:	0005b083          	ld	ra,0(a1)
    80001b96:	0085b103          	ld	sp,8(a1)
    80001b9a:	6980                	ld	s0,16(a1)
    80001b9c:	6d84                	ld	s1,24(a1)
    80001b9e:	0205b903          	ld	s2,32(a1)
    80001ba2:	0285b983          	ld	s3,40(a1)
    80001ba6:	0305ba03          	ld	s4,48(a1)
    80001baa:	0385ba83          	ld	s5,56(a1)
    80001bae:	0405bb03          	ld	s6,64(a1)
    80001bb2:	0485bb83          	ld	s7,72(a1)
    80001bb6:	0505bc03          	ld	s8,80(a1)
    80001bba:	0585bc83          	ld	s9,88(a1)
    80001bbe:	0605bd03          	ld	s10,96(a1)
    80001bc2:	0685bd83          	ld	s11,104(a1)
    80001bc6:	8082                	ret

0000000080001bc8 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80001bc8:	1141                	addi	sp,sp,-16
    80001bca:	e406                	sd	ra,8(sp)
    80001bcc:	e022                	sd	s0,0(sp)
    80001bce:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80001bd0:	00006597          	auipc	a1,0x6
    80001bd4:	6a858593          	addi	a1,a1,1704 # 80008278 <states.1725+0x30>
    80001bd8:	0000d517          	auipc	a0,0xd
    80001bdc:	5d850513          	addi	a0,a0,1496 # 8000f1b0 <tickslock>
    80001be0:	00005097          	auipc	ra,0x5
    80001be4:	b5c080e7          	jalr	-1188(ra) # 8000673c <initlock>
}
    80001be8:	60a2                	ld	ra,8(sp)
    80001bea:	6402                	ld	s0,0(sp)
    80001bec:	0141                	addi	sp,sp,16
    80001bee:	8082                	ret

0000000080001bf0 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80001bf0:	1141                	addi	sp,sp,-16
    80001bf2:	e422                	sd	s0,8(sp)
    80001bf4:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001bf6:	00003797          	auipc	a5,0x3
    80001bfa:	56a78793          	addi	a5,a5,1386 # 80005160 <kernelvec>
    80001bfe:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80001c02:	6422                	ld	s0,8(sp)
    80001c04:	0141                	addi	sp,sp,16
    80001c06:	8082                	ret

0000000080001c08 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80001c08:	1141                	addi	sp,sp,-16
    80001c0a:	e406                	sd	ra,8(sp)
    80001c0c:	e022                	sd	s0,0(sp)
    80001c0e:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80001c10:	fffff097          	auipc	ra,0xfffff
    80001c14:	394080e7          	jalr	916(ra) # 80000fa4 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001c18:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001c1c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001c1e:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80001c22:	00005617          	auipc	a2,0x5
    80001c26:	3de60613          	addi	a2,a2,990 # 80007000 <_trampoline>
    80001c2a:	00005697          	auipc	a3,0x5
    80001c2e:	3d668693          	addi	a3,a3,982 # 80007000 <_trampoline>
    80001c32:	8e91                	sub	a3,a3,a2
    80001c34:	040007b7          	lui	a5,0x4000
    80001c38:	17fd                	addi	a5,a5,-1
    80001c3a:	07b2                	slli	a5,a5,0xc
    80001c3c:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001c3e:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80001c42:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80001c44:	180026f3          	csrr	a3,satp
    80001c48:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80001c4a:	7138                	ld	a4,96(a0)
    80001c4c:	6534                	ld	a3,72(a0)
    80001c4e:	6585                	lui	a1,0x1
    80001c50:	96ae                	add	a3,a3,a1
    80001c52:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80001c54:	7138                	ld	a4,96(a0)
    80001c56:	00000697          	auipc	a3,0x0
    80001c5a:	13868693          	addi	a3,a3,312 # 80001d8e <usertrap>
    80001c5e:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80001c60:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80001c62:	8692                	mv	a3,tp
    80001c64:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001c66:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80001c6a:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80001c6e:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001c72:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80001c76:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001c78:	6f18                	ld	a4,24(a4)
    80001c7a:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80001c7e:	6d2c                	ld	a1,88(a0)
    80001c80:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80001c82:	00005717          	auipc	a4,0x5
    80001c86:	40e70713          	addi	a4,a4,1038 # 80007090 <userret>
    80001c8a:	8f11                	sub	a4,a4,a2
    80001c8c:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80001c8e:	577d                	li	a4,-1
    80001c90:	177e                	slli	a4,a4,0x3f
    80001c92:	8dd9                	or	a1,a1,a4
    80001c94:	02000537          	lui	a0,0x2000
    80001c98:	157d                	addi	a0,a0,-1
    80001c9a:	0536                	slli	a0,a0,0xd
    80001c9c:	9782                	jalr	a5
}
    80001c9e:	60a2                	ld	ra,8(sp)
    80001ca0:	6402                	ld	s0,0(sp)
    80001ca2:	0141                	addi	sp,sp,16
    80001ca4:	8082                	ret

0000000080001ca6 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80001ca6:	1101                	addi	sp,sp,-32
    80001ca8:	ec06                	sd	ra,24(sp)
    80001caa:	e822                	sd	s0,16(sp)
    80001cac:	e426                	sd	s1,8(sp)
    80001cae:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80001cb0:	0000d497          	auipc	s1,0xd
    80001cb4:	50048493          	addi	s1,s1,1280 # 8000f1b0 <tickslock>
    80001cb8:	8526                	mv	a0,s1
    80001cba:	00005097          	auipc	ra,0x5
    80001cbe:	906080e7          	jalr	-1786(ra) # 800065c0 <acquire>
  ticks++;
    80001cc2:	00007517          	auipc	a0,0x7
    80001cc6:	35650513          	addi	a0,a0,854 # 80009018 <ticks>
    80001cca:	411c                	lw	a5,0(a0)
    80001ccc:	2785                	addiw	a5,a5,1
    80001cce:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80001cd0:	00000097          	auipc	ra,0x0
    80001cd4:	b1c080e7          	jalr	-1252(ra) # 800017ec <wakeup>
  release(&tickslock);
    80001cd8:	8526                	mv	a0,s1
    80001cda:	00005097          	auipc	ra,0x5
    80001cde:	9b6080e7          	jalr	-1610(ra) # 80006690 <release>
}
    80001ce2:	60e2                	ld	ra,24(sp)
    80001ce4:	6442                	ld	s0,16(sp)
    80001ce6:	64a2                	ld	s1,8(sp)
    80001ce8:	6105                	addi	sp,sp,32
    80001cea:	8082                	ret

0000000080001cec <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80001cec:	1101                	addi	sp,sp,-32
    80001cee:	ec06                	sd	ra,24(sp)
    80001cf0:	e822                	sd	s0,16(sp)
    80001cf2:	e426                	sd	s1,8(sp)
    80001cf4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001cf6:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80001cfa:	00074d63          	bltz	a4,80001d14 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80001cfe:	57fd                	li	a5,-1
    80001d00:	17fe                	slli	a5,a5,0x3f
    80001d02:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80001d04:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80001d06:	06f70363          	beq	a4,a5,80001d6c <devintr+0x80>
  }
}
    80001d0a:	60e2                	ld	ra,24(sp)
    80001d0c:	6442                	ld	s0,16(sp)
    80001d0e:	64a2                	ld	s1,8(sp)
    80001d10:	6105                	addi	sp,sp,32
    80001d12:	8082                	ret
     (scause & 0xff) == 9){
    80001d14:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80001d18:	46a5                	li	a3,9
    80001d1a:	fed792e3          	bne	a5,a3,80001cfe <devintr+0x12>
    int irq = plic_claim();
    80001d1e:	00003097          	auipc	ra,0x3
    80001d22:	54a080e7          	jalr	1354(ra) # 80005268 <plic_claim>
    80001d26:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80001d28:	47a9                	li	a5,10
    80001d2a:	02f50763          	beq	a0,a5,80001d58 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80001d2e:	4785                	li	a5,1
    80001d30:	02f50963          	beq	a0,a5,80001d62 <devintr+0x76>
    return 1;
    80001d34:	4505                	li	a0,1
    } else if(irq){
    80001d36:	d8f1                	beqz	s1,80001d0a <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80001d38:	85a6                	mv	a1,s1
    80001d3a:	00006517          	auipc	a0,0x6
    80001d3e:	54650513          	addi	a0,a0,1350 # 80008280 <states.1725+0x38>
    80001d42:	00004097          	auipc	ra,0x4
    80001d46:	394080e7          	jalr	916(ra) # 800060d6 <printf>
      plic_complete(irq);
    80001d4a:	8526                	mv	a0,s1
    80001d4c:	00003097          	auipc	ra,0x3
    80001d50:	540080e7          	jalr	1344(ra) # 8000528c <plic_complete>
    return 1;
    80001d54:	4505                	li	a0,1
    80001d56:	bf55                	j	80001d0a <devintr+0x1e>
      uartintr();
    80001d58:	00004097          	auipc	ra,0x4
    80001d5c:	79e080e7          	jalr	1950(ra) # 800064f6 <uartintr>
    80001d60:	b7ed                	j	80001d4a <devintr+0x5e>
      virtio_disk_intr();
    80001d62:	00004097          	auipc	ra,0x4
    80001d66:	a0a080e7          	jalr	-1526(ra) # 8000576c <virtio_disk_intr>
    80001d6a:	b7c5                	j	80001d4a <devintr+0x5e>
    if(cpuid() == 0){
    80001d6c:	fffff097          	auipc	ra,0xfffff
    80001d70:	20c080e7          	jalr	524(ra) # 80000f78 <cpuid>
    80001d74:	c901                	beqz	a0,80001d84 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80001d76:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80001d7a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80001d7c:	14479073          	csrw	sip,a5
    return 2;
    80001d80:	4509                	li	a0,2
    80001d82:	b761                	j	80001d0a <devintr+0x1e>
      clockintr();
    80001d84:	00000097          	auipc	ra,0x0
    80001d88:	f22080e7          	jalr	-222(ra) # 80001ca6 <clockintr>
    80001d8c:	b7ed                	j	80001d76 <devintr+0x8a>

0000000080001d8e <usertrap>:
{
    80001d8e:	1101                	addi	sp,sp,-32
    80001d90:	ec06                	sd	ra,24(sp)
    80001d92:	e822                	sd	s0,16(sp)
    80001d94:	e426                	sd	s1,8(sp)
    80001d96:	e04a                	sd	s2,0(sp)
    80001d98:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d9a:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80001d9e:	1007f793          	andi	a5,a5,256
    80001da2:	e3ad                	bnez	a5,80001e04 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001da4:	00003797          	auipc	a5,0x3
    80001da8:	3bc78793          	addi	a5,a5,956 # 80005160 <kernelvec>
    80001dac:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80001db0:	fffff097          	auipc	ra,0xfffff
    80001db4:	1f4080e7          	jalr	500(ra) # 80000fa4 <myproc>
    80001db8:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80001dba:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001dbc:	14102773          	csrr	a4,sepc
    80001dc0:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001dc2:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80001dc6:	47a1                	li	a5,8
    80001dc8:	04f71c63          	bne	a4,a5,80001e20 <usertrap+0x92>
    if(p->killed)
    80001dcc:	591c                	lw	a5,48(a0)
    80001dce:	e3b9                	bnez	a5,80001e14 <usertrap+0x86>
    p->trapframe->epc += 4;
    80001dd0:	70b8                	ld	a4,96(s1)
    80001dd2:	6f1c                	ld	a5,24(a4)
    80001dd4:	0791                	addi	a5,a5,4
    80001dd6:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001dd8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001ddc:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001de0:	10079073          	csrw	sstatus,a5
    syscall();
    80001de4:	00000097          	auipc	ra,0x0
    80001de8:	2e0080e7          	jalr	736(ra) # 800020c4 <syscall>
  if(p->killed)
    80001dec:	589c                	lw	a5,48(s1)
    80001dee:	ebc1                	bnez	a5,80001e7e <usertrap+0xf0>
  usertrapret();
    80001df0:	00000097          	auipc	ra,0x0
    80001df4:	e18080e7          	jalr	-488(ra) # 80001c08 <usertrapret>
}
    80001df8:	60e2                	ld	ra,24(sp)
    80001dfa:	6442                	ld	s0,16(sp)
    80001dfc:	64a2                	ld	s1,8(sp)
    80001dfe:	6902                	ld	s2,0(sp)
    80001e00:	6105                	addi	sp,sp,32
    80001e02:	8082                	ret
    panic("usertrap: not from user mode");
    80001e04:	00006517          	auipc	a0,0x6
    80001e08:	49c50513          	addi	a0,a0,1180 # 800082a0 <states.1725+0x58>
    80001e0c:	00004097          	auipc	ra,0x4
    80001e10:	280080e7          	jalr	640(ra) # 8000608c <panic>
      exit(-1);
    80001e14:	557d                	li	a0,-1
    80001e16:	00000097          	auipc	ra,0x0
    80001e1a:	aa6080e7          	jalr	-1370(ra) # 800018bc <exit>
    80001e1e:	bf4d                	j	80001dd0 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80001e20:	00000097          	auipc	ra,0x0
    80001e24:	ecc080e7          	jalr	-308(ra) # 80001cec <devintr>
    80001e28:	892a                	mv	s2,a0
    80001e2a:	c501                	beqz	a0,80001e32 <usertrap+0xa4>
  if(p->killed)
    80001e2c:	589c                	lw	a5,48(s1)
    80001e2e:	c3a1                	beqz	a5,80001e6e <usertrap+0xe0>
    80001e30:	a815                	j	80001e64 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001e32:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80001e36:	5c90                	lw	a2,56(s1)
    80001e38:	00006517          	auipc	a0,0x6
    80001e3c:	48850513          	addi	a0,a0,1160 # 800082c0 <states.1725+0x78>
    80001e40:	00004097          	auipc	ra,0x4
    80001e44:	296080e7          	jalr	662(ra) # 800060d6 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001e48:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001e4c:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80001e50:	00006517          	auipc	a0,0x6
    80001e54:	4a050513          	addi	a0,a0,1184 # 800082f0 <states.1725+0xa8>
    80001e58:	00004097          	auipc	ra,0x4
    80001e5c:	27e080e7          	jalr	638(ra) # 800060d6 <printf>
    p->killed = 1;
    80001e60:	4785                	li	a5,1
    80001e62:	d89c                	sw	a5,48(s1)
    exit(-1);
    80001e64:	557d                	li	a0,-1
    80001e66:	00000097          	auipc	ra,0x0
    80001e6a:	a56080e7          	jalr	-1450(ra) # 800018bc <exit>
  if(which_dev == 2)
    80001e6e:	4789                	li	a5,2
    80001e70:	f8f910e3          	bne	s2,a5,80001df0 <usertrap+0x62>
    yield();
    80001e74:	fffff097          	auipc	ra,0xfffff
    80001e78:	7b0080e7          	jalr	1968(ra) # 80001624 <yield>
    80001e7c:	bf95                	j	80001df0 <usertrap+0x62>
  int which_dev = 0;
    80001e7e:	4901                	li	s2,0
    80001e80:	b7d5                	j	80001e64 <usertrap+0xd6>

0000000080001e82 <kerneltrap>:
{
    80001e82:	7179                	addi	sp,sp,-48
    80001e84:	f406                	sd	ra,40(sp)
    80001e86:	f022                	sd	s0,32(sp)
    80001e88:	ec26                	sd	s1,24(sp)
    80001e8a:	e84a                	sd	s2,16(sp)
    80001e8c:	e44e                	sd	s3,8(sp)
    80001e8e:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001e90:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e94:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001e98:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80001e9c:	1004f793          	andi	a5,s1,256
    80001ea0:	cb85                	beqz	a5,80001ed0 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ea2:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001ea6:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80001ea8:	ef85                	bnez	a5,80001ee0 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80001eaa:	00000097          	auipc	ra,0x0
    80001eae:	e42080e7          	jalr	-446(ra) # 80001cec <devintr>
    80001eb2:	cd1d                	beqz	a0,80001ef0 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80001eb4:	4789                	li	a5,2
    80001eb6:	06f50a63          	beq	a0,a5,80001f2a <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001eba:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001ebe:	10049073          	csrw	sstatus,s1
}
    80001ec2:	70a2                	ld	ra,40(sp)
    80001ec4:	7402                	ld	s0,32(sp)
    80001ec6:	64e2                	ld	s1,24(sp)
    80001ec8:	6942                	ld	s2,16(sp)
    80001eca:	69a2                	ld	s3,8(sp)
    80001ecc:	6145                	addi	sp,sp,48
    80001ece:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80001ed0:	00006517          	auipc	a0,0x6
    80001ed4:	44050513          	addi	a0,a0,1088 # 80008310 <states.1725+0xc8>
    80001ed8:	00004097          	auipc	ra,0x4
    80001edc:	1b4080e7          	jalr	436(ra) # 8000608c <panic>
    panic("kerneltrap: interrupts enabled");
    80001ee0:	00006517          	auipc	a0,0x6
    80001ee4:	45850513          	addi	a0,a0,1112 # 80008338 <states.1725+0xf0>
    80001ee8:	00004097          	auipc	ra,0x4
    80001eec:	1a4080e7          	jalr	420(ra) # 8000608c <panic>
    printf("scause %p\n", scause);
    80001ef0:	85ce                	mv	a1,s3
    80001ef2:	00006517          	auipc	a0,0x6
    80001ef6:	46650513          	addi	a0,a0,1126 # 80008358 <states.1725+0x110>
    80001efa:	00004097          	auipc	ra,0x4
    80001efe:	1dc080e7          	jalr	476(ra) # 800060d6 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001f02:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001f06:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80001f0a:	00006517          	auipc	a0,0x6
    80001f0e:	45e50513          	addi	a0,a0,1118 # 80008368 <states.1725+0x120>
    80001f12:	00004097          	auipc	ra,0x4
    80001f16:	1c4080e7          	jalr	452(ra) # 800060d6 <printf>
    panic("kerneltrap");
    80001f1a:	00006517          	auipc	a0,0x6
    80001f1e:	46650513          	addi	a0,a0,1126 # 80008380 <states.1725+0x138>
    80001f22:	00004097          	auipc	ra,0x4
    80001f26:	16a080e7          	jalr	362(ra) # 8000608c <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80001f2a:	fffff097          	auipc	ra,0xfffff
    80001f2e:	07a080e7          	jalr	122(ra) # 80000fa4 <myproc>
    80001f32:	d541                	beqz	a0,80001eba <kerneltrap+0x38>
    80001f34:	fffff097          	auipc	ra,0xfffff
    80001f38:	070080e7          	jalr	112(ra) # 80000fa4 <myproc>
    80001f3c:	5118                	lw	a4,32(a0)
    80001f3e:	4791                	li	a5,4
    80001f40:	f6f71de3          	bne	a4,a5,80001eba <kerneltrap+0x38>
    yield();
    80001f44:	fffff097          	auipc	ra,0xfffff
    80001f48:	6e0080e7          	jalr	1760(ra) # 80001624 <yield>
    80001f4c:	b7bd                	j	80001eba <kerneltrap+0x38>

0000000080001f4e <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80001f4e:	1101                	addi	sp,sp,-32
    80001f50:	ec06                	sd	ra,24(sp)
    80001f52:	e822                	sd	s0,16(sp)
    80001f54:	e426                	sd	s1,8(sp)
    80001f56:	1000                	addi	s0,sp,32
    80001f58:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001f5a:	fffff097          	auipc	ra,0xfffff
    80001f5e:	04a080e7          	jalr	74(ra) # 80000fa4 <myproc>
  switch (n) {
    80001f62:	4795                	li	a5,5
    80001f64:	0497e163          	bltu	a5,s1,80001fa6 <argraw+0x58>
    80001f68:	048a                	slli	s1,s1,0x2
    80001f6a:	00006717          	auipc	a4,0x6
    80001f6e:	44e70713          	addi	a4,a4,1102 # 800083b8 <states.1725+0x170>
    80001f72:	94ba                	add	s1,s1,a4
    80001f74:	409c                	lw	a5,0(s1)
    80001f76:	97ba                	add	a5,a5,a4
    80001f78:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80001f7a:	713c                	ld	a5,96(a0)
    80001f7c:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80001f7e:	60e2                	ld	ra,24(sp)
    80001f80:	6442                	ld	s0,16(sp)
    80001f82:	64a2                	ld	s1,8(sp)
    80001f84:	6105                	addi	sp,sp,32
    80001f86:	8082                	ret
    return p->trapframe->a1;
    80001f88:	713c                	ld	a5,96(a0)
    80001f8a:	7fa8                	ld	a0,120(a5)
    80001f8c:	bfcd                	j	80001f7e <argraw+0x30>
    return p->trapframe->a2;
    80001f8e:	713c                	ld	a5,96(a0)
    80001f90:	63c8                	ld	a0,128(a5)
    80001f92:	b7f5                	j	80001f7e <argraw+0x30>
    return p->trapframe->a3;
    80001f94:	713c                	ld	a5,96(a0)
    80001f96:	67c8                	ld	a0,136(a5)
    80001f98:	b7dd                	j	80001f7e <argraw+0x30>
    return p->trapframe->a4;
    80001f9a:	713c                	ld	a5,96(a0)
    80001f9c:	6bc8                	ld	a0,144(a5)
    80001f9e:	b7c5                	j	80001f7e <argraw+0x30>
    return p->trapframe->a5;
    80001fa0:	713c                	ld	a5,96(a0)
    80001fa2:	6fc8                	ld	a0,152(a5)
    80001fa4:	bfe9                	j	80001f7e <argraw+0x30>
  panic("argraw");
    80001fa6:	00006517          	auipc	a0,0x6
    80001faa:	3ea50513          	addi	a0,a0,1002 # 80008390 <states.1725+0x148>
    80001fae:	00004097          	auipc	ra,0x4
    80001fb2:	0de080e7          	jalr	222(ra) # 8000608c <panic>

0000000080001fb6 <fetchaddr>:
{
    80001fb6:	1101                	addi	sp,sp,-32
    80001fb8:	ec06                	sd	ra,24(sp)
    80001fba:	e822                	sd	s0,16(sp)
    80001fbc:	e426                	sd	s1,8(sp)
    80001fbe:	e04a                	sd	s2,0(sp)
    80001fc0:	1000                	addi	s0,sp,32
    80001fc2:	84aa                	mv	s1,a0
    80001fc4:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001fc6:	fffff097          	auipc	ra,0xfffff
    80001fca:	fde080e7          	jalr	-34(ra) # 80000fa4 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80001fce:	693c                	ld	a5,80(a0)
    80001fd0:	02f4f863          	bgeu	s1,a5,80002000 <fetchaddr+0x4a>
    80001fd4:	00848713          	addi	a4,s1,8
    80001fd8:	02e7e663          	bltu	a5,a4,80002004 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80001fdc:	46a1                	li	a3,8
    80001fde:	8626                	mv	a2,s1
    80001fe0:	85ca                	mv	a1,s2
    80001fe2:	6d28                	ld	a0,88(a0)
    80001fe4:	fffff097          	auipc	ra,0xfffff
    80001fe8:	d0e080e7          	jalr	-754(ra) # 80000cf2 <copyin>
    80001fec:	00a03533          	snez	a0,a0
    80001ff0:	40a00533          	neg	a0,a0
}
    80001ff4:	60e2                	ld	ra,24(sp)
    80001ff6:	6442                	ld	s0,16(sp)
    80001ff8:	64a2                	ld	s1,8(sp)
    80001ffa:	6902                	ld	s2,0(sp)
    80001ffc:	6105                	addi	sp,sp,32
    80001ffe:	8082                	ret
    return -1;
    80002000:	557d                	li	a0,-1
    80002002:	bfcd                	j	80001ff4 <fetchaddr+0x3e>
    80002004:	557d                	li	a0,-1
    80002006:	b7fd                	j	80001ff4 <fetchaddr+0x3e>

0000000080002008 <fetchstr>:
{
    80002008:	7179                	addi	sp,sp,-48
    8000200a:	f406                	sd	ra,40(sp)
    8000200c:	f022                	sd	s0,32(sp)
    8000200e:	ec26                	sd	s1,24(sp)
    80002010:	e84a                	sd	s2,16(sp)
    80002012:	e44e                	sd	s3,8(sp)
    80002014:	1800                	addi	s0,sp,48
    80002016:	892a                	mv	s2,a0
    80002018:	84ae                	mv	s1,a1
    8000201a:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    8000201c:	fffff097          	auipc	ra,0xfffff
    80002020:	f88080e7          	jalr	-120(ra) # 80000fa4 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002024:	86ce                	mv	a3,s3
    80002026:	864a                	mv	a2,s2
    80002028:	85a6                	mv	a1,s1
    8000202a:	6d28                	ld	a0,88(a0)
    8000202c:	fffff097          	auipc	ra,0xfffff
    80002030:	d52080e7          	jalr	-686(ra) # 80000d7e <copyinstr>
  if(err < 0)
    80002034:	00054763          	bltz	a0,80002042 <fetchstr+0x3a>
  return strlen(buf);
    80002038:	8526                	mv	a0,s1
    8000203a:	ffffe097          	auipc	ra,0xffffe
    8000203e:	40e080e7          	jalr	1038(ra) # 80000448 <strlen>
}
    80002042:	70a2                	ld	ra,40(sp)
    80002044:	7402                	ld	s0,32(sp)
    80002046:	64e2                	ld	s1,24(sp)
    80002048:	6942                	ld	s2,16(sp)
    8000204a:	69a2                	ld	s3,8(sp)
    8000204c:	6145                	addi	sp,sp,48
    8000204e:	8082                	ret

0000000080002050 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002050:	1101                	addi	sp,sp,-32
    80002052:	ec06                	sd	ra,24(sp)
    80002054:	e822                	sd	s0,16(sp)
    80002056:	e426                	sd	s1,8(sp)
    80002058:	1000                	addi	s0,sp,32
    8000205a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000205c:	00000097          	auipc	ra,0x0
    80002060:	ef2080e7          	jalr	-270(ra) # 80001f4e <argraw>
    80002064:	c088                	sw	a0,0(s1)
  return 0;
}
    80002066:	4501                	li	a0,0
    80002068:	60e2                	ld	ra,24(sp)
    8000206a:	6442                	ld	s0,16(sp)
    8000206c:	64a2                	ld	s1,8(sp)
    8000206e:	6105                	addi	sp,sp,32
    80002070:	8082                	ret

0000000080002072 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002072:	1101                	addi	sp,sp,-32
    80002074:	ec06                	sd	ra,24(sp)
    80002076:	e822                	sd	s0,16(sp)
    80002078:	e426                	sd	s1,8(sp)
    8000207a:	1000                	addi	s0,sp,32
    8000207c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000207e:	00000097          	auipc	ra,0x0
    80002082:	ed0080e7          	jalr	-304(ra) # 80001f4e <argraw>
    80002086:	e088                	sd	a0,0(s1)
  return 0;
}
    80002088:	4501                	li	a0,0
    8000208a:	60e2                	ld	ra,24(sp)
    8000208c:	6442                	ld	s0,16(sp)
    8000208e:	64a2                	ld	s1,8(sp)
    80002090:	6105                	addi	sp,sp,32
    80002092:	8082                	ret

0000000080002094 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002094:	1101                	addi	sp,sp,-32
    80002096:	ec06                	sd	ra,24(sp)
    80002098:	e822                	sd	s0,16(sp)
    8000209a:	e426                	sd	s1,8(sp)
    8000209c:	e04a                	sd	s2,0(sp)
    8000209e:	1000                	addi	s0,sp,32
    800020a0:	84ae                	mv	s1,a1
    800020a2:	8932                	mv	s2,a2
  *ip = argraw(n);
    800020a4:	00000097          	auipc	ra,0x0
    800020a8:	eaa080e7          	jalr	-342(ra) # 80001f4e <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    800020ac:	864a                	mv	a2,s2
    800020ae:	85a6                	mv	a1,s1
    800020b0:	00000097          	auipc	ra,0x0
    800020b4:	f58080e7          	jalr	-168(ra) # 80002008 <fetchstr>
}
    800020b8:	60e2                	ld	ra,24(sp)
    800020ba:	6442                	ld	s0,16(sp)
    800020bc:	64a2                	ld	s1,8(sp)
    800020be:	6902                	ld	s2,0(sp)
    800020c0:	6105                	addi	sp,sp,32
    800020c2:	8082                	ret

00000000800020c4 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    800020c4:	1101                	addi	sp,sp,-32
    800020c6:	ec06                	sd	ra,24(sp)
    800020c8:	e822                	sd	s0,16(sp)
    800020ca:	e426                	sd	s1,8(sp)
    800020cc:	e04a                	sd	s2,0(sp)
    800020ce:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800020d0:	fffff097          	auipc	ra,0xfffff
    800020d4:	ed4080e7          	jalr	-300(ra) # 80000fa4 <myproc>
    800020d8:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    800020da:	06053903          	ld	s2,96(a0)
    800020de:	0a893783          	ld	a5,168(s2)
    800020e2:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800020e6:	37fd                	addiw	a5,a5,-1
    800020e8:	4751                	li	a4,20
    800020ea:	00f76f63          	bltu	a4,a5,80002108 <syscall+0x44>
    800020ee:	00369713          	slli	a4,a3,0x3
    800020f2:	00006797          	auipc	a5,0x6
    800020f6:	2de78793          	addi	a5,a5,734 # 800083d0 <syscalls>
    800020fa:	97ba                	add	a5,a5,a4
    800020fc:	639c                	ld	a5,0(a5)
    800020fe:	c789                	beqz	a5,80002108 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002100:	9782                	jalr	a5
    80002102:	06a93823          	sd	a0,112(s2)
    80002106:	a839                	j	80002124 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002108:	16048613          	addi	a2,s1,352
    8000210c:	5c8c                	lw	a1,56(s1)
    8000210e:	00006517          	auipc	a0,0x6
    80002112:	28a50513          	addi	a0,a0,650 # 80008398 <states.1725+0x150>
    80002116:	00004097          	auipc	ra,0x4
    8000211a:	fc0080e7          	jalr	-64(ra) # 800060d6 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    8000211e:	70bc                	ld	a5,96(s1)
    80002120:	577d                	li	a4,-1
    80002122:	fbb8                	sd	a4,112(a5)
  }
}
    80002124:	60e2                	ld	ra,24(sp)
    80002126:	6442                	ld	s0,16(sp)
    80002128:	64a2                	ld	s1,8(sp)
    8000212a:	6902                	ld	s2,0(sp)
    8000212c:	6105                	addi	sp,sp,32
    8000212e:	8082                	ret

0000000080002130 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002130:	1101                	addi	sp,sp,-32
    80002132:	ec06                	sd	ra,24(sp)
    80002134:	e822                	sd	s0,16(sp)
    80002136:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002138:	fec40593          	addi	a1,s0,-20
    8000213c:	4501                	li	a0,0
    8000213e:	00000097          	auipc	ra,0x0
    80002142:	f12080e7          	jalr	-238(ra) # 80002050 <argint>
    return -1;
    80002146:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002148:	00054963          	bltz	a0,8000215a <sys_exit+0x2a>
  exit(n);
    8000214c:	fec42503          	lw	a0,-20(s0)
    80002150:	fffff097          	auipc	ra,0xfffff
    80002154:	76c080e7          	jalr	1900(ra) # 800018bc <exit>
  return 0;  // not reached
    80002158:	4781                	li	a5,0
}
    8000215a:	853e                	mv	a0,a5
    8000215c:	60e2                	ld	ra,24(sp)
    8000215e:	6442                	ld	s0,16(sp)
    80002160:	6105                	addi	sp,sp,32
    80002162:	8082                	ret

0000000080002164 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002164:	1141                	addi	sp,sp,-16
    80002166:	e406                	sd	ra,8(sp)
    80002168:	e022                	sd	s0,0(sp)
    8000216a:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000216c:	fffff097          	auipc	ra,0xfffff
    80002170:	e38080e7          	jalr	-456(ra) # 80000fa4 <myproc>
}
    80002174:	5d08                	lw	a0,56(a0)
    80002176:	60a2                	ld	ra,8(sp)
    80002178:	6402                	ld	s0,0(sp)
    8000217a:	0141                	addi	sp,sp,16
    8000217c:	8082                	ret

000000008000217e <sys_fork>:

uint64
sys_fork(void)
{
    8000217e:	1141                	addi	sp,sp,-16
    80002180:	e406                	sd	ra,8(sp)
    80002182:	e022                	sd	s0,0(sp)
    80002184:	0800                	addi	s0,sp,16
  return fork();
    80002186:	fffff097          	auipc	ra,0xfffff
    8000218a:	1ec080e7          	jalr	492(ra) # 80001372 <fork>
}
    8000218e:	60a2                	ld	ra,8(sp)
    80002190:	6402                	ld	s0,0(sp)
    80002192:	0141                	addi	sp,sp,16
    80002194:	8082                	ret

0000000080002196 <sys_wait>:

uint64
sys_wait(void)
{
    80002196:	1101                	addi	sp,sp,-32
    80002198:	ec06                	sd	ra,24(sp)
    8000219a:	e822                	sd	s0,16(sp)
    8000219c:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    8000219e:	fe840593          	addi	a1,s0,-24
    800021a2:	4501                	li	a0,0
    800021a4:	00000097          	auipc	ra,0x0
    800021a8:	ece080e7          	jalr	-306(ra) # 80002072 <argaddr>
    800021ac:	87aa                	mv	a5,a0
    return -1;
    800021ae:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    800021b0:	0007c863          	bltz	a5,800021c0 <sys_wait+0x2a>
  return wait(p);
    800021b4:	fe843503          	ld	a0,-24(s0)
    800021b8:	fffff097          	auipc	ra,0xfffff
    800021bc:	50c080e7          	jalr	1292(ra) # 800016c4 <wait>
}
    800021c0:	60e2                	ld	ra,24(sp)
    800021c2:	6442                	ld	s0,16(sp)
    800021c4:	6105                	addi	sp,sp,32
    800021c6:	8082                	ret

00000000800021c8 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800021c8:	7179                	addi	sp,sp,-48
    800021ca:	f406                	sd	ra,40(sp)
    800021cc:	f022                	sd	s0,32(sp)
    800021ce:	ec26                	sd	s1,24(sp)
    800021d0:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    800021d2:	fdc40593          	addi	a1,s0,-36
    800021d6:	4501                	li	a0,0
    800021d8:	00000097          	auipc	ra,0x0
    800021dc:	e78080e7          	jalr	-392(ra) # 80002050 <argint>
    800021e0:	87aa                	mv	a5,a0
    return -1;
    800021e2:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    800021e4:	0207c063          	bltz	a5,80002204 <sys_sbrk+0x3c>
  addr = myproc()->sz;
    800021e8:	fffff097          	auipc	ra,0xfffff
    800021ec:	dbc080e7          	jalr	-580(ra) # 80000fa4 <myproc>
    800021f0:	4924                	lw	s1,80(a0)
  if(growproc(n) < 0)
    800021f2:	fdc42503          	lw	a0,-36(s0)
    800021f6:	fffff097          	auipc	ra,0xfffff
    800021fa:	108080e7          	jalr	264(ra) # 800012fe <growproc>
    800021fe:	00054863          	bltz	a0,8000220e <sys_sbrk+0x46>
    return -1;
  return addr;
    80002202:	8526                	mv	a0,s1
}
    80002204:	70a2                	ld	ra,40(sp)
    80002206:	7402                	ld	s0,32(sp)
    80002208:	64e2                	ld	s1,24(sp)
    8000220a:	6145                	addi	sp,sp,48
    8000220c:	8082                	ret
    return -1;
    8000220e:	557d                	li	a0,-1
    80002210:	bfd5                	j	80002204 <sys_sbrk+0x3c>

0000000080002212 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002212:	7139                	addi	sp,sp,-64
    80002214:	fc06                	sd	ra,56(sp)
    80002216:	f822                	sd	s0,48(sp)
    80002218:	f426                	sd	s1,40(sp)
    8000221a:	f04a                	sd	s2,32(sp)
    8000221c:	ec4e                	sd	s3,24(sp)
    8000221e:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002220:	fcc40593          	addi	a1,s0,-52
    80002224:	4501                	li	a0,0
    80002226:	00000097          	auipc	ra,0x0
    8000222a:	e2a080e7          	jalr	-470(ra) # 80002050 <argint>
    return -1;
    8000222e:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002230:	06054563          	bltz	a0,8000229a <sys_sleep+0x88>
  acquire(&tickslock);
    80002234:	0000d517          	auipc	a0,0xd
    80002238:	f7c50513          	addi	a0,a0,-132 # 8000f1b0 <tickslock>
    8000223c:	00004097          	auipc	ra,0x4
    80002240:	384080e7          	jalr	900(ra) # 800065c0 <acquire>
  ticks0 = ticks;
    80002244:	00007917          	auipc	s2,0x7
    80002248:	dd492903          	lw	s2,-556(s2) # 80009018 <ticks>
  while(ticks - ticks0 < n){
    8000224c:	fcc42783          	lw	a5,-52(s0)
    80002250:	cf85                	beqz	a5,80002288 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002252:	0000d997          	auipc	s3,0xd
    80002256:	f5e98993          	addi	s3,s3,-162 # 8000f1b0 <tickslock>
    8000225a:	00007497          	auipc	s1,0x7
    8000225e:	dbe48493          	addi	s1,s1,-578 # 80009018 <ticks>
    if(myproc()->killed){
    80002262:	fffff097          	auipc	ra,0xfffff
    80002266:	d42080e7          	jalr	-702(ra) # 80000fa4 <myproc>
    8000226a:	591c                	lw	a5,48(a0)
    8000226c:	ef9d                	bnez	a5,800022aa <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    8000226e:	85ce                	mv	a1,s3
    80002270:	8526                	mv	a0,s1
    80002272:	fffff097          	auipc	ra,0xfffff
    80002276:	3ee080e7          	jalr	1006(ra) # 80001660 <sleep>
  while(ticks - ticks0 < n){
    8000227a:	409c                	lw	a5,0(s1)
    8000227c:	412787bb          	subw	a5,a5,s2
    80002280:	fcc42703          	lw	a4,-52(s0)
    80002284:	fce7efe3          	bltu	a5,a4,80002262 <sys_sleep+0x50>
  }
  release(&tickslock);
    80002288:	0000d517          	auipc	a0,0xd
    8000228c:	f2850513          	addi	a0,a0,-216 # 8000f1b0 <tickslock>
    80002290:	00004097          	auipc	ra,0x4
    80002294:	400080e7          	jalr	1024(ra) # 80006690 <release>
  return 0;
    80002298:	4781                	li	a5,0
}
    8000229a:	853e                	mv	a0,a5
    8000229c:	70e2                	ld	ra,56(sp)
    8000229e:	7442                	ld	s0,48(sp)
    800022a0:	74a2                	ld	s1,40(sp)
    800022a2:	7902                	ld	s2,32(sp)
    800022a4:	69e2                	ld	s3,24(sp)
    800022a6:	6121                	addi	sp,sp,64
    800022a8:	8082                	ret
      release(&tickslock);
    800022aa:	0000d517          	auipc	a0,0xd
    800022ae:	f0650513          	addi	a0,a0,-250 # 8000f1b0 <tickslock>
    800022b2:	00004097          	auipc	ra,0x4
    800022b6:	3de080e7          	jalr	990(ra) # 80006690 <release>
      return -1;
    800022ba:	57fd                	li	a5,-1
    800022bc:	bff9                	j	8000229a <sys_sleep+0x88>

00000000800022be <sys_kill>:

uint64
sys_kill(void)
{
    800022be:	1101                	addi	sp,sp,-32
    800022c0:	ec06                	sd	ra,24(sp)
    800022c2:	e822                	sd	s0,16(sp)
    800022c4:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    800022c6:	fec40593          	addi	a1,s0,-20
    800022ca:	4501                	li	a0,0
    800022cc:	00000097          	auipc	ra,0x0
    800022d0:	d84080e7          	jalr	-636(ra) # 80002050 <argint>
    800022d4:	87aa                	mv	a5,a0
    return -1;
    800022d6:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    800022d8:	0007c863          	bltz	a5,800022e8 <sys_kill+0x2a>
  return kill(pid);
    800022dc:	fec42503          	lw	a0,-20(s0)
    800022e0:	fffff097          	auipc	ra,0xfffff
    800022e4:	6b2080e7          	jalr	1714(ra) # 80001992 <kill>
}
    800022e8:	60e2                	ld	ra,24(sp)
    800022ea:	6442                	ld	s0,16(sp)
    800022ec:	6105                	addi	sp,sp,32
    800022ee:	8082                	ret

00000000800022f0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800022f0:	1101                	addi	sp,sp,-32
    800022f2:	ec06                	sd	ra,24(sp)
    800022f4:	e822                	sd	s0,16(sp)
    800022f6:	e426                	sd	s1,8(sp)
    800022f8:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800022fa:	0000d517          	auipc	a0,0xd
    800022fe:	eb650513          	addi	a0,a0,-330 # 8000f1b0 <tickslock>
    80002302:	00004097          	auipc	ra,0x4
    80002306:	2be080e7          	jalr	702(ra) # 800065c0 <acquire>
  xticks = ticks;
    8000230a:	00007497          	auipc	s1,0x7
    8000230e:	d0e4a483          	lw	s1,-754(s1) # 80009018 <ticks>
  release(&tickslock);
    80002312:	0000d517          	auipc	a0,0xd
    80002316:	e9e50513          	addi	a0,a0,-354 # 8000f1b0 <tickslock>
    8000231a:	00004097          	auipc	ra,0x4
    8000231e:	376080e7          	jalr	886(ra) # 80006690 <release>
  return xticks;
}
    80002322:	02049513          	slli	a0,s1,0x20
    80002326:	9101                	srli	a0,a0,0x20
    80002328:	60e2                	ld	ra,24(sp)
    8000232a:	6442                	ld	s0,16(sp)
    8000232c:	64a2                	ld	s1,8(sp)
    8000232e:	6105                	addi	sp,sp,32
    80002330:	8082                	ret

0000000080002332 <binit>:
  b->head.next = &b->head;
}

void
binit(void)
{
    80002332:	7179                	addi	sp,sp,-48
    80002334:	f406                	sd	ra,40(sp)
    80002336:	f022                	sd	s0,32(sp)
    80002338:	ec26                	sd	s1,24(sp)
    8000233a:	e84a                	sd	s2,16(sp)
    8000233c:	e44e                	sd	s3,8(sp)
    8000233e:	1800                	addi	s0,sp,48
  for (int i = 0; i < NBUF; ++i) {
    80002340:	0000d497          	auipc	s1,0xd
    80002344:	ea848493          	addi	s1,s1,-344 # 8000f1e8 <bcache+0x18>
    80002348:	00015997          	auipc	s3,0x15
    8000234c:	2d098993          	addi	s3,s3,720 # 80017618 <bcache+0x8448>
    initsleeplock(&bcache.buf[i].lock, "buffer");
    80002350:	00006917          	auipc	s2,0x6
    80002354:	13090913          	addi	s2,s2,304 # 80008480 <syscalls+0xb0>
    80002358:	85ca                	mv	a1,s2
    8000235a:	8526                	mv	a0,s1
    8000235c:	00001097          	auipc	ra,0x1
    80002360:	5ce080e7          	jalr	1486(ra) # 8000392a <initsleeplock>
  for (int i = 0; i < NBUF; ++i) {
    80002364:	46848493          	addi	s1,s1,1128
    80002368:	ff3498e3          	bne	s1,s3,80002358 <binit+0x26>
    8000236c:	00015497          	auipc	s1,0x15
    80002370:	29448493          	addi	s1,s1,660 # 80017600 <bcache+0x8430>
    80002374:	0000d917          	auipc	s2,0xd
    80002378:	e5c90913          	addi	s2,s2,-420 # 8000f1d0 <bcache>
    8000237c:	67b1                	lui	a5,0xc
    8000237e:	f1878793          	addi	a5,a5,-232 # bf18 <_entry-0x7fff40e8>
    80002382:	993e                	add	s2,s2,a5
  initlock(&b->lock, "bcache.bucket");
    80002384:	00006997          	auipc	s3,0x6
    80002388:	10498993          	addi	s3,s3,260 # 80008488 <syscalls+0xb8>
    8000238c:	85ce                	mv	a1,s3
    8000238e:	8526                	mv	a0,s1
    80002390:	00004097          	auipc	ra,0x4
    80002394:	3ac080e7          	jalr	940(ra) # 8000673c <initlock>
  b->head.prev = &b->head;
    80002398:	02048793          	addi	a5,s1,32
    8000239c:	fcbc                	sd	a5,120(s1)
  b->head.next = &b->head;
    8000239e:	e0dc                	sd	a5,128(s1)
  }
  for (int i = 0; i < NBUCKET; ++i) {
    800023a0:	48848493          	addi	s1,s1,1160
    800023a4:	ff2494e3          	bne	s1,s2,8000238c <binit+0x5a>
    initbucket(&bcache.bucket[i]);
  }
}
    800023a8:	70a2                	ld	ra,40(sp)
    800023aa:	7402                	ld	s0,32(sp)
    800023ac:	64e2                	ld	s1,24(sp)
    800023ae:	6942                	ld	s2,16(sp)
    800023b0:	69a2                	ld	s3,8(sp)
    800023b2:	6145                	addi	sp,sp,48
    800023b4:	8082                	ret

00000000800023b6 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800023b6:	715d                	addi	sp,sp,-80
    800023b8:	e486                	sd	ra,72(sp)
    800023ba:	e0a2                	sd	s0,64(sp)
    800023bc:	fc26                	sd	s1,56(sp)
    800023be:	f84a                	sd	s2,48(sp)
    800023c0:	f44e                	sd	s3,40(sp)
    800023c2:	f052                	sd	s4,32(sp)
    800023c4:	ec56                	sd	s5,24(sp)
    800023c6:	e85a                	sd	s6,16(sp)
    800023c8:	e45e                	sd	s7,8(sp)
    800023ca:	e062                	sd	s8,0(sp)
    800023cc:	0880                	addi	s0,sp,80
    800023ce:	8baa                	mv	s7,a0
    800023d0:	8b2e                	mv	s6,a1
  return key % NBUCKET;
    800023d2:	4ab5                	li	s5,13
    800023d4:	0355fabb          	remuw	s5,a1,s5
  acquire(&bucket->lock);
    800023d8:	020a9493          	slli	s1,s5,0x20
    800023dc:	9081                	srli	s1,s1,0x20
    800023de:	48800793          	li	a5,1160
    800023e2:	02f484b3          	mul	s1,s1,a5
    800023e6:	6a21                	lui	s4,0x8
    800023e8:	430a0993          	addi	s3,s4,1072 # 8430 <_entry-0x7fff7bd0>
    800023ec:	99a6                	add	s3,s3,s1
    800023ee:	0000dc17          	auipc	s8,0xd
    800023f2:	de2c0c13          	addi	s8,s8,-542 # 8000f1d0 <bcache>
    800023f6:	99e2                	add	s3,s3,s8
    800023f8:	854e                	mv	a0,s3
    800023fa:	00004097          	auipc	ra,0x4
    800023fe:	1c6080e7          	jalr	454(ra) # 800065c0 <acquire>
  for (struct buf *buf = bucket->head.next; buf != &bucket->head;
    80002402:	009c07b3          	add	a5,s8,s1
    80002406:	97d2                	add	a5,a5,s4
    80002408:	4b07b903          	ld	s2,1200(a5)
    8000240c:	450a0a13          	addi	s4,s4,1104
    80002410:	94d2                	add	s1,s1,s4
    80002412:	94e2                	add	s1,s1,s8
    80002414:	00991e63          	bne	s2,s1,80002430 <bread+0x7a>
  for (int i = 0; i < NBUF; ++i) {
    80002418:	0000d797          	auipc	a5,0xd
    8000241c:	db878793          	addi	a5,a5,-584 # 8000f1d0 <bcache>
    80002420:	4501                	li	a0,0
        !__atomic_test_and_set(&bcache.buf[i].used, __ATOMIC_ACQUIRE)) {
    80002422:	4885                	li	a7,1
  for (int i = 0; i < NBUF; ++i) {
    80002424:	4879                	li	a6,30
    80002426:	a099                	j	8000246c <bread+0xb6>
       buf = buf->next) {
    80002428:	06093903          	ld	s2,96(s2)
  for (struct buf *buf = bucket->head.next; buf != &bucket->head;
    8000242c:	fe9906e3          	beq	s2,s1,80002418 <bread+0x62>
    if(buf->dev == dev && buf->blockno == blockno){
    80002430:	00c92783          	lw	a5,12(s2)
    80002434:	ff779ae3          	bne	a5,s7,80002428 <bread+0x72>
    80002438:	01092783          	lw	a5,16(s2)
    8000243c:	ff6796e3          	bne	a5,s6,80002428 <bread+0x72>
      buf->refcnt++;
    80002440:	05092783          	lw	a5,80(s2)
    80002444:	2785                	addiw	a5,a5,1
    80002446:	04f92823          	sw	a5,80(s2)
      release(&bucket->lock);
    8000244a:	854e                	mv	a0,s3
    8000244c:	00004097          	auipc	ra,0x4
    80002450:	244080e7          	jalr	580(ra) # 80006690 <release>
      acquiresleep(&buf->lock);
    80002454:	01890513          	addi	a0,s2,24
    80002458:	00001097          	auipc	ra,0x1
    8000245c:	50c080e7          	jalr	1292(ra) # 80003964 <acquiresleep>
      return buf;
    80002460:	a849                	j	800024f2 <bread+0x13c>
  for (int i = 0; i < NBUF; ++i) {
    80002462:	2505                	addiw	a0,a0,1
    80002464:	46878793          	addi	a5,a5,1128
    80002468:	0b050563          	beq	a0,a6,80002512 <bread+0x15c>
    if (!bcache.buf[i].used &&
    8000246c:	893e                	mv	s2,a5
    8000246e:	0007c703          	lbu	a4,0(a5)
    80002472:	fb65                	bnez	a4,80002462 <bread+0xac>
        !__atomic_test_and_set(&bcache.buf[i].used, __ATOMIC_ACQUIRE)) {
    80002474:	ffc7f693          	andi	a3,a5,-4
    80002478:	0037f713          	andi	a4,a5,3
    8000247c:	0037161b          	slliw	a2,a4,0x3
    80002480:	00c895bb          	sllw	a1,a7,a2
    80002484:	44b6a72f          	amoor.w.aq	a4,a1,(a3)
    80002488:	00c7573b          	srlw	a4,a4,a2
    8000248c:	0ff77713          	andi	a4,a4,255
    if (!bcache.buf[i].used &&
    80002490:	fb69                	bnez	a4,80002462 <bread+0xac>
      buf->dev = dev;
    80002492:	0000dc17          	auipc	s8,0xd
    80002496:	d3ec0c13          	addi	s8,s8,-706 # 8000f1d0 <bcache>
    8000249a:	46800a13          	li	s4,1128
    8000249e:	03450a33          	mul	s4,a0,s4
    800024a2:	014c07b3          	add	a5,s8,s4
    800024a6:	0177a623          	sw	s7,12(a5)
      buf->blockno = blockno;
    800024aa:	0167a823          	sw	s6,16(a5)
      buf->valid = 0;
    800024ae:	0007a223          	sw	zero,4(a5)
      buf->refcnt = 1;
    800024b2:	4705                	li	a4,1
    800024b4:	cbb8                	sw	a4,80(a5)
      buf->next = bucket->head.next;
    800024b6:	1a82                	slli	s5,s5,0x20
    800024b8:	020ada93          	srli	s5,s5,0x20
    800024bc:	48800713          	li	a4,1160
    800024c0:	02ea8ab3          	mul	s5,s5,a4
    800024c4:	9ae2                	add	s5,s5,s8
    800024c6:	6721                	lui	a4,0x8
    800024c8:	9aba                	add	s5,s5,a4
    800024ca:	4b0ab703          	ld	a4,1200(s5)
    800024ce:	f3b8                	sd	a4,96(a5)
      buf->prev = &bucket->head;
    800024d0:	efa4                	sd	s1,88(a5)
      bucket->head.next->prev = buf;
    800024d2:	05273c23          	sd	s2,88(a4) # 8058 <_entry-0x7fff7fa8>
      bucket->head.next = buf;
    800024d6:	4b2ab823          	sd	s2,1200(s5)
      release(&bucket->lock);
    800024da:	854e                	mv	a0,s3
    800024dc:	00004097          	auipc	ra,0x4
    800024e0:	1b4080e7          	jalr	436(ra) # 80006690 <release>
      acquiresleep(&buf->lock);
    800024e4:	018a0513          	addi	a0,s4,24
    800024e8:	9562                	add	a0,a0,s8
    800024ea:	00001097          	auipc	ra,0x1
    800024ee:	47a080e7          	jalr	1146(ra) # 80003964 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800024f2:	00492783          	lw	a5,4(s2)
    800024f6:	c795                	beqz	a5,80002522 <bread+0x16c>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800024f8:	854a                	mv	a0,s2
    800024fa:	60a6                	ld	ra,72(sp)
    800024fc:	6406                	ld	s0,64(sp)
    800024fe:	74e2                	ld	s1,56(sp)
    80002500:	7942                	ld	s2,48(sp)
    80002502:	79a2                	ld	s3,40(sp)
    80002504:	7a02                	ld	s4,32(sp)
    80002506:	6ae2                	ld	s5,24(sp)
    80002508:	6b42                	ld	s6,16(sp)
    8000250a:	6ba2                	ld	s7,8(sp)
    8000250c:	6c02                	ld	s8,0(sp)
    8000250e:	6161                	addi	sp,sp,80
    80002510:	8082                	ret
  panic("bget: no buffers");
    80002512:	00006517          	auipc	a0,0x6
    80002516:	f8650513          	addi	a0,a0,-122 # 80008498 <syscalls+0xc8>
    8000251a:	00004097          	auipc	ra,0x4
    8000251e:	b72080e7          	jalr	-1166(ra) # 8000608c <panic>
    virtio_disk_rw(b, 0);
    80002522:	4581                	li	a1,0
    80002524:	854a                	mv	a0,s2
    80002526:	00003097          	auipc	ra,0x3
    8000252a:	f70080e7          	jalr	-144(ra) # 80005496 <virtio_disk_rw>
    b->valid = 1;
    8000252e:	4785                	li	a5,1
    80002530:	00f92223          	sw	a5,4(s2)
  return b;
    80002534:	b7d1                	j	800024f8 <bread+0x142>

0000000080002536 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002536:	1101                	addi	sp,sp,-32
    80002538:	ec06                	sd	ra,24(sp)
    8000253a:	e822                	sd	s0,16(sp)
    8000253c:	e426                	sd	s1,8(sp)
    8000253e:	1000                	addi	s0,sp,32
    80002540:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002542:	0561                	addi	a0,a0,24
    80002544:	00001097          	auipc	ra,0x1
    80002548:	4ba080e7          	jalr	1210(ra) # 800039fe <holdingsleep>
    8000254c:	cd01                	beqz	a0,80002564 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000254e:	4585                	li	a1,1
    80002550:	8526                	mv	a0,s1
    80002552:	00003097          	auipc	ra,0x3
    80002556:	f44080e7          	jalr	-188(ra) # 80005496 <virtio_disk_rw>
}
    8000255a:	60e2                	ld	ra,24(sp)
    8000255c:	6442                	ld	s0,16(sp)
    8000255e:	64a2                	ld	s1,8(sp)
    80002560:	6105                	addi	sp,sp,32
    80002562:	8082                	ret
    panic("bwrite");
    80002564:	00006517          	auipc	a0,0x6
    80002568:	f4c50513          	addi	a0,a0,-180 # 800084b0 <syscalls+0xe0>
    8000256c:	00004097          	auipc	ra,0x4
    80002570:	b20080e7          	jalr	-1248(ra) # 8000608c <panic>

0000000080002574 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002574:	1101                	addi	sp,sp,-32
    80002576:	ec06                	sd	ra,24(sp)
    80002578:	e822                	sd	s0,16(sp)
    8000257a:	e426                	sd	s1,8(sp)
    8000257c:	e04a                	sd	s2,0(sp)
    8000257e:	1000                	addi	s0,sp,32
    80002580:	892a                	mv	s2,a0
  if(!holdingsleep(&b->lock))
    80002582:	01850493          	addi	s1,a0,24
    80002586:	8526                	mv	a0,s1
    80002588:	00001097          	auipc	ra,0x1
    8000258c:	476080e7          	jalr	1142(ra) # 800039fe <holdingsleep>
    80002590:	c135                	beqz	a0,800025f4 <brelse+0x80>
    panic("brelse");

  releasesleep(&b->lock);
    80002592:	8526                	mv	a0,s1
    80002594:	00001097          	auipc	ra,0x1
    80002598:	426080e7          	jalr	1062(ra) # 800039ba <releasesleep>
  return key % NBUCKET;
    8000259c:	01092483          	lw	s1,16(s2)
    800025a0:	47b5                	li	a5,13
    800025a2:	02f4f4bb          	remuw	s1,s1,a5

  uint v = hash_v(b->blockno);
  struct bucket* bucket = &bcache.bucket[v];
  acquire(&bucket->lock);
    800025a6:	1482                	slli	s1,s1,0x20
    800025a8:	9081                	srli	s1,s1,0x20
    800025aa:	48800793          	li	a5,1160
    800025ae:	02f484b3          	mul	s1,s1,a5
    800025b2:	67a1                	lui	a5,0x8
    800025b4:	43078793          	addi	a5,a5,1072 # 8430 <_entry-0x7fff7bd0>
    800025b8:	94be                	add	s1,s1,a5
    800025ba:	0000d797          	auipc	a5,0xd
    800025be:	c1678793          	addi	a5,a5,-1002 # 8000f1d0 <bcache>
    800025c2:	94be                	add	s1,s1,a5
    800025c4:	8526                	mv	a0,s1
    800025c6:	00004097          	auipc	ra,0x4
    800025ca:	ffa080e7          	jalr	-6(ra) # 800065c0 <acquire>

  b->refcnt--;
    800025ce:	05092783          	lw	a5,80(s2)
    800025d2:	37fd                	addiw	a5,a5,-1
    800025d4:	0007871b          	sext.w	a4,a5
    800025d8:	04f92823          	sw	a5,80(s2)
  if (b->refcnt == 0) {
    800025dc:	c705                	beqz	a4,80002604 <brelse+0x90>
    b->next->prev = b->prev;
    b->prev->next = b->next;
    __atomic_clear(&b->used, __ATOMIC_RELEASE);
  }
  
  release(&bucket->lock);
    800025de:	8526                	mv	a0,s1
    800025e0:	00004097          	auipc	ra,0x4
    800025e4:	0b0080e7          	jalr	176(ra) # 80006690 <release>
}
    800025e8:	60e2                	ld	ra,24(sp)
    800025ea:	6442                	ld	s0,16(sp)
    800025ec:	64a2                	ld	s1,8(sp)
    800025ee:	6902                	ld	s2,0(sp)
    800025f0:	6105                	addi	sp,sp,32
    800025f2:	8082                	ret
    panic("brelse");
    800025f4:	00006517          	auipc	a0,0x6
    800025f8:	ec450513          	addi	a0,a0,-316 # 800084b8 <syscalls+0xe8>
    800025fc:	00004097          	auipc	ra,0x4
    80002600:	a90080e7          	jalr	-1392(ra) # 8000608c <panic>
    b->next->prev = b->prev;
    80002604:	06093783          	ld	a5,96(s2)
    80002608:	05893703          	ld	a4,88(s2)
    8000260c:	efb8                	sd	a4,88(a5)
    b->prev->next = b->next;
    8000260e:	05893783          	ld	a5,88(s2)
    80002612:	06093703          	ld	a4,96(s2)
    80002616:	f3b8                	sd	a4,96(a5)
    __atomic_clear(&b->used, __ATOMIC_RELEASE);
    80002618:	0ff0000f          	fence
    8000261c:	00090023          	sb	zero,0(s2)
    80002620:	bf7d                	j	800025de <brelse+0x6a>

0000000080002622 <bpin>:

void
bpin(struct buf *b) {
    80002622:	1101                	addi	sp,sp,-32
    80002624:	ec06                	sd	ra,24(sp)
    80002626:	e822                	sd	s0,16(sp)
    80002628:	e426                	sd	s1,8(sp)
    8000262a:	e04a                	sd	s2,0(sp)
    8000262c:	1000                	addi	s0,sp,32
    8000262e:	892a                	mv	s2,a0
  return key % NBUCKET;
    80002630:	4904                	lw	s1,16(a0)
    80002632:	47b5                	li	a5,13
    80002634:	02f4f4bb          	remuw	s1,s1,a5
  uint v = hash_v(b->blockno);
  struct bucket* bucket = &bcache.bucket[v];
  acquire(&bucket->lock);
    80002638:	1482                	slli	s1,s1,0x20
    8000263a:	9081                	srli	s1,s1,0x20
    8000263c:	48800793          	li	a5,1160
    80002640:	02f484b3          	mul	s1,s1,a5
    80002644:	67a1                	lui	a5,0x8
    80002646:	43078793          	addi	a5,a5,1072 # 8430 <_entry-0x7fff7bd0>
    8000264a:	94be                	add	s1,s1,a5
    8000264c:	0000d797          	auipc	a5,0xd
    80002650:	b8478793          	addi	a5,a5,-1148 # 8000f1d0 <bcache>
    80002654:	94be                	add	s1,s1,a5
    80002656:	8526                	mv	a0,s1
    80002658:	00004097          	auipc	ra,0x4
    8000265c:	f68080e7          	jalr	-152(ra) # 800065c0 <acquire>
  b->refcnt++;
    80002660:	05092783          	lw	a5,80(s2)
    80002664:	2785                	addiw	a5,a5,1
    80002666:	04f92823          	sw	a5,80(s2)
  release(&bucket->lock);
    8000266a:	8526                	mv	a0,s1
    8000266c:	00004097          	auipc	ra,0x4
    80002670:	024080e7          	jalr	36(ra) # 80006690 <release>
}
    80002674:	60e2                	ld	ra,24(sp)
    80002676:	6442                	ld	s0,16(sp)
    80002678:	64a2                	ld	s1,8(sp)
    8000267a:	6902                	ld	s2,0(sp)
    8000267c:	6105                	addi	sp,sp,32
    8000267e:	8082                	ret

0000000080002680 <bunpin>:

void
bunpin(struct buf *b) {
    80002680:	1101                	addi	sp,sp,-32
    80002682:	ec06                	sd	ra,24(sp)
    80002684:	e822                	sd	s0,16(sp)
    80002686:	e426                	sd	s1,8(sp)
    80002688:	e04a                	sd	s2,0(sp)
    8000268a:	1000                	addi	s0,sp,32
    8000268c:	892a                	mv	s2,a0
  return key % NBUCKET;
    8000268e:	4904                	lw	s1,16(a0)
    80002690:	47b5                	li	a5,13
    80002692:	02f4f4bb          	remuw	s1,s1,a5
  uint v = hash_v(b->blockno);
  struct bucket* bucket = &bcache.bucket[v];
  acquire(&bucket->lock);
    80002696:	1482                	slli	s1,s1,0x20
    80002698:	9081                	srli	s1,s1,0x20
    8000269a:	48800793          	li	a5,1160
    8000269e:	02f484b3          	mul	s1,s1,a5
    800026a2:	67a1                	lui	a5,0x8
    800026a4:	43078793          	addi	a5,a5,1072 # 8430 <_entry-0x7fff7bd0>
    800026a8:	94be                	add	s1,s1,a5
    800026aa:	0000d797          	auipc	a5,0xd
    800026ae:	b2678793          	addi	a5,a5,-1242 # 8000f1d0 <bcache>
    800026b2:	94be                	add	s1,s1,a5
    800026b4:	8526                	mv	a0,s1
    800026b6:	00004097          	auipc	ra,0x4
    800026ba:	f0a080e7          	jalr	-246(ra) # 800065c0 <acquire>
  b->refcnt--;
    800026be:	05092783          	lw	a5,80(s2)
    800026c2:	37fd                	addiw	a5,a5,-1
    800026c4:	04f92823          	sw	a5,80(s2)
  release(&bucket->lock);
    800026c8:	8526                	mv	a0,s1
    800026ca:	00004097          	auipc	ra,0x4
    800026ce:	fc6080e7          	jalr	-58(ra) # 80006690 <release>
}
    800026d2:	60e2                	ld	ra,24(sp)
    800026d4:	6442                	ld	s0,16(sp)
    800026d6:	64a2                	ld	s1,8(sp)
    800026d8:	6902                	ld	s2,0(sp)
    800026da:	6105                	addi	sp,sp,32
    800026dc:	8082                	ret

00000000800026de <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800026de:	1101                	addi	sp,sp,-32
    800026e0:	ec06                	sd	ra,24(sp)
    800026e2:	e822                	sd	s0,16(sp)
    800026e4:	e426                	sd	s1,8(sp)
    800026e6:	e04a                	sd	s2,0(sp)
    800026e8:	1000                	addi	s0,sp,32
    800026ea:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800026ec:	00d5d59b          	srliw	a1,a1,0xd
    800026f0:	00019797          	auipc	a5,0x19
    800026f4:	a147a783          	lw	a5,-1516(a5) # 8001b104 <sb+0x1c>
    800026f8:	9dbd                	addw	a1,a1,a5
    800026fa:	00000097          	auipc	ra,0x0
    800026fe:	cbc080e7          	jalr	-836(ra) # 800023b6 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002702:	0074f713          	andi	a4,s1,7
    80002706:	4785                	li	a5,1
    80002708:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000270c:	14ce                	slli	s1,s1,0x33
    8000270e:	90d9                	srli	s1,s1,0x36
    80002710:	00950733          	add	a4,a0,s1
    80002714:	06874703          	lbu	a4,104(a4)
    80002718:	00e7f6b3          	and	a3,a5,a4
    8000271c:	c69d                	beqz	a3,8000274a <bfree+0x6c>
    8000271e:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002720:	94aa                	add	s1,s1,a0
    80002722:	fff7c793          	not	a5,a5
    80002726:	8ff9                	and	a5,a5,a4
    80002728:	06f48423          	sb	a5,104(s1)
  log_write(bp);
    8000272c:	00001097          	auipc	ra,0x1
    80002730:	118080e7          	jalr	280(ra) # 80003844 <log_write>
  brelse(bp);
    80002734:	854a                	mv	a0,s2
    80002736:	00000097          	auipc	ra,0x0
    8000273a:	e3e080e7          	jalr	-450(ra) # 80002574 <brelse>
}
    8000273e:	60e2                	ld	ra,24(sp)
    80002740:	6442                	ld	s0,16(sp)
    80002742:	64a2                	ld	s1,8(sp)
    80002744:	6902                	ld	s2,0(sp)
    80002746:	6105                	addi	sp,sp,32
    80002748:	8082                	ret
    panic("freeing free block");
    8000274a:	00006517          	auipc	a0,0x6
    8000274e:	d7650513          	addi	a0,a0,-650 # 800084c0 <syscalls+0xf0>
    80002752:	00004097          	auipc	ra,0x4
    80002756:	93a080e7          	jalr	-1734(ra) # 8000608c <panic>

000000008000275a <balloc>:
{
    8000275a:	711d                	addi	sp,sp,-96
    8000275c:	ec86                	sd	ra,88(sp)
    8000275e:	e8a2                	sd	s0,80(sp)
    80002760:	e4a6                	sd	s1,72(sp)
    80002762:	e0ca                	sd	s2,64(sp)
    80002764:	fc4e                	sd	s3,56(sp)
    80002766:	f852                	sd	s4,48(sp)
    80002768:	f456                	sd	s5,40(sp)
    8000276a:	f05a                	sd	s6,32(sp)
    8000276c:	ec5e                	sd	s7,24(sp)
    8000276e:	e862                	sd	s8,16(sp)
    80002770:	e466                	sd	s9,8(sp)
    80002772:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002774:	00019797          	auipc	a5,0x19
    80002778:	9787a783          	lw	a5,-1672(a5) # 8001b0ec <sb+0x4>
    8000277c:	cbd1                	beqz	a5,80002810 <balloc+0xb6>
    8000277e:	8baa                	mv	s7,a0
    80002780:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002782:	00019b17          	auipc	s6,0x19
    80002786:	966b0b13          	addi	s6,s6,-1690 # 8001b0e8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000278a:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000278c:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000278e:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002790:	6c89                	lui	s9,0x2
    80002792:	a831                	j	800027ae <balloc+0x54>
    brelse(bp);
    80002794:	854a                	mv	a0,s2
    80002796:	00000097          	auipc	ra,0x0
    8000279a:	dde080e7          	jalr	-546(ra) # 80002574 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000279e:	015c87bb          	addw	a5,s9,s5
    800027a2:	00078a9b          	sext.w	s5,a5
    800027a6:	004b2703          	lw	a4,4(s6)
    800027aa:	06eaf363          	bgeu	s5,a4,80002810 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    800027ae:	41fad79b          	sraiw	a5,s5,0x1f
    800027b2:	0137d79b          	srliw	a5,a5,0x13
    800027b6:	015787bb          	addw	a5,a5,s5
    800027ba:	40d7d79b          	sraiw	a5,a5,0xd
    800027be:	01cb2583          	lw	a1,28(s6)
    800027c2:	9dbd                	addw	a1,a1,a5
    800027c4:	855e                	mv	a0,s7
    800027c6:	00000097          	auipc	ra,0x0
    800027ca:	bf0080e7          	jalr	-1040(ra) # 800023b6 <bread>
    800027ce:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800027d0:	004b2503          	lw	a0,4(s6)
    800027d4:	000a849b          	sext.w	s1,s5
    800027d8:	8662                	mv	a2,s8
    800027da:	faa4fde3          	bgeu	s1,a0,80002794 <balloc+0x3a>
      m = 1 << (bi % 8);
    800027de:	41f6579b          	sraiw	a5,a2,0x1f
    800027e2:	01d7d69b          	srliw	a3,a5,0x1d
    800027e6:	00c6873b          	addw	a4,a3,a2
    800027ea:	00777793          	andi	a5,a4,7
    800027ee:	9f95                	subw	a5,a5,a3
    800027f0:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800027f4:	4037571b          	sraiw	a4,a4,0x3
    800027f8:	00e906b3          	add	a3,s2,a4
    800027fc:	0686c683          	lbu	a3,104(a3)
    80002800:	00d7f5b3          	and	a1,a5,a3
    80002804:	cd91                	beqz	a1,80002820 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002806:	2605                	addiw	a2,a2,1
    80002808:	2485                	addiw	s1,s1,1
    8000280a:	fd4618e3          	bne	a2,s4,800027da <balloc+0x80>
    8000280e:	b759                	j	80002794 <balloc+0x3a>
  panic("balloc: out of blocks");
    80002810:	00006517          	auipc	a0,0x6
    80002814:	cc850513          	addi	a0,a0,-824 # 800084d8 <syscalls+0x108>
    80002818:	00004097          	auipc	ra,0x4
    8000281c:	874080e7          	jalr	-1932(ra) # 8000608c <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002820:	974a                	add	a4,a4,s2
    80002822:	8fd5                	or	a5,a5,a3
    80002824:	06f70423          	sb	a5,104(a4)
        log_write(bp);
    80002828:	854a                	mv	a0,s2
    8000282a:	00001097          	auipc	ra,0x1
    8000282e:	01a080e7          	jalr	26(ra) # 80003844 <log_write>
        brelse(bp);
    80002832:	854a                	mv	a0,s2
    80002834:	00000097          	auipc	ra,0x0
    80002838:	d40080e7          	jalr	-704(ra) # 80002574 <brelse>
  bp = bread(dev, bno);
    8000283c:	85a6                	mv	a1,s1
    8000283e:	855e                	mv	a0,s7
    80002840:	00000097          	auipc	ra,0x0
    80002844:	b76080e7          	jalr	-1162(ra) # 800023b6 <bread>
    80002848:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000284a:	40000613          	li	a2,1024
    8000284e:	4581                	li	a1,0
    80002850:	06850513          	addi	a0,a0,104
    80002854:	ffffe097          	auipc	ra,0xffffe
    80002858:	a70080e7          	jalr	-1424(ra) # 800002c4 <memset>
  log_write(bp);
    8000285c:	854a                	mv	a0,s2
    8000285e:	00001097          	auipc	ra,0x1
    80002862:	fe6080e7          	jalr	-26(ra) # 80003844 <log_write>
  brelse(bp);
    80002866:	854a                	mv	a0,s2
    80002868:	00000097          	auipc	ra,0x0
    8000286c:	d0c080e7          	jalr	-756(ra) # 80002574 <brelse>
}
    80002870:	8526                	mv	a0,s1
    80002872:	60e6                	ld	ra,88(sp)
    80002874:	6446                	ld	s0,80(sp)
    80002876:	64a6                	ld	s1,72(sp)
    80002878:	6906                	ld	s2,64(sp)
    8000287a:	79e2                	ld	s3,56(sp)
    8000287c:	7a42                	ld	s4,48(sp)
    8000287e:	7aa2                	ld	s5,40(sp)
    80002880:	7b02                	ld	s6,32(sp)
    80002882:	6be2                	ld	s7,24(sp)
    80002884:	6c42                	ld	s8,16(sp)
    80002886:	6ca2                	ld	s9,8(sp)
    80002888:	6125                	addi	sp,sp,96
    8000288a:	8082                	ret

000000008000288c <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    8000288c:	7179                	addi	sp,sp,-48
    8000288e:	f406                	sd	ra,40(sp)
    80002890:	f022                	sd	s0,32(sp)
    80002892:	ec26                	sd	s1,24(sp)
    80002894:	e84a                	sd	s2,16(sp)
    80002896:	e44e                	sd	s3,8(sp)
    80002898:	e052                	sd	s4,0(sp)
    8000289a:	1800                	addi	s0,sp,48
    8000289c:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000289e:	47ad                	li	a5,11
    800028a0:	04b7fe63          	bgeu	a5,a1,800028fc <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800028a4:	ff45849b          	addiw	s1,a1,-12
    800028a8:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800028ac:	0ff00793          	li	a5,255
    800028b0:	0ae7e363          	bltu	a5,a4,80002956 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    800028b4:	08852583          	lw	a1,136(a0)
    800028b8:	c5ad                	beqz	a1,80002922 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    800028ba:	00092503          	lw	a0,0(s2)
    800028be:	00000097          	auipc	ra,0x0
    800028c2:	af8080e7          	jalr	-1288(ra) # 800023b6 <bread>
    800028c6:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800028c8:	06850793          	addi	a5,a0,104
    if((addr = a[bn]) == 0){
    800028cc:	02049593          	slli	a1,s1,0x20
    800028d0:	9181                	srli	a1,a1,0x20
    800028d2:	058a                	slli	a1,a1,0x2
    800028d4:	00b784b3          	add	s1,a5,a1
    800028d8:	0004a983          	lw	s3,0(s1)
    800028dc:	04098d63          	beqz	s3,80002936 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800028e0:	8552                	mv	a0,s4
    800028e2:	00000097          	auipc	ra,0x0
    800028e6:	c92080e7          	jalr	-878(ra) # 80002574 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800028ea:	854e                	mv	a0,s3
    800028ec:	70a2                	ld	ra,40(sp)
    800028ee:	7402                	ld	s0,32(sp)
    800028f0:	64e2                	ld	s1,24(sp)
    800028f2:	6942                	ld	s2,16(sp)
    800028f4:	69a2                	ld	s3,8(sp)
    800028f6:	6a02                	ld	s4,0(sp)
    800028f8:	6145                	addi	sp,sp,48
    800028fa:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800028fc:	02059493          	slli	s1,a1,0x20
    80002900:	9081                	srli	s1,s1,0x20
    80002902:	048a                	slli	s1,s1,0x2
    80002904:	94aa                	add	s1,s1,a0
    80002906:	0584a983          	lw	s3,88(s1)
    8000290a:	fe0990e3          	bnez	s3,800028ea <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    8000290e:	4108                	lw	a0,0(a0)
    80002910:	00000097          	auipc	ra,0x0
    80002914:	e4a080e7          	jalr	-438(ra) # 8000275a <balloc>
    80002918:	0005099b          	sext.w	s3,a0
    8000291c:	0534ac23          	sw	s3,88(s1)
    80002920:	b7e9                	j	800028ea <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80002922:	4108                	lw	a0,0(a0)
    80002924:	00000097          	auipc	ra,0x0
    80002928:	e36080e7          	jalr	-458(ra) # 8000275a <balloc>
    8000292c:	0005059b          	sext.w	a1,a0
    80002930:	08b92423          	sw	a1,136(s2)
    80002934:	b759                	j	800028ba <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80002936:	00092503          	lw	a0,0(s2)
    8000293a:	00000097          	auipc	ra,0x0
    8000293e:	e20080e7          	jalr	-480(ra) # 8000275a <balloc>
    80002942:	0005099b          	sext.w	s3,a0
    80002946:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    8000294a:	8552                	mv	a0,s4
    8000294c:	00001097          	auipc	ra,0x1
    80002950:	ef8080e7          	jalr	-264(ra) # 80003844 <log_write>
    80002954:	b771                	j	800028e0 <bmap+0x54>
  panic("bmap: out of range");
    80002956:	00006517          	auipc	a0,0x6
    8000295a:	b9a50513          	addi	a0,a0,-1126 # 800084f0 <syscalls+0x120>
    8000295e:	00003097          	auipc	ra,0x3
    80002962:	72e080e7          	jalr	1838(ra) # 8000608c <panic>

0000000080002966 <iget>:
{
    80002966:	7179                	addi	sp,sp,-48
    80002968:	f406                	sd	ra,40(sp)
    8000296a:	f022                	sd	s0,32(sp)
    8000296c:	ec26                	sd	s1,24(sp)
    8000296e:	e84a                	sd	s2,16(sp)
    80002970:	e44e                	sd	s3,8(sp)
    80002972:	e052                	sd	s4,0(sp)
    80002974:	1800                	addi	s0,sp,48
    80002976:	89aa                	mv	s3,a0
    80002978:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000297a:	00018517          	auipc	a0,0x18
    8000297e:	78e50513          	addi	a0,a0,1934 # 8001b108 <itable>
    80002982:	00004097          	auipc	ra,0x4
    80002986:	c3e080e7          	jalr	-962(ra) # 800065c0 <acquire>
  empty = 0;
    8000298a:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000298c:	00018497          	auipc	s1,0x18
    80002990:	79c48493          	addi	s1,s1,1948 # 8001b128 <itable+0x20>
    80002994:	0001a697          	auipc	a3,0x1a
    80002998:	3b468693          	addi	a3,a3,948 # 8001cd48 <log>
    8000299c:	a039                	j	800029aa <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000299e:	02090b63          	beqz	s2,800029d4 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800029a2:	09048493          	addi	s1,s1,144
    800029a6:	02d48a63          	beq	s1,a3,800029da <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800029aa:	449c                	lw	a5,8(s1)
    800029ac:	fef059e3          	blez	a5,8000299e <iget+0x38>
    800029b0:	4098                	lw	a4,0(s1)
    800029b2:	ff3716e3          	bne	a4,s3,8000299e <iget+0x38>
    800029b6:	40d8                	lw	a4,4(s1)
    800029b8:	ff4713e3          	bne	a4,s4,8000299e <iget+0x38>
      ip->ref++;
    800029bc:	2785                	addiw	a5,a5,1
    800029be:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800029c0:	00018517          	auipc	a0,0x18
    800029c4:	74850513          	addi	a0,a0,1864 # 8001b108 <itable>
    800029c8:	00004097          	auipc	ra,0x4
    800029cc:	cc8080e7          	jalr	-824(ra) # 80006690 <release>
      return ip;
    800029d0:	8926                	mv	s2,s1
    800029d2:	a03d                	j	80002a00 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800029d4:	f7f9                	bnez	a5,800029a2 <iget+0x3c>
    800029d6:	8926                	mv	s2,s1
    800029d8:	b7e9                	j	800029a2 <iget+0x3c>
  if(empty == 0)
    800029da:	02090c63          	beqz	s2,80002a12 <iget+0xac>
  ip->dev = dev;
    800029de:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800029e2:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800029e6:	4785                	li	a5,1
    800029e8:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800029ec:	04092423          	sw	zero,72(s2)
  release(&itable.lock);
    800029f0:	00018517          	auipc	a0,0x18
    800029f4:	71850513          	addi	a0,a0,1816 # 8001b108 <itable>
    800029f8:	00004097          	auipc	ra,0x4
    800029fc:	c98080e7          	jalr	-872(ra) # 80006690 <release>
}
    80002a00:	854a                	mv	a0,s2
    80002a02:	70a2                	ld	ra,40(sp)
    80002a04:	7402                	ld	s0,32(sp)
    80002a06:	64e2                	ld	s1,24(sp)
    80002a08:	6942                	ld	s2,16(sp)
    80002a0a:	69a2                	ld	s3,8(sp)
    80002a0c:	6a02                	ld	s4,0(sp)
    80002a0e:	6145                	addi	sp,sp,48
    80002a10:	8082                	ret
    panic("iget: no inodes");
    80002a12:	00006517          	auipc	a0,0x6
    80002a16:	af650513          	addi	a0,a0,-1290 # 80008508 <syscalls+0x138>
    80002a1a:	00003097          	auipc	ra,0x3
    80002a1e:	672080e7          	jalr	1650(ra) # 8000608c <panic>

0000000080002a22 <fsinit>:
fsinit(int dev) {
    80002a22:	7179                	addi	sp,sp,-48
    80002a24:	f406                	sd	ra,40(sp)
    80002a26:	f022                	sd	s0,32(sp)
    80002a28:	ec26                	sd	s1,24(sp)
    80002a2a:	e84a                	sd	s2,16(sp)
    80002a2c:	e44e                	sd	s3,8(sp)
    80002a2e:	1800                	addi	s0,sp,48
    80002a30:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80002a32:	4585                	li	a1,1
    80002a34:	00000097          	auipc	ra,0x0
    80002a38:	982080e7          	jalr	-1662(ra) # 800023b6 <bread>
    80002a3c:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80002a3e:	00018997          	auipc	s3,0x18
    80002a42:	6aa98993          	addi	s3,s3,1706 # 8001b0e8 <sb>
    80002a46:	02000613          	li	a2,32
    80002a4a:	06850593          	addi	a1,a0,104
    80002a4e:	854e                	mv	a0,s3
    80002a50:	ffffe097          	auipc	ra,0xffffe
    80002a54:	8d4080e7          	jalr	-1836(ra) # 80000324 <memmove>
  brelse(bp);
    80002a58:	8526                	mv	a0,s1
    80002a5a:	00000097          	auipc	ra,0x0
    80002a5e:	b1a080e7          	jalr	-1254(ra) # 80002574 <brelse>
  if(sb.magic != FSMAGIC)
    80002a62:	0009a703          	lw	a4,0(s3)
    80002a66:	102037b7          	lui	a5,0x10203
    80002a6a:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80002a6e:	02f71263          	bne	a4,a5,80002a92 <fsinit+0x70>
  initlog(dev, &sb);
    80002a72:	00018597          	auipc	a1,0x18
    80002a76:	67658593          	addi	a1,a1,1654 # 8001b0e8 <sb>
    80002a7a:	854a                	mv	a0,s2
    80002a7c:	00001097          	auipc	ra,0x1
    80002a80:	b4c080e7          	jalr	-1204(ra) # 800035c8 <initlog>
}
    80002a84:	70a2                	ld	ra,40(sp)
    80002a86:	7402                	ld	s0,32(sp)
    80002a88:	64e2                	ld	s1,24(sp)
    80002a8a:	6942                	ld	s2,16(sp)
    80002a8c:	69a2                	ld	s3,8(sp)
    80002a8e:	6145                	addi	sp,sp,48
    80002a90:	8082                	ret
    panic("invalid file system");
    80002a92:	00006517          	auipc	a0,0x6
    80002a96:	a8650513          	addi	a0,a0,-1402 # 80008518 <syscalls+0x148>
    80002a9a:	00003097          	auipc	ra,0x3
    80002a9e:	5f2080e7          	jalr	1522(ra) # 8000608c <panic>

0000000080002aa2 <iinit>:
{
    80002aa2:	7179                	addi	sp,sp,-48
    80002aa4:	f406                	sd	ra,40(sp)
    80002aa6:	f022                	sd	s0,32(sp)
    80002aa8:	ec26                	sd	s1,24(sp)
    80002aaa:	e84a                	sd	s2,16(sp)
    80002aac:	e44e                	sd	s3,8(sp)
    80002aae:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80002ab0:	00006597          	auipc	a1,0x6
    80002ab4:	a8058593          	addi	a1,a1,-1408 # 80008530 <syscalls+0x160>
    80002ab8:	00018517          	auipc	a0,0x18
    80002abc:	65050513          	addi	a0,a0,1616 # 8001b108 <itable>
    80002ac0:	00004097          	auipc	ra,0x4
    80002ac4:	c7c080e7          	jalr	-900(ra) # 8000673c <initlock>
  for(i = 0; i < NINODE; i++) {
    80002ac8:	00018497          	auipc	s1,0x18
    80002acc:	67048493          	addi	s1,s1,1648 # 8001b138 <itable+0x30>
    80002ad0:	0001a997          	auipc	s3,0x1a
    80002ad4:	28898993          	addi	s3,s3,648 # 8001cd58 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80002ad8:	00006917          	auipc	s2,0x6
    80002adc:	a6090913          	addi	s2,s2,-1440 # 80008538 <syscalls+0x168>
    80002ae0:	85ca                	mv	a1,s2
    80002ae2:	8526                	mv	a0,s1
    80002ae4:	00001097          	auipc	ra,0x1
    80002ae8:	e46080e7          	jalr	-442(ra) # 8000392a <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80002aec:	09048493          	addi	s1,s1,144
    80002af0:	ff3498e3          	bne	s1,s3,80002ae0 <iinit+0x3e>
}
    80002af4:	70a2                	ld	ra,40(sp)
    80002af6:	7402                	ld	s0,32(sp)
    80002af8:	64e2                	ld	s1,24(sp)
    80002afa:	6942                	ld	s2,16(sp)
    80002afc:	69a2                	ld	s3,8(sp)
    80002afe:	6145                	addi	sp,sp,48
    80002b00:	8082                	ret

0000000080002b02 <ialloc>:
{
    80002b02:	715d                	addi	sp,sp,-80
    80002b04:	e486                	sd	ra,72(sp)
    80002b06:	e0a2                	sd	s0,64(sp)
    80002b08:	fc26                	sd	s1,56(sp)
    80002b0a:	f84a                	sd	s2,48(sp)
    80002b0c:	f44e                	sd	s3,40(sp)
    80002b0e:	f052                	sd	s4,32(sp)
    80002b10:	ec56                	sd	s5,24(sp)
    80002b12:	e85a                	sd	s6,16(sp)
    80002b14:	e45e                	sd	s7,8(sp)
    80002b16:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80002b18:	00018717          	auipc	a4,0x18
    80002b1c:	5dc72703          	lw	a4,1500(a4) # 8001b0f4 <sb+0xc>
    80002b20:	4785                	li	a5,1
    80002b22:	04e7fa63          	bgeu	a5,a4,80002b76 <ialloc+0x74>
    80002b26:	8aaa                	mv	s5,a0
    80002b28:	8bae                	mv	s7,a1
    80002b2a:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80002b2c:	00018a17          	auipc	s4,0x18
    80002b30:	5bca0a13          	addi	s4,s4,1468 # 8001b0e8 <sb>
    80002b34:	00048b1b          	sext.w	s6,s1
    80002b38:	0044d593          	srli	a1,s1,0x4
    80002b3c:	018a2783          	lw	a5,24(s4)
    80002b40:	9dbd                	addw	a1,a1,a5
    80002b42:	8556                	mv	a0,s5
    80002b44:	00000097          	auipc	ra,0x0
    80002b48:	872080e7          	jalr	-1934(ra) # 800023b6 <bread>
    80002b4c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80002b4e:	06850993          	addi	s3,a0,104
    80002b52:	00f4f793          	andi	a5,s1,15
    80002b56:	079a                	slli	a5,a5,0x6
    80002b58:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80002b5a:	00099783          	lh	a5,0(s3)
    80002b5e:	c785                	beqz	a5,80002b86 <ialloc+0x84>
    brelse(bp);
    80002b60:	00000097          	auipc	ra,0x0
    80002b64:	a14080e7          	jalr	-1516(ra) # 80002574 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80002b68:	0485                	addi	s1,s1,1
    80002b6a:	00ca2703          	lw	a4,12(s4)
    80002b6e:	0004879b          	sext.w	a5,s1
    80002b72:	fce7e1e3          	bltu	a5,a4,80002b34 <ialloc+0x32>
  panic("ialloc: no inodes");
    80002b76:	00006517          	auipc	a0,0x6
    80002b7a:	9ca50513          	addi	a0,a0,-1590 # 80008540 <syscalls+0x170>
    80002b7e:	00003097          	auipc	ra,0x3
    80002b82:	50e080e7          	jalr	1294(ra) # 8000608c <panic>
      memset(dip, 0, sizeof(*dip));
    80002b86:	04000613          	li	a2,64
    80002b8a:	4581                	li	a1,0
    80002b8c:	854e                	mv	a0,s3
    80002b8e:	ffffd097          	auipc	ra,0xffffd
    80002b92:	736080e7          	jalr	1846(ra) # 800002c4 <memset>
      dip->type = type;
    80002b96:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80002b9a:	854a                	mv	a0,s2
    80002b9c:	00001097          	auipc	ra,0x1
    80002ba0:	ca8080e7          	jalr	-856(ra) # 80003844 <log_write>
      brelse(bp);
    80002ba4:	854a                	mv	a0,s2
    80002ba6:	00000097          	auipc	ra,0x0
    80002baa:	9ce080e7          	jalr	-1586(ra) # 80002574 <brelse>
      return iget(dev, inum);
    80002bae:	85da                	mv	a1,s6
    80002bb0:	8556                	mv	a0,s5
    80002bb2:	00000097          	auipc	ra,0x0
    80002bb6:	db4080e7          	jalr	-588(ra) # 80002966 <iget>
}
    80002bba:	60a6                	ld	ra,72(sp)
    80002bbc:	6406                	ld	s0,64(sp)
    80002bbe:	74e2                	ld	s1,56(sp)
    80002bc0:	7942                	ld	s2,48(sp)
    80002bc2:	79a2                	ld	s3,40(sp)
    80002bc4:	7a02                	ld	s4,32(sp)
    80002bc6:	6ae2                	ld	s5,24(sp)
    80002bc8:	6b42                	ld	s6,16(sp)
    80002bca:	6ba2                	ld	s7,8(sp)
    80002bcc:	6161                	addi	sp,sp,80
    80002bce:	8082                	ret

0000000080002bd0 <iupdate>:
{
    80002bd0:	1101                	addi	sp,sp,-32
    80002bd2:	ec06                	sd	ra,24(sp)
    80002bd4:	e822                	sd	s0,16(sp)
    80002bd6:	e426                	sd	s1,8(sp)
    80002bd8:	e04a                	sd	s2,0(sp)
    80002bda:	1000                	addi	s0,sp,32
    80002bdc:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002bde:	415c                	lw	a5,4(a0)
    80002be0:	0047d79b          	srliw	a5,a5,0x4
    80002be4:	00018597          	auipc	a1,0x18
    80002be8:	51c5a583          	lw	a1,1308(a1) # 8001b100 <sb+0x18>
    80002bec:	9dbd                	addw	a1,a1,a5
    80002bee:	4108                	lw	a0,0(a0)
    80002bf0:	fffff097          	auipc	ra,0xfffff
    80002bf4:	7c6080e7          	jalr	1990(ra) # 800023b6 <bread>
    80002bf8:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80002bfa:	06850793          	addi	a5,a0,104
    80002bfe:	40c8                	lw	a0,4(s1)
    80002c00:	893d                	andi	a0,a0,15
    80002c02:	051a                	slli	a0,a0,0x6
    80002c04:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80002c06:	04c49703          	lh	a4,76(s1)
    80002c0a:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80002c0e:	04e49703          	lh	a4,78(s1)
    80002c12:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80002c16:	05049703          	lh	a4,80(s1)
    80002c1a:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80002c1e:	05249703          	lh	a4,82(s1)
    80002c22:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80002c26:	48f8                	lw	a4,84(s1)
    80002c28:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80002c2a:	03400613          	li	a2,52
    80002c2e:	05848593          	addi	a1,s1,88
    80002c32:	0531                	addi	a0,a0,12
    80002c34:	ffffd097          	auipc	ra,0xffffd
    80002c38:	6f0080e7          	jalr	1776(ra) # 80000324 <memmove>
  log_write(bp);
    80002c3c:	854a                	mv	a0,s2
    80002c3e:	00001097          	auipc	ra,0x1
    80002c42:	c06080e7          	jalr	-1018(ra) # 80003844 <log_write>
  brelse(bp);
    80002c46:	854a                	mv	a0,s2
    80002c48:	00000097          	auipc	ra,0x0
    80002c4c:	92c080e7          	jalr	-1748(ra) # 80002574 <brelse>
}
    80002c50:	60e2                	ld	ra,24(sp)
    80002c52:	6442                	ld	s0,16(sp)
    80002c54:	64a2                	ld	s1,8(sp)
    80002c56:	6902                	ld	s2,0(sp)
    80002c58:	6105                	addi	sp,sp,32
    80002c5a:	8082                	ret

0000000080002c5c <idup>:
{
    80002c5c:	1101                	addi	sp,sp,-32
    80002c5e:	ec06                	sd	ra,24(sp)
    80002c60:	e822                	sd	s0,16(sp)
    80002c62:	e426                	sd	s1,8(sp)
    80002c64:	1000                	addi	s0,sp,32
    80002c66:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002c68:	00018517          	auipc	a0,0x18
    80002c6c:	4a050513          	addi	a0,a0,1184 # 8001b108 <itable>
    80002c70:	00004097          	auipc	ra,0x4
    80002c74:	950080e7          	jalr	-1712(ra) # 800065c0 <acquire>
  ip->ref++;
    80002c78:	449c                	lw	a5,8(s1)
    80002c7a:	2785                	addiw	a5,a5,1
    80002c7c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002c7e:	00018517          	auipc	a0,0x18
    80002c82:	48a50513          	addi	a0,a0,1162 # 8001b108 <itable>
    80002c86:	00004097          	auipc	ra,0x4
    80002c8a:	a0a080e7          	jalr	-1526(ra) # 80006690 <release>
}
    80002c8e:	8526                	mv	a0,s1
    80002c90:	60e2                	ld	ra,24(sp)
    80002c92:	6442                	ld	s0,16(sp)
    80002c94:	64a2                	ld	s1,8(sp)
    80002c96:	6105                	addi	sp,sp,32
    80002c98:	8082                	ret

0000000080002c9a <ilock>:
{
    80002c9a:	1101                	addi	sp,sp,-32
    80002c9c:	ec06                	sd	ra,24(sp)
    80002c9e:	e822                	sd	s0,16(sp)
    80002ca0:	e426                	sd	s1,8(sp)
    80002ca2:	e04a                	sd	s2,0(sp)
    80002ca4:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80002ca6:	c115                	beqz	a0,80002cca <ilock+0x30>
    80002ca8:	84aa                	mv	s1,a0
    80002caa:	451c                	lw	a5,8(a0)
    80002cac:	00f05f63          	blez	a5,80002cca <ilock+0x30>
  acquiresleep(&ip->lock);
    80002cb0:	0541                	addi	a0,a0,16
    80002cb2:	00001097          	auipc	ra,0x1
    80002cb6:	cb2080e7          	jalr	-846(ra) # 80003964 <acquiresleep>
  if(ip->valid == 0){
    80002cba:	44bc                	lw	a5,72(s1)
    80002cbc:	cf99                	beqz	a5,80002cda <ilock+0x40>
}
    80002cbe:	60e2                	ld	ra,24(sp)
    80002cc0:	6442                	ld	s0,16(sp)
    80002cc2:	64a2                	ld	s1,8(sp)
    80002cc4:	6902                	ld	s2,0(sp)
    80002cc6:	6105                	addi	sp,sp,32
    80002cc8:	8082                	ret
    panic("ilock");
    80002cca:	00006517          	auipc	a0,0x6
    80002cce:	88e50513          	addi	a0,a0,-1906 # 80008558 <syscalls+0x188>
    80002cd2:	00003097          	auipc	ra,0x3
    80002cd6:	3ba080e7          	jalr	954(ra) # 8000608c <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002cda:	40dc                	lw	a5,4(s1)
    80002cdc:	0047d79b          	srliw	a5,a5,0x4
    80002ce0:	00018597          	auipc	a1,0x18
    80002ce4:	4205a583          	lw	a1,1056(a1) # 8001b100 <sb+0x18>
    80002ce8:	9dbd                	addw	a1,a1,a5
    80002cea:	4088                	lw	a0,0(s1)
    80002cec:	fffff097          	auipc	ra,0xfffff
    80002cf0:	6ca080e7          	jalr	1738(ra) # 800023b6 <bread>
    80002cf4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80002cf6:	06850593          	addi	a1,a0,104
    80002cfa:	40dc                	lw	a5,4(s1)
    80002cfc:	8bbd                	andi	a5,a5,15
    80002cfe:	079a                	slli	a5,a5,0x6
    80002d00:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80002d02:	00059783          	lh	a5,0(a1)
    80002d06:	04f49623          	sh	a5,76(s1)
    ip->major = dip->major;
    80002d0a:	00259783          	lh	a5,2(a1)
    80002d0e:	04f49723          	sh	a5,78(s1)
    ip->minor = dip->minor;
    80002d12:	00459783          	lh	a5,4(a1)
    80002d16:	04f49823          	sh	a5,80(s1)
    ip->nlink = dip->nlink;
    80002d1a:	00659783          	lh	a5,6(a1)
    80002d1e:	04f49923          	sh	a5,82(s1)
    ip->size = dip->size;
    80002d22:	459c                	lw	a5,8(a1)
    80002d24:	c8fc                	sw	a5,84(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80002d26:	03400613          	li	a2,52
    80002d2a:	05b1                	addi	a1,a1,12
    80002d2c:	05848513          	addi	a0,s1,88
    80002d30:	ffffd097          	auipc	ra,0xffffd
    80002d34:	5f4080e7          	jalr	1524(ra) # 80000324 <memmove>
    brelse(bp);
    80002d38:	854a                	mv	a0,s2
    80002d3a:	00000097          	auipc	ra,0x0
    80002d3e:	83a080e7          	jalr	-1990(ra) # 80002574 <brelse>
    ip->valid = 1;
    80002d42:	4785                	li	a5,1
    80002d44:	c4bc                	sw	a5,72(s1)
    if(ip->type == 0)
    80002d46:	04c49783          	lh	a5,76(s1)
    80002d4a:	fbb5                	bnez	a5,80002cbe <ilock+0x24>
      panic("ilock: no type");
    80002d4c:	00006517          	auipc	a0,0x6
    80002d50:	81450513          	addi	a0,a0,-2028 # 80008560 <syscalls+0x190>
    80002d54:	00003097          	auipc	ra,0x3
    80002d58:	338080e7          	jalr	824(ra) # 8000608c <panic>

0000000080002d5c <iunlock>:
{
    80002d5c:	1101                	addi	sp,sp,-32
    80002d5e:	ec06                	sd	ra,24(sp)
    80002d60:	e822                	sd	s0,16(sp)
    80002d62:	e426                	sd	s1,8(sp)
    80002d64:	e04a                	sd	s2,0(sp)
    80002d66:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80002d68:	c905                	beqz	a0,80002d98 <iunlock+0x3c>
    80002d6a:	84aa                	mv	s1,a0
    80002d6c:	01050913          	addi	s2,a0,16
    80002d70:	854a                	mv	a0,s2
    80002d72:	00001097          	auipc	ra,0x1
    80002d76:	c8c080e7          	jalr	-884(ra) # 800039fe <holdingsleep>
    80002d7a:	cd19                	beqz	a0,80002d98 <iunlock+0x3c>
    80002d7c:	449c                	lw	a5,8(s1)
    80002d7e:	00f05d63          	blez	a5,80002d98 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80002d82:	854a                	mv	a0,s2
    80002d84:	00001097          	auipc	ra,0x1
    80002d88:	c36080e7          	jalr	-970(ra) # 800039ba <releasesleep>
}
    80002d8c:	60e2                	ld	ra,24(sp)
    80002d8e:	6442                	ld	s0,16(sp)
    80002d90:	64a2                	ld	s1,8(sp)
    80002d92:	6902                	ld	s2,0(sp)
    80002d94:	6105                	addi	sp,sp,32
    80002d96:	8082                	ret
    panic("iunlock");
    80002d98:	00005517          	auipc	a0,0x5
    80002d9c:	7d850513          	addi	a0,a0,2008 # 80008570 <syscalls+0x1a0>
    80002da0:	00003097          	auipc	ra,0x3
    80002da4:	2ec080e7          	jalr	748(ra) # 8000608c <panic>

0000000080002da8 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80002da8:	7179                	addi	sp,sp,-48
    80002daa:	f406                	sd	ra,40(sp)
    80002dac:	f022                	sd	s0,32(sp)
    80002dae:	ec26                	sd	s1,24(sp)
    80002db0:	e84a                	sd	s2,16(sp)
    80002db2:	e44e                	sd	s3,8(sp)
    80002db4:	e052                	sd	s4,0(sp)
    80002db6:	1800                	addi	s0,sp,48
    80002db8:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80002dba:	05850493          	addi	s1,a0,88
    80002dbe:	08850913          	addi	s2,a0,136
    80002dc2:	a021                	j	80002dca <itrunc+0x22>
    80002dc4:	0491                	addi	s1,s1,4
    80002dc6:	01248d63          	beq	s1,s2,80002de0 <itrunc+0x38>
    if(ip->addrs[i]){
    80002dca:	408c                	lw	a1,0(s1)
    80002dcc:	dde5                	beqz	a1,80002dc4 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80002dce:	0009a503          	lw	a0,0(s3)
    80002dd2:	00000097          	auipc	ra,0x0
    80002dd6:	90c080e7          	jalr	-1780(ra) # 800026de <bfree>
      ip->addrs[i] = 0;
    80002dda:	0004a023          	sw	zero,0(s1)
    80002dde:	b7dd                	j	80002dc4 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80002de0:	0889a583          	lw	a1,136(s3)
    80002de4:	e185                	bnez	a1,80002e04 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80002de6:	0409aa23          	sw	zero,84(s3)
  iupdate(ip);
    80002dea:	854e                	mv	a0,s3
    80002dec:	00000097          	auipc	ra,0x0
    80002df0:	de4080e7          	jalr	-540(ra) # 80002bd0 <iupdate>
}
    80002df4:	70a2                	ld	ra,40(sp)
    80002df6:	7402                	ld	s0,32(sp)
    80002df8:	64e2                	ld	s1,24(sp)
    80002dfa:	6942                	ld	s2,16(sp)
    80002dfc:	69a2                	ld	s3,8(sp)
    80002dfe:	6a02                	ld	s4,0(sp)
    80002e00:	6145                	addi	sp,sp,48
    80002e02:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80002e04:	0009a503          	lw	a0,0(s3)
    80002e08:	fffff097          	auipc	ra,0xfffff
    80002e0c:	5ae080e7          	jalr	1454(ra) # 800023b6 <bread>
    80002e10:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80002e12:	06850493          	addi	s1,a0,104
    80002e16:	46850913          	addi	s2,a0,1128
    80002e1a:	a811                	j	80002e2e <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80002e1c:	0009a503          	lw	a0,0(s3)
    80002e20:	00000097          	auipc	ra,0x0
    80002e24:	8be080e7          	jalr	-1858(ra) # 800026de <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80002e28:	0491                	addi	s1,s1,4
    80002e2a:	01248563          	beq	s1,s2,80002e34 <itrunc+0x8c>
      if(a[j])
    80002e2e:	408c                	lw	a1,0(s1)
    80002e30:	dde5                	beqz	a1,80002e28 <itrunc+0x80>
    80002e32:	b7ed                	j	80002e1c <itrunc+0x74>
    brelse(bp);
    80002e34:	8552                	mv	a0,s4
    80002e36:	fffff097          	auipc	ra,0xfffff
    80002e3a:	73e080e7          	jalr	1854(ra) # 80002574 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80002e3e:	0889a583          	lw	a1,136(s3)
    80002e42:	0009a503          	lw	a0,0(s3)
    80002e46:	00000097          	auipc	ra,0x0
    80002e4a:	898080e7          	jalr	-1896(ra) # 800026de <bfree>
    ip->addrs[NDIRECT] = 0;
    80002e4e:	0809a423          	sw	zero,136(s3)
    80002e52:	bf51                	j	80002de6 <itrunc+0x3e>

0000000080002e54 <iput>:
{
    80002e54:	1101                	addi	sp,sp,-32
    80002e56:	ec06                	sd	ra,24(sp)
    80002e58:	e822                	sd	s0,16(sp)
    80002e5a:	e426                	sd	s1,8(sp)
    80002e5c:	e04a                	sd	s2,0(sp)
    80002e5e:	1000                	addi	s0,sp,32
    80002e60:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002e62:	00018517          	auipc	a0,0x18
    80002e66:	2a650513          	addi	a0,a0,678 # 8001b108 <itable>
    80002e6a:	00003097          	auipc	ra,0x3
    80002e6e:	756080e7          	jalr	1878(ra) # 800065c0 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002e72:	4498                	lw	a4,8(s1)
    80002e74:	4785                	li	a5,1
    80002e76:	02f70363          	beq	a4,a5,80002e9c <iput+0x48>
  ip->ref--;
    80002e7a:	449c                	lw	a5,8(s1)
    80002e7c:	37fd                	addiw	a5,a5,-1
    80002e7e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002e80:	00018517          	auipc	a0,0x18
    80002e84:	28850513          	addi	a0,a0,648 # 8001b108 <itable>
    80002e88:	00004097          	auipc	ra,0x4
    80002e8c:	808080e7          	jalr	-2040(ra) # 80006690 <release>
}
    80002e90:	60e2                	ld	ra,24(sp)
    80002e92:	6442                	ld	s0,16(sp)
    80002e94:	64a2                	ld	s1,8(sp)
    80002e96:	6902                	ld	s2,0(sp)
    80002e98:	6105                	addi	sp,sp,32
    80002e9a:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002e9c:	44bc                	lw	a5,72(s1)
    80002e9e:	dff1                	beqz	a5,80002e7a <iput+0x26>
    80002ea0:	05249783          	lh	a5,82(s1)
    80002ea4:	fbf9                	bnez	a5,80002e7a <iput+0x26>
    acquiresleep(&ip->lock);
    80002ea6:	01048913          	addi	s2,s1,16
    80002eaa:	854a                	mv	a0,s2
    80002eac:	00001097          	auipc	ra,0x1
    80002eb0:	ab8080e7          	jalr	-1352(ra) # 80003964 <acquiresleep>
    release(&itable.lock);
    80002eb4:	00018517          	auipc	a0,0x18
    80002eb8:	25450513          	addi	a0,a0,596 # 8001b108 <itable>
    80002ebc:	00003097          	auipc	ra,0x3
    80002ec0:	7d4080e7          	jalr	2004(ra) # 80006690 <release>
    itrunc(ip);
    80002ec4:	8526                	mv	a0,s1
    80002ec6:	00000097          	auipc	ra,0x0
    80002eca:	ee2080e7          	jalr	-286(ra) # 80002da8 <itrunc>
    ip->type = 0;
    80002ece:	04049623          	sh	zero,76(s1)
    iupdate(ip);
    80002ed2:	8526                	mv	a0,s1
    80002ed4:	00000097          	auipc	ra,0x0
    80002ed8:	cfc080e7          	jalr	-772(ra) # 80002bd0 <iupdate>
    ip->valid = 0;
    80002edc:	0404a423          	sw	zero,72(s1)
    releasesleep(&ip->lock);
    80002ee0:	854a                	mv	a0,s2
    80002ee2:	00001097          	auipc	ra,0x1
    80002ee6:	ad8080e7          	jalr	-1320(ra) # 800039ba <releasesleep>
    acquire(&itable.lock);
    80002eea:	00018517          	auipc	a0,0x18
    80002eee:	21e50513          	addi	a0,a0,542 # 8001b108 <itable>
    80002ef2:	00003097          	auipc	ra,0x3
    80002ef6:	6ce080e7          	jalr	1742(ra) # 800065c0 <acquire>
    80002efa:	b741                	j	80002e7a <iput+0x26>

0000000080002efc <iunlockput>:
{
    80002efc:	1101                	addi	sp,sp,-32
    80002efe:	ec06                	sd	ra,24(sp)
    80002f00:	e822                	sd	s0,16(sp)
    80002f02:	e426                	sd	s1,8(sp)
    80002f04:	1000                	addi	s0,sp,32
    80002f06:	84aa                	mv	s1,a0
  iunlock(ip);
    80002f08:	00000097          	auipc	ra,0x0
    80002f0c:	e54080e7          	jalr	-428(ra) # 80002d5c <iunlock>
  iput(ip);
    80002f10:	8526                	mv	a0,s1
    80002f12:	00000097          	auipc	ra,0x0
    80002f16:	f42080e7          	jalr	-190(ra) # 80002e54 <iput>
}
    80002f1a:	60e2                	ld	ra,24(sp)
    80002f1c:	6442                	ld	s0,16(sp)
    80002f1e:	64a2                	ld	s1,8(sp)
    80002f20:	6105                	addi	sp,sp,32
    80002f22:	8082                	ret

0000000080002f24 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80002f24:	1141                	addi	sp,sp,-16
    80002f26:	e422                	sd	s0,8(sp)
    80002f28:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80002f2a:	411c                	lw	a5,0(a0)
    80002f2c:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80002f2e:	415c                	lw	a5,4(a0)
    80002f30:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80002f32:	04c51783          	lh	a5,76(a0)
    80002f36:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80002f3a:	05251783          	lh	a5,82(a0)
    80002f3e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80002f42:	05456783          	lwu	a5,84(a0)
    80002f46:	e99c                	sd	a5,16(a1)
}
    80002f48:	6422                	ld	s0,8(sp)
    80002f4a:	0141                	addi	sp,sp,16
    80002f4c:	8082                	ret

0000000080002f4e <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002f4e:	497c                	lw	a5,84(a0)
    80002f50:	0ed7e963          	bltu	a5,a3,80003042 <readi+0xf4>
{
    80002f54:	7159                	addi	sp,sp,-112
    80002f56:	f486                	sd	ra,104(sp)
    80002f58:	f0a2                	sd	s0,96(sp)
    80002f5a:	eca6                	sd	s1,88(sp)
    80002f5c:	e8ca                	sd	s2,80(sp)
    80002f5e:	e4ce                	sd	s3,72(sp)
    80002f60:	e0d2                	sd	s4,64(sp)
    80002f62:	fc56                	sd	s5,56(sp)
    80002f64:	f85a                	sd	s6,48(sp)
    80002f66:	f45e                	sd	s7,40(sp)
    80002f68:	f062                	sd	s8,32(sp)
    80002f6a:	ec66                	sd	s9,24(sp)
    80002f6c:	e86a                	sd	s10,16(sp)
    80002f6e:	e46e                	sd	s11,8(sp)
    80002f70:	1880                	addi	s0,sp,112
    80002f72:	8baa                	mv	s7,a0
    80002f74:	8c2e                	mv	s8,a1
    80002f76:	8ab2                	mv	s5,a2
    80002f78:	84b6                	mv	s1,a3
    80002f7a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80002f7c:	9f35                	addw	a4,a4,a3
    return 0;
    80002f7e:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80002f80:	0ad76063          	bltu	a4,a3,80003020 <readi+0xd2>
  if(off + n > ip->size)
    80002f84:	00e7f463          	bgeu	a5,a4,80002f8c <readi+0x3e>
    n = ip->size - off;
    80002f88:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002f8c:	0a0b0963          	beqz	s6,8000303e <readi+0xf0>
    80002f90:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80002f92:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80002f96:	5cfd                	li	s9,-1
    80002f98:	a82d                	j	80002fd2 <readi+0x84>
    80002f9a:	020a1d93          	slli	s11,s4,0x20
    80002f9e:	020ddd93          	srli	s11,s11,0x20
    80002fa2:	06890613          	addi	a2,s2,104
    80002fa6:	86ee                	mv	a3,s11
    80002fa8:	963a                	add	a2,a2,a4
    80002faa:	85d6                	mv	a1,s5
    80002fac:	8562                	mv	a0,s8
    80002fae:	fffff097          	auipc	ra,0xfffff
    80002fb2:	a56080e7          	jalr	-1450(ra) # 80001a04 <either_copyout>
    80002fb6:	05950d63          	beq	a0,s9,80003010 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80002fba:	854a                	mv	a0,s2
    80002fbc:	fffff097          	auipc	ra,0xfffff
    80002fc0:	5b8080e7          	jalr	1464(ra) # 80002574 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002fc4:	013a09bb          	addw	s3,s4,s3
    80002fc8:	009a04bb          	addw	s1,s4,s1
    80002fcc:	9aee                	add	s5,s5,s11
    80002fce:	0569f763          	bgeu	s3,s6,8000301c <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80002fd2:	000ba903          	lw	s2,0(s7)
    80002fd6:	00a4d59b          	srliw	a1,s1,0xa
    80002fda:	855e                	mv	a0,s7
    80002fdc:	00000097          	auipc	ra,0x0
    80002fe0:	8b0080e7          	jalr	-1872(ra) # 8000288c <bmap>
    80002fe4:	0005059b          	sext.w	a1,a0
    80002fe8:	854a                	mv	a0,s2
    80002fea:	fffff097          	auipc	ra,0xfffff
    80002fee:	3cc080e7          	jalr	972(ra) # 800023b6 <bread>
    80002ff2:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002ff4:	3ff4f713          	andi	a4,s1,1023
    80002ff8:	40ed07bb          	subw	a5,s10,a4
    80002ffc:	413b06bb          	subw	a3,s6,s3
    80003000:	8a3e                	mv	s4,a5
    80003002:	2781                	sext.w	a5,a5
    80003004:	0006861b          	sext.w	a2,a3
    80003008:	f8f679e3          	bgeu	a2,a5,80002f9a <readi+0x4c>
    8000300c:	8a36                	mv	s4,a3
    8000300e:	b771                	j	80002f9a <readi+0x4c>
      brelse(bp);
    80003010:	854a                	mv	a0,s2
    80003012:	fffff097          	auipc	ra,0xfffff
    80003016:	562080e7          	jalr	1378(ra) # 80002574 <brelse>
      tot = -1;
    8000301a:	59fd                	li	s3,-1
  }
  return tot;
    8000301c:	0009851b          	sext.w	a0,s3
}
    80003020:	70a6                	ld	ra,104(sp)
    80003022:	7406                	ld	s0,96(sp)
    80003024:	64e6                	ld	s1,88(sp)
    80003026:	6946                	ld	s2,80(sp)
    80003028:	69a6                	ld	s3,72(sp)
    8000302a:	6a06                	ld	s4,64(sp)
    8000302c:	7ae2                	ld	s5,56(sp)
    8000302e:	7b42                	ld	s6,48(sp)
    80003030:	7ba2                	ld	s7,40(sp)
    80003032:	7c02                	ld	s8,32(sp)
    80003034:	6ce2                	ld	s9,24(sp)
    80003036:	6d42                	ld	s10,16(sp)
    80003038:	6da2                	ld	s11,8(sp)
    8000303a:	6165                	addi	sp,sp,112
    8000303c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000303e:	89da                	mv	s3,s6
    80003040:	bff1                	j	8000301c <readi+0xce>
    return 0;
    80003042:	4501                	li	a0,0
}
    80003044:	8082                	ret

0000000080003046 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003046:	497c                	lw	a5,84(a0)
    80003048:	10d7e863          	bltu	a5,a3,80003158 <writei+0x112>
{
    8000304c:	7159                	addi	sp,sp,-112
    8000304e:	f486                	sd	ra,104(sp)
    80003050:	f0a2                	sd	s0,96(sp)
    80003052:	eca6                	sd	s1,88(sp)
    80003054:	e8ca                	sd	s2,80(sp)
    80003056:	e4ce                	sd	s3,72(sp)
    80003058:	e0d2                	sd	s4,64(sp)
    8000305a:	fc56                	sd	s5,56(sp)
    8000305c:	f85a                	sd	s6,48(sp)
    8000305e:	f45e                	sd	s7,40(sp)
    80003060:	f062                	sd	s8,32(sp)
    80003062:	ec66                	sd	s9,24(sp)
    80003064:	e86a                	sd	s10,16(sp)
    80003066:	e46e                	sd	s11,8(sp)
    80003068:	1880                	addi	s0,sp,112
    8000306a:	8b2a                	mv	s6,a0
    8000306c:	8c2e                	mv	s8,a1
    8000306e:	8ab2                	mv	s5,a2
    80003070:	8936                	mv	s2,a3
    80003072:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80003074:	00e687bb          	addw	a5,a3,a4
    80003078:	0ed7e263          	bltu	a5,a3,8000315c <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    8000307c:	00043737          	lui	a4,0x43
    80003080:	0ef76063          	bltu	a4,a5,80003160 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003084:	0c0b8863          	beqz	s7,80003154 <writei+0x10e>
    80003088:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    8000308a:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000308e:	5cfd                	li	s9,-1
    80003090:	a091                	j	800030d4 <writei+0x8e>
    80003092:	02099d93          	slli	s11,s3,0x20
    80003096:	020ddd93          	srli	s11,s11,0x20
    8000309a:	06848513          	addi	a0,s1,104
    8000309e:	86ee                	mv	a3,s11
    800030a0:	8656                	mv	a2,s5
    800030a2:	85e2                	mv	a1,s8
    800030a4:	953a                	add	a0,a0,a4
    800030a6:	fffff097          	auipc	ra,0xfffff
    800030aa:	9b4080e7          	jalr	-1612(ra) # 80001a5a <either_copyin>
    800030ae:	07950263          	beq	a0,s9,80003112 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    800030b2:	8526                	mv	a0,s1
    800030b4:	00000097          	auipc	ra,0x0
    800030b8:	790080e7          	jalr	1936(ra) # 80003844 <log_write>
    brelse(bp);
    800030bc:	8526                	mv	a0,s1
    800030be:	fffff097          	auipc	ra,0xfffff
    800030c2:	4b6080e7          	jalr	1206(ra) # 80002574 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800030c6:	01498a3b          	addw	s4,s3,s4
    800030ca:	0129893b          	addw	s2,s3,s2
    800030ce:	9aee                	add	s5,s5,s11
    800030d0:	057a7663          	bgeu	s4,s7,8000311c <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    800030d4:	000b2483          	lw	s1,0(s6)
    800030d8:	00a9559b          	srliw	a1,s2,0xa
    800030dc:	855a                	mv	a0,s6
    800030de:	fffff097          	auipc	ra,0xfffff
    800030e2:	7ae080e7          	jalr	1966(ra) # 8000288c <bmap>
    800030e6:	0005059b          	sext.w	a1,a0
    800030ea:	8526                	mv	a0,s1
    800030ec:	fffff097          	auipc	ra,0xfffff
    800030f0:	2ca080e7          	jalr	714(ra) # 800023b6 <bread>
    800030f4:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800030f6:	3ff97713          	andi	a4,s2,1023
    800030fa:	40ed07bb          	subw	a5,s10,a4
    800030fe:	414b86bb          	subw	a3,s7,s4
    80003102:	89be                	mv	s3,a5
    80003104:	2781                	sext.w	a5,a5
    80003106:	0006861b          	sext.w	a2,a3
    8000310a:	f8f674e3          	bgeu	a2,a5,80003092 <writei+0x4c>
    8000310e:	89b6                	mv	s3,a3
    80003110:	b749                	j	80003092 <writei+0x4c>
      brelse(bp);
    80003112:	8526                	mv	a0,s1
    80003114:	fffff097          	auipc	ra,0xfffff
    80003118:	460080e7          	jalr	1120(ra) # 80002574 <brelse>
  }

  if(off > ip->size)
    8000311c:	054b2783          	lw	a5,84(s6)
    80003120:	0127f463          	bgeu	a5,s2,80003128 <writei+0xe2>
    ip->size = off;
    80003124:	052b2a23          	sw	s2,84(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003128:	855a                	mv	a0,s6
    8000312a:	00000097          	auipc	ra,0x0
    8000312e:	aa6080e7          	jalr	-1370(ra) # 80002bd0 <iupdate>

  return tot;
    80003132:	000a051b          	sext.w	a0,s4
}
    80003136:	70a6                	ld	ra,104(sp)
    80003138:	7406                	ld	s0,96(sp)
    8000313a:	64e6                	ld	s1,88(sp)
    8000313c:	6946                	ld	s2,80(sp)
    8000313e:	69a6                	ld	s3,72(sp)
    80003140:	6a06                	ld	s4,64(sp)
    80003142:	7ae2                	ld	s5,56(sp)
    80003144:	7b42                	ld	s6,48(sp)
    80003146:	7ba2                	ld	s7,40(sp)
    80003148:	7c02                	ld	s8,32(sp)
    8000314a:	6ce2                	ld	s9,24(sp)
    8000314c:	6d42                	ld	s10,16(sp)
    8000314e:	6da2                	ld	s11,8(sp)
    80003150:	6165                	addi	sp,sp,112
    80003152:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003154:	8a5e                	mv	s4,s7
    80003156:	bfc9                	j	80003128 <writei+0xe2>
    return -1;
    80003158:	557d                	li	a0,-1
}
    8000315a:	8082                	ret
    return -1;
    8000315c:	557d                	li	a0,-1
    8000315e:	bfe1                	j	80003136 <writei+0xf0>
    return -1;
    80003160:	557d                	li	a0,-1
    80003162:	bfd1                	j	80003136 <writei+0xf0>

0000000080003164 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003164:	1141                	addi	sp,sp,-16
    80003166:	e406                	sd	ra,8(sp)
    80003168:	e022                	sd	s0,0(sp)
    8000316a:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000316c:	4639                	li	a2,14
    8000316e:	ffffd097          	auipc	ra,0xffffd
    80003172:	22e080e7          	jalr	558(ra) # 8000039c <strncmp>
}
    80003176:	60a2                	ld	ra,8(sp)
    80003178:	6402                	ld	s0,0(sp)
    8000317a:	0141                	addi	sp,sp,16
    8000317c:	8082                	ret

000000008000317e <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000317e:	7139                	addi	sp,sp,-64
    80003180:	fc06                	sd	ra,56(sp)
    80003182:	f822                	sd	s0,48(sp)
    80003184:	f426                	sd	s1,40(sp)
    80003186:	f04a                	sd	s2,32(sp)
    80003188:	ec4e                	sd	s3,24(sp)
    8000318a:	e852                	sd	s4,16(sp)
    8000318c:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000318e:	04c51703          	lh	a4,76(a0)
    80003192:	4785                	li	a5,1
    80003194:	00f71a63          	bne	a4,a5,800031a8 <dirlookup+0x2a>
    80003198:	892a                	mv	s2,a0
    8000319a:	89ae                	mv	s3,a1
    8000319c:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000319e:	497c                	lw	a5,84(a0)
    800031a0:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800031a2:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800031a4:	e79d                	bnez	a5,800031d2 <dirlookup+0x54>
    800031a6:	a8a5                	j	8000321e <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800031a8:	00005517          	auipc	a0,0x5
    800031ac:	3d050513          	addi	a0,a0,976 # 80008578 <syscalls+0x1a8>
    800031b0:	00003097          	auipc	ra,0x3
    800031b4:	edc080e7          	jalr	-292(ra) # 8000608c <panic>
      panic("dirlookup read");
    800031b8:	00005517          	auipc	a0,0x5
    800031bc:	3d850513          	addi	a0,a0,984 # 80008590 <syscalls+0x1c0>
    800031c0:	00003097          	auipc	ra,0x3
    800031c4:	ecc080e7          	jalr	-308(ra) # 8000608c <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800031c8:	24c1                	addiw	s1,s1,16
    800031ca:	05492783          	lw	a5,84(s2)
    800031ce:	04f4f763          	bgeu	s1,a5,8000321c <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800031d2:	4741                	li	a4,16
    800031d4:	86a6                	mv	a3,s1
    800031d6:	fc040613          	addi	a2,s0,-64
    800031da:	4581                	li	a1,0
    800031dc:	854a                	mv	a0,s2
    800031de:	00000097          	auipc	ra,0x0
    800031e2:	d70080e7          	jalr	-656(ra) # 80002f4e <readi>
    800031e6:	47c1                	li	a5,16
    800031e8:	fcf518e3          	bne	a0,a5,800031b8 <dirlookup+0x3a>
    if(de.inum == 0)
    800031ec:	fc045783          	lhu	a5,-64(s0)
    800031f0:	dfe1                	beqz	a5,800031c8 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    800031f2:	fc240593          	addi	a1,s0,-62
    800031f6:	854e                	mv	a0,s3
    800031f8:	00000097          	auipc	ra,0x0
    800031fc:	f6c080e7          	jalr	-148(ra) # 80003164 <namecmp>
    80003200:	f561                	bnez	a0,800031c8 <dirlookup+0x4a>
      if(poff)
    80003202:	000a0463          	beqz	s4,8000320a <dirlookup+0x8c>
        *poff = off;
    80003206:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000320a:	fc045583          	lhu	a1,-64(s0)
    8000320e:	00092503          	lw	a0,0(s2)
    80003212:	fffff097          	auipc	ra,0xfffff
    80003216:	754080e7          	jalr	1876(ra) # 80002966 <iget>
    8000321a:	a011                	j	8000321e <dirlookup+0xa0>
  return 0;
    8000321c:	4501                	li	a0,0
}
    8000321e:	70e2                	ld	ra,56(sp)
    80003220:	7442                	ld	s0,48(sp)
    80003222:	74a2                	ld	s1,40(sp)
    80003224:	7902                	ld	s2,32(sp)
    80003226:	69e2                	ld	s3,24(sp)
    80003228:	6a42                	ld	s4,16(sp)
    8000322a:	6121                	addi	sp,sp,64
    8000322c:	8082                	ret

000000008000322e <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000322e:	711d                	addi	sp,sp,-96
    80003230:	ec86                	sd	ra,88(sp)
    80003232:	e8a2                	sd	s0,80(sp)
    80003234:	e4a6                	sd	s1,72(sp)
    80003236:	e0ca                	sd	s2,64(sp)
    80003238:	fc4e                	sd	s3,56(sp)
    8000323a:	f852                	sd	s4,48(sp)
    8000323c:	f456                	sd	s5,40(sp)
    8000323e:	f05a                	sd	s6,32(sp)
    80003240:	ec5e                	sd	s7,24(sp)
    80003242:	e862                	sd	s8,16(sp)
    80003244:	e466                	sd	s9,8(sp)
    80003246:	1080                	addi	s0,sp,96
    80003248:	84aa                	mv	s1,a0
    8000324a:	8b2e                	mv	s6,a1
    8000324c:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000324e:	00054703          	lbu	a4,0(a0)
    80003252:	02f00793          	li	a5,47
    80003256:	02f70363          	beq	a4,a5,8000327c <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000325a:	ffffe097          	auipc	ra,0xffffe
    8000325e:	d4a080e7          	jalr	-694(ra) # 80000fa4 <myproc>
    80003262:	15853503          	ld	a0,344(a0)
    80003266:	00000097          	auipc	ra,0x0
    8000326a:	9f6080e7          	jalr	-1546(ra) # 80002c5c <idup>
    8000326e:	89aa                	mv	s3,a0
  while(*path == '/')
    80003270:	02f00913          	li	s2,47
  len = path - s;
    80003274:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80003276:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003278:	4c05                	li	s8,1
    8000327a:	a865                	j	80003332 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    8000327c:	4585                	li	a1,1
    8000327e:	4505                	li	a0,1
    80003280:	fffff097          	auipc	ra,0xfffff
    80003284:	6e6080e7          	jalr	1766(ra) # 80002966 <iget>
    80003288:	89aa                	mv	s3,a0
    8000328a:	b7dd                	j	80003270 <namex+0x42>
      iunlockput(ip);
    8000328c:	854e                	mv	a0,s3
    8000328e:	00000097          	auipc	ra,0x0
    80003292:	c6e080e7          	jalr	-914(ra) # 80002efc <iunlockput>
      return 0;
    80003296:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003298:	854e                	mv	a0,s3
    8000329a:	60e6                	ld	ra,88(sp)
    8000329c:	6446                	ld	s0,80(sp)
    8000329e:	64a6                	ld	s1,72(sp)
    800032a0:	6906                	ld	s2,64(sp)
    800032a2:	79e2                	ld	s3,56(sp)
    800032a4:	7a42                	ld	s4,48(sp)
    800032a6:	7aa2                	ld	s5,40(sp)
    800032a8:	7b02                	ld	s6,32(sp)
    800032aa:	6be2                	ld	s7,24(sp)
    800032ac:	6c42                	ld	s8,16(sp)
    800032ae:	6ca2                	ld	s9,8(sp)
    800032b0:	6125                	addi	sp,sp,96
    800032b2:	8082                	ret
      iunlock(ip);
    800032b4:	854e                	mv	a0,s3
    800032b6:	00000097          	auipc	ra,0x0
    800032ba:	aa6080e7          	jalr	-1370(ra) # 80002d5c <iunlock>
      return ip;
    800032be:	bfe9                	j	80003298 <namex+0x6a>
      iunlockput(ip);
    800032c0:	854e                	mv	a0,s3
    800032c2:	00000097          	auipc	ra,0x0
    800032c6:	c3a080e7          	jalr	-966(ra) # 80002efc <iunlockput>
      return 0;
    800032ca:	89d2                	mv	s3,s4
    800032cc:	b7f1                	j	80003298 <namex+0x6a>
  len = path - s;
    800032ce:	40b48633          	sub	a2,s1,a1
    800032d2:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    800032d6:	094cd463          	bge	s9,s4,8000335e <namex+0x130>
    memmove(name, s, DIRSIZ);
    800032da:	4639                	li	a2,14
    800032dc:	8556                	mv	a0,s5
    800032de:	ffffd097          	auipc	ra,0xffffd
    800032e2:	046080e7          	jalr	70(ra) # 80000324 <memmove>
  while(*path == '/')
    800032e6:	0004c783          	lbu	a5,0(s1)
    800032ea:	01279763          	bne	a5,s2,800032f8 <namex+0xca>
    path++;
    800032ee:	0485                	addi	s1,s1,1
  while(*path == '/')
    800032f0:	0004c783          	lbu	a5,0(s1)
    800032f4:	ff278de3          	beq	a5,s2,800032ee <namex+0xc0>
    ilock(ip);
    800032f8:	854e                	mv	a0,s3
    800032fa:	00000097          	auipc	ra,0x0
    800032fe:	9a0080e7          	jalr	-1632(ra) # 80002c9a <ilock>
    if(ip->type != T_DIR){
    80003302:	04c99783          	lh	a5,76(s3)
    80003306:	f98793e3          	bne	a5,s8,8000328c <namex+0x5e>
    if(nameiparent && *path == '\0'){
    8000330a:	000b0563          	beqz	s6,80003314 <namex+0xe6>
    8000330e:	0004c783          	lbu	a5,0(s1)
    80003312:	d3cd                	beqz	a5,800032b4 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003314:	865e                	mv	a2,s7
    80003316:	85d6                	mv	a1,s5
    80003318:	854e                	mv	a0,s3
    8000331a:	00000097          	auipc	ra,0x0
    8000331e:	e64080e7          	jalr	-412(ra) # 8000317e <dirlookup>
    80003322:	8a2a                	mv	s4,a0
    80003324:	dd51                	beqz	a0,800032c0 <namex+0x92>
    iunlockput(ip);
    80003326:	854e                	mv	a0,s3
    80003328:	00000097          	auipc	ra,0x0
    8000332c:	bd4080e7          	jalr	-1068(ra) # 80002efc <iunlockput>
    ip = next;
    80003330:	89d2                	mv	s3,s4
  while(*path == '/')
    80003332:	0004c783          	lbu	a5,0(s1)
    80003336:	05279763          	bne	a5,s2,80003384 <namex+0x156>
    path++;
    8000333a:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000333c:	0004c783          	lbu	a5,0(s1)
    80003340:	ff278de3          	beq	a5,s2,8000333a <namex+0x10c>
  if(*path == 0)
    80003344:	c79d                	beqz	a5,80003372 <namex+0x144>
    path++;
    80003346:	85a6                	mv	a1,s1
  len = path - s;
    80003348:	8a5e                	mv	s4,s7
    8000334a:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    8000334c:	01278963          	beq	a5,s2,8000335e <namex+0x130>
    80003350:	dfbd                	beqz	a5,800032ce <namex+0xa0>
    path++;
    80003352:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003354:	0004c783          	lbu	a5,0(s1)
    80003358:	ff279ce3          	bne	a5,s2,80003350 <namex+0x122>
    8000335c:	bf8d                	j	800032ce <namex+0xa0>
    memmove(name, s, len);
    8000335e:	2601                	sext.w	a2,a2
    80003360:	8556                	mv	a0,s5
    80003362:	ffffd097          	auipc	ra,0xffffd
    80003366:	fc2080e7          	jalr	-62(ra) # 80000324 <memmove>
    name[len] = 0;
    8000336a:	9a56                	add	s4,s4,s5
    8000336c:	000a0023          	sb	zero,0(s4)
    80003370:	bf9d                	j	800032e6 <namex+0xb8>
  if(nameiparent){
    80003372:	f20b03e3          	beqz	s6,80003298 <namex+0x6a>
    iput(ip);
    80003376:	854e                	mv	a0,s3
    80003378:	00000097          	auipc	ra,0x0
    8000337c:	adc080e7          	jalr	-1316(ra) # 80002e54 <iput>
    return 0;
    80003380:	4981                	li	s3,0
    80003382:	bf19                	j	80003298 <namex+0x6a>
  if(*path == 0)
    80003384:	d7fd                	beqz	a5,80003372 <namex+0x144>
  while(*path != '/' && *path != 0)
    80003386:	0004c783          	lbu	a5,0(s1)
    8000338a:	85a6                	mv	a1,s1
    8000338c:	b7d1                	j	80003350 <namex+0x122>

000000008000338e <dirlink>:
{
    8000338e:	7139                	addi	sp,sp,-64
    80003390:	fc06                	sd	ra,56(sp)
    80003392:	f822                	sd	s0,48(sp)
    80003394:	f426                	sd	s1,40(sp)
    80003396:	f04a                	sd	s2,32(sp)
    80003398:	ec4e                	sd	s3,24(sp)
    8000339a:	e852                	sd	s4,16(sp)
    8000339c:	0080                	addi	s0,sp,64
    8000339e:	892a                	mv	s2,a0
    800033a0:	8a2e                	mv	s4,a1
    800033a2:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800033a4:	4601                	li	a2,0
    800033a6:	00000097          	auipc	ra,0x0
    800033aa:	dd8080e7          	jalr	-552(ra) # 8000317e <dirlookup>
    800033ae:	e93d                	bnez	a0,80003424 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800033b0:	05492483          	lw	s1,84(s2)
    800033b4:	c49d                	beqz	s1,800033e2 <dirlink+0x54>
    800033b6:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800033b8:	4741                	li	a4,16
    800033ba:	86a6                	mv	a3,s1
    800033bc:	fc040613          	addi	a2,s0,-64
    800033c0:	4581                	li	a1,0
    800033c2:	854a                	mv	a0,s2
    800033c4:	00000097          	auipc	ra,0x0
    800033c8:	b8a080e7          	jalr	-1142(ra) # 80002f4e <readi>
    800033cc:	47c1                	li	a5,16
    800033ce:	06f51163          	bne	a0,a5,80003430 <dirlink+0xa2>
    if(de.inum == 0)
    800033d2:	fc045783          	lhu	a5,-64(s0)
    800033d6:	c791                	beqz	a5,800033e2 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800033d8:	24c1                	addiw	s1,s1,16
    800033da:	05492783          	lw	a5,84(s2)
    800033de:	fcf4ede3          	bltu	s1,a5,800033b8 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800033e2:	4639                	li	a2,14
    800033e4:	85d2                	mv	a1,s4
    800033e6:	fc240513          	addi	a0,s0,-62
    800033ea:	ffffd097          	auipc	ra,0xffffd
    800033ee:	fee080e7          	jalr	-18(ra) # 800003d8 <strncpy>
  de.inum = inum;
    800033f2:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800033f6:	4741                	li	a4,16
    800033f8:	86a6                	mv	a3,s1
    800033fa:	fc040613          	addi	a2,s0,-64
    800033fe:	4581                	li	a1,0
    80003400:	854a                	mv	a0,s2
    80003402:	00000097          	auipc	ra,0x0
    80003406:	c44080e7          	jalr	-956(ra) # 80003046 <writei>
    8000340a:	872a                	mv	a4,a0
    8000340c:	47c1                	li	a5,16
  return 0;
    8000340e:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003410:	02f71863          	bne	a4,a5,80003440 <dirlink+0xb2>
}
    80003414:	70e2                	ld	ra,56(sp)
    80003416:	7442                	ld	s0,48(sp)
    80003418:	74a2                	ld	s1,40(sp)
    8000341a:	7902                	ld	s2,32(sp)
    8000341c:	69e2                	ld	s3,24(sp)
    8000341e:	6a42                	ld	s4,16(sp)
    80003420:	6121                	addi	sp,sp,64
    80003422:	8082                	ret
    iput(ip);
    80003424:	00000097          	auipc	ra,0x0
    80003428:	a30080e7          	jalr	-1488(ra) # 80002e54 <iput>
    return -1;
    8000342c:	557d                	li	a0,-1
    8000342e:	b7dd                	j	80003414 <dirlink+0x86>
      panic("dirlink read");
    80003430:	00005517          	auipc	a0,0x5
    80003434:	17050513          	addi	a0,a0,368 # 800085a0 <syscalls+0x1d0>
    80003438:	00003097          	auipc	ra,0x3
    8000343c:	c54080e7          	jalr	-940(ra) # 8000608c <panic>
    panic("dirlink");
    80003440:	00005517          	auipc	a0,0x5
    80003444:	27050513          	addi	a0,a0,624 # 800086b0 <syscalls+0x2e0>
    80003448:	00003097          	auipc	ra,0x3
    8000344c:	c44080e7          	jalr	-956(ra) # 8000608c <panic>

0000000080003450 <namei>:

struct inode*
namei(char *path)
{
    80003450:	1101                	addi	sp,sp,-32
    80003452:	ec06                	sd	ra,24(sp)
    80003454:	e822                	sd	s0,16(sp)
    80003456:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003458:	fe040613          	addi	a2,s0,-32
    8000345c:	4581                	li	a1,0
    8000345e:	00000097          	auipc	ra,0x0
    80003462:	dd0080e7          	jalr	-560(ra) # 8000322e <namex>
}
    80003466:	60e2                	ld	ra,24(sp)
    80003468:	6442                	ld	s0,16(sp)
    8000346a:	6105                	addi	sp,sp,32
    8000346c:	8082                	ret

000000008000346e <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000346e:	1141                	addi	sp,sp,-16
    80003470:	e406                	sd	ra,8(sp)
    80003472:	e022                	sd	s0,0(sp)
    80003474:	0800                	addi	s0,sp,16
    80003476:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003478:	4585                	li	a1,1
    8000347a:	00000097          	auipc	ra,0x0
    8000347e:	db4080e7          	jalr	-588(ra) # 8000322e <namex>
}
    80003482:	60a2                	ld	ra,8(sp)
    80003484:	6402                	ld	s0,0(sp)
    80003486:	0141                	addi	sp,sp,16
    80003488:	8082                	ret

000000008000348a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000348a:	1101                	addi	sp,sp,-32
    8000348c:	ec06                	sd	ra,24(sp)
    8000348e:	e822                	sd	s0,16(sp)
    80003490:	e426                	sd	s1,8(sp)
    80003492:	e04a                	sd	s2,0(sp)
    80003494:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003496:	0001a917          	auipc	s2,0x1a
    8000349a:	8b290913          	addi	s2,s2,-1870 # 8001cd48 <log>
    8000349e:	02092583          	lw	a1,32(s2)
    800034a2:	03092503          	lw	a0,48(s2)
    800034a6:	fffff097          	auipc	ra,0xfffff
    800034aa:	f10080e7          	jalr	-240(ra) # 800023b6 <bread>
    800034ae:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800034b0:	03492683          	lw	a3,52(s2)
    800034b4:	d534                	sw	a3,104(a0)
  for (i = 0; i < log.lh.n; i++) {
    800034b6:	02d05763          	blez	a3,800034e4 <write_head+0x5a>
    800034ba:	0001a797          	auipc	a5,0x1a
    800034be:	8c678793          	addi	a5,a5,-1850 # 8001cd80 <log+0x38>
    800034c2:	06c50713          	addi	a4,a0,108
    800034c6:	36fd                	addiw	a3,a3,-1
    800034c8:	1682                	slli	a3,a3,0x20
    800034ca:	9281                	srli	a3,a3,0x20
    800034cc:	068a                	slli	a3,a3,0x2
    800034ce:	0001a617          	auipc	a2,0x1a
    800034d2:	8b660613          	addi	a2,a2,-1866 # 8001cd84 <log+0x3c>
    800034d6:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800034d8:	4390                	lw	a2,0(a5)
    800034da:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800034dc:	0791                	addi	a5,a5,4
    800034de:	0711                	addi	a4,a4,4
    800034e0:	fed79ce3          	bne	a5,a3,800034d8 <write_head+0x4e>
  }
  bwrite(buf);
    800034e4:	8526                	mv	a0,s1
    800034e6:	fffff097          	auipc	ra,0xfffff
    800034ea:	050080e7          	jalr	80(ra) # 80002536 <bwrite>
  brelse(buf);
    800034ee:	8526                	mv	a0,s1
    800034f0:	fffff097          	auipc	ra,0xfffff
    800034f4:	084080e7          	jalr	132(ra) # 80002574 <brelse>
}
    800034f8:	60e2                	ld	ra,24(sp)
    800034fa:	6442                	ld	s0,16(sp)
    800034fc:	64a2                	ld	s1,8(sp)
    800034fe:	6902                	ld	s2,0(sp)
    80003500:	6105                	addi	sp,sp,32
    80003502:	8082                	ret

0000000080003504 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003504:	0001a797          	auipc	a5,0x1a
    80003508:	8787a783          	lw	a5,-1928(a5) # 8001cd7c <log+0x34>
    8000350c:	0af05d63          	blez	a5,800035c6 <install_trans+0xc2>
{
    80003510:	7139                	addi	sp,sp,-64
    80003512:	fc06                	sd	ra,56(sp)
    80003514:	f822                	sd	s0,48(sp)
    80003516:	f426                	sd	s1,40(sp)
    80003518:	f04a                	sd	s2,32(sp)
    8000351a:	ec4e                	sd	s3,24(sp)
    8000351c:	e852                	sd	s4,16(sp)
    8000351e:	e456                	sd	s5,8(sp)
    80003520:	e05a                	sd	s6,0(sp)
    80003522:	0080                	addi	s0,sp,64
    80003524:	8b2a                	mv	s6,a0
    80003526:	0001aa97          	auipc	s5,0x1a
    8000352a:	85aa8a93          	addi	s5,s5,-1958 # 8001cd80 <log+0x38>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000352e:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003530:	0001a997          	auipc	s3,0x1a
    80003534:	81898993          	addi	s3,s3,-2024 # 8001cd48 <log>
    80003538:	a035                	j	80003564 <install_trans+0x60>
      bunpin(dbuf);
    8000353a:	8526                	mv	a0,s1
    8000353c:	fffff097          	auipc	ra,0xfffff
    80003540:	144080e7          	jalr	324(ra) # 80002680 <bunpin>
    brelse(lbuf);
    80003544:	854a                	mv	a0,s2
    80003546:	fffff097          	auipc	ra,0xfffff
    8000354a:	02e080e7          	jalr	46(ra) # 80002574 <brelse>
    brelse(dbuf);
    8000354e:	8526                	mv	a0,s1
    80003550:	fffff097          	auipc	ra,0xfffff
    80003554:	024080e7          	jalr	36(ra) # 80002574 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003558:	2a05                	addiw	s4,s4,1
    8000355a:	0a91                	addi	s5,s5,4
    8000355c:	0349a783          	lw	a5,52(s3)
    80003560:	04fa5963          	bge	s4,a5,800035b2 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003564:	0209a583          	lw	a1,32(s3)
    80003568:	014585bb          	addw	a1,a1,s4
    8000356c:	2585                	addiw	a1,a1,1
    8000356e:	0309a503          	lw	a0,48(s3)
    80003572:	fffff097          	auipc	ra,0xfffff
    80003576:	e44080e7          	jalr	-444(ra) # 800023b6 <bread>
    8000357a:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000357c:	000aa583          	lw	a1,0(s5)
    80003580:	0309a503          	lw	a0,48(s3)
    80003584:	fffff097          	auipc	ra,0xfffff
    80003588:	e32080e7          	jalr	-462(ra) # 800023b6 <bread>
    8000358c:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000358e:	40000613          	li	a2,1024
    80003592:	06890593          	addi	a1,s2,104
    80003596:	06850513          	addi	a0,a0,104
    8000359a:	ffffd097          	auipc	ra,0xffffd
    8000359e:	d8a080e7          	jalr	-630(ra) # 80000324 <memmove>
    bwrite(dbuf);  // write dst to disk
    800035a2:	8526                	mv	a0,s1
    800035a4:	fffff097          	auipc	ra,0xfffff
    800035a8:	f92080e7          	jalr	-110(ra) # 80002536 <bwrite>
    if(recovering == 0)
    800035ac:	f80b1ce3          	bnez	s6,80003544 <install_trans+0x40>
    800035b0:	b769                	j	8000353a <install_trans+0x36>
}
    800035b2:	70e2                	ld	ra,56(sp)
    800035b4:	7442                	ld	s0,48(sp)
    800035b6:	74a2                	ld	s1,40(sp)
    800035b8:	7902                	ld	s2,32(sp)
    800035ba:	69e2                	ld	s3,24(sp)
    800035bc:	6a42                	ld	s4,16(sp)
    800035be:	6aa2                	ld	s5,8(sp)
    800035c0:	6b02                	ld	s6,0(sp)
    800035c2:	6121                	addi	sp,sp,64
    800035c4:	8082                	ret
    800035c6:	8082                	ret

00000000800035c8 <initlog>:
{
    800035c8:	7179                	addi	sp,sp,-48
    800035ca:	f406                	sd	ra,40(sp)
    800035cc:	f022                	sd	s0,32(sp)
    800035ce:	ec26                	sd	s1,24(sp)
    800035d0:	e84a                	sd	s2,16(sp)
    800035d2:	e44e                	sd	s3,8(sp)
    800035d4:	1800                	addi	s0,sp,48
    800035d6:	892a                	mv	s2,a0
    800035d8:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800035da:	00019497          	auipc	s1,0x19
    800035de:	76e48493          	addi	s1,s1,1902 # 8001cd48 <log>
    800035e2:	00005597          	auipc	a1,0x5
    800035e6:	fce58593          	addi	a1,a1,-50 # 800085b0 <syscalls+0x1e0>
    800035ea:	8526                	mv	a0,s1
    800035ec:	00003097          	auipc	ra,0x3
    800035f0:	150080e7          	jalr	336(ra) # 8000673c <initlock>
  log.start = sb->logstart;
    800035f4:	0149a583          	lw	a1,20(s3)
    800035f8:	d08c                	sw	a1,32(s1)
  log.size = sb->nlog;
    800035fa:	0109a783          	lw	a5,16(s3)
    800035fe:	d0dc                	sw	a5,36(s1)
  log.dev = dev;
    80003600:	0324a823          	sw	s2,48(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003604:	854a                	mv	a0,s2
    80003606:	fffff097          	auipc	ra,0xfffff
    8000360a:	db0080e7          	jalr	-592(ra) # 800023b6 <bread>
  log.lh.n = lh->n;
    8000360e:	553c                	lw	a5,104(a0)
    80003610:	d8dc                	sw	a5,52(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003612:	02f05563          	blez	a5,8000363c <initlog+0x74>
    80003616:	06c50713          	addi	a4,a0,108
    8000361a:	00019697          	auipc	a3,0x19
    8000361e:	76668693          	addi	a3,a3,1894 # 8001cd80 <log+0x38>
    80003622:	37fd                	addiw	a5,a5,-1
    80003624:	1782                	slli	a5,a5,0x20
    80003626:	9381                	srli	a5,a5,0x20
    80003628:	078a                	slli	a5,a5,0x2
    8000362a:	07050613          	addi	a2,a0,112
    8000362e:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    80003630:	4310                	lw	a2,0(a4)
    80003632:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    80003634:	0711                	addi	a4,a4,4
    80003636:	0691                	addi	a3,a3,4
    80003638:	fef71ce3          	bne	a4,a5,80003630 <initlog+0x68>
  brelse(buf);
    8000363c:	fffff097          	auipc	ra,0xfffff
    80003640:	f38080e7          	jalr	-200(ra) # 80002574 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003644:	4505                	li	a0,1
    80003646:	00000097          	auipc	ra,0x0
    8000364a:	ebe080e7          	jalr	-322(ra) # 80003504 <install_trans>
  log.lh.n = 0;
    8000364e:	00019797          	auipc	a5,0x19
    80003652:	7207a723          	sw	zero,1838(a5) # 8001cd7c <log+0x34>
  write_head(); // clear the log
    80003656:	00000097          	auipc	ra,0x0
    8000365a:	e34080e7          	jalr	-460(ra) # 8000348a <write_head>
}
    8000365e:	70a2                	ld	ra,40(sp)
    80003660:	7402                	ld	s0,32(sp)
    80003662:	64e2                	ld	s1,24(sp)
    80003664:	6942                	ld	s2,16(sp)
    80003666:	69a2                	ld	s3,8(sp)
    80003668:	6145                	addi	sp,sp,48
    8000366a:	8082                	ret

000000008000366c <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000366c:	1101                	addi	sp,sp,-32
    8000366e:	ec06                	sd	ra,24(sp)
    80003670:	e822                	sd	s0,16(sp)
    80003672:	e426                	sd	s1,8(sp)
    80003674:	e04a                	sd	s2,0(sp)
    80003676:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003678:	00019517          	auipc	a0,0x19
    8000367c:	6d050513          	addi	a0,a0,1744 # 8001cd48 <log>
    80003680:	00003097          	auipc	ra,0x3
    80003684:	f40080e7          	jalr	-192(ra) # 800065c0 <acquire>
  while(1){
    if(log.committing){
    80003688:	00019497          	auipc	s1,0x19
    8000368c:	6c048493          	addi	s1,s1,1728 # 8001cd48 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003690:	4979                	li	s2,30
    80003692:	a039                	j	800036a0 <begin_op+0x34>
      sleep(&log, &log.lock);
    80003694:	85a6                	mv	a1,s1
    80003696:	8526                	mv	a0,s1
    80003698:	ffffe097          	auipc	ra,0xffffe
    8000369c:	fc8080e7          	jalr	-56(ra) # 80001660 <sleep>
    if(log.committing){
    800036a0:	54dc                	lw	a5,44(s1)
    800036a2:	fbed                	bnez	a5,80003694 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800036a4:	549c                	lw	a5,40(s1)
    800036a6:	0017871b          	addiw	a4,a5,1
    800036aa:	0007069b          	sext.w	a3,a4
    800036ae:	0027179b          	slliw	a5,a4,0x2
    800036b2:	9fb9                	addw	a5,a5,a4
    800036b4:	0017979b          	slliw	a5,a5,0x1
    800036b8:	58d8                	lw	a4,52(s1)
    800036ba:	9fb9                	addw	a5,a5,a4
    800036bc:	00f95963          	bge	s2,a5,800036ce <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800036c0:	85a6                	mv	a1,s1
    800036c2:	8526                	mv	a0,s1
    800036c4:	ffffe097          	auipc	ra,0xffffe
    800036c8:	f9c080e7          	jalr	-100(ra) # 80001660 <sleep>
    800036cc:	bfd1                	j	800036a0 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800036ce:	00019517          	auipc	a0,0x19
    800036d2:	67a50513          	addi	a0,a0,1658 # 8001cd48 <log>
    800036d6:	d514                	sw	a3,40(a0)
      release(&log.lock);
    800036d8:	00003097          	auipc	ra,0x3
    800036dc:	fb8080e7          	jalr	-72(ra) # 80006690 <release>
      break;
    }
  }
}
    800036e0:	60e2                	ld	ra,24(sp)
    800036e2:	6442                	ld	s0,16(sp)
    800036e4:	64a2                	ld	s1,8(sp)
    800036e6:	6902                	ld	s2,0(sp)
    800036e8:	6105                	addi	sp,sp,32
    800036ea:	8082                	ret

00000000800036ec <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800036ec:	7139                	addi	sp,sp,-64
    800036ee:	fc06                	sd	ra,56(sp)
    800036f0:	f822                	sd	s0,48(sp)
    800036f2:	f426                	sd	s1,40(sp)
    800036f4:	f04a                	sd	s2,32(sp)
    800036f6:	ec4e                	sd	s3,24(sp)
    800036f8:	e852                	sd	s4,16(sp)
    800036fa:	e456                	sd	s5,8(sp)
    800036fc:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800036fe:	00019497          	auipc	s1,0x19
    80003702:	64a48493          	addi	s1,s1,1610 # 8001cd48 <log>
    80003706:	8526                	mv	a0,s1
    80003708:	00003097          	auipc	ra,0x3
    8000370c:	eb8080e7          	jalr	-328(ra) # 800065c0 <acquire>
  log.outstanding -= 1;
    80003710:	549c                	lw	a5,40(s1)
    80003712:	37fd                	addiw	a5,a5,-1
    80003714:	0007891b          	sext.w	s2,a5
    80003718:	d49c                	sw	a5,40(s1)
  if(log.committing)
    8000371a:	54dc                	lw	a5,44(s1)
    8000371c:	efb9                	bnez	a5,8000377a <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000371e:	06091663          	bnez	s2,8000378a <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    80003722:	00019497          	auipc	s1,0x19
    80003726:	62648493          	addi	s1,s1,1574 # 8001cd48 <log>
    8000372a:	4785                	li	a5,1
    8000372c:	d4dc                	sw	a5,44(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000372e:	8526                	mv	a0,s1
    80003730:	00003097          	auipc	ra,0x3
    80003734:	f60080e7          	jalr	-160(ra) # 80006690 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003738:	58dc                	lw	a5,52(s1)
    8000373a:	06f04763          	bgtz	a5,800037a8 <end_op+0xbc>
    acquire(&log.lock);
    8000373e:	00019497          	auipc	s1,0x19
    80003742:	60a48493          	addi	s1,s1,1546 # 8001cd48 <log>
    80003746:	8526                	mv	a0,s1
    80003748:	00003097          	auipc	ra,0x3
    8000374c:	e78080e7          	jalr	-392(ra) # 800065c0 <acquire>
    log.committing = 0;
    80003750:	0204a623          	sw	zero,44(s1)
    wakeup(&log);
    80003754:	8526                	mv	a0,s1
    80003756:	ffffe097          	auipc	ra,0xffffe
    8000375a:	096080e7          	jalr	150(ra) # 800017ec <wakeup>
    release(&log.lock);
    8000375e:	8526                	mv	a0,s1
    80003760:	00003097          	auipc	ra,0x3
    80003764:	f30080e7          	jalr	-208(ra) # 80006690 <release>
}
    80003768:	70e2                	ld	ra,56(sp)
    8000376a:	7442                	ld	s0,48(sp)
    8000376c:	74a2                	ld	s1,40(sp)
    8000376e:	7902                	ld	s2,32(sp)
    80003770:	69e2                	ld	s3,24(sp)
    80003772:	6a42                	ld	s4,16(sp)
    80003774:	6aa2                	ld	s5,8(sp)
    80003776:	6121                	addi	sp,sp,64
    80003778:	8082                	ret
    panic("log.committing");
    8000377a:	00005517          	auipc	a0,0x5
    8000377e:	e3e50513          	addi	a0,a0,-450 # 800085b8 <syscalls+0x1e8>
    80003782:	00003097          	auipc	ra,0x3
    80003786:	90a080e7          	jalr	-1782(ra) # 8000608c <panic>
    wakeup(&log);
    8000378a:	00019497          	auipc	s1,0x19
    8000378e:	5be48493          	addi	s1,s1,1470 # 8001cd48 <log>
    80003792:	8526                	mv	a0,s1
    80003794:	ffffe097          	auipc	ra,0xffffe
    80003798:	058080e7          	jalr	88(ra) # 800017ec <wakeup>
  release(&log.lock);
    8000379c:	8526                	mv	a0,s1
    8000379e:	00003097          	auipc	ra,0x3
    800037a2:	ef2080e7          	jalr	-270(ra) # 80006690 <release>
  if(do_commit){
    800037a6:	b7c9                	j	80003768 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    800037a8:	00019a97          	auipc	s5,0x19
    800037ac:	5d8a8a93          	addi	s5,s5,1496 # 8001cd80 <log+0x38>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800037b0:	00019a17          	auipc	s4,0x19
    800037b4:	598a0a13          	addi	s4,s4,1432 # 8001cd48 <log>
    800037b8:	020a2583          	lw	a1,32(s4)
    800037bc:	012585bb          	addw	a1,a1,s2
    800037c0:	2585                	addiw	a1,a1,1
    800037c2:	030a2503          	lw	a0,48(s4)
    800037c6:	fffff097          	auipc	ra,0xfffff
    800037ca:	bf0080e7          	jalr	-1040(ra) # 800023b6 <bread>
    800037ce:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800037d0:	000aa583          	lw	a1,0(s5)
    800037d4:	030a2503          	lw	a0,48(s4)
    800037d8:	fffff097          	auipc	ra,0xfffff
    800037dc:	bde080e7          	jalr	-1058(ra) # 800023b6 <bread>
    800037e0:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800037e2:	40000613          	li	a2,1024
    800037e6:	06850593          	addi	a1,a0,104
    800037ea:	06848513          	addi	a0,s1,104
    800037ee:	ffffd097          	auipc	ra,0xffffd
    800037f2:	b36080e7          	jalr	-1226(ra) # 80000324 <memmove>
    bwrite(to);  // write the log
    800037f6:	8526                	mv	a0,s1
    800037f8:	fffff097          	auipc	ra,0xfffff
    800037fc:	d3e080e7          	jalr	-706(ra) # 80002536 <bwrite>
    brelse(from);
    80003800:	854e                	mv	a0,s3
    80003802:	fffff097          	auipc	ra,0xfffff
    80003806:	d72080e7          	jalr	-654(ra) # 80002574 <brelse>
    brelse(to);
    8000380a:	8526                	mv	a0,s1
    8000380c:	fffff097          	auipc	ra,0xfffff
    80003810:	d68080e7          	jalr	-664(ra) # 80002574 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003814:	2905                	addiw	s2,s2,1
    80003816:	0a91                	addi	s5,s5,4
    80003818:	034a2783          	lw	a5,52(s4)
    8000381c:	f8f94ee3          	blt	s2,a5,800037b8 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003820:	00000097          	auipc	ra,0x0
    80003824:	c6a080e7          	jalr	-918(ra) # 8000348a <write_head>
    install_trans(0); // Now install writes to home locations
    80003828:	4501                	li	a0,0
    8000382a:	00000097          	auipc	ra,0x0
    8000382e:	cda080e7          	jalr	-806(ra) # 80003504 <install_trans>
    log.lh.n = 0;
    80003832:	00019797          	auipc	a5,0x19
    80003836:	5407a523          	sw	zero,1354(a5) # 8001cd7c <log+0x34>
    write_head();    // Erase the transaction from the log
    8000383a:	00000097          	auipc	ra,0x0
    8000383e:	c50080e7          	jalr	-944(ra) # 8000348a <write_head>
    80003842:	bdf5                	j	8000373e <end_op+0x52>

0000000080003844 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003844:	1101                	addi	sp,sp,-32
    80003846:	ec06                	sd	ra,24(sp)
    80003848:	e822                	sd	s0,16(sp)
    8000384a:	e426                	sd	s1,8(sp)
    8000384c:	e04a                	sd	s2,0(sp)
    8000384e:	1000                	addi	s0,sp,32
    80003850:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003852:	00019917          	auipc	s2,0x19
    80003856:	4f690913          	addi	s2,s2,1270 # 8001cd48 <log>
    8000385a:	854a                	mv	a0,s2
    8000385c:	00003097          	auipc	ra,0x3
    80003860:	d64080e7          	jalr	-668(ra) # 800065c0 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80003864:	03492603          	lw	a2,52(s2)
    80003868:	47f5                	li	a5,29
    8000386a:	06c7c563          	blt	a5,a2,800038d4 <log_write+0x90>
    8000386e:	00019797          	auipc	a5,0x19
    80003872:	4fe7a783          	lw	a5,1278(a5) # 8001cd6c <log+0x24>
    80003876:	37fd                	addiw	a5,a5,-1
    80003878:	04f65e63          	bge	a2,a5,800038d4 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000387c:	00019797          	auipc	a5,0x19
    80003880:	4f47a783          	lw	a5,1268(a5) # 8001cd70 <log+0x28>
    80003884:	06f05063          	blez	a5,800038e4 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003888:	4781                	li	a5,0
    8000388a:	06c05563          	blez	a2,800038f4 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000388e:	488c                	lw	a1,16(s1)
    80003890:	00019717          	auipc	a4,0x19
    80003894:	4f070713          	addi	a4,a4,1264 # 8001cd80 <log+0x38>
  for (i = 0; i < log.lh.n; i++) {
    80003898:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000389a:	4314                	lw	a3,0(a4)
    8000389c:	04b68c63          	beq	a3,a1,800038f4 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800038a0:	2785                	addiw	a5,a5,1
    800038a2:	0711                	addi	a4,a4,4
    800038a4:	fef61be3          	bne	a2,a5,8000389a <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800038a8:	0631                	addi	a2,a2,12
    800038aa:	060a                	slli	a2,a2,0x2
    800038ac:	00019797          	auipc	a5,0x19
    800038b0:	49c78793          	addi	a5,a5,1180 # 8001cd48 <log>
    800038b4:	963e                	add	a2,a2,a5
    800038b6:	489c                	lw	a5,16(s1)
    800038b8:	c61c                	sw	a5,8(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800038ba:	8526                	mv	a0,s1
    800038bc:	fffff097          	auipc	ra,0xfffff
    800038c0:	d66080e7          	jalr	-666(ra) # 80002622 <bpin>
    log.lh.n++;
    800038c4:	00019717          	auipc	a4,0x19
    800038c8:	48470713          	addi	a4,a4,1156 # 8001cd48 <log>
    800038cc:	5b5c                	lw	a5,52(a4)
    800038ce:	2785                	addiw	a5,a5,1
    800038d0:	db5c                	sw	a5,52(a4)
    800038d2:	a835                	j	8000390e <log_write+0xca>
    panic("too big a transaction");
    800038d4:	00005517          	auipc	a0,0x5
    800038d8:	cf450513          	addi	a0,a0,-780 # 800085c8 <syscalls+0x1f8>
    800038dc:	00002097          	auipc	ra,0x2
    800038e0:	7b0080e7          	jalr	1968(ra) # 8000608c <panic>
    panic("log_write outside of trans");
    800038e4:	00005517          	auipc	a0,0x5
    800038e8:	cfc50513          	addi	a0,a0,-772 # 800085e0 <syscalls+0x210>
    800038ec:	00002097          	auipc	ra,0x2
    800038f0:	7a0080e7          	jalr	1952(ra) # 8000608c <panic>
  log.lh.block[i] = b->blockno;
    800038f4:	00c78713          	addi	a4,a5,12
    800038f8:	00271693          	slli	a3,a4,0x2
    800038fc:	00019717          	auipc	a4,0x19
    80003900:	44c70713          	addi	a4,a4,1100 # 8001cd48 <log>
    80003904:	9736                	add	a4,a4,a3
    80003906:	4894                	lw	a3,16(s1)
    80003908:	c714                	sw	a3,8(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000390a:	faf608e3          	beq	a2,a5,800038ba <log_write+0x76>
  }
  release(&log.lock);
    8000390e:	00019517          	auipc	a0,0x19
    80003912:	43a50513          	addi	a0,a0,1082 # 8001cd48 <log>
    80003916:	00003097          	auipc	ra,0x3
    8000391a:	d7a080e7          	jalr	-646(ra) # 80006690 <release>
}
    8000391e:	60e2                	ld	ra,24(sp)
    80003920:	6442                	ld	s0,16(sp)
    80003922:	64a2                	ld	s1,8(sp)
    80003924:	6902                	ld	s2,0(sp)
    80003926:	6105                	addi	sp,sp,32
    80003928:	8082                	ret

000000008000392a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000392a:	1101                	addi	sp,sp,-32
    8000392c:	ec06                	sd	ra,24(sp)
    8000392e:	e822                	sd	s0,16(sp)
    80003930:	e426                	sd	s1,8(sp)
    80003932:	e04a                	sd	s2,0(sp)
    80003934:	1000                	addi	s0,sp,32
    80003936:	84aa                	mv	s1,a0
    80003938:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000393a:	00005597          	auipc	a1,0x5
    8000393e:	cc658593          	addi	a1,a1,-826 # 80008600 <syscalls+0x230>
    80003942:	0521                	addi	a0,a0,8
    80003944:	00003097          	auipc	ra,0x3
    80003948:	df8080e7          	jalr	-520(ra) # 8000673c <initlock>
  lk->name = name;
    8000394c:	0324b423          	sd	s2,40(s1)
  lk->locked = 0;
    80003950:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003954:	0204a823          	sw	zero,48(s1)
}
    80003958:	60e2                	ld	ra,24(sp)
    8000395a:	6442                	ld	s0,16(sp)
    8000395c:	64a2                	ld	s1,8(sp)
    8000395e:	6902                	ld	s2,0(sp)
    80003960:	6105                	addi	sp,sp,32
    80003962:	8082                	ret

0000000080003964 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003964:	1101                	addi	sp,sp,-32
    80003966:	ec06                	sd	ra,24(sp)
    80003968:	e822                	sd	s0,16(sp)
    8000396a:	e426                	sd	s1,8(sp)
    8000396c:	e04a                	sd	s2,0(sp)
    8000396e:	1000                	addi	s0,sp,32
    80003970:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003972:	00850913          	addi	s2,a0,8
    80003976:	854a                	mv	a0,s2
    80003978:	00003097          	auipc	ra,0x3
    8000397c:	c48080e7          	jalr	-952(ra) # 800065c0 <acquire>
  while (lk->locked) {
    80003980:	409c                	lw	a5,0(s1)
    80003982:	cb89                	beqz	a5,80003994 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80003984:	85ca                	mv	a1,s2
    80003986:	8526                	mv	a0,s1
    80003988:	ffffe097          	auipc	ra,0xffffe
    8000398c:	cd8080e7          	jalr	-808(ra) # 80001660 <sleep>
  while (lk->locked) {
    80003990:	409c                	lw	a5,0(s1)
    80003992:	fbed                	bnez	a5,80003984 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80003994:	4785                	li	a5,1
    80003996:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003998:	ffffd097          	auipc	ra,0xffffd
    8000399c:	60c080e7          	jalr	1548(ra) # 80000fa4 <myproc>
    800039a0:	5d1c                	lw	a5,56(a0)
    800039a2:	d89c                	sw	a5,48(s1)
  release(&lk->lk);
    800039a4:	854a                	mv	a0,s2
    800039a6:	00003097          	auipc	ra,0x3
    800039aa:	cea080e7          	jalr	-790(ra) # 80006690 <release>
}
    800039ae:	60e2                	ld	ra,24(sp)
    800039b0:	6442                	ld	s0,16(sp)
    800039b2:	64a2                	ld	s1,8(sp)
    800039b4:	6902                	ld	s2,0(sp)
    800039b6:	6105                	addi	sp,sp,32
    800039b8:	8082                	ret

00000000800039ba <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800039ba:	1101                	addi	sp,sp,-32
    800039bc:	ec06                	sd	ra,24(sp)
    800039be:	e822                	sd	s0,16(sp)
    800039c0:	e426                	sd	s1,8(sp)
    800039c2:	e04a                	sd	s2,0(sp)
    800039c4:	1000                	addi	s0,sp,32
    800039c6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800039c8:	00850913          	addi	s2,a0,8
    800039cc:	854a                	mv	a0,s2
    800039ce:	00003097          	auipc	ra,0x3
    800039d2:	bf2080e7          	jalr	-1038(ra) # 800065c0 <acquire>
  lk->locked = 0;
    800039d6:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800039da:	0204a823          	sw	zero,48(s1)
  wakeup(lk);
    800039de:	8526                	mv	a0,s1
    800039e0:	ffffe097          	auipc	ra,0xffffe
    800039e4:	e0c080e7          	jalr	-500(ra) # 800017ec <wakeup>
  release(&lk->lk);
    800039e8:	854a                	mv	a0,s2
    800039ea:	00003097          	auipc	ra,0x3
    800039ee:	ca6080e7          	jalr	-858(ra) # 80006690 <release>
}
    800039f2:	60e2                	ld	ra,24(sp)
    800039f4:	6442                	ld	s0,16(sp)
    800039f6:	64a2                	ld	s1,8(sp)
    800039f8:	6902                	ld	s2,0(sp)
    800039fa:	6105                	addi	sp,sp,32
    800039fc:	8082                	ret

00000000800039fe <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800039fe:	7179                	addi	sp,sp,-48
    80003a00:	f406                	sd	ra,40(sp)
    80003a02:	f022                	sd	s0,32(sp)
    80003a04:	ec26                	sd	s1,24(sp)
    80003a06:	e84a                	sd	s2,16(sp)
    80003a08:	e44e                	sd	s3,8(sp)
    80003a0a:	1800                	addi	s0,sp,48
    80003a0c:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003a0e:	00850913          	addi	s2,a0,8
    80003a12:	854a                	mv	a0,s2
    80003a14:	00003097          	auipc	ra,0x3
    80003a18:	bac080e7          	jalr	-1108(ra) # 800065c0 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003a1c:	409c                	lw	a5,0(s1)
    80003a1e:	ef99                	bnez	a5,80003a3c <holdingsleep+0x3e>
    80003a20:	4481                	li	s1,0
  release(&lk->lk);
    80003a22:	854a                	mv	a0,s2
    80003a24:	00003097          	auipc	ra,0x3
    80003a28:	c6c080e7          	jalr	-916(ra) # 80006690 <release>
  return r;
}
    80003a2c:	8526                	mv	a0,s1
    80003a2e:	70a2                	ld	ra,40(sp)
    80003a30:	7402                	ld	s0,32(sp)
    80003a32:	64e2                	ld	s1,24(sp)
    80003a34:	6942                	ld	s2,16(sp)
    80003a36:	69a2                	ld	s3,8(sp)
    80003a38:	6145                	addi	sp,sp,48
    80003a3a:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80003a3c:	0304a983          	lw	s3,48(s1)
    80003a40:	ffffd097          	auipc	ra,0xffffd
    80003a44:	564080e7          	jalr	1380(ra) # 80000fa4 <myproc>
    80003a48:	5d04                	lw	s1,56(a0)
    80003a4a:	413484b3          	sub	s1,s1,s3
    80003a4e:	0014b493          	seqz	s1,s1
    80003a52:	bfc1                	j	80003a22 <holdingsleep+0x24>

0000000080003a54 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003a54:	1141                	addi	sp,sp,-16
    80003a56:	e406                	sd	ra,8(sp)
    80003a58:	e022                	sd	s0,0(sp)
    80003a5a:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003a5c:	00005597          	auipc	a1,0x5
    80003a60:	bb458593          	addi	a1,a1,-1100 # 80008610 <syscalls+0x240>
    80003a64:	00019517          	auipc	a0,0x19
    80003a68:	43450513          	addi	a0,a0,1076 # 8001ce98 <ftable>
    80003a6c:	00003097          	auipc	ra,0x3
    80003a70:	cd0080e7          	jalr	-816(ra) # 8000673c <initlock>
}
    80003a74:	60a2                	ld	ra,8(sp)
    80003a76:	6402                	ld	s0,0(sp)
    80003a78:	0141                	addi	sp,sp,16
    80003a7a:	8082                	ret

0000000080003a7c <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80003a7c:	1101                	addi	sp,sp,-32
    80003a7e:	ec06                	sd	ra,24(sp)
    80003a80:	e822                	sd	s0,16(sp)
    80003a82:	e426                	sd	s1,8(sp)
    80003a84:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003a86:	00019517          	auipc	a0,0x19
    80003a8a:	41250513          	addi	a0,a0,1042 # 8001ce98 <ftable>
    80003a8e:	00003097          	auipc	ra,0x3
    80003a92:	b32080e7          	jalr	-1230(ra) # 800065c0 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003a96:	00019497          	auipc	s1,0x19
    80003a9a:	42248493          	addi	s1,s1,1058 # 8001ceb8 <ftable+0x20>
    80003a9e:	0001a717          	auipc	a4,0x1a
    80003aa2:	3ba70713          	addi	a4,a4,954 # 8001de58 <ftable+0xfc0>
    if(f->ref == 0){
    80003aa6:	40dc                	lw	a5,4(s1)
    80003aa8:	cf99                	beqz	a5,80003ac6 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003aaa:	02848493          	addi	s1,s1,40
    80003aae:	fee49ce3          	bne	s1,a4,80003aa6 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003ab2:	00019517          	auipc	a0,0x19
    80003ab6:	3e650513          	addi	a0,a0,998 # 8001ce98 <ftable>
    80003aba:	00003097          	auipc	ra,0x3
    80003abe:	bd6080e7          	jalr	-1066(ra) # 80006690 <release>
  return 0;
    80003ac2:	4481                	li	s1,0
    80003ac4:	a819                	j	80003ada <filealloc+0x5e>
      f->ref = 1;
    80003ac6:	4785                	li	a5,1
    80003ac8:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003aca:	00019517          	auipc	a0,0x19
    80003ace:	3ce50513          	addi	a0,a0,974 # 8001ce98 <ftable>
    80003ad2:	00003097          	auipc	ra,0x3
    80003ad6:	bbe080e7          	jalr	-1090(ra) # 80006690 <release>
}
    80003ada:	8526                	mv	a0,s1
    80003adc:	60e2                	ld	ra,24(sp)
    80003ade:	6442                	ld	s0,16(sp)
    80003ae0:	64a2                	ld	s1,8(sp)
    80003ae2:	6105                	addi	sp,sp,32
    80003ae4:	8082                	ret

0000000080003ae6 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003ae6:	1101                	addi	sp,sp,-32
    80003ae8:	ec06                	sd	ra,24(sp)
    80003aea:	e822                	sd	s0,16(sp)
    80003aec:	e426                	sd	s1,8(sp)
    80003aee:	1000                	addi	s0,sp,32
    80003af0:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003af2:	00019517          	auipc	a0,0x19
    80003af6:	3a650513          	addi	a0,a0,934 # 8001ce98 <ftable>
    80003afa:	00003097          	auipc	ra,0x3
    80003afe:	ac6080e7          	jalr	-1338(ra) # 800065c0 <acquire>
  if(f->ref < 1)
    80003b02:	40dc                	lw	a5,4(s1)
    80003b04:	02f05263          	blez	a5,80003b28 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80003b08:	2785                	addiw	a5,a5,1
    80003b0a:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003b0c:	00019517          	auipc	a0,0x19
    80003b10:	38c50513          	addi	a0,a0,908 # 8001ce98 <ftable>
    80003b14:	00003097          	auipc	ra,0x3
    80003b18:	b7c080e7          	jalr	-1156(ra) # 80006690 <release>
  return f;
}
    80003b1c:	8526                	mv	a0,s1
    80003b1e:	60e2                	ld	ra,24(sp)
    80003b20:	6442                	ld	s0,16(sp)
    80003b22:	64a2                	ld	s1,8(sp)
    80003b24:	6105                	addi	sp,sp,32
    80003b26:	8082                	ret
    panic("filedup");
    80003b28:	00005517          	auipc	a0,0x5
    80003b2c:	af050513          	addi	a0,a0,-1296 # 80008618 <syscalls+0x248>
    80003b30:	00002097          	auipc	ra,0x2
    80003b34:	55c080e7          	jalr	1372(ra) # 8000608c <panic>

0000000080003b38 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80003b38:	7139                	addi	sp,sp,-64
    80003b3a:	fc06                	sd	ra,56(sp)
    80003b3c:	f822                	sd	s0,48(sp)
    80003b3e:	f426                	sd	s1,40(sp)
    80003b40:	f04a                	sd	s2,32(sp)
    80003b42:	ec4e                	sd	s3,24(sp)
    80003b44:	e852                	sd	s4,16(sp)
    80003b46:	e456                	sd	s5,8(sp)
    80003b48:	0080                	addi	s0,sp,64
    80003b4a:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003b4c:	00019517          	auipc	a0,0x19
    80003b50:	34c50513          	addi	a0,a0,844 # 8001ce98 <ftable>
    80003b54:	00003097          	auipc	ra,0x3
    80003b58:	a6c080e7          	jalr	-1428(ra) # 800065c0 <acquire>
  if(f->ref < 1)
    80003b5c:	40dc                	lw	a5,4(s1)
    80003b5e:	06f05163          	blez	a5,80003bc0 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80003b62:	37fd                	addiw	a5,a5,-1
    80003b64:	0007871b          	sext.w	a4,a5
    80003b68:	c0dc                	sw	a5,4(s1)
    80003b6a:	06e04363          	bgtz	a4,80003bd0 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80003b6e:	0004a903          	lw	s2,0(s1)
    80003b72:	0094ca83          	lbu	s5,9(s1)
    80003b76:	0104ba03          	ld	s4,16(s1)
    80003b7a:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80003b7e:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80003b82:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80003b86:	00019517          	auipc	a0,0x19
    80003b8a:	31250513          	addi	a0,a0,786 # 8001ce98 <ftable>
    80003b8e:	00003097          	auipc	ra,0x3
    80003b92:	b02080e7          	jalr	-1278(ra) # 80006690 <release>

  if(ff.type == FD_PIPE){
    80003b96:	4785                	li	a5,1
    80003b98:	04f90d63          	beq	s2,a5,80003bf2 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80003b9c:	3979                	addiw	s2,s2,-2
    80003b9e:	4785                	li	a5,1
    80003ba0:	0527e063          	bltu	a5,s2,80003be0 <fileclose+0xa8>
    begin_op();
    80003ba4:	00000097          	auipc	ra,0x0
    80003ba8:	ac8080e7          	jalr	-1336(ra) # 8000366c <begin_op>
    iput(ff.ip);
    80003bac:	854e                	mv	a0,s3
    80003bae:	fffff097          	auipc	ra,0xfffff
    80003bb2:	2a6080e7          	jalr	678(ra) # 80002e54 <iput>
    end_op();
    80003bb6:	00000097          	auipc	ra,0x0
    80003bba:	b36080e7          	jalr	-1226(ra) # 800036ec <end_op>
    80003bbe:	a00d                	j	80003be0 <fileclose+0xa8>
    panic("fileclose");
    80003bc0:	00005517          	auipc	a0,0x5
    80003bc4:	a6050513          	addi	a0,a0,-1440 # 80008620 <syscalls+0x250>
    80003bc8:	00002097          	auipc	ra,0x2
    80003bcc:	4c4080e7          	jalr	1220(ra) # 8000608c <panic>
    release(&ftable.lock);
    80003bd0:	00019517          	auipc	a0,0x19
    80003bd4:	2c850513          	addi	a0,a0,712 # 8001ce98 <ftable>
    80003bd8:	00003097          	auipc	ra,0x3
    80003bdc:	ab8080e7          	jalr	-1352(ra) # 80006690 <release>
  }
}
    80003be0:	70e2                	ld	ra,56(sp)
    80003be2:	7442                	ld	s0,48(sp)
    80003be4:	74a2                	ld	s1,40(sp)
    80003be6:	7902                	ld	s2,32(sp)
    80003be8:	69e2                	ld	s3,24(sp)
    80003bea:	6a42                	ld	s4,16(sp)
    80003bec:	6aa2                	ld	s5,8(sp)
    80003bee:	6121                	addi	sp,sp,64
    80003bf0:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80003bf2:	85d6                	mv	a1,s5
    80003bf4:	8552                	mv	a0,s4
    80003bf6:	00000097          	auipc	ra,0x0
    80003bfa:	34c080e7          	jalr	844(ra) # 80003f42 <pipeclose>
    80003bfe:	b7cd                	j	80003be0 <fileclose+0xa8>

0000000080003c00 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80003c00:	715d                	addi	sp,sp,-80
    80003c02:	e486                	sd	ra,72(sp)
    80003c04:	e0a2                	sd	s0,64(sp)
    80003c06:	fc26                	sd	s1,56(sp)
    80003c08:	f84a                	sd	s2,48(sp)
    80003c0a:	f44e                	sd	s3,40(sp)
    80003c0c:	0880                	addi	s0,sp,80
    80003c0e:	84aa                	mv	s1,a0
    80003c10:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80003c12:	ffffd097          	auipc	ra,0xffffd
    80003c16:	392080e7          	jalr	914(ra) # 80000fa4 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80003c1a:	409c                	lw	a5,0(s1)
    80003c1c:	37f9                	addiw	a5,a5,-2
    80003c1e:	4705                	li	a4,1
    80003c20:	04f76763          	bltu	a4,a5,80003c6e <filestat+0x6e>
    80003c24:	892a                	mv	s2,a0
    ilock(f->ip);
    80003c26:	6c88                	ld	a0,24(s1)
    80003c28:	fffff097          	auipc	ra,0xfffff
    80003c2c:	072080e7          	jalr	114(ra) # 80002c9a <ilock>
    stati(f->ip, &st);
    80003c30:	fb840593          	addi	a1,s0,-72
    80003c34:	6c88                	ld	a0,24(s1)
    80003c36:	fffff097          	auipc	ra,0xfffff
    80003c3a:	2ee080e7          	jalr	750(ra) # 80002f24 <stati>
    iunlock(f->ip);
    80003c3e:	6c88                	ld	a0,24(s1)
    80003c40:	fffff097          	auipc	ra,0xfffff
    80003c44:	11c080e7          	jalr	284(ra) # 80002d5c <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80003c48:	46e1                	li	a3,24
    80003c4a:	fb840613          	addi	a2,s0,-72
    80003c4e:	85ce                	mv	a1,s3
    80003c50:	05893503          	ld	a0,88(s2)
    80003c54:	ffffd097          	auipc	ra,0xffffd
    80003c58:	012080e7          	jalr	18(ra) # 80000c66 <copyout>
    80003c5c:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80003c60:	60a6                	ld	ra,72(sp)
    80003c62:	6406                	ld	s0,64(sp)
    80003c64:	74e2                	ld	s1,56(sp)
    80003c66:	7942                	ld	s2,48(sp)
    80003c68:	79a2                	ld	s3,40(sp)
    80003c6a:	6161                	addi	sp,sp,80
    80003c6c:	8082                	ret
  return -1;
    80003c6e:	557d                	li	a0,-1
    80003c70:	bfc5                	j	80003c60 <filestat+0x60>

0000000080003c72 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80003c72:	7179                	addi	sp,sp,-48
    80003c74:	f406                	sd	ra,40(sp)
    80003c76:	f022                	sd	s0,32(sp)
    80003c78:	ec26                	sd	s1,24(sp)
    80003c7a:	e84a                	sd	s2,16(sp)
    80003c7c:	e44e                	sd	s3,8(sp)
    80003c7e:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80003c80:	00854783          	lbu	a5,8(a0)
    80003c84:	c3d5                	beqz	a5,80003d28 <fileread+0xb6>
    80003c86:	84aa                	mv	s1,a0
    80003c88:	89ae                	mv	s3,a1
    80003c8a:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80003c8c:	411c                	lw	a5,0(a0)
    80003c8e:	4705                	li	a4,1
    80003c90:	04e78963          	beq	a5,a4,80003ce2 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003c94:	470d                	li	a4,3
    80003c96:	04e78d63          	beq	a5,a4,80003cf0 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80003c9a:	4709                	li	a4,2
    80003c9c:	06e79e63          	bne	a5,a4,80003d18 <fileread+0xa6>
    ilock(f->ip);
    80003ca0:	6d08                	ld	a0,24(a0)
    80003ca2:	fffff097          	auipc	ra,0xfffff
    80003ca6:	ff8080e7          	jalr	-8(ra) # 80002c9a <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80003caa:	874a                	mv	a4,s2
    80003cac:	5094                	lw	a3,32(s1)
    80003cae:	864e                	mv	a2,s3
    80003cb0:	4585                	li	a1,1
    80003cb2:	6c88                	ld	a0,24(s1)
    80003cb4:	fffff097          	auipc	ra,0xfffff
    80003cb8:	29a080e7          	jalr	666(ra) # 80002f4e <readi>
    80003cbc:	892a                	mv	s2,a0
    80003cbe:	00a05563          	blez	a0,80003cc8 <fileread+0x56>
      f->off += r;
    80003cc2:	509c                	lw	a5,32(s1)
    80003cc4:	9fa9                	addw	a5,a5,a0
    80003cc6:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80003cc8:	6c88                	ld	a0,24(s1)
    80003cca:	fffff097          	auipc	ra,0xfffff
    80003cce:	092080e7          	jalr	146(ra) # 80002d5c <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80003cd2:	854a                	mv	a0,s2
    80003cd4:	70a2                	ld	ra,40(sp)
    80003cd6:	7402                	ld	s0,32(sp)
    80003cd8:	64e2                	ld	s1,24(sp)
    80003cda:	6942                	ld	s2,16(sp)
    80003cdc:	69a2                	ld	s3,8(sp)
    80003cde:	6145                	addi	sp,sp,48
    80003ce0:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80003ce2:	6908                	ld	a0,16(a0)
    80003ce4:	00000097          	auipc	ra,0x0
    80003ce8:	3d2080e7          	jalr	978(ra) # 800040b6 <piperead>
    80003cec:	892a                	mv	s2,a0
    80003cee:	b7d5                	j	80003cd2 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80003cf0:	02451783          	lh	a5,36(a0)
    80003cf4:	03079693          	slli	a3,a5,0x30
    80003cf8:	92c1                	srli	a3,a3,0x30
    80003cfa:	4725                	li	a4,9
    80003cfc:	02d76863          	bltu	a4,a3,80003d2c <fileread+0xba>
    80003d00:	0792                	slli	a5,a5,0x4
    80003d02:	00019717          	auipc	a4,0x19
    80003d06:	0f670713          	addi	a4,a4,246 # 8001cdf8 <devsw>
    80003d0a:	97ba                	add	a5,a5,a4
    80003d0c:	639c                	ld	a5,0(a5)
    80003d0e:	c38d                	beqz	a5,80003d30 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80003d10:	4505                	li	a0,1
    80003d12:	9782                	jalr	a5
    80003d14:	892a                	mv	s2,a0
    80003d16:	bf75                	j	80003cd2 <fileread+0x60>
    panic("fileread");
    80003d18:	00005517          	auipc	a0,0x5
    80003d1c:	91850513          	addi	a0,a0,-1768 # 80008630 <syscalls+0x260>
    80003d20:	00002097          	auipc	ra,0x2
    80003d24:	36c080e7          	jalr	876(ra) # 8000608c <panic>
    return -1;
    80003d28:	597d                	li	s2,-1
    80003d2a:	b765                	j	80003cd2 <fileread+0x60>
      return -1;
    80003d2c:	597d                	li	s2,-1
    80003d2e:	b755                	j	80003cd2 <fileread+0x60>
    80003d30:	597d                	li	s2,-1
    80003d32:	b745                	j	80003cd2 <fileread+0x60>

0000000080003d34 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80003d34:	715d                	addi	sp,sp,-80
    80003d36:	e486                	sd	ra,72(sp)
    80003d38:	e0a2                	sd	s0,64(sp)
    80003d3a:	fc26                	sd	s1,56(sp)
    80003d3c:	f84a                	sd	s2,48(sp)
    80003d3e:	f44e                	sd	s3,40(sp)
    80003d40:	f052                	sd	s4,32(sp)
    80003d42:	ec56                	sd	s5,24(sp)
    80003d44:	e85a                	sd	s6,16(sp)
    80003d46:	e45e                	sd	s7,8(sp)
    80003d48:	e062                	sd	s8,0(sp)
    80003d4a:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80003d4c:	00954783          	lbu	a5,9(a0)
    80003d50:	10078663          	beqz	a5,80003e5c <filewrite+0x128>
    80003d54:	892a                	mv	s2,a0
    80003d56:	8aae                	mv	s5,a1
    80003d58:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80003d5a:	411c                	lw	a5,0(a0)
    80003d5c:	4705                	li	a4,1
    80003d5e:	02e78263          	beq	a5,a4,80003d82 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003d62:	470d                	li	a4,3
    80003d64:	02e78663          	beq	a5,a4,80003d90 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80003d68:	4709                	li	a4,2
    80003d6a:	0ee79163          	bne	a5,a4,80003e4c <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80003d6e:	0ac05d63          	blez	a2,80003e28 <filewrite+0xf4>
    int i = 0;
    80003d72:	4981                	li	s3,0
    80003d74:	6b05                	lui	s6,0x1
    80003d76:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80003d7a:	6b85                	lui	s7,0x1
    80003d7c:	c00b8b9b          	addiw	s7,s7,-1024
    80003d80:	a861                	j	80003e18 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80003d82:	6908                	ld	a0,16(a0)
    80003d84:	00000097          	auipc	ra,0x0
    80003d88:	238080e7          	jalr	568(ra) # 80003fbc <pipewrite>
    80003d8c:	8a2a                	mv	s4,a0
    80003d8e:	a045                	j	80003e2e <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80003d90:	02451783          	lh	a5,36(a0)
    80003d94:	03079693          	slli	a3,a5,0x30
    80003d98:	92c1                	srli	a3,a3,0x30
    80003d9a:	4725                	li	a4,9
    80003d9c:	0cd76263          	bltu	a4,a3,80003e60 <filewrite+0x12c>
    80003da0:	0792                	slli	a5,a5,0x4
    80003da2:	00019717          	auipc	a4,0x19
    80003da6:	05670713          	addi	a4,a4,86 # 8001cdf8 <devsw>
    80003daa:	97ba                	add	a5,a5,a4
    80003dac:	679c                	ld	a5,8(a5)
    80003dae:	cbdd                	beqz	a5,80003e64 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80003db0:	4505                	li	a0,1
    80003db2:	9782                	jalr	a5
    80003db4:	8a2a                	mv	s4,a0
    80003db6:	a8a5                	j	80003e2e <filewrite+0xfa>
    80003db8:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80003dbc:	00000097          	auipc	ra,0x0
    80003dc0:	8b0080e7          	jalr	-1872(ra) # 8000366c <begin_op>
      ilock(f->ip);
    80003dc4:	01893503          	ld	a0,24(s2)
    80003dc8:	fffff097          	auipc	ra,0xfffff
    80003dcc:	ed2080e7          	jalr	-302(ra) # 80002c9a <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80003dd0:	8762                	mv	a4,s8
    80003dd2:	02092683          	lw	a3,32(s2)
    80003dd6:	01598633          	add	a2,s3,s5
    80003dda:	4585                	li	a1,1
    80003ddc:	01893503          	ld	a0,24(s2)
    80003de0:	fffff097          	auipc	ra,0xfffff
    80003de4:	266080e7          	jalr	614(ra) # 80003046 <writei>
    80003de8:	84aa                	mv	s1,a0
    80003dea:	00a05763          	blez	a0,80003df8 <filewrite+0xc4>
        f->off += r;
    80003dee:	02092783          	lw	a5,32(s2)
    80003df2:	9fa9                	addw	a5,a5,a0
    80003df4:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80003df8:	01893503          	ld	a0,24(s2)
    80003dfc:	fffff097          	auipc	ra,0xfffff
    80003e00:	f60080e7          	jalr	-160(ra) # 80002d5c <iunlock>
      end_op();
    80003e04:	00000097          	auipc	ra,0x0
    80003e08:	8e8080e7          	jalr	-1816(ra) # 800036ec <end_op>

      if(r != n1){
    80003e0c:	009c1f63          	bne	s8,s1,80003e2a <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80003e10:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80003e14:	0149db63          	bge	s3,s4,80003e2a <filewrite+0xf6>
      int n1 = n - i;
    80003e18:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80003e1c:	84be                	mv	s1,a5
    80003e1e:	2781                	sext.w	a5,a5
    80003e20:	f8fb5ce3          	bge	s6,a5,80003db8 <filewrite+0x84>
    80003e24:	84de                	mv	s1,s7
    80003e26:	bf49                	j	80003db8 <filewrite+0x84>
    int i = 0;
    80003e28:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80003e2a:	013a1f63          	bne	s4,s3,80003e48 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80003e2e:	8552                	mv	a0,s4
    80003e30:	60a6                	ld	ra,72(sp)
    80003e32:	6406                	ld	s0,64(sp)
    80003e34:	74e2                	ld	s1,56(sp)
    80003e36:	7942                	ld	s2,48(sp)
    80003e38:	79a2                	ld	s3,40(sp)
    80003e3a:	7a02                	ld	s4,32(sp)
    80003e3c:	6ae2                	ld	s5,24(sp)
    80003e3e:	6b42                	ld	s6,16(sp)
    80003e40:	6ba2                	ld	s7,8(sp)
    80003e42:	6c02                	ld	s8,0(sp)
    80003e44:	6161                	addi	sp,sp,80
    80003e46:	8082                	ret
    ret = (i == n ? n : -1);
    80003e48:	5a7d                	li	s4,-1
    80003e4a:	b7d5                	j	80003e2e <filewrite+0xfa>
    panic("filewrite");
    80003e4c:	00004517          	auipc	a0,0x4
    80003e50:	7f450513          	addi	a0,a0,2036 # 80008640 <syscalls+0x270>
    80003e54:	00002097          	auipc	ra,0x2
    80003e58:	238080e7          	jalr	568(ra) # 8000608c <panic>
    return -1;
    80003e5c:	5a7d                	li	s4,-1
    80003e5e:	bfc1                	j	80003e2e <filewrite+0xfa>
      return -1;
    80003e60:	5a7d                	li	s4,-1
    80003e62:	b7f1                	j	80003e2e <filewrite+0xfa>
    80003e64:	5a7d                	li	s4,-1
    80003e66:	b7e1                	j	80003e2e <filewrite+0xfa>

0000000080003e68 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80003e68:	7179                	addi	sp,sp,-48
    80003e6a:	f406                	sd	ra,40(sp)
    80003e6c:	f022                	sd	s0,32(sp)
    80003e6e:	ec26                	sd	s1,24(sp)
    80003e70:	e84a                	sd	s2,16(sp)
    80003e72:	e44e                	sd	s3,8(sp)
    80003e74:	e052                	sd	s4,0(sp)
    80003e76:	1800                	addi	s0,sp,48
    80003e78:	84aa                	mv	s1,a0
    80003e7a:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80003e7c:	0005b023          	sd	zero,0(a1)
    80003e80:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80003e84:	00000097          	auipc	ra,0x0
    80003e88:	bf8080e7          	jalr	-1032(ra) # 80003a7c <filealloc>
    80003e8c:	e088                	sd	a0,0(s1)
    80003e8e:	c551                	beqz	a0,80003f1a <pipealloc+0xb2>
    80003e90:	00000097          	auipc	ra,0x0
    80003e94:	bec080e7          	jalr	-1044(ra) # 80003a7c <filealloc>
    80003e98:	00aa3023          	sd	a0,0(s4)
    80003e9c:	c92d                	beqz	a0,80003f0e <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80003e9e:	ffffc097          	auipc	ra,0xffffc
    80003ea2:	2e2080e7          	jalr	738(ra) # 80000180 <kalloc>
    80003ea6:	892a                	mv	s2,a0
    80003ea8:	c125                	beqz	a0,80003f08 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80003eaa:	4985                	li	s3,1
    80003eac:	23352423          	sw	s3,552(a0)
  pi->writeopen = 1;
    80003eb0:	23352623          	sw	s3,556(a0)
  pi->nwrite = 0;
    80003eb4:	22052223          	sw	zero,548(a0)
  pi->nread = 0;
    80003eb8:	22052023          	sw	zero,544(a0)
  initlock(&pi->lock, "pipe");
    80003ebc:	00004597          	auipc	a1,0x4
    80003ec0:	79458593          	addi	a1,a1,1940 # 80008650 <syscalls+0x280>
    80003ec4:	00003097          	auipc	ra,0x3
    80003ec8:	878080e7          	jalr	-1928(ra) # 8000673c <initlock>
  (*f0)->type = FD_PIPE;
    80003ecc:	609c                	ld	a5,0(s1)
    80003ece:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80003ed2:	609c                	ld	a5,0(s1)
    80003ed4:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80003ed8:	609c                	ld	a5,0(s1)
    80003eda:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80003ede:	609c                	ld	a5,0(s1)
    80003ee0:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80003ee4:	000a3783          	ld	a5,0(s4)
    80003ee8:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80003eec:	000a3783          	ld	a5,0(s4)
    80003ef0:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80003ef4:	000a3783          	ld	a5,0(s4)
    80003ef8:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80003efc:	000a3783          	ld	a5,0(s4)
    80003f00:	0127b823          	sd	s2,16(a5)
  return 0;
    80003f04:	4501                	li	a0,0
    80003f06:	a025                	j	80003f2e <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80003f08:	6088                	ld	a0,0(s1)
    80003f0a:	e501                	bnez	a0,80003f12 <pipealloc+0xaa>
    80003f0c:	a039                	j	80003f1a <pipealloc+0xb2>
    80003f0e:	6088                	ld	a0,0(s1)
    80003f10:	c51d                	beqz	a0,80003f3e <pipealloc+0xd6>
    fileclose(*f0);
    80003f12:	00000097          	auipc	ra,0x0
    80003f16:	c26080e7          	jalr	-986(ra) # 80003b38 <fileclose>
  if(*f1)
    80003f1a:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80003f1e:	557d                	li	a0,-1
  if(*f1)
    80003f20:	c799                	beqz	a5,80003f2e <pipealloc+0xc6>
    fileclose(*f1);
    80003f22:	853e                	mv	a0,a5
    80003f24:	00000097          	auipc	ra,0x0
    80003f28:	c14080e7          	jalr	-1004(ra) # 80003b38 <fileclose>
  return -1;
    80003f2c:	557d                	li	a0,-1
}
    80003f2e:	70a2                	ld	ra,40(sp)
    80003f30:	7402                	ld	s0,32(sp)
    80003f32:	64e2                	ld	s1,24(sp)
    80003f34:	6942                	ld	s2,16(sp)
    80003f36:	69a2                	ld	s3,8(sp)
    80003f38:	6a02                	ld	s4,0(sp)
    80003f3a:	6145                	addi	sp,sp,48
    80003f3c:	8082                	ret
  return -1;
    80003f3e:	557d                	li	a0,-1
    80003f40:	b7fd                	j	80003f2e <pipealloc+0xc6>

0000000080003f42 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80003f42:	1101                	addi	sp,sp,-32
    80003f44:	ec06                	sd	ra,24(sp)
    80003f46:	e822                	sd	s0,16(sp)
    80003f48:	e426                	sd	s1,8(sp)
    80003f4a:	e04a                	sd	s2,0(sp)
    80003f4c:	1000                	addi	s0,sp,32
    80003f4e:	84aa                	mv	s1,a0
    80003f50:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80003f52:	00002097          	auipc	ra,0x2
    80003f56:	66e080e7          	jalr	1646(ra) # 800065c0 <acquire>
  if(writable){
    80003f5a:	04090263          	beqz	s2,80003f9e <pipeclose+0x5c>
    pi->writeopen = 0;
    80003f5e:	2204a623          	sw	zero,556(s1)
    wakeup(&pi->nread);
    80003f62:	22048513          	addi	a0,s1,544
    80003f66:	ffffe097          	auipc	ra,0xffffe
    80003f6a:	886080e7          	jalr	-1914(ra) # 800017ec <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80003f6e:	2284b783          	ld	a5,552(s1)
    80003f72:	ef9d                	bnez	a5,80003fb0 <pipeclose+0x6e>
    release(&pi->lock);
    80003f74:	8526                	mv	a0,s1
    80003f76:	00002097          	auipc	ra,0x2
    80003f7a:	71a080e7          	jalr	1818(ra) # 80006690 <release>
#ifdef LAB_LOCK
    freelock(&pi->lock);
    80003f7e:	8526                	mv	a0,s1
    80003f80:	00002097          	auipc	ra,0x2
    80003f84:	758080e7          	jalr	1880(ra) # 800066d8 <freelock>
#endif    
    kfree((char*)pi);
    80003f88:	8526                	mv	a0,s1
    80003f8a:	ffffc097          	auipc	ra,0xffffc
    80003f8e:	092080e7          	jalr	146(ra) # 8000001c <kfree>
  } else
    release(&pi->lock);
}
    80003f92:	60e2                	ld	ra,24(sp)
    80003f94:	6442                	ld	s0,16(sp)
    80003f96:	64a2                	ld	s1,8(sp)
    80003f98:	6902                	ld	s2,0(sp)
    80003f9a:	6105                	addi	sp,sp,32
    80003f9c:	8082                	ret
    pi->readopen = 0;
    80003f9e:	2204a423          	sw	zero,552(s1)
    wakeup(&pi->nwrite);
    80003fa2:	22448513          	addi	a0,s1,548
    80003fa6:	ffffe097          	auipc	ra,0xffffe
    80003faa:	846080e7          	jalr	-1978(ra) # 800017ec <wakeup>
    80003fae:	b7c1                	j	80003f6e <pipeclose+0x2c>
    release(&pi->lock);
    80003fb0:	8526                	mv	a0,s1
    80003fb2:	00002097          	auipc	ra,0x2
    80003fb6:	6de080e7          	jalr	1758(ra) # 80006690 <release>
}
    80003fba:	bfe1                	j	80003f92 <pipeclose+0x50>

0000000080003fbc <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80003fbc:	7159                	addi	sp,sp,-112
    80003fbe:	f486                	sd	ra,104(sp)
    80003fc0:	f0a2                	sd	s0,96(sp)
    80003fc2:	eca6                	sd	s1,88(sp)
    80003fc4:	e8ca                	sd	s2,80(sp)
    80003fc6:	e4ce                	sd	s3,72(sp)
    80003fc8:	e0d2                	sd	s4,64(sp)
    80003fca:	fc56                	sd	s5,56(sp)
    80003fcc:	f85a                	sd	s6,48(sp)
    80003fce:	f45e                	sd	s7,40(sp)
    80003fd0:	f062                	sd	s8,32(sp)
    80003fd2:	ec66                	sd	s9,24(sp)
    80003fd4:	1880                	addi	s0,sp,112
    80003fd6:	84aa                	mv	s1,a0
    80003fd8:	8aae                	mv	s5,a1
    80003fda:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80003fdc:	ffffd097          	auipc	ra,0xffffd
    80003fe0:	fc8080e7          	jalr	-56(ra) # 80000fa4 <myproc>
    80003fe4:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80003fe6:	8526                	mv	a0,s1
    80003fe8:	00002097          	auipc	ra,0x2
    80003fec:	5d8080e7          	jalr	1496(ra) # 800065c0 <acquire>
  while(i < n){
    80003ff0:	0d405163          	blez	s4,800040b2 <pipewrite+0xf6>
    80003ff4:	8ba6                	mv	s7,s1
  int i = 0;
    80003ff6:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003ff8:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80003ffa:	22048c93          	addi	s9,s1,544
      sleep(&pi->nwrite, &pi->lock);
    80003ffe:	22448c13          	addi	s8,s1,548
    80004002:	a08d                	j	80004064 <pipewrite+0xa8>
      release(&pi->lock);
    80004004:	8526                	mv	a0,s1
    80004006:	00002097          	auipc	ra,0x2
    8000400a:	68a080e7          	jalr	1674(ra) # 80006690 <release>
      return -1;
    8000400e:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004010:	854a                	mv	a0,s2
    80004012:	70a6                	ld	ra,104(sp)
    80004014:	7406                	ld	s0,96(sp)
    80004016:	64e6                	ld	s1,88(sp)
    80004018:	6946                	ld	s2,80(sp)
    8000401a:	69a6                	ld	s3,72(sp)
    8000401c:	6a06                	ld	s4,64(sp)
    8000401e:	7ae2                	ld	s5,56(sp)
    80004020:	7b42                	ld	s6,48(sp)
    80004022:	7ba2                	ld	s7,40(sp)
    80004024:	7c02                	ld	s8,32(sp)
    80004026:	6ce2                	ld	s9,24(sp)
    80004028:	6165                	addi	sp,sp,112
    8000402a:	8082                	ret
      wakeup(&pi->nread);
    8000402c:	8566                	mv	a0,s9
    8000402e:	ffffd097          	auipc	ra,0xffffd
    80004032:	7be080e7          	jalr	1982(ra) # 800017ec <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004036:	85de                	mv	a1,s7
    80004038:	8562                	mv	a0,s8
    8000403a:	ffffd097          	auipc	ra,0xffffd
    8000403e:	626080e7          	jalr	1574(ra) # 80001660 <sleep>
    80004042:	a839                	j	80004060 <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004044:	2244a783          	lw	a5,548(s1)
    80004048:	0017871b          	addiw	a4,a5,1
    8000404c:	22e4a223          	sw	a4,548(s1)
    80004050:	1ff7f793          	andi	a5,a5,511
    80004054:	97a6                	add	a5,a5,s1
    80004056:	f9f44703          	lbu	a4,-97(s0)
    8000405a:	02e78023          	sb	a4,32(a5)
      i++;
    8000405e:	2905                	addiw	s2,s2,1
  while(i < n){
    80004060:	03495d63          	bge	s2,s4,8000409a <pipewrite+0xde>
    if(pi->readopen == 0 || pr->killed){
    80004064:	2284a783          	lw	a5,552(s1)
    80004068:	dfd1                	beqz	a5,80004004 <pipewrite+0x48>
    8000406a:	0309a783          	lw	a5,48(s3)
    8000406e:	fbd9                	bnez	a5,80004004 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004070:	2204a783          	lw	a5,544(s1)
    80004074:	2244a703          	lw	a4,548(s1)
    80004078:	2007879b          	addiw	a5,a5,512
    8000407c:	faf708e3          	beq	a4,a5,8000402c <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004080:	4685                	li	a3,1
    80004082:	01590633          	add	a2,s2,s5
    80004086:	f9f40593          	addi	a1,s0,-97
    8000408a:	0589b503          	ld	a0,88(s3)
    8000408e:	ffffd097          	auipc	ra,0xffffd
    80004092:	c64080e7          	jalr	-924(ra) # 80000cf2 <copyin>
    80004096:	fb6517e3          	bne	a0,s6,80004044 <pipewrite+0x88>
  wakeup(&pi->nread);
    8000409a:	22048513          	addi	a0,s1,544
    8000409e:	ffffd097          	auipc	ra,0xffffd
    800040a2:	74e080e7          	jalr	1870(ra) # 800017ec <wakeup>
  release(&pi->lock);
    800040a6:	8526                	mv	a0,s1
    800040a8:	00002097          	auipc	ra,0x2
    800040ac:	5e8080e7          	jalr	1512(ra) # 80006690 <release>
  return i;
    800040b0:	b785                	j	80004010 <pipewrite+0x54>
  int i = 0;
    800040b2:	4901                	li	s2,0
    800040b4:	b7dd                	j	8000409a <pipewrite+0xde>

00000000800040b6 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800040b6:	715d                	addi	sp,sp,-80
    800040b8:	e486                	sd	ra,72(sp)
    800040ba:	e0a2                	sd	s0,64(sp)
    800040bc:	fc26                	sd	s1,56(sp)
    800040be:	f84a                	sd	s2,48(sp)
    800040c0:	f44e                	sd	s3,40(sp)
    800040c2:	f052                	sd	s4,32(sp)
    800040c4:	ec56                	sd	s5,24(sp)
    800040c6:	e85a                	sd	s6,16(sp)
    800040c8:	0880                	addi	s0,sp,80
    800040ca:	84aa                	mv	s1,a0
    800040cc:	892e                	mv	s2,a1
    800040ce:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800040d0:	ffffd097          	auipc	ra,0xffffd
    800040d4:	ed4080e7          	jalr	-300(ra) # 80000fa4 <myproc>
    800040d8:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800040da:	8b26                	mv	s6,s1
    800040dc:	8526                	mv	a0,s1
    800040de:	00002097          	auipc	ra,0x2
    800040e2:	4e2080e7          	jalr	1250(ra) # 800065c0 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800040e6:	2204a703          	lw	a4,544(s1)
    800040ea:	2244a783          	lw	a5,548(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800040ee:	22048993          	addi	s3,s1,544
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800040f2:	02f71463          	bne	a4,a5,8000411a <piperead+0x64>
    800040f6:	22c4a783          	lw	a5,556(s1)
    800040fa:	c385                	beqz	a5,8000411a <piperead+0x64>
    if(pr->killed){
    800040fc:	030a2783          	lw	a5,48(s4)
    80004100:	ebc1                	bnez	a5,80004190 <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004102:	85da                	mv	a1,s6
    80004104:	854e                	mv	a0,s3
    80004106:	ffffd097          	auipc	ra,0xffffd
    8000410a:	55a080e7          	jalr	1370(ra) # 80001660 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000410e:	2204a703          	lw	a4,544(s1)
    80004112:	2244a783          	lw	a5,548(s1)
    80004116:	fef700e3          	beq	a4,a5,800040f6 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000411a:	09505263          	blez	s5,8000419e <piperead+0xe8>
    8000411e:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004120:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80004122:	2204a783          	lw	a5,544(s1)
    80004126:	2244a703          	lw	a4,548(s1)
    8000412a:	02f70d63          	beq	a4,a5,80004164 <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    8000412e:	0017871b          	addiw	a4,a5,1
    80004132:	22e4a023          	sw	a4,544(s1)
    80004136:	1ff7f793          	andi	a5,a5,511
    8000413a:	97a6                	add	a5,a5,s1
    8000413c:	0207c783          	lbu	a5,32(a5)
    80004140:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004144:	4685                	li	a3,1
    80004146:	fbf40613          	addi	a2,s0,-65
    8000414a:	85ca                	mv	a1,s2
    8000414c:	058a3503          	ld	a0,88(s4)
    80004150:	ffffd097          	auipc	ra,0xffffd
    80004154:	b16080e7          	jalr	-1258(ra) # 80000c66 <copyout>
    80004158:	01650663          	beq	a0,s6,80004164 <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000415c:	2985                	addiw	s3,s3,1
    8000415e:	0905                	addi	s2,s2,1
    80004160:	fd3a91e3          	bne	s5,s3,80004122 <piperead+0x6c>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004164:	22448513          	addi	a0,s1,548
    80004168:	ffffd097          	auipc	ra,0xffffd
    8000416c:	684080e7          	jalr	1668(ra) # 800017ec <wakeup>
  release(&pi->lock);
    80004170:	8526                	mv	a0,s1
    80004172:	00002097          	auipc	ra,0x2
    80004176:	51e080e7          	jalr	1310(ra) # 80006690 <release>
  return i;
}
    8000417a:	854e                	mv	a0,s3
    8000417c:	60a6                	ld	ra,72(sp)
    8000417e:	6406                	ld	s0,64(sp)
    80004180:	74e2                	ld	s1,56(sp)
    80004182:	7942                	ld	s2,48(sp)
    80004184:	79a2                	ld	s3,40(sp)
    80004186:	7a02                	ld	s4,32(sp)
    80004188:	6ae2                	ld	s5,24(sp)
    8000418a:	6b42                	ld	s6,16(sp)
    8000418c:	6161                	addi	sp,sp,80
    8000418e:	8082                	ret
      release(&pi->lock);
    80004190:	8526                	mv	a0,s1
    80004192:	00002097          	auipc	ra,0x2
    80004196:	4fe080e7          	jalr	1278(ra) # 80006690 <release>
      return -1;
    8000419a:	59fd                	li	s3,-1
    8000419c:	bff9                	j	8000417a <piperead+0xc4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000419e:	4981                	li	s3,0
    800041a0:	b7d1                	j	80004164 <piperead+0xae>

00000000800041a2 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    800041a2:	df010113          	addi	sp,sp,-528
    800041a6:	20113423          	sd	ra,520(sp)
    800041aa:	20813023          	sd	s0,512(sp)
    800041ae:	ffa6                	sd	s1,504(sp)
    800041b0:	fbca                	sd	s2,496(sp)
    800041b2:	f7ce                	sd	s3,488(sp)
    800041b4:	f3d2                	sd	s4,480(sp)
    800041b6:	efd6                	sd	s5,472(sp)
    800041b8:	ebda                	sd	s6,464(sp)
    800041ba:	e7de                	sd	s7,456(sp)
    800041bc:	e3e2                	sd	s8,448(sp)
    800041be:	ff66                	sd	s9,440(sp)
    800041c0:	fb6a                	sd	s10,432(sp)
    800041c2:	f76e                	sd	s11,424(sp)
    800041c4:	0c00                	addi	s0,sp,528
    800041c6:	84aa                	mv	s1,a0
    800041c8:	dea43c23          	sd	a0,-520(s0)
    800041cc:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800041d0:	ffffd097          	auipc	ra,0xffffd
    800041d4:	dd4080e7          	jalr	-556(ra) # 80000fa4 <myproc>
    800041d8:	892a                	mv	s2,a0

  begin_op();
    800041da:	fffff097          	auipc	ra,0xfffff
    800041de:	492080e7          	jalr	1170(ra) # 8000366c <begin_op>

  if((ip = namei(path)) == 0){
    800041e2:	8526                	mv	a0,s1
    800041e4:	fffff097          	auipc	ra,0xfffff
    800041e8:	26c080e7          	jalr	620(ra) # 80003450 <namei>
    800041ec:	c92d                	beqz	a0,8000425e <exec+0xbc>
    800041ee:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800041f0:	fffff097          	auipc	ra,0xfffff
    800041f4:	aaa080e7          	jalr	-1366(ra) # 80002c9a <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800041f8:	04000713          	li	a4,64
    800041fc:	4681                	li	a3,0
    800041fe:	e5040613          	addi	a2,s0,-432
    80004202:	4581                	li	a1,0
    80004204:	8526                	mv	a0,s1
    80004206:	fffff097          	auipc	ra,0xfffff
    8000420a:	d48080e7          	jalr	-696(ra) # 80002f4e <readi>
    8000420e:	04000793          	li	a5,64
    80004212:	00f51a63          	bne	a0,a5,80004226 <exec+0x84>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004216:	e5042703          	lw	a4,-432(s0)
    8000421a:	464c47b7          	lui	a5,0x464c4
    8000421e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004222:	04f70463          	beq	a4,a5,8000426a <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004226:	8526                	mv	a0,s1
    80004228:	fffff097          	auipc	ra,0xfffff
    8000422c:	cd4080e7          	jalr	-812(ra) # 80002efc <iunlockput>
    end_op();
    80004230:	fffff097          	auipc	ra,0xfffff
    80004234:	4bc080e7          	jalr	1212(ra) # 800036ec <end_op>
  }
  return -1;
    80004238:	557d                	li	a0,-1
}
    8000423a:	20813083          	ld	ra,520(sp)
    8000423e:	20013403          	ld	s0,512(sp)
    80004242:	74fe                	ld	s1,504(sp)
    80004244:	795e                	ld	s2,496(sp)
    80004246:	79be                	ld	s3,488(sp)
    80004248:	7a1e                	ld	s4,480(sp)
    8000424a:	6afe                	ld	s5,472(sp)
    8000424c:	6b5e                	ld	s6,464(sp)
    8000424e:	6bbe                	ld	s7,456(sp)
    80004250:	6c1e                	ld	s8,448(sp)
    80004252:	7cfa                	ld	s9,440(sp)
    80004254:	7d5a                	ld	s10,432(sp)
    80004256:	7dba                	ld	s11,424(sp)
    80004258:	21010113          	addi	sp,sp,528
    8000425c:	8082                	ret
    end_op();
    8000425e:	fffff097          	auipc	ra,0xfffff
    80004262:	48e080e7          	jalr	1166(ra) # 800036ec <end_op>
    return -1;
    80004266:	557d                	li	a0,-1
    80004268:	bfc9                	j	8000423a <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    8000426a:	854a                	mv	a0,s2
    8000426c:	ffffd097          	auipc	ra,0xffffd
    80004270:	dfc080e7          	jalr	-516(ra) # 80001068 <proc_pagetable>
    80004274:	8baa                	mv	s7,a0
    80004276:	d945                	beqz	a0,80004226 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004278:	e7042983          	lw	s3,-400(s0)
    8000427c:	e8845783          	lhu	a5,-376(s0)
    80004280:	c7ad                	beqz	a5,800042ea <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004282:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004284:	4b01                	li	s6,0
    if((ph.vaddr % PGSIZE) != 0)
    80004286:	6c85                	lui	s9,0x1
    80004288:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    8000428c:	def43823          	sd	a5,-528(s0)
    80004290:	a42d                	j	800044ba <exec+0x318>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004292:	00004517          	auipc	a0,0x4
    80004296:	3c650513          	addi	a0,a0,966 # 80008658 <syscalls+0x288>
    8000429a:	00002097          	auipc	ra,0x2
    8000429e:	df2080e7          	jalr	-526(ra) # 8000608c <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800042a2:	8756                	mv	a4,s5
    800042a4:	012d86bb          	addw	a3,s11,s2
    800042a8:	4581                	li	a1,0
    800042aa:	8526                	mv	a0,s1
    800042ac:	fffff097          	auipc	ra,0xfffff
    800042b0:	ca2080e7          	jalr	-862(ra) # 80002f4e <readi>
    800042b4:	2501                	sext.w	a0,a0
    800042b6:	1aaa9963          	bne	s5,a0,80004468 <exec+0x2c6>
  for(i = 0; i < sz; i += PGSIZE){
    800042ba:	6785                	lui	a5,0x1
    800042bc:	0127893b          	addw	s2,a5,s2
    800042c0:	77fd                	lui	a5,0xfffff
    800042c2:	01478a3b          	addw	s4,a5,s4
    800042c6:	1f897163          	bgeu	s2,s8,800044a8 <exec+0x306>
    pa = walkaddr(pagetable, va + i);
    800042ca:	02091593          	slli	a1,s2,0x20
    800042ce:	9181                	srli	a1,a1,0x20
    800042d0:	95ea                	add	a1,a1,s10
    800042d2:	855e                	mv	a0,s7
    800042d4:	ffffc097          	auipc	ra,0xffffc
    800042d8:	38e080e7          	jalr	910(ra) # 80000662 <walkaddr>
    800042dc:	862a                	mv	a2,a0
    if(pa == 0)
    800042de:	d955                	beqz	a0,80004292 <exec+0xf0>
      n = PGSIZE;
    800042e0:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    800042e2:	fd9a70e3          	bgeu	s4,s9,800042a2 <exec+0x100>
      n = sz - i;
    800042e6:	8ad2                	mv	s5,s4
    800042e8:	bf6d                	j	800042a2 <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800042ea:	4901                	li	s2,0
  iunlockput(ip);
    800042ec:	8526                	mv	a0,s1
    800042ee:	fffff097          	auipc	ra,0xfffff
    800042f2:	c0e080e7          	jalr	-1010(ra) # 80002efc <iunlockput>
  end_op();
    800042f6:	fffff097          	auipc	ra,0xfffff
    800042fa:	3f6080e7          	jalr	1014(ra) # 800036ec <end_op>
  p = myproc();
    800042fe:	ffffd097          	auipc	ra,0xffffd
    80004302:	ca6080e7          	jalr	-858(ra) # 80000fa4 <myproc>
    80004306:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004308:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    8000430c:	6785                	lui	a5,0x1
    8000430e:	17fd                	addi	a5,a5,-1
    80004310:	993e                	add	s2,s2,a5
    80004312:	757d                	lui	a0,0xfffff
    80004314:	00a977b3          	and	a5,s2,a0
    80004318:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    8000431c:	6609                	lui	a2,0x2
    8000431e:	963e                	add	a2,a2,a5
    80004320:	85be                	mv	a1,a5
    80004322:	855e                	mv	a0,s7
    80004324:	ffffc097          	auipc	ra,0xffffc
    80004328:	6f2080e7          	jalr	1778(ra) # 80000a16 <uvmalloc>
    8000432c:	8b2a                	mv	s6,a0
  ip = 0;
    8000432e:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004330:	12050c63          	beqz	a0,80004468 <exec+0x2c6>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004334:	75f9                	lui	a1,0xffffe
    80004336:	95aa                	add	a1,a1,a0
    80004338:	855e                	mv	a0,s7
    8000433a:	ffffd097          	auipc	ra,0xffffd
    8000433e:	8fa080e7          	jalr	-1798(ra) # 80000c34 <uvmclear>
  stackbase = sp - PGSIZE;
    80004342:	7c7d                	lui	s8,0xfffff
    80004344:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    80004346:	e0043783          	ld	a5,-512(s0)
    8000434a:	6388                	ld	a0,0(a5)
    8000434c:	c535                	beqz	a0,800043b8 <exec+0x216>
    8000434e:	e9040993          	addi	s3,s0,-368
    80004352:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004356:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80004358:	ffffc097          	auipc	ra,0xffffc
    8000435c:	0f0080e7          	jalr	240(ra) # 80000448 <strlen>
    80004360:	2505                	addiw	a0,a0,1
    80004362:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004366:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    8000436a:	13896363          	bltu	s2,s8,80004490 <exec+0x2ee>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000436e:	e0043d83          	ld	s11,-512(s0)
    80004372:	000dba03          	ld	s4,0(s11)
    80004376:	8552                	mv	a0,s4
    80004378:	ffffc097          	auipc	ra,0xffffc
    8000437c:	0d0080e7          	jalr	208(ra) # 80000448 <strlen>
    80004380:	0015069b          	addiw	a3,a0,1
    80004384:	8652                	mv	a2,s4
    80004386:	85ca                	mv	a1,s2
    80004388:	855e                	mv	a0,s7
    8000438a:	ffffd097          	auipc	ra,0xffffd
    8000438e:	8dc080e7          	jalr	-1828(ra) # 80000c66 <copyout>
    80004392:	10054363          	bltz	a0,80004498 <exec+0x2f6>
    ustack[argc] = sp;
    80004396:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    8000439a:	0485                	addi	s1,s1,1
    8000439c:	008d8793          	addi	a5,s11,8
    800043a0:	e0f43023          	sd	a5,-512(s0)
    800043a4:	008db503          	ld	a0,8(s11)
    800043a8:	c911                	beqz	a0,800043bc <exec+0x21a>
    if(argc >= MAXARG)
    800043aa:	09a1                	addi	s3,s3,8
    800043ac:	fb3c96e3          	bne	s9,s3,80004358 <exec+0x1b6>
  sz = sz1;
    800043b0:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800043b4:	4481                	li	s1,0
    800043b6:	a84d                	j	80004468 <exec+0x2c6>
  sp = sz;
    800043b8:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    800043ba:	4481                	li	s1,0
  ustack[argc] = 0;
    800043bc:	00349793          	slli	a5,s1,0x3
    800043c0:	f9040713          	addi	a4,s0,-112
    800043c4:	97ba                	add	a5,a5,a4
    800043c6:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    800043ca:	00148693          	addi	a3,s1,1
    800043ce:	068e                	slli	a3,a3,0x3
    800043d0:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800043d4:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800043d8:	01897663          	bgeu	s2,s8,800043e4 <exec+0x242>
  sz = sz1;
    800043dc:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800043e0:	4481                	li	s1,0
    800043e2:	a059                	j	80004468 <exec+0x2c6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800043e4:	e9040613          	addi	a2,s0,-368
    800043e8:	85ca                	mv	a1,s2
    800043ea:	855e                	mv	a0,s7
    800043ec:	ffffd097          	auipc	ra,0xffffd
    800043f0:	87a080e7          	jalr	-1926(ra) # 80000c66 <copyout>
    800043f4:	0a054663          	bltz	a0,800044a0 <exec+0x2fe>
  p->trapframe->a1 = sp;
    800043f8:	060ab783          	ld	a5,96(s5)
    800043fc:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004400:	df843783          	ld	a5,-520(s0)
    80004404:	0007c703          	lbu	a4,0(a5)
    80004408:	cf11                	beqz	a4,80004424 <exec+0x282>
    8000440a:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000440c:	02f00693          	li	a3,47
    80004410:	a039                	j	8000441e <exec+0x27c>
      last = s+1;
    80004412:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004416:	0785                	addi	a5,a5,1
    80004418:	fff7c703          	lbu	a4,-1(a5)
    8000441c:	c701                	beqz	a4,80004424 <exec+0x282>
    if(*s == '/')
    8000441e:	fed71ce3          	bne	a4,a3,80004416 <exec+0x274>
    80004422:	bfc5                	j	80004412 <exec+0x270>
  safestrcpy(p->name, last, sizeof(p->name));
    80004424:	4641                	li	a2,16
    80004426:	df843583          	ld	a1,-520(s0)
    8000442a:	160a8513          	addi	a0,s5,352
    8000442e:	ffffc097          	auipc	ra,0xffffc
    80004432:	fe8080e7          	jalr	-24(ra) # 80000416 <safestrcpy>
  oldpagetable = p->pagetable;
    80004436:	058ab503          	ld	a0,88(s5)
  p->pagetable = pagetable;
    8000443a:	057abc23          	sd	s7,88(s5)
  p->sz = sz;
    8000443e:	056ab823          	sd	s6,80(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004442:	060ab783          	ld	a5,96(s5)
    80004446:	e6843703          	ld	a4,-408(s0)
    8000444a:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000444c:	060ab783          	ld	a5,96(s5)
    80004450:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004454:	85ea                	mv	a1,s10
    80004456:	ffffd097          	auipc	ra,0xffffd
    8000445a:	cae080e7          	jalr	-850(ra) # 80001104 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000445e:	0004851b          	sext.w	a0,s1
    80004462:	bbe1                	j	8000423a <exec+0x98>
    80004464:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    80004468:	e0843583          	ld	a1,-504(s0)
    8000446c:	855e                	mv	a0,s7
    8000446e:	ffffd097          	auipc	ra,0xffffd
    80004472:	c96080e7          	jalr	-874(ra) # 80001104 <proc_freepagetable>
  if(ip){
    80004476:	da0498e3          	bnez	s1,80004226 <exec+0x84>
  return -1;
    8000447a:	557d                	li	a0,-1
    8000447c:	bb7d                	j	8000423a <exec+0x98>
    8000447e:	e1243423          	sd	s2,-504(s0)
    80004482:	b7dd                	j	80004468 <exec+0x2c6>
    80004484:	e1243423          	sd	s2,-504(s0)
    80004488:	b7c5                	j	80004468 <exec+0x2c6>
    8000448a:	e1243423          	sd	s2,-504(s0)
    8000448e:	bfe9                	j	80004468 <exec+0x2c6>
  sz = sz1;
    80004490:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004494:	4481                	li	s1,0
    80004496:	bfc9                	j	80004468 <exec+0x2c6>
  sz = sz1;
    80004498:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000449c:	4481                	li	s1,0
    8000449e:	b7e9                	j	80004468 <exec+0x2c6>
  sz = sz1;
    800044a0:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800044a4:	4481                	li	s1,0
    800044a6:	b7c9                	j	80004468 <exec+0x2c6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800044a8:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800044ac:	2b05                	addiw	s6,s6,1
    800044ae:	0389899b          	addiw	s3,s3,56
    800044b2:	e8845783          	lhu	a5,-376(s0)
    800044b6:	e2fb5be3          	bge	s6,a5,800042ec <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800044ba:	2981                	sext.w	s3,s3
    800044bc:	03800713          	li	a4,56
    800044c0:	86ce                	mv	a3,s3
    800044c2:	e1840613          	addi	a2,s0,-488
    800044c6:	4581                	li	a1,0
    800044c8:	8526                	mv	a0,s1
    800044ca:	fffff097          	auipc	ra,0xfffff
    800044ce:	a84080e7          	jalr	-1404(ra) # 80002f4e <readi>
    800044d2:	03800793          	li	a5,56
    800044d6:	f8f517e3          	bne	a0,a5,80004464 <exec+0x2c2>
    if(ph.type != ELF_PROG_LOAD)
    800044da:	e1842783          	lw	a5,-488(s0)
    800044de:	4705                	li	a4,1
    800044e0:	fce796e3          	bne	a5,a4,800044ac <exec+0x30a>
    if(ph.memsz < ph.filesz)
    800044e4:	e4043603          	ld	a2,-448(s0)
    800044e8:	e3843783          	ld	a5,-456(s0)
    800044ec:	f8f669e3          	bltu	a2,a5,8000447e <exec+0x2dc>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800044f0:	e2843783          	ld	a5,-472(s0)
    800044f4:	963e                	add	a2,a2,a5
    800044f6:	f8f667e3          	bltu	a2,a5,80004484 <exec+0x2e2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800044fa:	85ca                	mv	a1,s2
    800044fc:	855e                	mv	a0,s7
    800044fe:	ffffc097          	auipc	ra,0xffffc
    80004502:	518080e7          	jalr	1304(ra) # 80000a16 <uvmalloc>
    80004506:	e0a43423          	sd	a0,-504(s0)
    8000450a:	d141                	beqz	a0,8000448a <exec+0x2e8>
    if((ph.vaddr % PGSIZE) != 0)
    8000450c:	e2843d03          	ld	s10,-472(s0)
    80004510:	df043783          	ld	a5,-528(s0)
    80004514:	00fd77b3          	and	a5,s10,a5
    80004518:	fba1                	bnez	a5,80004468 <exec+0x2c6>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000451a:	e2042d83          	lw	s11,-480(s0)
    8000451e:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004522:	f80c03e3          	beqz	s8,800044a8 <exec+0x306>
    80004526:	8a62                	mv	s4,s8
    80004528:	4901                	li	s2,0
    8000452a:	b345                	j	800042ca <exec+0x128>

000000008000452c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000452c:	7179                	addi	sp,sp,-48
    8000452e:	f406                	sd	ra,40(sp)
    80004530:	f022                	sd	s0,32(sp)
    80004532:	ec26                	sd	s1,24(sp)
    80004534:	e84a                	sd	s2,16(sp)
    80004536:	1800                	addi	s0,sp,48
    80004538:	892e                	mv	s2,a1
    8000453a:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    8000453c:	fdc40593          	addi	a1,s0,-36
    80004540:	ffffe097          	auipc	ra,0xffffe
    80004544:	b10080e7          	jalr	-1264(ra) # 80002050 <argint>
    80004548:	04054063          	bltz	a0,80004588 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000454c:	fdc42703          	lw	a4,-36(s0)
    80004550:	47bd                	li	a5,15
    80004552:	02e7ed63          	bltu	a5,a4,8000458c <argfd+0x60>
    80004556:	ffffd097          	auipc	ra,0xffffd
    8000455a:	a4e080e7          	jalr	-1458(ra) # 80000fa4 <myproc>
    8000455e:	fdc42703          	lw	a4,-36(s0)
    80004562:	01a70793          	addi	a5,a4,26
    80004566:	078e                	slli	a5,a5,0x3
    80004568:	953e                	add	a0,a0,a5
    8000456a:	651c                	ld	a5,8(a0)
    8000456c:	c395                	beqz	a5,80004590 <argfd+0x64>
    return -1;
  if(pfd)
    8000456e:	00090463          	beqz	s2,80004576 <argfd+0x4a>
    *pfd = fd;
    80004572:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004576:	4501                	li	a0,0
  if(pf)
    80004578:	c091                	beqz	s1,8000457c <argfd+0x50>
    *pf = f;
    8000457a:	e09c                	sd	a5,0(s1)
}
    8000457c:	70a2                	ld	ra,40(sp)
    8000457e:	7402                	ld	s0,32(sp)
    80004580:	64e2                	ld	s1,24(sp)
    80004582:	6942                	ld	s2,16(sp)
    80004584:	6145                	addi	sp,sp,48
    80004586:	8082                	ret
    return -1;
    80004588:	557d                	li	a0,-1
    8000458a:	bfcd                	j	8000457c <argfd+0x50>
    return -1;
    8000458c:	557d                	li	a0,-1
    8000458e:	b7fd                	j	8000457c <argfd+0x50>
    80004590:	557d                	li	a0,-1
    80004592:	b7ed                	j	8000457c <argfd+0x50>

0000000080004594 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004594:	1101                	addi	sp,sp,-32
    80004596:	ec06                	sd	ra,24(sp)
    80004598:	e822                	sd	s0,16(sp)
    8000459a:	e426                	sd	s1,8(sp)
    8000459c:	1000                	addi	s0,sp,32
    8000459e:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800045a0:	ffffd097          	auipc	ra,0xffffd
    800045a4:	a04080e7          	jalr	-1532(ra) # 80000fa4 <myproc>
    800045a8:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800045aa:	0d850793          	addi	a5,a0,216 # fffffffffffff0d8 <end+0xffffffff7ffd3e90>
    800045ae:	4501                	li	a0,0
    800045b0:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800045b2:	6398                	ld	a4,0(a5)
    800045b4:	cb19                	beqz	a4,800045ca <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800045b6:	2505                	addiw	a0,a0,1
    800045b8:	07a1                	addi	a5,a5,8
    800045ba:	fed51ce3          	bne	a0,a3,800045b2 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800045be:	557d                	li	a0,-1
}
    800045c0:	60e2                	ld	ra,24(sp)
    800045c2:	6442                	ld	s0,16(sp)
    800045c4:	64a2                	ld	s1,8(sp)
    800045c6:	6105                	addi	sp,sp,32
    800045c8:	8082                	ret
      p->ofile[fd] = f;
    800045ca:	01a50793          	addi	a5,a0,26
    800045ce:	078e                	slli	a5,a5,0x3
    800045d0:	963e                	add	a2,a2,a5
    800045d2:	e604                	sd	s1,8(a2)
      return fd;
    800045d4:	b7f5                	j	800045c0 <fdalloc+0x2c>

00000000800045d6 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800045d6:	715d                	addi	sp,sp,-80
    800045d8:	e486                	sd	ra,72(sp)
    800045da:	e0a2                	sd	s0,64(sp)
    800045dc:	fc26                	sd	s1,56(sp)
    800045de:	f84a                	sd	s2,48(sp)
    800045e0:	f44e                	sd	s3,40(sp)
    800045e2:	f052                	sd	s4,32(sp)
    800045e4:	ec56                	sd	s5,24(sp)
    800045e6:	0880                	addi	s0,sp,80
    800045e8:	89ae                	mv	s3,a1
    800045ea:	8ab2                	mv	s5,a2
    800045ec:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800045ee:	fb040593          	addi	a1,s0,-80
    800045f2:	fffff097          	auipc	ra,0xfffff
    800045f6:	e7c080e7          	jalr	-388(ra) # 8000346e <nameiparent>
    800045fa:	892a                	mv	s2,a0
    800045fc:	12050f63          	beqz	a0,8000473a <create+0x164>
    return 0;

  ilock(dp);
    80004600:	ffffe097          	auipc	ra,0xffffe
    80004604:	69a080e7          	jalr	1690(ra) # 80002c9a <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004608:	4601                	li	a2,0
    8000460a:	fb040593          	addi	a1,s0,-80
    8000460e:	854a                	mv	a0,s2
    80004610:	fffff097          	auipc	ra,0xfffff
    80004614:	b6e080e7          	jalr	-1170(ra) # 8000317e <dirlookup>
    80004618:	84aa                	mv	s1,a0
    8000461a:	c921                	beqz	a0,8000466a <create+0x94>
    iunlockput(dp);
    8000461c:	854a                	mv	a0,s2
    8000461e:	fffff097          	auipc	ra,0xfffff
    80004622:	8de080e7          	jalr	-1826(ra) # 80002efc <iunlockput>
    ilock(ip);
    80004626:	8526                	mv	a0,s1
    80004628:	ffffe097          	auipc	ra,0xffffe
    8000462c:	672080e7          	jalr	1650(ra) # 80002c9a <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004630:	2981                	sext.w	s3,s3
    80004632:	4789                	li	a5,2
    80004634:	02f99463          	bne	s3,a5,8000465c <create+0x86>
    80004638:	04c4d783          	lhu	a5,76(s1)
    8000463c:	37f9                	addiw	a5,a5,-2
    8000463e:	17c2                	slli	a5,a5,0x30
    80004640:	93c1                	srli	a5,a5,0x30
    80004642:	4705                	li	a4,1
    80004644:	00f76c63          	bltu	a4,a5,8000465c <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80004648:	8526                	mv	a0,s1
    8000464a:	60a6                	ld	ra,72(sp)
    8000464c:	6406                	ld	s0,64(sp)
    8000464e:	74e2                	ld	s1,56(sp)
    80004650:	7942                	ld	s2,48(sp)
    80004652:	79a2                	ld	s3,40(sp)
    80004654:	7a02                	ld	s4,32(sp)
    80004656:	6ae2                	ld	s5,24(sp)
    80004658:	6161                	addi	sp,sp,80
    8000465a:	8082                	ret
    iunlockput(ip);
    8000465c:	8526                	mv	a0,s1
    8000465e:	fffff097          	auipc	ra,0xfffff
    80004662:	89e080e7          	jalr	-1890(ra) # 80002efc <iunlockput>
    return 0;
    80004666:	4481                	li	s1,0
    80004668:	b7c5                	j	80004648 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    8000466a:	85ce                	mv	a1,s3
    8000466c:	00092503          	lw	a0,0(s2)
    80004670:	ffffe097          	auipc	ra,0xffffe
    80004674:	492080e7          	jalr	1170(ra) # 80002b02 <ialloc>
    80004678:	84aa                	mv	s1,a0
    8000467a:	c529                	beqz	a0,800046c4 <create+0xee>
  ilock(ip);
    8000467c:	ffffe097          	auipc	ra,0xffffe
    80004680:	61e080e7          	jalr	1566(ra) # 80002c9a <ilock>
  ip->major = major;
    80004684:	05549723          	sh	s5,78(s1)
  ip->minor = minor;
    80004688:	05449823          	sh	s4,80(s1)
  ip->nlink = 1;
    8000468c:	4785                	li	a5,1
    8000468e:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    80004692:	8526                	mv	a0,s1
    80004694:	ffffe097          	auipc	ra,0xffffe
    80004698:	53c080e7          	jalr	1340(ra) # 80002bd0 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000469c:	2981                	sext.w	s3,s3
    8000469e:	4785                	li	a5,1
    800046a0:	02f98a63          	beq	s3,a5,800046d4 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    800046a4:	40d0                	lw	a2,4(s1)
    800046a6:	fb040593          	addi	a1,s0,-80
    800046aa:	854a                	mv	a0,s2
    800046ac:	fffff097          	auipc	ra,0xfffff
    800046b0:	ce2080e7          	jalr	-798(ra) # 8000338e <dirlink>
    800046b4:	06054b63          	bltz	a0,8000472a <create+0x154>
  iunlockput(dp);
    800046b8:	854a                	mv	a0,s2
    800046ba:	fffff097          	auipc	ra,0xfffff
    800046be:	842080e7          	jalr	-1982(ra) # 80002efc <iunlockput>
  return ip;
    800046c2:	b759                	j	80004648 <create+0x72>
    panic("create: ialloc");
    800046c4:	00004517          	auipc	a0,0x4
    800046c8:	fb450513          	addi	a0,a0,-76 # 80008678 <syscalls+0x2a8>
    800046cc:	00002097          	auipc	ra,0x2
    800046d0:	9c0080e7          	jalr	-1600(ra) # 8000608c <panic>
    dp->nlink++;  // for ".."
    800046d4:	05295783          	lhu	a5,82(s2)
    800046d8:	2785                	addiw	a5,a5,1
    800046da:	04f91923          	sh	a5,82(s2)
    iupdate(dp);
    800046de:	854a                	mv	a0,s2
    800046e0:	ffffe097          	auipc	ra,0xffffe
    800046e4:	4f0080e7          	jalr	1264(ra) # 80002bd0 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800046e8:	40d0                	lw	a2,4(s1)
    800046ea:	00004597          	auipc	a1,0x4
    800046ee:	f9e58593          	addi	a1,a1,-98 # 80008688 <syscalls+0x2b8>
    800046f2:	8526                	mv	a0,s1
    800046f4:	fffff097          	auipc	ra,0xfffff
    800046f8:	c9a080e7          	jalr	-870(ra) # 8000338e <dirlink>
    800046fc:	00054f63          	bltz	a0,8000471a <create+0x144>
    80004700:	00492603          	lw	a2,4(s2)
    80004704:	00004597          	auipc	a1,0x4
    80004708:	f8c58593          	addi	a1,a1,-116 # 80008690 <syscalls+0x2c0>
    8000470c:	8526                	mv	a0,s1
    8000470e:	fffff097          	auipc	ra,0xfffff
    80004712:	c80080e7          	jalr	-896(ra) # 8000338e <dirlink>
    80004716:	f80557e3          	bgez	a0,800046a4 <create+0xce>
      panic("create dots");
    8000471a:	00004517          	auipc	a0,0x4
    8000471e:	f7e50513          	addi	a0,a0,-130 # 80008698 <syscalls+0x2c8>
    80004722:	00002097          	auipc	ra,0x2
    80004726:	96a080e7          	jalr	-1686(ra) # 8000608c <panic>
    panic("create: dirlink");
    8000472a:	00004517          	auipc	a0,0x4
    8000472e:	f7e50513          	addi	a0,a0,-130 # 800086a8 <syscalls+0x2d8>
    80004732:	00002097          	auipc	ra,0x2
    80004736:	95a080e7          	jalr	-1702(ra) # 8000608c <panic>
    return 0;
    8000473a:	84aa                	mv	s1,a0
    8000473c:	b731                	j	80004648 <create+0x72>

000000008000473e <sys_dup>:
{
    8000473e:	7179                	addi	sp,sp,-48
    80004740:	f406                	sd	ra,40(sp)
    80004742:	f022                	sd	s0,32(sp)
    80004744:	ec26                	sd	s1,24(sp)
    80004746:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004748:	fd840613          	addi	a2,s0,-40
    8000474c:	4581                	li	a1,0
    8000474e:	4501                	li	a0,0
    80004750:	00000097          	auipc	ra,0x0
    80004754:	ddc080e7          	jalr	-548(ra) # 8000452c <argfd>
    return -1;
    80004758:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000475a:	02054363          	bltz	a0,80004780 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    8000475e:	fd843503          	ld	a0,-40(s0)
    80004762:	00000097          	auipc	ra,0x0
    80004766:	e32080e7          	jalr	-462(ra) # 80004594 <fdalloc>
    8000476a:	84aa                	mv	s1,a0
    return -1;
    8000476c:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000476e:	00054963          	bltz	a0,80004780 <sys_dup+0x42>
  filedup(f);
    80004772:	fd843503          	ld	a0,-40(s0)
    80004776:	fffff097          	auipc	ra,0xfffff
    8000477a:	370080e7          	jalr	880(ra) # 80003ae6 <filedup>
  return fd;
    8000477e:	87a6                	mv	a5,s1
}
    80004780:	853e                	mv	a0,a5
    80004782:	70a2                	ld	ra,40(sp)
    80004784:	7402                	ld	s0,32(sp)
    80004786:	64e2                	ld	s1,24(sp)
    80004788:	6145                	addi	sp,sp,48
    8000478a:	8082                	ret

000000008000478c <sys_read>:
{
    8000478c:	7179                	addi	sp,sp,-48
    8000478e:	f406                	sd	ra,40(sp)
    80004790:	f022                	sd	s0,32(sp)
    80004792:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80004794:	fe840613          	addi	a2,s0,-24
    80004798:	4581                	li	a1,0
    8000479a:	4501                	li	a0,0
    8000479c:	00000097          	auipc	ra,0x0
    800047a0:	d90080e7          	jalr	-624(ra) # 8000452c <argfd>
    return -1;
    800047a4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800047a6:	04054163          	bltz	a0,800047e8 <sys_read+0x5c>
    800047aa:	fe440593          	addi	a1,s0,-28
    800047ae:	4509                	li	a0,2
    800047b0:	ffffe097          	auipc	ra,0xffffe
    800047b4:	8a0080e7          	jalr	-1888(ra) # 80002050 <argint>
    return -1;
    800047b8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800047ba:	02054763          	bltz	a0,800047e8 <sys_read+0x5c>
    800047be:	fd840593          	addi	a1,s0,-40
    800047c2:	4505                	li	a0,1
    800047c4:	ffffe097          	auipc	ra,0xffffe
    800047c8:	8ae080e7          	jalr	-1874(ra) # 80002072 <argaddr>
    return -1;
    800047cc:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800047ce:	00054d63          	bltz	a0,800047e8 <sys_read+0x5c>
  return fileread(f, p, n);
    800047d2:	fe442603          	lw	a2,-28(s0)
    800047d6:	fd843583          	ld	a1,-40(s0)
    800047da:	fe843503          	ld	a0,-24(s0)
    800047de:	fffff097          	auipc	ra,0xfffff
    800047e2:	494080e7          	jalr	1172(ra) # 80003c72 <fileread>
    800047e6:	87aa                	mv	a5,a0
}
    800047e8:	853e                	mv	a0,a5
    800047ea:	70a2                	ld	ra,40(sp)
    800047ec:	7402                	ld	s0,32(sp)
    800047ee:	6145                	addi	sp,sp,48
    800047f0:	8082                	ret

00000000800047f2 <sys_write>:
{
    800047f2:	7179                	addi	sp,sp,-48
    800047f4:	f406                	sd	ra,40(sp)
    800047f6:	f022                	sd	s0,32(sp)
    800047f8:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800047fa:	fe840613          	addi	a2,s0,-24
    800047fe:	4581                	li	a1,0
    80004800:	4501                	li	a0,0
    80004802:	00000097          	auipc	ra,0x0
    80004806:	d2a080e7          	jalr	-726(ra) # 8000452c <argfd>
    return -1;
    8000480a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000480c:	04054163          	bltz	a0,8000484e <sys_write+0x5c>
    80004810:	fe440593          	addi	a1,s0,-28
    80004814:	4509                	li	a0,2
    80004816:	ffffe097          	auipc	ra,0xffffe
    8000481a:	83a080e7          	jalr	-1990(ra) # 80002050 <argint>
    return -1;
    8000481e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80004820:	02054763          	bltz	a0,8000484e <sys_write+0x5c>
    80004824:	fd840593          	addi	a1,s0,-40
    80004828:	4505                	li	a0,1
    8000482a:	ffffe097          	auipc	ra,0xffffe
    8000482e:	848080e7          	jalr	-1976(ra) # 80002072 <argaddr>
    return -1;
    80004832:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80004834:	00054d63          	bltz	a0,8000484e <sys_write+0x5c>
  return filewrite(f, p, n);
    80004838:	fe442603          	lw	a2,-28(s0)
    8000483c:	fd843583          	ld	a1,-40(s0)
    80004840:	fe843503          	ld	a0,-24(s0)
    80004844:	fffff097          	auipc	ra,0xfffff
    80004848:	4f0080e7          	jalr	1264(ra) # 80003d34 <filewrite>
    8000484c:	87aa                	mv	a5,a0
}
    8000484e:	853e                	mv	a0,a5
    80004850:	70a2                	ld	ra,40(sp)
    80004852:	7402                	ld	s0,32(sp)
    80004854:	6145                	addi	sp,sp,48
    80004856:	8082                	ret

0000000080004858 <sys_close>:
{
    80004858:	1101                	addi	sp,sp,-32
    8000485a:	ec06                	sd	ra,24(sp)
    8000485c:	e822                	sd	s0,16(sp)
    8000485e:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004860:	fe040613          	addi	a2,s0,-32
    80004864:	fec40593          	addi	a1,s0,-20
    80004868:	4501                	li	a0,0
    8000486a:	00000097          	auipc	ra,0x0
    8000486e:	cc2080e7          	jalr	-830(ra) # 8000452c <argfd>
    return -1;
    80004872:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004874:	02054463          	bltz	a0,8000489c <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80004878:	ffffc097          	auipc	ra,0xffffc
    8000487c:	72c080e7          	jalr	1836(ra) # 80000fa4 <myproc>
    80004880:	fec42783          	lw	a5,-20(s0)
    80004884:	07e9                	addi	a5,a5,26
    80004886:	078e                	slli	a5,a5,0x3
    80004888:	97aa                	add	a5,a5,a0
    8000488a:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    8000488e:	fe043503          	ld	a0,-32(s0)
    80004892:	fffff097          	auipc	ra,0xfffff
    80004896:	2a6080e7          	jalr	678(ra) # 80003b38 <fileclose>
  return 0;
    8000489a:	4781                	li	a5,0
}
    8000489c:	853e                	mv	a0,a5
    8000489e:	60e2                	ld	ra,24(sp)
    800048a0:	6442                	ld	s0,16(sp)
    800048a2:	6105                	addi	sp,sp,32
    800048a4:	8082                	ret

00000000800048a6 <sys_fstat>:
{
    800048a6:	1101                	addi	sp,sp,-32
    800048a8:	ec06                	sd	ra,24(sp)
    800048aa:	e822                	sd	s0,16(sp)
    800048ac:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800048ae:	fe840613          	addi	a2,s0,-24
    800048b2:	4581                	li	a1,0
    800048b4:	4501                	li	a0,0
    800048b6:	00000097          	auipc	ra,0x0
    800048ba:	c76080e7          	jalr	-906(ra) # 8000452c <argfd>
    return -1;
    800048be:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800048c0:	02054563          	bltz	a0,800048ea <sys_fstat+0x44>
    800048c4:	fe040593          	addi	a1,s0,-32
    800048c8:	4505                	li	a0,1
    800048ca:	ffffd097          	auipc	ra,0xffffd
    800048ce:	7a8080e7          	jalr	1960(ra) # 80002072 <argaddr>
    return -1;
    800048d2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800048d4:	00054b63          	bltz	a0,800048ea <sys_fstat+0x44>
  return filestat(f, st);
    800048d8:	fe043583          	ld	a1,-32(s0)
    800048dc:	fe843503          	ld	a0,-24(s0)
    800048e0:	fffff097          	auipc	ra,0xfffff
    800048e4:	320080e7          	jalr	800(ra) # 80003c00 <filestat>
    800048e8:	87aa                	mv	a5,a0
}
    800048ea:	853e                	mv	a0,a5
    800048ec:	60e2                	ld	ra,24(sp)
    800048ee:	6442                	ld	s0,16(sp)
    800048f0:	6105                	addi	sp,sp,32
    800048f2:	8082                	ret

00000000800048f4 <sys_link>:
{
    800048f4:	7169                	addi	sp,sp,-304
    800048f6:	f606                	sd	ra,296(sp)
    800048f8:	f222                	sd	s0,288(sp)
    800048fa:	ee26                	sd	s1,280(sp)
    800048fc:	ea4a                	sd	s2,272(sp)
    800048fe:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004900:	08000613          	li	a2,128
    80004904:	ed040593          	addi	a1,s0,-304
    80004908:	4501                	li	a0,0
    8000490a:	ffffd097          	auipc	ra,0xffffd
    8000490e:	78a080e7          	jalr	1930(ra) # 80002094 <argstr>
    return -1;
    80004912:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004914:	10054e63          	bltz	a0,80004a30 <sys_link+0x13c>
    80004918:	08000613          	li	a2,128
    8000491c:	f5040593          	addi	a1,s0,-176
    80004920:	4505                	li	a0,1
    80004922:	ffffd097          	auipc	ra,0xffffd
    80004926:	772080e7          	jalr	1906(ra) # 80002094 <argstr>
    return -1;
    8000492a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000492c:	10054263          	bltz	a0,80004a30 <sys_link+0x13c>
  begin_op();
    80004930:	fffff097          	auipc	ra,0xfffff
    80004934:	d3c080e7          	jalr	-708(ra) # 8000366c <begin_op>
  if((ip = namei(old)) == 0){
    80004938:	ed040513          	addi	a0,s0,-304
    8000493c:	fffff097          	auipc	ra,0xfffff
    80004940:	b14080e7          	jalr	-1260(ra) # 80003450 <namei>
    80004944:	84aa                	mv	s1,a0
    80004946:	c551                	beqz	a0,800049d2 <sys_link+0xde>
  ilock(ip);
    80004948:	ffffe097          	auipc	ra,0xffffe
    8000494c:	352080e7          	jalr	850(ra) # 80002c9a <ilock>
  if(ip->type == T_DIR){
    80004950:	04c49703          	lh	a4,76(s1)
    80004954:	4785                	li	a5,1
    80004956:	08f70463          	beq	a4,a5,800049de <sys_link+0xea>
  ip->nlink++;
    8000495a:	0524d783          	lhu	a5,82(s1)
    8000495e:	2785                	addiw	a5,a5,1
    80004960:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    80004964:	8526                	mv	a0,s1
    80004966:	ffffe097          	auipc	ra,0xffffe
    8000496a:	26a080e7          	jalr	618(ra) # 80002bd0 <iupdate>
  iunlock(ip);
    8000496e:	8526                	mv	a0,s1
    80004970:	ffffe097          	auipc	ra,0xffffe
    80004974:	3ec080e7          	jalr	1004(ra) # 80002d5c <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004978:	fd040593          	addi	a1,s0,-48
    8000497c:	f5040513          	addi	a0,s0,-176
    80004980:	fffff097          	auipc	ra,0xfffff
    80004984:	aee080e7          	jalr	-1298(ra) # 8000346e <nameiparent>
    80004988:	892a                	mv	s2,a0
    8000498a:	c935                	beqz	a0,800049fe <sys_link+0x10a>
  ilock(dp);
    8000498c:	ffffe097          	auipc	ra,0xffffe
    80004990:	30e080e7          	jalr	782(ra) # 80002c9a <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004994:	00092703          	lw	a4,0(s2)
    80004998:	409c                	lw	a5,0(s1)
    8000499a:	04f71d63          	bne	a4,a5,800049f4 <sys_link+0x100>
    8000499e:	40d0                	lw	a2,4(s1)
    800049a0:	fd040593          	addi	a1,s0,-48
    800049a4:	854a                	mv	a0,s2
    800049a6:	fffff097          	auipc	ra,0xfffff
    800049aa:	9e8080e7          	jalr	-1560(ra) # 8000338e <dirlink>
    800049ae:	04054363          	bltz	a0,800049f4 <sys_link+0x100>
  iunlockput(dp);
    800049b2:	854a                	mv	a0,s2
    800049b4:	ffffe097          	auipc	ra,0xffffe
    800049b8:	548080e7          	jalr	1352(ra) # 80002efc <iunlockput>
  iput(ip);
    800049bc:	8526                	mv	a0,s1
    800049be:	ffffe097          	auipc	ra,0xffffe
    800049c2:	496080e7          	jalr	1174(ra) # 80002e54 <iput>
  end_op();
    800049c6:	fffff097          	auipc	ra,0xfffff
    800049ca:	d26080e7          	jalr	-730(ra) # 800036ec <end_op>
  return 0;
    800049ce:	4781                	li	a5,0
    800049d0:	a085                	j	80004a30 <sys_link+0x13c>
    end_op();
    800049d2:	fffff097          	auipc	ra,0xfffff
    800049d6:	d1a080e7          	jalr	-742(ra) # 800036ec <end_op>
    return -1;
    800049da:	57fd                	li	a5,-1
    800049dc:	a891                	j	80004a30 <sys_link+0x13c>
    iunlockput(ip);
    800049de:	8526                	mv	a0,s1
    800049e0:	ffffe097          	auipc	ra,0xffffe
    800049e4:	51c080e7          	jalr	1308(ra) # 80002efc <iunlockput>
    end_op();
    800049e8:	fffff097          	auipc	ra,0xfffff
    800049ec:	d04080e7          	jalr	-764(ra) # 800036ec <end_op>
    return -1;
    800049f0:	57fd                	li	a5,-1
    800049f2:	a83d                	j	80004a30 <sys_link+0x13c>
    iunlockput(dp);
    800049f4:	854a                	mv	a0,s2
    800049f6:	ffffe097          	auipc	ra,0xffffe
    800049fa:	506080e7          	jalr	1286(ra) # 80002efc <iunlockput>
  ilock(ip);
    800049fe:	8526                	mv	a0,s1
    80004a00:	ffffe097          	auipc	ra,0xffffe
    80004a04:	29a080e7          	jalr	666(ra) # 80002c9a <ilock>
  ip->nlink--;
    80004a08:	0524d783          	lhu	a5,82(s1)
    80004a0c:	37fd                	addiw	a5,a5,-1
    80004a0e:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    80004a12:	8526                	mv	a0,s1
    80004a14:	ffffe097          	auipc	ra,0xffffe
    80004a18:	1bc080e7          	jalr	444(ra) # 80002bd0 <iupdate>
  iunlockput(ip);
    80004a1c:	8526                	mv	a0,s1
    80004a1e:	ffffe097          	auipc	ra,0xffffe
    80004a22:	4de080e7          	jalr	1246(ra) # 80002efc <iunlockput>
  end_op();
    80004a26:	fffff097          	auipc	ra,0xfffff
    80004a2a:	cc6080e7          	jalr	-826(ra) # 800036ec <end_op>
  return -1;
    80004a2e:	57fd                	li	a5,-1
}
    80004a30:	853e                	mv	a0,a5
    80004a32:	70b2                	ld	ra,296(sp)
    80004a34:	7412                	ld	s0,288(sp)
    80004a36:	64f2                	ld	s1,280(sp)
    80004a38:	6952                	ld	s2,272(sp)
    80004a3a:	6155                	addi	sp,sp,304
    80004a3c:	8082                	ret

0000000080004a3e <sys_unlink>:
{
    80004a3e:	7151                	addi	sp,sp,-240
    80004a40:	f586                	sd	ra,232(sp)
    80004a42:	f1a2                	sd	s0,224(sp)
    80004a44:	eda6                	sd	s1,216(sp)
    80004a46:	e9ca                	sd	s2,208(sp)
    80004a48:	e5ce                	sd	s3,200(sp)
    80004a4a:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004a4c:	08000613          	li	a2,128
    80004a50:	f3040593          	addi	a1,s0,-208
    80004a54:	4501                	li	a0,0
    80004a56:	ffffd097          	auipc	ra,0xffffd
    80004a5a:	63e080e7          	jalr	1598(ra) # 80002094 <argstr>
    80004a5e:	18054163          	bltz	a0,80004be0 <sys_unlink+0x1a2>
  begin_op();
    80004a62:	fffff097          	auipc	ra,0xfffff
    80004a66:	c0a080e7          	jalr	-1014(ra) # 8000366c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004a6a:	fb040593          	addi	a1,s0,-80
    80004a6e:	f3040513          	addi	a0,s0,-208
    80004a72:	fffff097          	auipc	ra,0xfffff
    80004a76:	9fc080e7          	jalr	-1540(ra) # 8000346e <nameiparent>
    80004a7a:	84aa                	mv	s1,a0
    80004a7c:	c979                	beqz	a0,80004b52 <sys_unlink+0x114>
  ilock(dp);
    80004a7e:	ffffe097          	auipc	ra,0xffffe
    80004a82:	21c080e7          	jalr	540(ra) # 80002c9a <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004a86:	00004597          	auipc	a1,0x4
    80004a8a:	c0258593          	addi	a1,a1,-1022 # 80008688 <syscalls+0x2b8>
    80004a8e:	fb040513          	addi	a0,s0,-80
    80004a92:	ffffe097          	auipc	ra,0xffffe
    80004a96:	6d2080e7          	jalr	1746(ra) # 80003164 <namecmp>
    80004a9a:	14050a63          	beqz	a0,80004bee <sys_unlink+0x1b0>
    80004a9e:	00004597          	auipc	a1,0x4
    80004aa2:	bf258593          	addi	a1,a1,-1038 # 80008690 <syscalls+0x2c0>
    80004aa6:	fb040513          	addi	a0,s0,-80
    80004aaa:	ffffe097          	auipc	ra,0xffffe
    80004aae:	6ba080e7          	jalr	1722(ra) # 80003164 <namecmp>
    80004ab2:	12050e63          	beqz	a0,80004bee <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004ab6:	f2c40613          	addi	a2,s0,-212
    80004aba:	fb040593          	addi	a1,s0,-80
    80004abe:	8526                	mv	a0,s1
    80004ac0:	ffffe097          	auipc	ra,0xffffe
    80004ac4:	6be080e7          	jalr	1726(ra) # 8000317e <dirlookup>
    80004ac8:	892a                	mv	s2,a0
    80004aca:	12050263          	beqz	a0,80004bee <sys_unlink+0x1b0>
  ilock(ip);
    80004ace:	ffffe097          	auipc	ra,0xffffe
    80004ad2:	1cc080e7          	jalr	460(ra) # 80002c9a <ilock>
  if(ip->nlink < 1)
    80004ad6:	05291783          	lh	a5,82(s2)
    80004ada:	08f05263          	blez	a5,80004b5e <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004ade:	04c91703          	lh	a4,76(s2)
    80004ae2:	4785                	li	a5,1
    80004ae4:	08f70563          	beq	a4,a5,80004b6e <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80004ae8:	4641                	li	a2,16
    80004aea:	4581                	li	a1,0
    80004aec:	fc040513          	addi	a0,s0,-64
    80004af0:	ffffb097          	auipc	ra,0xffffb
    80004af4:	7d4080e7          	jalr	2004(ra) # 800002c4 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004af8:	4741                	li	a4,16
    80004afa:	f2c42683          	lw	a3,-212(s0)
    80004afe:	fc040613          	addi	a2,s0,-64
    80004b02:	4581                	li	a1,0
    80004b04:	8526                	mv	a0,s1
    80004b06:	ffffe097          	auipc	ra,0xffffe
    80004b0a:	540080e7          	jalr	1344(ra) # 80003046 <writei>
    80004b0e:	47c1                	li	a5,16
    80004b10:	0af51563          	bne	a0,a5,80004bba <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80004b14:	04c91703          	lh	a4,76(s2)
    80004b18:	4785                	li	a5,1
    80004b1a:	0af70863          	beq	a4,a5,80004bca <sys_unlink+0x18c>
  iunlockput(dp);
    80004b1e:	8526                	mv	a0,s1
    80004b20:	ffffe097          	auipc	ra,0xffffe
    80004b24:	3dc080e7          	jalr	988(ra) # 80002efc <iunlockput>
  ip->nlink--;
    80004b28:	05295783          	lhu	a5,82(s2)
    80004b2c:	37fd                	addiw	a5,a5,-1
    80004b2e:	04f91923          	sh	a5,82(s2)
  iupdate(ip);
    80004b32:	854a                	mv	a0,s2
    80004b34:	ffffe097          	auipc	ra,0xffffe
    80004b38:	09c080e7          	jalr	156(ra) # 80002bd0 <iupdate>
  iunlockput(ip);
    80004b3c:	854a                	mv	a0,s2
    80004b3e:	ffffe097          	auipc	ra,0xffffe
    80004b42:	3be080e7          	jalr	958(ra) # 80002efc <iunlockput>
  end_op();
    80004b46:	fffff097          	auipc	ra,0xfffff
    80004b4a:	ba6080e7          	jalr	-1114(ra) # 800036ec <end_op>
  return 0;
    80004b4e:	4501                	li	a0,0
    80004b50:	a84d                	j	80004c02 <sys_unlink+0x1c4>
    end_op();
    80004b52:	fffff097          	auipc	ra,0xfffff
    80004b56:	b9a080e7          	jalr	-1126(ra) # 800036ec <end_op>
    return -1;
    80004b5a:	557d                	li	a0,-1
    80004b5c:	a05d                	j	80004c02 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80004b5e:	00004517          	auipc	a0,0x4
    80004b62:	b5a50513          	addi	a0,a0,-1190 # 800086b8 <syscalls+0x2e8>
    80004b66:	00001097          	auipc	ra,0x1
    80004b6a:	526080e7          	jalr	1318(ra) # 8000608c <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004b6e:	05492703          	lw	a4,84(s2)
    80004b72:	02000793          	li	a5,32
    80004b76:	f6e7f9e3          	bgeu	a5,a4,80004ae8 <sys_unlink+0xaa>
    80004b7a:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004b7e:	4741                	li	a4,16
    80004b80:	86ce                	mv	a3,s3
    80004b82:	f1840613          	addi	a2,s0,-232
    80004b86:	4581                	li	a1,0
    80004b88:	854a                	mv	a0,s2
    80004b8a:	ffffe097          	auipc	ra,0xffffe
    80004b8e:	3c4080e7          	jalr	964(ra) # 80002f4e <readi>
    80004b92:	47c1                	li	a5,16
    80004b94:	00f51b63          	bne	a0,a5,80004baa <sys_unlink+0x16c>
    if(de.inum != 0)
    80004b98:	f1845783          	lhu	a5,-232(s0)
    80004b9c:	e7a1                	bnez	a5,80004be4 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004b9e:	29c1                	addiw	s3,s3,16
    80004ba0:	05492783          	lw	a5,84(s2)
    80004ba4:	fcf9ede3          	bltu	s3,a5,80004b7e <sys_unlink+0x140>
    80004ba8:	b781                	j	80004ae8 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80004baa:	00004517          	auipc	a0,0x4
    80004bae:	b2650513          	addi	a0,a0,-1242 # 800086d0 <syscalls+0x300>
    80004bb2:	00001097          	auipc	ra,0x1
    80004bb6:	4da080e7          	jalr	1242(ra) # 8000608c <panic>
    panic("unlink: writei");
    80004bba:	00004517          	auipc	a0,0x4
    80004bbe:	b2e50513          	addi	a0,a0,-1234 # 800086e8 <syscalls+0x318>
    80004bc2:	00001097          	auipc	ra,0x1
    80004bc6:	4ca080e7          	jalr	1226(ra) # 8000608c <panic>
    dp->nlink--;
    80004bca:	0524d783          	lhu	a5,82(s1)
    80004bce:	37fd                	addiw	a5,a5,-1
    80004bd0:	04f49923          	sh	a5,82(s1)
    iupdate(dp);
    80004bd4:	8526                	mv	a0,s1
    80004bd6:	ffffe097          	auipc	ra,0xffffe
    80004bda:	ffa080e7          	jalr	-6(ra) # 80002bd0 <iupdate>
    80004bde:	b781                	j	80004b1e <sys_unlink+0xe0>
    return -1;
    80004be0:	557d                	li	a0,-1
    80004be2:	a005                	j	80004c02 <sys_unlink+0x1c4>
    iunlockput(ip);
    80004be4:	854a                	mv	a0,s2
    80004be6:	ffffe097          	auipc	ra,0xffffe
    80004bea:	316080e7          	jalr	790(ra) # 80002efc <iunlockput>
  iunlockput(dp);
    80004bee:	8526                	mv	a0,s1
    80004bf0:	ffffe097          	auipc	ra,0xffffe
    80004bf4:	30c080e7          	jalr	780(ra) # 80002efc <iunlockput>
  end_op();
    80004bf8:	fffff097          	auipc	ra,0xfffff
    80004bfc:	af4080e7          	jalr	-1292(ra) # 800036ec <end_op>
  return -1;
    80004c00:	557d                	li	a0,-1
}
    80004c02:	70ae                	ld	ra,232(sp)
    80004c04:	740e                	ld	s0,224(sp)
    80004c06:	64ee                	ld	s1,216(sp)
    80004c08:	694e                	ld	s2,208(sp)
    80004c0a:	69ae                	ld	s3,200(sp)
    80004c0c:	616d                	addi	sp,sp,240
    80004c0e:	8082                	ret

0000000080004c10 <sys_open>:

uint64
sys_open(void)
{
    80004c10:	7131                	addi	sp,sp,-192
    80004c12:	fd06                	sd	ra,184(sp)
    80004c14:	f922                	sd	s0,176(sp)
    80004c16:	f526                	sd	s1,168(sp)
    80004c18:	f14a                	sd	s2,160(sp)
    80004c1a:	ed4e                	sd	s3,152(sp)
    80004c1c:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80004c1e:	08000613          	li	a2,128
    80004c22:	f5040593          	addi	a1,s0,-176
    80004c26:	4501                	li	a0,0
    80004c28:	ffffd097          	auipc	ra,0xffffd
    80004c2c:	46c080e7          	jalr	1132(ra) # 80002094 <argstr>
    return -1;
    80004c30:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80004c32:	0c054163          	bltz	a0,80004cf4 <sys_open+0xe4>
    80004c36:	f4c40593          	addi	a1,s0,-180
    80004c3a:	4505                	li	a0,1
    80004c3c:	ffffd097          	auipc	ra,0xffffd
    80004c40:	414080e7          	jalr	1044(ra) # 80002050 <argint>
    80004c44:	0a054863          	bltz	a0,80004cf4 <sys_open+0xe4>

  begin_op();
    80004c48:	fffff097          	auipc	ra,0xfffff
    80004c4c:	a24080e7          	jalr	-1500(ra) # 8000366c <begin_op>

  if(omode & O_CREATE){
    80004c50:	f4c42783          	lw	a5,-180(s0)
    80004c54:	2007f793          	andi	a5,a5,512
    80004c58:	cbdd                	beqz	a5,80004d0e <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80004c5a:	4681                	li	a3,0
    80004c5c:	4601                	li	a2,0
    80004c5e:	4589                	li	a1,2
    80004c60:	f5040513          	addi	a0,s0,-176
    80004c64:	00000097          	auipc	ra,0x0
    80004c68:	972080e7          	jalr	-1678(ra) # 800045d6 <create>
    80004c6c:	892a                	mv	s2,a0
    if(ip == 0){
    80004c6e:	c959                	beqz	a0,80004d04 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004c70:	04c91703          	lh	a4,76(s2)
    80004c74:	478d                	li	a5,3
    80004c76:	00f71763          	bne	a4,a5,80004c84 <sys_open+0x74>
    80004c7a:	04e95703          	lhu	a4,78(s2)
    80004c7e:	47a5                	li	a5,9
    80004c80:	0ce7ec63          	bltu	a5,a4,80004d58 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004c84:	fffff097          	auipc	ra,0xfffff
    80004c88:	df8080e7          	jalr	-520(ra) # 80003a7c <filealloc>
    80004c8c:	89aa                	mv	s3,a0
    80004c8e:	10050263          	beqz	a0,80004d92 <sys_open+0x182>
    80004c92:	00000097          	auipc	ra,0x0
    80004c96:	902080e7          	jalr	-1790(ra) # 80004594 <fdalloc>
    80004c9a:	84aa                	mv	s1,a0
    80004c9c:	0e054663          	bltz	a0,80004d88 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004ca0:	04c91703          	lh	a4,76(s2)
    80004ca4:	478d                	li	a5,3
    80004ca6:	0cf70463          	beq	a4,a5,80004d6e <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004caa:	4789                	li	a5,2
    80004cac:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80004cb0:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80004cb4:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80004cb8:	f4c42783          	lw	a5,-180(s0)
    80004cbc:	0017c713          	xori	a4,a5,1
    80004cc0:	8b05                	andi	a4,a4,1
    80004cc2:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004cc6:	0037f713          	andi	a4,a5,3
    80004cca:	00e03733          	snez	a4,a4
    80004cce:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004cd2:	4007f793          	andi	a5,a5,1024
    80004cd6:	c791                	beqz	a5,80004ce2 <sys_open+0xd2>
    80004cd8:	04c91703          	lh	a4,76(s2)
    80004cdc:	4789                	li	a5,2
    80004cde:	08f70f63          	beq	a4,a5,80004d7c <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80004ce2:	854a                	mv	a0,s2
    80004ce4:	ffffe097          	auipc	ra,0xffffe
    80004ce8:	078080e7          	jalr	120(ra) # 80002d5c <iunlock>
  end_op();
    80004cec:	fffff097          	auipc	ra,0xfffff
    80004cf0:	a00080e7          	jalr	-1536(ra) # 800036ec <end_op>

  return fd;
}
    80004cf4:	8526                	mv	a0,s1
    80004cf6:	70ea                	ld	ra,184(sp)
    80004cf8:	744a                	ld	s0,176(sp)
    80004cfa:	74aa                	ld	s1,168(sp)
    80004cfc:	790a                	ld	s2,160(sp)
    80004cfe:	69ea                	ld	s3,152(sp)
    80004d00:	6129                	addi	sp,sp,192
    80004d02:	8082                	ret
      end_op();
    80004d04:	fffff097          	auipc	ra,0xfffff
    80004d08:	9e8080e7          	jalr	-1560(ra) # 800036ec <end_op>
      return -1;
    80004d0c:	b7e5                	j	80004cf4 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80004d0e:	f5040513          	addi	a0,s0,-176
    80004d12:	ffffe097          	auipc	ra,0xffffe
    80004d16:	73e080e7          	jalr	1854(ra) # 80003450 <namei>
    80004d1a:	892a                	mv	s2,a0
    80004d1c:	c905                	beqz	a0,80004d4c <sys_open+0x13c>
    ilock(ip);
    80004d1e:	ffffe097          	auipc	ra,0xffffe
    80004d22:	f7c080e7          	jalr	-132(ra) # 80002c9a <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80004d26:	04c91703          	lh	a4,76(s2)
    80004d2a:	4785                	li	a5,1
    80004d2c:	f4f712e3          	bne	a4,a5,80004c70 <sys_open+0x60>
    80004d30:	f4c42783          	lw	a5,-180(s0)
    80004d34:	dba1                	beqz	a5,80004c84 <sys_open+0x74>
      iunlockput(ip);
    80004d36:	854a                	mv	a0,s2
    80004d38:	ffffe097          	auipc	ra,0xffffe
    80004d3c:	1c4080e7          	jalr	452(ra) # 80002efc <iunlockput>
      end_op();
    80004d40:	fffff097          	auipc	ra,0xfffff
    80004d44:	9ac080e7          	jalr	-1620(ra) # 800036ec <end_op>
      return -1;
    80004d48:	54fd                	li	s1,-1
    80004d4a:	b76d                	j	80004cf4 <sys_open+0xe4>
      end_op();
    80004d4c:	fffff097          	auipc	ra,0xfffff
    80004d50:	9a0080e7          	jalr	-1632(ra) # 800036ec <end_op>
      return -1;
    80004d54:	54fd                	li	s1,-1
    80004d56:	bf79                	j	80004cf4 <sys_open+0xe4>
    iunlockput(ip);
    80004d58:	854a                	mv	a0,s2
    80004d5a:	ffffe097          	auipc	ra,0xffffe
    80004d5e:	1a2080e7          	jalr	418(ra) # 80002efc <iunlockput>
    end_op();
    80004d62:	fffff097          	auipc	ra,0xfffff
    80004d66:	98a080e7          	jalr	-1654(ra) # 800036ec <end_op>
    return -1;
    80004d6a:	54fd                	li	s1,-1
    80004d6c:	b761                	j	80004cf4 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80004d6e:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80004d72:	04e91783          	lh	a5,78(s2)
    80004d76:	02f99223          	sh	a5,36(s3)
    80004d7a:	bf2d                	j	80004cb4 <sys_open+0xa4>
    itrunc(ip);
    80004d7c:	854a                	mv	a0,s2
    80004d7e:	ffffe097          	auipc	ra,0xffffe
    80004d82:	02a080e7          	jalr	42(ra) # 80002da8 <itrunc>
    80004d86:	bfb1                	j	80004ce2 <sys_open+0xd2>
      fileclose(f);
    80004d88:	854e                	mv	a0,s3
    80004d8a:	fffff097          	auipc	ra,0xfffff
    80004d8e:	dae080e7          	jalr	-594(ra) # 80003b38 <fileclose>
    iunlockput(ip);
    80004d92:	854a                	mv	a0,s2
    80004d94:	ffffe097          	auipc	ra,0xffffe
    80004d98:	168080e7          	jalr	360(ra) # 80002efc <iunlockput>
    end_op();
    80004d9c:	fffff097          	auipc	ra,0xfffff
    80004da0:	950080e7          	jalr	-1712(ra) # 800036ec <end_op>
    return -1;
    80004da4:	54fd                	li	s1,-1
    80004da6:	b7b9                	j	80004cf4 <sys_open+0xe4>

0000000080004da8 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80004da8:	7175                	addi	sp,sp,-144
    80004daa:	e506                	sd	ra,136(sp)
    80004dac:	e122                	sd	s0,128(sp)
    80004dae:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80004db0:	fffff097          	auipc	ra,0xfffff
    80004db4:	8bc080e7          	jalr	-1860(ra) # 8000366c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80004db8:	08000613          	li	a2,128
    80004dbc:	f7040593          	addi	a1,s0,-144
    80004dc0:	4501                	li	a0,0
    80004dc2:	ffffd097          	auipc	ra,0xffffd
    80004dc6:	2d2080e7          	jalr	722(ra) # 80002094 <argstr>
    80004dca:	02054963          	bltz	a0,80004dfc <sys_mkdir+0x54>
    80004dce:	4681                	li	a3,0
    80004dd0:	4601                	li	a2,0
    80004dd2:	4585                	li	a1,1
    80004dd4:	f7040513          	addi	a0,s0,-144
    80004dd8:	fffff097          	auipc	ra,0xfffff
    80004ddc:	7fe080e7          	jalr	2046(ra) # 800045d6 <create>
    80004de0:	cd11                	beqz	a0,80004dfc <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004de2:	ffffe097          	auipc	ra,0xffffe
    80004de6:	11a080e7          	jalr	282(ra) # 80002efc <iunlockput>
  end_op();
    80004dea:	fffff097          	auipc	ra,0xfffff
    80004dee:	902080e7          	jalr	-1790(ra) # 800036ec <end_op>
  return 0;
    80004df2:	4501                	li	a0,0
}
    80004df4:	60aa                	ld	ra,136(sp)
    80004df6:	640a                	ld	s0,128(sp)
    80004df8:	6149                	addi	sp,sp,144
    80004dfa:	8082                	ret
    end_op();
    80004dfc:	fffff097          	auipc	ra,0xfffff
    80004e00:	8f0080e7          	jalr	-1808(ra) # 800036ec <end_op>
    return -1;
    80004e04:	557d                	li	a0,-1
    80004e06:	b7fd                	j	80004df4 <sys_mkdir+0x4c>

0000000080004e08 <sys_mknod>:

uint64
sys_mknod(void)
{
    80004e08:	7135                	addi	sp,sp,-160
    80004e0a:	ed06                	sd	ra,152(sp)
    80004e0c:	e922                	sd	s0,144(sp)
    80004e0e:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80004e10:	fffff097          	auipc	ra,0xfffff
    80004e14:	85c080e7          	jalr	-1956(ra) # 8000366c <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004e18:	08000613          	li	a2,128
    80004e1c:	f7040593          	addi	a1,s0,-144
    80004e20:	4501                	li	a0,0
    80004e22:	ffffd097          	auipc	ra,0xffffd
    80004e26:	272080e7          	jalr	626(ra) # 80002094 <argstr>
    80004e2a:	04054a63          	bltz	a0,80004e7e <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80004e2e:	f6c40593          	addi	a1,s0,-148
    80004e32:	4505                	li	a0,1
    80004e34:	ffffd097          	auipc	ra,0xffffd
    80004e38:	21c080e7          	jalr	540(ra) # 80002050 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004e3c:	04054163          	bltz	a0,80004e7e <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80004e40:	f6840593          	addi	a1,s0,-152
    80004e44:	4509                	li	a0,2
    80004e46:	ffffd097          	auipc	ra,0xffffd
    80004e4a:	20a080e7          	jalr	522(ra) # 80002050 <argint>
     argint(1, &major) < 0 ||
    80004e4e:	02054863          	bltz	a0,80004e7e <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80004e52:	f6841683          	lh	a3,-152(s0)
    80004e56:	f6c41603          	lh	a2,-148(s0)
    80004e5a:	458d                	li	a1,3
    80004e5c:	f7040513          	addi	a0,s0,-144
    80004e60:	fffff097          	auipc	ra,0xfffff
    80004e64:	776080e7          	jalr	1910(ra) # 800045d6 <create>
     argint(2, &minor) < 0 ||
    80004e68:	c919                	beqz	a0,80004e7e <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004e6a:	ffffe097          	auipc	ra,0xffffe
    80004e6e:	092080e7          	jalr	146(ra) # 80002efc <iunlockput>
  end_op();
    80004e72:	fffff097          	auipc	ra,0xfffff
    80004e76:	87a080e7          	jalr	-1926(ra) # 800036ec <end_op>
  return 0;
    80004e7a:	4501                	li	a0,0
    80004e7c:	a031                	j	80004e88 <sys_mknod+0x80>
    end_op();
    80004e7e:	fffff097          	auipc	ra,0xfffff
    80004e82:	86e080e7          	jalr	-1938(ra) # 800036ec <end_op>
    return -1;
    80004e86:	557d                	li	a0,-1
}
    80004e88:	60ea                	ld	ra,152(sp)
    80004e8a:	644a                	ld	s0,144(sp)
    80004e8c:	610d                	addi	sp,sp,160
    80004e8e:	8082                	ret

0000000080004e90 <sys_chdir>:

uint64
sys_chdir(void)
{
    80004e90:	7135                	addi	sp,sp,-160
    80004e92:	ed06                	sd	ra,152(sp)
    80004e94:	e922                	sd	s0,144(sp)
    80004e96:	e526                	sd	s1,136(sp)
    80004e98:	e14a                	sd	s2,128(sp)
    80004e9a:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80004e9c:	ffffc097          	auipc	ra,0xffffc
    80004ea0:	108080e7          	jalr	264(ra) # 80000fa4 <myproc>
    80004ea4:	892a                	mv	s2,a0
  
  begin_op();
    80004ea6:	ffffe097          	auipc	ra,0xffffe
    80004eaa:	7c6080e7          	jalr	1990(ra) # 8000366c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80004eae:	08000613          	li	a2,128
    80004eb2:	f6040593          	addi	a1,s0,-160
    80004eb6:	4501                	li	a0,0
    80004eb8:	ffffd097          	auipc	ra,0xffffd
    80004ebc:	1dc080e7          	jalr	476(ra) # 80002094 <argstr>
    80004ec0:	04054b63          	bltz	a0,80004f16 <sys_chdir+0x86>
    80004ec4:	f6040513          	addi	a0,s0,-160
    80004ec8:	ffffe097          	auipc	ra,0xffffe
    80004ecc:	588080e7          	jalr	1416(ra) # 80003450 <namei>
    80004ed0:	84aa                	mv	s1,a0
    80004ed2:	c131                	beqz	a0,80004f16 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80004ed4:	ffffe097          	auipc	ra,0xffffe
    80004ed8:	dc6080e7          	jalr	-570(ra) # 80002c9a <ilock>
  if(ip->type != T_DIR){
    80004edc:	04c49703          	lh	a4,76(s1)
    80004ee0:	4785                	li	a5,1
    80004ee2:	04f71063          	bne	a4,a5,80004f22 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80004ee6:	8526                	mv	a0,s1
    80004ee8:	ffffe097          	auipc	ra,0xffffe
    80004eec:	e74080e7          	jalr	-396(ra) # 80002d5c <iunlock>
  iput(p->cwd);
    80004ef0:	15893503          	ld	a0,344(s2)
    80004ef4:	ffffe097          	auipc	ra,0xffffe
    80004ef8:	f60080e7          	jalr	-160(ra) # 80002e54 <iput>
  end_op();
    80004efc:	ffffe097          	auipc	ra,0xffffe
    80004f00:	7f0080e7          	jalr	2032(ra) # 800036ec <end_op>
  p->cwd = ip;
    80004f04:	14993c23          	sd	s1,344(s2)
  return 0;
    80004f08:	4501                	li	a0,0
}
    80004f0a:	60ea                	ld	ra,152(sp)
    80004f0c:	644a                	ld	s0,144(sp)
    80004f0e:	64aa                	ld	s1,136(sp)
    80004f10:	690a                	ld	s2,128(sp)
    80004f12:	610d                	addi	sp,sp,160
    80004f14:	8082                	ret
    end_op();
    80004f16:	ffffe097          	auipc	ra,0xffffe
    80004f1a:	7d6080e7          	jalr	2006(ra) # 800036ec <end_op>
    return -1;
    80004f1e:	557d                	li	a0,-1
    80004f20:	b7ed                	j	80004f0a <sys_chdir+0x7a>
    iunlockput(ip);
    80004f22:	8526                	mv	a0,s1
    80004f24:	ffffe097          	auipc	ra,0xffffe
    80004f28:	fd8080e7          	jalr	-40(ra) # 80002efc <iunlockput>
    end_op();
    80004f2c:	ffffe097          	auipc	ra,0xffffe
    80004f30:	7c0080e7          	jalr	1984(ra) # 800036ec <end_op>
    return -1;
    80004f34:	557d                	li	a0,-1
    80004f36:	bfd1                	j	80004f0a <sys_chdir+0x7a>

0000000080004f38 <sys_exec>:

uint64
sys_exec(void)
{
    80004f38:	7145                	addi	sp,sp,-464
    80004f3a:	e786                	sd	ra,456(sp)
    80004f3c:	e3a2                	sd	s0,448(sp)
    80004f3e:	ff26                	sd	s1,440(sp)
    80004f40:	fb4a                	sd	s2,432(sp)
    80004f42:	f74e                	sd	s3,424(sp)
    80004f44:	f352                	sd	s4,416(sp)
    80004f46:	ef56                	sd	s5,408(sp)
    80004f48:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80004f4a:	08000613          	li	a2,128
    80004f4e:	f4040593          	addi	a1,s0,-192
    80004f52:	4501                	li	a0,0
    80004f54:	ffffd097          	auipc	ra,0xffffd
    80004f58:	140080e7          	jalr	320(ra) # 80002094 <argstr>
    return -1;
    80004f5c:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80004f5e:	0c054a63          	bltz	a0,80005032 <sys_exec+0xfa>
    80004f62:	e3840593          	addi	a1,s0,-456
    80004f66:	4505                	li	a0,1
    80004f68:	ffffd097          	auipc	ra,0xffffd
    80004f6c:	10a080e7          	jalr	266(ra) # 80002072 <argaddr>
    80004f70:	0c054163          	bltz	a0,80005032 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80004f74:	10000613          	li	a2,256
    80004f78:	4581                	li	a1,0
    80004f7a:	e4040513          	addi	a0,s0,-448
    80004f7e:	ffffb097          	auipc	ra,0xffffb
    80004f82:	346080e7          	jalr	838(ra) # 800002c4 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80004f86:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80004f8a:	89a6                	mv	s3,s1
    80004f8c:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80004f8e:	02000a13          	li	s4,32
    80004f92:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80004f96:	00391513          	slli	a0,s2,0x3
    80004f9a:	e3040593          	addi	a1,s0,-464
    80004f9e:	e3843783          	ld	a5,-456(s0)
    80004fa2:	953e                	add	a0,a0,a5
    80004fa4:	ffffd097          	auipc	ra,0xffffd
    80004fa8:	012080e7          	jalr	18(ra) # 80001fb6 <fetchaddr>
    80004fac:	02054a63          	bltz	a0,80004fe0 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80004fb0:	e3043783          	ld	a5,-464(s0)
    80004fb4:	c3b9                	beqz	a5,80004ffa <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80004fb6:	ffffb097          	auipc	ra,0xffffb
    80004fba:	1ca080e7          	jalr	458(ra) # 80000180 <kalloc>
    80004fbe:	85aa                	mv	a1,a0
    80004fc0:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80004fc4:	cd11                	beqz	a0,80004fe0 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80004fc6:	6605                	lui	a2,0x1
    80004fc8:	e3043503          	ld	a0,-464(s0)
    80004fcc:	ffffd097          	auipc	ra,0xffffd
    80004fd0:	03c080e7          	jalr	60(ra) # 80002008 <fetchstr>
    80004fd4:	00054663          	bltz	a0,80004fe0 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80004fd8:	0905                	addi	s2,s2,1
    80004fda:	09a1                	addi	s3,s3,8
    80004fdc:	fb491be3          	bne	s2,s4,80004f92 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004fe0:	10048913          	addi	s2,s1,256
    80004fe4:	6088                	ld	a0,0(s1)
    80004fe6:	c529                	beqz	a0,80005030 <sys_exec+0xf8>
    kfree(argv[i]);
    80004fe8:	ffffb097          	auipc	ra,0xffffb
    80004fec:	034080e7          	jalr	52(ra) # 8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004ff0:	04a1                	addi	s1,s1,8
    80004ff2:	ff2499e3          	bne	s1,s2,80004fe4 <sys_exec+0xac>
  return -1;
    80004ff6:	597d                	li	s2,-1
    80004ff8:	a82d                	j	80005032 <sys_exec+0xfa>
      argv[i] = 0;
    80004ffa:	0a8e                	slli	s5,s5,0x3
    80004ffc:	fc040793          	addi	a5,s0,-64
    80005000:	9abe                	add	s5,s5,a5
    80005002:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005006:	e4040593          	addi	a1,s0,-448
    8000500a:	f4040513          	addi	a0,s0,-192
    8000500e:	fffff097          	auipc	ra,0xfffff
    80005012:	194080e7          	jalr	404(ra) # 800041a2 <exec>
    80005016:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005018:	10048993          	addi	s3,s1,256
    8000501c:	6088                	ld	a0,0(s1)
    8000501e:	c911                	beqz	a0,80005032 <sys_exec+0xfa>
    kfree(argv[i]);
    80005020:	ffffb097          	auipc	ra,0xffffb
    80005024:	ffc080e7          	jalr	-4(ra) # 8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005028:	04a1                	addi	s1,s1,8
    8000502a:	ff3499e3          	bne	s1,s3,8000501c <sys_exec+0xe4>
    8000502e:	a011                	j	80005032 <sys_exec+0xfa>
  return -1;
    80005030:	597d                	li	s2,-1
}
    80005032:	854a                	mv	a0,s2
    80005034:	60be                	ld	ra,456(sp)
    80005036:	641e                	ld	s0,448(sp)
    80005038:	74fa                	ld	s1,440(sp)
    8000503a:	795a                	ld	s2,432(sp)
    8000503c:	79ba                	ld	s3,424(sp)
    8000503e:	7a1a                	ld	s4,416(sp)
    80005040:	6afa                	ld	s5,408(sp)
    80005042:	6179                	addi	sp,sp,464
    80005044:	8082                	ret

0000000080005046 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005046:	7139                	addi	sp,sp,-64
    80005048:	fc06                	sd	ra,56(sp)
    8000504a:	f822                	sd	s0,48(sp)
    8000504c:	f426                	sd	s1,40(sp)
    8000504e:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005050:	ffffc097          	auipc	ra,0xffffc
    80005054:	f54080e7          	jalr	-172(ra) # 80000fa4 <myproc>
    80005058:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    8000505a:	fd840593          	addi	a1,s0,-40
    8000505e:	4501                	li	a0,0
    80005060:	ffffd097          	auipc	ra,0xffffd
    80005064:	012080e7          	jalr	18(ra) # 80002072 <argaddr>
    return -1;
    80005068:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    8000506a:	0e054063          	bltz	a0,8000514a <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    8000506e:	fc840593          	addi	a1,s0,-56
    80005072:	fd040513          	addi	a0,s0,-48
    80005076:	fffff097          	auipc	ra,0xfffff
    8000507a:	df2080e7          	jalr	-526(ra) # 80003e68 <pipealloc>
    return -1;
    8000507e:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005080:	0c054563          	bltz	a0,8000514a <sys_pipe+0x104>
  fd0 = -1;
    80005084:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005088:	fd043503          	ld	a0,-48(s0)
    8000508c:	fffff097          	auipc	ra,0xfffff
    80005090:	508080e7          	jalr	1288(ra) # 80004594 <fdalloc>
    80005094:	fca42223          	sw	a0,-60(s0)
    80005098:	08054c63          	bltz	a0,80005130 <sys_pipe+0xea>
    8000509c:	fc843503          	ld	a0,-56(s0)
    800050a0:	fffff097          	auipc	ra,0xfffff
    800050a4:	4f4080e7          	jalr	1268(ra) # 80004594 <fdalloc>
    800050a8:	fca42023          	sw	a0,-64(s0)
    800050ac:	06054863          	bltz	a0,8000511c <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800050b0:	4691                	li	a3,4
    800050b2:	fc440613          	addi	a2,s0,-60
    800050b6:	fd843583          	ld	a1,-40(s0)
    800050ba:	6ca8                	ld	a0,88(s1)
    800050bc:	ffffc097          	auipc	ra,0xffffc
    800050c0:	baa080e7          	jalr	-1110(ra) # 80000c66 <copyout>
    800050c4:	02054063          	bltz	a0,800050e4 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800050c8:	4691                	li	a3,4
    800050ca:	fc040613          	addi	a2,s0,-64
    800050ce:	fd843583          	ld	a1,-40(s0)
    800050d2:	0591                	addi	a1,a1,4
    800050d4:	6ca8                	ld	a0,88(s1)
    800050d6:	ffffc097          	auipc	ra,0xffffc
    800050da:	b90080e7          	jalr	-1136(ra) # 80000c66 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800050de:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800050e0:	06055563          	bgez	a0,8000514a <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    800050e4:	fc442783          	lw	a5,-60(s0)
    800050e8:	07e9                	addi	a5,a5,26
    800050ea:	078e                	slli	a5,a5,0x3
    800050ec:	97a6                	add	a5,a5,s1
    800050ee:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    800050f2:	fc042503          	lw	a0,-64(s0)
    800050f6:	0569                	addi	a0,a0,26
    800050f8:	050e                	slli	a0,a0,0x3
    800050fa:	9526                	add	a0,a0,s1
    800050fc:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005100:	fd043503          	ld	a0,-48(s0)
    80005104:	fffff097          	auipc	ra,0xfffff
    80005108:	a34080e7          	jalr	-1484(ra) # 80003b38 <fileclose>
    fileclose(wf);
    8000510c:	fc843503          	ld	a0,-56(s0)
    80005110:	fffff097          	auipc	ra,0xfffff
    80005114:	a28080e7          	jalr	-1496(ra) # 80003b38 <fileclose>
    return -1;
    80005118:	57fd                	li	a5,-1
    8000511a:	a805                	j	8000514a <sys_pipe+0x104>
    if(fd0 >= 0)
    8000511c:	fc442783          	lw	a5,-60(s0)
    80005120:	0007c863          	bltz	a5,80005130 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005124:	01a78513          	addi	a0,a5,26
    80005128:	050e                	slli	a0,a0,0x3
    8000512a:	9526                	add	a0,a0,s1
    8000512c:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005130:	fd043503          	ld	a0,-48(s0)
    80005134:	fffff097          	auipc	ra,0xfffff
    80005138:	a04080e7          	jalr	-1532(ra) # 80003b38 <fileclose>
    fileclose(wf);
    8000513c:	fc843503          	ld	a0,-56(s0)
    80005140:	fffff097          	auipc	ra,0xfffff
    80005144:	9f8080e7          	jalr	-1544(ra) # 80003b38 <fileclose>
    return -1;
    80005148:	57fd                	li	a5,-1
}
    8000514a:	853e                	mv	a0,a5
    8000514c:	70e2                	ld	ra,56(sp)
    8000514e:	7442                	ld	s0,48(sp)
    80005150:	74a2                	ld	s1,40(sp)
    80005152:	6121                	addi	sp,sp,64
    80005154:	8082                	ret
	...

0000000080005160 <kernelvec>:
    80005160:	7111                	addi	sp,sp,-256
    80005162:	e006                	sd	ra,0(sp)
    80005164:	e40a                	sd	sp,8(sp)
    80005166:	e80e                	sd	gp,16(sp)
    80005168:	ec12                	sd	tp,24(sp)
    8000516a:	f016                	sd	t0,32(sp)
    8000516c:	f41a                	sd	t1,40(sp)
    8000516e:	f81e                	sd	t2,48(sp)
    80005170:	fc22                	sd	s0,56(sp)
    80005172:	e0a6                	sd	s1,64(sp)
    80005174:	e4aa                	sd	a0,72(sp)
    80005176:	e8ae                	sd	a1,80(sp)
    80005178:	ecb2                	sd	a2,88(sp)
    8000517a:	f0b6                	sd	a3,96(sp)
    8000517c:	f4ba                	sd	a4,104(sp)
    8000517e:	f8be                	sd	a5,112(sp)
    80005180:	fcc2                	sd	a6,120(sp)
    80005182:	e146                	sd	a7,128(sp)
    80005184:	e54a                	sd	s2,136(sp)
    80005186:	e94e                	sd	s3,144(sp)
    80005188:	ed52                	sd	s4,152(sp)
    8000518a:	f156                	sd	s5,160(sp)
    8000518c:	f55a                	sd	s6,168(sp)
    8000518e:	f95e                	sd	s7,176(sp)
    80005190:	fd62                	sd	s8,184(sp)
    80005192:	e1e6                	sd	s9,192(sp)
    80005194:	e5ea                	sd	s10,200(sp)
    80005196:	e9ee                	sd	s11,208(sp)
    80005198:	edf2                	sd	t3,216(sp)
    8000519a:	f1f6                	sd	t4,224(sp)
    8000519c:	f5fa                	sd	t5,232(sp)
    8000519e:	f9fe                	sd	t6,240(sp)
    800051a0:	ce3fc0ef          	jal	ra,80001e82 <kerneltrap>
    800051a4:	6082                	ld	ra,0(sp)
    800051a6:	6122                	ld	sp,8(sp)
    800051a8:	61c2                	ld	gp,16(sp)
    800051aa:	7282                	ld	t0,32(sp)
    800051ac:	7322                	ld	t1,40(sp)
    800051ae:	73c2                	ld	t2,48(sp)
    800051b0:	7462                	ld	s0,56(sp)
    800051b2:	6486                	ld	s1,64(sp)
    800051b4:	6526                	ld	a0,72(sp)
    800051b6:	65c6                	ld	a1,80(sp)
    800051b8:	6666                	ld	a2,88(sp)
    800051ba:	7686                	ld	a3,96(sp)
    800051bc:	7726                	ld	a4,104(sp)
    800051be:	77c6                	ld	a5,112(sp)
    800051c0:	7866                	ld	a6,120(sp)
    800051c2:	688a                	ld	a7,128(sp)
    800051c4:	692a                	ld	s2,136(sp)
    800051c6:	69ca                	ld	s3,144(sp)
    800051c8:	6a6a                	ld	s4,152(sp)
    800051ca:	7a8a                	ld	s5,160(sp)
    800051cc:	7b2a                	ld	s6,168(sp)
    800051ce:	7bca                	ld	s7,176(sp)
    800051d0:	7c6a                	ld	s8,184(sp)
    800051d2:	6c8e                	ld	s9,192(sp)
    800051d4:	6d2e                	ld	s10,200(sp)
    800051d6:	6dce                	ld	s11,208(sp)
    800051d8:	6e6e                	ld	t3,216(sp)
    800051da:	7e8e                	ld	t4,224(sp)
    800051dc:	7f2e                	ld	t5,232(sp)
    800051de:	7fce                	ld	t6,240(sp)
    800051e0:	6111                	addi	sp,sp,256
    800051e2:	10200073          	sret
    800051e6:	00000013          	nop
    800051ea:	00000013          	nop
    800051ee:	0001                	nop

00000000800051f0 <timervec>:
    800051f0:	34051573          	csrrw	a0,mscratch,a0
    800051f4:	e10c                	sd	a1,0(a0)
    800051f6:	e510                	sd	a2,8(a0)
    800051f8:	e914                	sd	a3,16(a0)
    800051fa:	6d0c                	ld	a1,24(a0)
    800051fc:	7110                	ld	a2,32(a0)
    800051fe:	6194                	ld	a3,0(a1)
    80005200:	96b2                	add	a3,a3,a2
    80005202:	e194                	sd	a3,0(a1)
    80005204:	4589                	li	a1,2
    80005206:	14459073          	csrw	sip,a1
    8000520a:	6914                	ld	a3,16(a0)
    8000520c:	6510                	ld	a2,8(a0)
    8000520e:	610c                	ld	a1,0(a0)
    80005210:	34051573          	csrrw	a0,mscratch,a0
    80005214:	30200073          	mret
	...

000000008000521a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000521a:	1141                	addi	sp,sp,-16
    8000521c:	e422                	sd	s0,8(sp)
    8000521e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005220:	0c0007b7          	lui	a5,0xc000
    80005224:	4705                	li	a4,1
    80005226:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005228:	c3d8                	sw	a4,4(a5)
}
    8000522a:	6422                	ld	s0,8(sp)
    8000522c:	0141                	addi	sp,sp,16
    8000522e:	8082                	ret

0000000080005230 <plicinithart>:

void
plicinithart(void)
{
    80005230:	1141                	addi	sp,sp,-16
    80005232:	e406                	sd	ra,8(sp)
    80005234:	e022                	sd	s0,0(sp)
    80005236:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005238:	ffffc097          	auipc	ra,0xffffc
    8000523c:	d40080e7          	jalr	-704(ra) # 80000f78 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005240:	0085171b          	slliw	a4,a0,0x8
    80005244:	0c0027b7          	lui	a5,0xc002
    80005248:	97ba                	add	a5,a5,a4
    8000524a:	40200713          	li	a4,1026
    8000524e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005252:	00d5151b          	slliw	a0,a0,0xd
    80005256:	0c2017b7          	lui	a5,0xc201
    8000525a:	953e                	add	a0,a0,a5
    8000525c:	00052023          	sw	zero,0(a0)
}
    80005260:	60a2                	ld	ra,8(sp)
    80005262:	6402                	ld	s0,0(sp)
    80005264:	0141                	addi	sp,sp,16
    80005266:	8082                	ret

0000000080005268 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005268:	1141                	addi	sp,sp,-16
    8000526a:	e406                	sd	ra,8(sp)
    8000526c:	e022                	sd	s0,0(sp)
    8000526e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005270:	ffffc097          	auipc	ra,0xffffc
    80005274:	d08080e7          	jalr	-760(ra) # 80000f78 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005278:	00d5179b          	slliw	a5,a0,0xd
    8000527c:	0c201537          	lui	a0,0xc201
    80005280:	953e                	add	a0,a0,a5
  return irq;
}
    80005282:	4148                	lw	a0,4(a0)
    80005284:	60a2                	ld	ra,8(sp)
    80005286:	6402                	ld	s0,0(sp)
    80005288:	0141                	addi	sp,sp,16
    8000528a:	8082                	ret

000000008000528c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000528c:	1101                	addi	sp,sp,-32
    8000528e:	ec06                	sd	ra,24(sp)
    80005290:	e822                	sd	s0,16(sp)
    80005292:	e426                	sd	s1,8(sp)
    80005294:	1000                	addi	s0,sp,32
    80005296:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005298:	ffffc097          	auipc	ra,0xffffc
    8000529c:	ce0080e7          	jalr	-800(ra) # 80000f78 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800052a0:	00d5151b          	slliw	a0,a0,0xd
    800052a4:	0c2017b7          	lui	a5,0xc201
    800052a8:	97aa                	add	a5,a5,a0
    800052aa:	c3c4                	sw	s1,4(a5)
}
    800052ac:	60e2                	ld	ra,24(sp)
    800052ae:	6442                	ld	s0,16(sp)
    800052b0:	64a2                	ld	s1,8(sp)
    800052b2:	6105                	addi	sp,sp,32
    800052b4:	8082                	ret

00000000800052b6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800052b6:	1141                	addi	sp,sp,-16
    800052b8:	e406                	sd	ra,8(sp)
    800052ba:	e022                	sd	s0,0(sp)
    800052bc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800052be:	479d                	li	a5,7
    800052c0:	06a7c963          	blt	a5,a0,80005332 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    800052c4:	00019797          	auipc	a5,0x19
    800052c8:	d3c78793          	addi	a5,a5,-708 # 8001e000 <disk>
    800052cc:	00a78733          	add	a4,a5,a0
    800052d0:	6789                	lui	a5,0x2
    800052d2:	97ba                	add	a5,a5,a4
    800052d4:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    800052d8:	e7ad                	bnez	a5,80005342 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800052da:	00451793          	slli	a5,a0,0x4
    800052de:	0001b717          	auipc	a4,0x1b
    800052e2:	d2270713          	addi	a4,a4,-734 # 80020000 <disk+0x2000>
    800052e6:	6314                	ld	a3,0(a4)
    800052e8:	96be                	add	a3,a3,a5
    800052ea:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    800052ee:	6314                	ld	a3,0(a4)
    800052f0:	96be                	add	a3,a3,a5
    800052f2:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    800052f6:	6314                	ld	a3,0(a4)
    800052f8:	96be                	add	a3,a3,a5
    800052fa:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    800052fe:	6318                	ld	a4,0(a4)
    80005300:	97ba                	add	a5,a5,a4
    80005302:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80005306:	00019797          	auipc	a5,0x19
    8000530a:	cfa78793          	addi	a5,a5,-774 # 8001e000 <disk>
    8000530e:	97aa                	add	a5,a5,a0
    80005310:	6509                	lui	a0,0x2
    80005312:	953e                	add	a0,a0,a5
    80005314:	4785                	li	a5,1
    80005316:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    8000531a:	0001b517          	auipc	a0,0x1b
    8000531e:	cfe50513          	addi	a0,a0,-770 # 80020018 <disk+0x2018>
    80005322:	ffffc097          	auipc	ra,0xffffc
    80005326:	4ca080e7          	jalr	1226(ra) # 800017ec <wakeup>
}
    8000532a:	60a2                	ld	ra,8(sp)
    8000532c:	6402                	ld	s0,0(sp)
    8000532e:	0141                	addi	sp,sp,16
    80005330:	8082                	ret
    panic("free_desc 1");
    80005332:	00003517          	auipc	a0,0x3
    80005336:	3c650513          	addi	a0,a0,966 # 800086f8 <syscalls+0x328>
    8000533a:	00001097          	auipc	ra,0x1
    8000533e:	d52080e7          	jalr	-686(ra) # 8000608c <panic>
    panic("free_desc 2");
    80005342:	00003517          	auipc	a0,0x3
    80005346:	3c650513          	addi	a0,a0,966 # 80008708 <syscalls+0x338>
    8000534a:	00001097          	auipc	ra,0x1
    8000534e:	d42080e7          	jalr	-702(ra) # 8000608c <panic>

0000000080005352 <virtio_disk_init>:
{
    80005352:	1101                	addi	sp,sp,-32
    80005354:	ec06                	sd	ra,24(sp)
    80005356:	e822                	sd	s0,16(sp)
    80005358:	e426                	sd	s1,8(sp)
    8000535a:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000535c:	00003597          	auipc	a1,0x3
    80005360:	3bc58593          	addi	a1,a1,956 # 80008718 <syscalls+0x348>
    80005364:	0001b517          	auipc	a0,0x1b
    80005368:	dc450513          	addi	a0,a0,-572 # 80020128 <disk+0x2128>
    8000536c:	00001097          	auipc	ra,0x1
    80005370:	3d0080e7          	jalr	976(ra) # 8000673c <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005374:	100017b7          	lui	a5,0x10001
    80005378:	4398                	lw	a4,0(a5)
    8000537a:	2701                	sext.w	a4,a4
    8000537c:	747277b7          	lui	a5,0x74727
    80005380:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005384:	0ef71163          	bne	a4,a5,80005466 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005388:	100017b7          	lui	a5,0x10001
    8000538c:	43dc                	lw	a5,4(a5)
    8000538e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005390:	4705                	li	a4,1
    80005392:	0ce79a63          	bne	a5,a4,80005466 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005396:	100017b7          	lui	a5,0x10001
    8000539a:	479c                	lw	a5,8(a5)
    8000539c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    8000539e:	4709                	li	a4,2
    800053a0:	0ce79363          	bne	a5,a4,80005466 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800053a4:	100017b7          	lui	a5,0x10001
    800053a8:	47d8                	lw	a4,12(a5)
    800053aa:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800053ac:	554d47b7          	lui	a5,0x554d4
    800053b0:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800053b4:	0af71963          	bne	a4,a5,80005466 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    800053b8:	100017b7          	lui	a5,0x10001
    800053bc:	4705                	li	a4,1
    800053be:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800053c0:	470d                	li	a4,3
    800053c2:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800053c4:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800053c6:	c7ffe737          	lui	a4,0xc7ffe
    800053ca:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd3517>
    800053ce:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800053d0:	2701                	sext.w	a4,a4
    800053d2:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800053d4:	472d                	li	a4,11
    800053d6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800053d8:	473d                	li	a4,15
    800053da:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    800053dc:	6705                	lui	a4,0x1
    800053de:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800053e0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800053e4:	5bdc                	lw	a5,52(a5)
    800053e6:	2781                	sext.w	a5,a5
  if(max == 0)
    800053e8:	c7d9                	beqz	a5,80005476 <virtio_disk_init+0x124>
  if(max < NUM)
    800053ea:	471d                	li	a4,7
    800053ec:	08f77d63          	bgeu	a4,a5,80005486 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800053f0:	100014b7          	lui	s1,0x10001
    800053f4:	47a1                	li	a5,8
    800053f6:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    800053f8:	6609                	lui	a2,0x2
    800053fa:	4581                	li	a1,0
    800053fc:	00019517          	auipc	a0,0x19
    80005400:	c0450513          	addi	a0,a0,-1020 # 8001e000 <disk>
    80005404:	ffffb097          	auipc	ra,0xffffb
    80005408:	ec0080e7          	jalr	-320(ra) # 800002c4 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    8000540c:	00019717          	auipc	a4,0x19
    80005410:	bf470713          	addi	a4,a4,-1036 # 8001e000 <disk>
    80005414:	00c75793          	srli	a5,a4,0xc
    80005418:	2781                	sext.w	a5,a5
    8000541a:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    8000541c:	0001b797          	auipc	a5,0x1b
    80005420:	be478793          	addi	a5,a5,-1052 # 80020000 <disk+0x2000>
    80005424:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80005426:	00019717          	auipc	a4,0x19
    8000542a:	c5a70713          	addi	a4,a4,-934 # 8001e080 <disk+0x80>
    8000542e:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80005430:	0001a717          	auipc	a4,0x1a
    80005434:	bd070713          	addi	a4,a4,-1072 # 8001f000 <disk+0x1000>
    80005438:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    8000543a:	4705                	li	a4,1
    8000543c:	00e78c23          	sb	a4,24(a5)
    80005440:	00e78ca3          	sb	a4,25(a5)
    80005444:	00e78d23          	sb	a4,26(a5)
    80005448:	00e78da3          	sb	a4,27(a5)
    8000544c:	00e78e23          	sb	a4,28(a5)
    80005450:	00e78ea3          	sb	a4,29(a5)
    80005454:	00e78f23          	sb	a4,30(a5)
    80005458:	00e78fa3          	sb	a4,31(a5)
}
    8000545c:	60e2                	ld	ra,24(sp)
    8000545e:	6442                	ld	s0,16(sp)
    80005460:	64a2                	ld	s1,8(sp)
    80005462:	6105                	addi	sp,sp,32
    80005464:	8082                	ret
    panic("could not find virtio disk");
    80005466:	00003517          	auipc	a0,0x3
    8000546a:	2c250513          	addi	a0,a0,706 # 80008728 <syscalls+0x358>
    8000546e:	00001097          	auipc	ra,0x1
    80005472:	c1e080e7          	jalr	-994(ra) # 8000608c <panic>
    panic("virtio disk has no queue 0");
    80005476:	00003517          	auipc	a0,0x3
    8000547a:	2d250513          	addi	a0,a0,722 # 80008748 <syscalls+0x378>
    8000547e:	00001097          	auipc	ra,0x1
    80005482:	c0e080e7          	jalr	-1010(ra) # 8000608c <panic>
    panic("virtio disk max queue too short");
    80005486:	00003517          	auipc	a0,0x3
    8000548a:	2e250513          	addi	a0,a0,738 # 80008768 <syscalls+0x398>
    8000548e:	00001097          	auipc	ra,0x1
    80005492:	bfe080e7          	jalr	-1026(ra) # 8000608c <panic>

0000000080005496 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005496:	7159                	addi	sp,sp,-112
    80005498:	f486                	sd	ra,104(sp)
    8000549a:	f0a2                	sd	s0,96(sp)
    8000549c:	eca6                	sd	s1,88(sp)
    8000549e:	e8ca                	sd	s2,80(sp)
    800054a0:	e4ce                	sd	s3,72(sp)
    800054a2:	e0d2                	sd	s4,64(sp)
    800054a4:	fc56                	sd	s5,56(sp)
    800054a6:	f85a                	sd	s6,48(sp)
    800054a8:	f45e                	sd	s7,40(sp)
    800054aa:	f062                	sd	s8,32(sp)
    800054ac:	ec66                	sd	s9,24(sp)
    800054ae:	e86a                	sd	s10,16(sp)
    800054b0:	1880                	addi	s0,sp,112
    800054b2:	892a                	mv	s2,a0
    800054b4:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800054b6:	01052c83          	lw	s9,16(a0)
    800054ba:	001c9c9b          	slliw	s9,s9,0x1
    800054be:	1c82                	slli	s9,s9,0x20
    800054c0:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800054c4:	0001b517          	auipc	a0,0x1b
    800054c8:	c6450513          	addi	a0,a0,-924 # 80020128 <disk+0x2128>
    800054cc:	00001097          	auipc	ra,0x1
    800054d0:	0f4080e7          	jalr	244(ra) # 800065c0 <acquire>
  for(int i = 0; i < 3; i++){
    800054d4:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800054d6:	4c21                	li	s8,8
      disk.free[i] = 0;
    800054d8:	00019b97          	auipc	s7,0x19
    800054dc:	b28b8b93          	addi	s7,s7,-1240 # 8001e000 <disk>
    800054e0:	6b09                	lui	s6,0x2
  for(int i = 0; i < 3; i++){
    800054e2:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    800054e4:	8a4e                	mv	s4,s3
    800054e6:	a051                	j	8000556a <virtio_disk_rw+0xd4>
      disk.free[i] = 0;
    800054e8:	00fb86b3          	add	a3,s7,a5
    800054ec:	96da                	add	a3,a3,s6
    800054ee:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    800054f2:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    800054f4:	0207c563          	bltz	a5,8000551e <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    800054f8:	2485                	addiw	s1,s1,1
    800054fa:	0711                	addi	a4,a4,4
    800054fc:	25548063          	beq	s1,s5,8000573c <virtio_disk_rw+0x2a6>
    idx[i] = alloc_desc();
    80005500:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80005502:	0001b697          	auipc	a3,0x1b
    80005506:	b1668693          	addi	a3,a3,-1258 # 80020018 <disk+0x2018>
    8000550a:	87d2                	mv	a5,s4
    if(disk.free[i]){
    8000550c:	0006c583          	lbu	a1,0(a3)
    80005510:	fde1                	bnez	a1,800054e8 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80005512:	2785                	addiw	a5,a5,1
    80005514:	0685                	addi	a3,a3,1
    80005516:	ff879be3          	bne	a5,s8,8000550c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000551a:	57fd                	li	a5,-1
    8000551c:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    8000551e:	02905a63          	blez	s1,80005552 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80005522:	f9042503          	lw	a0,-112(s0)
    80005526:	00000097          	auipc	ra,0x0
    8000552a:	d90080e7          	jalr	-624(ra) # 800052b6 <free_desc>
      for(int j = 0; j < i; j++)
    8000552e:	4785                	li	a5,1
    80005530:	0297d163          	bge	a5,s1,80005552 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80005534:	f9442503          	lw	a0,-108(s0)
    80005538:	00000097          	auipc	ra,0x0
    8000553c:	d7e080e7          	jalr	-642(ra) # 800052b6 <free_desc>
      for(int j = 0; j < i; j++)
    80005540:	4789                	li	a5,2
    80005542:	0097d863          	bge	a5,s1,80005552 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80005546:	f9842503          	lw	a0,-104(s0)
    8000554a:	00000097          	auipc	ra,0x0
    8000554e:	d6c080e7          	jalr	-660(ra) # 800052b6 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005552:	0001b597          	auipc	a1,0x1b
    80005556:	bd658593          	addi	a1,a1,-1066 # 80020128 <disk+0x2128>
    8000555a:	0001b517          	auipc	a0,0x1b
    8000555e:	abe50513          	addi	a0,a0,-1346 # 80020018 <disk+0x2018>
    80005562:	ffffc097          	auipc	ra,0xffffc
    80005566:	0fe080e7          	jalr	254(ra) # 80001660 <sleep>
  for(int i = 0; i < 3; i++){
    8000556a:	f9040713          	addi	a4,s0,-112
    8000556e:	84ce                	mv	s1,s3
    80005570:	bf41                	j	80005500 <virtio_disk_rw+0x6a>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    80005572:	20058713          	addi	a4,a1,512
    80005576:	00471693          	slli	a3,a4,0x4
    8000557a:	00019717          	auipc	a4,0x19
    8000557e:	a8670713          	addi	a4,a4,-1402 # 8001e000 <disk>
    80005582:	9736                	add	a4,a4,a3
    80005584:	4685                	li	a3,1
    80005586:	0ad72423          	sw	a3,168(a4)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    8000558a:	20058713          	addi	a4,a1,512
    8000558e:	00471693          	slli	a3,a4,0x4
    80005592:	00019717          	auipc	a4,0x19
    80005596:	a6e70713          	addi	a4,a4,-1426 # 8001e000 <disk>
    8000559a:	9736                	add	a4,a4,a3
    8000559c:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    800055a0:	0b973823          	sd	s9,176(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800055a4:	7679                	lui	a2,0xffffe
    800055a6:	963e                	add	a2,a2,a5
    800055a8:	0001b697          	auipc	a3,0x1b
    800055ac:	a5868693          	addi	a3,a3,-1448 # 80020000 <disk+0x2000>
    800055b0:	6298                	ld	a4,0(a3)
    800055b2:	9732                	add	a4,a4,a2
    800055b4:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800055b6:	6298                	ld	a4,0(a3)
    800055b8:	9732                	add	a4,a4,a2
    800055ba:	4541                	li	a0,16
    800055bc:	c708                	sw	a0,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800055be:	6298                	ld	a4,0(a3)
    800055c0:	9732                	add	a4,a4,a2
    800055c2:	4505                	li	a0,1
    800055c4:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[0]].next = idx[1];
    800055c8:	f9442703          	lw	a4,-108(s0)
    800055cc:	6288                	ld	a0,0(a3)
    800055ce:	962a                	add	a2,a2,a0
    800055d0:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd2dc6>

  disk.desc[idx[1]].addr = (uint64) b->data;
    800055d4:	0712                	slli	a4,a4,0x4
    800055d6:	6290                	ld	a2,0(a3)
    800055d8:	963a                	add	a2,a2,a4
    800055da:	06890513          	addi	a0,s2,104
    800055de:	e208                	sd	a0,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800055e0:	6294                	ld	a3,0(a3)
    800055e2:	96ba                	add	a3,a3,a4
    800055e4:	40000613          	li	a2,1024
    800055e8:	c690                	sw	a2,8(a3)
  if(write)
    800055ea:	140d0063          	beqz	s10,8000572a <virtio_disk_rw+0x294>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    800055ee:	0001b697          	auipc	a3,0x1b
    800055f2:	a126b683          	ld	a3,-1518(a3) # 80020000 <disk+0x2000>
    800055f6:	96ba                	add	a3,a3,a4
    800055f8:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800055fc:	00019817          	auipc	a6,0x19
    80005600:	a0480813          	addi	a6,a6,-1532 # 8001e000 <disk>
    80005604:	0001b517          	auipc	a0,0x1b
    80005608:	9fc50513          	addi	a0,a0,-1540 # 80020000 <disk+0x2000>
    8000560c:	6114                	ld	a3,0(a0)
    8000560e:	96ba                	add	a3,a3,a4
    80005610:	00c6d603          	lhu	a2,12(a3)
    80005614:	00166613          	ori	a2,a2,1
    80005618:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    8000561c:	f9842683          	lw	a3,-104(s0)
    80005620:	6110                	ld	a2,0(a0)
    80005622:	9732                	add	a4,a4,a2
    80005624:	00d71723          	sh	a3,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005628:	20058613          	addi	a2,a1,512
    8000562c:	0612                	slli	a2,a2,0x4
    8000562e:	9642                	add	a2,a2,a6
    80005630:	577d                	li	a4,-1
    80005632:	02e60823          	sb	a4,48(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005636:	00469713          	slli	a4,a3,0x4
    8000563a:	6114                	ld	a3,0(a0)
    8000563c:	96ba                	add	a3,a3,a4
    8000563e:	03078793          	addi	a5,a5,48
    80005642:	97c2                	add	a5,a5,a6
    80005644:	e29c                	sd	a5,0(a3)
  disk.desc[idx[2]].len = 1;
    80005646:	611c                	ld	a5,0(a0)
    80005648:	97ba                	add	a5,a5,a4
    8000564a:	4685                	li	a3,1
    8000564c:	c794                	sw	a3,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000564e:	611c                	ld	a5,0(a0)
    80005650:	97ba                	add	a5,a5,a4
    80005652:	4809                	li	a6,2
    80005654:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80005658:	611c                	ld	a5,0(a0)
    8000565a:	973e                	add	a4,a4,a5
    8000565c:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005660:	00d92423          	sw	a3,8(s2)
  disk.info[idx[0]].b = b;
    80005664:	03263423          	sd	s2,40(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005668:	6518                	ld	a4,8(a0)
    8000566a:	00275783          	lhu	a5,2(a4)
    8000566e:	8b9d                	andi	a5,a5,7
    80005670:	0786                	slli	a5,a5,0x1
    80005672:	97ba                	add	a5,a5,a4
    80005674:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80005678:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000567c:	6518                	ld	a4,8(a0)
    8000567e:	00275783          	lhu	a5,2(a4)
    80005682:	2785                	addiw	a5,a5,1
    80005684:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005688:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000568c:	100017b7          	lui	a5,0x10001
    80005690:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005694:	00892703          	lw	a4,8(s2)
    80005698:	4785                	li	a5,1
    8000569a:	02f71163          	bne	a4,a5,800056bc <virtio_disk_rw+0x226>
    sleep(b, &disk.vdisk_lock);
    8000569e:	0001b997          	auipc	s3,0x1b
    800056a2:	a8a98993          	addi	s3,s3,-1398 # 80020128 <disk+0x2128>
  while(b->disk == 1) {
    800056a6:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800056a8:	85ce                	mv	a1,s3
    800056aa:	854a                	mv	a0,s2
    800056ac:	ffffc097          	auipc	ra,0xffffc
    800056b0:	fb4080e7          	jalr	-76(ra) # 80001660 <sleep>
  while(b->disk == 1) {
    800056b4:	00892783          	lw	a5,8(s2)
    800056b8:	fe9788e3          	beq	a5,s1,800056a8 <virtio_disk_rw+0x212>
  }

  disk.info[idx[0]].b = 0;
    800056bc:	f9042903          	lw	s2,-112(s0)
    800056c0:	20090793          	addi	a5,s2,512
    800056c4:	00479713          	slli	a4,a5,0x4
    800056c8:	00019797          	auipc	a5,0x19
    800056cc:	93878793          	addi	a5,a5,-1736 # 8001e000 <disk>
    800056d0:	97ba                	add	a5,a5,a4
    800056d2:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    800056d6:	0001b997          	auipc	s3,0x1b
    800056da:	92a98993          	addi	s3,s3,-1750 # 80020000 <disk+0x2000>
    800056de:	00491713          	slli	a4,s2,0x4
    800056e2:	0009b783          	ld	a5,0(s3)
    800056e6:	97ba                	add	a5,a5,a4
    800056e8:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800056ec:	854a                	mv	a0,s2
    800056ee:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800056f2:	00000097          	auipc	ra,0x0
    800056f6:	bc4080e7          	jalr	-1084(ra) # 800052b6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800056fa:	8885                	andi	s1,s1,1
    800056fc:	f0ed                	bnez	s1,800056de <virtio_disk_rw+0x248>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800056fe:	0001b517          	auipc	a0,0x1b
    80005702:	a2a50513          	addi	a0,a0,-1494 # 80020128 <disk+0x2128>
    80005706:	00001097          	auipc	ra,0x1
    8000570a:	f8a080e7          	jalr	-118(ra) # 80006690 <release>
}
    8000570e:	70a6                	ld	ra,104(sp)
    80005710:	7406                	ld	s0,96(sp)
    80005712:	64e6                	ld	s1,88(sp)
    80005714:	6946                	ld	s2,80(sp)
    80005716:	69a6                	ld	s3,72(sp)
    80005718:	6a06                	ld	s4,64(sp)
    8000571a:	7ae2                	ld	s5,56(sp)
    8000571c:	7b42                	ld	s6,48(sp)
    8000571e:	7ba2                	ld	s7,40(sp)
    80005720:	7c02                	ld	s8,32(sp)
    80005722:	6ce2                	ld	s9,24(sp)
    80005724:	6d42                	ld	s10,16(sp)
    80005726:	6165                	addi	sp,sp,112
    80005728:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000572a:	0001b697          	auipc	a3,0x1b
    8000572e:	8d66b683          	ld	a3,-1834(a3) # 80020000 <disk+0x2000>
    80005732:	96ba                	add	a3,a3,a4
    80005734:	4609                	li	a2,2
    80005736:	00c69623          	sh	a2,12(a3)
    8000573a:	b5c9                	j	800055fc <virtio_disk_rw+0x166>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000573c:	f9042583          	lw	a1,-112(s0)
    80005740:	20058793          	addi	a5,a1,512
    80005744:	0792                	slli	a5,a5,0x4
    80005746:	00019517          	auipc	a0,0x19
    8000574a:	96250513          	addi	a0,a0,-1694 # 8001e0a8 <disk+0xa8>
    8000574e:	953e                	add	a0,a0,a5
  if(write)
    80005750:	e20d11e3          	bnez	s10,80005572 <virtio_disk_rw+0xdc>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    80005754:	20058713          	addi	a4,a1,512
    80005758:	00471693          	slli	a3,a4,0x4
    8000575c:	00019717          	auipc	a4,0x19
    80005760:	8a470713          	addi	a4,a4,-1884 # 8001e000 <disk>
    80005764:	9736                	add	a4,a4,a3
    80005766:	0a072423          	sw	zero,168(a4)
    8000576a:	b505                	j	8000558a <virtio_disk_rw+0xf4>

000000008000576c <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000576c:	1101                	addi	sp,sp,-32
    8000576e:	ec06                	sd	ra,24(sp)
    80005770:	e822                	sd	s0,16(sp)
    80005772:	e426                	sd	s1,8(sp)
    80005774:	e04a                	sd	s2,0(sp)
    80005776:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005778:	0001b517          	auipc	a0,0x1b
    8000577c:	9b050513          	addi	a0,a0,-1616 # 80020128 <disk+0x2128>
    80005780:	00001097          	auipc	ra,0x1
    80005784:	e40080e7          	jalr	-448(ra) # 800065c0 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005788:	10001737          	lui	a4,0x10001
    8000578c:	533c                	lw	a5,96(a4)
    8000578e:	8b8d                	andi	a5,a5,3
    80005790:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80005792:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005796:	0001b797          	auipc	a5,0x1b
    8000579a:	86a78793          	addi	a5,a5,-1942 # 80020000 <disk+0x2000>
    8000579e:	6b94                	ld	a3,16(a5)
    800057a0:	0207d703          	lhu	a4,32(a5)
    800057a4:	0026d783          	lhu	a5,2(a3)
    800057a8:	06f70163          	beq	a4,a5,8000580a <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800057ac:	00019917          	auipc	s2,0x19
    800057b0:	85490913          	addi	s2,s2,-1964 # 8001e000 <disk>
    800057b4:	0001b497          	auipc	s1,0x1b
    800057b8:	84c48493          	addi	s1,s1,-1972 # 80020000 <disk+0x2000>
    __sync_synchronize();
    800057bc:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800057c0:	6898                	ld	a4,16(s1)
    800057c2:	0204d783          	lhu	a5,32(s1)
    800057c6:	8b9d                	andi	a5,a5,7
    800057c8:	078e                	slli	a5,a5,0x3
    800057ca:	97ba                	add	a5,a5,a4
    800057cc:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800057ce:	20078713          	addi	a4,a5,512
    800057d2:	0712                	slli	a4,a4,0x4
    800057d4:	974a                	add	a4,a4,s2
    800057d6:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    800057da:	e731                	bnez	a4,80005826 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800057dc:	20078793          	addi	a5,a5,512
    800057e0:	0792                	slli	a5,a5,0x4
    800057e2:	97ca                	add	a5,a5,s2
    800057e4:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    800057e6:	00052423          	sw	zero,8(a0)
    wakeup(b);
    800057ea:	ffffc097          	auipc	ra,0xffffc
    800057ee:	002080e7          	jalr	2(ra) # 800017ec <wakeup>

    disk.used_idx += 1;
    800057f2:	0204d783          	lhu	a5,32(s1)
    800057f6:	2785                	addiw	a5,a5,1
    800057f8:	17c2                	slli	a5,a5,0x30
    800057fa:	93c1                	srli	a5,a5,0x30
    800057fc:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005800:	6898                	ld	a4,16(s1)
    80005802:	00275703          	lhu	a4,2(a4)
    80005806:	faf71be3          	bne	a4,a5,800057bc <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    8000580a:	0001b517          	auipc	a0,0x1b
    8000580e:	91e50513          	addi	a0,a0,-1762 # 80020128 <disk+0x2128>
    80005812:	00001097          	auipc	ra,0x1
    80005816:	e7e080e7          	jalr	-386(ra) # 80006690 <release>
}
    8000581a:	60e2                	ld	ra,24(sp)
    8000581c:	6442                	ld	s0,16(sp)
    8000581e:	64a2                	ld	s1,8(sp)
    80005820:	6902                	ld	s2,0(sp)
    80005822:	6105                	addi	sp,sp,32
    80005824:	8082                	ret
      panic("virtio_disk_intr status");
    80005826:	00003517          	auipc	a0,0x3
    8000582a:	f6250513          	addi	a0,a0,-158 # 80008788 <syscalls+0x3b8>
    8000582e:	00001097          	auipc	ra,0x1
    80005832:	85e080e7          	jalr	-1954(ra) # 8000608c <panic>

0000000080005836 <statswrite>:
int statscopyin(char*, int);
int statslock(char*, int);
  
int
statswrite(int user_src, uint64 src, int n)
{
    80005836:	1141                	addi	sp,sp,-16
    80005838:	e422                	sd	s0,8(sp)
    8000583a:	0800                	addi	s0,sp,16
  return -1;
}
    8000583c:	557d                	li	a0,-1
    8000583e:	6422                	ld	s0,8(sp)
    80005840:	0141                	addi	sp,sp,16
    80005842:	8082                	ret

0000000080005844 <statsread>:

int
statsread(int user_dst, uint64 dst, int n)
{
    80005844:	7179                	addi	sp,sp,-48
    80005846:	f406                	sd	ra,40(sp)
    80005848:	f022                	sd	s0,32(sp)
    8000584a:	ec26                	sd	s1,24(sp)
    8000584c:	e84a                	sd	s2,16(sp)
    8000584e:	e44e                	sd	s3,8(sp)
    80005850:	e052                	sd	s4,0(sp)
    80005852:	1800                	addi	s0,sp,48
    80005854:	892a                	mv	s2,a0
    80005856:	89ae                	mv	s3,a1
    80005858:	84b2                	mv	s1,a2
  int m;

  acquire(&stats.lock);
    8000585a:	0001b517          	auipc	a0,0x1b
    8000585e:	7a650513          	addi	a0,a0,1958 # 80021000 <stats>
    80005862:	00001097          	auipc	ra,0x1
    80005866:	d5e080e7          	jalr	-674(ra) # 800065c0 <acquire>

  if(stats.sz == 0) {
    8000586a:	0001c797          	auipc	a5,0x1c
    8000586e:	7b67a783          	lw	a5,1974(a5) # 80022020 <stats+0x1020>
    80005872:	cbb5                	beqz	a5,800058e6 <statsread+0xa2>
#endif
#ifdef LAB_LOCK
    stats.sz = statslock(stats.buf, BUFSZ);
#endif
  }
  m = stats.sz - stats.off;
    80005874:	0001c797          	auipc	a5,0x1c
    80005878:	78c78793          	addi	a5,a5,1932 # 80022000 <stats+0x1000>
    8000587c:	53d8                	lw	a4,36(a5)
    8000587e:	539c                	lw	a5,32(a5)
    80005880:	9f99                	subw	a5,a5,a4
    80005882:	0007869b          	sext.w	a3,a5

  if (m > 0) {
    80005886:	06d05e63          	blez	a3,80005902 <statsread+0xbe>
    if(m > n)
    8000588a:	8a3e                	mv	s4,a5
    8000588c:	00d4d363          	bge	s1,a3,80005892 <statsread+0x4e>
    80005890:	8a26                	mv	s4,s1
    80005892:	000a049b          	sext.w	s1,s4
      m  = n;
    if(either_copyout(user_dst, dst, stats.buf+stats.off, m) != -1) {
    80005896:	86a6                	mv	a3,s1
    80005898:	0001b617          	auipc	a2,0x1b
    8000589c:	78860613          	addi	a2,a2,1928 # 80021020 <stats+0x20>
    800058a0:	963a                	add	a2,a2,a4
    800058a2:	85ce                	mv	a1,s3
    800058a4:	854a                	mv	a0,s2
    800058a6:	ffffc097          	auipc	ra,0xffffc
    800058aa:	15e080e7          	jalr	350(ra) # 80001a04 <either_copyout>
    800058ae:	57fd                	li	a5,-1
    800058b0:	00f50a63          	beq	a0,a5,800058c4 <statsread+0x80>
      stats.off += m;
    800058b4:	0001c717          	auipc	a4,0x1c
    800058b8:	74c70713          	addi	a4,a4,1868 # 80022000 <stats+0x1000>
    800058bc:	535c                	lw	a5,36(a4)
    800058be:	014787bb          	addw	a5,a5,s4
    800058c2:	d35c                	sw	a5,36(a4)
  } else {
    m = -1;
    stats.sz = 0;
    stats.off = 0;
  }
  release(&stats.lock);
    800058c4:	0001b517          	auipc	a0,0x1b
    800058c8:	73c50513          	addi	a0,a0,1852 # 80021000 <stats>
    800058cc:	00001097          	auipc	ra,0x1
    800058d0:	dc4080e7          	jalr	-572(ra) # 80006690 <release>
  return m;
}
    800058d4:	8526                	mv	a0,s1
    800058d6:	70a2                	ld	ra,40(sp)
    800058d8:	7402                	ld	s0,32(sp)
    800058da:	64e2                	ld	s1,24(sp)
    800058dc:	6942                	ld	s2,16(sp)
    800058de:	69a2                	ld	s3,8(sp)
    800058e0:	6a02                	ld	s4,0(sp)
    800058e2:	6145                	addi	sp,sp,48
    800058e4:	8082                	ret
    stats.sz = statslock(stats.buf, BUFSZ);
    800058e6:	6585                	lui	a1,0x1
    800058e8:	0001b517          	auipc	a0,0x1b
    800058ec:	73850513          	addi	a0,a0,1848 # 80021020 <stats+0x20>
    800058f0:	00001097          	auipc	ra,0x1
    800058f4:	f28080e7          	jalr	-216(ra) # 80006818 <statslock>
    800058f8:	0001c797          	auipc	a5,0x1c
    800058fc:	72a7a423          	sw	a0,1832(a5) # 80022020 <stats+0x1020>
    80005900:	bf95                	j	80005874 <statsread+0x30>
    stats.sz = 0;
    80005902:	0001c797          	auipc	a5,0x1c
    80005906:	6fe78793          	addi	a5,a5,1790 # 80022000 <stats+0x1000>
    8000590a:	0207a023          	sw	zero,32(a5)
    stats.off = 0;
    8000590e:	0207a223          	sw	zero,36(a5)
    m = -1;
    80005912:	54fd                	li	s1,-1
    80005914:	bf45                	j	800058c4 <statsread+0x80>

0000000080005916 <statsinit>:

void
statsinit(void)
{
    80005916:	1141                	addi	sp,sp,-16
    80005918:	e406                	sd	ra,8(sp)
    8000591a:	e022                	sd	s0,0(sp)
    8000591c:	0800                	addi	s0,sp,16
  initlock(&stats.lock, "stats");
    8000591e:	00003597          	auipc	a1,0x3
    80005922:	e8258593          	addi	a1,a1,-382 # 800087a0 <syscalls+0x3d0>
    80005926:	0001b517          	auipc	a0,0x1b
    8000592a:	6da50513          	addi	a0,a0,1754 # 80021000 <stats>
    8000592e:	00001097          	auipc	ra,0x1
    80005932:	e0e080e7          	jalr	-498(ra) # 8000673c <initlock>

  devsw[STATS].read = statsread;
    80005936:	00017797          	auipc	a5,0x17
    8000593a:	4c278793          	addi	a5,a5,1218 # 8001cdf8 <devsw>
    8000593e:	00000717          	auipc	a4,0x0
    80005942:	f0670713          	addi	a4,a4,-250 # 80005844 <statsread>
    80005946:	f398                	sd	a4,32(a5)
  devsw[STATS].write = statswrite;
    80005948:	00000717          	auipc	a4,0x0
    8000594c:	eee70713          	addi	a4,a4,-274 # 80005836 <statswrite>
    80005950:	f798                	sd	a4,40(a5)
}
    80005952:	60a2                	ld	ra,8(sp)
    80005954:	6402                	ld	s0,0(sp)
    80005956:	0141                	addi	sp,sp,16
    80005958:	8082                	ret

000000008000595a <sprintint>:
  return 1;
}

static int
sprintint(char *s, int xx, int base, int sign)
{
    8000595a:	1101                	addi	sp,sp,-32
    8000595c:	ec22                	sd	s0,24(sp)
    8000595e:	1000                	addi	s0,sp,32
    80005960:	882a                	mv	a6,a0
  char buf[16];
  int i, n;
  uint x;

  if(sign && (sign = xx < 0))
    80005962:	c299                	beqz	a3,80005968 <sprintint+0xe>
    80005964:	0805c163          	bltz	a1,800059e6 <sprintint+0x8c>
    x = -xx;
  else
    x = xx;
    80005968:	2581                	sext.w	a1,a1
    8000596a:	4301                	li	t1,0

  i = 0;
    8000596c:	fe040713          	addi	a4,s0,-32
    80005970:	4501                	li	a0,0
  do {
    buf[i++] = digits[x % base];
    80005972:	2601                	sext.w	a2,a2
    80005974:	00003697          	auipc	a3,0x3
    80005978:	e4c68693          	addi	a3,a3,-436 # 800087c0 <digits>
    8000597c:	88aa                	mv	a7,a0
    8000597e:	2505                	addiw	a0,a0,1
    80005980:	02c5f7bb          	remuw	a5,a1,a2
    80005984:	1782                	slli	a5,a5,0x20
    80005986:	9381                	srli	a5,a5,0x20
    80005988:	97b6                	add	a5,a5,a3
    8000598a:	0007c783          	lbu	a5,0(a5)
    8000598e:	00f70023          	sb	a5,0(a4)
  } while((x /= base) != 0);
    80005992:	0005879b          	sext.w	a5,a1
    80005996:	02c5d5bb          	divuw	a1,a1,a2
    8000599a:	0705                	addi	a4,a4,1
    8000599c:	fec7f0e3          	bgeu	a5,a2,8000597c <sprintint+0x22>

  if(sign)
    800059a0:	00030b63          	beqz	t1,800059b6 <sprintint+0x5c>
    buf[i++] = '-';
    800059a4:	ff040793          	addi	a5,s0,-16
    800059a8:	97aa                	add	a5,a5,a0
    800059aa:	02d00713          	li	a4,45
    800059ae:	fee78823          	sb	a4,-16(a5)
    800059b2:	0028851b          	addiw	a0,a7,2

  n = 0;
  while(--i >= 0)
    800059b6:	02a05c63          	blez	a0,800059ee <sprintint+0x94>
    800059ba:	fe040793          	addi	a5,s0,-32
    800059be:	00a78733          	add	a4,a5,a0
    800059c2:	87c2                	mv	a5,a6
    800059c4:	0805                	addi	a6,a6,1
    800059c6:	fff5061b          	addiw	a2,a0,-1
    800059ca:	1602                	slli	a2,a2,0x20
    800059cc:	9201                	srli	a2,a2,0x20
    800059ce:	9642                	add	a2,a2,a6
  *s = c;
    800059d0:	fff74683          	lbu	a3,-1(a4)
    800059d4:	00d78023          	sb	a3,0(a5)
  while(--i >= 0)
    800059d8:	177d                	addi	a4,a4,-1
    800059da:	0785                	addi	a5,a5,1
    800059dc:	fec79ae3          	bne	a5,a2,800059d0 <sprintint+0x76>
    n += sputc(s+n, buf[i]);
  return n;
}
    800059e0:	6462                	ld	s0,24(sp)
    800059e2:	6105                	addi	sp,sp,32
    800059e4:	8082                	ret
    x = -xx;
    800059e6:	40b005bb          	negw	a1,a1
  if(sign && (sign = xx < 0))
    800059ea:	4305                	li	t1,1
    x = -xx;
    800059ec:	b741                	j	8000596c <sprintint+0x12>
  while(--i >= 0)
    800059ee:	4501                	li	a0,0
    800059f0:	bfc5                	j	800059e0 <sprintint+0x86>

00000000800059f2 <snprintf>:

int
snprintf(char *buf, int sz, char *fmt, ...)
{
    800059f2:	7171                	addi	sp,sp,-176
    800059f4:	fc86                	sd	ra,120(sp)
    800059f6:	f8a2                	sd	s0,112(sp)
    800059f8:	f4a6                	sd	s1,104(sp)
    800059fa:	f0ca                	sd	s2,96(sp)
    800059fc:	ecce                	sd	s3,88(sp)
    800059fe:	e8d2                	sd	s4,80(sp)
    80005a00:	e4d6                	sd	s5,72(sp)
    80005a02:	e0da                	sd	s6,64(sp)
    80005a04:	fc5e                	sd	s7,56(sp)
    80005a06:	f862                	sd	s8,48(sp)
    80005a08:	f466                	sd	s9,40(sp)
    80005a0a:	f06a                	sd	s10,32(sp)
    80005a0c:	ec6e                	sd	s11,24(sp)
    80005a0e:	0100                	addi	s0,sp,128
    80005a10:	e414                	sd	a3,8(s0)
    80005a12:	e818                	sd	a4,16(s0)
    80005a14:	ec1c                	sd	a5,24(s0)
    80005a16:	03043023          	sd	a6,32(s0)
    80005a1a:	03143423          	sd	a7,40(s0)
  va_list ap;
  int i, c;
  int off = 0;
  char *s;

  if (fmt == 0)
    80005a1e:	ca0d                	beqz	a2,80005a50 <snprintf+0x5e>
    80005a20:	8baa                	mv	s7,a0
    80005a22:	89ae                	mv	s3,a1
    80005a24:	8a32                	mv	s4,a2
    panic("null fmt");

  va_start(ap, fmt);
    80005a26:	00840793          	addi	a5,s0,8
    80005a2a:	f8f43423          	sd	a5,-120(s0)
  int off = 0;
    80005a2e:	4481                	li	s1,0
  for(i = 0; off < sz && (c = fmt[i] & 0xff) != 0; i++){
    80005a30:	4901                	li	s2,0
    80005a32:	02b05763          	blez	a1,80005a60 <snprintf+0x6e>
    if(c != '%'){
    80005a36:	02500a93          	li	s5,37
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
    switch(c){
    80005a3a:	07300b13          	li	s6,115
      off += sprintint(buf+off, va_arg(ap, int), 16, 1);
      break;
    case 's':
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s && off < sz; s++)
    80005a3e:	02800d93          	li	s11,40
  *s = c;
    80005a42:	02500d13          	li	s10,37
    switch(c){
    80005a46:	07800c93          	li	s9,120
    80005a4a:	06400c13          	li	s8,100
    80005a4e:	a01d                	j	80005a74 <snprintf+0x82>
    panic("null fmt");
    80005a50:	00003517          	auipc	a0,0x3
    80005a54:	d6050513          	addi	a0,a0,-672 # 800087b0 <syscalls+0x3e0>
    80005a58:	00000097          	auipc	ra,0x0
    80005a5c:	634080e7          	jalr	1588(ra) # 8000608c <panic>
  int off = 0;
    80005a60:	4481                	li	s1,0
    80005a62:	a86d                	j	80005b1c <snprintf+0x12a>
  *s = c;
    80005a64:	009b8733          	add	a4,s7,s1
    80005a68:	00f70023          	sb	a5,0(a4)
      off += sputc(buf+off, c);
    80005a6c:	2485                	addiw	s1,s1,1
  for(i = 0; off < sz && (c = fmt[i] & 0xff) != 0; i++){
    80005a6e:	2905                	addiw	s2,s2,1
    80005a70:	0b34d663          	bge	s1,s3,80005b1c <snprintf+0x12a>
    80005a74:	012a07b3          	add	a5,s4,s2
    80005a78:	0007c783          	lbu	a5,0(a5)
    80005a7c:	0007871b          	sext.w	a4,a5
    80005a80:	cfd1                	beqz	a5,80005b1c <snprintf+0x12a>
    if(c != '%'){
    80005a82:	ff5711e3          	bne	a4,s5,80005a64 <snprintf+0x72>
    c = fmt[++i] & 0xff;
    80005a86:	2905                	addiw	s2,s2,1
    80005a88:	012a07b3          	add	a5,s4,s2
    80005a8c:	0007c783          	lbu	a5,0(a5)
    if(c == 0)
    80005a90:	c7d1                	beqz	a5,80005b1c <snprintf+0x12a>
    switch(c){
    80005a92:	05678c63          	beq	a5,s6,80005aea <snprintf+0xf8>
    80005a96:	02fb6763          	bltu	s6,a5,80005ac4 <snprintf+0xd2>
    80005a9a:	0b578763          	beq	a5,s5,80005b48 <snprintf+0x156>
    80005a9e:	0b879b63          	bne	a5,s8,80005b54 <snprintf+0x162>
      off += sprintint(buf+off, va_arg(ap, int), 10, 1);
    80005aa2:	f8843783          	ld	a5,-120(s0)
    80005aa6:	00878713          	addi	a4,a5,8
    80005aaa:	f8e43423          	sd	a4,-120(s0)
    80005aae:	4685                	li	a3,1
    80005ab0:	4629                	li	a2,10
    80005ab2:	438c                	lw	a1,0(a5)
    80005ab4:	009b8533          	add	a0,s7,s1
    80005ab8:	00000097          	auipc	ra,0x0
    80005abc:	ea2080e7          	jalr	-350(ra) # 8000595a <sprintint>
    80005ac0:	9ca9                	addw	s1,s1,a0
      break;
    80005ac2:	b775                	j	80005a6e <snprintf+0x7c>
    switch(c){
    80005ac4:	09979863          	bne	a5,s9,80005b54 <snprintf+0x162>
      off += sprintint(buf+off, va_arg(ap, int), 16, 1);
    80005ac8:	f8843783          	ld	a5,-120(s0)
    80005acc:	00878713          	addi	a4,a5,8
    80005ad0:	f8e43423          	sd	a4,-120(s0)
    80005ad4:	4685                	li	a3,1
    80005ad6:	4641                	li	a2,16
    80005ad8:	438c                	lw	a1,0(a5)
    80005ada:	009b8533          	add	a0,s7,s1
    80005ade:	00000097          	auipc	ra,0x0
    80005ae2:	e7c080e7          	jalr	-388(ra) # 8000595a <sprintint>
    80005ae6:	9ca9                	addw	s1,s1,a0
      break;
    80005ae8:	b759                	j	80005a6e <snprintf+0x7c>
      if((s = va_arg(ap, char*)) == 0)
    80005aea:	f8843783          	ld	a5,-120(s0)
    80005aee:	00878713          	addi	a4,a5,8
    80005af2:	f8e43423          	sd	a4,-120(s0)
    80005af6:	639c                	ld	a5,0(a5)
    80005af8:	c3b1                	beqz	a5,80005b3c <snprintf+0x14a>
      for(; *s && off < sz; s++)
    80005afa:	0007c703          	lbu	a4,0(a5)
    80005afe:	db25                	beqz	a4,80005a6e <snprintf+0x7c>
    80005b00:	0134de63          	bge	s1,s3,80005b1c <snprintf+0x12a>
    80005b04:	009b86b3          	add	a3,s7,s1
  *s = c;
    80005b08:	00e68023          	sb	a4,0(a3)
        off += sputc(buf+off, *s);
    80005b0c:	2485                	addiw	s1,s1,1
      for(; *s && off < sz; s++)
    80005b0e:	0785                	addi	a5,a5,1
    80005b10:	0007c703          	lbu	a4,0(a5)
    80005b14:	df29                	beqz	a4,80005a6e <snprintf+0x7c>
    80005b16:	0685                	addi	a3,a3,1
    80005b18:	fe9998e3          	bne	s3,s1,80005b08 <snprintf+0x116>
      off += sputc(buf+off, c);
      break;
    }
  }
  return off;
}
    80005b1c:	8526                	mv	a0,s1
    80005b1e:	70e6                	ld	ra,120(sp)
    80005b20:	7446                	ld	s0,112(sp)
    80005b22:	74a6                	ld	s1,104(sp)
    80005b24:	7906                	ld	s2,96(sp)
    80005b26:	69e6                	ld	s3,88(sp)
    80005b28:	6a46                	ld	s4,80(sp)
    80005b2a:	6aa6                	ld	s5,72(sp)
    80005b2c:	6b06                	ld	s6,64(sp)
    80005b2e:	7be2                	ld	s7,56(sp)
    80005b30:	7c42                	ld	s8,48(sp)
    80005b32:	7ca2                	ld	s9,40(sp)
    80005b34:	7d02                	ld	s10,32(sp)
    80005b36:	6de2                	ld	s11,24(sp)
    80005b38:	614d                	addi	sp,sp,176
    80005b3a:	8082                	ret
        s = "(null)";
    80005b3c:	00003797          	auipc	a5,0x3
    80005b40:	c6c78793          	addi	a5,a5,-916 # 800087a8 <syscalls+0x3d8>
      for(; *s && off < sz; s++)
    80005b44:	876e                	mv	a4,s11
    80005b46:	bf6d                	j	80005b00 <snprintf+0x10e>
  *s = c;
    80005b48:	009b87b3          	add	a5,s7,s1
    80005b4c:	01a78023          	sb	s10,0(a5)
      off += sputc(buf+off, '%');
    80005b50:	2485                	addiw	s1,s1,1
      break;
    80005b52:	bf31                	j	80005a6e <snprintf+0x7c>
  *s = c;
    80005b54:	009b8733          	add	a4,s7,s1
    80005b58:	01a70023          	sb	s10,0(a4)
      off += sputc(buf+off, c);
    80005b5c:	0014871b          	addiw	a4,s1,1
  *s = c;
    80005b60:	975e                	add	a4,a4,s7
    80005b62:	00f70023          	sb	a5,0(a4)
      off += sputc(buf+off, c);
    80005b66:	2489                	addiw	s1,s1,2
      break;
    80005b68:	b719                	j	80005a6e <snprintf+0x7c>

0000000080005b6a <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    80005b6a:	1141                	addi	sp,sp,-16
    80005b6c:	e422                	sd	s0,8(sp)
    80005b6e:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80005b70:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80005b74:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    80005b78:	0037979b          	slliw	a5,a5,0x3
    80005b7c:	02004737          	lui	a4,0x2004
    80005b80:	97ba                	add	a5,a5,a4
    80005b82:	0200c737          	lui	a4,0x200c
    80005b86:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    80005b8a:	000f4637          	lui	a2,0xf4
    80005b8e:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80005b92:	95b2                	add	a1,a1,a2
    80005b94:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80005b96:	00269713          	slli	a4,a3,0x2
    80005b9a:	9736                	add	a4,a4,a3
    80005b9c:	00371693          	slli	a3,a4,0x3
    80005ba0:	0001c717          	auipc	a4,0x1c
    80005ba4:	49070713          	addi	a4,a4,1168 # 80022030 <timer_scratch>
    80005ba8:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    80005baa:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    80005bac:	f310                	sd	a2,32(a4)
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80005bae:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80005bb2:	fffff797          	auipc	a5,0xfffff
    80005bb6:	63e78793          	addi	a5,a5,1598 # 800051f0 <timervec>
    80005bba:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80005bbe:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80005bc2:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80005bc6:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    80005bca:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80005bce:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80005bd2:	30479073          	csrw	mie,a5
}
    80005bd6:	6422                	ld	s0,8(sp)
    80005bd8:	0141                	addi	sp,sp,16
    80005bda:	8082                	ret

0000000080005bdc <start>:
{
    80005bdc:	1141                	addi	sp,sp,-16
    80005bde:	e406                	sd	ra,8(sp)
    80005be0:	e022                	sd	s0,0(sp)
    80005be2:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80005be4:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80005be8:	7779                	lui	a4,0xffffe
    80005bea:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd35b7>
    80005bee:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80005bf0:	6705                	lui	a4,0x1
    80005bf2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80005bf6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80005bf8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80005bfc:	ffffb797          	auipc	a5,0xffffb
    80005c00:	87678793          	addi	a5,a5,-1930 # 80000472 <main>
    80005c04:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    80005c08:	4781                	li	a5,0
    80005c0a:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80005c0e:	67c1                	lui	a5,0x10
    80005c10:	17fd                	addi	a5,a5,-1
    80005c12:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    80005c16:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    80005c1a:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80005c1e:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80005c22:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    80005c26:	57fd                	li	a5,-1
    80005c28:	83a9                	srli	a5,a5,0xa
    80005c2a:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    80005c2e:	47bd                	li	a5,15
    80005c30:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    80005c34:	00000097          	auipc	ra,0x0
    80005c38:	f36080e7          	jalr	-202(ra) # 80005b6a <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80005c3c:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    80005c40:	2781                	sext.w	a5,a5
  asm volatile("mv tp, %0" : : "r" (x));
    80005c42:	823e                	mv	tp,a5
  asm volatile("mret");
    80005c44:	30200073          	mret
}
    80005c48:	60a2                	ld	ra,8(sp)
    80005c4a:	6402                	ld	s0,0(sp)
    80005c4c:	0141                	addi	sp,sp,16
    80005c4e:	8082                	ret

0000000080005c50 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80005c50:	715d                	addi	sp,sp,-80
    80005c52:	e486                	sd	ra,72(sp)
    80005c54:	e0a2                	sd	s0,64(sp)
    80005c56:	fc26                	sd	s1,56(sp)
    80005c58:	f84a                	sd	s2,48(sp)
    80005c5a:	f44e                	sd	s3,40(sp)
    80005c5c:	f052                	sd	s4,32(sp)
    80005c5e:	ec56                	sd	s5,24(sp)
    80005c60:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80005c62:	04c05663          	blez	a2,80005cae <consolewrite+0x5e>
    80005c66:	8a2a                	mv	s4,a0
    80005c68:	84ae                	mv	s1,a1
    80005c6a:	89b2                	mv	s3,a2
    80005c6c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80005c6e:	5afd                	li	s5,-1
    80005c70:	4685                	li	a3,1
    80005c72:	8626                	mv	a2,s1
    80005c74:	85d2                	mv	a1,s4
    80005c76:	fbf40513          	addi	a0,s0,-65
    80005c7a:	ffffc097          	auipc	ra,0xffffc
    80005c7e:	de0080e7          	jalr	-544(ra) # 80001a5a <either_copyin>
    80005c82:	01550c63          	beq	a0,s5,80005c9a <consolewrite+0x4a>
      break;
    uartputc(c);
    80005c86:	fbf44503          	lbu	a0,-65(s0)
    80005c8a:	00000097          	auipc	ra,0x0
    80005c8e:	78e080e7          	jalr	1934(ra) # 80006418 <uartputc>
  for(i = 0; i < n; i++){
    80005c92:	2905                	addiw	s2,s2,1
    80005c94:	0485                	addi	s1,s1,1
    80005c96:	fd299de3          	bne	s3,s2,80005c70 <consolewrite+0x20>
  }

  return i;
}
    80005c9a:	854a                	mv	a0,s2
    80005c9c:	60a6                	ld	ra,72(sp)
    80005c9e:	6406                	ld	s0,64(sp)
    80005ca0:	74e2                	ld	s1,56(sp)
    80005ca2:	7942                	ld	s2,48(sp)
    80005ca4:	79a2                	ld	s3,40(sp)
    80005ca6:	7a02                	ld	s4,32(sp)
    80005ca8:	6ae2                	ld	s5,24(sp)
    80005caa:	6161                	addi	sp,sp,80
    80005cac:	8082                	ret
  for(i = 0; i < n; i++){
    80005cae:	4901                	li	s2,0
    80005cb0:	b7ed                	j	80005c9a <consolewrite+0x4a>

0000000080005cb2 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80005cb2:	7119                	addi	sp,sp,-128
    80005cb4:	fc86                	sd	ra,120(sp)
    80005cb6:	f8a2                	sd	s0,112(sp)
    80005cb8:	f4a6                	sd	s1,104(sp)
    80005cba:	f0ca                	sd	s2,96(sp)
    80005cbc:	ecce                	sd	s3,88(sp)
    80005cbe:	e8d2                	sd	s4,80(sp)
    80005cc0:	e4d6                	sd	s5,72(sp)
    80005cc2:	e0da                	sd	s6,64(sp)
    80005cc4:	fc5e                	sd	s7,56(sp)
    80005cc6:	f862                	sd	s8,48(sp)
    80005cc8:	f466                	sd	s9,40(sp)
    80005cca:	f06a                	sd	s10,32(sp)
    80005ccc:	ec6e                	sd	s11,24(sp)
    80005cce:	0100                	addi	s0,sp,128
    80005cd0:	8b2a                	mv	s6,a0
    80005cd2:	8aae                	mv	s5,a1
    80005cd4:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80005cd6:	00060b9b          	sext.w	s7,a2
  acquire(&cons.lock);
    80005cda:	00024517          	auipc	a0,0x24
    80005cde:	49650513          	addi	a0,a0,1174 # 8002a170 <cons>
    80005ce2:	00001097          	auipc	ra,0x1
    80005ce6:	8de080e7          	jalr	-1826(ra) # 800065c0 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80005cea:	00024497          	auipc	s1,0x24
    80005cee:	48648493          	addi	s1,s1,1158 # 8002a170 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80005cf2:	89a6                	mv	s3,s1
    80005cf4:	00024917          	auipc	s2,0x24
    80005cf8:	51c90913          	addi	s2,s2,1308 # 8002a210 <cons+0xa0>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    80005cfc:	4c91                	li	s9,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80005cfe:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    80005d00:	4da9                	li	s11,10
  while(n > 0){
    80005d02:	07405863          	blez	s4,80005d72 <consoleread+0xc0>
    while(cons.r == cons.w){
    80005d06:	0a04a783          	lw	a5,160(s1)
    80005d0a:	0a44a703          	lw	a4,164(s1)
    80005d0e:	02f71463          	bne	a4,a5,80005d36 <consoleread+0x84>
      if(myproc()->killed){
    80005d12:	ffffb097          	auipc	ra,0xffffb
    80005d16:	292080e7          	jalr	658(ra) # 80000fa4 <myproc>
    80005d1a:	591c                	lw	a5,48(a0)
    80005d1c:	e7b5                	bnez	a5,80005d88 <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    80005d1e:	85ce                	mv	a1,s3
    80005d20:	854a                	mv	a0,s2
    80005d22:	ffffc097          	auipc	ra,0xffffc
    80005d26:	93e080e7          	jalr	-1730(ra) # 80001660 <sleep>
    while(cons.r == cons.w){
    80005d2a:	0a04a783          	lw	a5,160(s1)
    80005d2e:	0a44a703          	lw	a4,164(s1)
    80005d32:	fef700e3          	beq	a4,a5,80005d12 <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF];
    80005d36:	0017871b          	addiw	a4,a5,1
    80005d3a:	0ae4a023          	sw	a4,160(s1)
    80005d3e:	07f7f713          	andi	a4,a5,127
    80005d42:	9726                	add	a4,a4,s1
    80005d44:	02074703          	lbu	a4,32(a4)
    80005d48:	00070c1b          	sext.w	s8,a4
    if(c == C('D')){  // end-of-file
    80005d4c:	079c0663          	beq	s8,s9,80005db8 <consoleread+0x106>
    cbuf = c;
    80005d50:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80005d54:	4685                	li	a3,1
    80005d56:	f8f40613          	addi	a2,s0,-113
    80005d5a:	85d6                	mv	a1,s5
    80005d5c:	855a                	mv	a0,s6
    80005d5e:	ffffc097          	auipc	ra,0xffffc
    80005d62:	ca6080e7          	jalr	-858(ra) # 80001a04 <either_copyout>
    80005d66:	01a50663          	beq	a0,s10,80005d72 <consoleread+0xc0>
    dst++;
    80005d6a:	0a85                	addi	s5,s5,1
    --n;
    80005d6c:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    80005d6e:	f9bc1ae3          	bne	s8,s11,80005d02 <consoleread+0x50>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80005d72:	00024517          	auipc	a0,0x24
    80005d76:	3fe50513          	addi	a0,a0,1022 # 8002a170 <cons>
    80005d7a:	00001097          	auipc	ra,0x1
    80005d7e:	916080e7          	jalr	-1770(ra) # 80006690 <release>

  return target - n;
    80005d82:	414b853b          	subw	a0,s7,s4
    80005d86:	a811                	j	80005d9a <consoleread+0xe8>
        release(&cons.lock);
    80005d88:	00024517          	auipc	a0,0x24
    80005d8c:	3e850513          	addi	a0,a0,1000 # 8002a170 <cons>
    80005d90:	00001097          	auipc	ra,0x1
    80005d94:	900080e7          	jalr	-1792(ra) # 80006690 <release>
        return -1;
    80005d98:	557d                	li	a0,-1
}
    80005d9a:	70e6                	ld	ra,120(sp)
    80005d9c:	7446                	ld	s0,112(sp)
    80005d9e:	74a6                	ld	s1,104(sp)
    80005da0:	7906                	ld	s2,96(sp)
    80005da2:	69e6                	ld	s3,88(sp)
    80005da4:	6a46                	ld	s4,80(sp)
    80005da6:	6aa6                	ld	s5,72(sp)
    80005da8:	6b06                	ld	s6,64(sp)
    80005daa:	7be2                	ld	s7,56(sp)
    80005dac:	7c42                	ld	s8,48(sp)
    80005dae:	7ca2                	ld	s9,40(sp)
    80005db0:	7d02                	ld	s10,32(sp)
    80005db2:	6de2                	ld	s11,24(sp)
    80005db4:	6109                	addi	sp,sp,128
    80005db6:	8082                	ret
      if(n < target){
    80005db8:	000a071b          	sext.w	a4,s4
    80005dbc:	fb777be3          	bgeu	a4,s7,80005d72 <consoleread+0xc0>
        cons.r--;
    80005dc0:	00024717          	auipc	a4,0x24
    80005dc4:	44f72823          	sw	a5,1104(a4) # 8002a210 <cons+0xa0>
    80005dc8:	b76d                	j	80005d72 <consoleread+0xc0>

0000000080005dca <consputc>:
{
    80005dca:	1141                	addi	sp,sp,-16
    80005dcc:	e406                	sd	ra,8(sp)
    80005dce:	e022                	sd	s0,0(sp)
    80005dd0:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80005dd2:	10000793          	li	a5,256
    80005dd6:	00f50a63          	beq	a0,a5,80005dea <consputc+0x20>
    uartputc_sync(c);
    80005dda:	00000097          	auipc	ra,0x0
    80005dde:	564080e7          	jalr	1380(ra) # 8000633e <uartputc_sync>
}
    80005de2:	60a2                	ld	ra,8(sp)
    80005de4:	6402                	ld	s0,0(sp)
    80005de6:	0141                	addi	sp,sp,16
    80005de8:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80005dea:	4521                	li	a0,8
    80005dec:	00000097          	auipc	ra,0x0
    80005df0:	552080e7          	jalr	1362(ra) # 8000633e <uartputc_sync>
    80005df4:	02000513          	li	a0,32
    80005df8:	00000097          	auipc	ra,0x0
    80005dfc:	546080e7          	jalr	1350(ra) # 8000633e <uartputc_sync>
    80005e00:	4521                	li	a0,8
    80005e02:	00000097          	auipc	ra,0x0
    80005e06:	53c080e7          	jalr	1340(ra) # 8000633e <uartputc_sync>
    80005e0a:	bfe1                	j	80005de2 <consputc+0x18>

0000000080005e0c <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80005e0c:	1101                	addi	sp,sp,-32
    80005e0e:	ec06                	sd	ra,24(sp)
    80005e10:	e822                	sd	s0,16(sp)
    80005e12:	e426                	sd	s1,8(sp)
    80005e14:	e04a                	sd	s2,0(sp)
    80005e16:	1000                	addi	s0,sp,32
    80005e18:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    80005e1a:	00024517          	auipc	a0,0x24
    80005e1e:	35650513          	addi	a0,a0,854 # 8002a170 <cons>
    80005e22:	00000097          	auipc	ra,0x0
    80005e26:	79e080e7          	jalr	1950(ra) # 800065c0 <acquire>

  switch(c){
    80005e2a:	47d5                	li	a5,21
    80005e2c:	0af48663          	beq	s1,a5,80005ed8 <consoleintr+0xcc>
    80005e30:	0297ca63          	blt	a5,s1,80005e64 <consoleintr+0x58>
    80005e34:	47a1                	li	a5,8
    80005e36:	0ef48763          	beq	s1,a5,80005f24 <consoleintr+0x118>
    80005e3a:	47c1                	li	a5,16
    80005e3c:	10f49a63          	bne	s1,a5,80005f50 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    80005e40:	ffffc097          	auipc	ra,0xffffc
    80005e44:	c70080e7          	jalr	-912(ra) # 80001ab0 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80005e48:	00024517          	auipc	a0,0x24
    80005e4c:	32850513          	addi	a0,a0,808 # 8002a170 <cons>
    80005e50:	00001097          	auipc	ra,0x1
    80005e54:	840080e7          	jalr	-1984(ra) # 80006690 <release>
}
    80005e58:	60e2                	ld	ra,24(sp)
    80005e5a:	6442                	ld	s0,16(sp)
    80005e5c:	64a2                	ld	s1,8(sp)
    80005e5e:	6902                	ld	s2,0(sp)
    80005e60:	6105                	addi	sp,sp,32
    80005e62:	8082                	ret
  switch(c){
    80005e64:	07f00793          	li	a5,127
    80005e68:	0af48e63          	beq	s1,a5,80005f24 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80005e6c:	00024717          	auipc	a4,0x24
    80005e70:	30470713          	addi	a4,a4,772 # 8002a170 <cons>
    80005e74:	0a872783          	lw	a5,168(a4)
    80005e78:	0a072703          	lw	a4,160(a4)
    80005e7c:	9f99                	subw	a5,a5,a4
    80005e7e:	07f00713          	li	a4,127
    80005e82:	fcf763e3          	bltu	a4,a5,80005e48 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80005e86:	47b5                	li	a5,13
    80005e88:	0cf48763          	beq	s1,a5,80005f56 <consoleintr+0x14a>
      consputc(c);
    80005e8c:	8526                	mv	a0,s1
    80005e8e:	00000097          	auipc	ra,0x0
    80005e92:	f3c080e7          	jalr	-196(ra) # 80005dca <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80005e96:	00024797          	auipc	a5,0x24
    80005e9a:	2da78793          	addi	a5,a5,730 # 8002a170 <cons>
    80005e9e:	0a87a703          	lw	a4,168(a5)
    80005ea2:	0017069b          	addiw	a3,a4,1
    80005ea6:	0006861b          	sext.w	a2,a3
    80005eaa:	0ad7a423          	sw	a3,168(a5)
    80005eae:	07f77713          	andi	a4,a4,127
    80005eb2:	97ba                	add	a5,a5,a4
    80005eb4:	02978023          	sb	s1,32(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80005eb8:	47a9                	li	a5,10
    80005eba:	0cf48563          	beq	s1,a5,80005f84 <consoleintr+0x178>
    80005ebe:	4791                	li	a5,4
    80005ec0:	0cf48263          	beq	s1,a5,80005f84 <consoleintr+0x178>
    80005ec4:	00024797          	auipc	a5,0x24
    80005ec8:	34c7a783          	lw	a5,844(a5) # 8002a210 <cons+0xa0>
    80005ecc:	0807879b          	addiw	a5,a5,128
    80005ed0:	f6f61ce3          	bne	a2,a5,80005e48 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80005ed4:	863e                	mv	a2,a5
    80005ed6:	a07d                	j	80005f84 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80005ed8:	00024717          	auipc	a4,0x24
    80005edc:	29870713          	addi	a4,a4,664 # 8002a170 <cons>
    80005ee0:	0a872783          	lw	a5,168(a4)
    80005ee4:	0a472703          	lw	a4,164(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80005ee8:	00024497          	auipc	s1,0x24
    80005eec:	28848493          	addi	s1,s1,648 # 8002a170 <cons>
    while(cons.e != cons.w &&
    80005ef0:	4929                	li	s2,10
    80005ef2:	f4f70be3          	beq	a4,a5,80005e48 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80005ef6:	37fd                	addiw	a5,a5,-1
    80005ef8:	07f7f713          	andi	a4,a5,127
    80005efc:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80005efe:	02074703          	lbu	a4,32(a4)
    80005f02:	f52703e3          	beq	a4,s2,80005e48 <consoleintr+0x3c>
      cons.e--;
    80005f06:	0af4a423          	sw	a5,168(s1)
      consputc(BACKSPACE);
    80005f0a:	10000513          	li	a0,256
    80005f0e:	00000097          	auipc	ra,0x0
    80005f12:	ebc080e7          	jalr	-324(ra) # 80005dca <consputc>
    while(cons.e != cons.w &&
    80005f16:	0a84a783          	lw	a5,168(s1)
    80005f1a:	0a44a703          	lw	a4,164(s1)
    80005f1e:	fcf71ce3          	bne	a4,a5,80005ef6 <consoleintr+0xea>
    80005f22:	b71d                	j	80005e48 <consoleintr+0x3c>
    if(cons.e != cons.w){
    80005f24:	00024717          	auipc	a4,0x24
    80005f28:	24c70713          	addi	a4,a4,588 # 8002a170 <cons>
    80005f2c:	0a872783          	lw	a5,168(a4)
    80005f30:	0a472703          	lw	a4,164(a4)
    80005f34:	f0f70ae3          	beq	a4,a5,80005e48 <consoleintr+0x3c>
      cons.e--;
    80005f38:	37fd                	addiw	a5,a5,-1
    80005f3a:	00024717          	auipc	a4,0x24
    80005f3e:	2cf72f23          	sw	a5,734(a4) # 8002a218 <cons+0xa8>
      consputc(BACKSPACE);
    80005f42:	10000513          	li	a0,256
    80005f46:	00000097          	auipc	ra,0x0
    80005f4a:	e84080e7          	jalr	-380(ra) # 80005dca <consputc>
    80005f4e:	bded                	j	80005e48 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80005f50:	ee048ce3          	beqz	s1,80005e48 <consoleintr+0x3c>
    80005f54:	bf21                	j	80005e6c <consoleintr+0x60>
      consputc(c);
    80005f56:	4529                	li	a0,10
    80005f58:	00000097          	auipc	ra,0x0
    80005f5c:	e72080e7          	jalr	-398(ra) # 80005dca <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80005f60:	00024797          	auipc	a5,0x24
    80005f64:	21078793          	addi	a5,a5,528 # 8002a170 <cons>
    80005f68:	0a87a703          	lw	a4,168(a5)
    80005f6c:	0017069b          	addiw	a3,a4,1
    80005f70:	0006861b          	sext.w	a2,a3
    80005f74:	0ad7a423          	sw	a3,168(a5)
    80005f78:	07f77713          	andi	a4,a4,127
    80005f7c:	97ba                	add	a5,a5,a4
    80005f7e:	4729                	li	a4,10
    80005f80:	02e78023          	sb	a4,32(a5)
        cons.w = cons.e;
    80005f84:	00024797          	auipc	a5,0x24
    80005f88:	28c7a823          	sw	a2,656(a5) # 8002a214 <cons+0xa4>
        wakeup(&cons.r);
    80005f8c:	00024517          	auipc	a0,0x24
    80005f90:	28450513          	addi	a0,a0,644 # 8002a210 <cons+0xa0>
    80005f94:	ffffc097          	auipc	ra,0xffffc
    80005f98:	858080e7          	jalr	-1960(ra) # 800017ec <wakeup>
    80005f9c:	b575                	j	80005e48 <consoleintr+0x3c>

0000000080005f9e <consoleinit>:

void
consoleinit(void)
{
    80005f9e:	1141                	addi	sp,sp,-16
    80005fa0:	e406                	sd	ra,8(sp)
    80005fa2:	e022                	sd	s0,0(sp)
    80005fa4:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80005fa6:	00003597          	auipc	a1,0x3
    80005faa:	83258593          	addi	a1,a1,-1998 # 800087d8 <digits+0x18>
    80005fae:	00024517          	auipc	a0,0x24
    80005fb2:	1c250513          	addi	a0,a0,450 # 8002a170 <cons>
    80005fb6:	00000097          	auipc	ra,0x0
    80005fba:	786080e7          	jalr	1926(ra) # 8000673c <initlock>

  uartinit();
    80005fbe:	00000097          	auipc	ra,0x0
    80005fc2:	330080e7          	jalr	816(ra) # 800062ee <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80005fc6:	00017797          	auipc	a5,0x17
    80005fca:	e3278793          	addi	a5,a5,-462 # 8001cdf8 <devsw>
    80005fce:	00000717          	auipc	a4,0x0
    80005fd2:	ce470713          	addi	a4,a4,-796 # 80005cb2 <consoleread>
    80005fd6:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80005fd8:	00000717          	auipc	a4,0x0
    80005fdc:	c7870713          	addi	a4,a4,-904 # 80005c50 <consolewrite>
    80005fe0:	ef98                	sd	a4,24(a5)
}
    80005fe2:	60a2                	ld	ra,8(sp)
    80005fe4:	6402                	ld	s0,0(sp)
    80005fe6:	0141                	addi	sp,sp,16
    80005fe8:	8082                	ret

0000000080005fea <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80005fea:	7179                	addi	sp,sp,-48
    80005fec:	f406                	sd	ra,40(sp)
    80005fee:	f022                	sd	s0,32(sp)
    80005ff0:	ec26                	sd	s1,24(sp)
    80005ff2:	e84a                	sd	s2,16(sp)
    80005ff4:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    80005ff6:	c219                	beqz	a2,80005ffc <printint+0x12>
    80005ff8:	08054663          	bltz	a0,80006084 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    80005ffc:	2501                	sext.w	a0,a0
    80005ffe:	4881                	li	a7,0
    80006000:	fd040693          	addi	a3,s0,-48

  i = 0;
    80006004:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    80006006:	2581                	sext.w	a1,a1
    80006008:	00002617          	auipc	a2,0x2
    8000600c:	7e860613          	addi	a2,a2,2024 # 800087f0 <digits>
    80006010:	883a                	mv	a6,a4
    80006012:	2705                	addiw	a4,a4,1
    80006014:	02b577bb          	remuw	a5,a0,a1
    80006018:	1782                	slli	a5,a5,0x20
    8000601a:	9381                	srli	a5,a5,0x20
    8000601c:	97b2                	add	a5,a5,a2
    8000601e:	0007c783          	lbu	a5,0(a5)
    80006022:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    80006026:	0005079b          	sext.w	a5,a0
    8000602a:	02b5553b          	divuw	a0,a0,a1
    8000602e:	0685                	addi	a3,a3,1
    80006030:	feb7f0e3          	bgeu	a5,a1,80006010 <printint+0x26>

  if(sign)
    80006034:	00088b63          	beqz	a7,8000604a <printint+0x60>
    buf[i++] = '-';
    80006038:	fe040793          	addi	a5,s0,-32
    8000603c:	973e                	add	a4,a4,a5
    8000603e:	02d00793          	li	a5,45
    80006042:	fef70823          	sb	a5,-16(a4)
    80006046:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    8000604a:	02e05763          	blez	a4,80006078 <printint+0x8e>
    8000604e:	fd040793          	addi	a5,s0,-48
    80006052:	00e784b3          	add	s1,a5,a4
    80006056:	fff78913          	addi	s2,a5,-1
    8000605a:	993a                	add	s2,s2,a4
    8000605c:	377d                	addiw	a4,a4,-1
    8000605e:	1702                	slli	a4,a4,0x20
    80006060:	9301                	srli	a4,a4,0x20
    80006062:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80006066:	fff4c503          	lbu	a0,-1(s1)
    8000606a:	00000097          	auipc	ra,0x0
    8000606e:	d60080e7          	jalr	-672(ra) # 80005dca <consputc>
  while(--i >= 0)
    80006072:	14fd                	addi	s1,s1,-1
    80006074:	ff2499e3          	bne	s1,s2,80006066 <printint+0x7c>
}
    80006078:	70a2                	ld	ra,40(sp)
    8000607a:	7402                	ld	s0,32(sp)
    8000607c:	64e2                	ld	s1,24(sp)
    8000607e:	6942                	ld	s2,16(sp)
    80006080:	6145                	addi	sp,sp,48
    80006082:	8082                	ret
    x = -xx;
    80006084:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80006088:	4885                	li	a7,1
    x = -xx;
    8000608a:	bf9d                	j	80006000 <printint+0x16>

000000008000608c <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000608c:	1101                	addi	sp,sp,-32
    8000608e:	ec06                	sd	ra,24(sp)
    80006090:	e822                	sd	s0,16(sp)
    80006092:	e426                	sd	s1,8(sp)
    80006094:	1000                	addi	s0,sp,32
    80006096:	84aa                	mv	s1,a0
  pr.locking = 0;
    80006098:	00024797          	auipc	a5,0x24
    8000609c:	1a07a423          	sw	zero,424(a5) # 8002a240 <pr+0x20>
  printf("panic: ");
    800060a0:	00002517          	auipc	a0,0x2
    800060a4:	74050513          	addi	a0,a0,1856 # 800087e0 <digits+0x20>
    800060a8:	00000097          	auipc	ra,0x0
    800060ac:	02e080e7          	jalr	46(ra) # 800060d6 <printf>
  printf(s);
    800060b0:	8526                	mv	a0,s1
    800060b2:	00000097          	auipc	ra,0x0
    800060b6:	024080e7          	jalr	36(ra) # 800060d6 <printf>
  printf("\n");
    800060ba:	00002517          	auipc	a0,0x2
    800060be:	7be50513          	addi	a0,a0,1982 # 80008878 <digits+0x88>
    800060c2:	00000097          	auipc	ra,0x0
    800060c6:	014080e7          	jalr	20(ra) # 800060d6 <printf>
  panicked = 1; // freeze uart output from other CPUs
    800060ca:	4785                	li	a5,1
    800060cc:	00003717          	auipc	a4,0x3
    800060d0:	f4f72823          	sw	a5,-176(a4) # 8000901c <panicked>
  for(;;)
    800060d4:	a001                	j	800060d4 <panic+0x48>

00000000800060d6 <printf>:
{
    800060d6:	7131                	addi	sp,sp,-192
    800060d8:	fc86                	sd	ra,120(sp)
    800060da:	f8a2                	sd	s0,112(sp)
    800060dc:	f4a6                	sd	s1,104(sp)
    800060de:	f0ca                	sd	s2,96(sp)
    800060e0:	ecce                	sd	s3,88(sp)
    800060e2:	e8d2                	sd	s4,80(sp)
    800060e4:	e4d6                	sd	s5,72(sp)
    800060e6:	e0da                	sd	s6,64(sp)
    800060e8:	fc5e                	sd	s7,56(sp)
    800060ea:	f862                	sd	s8,48(sp)
    800060ec:	f466                	sd	s9,40(sp)
    800060ee:	f06a                	sd	s10,32(sp)
    800060f0:	ec6e                	sd	s11,24(sp)
    800060f2:	0100                	addi	s0,sp,128
    800060f4:	8a2a                	mv	s4,a0
    800060f6:	e40c                	sd	a1,8(s0)
    800060f8:	e810                	sd	a2,16(s0)
    800060fa:	ec14                	sd	a3,24(s0)
    800060fc:	f018                	sd	a4,32(s0)
    800060fe:	f41c                	sd	a5,40(s0)
    80006100:	03043823          	sd	a6,48(s0)
    80006104:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    80006108:	00024d97          	auipc	s11,0x24
    8000610c:	138dad83          	lw	s11,312(s11) # 8002a240 <pr+0x20>
  if(locking)
    80006110:	020d9b63          	bnez	s11,80006146 <printf+0x70>
  if (fmt == 0)
    80006114:	040a0263          	beqz	s4,80006158 <printf+0x82>
  va_start(ap, fmt);
    80006118:	00840793          	addi	a5,s0,8
    8000611c:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80006120:	000a4503          	lbu	a0,0(s4)
    80006124:	16050263          	beqz	a0,80006288 <printf+0x1b2>
    80006128:	4481                	li	s1,0
    if(c != '%'){
    8000612a:	02500a93          	li	s5,37
    switch(c){
    8000612e:	07000b13          	li	s6,112
  consputc('x');
    80006132:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80006134:	00002b97          	auipc	s7,0x2
    80006138:	6bcb8b93          	addi	s7,s7,1724 # 800087f0 <digits>
    switch(c){
    8000613c:	07300c93          	li	s9,115
    80006140:	06400c13          	li	s8,100
    80006144:	a82d                	j	8000617e <printf+0xa8>
    acquire(&pr.lock);
    80006146:	00024517          	auipc	a0,0x24
    8000614a:	0da50513          	addi	a0,a0,218 # 8002a220 <pr>
    8000614e:	00000097          	auipc	ra,0x0
    80006152:	472080e7          	jalr	1138(ra) # 800065c0 <acquire>
    80006156:	bf7d                	j	80006114 <printf+0x3e>
    panic("null fmt");
    80006158:	00002517          	auipc	a0,0x2
    8000615c:	65850513          	addi	a0,a0,1624 # 800087b0 <syscalls+0x3e0>
    80006160:	00000097          	auipc	ra,0x0
    80006164:	f2c080e7          	jalr	-212(ra) # 8000608c <panic>
      consputc(c);
    80006168:	00000097          	auipc	ra,0x0
    8000616c:	c62080e7          	jalr	-926(ra) # 80005dca <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80006170:	2485                	addiw	s1,s1,1
    80006172:	009a07b3          	add	a5,s4,s1
    80006176:	0007c503          	lbu	a0,0(a5)
    8000617a:	10050763          	beqz	a0,80006288 <printf+0x1b2>
    if(c != '%'){
    8000617e:	ff5515e3          	bne	a0,s5,80006168 <printf+0x92>
    c = fmt[++i] & 0xff;
    80006182:	2485                	addiw	s1,s1,1
    80006184:	009a07b3          	add	a5,s4,s1
    80006188:	0007c783          	lbu	a5,0(a5)
    8000618c:	0007891b          	sext.w	s2,a5
    if(c == 0)
    80006190:	cfe5                	beqz	a5,80006288 <printf+0x1b2>
    switch(c){
    80006192:	05678a63          	beq	a5,s6,800061e6 <printf+0x110>
    80006196:	02fb7663          	bgeu	s6,a5,800061c2 <printf+0xec>
    8000619a:	09978963          	beq	a5,s9,8000622c <printf+0x156>
    8000619e:	07800713          	li	a4,120
    800061a2:	0ce79863          	bne	a5,a4,80006272 <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    800061a6:	f8843783          	ld	a5,-120(s0)
    800061aa:	00878713          	addi	a4,a5,8
    800061ae:	f8e43423          	sd	a4,-120(s0)
    800061b2:	4605                	li	a2,1
    800061b4:	85ea                	mv	a1,s10
    800061b6:	4388                	lw	a0,0(a5)
    800061b8:	00000097          	auipc	ra,0x0
    800061bc:	e32080e7          	jalr	-462(ra) # 80005fea <printint>
      break;
    800061c0:	bf45                	j	80006170 <printf+0x9a>
    switch(c){
    800061c2:	0b578263          	beq	a5,s5,80006266 <printf+0x190>
    800061c6:	0b879663          	bne	a5,s8,80006272 <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    800061ca:	f8843783          	ld	a5,-120(s0)
    800061ce:	00878713          	addi	a4,a5,8
    800061d2:	f8e43423          	sd	a4,-120(s0)
    800061d6:	4605                	li	a2,1
    800061d8:	45a9                	li	a1,10
    800061da:	4388                	lw	a0,0(a5)
    800061dc:	00000097          	auipc	ra,0x0
    800061e0:	e0e080e7          	jalr	-498(ra) # 80005fea <printint>
      break;
    800061e4:	b771                	j	80006170 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    800061e6:	f8843783          	ld	a5,-120(s0)
    800061ea:	00878713          	addi	a4,a5,8
    800061ee:	f8e43423          	sd	a4,-120(s0)
    800061f2:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800061f6:	03000513          	li	a0,48
    800061fa:	00000097          	auipc	ra,0x0
    800061fe:	bd0080e7          	jalr	-1072(ra) # 80005dca <consputc>
  consputc('x');
    80006202:	07800513          	li	a0,120
    80006206:	00000097          	auipc	ra,0x0
    8000620a:	bc4080e7          	jalr	-1084(ra) # 80005dca <consputc>
    8000620e:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80006210:	03c9d793          	srli	a5,s3,0x3c
    80006214:	97de                	add	a5,a5,s7
    80006216:	0007c503          	lbu	a0,0(a5)
    8000621a:	00000097          	auipc	ra,0x0
    8000621e:	bb0080e7          	jalr	-1104(ra) # 80005dca <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80006222:	0992                	slli	s3,s3,0x4
    80006224:	397d                	addiw	s2,s2,-1
    80006226:	fe0915e3          	bnez	s2,80006210 <printf+0x13a>
    8000622a:	b799                	j	80006170 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    8000622c:	f8843783          	ld	a5,-120(s0)
    80006230:	00878713          	addi	a4,a5,8
    80006234:	f8e43423          	sd	a4,-120(s0)
    80006238:	0007b903          	ld	s2,0(a5)
    8000623c:	00090e63          	beqz	s2,80006258 <printf+0x182>
      for(; *s; s++)
    80006240:	00094503          	lbu	a0,0(s2)
    80006244:	d515                	beqz	a0,80006170 <printf+0x9a>
        consputc(*s);
    80006246:	00000097          	auipc	ra,0x0
    8000624a:	b84080e7          	jalr	-1148(ra) # 80005dca <consputc>
      for(; *s; s++)
    8000624e:	0905                	addi	s2,s2,1
    80006250:	00094503          	lbu	a0,0(s2)
    80006254:	f96d                	bnez	a0,80006246 <printf+0x170>
    80006256:	bf29                	j	80006170 <printf+0x9a>
        s = "(null)";
    80006258:	00002917          	auipc	s2,0x2
    8000625c:	55090913          	addi	s2,s2,1360 # 800087a8 <syscalls+0x3d8>
      for(; *s; s++)
    80006260:	02800513          	li	a0,40
    80006264:	b7cd                	j	80006246 <printf+0x170>
      consputc('%');
    80006266:	8556                	mv	a0,s5
    80006268:	00000097          	auipc	ra,0x0
    8000626c:	b62080e7          	jalr	-1182(ra) # 80005dca <consputc>
      break;
    80006270:	b701                	j	80006170 <printf+0x9a>
      consputc('%');
    80006272:	8556                	mv	a0,s5
    80006274:	00000097          	auipc	ra,0x0
    80006278:	b56080e7          	jalr	-1194(ra) # 80005dca <consputc>
      consputc(c);
    8000627c:	854a                	mv	a0,s2
    8000627e:	00000097          	auipc	ra,0x0
    80006282:	b4c080e7          	jalr	-1204(ra) # 80005dca <consputc>
      break;
    80006286:	b5ed                	j	80006170 <printf+0x9a>
  if(locking)
    80006288:	020d9163          	bnez	s11,800062aa <printf+0x1d4>
}
    8000628c:	70e6                	ld	ra,120(sp)
    8000628e:	7446                	ld	s0,112(sp)
    80006290:	74a6                	ld	s1,104(sp)
    80006292:	7906                	ld	s2,96(sp)
    80006294:	69e6                	ld	s3,88(sp)
    80006296:	6a46                	ld	s4,80(sp)
    80006298:	6aa6                	ld	s5,72(sp)
    8000629a:	6b06                	ld	s6,64(sp)
    8000629c:	7be2                	ld	s7,56(sp)
    8000629e:	7c42                	ld	s8,48(sp)
    800062a0:	7ca2                	ld	s9,40(sp)
    800062a2:	7d02                	ld	s10,32(sp)
    800062a4:	6de2                	ld	s11,24(sp)
    800062a6:	6129                	addi	sp,sp,192
    800062a8:	8082                	ret
    release(&pr.lock);
    800062aa:	00024517          	auipc	a0,0x24
    800062ae:	f7650513          	addi	a0,a0,-138 # 8002a220 <pr>
    800062b2:	00000097          	auipc	ra,0x0
    800062b6:	3de080e7          	jalr	990(ra) # 80006690 <release>
}
    800062ba:	bfc9                	j	8000628c <printf+0x1b6>

00000000800062bc <printfinit>:
    ;
}

void
printfinit(void)
{
    800062bc:	1101                	addi	sp,sp,-32
    800062be:	ec06                	sd	ra,24(sp)
    800062c0:	e822                	sd	s0,16(sp)
    800062c2:	e426                	sd	s1,8(sp)
    800062c4:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800062c6:	00024497          	auipc	s1,0x24
    800062ca:	f5a48493          	addi	s1,s1,-166 # 8002a220 <pr>
    800062ce:	00002597          	auipc	a1,0x2
    800062d2:	51a58593          	addi	a1,a1,1306 # 800087e8 <digits+0x28>
    800062d6:	8526                	mv	a0,s1
    800062d8:	00000097          	auipc	ra,0x0
    800062dc:	464080e7          	jalr	1124(ra) # 8000673c <initlock>
  pr.locking = 1;
    800062e0:	4785                	li	a5,1
    800062e2:	d09c                	sw	a5,32(s1)
}
    800062e4:	60e2                	ld	ra,24(sp)
    800062e6:	6442                	ld	s0,16(sp)
    800062e8:	64a2                	ld	s1,8(sp)
    800062ea:	6105                	addi	sp,sp,32
    800062ec:	8082                	ret

00000000800062ee <uartinit>:

void uartstart();

void
uartinit(void)
{
    800062ee:	1141                	addi	sp,sp,-16
    800062f0:	e406                	sd	ra,8(sp)
    800062f2:	e022                	sd	s0,0(sp)
    800062f4:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800062f6:	100007b7          	lui	a5,0x10000
    800062fa:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800062fe:	f8000713          	li	a4,-128
    80006302:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80006306:	470d                	li	a4,3
    80006308:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    8000630c:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80006310:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80006314:	469d                	li	a3,7
    80006316:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    8000631a:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    8000631e:	00002597          	auipc	a1,0x2
    80006322:	4ea58593          	addi	a1,a1,1258 # 80008808 <digits+0x18>
    80006326:	00024517          	auipc	a0,0x24
    8000632a:	f2250513          	addi	a0,a0,-222 # 8002a248 <uart_tx_lock>
    8000632e:	00000097          	auipc	ra,0x0
    80006332:	40e080e7          	jalr	1038(ra) # 8000673c <initlock>
}
    80006336:	60a2                	ld	ra,8(sp)
    80006338:	6402                	ld	s0,0(sp)
    8000633a:	0141                	addi	sp,sp,16
    8000633c:	8082                	ret

000000008000633e <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000633e:	1101                	addi	sp,sp,-32
    80006340:	ec06                	sd	ra,24(sp)
    80006342:	e822                	sd	s0,16(sp)
    80006344:	e426                	sd	s1,8(sp)
    80006346:	1000                	addi	s0,sp,32
    80006348:	84aa                	mv	s1,a0
  push_off();
    8000634a:	00000097          	auipc	ra,0x0
    8000634e:	22a080e7          	jalr	554(ra) # 80006574 <push_off>

  if(panicked){
    80006352:	00003797          	auipc	a5,0x3
    80006356:	cca7a783          	lw	a5,-822(a5) # 8000901c <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000635a:	10000737          	lui	a4,0x10000
  if(panicked){
    8000635e:	c391                	beqz	a5,80006362 <uartputc_sync+0x24>
    for(;;)
    80006360:	a001                	j	80006360 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80006362:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80006366:	0ff7f793          	andi	a5,a5,255
    8000636a:	0207f793          	andi	a5,a5,32
    8000636e:	dbf5                	beqz	a5,80006362 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80006370:	0ff4f793          	andi	a5,s1,255
    80006374:	10000737          	lui	a4,0x10000
    80006378:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    8000637c:	00000097          	auipc	ra,0x0
    80006380:	2b4080e7          	jalr	692(ra) # 80006630 <pop_off>
}
    80006384:	60e2                	ld	ra,24(sp)
    80006386:	6442                	ld	s0,16(sp)
    80006388:	64a2                	ld	s1,8(sp)
    8000638a:	6105                	addi	sp,sp,32
    8000638c:	8082                	ret

000000008000638e <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000638e:	00003717          	auipc	a4,0x3
    80006392:	c9273703          	ld	a4,-878(a4) # 80009020 <uart_tx_r>
    80006396:	00003797          	auipc	a5,0x3
    8000639a:	c927b783          	ld	a5,-878(a5) # 80009028 <uart_tx_w>
    8000639e:	06e78c63          	beq	a5,a4,80006416 <uartstart+0x88>
{
    800063a2:	7139                	addi	sp,sp,-64
    800063a4:	fc06                	sd	ra,56(sp)
    800063a6:	f822                	sd	s0,48(sp)
    800063a8:	f426                	sd	s1,40(sp)
    800063aa:	f04a                	sd	s2,32(sp)
    800063ac:	ec4e                	sd	s3,24(sp)
    800063ae:	e852                	sd	s4,16(sp)
    800063b0:	e456                	sd	s5,8(sp)
    800063b2:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800063b4:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800063b8:	00024a17          	auipc	s4,0x24
    800063bc:	e90a0a13          	addi	s4,s4,-368 # 8002a248 <uart_tx_lock>
    uart_tx_r += 1;
    800063c0:	00003497          	auipc	s1,0x3
    800063c4:	c6048493          	addi	s1,s1,-928 # 80009020 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    800063c8:	00003997          	auipc	s3,0x3
    800063cc:	c6098993          	addi	s3,s3,-928 # 80009028 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800063d0:	00594783          	lbu	a5,5(s2) # 10000005 <_entry-0x6ffffffb>
    800063d4:	0ff7f793          	andi	a5,a5,255
    800063d8:	0207f793          	andi	a5,a5,32
    800063dc:	c785                	beqz	a5,80006404 <uartstart+0x76>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800063de:	01f77793          	andi	a5,a4,31
    800063e2:	97d2                	add	a5,a5,s4
    800063e4:	0207ca83          	lbu	s5,32(a5)
    uart_tx_r += 1;
    800063e8:	0705                	addi	a4,a4,1
    800063ea:	e098                	sd	a4,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    800063ec:	8526                	mv	a0,s1
    800063ee:	ffffb097          	auipc	ra,0xffffb
    800063f2:	3fe080e7          	jalr	1022(ra) # 800017ec <wakeup>
    
    WriteReg(THR, c);
    800063f6:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800063fa:	6098                	ld	a4,0(s1)
    800063fc:	0009b783          	ld	a5,0(s3)
    80006400:	fce798e3          	bne	a5,a4,800063d0 <uartstart+0x42>
  }
}
    80006404:	70e2                	ld	ra,56(sp)
    80006406:	7442                	ld	s0,48(sp)
    80006408:	74a2                	ld	s1,40(sp)
    8000640a:	7902                	ld	s2,32(sp)
    8000640c:	69e2                	ld	s3,24(sp)
    8000640e:	6a42                	ld	s4,16(sp)
    80006410:	6aa2                	ld	s5,8(sp)
    80006412:	6121                	addi	sp,sp,64
    80006414:	8082                	ret
    80006416:	8082                	ret

0000000080006418 <uartputc>:
{
    80006418:	7179                	addi	sp,sp,-48
    8000641a:	f406                	sd	ra,40(sp)
    8000641c:	f022                	sd	s0,32(sp)
    8000641e:	ec26                	sd	s1,24(sp)
    80006420:	e84a                	sd	s2,16(sp)
    80006422:	e44e                	sd	s3,8(sp)
    80006424:	e052                	sd	s4,0(sp)
    80006426:	1800                	addi	s0,sp,48
    80006428:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    8000642a:	00024517          	auipc	a0,0x24
    8000642e:	e1e50513          	addi	a0,a0,-482 # 8002a248 <uart_tx_lock>
    80006432:	00000097          	auipc	ra,0x0
    80006436:	18e080e7          	jalr	398(ra) # 800065c0 <acquire>
  if(panicked){
    8000643a:	00003797          	auipc	a5,0x3
    8000643e:	be27a783          	lw	a5,-1054(a5) # 8000901c <panicked>
    80006442:	c391                	beqz	a5,80006446 <uartputc+0x2e>
    for(;;)
    80006444:	a001                	j	80006444 <uartputc+0x2c>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80006446:	00003797          	auipc	a5,0x3
    8000644a:	be27b783          	ld	a5,-1054(a5) # 80009028 <uart_tx_w>
    8000644e:	00003717          	auipc	a4,0x3
    80006452:	bd273703          	ld	a4,-1070(a4) # 80009020 <uart_tx_r>
    80006456:	02070713          	addi	a4,a4,32
    8000645a:	02f71b63          	bne	a4,a5,80006490 <uartputc+0x78>
      sleep(&uart_tx_r, &uart_tx_lock);
    8000645e:	00024a17          	auipc	s4,0x24
    80006462:	deaa0a13          	addi	s4,s4,-534 # 8002a248 <uart_tx_lock>
    80006466:	00003497          	auipc	s1,0x3
    8000646a:	bba48493          	addi	s1,s1,-1094 # 80009020 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000646e:	00003917          	auipc	s2,0x3
    80006472:	bba90913          	addi	s2,s2,-1094 # 80009028 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80006476:	85d2                	mv	a1,s4
    80006478:	8526                	mv	a0,s1
    8000647a:	ffffb097          	auipc	ra,0xffffb
    8000647e:	1e6080e7          	jalr	486(ra) # 80001660 <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80006482:	00093783          	ld	a5,0(s2)
    80006486:	6098                	ld	a4,0(s1)
    80006488:	02070713          	addi	a4,a4,32
    8000648c:	fef705e3          	beq	a4,a5,80006476 <uartputc+0x5e>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80006490:	00024497          	auipc	s1,0x24
    80006494:	db848493          	addi	s1,s1,-584 # 8002a248 <uart_tx_lock>
    80006498:	01f7f713          	andi	a4,a5,31
    8000649c:	9726                	add	a4,a4,s1
    8000649e:	03370023          	sb	s3,32(a4)
      uart_tx_w += 1;
    800064a2:	0785                	addi	a5,a5,1
    800064a4:	00003717          	auipc	a4,0x3
    800064a8:	b8f73223          	sd	a5,-1148(a4) # 80009028 <uart_tx_w>
      uartstart();
    800064ac:	00000097          	auipc	ra,0x0
    800064b0:	ee2080e7          	jalr	-286(ra) # 8000638e <uartstart>
      release(&uart_tx_lock);
    800064b4:	8526                	mv	a0,s1
    800064b6:	00000097          	auipc	ra,0x0
    800064ba:	1da080e7          	jalr	474(ra) # 80006690 <release>
}
    800064be:	70a2                	ld	ra,40(sp)
    800064c0:	7402                	ld	s0,32(sp)
    800064c2:	64e2                	ld	s1,24(sp)
    800064c4:	6942                	ld	s2,16(sp)
    800064c6:	69a2                	ld	s3,8(sp)
    800064c8:	6a02                	ld	s4,0(sp)
    800064ca:	6145                	addi	sp,sp,48
    800064cc:	8082                	ret

00000000800064ce <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800064ce:	1141                	addi	sp,sp,-16
    800064d0:	e422                	sd	s0,8(sp)
    800064d2:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800064d4:	100007b7          	lui	a5,0x10000
    800064d8:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800064dc:	8b85                	andi	a5,a5,1
    800064de:	cb91                	beqz	a5,800064f2 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800064e0:	100007b7          	lui	a5,0x10000
    800064e4:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    800064e8:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    800064ec:	6422                	ld	s0,8(sp)
    800064ee:	0141                	addi	sp,sp,16
    800064f0:	8082                	ret
    return -1;
    800064f2:	557d                	li	a0,-1
    800064f4:	bfe5                	j	800064ec <uartgetc+0x1e>

00000000800064f6 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    800064f6:	1101                	addi	sp,sp,-32
    800064f8:	ec06                	sd	ra,24(sp)
    800064fa:	e822                	sd	s0,16(sp)
    800064fc:	e426                	sd	s1,8(sp)
    800064fe:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80006500:	54fd                	li	s1,-1
    int c = uartgetc();
    80006502:	00000097          	auipc	ra,0x0
    80006506:	fcc080e7          	jalr	-52(ra) # 800064ce <uartgetc>
    if(c == -1)
    8000650a:	00950763          	beq	a0,s1,80006518 <uartintr+0x22>
      break;
    consoleintr(c);
    8000650e:	00000097          	auipc	ra,0x0
    80006512:	8fe080e7          	jalr	-1794(ra) # 80005e0c <consoleintr>
  while(1){
    80006516:	b7f5                	j	80006502 <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80006518:	00024497          	auipc	s1,0x24
    8000651c:	d3048493          	addi	s1,s1,-720 # 8002a248 <uart_tx_lock>
    80006520:	8526                	mv	a0,s1
    80006522:	00000097          	auipc	ra,0x0
    80006526:	09e080e7          	jalr	158(ra) # 800065c0 <acquire>
  uartstart();
    8000652a:	00000097          	auipc	ra,0x0
    8000652e:	e64080e7          	jalr	-412(ra) # 8000638e <uartstart>
  release(&uart_tx_lock);
    80006532:	8526                	mv	a0,s1
    80006534:	00000097          	auipc	ra,0x0
    80006538:	15c080e7          	jalr	348(ra) # 80006690 <release>
}
    8000653c:	60e2                	ld	ra,24(sp)
    8000653e:	6442                	ld	s0,16(sp)
    80006540:	64a2                	ld	s1,8(sp)
    80006542:	6105                	addi	sp,sp,32
    80006544:	8082                	ret

0000000080006546 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80006546:	411c                	lw	a5,0(a0)
    80006548:	e399                	bnez	a5,8000654e <holding+0x8>
    8000654a:	4501                	li	a0,0
  return r;
}
    8000654c:	8082                	ret
{
    8000654e:	1101                	addi	sp,sp,-32
    80006550:	ec06                	sd	ra,24(sp)
    80006552:	e822                	sd	s0,16(sp)
    80006554:	e426                	sd	s1,8(sp)
    80006556:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80006558:	6904                	ld	s1,16(a0)
    8000655a:	ffffb097          	auipc	ra,0xffffb
    8000655e:	a2e080e7          	jalr	-1490(ra) # 80000f88 <mycpu>
    80006562:	40a48533          	sub	a0,s1,a0
    80006566:	00153513          	seqz	a0,a0
}
    8000656a:	60e2                	ld	ra,24(sp)
    8000656c:	6442                	ld	s0,16(sp)
    8000656e:	64a2                	ld	s1,8(sp)
    80006570:	6105                	addi	sp,sp,32
    80006572:	8082                	ret

0000000080006574 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80006574:	1101                	addi	sp,sp,-32
    80006576:	ec06                	sd	ra,24(sp)
    80006578:	e822                	sd	s0,16(sp)
    8000657a:	e426                	sd	s1,8(sp)
    8000657c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000657e:	100024f3          	csrr	s1,sstatus
    80006582:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80006586:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80006588:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    8000658c:	ffffb097          	auipc	ra,0xffffb
    80006590:	9fc080e7          	jalr	-1540(ra) # 80000f88 <mycpu>
    80006594:	5d3c                	lw	a5,120(a0)
    80006596:	cf89                	beqz	a5,800065b0 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80006598:	ffffb097          	auipc	ra,0xffffb
    8000659c:	9f0080e7          	jalr	-1552(ra) # 80000f88 <mycpu>
    800065a0:	5d3c                	lw	a5,120(a0)
    800065a2:	2785                	addiw	a5,a5,1
    800065a4:	dd3c                	sw	a5,120(a0)
}
    800065a6:	60e2                	ld	ra,24(sp)
    800065a8:	6442                	ld	s0,16(sp)
    800065aa:	64a2                	ld	s1,8(sp)
    800065ac:	6105                	addi	sp,sp,32
    800065ae:	8082                	ret
    mycpu()->intena = old;
    800065b0:	ffffb097          	auipc	ra,0xffffb
    800065b4:	9d8080e7          	jalr	-1576(ra) # 80000f88 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    800065b8:	8085                	srli	s1,s1,0x1
    800065ba:	8885                	andi	s1,s1,1
    800065bc:	dd64                	sw	s1,124(a0)
    800065be:	bfe9                	j	80006598 <push_off+0x24>

00000000800065c0 <acquire>:
{
    800065c0:	1101                	addi	sp,sp,-32
    800065c2:	ec06                	sd	ra,24(sp)
    800065c4:	e822                	sd	s0,16(sp)
    800065c6:	e426                	sd	s1,8(sp)
    800065c8:	1000                	addi	s0,sp,32
    800065ca:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    800065cc:	00000097          	auipc	ra,0x0
    800065d0:	fa8080e7          	jalr	-88(ra) # 80006574 <push_off>
  if(holding(lk))
    800065d4:	8526                	mv	a0,s1
    800065d6:	00000097          	auipc	ra,0x0
    800065da:	f70080e7          	jalr	-144(ra) # 80006546 <holding>
    800065de:	e911                	bnez	a0,800065f2 <acquire+0x32>
    __sync_fetch_and_add(&(lk->n), 1);
    800065e0:	4785                	li	a5,1
    800065e2:	01c48713          	addi	a4,s1,28
    800065e6:	0f50000f          	fence	iorw,ow
    800065ea:	04f7202f          	amoadd.w.aq	zero,a5,(a4)
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    800065ee:	4705                	li	a4,1
    800065f0:	a839                	j	8000660e <acquire+0x4e>
    panic("acquire");
    800065f2:	00002517          	auipc	a0,0x2
    800065f6:	21e50513          	addi	a0,a0,542 # 80008810 <digits+0x20>
    800065fa:	00000097          	auipc	ra,0x0
    800065fe:	a92080e7          	jalr	-1390(ra) # 8000608c <panic>
    __sync_fetch_and_add(&(lk->nts), 1);
    80006602:	01848793          	addi	a5,s1,24
    80006606:	0f50000f          	fence	iorw,ow
    8000660a:	04e7a02f          	amoadd.w.aq	zero,a4,(a5)
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    8000660e:	87ba                	mv	a5,a4
    80006610:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80006614:	2781                	sext.w	a5,a5
    80006616:	f7f5                	bnez	a5,80006602 <acquire+0x42>
  __sync_synchronize();
    80006618:	0ff0000f          	fence
  lk->cpu = mycpu();
    8000661c:	ffffb097          	auipc	ra,0xffffb
    80006620:	96c080e7          	jalr	-1684(ra) # 80000f88 <mycpu>
    80006624:	e888                	sd	a0,16(s1)
}
    80006626:	60e2                	ld	ra,24(sp)
    80006628:	6442                	ld	s0,16(sp)
    8000662a:	64a2                	ld	s1,8(sp)
    8000662c:	6105                	addi	sp,sp,32
    8000662e:	8082                	ret

0000000080006630 <pop_off>:

void
pop_off(void)
{
    80006630:	1141                	addi	sp,sp,-16
    80006632:	e406                	sd	ra,8(sp)
    80006634:	e022                	sd	s0,0(sp)
    80006636:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80006638:	ffffb097          	auipc	ra,0xffffb
    8000663c:	950080e7          	jalr	-1712(ra) # 80000f88 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80006640:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80006644:	8b89                	andi	a5,a5,2
  if(intr_get())
    80006646:	e78d                	bnez	a5,80006670 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80006648:	5d3c                	lw	a5,120(a0)
    8000664a:	02f05b63          	blez	a5,80006680 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    8000664e:	37fd                	addiw	a5,a5,-1
    80006650:	0007871b          	sext.w	a4,a5
    80006654:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80006656:	eb09                	bnez	a4,80006668 <pop_off+0x38>
    80006658:	5d7c                	lw	a5,124(a0)
    8000665a:	c799                	beqz	a5,80006668 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000665c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80006660:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80006664:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80006668:	60a2                	ld	ra,8(sp)
    8000666a:	6402                	ld	s0,0(sp)
    8000666c:	0141                	addi	sp,sp,16
    8000666e:	8082                	ret
    panic("pop_off - interruptible");
    80006670:	00002517          	auipc	a0,0x2
    80006674:	1a850513          	addi	a0,a0,424 # 80008818 <digits+0x28>
    80006678:	00000097          	auipc	ra,0x0
    8000667c:	a14080e7          	jalr	-1516(ra) # 8000608c <panic>
    panic("pop_off");
    80006680:	00002517          	auipc	a0,0x2
    80006684:	1b050513          	addi	a0,a0,432 # 80008830 <digits+0x40>
    80006688:	00000097          	auipc	ra,0x0
    8000668c:	a04080e7          	jalr	-1532(ra) # 8000608c <panic>

0000000080006690 <release>:
{
    80006690:	1101                	addi	sp,sp,-32
    80006692:	ec06                	sd	ra,24(sp)
    80006694:	e822                	sd	s0,16(sp)
    80006696:	e426                	sd	s1,8(sp)
    80006698:	1000                	addi	s0,sp,32
    8000669a:	84aa                	mv	s1,a0
  if(!holding(lk))
    8000669c:	00000097          	auipc	ra,0x0
    800066a0:	eaa080e7          	jalr	-342(ra) # 80006546 <holding>
    800066a4:	c115                	beqz	a0,800066c8 <release+0x38>
  lk->cpu = 0;
    800066a6:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    800066aa:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    800066ae:	0f50000f          	fence	iorw,ow
    800066b2:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    800066b6:	00000097          	auipc	ra,0x0
    800066ba:	f7a080e7          	jalr	-134(ra) # 80006630 <pop_off>
}
    800066be:	60e2                	ld	ra,24(sp)
    800066c0:	6442                	ld	s0,16(sp)
    800066c2:	64a2                	ld	s1,8(sp)
    800066c4:	6105                	addi	sp,sp,32
    800066c6:	8082                	ret
    panic("release");
    800066c8:	00002517          	auipc	a0,0x2
    800066cc:	17050513          	addi	a0,a0,368 # 80008838 <digits+0x48>
    800066d0:	00000097          	auipc	ra,0x0
    800066d4:	9bc080e7          	jalr	-1604(ra) # 8000608c <panic>

00000000800066d8 <freelock>:
{
    800066d8:	1101                	addi	sp,sp,-32
    800066da:	ec06                	sd	ra,24(sp)
    800066dc:	e822                	sd	s0,16(sp)
    800066de:	e426                	sd	s1,8(sp)
    800066e0:	1000                	addi	s0,sp,32
    800066e2:	84aa                	mv	s1,a0
  acquire(&lock_locks);
    800066e4:	00024517          	auipc	a0,0x24
    800066e8:	ba450513          	addi	a0,a0,-1116 # 8002a288 <lock_locks>
    800066ec:	00000097          	auipc	ra,0x0
    800066f0:	ed4080e7          	jalr	-300(ra) # 800065c0 <acquire>
  for (i = 0; i < NLOCK; i++) {
    800066f4:	00024717          	auipc	a4,0x24
    800066f8:	bb470713          	addi	a4,a4,-1100 # 8002a2a8 <locks>
    800066fc:	4781                	li	a5,0
    800066fe:	1f400613          	li	a2,500
    if(locks[i] == lk) {
    80006702:	6314                	ld	a3,0(a4)
    80006704:	00968763          	beq	a3,s1,80006712 <freelock+0x3a>
  for (i = 0; i < NLOCK; i++) {
    80006708:	2785                	addiw	a5,a5,1
    8000670a:	0721                	addi	a4,a4,8
    8000670c:	fec79be3          	bne	a5,a2,80006702 <freelock+0x2a>
    80006710:	a809                	j	80006722 <freelock+0x4a>
      locks[i] = 0;
    80006712:	078e                	slli	a5,a5,0x3
    80006714:	00024717          	auipc	a4,0x24
    80006718:	b9470713          	addi	a4,a4,-1132 # 8002a2a8 <locks>
    8000671c:	97ba                	add	a5,a5,a4
    8000671e:	0007b023          	sd	zero,0(a5)
  release(&lock_locks);
    80006722:	00024517          	auipc	a0,0x24
    80006726:	b6650513          	addi	a0,a0,-1178 # 8002a288 <lock_locks>
    8000672a:	00000097          	auipc	ra,0x0
    8000672e:	f66080e7          	jalr	-154(ra) # 80006690 <release>
}
    80006732:	60e2                	ld	ra,24(sp)
    80006734:	6442                	ld	s0,16(sp)
    80006736:	64a2                	ld	s1,8(sp)
    80006738:	6105                	addi	sp,sp,32
    8000673a:	8082                	ret

000000008000673c <initlock>:
{
    8000673c:	1101                	addi	sp,sp,-32
    8000673e:	ec06                	sd	ra,24(sp)
    80006740:	e822                	sd	s0,16(sp)
    80006742:	e426                	sd	s1,8(sp)
    80006744:	1000                	addi	s0,sp,32
    80006746:	84aa                	mv	s1,a0
  lk->name = name;
    80006748:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    8000674a:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    8000674e:	00053823          	sd	zero,16(a0)
  lk->nts = 0;
    80006752:	00052c23          	sw	zero,24(a0)
  lk->n = 0;
    80006756:	00052e23          	sw	zero,28(a0)
  acquire(&lock_locks);
    8000675a:	00024517          	auipc	a0,0x24
    8000675e:	b2e50513          	addi	a0,a0,-1234 # 8002a288 <lock_locks>
    80006762:	00000097          	auipc	ra,0x0
    80006766:	e5e080e7          	jalr	-418(ra) # 800065c0 <acquire>
  for (i = 0; i < NLOCK; i++) {
    8000676a:	00024717          	auipc	a4,0x24
    8000676e:	b3e70713          	addi	a4,a4,-1218 # 8002a2a8 <locks>
    80006772:	4781                	li	a5,0
    80006774:	1f400693          	li	a3,500
    if(locks[i] == 0) {
    80006778:	6310                	ld	a2,0(a4)
    8000677a:	ce09                	beqz	a2,80006794 <initlock+0x58>
  for (i = 0; i < NLOCK; i++) {
    8000677c:	2785                	addiw	a5,a5,1
    8000677e:	0721                	addi	a4,a4,8
    80006780:	fed79ce3          	bne	a5,a3,80006778 <initlock+0x3c>
  panic("findslot");
    80006784:	00002517          	auipc	a0,0x2
    80006788:	0bc50513          	addi	a0,a0,188 # 80008840 <digits+0x50>
    8000678c:	00000097          	auipc	ra,0x0
    80006790:	900080e7          	jalr	-1792(ra) # 8000608c <panic>
      locks[i] = lk;
    80006794:	078e                	slli	a5,a5,0x3
    80006796:	00024717          	auipc	a4,0x24
    8000679a:	b1270713          	addi	a4,a4,-1262 # 8002a2a8 <locks>
    8000679e:	97ba                	add	a5,a5,a4
    800067a0:	e384                	sd	s1,0(a5)
      release(&lock_locks);
    800067a2:	00024517          	auipc	a0,0x24
    800067a6:	ae650513          	addi	a0,a0,-1306 # 8002a288 <lock_locks>
    800067aa:	00000097          	auipc	ra,0x0
    800067ae:	ee6080e7          	jalr	-282(ra) # 80006690 <release>
}
    800067b2:	60e2                	ld	ra,24(sp)
    800067b4:	6442                	ld	s0,16(sp)
    800067b6:	64a2                	ld	s1,8(sp)
    800067b8:	6105                	addi	sp,sp,32
    800067ba:	8082                	ret

00000000800067bc <lockfree_read8>:

// Read a shared 64-bit value without holding a lock
uint64
lockfree_read8(uint64 *addr) {
    800067bc:	1141                	addi	sp,sp,-16
    800067be:	e422                	sd	s0,8(sp)
    800067c0:	0800                	addi	s0,sp,16
  uint64 val;
  __atomic_load(addr, &val, __ATOMIC_SEQ_CST);
    800067c2:	0ff0000f          	fence
    800067c6:	6108                	ld	a0,0(a0)
    800067c8:	0ff0000f          	fence
  return val;
}
    800067cc:	6422                	ld	s0,8(sp)
    800067ce:	0141                	addi	sp,sp,16
    800067d0:	8082                	ret

00000000800067d2 <lockfree_read4>:

// Read a shared 32-bit value without holding a lock
int
lockfree_read4(int *addr) {
    800067d2:	1141                	addi	sp,sp,-16
    800067d4:	e422                	sd	s0,8(sp)
    800067d6:	0800                	addi	s0,sp,16
  uint32 val;
  __atomic_load(addr, &val, __ATOMIC_SEQ_CST);
    800067d8:	0ff0000f          	fence
    800067dc:	4108                	lw	a0,0(a0)
    800067de:	0ff0000f          	fence
  return val;
}
    800067e2:	2501                	sext.w	a0,a0
    800067e4:	6422                	ld	s0,8(sp)
    800067e6:	0141                	addi	sp,sp,16
    800067e8:	8082                	ret

00000000800067ea <snprint_lock>:
#ifdef LAB_LOCK
int
snprint_lock(char *buf, int sz, struct spinlock *lk)
{
  int n = 0;
  if(lk->n > 0) {
    800067ea:	4e5c                	lw	a5,28(a2)
    800067ec:	00f04463          	bgtz	a5,800067f4 <snprint_lock+0xa>
  int n = 0;
    800067f0:	4501                	li	a0,0
    n = snprintf(buf, sz, "lock: %s: #test-and-set %d #acquire() %d\n",
                 lk->name, lk->nts, lk->n);
  }
  return n;
}
    800067f2:	8082                	ret
{
    800067f4:	1141                	addi	sp,sp,-16
    800067f6:	e406                	sd	ra,8(sp)
    800067f8:	e022                	sd	s0,0(sp)
    800067fa:	0800                	addi	s0,sp,16
    n = snprintf(buf, sz, "lock: %s: #test-and-set %d #acquire() %d\n",
    800067fc:	4e18                	lw	a4,24(a2)
    800067fe:	6614                	ld	a3,8(a2)
    80006800:	00002617          	auipc	a2,0x2
    80006804:	05060613          	addi	a2,a2,80 # 80008850 <digits+0x60>
    80006808:	fffff097          	auipc	ra,0xfffff
    8000680c:	1ea080e7          	jalr	490(ra) # 800059f2 <snprintf>
}
    80006810:	60a2                	ld	ra,8(sp)
    80006812:	6402                	ld	s0,0(sp)
    80006814:	0141                	addi	sp,sp,16
    80006816:	8082                	ret

0000000080006818 <statslock>:

int
statslock(char *buf, int sz) {
    80006818:	7159                	addi	sp,sp,-112
    8000681a:	f486                	sd	ra,104(sp)
    8000681c:	f0a2                	sd	s0,96(sp)
    8000681e:	eca6                	sd	s1,88(sp)
    80006820:	e8ca                	sd	s2,80(sp)
    80006822:	e4ce                	sd	s3,72(sp)
    80006824:	e0d2                	sd	s4,64(sp)
    80006826:	fc56                	sd	s5,56(sp)
    80006828:	f85a                	sd	s6,48(sp)
    8000682a:	f45e                	sd	s7,40(sp)
    8000682c:	f062                	sd	s8,32(sp)
    8000682e:	ec66                	sd	s9,24(sp)
    80006830:	e86a                	sd	s10,16(sp)
    80006832:	e46e                	sd	s11,8(sp)
    80006834:	1880                	addi	s0,sp,112
    80006836:	8aaa                	mv	s5,a0
    80006838:	8b2e                	mv	s6,a1
  int n;
  int tot = 0;

  acquire(&lock_locks);
    8000683a:	00024517          	auipc	a0,0x24
    8000683e:	a4e50513          	addi	a0,a0,-1458 # 8002a288 <lock_locks>
    80006842:	00000097          	auipc	ra,0x0
    80006846:	d7e080e7          	jalr	-642(ra) # 800065c0 <acquire>
  n = snprintf(buf, sz, "--- lock kmem/bcache stats\n");
    8000684a:	00002617          	auipc	a2,0x2
    8000684e:	03660613          	addi	a2,a2,54 # 80008880 <digits+0x90>
    80006852:	85da                	mv	a1,s6
    80006854:	8556                	mv	a0,s5
    80006856:	fffff097          	auipc	ra,0xfffff
    8000685a:	19c080e7          	jalr	412(ra) # 800059f2 <snprintf>
    8000685e:	892a                	mv	s2,a0
  for(int i = 0; i < NLOCK; i++) {
    80006860:	00024c97          	auipc	s9,0x24
    80006864:	a48c8c93          	addi	s9,s9,-1464 # 8002a2a8 <locks>
    80006868:	00025c17          	auipc	s8,0x25
    8000686c:	9e0c0c13          	addi	s8,s8,-1568 # 8002b248 <end>
  n = snprintf(buf, sz, "--- lock kmem/bcache stats\n");
    80006870:	84e6                	mv	s1,s9
  int tot = 0;
    80006872:	4a01                	li	s4,0
    if(locks[i] == 0)
      break;
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    80006874:	00002b97          	auipc	s7,0x2
    80006878:	02cb8b93          	addi	s7,s7,44 # 800088a0 <digits+0xb0>
       strncmp(locks[i]->name, "kmem", strlen("kmem")) == 0) {
    8000687c:	00002d17          	auipc	s10,0x2
    80006880:	02cd0d13          	addi	s10,s10,44 # 800088a8 <digits+0xb8>
    80006884:	a01d                	j	800068aa <statslock+0x92>
      tot += locks[i]->nts;
    80006886:	0009b603          	ld	a2,0(s3)
    8000688a:	4e1c                	lw	a5,24(a2)
    8000688c:	01478a3b          	addw	s4,a5,s4
      n += snprint_lock(buf +n, sz-n, locks[i]);
    80006890:	412b05bb          	subw	a1,s6,s2
    80006894:	012a8533          	add	a0,s5,s2
    80006898:	00000097          	auipc	ra,0x0
    8000689c:	f52080e7          	jalr	-174(ra) # 800067ea <snprint_lock>
    800068a0:	0125093b          	addw	s2,a0,s2
  for(int i = 0; i < NLOCK; i++) {
    800068a4:	04a1                	addi	s1,s1,8
    800068a6:	05848763          	beq	s1,s8,800068f4 <statslock+0xdc>
    if(locks[i] == 0)
    800068aa:	89a6                	mv	s3,s1
    800068ac:	609c                	ld	a5,0(s1)
    800068ae:	c3b9                	beqz	a5,800068f4 <statslock+0xdc>
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    800068b0:	0087bd83          	ld	s11,8(a5)
    800068b4:	855e                	mv	a0,s7
    800068b6:	ffffa097          	auipc	ra,0xffffa
    800068ba:	b92080e7          	jalr	-1134(ra) # 80000448 <strlen>
    800068be:	0005061b          	sext.w	a2,a0
    800068c2:	85de                	mv	a1,s7
    800068c4:	856e                	mv	a0,s11
    800068c6:	ffffa097          	auipc	ra,0xffffa
    800068ca:	ad6080e7          	jalr	-1322(ra) # 8000039c <strncmp>
    800068ce:	dd45                	beqz	a0,80006886 <statslock+0x6e>
       strncmp(locks[i]->name, "kmem", strlen("kmem")) == 0) {
    800068d0:	609c                	ld	a5,0(s1)
    800068d2:	0087bd83          	ld	s11,8(a5)
    800068d6:	856a                	mv	a0,s10
    800068d8:	ffffa097          	auipc	ra,0xffffa
    800068dc:	b70080e7          	jalr	-1168(ra) # 80000448 <strlen>
    800068e0:	0005061b          	sext.w	a2,a0
    800068e4:	85ea                	mv	a1,s10
    800068e6:	856e                	mv	a0,s11
    800068e8:	ffffa097          	auipc	ra,0xffffa
    800068ec:	ab4080e7          	jalr	-1356(ra) # 8000039c <strncmp>
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    800068f0:	f955                	bnez	a0,800068a4 <statslock+0x8c>
    800068f2:	bf51                	j	80006886 <statslock+0x6e>
    }
  }
  
  n += snprintf(buf+n, sz-n, "--- top 5 contended locks:\n");
    800068f4:	00002617          	auipc	a2,0x2
    800068f8:	fbc60613          	addi	a2,a2,-68 # 800088b0 <digits+0xc0>
    800068fc:	412b05bb          	subw	a1,s6,s2
    80006900:	012a8533          	add	a0,s5,s2
    80006904:	fffff097          	auipc	ra,0xfffff
    80006908:	0ee080e7          	jalr	238(ra) # 800059f2 <snprintf>
    8000690c:	012509bb          	addw	s3,a0,s2
    80006910:	4b95                	li	s7,5
  int last = 100000000;
    80006912:	05f5e537          	lui	a0,0x5f5e
    80006916:	10050513          	addi	a0,a0,256 # 5f5e100 <_entry-0x7a0a1f00>
  // stupid way to compute top 5 contended locks
  for(int t = 0; t < 5; t++) {
    int top = 0;
    for(int i = 0; i < NLOCK; i++) {
    8000691a:	4c01                	li	s8,0
      if(locks[i] == 0)
        break;
      if(locks[i]->nts > locks[top]->nts && locks[i]->nts < last) {
    8000691c:	00024497          	auipc	s1,0x24
    80006920:	98c48493          	addi	s1,s1,-1652 # 8002a2a8 <locks>
    for(int i = 0; i < NLOCK; i++) {
    80006924:	1f400913          	li	s2,500
    80006928:	a881                	j	80006978 <statslock+0x160>
    8000692a:	2705                	addiw	a4,a4,1
    8000692c:	06a1                	addi	a3,a3,8
    8000692e:	03270063          	beq	a4,s2,8000694e <statslock+0x136>
      if(locks[i] == 0)
    80006932:	629c                	ld	a5,0(a3)
    80006934:	cf89                	beqz	a5,8000694e <statslock+0x136>
      if(locks[i]->nts > locks[top]->nts && locks[i]->nts < last) {
    80006936:	4f90                	lw	a2,24(a5)
    80006938:	00359793          	slli	a5,a1,0x3
    8000693c:	97a6                	add	a5,a5,s1
    8000693e:	639c                	ld	a5,0(a5)
    80006940:	4f9c                	lw	a5,24(a5)
    80006942:	fec7d4e3          	bge	a5,a2,8000692a <statslock+0x112>
    80006946:	fea652e3          	bge	a2,a0,8000692a <statslock+0x112>
    8000694a:	85ba                	mv	a1,a4
    8000694c:	bff9                	j	8000692a <statslock+0x112>
        top = i;
      }
    }
    n += snprint_lock(buf+n, sz-n, locks[top]);
    8000694e:	058e                	slli	a1,a1,0x3
    80006950:	00b48d33          	add	s10,s1,a1
    80006954:	000d3603          	ld	a2,0(s10)
    80006958:	413b05bb          	subw	a1,s6,s3
    8000695c:	013a8533          	add	a0,s5,s3
    80006960:	00000097          	auipc	ra,0x0
    80006964:	e8a080e7          	jalr	-374(ra) # 800067ea <snprint_lock>
    80006968:	013509bb          	addw	s3,a0,s3
    last = locks[top]->nts;
    8000696c:	000d3783          	ld	a5,0(s10)
    80006970:	4f88                	lw	a0,24(a5)
  for(int t = 0; t < 5; t++) {
    80006972:	3bfd                	addiw	s7,s7,-1
    80006974:	000b8663          	beqz	s7,80006980 <statslock+0x168>
  int tot = 0;
    80006978:	86e6                	mv	a3,s9
    for(int i = 0; i < NLOCK; i++) {
    8000697a:	8762                	mv	a4,s8
    int top = 0;
    8000697c:	85e2                	mv	a1,s8
    8000697e:	bf55                	j	80006932 <statslock+0x11a>
  }
  n += snprintf(buf+n, sz-n, "tot= %d\n", tot);
    80006980:	86d2                	mv	a3,s4
    80006982:	00002617          	auipc	a2,0x2
    80006986:	f4e60613          	addi	a2,a2,-178 # 800088d0 <digits+0xe0>
    8000698a:	413b05bb          	subw	a1,s6,s3
    8000698e:	013a8533          	add	a0,s5,s3
    80006992:	fffff097          	auipc	ra,0xfffff
    80006996:	060080e7          	jalr	96(ra) # 800059f2 <snprintf>
    8000699a:	013509bb          	addw	s3,a0,s3
  release(&lock_locks);  
    8000699e:	00024517          	auipc	a0,0x24
    800069a2:	8ea50513          	addi	a0,a0,-1814 # 8002a288 <lock_locks>
    800069a6:	00000097          	auipc	ra,0x0
    800069aa:	cea080e7          	jalr	-790(ra) # 80006690 <release>
  return n;
}
    800069ae:	854e                	mv	a0,s3
    800069b0:	70a6                	ld	ra,104(sp)
    800069b2:	7406                	ld	s0,96(sp)
    800069b4:	64e6                	ld	s1,88(sp)
    800069b6:	6946                	ld	s2,80(sp)
    800069b8:	69a6                	ld	s3,72(sp)
    800069ba:	6a06                	ld	s4,64(sp)
    800069bc:	7ae2                	ld	s5,56(sp)
    800069be:	7b42                	ld	s6,48(sp)
    800069c0:	7ba2                	ld	s7,40(sp)
    800069c2:	7c02                	ld	s8,32(sp)
    800069c4:	6ce2                	ld	s9,24(sp)
    800069c6:	6d42                	ld	s10,16(sp)
    800069c8:	6da2                	ld	s11,8(sp)
    800069ca:	6165                	addi	sp,sp,112
    800069cc:	8082                	ret
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
