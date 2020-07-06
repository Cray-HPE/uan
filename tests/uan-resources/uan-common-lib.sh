#!/bin/bash
#
# uan-common-lib.sh - UAN common functions
# Copyright 2020 Cray Inc. 

# Global variables
EXIT_CODE=0
FN_COMMON="uan-common-lib"
LOGIN_NODE=""
MAX_TRY=5
MOUNT_FILE="/proc/mounts"
TEST_CASE=0
PBS_JOB_ID=""
CT_SHARED_FS="$SHARED_FS/CT"

# Test case header
function TEST_CASE_HEADER {
    ((TEST_CASE++))
    echo ""
    echo "#########################################################################################"
    echo "# Test case $TEST_CASE: $1"
    echo "#########################################################################################"
}

# Find WLM on the system
function FIND_WLM {
    # Verify that slurm pod is running on the system
    # check_pod_status is defined in /opt/cray/tests/ncn-resources/bin/
    check_pod_status slurm
    RC_SLURM_POD=$?

    # Verify that pbs pod is running on the system
    check_pod_status pbs
    RC_PBS_POD=$?
}

# SLURM smoke test
function SLURM_SMOKE_TEST {

    if [[ $1 == UAN ]]; then
        LOGIN_NODE="$i_uan"
    else
        echo "WARNING: No argument supplied. Skipping check..."
        exit 123
    fi

    TEST_CASE_HEADER "Running SLURM smoke tests on $LOGIN_NODE"

    for ((try = 1; try <= $MAX_TRY; try++))
    do
        # Test sinfo to make sure that compute nodes are up running and idle state
        echo "ssh $LOGIN_NODE sinfo -r -l --states=idle | grep up"
        ssh $LOGIN_NODE sinfo -r -l --states=idle | grep up
        if [[ $? == 0 ]]; then
            echo "Try: $try"
            echo "SUCCESS: [$FN_COMMON] sinfo works well."
            break;
        fi
    done

    if ((try > MAX_TRY))
    then
        echo "Try: $try"
        echo "FAIL: [$FN_COMMON] sinfo doesn't work." >> $RESULT_TEST
        EXIT_CODE=1
    fi
}

# PBS smoke test
function PBS_SMOKE_TEST {

    if [[ $1 == UAN ]]; then
        LOGIN_NODE="$i_uan"
    else
        echo "WARNING: No argument supplied. Skipping check..."
        exit 123
    fi

    TEST_CASE_HEADER "Running PBS smoke tests on $LOGIN_NODE"

    for ((try = 1; try <= $MAX_TRY; try++))
    do
        # Test qstat
        echo "ssh $LOGIN_NODE qstat -B | grep -i Active"
        ssh $LOGIN_NODE qstat -B | grep -i Active
        if [[ $? == 0 ]]; then
            echo "Try: $try"
            echo "SUCCESS: [$FN_COMMON] qstat works well."
            break;
        fi
    done

    if ((try > MAX_TRY))
    then
        echo "Try: $try"
        echo "FAIL: [$FN_COMMON] qstat doesn't work." >> $RESULT_TEST
        EXIT_CODE=1
    fi
}

# Check that UAN is available on the system
function IS_UAN_AVAILABLE {
    TEST_CASE_HEADER "Verify that UAN is available on the system"
    # See if Role="Application" for UAN is in the Node Map
    cray hsm defaults nodeMaps list | grep Application
    if [[ $? == 0 ]]; then
        echo "SUCCESS: [$FN_COMMON] Role=Application for UAN is in the Node Map"
    else
        echo "FAIL: [$FN_COMMON] Role=Application for UAN is not in the Node Map. Skipping check..."
        echo "[$FN_COMMON] After an automated installation of UAN is done, we need to change exit 123 to exit 1"
        exit 123
    fi

    # Get ID for UAN
    ID_UANs=$(cray hsm defaults nodeMaps list | grep ID | grep -v NID | awk '{print $3}' | sed 's/"//g')

    if [[ -n $ID_UANs ]]; then
        echo "#################################################"
        echo "ID for nodes: $ID_UANs"
        echo "#################################################"
    else
        echo "FAIL: [$FN_COMMON] No IDs are available on a system"
        exit 1
    fi

    # Run cray hsm inventory hardware describe ID
    for id in $ID_UANs
    do
        echo ""
        echo "#################################################"
        echo "cray hsm inventory hardware describe $id"
        echo "#################################################"
        cray hsm inventory hardware describe $id
        if [[ $? == 0 ]]; then
            echo "SUCCESS: [$FN_COMMON] UAN is installed on a system."
        else
            echo "FAIL: [$FN_COMMON] UAN is not installed on a system. Skipping check..."
            echo "[$FN_COMMON] After an automated installation of UAN is done, we need to change exit 123 to exit 1"
            exit 123
        fi
    done

    # Get list of UANs
    if [[ -f /etc/ansible/hosts/hosts-uan ]]; then
        List_UANs=$(cat /etc/ansible/hosts/hosts-uan | grep -v "\[" | grep -v "#")
        if [[ -n $List_UANs ]]; then
            echo "[$FN_COMMON] List of UANs: $List_UANs"
        else
            echo "FAIL: [$FN_COMMON] No UANs on a system"
            exit 1
        fi
    else
        echo "FAIL: [$FN_COMMON] /etc/ansible/hosts/hosts-uan doesn't exit"
        exit 1
    fi
}

