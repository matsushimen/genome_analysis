use Statistics::Lite qw(:all);
use Getopt::Long qw(:config posix_default no_ignore_case gnu_compat);
my ($INPUT ,$border_u,$border_t, $length_u, $length_t) = (None,0,0,0,3000000000);
GetOptions('input|i=s' => \$INPUT, 'low|l=f' => \$border_u, 'high|h=f' => \$border_t, 'short|s=f' => \$length_u, 'big|b=f' => \$length_t);
print "$border_u\n";
open IN,"$INPUT"or die;
$start = -1;
$end = -1;
@score = ();
while(my $line = <IN>){
    chomp $line;
    
    if($line !~ /#/){
        @data = split /\s/,$line;
        if(($border_u<=$data[3])&&($data[3]<=$border_t)){
            if($start==-1){#スタート位置を覚えていなければ現在位置の記憶と終わりの記憶
                $start = $data[1];
                $end = $data[2];
                $chr = $data[0];
                @score = ();
                push @score,$data[3];
            }
            else{
                if($end >= $data[1]){#一つ前のデータの終わりから繋がっているか
                    $end = $data[2];
                    push @score,$data[3];
                }
                else{
                    if($end-$start>=$length_u){
                        print "$chr $start $end ",$end-$start," ",sum(@score)/($end-$start),"\n";
                    }
                    $start = -1;
                    $end = -1;
                }
            }
        }
        else{
            if($start != -1){
                if($end-$start>=$length_u){
                    print "$chr $start $end ",$end-$start," ",sum(@score)/($end-$start),"\n";
                }
                $start = -1;
            }
        }
    }
    else{
        if($start!=-1){
            if($end-$start>$length_u){
                print "$chr $start $end ",$end-$start," ",sum(@score)/($end-$start),"\n";
            }
        }
    }
    
}
close IN;
