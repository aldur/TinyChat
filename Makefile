COMPONENT=ChatAppC

BUILD_EXTRA_DEPS += ChatMsg.py
CLEAN_EXTRA += ChatMsg.py *.pyc

CFLAGS += -I$(TOSDIR)/lib/T2Hack
CFLAGS += -DCC2420_DEF_CHANNEL=12
PFLAGS +=-DTOSH_DATA_LENGTH=64

ChatMsg.py: Chat.h
	mig python -target=$(PLATFORM) $(CFLAGS) -python-classname=ChatMsg Chat.h chat_serial_msg -o $@

include $(MAKERULES)

