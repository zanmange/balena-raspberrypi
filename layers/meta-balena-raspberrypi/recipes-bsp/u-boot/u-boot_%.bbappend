inherit resin-u-boot
UBOOT_KCONFIG_SUPPORT = "1"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

# Remove patch inherited from meta-raspberrypi already upstream in v2018.07
SRC_URI_remove = " file://0002-rpi_0_w-Add-configs-consistent-with-RpI3.patch "

# Remove patch inherited from meta-resin. This needs to be rebased for v2018.07
SRC_URI_remove = " file://resin-specific-env-integration-kconfig.patch "

RPI_PATCHES = " \
    file://rpi-Use-CONFIG_OF_BOARD-instead-of-CONFIG_EMBED.patch \
    file://increase-usb-interface-nr.patch \
    file://rpi.h-Remove-usb-start-from-CONFIG_PREBOOT.patch \
    file://0002-raspberrypi-Disable-simple-framebuffer-support.patch \
    file://0001-avoid-block-uart-write.patch \
"

SRC_URI += " \
    file://0001-Integrate-machine-independent-resin-environment-conf.patch \
    ${RPI_PATCHES} \
"

# Below patches come from upstream u-boot v2020.04, they fix the
# "Error: allocating new dir entry" issue and may be removed once
# updated u-boot provided by BSP will include them:
BACKPORTED_FAT_FS_PATCHES = " \
   file://0001-fs-fat-write-to-non-cluster-aligned-root-directory.patch \
   file://0001-fs-fat-flush-a-directory-cluster-properly.patch \
   file://0001-fs-fat-allocate-a-new-cluster-for-root-directory-of-.patch \
"

SRC_URI += "${BACKPORTED_FAT_FS_PATCHES}"

# Disable flasher check since it starts usb unnecessarily
# and we don't generate flasher images for any of the RPIs.
SRC_URI_append = " \
    file://0001-rpi-Disable-image-flasher-check.patch \
"

RESIN_UBOOT_DEVICE_TYPES_append = " usb"

# Patches for rpi4 usb support are not part of upstream u-boot v2020.07,
# but are merged in master branch
SRCREV_raspberrypi4-64 = "49cf75101db58ad3540d8de6749cf0c1d780dc76"

# Patches that apply on poky u-boot and are not present
# in this list are either merged in upstream master,
# or are re-based below.
SRC_URI_remove_raspberrypi4-64 = "${RPI_PATCHES}"
SRC_URI_append_raspberrypi4-64 = " \
    file://rpi4-Increase-to-16-the-number-of-USB-interfaces.patch \
    file://rpi4-Disable-simple-framebuffer-support.patch \
    file://rpi4-avoid-block-uart-write.patch \
"

# These are present in u-boot v2020.07
SRC_URI_remove_raspberrypi4-64 = "${BACKPORTED_FAT_FS_PATCHES}"

# These are added by meta-raspberrypi on top of poky uboot (pi0 - pi3)
SRC_URI_remove_raspberrypi4-64 = "${UBOOT_RPI4_SUPPORT_PATCHES}"

# config_defaults.h is removed starting usptream v2020.06
SRC_URI_append_raspberrypi4-64 = " \
    file://Revert-remove-include-config_defaults.h.patch \
    file://rpi4-include-configs-Use-config-defaults.patch \
    file://0001-rpi-Add-rpi-400-model-to-known-types.patch \
    file://0001-pi-Add-identifier-for-the-new-CM4.patch \
    file://0001-usb-xhci-Add-virt_to_phys-to-support-mapped-platform.patch \
    file://0002-pci-pcie-brcmstb-Fix-inbound-window-configurations.patch \
    file://0003-dm-Introduce-xxx_get_dma_range.patch \
    file://0004-dm-Introduce-DMA-constraints-into-the-core-device-mo.patch \
    file://0005-dm-Introduce-dev_phys_to_bus-dev_bus_to_phys.patch \
    file://0006-usb-xhci-Add-missing-endian-conversions-cpu_to_leXX.patch \
    file://0007-usb-xhci-Add-virt_to_phys-to-support-mapped-platform.patch \
    file://0008-xhci-translate-virtual-addresses-into-the-bus-s-addr.patch \
    file://0009-mmc-Introduce-mmc_phys_to_bus-mmc_bus_to_phys.patch \
"

# In production builds enable_uart is not set, and this makes
# the pi4 serial driver freeze. Let's not use this driver in
# production, because we don't want to output anything to the
# console anyway.
SRC_URI_append_raspberrypi4-64 = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'development-image', '', 'file://rpi4-disable-pl01-serial-driver.patch', d)} \
"
