#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <sys/types.h>

#if defined(HAS_MSG) || defined(HAS_SEM) || defined(HAS_SHM)
#include <sys/ipc.h>
#ifdef HAS_MSG
#include <sys/msg.h>
#endif
#ifdef HAS_SEM
#include <sys/sem.h>
#endif
#ifdef HAS_SHM
#include <sys/shm.h>
# ifndef HAS_SHMAT_PROTOTYPE
    extern Shmat_t shmat _((int, char *, int));
# endif
#endif
#endif

typedef char* IPC__SysV__Shm;

static int
not_here(s)
char *s;
{
    croak("IPC::SysV::%s not implemented on this architecture", s);
    return -1;
}

static double
constant(name, arg)
char *name;
int arg;
{
    errno = 0; 
    switch (*name) {
    case 'A':
	break;
    case 'B':
	break;
    case 'C':
	break;
    case 'D':
	break;
    case 'E':
	break;
    case 'F':
	break;
    case 'G':
	if (strEQ(name, "GETVAL"))
#ifdef GETVAL
	    return GETVAL;
#else
	    goto not_there;
#endif
	if (strEQ(name, "GETPID"))
#ifdef GETPID
	    return GETPID;
#else
	    goto not_there;
#endif
	if (strEQ(name, "GETNCNT"))
#ifdef GETNCNT
	    return GETNCNT;
#else
	    goto not_there;
#endif
	if (strEQ(name, "GETZCNT"))
#ifdef GETZCNT
	    return GETZCNT;
#else
	    goto not_there;
#endif
	if (strEQ(name, "GETALL"))
#ifdef GETALL
	    return GETALL;
#else
	    goto not_there;
#endif
	break;
    case 'H':
	break;
    case 'I':
	if (strEQ(name, "IPC_STAT"))
#ifdef IPC_STAT
	    return IPC_STAT;
#else
	    goto not_there;
#endif
	if (strEQ(name, "IPC_SET"))
#ifdef IPC_SET
	    return IPC_SET;
#else
	    goto not_there;
#endif
	if (strEQ(name, "IPC_RMID"))
#ifdef IPC_RMID
	    return IPC_RMID;
#else
	    goto not_there;
#endif
	if (strEQ(name, "IPC_NOWAIT"))
#ifdef IPC_NOWAIT
	    return IPC_NOWAIT;
#else
	    goto not_there;
#endif
	if (strEQ(name, "IPC_PRIVATE"))
#ifdef IPC_PRIVATE
	    return IPC_PRIVATE;
#else
	    goto not_there;
#endif
	if (strEQ(name, "IPC_CREAT"))
#ifdef IPC_CREAT
	    return IPC_CREAT;
#else
	    goto not_there;
#endif
	if (strEQ(name, "IPC_ALLOC"))
#ifdef IPC_ALLOC
	    return IPC_ALLOC;
#else
	    goto not_there;
#endif
	if (strEQ(name, "IPC_EXCL"))
#ifdef IPC_EXCL
	    return IPC_EXCL;
#else
	    goto not_there;
#endif
	break;
    case 'J':
	break;
    case 'K':
	break;
    case 'L':
	break;
    case 'M':
	if (strEQ(name, "MSG_NOERROR"))
#ifdef MSG_NOERROR
	    return MSG_NOERROR;
#else
	    goto not_there;
#endif
	break;
    case 'N':
	break;
    case 'O':
	break;
    case 'P':
	break;
    case 'Q':
	break;
    case 'R':
	break;
    case 'S':
	if (strEQ(name, "SETVAL"))
#ifdef SETVAL
	    return SETVAL;
#else
	    goto not_there;
#endif
	if (strEQ(name, "SETALL"))
#ifdef SETALL
	    return SETALL;
#else
	    goto not_there;
#endif
	if (strEQ(name, "SEM_UNDO"))
#ifdef SEM_UNDO
	    return SEM_UNDO;
#else
	    goto not_there;
#endif
	if (strEQ(name, "SHM_RDONLY"))
#ifdef SHM_RDONLY
	    return SHM_RDONLY;
#else
	    goto not_there;
#endif
	if (strEQ(name, "SHM_RND"))
#ifdef SHM_RND
	    return SHM_RND;
#else
	    goto not_there;
#endif
	if (strEQ(name, "SHM_LOCK"))
#ifdef SHM_LOCK
	    return SHM_LOCK;
#else
	    goto not_there;
#endif
	if (strEQ(name, "SHM_UNLOCK"))
#ifdef SHM_UNLOCK
	    return SHM_UNLOCK;
#else
	    goto not_there;
#endif
	if (strEQ(name, "SHMLBA"))
#ifdef SHMLBA
	    return SHMLBA;
#else
	    goto not_there;
#endif
	break;
    case 'T':
	break;
    case 'U':
	break;
    case 'V':
	break;
    case 'W':
	break;
    case 'X':
	break;
    case 'Y':
	break;
    case 'Z':
	break;
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

I32
do_ipcctl(optype, id, n, cmd, astr)
I32 optype;
int id;
int n;
int cmd;
SV *astr;
{
    union semun {
	int val;
	struct semid_ds *buf;
	ushort *array;
    } arg;
    char *a;
    I32 infosize, getinfo;
    I32 ret = -1;

    infosize = 0;
    getinfo = (cmd == IPC_STAT);

    switch (optype)
    {
#ifdef HAS_MSG
    case OP_MSGCTL:
	if (cmd == IPC_STAT || cmd == IPC_SET)
	    infosize = sizeof(struct msqid_ds);
	break;
#endif
#ifdef HAS_SHM
    case OP_SHMCTL:
	if (cmd == IPC_STAT || cmd == IPC_SET)
	    infosize = sizeof(struct shmid_ds);
	break;
#endif
#ifdef HAS_SEM
    case OP_SEMCTL:
	if (cmd == IPC_STAT || cmd == IPC_SET)
	    infosize = sizeof(struct semid_ds);
	else if (cmd == GETALL || cmd == SETALL)
	{
	    struct semid_ds semds;
	    arg.buf = &semds;

	    if (semctl(id, 0, IPC_STAT, arg) == -1)
		return -1;
	    getinfo = (cmd == GETALL);
	    infosize = semds.sem_nsems * sizeof(short);
		/* "short" is technically wrong but much more portable
		   than guessing about u_?short(_t)? */
	}
	break;
#endif
#if !defined(HAS_MSG) || !defined(HAS_SEM) || !defined(HAS_SHM)
    default:
	croak("%s not implemented", op_name[optype]);
#endif
    }

    if (infosize)
    {
	STRLEN len;
	if (getinfo)
	{
	    SvPV_force(astr, len);
	    a = SvGROW(astr, infosize+1);
	}
	else
	{
	    a = SvPV(astr, len);
	    if (len != infosize)
		croak("Bad arg length for %s, is %d, should be %d",
			op_name[optype], len, infosize);
	}
    }
    else
    {
	I32 i = SvIV(astr);
	a = (char *)i;		/* ouch */
    }
    SETERRNO(0,0);
    switch (optype)
    {
#ifdef HAS_MSG
    case OP_MSGCTL:
	ret = msgctl(id, cmd, (struct msqid_ds *)a);
	break;
#endif
#ifdef HAS_SEM
    case OP_SEMCTL:
	arg.buf = (struct semid_ds *)a;
	arg.array = (ushort *)a;
	arg.val = (int)a;
	ret = semctl(id, n, cmd, arg);
	break;
#endif
#ifdef HAS_SHM
    case OP_SHMCTL:
	ret = shmctl(id, cmd, (struct shmid_ds *)a);
	break;
#endif
    }
    if (getinfo && ret >= 0) {
	SvCUR_set(astr, infosize);
	*SvEND(astr) = '\0';
	SvSETMAGIC(astr);
    }
    return ret;
}

I32
do_shmio(optype, id, mstr, mpos, msize)
I32 optype;
I32 id;
SV *mstr;
I32 mpos;
I32 msize;
{
#ifdef HAS_SHM
    char *mbuf, *shm;
    STRLEN len;
    struct shmid_ds shmds;

    SETERRNO(0,0);
    if (shmctl(id, IPC_STAT, &shmds) == -1)
	return -1;
    if (mpos < 0 || msize < 0 || mpos + msize > shmds.shm_segsz) {
	SETERRNO(EFAULT,SS$_ACCVIO);	/* can't do as caller requested */
	return -1;
    }
    shm = (Shmat_t)shmat(id, (char*)NULL, (optype == OP_SHMREAD) ? SHM_RDONLY : 0);
    if (shm == (char *)-1)	/* I hate System V IPC, I really do */
	return -1;
				/* Its got its good points Larry. (-JS)*/
    if (optype == OP_SHMREAD) {
	SvPV_force(mstr, len);
	mbuf = SvGROW(mstr, msize+1);

	Copy(shm + mpos, mbuf, msize, char);
	SvCUR_set(mstr, msize);
	*SvEND(mstr) = '\0';
	SvSETMAGIC(mstr);
    }
    else {
	I32 n;

	mbuf = SvPV(mstr, len);
	if ((n = len) > msize)
	    n = msize;
	Copy(mbuf, shm + mpos, n, char);
	if (n < msize)
	    memzero(shm + mpos + n, msize - n);
    }
    return shmdt(shm);
#else
    croak("shm I/O not implemented");
#endif
}

MODULE = IPC::SysV		PACKAGE = IPC::SysV

double
constant(name,arg)
	char *		name
	int		arg

void
msg_unpack_msqid_ds(msqid_buf)
	SV *		msqid_buf
	PPCODE:
	{
	STRLEN buflen;
	struct msqid_ds queue;
	char *buf = SvPV(msqid_buf,buflen);
	if (buflen != sizeof(queue)) {
	    croak("IPC::SysV::unpack_msqid_ds(MSQID_DS): MSQID_DS has incorrect size");
	}
	Copy( buf, &queue, sizeof queue, char );
	EXTEND(sp, 12);
	PUSHs(sv_2mortal(newSViv(queue.msg_perm.uid)));
	PUSHs(sv_2mortal(newSViv(queue.msg_perm.gid)));
	PUSHs(sv_2mortal(newSViv(queue.msg_perm.cuid)));
	PUSHs(sv_2mortal(newSViv(queue.msg_perm.cgid)));
	PUSHs(sv_2mortal(newSViv(queue.msg_perm.mode)));
	PUSHs(sv_2mortal(newSViv(queue.msg_qnum)));
	PUSHs(sv_2mortal(newSViv(queue.msg_qbytes)));
	PUSHs(sv_2mortal(newSViv(queue.msg_lspid)));
	PUSHs(sv_2mortal(newSViv(queue.msg_lrpid)));
	PUSHs(sv_2mortal(newSViv(queue.msg_stime)));
	PUSHs(sv_2mortal(newSViv(queue.msg_rtime)));
	PUSHs(sv_2mortal(newSViv(queue.msg_ctime)));
	}
	
void
msg_pack_msqid_ds(uid,gid,mode,qbytes)
	ushort 	uid
	ushort	gid
	ushort	mode
	ushort	qbytes
	CODE:
	{
	struct msqid_ds queue;
	queue.msg_perm.uid = uid;
	queue.msg_perm.gid = gid;
	queue.msg_perm.mode = mode;
	queue.msg_qbytes = qbytes;
	ST(0) = sv_2mortal(newSVpv((char *)&queue,sizeof queue ));
	}

void
msg_queue_read_ready(...)
	PPCODE:
	{
	    int i;
	    struct msqid_ds buf;
	    for (i = 0; i < items; i++) {
		if (msgctl(SvIV(ST(i)), IPC_STAT, &buf) == 0 ) {
		    if (buf.msg_qnum != 0) {
			PUSHs(sv_2mortal(newSViv(1)));
		    } else {
			PUSHs(sv_2mortal(newSViv(0)));
		    }
		} else {
		    PUSHs(sv_2mortal(newSViv(-1)));
		}
	    }
	}


void
sem_arr_2_sembuf_arr(...)
	CODE:
	{
	struct sembuf sbuf;
	int i, size;
	char *ret, *index;

	if (items % 3 != 0) {
	    croak("IPC::SysV::sem_arr_2_sembuf_arr(...): Invalid number of args");
	}
	
	New(12345, ret, size = sizeof(sbuf) * items / 3, char);
	index = ret;

	for (i = 0; i < items; i+=3) {
	    sbuf.sem_num = SvIV(ST(i));
	    sbuf.sem_op  = SvIV(ST(i+1));
	    sbuf.sem_flg = SvIV(ST(i+2));
	    Copy( &sbuf, index, sizeof(sbuf), char);
	    index += sizeof(sbuf);
	}

	ST(0) = sv_2mortal(newSVpv(ret, size));
	Renew(ret, size, char);
	}

void
shm_unpack_shmid_ds(str)
	SV *		str
	PPCODE:
	{
	    STRLEN buflen;
	    struct shmid_ds ds;
	    char *buf = SvPV(str,buflen);

	    if ( buflen != sizeof(ds) ) {
		croak("IPC::SysV::sem_unpack_shmid_ds(STR): STR has incorrect length");
	    }

	    EXTEND(sp, 12);
	    Copy( buf, (char *)&ds, sizeof(ds), char);
	    PUSHs(sv_2mortal(newSViv(ds.shm_segsz)));
	    PUSHs(sv_2mortal(newSViv(ds.shm_cpid)));
	    PUSHs(sv_2mortal(newSViv(ds.shm_lpid)));
	    PUSHs(sv_2mortal(newSViv(ds.shm_nattch)));
	    PUSHs(sv_2mortal(newSViv(ds.shm_atime)));
	    PUSHs(sv_2mortal(newSViv(ds.shm_dtime)));
	    PUSHs(sv_2mortal(newSViv(ds.shm_ctime)));
	    PUSHs(sv_2mortal(newSViv(ds.shm_perm.cuid)));
	    PUSHs(sv_2mortal(newSViv(ds.shm_perm.cgid)));
	    PUSHs(sv_2mortal(newSViv(ds.shm_perm.uid)));
	    PUSHs(sv_2mortal(newSViv(ds.shm_perm.gid)));
	    PUSHs(sv_2mortal(newSViv(ds.shm_perm.mode)));
	}

void
shm_pack_shmid_ds(uid,gid,mode)
	ushort 	uid
	ushort	gid
	ushort	mode
	CODE:
	{
	struct shmid_ds shmid;
	shmid.shm_perm.uid = uid;
	shmid.shm_perm.gid = gid;
	shmid.shm_perm.mode = mode;
	ST(0) = sv_2mortal(newSVpv((char *)&shmid,sizeof shmid ));
	}

void
sem_unpack_semid_ds(str)
	SV *		str
	PPCODE:
	{
	    STRLEN buflen;
	    struct semid_ds ds;
	    char *buf = SvPV(str,buflen);

	    if ( buflen != sizeof(ds) ) {
		croak("IPC::SysV::sem_unpack_semid_ds(STR): STR has incorrect length");
	    }

	    EXTEND(sp, 8);
	    Copy( buf, (char *)&ds, sizeof(ds), char);
	    PUSHs(sv_2mortal(newSViv(ds.sem_nsems)));
	    PUSHs(sv_2mortal(newSViv(ds.sem_otime)));
	    PUSHs(sv_2mortal(newSViv(ds.sem_ctime)));
	    PUSHs(sv_2mortal(newSViv(ds.sem_perm.cuid)));
	    PUSHs(sv_2mortal(newSViv(ds.sem_perm.cgid)));
	    PUSHs(sv_2mortal(newSViv(ds.sem_perm.uid)));
	    PUSHs(sv_2mortal(newSViv(ds.sem_perm.gid)));
	    PUSHs(sv_2mortal(newSViv(ds.sem_perm.mode)));
	}

void
sem_pack_semid_ds(uid,gid,mode)
	ushort 	uid
	ushort	gid
	ushort	mode
	CODE:
	{
	struct semid_ds semid;
	semid.sem_perm.uid = uid;
	semid.sem_perm.gid = gid;
	semid.sem_perm.mode = mode;
	ST(0) = sv_2mortal(newSVpv((char *)&semid,sizeof semid ));
	}

void
semctl(semid, semnum, cmd, astr)
	int semid
	int semnum
	int cmd
	SV * astr
	CODE:
	{
	    I32 ret;
	    if ( (ret = do_ipcctl(OP_SEMCTL, semid, semnum, cmd, astr)) == -1)
	    {
		ST(0) = sv_newmortal();
	    }
	    else if (ret == 0)
	    {
		ST(0) = sv_2mortal(newSVpv("0 but true",10));
	    }
	    else
	    {
		ST(0) = sv_2mortal(newSViv(ret));
	    }
	}

void
msgctl(msgid, cmd, astr)
	int msgid
	int cmd
	SV * astr
	CODE:
	{
	    int ret;
	    if ( (ret = do_ipcctl(OP_MSGCTL, msgid, 0, cmd, astr)) == -1)
	    {
		ST(0) = sv_newmortal();
	    }
	    else if (ret == 0)
	    {
		ST(0) = sv_2mortal(newSVpv("0 but true",10));
	    }
	    else
	    {
		ST(0) = sv_2mortal(newSViv(ret));
	    }
	}

void
shmctl(shmid, cmd, astr)
	int shmid
	int cmd
	SV * astr
	CODE:
	{
	    int ret;
	    if ( (ret = do_ipcctl(OP_SHMCTL, shmid, 0, cmd, astr)) == -1)
	    {
		ST(0) = sv_newmortal();
	    }
	    else if (ret == 0)
	    {
		ST(0) = sv_2mortal(newSVpv("0 but true",10));
	    }
	    else
	    {
		ST(0) = sv_2mortal(newSViv(ret));
	    }
	}

void
msgget(key, msgflg)
	key_t key
	int msgflg
	CODE:
	{
#ifdef HAS_MSG
	   int ret;
	   SETERRNO(0,0);
	   if ( (ret = msgget(key, msgflg)) == -1)
	    {
		ST(0) = sv_newmortal();
	    }
	    else
	    {
		ST(0) = sv_2mortal(newSViv(ret));
	    }
#else
	   croak("msgget not implemented");
#endif
	}

void
shmget(key, size, msgflg)
	key_t key
	int size
	int msgflg
	CODE:
	{
#ifdef HAS_SHM
	   int ret;
	   SETERRNO(0,0);
	   if ( (ret = shmget(key, size, msgflg)) == -1)
	    {
		ST(0) = sv_newmortal();
	    }
	    else
	    {
		ST(0) = sv_2mortal(newSViv(ret));
	    }
#else
	   croak("shmget not implemented");
#endif
	}

void
semget(key, nsems, msgflg)
	key_t key
	int nsems
	int msgflg
	CODE:
	{
#ifdef HAS_SHM
	   int ret;
	   SETERRNO(0,0);
	   if ( (ret = semget(key, nsems, msgflg)) == -1)
	    {
		ST(0) = sv_newmortal();
	    }
	    else
	    {
		ST(0) = sv_2mortal(newSViv(ret));
	    }
#else
	   croak("semget not implemented");
#endif
	}

void
semop(id,opstr)
	int id
	SV * opstr
	CODE:
	{
#ifdef HAS_SEM
	STRLEN opsize;
	char * opbuf = SvPV(opstr, opsize);
	if (opsize < sizeof(struct sembuf)
	    || (opsize % sizeof(struct sembuf)) != 0) {
		SETERRNO(EINVAL,LIB$_INVARG);
		ST(0) = sv_newmortal();
	} else {
	    SETERRNO(0,0);
	    if (semop(id, (struct sembuf *)opbuf, 
	    		opsize/sizeof(struct sembuf)) == 0) {
		ST(0) = sv_2mortal(newSViv(1));
	    } else {
		ST(0) = sv_newmortal();
	    }
	}
#else
	croak("semop not implemented");
#endif
	}

void
msgsnd(id, mstr, flags)
	int id
	SV * mstr
	int flags
	CODE:
	{
#ifdef HAS_MSG
	int msize;
	STRLEN len;
	char *mbuf = SvPV(mstr, len);
	if ((msize = len - sizeof(long)) < 0)
		croak("Arg too short for msgsnd");

	SETERRNO(0,0);
	if (msgsnd(id, (struct msgbuf *)mbuf, msize, flags) == 0) {
		ST(0) = sv_2mortal(newSViv(1));
	} else {
		ST(0) = sv_newmortal();
	}
#else
	croak("msgsnd not implemented");
#endif
	}

void
msgrcv(id, mstr, msize, mtype, flags)
	int id
	SV *mstr
	int msize
	long mtype
	int flags
	CODE:
	{
#ifdef HAS_MSG
	STRLEN len;
	char *mbuf;	
	int ret;

	if (SvTHINKFIRST(mstr)) {
	    if (SvREADONLY(mstr))
		croak("Can't msgrcv to readonly var");
	    if (SvROK(mstr))
		sv_unref(mstr);
	}
	SvPV_force(mstr, len);
	mbuf = SvGROW(mstr, sizeof(long)+msize+1);

	SETERRNO(0,0);
	ret = msgrcv(id, (struct msgbuf *)mbuf, msize, mtype, flags);
	if (ret >= 0) {
	    SvCUR_set(mstr, sizeof(long)+ret);
	    *SvEND(mstr) = '\0';
	    ST(0) = sv_2mortal(newSViv(1));
	} else {
	    ST(0) = sv_newmortal();
	}
#else
	croak("msgsnd not implemented");
#endif
	}

void
shmread(id, mstr, mpos, msize)
	int id
	SV *mstr
	I32 mpos
	I32 msize
	CODE:
	{
	    if ( do_shmio(OP_SHMREAD, id, mstr, mpos, msize) == -1)
	    {
		ST(0) = sv_newmortal();
	    }
	    else
	    {
		ST(0) = sv_2mortal(newSViv(1));
	    }
	}

void
shmwrite(id, mstr, mpos, msize)
	int id
	SV *mstr
	I32 mpos
	I32 msize
	CODE:
	{
	    if ( do_shmio(OP_SHMWRITE, id, mstr, mpos, msize) == -1)
	    {
		ST(0) = sv_newmortal();
	    }
	    else
	    {
		ST(0) = sv_2mortal(newSViv(1));
	    }
	}


char *
shmat(shmid, shmaddr, shmflg)
	int shmid
	char *	shmaddr
	int shmflg

int
shmdt(shmaddr)
	char *	shmaddr

