# Mailbox Unit

A number of configurable mailboxes with interrupt based signaling receiver and
sender. The mailbox unit has a single register interface port. A convenience
AXI-Lite wrapper is also available.

## Register map

| Offset   | Register         | Width (bit)   |
| -------- | ----------       | ------        |
| 0x00     | INT\_SND\_STAT   |  1            |
| 0x04     | INT\_SND\_SET    |  1            |
| 0x08     | INT\_SND\_CLR    |  1            |
| 0x0C     | INT\_SND\_EN     |  1            |
| 0x40     | INT\_RCV\_STAT   |  1            |
| 0x44     | INT\_RCV\_SET    |  1            |
| 0x48     | INT\_RCV\_CLR    |  1            |
| 0x4C     | INT\_RCV\_EN     |  1            |
| 0x80     | LETTER0          |  32           |
| 0x8C     | LETTER1          |  32           |

## Basics
   Interrupt lines are level sensitive. There are interrupt lines for sender and
   receivers. They work exactly the same way so only the name is different.

   Interrupts can be asserted by writing `1` to the `SET` register and cleared
   by writing `1` to the `CLR` register. The current state of the
   level-sensitive interrupt line is reflected in the `STAT` register.

   The interrupt line is only asserted if the `EN` register is `1`. This allows
   sender and receiver to block interrupts if they prefer to poll `STAT`
   instead.

## Suggested Messaging Concept

1. Sender places message into `LETTER0` and/or `LETTER1`. This can potentially
   be a 64-bit pointer to some other location that contains more data or plain
   data (e.g. error code of an offload operation)

2. Sender notifies receiver by writing `1` to `INT_RCV_SET`.

3. If receiver has written `1` to `INT_RCV_EN` then he will get a
   level-sensitive interrupt.

4. Receiver can now read `LETTER*` and process it.

5. The receiver can optionally notify the Sender by writing `1` to
   `INT_SND_SET`. Again the sender will get interrupt if he set `INT_SND_EN`.

Note that the registers are all accessible to everyone so there is no security
boundary within a mailbox.

## Testbench
In `tb/` there is a simple testbench. Run it by calling

```
make build
make sim
run -a
```
