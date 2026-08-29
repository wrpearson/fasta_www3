#!/usr/bin/perl -w

# lav2plt.pl - produce plot from lav output */

# 26-Aug-2028 modified to read annotation from .lav file if available
# this strategy reads all the annotation information and plots it at the end

# $Id: lav2plt.c 625 2011-03-23 17:21:38Z wrp $ */
# $Revision: 625 $  */

use strict;
use Getopt::Long;
use Pod::Usage;

use vars qw($pminx $pmaxx $pminy $pmaxy $lvstr $max_x $max_y
	    $fxscal $fyscal $fxoff $fyoff
	    @linarr @elinval @blinval @ilinval
	    @line_colors @block_colors
	    $annot_color %annot_names %color_names
	    $have_zdb $have_bits $zdb_size
);

my $OK_CHARS='\'"=!\+\-\|\w\.@ \\\\/%\:\(\)#';

@line_colors=qw(black blue brown green lightgreen);
@block_colors = qw( slategrey lightgreen lightblue pink cyan tan gold plum darkgreen );

($have_bits, $have_zdb, $zdb_size) = (0,0,0);
my ($lav_dev, $shelp, $help) = ('svg',0,0);
my ($x_upd_script, $y_upd_script) = ("","");
my ($x_annot_arr_r, $y_annot_arr_r) = (0,0);

$annot_color = 1;
%annot_names = ();

GetOptions("B"=>\$have_bits,
	   "Z=i"=>\$zdb_size,
	   "xA=s"=>\$x_upd_script,
	   "yA=s"=> \$y_upd_script,
	   "dev=s" => \$lav_dev,
	   "h|?" => \$shelp,
	   "help" => \$help,
    );

pod2usage(1) if $shelp;
pod2usage(exitstatus => 0, verbose => 2) if $help;

#require "./lav_defs.pl";
# $max_x, $max_y define the maximum plotting area
# the actual bounding box/view area will be larger if annotation comments are available
($max_x,$max_y)=(540,540);
@elinval=(1e-4,1e-2,1.0,100.0);
@blinval=(40.0,30.0,20.0,10.0);
@ilinval=(200,100,50,25);

require "./color_defs.pl";

if ($lav_dev =~ m/ps/) {require "./lavplt_ps.pl";}
else {require "./lavplt_svg.pl";}

my ($g_n0, $g_n1);

my $pgm_desc;
my ($s_name0, $s_name1);
my ($s_desc0, $s_desc1, $ss_desc0, $ss_desc1);
my ($p0_beg, $p1_beg, $p0_end, $p1_end);
my $open_plt = 0;

if ($zdb_size) {
  $have_zdb = 1;
}
else {
  $zdb_size = 1;
}

my @xa_annot = ();
my @ya_annot = ();

