use Statictics::Lite qw(:all);
use Getopt::Long qw(:config posix_default no_ignore_case gnu_compat);
#オプション処理
my ($INPUT_POS ,$INPUT_WIG, $OUTPUT_NAME, $length, $inner, $help) = ("","","",0,0,0);
GetOptions('position|p=s' => \$INPUT_POS, 'wiggle|w=s' => \$INPUT_WIG, 'output|o=s' => \$OUTPUT_NAME, 'length|l=f' => \$length, 'inner|i=f' => \$inner, 'help|h=i' => \$help);

my $SP = 0;#position of file pointer
my $OPEN_FLUG = 1;#A flug , opening wig file
open OUT,"> $OUTPUT_NAME"or die;
open POS,"$INPUT_POS"or die;
open WIG,"$INPUT_WIG"or die;
while(my $line_pos = <POS>){
    chomp $line_pos;
    my @tmp_data = split /\s/,$line_pos;
    my ($ST, $EN, $LGT) = ($tmp_data[1],$tmp_data[2],$tmp_data[2]-$tmp_data[1]);
    my $last = $ST;#previous push point at wig file
    my @SCR = ();
    while(my $line_wig = <WIG>){
        chomp $line_wig;
        
        if($line_wig =~ /#/){ next; }#skip header

        my @wig_data = split /\s+/,$line_wig;
        my ($WS,$WE,$score) = ($wig_data[1],$wig_data[2],$wig_data[3]);
        $SP = tell WIG;#remind position at WIG
        
        ########A set P is [$ST,$EN] and a set W is [$WS,$WE]#################
        #P∩W≠φ or W⊂P　  
        if((($ST<=$WS)&&($WS<=$EN))||(($ST<=$WE)&&($WE<=$EN))){
            for(my $i = 0;$i < $WE - $last;$i++){#push score to @SCR
                push @SCR,$score;
            }
            $last = $WE;
        }
        
        elsif(($WS<$ST)&&($EN<$WE)){#P⊂W
            $SP = tell(WIG);
            for(my $i = 0;$i < $LGT;$i++){#push score to @SCR
                push @SCR,$score;
            }
            next;
        }
    
        elsif($EN<$WS){#over position => next
            next;
        }
        #######################################################################
    }
    if(length @SCR != 0){
        my $OVER_F = 0;
        my $mn = mean(@SCR);
        if($mn >= $boder){
            $OVER_F = 1;
        }
        print OUT "$line_pos $mn $OVER_F\n";
    }
    seek(WIG,$SP,0);#move to $SP
}
close POS;
close OUT;
close WIG;

