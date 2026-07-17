# SPDX-License-Identifier: 0BSD
# SPDX-FileCopyrightText: 2026 lifehackerhansol

CONFIG	?=	ak2

include build/config/$(CONFIG).config

OUT_DIR			:= $(CURDIR)/out/akmenu4_$(CONFIG_PLATFORM)
RPG_DIR			:= $(OUT_DIR)/__rpg
ASSETS_DIR		:= $(CURDIR)/assets
ASSETS_DEST		:= $(RPG_DIR)
AKLOADER_DIR	:= $(CURDIR)/loader/akloader-prebuilts
AKLOADER_OUT	:= $(RPG_DIR)

PACKAGE_DEPENDENCIES	:=	assets akmenu4_$(CONFIG_AKMENU4_PLATFORM)
ifeq ($(CONFIG_AKMENU4_PLATFORM),pico)
PACKAGE_DEPENDENCIES	+=	pico-loader
endif
ifeq ($(CONFIG_AKMENU4_PLATFORM),ak2)
PACKAGE_DEPENDENCIES	+=	akloader
endif

ifneq ($(CONFIG_MINIBOOT_DIST),)
PACKAGE_DEPENDENCIES	+=	nds-miniboot
endif

define miniboot-copy
# Create a path with the first folder stripped,
# to remove the platform name from nds-miniboot dist output
# Works by replacing the parameter's slash with space to convert it to a list,
# then use the first word to remove that substring from the parameter
$(eval MINIBOOT_COPY_DEST=$(patsubst $(firstword $(subst /, ,$(1)))/%,%,$(1)))

# Then pass the resulting string into $(dir) to get the directory path
# mkdir won't fail even if the string turns empty as a result,
# since we pass -p, and $(OUT_DIR) either already exists, or needs to exist
mkdir -p $(OUT_DIR)/$(dir $(MINIBOOT_COPY_DEST))

# Then copy the file there
cp -f nds-miniboot/dist/$(1) $(OUT_DIR)/$(MINIBOOT_COPY_DEST)
endef

.PHONY: all akmenu4_$(CONFIG_AKMENU4_PLATFORM) nds-miniboot clean

# First build target must come before any include to avoid defaults becoming a single image etc
all: $(OUT_DIR).zip

include assets/Makefile
include loader/akloader-prebuilts/Makefile

akmenu4_$(CONFIG_AKMENU4_PLATFORM):
	@$(MAKE) -C akmenu4 akmenu4_$(CONFIG_AKMENU4_PLATFORM).nds

clean:
	@$(MAKE) -C akmenu4 clean
	@$(MAKE) -C nds-miniboot clean
	@$(MAKE) -C loader/pico-loader clean
	@rm -rf out

nds-miniboot:
	$(MAKE) -C $@

pico-loader:
	@$(MAKE) -C loader/pico-loader PICO_PLATFORM=$(CONFIG_PICO_LOADER_PLATFORM)
	@mkdir -p $(OUT_DIR)/_pico
	@cp loader/pico-loader/picoLoader7.bin $(OUT_DIR)/_pico/picoLoader7.bin
	@cp loader/pico-loader/picoLoader7.bin $(OUT_DIR)/_pico/picoLoader9.bin
	@cp loader/pico-loader/data/aplist.bin $(OUT_DIR)/_pico/aplist.bin
	@cp loader/pico-loader/data/patchlist.bin $(OUT_DIR)/_pico/patchlist.bin
	@cp loader/pico-loader/data/savelist.bin $(OUT_DIR)/_pico/savelist.bin

# Final output
$(OUT_DIR).zip: $(PACKAGE_DEPENDENCIES)
	@cp akmenu4/akmenu4_$(CONFIG_AKMENU4_PLATFORM).nds $(RPG_DIR)/akmenu4.nds
	@$(foreach miniboot,$(CONFIG_MINIBOOT_DIST),$(call miniboot-copy,$(miniboot)))
	@cd $(OUT_DIR) && zip -r $@ *
