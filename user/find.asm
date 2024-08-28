
user/_find:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <find>:
#include "kernel/stat.h"
#include "kernel/fs.h"
#include "kernel/fcntl.h"
#include "user/user.h"

void find(const char *path, const char *name) {
   0:	7109                	addi	sp,sp,-384
   2:	fe86                	sd	ra,376(sp)
   4:	faa2                	sd	s0,368(sp)
   6:	f6a6                	sd	s1,360(sp)
   8:	f2ca                	sd	s2,352(sp)
   a:	eece                	sd	s3,344(sp)
   c:	ead2                	sd	s4,336(sp)
   e:	e6d6                	sd	s5,328(sp)
  10:	e2da                	sd	s6,320(sp)
  12:	fe5e                	sd	s7,312(sp)
  14:	fa62                	sd	s8,304(sp)
  16:	0300                	addi	s0,sp,384
  18:	892a                	mv	s2,a0
  1a:	89ae                	mv	s3,a1
    int fd = open(path, O_RDONLY);
  1c:	4581                	li	a1,0
  1e:	00000097          	auipc	ra,0x0
  22:	5de080e7          	jalr	1502(ra) # 5fc <open>
    if (fd < 0) {
  26:	04054763          	bltz	a0,74 <find+0x74>
  2a:	84aa                	mv	s1,a0
        fprintf(2, "find: cannot open %s\n", path);
        exit(1);
    }
    struct stat st;
    if (fstat(fd, &st) < 0) {
  2c:	f9840593          	addi	a1,s0,-104
  30:	00000097          	auipc	ra,0x0
  34:	5e4080e7          	jalr	1508(ra) # 614 <fstat>
  38:	04054d63          	bltz	a0,92 <find+0x92>
        fprintf(2, "find: cannot fstat %s\n", path);
        close(fd);
        exit(1);
    }
    if (st.type == T_FILE) {
  3c:	fa041783          	lh	a5,-96(s0)
  40:	0007869b          	sext.w	a3,a5
  44:	4709                	li	a4,2
  46:	06e68a63          	beq	a3,a4,ba <find+0xba>
        int i;
        for (i = strlen(path); path[i-1] != '/'; i--);
        if (strcmp(path + i, name) == 0)
            printf("%s\n", path);
    }
    else if (st.type == T_DIR) {
  4a:	2781                	sext.w	a5,a5
  4c:	4705                	li	a4,1
  4e:	0ce78463          	beq	a5,a4,116 <find+0x116>
            }
            memmove(p, de.name, DIRSIZ);
            find(buf, name);
        }
    }
    close(fd);
  52:	8526                	mv	a0,s1
  54:	00000097          	auipc	ra,0x0
  58:	590080e7          	jalr	1424(ra) # 5e4 <close>
}
  5c:	70f6                	ld	ra,376(sp)
  5e:	7456                	ld	s0,368(sp)
  60:	74b6                	ld	s1,360(sp)
  62:	7916                	ld	s2,352(sp)
  64:	69f6                	ld	s3,344(sp)
  66:	6a56                	ld	s4,336(sp)
  68:	6ab6                	ld	s5,328(sp)
  6a:	6b16                	ld	s6,320(sp)
  6c:	7bf2                	ld	s7,312(sp)
  6e:	7c52                	ld	s8,304(sp)
  70:	6119                	addi	sp,sp,384
  72:	8082                	ret
        fprintf(2, "find: cannot open %s\n", path);
  74:	864a                	mv	a2,s2
  76:	00001597          	auipc	a1,0x1
  7a:	a6258593          	addi	a1,a1,-1438 # ad8 <malloc+0xe6>
  7e:	4509                	li	a0,2
  80:	00001097          	auipc	ra,0x1
  84:	886080e7          	jalr	-1914(ra) # 906 <fprintf>
        exit(1);
  88:	4505                	li	a0,1
  8a:	00000097          	auipc	ra,0x0
  8e:	532080e7          	jalr	1330(ra) # 5bc <exit>
        fprintf(2, "find: cannot fstat %s\n", path);
  92:	864a                	mv	a2,s2
  94:	00001597          	auipc	a1,0x1
  98:	a5c58593          	addi	a1,a1,-1444 # af0 <malloc+0xfe>
  9c:	4509                	li	a0,2
  9e:	00001097          	auipc	ra,0x1
  a2:	868080e7          	jalr	-1944(ra) # 906 <fprintf>
        close(fd);
  a6:	8526                	mv	a0,s1
  a8:	00000097          	auipc	ra,0x0
  ac:	53c080e7          	jalr	1340(ra) # 5e4 <close>
        exit(1);
  b0:	4505                	li	a0,1
  b2:	00000097          	auipc	ra,0x0
  b6:	50a080e7          	jalr	1290(ra) # 5bc <exit>
        for (i = strlen(path); path[i-1] != '/'; i--);
  ba:	854a                	mv	a0,s2
  bc:	00000097          	auipc	ra,0x0
  c0:	2d2080e7          	jalr	722(ra) # 38e <strlen>
  c4:	2501                	sext.w	a0,a0
  c6:	00a907b3          	add	a5,s2,a0
  ca:	fff7c703          	lbu	a4,-1(a5)
  ce:	02f00793          	li	a5,47
  d2:	02f70163          	beq	a4,a5,f4 <find+0xf4>
  d6:	1579                	addi	a0,a0,-2
  d8:	00a907b3          	add	a5,s2,a0
  dc:	4685                	li	a3,1
  de:	412686b3          	sub	a3,a3,s2
  e2:	02f00613          	li	a2,47
  e6:	00f68533          	add	a0,a3,a5
  ea:	17fd                	addi	a5,a5,-1
  ec:	0017c703          	lbu	a4,1(a5)
  f0:	fec71be3          	bne	a4,a2,e6 <find+0xe6>
        if (strcmp(path + i, name) == 0)
  f4:	85ce                	mv	a1,s3
  f6:	954a                	add	a0,a0,s2
  f8:	00000097          	auipc	ra,0x0
  fc:	26a080e7          	jalr	618(ra) # 362 <strcmp>
 100:	f929                	bnez	a0,52 <find+0x52>
            printf("%s\n", path);
 102:	85ca                	mv	a1,s2
 104:	00001517          	auipc	a0,0x1
 108:	a0450513          	addi	a0,a0,-1532 # b08 <malloc+0x116>
 10c:	00001097          	auipc	ra,0x1
 110:	828080e7          	jalr	-2008(ra) # 934 <printf>
 114:	bf3d                	j	52 <find+0x52>
        strcpy(buf, path);
 116:	85ca                	mv	a1,s2
 118:	e9840513          	addi	a0,s0,-360
 11c:	00000097          	auipc	ra,0x0
 120:	22a080e7          	jalr	554(ra) # 346 <strcpy>
        char *p = buf + strlen(buf);
 124:	e9840513          	addi	a0,s0,-360
 128:	00000097          	auipc	ra,0x0
 12c:	266080e7          	jalr	614(ra) # 38e <strlen>
 130:	1502                	slli	a0,a0,0x20
 132:	9101                	srli	a0,a0,0x20
 134:	e9840793          	addi	a5,s0,-360
 138:	953e                	add	a0,a0,a5
        *p++ = '/';
 13a:	00150c13          	addi	s8,a0,1
 13e:	02f00793          	li	a5,47
 142:	00f50023          	sb	a5,0(a0)
            if (strcmp(de.name, ".") == 0 || strcmp(de.name, "..") == 0)
 146:	00001a97          	auipc	s5,0x1
 14a:	9caa8a93          	addi	s5,s5,-1590 # b10 <malloc+0x11e>
 14e:	00001b17          	auipc	s6,0x1
 152:	9cab0b13          	addi	s6,s6,-1590 # b18 <malloc+0x126>
 156:	e8a40a13          	addi	s4,s0,-374
            if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf) {
 15a:	10000b93          	li	s7,256
        while (read(fd, &de, sizeof(de)) == sizeof(de)) {
 15e:	4641                	li	a2,16
 160:	e8840593          	addi	a1,s0,-376
 164:	8526                	mv	a0,s1
 166:	00000097          	auipc	ra,0x0
 16a:	46e080e7          	jalr	1134(ra) # 5d4 <read>
 16e:	47c1                	li	a5,16
 170:	eef511e3          	bne	a0,a5,52 <find+0x52>
            if(de.inum == 0)
 174:	e8845783          	lhu	a5,-376(s0)
 178:	d3fd                	beqz	a5,15e <find+0x15e>
            if (strcmp(de.name, ".") == 0 || strcmp(de.name, "..") == 0)
 17a:	85d6                	mv	a1,s5
 17c:	8552                	mv	a0,s4
 17e:	00000097          	auipc	ra,0x0
 182:	1e4080e7          	jalr	484(ra) # 362 <strcmp>
 186:	dd61                	beqz	a0,15e <find+0x15e>
 188:	85da                	mv	a1,s6
 18a:	8552                	mv	a0,s4
 18c:	00000097          	auipc	ra,0x0
 190:	1d6080e7          	jalr	470(ra) # 362 <strcmp>
 194:	d569                	beqz	a0,15e <find+0x15e>
            if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf) {
 196:	854a                	mv	a0,s2
 198:	00000097          	auipc	ra,0x0
 19c:	1f6080e7          	jalr	502(ra) # 38e <strlen>
 1a0:	2541                	addiw	a0,a0,16
 1a2:	02abe263          	bltu	s7,a0,1c6 <find+0x1c6>
            memmove(p, de.name, DIRSIZ);
 1a6:	4639                	li	a2,14
 1a8:	e8a40593          	addi	a1,s0,-374
 1ac:	8562                	mv	a0,s8
 1ae:	00000097          	auipc	ra,0x0
 1b2:	358080e7          	jalr	856(ra) # 506 <memmove>
            find(buf, name);
 1b6:	85ce                	mv	a1,s3
 1b8:	e9840513          	addi	a0,s0,-360
 1bc:	00000097          	auipc	ra,0x0
 1c0:	e44080e7          	jalr	-444(ra) # 0 <find>
 1c4:	bf69                	j	15e <find+0x15e>
                printf("find: path too long\n");
 1c6:	00001517          	auipc	a0,0x1
 1ca:	95a50513          	addi	a0,a0,-1702 # b20 <malloc+0x12e>
 1ce:	00000097          	auipc	ra,0x0
 1d2:	766080e7          	jalr	1894(ra) # 934 <printf>
                close(fd);
 1d6:	8526                	mv	a0,s1
 1d8:	00000097          	auipc	ra,0x0
 1dc:	40c080e7          	jalr	1036(ra) # 5e4 <close>
                exit(1);
 1e0:	4505                	li	a0,1
 1e2:	00000097          	auipc	ra,0x0
 1e6:	3da080e7          	jalr	986(ra) # 5bc <exit>

00000000000001ea <main>:

int main(int argc, char const *argv[]) {
 1ea:	7129                	addi	sp,sp,-320
 1ec:	fe06                	sd	ra,312(sp)
 1ee:	fa22                	sd	s0,304(sp)
 1f0:	f626                	sd	s1,296(sp)
 1f2:	f24a                	sd	s2,288(sp)
 1f4:	0280                	addi	s0,sp,320
    if (argc != 3) {
 1f6:	478d                	li	a5,3
 1f8:	02f50063          	beq	a0,a5,218 <main+0x2e>
        fprintf(2, "Usage: find DIR FILENAME\n");
 1fc:	00001597          	auipc	a1,0x1
 200:	93c58593          	addi	a1,a1,-1732 # b38 <malloc+0x146>
 204:	4509                	li	a0,2
 206:	00000097          	auipc	ra,0x0
 20a:	700080e7          	jalr	1792(ra) # 906 <fprintf>
        exit(1);
 20e:	4505                	li	a0,1
 210:	00000097          	auipc	ra,0x0
 214:	3ac080e7          	jalr	940(ra) # 5bc <exit>
 218:	84ae                	mv	s1,a1
    }
    char dir[256];
    if (strlen(argv[1]) > 255) {
 21a:	6588                	ld	a0,8(a1)
 21c:	00000097          	auipc	ra,0x0
 220:	172080e7          	jalr	370(ra) # 38e <strlen>
 224:	2501                	sext.w	a0,a0
 226:	0ff00793          	li	a5,255
 22a:	00a7ff63          	bgeu	a5,a0,248 <main+0x5e>
        printf("find: path too long\n");
 22e:	00001517          	auipc	a0,0x1
 232:	8f250513          	addi	a0,a0,-1806 # b20 <malloc+0x12e>
 236:	00000097          	auipc	ra,0x0
 23a:	6fe080e7          	jalr	1790(ra) # 934 <printf>
        exit(1);
 23e:	4505                	li	a0,1
 240:	00000097          	auipc	ra,0x0
 244:	37c080e7          	jalr	892(ra) # 5bc <exit>
    }
    strcpy(dir, argv[1]);
 248:	648c                	ld	a1,8(s1)
 24a:	ee040513          	addi	a0,s0,-288
 24e:	00000097          	auipc	ra,0x0
 252:	0f8080e7          	jalr	248(ra) # 346 <strcpy>
    char *p = dir + strlen(dir) - 1;
 256:	ee040513          	addi	a0,s0,-288
 25a:	00000097          	auipc	ra,0x0
 25e:	134080e7          	jalr	308(ra) # 38e <strlen>
 262:	02051793          	slli	a5,a0,0x20
 266:	9381                	srli	a5,a5,0x20
 268:	17fd                	addi	a5,a5,-1
 26a:	ee040713          	addi	a4,s0,-288
 26e:	97ba                	add	a5,a5,a4
    while (*p == '/')
 270:	0007c683          	lbu	a3,0(a5)
 274:	02f00713          	li	a4,47
 278:	00e69b63          	bne	a3,a4,28e <main+0xa4>
 27c:	02f00693          	li	a3,47
        *p-- = 0;
 280:	17fd                	addi	a5,a5,-1
 282:	000780a3          	sb	zero,1(a5)
    while (*p == '/')
 286:	0007c703          	lbu	a4,0(a5)
 28a:	fed70be3          	beq	a4,a3,280 <main+0x96>
    int fd = open(dir, O_RDONLY);
 28e:	4581                	li	a1,0
 290:	ee040513          	addi	a0,s0,-288
 294:	00000097          	auipc	ra,0x0
 298:	368080e7          	jalr	872(ra) # 5fc <open>
 29c:	892a                	mv	s2,a0
    if (fd < 0) {
 29e:	04054363          	bltz	a0,2e4 <main+0xfa>
        fprintf(2, "find: cannot open %s\n", dir);
        exit(1);
    }
    struct stat st;
    if (fstat(fd, &st) < 0) {
 2a2:	ec840593          	addi	a1,s0,-312
 2a6:	00000097          	auipc	ra,0x0
 2aa:	36e080e7          	jalr	878(ra) # 614 <fstat>
 2ae:	04054b63          	bltz	a0,304 <main+0x11a>
        fprintf(2, "find: cannot fstat %s\n", dir);
        close(fd);
        exit(1);
    }
    if (st.type != T_DIR) {
 2b2:	ed041703          	lh	a4,-304(s0)
 2b6:	4785                	li	a5,1
 2b8:	06f70b63          	beq	a4,a5,32e <main+0x144>
        fprintf(2, "'%s' is not a directory\n", argv[1]);
 2bc:	6490                	ld	a2,8(s1)
 2be:	00001597          	auipc	a1,0x1
 2c2:	89a58593          	addi	a1,a1,-1894 # b58 <malloc+0x166>
 2c6:	4509                	li	a0,2
 2c8:	00000097          	auipc	ra,0x0
 2cc:	63e080e7          	jalr	1598(ra) # 906 <fprintf>
        close(fd);
 2d0:	854a                	mv	a0,s2
 2d2:	00000097          	auipc	ra,0x0
 2d6:	312080e7          	jalr	786(ra) # 5e4 <close>
        exit(1);
 2da:	4505                	li	a0,1
 2dc:	00000097          	auipc	ra,0x0
 2e0:	2e0080e7          	jalr	736(ra) # 5bc <exit>
        fprintf(2, "find: cannot open %s\n", dir);
 2e4:	ee040613          	addi	a2,s0,-288
 2e8:	00000597          	auipc	a1,0x0
 2ec:	7f058593          	addi	a1,a1,2032 # ad8 <malloc+0xe6>
 2f0:	4509                	li	a0,2
 2f2:	00000097          	auipc	ra,0x0
 2f6:	614080e7          	jalr	1556(ra) # 906 <fprintf>
        exit(1);
 2fa:	4505                	li	a0,1
 2fc:	00000097          	auipc	ra,0x0
 300:	2c0080e7          	jalr	704(ra) # 5bc <exit>
        fprintf(2, "find: cannot fstat %s\n", dir);
 304:	ee040613          	addi	a2,s0,-288
 308:	00000597          	auipc	a1,0x0
 30c:	7e858593          	addi	a1,a1,2024 # af0 <malloc+0xfe>
 310:	4509                	li	a0,2
 312:	00000097          	auipc	ra,0x0
 316:	5f4080e7          	jalr	1524(ra) # 906 <fprintf>
        close(fd);
 31a:	854a                	mv	a0,s2
 31c:	00000097          	auipc	ra,0x0
 320:	2c8080e7          	jalr	712(ra) # 5e4 <close>
        exit(1);
 324:	4505                	li	a0,1
 326:	00000097          	auipc	ra,0x0
 32a:	296080e7          	jalr	662(ra) # 5bc <exit>
    }
    find(dir, argv[2]);
 32e:	688c                	ld	a1,16(s1)
 330:	ee040513          	addi	a0,s0,-288
 334:	00000097          	auipc	ra,0x0
 338:	ccc080e7          	jalr	-820(ra) # 0 <find>
    exit(0);
 33c:	4501                	li	a0,0
 33e:	00000097          	auipc	ra,0x0
 342:	27e080e7          	jalr	638(ra) # 5bc <exit>

0000000000000346 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 346:	1141                	addi	sp,sp,-16
 348:	e422                	sd	s0,8(sp)
 34a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 34c:	87aa                	mv	a5,a0
 34e:	0585                	addi	a1,a1,1
 350:	0785                	addi	a5,a5,1
 352:	fff5c703          	lbu	a4,-1(a1)
 356:	fee78fa3          	sb	a4,-1(a5)
 35a:	fb75                	bnez	a4,34e <strcpy+0x8>
    ;
  return os;
}
 35c:	6422                	ld	s0,8(sp)
 35e:	0141                	addi	sp,sp,16
 360:	8082                	ret

0000000000000362 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 362:	1141                	addi	sp,sp,-16
 364:	e422                	sd	s0,8(sp)
 366:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 368:	00054783          	lbu	a5,0(a0)
 36c:	cb91                	beqz	a5,380 <strcmp+0x1e>
 36e:	0005c703          	lbu	a4,0(a1)
 372:	00f71763          	bne	a4,a5,380 <strcmp+0x1e>
    p++, q++;
 376:	0505                	addi	a0,a0,1
 378:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 37a:	00054783          	lbu	a5,0(a0)
 37e:	fbe5                	bnez	a5,36e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 380:	0005c503          	lbu	a0,0(a1)
}
 384:	40a7853b          	subw	a0,a5,a0
 388:	6422                	ld	s0,8(sp)
 38a:	0141                	addi	sp,sp,16
 38c:	8082                	ret

000000000000038e <strlen>:

uint
strlen(const char *s)
{
 38e:	1141                	addi	sp,sp,-16
 390:	e422                	sd	s0,8(sp)
 392:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 394:	00054783          	lbu	a5,0(a0)
 398:	cf91                	beqz	a5,3b4 <strlen+0x26>
 39a:	0505                	addi	a0,a0,1
 39c:	87aa                	mv	a5,a0
 39e:	4685                	li	a3,1
 3a0:	9e89                	subw	a3,a3,a0
 3a2:	00f6853b          	addw	a0,a3,a5
 3a6:	0785                	addi	a5,a5,1
 3a8:	fff7c703          	lbu	a4,-1(a5)
 3ac:	fb7d                	bnez	a4,3a2 <strlen+0x14>
    ;
  return n;
}
 3ae:	6422                	ld	s0,8(sp)
 3b0:	0141                	addi	sp,sp,16
 3b2:	8082                	ret
  for(n = 0; s[n]; n++)
 3b4:	4501                	li	a0,0
 3b6:	bfe5                	j	3ae <strlen+0x20>

00000000000003b8 <memset>:

void*
memset(void *dst, int c, uint n)
{
 3b8:	1141                	addi	sp,sp,-16
 3ba:	e422                	sd	s0,8(sp)
 3bc:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 3be:	ce09                	beqz	a2,3d8 <memset+0x20>
 3c0:	87aa                	mv	a5,a0
 3c2:	fff6071b          	addiw	a4,a2,-1
 3c6:	1702                	slli	a4,a4,0x20
 3c8:	9301                	srli	a4,a4,0x20
 3ca:	0705                	addi	a4,a4,1
 3cc:	972a                	add	a4,a4,a0
    cdst[i] = c;
 3ce:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 3d2:	0785                	addi	a5,a5,1
 3d4:	fee79de3          	bne	a5,a4,3ce <memset+0x16>
  }
  return dst;
}
 3d8:	6422                	ld	s0,8(sp)
 3da:	0141                	addi	sp,sp,16
 3dc:	8082                	ret

