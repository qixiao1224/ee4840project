#include<stdlib.h>
#include<stdio.h>
#include <math.h>
#define img_path "data/imgs/img2.txt"
void f_to_bin(float a, char *c)
{	
	if (a>=0)	c[0]='0';	
	else 		c[0]='1';
	int a16 = int (a*16 + 0.5);
	a16 = a16+ 1; // i dont know why
	for(int i =0;i<7;i++)
	{
		float temp = pow(2,(6-i));
		if (a16>temp)	
		{
			c[i+1]='1';
			a16= a16- temp;
		}
		else	c[i+1]= '0';
	}
	c[8]='\0';
}
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
	char c[9];
	for (int i =0;i<15;i++)
	{
		for (int j =0; j<15; j++)
		{
			f_to_bin (array[2*i][2*j],c);
			printf("%s\n",c);
			f_to_bin (array[2*i][2*j+1],c);
			printf("%s\n",c);
			f_to_bin (array[2*i+1][2*j],c);
			printf("%s\n",c);
			f_to_bin (array[2*i+1][2*j+1],c);
			printf("%s\n",c);	
			//printf("%f %d %d\n",array[2*i][2*j],2*i,2*j);
			//printf("%f\n",array[2*i][2*j+1]);
			//printf("%f\n",array[2*i+1][2*j]);
			//printf("%f\n",array[2*i+1][2*j+1]);
		}
	}
	return 0;
}
