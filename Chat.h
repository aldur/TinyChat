#ifndef CHAT_H
#define CHAT_H

enum {
    AM_CHAT_SERIAL_MSG = 0x89,
    AM_CHAT_MSG = 0x99,
    TIMER_PERIOD_MILLI = 250,
    MSG_LEN = 60
};

typedef nx_struct chat_msg {
    nx_uint16_t nodeid;
    nx_uint8_t msg[MSG_LEN];
} chat_msg;

typedef nx_struct chat_serial_msg {
    nx_uint8_t msg[MSG_LEN];
} chat_serial_msg;

#endif
