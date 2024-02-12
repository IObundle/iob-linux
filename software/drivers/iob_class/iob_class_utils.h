#ifndef H_IOB_CLASS_UTILS_H
#define H_IOB_CLASS_UTILS_H

#include <linux/cdev.h>

u32 iob_data_read_reg(void __iomem *, u32, u32);
void iob_data_write_reg(void __iomem *, u32, u32, u32);
int read_user_data(const char *, int, u32 *);

struct iob_data {
	dev_t devnum;
	struct cdev cdev;
	void __iomem *regbase;
	resource_size_t regsize;
	struct device *device;
    struct class *class;
};

#endif // H_IOB_CLASS_UTILS_H
