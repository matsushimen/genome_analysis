use Statistics::Lite qw(:all);
$posfile = shift @ARGV;
$hicfile = shift @ARGV;
$savefile = shift @ARGV;
$length = shift @ARGV;
for(my $i = 0;$i < 2*$length/1000;$i++){
    for(my $j = 0;$j < 2*$length/1000;$j++){
        $matrix[$i][$j] = 0;
        $count[$i][$j] = 0;
    }
}
print "matrix\n\n";
open POS,"$posfile"or die;
open HIC, "$hicfile"or die;
$i = 0;
my $PS = 0;
while (my $pos_line = <POS>){
    chomp $pos_line;
    my @pos_data = split " ",$pos_line;
    my $midpoint = ($pos_data[2]+$pos_data[1])/2;
    my $MP = int($midpoint/$length+1)*$length;
    my $SP = $MP - $length;
    my $EP = $MP + $length;
    my $fin_cnt = 0;
    #print "$SP-$EP\n";
    $PS = tell(HIC);
    while(my $hic_line = <HIC>){
        chomp $hic_line;
        my @hic_data = split /\s/, $hic_line;

        if(($SP<=$hic_data[0])&&($hic_data[0]<$EP)&&($SP<=$hic_data[1])&&($hic_data[1]<$EP)){
            my $pos_a = ($hic_data[0] - $SP)/($length/10);
            my $pos_b = ($hic_data[1] - $SP)/($length/10);
            #print "$hic_data[0]-$SP = $pos_a $hic_data[1] - $SP = $pos_b\n";
            $matrix[$pos_a][$pos_b] += $hic_data[2];
            $count[$pos_a][$pos_b] += 1;
            $fin_cnt++;
        }
        elsif(($hic_data[0]>=$EP)&&($hic_data[1]>=$EP)){
            last;
        }
        if($fin_cnt == (2*$length/1000)*(2*$length/1000)){
            last;
        }
        
    }
    seek(WIG,$PS,0);

}
close HIC;
close POS;
open OUT, ">$savefile";

for(my $i = 0;$i < 2*$length/1000;$i++){
    for(my $j = 0;$j < 2*$length/1000;$j++){
        if($count[$i][$j]==0){
            $count[$i][$j] = 1;
        }
        print OUT "$matrix[$i][$j]:$count[$i][$j] ";
    }
    print OUT "\n";
}
close OUT;
