###dummy###
use lib qw(./Mod);
use Mod::Posdata;
use Mod::Scorefile;
use Statistics::Lite qw(:all);

$stream= shift @ARGV;
$savefile = shift @ARGV;
@datafiles = @ARGV;

$count = 0;

@scorefiles = grep { /\.data$/ } @datafiles;
@posfiles = grep { /\.txt$/ } @datafiles;
open OUT ,"> $savefile"or die;
foreach my $posfile (@posfiles){
    my $chr;
    
    ###スコアファイル(wigファイル)を開く###
    
    if ($posfile =~ /(chr[0-9]+)/g){
        $chr = $1;
    }
    else{
        "Chromosome type couldn't be found. Input the chromosome number :";
        $chr = "chr".<STDIN>;
        chomp($chr);
    }
    print $chr,"\n";
    my @tmp = grep { $_=~ /$chr\.data/ } @scorefiles;
    my $scorefile = $tmp[0];
    print "Opening $posfile ...\n";
    print "Searching in $scorefile\n";
    open SCORE, "$scorefile"or die;
    my $data = undef;
    $data = Mod::Scorefile -> new();
    while (my $line = <SCORE>){
        chomp $line;
        $data -> new_data($line);
    }
    close SCORE;
    print "Score set has made.\n";
    ##################################
    open POS, "$posfile"or die;
    while (my $line = <POS>){
        chomp $line;
        my $pos = Mod::Posdata->new();
        $pos = $pos -> set_position_data($line);
        my $start = $pos -> start();
        my $end = $pos -> end();
        my $score = $pos -> score();
        #print "$chr $start $end\n";
        my @up = ();
        my @down = ();
        my @seq = ();
        for(my $i = $start - $stream +75; $i <$start +75; $i++){
            my $scr = $data -> get_score_from_position($i);
            if($scr != -1){
                push @up,$scr;
            }
            else{
                push @up,-1;
            }
        }
        
        for(my $i = $end + 1 -75; $i <= $end + $stream -75; $i++){
            my $scr = $data -> get_score_from_position($i);
            if($scr != -1){
                push @down,$scr;
            }
            else{
                push @down,-1;
            }
        }
        for(my $i = $start; $i <= $end; $i++){
            my $scr = $data -> get_score_from_position($i);
            if($scr != -1){
                push @seq,$scr;
            }
            else{
                push @seq,0;
            }
        }
        my $cn = int(($end-$start)/2);
        my $mini = min(@seq);
        my $cent = $seq[$cn];
        my $mn = mean(@seq);
        print OUT "$chr $start $end $score $mini $cent $mn (@up/@down)\n";
        $count++;
    }
    close POS;
    $data = undef;
}
close OUT;
print "Number = $count\n";