00000000000003de <strchr>:

char*
strchr(const char *s, char c)
{
 3de:	1141                	addi	sp,sp,-16
 3e0:	e422                	sd	s0,8(sp)
 3e2:	0800                	addi	s0,sp,16
  for(; *s; s++)
 3e4:	00054783          	lbu	a5,0(a0)
 3e8:	cb99                	beqz	a5,3fe <strchr+0x20>
    if(*s == c)
 3ea:	00f58763          	beq	a1,a5,3f8 <strchr+0x1a>
  for(; *s; s++)
 3ee:	0505                	addi	a0,a0,1
 3f0:	00054783          	lbu	a5,0(a0)
 3f4:	fbfd                	bnez	a5,3ea <strchr+0xc>
      return (char*)s;
  return 0;
 3f6:	4501                	li	a0,0
}
 3f8:	6422                	ld	s0,8(sp)
 3fa:	0141                	addi	sp,sp,16
 3fc:	8082                	ret
  return 0;
 3fe:	4501                	li	a0,0
 400:	bfe5                	j	3f8 <strchr+0x1a>

0000000000000402 <gets>:

char*
gets(char *buf, int max)
{
 402:	711d                	addi	sp,sp,-96
 404:	ec86                	sd	ra,88(sp)
 406:	e8a2                	sd	s0,80(sp)
 408:	e4a6                	sd	s1,72(sp)
 40a:	e0ca                	sd	s2,64(sp)
 40c:	fc4e                	sd	s3,56(sp)
 40e:	f852                	sd	s4,48(sp)
 410:	f456                	sd	s5,40(sp)
 412:	f05a                	sd	s6,32(sp)
 414:	ec5e                	sd	s7,24(sp)
 416:	1080                	addi	s0,sp,96
 418:	8baa                	mv	s7,a0
 41a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 41c:	892a                	mv	s2,a0
 41e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 420:	4aa9                	li	s5,10
 422:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 424:	89a6                	mv	s3,s1
 426:	2485                	addiw	s1,s1,1
 428:	0344d863          	bge	s1,s4,458 <gets+0x56>
    cc = read(0, &c, 1);
 42c:	4605                	li	a2,1
 42e:	faf40593          	addi	a1,s0,-81
 432:	4501                	li	a0,0
 434:	00000097          	auipc	ra,0x0
 438:	1a0080e7          	jalr	416(ra) # 5d4 <read>
    if(cc < 1)
 43c:	00a05e63          	blez	a0,458 <gets+0x56>
    buf[i++] = c;
 440:	faf44783          	lbu	a5,-81(s0)
 444:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 448:	01578763          	beq	a5,s5,456 <gets+0x54>
 44c:	0905                	addi	s2,s2,1
 44e:	fd679be3          	bne	a5,s6,424 <gets+0x22>
  for(i=0; i+1 < max; ){
 452:	89a6                	mv	s3,s1
 454:	a011                	j	458 <gets+0x56>
 456:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 458:	99de                	add	s3,s3,s7
 45a:	00098023          	sb	zero,0(s3)
  return buf;
}
 45e:	855e                	mv	a0,s7
 460:	60e6                	ld	ra,88(sp)
 462:	6446                	ld	s0,80(sp)
 464:	64a6                	ld	s1,72(sp)
 466:	6906                	ld	s2,64(sp)
 468:	79e2                	ld	s3,56(sp)
 46a:	7a42                	ld	s4,48(sp)
 46c:	7aa2                	ld	s5,40(sp)
 46e:	7b02                	ld	s6,32(sp)
 470:	6be2                	ld	s7,24(sp)
 472:	6125                	addi	sp,sp,96
 474:	8082                	ret

0000000000000476 <stat>:

int
stat(const char *n, struct stat *st)
{
 476:	1101                	addi	sp,sp,-32
 478:	ec06                	sd	ra,24(sp)
 47a:	e822                	sd	s0,16(sp)
 47c:	e426                	sd	s1,8(sp)
 47e:	e04a                	sd	s2,0(sp)
 480:	1000                	addi	s0,sp,32
 482:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 484:	4581                	li	a1,0
 486:	00000097          	auipc	ra,0x0
 48a:	176080e7          	jalr	374(ra) # 5fc <open>
  if(fd < 0)
 48e:	02054563          	bltz	a0,4b8 <stat+0x42>
 492:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 494:	85ca                	mv	a1,s2
 496:	00000097          	auipc	ra,0x0
 49a:	17e080e7          	jalr	382(ra) # 614 <fstat>
 49e:	892a                	mv	s2,a0
  close(fd);
 4a0:	8526                	mv	a0,s1
 4a2:	00000097          	auipc	ra,0x0
 4a6:	142080e7          	jalr	322(ra) # 5e4 <close>
  return r;
}
 4aa:	854a                	mv	a0,s2
 4ac:	60e2                	ld	ra,24(sp)
 4ae:	6442                	ld	s0,16(sp)
 4b0:	64a2                	ld	s1,8(sp)
 4b2:	6902                	ld	s2,0(sp)
 4b4:	6105                	addi	sp,sp,32
 4b6:	8082                	ret
    return -1;
 4b8:	597d                	li	s2,-1
 4ba:	bfc5                	j	4aa <stat+0x34>

00000000000004bc <atoi>:

int
atoi(const char *s)
{
 4bc:	1141                	addi	sp,sp,-16
 4be:	e422                	sd	s0,8(sp)
 4c0:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 4c2:	00054603          	lbu	a2,0(a0)
 4c6:	fd06079b          	addiw	a5,a2,-48
 4ca:	0ff7f793          	andi	a5,a5,255
 4ce:	4725                	li	a4,9
 4d0:	02f76963          	bltu	a4,a5,502 <atoi+0x46>
 4d4:	86aa                	mv	a3,a0
  n = 0;
 4d6:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 4d8:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 4da:	0685                	addi	a3,a3,1
 4dc:	0025179b          	slliw	a5,a0,0x2
 4e0:	9fa9                	addw	a5,a5,a0
 4e2:	0017979b          	slliw	a5,a5,0x1
 4e6:	9fb1                	addw	a5,a5,a2
 4e8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 4ec:	0006c603          	lbu	a2,0(a3)
 4f0:	fd06071b          	addiw	a4,a2,-48
 4f4:	0ff77713          	andi	a4,a4,255
 4f8:	fee5f1e3          	bgeu	a1,a4,4da <atoi+0x1e>
  return n;
}
 4fc:	6422                	ld	s0,8(sp)
 4fe:	0141                	addi	sp,sp,16
 500:	8082                	ret
  n = 0;
 502:	4501                	li	a0,0
 504:	bfe5                	j	4fc <atoi+0x40>

0000000000000506 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 506:	1141                	addi	sp,sp,-16
 508:	e422                	sd	s0,8(sp)
 50a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 50c:	02b57663          	bgeu	a0,a1,538 <memmove+0x32>
    while(n-- > 0)
 510:	02c05163          	blez	a2,532 <memmove+0x2c>
 514:	fff6079b          	addiw	a5,a2,-1
 518:	1782                	slli	a5,a5,0x20
 51a:	9381                	srli	a5,a5,0x20
 51c:	0785                	addi	a5,a5,1
 51e:	97aa                	add	a5,a5,a0
  dst = vdst;
 520:	872a                	mv	a4,a0
      *dst++ = *src++;
 522:	0585                	addi	a1,a1,1
 524:	0705                	addi	a4,a4,1
 526:	fff5c683          	lbu	a3,-1(a1)
 52a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 52e:	fee79ae3          	bne	a5,a4,522 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 532:	6422                	ld	s0,8(sp)
 534:	0141                	addi	sp,sp,16
 536:	8082                	ret
    dst += n;
 538:	00c50733          	add	a4,a0,a2
    src += n;
 53c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 53e:	fec05ae3          	blez	a2,532 <memmove+0x2c>
 542:	fff6079b          	addiw	a5,a2,-1
 546:	1782                	slli	a5,a5,0x20
 548:	9381                	srli	a5,a5,0x20
 54a:	fff7c793          	not	a5,a5
 54e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 550:	15fd                	addi	a1,a1,-1
 552:	177d                	addi	a4,a4,-1
 554:	0005c683          	lbu	a3,0(a1)
 558:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 55c:	fee79ae3          	bne	a5,a4,550 <memmove+0x4a>
 560:	bfc9                	j	532 <memmove+0x2c>

0000000000000562 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 562:	1141                	addi	sp,sp,-16
 564:	e422                	sd	s0,8(sp)
 566:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 568:	ca05                	beqz	a2,598 <memcmp+0x36>
 56a:	fff6069b          	addiw	a3,a2,-1
 56e:	1682                	slli	a3,a3,0x20
 570:	9281                	srli	a3,a3,0x20
 572:	0685                	addi	a3,a3,1
 574:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 576:	00054783          	lbu	a5,0(a0)
 57a:	0005c703          	lbu	a4,0(a1)
 57e:	00e79863          	bne	a5,a4,58e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 582:	0505                	addi	a0,a0,1
    p2++;
 584:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 586:	fed518e3          	bne	a0,a3,576 <memcmp+0x14>
  }
  return 0;
 58a:	4501                	li	a0,0
 58c:	a019                	j	592 <memcmp+0x30>
      return *p1 - *p2;
 58e:	40e7853b          	subw	a0,a5,a4
}
 592:	6422                	ld	s0,8(sp)
 594:	0141                	addi	sp,sp,16
 596:	8082                	ret
  return 0;
 598:	4501                	li	a0,0
 59a:	bfe5                	j	592 <memcmp+0x30>

