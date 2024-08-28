
user/_xargs:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <getline>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/param.h"
#include "user/user.h"

int getline(char *buf) {
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	e052                	sd	s4,0(sp)
   e:	1800                	addi	s0,sp,48
  10:	84aa                	mv	s1,a0
    int cnt = 0;
  12:	4901                	li	s2,0
    while (read(0, buf, 1)) {
        if (++cnt >= 256) {
  14:	10000993          	li	s3,256
            fprintf(2, "xargs: line too long\n");
            exit(1);
        }
        if (*buf++ == '\n')
  18:	4a29                	li	s4,10
    while (read(0, buf, 1)) {
  1a:	4605                	li	a2,1
  1c:	85a6                	mv	a1,s1
  1e:	4501                	li	a0,0
  20:	00000097          	auipc	ra,0x0
  24:	45c080e7          	jalr	1116(ra) # 47c <read>
  28:	c909                	beqz	a0,3a <getline+0x3a>
        if (++cnt >= 256) {
  2a:	2905                	addiw	s2,s2,1
  2c:	03390263          	beq	s2,s3,50 <getline+0x50>
        if (*buf++ == '\n')
  30:	0485                	addi	s1,s1,1
  32:	fff4c783          	lbu	a5,-1(s1)
  36:	ff4792e3          	bne	a5,s4,1a <getline+0x1a>
            break;
    }
    *(buf-1) = 0;
  3a:	fe048fa3          	sb	zero,-1(s1)
    return cnt;
}
  3e:	854a                	mv	a0,s2
  40:	70a2                	ld	ra,40(sp)
  42:	7402                	ld	s0,32(sp)
  44:	64e2                	ld	s1,24(sp)
  46:	6942                	ld	s2,16(sp)
  48:	69a2                	ld	s3,8(sp)
  4a:	6a02                	ld	s4,0(sp)
  4c:	6145                	addi	sp,sp,48
  4e:	8082                	ret
            fprintf(2, "xargs: line too long\n");
  50:	00001597          	auipc	a1,0x1
  54:	93058593          	addi	a1,a1,-1744 # 980 <malloc+0xe6>
  58:	4509                	li	a0,2
  5a:	00000097          	auipc	ra,0x0
  5e:	754080e7          	jalr	1876(ra) # 7ae <fprintf>
            exit(1);
  62:	4505                	li	a0,1
  64:	00000097          	auipc	ra,0x0
  68:	400080e7          	jalr	1024(ra) # 464 <exit>

000000000000006c <prase>:

int prase(char *buf, char **nargv, const int max) {
    int cnt = 0;
    while (*buf) {
  6c:	00054703          	lbu	a4,0(a0)
  70:	cf31                	beqz	a4,cc <prase+0x60>
  72:	87aa                	mv	a5,a0
    int cnt = 0;
  74:	4501                	li	a0,0
                fprintf(2, "xargs: args too many\n");
                exit(1);
            }
            nargv[cnt++] = buf;
        }
        else if (*buf == ' ')
  76:	02000813          	li	a6,32
  7a:	a80d                	j	ac <prase+0x40>
int prase(char *buf, char **nargv, const int max) {
  7c:	1141                	addi	sp,sp,-16
  7e:	e406                	sd	ra,8(sp)
  80:	e022                	sd	s0,0(sp)
  82:	0800                	addi	s0,sp,16
                fprintf(2, "xargs: args too many\n");
  84:	00001597          	auipc	a1,0x1
  88:	91458593          	addi	a1,a1,-1772 # 998 <malloc+0xfe>
  8c:	4509                	li	a0,2
  8e:	00000097          	auipc	ra,0x0
  92:	720080e7          	jalr	1824(ra) # 7ae <fprintf>
                exit(1);
  96:	4505                	li	a0,1
  98:	00000097          	auipc	ra,0x0
  9c:	3cc080e7          	jalr	972(ra) # 464 <exit>
        else if (*buf == ' ')
  a0:	03070363          	beq	a4,a6,c6 <prase+0x5a>
            *buf = 0;
        buf++;
  a4:	0785                	addi	a5,a5,1
    while (*buf) {
  a6:	0007c703          	lbu	a4,0(a5)
  aa:	c315                	beqz	a4,ce <prase+0x62>
        if (*last == 0 && *buf != ' ') {
  ac:	fff7c683          	lbu	a3,-1(a5)
  b0:	fae5                	bnez	a3,a0 <prase+0x34>
  b2:	01070a63          	beq	a4,a6,c6 <prase+0x5a>
            if (cnt >= max) {
  b6:	fcc553e3          	bge	a0,a2,7c <prase+0x10>
            nargv[cnt++] = buf;
  ba:	00351713          	slli	a4,a0,0x3
  be:	972e                	add	a4,a4,a1
  c0:	e31c                	sd	a5,0(a4)
  c2:	2505                	addiw	a0,a0,1
  c4:	b7c5                	j	a4 <prase+0x38>
            *buf = 0;
  c6:	00078023          	sb	zero,0(a5)
  ca:	bfe9                	j	a4 <prase+0x38>
    int cnt = 0;
  cc:	4501                	li	a0,0
    }
    nargv[cnt] = 0;
  ce:	00351793          	slli	a5,a0,0x3
  d2:	95be                	add	a1,a1,a5
  d4:	0005b023          	sd	zero,0(a1)
    return cnt;
}
  d8:	8082                	ret

00000000000000da <main>:

int main(int argc, char const *argv[]) {
  da:	d3010113          	addi	sp,sp,-720
  de:	2c113423          	sd	ra,712(sp)
  e2:	2c813023          	sd	s0,704(sp)
  e6:	2a913c23          	sd	s1,696(sp)
  ea:	2b213823          	sd	s2,688(sp)
  ee:	2b313423          	sd	s3,680(sp)
  f2:	2b413023          	sd	s4,672(sp)
  f6:	29513c23          	sd	s5,664(sp)
  fa:	29613823          	sd	s6,656(sp)
  fe:	0d80                	addi	s0,sp,720
    if (argc == 1) {
 100:	4785                	li	a5,1
 102:	04f50163          	beq	a0,a5,144 <main+0x6a>
 106:	8b2a                	mv	s6,a0
 108:	8aae                	mv	s5,a1
        fprintf(2, "Usage: xargs COMMAND ...\n");
        exit(1);
    }
    char buf[257] = {0};
 10a:	ea043c23          	sd	zero,-328(s0)
 10e:	0f900613          	li	a2,249
 112:	4581                	li	a1,0
 114:	ec040513          	addi	a0,s0,-320
 118:	00000097          	auipc	ra,0x0
 11c:	148080e7          	jalr	328(ra) # 260 <memset>
    while (getline(buf + 1)) {
        char *nargv[MAXARG + 1];
        memcpy(nargv, argv + 1, sizeof(char *) * (argc - 1));
 120:	fffb099b          	addiw	s3,s6,-1
 124:	0039999b          	slliw	s3,s3,0x3
        prase(buf + 1, nargv + argc - 1, MAXARG - argc + 1);
 128:	003b1493          	slli	s1,s6,0x3
 12c:	fc040793          	addi	a5,s0,-64
 130:	94be                	add	s1,s1,a5
 132:	de848493          	addi	s1,s1,-536
        memcpy(nargv, argv + 1, sizeof(char *) * (argc - 1));
 136:	008a8a13          	addi	s4,s5,8
        prase(buf + 1, nargv + argc - 1, MAXARG - argc + 1);
 13a:	02100913          	li	s2,33
 13e:	4169093b          	subw	s2,s2,s6
    while (getline(buf + 1)) {
 142:	a02d                	j	16c <main+0x92>
        fprintf(2, "Usage: xargs COMMAND ...\n");
 144:	00001597          	auipc	a1,0x1
 148:	86c58593          	addi	a1,a1,-1940 # 9b0 <malloc+0x116>
 14c:	4509                	li	a0,2
 14e:	00000097          	auipc	ra,0x0
 152:	660080e7          	jalr	1632(ra) # 7ae <fprintf>
        exit(1);
 156:	4505                	li	a0,1
 158:	00000097          	auipc	ra,0x0
 15c:	30c080e7          	jalr	780(ra) # 464 <exit>
        int pid = fork();
        if (pid > 0) {
            int status;
            wait(&status);
 160:	d3040513          	addi	a0,s0,-720
 164:	00000097          	auipc	ra,0x0
 168:	308080e7          	jalr	776(ra) # 46c <wait>
    while (getline(buf + 1)) {
 16c:	eb940513          	addi	a0,s0,-327
 170:	00000097          	auipc	ra,0x0
 174:	e90080e7          	jalr	-368(ra) # 0 <getline>
 178:	c53d                	beqz	a0,1e6 <main+0x10c>
        memcpy(nargv, argv + 1, sizeof(char *) * (argc - 1));
 17a:	864e                	mv	a2,s3
 17c:	85d2                	mv	a1,s4
 17e:	db040513          	addi	a0,s0,-592
 182:	00000097          	auipc	ra,0x0
 186:	2c2080e7          	jalr	706(ra) # 444 <memcpy>
        prase(buf + 1, nargv + argc - 1, MAXARG - argc + 1);
 18a:	864a                	mv	a2,s2
 18c:	85a6                	mv	a1,s1
 18e:	eb940513          	addi	a0,s0,-327
 192:	00000097          	auipc	ra,0x0
 196:	eda080e7          	jalr	-294(ra) # 6c <prase>
        int pid = fork();
 19a:	00000097          	auipc	ra,0x0
 19e:	2c2080e7          	jalr	706(ra) # 45c <fork>
        if (pid > 0) {
 1a2:	faa04fe3          	bgtz	a0,160 <main+0x86>
        }
        else if (pid == 0) {
 1a6:	e115                	bnez	a0,1ca <main+0xf0>
            char cmd[128];
            strcpy(cmd, argv[1]);
 1a8:	008ab583          	ld	a1,8(s5)
 1ac:	d3040513          	addi	a0,s0,-720
 1b0:	00000097          	auipc	ra,0x0
 1b4:	03e080e7          	jalr	62(ra) # 1ee <strcpy>
            exec(cmd, nargv);
 1b8:	db040593          	addi	a1,s0,-592
 1bc:	d3040513          	addi	a0,s0,-720
 1c0:	00000097          	auipc	ra,0x0
 1c4:	2dc080e7          	jalr	732(ra) # 49c <exec>
 1c8:	b755                	j	16c <main+0x92>
        }
        else {
            fprintf(2, "fork error\n");
 1ca:	00001597          	auipc	a1,0x1
 1ce:	80658593          	addi	a1,a1,-2042 # 9d0 <malloc+0x136>
 1d2:	4509                	li	a0,2
 1d4:	00000097          	auipc	ra,0x0
 1d8:	5da080e7          	jalr	1498(ra) # 7ae <fprintf>
            exit(1);
 1dc:	4505                	li	a0,1
 1de:	00000097          	auipc	ra,0x0
 1e2:	286080e7          	jalr	646(ra) # 464 <exit>
        }
    }
    exit(0);
 1e6:	00000097          	auipc	ra,0x0
 1ea:	27e080e7          	jalr	638(ra) # 464 <exit>

00000000000001ee <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 1ee:	1141                	addi	sp,sp,-16
 1f0:	e422                	sd	s0,8(sp)
 1f2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1f4:	87aa                	mv	a5,a0
 1f6:	0585                	addi	a1,a1,1
 1f8:	0785                	addi	a5,a5,1
 1fa:	fff5c703          	lbu	a4,-1(a1)
 1fe:	fee78fa3          	sb	a4,-1(a5)
 202:	fb75                	bnez	a4,1f6 <strcpy+0x8>
    ;
  return os;
}
 204:	6422                	ld	s0,8(sp)
 206:	0141                	addi	sp,sp,16
 208:	8082                	ret

000000000000020a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 20a:	1141                	addi	sp,sp,-16
 20c:	e422                	sd	s0,8(sp)
 20e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 210:	00054783          	lbu	a5,0(a0)
 214:	cb91                	beqz	a5,228 <strcmp+0x1e>
 216:	0005c703          	lbu	a4,0(a1)
 21a:	00f71763          	bne	a4,a5,228 <strcmp+0x1e>
    p++, q++;
 21e:	0505                	addi	a0,a0,1
 220:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 222:	00054783          	lbu	a5,0(a0)
 226:	fbe5                	bnez	a5,216 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 228:	0005c503          	lbu	a0,0(a1)
}
 22c:	40a7853b          	subw	a0,a5,a0
 230:	6422                	ld	s0,8(sp)
 232:	0141                	addi	sp,sp,16
 234:	8082                	ret

0000000000000236 <strlen>:

uint
strlen(const char *s)
{
 236:	1141                	addi	sp,sp,-16
 238:	e422                	sd	s0,8(sp)
 23a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 23c:	00054783          	lbu	a5,0(a0)
 240:	cf91                	beqz	a5,25c <strlen+0x26>
 242:	0505                	addi	a0,a0,1
 244:	87aa                	mv	a5,a0
 246:	4685                	li	a3,1
 248:	9e89                	subw	a3,a3,a0
 24a:	00f6853b          	addw	a0,a3,a5
 24e:	0785                	addi	a5,a5,1
 250:	fff7c703          	lbu	a4,-1(a5)
 254:	fb7d                	bnez	a4,24a <strlen+0x14>
    ;
  return n;
}
 256:	6422                	ld	s0,8(sp)
 258:	0141                	addi	sp,sp,16
 25a:	8082                	ret
  for(n = 0; s[n]; n++)
 25c:	4501                	li	a0,0
 25e:	bfe5                	j	256 <strlen+0x20>

0000000000000260 <memset>:

void*
memset(void *dst, int c, uint n)
{
 260:	1141                	addi	sp,sp,-16
 262:	e422                	sd	s0,8(sp)
 264:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 266:	ce09                	beqz	a2,280 <memset+0x20>
 268:	87aa                	mv	a5,a0
 26a:	fff6071b          	addiw	a4,a2,-1
 26e:	1702                	slli	a4,a4,0x20
 270:	9301                	srli	a4,a4,0x20
 272:	0705                	addi	a4,a4,1
 274:	972a                	add	a4,a4,a0
    cdst[i] = c;
 276:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 27a:	0785                	addi	a5,a5,1
 27c:	fee79de3          	bne	a5,a4,276 <memset+0x16>
  }
  return dst;
}
 280:	6422                	ld	s0,8(sp)
 282:	0141                	addi	sp,sp,16
 284:	8082                	ret

0000000000000286 <strchr>:

char*
strchr(const char *s, char c)
{
 286:	1141                	addi	sp,sp,-16
 288:	e422                	sd	s0,8(sp)
 28a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 28c:	00054783          	lbu	a5,0(a0)
 290:	cb99                	beqz	a5,2a6 <strchr+0x20>
    if(*s == c)
 292:	00f58763          	beq	a1,a5,2a0 <strchr+0x1a>
  for(; *s; s++)
 296:	0505                	addi	a0,a0,1
 298:	00054783          	lbu	a5,0(a0)
 29c:	fbfd                	bnez	a5,292 <strchr+0xc>
      return (char*)s;
  return 0;
 29e:	4501                	li	a0,0
}
 2a0:	6422                	ld	s0,8(sp)
 2a2:	0141                	addi	sp,sp,16
 2a4:	8082                	ret
  return 0;
 2a6:	4501                	li	a0,0
 2a8:	bfe5                	j	2a0 <strchr+0x1a>

00000000000002aa <gets>:

char*
gets(char *buf, int max)
{
 2aa:	711d                	addi	sp,sp,-96
 2ac:	ec86                	sd	ra,88(sp)
 2ae:	e8a2                	sd	s0,80(sp)
 2b0:	e4a6                	sd	s1,72(sp)
 2b2:	e0ca                	sd	s2,64(sp)
 2b4:	fc4e                	sd	s3,56(sp)
 2b6:	f852                	sd	s4,48(sp)
 2b8:	f456                	sd	s5,40(sp)
 2ba:	f05a                	sd	s6,32(sp)
 2bc:	ec5e                	sd	s7,24(sp)
 2be:	1080                	addi	s0,sp,96
 2c0:	8baa                	mv	s7,a0
 2c2:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2c4:	892a                	mv	s2,a0
 2c6:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2c8:	4aa9                	li	s5,10
 2ca:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2cc:	89a6                	mv	s3,s1
 2ce:	2485                	addiw	s1,s1,1
 2d0:	0344d863          	bge	s1,s4,300 <gets+0x56>
    cc = read(0, &c, 1);
 2d4:	4605                	li	a2,1
 2d6:	faf40593          	addi	a1,s0,-81
 2da:	4501                	li	a0,0
 2dc:	00000097          	auipc	ra,0x0
 2e0:	1a0080e7          	jalr	416(ra) # 47c <read>
    if(cc < 1)
 2e4:	00a05e63          	blez	a0,300 <gets+0x56>
    buf[i++] = c;
 2e8:	faf44783          	lbu	a5,-81(s0)
 2ec:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2f0:	01578763          	beq	a5,s5,2fe <gets+0x54>
 2f4:	0905                	addi	s2,s2,1
 2f6:	fd679be3          	bne	a5,s6,2cc <gets+0x22>
  for(i=0; i+1 < max; ){
 2fa:	89a6                	mv	s3,s1
 2fc:	a011                	j	300 <gets+0x56>
 2fe:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 300:	99de                	add	s3,s3,s7
 302:	00098023          	sb	zero,0(s3)
  return buf;
}
 306:	855e                	mv	a0,s7
 308:	60e6                	ld	ra,88(sp)
 30a:	6446                	ld	s0,80(sp)
 30c:	64a6                	ld	s1,72(sp)
 30e:	6906                	ld	s2,64(sp)
 310:	79e2                	ld	s3,56(sp)
 312:	7a42                	ld	s4,48(sp)
 314:	7aa2                	ld	s5,40(sp)
 316:	7b02                	ld	s6,32(sp)
 318:	6be2                	ld	s7,24(sp)
 31a:	6125                	addi	sp,sp,96
 31c:	8082                	ret

000000000000031e <stat>:

int
stat(const char *n, struct stat *st)
{
 31e:	1101                	addi	sp,sp,-32
 320:	ec06                	sd	ra,24(sp)
 322:	e822                	sd	s0,16(sp)
 324:	e426                	sd	s1,8(sp)
 326:	e04a                	sd	s2,0(sp)
 328:	1000                	addi	s0,sp,32
 32a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 32c:	4581                	li	a1,0
 32e:	00000097          	auipc	ra,0x0
 332:	176080e7          	jalr	374(ra) # 4a4 <open>
  if(fd < 0)
 336:	02054563          	bltz	a0,360 <stat+0x42>
 33a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 33c:	85ca                	mv	a1,s2
 33e:	00000097          	auipc	ra,0x0
 342:	17e080e7          	jalr	382(ra) # 4bc <fstat>
 346:	892a                	mv	s2,a0
  close(fd);
 348:	8526                	mv	a0,s1
 34a:	00000097          	auipc	ra,0x0
 34e:	142080e7          	jalr	322(ra) # 48c <close>
  return r;
}
 352:	854a                	mv	a0,s2
 354:	60e2                	ld	ra,24(sp)
 356:	6442                	ld	s0,16(sp)
 358:	64a2                	ld	s1,8(sp)
 35a:	6902                	ld	s2,0(sp)
 35c:	6105                	addi	sp,sp,32
 35e:	8082                	ret
    return -1;
 360:	597d                	li	s2,-1
 362:	bfc5                	j	352 <stat+0x34>

0000000000000364 <atoi>:

int
atoi(const char *s)
{
 364:	1141                	addi	sp,sp,-16
 366:	e422                	sd	s0,8(sp)
 368:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 36a:	00054603          	lbu	a2,0(a0)
 36e:	fd06079b          	addiw	a5,a2,-48
 372:	0ff7f793          	andi	a5,a5,255
 376:	4725                	li	a4,9
 378:	02f76963          	bltu	a4,a5,3aa <atoi+0x46>
 37c:	86aa                	mv	a3,a0
  n = 0;
 37e:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 380:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 382:	0685                	addi	a3,a3,1
 384:	0025179b          	slliw	a5,a0,0x2
 388:	9fa9                	addw	a5,a5,a0
 38a:	0017979b          	slliw	a5,a5,0x1
 38e:	9fb1                	addw	a5,a5,a2
 390:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 394:	0006c603          	lbu	a2,0(a3)
 398:	fd06071b          	addiw	a4,a2,-48
 39c:	0ff77713          	andi	a4,a4,255
 3a0:	fee5f1e3          	bgeu	a1,a4,382 <atoi+0x1e>
  return n;
}
 3a4:	6422                	ld	s0,8(sp)
 3a6:	0141                	addi	sp,sp,16
 3a8:	8082                	ret
  n = 0;
 3aa:	4501                	li	a0,0
 3ac:	bfe5                	j	3a4 <atoi+0x40>

00000000000003ae <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3ae:	1141                	addi	sp,sp,-16
 3b0:	e422                	sd	s0,8(sp)
 3b2:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3b4:	02b57663          	bgeu	a0,a1,3e0 <memmove+0x32>
    while(n-- > 0)
 3b8:	02c05163          	blez	a2,3da <memmove+0x2c>
 3bc:	fff6079b          	addiw	a5,a2,-1
 3c0:	1782                	slli	a5,a5,0x20
 3c2:	9381                	srli	a5,a5,0x20
 3c4:	0785                	addi	a5,a5,1
 3c6:	97aa                	add	a5,a5,a0
  dst = vdst;
 3c8:	872a                	mv	a4,a0
      *dst++ = *src++;
 3ca:	0585                	addi	a1,a1,1
 3cc:	0705                	addi	a4,a4,1
 3ce:	fff5c683          	lbu	a3,-1(a1)
 3d2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3d6:	fee79ae3          	bne	a5,a4,3ca <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3da:	6422                	ld	s0,8(sp)
 3dc:	0141                	addi	sp,sp,16
 3de:	8082                	ret
    dst += n;
 3e0:	00c50733          	add	a4,a0,a2
    src += n;
 3e4:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3e6:	fec05ae3          	blez	a2,3da <memmove+0x2c>
 3ea:	fff6079b          	addiw	a5,a2,-1
 3ee:	1782                	slli	a5,a5,0x20
 3f0:	9381                	srli	a5,a5,0x20
 3f2:	fff7c793          	not	a5,a5
 3f6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3f8:	15fd                	addi	a1,a1,-1
 3fa:	177d                	addi	a4,a4,-1
 3fc:	0005c683          	lbu	a3,0(a1)
 400:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 404:	fee79ae3          	bne	a5,a4,3f8 <memmove+0x4a>
 408:	bfc9                	j	3da <memmove+0x2c>

000000000000040a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 40a:	1141                	addi	sp,sp,-16
 40c:	e422                	sd	s0,8(sp)
 40e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 410:	ca05                	beqz	a2,440 <memcmp+0x36>
 412:	fff6069b          	addiw	a3,a2,-1
 416:	1682                	slli	a3,a3,0x20
 418:	9281                	srli	a3,a3,0x20
 41a:	0685                	addi	a3,a3,1
 41c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 41e:	00054783          	lbu	a5,0(a0)
 422:	0005c703          	lbu	a4,0(a1)
 426:	00e79863          	bne	a5,a4,436 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 42a:	0505                	addi	a0,a0,1
    p2++;
 42c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 42e:	fed518e3          	bne	a0,a3,41e <memcmp+0x14>
  }
  return 0;
 432:	4501                	li	a0,0
 434:	a019                	j	43a <memcmp+0x30>
      return *p1 - *p2;
 436:	40e7853b          	subw	a0,a5,a4
}
 43a:	6422                	ld	s0,8(sp)
 43c:	0141                	addi	sp,sp,16
 43e:	8082                	ret
  return 0;
 440:	4501                	li	a0,0
 442:	bfe5                	j	43a <memcmp+0x30>

0000000000000444 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 444:	1141                	addi	sp,sp,-16
 446:	e406                	sd	ra,8(sp)
 448:	e022                	sd	s0,0(sp)
 44a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 44c:	00000097          	auipc	ra,0x0
 450:	f62080e7          	jalr	-158(ra) # 3ae <memmove>
}
 454:	60a2                	ld	ra,8(sp)
 456:	6402                	ld	s0,0(sp)
 458:	0141                	addi	sp,sp,16
 45a:	8082                	ret

000000000000045c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 45c:	4885                	li	a7,1
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <exit>:
.global exit
exit:
 li a7, SYS_exit
 464:	4889                	li	a7,2
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <wait>:
.global wait
wait:
 li a7, SYS_wait
 46c:	488d                	li	a7,3
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 474:	4891                	li	a7,4
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <read>:
.global read
read:
 li a7, SYS_read
 47c:	4895                	li	a7,5
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <write>:
.global write
write:
 li a7, SYS_write
 484:	48c1                	li	a7,16
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <close>:
.global close
close:
 li a7, SYS_close
 48c:	48d5                	li	a7,21
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <kill>:
.global kill
kill:
 li a7, SYS_kill
 494:	4899                	li	a7,6
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <exec>:
.global exec
exec:
 li a7, SYS_exec
 49c:	489d                	li	a7,7
 ecall
 49e:	00000073          	ecall
 ret
 4a2:	8082                	ret

00000000000004a4 <open>:
.global open
open:
 li a7, SYS_open
 4a4:	48bd                	li	a7,15
 ecall
 4a6:	00000073          	ecall
 ret
 4aa:	8082                	ret

00000000000004ac <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4ac:	48c5                	li	a7,17
 ecall
 4ae:	00000073          	ecall
 ret
 4b2:	8082                	ret

00000000000004b4 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4b4:	48c9                	li	a7,18
 ecall
 4b6:	00000073          	ecall
 ret
 4ba:	8082                	ret

00000000000004bc <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4bc:	48a1                	li	a7,8
 ecall
 4be:	00000073          	ecall
 ret
 4c2:	8082                	ret

00000000000004c4 <link>:
.global link
link:
 li a7, SYS_link
 4c4:	48cd                	li	a7,19
 ecall
 4c6:	00000073          	ecall
 ret
 4ca:	8082                	ret

00000000000004cc <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4cc:	48d1                	li	a7,20
 ecall
 4ce:	00000073          	ecall
 ret
 4d2:	8082                	ret

00000000000004d4 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4d4:	48a5                	li	a7,9
 ecall
 4d6:	00000073          	ecall
 ret
 4da:	8082                	ret

00000000000004dc <dup>:
.global dup
dup:
 li a7, SYS_dup
 4dc:	48a9                	li	a7,10
 ecall
 4de:	00000073          	ecall
 ret
 4e2:	8082                	ret

00000000000004e4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4e4:	48ad                	li	a7,11
 ecall
 4e6:	00000073          	ecall
 ret
 4ea:	8082                	ret

00000000000004ec <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4ec:	48b1                	li	a7,12
 ecall
 4ee:	00000073          	ecall
 ret
 4f2:	8082                	ret

00000000000004f4 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4f4:	48b5                	li	a7,13
 ecall
 4f6:	00000073          	ecall
 ret
 4fa:	8082                	ret

00000000000004fc <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4fc:	48b9                	li	a7,14
 ecall
 4fe:	00000073          	ecall
 ret
 502:	8082                	ret

0000000000000504 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 504:	1101                	addi	sp,sp,-32
 506:	ec06                	sd	ra,24(sp)
 508:	e822                	sd	s0,16(sp)
 50a:	1000                	addi	s0,sp,32
 50c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 510:	4605                	li	a2,1
 512:	fef40593          	addi	a1,s0,-17
 516:	00000097          	auipc	ra,0x0
 51a:	f6e080e7          	jalr	-146(ra) # 484 <write>
}
 51e:	60e2                	ld	ra,24(sp)
 520:	6442                	ld	s0,16(sp)
 522:	6105                	addi	sp,sp,32
 524:	8082                	ret

0000000000000526 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 526:	7139                	addi	sp,sp,-64
 528:	fc06                	sd	ra,56(sp)
 52a:	f822                	sd	s0,48(sp)
 52c:	f426                	sd	s1,40(sp)
 52e:	f04a                	sd	s2,32(sp)
 530:	ec4e                	sd	s3,24(sp)
 532:	0080                	addi	s0,sp,64
 534:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 536:	c299                	beqz	a3,53c <printint+0x16>
 538:	0805c863          	bltz	a1,5c8 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 53c:	2581                	sext.w	a1,a1
  neg = 0;
 53e:	4881                	li	a7,0
 540:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 544:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 546:	2601                	sext.w	a2,a2
 548:	00000517          	auipc	a0,0x0
 54c:	4a050513          	addi	a0,a0,1184 # 9e8 <digits>
 550:	883a                	mv	a6,a4
 552:	2705                	addiw	a4,a4,1
 554:	02c5f7bb          	remuw	a5,a1,a2
 558:	1782                	slli	a5,a5,0x20
 55a:	9381                	srli	a5,a5,0x20
 55c:	97aa                	add	a5,a5,a0
 55e:	0007c783          	lbu	a5,0(a5)
 562:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 566:	0005879b          	sext.w	a5,a1
 56a:	02c5d5bb          	divuw	a1,a1,a2
 56e:	0685                	addi	a3,a3,1
 570:	fec7f0e3          	bgeu	a5,a2,550 <printint+0x2a>
  if(neg)
 574:	00088b63          	beqz	a7,58a <printint+0x64>
    buf[i++] = '-';
 578:	fd040793          	addi	a5,s0,-48
 57c:	973e                	add	a4,a4,a5
 57e:	02d00793          	li	a5,45
 582:	fef70823          	sb	a5,-16(a4)
 586:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 58a:	02e05863          	blez	a4,5ba <printint+0x94>
 58e:	fc040793          	addi	a5,s0,-64
 592:	00e78933          	add	s2,a5,a4
 596:	fff78993          	addi	s3,a5,-1
 59a:	99ba                	add	s3,s3,a4
 59c:	377d                	addiw	a4,a4,-1
 59e:	1702                	slli	a4,a4,0x20
 5a0:	9301                	srli	a4,a4,0x20
 5a2:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5a6:	fff94583          	lbu	a1,-1(s2)
 5aa:	8526                	mv	a0,s1
 5ac:	00000097          	auipc	ra,0x0
 5b0:	f58080e7          	jalr	-168(ra) # 504 <putc>
  while(--i >= 0)
 5b4:	197d                	addi	s2,s2,-1
 5b6:	ff3918e3          	bne	s2,s3,5a6 <printint+0x80>
}
 5ba:	70e2                	ld	ra,56(sp)
 5bc:	7442                	ld	s0,48(sp)
 5be:	74a2                	ld	s1,40(sp)
 5c0:	7902                	ld	s2,32(sp)
 5c2:	69e2                	ld	s3,24(sp)
 5c4:	6121                	addi	sp,sp,64
 5c6:	8082                	ret
    x = -xx;
 5c8:	40b005bb          	negw	a1,a1
    neg = 1;
 5cc:	4885                	li	a7,1
    x = -xx;
 5ce:	bf8d                	j	540 <printint+0x1a>

00000000000005d0 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5d0:	7119                	addi	sp,sp,-128
 5d2:	fc86                	sd	ra,120(sp)
 5d4:	f8a2                	sd	s0,112(sp)
 5d6:	f4a6                	sd	s1,104(sp)
 5d8:	f0ca                	sd	s2,96(sp)
 5da:	ecce                	sd	s3,88(sp)
 5dc:	e8d2                	sd	s4,80(sp)
 5de:	e4d6                	sd	s5,72(sp)
 5e0:	e0da                	sd	s6,64(sp)
 5e2:	fc5e                	sd	s7,56(sp)
 5e4:	f862                	sd	s8,48(sp)
 5e6:	f466                	sd	s9,40(sp)
 5e8:	f06a                	sd	s10,32(sp)
 5ea:	ec6e                	sd	s11,24(sp)
 5ec:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5ee:	0005c903          	lbu	s2,0(a1)
 5f2:	18090f63          	beqz	s2,790 <vprintf+0x1c0>
 5f6:	8aaa                	mv	s5,a0
 5f8:	8b32                	mv	s6,a2
 5fa:	00158493          	addi	s1,a1,1
  state = 0;
 5fe:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 600:	02500a13          	li	s4,37
      if(c == 'd'){
 604:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 608:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 60c:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 610:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 614:	00000b97          	auipc	s7,0x0
 618:	3d4b8b93          	addi	s7,s7,980 # 9e8 <digits>
 61c:	a839                	j	63a <vprintf+0x6a>
        putc(fd, c);
 61e:	85ca                	mv	a1,s2
 620:	8556                	mv	a0,s5
 622:	00000097          	auipc	ra,0x0
 626:	ee2080e7          	jalr	-286(ra) # 504 <putc>
 62a:	a019                	j	630 <vprintf+0x60>
    } else if(state == '%'){
 62c:	01498f63          	beq	s3,s4,64a <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 630:	0485                	addi	s1,s1,1
 632:	fff4c903          	lbu	s2,-1(s1)
 636:	14090d63          	beqz	s2,790 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 63a:	0009079b          	sext.w	a5,s2
    if(state == 0){
 63e:	fe0997e3          	bnez	s3,62c <vprintf+0x5c>
      if(c == '%'){
 642:	fd479ee3          	bne	a5,s4,61e <vprintf+0x4e>
        state = '%';
 646:	89be                	mv	s3,a5
 648:	b7e5                	j	630 <vprintf+0x60>
      if(c == 'd'){
 64a:	05878063          	beq	a5,s8,68a <vprintf+0xba>
      } else if(c == 'l') {
 64e:	05978c63          	beq	a5,s9,6a6 <vprintf+0xd6>
      } else if(c == 'x') {
 652:	07a78863          	beq	a5,s10,6c2 <vprintf+0xf2>
      } else if(c == 'p') {
 656:	09b78463          	beq	a5,s11,6de <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 65a:	07300713          	li	a4,115
 65e:	0ce78663          	beq	a5,a4,72a <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 662:	06300713          	li	a4,99
 666:	0ee78e63          	beq	a5,a4,762 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 66a:	11478863          	beq	a5,s4,77a <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 66e:	85d2                	mv	a1,s4
 670:	8556                	mv	a0,s5
 672:	00000097          	auipc	ra,0x0
 676:	e92080e7          	jalr	-366(ra) # 504 <putc>
        putc(fd, c);
 67a:	85ca                	mv	a1,s2
 67c:	8556                	mv	a0,s5
 67e:	00000097          	auipc	ra,0x0
 682:	e86080e7          	jalr	-378(ra) # 504 <putc>
      }
      state = 0;
 686:	4981                	li	s3,0
 688:	b765                	j	630 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 68a:	008b0913          	addi	s2,s6,8
 68e:	4685                	li	a3,1
 690:	4629                	li	a2,10
 692:	000b2583          	lw	a1,0(s6)
 696:	8556                	mv	a0,s5
 698:	00000097          	auipc	ra,0x0
 69c:	e8e080e7          	jalr	-370(ra) # 526 <printint>
 6a0:	8b4a                	mv	s6,s2
      state = 0;
 6a2:	4981                	li	s3,0
 6a4:	b771                	j	630 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6a6:	008b0913          	addi	s2,s6,8
 6aa:	4681                	li	a3,0
 6ac:	4629                	li	a2,10
 6ae:	000b2583          	lw	a1,0(s6)
 6b2:	8556                	mv	a0,s5
 6b4:	00000097          	auipc	ra,0x0
 6b8:	e72080e7          	jalr	-398(ra) # 526 <printint>
 6bc:	8b4a                	mv	s6,s2
      state = 0;
 6be:	4981                	li	s3,0
 6c0:	bf85                	j	630 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 6c2:	008b0913          	addi	s2,s6,8
 6c6:	4681                	li	a3,0
 6c8:	4641                	li	a2,16
 6ca:	000b2583          	lw	a1,0(s6)
 6ce:	8556                	mv	a0,s5
 6d0:	00000097          	auipc	ra,0x0
 6d4:	e56080e7          	jalr	-426(ra) # 526 <printint>
 6d8:	8b4a                	mv	s6,s2
      state = 0;
 6da:	4981                	li	s3,0
 6dc:	bf91                	j	630 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 6de:	008b0793          	addi	a5,s6,8
 6e2:	f8f43423          	sd	a5,-120(s0)
 6e6:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 6ea:	03000593          	li	a1,48
 6ee:	8556                	mv	a0,s5
 6f0:	00000097          	auipc	ra,0x0
 6f4:	e14080e7          	jalr	-492(ra) # 504 <putc>
  putc(fd, 'x');
 6f8:	85ea                	mv	a1,s10
 6fa:	8556                	mv	a0,s5
 6fc:	00000097          	auipc	ra,0x0
 700:	e08080e7          	jalr	-504(ra) # 504 <putc>
 704:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 706:	03c9d793          	srli	a5,s3,0x3c
 70a:	97de                	add	a5,a5,s7
 70c:	0007c583          	lbu	a1,0(a5)
 710:	8556                	mv	a0,s5
 712:	00000097          	auipc	ra,0x0
 716:	df2080e7          	jalr	-526(ra) # 504 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 71a:	0992                	slli	s3,s3,0x4
 71c:	397d                	addiw	s2,s2,-1
 71e:	fe0914e3          	bnez	s2,706 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 722:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 726:	4981                	li	s3,0
 728:	b721                	j	630 <vprintf+0x60>
        s = va_arg(ap, char*);
 72a:	008b0993          	addi	s3,s6,8
 72e:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 732:	02090163          	beqz	s2,754 <vprintf+0x184>
        while(*s != 0){
 736:	00094583          	lbu	a1,0(s2)
 73a:	c9a1                	beqz	a1,78a <vprintf+0x1ba>
          putc(fd, *s);
 73c:	8556                	mv	a0,s5
 73e:	00000097          	auipc	ra,0x0
 742:	dc6080e7          	jalr	-570(ra) # 504 <putc>
          s++;
 746:	0905                	addi	s2,s2,1
        while(*s != 0){
 748:	00094583          	lbu	a1,0(s2)
 74c:	f9e5                	bnez	a1,73c <vprintf+0x16c>
        s = va_arg(ap, char*);
 74e:	8b4e                	mv	s6,s3
      state = 0;
 750:	4981                	li	s3,0
 752:	bdf9                	j	630 <vprintf+0x60>
          s = "(null)";
 754:	00000917          	auipc	s2,0x0
 758:	28c90913          	addi	s2,s2,652 # 9e0 <malloc+0x146>
        while(*s != 0){
 75c:	02800593          	li	a1,40
 760:	bff1                	j	73c <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 762:	008b0913          	addi	s2,s6,8
 766:	000b4583          	lbu	a1,0(s6)
 76a:	8556                	mv	a0,s5
 76c:	00000097          	auipc	ra,0x0
 770:	d98080e7          	jalr	-616(ra) # 504 <putc>
 774:	8b4a                	mv	s6,s2
      state = 0;
 776:	4981                	li	s3,0
 778:	bd65                	j	630 <vprintf+0x60>
        putc(fd, c);
 77a:	85d2                	mv	a1,s4
 77c:	8556                	mv	a0,s5
 77e:	00000097          	auipc	ra,0x0
 782:	d86080e7          	jalr	-634(ra) # 504 <putc>
      state = 0;
 786:	4981                	li	s3,0
 788:	b565                	j	630 <vprintf+0x60>
        s = va_arg(ap, char*);
 78a:	8b4e                	mv	s6,s3
      state = 0;
 78c:	4981                	li	s3,0
 78e:	b54d                	j	630 <vprintf+0x60>
    }
  }
}
 790:	70e6                	ld	ra,120(sp)
 792:	7446                	ld	s0,112(sp)
 794:	74a6                	ld	s1,104(sp)
 796:	7906                	ld	s2,96(sp)
 798:	69e6                	ld	s3,88(sp)
 79a:	6a46                	ld	s4,80(sp)
 79c:	6aa6                	ld	s5,72(sp)
 79e:	6b06                	ld	s6,64(sp)
 7a0:	7be2                	ld	s7,56(sp)
 7a2:	7c42                	ld	s8,48(sp)
 7a4:	7ca2                	ld	s9,40(sp)
 7a6:	7d02                	ld	s10,32(sp)
 7a8:	6de2                	ld	s11,24(sp)
 7aa:	6109                	addi	sp,sp,128
 7ac:	8082                	ret

00000000000007ae <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7ae:	715d                	addi	sp,sp,-80
 7b0:	ec06                	sd	ra,24(sp)
 7b2:	e822                	sd	s0,16(sp)
 7b4:	1000                	addi	s0,sp,32
 7b6:	e010                	sd	a2,0(s0)
 7b8:	e414                	sd	a3,8(s0)
 7ba:	e818                	sd	a4,16(s0)
 7bc:	ec1c                	sd	a5,24(s0)
 7be:	03043023          	sd	a6,32(s0)
 7c2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7c6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7ca:	8622                	mv	a2,s0
 7cc:	00000097          	auipc	ra,0x0
 7d0:	e04080e7          	jalr	-508(ra) # 5d0 <vprintf>
}
 7d4:	60e2                	ld	ra,24(sp)
 7d6:	6442                	ld	s0,16(sp)
 7d8:	6161                	addi	sp,sp,80
 7da:	8082                	ret

00000000000007dc <printf>:

void
printf(const char *fmt, ...)
{
 7dc:	711d                	addi	sp,sp,-96
 7de:	ec06                	sd	ra,24(sp)
 7e0:	e822                	sd	s0,16(sp)
 7e2:	1000                	addi	s0,sp,32
 7e4:	e40c                	sd	a1,8(s0)
 7e6:	e810                	sd	a2,16(s0)
 7e8:	ec14                	sd	a3,24(s0)
 7ea:	f018                	sd	a4,32(s0)
 7ec:	f41c                	sd	a5,40(s0)
 7ee:	03043823          	sd	a6,48(s0)
 7f2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7f6:	00840613          	addi	a2,s0,8
 7fa:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7fe:	85aa                	mv	a1,a0
 800:	4505                	li	a0,1
 802:	00000097          	auipc	ra,0x0
 806:	dce080e7          	jalr	-562(ra) # 5d0 <vprintf>
}
 80a:	60e2                	ld	ra,24(sp)
 80c:	6442                	ld	s0,16(sp)
 80e:	6125                	addi	sp,sp,96
 810:	8082                	ret

0000000000000812 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 812:	1141                	addi	sp,sp,-16
 814:	e422                	sd	s0,8(sp)
 816:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 818:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 81c:	00000797          	auipc	a5,0x0
 820:	1e47b783          	ld	a5,484(a5) # a00 <freep>
 824:	a805                	j	854 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 826:	4618                	lw	a4,8(a2)
 828:	9db9                	addw	a1,a1,a4
 82a:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 82e:	6398                	ld	a4,0(a5)
 830:	6318                	ld	a4,0(a4)
 832:	fee53823          	sd	a4,-16(a0)
 836:	a091                	j	87a <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 838:	ff852703          	lw	a4,-8(a0)
 83c:	9e39                	addw	a2,a2,a4
 83e:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 840:	ff053703          	ld	a4,-16(a0)
 844:	e398                	sd	a4,0(a5)
 846:	a099                	j	88c <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 848:	6398                	ld	a4,0(a5)
 84a:	00e7e463          	bltu	a5,a4,852 <free+0x40>
 84e:	00e6ea63          	bltu	a3,a4,862 <free+0x50>
{
 852:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 854:	fed7fae3          	bgeu	a5,a3,848 <free+0x36>
 858:	6398                	ld	a4,0(a5)
 85a:	00e6e463          	bltu	a3,a4,862 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 85e:	fee7eae3          	bltu	a5,a4,852 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 862:	ff852583          	lw	a1,-8(a0)
 866:	6390                	ld	a2,0(a5)
 868:	02059713          	slli	a4,a1,0x20
 86c:	9301                	srli	a4,a4,0x20
 86e:	0712                	slli	a4,a4,0x4
 870:	9736                	add	a4,a4,a3
 872:	fae60ae3          	beq	a2,a4,826 <free+0x14>
    bp->s.ptr = p->s.ptr;
 876:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 87a:	4790                	lw	a2,8(a5)
 87c:	02061713          	slli	a4,a2,0x20
 880:	9301                	srli	a4,a4,0x20
 882:	0712                	slli	a4,a4,0x4
 884:	973e                	add	a4,a4,a5
 886:	fae689e3          	beq	a3,a4,838 <free+0x26>
  } else
    p->s.ptr = bp;
 88a:	e394                	sd	a3,0(a5)
  freep = p;
 88c:	00000717          	auipc	a4,0x0
 890:	16f73a23          	sd	a5,372(a4) # a00 <freep>
}
 894:	6422                	ld	s0,8(sp)
 896:	0141                	addi	sp,sp,16
 898:	8082                	ret

000000000000089a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 89a:	7139                	addi	sp,sp,-64
 89c:	fc06                	sd	ra,56(sp)
 89e:	f822                	sd	s0,48(sp)
 8a0:	f426                	sd	s1,40(sp)
 8a2:	f04a                	sd	s2,32(sp)
 8a4:	ec4e                	sd	s3,24(sp)
 8a6:	e852                	sd	s4,16(sp)
 8a8:	e456                	sd	s5,8(sp)
 8aa:	e05a                	sd	s6,0(sp)
 8ac:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8ae:	02051493          	slli	s1,a0,0x20
 8b2:	9081                	srli	s1,s1,0x20
 8b4:	04bd                	addi	s1,s1,15
 8b6:	8091                	srli	s1,s1,0x4
 8b8:	0014899b          	addiw	s3,s1,1
 8bc:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8be:	00000517          	auipc	a0,0x0
 8c2:	14253503          	ld	a0,322(a0) # a00 <freep>
 8c6:	c515                	beqz	a0,8f2 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8c8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8ca:	4798                	lw	a4,8(a5)
 8cc:	02977f63          	bgeu	a4,s1,90a <malloc+0x70>
 8d0:	8a4e                	mv	s4,s3
 8d2:	0009871b          	sext.w	a4,s3
 8d6:	6685                	lui	a3,0x1
 8d8:	00d77363          	bgeu	a4,a3,8de <malloc+0x44>
 8dc:	6a05                	lui	s4,0x1
 8de:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8e2:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8e6:	00000917          	auipc	s2,0x0
 8ea:	11a90913          	addi	s2,s2,282 # a00 <freep>
  if(p == (char*)-1)
 8ee:	5afd                	li	s5,-1
 8f0:	a88d                	j	962 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 8f2:	00000797          	auipc	a5,0x0
 8f6:	11678793          	addi	a5,a5,278 # a08 <base>
 8fa:	00000717          	auipc	a4,0x0
 8fe:	10f73323          	sd	a5,262(a4) # a00 <freep>
 902:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 904:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 908:	b7e1                	j	8d0 <malloc+0x36>
      if(p->s.size == nunits)
 90a:	02e48b63          	beq	s1,a4,940 <malloc+0xa6>
        p->s.size -= nunits;
 90e:	4137073b          	subw	a4,a4,s3
 912:	c798                	sw	a4,8(a5)
        p += p->s.size;
 914:	1702                	slli	a4,a4,0x20
 916:	9301                	srli	a4,a4,0x20
 918:	0712                	slli	a4,a4,0x4
 91a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 91c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 920:	00000717          	auipc	a4,0x0
 924:	0ea73023          	sd	a0,224(a4) # a00 <freep>
      return (void*)(p + 1);
 928:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 92c:	70e2                	ld	ra,56(sp)
 92e:	7442                	ld	s0,48(sp)
 930:	74a2                	ld	s1,40(sp)
 932:	7902                	ld	s2,32(sp)
 934:	69e2                	ld	s3,24(sp)
 936:	6a42                	ld	s4,16(sp)
 938:	6aa2                	ld	s5,8(sp)
 93a:	6b02                	ld	s6,0(sp)
 93c:	6121                	addi	sp,sp,64
 93e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 940:	6398                	ld	a4,0(a5)
 942:	e118                	sd	a4,0(a0)
 944:	bff1                	j	920 <malloc+0x86>
  hp->s.size = nu;
 946:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 94a:	0541                	addi	a0,a0,16
 94c:	00000097          	auipc	ra,0x0
 950:	ec6080e7          	jalr	-314(ra) # 812 <free>
  return freep;
 954:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 958:	d971                	beqz	a0,92c <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 95a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 95c:	4798                	lw	a4,8(a5)
 95e:	fa9776e3          	bgeu	a4,s1,90a <malloc+0x70>
    if(p == freep)
 962:	00093703          	ld	a4,0(s2)
 966:	853e                	mv	a0,a5
 968:	fef719e3          	bne	a4,a5,95a <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 96c:	8552                	mv	a0,s4
 96e:	00000097          	auipc	ra,0x0
 972:	b7e080e7          	jalr	-1154(ra) # 4ec <sbrk>
  if(p == (char*)-1)
 976:	fd5518e3          	bne	a0,s5,946 <malloc+0xac>
        return 0;
 97a:	4501                	li	a0,0
 97c:	bf45                	j	92c <malloc+0x92>
