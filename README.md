# macCANable

This project is a basic macOS CAN messaging utility. It allows you to receive
and send CAN traffic on a Macintosh using the [CANable](https://canable.io)
CAN bus peripheral device. While its current form serves as more of CAN bus
monitor and simple message sender, it can serve as a starting point for more
sophisticated features as the need arises.

## Project Setup and Test:

You'll need to have another device connected to your CAN bus that can transmit
and receive messages. Examples are a Raspberry Pi with a CAN hat, a BeagleBone,
a Linux or Windows machine with a suitable CAN adapter attached and configured.

1. Build the project. The project builds under Xcode 12.x, but Xcode 11.x should work too.
1. Run the `macCANable` app.
1. Plug in a CANable adapter connected to a working CAN bus.
1. Select the desired CANable “usbmodem” port associated with the CANable adapter.
1. Select the desired bit rate (the default is 500 kbps).
1. Click the “Open” button. It becomes a "Close" button for when you want to close the port.
1. Received messages are displayed in the "Receiption" text field. Use the "Clear" button to clear old data.
1. To transmit, configure "Transmission "data settings and click the "Send" button.

You can also plug in two CANable adapters to your Mac, opening new windows for each
adapter. You'll need to make the necessary physical CAN connections so that they can
all talk.

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

### Serial port examples:

TX:  
To close channel, set rate to 500 kbps, open channel, send `123#11.22.33.44.55.66.77.88`:  
`C`  
`S6`  
`O`  
`t12381122334455667788`

RX:  
The receipt of `321#DE.AD.BE.EF` gives  
`t3214DEADBEEF`

## Basic Application Structure:

The project is set up as a multi-document application. This was done to allow for multiple windows
to be open, each with its own CANable connection. Although the `Document` class is currently is its
default template state, a future version of the applications may offer the ability to save and restore
configurations as well as captured CAN receptions.

The main view controller is augmented by a companion "logic" class that offloads the business logic
from the view controller.

Cocoa-bindings are used to manage the data exchanges of the port "bit rate" and the "Transmission"
message "DLC" popup menus.

Integration with the `ORSSerialPort` package is a bit tricky, especially when it comes to managing
multiple and simultaneous serial port instances. The `ORSSerialPortDelegate` methods along with
Cocoa notifications are used to keep everything in order. There's probably a better way, but this works
for now.
