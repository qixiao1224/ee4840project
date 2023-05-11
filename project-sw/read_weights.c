#include<stdlib.h>
#include<stdio.h>
#include <math.h>
#include <stdint.h>
void send_weight(char path[32])
{
        FILE* ptr;
	char ch;
	ptr = fopen(path,"r");
	if ( ptr == NULL)
	{
		printf("no such file\n");
		return ;
	}
	char line[16];
	int state = 0;
	uint32_t data=0;
	while(fgets(line,16,ptr)!= NULL)
	{	
		printf("%s",line);
		uint32_t temp = 0;
		int i = 0;
		for(i =0;i<8;i++)
		{
			if(line[i]=='1') temp = temp + pow(2,(7-i));
		}
		printf("temp = %d\n",temp);
		//printf("state= %d\n",state);
		/*
		if(state==0)	
		{
			data =data+ temp * 0x1000000;
			state +=1;
			continue;
		}
		if(state==1)	
		{	
			data = data + temp *0x10000;
			state +=1;	
			continue;
		}
		if(state ==2)	
		{
			data = data + temp *0x100;
			state+=1;
			continue;
		}
		if(state ==3)
		{
		*/
		//state=0;
			data = 0x00000000  | temp;
			//set_data(&data);
			printf("data= %08x\n",data);
		//	data = 0;
		//}
		
	}
	fclose(ptr);

}
int main()
{
       char path[32] = "../data/weight_bias_conv2d1.txt";
	send_weight(path);
	return 0;
}

