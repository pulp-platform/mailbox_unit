# Axi SCMI Mailbox

The mailbox presents one singular Axi Lite slave port because in the Opentitan integration, the Ibex core of the RoT is a master of the main Axi bus of the Alsaqr Platform.
So the arbitration is performed by the crossbar itself and two ports are not needed. The registers are compliant to the SCMI protocol in terms of width and address (offset).
In this table the registers are shown:

| Offset   | Register        | Width (bit)   |
| -------- | ----------      | ------        |
| 0x00     | Reserved 1      |  32           |
| 0x04     | Channel Status  |  32           |
| 0x08     | Reserved 2      |  32           |
| 0x0C     | Reserved 3      |  32           |
| 0x10     | Channel Flags   |  32           |
| 0x14     | Length          |  32           |
| 0x18     | Message Header  |  32           |
| 0x1C     | Message Payload |  32           |
| 0x20     | Doorbell irq    |  32           |
| 0x24     | Completion irq  |  32           |

The regfile has been generated with the reggen tool, available in the register_interface repository (as bender.yml dependency). The hjson file can be found in the data/ directory.
The SCMI documentation specify that the Message Payload width is arbitrary, here it is 32 bit. The Reserved 2 and 3 regs are a unique 64 bit register in the SCMI specification.
To get a larger payload or different data width for the registers, the reg file has to be generated with those modifications ot the hjson.
Moreover, to extend the payload width more registers are needed, thus the doorbell and the completion irqs will be
shifted in offset by N*4 where N is the number of register that are introduced for the Message Payload.

The output interrupts (doorbell and completion irq) are hard-connected to the bit [0] of the corresponding registers throught a sync_wedge. 
