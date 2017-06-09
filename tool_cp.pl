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
