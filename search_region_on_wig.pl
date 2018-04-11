use Statistics::Lite qw(:all);
use Getopt::Long qw(:config posix_default no_ignore_case gnu_compat);
#オプション処理
my ($INPUT ,$border_u,$border_t, $length_u, $length_t, $help) = ("",0,0,0,3000000000,0);
GetOptions('input|i=s' => \$INPUT, 'bottom|b=f' => \$border_u, 'top|t=f' => \$border_t, 'short|s=f' => \$length_u, 'long|l=f' => \$length_t, 'help|h=i' => \$help);

if($help == 1){
    my $message = <<'EOS';
[-i] [-input] : path of wiggle file
[-b] [-bottom] : bottom border of score
[-t] [-top] : top border of score
[-s] [-short] : minimum length
[-l] [-long] : maximum length
EOS
    print "$message\n";
    exit(0);
}
print "\n\n",$INPUT,"\n";
if($INPUT eq ""){
    print "Error : no file inputted.\n";
    my $message = <<'EOS';
[-i] [-input] : path of wiggle file
[-b] [-bottom] : bottom border of score
[-t] [-top] : top border of score
[-s] [-short] : minimum length
[-l] [-long] : maximum length
EOS
    print "hint : \n$message\n";
    exit(1);
}

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
                    if(($length_t>=$end-$start)&&($end-$start>=$length_u)){
                        print "$chr $start $end ",$end-$start," ",sum(@score)/($end-$start),"\n";
                    }
                    $start = -1;
                    $end = -1;
                }
            }
        }
        else{
            if($start != -1){
                if(($length_t>=$end-$start)&&($end-$start>=$length_u)){
                    print "$chr $start $end ",$end-$start," ",sum(@score)/($end-$start),"\n";
                }
                $start = -1;
            }
        }
    }
    else{
        if($start!=-1){
            if(($length_t>=$end-$start)&&($end-$start>=$length_u)){
                print "$chr $start $end ",$end-$start," ",sum(@score)/($end-$start),"\n";
            }
        }
    }
    
}
close IN;
