use Statistics::Lite qw(:all);
my $INPUT_POS = $ARGV[0];
my $RIGID = $ARGV[1];
my $OUT = $ARGV[2];
open POS,"$INPUT_POS"or die;
open RIG,"$RIGID"or die;
open OUT,"> $OUT"or die;
my $tel_rig = tell(RIG);#位置の移動
while(my $pos_line = <POS>){
    chomp($pos_line);
    my @pos_data = split(/\s/,$pos_line);
    my $start_pos = $pos_data[1];
    my $end_pos = $pos_data[2];
    my @score = ();
    my $flag = 0;

    seek(RIG,$tel_rig,0);

    while(my $rig_line = <RIG>){
        chomp($rig_line);
        my @rig_data = split(/\s/,$rig_line);
        if(($start_pos <= $rig_data[0])&&($rig_data[0] < $end_pos)){
            if($flag == 0){
                $tel_rig = tell(RIG);#場所の記憶
                $flag = 1;
            }
            push(@score,$rig_data[1]);#硬さスコアの平均の計算
        }
        elsif($flag==0){
            print("hogehoge\n");
            next;
        }
        else{
            print("hoge\n");
            last;
        }
    }
    if($flag == 1){
        my $mn = mean(@score);
        print OUT "$pos_line $mn\n";
    }
}
close(POS);
close(RIG);
close(OUT);