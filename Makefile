# SPDX-License-Identifier: 0BSD
# SPDX-FileCopyrightText: 2026 lifehackerhansol

.PHONY: akmenu4 akmenu4_ak2 akmenu4_dsi akmenu4_pico

akmenu4:
	$(MAKE) -C akmenu4

akmenu4_ak2:
	$(MAKE) -C akmenu4 akmenu4_ak2.nds

akmenu4_dsi:
	$(MAKE) -C akmenu4 akmenu4.dsi

akmenu4_pico:
	$(MAKE) -C akmenu4 akmenu4_pico.nds
