//
//
//  
//
//
//
//プログラム　chrM positionファイル名 保存ファイル名 前　後ろ

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <sys/stat.h>
int main(int argc,char **argv)
{
    int before, after;
    unsigned int start, end, length;
    double score;
    char chrname[64];
    char posfile[256], chrfile[256], savefile[256];
    char BEF[64], AFT[64];
    char chr[64];
    
    FILE *fp;
    FILE *gp;
    FILE *hp;

    sprintf(chrfile, "%s", argv[1]);
    sprintf(posfile, "%s", argv[2]);
    sprintf(savefile, "%s", argv[3]);

    if((fp = fopen(chrfile, "r"))==NULL){
        printf("error : can not open %s to read.",chrfile);
        exit(1);
    }
    //位置ファイルの読みこみ
    if((gp = fopen(posfile, "r"))==NULL){
        printf("error : can not open %s to read.",posfile);
        exit(1);
    }
    printf("position file is %s.\n",posfile);
    //保存ファイルの読み込み
    if((hp = fopen(savefile, "wt"))==NULL){
        printf("error : can not open %s to read.",savefile);
        exit(1);
    }
    printf("savefile is %s.\n",savefile);
    
    //染色体データ作成
    char *chromosome;
    char buff;
    unsigned int chrlength=0;
    printf("reading chromosome file...");
    
    //データ数カウント
    while ((fscanf(fp, "%c",&buff))==1) {
        chrlength++;
    }

    rewind(fp);
    chromosome = (char *)malloc((chrlength + 1) * sizeof(char));
    unsigned int i;
    
    fscanf(fp,"%s",chromosome);

    fclose(fp);
    printf("OK. chromosome's length is %u.\n",chrlength);
    
    //検索
    while (fscanf(gp, "%s %u %u %u %lf\n", chrname, &start, &end, &length, &score)==5){
        fprintf(hp, "> %s_%u_%u_%u\n",chrname, start, end, length);//染色体　始点　終点　対象配列の長さ　スコア
        for(i=start ;i<end;i++){//塩基配列
            fprintf(hp, "%c",chromosome[i]);
        }
        fprintf(hp, "\n");
    }
    printf("done\n");
    fclose(gp);
    fclose(hp);
    free(chromosome);
}
