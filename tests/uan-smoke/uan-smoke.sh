#!/bin/bash

# uan-smoke.sh - UAN Smoke
# Copyright 2020 Cray Inc. 

# UAN common functions to test
RESOURCES="/opt/cray/tests/uan-resources"
if [[ -f $RESOURCES/uan-common-lib.sh ]]; then
    echo "source $RESOURCES/uan-common-lib.sh"
    source $RESOURCES/uan-common-lib.sh
else
    echo "FAIL: Cannot find uan-common-lib.sh. Skipping check..."
    exit 123
fi

RESULT_TEST="$PWD/output_${@}$$.txt"
touch $RESULT_TEST

echo "UAN Smoke test" >> $RESULT_TEST
echo "" >> $RESULT_TEST

# Check that UAN is available on a system
# Function IS_UAN_AVAILABLE is defined in $RESOURCES/user/cray-uas-mgr/uas-common-lib.sh
IS_UAN_AVAILABLE

# Verify that ssh UAN works well
for i_uan in $List_UANs
do
    TEST_CASE_HEADER "Verify that ssh UAN cat /etc/motd works well"
    ssh $i_uan cat /etc/motd
    if [[ $? == 0 ]]; then
        echo "SUCCESS: ssh $i_uan cat /etc/motd works well"
    else
        echo "FAIL: ssh $i_uan cat /etc/motd doesn't work." >> $RESULT_TEST
        EXIT_CODE=1
    fi

    TEST_CASE_HEADER "Verify that PE is installed on UAN"
    ssh $i_uan module list
    if [[ $? == 0 ]]; then
        echo "SUCCESS: PE is installed on $i_uan"
    else
        echo "FAIL: PE is not installed on $i_uan" >> $RESULT_TEST
        EXIT_CODE=1
    fi

    TEST_CASE_HEADER "Verify that ping outside of cray network works well on $i_uan"
    # When trying to do ping -c 1 www.hpe.com on UANs,
    # it returns destination unreachable: No route error randomly.
    # To avoid getting the random failure, need to retry in ping
    max_try=20
    for ((try = 1; try <= $max_try; try++))
    do
        echo "ssh $i_uan ping -c 1 www.hpe.com"

        ssh $i_uan ping -c 1 www.hpe.com
        if [[ $? == 0 ]]; then
            echo "Try: $try"
            echo "SUCCESS: ping outside of cray network works well on $i_uan"
            break;
        fi
    done

    if ((try > max_try))
    then
        echo "Try: $try"
        echo "FAIL: Cannot ping outside of cray network on $i_uan" >> $RESULT_TEST
        EXIT_CODE=1
    fi

    TEST_CASE_HEADER "Verify that man pages work for standard Linux/Unix commands on $i_uan"
    ssh $i_uan man ls > /dev/null 2>&1
    if [[ $? == 0 ]]; then
        echo "SUCCESS: man page work for standard Linux/Unix commands on $i_uan"
    else
        echo "WARNING: man page does not work for standard Linux/Unix commands on $i_uan. It is due to a known bug, SKERN-2206. Skipping check..."
        EXIT_CODE=123
    fi

    TEST_CASE_HEADER "Verify that Lustre file system works well on $i_uan"
    # An environment variable, SHARED_FS, must be defined in /opt/cray/tests/bin/ct-uan-create.
    echo "SHARED_FS: $SHARED_FS"
    if [[ -n $SHARED_FS ]] ; then
        echo "ssh $i_uan ls -l $SHARED_FS"
        ssh $i_uan ls -l $SHARED_FS
        if [[ $? == 0 ]]; then
            echo ""
            echo "ssh $i_uan ls -l $MOUNT_FILE"
            ssh $i_uan ls -l $MOUNT_FILE
            if [[ $? == 0 ]]; then
                echo ""
                echo "ssh $i_uan grep -qs $SHARED_FS $MOUNT_FILE"
                ssh $i_uan grep -qs $SHARED_FS $MOUNT_FILE
                if [[ $? == 0 ]]; then
                    echo "SUCCESS: Lustre file system, $SHARED_FS, is mounted on $i_uan"
                else
                    echo "FAIL: Lustre file system, $SHARED_FS, is not mounted on $i_uan" >> $RESULT_TEST
                    EXIT_CODE=1
                fi
            else
                echo "FAIL: /proc/mounts does not exit on $i_uan" >> $RESULT_TEST
                EXIT_CODE=1
            fi
        else
            echo "FAIL: Lustre file system, $SHARED_FS, is not available on $i_uan" >> $RESULT_TEST
            EXIT_CODE=1
        fi
    else
        echo "WARNING: An environment variable, SHARED_FS, is not set. Skipping check..."
        EXIT_CODE=123
    fi

    TEST_CASE_HEADER "Verify that at least one of WLM pods is running on the system"
    # Check that WLM is running on the system
    FIND_WLM

    if [[ $RC_SLURM_POD == 0 && $RC_PBS_POD == 0 ]]; then
        echo "SUCCESS: Both SLURM and PBS pods are running on the system."

        # Test WLM version
        GET_WLM_VERSION "SLURM|PBS"

        # SLURM smoke test
        SLURM_SMOKE_TEST UAN

        # SLURM functional test
        SLURM_FUNCTIONAL_TEST UAN "srun -N 1 hostname"
        SLURM_FUNCTIONAL_TEST UAN "salloc -N 1 hostname"
        SLURM_FUNCTIONAL_TEST UAN "squeue"
        SLURM_FUNCTIONAL_TEST UAN "sacct"
        SLURM_FUNCTIONAL_TEST UAN "sacctmgr list account"

        # PBS smoke test
        PBS_SMOKE_TEST UAN

        # PBS functional test
        PBS_FUNCTIONAL_TEST UAN pbs_uas_test.sh

    elif [[ $RC_SLURM_POD == 0 ]]; then
        echo "SUCCESS: SLURM pod is running on the system"

        # Test SLURM version
        GET_WLM_VERSION SLURM

        # Check that a default UAS image is SLURM
        CHECK_DEFAULT_UAS_IMAGE SLURM

        # SLURM smoke test
        # It is defined in $RESOURCES/user/cray-uas-mgr/uas-common-lib.sh
        SLURM_SMOKE_TEST UAN

        # SLURM functional test
        SLURM_FUNCTIONAL_TEST UAN "srun -N 1 hostname"
        SLURM_FUNCTIONAL_TEST UAN "salloc -N 1 hostname"
        SLURM_FUNCTIONAL_TEST UAN "squeue"
        SLURM_FUNCTIONAL_TEST UAN "sacct"
        SLURM_FUNCTIONAL_TEST UAN "sacctmgr list account"

    elif [[ $RC_PBS_POD == 0 ]]; then
        echo "SUCCESS: PBS pod is running on the system"

        # Test PBS vesion
        GET_WLM_VERSION PBS

        # Check that a default UAS image is PBS
        CHECK_DEFAULT_UAS_IMAGE PBS

        # PBS smoke test
        # It is defined in $RESOURCES/user/cray-uas-mgr/uas-common-lib.sh
        PBS_SMOKE_TEST UAN

        # PBS functional test
        PBS_FUNCTIONAL_TEST UAN pbs_uas_test.sh

    else
        echo "FAIL: No WLM pod is running on the system." >> $RESULT_TEST
        EXIT_CODE=1
    fi
done

# Check a final result
# Function CHECK_FINAL_RESULT is defined in $RESOURCES/user/cray-uas-mgr/uas-common-lib.sh
CHECK_FINAL_RESULT
