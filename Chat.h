#ifndef CHAT_H
#define CHAT_H

enum {
    MSG_LEN = 60,

    AM_CHAT_SERIAL_MSG = 0x89,
    AM_CHAT_MSG = 0x99,

    SLEEP_TIMER = 750,
    DUTY_TIMER = 250,

    MAX_RETRIES = 3,
    RETRY_DELAY = 100
};

typedef nx_struct chat_msg {
    nx_uint16_t nodeid;
    nx_uint8_t msg[MSG_LEN];
} chat_msg;

typedef nx_struct chat_serial_msg {
    nx_uint8_t msg[MSG_LEN];
} chat_serial_msg;

#endif