000000000000059c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 59c:	1141                	addi	sp,sp,-16
 59e:	e406                	sd	ra,8(sp)
 5a0:	e022                	sd	s0,0(sp)
 5a2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 5a4:	00000097          	auipc	ra,0x0
 5a8:	f62080e7          	jalr	-158(ra) # 506 <memmove>
}
 5ac:	60a2                	ld	ra,8(sp)
 5ae:	6402                	ld	s0,0(sp)
 5b0:	0141                	addi	sp,sp,16
 5b2:	8082                	ret

00000000000005b4 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 5b4:	4885                	li	a7,1
 ecall
 5b6:	00000073          	ecall
 ret
 5ba:	8082                	ret

00000000000005bc <exit>:
.global exit
exit:
 li a7, SYS_exit
 5bc:	4889                	li	a7,2
 ecall
 5be:	00000073          	ecall
 ret
 5c2:	8082                	ret

00000000000005c4 <wait>:
.global wait
wait:
 li a7, SYS_wait
 5c4:	488d                	li	a7,3
 ecall
 5c6:	00000073          	ecall
 ret
 5ca:	8082                	ret

00000000000005cc <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 5cc:	4891                	li	a7,4
 ecall
 5ce:	00000073          	ecall
 ret
 5d2:	8082                	ret

