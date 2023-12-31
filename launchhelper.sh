#!/bin/sh

#############
# CONSTANTS #
#############

RCUX_NAME='RiotClientUx.exe'
LCUX_NAME='LeagueClientUx.exe'
SCC_SH='syscall_check.sh'


#############
# FUNCTIONS #
#############

die() { # printf style params
    >&2 printf 'ERROR: '
    >&2 printf "${@}"
    >&2 echo
    sleep 5
    exit 1
}

wait_for() { # $1: time, $2: command
    timeout "${1}" sh -c "until ${2}; do \
        sleep 1; \
    done"
}

notify_send_wrapper() { # $1: notify_send_wrapper text
    if command -v 'notify-send'; then
        notify-send \
            'LoL LaunchHelper' \
            "${1}"
    fi
}


########
# MAIN #
########

# call syscall_check
own_dir="$(dirname "$(readlink -f "${0}")")"
if ! [ -x "${own_dir}/${SCC_SH}" ]; then
    die 'Please place this script into the same directory as "%s"!' "${SCC_SH}"
fi
"${own_dir}/${SCC_SH}"

# wait for RiotClientUx or LeagueClientUx to start
notify_send_wrapper "Waiting for ${RCUX_NAME} ... (Step 1/4)"
printf 'Waiting for process of "%s" or "%s" ... ' "${RCUX_NAME}" "${LCUX_NAME}"
wait_for 2m "pidof '${RCUX_NAME}' || pidof '${LCUX_NAME}'" >/dev/null
echo 'OK'

if pidof "${RCUX_NAME}" >/dev/null; then
    # wait for RiotClientUx process to exit
    printf 'Waiting for process of "%s" to exit ... ' "${RCUX_NAME}"
    wait_for 10m "! pidof '${RCUX_NAME}'" >/dev/null
    echo 'OK'
    notify_send_wrapper "${RCUX_NAME} exited (Step 2/4)"

    # find pid of LeagueClientUx process
    printf 'Waiting for process of "%s" ... ' "${LCUX_NAME}"
    lcux_pid=$(wait_for 2m "pidof '${LCUX_NAME}'")
    echo 'OK'

    if [ -z "${lcux_pid}" ]; then
        notify_send_wrapper "${LCUX_NAME} did not spawn in time (ERROR)"
        die 'Could not find processes of "%s"' "${LCUX_NAME}"
    fi

elif lcux_pid=$(pidof "${LCUX_NAME}"); then
    notify_send_wrapper "Skipped waiting for ${RCUX_NAME} (Step 2/4)"

else
    notify_send_wrapper "${RCUX_NAME} or ${LCUX_NAME} did not spawn in time (ERROR)"
    die 'Could not find processes of "%s" or "%s"' "${RCUX_NAME}" "${LCUX_NAME}"

fi

echo "${LCUX_NAME} pid found: ${lcux_pid}"

# find port of LeagueClientUx process
ux_port=$(grep -ao -- '--app-port=[0-9]*' "/proc/${lcux_pid}/cmdline" | grep -o '[0-9]*')

if [ -z "${ux_port}" ]; then
    die 'Could not find port of "%s" process!' "${LCUX_NAME}"
fi

echo "${LCUX_NAME} port found: ${ux_port}"
notify_send_wrapper "Found out about ${LCUX_NAME}, knocking on port ${ux_port} ... (Step 3/4)"

# pause LeagueClientUx process
kill -STOP "${lcux_pid}"

printf 'Waiting for port %s ... ' "${ux_port}"
wait_for 5m "echo 'Q' | openssl s_client -connect ':${ux_port}' >/dev/null 2>&1"
echo 'OK'
notify_send_wrapper "OpenSSL Connection established (Step 4/4)"

# continue LeagueClientUx process
kill -CONT "${lcux_pid}"

# finalize
echo "${LCUX_NAME} continues, my job is done!"

sleep 5

exit 0