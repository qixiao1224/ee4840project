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
int color_idx=0;
/* Read and print the background color */
void print_background_color() {
  vga_ball_arg_t vla;
  
  if (ioctl(vga_ball_fd, VGA_BALL_READ_BACKGROUND, &vla)) {
      perror("ioctl(VGA_BALL_READ_BACKGROUND) failed");
      return;
  }
  printf("%02x %02x %02x %02x%02x %02x%02x\n",
	 vla.background.red, vla.background.green, vla.background.blue,
 	 vla.position.col15_8, vla.position.col7_0,vla.position.row15_8, vla.position.row7_0);
}

/* Set the background color */
void set_background_color(const vga_ball_color_t *c,const vga_ball_posi_t *p)
{
  vga_ball_arg_t vla;
  vla.background = *c;
  vla.position = *p;
  if (ioctl(vga_ball_fd, VGA_BALL_WRITE_BACKGROUND, &vla)) {
      perror("ioctl(VGA_BALL_SET_BACKGROUND) failed");
      return;
  }
}

void change_position(vga_ball_posi_t *);

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
    { 0xaa, 0xff, 0xff }  /* White */
  };

  static vga_ball_posi_t positions[] = {
    { 0x01,0x00, 0x00,0x10}
  };

# define COLORS 9

  printf("VGA ball Userspace program started\n");

  if ( (vga_ball_fd = open(filename, O_RDWR)) == -1) {
    fprintf(stderr, "could not open %s\n", filename);
    return -1;
  }

  printf("initial state: ");
  print_background_color();

//  for (i = 0 ; i < 5000 ; i++) {
while (1){
    set_background_color(&colors[color_idx%COLORS], &positions[0]);
    print_background_color();
    change_position(&positions[0]);
    usleep(17000);
  }
  
  printf("VGA BALL Userspace program terminating\n");
  return 0;
}

void change_position(vga_ball_posi_t *position){
  static int deltax=3;
  static int deltay=1;

  int temp_x;         //used only for condition, not for assignment
  int temp_y;

  int next_col;       //used only for assignment, not for condition
  int next_row;

  //display size 640*480
  //640 = 213*3+1
  //480 = 160*3
  //640-32 = 608 = 202*3 + 2
  //480-32 = 448 = 149*3 + 1

  temp_x = position->col15_8;
  temp_x = (temp_x<<8) + (position->col7_0) +  deltax; // next x position

  temp_y = position->row15_8;
  temp_y = (temp_y<<8) + (position->row7_0) +  deltay;

  next_col = position->col15_8;
  next_col = (next_col<<8) + (position->col7_0);

  next_row = position->row15_8;
  next_row = (next_row<<8) + (position->row7_0);


  if (temp_x>0 && temp_x<607 && temp_y>0 && temp_y<447){
    next_col = next_col+deltax;
    next_row = next_row+deltay;

    position->col7_0  = next_col;         //assign next_col[7:0]
    position->col15_8 = (next_col>>8);     //assign next_col[15:8]
    position->row7_0  = next_row;         //assign next_col[7:0]
    position->row15_8 = (next_row>>8);     //assign next_col[15:8]
  }

  else {
    if (temp_x<=0){
      position->col15_8 = 0;
      position->col7_0 = 0;
      deltax = -deltax;
      color_idx ++;
    }

    if (temp_x>=607){
      position->col15_8 = 0x02;
      position->col7_0 = 0x5F;
      deltax = -deltax;
      color_idx ++;
    }

    if (temp_y<=0){
      position->row15_8 = 0;
      position->row7_0 = 0;
      deltay = -deltay;
      color_idx ++;
    }

    if (temp_y>=447){
      position->row15_8 = 0x01;
      position->row7_0 = 0xBF;
      deltay = -deltay;
      color_idx ++;
    }
  }
  printf("dx: %02x dy: %02x", deltax,deltay);

}
