#!/usr/bin/perl

require "common_tools.pl";
$file="aux3_reformatted.nc";
$ans=&tool_file_wait_sizeconverge($file, 10, 100, 1, 1);
