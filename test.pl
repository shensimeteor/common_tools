#!/usr/bin/perl

require "common_tools.pl";

$f="auxhist3_d02_2017-04-27_12:00:00";

$date=&tool_outfilename_to_date12($f);

print $date;

