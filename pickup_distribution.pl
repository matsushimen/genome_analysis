
use Getopt::Long qw(:config posix_default no_ignore_case gnu_compat);
#オプション処理
my ($INPUT_POS ,$INPUT_WIG, $OUTPUT_NAME, $LOG_NAME, $METHOD, $length, $inner, $help) = ("","","","vector.log",0,0,0,0);
GetOptions('position|p=s' => \$INPUT_POS, 'wiggle|w=s' => \$INPUT_WIG, 'output|o=s' => \$OUTPUT_NAME, 'log|g=s' => \$LOG_NAME, 'method|m=f' => \$METHOD, 'length|l=f' => \$length, 'inner|i=f' => \$inner, 'help|h=i' => \$help);

if($help == 1){
    my $message = <<'EOS';
[-p] [-position] : path of position file
[-w] [-wiggle] : path of wiggle file
[-o] [-output] : path and name of output file
[-m] [-method] : normalizing method (reference : README.md)
[-l] [-length] : normalizing length
[-i] [-inner] : inner length (reference : README.md)
EOS
    print "$message\n";
    exit(0);
}
print "\n",$INPUT_POS,"\n";

if($INPUT_POS eq ""){
    print "Error : no file inputted.\n";
    my $message = <<'EOS';
[-p] [-position] : path of position file
[-w] [-wiggle] : path of wiggle file
[-o] [-output] : path and name of output file
[-m] [-method] : normalizing method (reference : README.md)
[-l] [-length] : normalizing length
EOS
    print "hint : \n$message\n";
    exit(1);
}
my $test = 0;
my (@left,@right,@left_v,@right_v,@left_n,@right_n);

