use IPC::SysV qw(IPC_PRIVATE IPC_RMID sem_arr_2_sembuf_arr
		 mode_string_2_num GETNCNT GETALL IPC_STAT);
require IPC::SysV::SemDS;


#Creating a semaphore queue
$mode = mode_string_2_num('rw-rw-rw-');
defined($semid = semget(IPC_PRIVATE, 1, $mode)) || die "semget: ",$!+0," $!\n";
print "Semid is ",$semid,"\n";

#Check semncnt
$arg = semctl($semid,$semnum,GETNCNT,undef) || die "semctl:",$!+0," $!\n";
print "The current value of semncnt is ",$arg,"\n";

#Waiting on  a semaphore
$semnum = 0; #index into semaphore array
$semflg = 0; #False
defined($pid = fork) || die "fork: $!\n";
unless($pid) {
    print "Child (pid $$) waiting on a semaphore ...\n";
    semop($semid, sem_arr_2_sembuf_arr($semnum,-1,$semflg)) ||
	die "semop: ",$!+0," $!\n";
    die "Child finished - semaphore signalled\n";
}

select(undef,undef,undef,1.5); #pause a second or so

#Check semncnt
$arg = semctl($semid,$semnum,GETNCNT,undef) || die "semctl:",$!+0," $!\n";
print "The current value of semncnt is ",$arg+0,"\n";

#semctl with IPC_STAT doesn't work!
IPC::SysV::semctl($semid,$semnum,IPC_STAT,$arg2) || die "semctl: $!\n";
$semid_ds_arr = IPC::SysV::SemDS->new($arg2);
print $semid_ds_arr->_as_string();

#Signalling the waiting child
print "Signalling the child waiting on the semaphore\n";
semop($semid, sem_arr_2_sembuf_arr($semnum,1,$semflg)) ||
	die "semop: ",$!+0," $!\n";

select(undef,undef,undef,1.5); #pause a second or so

#Check semncnt
$arg = semctl($semid,$semnum,GETNCNT,undef) || die "semctl:",$!+0," $!\n";
print "The current value of semncnt is ",$arg+0,"\n";

#Removing the semaphore queue
print "Removing the semaphore queue\n";
semctl($semid,0,IPC_RMID,undef);

__END__
