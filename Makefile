# Copyright ETH Zurich
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
# Author: Alessandro Ottaviano

# Generate C header file

REGTOOL=../register_interface/vendor/lowrisc_opentitan/util/regtool.py

all: scmi.hjson headers

headers: scmi.h

scmi.h: scmi.hjson
	$(REGTOOL)  --cdefines $< > $@

