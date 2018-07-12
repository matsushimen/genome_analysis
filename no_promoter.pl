use Statictics::Lite qw(:all);
use Getopt::Long qw(:config posix_default no_ignore_case gnu_compat);
#オプション処理
my ($INPUT_POS ,$INPUT_GENE, $OUTPUT_NAME, $length, $help) = ("","","",0,0);
GetOptions('position|p=s' => \$INPUT_POS, 'wiggle|w=s' => \$INPUT_WIG, 'output|o=s' => \$OUTPUT_NAME, 'length|l=f' => \$length, 'help|h=i' => \$help);

open POS,"$INPUT_POS"or die;
open GEN,"$INPUT_GENE"or die;
open OUT,">$OUTPUT_NAME"or die;
while(my $line_pos = <POS>){
    chomp $line_pos;
    my @tmp_data = split /\s/,$line_pos;
    print LOG "$line_pos ";
    my ($ST_POS, $END_POS) = ($tmp_data[1], $tmp_data[2]);
    my $PROM_FLAG = 0;
    while(my $gene_pos = <GEN>){
        chomp $gene_pos;
        my @gene_data = split /\s/,$gene_pos;
        ##########################
        ###変数に代入するブロック###
        ##########################
        my ($ST_GENE, $END_GENE);
        if($gene_pos[6] =~ /\+/){
            ($ST_GENE, $END_GENE) = ($gene_data[3], $gene_data[4]);
            ###距離の計算・振り分け###
            if((0<$ST_GENE-$ST_POS)&&($ST_GENE-$ST_POS<$length)){
                $PROM_FLAG = 1;
                next;
            }
        }
        else{
            ($ST_GENE, $END_GENE) = ($gene_data[4], $gene_data[3]);
            ###距離の計算・振り分け###
            if((0<$END_POS-$ST_GENE)&&($END_POS-$ST_GENE<$length)){
                $PROM_FLAG = 1;
                next;
            }
        }     
    }
    if(!$PROM_FLAG){
            print OUT "$line_pos\n";
        }   
}