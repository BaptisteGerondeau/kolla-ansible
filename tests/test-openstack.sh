#!/bin/bash

set -o xtrace
set -o errexit
set -o pipefail

# Enable unbuffered output for Ansible in Jenkins.
export PYTHONUNBUFFERED=1

function test_smoke {
    openstack --debug compute service list
    openstack --debug network agent list
}

function test_instance_boot {
    echo "TESTING: Server creation"
    openstack server create --wait --image cirros --flavor m1.tiny --key-name mykey --network demo-net kolla_boot_test
    openstack --debug server list
    # If the status is not ACTIVE, print info and exit 1
    if [[ $(openstack server show kolla_boot_test -f value -c status) != "ACTIVE" ]]; then
        echo "FAILED: Instance is not active"
        openstack --debug server show kolla_boot_test
        return 1
    fi
    echo "SUCCESS: Server creation"

    if [[ $ACTION =~ "ceph" ]] || [[ $ACTION == "cinder-lvm" ]]; then
        echo "TESTING: Cinder volume attachment"
        openstack volume create --size 2 test_volume
        attempt=1
        while [[ $(openstack volume show test_volume -f value -c status) != "available" ]]; do
            echo "Volume not available yet"
            attempt=$((attempt+1))
            if [[ $attempt -eq 10 ]]; then
                echo "Volume failed to become available"
                openstack volume show test_volume
                return 1
            fi
            sleep 10
        done
        openstack server add volume kolla_boot_test test_volume --device /dev/vdb
        attempt=1
        while [[ $(openstack volume show test_volume -f value -c status) != "in-use" ]]; do
            echo "Volume not attached yet"
            attempt=$((attempt+1))
            if [[ $attempt -eq 10 ]]; then
                echo "Volume failed to attach"
                openstack volume show test_volume
                return 1
            fi
            sleep 10
        done
        openstack server remove volume kolla_boot_test test_volume
        attempt=1
        while [[ $(openstack volume show test_volume -f value -c status) != "available" ]]; do
            echo "Volume not detached yet"
            attempt=$((attempt+1))
            if [[ $attempt -eq 10 ]]; then
                echo "Volume failed to detach"
                openstack volume show test_volume
                return 1
            fi
            sleep 10
        done
        openstack volume delete test_volume
        echo "SUCCESS: Cinder volume attachment"
    fi

    echo "TESTING: Server deletion"
    openstack server delete --wait kolla_boot_test
    echo "SUCCESS: Server deletion"
}

function check_dashboard {
    # Query the dashboard, and check that the returned page looks like a login
    # page.
    DASHBOARD_URL=${OS_AUTH_URL%:*}
    output_path=$1
    if ! curl --include --location --fail $DASHBOARD_URL > $output_path; then
        return 1
    fi
    if ! grep Login $output_path >/dev/null; then
        return 1
    fi
}

function test_dashboard {
    echo "TESTING: Dashboard"
    # The dashboard has been known to take some time to become accessible, so
    # use retries.
    output_path=$(mktemp)
    attempt=1
    while ! check_dashboard $output_path; do
        echo "Dashboard not accessible yet"
        attempt=$((attempt+1))
        if [[ $attempt -eq 10 ]]; then
            echo "FAILED: Dashboard did not become accessible. Response:"
            cat $output_path
            return 1
        fi
        sleep 10
    done
    echo "SUCCESS: Dashboard"
}

function test_openstack_logged {
    . /etc/kolla/admin-openrc.sh
    . ~/openstackclient-venv/bin/activate
    test_smoke
    test_instance_boot
    test_dashboard
}

function test_openstack {
    echo "Testing OpenStack"
    log_file=/tmp/logs/ansible/test-openstack
    if [[ -f $log_file ]]; then
        log_file=${log_file}-upgrade
    fi
    test_openstack_logged > $log_file 2>&1
    result=$?
    if [[ $result != 0 ]]; then
        echo "Testing OpenStack failed. See ansible/test-openstack for details"
    else
        echo "Successfully tested OpenStack. See ansible/test-openstack for details"
    fi
    return $result
}

test_openstack
