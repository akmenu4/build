# SPDX-License-Identifier: 0BSD
# SPDX-FileCopyrightText: 2026 lifehackerhansol

.PHONY: all akmenu4 akmenu4_ak2 akmenu4_dsi akmenu4_pico nds-miniboot pico-loader clean

PLATFORM	:= ak2

ASSETS_DIR	:= $(CURDIR)/assets
ASSETS_DEST	:= $(CURDIR)/out/akmenu4_$(PLATFORM)/__rpg
OUT_DIR	:= $(CURDIR)/out

# First build target must come before any include to avoid defaults becoming a single image etc
all: $(OUT_DIR)/akmenu4_$(PLATFORM).zip

include assets/Makefile

akmenu4:
	$(MAKE) -C akmenu4

akmenu4_ak2:
	$(MAKE) -C akmenu4 akmenu4_ak2.nds

akmenu4_dsi:
	$(MAKE) -C akmenu4 akmenu4.dsi

akmenu4_pico:
	$(MAKE) -C akmenu4 akmenu4_pico.nds

clean:
	$(MAKE) -C akmenu4 clean
	$(MAKE) -C loader/pico-loader clean
	rm -rf $(OUT_DIR)

nds-miniboot:
	$(MAKE) -C $@

# Final output
$(OUT_DIR)/akmenu4_ak2.zip: akmenu4_ak2 nds-miniboot assets
	cp akmenu4/akmenu4_ak2.nds $(OUT_DIR)/akmenu4_ak2/__rpg/akmenu4.nds
	cp nds-miniboot/dist/generic/akmenu4.nds nds-miniboot/dist/generic/dsedgei.dat nds-miniboot/dist/r4itt/_ds_menu.dat $(OUT_DIR)/akmenu4_ak2/
	cd $(OUT_DIR)/akmenu4_ak2 && zip -r $@ *

$(OUT_DIR)/akmenu4_dstt.zip: akmenu4_pico nds-miniboot assets
	cp akmenu4/akmenu4_pico.nds $(OUT_DIR)/akmenu4_dstt/__rpg/akmenu4.nds
	cp nds-miniboot/dist/generic/ttmenu.dat nds-miniboot/dist/generic/r4.dat $(OUT_DIR)/akmenu4_dstt/
	cd $(OUT_DIR)/akmenu4_dstt && zip -r $@ *