00000000000005d4 <read>:
.global read
read:
 li a7, SYS_read
 5d4:	4895                	li	a7,5
 ecall
 5d6:	00000073          	ecall
 ret
 5da:	8082                	ret

00000000000005dc <write>:
.global write
write:
 li a7, SYS_write
 5dc:	48c1                	li	a7,16
 ecall
 5de:	00000073          	ecall
 ret
 5e2:	8082                	ret

00000000000005e4 <close>:
.global close
close:
 li a7, SYS_close
 5e4:	48d5                	li	a7,21
 ecall
 5e6:	00000073          	ecall
 ret
 5ea:	8082                	ret

00000000000005ec <kill>:
.global kill
kill:
 li a7, SYS_kill
 5ec:	4899                	li	a7,6
 ecall
 5ee:	00000073          	ecall
 ret
 5f2:	8082                	ret

00000000000005f4 <exec>:
.global exec
exec:
 li a7, SYS_exec
 5f4:	489d                	li	a7,7
 ecall
 5f6:	00000073          	ecall
 ret
 5fa:	8082                	ret

00000000000005fc <open>:
.global open
open:
 li a7, SYS_open
 5fc:	48bd                	li	a7,15
 ecall
 5fe:	00000073          	ecall
 ret
 602:	8082                	ret

