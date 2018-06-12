
use Getopt::Long qw(:config posix_default no_ignore_case gnu_compat);
#オプション処理
my ($INPUT_POS ,$INPUT_WIG, $OUTPUT_NAME, $METHOD, $length, $inner, $help) = ("","","",1000,0,0,0);
GetOptions('position|p=s' => \$INPUT_POS, 'wiggle|w=s' => \$INPUT_WIG, 'output|o=s' => \$OUTPUT_NAME, 'method|m=f' => \$METHOD, 'length|l=f' => \$length, 'inner|i=f' => \$inner, 'help|h=i' => \$help);

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
print "\n\n",$INPUT_POS,"\n";
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

my $OPEN_FLUG = 1;
open POS,"$INPUT_POS"or die;
while(my $line_pos = <POS>){
    chomp $line_pos;
    print "serching at $line_pos\n";
    my @tmp_data = split $line_pos," ";
    if($METHOD==0){
        my $LS = $tmp_data[2] - $length;
        my $LE = $tmp_data[2];
        my $RS = $tmp_data[1];
        my $RE = $tmp_data[1] + $length;
    }
    elsif($METHOD==1){
        my $LS = $tmp_data[1] - $length;
        my $LE = $tmp_data[1];
        my $RS = $tmp_data[2];
        my $RE = $tmp_data[2] + $length;
    }
    elsif($METHOD==2){
        my $LS = $tmp_data[1] + $inner - $length;
        my $LE = $tmp_data[1] + $inner;
        my $RS = $tmp_data[2] - $inner;
        my $RE = $tmp_data[1] - $inner + $length;
    }
    if($OPEN_FLUG){
        open WIG,"$INPUT_WIG"or die;
        $OPEN_FLUG = 0;
    }
    my $left_pos = 0;#leftに入っているスコアの数
    my $right_pos = 0;#rightに入っているスコアの数
    
    while(my $line_wig = <WIG>){
        chomp $line_wig;
        if($line_wig =~ //){next};#skip header
        my @wig_data = split $line_wig;
        my $WS = $wig_data[1];#wig : start
        my $WE = $wig_data[2];#wig : end
        my $score = $wig_data[3];#wig : score
        
        if((($LS<$WS)&&($WS<$LE))||(($LS<$WE)&&($WE<$LE))){
            if($left_pos ==0){#first time at left, remind the position of start
                $SP = tell(WIG);
                print "set sp\n"
            }
            for(my $i = 0;$i < $WE-$WS;$i++){#push score to @left
                if($left_pos==$length){
                    print "hogehoge\n";
                    last;
                }
                $left[$left_pos] += $score;
                $left_v[$left_pos] += $score*$score;
                $left_n[$left_pos]++;
                $left_pos++;
                
            }
        }
        if((($RS<$WS)&&($WS<$RE))||(($RS<$WE)&&($WE<$RE))){
            for(my $i = 0;$i < $WE-$WS;$i++){
                if($right_pos == $length){
                    print("hoge\n");
                    last;
                    
                }
                $right[$right_pos] += $score;
                $rignt_v[$right_pos] += $score*$score;
                $right_n[$right_pos]++;
                $right_pos++;
            }
        }
    }
    seek(WIG,0,$SP);
}
close OUT;
close WIG;
open OUT,"> $OUTPUT_NAME";
for(my $i = 0;$i < $length;$i++){
    if($left_n[$i] == 0){
        $left_n[$i] = 1;
    }
    $mean = $left[$i]/$left_n[$i];
    $variant = ($left_v[$i]-$mean*$mean)/$left_n[$i];
    print OUT "$i $mean $variant\n"
}
for(my $i = 0;$i < $length;$i++){
    if($right_n[$i] == 0){
        $right_n[$i] = 1;
    }
    $mean = $right[$i]/$right_n[$i];
    $variant = ($right_v[$i]-$mean*$mean)/$right_n[$i];
    my $num = $i + $lengh;
    print OUT "$num $mean $variant\n"
}
close OUT;
