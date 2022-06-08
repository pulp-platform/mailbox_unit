// Generated register defines for scmi

// Copyright information found in source file:
// Copyright lowRISC contributors.

// Licensing information found in source file:
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#ifndef _SCMI_REG_DEFS_
#define _SCMI_REG_DEFS_

#ifdef __cplusplus
extern "C" {
#endif
// Register width
#define SCMI_PARAM_REG_WIDTH 32

// Reserved, must be 0
#define SCMI_RESERVED_1_REG_OFFSET 0x0

// Indicates which entity has access to the Shared Memory
#define SCMI_CHANNEL_STATUS_REG_OFFSET 0x4
#define SCMI_CHANNEL_STATUS_CHANNEL_FREE_BIT 0
#define SCMI_CHANNEL_STATUS_CHANNEL_ERROR_BIT 1
#define SCMI_CHANNEL_STATUS_FIELD1_MASK 0x3fffffff
#define SCMI_CHANNEL_STATUS_FIELD1_OFFSET 2
#define SCMI_CHANNEL_STATUS_FIELD1_FIELD \
  ((bitfield_field32_t) { .mask = SCMI_CHANNEL_STATUS_FIELD1_MASK, .index = SCMI_CHANNEL_STATUS_FIELD1_OFFSET })

// Reserved, implementation defined (32 bits over 64)
#define SCMI_RESERVED_2_REG_OFFSET 0x8

// Reserved, implementation defined (32 bits over 64)
#define SCMI_RESERVED_3_REG_OFFSET 0xc

// Defines wheter interrupts or polling is used for communication
#define SCMI_CHANNEL_FLAGS_REG_OFFSET 0x10
#define SCMI_CHANNEL_FLAGS_INTR_ENABLE_BIT 0
#define SCMI_CHANNEL_FLAGS_FIELD1_MASK 0x7fffffff
#define SCMI_CHANNEL_FLAGS_FIELD1_OFFSET 1
#define SCMI_CHANNEL_FLAGS_FIELD1_FIELD \
  ((bitfield_field32_t) { .mask = SCMI_CHANNEL_FLAGS_FIELD1_MASK, .index = SCMI_CHANNEL_FLAGS_FIELD1_OFFSET })

// Lenght of payload + header
#define SCMI_LENGTH_REG_OFFSET 0x14

// Defines which commanad the message contains
#define SCMI_MESSAGE_HEADER_REG_OFFSET 0x18
#define SCMI_MESSAGE_HEADER_MESSAGE_ID_MASK 0xff
#define SCMI_MESSAGE_HEADER_MESSAGE_ID_OFFSET 0
#define SCMI_MESSAGE_HEADER_MESSAGE_ID_FIELD \
  ((bitfield_field32_t) { .mask = SCMI_MESSAGE_HEADER_MESSAGE_ID_MASK, .index = SCMI_MESSAGE_HEADER_MESSAGE_ID_OFFSET })
#define SCMI_MESSAGE_HEADER_MESSAGE_TYPE_MASK 0x3
#define SCMI_MESSAGE_HEADER_MESSAGE_TYPE_OFFSET 8
#define SCMI_MESSAGE_HEADER_MESSAGE_TYPE_FIELD \
  ((bitfield_field32_t) { .mask = SCMI_MESSAGE_HEADER_MESSAGE_TYPE_MASK, .index = SCMI_MESSAGE_HEADER_MESSAGE_TYPE_OFFSET })
#define SCMI_MESSAGE_HEADER_PROTOCOL_ID_MASK 0xff
#define SCMI_MESSAGE_HEADER_PROTOCOL_ID_OFFSET 10
#define SCMI_MESSAGE_HEADER_PROTOCOL_ID_FIELD \
  ((bitfield_field32_t) { .mask = SCMI_MESSAGE_HEADER_PROTOCOL_ID_MASK, .index = SCMI_MESSAGE_HEADER_PROTOCOL_ID_OFFSET })
#define SCMI_MESSAGE_HEADER_TOKEN_MASK 0x3ff
#define SCMI_MESSAGE_HEADER_TOKEN_OFFSET 18
#define SCMI_MESSAGE_HEADER_TOKEN_FIELD \
  ((bitfield_field32_t) { .mask = SCMI_MESSAGE_HEADER_TOKEN_MASK, .index = SCMI_MESSAGE_HEADER_TOKEN_OFFSET })
#define SCMI_MESSAGE_HEADER_FIELD1_MASK 0xf
#define SCMI_MESSAGE_HEADER_FIELD1_OFFSET 28
#define SCMI_MESSAGE_HEADER_FIELD1_FIELD \
  ((bitfield_field32_t) { .mask = SCMI_MESSAGE_HEADER_FIELD1_MASK, .index = SCMI_MESSAGE_HEADER_FIELD1_OFFSET })

// memory region dedicated to the parameters of the commands and their
// returns
#define SCMI_MESSAGE_PAYLOAD_1_REG_OFFSET 0x1c

// Rapresents the interrupt to be raised towards the platform
#define SCMI_DOORBELL_REG_OFFSET 0x20
#define SCMI_DOORBELL_INTR_BIT 0
#define SCMI_DOORBELL_PRESERVE_MASK_MASK 0x7fffffff
#define SCMI_DOORBELL_PRESERVE_MASK_OFFSET 1
#define SCMI_DOORBELL_PRESERVE_MASK_FIELD \
  ((bitfield_field32_t) { .mask = SCMI_DOORBELL_PRESERVE_MASK_MASK, .index = SCMI_DOORBELL_PRESERVE_MASK_OFFSET })

// Rapresent the interrupt the platform should raise when it finishes to
// execute the received command
#define SCMI_COMPLETION_INTERRUPT_REG_OFFSET 0x24
#define SCMI_COMPLETION_INTERRUPT_INTR_BIT 0
#define SCMI_COMPLETION_INTERRUPT_PRESERVE_MASK_MASK 0x7fffffff
#define SCMI_COMPLETION_INTERRUPT_PRESERVE_MASK_OFFSET 1
#define SCMI_COMPLETION_INTERRUPT_PRESERVE_MASK_FIELD \
  ((bitfield_field32_t) { .mask = SCMI_COMPLETION_INTERRUPT_PRESERVE_MASK_MASK, .index = SCMI_COMPLETION_INTERRUPT_PRESERVE_MASK_OFFSET })

#ifdef __cplusplus
}  // extern "C"
#endif
#endif  // _SCMI_REG_DEFS_
// End generated register defines for scmi