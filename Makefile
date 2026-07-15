# SPDX-License-Identifier: 0BSD
# SPDX-FileCopyrightText: 2026 lifehackerhansol

.PHONY: all akmenu4 akmenu4_ak2 akmenu4_dsi akmenu4_pico nds-miniboot akloader clean

CONFIG	?=	ak2

include build/config/$(CONFIG).config

ASSETS_DIR	:= $(CURDIR)/assets
ASSETS_DEST	:= $(CURDIR)/out/akmenu4_$(CONFIG_PLATFORM)/__rpg
OUT_DIR	:= $(CURDIR)/out

PACKAGE_DEPENDENCIES	:=	assets akmenu4_$(CONFIG_AKMENU4_LOADER)
ifeq ($(CONFIG_AKMENU4_LOADER),pico)
PACKAGE_DEPENDENCIES	+=	pico-loader
endif
ifeq ($(CONFIG_AKMENU4_LOADER),ak2)
PACKAGE_DEPENDENCIES	+=	akloader
endif

ifneq ($(CONFIG_MINIBOOT_DIST),)
PACKAGE_DEPENDENCIES	+=	nds-miniboot
endif

define miniboot-copy
cp -f nds-miniboot/dist/$(1) $(OUT_DIR)/akmenu4_$(CONFIG_PLATFORM)/;
endef

# First build target must come before any include to avoid defaults becoming a single image etc
all: $(OUT_DIR)/akmenu4_$(CONFIG_PLATFORM).zip

include assets/Makefile

akmenu4:
	@$(MAKE) -C akmenu4

akmenu4_ak2:
	@$(MAKE) -C akmenu4 akmenu4_ak2.nds

akmenu4_dsi:
	@$(MAKE) -C akmenu4 akmenu4.dsi

akmenu4_pico:
	@$(MAKE) -C akmenu4 akmenu4_pico.nds

clean:
	@$(MAKE) -C akmenu4 clean
	@$(MAKE) -C nds-miniboot clean
	@$(MAKE) -C loader/pico-loader clean
	@rm -rf $(OUT_DIR)

nds-miniboot:
	@$(MAKE) -C $@

pico-loader:
	@$(MAKE) -C loader/pico-loader PICO_PLATFORM=$(CONFIG_PICO_LOADER_PLATFORM)
	@mkdir -p $(OUT_DIR)/akmenu4_$(CONFIG_PLATFORM)/_pico
	@cp loader/pico-loader/picoLoader7.bin $(OUT_DIR)/akmenu4_$(CONFIG_PLATFORM)/_pico/picoLoader7.bin
	@cp loader/pico-loader/picoLoader7.bin $(OUT_DIR)/akmenu4_$(CONFIG_PLATFORM)/_pico/picoLoader9.bin
	@cp loader/pico-loader/data/aplist.bin $(OUT_DIR)/akmenu4_$(CONFIG_PLATFORM)/_pico/aplist.bin
	@cp loader/pico-loader/data/patchlist.bin $(OUT_DIR)/akmenu4_$(CONFIG_PLATFORM)/_pico/patchlist.bin
	@cp loader/pico-loader/data/savelist.bin $(OUT_DIR)/akmenu4_$(CONFIG_PLATFORM)/_pico/savelist.bin

# Final output
$(OUT_DIR)/akmenu4_$(CONFIG_PLATFORM).zip: $(PACKAGE_DEPENDENCIES)
	@cp akmenu4/akmenu4_$(CONFIG_AKMENU4_LOADER).nds $(OUT_DIR)/akmenu4_$(CONFIG_PLATFORM)/__rpg/akmenu4.nds
	@$(foreach miniboot,$(CONFIG_MINIBOOT_DIST),$(call miniboot-copy,$(miniboot)))
	@cd $(OUT_DIR)/akmenu4_$(CONFIG_PLATFORM) && zip -r $@ *