# Get WLM version
function GET_WLM_VERSION {
    TEST_CASE_HEADER "Test WLM version"

    WLM_Version=$(rpm -qa | egrep -i "$1")
    if [[ $? == 0 ]]; then
        echo "SUCCESS: $1 version, $WLM_Version"
    else
        echo "FAIL: Cannot get $1 version."
        exit 1
    fi
}

# SLURM functional test
function SLURM_FUNCTIONAL_TEST {

    if [[ $1 == UAN ]]; then
        LOGIN_NODE="$i_uan"
    else
        echo "WARNING: No first argument, UAN, supplied. Skipping check..."
        exit 123
    fi

    if [[ -n $SHARED_FS ]] ; then
        cd $SHARED_FS
    else
        echo "WARNING: An environment variable, SHARED_FS, is not set. Skipping check..."
        exit 123
    fi

    # Second argument is for testing SLURM commands
    if [[ $2 != "" ]]; then
        TEST_CASE_HEADER "Test $2 on $LOGIN_NODE"
        CMD="$2"
        echo "ssh $LOGIN_NODE $CMD"
        ssh $LOGIN_NODE $CMD
        if [[ $? == 0 ]]; then
            echo "SUCCESS: [$FN_COMMON] $CMD works well on $LOGIN_NODE."
        else
            echo "FAIL: [$FN_COMMON] $CMD doesn't work on $LOGIN_NODE." >> $RESULT_TEST
            EXIT_CODE=1
        fi
    else
        echo "WARNING: No second argument, SLURM commands, supplied. Skipping check..."
        exit 123
    fi
}

