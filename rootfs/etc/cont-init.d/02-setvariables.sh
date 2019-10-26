#!/usr/bin/with-contenv bash
if [ ${ENCODER} = "nvidia" ] ; then
ENCODER_SCRIPT=nvidia
fi
if [ ${ENCODER} = "intel" ] ; then
ENCODER_SCRIPT=intel
fi
if [ ${ENCODER} = "software" ] ; then
ENCODER_SCRIPT=software
fi
if [ ${ENCODER} = "custom" ] ; then
    if [ -f "/config/custom.sh" ] ; then
        chmod +x /config/custom.sh
        sed -i "s/scripts\/ENCODEREND/config\/custom.sh/g" /etc/services.d/autovideoconverter/run
        sed -i "s/ENCODEREND/custom.sh/g" /etc/services.d/autovideoconverter/run
    else echo "ERROR: Please save the custom script to /config/custom.sh"
    fi
fi
if [ ${SUBTITLES} = "0" ] ; then
ENCODER_SCRIPT_END=.sh
else ENCODER_SCRIPT_END=-subtitles.sh
fi
if [ ${DELETE_TS} = "1" ] ; then
sed -i "s/#SEDIF/if [ -f \"\$map\/\$mp4\" ] \&\& [ -s \"\$map\/\$mp4\" ] ; then\nrm \"\$1\"\nfi/g" /scripts/$ENCODER_SCRIPT$ENCODER_SCRIPT_END
fi
if [ ! -f /bin/sh ]; then
    ln -s /usr/bin/dash /bin/sh && ln -s /usr/bin/bash /bin/bash
fi
chmod +x /scripts/*
sed -i "s/ENCODER/$ENCODER_SCRIPT/g" /etc/services.d/autovideoconverter/run
sed -i "s/END/$ENCODER_SCRIPT_END/g" /etc/services.d/autovideoconverter/run
sed -i "s/SEDUSER/$PUID/g" /etc/cont-init.d/10-autoconvertor.sh
sed -i "s/SEDGROUP/$PGID/g" /etc/cont-init.d/10-autoconvertor.sh
sed -i "s/SEDUSER/$PUID/g" /etc/services.d/autovideoconverter/run
sed -i "s/SEDGROUP/$PGID/g" /etc/services.d/autovideoconverter/run
mkdir /output