0000000000000604 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 604:	48c5                	li	a7,17
 ecall
 606:	00000073          	ecall
 ret
 60a:	8082                	ret

000000000000060c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 60c:	48c9                	li	a7,18
 ecall
 60e:	00000073          	ecall
 ret
 612:	8082                	ret

0000000000000614 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 614:	48a1                	li	a7,8
 ecall
 616:	00000073          	ecall
 ret
 61a:	8082                	ret

000000000000061c <link>:
.global link
link:
 li a7, SYS_link
 61c:	48cd                	li	a7,19
 ecall
 61e:	00000073          	ecall
 ret
 622:	8082                	ret

0000000000000624 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 624:	48d1                	li	a7,20
 ecall
 626:	00000073          	ecall
 ret
 62a:	8082                	ret

000000000000062c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 62c:	48a5                	li	a7,9
 ecall
 62e:	00000073          	ecall
 ret
 632:	8082                	ret

0000000000000634 <dup>:
.global dup
dup:
 li a7, SYS_dup
 634:	48a9                	li	a7,10
 ecall
 636:	00000073          	ecall
 ret
 63a:	8082                	ret

000000000000063c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 63c:	48ad                	li	a7,11
 ecall
 63e:	00000073          	ecall
 ret
 642:	8082                	ret

0000000000000644 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 644:	48b1                	li	a7,12
 ecall
 646:	00000073          	ecall
 ret
 64a:	8082                	ret

000000000000064c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 64c:	48b5                	li	a7,13
 ecall
 64e:	00000073          	ecall
 ret
 652:	8082                	ret

0000000000000654 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 654:	48b9                	li	a7,14
 ecall
 656:	00000073          	ecall
 ret
 65a:	8082                	ret

000000000000065c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 65c:	1101                	addi	sp,sp,-32
 65e:	ec06                	sd	ra,24(sp)
 660:	e822                	sd	s0,16(sp)
 662:	1000                	addi	s0,sp,32
 664:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 668:	4605                	li	a2,1
 66a:	fef40593          	addi	a1,s0,-17
 66e:	00000097          	auipc	ra,0x0
 672:	f6e080e7          	jalr	-146(ra) # 5dc <write>
}
 676:	60e2                	ld	ra,24(sp)
 678:	6442                	ld	s0,16(sp)
 67a:	6105                	addi	sp,sp,32
 67c:	8082                	ret

