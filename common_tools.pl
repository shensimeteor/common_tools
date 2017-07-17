#!/usr/bin/perl
#NOT TEST YET
#on Date
#tool_outfilename_to_date12($filename): outfile: wrfout, auxhist3, etc.; date12:yyyymmddhhMM
#tool_date12_to_outfilename($prefix, $date12, $postfix): e.g.prefix=auxhist3_d04_, postifx=""
#tool_date12_diff_minutes($date12_1, $date12_2)
#tool_date12_add($date12, $add_value, $unit) #unit: day, hour, minute
#on File
#tool_file_wait($n_max_wait, $n_interval_sec, @files_to_be_waited)
#tool_outfile_ls($dir, $prefix, $postfix, $start_date12, $end_date12, $interval_minutes) #return 
#tool_to_abspath($filepath) #return the abspath for filepath
#on Process
#on Arguments

#$1: fill value, if nothing append to opt, then fill as fill
sub tool_get_cmdopt{
    my ($fill) = @_;
    $narg = scalar(@ARGV);
    %opt_hash = {};
    for ($i=0; $i< $narg; $i++) {
        if ( $ARGV[$i] =~ /^-/ ) {
            $arg_name = $ARGV[$i];
            $arg_name =~ s/^-//g; 
            if ( $i < $narg - 1) {
                $next_arg = $ARGV[$i+1];
                if ($next_arg =~ /^-/) {
                    $opt_hash{$arg_name} = $fill;
                }else{
                    $opt_hash{$arg_name} = $next_arg; 
                }
            } else{
                $opt_hash{$arg_name} = $fill;
            }
        }
    }
    %opt_hash;
}




#get date12(yyyymmddhhMM) from (wrfout/auxhist) file name, must end with either ".nc" or no_postfix
sub tool_outfilename_to_date12{
    my ($filename)=@_;
    my $len=length($filename);
    if( $filename =~ /.*\.nc$/) {
        $offset=3;
    }elsif ( $filename =~ /.*00$/) {
        $offset=0;
    }else{
        print "error: file $filename postfix is unkown, cannot resolve date from file name\n";
        return -1;
    }
    my $yyyy=substr($filename, $len-$offset-19, 4);
    my $mm=substr($filename, $len-$offset-14, 2);
    my $dd=substr($filename, $len-$offset-11, 2);
    my $hh=substr($filename, $len-$offset-8, 2);
    my $mn=substr($filename, $len-$offset-5, 2);
    my $date12="${yyyy}${mm}${dd}${hh}${mn}";
}

#e.g. 2017030200 -> 2017-03-02_00:00:00 (format in aux/wrfout names)
sub tool_date12_to_outfilename{
    my ($prefix,$date12,$postfix) = @_;
    my $yyyy=substr($date12,0,4);
    my $mm=substr($date12,4,2);
    my $dd=substr($date12,6,2);
    my $hh=substr($date12,8,2);
    my $mn=substr($date12,10,2);
    my $str=$prefix.$yyyy."-".$mm."-".$dd."_".$hh.":".$mn.":00".$postfix;
}

#$1 - $2, $1 & $2: date in 12 (yyyymmddhhMM)
sub tool_date12_diff_minutes{
    my ($date1, $date2) = @_;
    my $ymd1 = substr($date1, 0, 8);
    my $hh1 = substr($date1, 8, 2);
    my $mm1 = substr($date1, 10, 2);
    my $ymd2 = substr($date2, 0, 8);
    my $hh2 = substr($date2, 8, 2);
    my $mm2 = substr($date2, 10, 2);
    my $sec1 = `date -d "$ymd1 $hh1:$mm1:00" +%s`;
    chomp($sec1);
    my $sec2 = `date -d "$ymd2 $hh2:$mm2:00" +%s`;
    chomp($sec2);
    my $diff_minutes = ($sec1 - $sec2)/60;
}

