#!/usr/bin/perl

&tool_wait_process("start2.sh", $LOGNAME, 10000, 1, 3);

sub tool_wait_process{
    my ($process_grep, $user, $max_wait, $wait_interval, $n_limit) = @_;
    my $ps_cmd;
    if(length($user)==0){
        $ps_cmd=qq(ps -ef | grep "$process_grep" | grep -v grep | wc -l);
    }else{
        $ps_cmd=qq(ps -u $user -f | grep "$process_grep" | grep -v grep | wc -l);
    }
    for($i=0; $i<$max_wait; $i++){
        my $nps=`$ps_cmd`;
        print $nps;
        chomp($nps);
        if( $nps <= $n_limit) {
            last;
        }
        sleep $wait_interval;
    }
}
