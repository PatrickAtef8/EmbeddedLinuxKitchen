#define GPIO_BASE 0x3F200000
#define GPFSEL1   (GPIO_BASE + 0x04)
#define GPSET0    (GPIO_BASE + 0x1C)

void main() {
    volatile unsigned int *gpio_fsel1 = (unsigned int *)GPFSEL1;
    volatile unsigned int *gpio_set0 = (unsigned int *)GPSET0;

    // Set GPIO 17 as output
    *gpio_fsel1 |= (1 << 21);  

    // Set GPIO 17 high
    *gpio_set0 = (1 << 17);

    while (1);
}

