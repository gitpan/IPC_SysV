package IPC::SysV;

use Carp;
require Exporter;
require DynaLoader;
@ISA = qw(Exporter DynaLoader);

@EXPORT_OK = qw(
	
	mode_string_2_num
	mode_num_2_string

	msgctl
	msgget
	msgrcv
	msgsnd
	msg_unpack_msqid_ds
	msg_pack_msqid_ds
	msg_type_and_string_2_msgbuf
	msg_msgbuf_2_type_and_string
	msg_queue_read_ready

	semctl
	semget
	semop
	sem_arr_2_sembuf_arr
	sem_unpack_semid_ds
	sem_pack_semid_ds

	shmctl
	shmget
	shmread
	shmwrite
	shmat
	shmdt

	GETVAL
	GETPID
	GETNCNT
	GETZCNT
	GETALL
	IPC_STAT
	IPC_SET
	IPC_RMID
	IPC_NOWAIT
	IPC_PRIVATE
	IPC_CREAT
	IPC_ALLOC
	IPC_EXCL
	MSG_NOERROR
	SETVAL
	SETALL
	SEM_UNDO
	SHM_RDONLY
	SHM_RND
	SHM_LOCK
	SHM_UNLOCK
	SHMLBA
);	

sub AUTOLOAD {
    local($constname);
    ($constname = $AUTOLOAD) =~ s/.*:://;
    $val = constant($constname, @_ ? $_[0] : 0);
    if ($! != 0) {
#	if ($! =~ /Invalid/) {
#	    $AutoLoader::AUTOLOAD = $AUTOLOAD;
#	    goto &AutoLoader::AUTOLOAD;
#	}
#	else {
	    ($pack,$file,$line) = caller;
	    croak "Your vendor has not defined Socket macro $constname, used";
#	}
    }
    eval "sub $AUTOLOAD { $val }";
    goto &$AUTOLOAD;
}


bootstrap IPC::SysV;

sub mode_string_2_num {
    my($mode) = @_;

    # Just in case its a number already
    $mode =~ /^\d+$/ && return $mode+0;

    $mode =~ /^([r\-])([w\-])\-([r\-])([w\-])\-([r\-])([w\-])\-$/ || 
	return undef;

    my $n_mode = 0;
    if ($1 eq 'r') {$n_mode |= 00400}
    if ($2 eq 'w') {$n_mode |= 00200}
    if ($3 eq 'r') {$n_mode |= 00040}
    if ($4 eq 'w') {$n_mode |= 00020}
    if ($5 eq 'r') {$n_mode |= 00004}
    if ($6 eq 'w') {$n_mode |= 00002}
    $n_mode;
}

sub mode_num_2_string {
    my($n_mode) = @_;

    # Just in case its a string already
    $n_mode =~ /^[r\-][w\-]\-[r\-][w\-]\-[r\-][w\-]\-$/ && 
	return $n_mode;

    $n_mode =~ /^\d+$/ || return undef;

    my $mode = '';
    $mode .= ($n_mode & 00400) ? 'r' : '-';
    $mode .= ($n_mode & 00200) ? 'w' : '-';
    $mode .= '-';
    $mode .= ($n_mode & 00040) ? 'r' : '-';
    $mode .= ($n_mode & 00020) ? 'w' : '-';
    $mode .= '-';
    $mode .= ($n_mode & 00004) ? 'r' : '-';
    $mode .= ($n_mode & 00002) ? 'w' : '-';
    $mode .= '-';
    $mode;
}

sub msg_type_and_string_2_msgbuf {
    my($type,$string) = @_;
    pack("L", $type) . $string;
}

sub msg_msgbuf_2_type_and_string {
    my($msgbuf) = @_;
    unpack("L a*", $msgbuf);
}

1;
__END__
=head1 NAME

IPC::SysV - ipc defines, structure manipulators and functions

