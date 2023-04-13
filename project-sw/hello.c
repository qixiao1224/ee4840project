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

int vga_ball_fd;


// Set data register
void set_data(const int *message){
  vga_ball_arg_t vla;
  vla.message = *message;
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
  if (ioctl(vga_ball_fd, ACCU_WRITE_CONTROL_32, &vla)) {
      perror("ioctl(ACCU_WRITE_CONTROL_32) failed");
      return;
  }
}


int main()
{
  vga_ball_arg_t vla;
  int i;
  static const char filename[] = "/dev/vga_ball";

  static const vga_ball_color_t colors[] = {
    { 0xff, 0x00, 0x00 }, /* Red */
    { 0x00, 0xff, 0x00 }, /* Green */
    { 0x00, 0x00, 0xff }, /* Blue */
    { 0xff, 0xff, 0x00 }, /* Yellow */
    { 0x00, 0xff, 0xff }, /* Cyan */
    { 0xff, 0x00, 0xff }, /* Magenta */
    { 0x80, 0x80, 0x80 }, /* Gray */
    { 0x00, 0x00, 0x00 }, /* Black */
    { 0xff, 0xff, 0xff }  /* White */
  };

 
# define COLORS 9

  printf("VGA ball Userspace program started\n");

  if ( (vga_ball_fd = open(filename, O_RDWR)) == -1) {
    fprintf(stderr, "could not open %s\n", filename);
    return -1;
  }

  printf("initial state: ");
  print_background_color();
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
    
    vga_ball_pos_t pos ={v,h};
    //set_background_color(&colors[2],&pos);
    set_32(&colors[i % COLORS], &pos);
    if (flag2 == 0) {
        set_control(&i);
	flag2 = 1;
    } else {
	set_data(&j);
	flag2 = 0;
    }
    //set_ball_p(&colors[2],&poss[i%3]);
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
  return 0;
}
