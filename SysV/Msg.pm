package IPC::SysV::Msg;
require IPC::SysV;
require IPC::SysV::MsgDS;
require Exporter;

@ISA = qw(Exporter);

@EXPORT_OK = qw(
	msg_create_queue
	msg_get_queue_id
	msg_get_queue_status
	msg_set_queue_status
	msg_add_to_queue
	msg_remove_from_queue
	msg_remove_queue_id
);


sub msg_get_queue_id {
    my($key) = @_;
    $key == IPC::SysV::IPC_PRIVATE() && croak
	"Usage msg_get_queue_id(KEY): KEY cannot be IPC_PRIVATE value";
    msgget($key,0);
}

sub msg_create_queue {
    my($key,$mode) = @_;

    # msgget(IPC_PRIVATE,$mode); - $key == 0
    # msgget($key, IPC_CREAT|$mode|IPC_EXCL); - $key > 0

    $mode = IPC::SysV::mode_string_2_num($mode) || 
	croak "Usage msg_create_queue(KEY,MODE): MODE '$mode' not valid";

    (defined($key) && $key != 0) ? 
	msgget($key , $mode | IPC::SysV::IPC_CREAT() | IPC::SysV::IPC_EXCL()):
	msgget( IPC::SysV::IPC_PRIVATE() , $mode ) ;
}

sub msg_get_queue_status {
    my($qid) = @_;
    my($arg);
    defined(msgctl($qid , IPC::SysV::IPC_STAT(), $arg)) ?
	IPC::SysV::Msg::DS->new($arg) : undef;
}

sub msg_set_queue_status {
    my($qid,$msqid_ds) = @_;
    ref($msqid_ds) eq IPC::SysV::Msg::DS || croak
	"Usage msg_set_queue_status(ID,MSQID_DS): MSQID_DS of incorrect type";
    msgctl($qid , IPC::SysV::IPC_SET(), $msqid_ds->repack());
}

sub msg_add_to_queue {
    my($qid,$type,$string,$nowait) = @_;
    msgsnd($qid,IPC::SysV::msg_type_and_string_2_msgbuf($type,$string),
		$nowait ? IPC::SysV::IPC_NOWAIT() : 0);
}

sub msg_remove_from_queue {
    my($qid, $size, $type, $nowait, $no_size_error) = @_;
    my($var,$flags);
    $flags = 0;
    if($nowait) {$flags |= IPC::SysV::IPC_NOWAIT()}
    if($no_size_error) {$flags |= IPC::SysV::MSG_NOERROR()}
    msgrcv($qid, $var , $size , $type, $flags) ? 
	IPC::SysV::msg_msgbuf_2_type_and_string($var) : () ;
}

sub msg_remove_queue_id {
    my($qid) = @_;
    msgctl($qid , IPC::SysV::IPC_RMID(), undef);
}

1;
__END__
=head1 NAME

IPC::SysV::Msg - wrapper functions for the msg* functions

=head1 SYNOPSIS

    use IPC::SysV::Msg qw(msg_create_queue ...);

    $key = 55;
    $qid = msg_get_queue_id($key);
    $qid = msg_create_queue($key,'rw-rw--w-');
    msg_add_to_queue($qid,$type,$string,$nowait);
    $ds = msg_get_queue_status($qid);
    $ds->set_uid_gid_mode_qbytes($uid, $gid, $mode, $qbytes);
    msg_set_queue_status($qid,$ds);
    ($type,$str) = msg_remove_from_queue($qid,$size,$type,$nowait,$noerror);
    msg_remove_queue_id($qid);

=head1 DESCRIPTION

This module provides wrappers to msgctl, msgrcv, msgsnd and msgget.
Where undef is returned, you can check the $! status for the
various error types.

=item msg_get_queue_id KEY

Wraps the msgget function for accessing message queue ids.
Returns the msgqid (a number) of the queue data structure
to which KEY is already associated. Returns undef if that
queue does not exist.

=item msg_create_queue KEY, MODE

Wraps the msgget function for creating message queues.
It takes a KEY which should be a positive integer, and a MODE which
should be 9 bit mode or a string in the format: 'RW-RW-RW-' where R
is 'r' or '-', W is 'w' or '-' .

It returns the msgqid (a number) of the queue data structure
created, or undef if the queue could not be created. Specifically,
this will return undef if you try to create a queue on a key
which is already associated to an existing queue.

=item msg_add_to_queue QID, TYPE, STRING [,NOWAIT]

Wraps msgsnd. Adds a message to the queue specified by
QID. The message added contains the type TYPE and the
string STRING. If NOWAIT is true, then the msgsnd
will not block, otherwise it will until the message could
be added to the queue.

=item msg_remove_from_queue QID, SIZE, TYPE, [,NOWAIT [,NOERROR] ]

Wraps msgrcv. Tries to remove a message from the queue specified by
QID. If TYPE is 0, then the first message is removed; if TYPE
is greater than 0, the first message of type TYPE is removed;
If TYPE is less than 0, the first message of the lowest
type that is less than or equal to the absolute value of TYPE
is removed. The call is blocked until a message is available
unless NOWAIT is true. The removed message string is truncated
to size SIZE if it is larger than SIZE and NOERROR is true,
otherwise the call fails (empty array returned, error status in $!).
On success, returns an array with two values, the type of
the message removed, and the string it contained.

=item msg_get_queue_status QID

Wraps msgctl. Returns an IPC::SysV::Msg::DS object holding
the current status of the of the queue.

=item msg_set_queue_status QID, DS

Wraps msgctl. Sets the queue status using the IPC::SysV::Msg::DS
object DS. 

=item msg_remove_queue_id QID

Wraps msgctl. Removes the given by queue id QID from the system.

=AUTHOR

Jack Shirazi

  This program is free software; you can redistribute it and/or
  modify it under the same terms as Perl itself.

=MODIFICATION HISTORY

=item Version 1.0

Base version.

=cut
