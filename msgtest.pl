use IPC::SysV qw(IPC_PRIVATE IPC_RMID IPC_NOWAIT IPC_STAT mode_string_2_num
    msg_type_and_string_2_msgbuf msg_msgbuf_2_type_and_string);
require IPC::SysV::MsgDS;


#Creating a message queue
$mode = mode_string_2_num('rw-rw-rw-');
defined($msqid = msgget(IPC_PRIVATE, $mode)) || die "msgget: ",$!+0," $!\n";
print "Msqid is ",$msqid,"\n";

#Putting a message on the queue
$msgtype = 1;
$msg = "hello";
msgsnd($msqid,msg_type_and_string_2_msgbuf($msgtype,$msg),0) || 
	die "msgsnd: ",$!+0," $!\n";
print "Sent message of type '$msgtype'. Message is '$msg'\n";

#Check if there are messages on the queue
msgctl($msqid,IPC_STAT,$msqid_ds) || die "msgctl: $!\n";
$msqid_ds = IPC::SysV::MsgDS->new($msqid_ds);
$num = $msqid_ds->qnum();
print 'There ',($num == 1?'is ':'are '),($num?$num:'no'),
	' message',($num == 1?'':'s')," on the '$msqid' queue\n";

#Retreiving a message from the queue
$msgtype = 0; # Give me any type
msgrcv($msqid,$msgbuf,256,$msgtype,IPC_NOWAIT) || die "msgrcv: $!\n";
($msgtype,$msg) = msg_msgbuf_2_type_and_string($msgbuf);
print "Received Message of type '$msgtype'. Message is '$msg'\n";

#Removing the queue
msgctl($msqid,IPC_RMID,undef);

__END__
