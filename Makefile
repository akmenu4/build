# SPDX-License-Identifier: 0BSD
# SPDX-FileCopyrightText: 2026 lifehackerhansol

.PHONY: akmenu4 akmenu4_ak2 akmenu4_dsi akmenu4_pico clean

OUT_DIR	:= $(CURDIR)/out

# phony packages
akmenu4:
	$(MAKE) -C akmenu4

akmenu4_ak2: $(OUT_DIR)/akmenu4_ak2.zip

akmenu4_dsi:
	$(MAKE) -C akmenu4 akmenu4.dsi

akmenu4_pico:
	$(MAKE) -C akmenu4 akmenu4_pico.nds

clean:
	$(MAKE) -C akmenu4 clean
	$(MAKE) -C loader/pico-loader clean
	rm -rf $(OUT_DIR)

# actual packages
$(OUT_DIR)/akmenu4_ak2.zip:
	mkdir -p $(OUT_DIR)/akmenu4_ak2/__rpg/
	$(MAKE) -C akmenu4 akmenu4_ak2.nds
	cp akmenu4/akmenu4_ak2.nds $(OUT_DIR)/akmenu4_ak2/__rpg/menu.nds
	$(MAKE) -C assets DST_DIR=$(OUT_DIR)/akmenu4_ak2/__rpg
	cd $(OUT_DIR)/akmenu4_ak2 && zip -r $@ *