while (my $line = <>) {
  chomp $line;
  next unless ($line);
  next if ($line =~ m/^#/);

  if ($line =~ m/^d \{/) {$pgm_desc = get_str();}
  elsif ($line =~ m/^h \{/) {
      ($s_desc0, $s_desc1) = get_lav_header(\@xa_annot, \@ya_annot);
      $s_desc0 =~ s/^gi\|\d+\|//;
      $s_desc1 =~ s/^gi\|\d+\|//;
      $s_desc0 = substr($s_desc0,0,50);
      $s_desc1 = substr($s_desc1,0,50);
      $s_desc0 =~ s/[^$OK_CHARS]/_/g;
      $s_desc1 =~ s/[^$OK_CHARS]/_/g;
      ($ss_desc0) = ($s_desc0 =~ m/^(\S+)\s*/);
      ($ss_desc1) = ($s_desc1 =~ m/^(\S+)\s*/);

      if (@xa_annot) {
	  $x_annot_arr_r = \@xa_annot;
      }
      if (@ya_annot) {
	  $y_annot_arr_r = \@ya_annot;
      }
  }
  elsif ($line =~ m/^s \{/) {
    ($s_name0, $p0_beg, $p0_end,$s_name1, $p1_beg, $p1_end) = get_seq_info();
    $g_n0 = $p0_end - $p0_beg + 1;
    $g_n1 = $p1_end - $p1_beg + 1;
  }
  elsif ($line =~ m/^a \{/) {
    unless ($open_plt) {
      if ($y_upd_script) {
# $ss_desc1 needs to be an accession
	  ($ss_desc1) = ($ss_desc1 =~ m/([\w\.\|]+)/);
	  $y_annot_arr_r = get_annot($ss_desc1, $y_upd_script);
      }
      if ($x_upd_script) {
# $ss_desc0 needs to be an accession
	  ($ss_desc0) = ($ss_desc0 =~ m/([\w\.\|]+)/);
	  $x_annot_arr_r = get_annot($ss_desc0, $x_upd_script);
      }
      openplt($g_n0, $g_n1, $p0_beg, $p1_beg,  $s_desc0, $s_desc1, $x_annot_arr_r, $y_annot_arr_r,$have_zdb, $have_bits);
      if (($g_n0 == $g_n1) && ($p0_beg == $p1_beg) && ($p0_end == $p1_end) && $ss_desc0 eq $ss_desc1) {
	drawdiag($g_n0, $g_n1);
      }
      $open_plt = 1;
    }
    do_alignment($p0_beg, $p1_beg, \@xa_annot, \@ya_annot);
  }
}

# unless ($open_plt) {
#   if ($y_upd_script) {$y_annot_arr_r = get_annot($y_upd_script);}
#   if ($x_upd_script) {$x_annot_arr_r = get_annot($x_upd_script);}
#   openplt($g_n0, $g_n1, $p0_beg, $p1_beg,  $s_desc0, $s_desc1, $x_annot_arr_r, $y_annot_arr_r,$have_zdb, $have_bits);
#   if (($g_n0 == $g_n1) && ($p0_beg == $p1_beg) && ($p0_end == $p1_end) &&
#       $ss_desc0 eq $ss_desc1) {
#     drawdiag($g_n0, $g_n1);
#   }
#   $open_plt = 1;
# }

if ($open_plt) {
    if (@xa_annot > 0) {
    }

    if (@ya_annot > 0) {
    }

    closeplt();
}
exit(0);

# get a quote enclosed string
# d {
#   "../bin/lalign36 -m "F11 mchu.lav" ../seq/mchu.aa ../seq/mchu.aa"
# }

# void get_str(FILE *file, char *str, size_t len) {
sub get_str {

  my $str = "";
  while (my $line = <>) {
    chomp $line;
    next unless $line;
    next if ($line =~ m/^#/);
    last if ($line =~ m/}/);
    $str .= $line
  }

  $str =~ s/^\s+"//;
  $str =~ s/"\s*$//;

  return $str;
}

sub parse_h_info {
    my ($line, $annot_r) = @_;
    

    chomp $line;
    my @a_coords = split(/\s:\s/, $line);

    my %fields = ();
    @fields{qw(beg end descr)}  = split(/\t/,$a_coords[1]);

    my ($s_descr, $color) = split('~',$fields{descr});

    $fields{sdescr} = substr($fields{descr},0,12);
    ($fields{sname}) = ($fields{sdescr} =~ m/^(\S+)/);
    ($fields{sname}) = ($fields{sname} =~ m/^([^~]+)/);

    push @$annot_r, \%fields;
    unless ($annot_names{$fields{sname}}) {
      $annot_names{$fields{sname}} = $color
    }
}

# get two quote enclosed strings
# h {
# # qInfo : 7	42	EF-hand_1 {ECO:0000255|PROSITE-ProRule:PRU00448}~1
# # qInfo : 43	78	EF-hand_2 {ECO:0000255|PROSITE-ProRule:PRU00448}~2
# # qInfo : 80	115	EF-hand_3 {ECO:0000255|PROSITE-ProRule:PRU00448}~3
# # qInfo : 116	148	EF-hand_4 {ECO:0000255|PROSITE-ProRule:PRU00448}~4
# # Info : 9	73	C.EF_hand~1
# # Info : 82	146	C.EF_hand~1
#    "MCHU - Calmodulin - Human, rabbit, bovine, rat, a - 148 aa"
#    "MCHU - Calmodulin - Human, rabbit, bovine, rat, and ch"
# }
#
#void get_lav_hdr(FILE *file, char *str0, size_t len0,  char *str1, size_t len1)

sub get_lav_header {
    my ($x_annot_r, $y_annot_r) = @_;

  my @str = ();
  my ($str0,$str1) = ("","");

  while (my $line = <>) {
    chomp $line;
    next unless $line;
    if ($line =~ m/^# qInfo\s*:/) {
	parse_h_info($line, $x_annot_r);
	next;
    }
    elsif ($line =~ m/^# Info\s*:/) {
	parse_h_info($line, $y_annot_r);
	next;
    }
    next if ($line =~ m/^#/);
    last if ($line =~ m/}/);
    push @str, $line;
  }

  do {
    $str0 .= shift @str;
  } while (@str && $str0 !~ m/"\s*$/);

  do {
    $str1 .= shift @str;
  } while (@str && $str1 !~ m/"\s*$/);

  $str0 =~ s/^\s+"//;
  $str0 =~ s/"\s*$//;

  $str1 =~ s/^\s+"//;
  $str1 =~ s/"\s*$//;

  return ($str0, $str1);
}

#void get_seq_info(FILE *file,
#	     char *str0, size_t len0, int *n0_begin, int *n0_end,
#	     char *str1, size_t len1, int *n1_begin, int *n1_end)

sub get_seq_info {

  my @lines = ();
  my ($str0, $str1) = ("","");
  my ($n0_beg, $n0_end, $n1_beg, $n1_end, $blank);

  while (my $line = <>) {
    chomp($line);
    next if ($line =~ m/^#/);
    last if ($line =~ m/}/);
    push @lines, $line;
  }

  ($blank, $str0, $n0_beg, $n0_end) = split(/\s+/,$lines[0]);
  ($blank, $str1, $n1_beg, $n1_end) = split(/\s+/,$lines[1]);

  $str0 =~ s/^\s+"//;
  $str0 =~ s/"\s*$//;

  $str1 =~ s/^\s+"//;
  $str1 =~ s/"\s*$//;

  return ($str0, $n0_beg, $n0_end, $str1, $n1_beg, $n1_end);
}

# void do_alignment(FILE *file, int p0_beg, int p1_beg)
sub do_alignment {
  my ($p0_beg, $p1_beg, $x_annot_r, $y_annot_r ) = @_;
  my ($score, $bits, $s0_beg, $s1_beg, $s0_end, $s1_end, $percent);

  my $have_line = 0;

  while (my $line = <>) {
    chomp $line;
    next unless $line;
   
    if ($line =~ m/^#\s+Region:/) {
	my ($region_line) = ($line =~ m/^# (.+)$/);
	push @$x_annot_r, parse_annot($region_line);
	next;
    } elsif ($line =~ m/^#\s+qRegion:/) {
	my ($region_line) = ($line =~ m/^# (.+)$/);
	push @$y_annot_r, parse_annot($region_line);
	next;
    } elsif ($line =~ m/^#/) {
	next;
    }
    last if ($line =~ m/}/);

    my @fields = split(/\s+/,$line);
    # loose first field if blank
    unless ($fields[0]) {shift @fields;}

    if ($fields[0] eq 's') {($score, $bits) = @fields[1,2];}
    elsif ($fields[0] eq 'b') {($s0_beg, $s1_beg) = @fields[1,2];}
    elsif ($fields[0] eq 'e') {($s0_end, $s1_end) = @fields[1,2];}
    elsif ($fields[0] eq 'l') {
      ($s0_beg, $s1_beg, $s0_end, $s1_end,$percent) = @fields[1..5];
      if ($have_line) {
	sxy_draw($s0_beg-$p0_beg+1, $s1_beg-$p1_beg+1);
	sxy_draw($s0_end-$p0_beg+1, $s1_end-$p1_beg+1);
      }
      else {
	opnline($score, $bits);
	sxy_move($s0_beg - $p0_beg + 1, $s1_beg - $p1_beg + 1);
	sxy_draw($s0_end - $p0_beg + 1, $s1_end - $p1_beg + 1);
	$have_line = 1;
      }
    }
  }
  clsline();
}

# get annot does 2 things:
# (1) read in the annotations
# (2) make a hash of annotation colors, changing the color with each addition
#

sub get_annot {
  my ($acc, $script) = @_;

  my $FIN;

  if (!defined($script) || !$script) {
      return 0;
  }

  $script =~ s/\+/ /g;

  if ($script !~ /^!/) {
    if (!open($FIN,"<", $script)) {
      warn "cannot open annotation file: $script\n";
      return 0;
    }
  }
  else { # run the script on the accession
    $script =~ s/!//;
    ($acc) = ($acc =~ m/^([\w\|]+)/);
    $acc = $1;
    if (!open($FIN, "-|", split(" ","$script \'$acc\'"))) {
      warn "cannot run annotation script:  $script $acc\n";
      return 0;
    }
  }

  my @annots = ();

  my $header = <$FIN>;
  while (my $line = <$FIN>) {
    last if ($line =~ m/^>/);
    chomp $line;
    my %fields = ();
#    @fields{qw(beg type end descr)} = split(/\t/,$line);
    @fields{qw(beg end descr)} = ($line =~ m/^\s*(\d+)\s+(\d+)\s+(\S.*)$/);
    $fields{sdescr} = substr($fields{descr},0,12);
    ($fields{sname}) = ($fields{sdescr} =~ m/^(\S+)/);
    push @annots, \%fields;
    unless ($annot_names{$fields{sname}}) {
      $annot_names{$fields{sname}} = $annot_color++;
    }
  }
  close($FIN);
  return \@annots;
}

# produce e_val from bit score */

#double bit_to_E (double bit)
sub bit_to_E {
  my $bit = shift @_;

  my $M_LN2=0.69314718055994530942;
  my ($p_val);

  $p_val = $g_n0 * $g_n1 / exp($bit * $M_LN2);
  if ($p_val > 0.01) {$p_val = 1.0 - exp(-$p_val);}

  return $zdb_size * $p_val;
}

## parse_annot($region_line): parse
## #  qRegion: 10-74:86-147 : score=191; bits=39.9; Id=0.479; Q=79.1 :  C.EF_hand~1
## #  Region: 7-74:83-147 : score=205; bits=42.8; Id=0.479; Q=86.7 :  C.EF_hand~1
## return: 
sub parse_annot {
    my ($region_line) = @_;
    my ($r_beg, $r_end);

    my @r_fields = split(/\s*:\s+/,$region_line);
    my @range_list = split(':',$r_fields[1]);
    if ($region_line =~ m/qRegion/) {
	($r_beg, $r_end) = split('-',$range_list[0]);
    }
    else {
	($r_beg, $r_end) = split('-',$range_list[1]);
    }

    my ($r_desc) = ($r_fields[-1] =~ m/\s*(\S.*)$/);
    my $r_sdesc = substr($r_desc,0,12);
    my ($r_sname)= ($r_sdesc =~ m/^(\S+)/);

    my %r_info = ('beg'=> $r_beg, 'end'=> $r_end, 'descr'=>$r_desc, 'sdescr'=>$r_sdesc, 'sname'=>$r_sname);
    return \%r_info;
}

=pod

=head1 NAME

lav2plt.pl

=head1 SYNOPSIS

 lav2plt.pl -h -help -B -Z=10000 --dev svg|ps --xA x_annot_script.pl --yA y_annot_script.pl  output.lav

=head1 OPTIONS

 -h	short help
 --help include description
 -B	have bit scores
 -Z=#   simulated database size
 --dev svg|ps graphical output format
 --xA/--yA domain annotation script

=head1 DESCRIPTION

C<lav2plt.pl> reads a local alignment lav file, produced by 'lalign36
-m 11' and produces an alignment plot (on stdout) in svg (--dev svg, default)
or postscript (--dev ps) format.

=head1 AUTHOR

William R. Pearson, wrp@virginia.edu

=cut