000000000000067e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 67e:	7139                	addi	sp,sp,-64
 680:	fc06                	sd	ra,56(sp)
 682:	f822                	sd	s0,48(sp)
 684:	f426                	sd	s1,40(sp)
 686:	f04a                	sd	s2,32(sp)
 688:	ec4e                	sd	s3,24(sp)
 68a:	0080                	addi	s0,sp,64
 68c:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 68e:	c299                	beqz	a3,694 <printint+0x16>
 690:	0805c863          	bltz	a1,720 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 694:	2581                	sext.w	a1,a1
  neg = 0;
 696:	4881                	li	a7,0
 698:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 69c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 69e:	2601                	sext.w	a2,a2
 6a0:	00000517          	auipc	a0,0x0
 6a4:	4e050513          	addi	a0,a0,1248 # b80 <digits>
 6a8:	883a                	mv	a6,a4
 6aa:	2705                	addiw	a4,a4,1
 6ac:	02c5f7bb          	remuw	a5,a1,a2
 6b0:	1782                	slli	a5,a5,0x20
 6b2:	9381                	srli	a5,a5,0x20
 6b4:	97aa                	add	a5,a5,a0
 6b6:	0007c783          	lbu	a5,0(a5)
 6ba:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 6be:	0005879b          	sext.w	a5,a1
 6c2:	02c5d5bb          	divuw	a1,a1,a2
 6c6:	0685                	addi	a3,a3,1
 6c8:	fec7f0e3          	bgeu	a5,a2,6a8 <printint+0x2a>
  if(neg)
 6cc:	00088b63          	beqz	a7,6e2 <printint+0x64>
    buf[i++] = '-';
 6d0:	fd040793          	addi	a5,s0,-48
 6d4:	973e                	add	a4,a4,a5
 6d6:	02d00793          	li	a5,45
 6da:	fef70823          	sb	a5,-16(a4)
 6de:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 6e2:	02e05863          	blez	a4,712 <printint+0x94>
 6e6:	fc040793          	addi	a5,s0,-64
 6ea:	00e78933          	add	s2,a5,a4
 6ee:	fff78993          	addi	s3,a5,-1
 6f2:	99ba                	add	s3,s3,a4
 6f4:	377d                	addiw	a4,a4,-1
 6f6:	1702                	slli	a4,a4,0x20
 6f8:	9301                	srli	a4,a4,0x20
 6fa:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 6fe:	fff94583          	lbu	a1,-1(s2)
 702:	8526                	mv	a0,s1
 704:	00000097          	auipc	ra,0x0
 708:	f58080e7          	jalr	-168(ra) # 65c <putc>
  while(--i >= 0)
 70c:	197d                	addi	s2,s2,-1
 70e:	ff3918e3          	bne	s2,s3,6fe <printint+0x80>
}
 712:	70e2                	ld	ra,56(sp)
 714:	7442                	ld	s0,48(sp)
 716:	74a2                	ld	s1,40(sp)
 718:	7902                	ld	s2,32(sp)
 71a:	69e2                	ld	s3,24(sp)
 71c:	6121                	addi	sp,sp,64
 71e:	8082                	ret
    x = -xx;
 720:	40b005bb          	negw	a1,a1
    neg = 1;
 724:	4885                	li	a7,1
    x = -xx;
 726:	bf8d                	j	698 <printint+0x1a>

