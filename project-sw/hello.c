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

/* Read and print the background color */
void print_background_color() {
  vga_ball_arg_t vla;
  
  if (ioctl(vga_ball_fd, VGA_BALL_READ_BACKGROUND, &vla)) {
      perror("ioctl(VGA_BALL_READ_BACKGROUND) failed");
      return;
  }
  printf("%02x %02x %02x\n",
	 vla.background.red, vla.background.green, vla.background.blue);
}

void print_pos() {
  vga_ball_arg_t vla;
  
  if (ioctl(vga_ball_fd, VGA_BALL_READ_POS, &vla)) {
      perror("ioctl(VGA_BALL_READ_POS) failed");
      return;
  }
  printf("%02x %02x\n",
	 vla.pos.v,vla.pos.h);
}

void set_ball_p(const vga_ball_color_t *c, const vga_ball_pos_t *p){
  vga_ball_arg_t vla;
  vla.background = *c;
  vla.pos  = *p;
  if (ioctl(vga_ball_fd, VGA_BALL_WRITE_POS, &vla)) {
      perror("ioctl(VGA_BALL_SET_BALL) failed");
      return;
  }
}

/* Set the background color */
void set_background_color(const vga_ball_color_t *c, const vga_ball_pos_t *p)
{
  vga_ball_arg_t vla;
  vla.pos = *p;
  vla.background = *c;
  if (ioctl(vga_ball_fd, VGA_BALL_WRITE_BACKGROUND, &vla)) {
      perror("ioctl(VGA_BALL_SET_BACKGROUND) failed");
      return;
  }
}

/* Set everything in 32 bits */
void set_32(const vga_ball_color_t *c, const vga_ball_pos_t *p)
{
  vga_ball_arg_t vla;
  vla.pos = *p;
  vla.background = *c;
  if (ioctl(vga_ball_fd, VGA_BALL_WRITE_32, &vla)) {
      perror("ioctl(VGA_BALL_SET_BACKGROUND) failed");
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

   static const vga_ball_pos_t poss  [] = {
     {0x00, 0x01},
     {0x00,0x02},
     {0x00, 0x03}
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
  int fall =1;
  int right=1;
  unsigned char v;
  unsigned char h;
  vga_ball_pos_t pos ={v,h};
  unsigned char zero = 0;
  while(flag1==1 ) {
    // set_background_color(&colors[i % COLORS ]);
    v = (unsigned char)i;
    h = (unsigned char)j;
    vga_ball_pos_t pos ={v,h};
    //set_background_color(&colors[2],&pos);
    set_32(&colors[i % COLORS], &pos);
    //set_ball_p(&colors[2],&poss[i%3]);
    print_background_color();
    print_pos();
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
