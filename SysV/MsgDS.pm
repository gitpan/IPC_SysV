package IPC::SysV::MsgDS;
require IPC::SysV;

sub new 	{bless ['',IPC::SysV::msg_unpack_msqid_ds($_[1])];}
sub perm_uid 	{$_[0]->[1]}
sub perm_gid 	{$_[0]->[2]}
sub perm_cuid 	{$_[0]->[3]}
sub perm_cgid 	{$_[0]->[4]}
sub perm_mode 	{$_[0]->[5]}
sub qnum 	{$_[0]->[6]}
sub qbytes 	{$_[0]->[7]}
sub lspid 	{$_[0]->[8]}
sub lrpid 	{$_[0]->[9]}
sub stime 	{$_[0]->[10]}
sub rtime 	{$_[0]->[11]}
sub ctime 	{$_[0]->[12]}
sub mode {
    my($self) = @_;
    $self->[0] && return $self->[0];
    $self->[0] = IPC::SysV::mode_num_2_string($self->perm_mode());
}
sub set_uid_gid_mode_qbytes{
    my($self, $uid, $gid, $mode, $qbytes) = @_;
    if( defined($uid) ) {$_[0]->[1] = $uid}
    if( defined($gid) ) {$_[0]->[2] = $gid}
    if( defined($qbytes) ) {$_[0]->[7] = $qbytes}
    if( defined($mode) ) {
	$_[0]->[5] = IPC::SysV::mode_string_2_num($mode) || croak(
	    "Error IPC::SysV::MsgDS::set_uid_gid_mode_qbytes: Invalid MODE");
    }
}
sub repack {
    my($self) = @_;
    IPC::SysV::msg_pack_msqid_ds($self->perm_uid, $self->perm_gid,
					$self->perm_mode, $self->qbytes);
}

1;
__END__
=head1 NAME

IPC::SysV::MsgDS - Class to hold message queue data structures

=head1 SYNOPSIS


    require IPC::SysV::MsgDS;

    use IPC::SysV qw(IPC_STAT);
    msgctl($qid,IPC_STAT,$msqid_ds);
    
    $msqid_ds_obj = IPC::SysV::MsgDS->new($msqid_ds);
    $msqid_ds_obj->qnum();
    $msqid_ds_obj->set_uid_gid_mode_qbytes($uid, $gid, $mode, $qbytes);
    msgctl($qid,IPC_SET,$msqid_ds_obj->repack());
    $msqid_ds_obj->perm_uid();
    $msqid_ds_obj->perm_gid();
    $msqid_ds_obj->perm_cuid();
    $msqid_ds_obj->perm_cgid();
    $msqid_ds_obj->perm_mode();
    $msqid_ds_obj->qnum();
    $msqid_ds_obj->qbytes();
    $msqid_ds_obj->lspid();
    $msqid_ds_obj->lrpid();
    $msqid_ds_obj->stime();
    $msqid_ds_obj->rtime();
    $msqid_ds_obj->ctime();
    $msqid_ds_obj->mode();

=head1 DESCRIPTION

This package provides a nice interface to a message queue id data
structure (MSQID_DS).

Given a string holding a MSQID_DS structure ($msqid_ds, for example
as obtained with 'msgctl($qid,IPC_STAT,$msqid_ds)') you can get the
object with

    IPC::SysV::MsgDS->new($msqid_ds);

This object holds the individual parts of the data structure, and
has the following access methods to access the items returned
by IPC::SysV::msg_unpack_msqid_ds().

    $msqid_ds_obj->perm_uid()
    $msqid_ds_obj->perm_gid()
    $msqid_ds_obj->perm_cuid()
    $msqid_ds_obj->perm_cgid()
    $msqid_ds_obj->perm_mode()
    $msqid_ds_obj->qnum() 	
    $msqid_ds_obj->qbytes() 	
    $msqid_ds_obj->lspid() 	
    $msqid_ds_obj->lrpid() 	
    $msqid_ds_obj->stime() 	
    $msqid_ds_obj->rtime() 	
    $msqid_ds_obj->ctime()

In addition, one other access method, 'mode', accesses the perm_mode
in a string readable format ('RW-RW-RW-').

    $msqid_ds_obj->mode()

One updating method is available, 'set_uid_gid_mode_qbytes'
which takes four arguments, the UID, GID, MODE, and QBYTES,
to update the parts perm_uid, perm_gid, perm_mode and qbytes
respectively. Any of these can be undef, in which case the
corresponding value is not altered. The perm_mode argument can
be numeric or in 'RW-RW-RW-' format.

    $msqid_ds_obj->set_uid_gid_mode_qbytes(UID,GID,MODE,QBYTES)

Finally, you can retrieve the packed object for the current
state of the object with the repack method,

    $msqid_ds_obj->repack()

This is useful to reset values.

=AUTHOR

Jack Shirazi

  This program is free software; you can redistribute it and/or
  modify it under the same terms as Perl itself.

=MODIFICATION HISTORY

=item Version 1.0

Base version.

=cut
