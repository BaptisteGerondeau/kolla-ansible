#!/bin/bash

set -o xtrace
set -o errexit

# Enable unbuffered output for Ansible in Jenkins.
export PYTHONUNBUFFERED=1

GIT_PROJECT_DIR=$(mktemp -d)

function setup_openstack_clients {
    # Prepare virtualenv for openstack deployment tests
    virtualenv ~/openstackclient-venv
    ~/openstackclient-venv/bin/pip install -U pip
    ~/openstackclient-venv/bin/pip install python-openstackclient
    if [[ $ACTION == zun ]]; then
        ~/openstackclient-venv/bin/pip install python-zunclient
    fi
    if [[ $ACTION == ironic ]]; then
        ~/openstackclient-venv/bin/pip install python-ironicclient
    fi
    if [[ $ACTION == masakari ]]; then
        ~/openstackclient-venv/bin/pip install python-masakariclient
    fi
}

function setup_config {
    if [[ $ACTION != "bifrost" ]]; then
        GATE_IMAGES="cron,fluentd,glance,haproxy,keepalived,keystone,kolla-toolbox,mariadb,memcached,neutron,nova,openvswitch,rabbitmq,horizon,chrony,heat,placement"
    else
        GATE_IMAGES="bifrost"
    fi

    if [[ $ACTION =~ "ceph" ]]; then
        GATE_IMAGES+=",ceph,cinder"
    fi

    if [[ $ACTION == "cinder-lvm" ]]; then
        GATE_IMAGES+=",cinder,iscsid,tgtd"
    fi

    if [[ $ACTION == "zun" ]]; then
        GATE_IMAGES+=",zun,kuryr,etcd"
    fi

    if [[ $ACTION == "scenario_nfv" ]]; then
        GATE_IMAGES+=",tacker,mistral,redis,barbican"
    fi
    if [[ $ACTION == "ironic" ]]; then
        GATE_IMAGES+=",dnsmasq,ironic,iscsid"
    fi
    if [[ $ACTION == "masakari" ]]; then
        GATE_IMAGES+=",masakari"
    fi

    cat <<EOF | sudo tee /etc/kolla/kolla-build.conf
[DEFAULT]
namespace = lokolla
base = ${BASE_DISTRO}
install_type = ${INSTALL_TYPE}
tag = ${TAG}
profile = gate
registry = 127.0.0.1:4000
push = true
logs_dir = /tmp/logs/build
template_override = /etc/kolla/template_overrides.j2

[profiles]
gate = ${GATE_IMAGES}
EOF

    mkdir -p /tmp/logs/build
}

function setup_ansible {
    RAW_INVENTORY=/etc/kolla/inventory

    # Test latest ansible version on Ubuntu, minimum supported on others.
    if [[ $BASE_DISTRO == "ubuntu" ]]; then
        ANSIBLE_VERSION=">=2.6"
    else
        ANSIBLE_VERSION="<2.7"
    fi

    # TODO(SamYaple): Move to virtualenv
    sudo pip install -U "ansible${ANSIBLE_VERSION}" "ara<1.0.0"

    sudo mkdir /etc/ansible
    ara_location=$(python -m ara.setup.callback_plugins)
    sudo tee /etc/ansible/ansible.cfg<<EOF
[defaults]
callback_plugins = ${ara_location}
host_key_checking = False
EOF

    # Record the running state of the environment as seen by the setup module
    ansible all -i ${RAW_INVENTORY} -e ansible_user=$USER -m setup > /tmp/logs/ansible/initial-setup
}

function setup_node {
    ansible-playbook -i ${RAW_INVENTORY} -e ansible_user=$USER tools/playbook-setup-nodes.yml
}

function prepare_images {
    if [[ "${BUILD_IMAGE}" == "False" ]]; then
        return
    fi
    sudo docker run -d -p 4000:5000 --restart=always -v /opt/kolla_registry/:/var/lib/registry --name registry registry:2
    pushd "${KOLLA_SRC_DIR}"
    sudo tox -e "build-${BASE_DISTRO}-${INSTALL_TYPE}"
    popd
}

setup_openstack_clients

setup_ansible
setup_config
setup_node

tools/kolla-ansible -i ${RAW_INVENTORY} -e ansible_user=$USER -vvv bootstrap-servers &> /tmp/logs/ansible/bootstrap-servers
prepare_images
