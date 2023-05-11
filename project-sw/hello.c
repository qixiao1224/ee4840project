/*
 * Userspace program that communicates with the vga_ball device driver
 * through ioctls
 *
 * Stephen A. Edwards
 * Columbia University
 */

#include <stdio.h>
#include "vga_ball.h"
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>
#include <unistd.h>
#include <stdint.h>
#include <time.h>
#define img_path "data/imgs/img2.txt"
int vga_ball_fd;

int pow(int a, int b) {
	int temp = 1;
	int i = 0;
	for (i = 0; i < b; i++){
		temp = temp * a;
	}
}

// Set data register
void set_data(const int *message){
  vga_ball_arg_t vla;
  vla.message = *message;
  printf("send data: 0x%08x\n", *message);
  if (ioctl(vga_ball_fd, ACCU_WRITE_DATA_32, &vla)) {
      perror("ioctl(ACCU_WRITE_DATA) failed");
      return;
  }
}

/* Set control register */
void set_control(const int *message)
{
  vga_ball_arg_t vla;
  vla.message = *message;
  //printf("fd= %d",vga_ball_fd);
  if (ioctl(vga_ball_fd, ACCU_WRITE_CONTROL_32, &vla)) {
      perror("ioctl(ACCU_WRITE_CONTROL_32) failed");
      return;
  }
}

