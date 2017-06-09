#!/usr/bin/perl

require "../common_tools.pl";

$ans=&tool_file_wait(10, 5, ("hello.txt"));
print $ans;
