#include "Chat.h"

module ChatC {
    uses interface Boot;

    uses interface SplitControl as AMControl;
    uses interface Packet;
    uses interface AMPacket;
    uses interface AMSend;
    uses interface Receive as AMReceive;
    uses interface PacketLink;

    uses interface SplitControl as SerialControl;
    uses interface AMSend as SerialSend;
    uses interface Receive as SerialReceive;

    uses interface Timer<TMilli>;
    uses interface Leds;
} implementation {
    bool radio_busy = FALSE;
    bool serial_busy = FALSE;

    message_t radio_pkt;
    message_t serial_pkt;

    /** Should the iface be on? */
    bool on_duty;

    /** A packet was pending to be sent while radio was off. */
    bool is_pending;
    void radio_immediate_send();

    /* --- Boot --- */

    event void Boot.booted() {
        call SerialControl.start();
        call AMControl.start();

        /** Setup the PacketLink module */
        call PacketLink.setRetries(&radio_pkt, MAX_RETRIES);
        call PacketLink.setRetryDelay(&radio_pkt, RETRY_DELAY);
    }

    /* --- Control events --- */

    event void SerialControl.startDone(error_t err) {
        if (err != SUCCESS) {
            call SerialControl.start();
        }
    }

    event void SerialControl.stopDone(error_t err) {
        if (err != SUCCESS) {
            call SerialControl.stop();
        }
    }

    event void AMControl.startDone(error_t err) {
        if (err == SUCCESS) {
            on_duty = TRUE;
            call Leds.set(1);

            call Timer.startOneShot(DUTY_TIMER);

            if (is_pending) {
                radio_immediate_send();
            }
        } else {
            call AMControl.start();
        }
    }

    event void AMControl.stopDone(error_t err) {
        if (err == SUCCESS) {
            on_duty = FALSE;
            call Leds.set(0);
            call Timer.startOneShot(SLEEP_TIMER);
        } else {
            call AMControl.stop();
        }
    }

    /* --- Timer events --- */

    event void Timer.fired() {
        if (on_duty) {
            call AMControl.stop();
        } else {
            call AMControl.start();
        }
    }

    /* --- Send calls --- */

    void radio_immediate_send() {
        if (call AMSend.send(AM_BROADCAST_ADDR,
                    &radio_pkt, sizeof(chat_msg)) == SUCCESS) {
            radio_busy = TRUE;
            is_pending = FALSE;
        }
    }

    /**
     * Send message through radio.
     */
    void radio_send(nx_int16_t node_id, nx_uint8_t *msg) {
        if (!radio_busy) {
            chat_msg *spkt;

            spkt = (chat_msg *)(call Packet.getPayload(
                        &radio_pkt, sizeof(chat_msg)
                        ));
            if (spkt == NULL) { return; }

            spkt->nodeid = node_id;
            memcpy(spkt->msg, msg, sizeof(spkt->msg));

            if (!on_duty) {
                is_pending = TRUE;
                call Timer.stop();
                call AMControl.start();
            } else {
                radio_immediate_send();
            }
        }
    }

    /**
     * Send the received message through serial port.
     */
    void serial_send(nx_uint8_t* msg) {
        if (!serial_busy) {
            chat_serial_msg *spkt;

            spkt = (chat_serial_msg *)(call Packet.getPayload(
                        &serial_pkt, sizeof(chat_serial_msg))
                    );
            memcpy(spkt->msg, msg, sizeof(spkt->msg));
            if (spkt == NULL) { return; }

            if (call SerialSend.send(AM_BROADCAST_ADDR,
                        &serial_pkt, sizeof(chat_serial_msg)) == SUCCESS) {
                serial_busy = TRUE;
            }
        }
    }

    /* --- AM Send/Receive --- */

    event void AMSend.sendDone(message_t* msg, error_t err) {
        if (&radio_pkt == msg) { radio_busy = FALSE; }
    }

    event message_t* AMReceive.receive(
            message_t* msg, void* payload, uint8_t len
            ) {
        if (len == sizeof(chat_msg)) {
            chat_msg *rpkt = (chat_msg *)payload;

            if (rpkt->nodeid == 0) {
                // Send to serial.
                serial_send(rpkt->msg);
            } else {
                // Forward to sink.
                radio_send(rpkt->nodeid, rpkt->msg);
            }
        }

        return msg;
    }

    /* --- Serial Send/Receive --- */

    event void SerialSend.sendDone(message_t* msg, error_t err) {
        if (&serial_pkt == msg) { serial_busy = FALSE; }
    }

    event message_t* SerialReceive.receive(
            message_t* msg, void* payload, uint8_t len
            ) {

        if (len == sizeof(chat_serial_msg)) {
            chat_serial_msg *rpkt = (chat_serial_msg *)payload;
            radio_send(TOS_NODE_ID, rpkt->msg);
        }

        return msg;
    }

}
