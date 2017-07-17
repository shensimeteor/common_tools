#!/usr/bin/perl
$file="xxx.pl";
@g=lstat($file);
print($g[7]."\n");
@x=stat($file);
print($x[7]."\n");
