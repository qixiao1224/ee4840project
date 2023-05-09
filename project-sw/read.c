#include<stdlib.h>
#include<stdio.h>
#include <math.h>
#include <stdint.h>
#define img_path "data/imgs/img2.txt"

int main()
{
	FILE* ptr;
	char ch;
	ptr = fopen("../MATLAB_Golden_Model/data/imgs/img2.txt","r");
	if ( ptr == NULL)
	{
		printf("no such file\n");
		return 0;
	}
	float array[30][30];
	char line[512];
	for (int i = 0; i<30;i ++)
	{
		if (fgets(line,512,ptr)== NULL) return 0;	
		int n = sscanf(line, "%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f",&array[i][0],&array[i][1],&array[i][2],&array[i][3],&array[i][4],&array[i][5],&array[i][6],&array[i][7],&array[i][8],&array[i][9],&array[i][10],&array[i][11],&array[i][12],&array[i][13],&array[i][14],&array[i][15],&array[i][16],&array[i][17],&array[i][18],&array[i][19],&array[i][20],&array[i][21],&array[i][22],&array[i][23],&array[i][24],&array[i][25],&array[i][26],&array[i][27],&array[i][28],&array[i][29]);		
			
	}
	fclose(ptr);
	for (int i =0;i<15;i++)
	{
		for (int j =0; j<15; j++)
		{
		  uint32_t temp=0;
		  /*
		  uint32_t temp=0;
		  printf("%f    ",array[2*i][2*j]);
		  printf("%d\n",int(array[2*i][2*j]*16+0.5)<<24);
		  printf("temp = %d\n", temp);
		  printf("%f    ",array[2*i][2*j+1]);
		  printf("%d\n",int(array[2*i][2*j+1]*16+0.5)<<16);
		  printf("temp= %d\n", temp);
		  printf("%f    ",array[2*i+1][2*j]);
		  printf("%d\n",int(array[2*i+1][2*j]*16+0.5)<<8); 
		  printf("tmp= %d\n", temp);
		  printf("%f    ",array[2*i+1][2*j+1]);
		  */
		
		  temp = uint32_t(array[2*i][2*j]*16+0.5) * 0x1000000 + uint32_t(array[2*i][2*j+1]*16+0.5)*0x010000 +  uint32_t(array[2*i+1][2*j]*16+0.5) *0x100 + uint32_t(array[2*i+1][2*j+1]*16+0.5);
		  printf("temp = %d\n", temp);
		}
	}
	return 0;
}