# PBS functional test
function PBS_FUNCTIONAL_TEST {

    # Second argument is for PBS job script name
    if [[ $2 != "" ]]; then
        PBS_JOB_SCRIPT_NAME="$2"
        PBS_JOB_SCRIPT="$RESOURCES/user/cray-uas-mgr/$PBS_JOB_SCRIPT_NAME"
    else
        echo "WARNING: No second argument, PBS job script name, supplied. Skipping check..."
        exit 123
    fi

    # First argument is UAN
    if [[ $1 == UAN ]]; then
        LOGIN_NODE="$i_uan"
        # rsync Cray init script to shared file system in UAN
        if [[ -f $CRAY_INIT_UAS_SCRIPT ]]; then
            # rysnc cray-init-uas.sh to shared file system in UAN
            echo "rsync -rz $CRAY_INIT_UAS_SCRIPT $LOGIN_NODE:$CT_SHARED_FS"
            rsync -rz $CRAY_INIT_UAS_SCRIPT $LOGIN_NODE:$CT_SHARED_FS
        else
            echo "WARNING: Cannot find $CRAY_INIT_UAS_SCRIPT. Skipping check..."
            exit 123
        fi

        # rsync PBS job script to shared file system in UAN
        if [[ -f $PBS_JOB_SCRIPT ]]; then
            echo "rsync -rz $PBS_JOB_SCRIPT $LOGIN_NODE:$CT_SHARED_FS"
            rsync -rz $PBS_JOB_SCRIPT $LOGIN_NODE:$CT_SHARED_FS
        else
            echo "WARNING: Cannot find $PBS_JOB_SCRIPT. Skipping check..."
            exit 123
        fi
    else
        echo "WARNING: No first argument, UAN, supplied. Skipping check..."
        exit 123
    fi

    # Submits PBS job
    TEST_CASE_HEADER "Test qsub <job script> on $LOGIN_NODE"
    ssh $LOGIN_NODE which qsub
    if [[ $? == 0 ]]; then
        if [[ -f $PBS_JOB_SCRIPT ]]; then
            echo "[$FN_COMMON]: Found $PBS_JOB_SCRIPT"

            # Make sure that PBS job script exists in UAN/UAI
            ssh $LOGIN_NODE ls -l $CT_SHARED_FS/$PBS_JOB_SCRIPT_NAME
            if [[ $? == 0 ]]; then
                # qsub PBS job script
                CMD="qsub $CT_SHARED_FS/$PBS_JOB_SCRIPT_NAME"
                echo "ssh $LOGIN_NODE $CMD"

                # Get job ID
                PBS_JOB_ID=$(ssh $LOGIN_NODE $CMD)
                if [[ $? == 0 ]]; then
                    echo "SUCCESS: [$FN_COMMON] Job id is $PBS_JOB_ID for $CMD on $LOGIN_NODE."
                else
                    echo "FAIL: [$FN_COMMON] No job id found for $CMD on $LOGIN_NODE." >> $RESULT_TEST
                    EXIT_CODE=1
                fi
            else
                echo "FAIL: [$FN_COMMON] $CT_SHARED_FS/$PBS_JOB_SCRIPT_NAME doesn't exist on $LOGIN_NODE. Skipping check..."
                exit 123
            fi
        else
            echo "FAIL: [$FN_COMMON] $PBS_JOB_SCRIPT doesn't exist. Skipping check..."
            exit 123
        fi
    else
        echo "FAIL: [$FN_COMMON] qsub doesn't exist on $LOGIN_NODE." >> $RESULT_TEST
        EXIT_CODE=1
    fi

    # Shows the status of PBS jobs
    TEST_CASE_HEADER "Test qstat -f <job id> on $LOGIN_NODE"
    if [[ -n $PBS_JOB_ID ]]; then
        # Test qstat -f
        CMD="qstat -f $PBS_JOB_ID"

        # Get job state
        CMD_JOB_STATE="qstat -f $PBS_JOB_ID | grep job_state | awk '{print \$3}'"
        echo "ssh $LOGIN_NODE $CMD"
        ssh $LOGIN_NODE $CMD
        if [[ $? == 0 ]]; then
            echo "SUCCESS: [$FN_COMMON] $CMD works well on $LOGIN_NODE"
            for ((try = 1; try <= $MAX_TRY; try++))
            do
                # Make sure that job state is R
                # R means a job is running
                echo "ssh $LOGIN_NODE $CMD_JOB_STATE"
                JOB_STATE=$(ssh $LOGIN_NODE $CMD_JOB_STATE)
                if [[ $JOB_STATE == "R" ]]; then
                    echo "Try: $try"
                    echo "SUCCESS: [$FN_COMMON] $PBS_JOB_ID is running state, $JOB_STATE"
                    echo "ssh $LOGIN_NODE qstat"
                    ssh $LOGIN_NODE qstat
                    break;
                fi
            done

            if ((try > MAX_TRY))
            then
                echo "Try: $try"
                echo "FAIL: [$FN_COMMON] $PBS_JOB_ID is not running state, Job State: $JOB_STATE" >> $RESULT_TEST
                EXIT_CODE=1
            fi
        else
            echo "FAIL: [$FN_COMMON] $CMD doesn't work on $LOGIN_NODE" >> $RESULT_TEST
            EXIT_CODE=1
        fi
    else
        echo "FAIL: [$FN_COMMON] No job id found for $CMD on $LOGIN_NODE." >> $RESULT_TEST
        EXIT_CODE=1
    fi

    # Deletes PBS job
    TEST_CASE_HEADER "Test qdel <job id> on $LOGIN_NODE"
    local_max_try=25
    CMD="qdel $PBS_JOB_ID"
    echo "ssh $LOGIN_NODE $CMD"
    ssh $LOGIN_NODE $CMD
    if [[ $? == 0 ]]; then
        for ((try = 1; try <= $local_max_try; try++))
        do
            # Verify that job state is not R anymore after deleting the job
            JOB_STATE=$(ssh $LOGIN_NODE $CMD_JOB_STATE)
            if [[ $JOB_STATE != "R" ]]; then
                echo "Try: $try"
                echo "SUCCESS: [$FN_COMMON] $PBS_JOB_ID is deleted by $CMD. Job State: $JOB_STATE"
                break;
            fi
        done

        if ((try > local_max_try))
        then
            echo "Try: $try"
            echo "FAIL: [$FN_COMMON] $PBS_JOB_ID is not deleted by $CMD" >> $RESULT_TEST
            echo "ssh $LOGIN_NODE qstat"
            ssh $LOGIN_NODE qstat
            EXIT_CODE=1
        fi
    else
        echo "FAIL: [$FN_COMMON] $CMD doesn't work on $LOGIN_NODE" >> $RESULT_TEST
        EXIT_CODE=1
    fi
}

# Check a final result
function CHECK_FINAL_RESULT {
    if [[ -n $RESULT_TEST ]]; then
        echo ""
        grep FAIL $RESULT_TEST
        if [[ $? == 0 ]]; then
            EXIT_CODE=1
        fi
    else
        echo "WARNING: A result file doesn't exist. Skipping check..."
        EXIT_CODE=123
    fi

    echo ""
    echo -n "EXIT_CODE: $EXIT_CODE - "
    if [[ $EXIT_CODE == 0 ]]; then
        echo "SUCCESS: All test cases passed"
    elif [[ $EXIT_CODE == 123 ]]; then
        echo "Skipping check due to known issues."
    else
        echo "FAIL: At least one of test cases failed"
    fi

    exit $EXIT_CODE
}