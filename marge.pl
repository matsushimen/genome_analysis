my @m;
my @v;
my @n;
my $FLAG = 1;
my $i = 0;
my $OUTPUT = shift @ARGV;
foreach my $INPUT (@ARGV){
    open IN,"$INPUT";
    $i = 0;
    while(my $tmp = <IN>){
        my @data = split " ",$tmp;
        if($FLAG==1){
            $m[$data[0]] = $data[1]*$data[3];
            $v[$data[0]] = ($data[2]+$data[1]*$data[1])*$data[3];
            $n[$data[0]] = $data[3];
            $FLAG = 0;
            $i++;
        }
        else{
            $m[$data[0]] += $data[1]*$data[3];
            $v[$data[0]] += ($data[2]+$data[1]*$data[1])*$data[3];
            $n[$data[0]] += $data[3];
            $i++;
        }
    }
    close IN;
}
print "$i\n";
open OUT, "> $OUTPUT";
for(my $j = 0;$j < $i;$j++){
    if($n[$j]==0){
        $n[$j]=1;
    }
    my $mn = $m[$j]/$n[$j];
    my $va = $v[$j]/$n[$j]-$mn*$mn;
    print OUT "$j $mn $va $n[$j]\n";
}
close OUT;