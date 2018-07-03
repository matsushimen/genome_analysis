use Statictics::Lite qw(:all);

my $SP = 0;#position of file pointer
my $OPEN_FLUG = 1;#A flug , opening wig file
open LOG,"> $LOG_NAME"or die;
open POS,"$INPUT_POS"or die;
while(my $line_pos = <POS>){
    chomp $line_pos;
    my @tmp_data = split /\s/,$line_pos;

    print LOG "$line_pos ";

    my ($ST, $EN, $LGT) = ($tmp_data[1],$tmp_data[2],$tmp_data[2]-$tmp_data[1]);

    my $last = $ST;#previous push point at wig file
    my @SCR = ();
    if($OPEN_FLUG){#Open wig file
        open WIG,"$INPUT_WIG"or die;
        $OPEN_FLUG = 0;
    }
    while(my $line_wig = <WIG>){
        chomp $line_wig;
        
        if($line_wig =~ /#/){ next; }#skip header

        my @wig_data = split /\s+/,$line_wig;
        my ($WS,$WE,$score) = ($wig_data[1],$wig_data[2],$wig_data[3]);
        $SP = tell WIG;
        #A set P is [$ST,$EN] and a set W is [$WS,$WE]
        #P∩W≠φ or W⊂P　  
        if((($ST<=$WS)&&($WS<=$EN))||(($ST<=$WE)&&($WE<=$EN))){
            for(my $i = 0;$i < $WE - $left_last;$i++){#push score to @SCR
                push @SCR,$score;
                print LOG "$score ";
            }
            $last = $WE;
        }
        
        elsif(($WS<$ST)&&($EN<$WE)){#PがWの部分集合のとき
            $SP = tell(WIG);
            for(my $i = 0;$i < $LGT;$i++){#push score to @SCR
                push @SCR,$score;
                print LOG "$score ";
            }
            $last = $EN;
            next;
        }
    
        elsif($EN<$WS){#over position => next
            if(length @SCR == 0){#no $score in @SCR
                for(my $i = 0;$i < $length;$i++){
                    print LOG "-1 ";
                }
            }
            elsif(length @SCR < $LGT){#length(@SCR) is shorter than $LGT
                for(my $i = 0;$i < $LE-$last;$i++){
                    print LOG "-1 ";
                }
            }
        }
    }
    
    print LOG "\n";
    seek(WIG,$SP,0);

}
close LOG;
close OUT;
close WIG;
open OUT,"> $OUTPUT_NAME"or die;
for(my $i = 0;$i < $length;$i++){
    if($left_n[$i] == 0){
        $left_n[$i] = 1;
    }
    $mean = $left[$i]/$left_n[$i];
    $variance = $left_v[$i]/$left_n[$i]-$mean*$mean;
    print OUT "$i $mean $variance $left_n[$i]\n"
}
for(my $i = 0;$i < $length;$i++){
    if($right_n[$i] == 0){
        $right_n[$i] = 1;
    }
    $mean = $right[$i]/$right_n[$i];
    $variance = $right_v[$i]/$right_n[$i]-$mean*$mean;
    my $num = $i + $length;
    print OUT "$num $mean $variance $right_n[$i]\n"
}
close OUT;
print "$test\n";
