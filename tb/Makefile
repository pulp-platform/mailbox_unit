# Copyright 2023 ETH Zurich
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# SPDX-License-Identifier: Apache-2.0
# Author: Robert Balas <balasr@iis.ee.ethz.ch>

# Compile and run mailbox testbench

BENDER = bender
BENDER_VERSION = $(shell $(BENDER) --version | awk  '{split($$2,v,"."); print v[2]}')
BENDER_VERSION_VALID = $(shell [ $(BENDER_VERSION) -ge 28 ] && echo true )

VLOG = vlog
VOPT = vopt
VSIM = vsim
VLOG_FLAGS =
VOPT_FLAGS =
VSIM_FLAGS =

TOP = mbox_tb

ifneq ($(BENDER_VERSION_VALID), true)
  $(error "Need Bender v0.28.x because earlier versions have buggy flist output")
endif

.DEFAULT_GOAL=build

.PHONY: tb.f
tb.f:
	$(BENDER) script flist -t rtl -t test -t simulation > $@


.PHONY: build
build: tb.f
	$(VLOG) -sv -nologo -suppress 2583 -suppress 13314 $(VLOG_FLAGS) -f $^
	$(VOPT) $(VOPT_FLAGS) $(TOP) -o opt_$(TOP)

.PHONY: build-opt
VLOG_FLAGS=+acc
build-opt: build

.PHONY: sim
sim:
	$(VSIM) -c $(VSIM_FLAGS) opt_$(TOP)

.PHONY: clean
clean:
	$(RM) -r work/ tb.f
