/*
 * LEDs driver for PCEngines apu
 *
 * Copyright (C) 2013 Christian Herzog <daduke@daduke.org>, based on
 * Petr Leibman's leds-alix
 * Based on leds-wrap.c
 * Hardware info taken from http://www.dpie.com/manuals/miniboards/kontron/KTD-S0043-0_KTA55_SoftwareGuide.pdf
 *
 * 2014-12-8: Mark Schank
 *	- Added GPIO support for the APU push-button switch.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 */
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/init.h>
#include <linux/platform_device.h>
#include <linux/gpio.h>
#include <linux/err.h>
#include <asm/io.h>

#define DRVNAME		"apu-btn-gpio"

static struct platform_device *pdev;

#define BUTTONADDR	(0xFED801BB)
unsigned int *b1;

static int gpio_apu_button_direction_in(struct gpio_chip *gc, unsigned  gpio_num)
{
	u8 curr_state;

	curr_state = ioread8(b1);
	iowrite8(curr_state | (1 << 5), b1);

	return 0;
}

static int gpio_apu_button_get(struct gpio_chip *gc, unsigned gpio_num)
{
	u8 curr_state;

	curr_state = ioread8(b1);

	return((curr_state & (1 << 7)) == (1 << 7));
}

static struct gpio_chip apu_gpio_button = {
	.label			= "apu_button",
	.owner			= THIS_MODULE,
	.get			= gpio_apu_button_get,
	.direction_input	= gpio_apu_button_direction_in,
	.base			= 187,
	.ngpio			= 1,
};

static int apu_gpio_probe(struct platform_device *pdev)
{
	int ret;

	ret = gpiochip_add(&apu_gpio_button);
	if(ret == 0){
		if(!gpio_request_one(187, GPIOF_IN, "Button")){
			gpio_export(187, 0);
		}
	}
	return ret;
}

static int apu_gpio_remove(struct platform_device *pdev)
{
	gpiochip_remove(&apu_gpio_button);

	return 0;
}

static struct platform_driver apu_gpio_driver = {
	.probe		= apu_gpio_probe,
	.remove		= apu_gpio_remove,
	.driver		= {
	.name		= DRVNAME,
	.owner		= THIS_MODULE,
	},
};

static int __init apu_gpio_init(void)
{
	int ret;

	b1 = ioremap(BUTTONADDR, 1);
	
	ret = platform_driver_register(&apu_gpio_driver);
	if (ret < 0)
		goto out;

	pdev = platform_device_register_simple(DRVNAME, -1, NULL, 0);
	if (IS_ERR(pdev)) {
		ret = PTR_ERR(pdev);
		platform_driver_unregister(&apu_gpio_driver);
		goto out;
	}
out:
	return ret;
}

static void __exit apu_gpio_exit(void)
{
	platform_device_unregister(pdev);
	platform_driver_unregister(&apu_gpio_driver);
}

module_init(apu_gpio_init);
module_exit(apu_gpio_exit);

MODULE_AUTHOR("Christian Herzog");
MODULE_DESCRIPTION("PCEngines apu LED driver");
MODULE_LICENSE("GPL");
