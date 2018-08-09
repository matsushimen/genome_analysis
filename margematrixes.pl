my $F_FLAG = 0;
my $OUT = shift @ARGV;
my @inputs = @ARGV;
foreach my $INPUT(@inputs){
    open IN,"$INPUT"or die;
    my $n = 0;
    while(my $line = <IN>){
        chomp $line;
        my @data = split /\s/,$line;
        if($F_FLAG==0){#初回のみマトリックスの概形を作成
            $length = $#data+1;
            for(my $i = 0; $i < $length; $i++){
                for(my $j = 0; $j < $length; $j++){
                    $matrix_s[$i][$j] = 0.0;
                    $matrix_n[$i][$j] = 0;
                }
            }
            $F_FLAG = 1;
        }
        for(my $i = 0; $i < $#data+1; $i++){#dataをsplitしてscoreとnumberをmatrixに加えていく
            my ($score,$number) = split /:/,$data[$i];
            $matrix_s[$n][$i] += $score;
            $matrix_n[$n][$i] += $number;
        }
        $n++
    }
    close IN;
}
open OUT,"> $OUT"or die;
for(my $i = 0; $i < $length; $i++){
    for(my $j = 0; $j < $length; $j++){
        if($matrix_s[$i][$j] == 0){
            $matrix_s[$i][$j] = $matrix_s[$j][$i];
            $matrix_n[$i][$j] = $matrix_n[$j][$i];
        }
        my $element = $matrix_s[$i][$j]/$matrix_n[$i][$j];
        print OUT "$element ";
    }
    print OUT "\n";
}
close OUT;