0000000000000728 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 728:	7119                	addi	sp,sp,-128
 72a:	fc86                	sd	ra,120(sp)
 72c:	f8a2                	sd	s0,112(sp)
 72e:	f4a6                	sd	s1,104(sp)
 730:	f0ca                	sd	s2,96(sp)
 732:	ecce                	sd	s3,88(sp)
 734:	e8d2                	sd	s4,80(sp)
 736:	e4d6                	sd	s5,72(sp)
 738:	e0da                	sd	s6,64(sp)
 73a:	fc5e                	sd	s7,56(sp)
 73c:	f862                	sd	s8,48(sp)
 73e:	f466                	sd	s9,40(sp)
 740:	f06a                	sd	s10,32(sp)
 742:	ec6e                	sd	s11,24(sp)
 744:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 746:	0005c903          	lbu	s2,0(a1)
 74a:	18090f63          	beqz	s2,8e8 <vprintf+0x1c0>
 74e:	8aaa                	mv	s5,a0
 750:	8b32                	mv	s6,a2
 752:	00158493          	addi	s1,a1,1
  state = 0;
 756:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 758:	02500a13          	li	s4,37
      if(c == 'd'){
 75c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 760:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 764:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 768:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 76c:	00000b97          	auipc	s7,0x0
 770:	414b8b93          	addi	s7,s7,1044 # b80 <digits>
 774:	a839                	j	792 <vprintf+0x6a>
        putc(fd, c);
 776:	85ca                	mv	a1,s2
 778:	8556                	mv	a0,s5
 77a:	00000097          	auipc	ra,0x0
 77e:	ee2080e7          	jalr	-286(ra) # 65c <putc>
 782:	a019                	j	788 <vprintf+0x60>
    } else if(state == '%'){
 784:	01498f63          	beq	s3,s4,7a2 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 788:	0485                	addi	s1,s1,1
 78a:	fff4c903          	lbu	s2,-1(s1)
 78e:	14090d63          	beqz	s2,8e8 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 792:	0009079b          	sext.w	a5,s2
    if(state == 0){
 796:	fe0997e3          	bnez	s3,784 <vprintf+0x5c>
      if(c == '%'){
 79a:	fd479ee3          	bne	a5,s4,776 <vprintf+0x4e>
        state = '%';
 79e:	89be                	mv	s3,a5
 7a0:	b7e5                	j	788 <vprintf+0x60>
      if(c == 'd'){
 7a2:	05878063          	beq	a5,s8,7e2 <vprintf+0xba>
      } else if(c == 'l') {
 7a6:	05978c63          	beq	a5,s9,7fe <vprintf+0xd6>
      } else if(c == 'x') {
 7aa:	07a78863          	beq	a5,s10,81a <vprintf+0xf2>
      } else if(c == 'p') {
 7ae:	09b78463          	beq	a5,s11,836 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 7b2:	07300713          	li	a4,115
 7b6:	0ce78663          	beq	a5,a4,882 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 7ba:	06300713          	li	a4,99
 7be:	0ee78e63          	beq	a5,a4,8ba <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 7c2:	11478863          	beq	a5,s4,8d2 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7c6:	85d2                	mv	a1,s4
 7c8:	8556                	mv	a0,s5
 7ca:	00000097          	auipc	ra,0x0
 7ce:	e92080e7          	jalr	-366(ra) # 65c <putc>
        putc(fd, c);
 7d2:	85ca                	mv	a1,s2
 7d4:	8556                	mv	a0,s5
 7d6:	00000097          	auipc	ra,0x0
 7da:	e86080e7          	jalr	-378(ra) # 65c <putc>
      }
      state = 0;
 7de:	4981                	li	s3,0
 7e0:	b765                	j	788 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 7e2:	008b0913          	addi	s2,s6,8
 7e6:	4685                	li	a3,1
 7e8:	4629                	li	a2,10
 7ea:	000b2583          	lw	a1,0(s6)
 7ee:	8556                	mv	a0,s5
 7f0:	00000097          	auipc	ra,0x0
 7f4:	e8e080e7          	jalr	-370(ra) # 67e <printint>
 7f8:	8b4a                	mv	s6,s2
      state = 0;
 7fa:	4981                	li	s3,0
 7fc:	b771                	j	788 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7fe:	008b0913          	addi	s2,s6,8
 802:	4681                	li	a3,0
 804:	4629                	li	a2,10
 806:	000b2583          	lw	a1,0(s6)
 80a:	8556                	mv	a0,s5
 80c:	00000097          	auipc	ra,0x0
 810:	e72080e7          	jalr	-398(ra) # 67e <printint>
 814:	8b4a                	mv	s6,s2
      state = 0;
 816:	4981                	li	s3,0
 818:	bf85                	j	788 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 81a:	008b0913          	addi	s2,s6,8
 81e:	4681                	li	a3,0
 820:	4641                	li	a2,16
 822:	000b2583          	lw	a1,0(s6)
 826:	8556                	mv	a0,s5
 828:	00000097          	auipc	ra,0x0
 82c:	e56080e7          	jalr	-426(ra) # 67e <printint>
 830:	8b4a                	mv	s6,s2
      state = 0;
 832:	4981                	li	s3,0
 834:	bf91                	j	788 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 836:	008b0793          	addi	a5,s6,8
 83a:	f8f43423          	sd	a5,-120(s0)
 83e:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 842:	03000593          	li	a1,48
 846:	8556                	mv	a0,s5
 848:	00000097          	auipc	ra,0x0
 84c:	e14080e7          	jalr	-492(ra) # 65c <putc>
  putc(fd, 'x');
 850:	85ea                	mv	a1,s10
 852:	8556                	mv	a0,s5
 854:	00000097          	auipc	ra,0x0
 858:	e08080e7          	jalr	-504(ra) # 65c <putc>
 85c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 85e:	03c9d793          	srli	a5,s3,0x3c
 862:	97de                	add	a5,a5,s7
 864:	0007c583          	lbu	a1,0(a5)
 868:	8556                	mv	a0,s5
 86a:	00000097          	auipc	ra,0x0
 86e:	df2080e7          	jalr	-526(ra) # 65c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 872:	0992                	slli	s3,s3,0x4
 874:	397d                	addiw	s2,s2,-1
 876:	fe0914e3          	bnez	s2,85e <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 87a:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 87e:	4981                	li	s3,0
 880:	b721                	j	788 <vprintf+0x60>
        s = va_arg(ap, char*);
 882:	008b0993          	addi	s3,s6,8
 886:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 88a:	02090163          	beqz	s2,8ac <vprintf+0x184>
        while(*s != 0){
 88e:	00094583          	lbu	a1,0(s2)
 892:	c9a1                	beqz	a1,8e2 <vprintf+0x1ba>
          putc(fd, *s);
 894:	8556                	mv	a0,s5
 896:	00000097          	auipc	ra,0x0
 89a:	dc6080e7          	jalr	-570(ra) # 65c <putc>
          s++;
 89e:	0905                	addi	s2,s2,1
        while(*s != 0){
 8a0:	00094583          	lbu	a1,0(s2)
 8a4:	f9e5                	bnez	a1,894 <vprintf+0x16c>
        s = va_arg(ap, char*);
 8a6:	8b4e                	mv	s6,s3
      state = 0;
 8a8:	4981                	li	s3,0
 8aa:	bdf9                	j	788 <vprintf+0x60>
          s = "(null)";
 8ac:	00000917          	auipc	s2,0x0
 8b0:	2cc90913          	addi	s2,s2,716 # b78 <malloc+0x186>
        while(*s != 0){
 8b4:	02800593          	li	a1,40
 8b8:	bff1                	j	894 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 8ba:	008b0913          	addi	s2,s6,8
 8be:	000b4583          	lbu	a1,0(s6)
 8c2:	8556                	mv	a0,s5
 8c4:	00000097          	auipc	ra,0x0
 8c8:	d98080e7          	jalr	-616(ra) # 65c <putc>
 8cc:	8b4a                	mv	s6,s2
      state = 0;
 8ce:	4981                	li	s3,0
 8d0:	bd65                	j	788 <vprintf+0x60>
        putc(fd, c);
 8d2:	85d2                	mv	a1,s4
 8d4:	8556                	mv	a0,s5
 8d6:	00000097          	auipc	ra,0x0
 8da:	d86080e7          	jalr	-634(ra) # 65c <putc>
      state = 0;
 8de:	4981                	li	s3,0
 8e0:	b565                	j	788 <vprintf+0x60>
        s = va_arg(ap, char*);
 8e2:	8b4e                	mv	s6,s3
      state = 0;
 8e4:	4981                	li	s3,0
 8e6:	b54d                	j	788 <vprintf+0x60>
    }
  }
}
 8e8:	70e6                	ld	ra,120(sp)
 8ea:	7446                	ld	s0,112(sp)
 8ec:	74a6                	ld	s1,104(sp)
 8ee:	7906                	ld	s2,96(sp)
 8f0:	69e6                	ld	s3,88(sp)
 8f2:	6a46                	ld	s4,80(sp)
 8f4:	6aa6                	ld	s5,72(sp)
 8f6:	6b06                	ld	s6,64(sp)
 8f8:	7be2                	ld	s7,56(sp)
 8fa:	7c42                	ld	s8,48(sp)
 8fc:	7ca2                	ld	s9,40(sp)
 8fe:	7d02                	ld	s10,32(sp)
 900:	6de2                	ld	s11,24(sp)
 902:	6109                	addi	sp,sp,128
 904:	8082                	ret

0000000000000906 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 906:	715d                	addi	sp,sp,-80
 908:	ec06                	sd	ra,24(sp)
 90a:	e822                	sd	s0,16(sp)
 90c:	1000                	addi	s0,sp,32
 90e:	e010                	sd	a2,0(s0)
 910:	e414                	sd	a3,8(s0)
 912:	e818                	sd	a4,16(s0)
 914:	ec1c                	sd	a5,24(s0)
 916:	03043023          	sd	a6,32(s0)
 91a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 91e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 922:	8622                	mv	a2,s0
 924:	00000097          	auipc	ra,0x0
 928:	e04080e7          	jalr	-508(ra) # 728 <vprintf>
}
 92c:	60e2                	ld	ra,24(sp)
 92e:	6442                	ld	s0,16(sp)
 930:	6161                	addi	sp,sp,80
 932:	8082                	ret

0000000000000934 <printf>:

void
printf(const char *fmt, ...)
{
 934:	711d                	addi	sp,sp,-96
 936:	ec06                	sd	ra,24(sp)
 938:	e822                	sd	s0,16(sp)
 93a:	1000                	addi	s0,sp,32
 93c:	e40c                	sd	a1,8(s0)
 93e:	e810                	sd	a2,16(s0)
 940:	ec14                	sd	a3,24(s0)
 942:	f018                	sd	a4,32(s0)
 944:	f41c                	sd	a5,40(s0)
 946:	03043823          	sd	a6,48(s0)
 94a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 94e:	00840613          	addi	a2,s0,8
 952:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 956:	85aa                	mv	a1,a0
 958:	4505                	li	a0,1
 95a:	00000097          	auipc	ra,0x0
 95e:	dce080e7          	jalr	-562(ra) # 728 <vprintf>
}
 962:	60e2                	ld	ra,24(sp)
 964:	6442                	ld	s0,16(sp)
 966:	6125                	addi	sp,sp,96
 968:	8082                	ret

000000000000096a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 96a:	1141                	addi	sp,sp,-16
 96c:	e422                	sd	s0,8(sp)
 96e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 970:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 974:	00000797          	auipc	a5,0x0
 978:	2247b783          	ld	a5,548(a5) # b98 <freep>
 97c:	a805                	j	9ac <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 97e:	4618                	lw	a4,8(a2)
 980:	9db9                	addw	a1,a1,a4
 982:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 986:	6398                	ld	a4,0(a5)
 988:	6318                	ld	a4,0(a4)
 98a:	fee53823          	sd	a4,-16(a0)
 98e:	a091                	j	9d2 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 990:	ff852703          	lw	a4,-8(a0)
 994:	9e39                	addw	a2,a2,a4
 996:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 998:	ff053703          	ld	a4,-16(a0)
 99c:	e398                	sd	a4,0(a5)
 99e:	a099                	j	9e4 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9a0:	6398                	ld	a4,0(a5)
 9a2:	00e7e463          	bltu	a5,a4,9aa <free+0x40>
 9a6:	00e6ea63          	bltu	a3,a4,9ba <free+0x50>
{
 9aa:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9ac:	fed7fae3          	bgeu	a5,a3,9a0 <free+0x36>
 9b0:	6398                	ld	a4,0(a5)
 9b2:	00e6e463          	bltu	a3,a4,9ba <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9b6:	fee7eae3          	bltu	a5,a4,9aa <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 9ba:	ff852583          	lw	a1,-8(a0)
 9be:	6390                	ld	a2,0(a5)
 9c0:	02059713          	slli	a4,a1,0x20
 9c4:	9301                	srli	a4,a4,0x20
 9c6:	0712                	slli	a4,a4,0x4
 9c8:	9736                	add	a4,a4,a3
 9ca:	fae60ae3          	beq	a2,a4,97e <free+0x14>
    bp->s.ptr = p->s.ptr;
 9ce:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 9d2:	4790                	lw	a2,8(a5)
 9d4:	02061713          	slli	a4,a2,0x20
 9d8:	9301                	srli	a4,a4,0x20
 9da:	0712                	slli	a4,a4,0x4
 9dc:	973e                	add	a4,a4,a5
 9de:	fae689e3          	beq	a3,a4,990 <free+0x26>
  } else
    p->s.ptr = bp;
 9e2:	e394                	sd	a3,0(a5)
  freep = p;
 9e4:	00000717          	auipc	a4,0x0
 9e8:	1af73a23          	sd	a5,436(a4) # b98 <freep>
}
 9ec:	6422                	ld	s0,8(sp)
 9ee:	0141                	addi	sp,sp,16
 9f0:	8082                	ret

00000000000009f2 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9f2:	7139                	addi	sp,sp,-64
 9f4:	fc06                	sd	ra,56(sp)
 9f6:	f822                	sd	s0,48(sp)
 9f8:	f426                	sd	s1,40(sp)
 9fa:	f04a                	sd	s2,32(sp)
 9fc:	ec4e                	sd	s3,24(sp)
 9fe:	e852                	sd	s4,16(sp)
 a00:	e456                	sd	s5,8(sp)
 a02:	e05a                	sd	s6,0(sp)
 a04:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a06:	02051493          	slli	s1,a0,0x20
 a0a:	9081                	srli	s1,s1,0x20
 a0c:	04bd                	addi	s1,s1,15
 a0e:	8091                	srli	s1,s1,0x4
 a10:	0014899b          	addiw	s3,s1,1
 a14:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 a16:	00000517          	auipc	a0,0x0
 a1a:	18253503          	ld	a0,386(a0) # b98 <freep>
 a1e:	c515                	beqz	a0,a4a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a20:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a22:	4798                	lw	a4,8(a5)
 a24:	02977f63          	bgeu	a4,s1,a62 <malloc+0x70>
 a28:	8a4e                	mv	s4,s3
 a2a:	0009871b          	sext.w	a4,s3
 a2e:	6685                	lui	a3,0x1
 a30:	00d77363          	bgeu	a4,a3,a36 <malloc+0x44>
 a34:	6a05                	lui	s4,0x1
 a36:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a3a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a3e:	00000917          	auipc	s2,0x0
 a42:	15a90913          	addi	s2,s2,346 # b98 <freep>
  if(p == (char*)-1)
 a46:	5afd                	li	s5,-1
 a48:	a88d                	j	aba <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 a4a:	00000797          	auipc	a5,0x0
 a4e:	15678793          	addi	a5,a5,342 # ba0 <base>
 a52:	00000717          	auipc	a4,0x0
 a56:	14f73323          	sd	a5,326(a4) # b98 <freep>
 a5a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a5c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a60:	b7e1                	j	a28 <malloc+0x36>
      if(p->s.size == nunits)
 a62:	02e48b63          	beq	s1,a4,a98 <malloc+0xa6>
        p->s.size -= nunits;
 a66:	4137073b          	subw	a4,a4,s3
 a6a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a6c:	1702                	slli	a4,a4,0x20
 a6e:	9301                	srli	a4,a4,0x20
 a70:	0712                	slli	a4,a4,0x4
 a72:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a74:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a78:	00000717          	auipc	a4,0x0
 a7c:	12a73023          	sd	a0,288(a4) # b98 <freep>
      return (void*)(p + 1);
 a80:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 a84:	70e2                	ld	ra,56(sp)
 a86:	7442                	ld	s0,48(sp)
 a88:	74a2                	ld	s1,40(sp)
 a8a:	7902                	ld	s2,32(sp)
 a8c:	69e2                	ld	s3,24(sp)
 a8e:	6a42                	ld	s4,16(sp)
 a90:	6aa2                	ld	s5,8(sp)
 a92:	6b02                	ld	s6,0(sp)
 a94:	6121                	addi	sp,sp,64
 a96:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a98:	6398                	ld	a4,0(a5)
 a9a:	e118                	sd	a4,0(a0)
 a9c:	bff1                	j	a78 <malloc+0x86>
  hp->s.size = nu;
 a9e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 aa2:	0541                	addi	a0,a0,16
 aa4:	00000097          	auipc	ra,0x0
 aa8:	ec6080e7          	jalr	-314(ra) # 96a <free>
  return freep;
 aac:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 ab0:	d971                	beqz	a0,a84 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ab2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 ab4:	4798                	lw	a4,8(a5)
 ab6:	fa9776e3          	bgeu	a4,s1,a62 <malloc+0x70>
    if(p == freep)
 aba:	00093703          	ld	a4,0(s2)
 abe:	853e                	mv	a0,a5
 ac0:	fef719e3          	bne	a4,a5,ab2 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 ac4:	8552                	mv	a0,s4
 ac6:	00000097          	auipc	ra,0x0
 aca:	b7e080e7          	jalr	-1154(ra) # 644 <sbrk>
  if(p == (char*)-1)
 ace:	fd5518e3          	bne	a0,s5,a9e <malloc+0xac>
        return 0;
 ad2:	4501                	li	a0,0
 ad4:	bf45                	j	a84 <malloc+0x92>
