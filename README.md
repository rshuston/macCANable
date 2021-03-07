# macCANable

This project is the macOS CANable utility. It allows you to observe and control CAN traffic
on a Macintosh using a [CANable](https://canable.io) device.

## Basic Setup and Test:

Note: You should have another device connected to your CAN bus that can transmit
and receive messages. Examples are a Raspberry Pi with a CAN hat, a BeagleBone,
a Linux or Windows machine with a suitable CAN adapter attached and configured.

1. Build project.
1. Plug in CANable adapter connected to CAN bus
1. Run the macCANable app.
1. Select desired CANable “usbmodem” port.
1. Select desired bit rate.
1. Click the “Open” button.
1. To transmit, select data settings and click "Transmit" button.
1. Received messages are displayed in the "Receive" text field.

## CANable Serial Command Set:

Reference:  https://github.com/normaldotcom/cantact-fw

* `O` - Open channel
* `C` - Close channel
* `S0` - Set bitrate to 10 kbps
* `S1` - Set bitrate to 20 kbps
* `S2` - Set bitrate to 50 kbps
* `S3` - Set bitrate to 100 kbps
* `S4` - Set bitrate to 125 kbps
* `S5` - Set bitrate to 250 kbps
* `S6` - Set bitrate to 500 kbps
* `S7` - Set bitrate to 750 kbps
* `S8` - Set bitrate to 1 Mbps
* `M0` - Set mode to normal mode (default)
* `M1` - Set mode to silent mode
* `A0` - Disable automatic retransmission
* `A1` - Enable automatic retransmission (default)
* `TIIIIIIIILDD...` - Transmit data frame (Extended ID) [ID, length, data]
* `tIIILDD...` - Transmit data frame (Standard ID) [ID, length, data]
* `RIIIIIIIIL` - Transmit remote frame (Extended ID) [ID, length]
* `rIIIL` - Transmit remote frame (Standard ID) [ID, length]
* `V` - Returns firmware version and remote path as a string

__NOTE:__ The CAN channel must be closed when making speed and mode changes.

Examples:

Close channel, set rate to 500 kbps, open channel, send `123#11.22.33.44.55.66.77.88`:  
`C`  
`S6`  
`O`  
`t12381122334455667788`

Receipt of `321#DE.AD.BE.EF` gives  
`t3214DEADBEEF`
