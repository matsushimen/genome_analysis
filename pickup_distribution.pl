
use Getopt::Long qw(:config posix_default no_ignore_case gnu_compat);
#オプション処理
my ($INPUT_POS ,$INPUT_WIG, $OUTPUT_NAME, $LOG_NAME, $METHOD, $length, $inner, $help) = ("","","","vector.log",0,0,0,0);
GetOptions('position|p=s' => \$INPUT_POS, 'wiggle|w=s' => \$INPUT_WIG, 'output|o=s' => \$OUTPUT_NAME, 'log|g=s' => \$LOG_NAME 'method|m=f' => \$METHOD, 'length|l=f' => \$length, 'inner|i=f' => \$inner, 'help|h=i' => \$help);

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

for(my $i = 0;$i < $length;$i++){
    $left[$i] = 0;
    $right[$i] = 0;
    $left_v[$i] = 0;
    $right_v[$i] = 0;
    $left_n[$i] = 0;
    $right_n[$i] = 0;
}
my $SP = 0;
my $OPEN_FLUG = 1;
open LOG,"> $LOG_NAME"or die;
open POS,"$INPUT_POS"or die;
while(my $line_pos = <POS>){
    chomp $line_pos;
    #print "serching at $line_pos\n";
    my @tmp_data = split /\s/,$line_pos;
    my $LS,$LE,$RS,$RE;
    if($METHOD==0){
        $LS = $tmp_data[2] - $length;
        $LE = $tmp_data[2];
        $RS = $tmp_data[1];
        $RE = $tmp_data[1] + $length;
    }
    elsif($METHOD==1){
        $LS = $tmp_data[1] - $length;
        $LE = $tmp_data[1];
        $RS = $tmp_data[2];
        $RE = $tmp_data[2] + $length;
    }
    elsif($METHOD==2){
        $LS = $tmp_data[1] + $inner - $length;
        $LE = $tmp_data[1] + $inner;
        $RS = $tmp_data[2] - $inner;
        $RE = $tmp_data[2] - $inner + $length;
    }
    if($OPEN_FLUG){
        open WIG,"$INPUT_WIG"or die;
        $OPEN_FLUG = 0;
    }
    my $left_pos = 0;#leftに入っているスコアの数
    my $right_pos = 0;#rightに入っているスコアの数
    
    my $left_last = 0;
    my $right_last = 0;
    while(my $line_wig = <WIG>){
        chomp $line_wig;
        if($line_wig =~ //){
            next;
        }#skip header
        my @wig_data = split /\s/,$line_wig;
        my $WS = $wig_data[1];#wig : start
        my $WE = $wig_data[2];#wig : end
        my $score = $wig_data[3];#wig : score
        my @left_tmp;#ベクトル書き出し用
        my @right_tmp;#ベクトル書き出し用
        if((($LS<=$WS)&&($WS<=$LE))||(($LS<=$WE)&&($WE<=$LE))){
            if($left_pos == 0){#first time at left, remind the position of start
                $SP = tell(WIG);
                $left_last = $LS;
            }
            if($WS > $left_last){#ギャップの穴埋め
                for(my $i = 0;$i < $WS - $left_last;$i++){
                    $left_tmp[$left_pos] = -1;
                    $left_pos++;
                }
                $left_last = $WS;#スタート位置の移動
            }

            for(my $i = 0;$i < $WE - $left_last;$i++){#push score to @left
                if($left_pos==$length){
                    last;
                }
                $left[$left_pos] += $score;
                $left_tmp[$left_pos] = $score;
                $left_v[$left_pos] += $score*$score;
                $left_n[$left_pos]++;
                $left_pos++;
            }
            $left_last = $WE;
        }
        if((($RS<=$WS)&&($WS<=$RE))||(($RS<=$WE)&&($WE<=$RE))){
            if($right_pos == 0){
                $right_last = $RS;
            }
            if($WS > $right_last){#前回位置から現在位置までのギャップの穴埋め
                for(my $i = 0;$i < $WS - $right_last;$i++){
                    $right_tmp[$right_pos] = -1;
                    $right_pos++;
                }
                $right_last = $WS#スタート位置の移動
            }
            
            for(my $i = 0;$i < $WE - $right_last;$i++){
                if($right_pos == $length){
                    last;
                }
                $right[$right_pos] += $score;
                $right_tmp = $score;
                $right_v[$right_pos] += $score*$score;
                $right_n[$right_pos]++;
                $right_pos++;
                
            }
            $right_last = $WE;
        }
        elsif($RE<$WE){
            last;
        }
    }
    for(my $i = 0;$i < $length;$i++){#ベクトル書き出し
        print LOG "$left_tmp[$i]";
    }
    for(my $i = 0;$i < $length;$i++){
        print LOG "$right_tmp[$i]";
    }
    print LOG,"\n";
    seek(WIG,$SP,0);
}
close OUT;
close WIG;
open OUT,"> $OUTPUT_NAME";
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
