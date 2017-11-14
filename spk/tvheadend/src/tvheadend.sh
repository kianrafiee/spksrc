#!/bin/sh

PORT=$1
PORT2=$2
PID_FILE=$3
echo "Starting Tvheadend as user ${USER} on htttp port ${PORT} and htsp port ${PORT2} at ${SYNOPKG_PKGDEST}"
cd "${SYNOPKG_PKGDEST}"
tvheadend -f -u ${USER} --http_port ${port} --htsp_port ${port2} -c ${INSTALL_DIR}/var
echo "$!" > "${PID_FILE}"
