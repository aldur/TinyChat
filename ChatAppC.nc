#include <Timer.h>
#include "Chat.h"

configuration ChatAppC { }
implementation {
    components ChatC as App, MainC;

    components ActiveMessageC;
    components new AMSenderC(AM_CHAT_MSG);
    components new AMReceiverC(AM_CHAT_MSG);
    components CC2420ActiveMessageC;

    components SerialActiveMessageC as Serial;

    components new TimerMilliC() as Timer;
    components LedsC;

    App.Boot -> MainC;

    App.AMControl -> ActiveMessageC;
    App.Packet -> AMSenderC;
    App.AMPacket -> AMSenderC;
    App.AMSend -> AMSenderC;
    App.AMReceive -> AMReceiverC;
    App.PacketLink -> CC2420ActiveMessageC;

    App.SerialControl -> Serial;
    App.SerialReceive -> Serial.Receive[AM_CHAT_SERIAL_MSG];
    App.SerialSend -> Serial.AMSend[AM_CHAT_SERIAL_MSG];

    App.Timer -> Timer;
    App.Leds -> LedsC;
}