sub tool_date12_add{
    my ($date12, $add_value, $unit) = @_;
    my $datestr=&tool_date12_to_commondate($date12);
    my $sign="";
    if($add_value < 0){
        $sign=" ago";
        $add_value=-$add_value;
    }
    my $datex=`date -d "$datestr $add_value $unit $sign" +%Y%m%d%H%M`;
    chomp($datex);
    $datex;
}

#files_to_be_waited's elements are "or" with each other
sub tool_file_wait{
    my ($n_max_wait, $n_interval_sec, @files_to_be_waited) = @_;
    my $i=0;
    my $complete=0;
    my $waited_file="";
    my $flag="Fail for waiting!";
    for($i=0; $i<$n_max_wait; $i++) {
        for $file (@files_to_be_waited) {
            if ( -e $file ) {
                $complete=1;
                $waited_file=$file;
                last;
            }
        }
        if ( $complete == 1) {
            $flag="Succeed waiting: $file exist!";
            last;
        }
        sleep $n_interval_sec;
    }
    $flag;
}

#if file exist & size converges & size > size_threshold, return immediately, else wait until satisfy
sub tool_file_wait_sizeconverge{
    my ($file, $size_threshold, $n_max_wait, $n_int_sec, $verbose) = @_;
    my $size0;
    my $sizex;
    if( -e $file) {
        @statx=stat($file);
        $size0=$statx[7];
    }else{
        $size0=0;
    }
    if($verbose){
        print("in tool_file_wait_sizeconverge -- \n");
        print(" $file initial size = $size0 \n");
    }
    for (my $i=0; $i< $n_max_wait; $i++) {
        if($verbose) {
            print(" $i sleep $n_int_sec sec .. \n");
        }
        sleep($n_int_sec);
        if( -e $file) {
            @statx=stat($file); 
            $sizex=$statx[7];
        }else{
            $sizex=0;
        }
        if($sizex == $size0 && $sizex >= $size_threshold) {
            if($verbose){
                print(" size converges at $sizex b, return -- \n");
            }
            return "True";
        }
        $size0=$sizex;
    }
    return "False";
}
        




#common_date: YYYY-MM-DD HH:mm:ss
sub tool_date12_to_commondate{ 
    my ($date12)=@_;
    my $yyyy=substr($date12,0,4);
    my $mm=substr($date12,4,2);
    my $dd=substr($date12,6,2);
    my $hh=substr($date12,8,2);
    my $mn=substr($date12,10,2);
    my $str="${yyyy}-${mm}-${dd} ${hh}:${mn}:00";
}


sub tool_outfile_ls{
    my ($dir, $prefix, $postifx, $start_date12, $end_date12, $interval_minutes) = @_;
#interval_minutes to be added
    my $wd=`pwd`;
    chdir($dir);
    my @all_files=`ls $prefix*$postfix`;
    sort @all_files;
    my @ls_files=();
    foreach $file (@all_files) {
        chomp($file);
        my $this_date=&tool_outfilename_to_date12($file);
        my $diff1=&tool_date12_diff_minutes($this_date, $start_date12);
        my $diff2=&tool_date12_diff_minutes($this_date, $end_date12);
        if ($diff1 >= 0 && $diff2 <=0) {
            push(@ls_files, $file);
        }
    }
    @ls_files;
}

sub tool_to_abspath{
    my ($path) = @_;
    $cwd=`pwd`;
    chomp($cwd);
    if ($path =~ /^\//) {
        $abspath=$path;
    }else{
        $abspath=$cwd.'/'.$path;
    }
    return($abspath);
}

sub tool_wait_process{
    my ($process_grep, $user, $max_wait, $wait_interval, $n_limit) = @_;
    if(length($user)==0){
        my $ps_cmd=qq(ps -ef | grep "$process_grep" | grep -v grep | wc -l);
    }else{
        my $ps_cmd=qq(ps -u $user -f | grep "$process_grep" | grep -v grep | wc -l);
    }
    for($i=0; $i<$max_wait; $i++){
        my $nps=`$ps_cmd`;
        chomp($nps);
        if( $nps <= $n_limit) {
            last;
        }
        sleep $wait_interval;
    }
}

    
1;
