#!/usr/bin/sh
#
# This script receives the incoming ssh, scp, sftp command and
# determines which command to run to connect or transfer data
# to the proper uai (podman container).
#

UAI_IMAGE="registry.local/cray/uai:3.0"
UAI_VOLUMES="-v /home/users:/home/users \
             -v /var/run/slurm/conf/:/etc/slurm -v /var/run/munge:/var/run/munge \
             -v /opt/cray/pe:/opt/cray/pe -v /lus:/lus \
             -v /etc/ld.so.conf.d/cray-pe.conf:/etc/ld.so.conf.d/cray-pe.conf \
             -v /etc/profile.d:/etc/profile.d -v /opt/modulefiles:/opt/modulefiles \
             -v /etc/cray-pe.d:/etc/cray-pe.d \
             -v /var/opt/cray/pe/pe_images:/var/opt/cray/pe/pe_images \
             -v /etc/bash.bashrc.local:/etc/bash.bashrc.local"
GRAPHROOT="/scratch/containers"

# list of arguments expected in the input
OPTSTRING="v"

while getopts ${OPTSTRING} arg; do
  case ${arg} in
    v)
      VERBOSE=1
      ;;
    ?)
      echo "Invalid option: -${OPTARG}."
      exit 2
      ;;
  esac
done

UAI_HOST=$(hostname)
CONTAINER_NAME=$UAI_HOST-$(uuidgen | tr -d '-')
UAI_LAUNCH_CMD="podman --root $GRAPHROOT/$USER run -it --rm -h $USER-uai \
            --name $CONTAINER_NAME --label=uai=$USER \
            --cgroup-manager=cgroupfs --userns=keep-id \
            $UAI_VOLUMES \
            --network=host -e DISPLAY=$DISPLAY $UAI_IMAGE"
SCP_FLAGS=("-t" "-f")

function log() {
    logger "$0 - $@"
}

function log_and_echo() {
    logger "$0 - $@"
    echo "$@"
}

function get_host_mounts() {
    # Get the UAI host mounts. Include "~/" for the USER home directory.
    host_mounts=("~/")
    if [[ $VERBOSE == 1 ]]; then
        log "get_host_mounts: uan: $1"
    fi
    BINDS=$(podman --root $GRAPHROOT/$USER inspect $1 --format "{{ .HostConfig.Binds }}" | sed 's/\[//' | sed 's/\]//')
    IFS=' ' read -r -a mounts <<< "$BINDS"
    for i in ${mounts[@]}; do
        IFS=':' read -r -a mount_array <<< "$i"
        host_mounts+=(${mount_array[0]})
    done
    for j in ${host_mounts[@]}; do
        if [[ $VERBOSE == 1 ]]; then
            log "host_mounts: $j"
        fi
    done
}

log "--- STARTING UAI SESSION for $USER: $SSH_CONNECTION ---"

# Parse SSH_ORIGINAL_COMMAND into an array for processing
IFS=' ' read -r -a cmd_array <<< "$SSH_ORIGINAL_COMMAND"

# Gather a list of the USERs existing uais (podman containers)
UAIS=$(podman --root $GRAPHROOT/$USER ps --format='{{ .Names }}' -f label=uai=$USER)
if [ ! -z $UAIS ]; then
    log "UAIs are:"
    log "  $UAIS"
fi

# Parse UAIS into an array for processing
IFS=' ' read -r -a uai_array <<< "$UAIS"

# If SSH_ORIGINAL_COMMAND is empty, then we are simply doing an ssh
# connection to a podman container.
if [ -z ${cmd_array[0]} ]; then
    log "SSH_ORIGINAL_COMMAND is empty"
    # If there are no existing uais for the USER, then launch a new container
    if [ -z ${uai_array[0]} ]; then
        log "No active UAIs found for $USER. Creating a new UAI - $CONTAINER_NAME."
        eval $UAI_LAUNCH_CMD
    else
        # If there are existing uais for the USER, then exec into the first one
        log "Logging $USER into existing uai: ${uai_array[0]}"
        podman --root $GRAPHROOT/$USER exec -it ${uai_array[0]} /bin/bash
    fi
else
    log "SSH_ORIGINAL_COMMAND is $SSH_ORIGINAL_COMMAND"
    if [ -z ${uai_array[0]} ]; then
        # A command was sent. Handle the commands scp, and sftp to ensure the target is
        # a mounted filesystem from the host.  Otherwise, just run the command in the USERs
        # existing uai.
        log_and_echo "No existing UAI for scp. Exiting."
        exit
    else
        case ${cmd_array[0]} in
            ### SSH_ORIGINAL_COMMAND is SCP
            "scp")
                log "SCP to/from UAI as user: $USER"
                dest=""
		have_dest=""
		for scp_flag in ${SCP_FLAGS[@]}; do
                    if [[ ${cmd_array[1]} == $scp_flag ]]; then
                        dest=${cmd_array[2]}
			have_dest=1
			break
		    fi
	        done
		if [ -z $have_dest ]; then
                    log_and_echo "No scp destination. Exiting."
                    exit
                fi
                get_host_mounts "${uai_array[0]}"
                have_mount=""
                for k in ${host_mounts[@]}; do
                    if [[ $dest =~ ^$k ]]; then
			if [[ ${cmd_array[1]} == "-t" ]]; then
                            log "Will scp to $dest on UAI: ${uai_array[0]}"
			else
                            log "Will scp $dest from UAI: ${uai_array[0]}"
			fi
                        have_mount=1
                        $SSH_ORIGINAL_COMMAND
                        break
                    fi
                done
                if [ -z $have_mount ]; then
                    log_and_echo "scp destination not found. Exiting"
                    exit
                fi;;
            ### SSH_ORIGINAL_COMMAND is SFTP
            "/usr/lib/ssh/sftp-server")
                log "SFTP to/from UAI as user: $USER"
                log "Will sftp to/from ${uai_array[0]}"
                $SSH_ORIGINAL_COMMAND;;
            ### SSH_ORIGINAL_COMMAND is not SCP of SFTP
            *)
                log "SSH remote command: $SSH_ORIGINAL_COMMAND will be executed on ${uai_array[0]}"
                podman --root $GRAPHROOT/$USER exec -it ${uai_array[0]} $SSH_ORIGINAL_COMMAND;;
        esac
    fi
fi
log "--- EXITING UAI SESSION for $USER: $SSH_CONNECTION ---"

