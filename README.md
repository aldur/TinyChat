# TinyOS Chat
A simple TinyOS chat developed as a lab-project for the IoT class.
Developed for the Crossbow TelosB device.

## Make / install
Clone the repository and run:

```bash
$ make telosb install
```

Then, launch the TinyOS serial forwarder and run the attached `Chat.py` file.
It will let you send/receive messages to and from the network.

## Communication
Communication happens on channel #12 and should be reliable.
Duty cycles are implemented (by deliberately avoiding LPL) and can be manually inspected through the LEDs interface.
