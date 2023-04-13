#ifndef _VGA_BALL_H
#define _VGA_BALL_H

#include <linux/ioctl.h>

typedef struct {
  int message;
} vga_ball_arg_t;

#define ACCU_MAGIC 'q'

/* ioctls and their arguments */
#define ACCU_WRITE_DATA_32  _IOW(ACCU_MAGIC, 0, vga_ball_arg_t *)
#define ACCU_WRITE_CONTROL_32 _IOW(ACCU_MAGIC, 1, vga_ball_arg_t *)

#endif
