#!/usr/bin/perl
use strict;
use warnings;
use Switch;

#  20221013, ray - add UNIX text formate support
#  $ARGV[0] is the first parameter in the command line
#  $0 is the begining of the command line
   my%hSwitch =();
   my@aCmdLn =();
   while ($_=shift) {
      if (s/^-//) {
         $hSwitch{$_} = ($#ARGV<0 || ""eq$ARGV[0] || $ARGV[0]=~/^-/) ?"-" :shift;
      } else { push@aCmdLn,$_; }
   }
   $0 =~ s/.*\///;
   $#aCmdLn==0 || die
"  usage :
  % $0 infile [-b nbit]
  (c) all rights are reserved, rayhuang\@canyon-semi.com.tw, 2015/11/14
  description:
    intel hex file to verilog readmemh form
    -b : bits per line, 'nbit' can be 8, 16 or 32
  return:
    none
exit";

my$hInFile =0;
open (hInFile, "$aCmdLn[0]") || die "cannott open $aCmdLn[0] for reading\n$!";

my@array = ();
my$data = "";
my$ofs = 0;
my$upb = 0;
my$max = 1024*64;
for (my$i=0;$i<$max;$i=$i+1) { $array[$i] = "FF"; }

while (<hInFile>) {
#  print;
   if (/^:([0-9A-F]{2})([0-9A-F]{4})([0-9A-F]{2})([0-9A-F]*)([0-9A-F]{2})[^0-9A-F]*$/) {
#     print "\@$2:",hex$1,",",hex$3,",",$4,",",$5,"\n";
      switch ( $3 ) {
         case "00" {
            $data = $4;
            $ofs = hex$2;
            while ($data =~ /([0-9A-F][0-9A-F])(.*)/) {
               $array[$ofs] = $1;
               $data = $2;
               $ofs = $ofs + 1;
               if ( $upb<$ofs ) { $upb = $ofs; }
            }
#           print $#array," ",$ofs,"\n";
         }
         case "01" {}
         case "02" { die "not support extended address" }
         else { die "un-supported type" }
      }
   }
}

my$num = $upb;
my$biged =0; # 0/1: little/big-endian
my$nbyte =1; # default
  $nbyte =2 if$hSwitch{b}&&$hSwitch{b}==16;
  $nbyte =4 if$hSwitch{b}&&$hSwitch{b}==32;
if ($upb%$nbyte>0) { $num += ($nbyte-$upb%$nbyte); }

for (my $i=0;$i<$num;$i=$i+1) { # big-endian
#  print $array[$i];
   print (($i>$upb) ?"FF" :$array[ ($biged) ?$i :($i + $nbyte-1-($i%$nbyte)*2)]);
   if ($i>=($nbyte-1) && ($i+1)%$nbyte==0 || $i+1==$num) { print "\n"; }
#  print " " if $i%16!=15;
#  print "\n" if $i%16==15;
}

