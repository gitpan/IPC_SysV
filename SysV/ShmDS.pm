package IPC::SysV::ShmDS;
require IPC::SysV;

sub new 	{bless ['',IPC::SysV::shm_unpack_shmid_ds($_[1])];}
sub perm_uid 	{$_[0]->[8]}
sub perm_gid 	{$_[0]->[9]}
sub perm_cuid 	{$_[0]->[10]}
sub perm_cgid 	{$_[0]->[11]}
sub perm_mode 	{$_[0]->[12]}
sub segsz 	{$_[0]->[1]}
sub cpid 	{$_[0]->[2]}
sub lpid 	{$_[0]->[3]}
sub nattch 	{$_[0]->[4]}
sub atime 	{$_[0]->[5]}
sub dtime 	{$_[0]->[6]}
sub ctime 	{$_[0]->[7]}
sub mode {
    my($self) = @_;
    $self->[0] && return $self->[0];
    $self->[0] = IPC::SysV::mode_num_2_string($self->perm_mode());
}
sub set_uid_gid_mode{
    my($self, $uid, $gid, $mode) = @_;
    if( defined($uid) ) {$_[0]->[1] = $uid}
    if( defined($gid) ) {$_[0]->[2] = $gid}
    if( defined($qbytes) ) {$_[0]->[7] = $qbytes}
    if( defined($mode) ) {
	$_[0]->[5] = IPC::SysV::mode_string_2_num($mode) || croak(
	    "Error IPC::SysV::ShmDS::set_uid_gid_mode: Invalid MODE");
    }
}
sub repack {
    my($self) = @_;
    IPC::SysV::shm_pack_shmid_ds($self->perm_uid, $self->perm_gid,
					$self->perm_mode);
}

1;
__END__
=head1 NAME

IPC::SysV::ShmDS - Class to hold message queue data structures

=head1 SYNOPSIS


    require IPC::SysV::ShmDS;

    use IPC::SysV qw(IPC_STAT);
    shmctl($qid,IPC_STAT,$shmid_ds);
    
    $shmid_ds_obj = IPC::SysV::ShmDS->new($shmid_ds);
    $shmid_ds_obj->perm_uid();
    $shmid_ds_obj->perm_gid();
    $shmid_ds_obj->perm_cuid();
    $shmid_ds_obj->perm_cgid();
    $shmid_ds_obj->perm_mode();
    $shmid_ds_obj->segsz();
    $shmid_ds_obj->lpid();
    $shmid_ds_obj->cpid();
    $shmid_ds_obj->nattch();
    $shmid_ds_obj->atime();
    $shmid_ds_obj->dtime();
    $shmid_ds_obj->ctime();
    $shmid_ds_obj->mode();
    $shmid_ds_obj->set_uid_gid_mode($uid, $gid, $mode);
    shmctl($qid,IPC_SET,$shmid_ds_obj->repack());

=head1 DESCRIPTION

This package provides a nice interface to a shared memory id data
structure (SHMID_DS).

Given a string holding a SHMID_DS structure ($shmid_ds, for example
as obtained with 'shmctl($qid,IPC_STAT,$shmid_ds)') you can get the
object with

    IPC::SysV::ShmDS->new($shmid_ds);

This object holds the individual parts of the data structure, and
has the following access methods to access the items returned
by IPC::SysV::shm_unpack_shmid_ds().

    $shmid_ds_obj->perm_uid()
    $shmid_ds_obj->perm_gid()
    $shmid_ds_obj->perm_cuid()
    $shmid_ds_obj->perm_cgid()
    $shmid_ds_obj->perm_mode()
    $shmid_ds_obj->qnum() 	
    $shmid_ds_obj->qbytes() 	
    $shmid_ds_obj->lspid() 	
    $shmid_ds_obj->lrpid() 	
    $shmid_ds_obj->stime() 	
    $shmid_ds_obj->rtime() 	
    $shmid_ds_obj->ctime()

In addition, one other access method, 'mode', accesses the perm_mode
in a string readable format ('RW-RW-RW-').

    $shmid_ds_obj->mode()

One updating method is available, 'set_uid_gid_mode'
which takes three arguments, the UID, GID, and MODE,
to update the parts perm_uid, perm_gid, and perm_mode
respectively. Any of these can be undef, in which case the
corresponding value is not altered. The perm_mode argument can
be numeric or in 'RW-RW-RW-' format.

    $shmid_ds_obj->set_uid_gid_mode_qbytes(UID,GID,MODE,QBYTES)

Finally, you can retrieve the packed object for the current
state of the object with the repack method,

    $shmid_ds_obj->repack()

This is useful to reset values.

=AUTHOR

Jack Shirazi

  This program is free software; you can redistribute it and/or
  modify it under the same terms as Perl itself.

=MODIFICATION HISTORY

=item Version 1.0

Base version.

=cut
