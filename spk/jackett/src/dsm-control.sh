#!/bin/sh

# Package
PACKAGE="jackett"
DNAME="Jackett"

BUILDNUMBER="$(/bin/get_key_value /etc.defaults/VERSION buildnumber)"
SC_USER="sc-jackett"
LEGACY_USER="jackett"
USER="$([ "${BUILDNUMBER}" -ge "7321" ] && echo -n ${SC_USER} || echo -n ${LEGACY_USER})"

# Others
INSTALL_DIR="/usr/local/${PACKAGE}"
MONO_PATH="/usr/local/mono/bin/"
PATH="${INSTALL_DIR}/bin:${MONO_PATH}:${PATH}"

MONO="${MONO_PATH}/mono"
JACKETT="${INSTALL_DIR}/share/${PACKAGE}/JackettConsole.exe"
HOME_DIR="${INSTALL_DIR}/var"
PID_FILE="${HOME_DIR}/jackett.pid"
LOG_FILE="${HOME_DIR}/.config/Jackett/log.txt"
COMMAND="env XDG_CONFIG_HOME=${HOME_DIR} PATH=${PATH} LD_LIBRARY_PATH=${INSTALL_DIR}/lib ${MONO} -- --debug ${JACKETT}"

start_daemon ()
{
    start-stop-daemon -c ${USER} -Sqbmp ${PID_FILE} -x ${COMMAND}
}

stop_daemon ()
{
    start-stop-daemon -Kqu ${USER} -p ${PID_FILE}
    wait_for_status 1 20 || start-stop-daemon -Kqs 9 -p ${PID_FILE}
}

daemon_status ()
{
    start-stop-daemon -Kqtu ${USER} -p ${PID_FILE}
}

wait_for_status ()
{
    counter=$2
    while [ ${counter} -gt 0 ]; do
        daemon_status
        [ $? -eq $1 ] && return
        let counter=counter-1
        sleep 1
    done
    return 1
}

case $1 in
    start)
        if daemon_status; then
            echo ${DNAME} is already running
        else
            echo Starting ${DNAME} ...
            start_daemon
        fi
        ;;
    stop)
        if daemon_status; then
            echo Stopping ${DNAME} ...
            stop_daemon
        else
            echo ${DNAME} is not running
        fi
        ;;
    status)
	    if daemon_status; then
            echo ${DNAME} is running
            exit 0
        else
            echo ${DNAME} is not running
            exit 1
        fi
        ;;
    log)
        echo "${LOG_FILE}"
        exit 0
        ;;
    *)
        exit 1
        ;;
esac