void read_ready( int *message)
{
  vga_ball_arg_t vla;
  
  if (ioctl(vga_ball_fd, ACCU_READ_READY_32, &vla)) {
      perror("ioctl(ACCU_READ_READY_32) failed");
      return;
  }
  *message =  vla.message;
  //printf(vla.message);
}
void read_answer( int *message)
{
  vga_ball_arg_t vla;
  
  if (ioctl(vga_ball_fd, ACCU_READ_ANSWER_32, &vla)) {
      perror("ioctl(ACCU_READ_ANSWER_32) failed");
      return;
  }
  *message = vla.message;
  printf(vla.message);
}
void send_conv_weight(char path[64],int *count, uint32_t *d)
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
		//printf("%s",line);
		uint32_t temp = 0;
		int i = 0;
		for(i =0;i<8;i++)
		{
			if(line[i]=='1') temp = temp + pow(2,(7-i));
		}
		//printf("temp = %d\n",temp);
		
			data = 0x00000000  | temp;
			//set_data(&data);
			d[*count]=data;
			*count+=1;
			//printf("data= %u\n",data);	
	}
	fclose(ptr);

}
void send_dense_weight(char path[64], int *count, uint32_t *d)
{
        FILE* ptr;
	char ch;
	ptr = fopen(path,"r");
	if ( ptr == NULL)
	{
		printf("no such file\n");
		return 0;
	}
	char line[16];
	int state = 0;
	uint32_t data=0;
	while(fgets(line,16,ptr)!= NULL)
	{	
		//printf("%s",line);
		uint32_t temp = 0;
		int i = 0;
		for(i =0;i<8;i++)
		{
			if(line[i]=='1') temp = temp + pow(2,(7-i));
		}
		//printf("temp = %d\n",temp);
		//printf("state= %d\n",state);
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
			state=0;
			data = data+temp;
			//set_data(&data);
			d[*count]= data;
			*count+=1;
			//printf("data= %u\n",data);
			data = 0;
		}
		
	}
	fclose(ptr);
	return 0;
}
void send_image(int *count,uint32_t *d)
{

	FILE* ptr;
	char ch;
	ptr = fopen("../MATLAB_Golden_Model/data/imgs/img0.txt","r");
	if ( ptr == NULL)
	{
		printf("no such file\n");
		return 0;
	}
	float array[30][30];
	char line[512];
	int i = 0;
	for (i = 0; i<30;i ++)
	{
		if (fgets(line,512,ptr)== NULL) return 0;	
		int n = sscanf(line, "%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f",&array[i][0],&array[i][1],&array[i][2],&array[i][3],&array[i][4],&array[i][5],&array[i][6],&array[i][7],&array[i][8],&array[i][9],&array[i][10],&array[i][11],&array[i][12],&array[i][13],&array[i][14],&array[i][15],&array[i][16],&array[i][17],&array[i][18],&array[i][19],&array[i][20],&array[i][21],&array[i][22],&array[i][23],&array[i][24],&array[i][25],&array[i][26],&array[i][27],&array[i][28],&array[i][29]);		
			
	}
	fclose(ptr);
	for (i =0;i<15;i++)
	{
		int j = 0;
		for (j =0; j<15; j++)
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
		
		  temp = (uint32_t)(array[2*i][2*j]*16+0.5) * 0x1000000 + (uint32_t)(array[2*i][2*j+1]*16+0.5)*0x010000 + (uint32_t)(array[2*i+1][2*j]*16+0.5) *0x100 + (uint32_t)(array[2*i+1][2*j+1]*16+0.5);
		  //set_data(&temp);
		  d[*count]=temp;
		  *count +=1;
		  printf("count+=1\n");
		}
	}
}
int main()
{
  vga_ball_arg_t vla;
  static const char filename[] = "/dev/vga_ball";

  printf("VGA ball Userspace program started\n");

  if ( (vga_ball_fd = open(filename, O_RDWR)) == -1) {
    fprintf(stderr, "could not open %s\n", filename);
    return -1;
  }
  printf("Before count \n");
  int *count =0;
  printf("Before initialize \n");
  
  printf("Between count and d \n");
  uint32_t d[30000];
  printf("initial state: \n");
  char path1[64] = "../data/weight_bias_conv2d1.txt";
  char path2[64] = "../data/weight_bias_conv2d2.txt";
  char path3[64] = "../data/weight_bias_conv2d3.txt";
  char path4[64] = "../data/weight_bias_dense1_z_r_group4.txt";
  /*
  i=15;
  int j =30;
  int flag1=1;
  int flag2 = 0;
  int fall =1;
  int right=1;
  unsigned char v;
  unsigned char h;
  unsigned char zero = 0;
  
  while(flag1==1 ) {
    
    if (flag2 == 0) {
        set_control(&i);
	flag2 = 1;
    } else {
	set_data(&j);
	flag2 = 0;
    }

    usleep(400000);
    if (fall==1)
      i++;
    else 
      i--;
    if (right==1)
      j++;
    else
      j--;
    if(j==78)
      right=0;
    if(j==2)
      right=1;
    if(i==29)
      fall=0;
    if(i==1)
      fall=1;
  }
  
  printf("VGA BALL Userspace program terminating\n");
  */
  printf("send control\n");
  int i =1;


  send_image(count,d);
  send_conv_weight(path1,count,d);
  send_conv_weight(path2,count,d);
  send_conv_weight(path3,count,d);
  send_dense_weight(path4,count,d);
  printf("count k = %d.\n",*count);
  clock_t send_start = clock();
  set_control(&i);
  int k =0; 
  for(k=0;k<*count;k++)
  {
     set_data(&d[k]);
  }
  clock_t send_end = clock();
  i=2;
  clock_t start=clock();
  set_control(&i);
  int ready = 0;
  int counter = 0;
  while(ready == 0) {
	read_ready(&ready);
	counter++;
} 
printf("ready: %d \n", ready);
printf("counter: %d \n", counter);
  int answer =0;
  read_answer(&answer);
  printf("send finished \n");
  clock_t end = clock();
  double time_used;
  time_used = (double)(end - start)/CLOCKS_PER_SEC;
  double sent_time;
  sent_time = (double)(send_end - send_start)/CLOCKS_PER_SEC;
  printf("The answer is %d.\n",answer);
  printf("Send data time is %f s.\n",sent_time); 
  printf("Excution time is %f s.\n",time_used); 
  return 0;
}