=head1 SYNOPSIS

    use IPC::SysV;

    $msgbuf = msg_type_and_string_2_msgbuf($type,$str);
    ($type,$str) = msg_msgbuf_2_type_and_string($msgbuf);
    
    $msqid_ds = pack_msqid_ds($uid, $gid, $mode, $qbytes);
    @msqid_ds = unpack_msqid_ds($msqid_ds);
    $msgbuf = msg_type_and_string_2_msgbuf($type,$msg);
    ($type,$msg) = msg_msgbuf_2_type_and_string($msgbuf);
    @filtered = msg_queue_read_ready($msgqid1,$msgqid2, ...);
    
    $msqid_ds_obj = IPC::SysV::MSQID_DS->new($msqid_ds);
    $readable = $msqid_ds_obj->mode();
    $msqid_ds = $msqid_ds_obj->repack($uid, $gid, $mode, $qbytes);
    
    msgget(IPC_PRIVATE , $mode );
    ...

=head1 DESCRIPTION

This module includes a translation of the C F<sys/ipc.h>, F<sys/msg.h>,
F<sys/sem.h>, and F<sys/shm.h> files. In additions, various
structure manipulating functions, and useful calls are
defined (so far only for msg stuff).

NOTE!!!!! The Perl functions shmctl, shmget, shmread, shmwrite,
msgctl, msgget, msgrcv, msgsnd, semctl, semget, semop are defined
here exactly as for Perl (except that I've fixed semctl). Also I've
included shmat and shmdt. Please have a look to test these.

=item mode_string_2_num MODE

Takes a string representing a permission mode and returns the numeric
value for that string. The string can be a number, in which case
it is just returned, or it can be of the form 'RW-RW-RW-' where R
is 'r' or '-', W is 'w' or '-' . Returns undef if the argument is
neither a number nor a string of the appropriate type.

=item mode_num_2_string MODE

Opposite of mode_string_2_num(). Returns the string representation
of the given permission mode. MODE can be a string of type 'RW-RW-RW-'
in which case it is just returned. Returns undef if the argument is
neither a number nor a string of the appropriate type.

=item msg_type_and_string_2_msgbuf TYPE MSG

Returns the packed msgbuf structure as wanted by msgsnd().
TYPE is a positive number, and MSG is the string holding
the message.

=item msg_msgbuf_2_type_and_string MSGBUF

Returns the two element array consisting of the type
and the message string. MSGBUF is the structure as
filled in by msgrcv()

=item msg_queue_read_ready LIST_OF_MSQIDs

This takes a list of message queue id's and returns a mapped list
of the same size with each item being a 1, 0, or -1 depending
on whether that queue has messages on it (1), does not have
any messages on it (0), or an error occurred trying to determine
the queue status (-1). The error may be because the queue
did not exist, or may be a permission error. This can be determined
by examining $!. This call can be implemented using msgctl in perl,
and has been implemented in C in order to allow the slight gain
provided by not having to repeatedly call the unpack_msqid_ds()
for each queue in order to determine its status. There is
no benefit if you just need to check one queue.

=item pack_msqid_ds UID, GID, MODE, QBYTES

Packs the four argument values into a message queue id data
structure, and returns that as a string. These are the only
values that can be altered by msgctl. See also the
IPC::SysV::MSQID_DS 'repack' method.

=item unpack_msqid_ds MSQID_DS

Takes a string holding a message queue id data structure, and
unpacks it to return some of the packed parts (the parts
that are system inpdendent I hope). You are probably
better off using the IPC::SysV::MSQID_DS 'new' method
which does the same but returns an object which is more
easily handled.

The MSQID_DS structure can be returned by the msgctl() function
This function returns a 12 element array of the following elements
of the MSQID_DS:

    msqid_ds.msg_perm.uid	user id
    msqid_ds.msg_perm.gid	group id
    msqid_ds.msg_perm.cuid	creator user id
    msqid_ds.msg_perm.cgid	creator group id
    msqid_ds.msg_perm.mode	r/w permission
    msqid_ds.msg_qnum		current number of msgs on the queue
    msqid_ds.msg_qbytes		max number of bytes allowed on queue
    msqid_ds.msg_lspid		pid of last msgsnd operation
    msqid_ds.msg_lrpid		pid of last msgrcv operation
    msqid_ds.msg_stime		last msgsnd time
    msqid_ds.msg_rtime		last msgrcv time
    msqid_ds.msg_ctime		last time queue was changed

=AUTHOR

Jack Shirazi

  This program is free software; you can redistribute it and/or
  modify it under the same terms as Perl itself.

=MODIFICATION HISTORY

=item Version 1.0

Base version.

=cut
