package IPC::SysV::SemDS;

sub new {bless ['', IPC::SysV::sem_unpack_semid_ds($_[1])];}
sub perm_mode 	{$_[0]->[8]}
sub perm_gid 	{$_[0]->[7]}
sub perm_uid 	{$_[0]->[6]}
sub perm_cuid 	{$_[0]->[4]}
sub perm_cgid 	{$_[0]->[5]}
sub ctime 	{$_[0]->[3]}
sub otime 	{$_[0]->[2]}
sub nsems 	{$_[0]->[1]}
sub mode {
    my($self) = @_;
    $self->[0] && return $self->[0];
    $self->[0] = IPC::SysV::mode_num_2_string($self->perm_mode());
}
sub set_uid_gid_mode{
    my($self, $uid, $gid, $mode) = @_;
    if( defined($mode) ) {
	$mode = IPC::SysV::mode_string_2_num($mode) || croak(
	    "Error IPC::SysV::SemDSArray::set_uid_gid_mode: Invalid MODE");
	$self->[8] = $mode;
    }
    if( defined($uid) ) {$self->[6] = $uid}
    if( defined($gid) ) {$self->[7] = $gid}
}
sub repack {
    my($self) = @_;
    IPC::SysV::sem_pack_semid_ds($self->perm_uid, $self->perm_gid,
					$self->perm_mode);
}
sub _as_string {
    my($self) = @_;
    my $str = 'mode: ' . $self->mode() . "\n";
    $str .= 'gid:' . $self->perm_gid() . "\n";
    $str .= 'uid:' . $self->perm_uid() . "\n";
    $str .= 'cgid:' . $self->perm_cgid() . "\n";
    $str .= 'cuid:' . $self->perm_cuid() . "\n";
    $str .= 'ctime:' . $self->ctime() . "\n";
    $str .= 'otime:' . $self->otime() . "\n";
    $str .= 'nsems:' . $self->nsems() . "\n";
}

package IPC::SysV::SemDSArray;

1;
__END__
=head1 NAME

IPC::SysV::SemDS - Class to hold semaphore id data structures

=head1 SYNOPSIS


    require IPC::SysV::SemDS;

    use IPC::SysV qw(IPC_STAT IPC_SET);
    semctl($sid,0,IPC_STAT,$semid_ds);
    
    $semds_obj = IPC::SysV::SemDS->new($semid_ds);
    $semds_obj->perm_mode();
    $semds_obj->perm_gid();
    $semds_obj->perm_uid();
    $semds_obj->perm_cuid();
    $semds_obj->perm_cgid();
    $semds_obj->ctime();
    $semds_obj->otime();
    $semds_obj->nsems();
    $semds_obj->mode();
    $semds_obj->set_uid_gid_mode($uid, $gid, $mode);
    msgctl($qid,0,IPC_SET,$semds_obj->repack());

=head1 DESCRIPTION

This package provides an interface to a semaphore id data
structure (SEMID_DS).

Given a string holding a SEMID_DS array ($semid_ds, for example
as obtained with 'semctl($sid,0,IPC_STAT,$semid_ds)') you can get the
object with

    $semds_obj = IPC::SysV::SemDS->new($semid_ds);

This object holds the individual parts of the data structure, and
has the following access methods to access the items returned
by IPC::SysV::sem_unpack_semid_ds().

    $semds_obj->perm_mode();
    $semds_obj->perm_gid();
    $semds_obj->perm_uid();
    $semds_obj->perm_cuid();
    $semds_obj->perm_cgid();
    $semds_obj->ctime();
    $semds_obj->otime();
    $semds_obj->nsems();

In addition, one other access method, 'mode', accesses the perm_mode
in a string readable format ('RW-RW-RW-').

    $semds_obj->mode()

One updating method is available, 'set_uid_gid_mode'
which takes three arguments, the UID, GID, and MODE,
to update the parts perm_uid, perm_gid, and perm_mode
respectively. Any of these can be undef, in which case the
corresponding value is not altered. The perm_mode argument can
be numeric or in 'RW-RW-RW-' format.

    $semid_ds_obj->set_uid_gid_mode(UID,GID,MODE)

Finally, you can retrieve the packed object for the current
state of the object with the repack method,

    $semid_ds_obj->repack()

This is useful to reset values.

=AUTHOR

Jack Shirazi

  This program is free software; you can redistribute it and/or
  modify it under the same terms as Perl itself.

=MODIFICATION HISTORY

=item Version 1.0

Base version.

=cut
