# Mailbox Unit

A number of configurable mailboxes with interrupt based signaling receiver and
sender.


| Offset   | Register         | Width (bit)   |
| -------- | ----------       | ------        |
| 0x00     | INT\_SND\_STATUS |  1            |
| 0x04     | INT\_SND\_SET    |  1            |
| 0x08     | INT\_SND\_CLEAR  |  1            |
| 0x0C     | INT\_RCV\_STATUS |  1            |
| 0x10     | INT\_RCV\_SET    |  1            |
| 0x14     | INT\_RCV\_CLEAR  |  1            |
| 0x18     | LETTER0          |  32           |
| 0x1C     | LETTER1          |  32           |

