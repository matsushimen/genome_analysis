my @data;
while(my $line = <BED>){
    my @bed = split " ",$line;
    my $bs = $bed[1];
    my $be = $bed[2];
    my $us = $bs - $st;
    my $ue = $bs;
    my $ds = $be;
    my $de = $be + $st;
    my $u_flug = 0;
    while(my $wig = <WIG>){
        if($wig =~ /fixed/){
            
            my @wig = split $wig;
            my $ws = $wig[1];
            my $we = $wig[2];
            if(($u_flug==0)&&($ws<=$ue)){
                
            }
            if(($ws<=$us)&&($us<=$we)){
                if(($ws<=$ue)&&($ue<=$we)){
                    for(my $i =0; $i<$st, $i++){#listにぶちこみ
                        push @{$data->[$i]},$wig[3];
                    }
                }
                else{
                    for(my $i =0; $i<$$we-$us, $i++){#listにぶちこみ
                        push @{$data->[$i]},$wig[3];
                    }
                }
            }
        }
    }
}