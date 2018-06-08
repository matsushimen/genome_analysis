
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
print "\n\n",$INPUT,"\n";
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

open POS,"$INPUT_POS"or die;
while(my $line_pos = <POS>){
    my @tmp_data = split $line_pos," ";
    if($method==0){
        my $LS = $tmp_data[2] - $length;
        my $LE = $tmp_data[2];
        my $RS = $tmp_data[1];
        my $RE = $tmp_data[1] + $length;
    }
    elsif($method==1){
        my $LS = $tmp_data[1] - $length;
        my $LE = $tmp_data[1];
        my $RS = $tmp_data[2];
        my $RE = $tmp_data[2] + $length;
    }
    elsif($method==2){
        my $LS = $tmp_data[1] + $inner - $length;
        my $LE = $tmp_data[1] + $inner;
        my $RS = $tmp_data[2] - $inner;
        my $RE = $tmp_data[1] - $inner + $length;
    }
    
}
