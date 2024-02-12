/* iob_class_utils.c: common utility functions for iob_class drivers */

#include <linux/io.h>
#include <linux/uaccess.h>

#include "iob_class_utils.h"

static int char_to_u32(char *, u32, u32 *);

/* TODO: add error checking */
u32 iob_data_read_reg(void __iomem *regbase, u32 addr, u32 nbits) {
	u32 value = 0;
	switch (nbits) {
	case 8:
		value = (u32) ioread8(regbase + addr);
		break;
	case 16:
		value = (u32) ioread16(regbase + addr);
		break;
	default:
		value = ioread32(regbase + addr);
		break;
	}
	return value;
}

/* TODO: add error checking */
void iob_data_write_reg(void __iomem *regbase, u32 value, u32 addr, u32 nbits) {
	switch (nbits) {
	case 8:
		iowrite8(value, regbase + addr);
		break;
	case 16:
		iowrite16(value, regbase + addr);
		break;
	default:
		iowrite32(value, regbase + addr);
		break;
	}
}

/* read 1-4 nbytes from char array into u32 value
 * NOTE: assumes bytes[] at least nbytes long
 * NOTE2: assumes little-endian byte order
 * return:
 *      0 on success
 *      -EINVAL on invalid nbytes
 * */
static int char_to_u32(char *bytes, u32 nbytes, u32 *value) {
    if (nbytes > 4){
        return -EINVAL;
    }

	*value = 0; /* reset value */
	while (nbytes--) {
		*value = (*value << 8) | ((u32)bytes[nbytes]);
	}
	return 0;
}

/* read `size` bytes from user `buf` into `value`
 * return:
 *      0 on success
 *      -EINVAL on invalid size or char_to_u32 error
 *      -EFAULT on copy error
 */
int read_user_data(const char *buf, int size, u32 *value) {
	char kbuf[4] = {0}; // max 32 bit value
    if ((size < 1) || (size > 4)){
        return -EINVAL;
    }
	if (copy_from_user(&kbuf, buf, size))
		return -EFAULT;
	return char_to_u32(kbuf, size, value);
}