for(my $i = 0;$i < $length;$i++){
    $left[$i] = 0;
    $right[$i] = 0;
    $left_v[$i] = 0;
    $right_v[$i] = 0;
    $left_n[$i] = 0;
    $right_n[$i] = 0;
}
my $SP = 0;
my $OPEN_FLAG = 1;
my $LS,$LE,$RS,$RE;
open LOG,"> $LOG_NAME"or die;
open POS,"$INPUT_POS"or die;
while(my $line_pos = <POS>){
    chomp $line_pos;
    #print "serching at $line_pos\n";
    my @tmp_data = split /\s/,$line_pos;

    print LOG "$line_pos ";
    if($METHOD==0){
        ($LS, $LE, $RS, $RE) = ($tmp_data[2] - $length, $tmp_data[2], $tmp_data[1], $tmp_data[1] + $length);
    }
    elsif($METHOD==1){
        ($LS, $LE, $RS, $RE) = ($tmp_data[1] - $length, $tmp_data[1], $tmp_data[2], $tmp_data[2] + $length);
    }
    elsif($METHOD==2){
        ($LS, $LE, $RS, $RE) = ($tmp_data[1] + $inner - $length, $tmp_data[1] + $inner, $tmp_data[2] - $inner, $tmp_data[2] - $inner + $length);
    }
    if($OPEN_FLAG){
        open WIG,"$INPUT_WIG"or die;
        $OPEN_FLAG = 0;
    }
    my $left_pos = 0;#number of loaded score at left
    my $right_pos = 0;#number of loaded score at right
    
    my $left_last = 0;#previous loaded position at left
    my $right_last = 0;#previous loaded position at right
    while(my $line_wig = <WIG>){
        chomp $line_wig;
        
        if($line_wig =~ /#/){
            next;
        }#skip header
        my @wig_data = split /\s+/,$line_wig;
        my $WS = $wig_data[1];#wig : start
        my $WE = $wig_data[2];#wig : end
        my $score = $wig_data[3];#wig : score
    
        if((($LS<=$WS)&&($WS<=$LE))||(($LS<=$WE)&&($WE<=$LE))){#PとWの一部分が被っているもしくはWがPの部分集合の時
            if($left_pos == 0){#first time at left, remind the start position
                $SP = tell(WIG);
                $left_last = $LS;
            }
            if($left_last < $WS){#ギャップの穴埋め
                for(my $i = 0;$i < $WS - $left_last;$i++){
                    print LOG "-1 ";
                    #print "$line_wig\n";
                    $left_pos++;
                }
                $left_last = $WS;#move start position to previous position
            }
        
            for(my $i = 0;$i < $WE - $left_last;$i++){#push score to @left
                if($left_pos==$length){
                    last;
                }
                $left[$left_pos] += $score;
                print LOG "$score ";
                $left_v[$left_pos] += $score*$score;
                $left_n[$left_pos]++;
                $left_pos++;
            }
            
            $left_last = $WE;
        }
        
        elsif(($WS<$LS)&&($LE<$WE)){#PがWの部分集合のとき
            $SP = tell(WIG);
            for(my $i = 0;$i < $length;$i++){#push score to @left
                $left[$left_pos] += $score;
                print LOG "$score ";
                $left_v[$left_pos] += $score*$score;
                $left_n[$left_pos]++;
                $left_pos++;
            }
            $left_last = $LE;
        }
    
        elsif($LE<$WS){
            if($left_pos==0){
                #print "left $test\n";
                for(my $i = 0;$i < $length;$i++){
                    print LOG "-1 ";
                    $left_pos++;
                }
            }
            elsif($left_pos<$length){
                #print "$left_last\n";
                for(my $i = 0;$i < $LE-$left_last;$i++){
                    print LOG "-1 ";
                }
                $left_pos=$length;
            }
        }
        
        if((($RS<=$WS)&&($WS<=$RE))||(($RS<=$WE)&&($WE<=$RE))){
            if($right_pos == 0){
                $right_last = $RS;
            }
            if($WS > $right_last){#前回位置から現在位置までのギャップの穴埋め
                for(my $i = 0;$i < $WS - $right_last;$i++){
                    print LOG "-1 ";
                    $right_pos++;
                }
                $right_last = $WS;#スタート位置の移動
            }
            
            for(my $i = 0;$i < $WE - $right_last;$i++){
                if($right_pos == $length){
                    last;
                }
                $right[$right_pos] += $score;
                print LOG "$score ";
                $right_v[$right_pos] += $score*$score;
                $right_n[$right_pos]++;
                $right_pos++;
                
            }
            $right_last = $WE;
        }
        elsif(($WS<$RS)&&($RE<$WE)){#PがWの部分集合のとき
            
            for(my $i = 0;$i < $length;$i++){#push score to @left
                $right[$right_pos] += $score;
                print LOG "$score ";
                $right_v[$right_pos] += $score*$score;
                $right_n[$right_pos]++;
                $right_pos++;
            }
            $right_last = $RE;
            
        }
        if($RE<$WS){
            if($right_pos==0){
                #print "right $test\n";
                for(my $i = 0;$i < $length;$i++){
                    print LOG "-1 ";
                    $right_pos++;
                }
            }
            elsif($right_pos<$length){
                #print "$right_last\n";
                for(my $i = 0;$i < $RE-$right_last;$i++){
                    print LOG "-1 ";
                }
                $right_pos=$length;
            }
            last;
        }
        elsif(($RE<$WS)&&($right_pos==$length)){
            last;
        }
    
    }
    if(($right_pos<$length)&&($right_pos!=0)){
        #print "$right_last\n";
        for(my $i = 0;$i < $RE-$right_last;$i++){
            print LOG "-1 ";
        }
    }
    if(($right_pos == 0)&&($left_pos == 0)){
        for(my $i = 0;$i < $length*2 ;$i++){
            print LOG "-1 ";
        }
    }
    elsif(($right_pos==0)&&($left_pos!=0)){
        #print "right $test\n";
        for(my $i = 0;$i < $length-$left_pos;$i++){
            print LOG "-1 ";
        }
        for(my $i = 0;$i < $length;$i++){
            print LOG "-1 ";
        }
    }
    $right_pos=$length;

    $test++;
    print LOG "\n";
#print "\n";
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
