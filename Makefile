all: MicrophoneMain.swf

FLEX_HOME=$(HOME)/lib/flex/

MicrophoneMain.swf: MicrophoneMain.as
	@$(FLEX_HOME)bin/mxmlc -static-link-runtime-shared-libraries \
				-swf-version=12 \
				-target-player=10.3.0 \
				-output=MicrophoneMain.swf \
				MicrophoneMain.as

setupflex:
	@wget http://fpdownload.adobe.com/pub/flex/sdk/builds/flex4.5/flex_sdk_4.5.1.21328_mpl.zip
	@unzip -d $(HOME)/lib/flex flex_sdk_4.5.1.21328_mpl.zip
	@rm flex_sdk_4.5.1.21328_mpl.zip
	@cp -r player/* $(HOME)/lib/flex/frameworks/libs/player/

.PHONY: all setupflex
