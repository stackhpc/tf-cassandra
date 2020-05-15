Example of using [Terraform](https://www.terraform.io/) with Ansible-deployed Cassandra DB using [`ansible-cassandra`](https://github.com/wireapp/ansible-cassandra).

**NB: This is for teaching purposes only and is NOT intended as a production deployment.**

# Setup Deployment Environment

Your deployment environment should have the following commands available:
- `git`
- `python`
- `pip`
- `virtualenv`
- `wget`
- `unzip`

If on centos7 with sudo rights you can run:

```shell
sudo yum install -y epel-release
sudo yum install -y git
sudo yum install -y python-pip
sudo pip install -U pip # updates pip
sudo pip install virtualenv
sudo yum install -y wget
sudo yum install -y unzip
```

Now clone this repo:
```shell
git clone git@github.com:stackhpc/tf-cassandra.git
```

Make and activate a virtualenv, then install ansible, the openstack sdk and an selinux shim via `pip`:
```shell
cd tf-cassandra
virtualenv .venv
. .venv/bin/activate
pip install -U pip
pip install -U -r requirements.txt # ansible, openstack sdk and selinux shim
```

Clone the cassandra role and install its requirements into a local directory:
```shell
mkdir roles
git clone git@github.com:wireapp/ansible-cassandra.git roles/ansible-cassandra
ansible-galaxy install --roles-path roles/ -r roles/ansible-cassandra/molecule/default/requirements.yml
```

Modify the cassandra role to fix a missing package:
- Edit `roles/ansible-cassandra/defaults/RedHat.yml`
- Change `jemalloc` to `memkind.x86_64`

Install terraform:
```shell
cd
wget https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_linux_amd64.zip
unzip terraform*.zip
sudo cp terraform /bin # or ~/.bin or wherever is on your path
```

Create a [`clouds.yaml`](https://docs.openstack.org/openstacksdk/latest/user/config/configuration.html#config-files) file with your credentials for the Openstack project to use - see `clouds.yaml.example` if necessary.

# Deployment and Configuration

If you want to use a new ssh keypair to connect to the nodes, create it now.

Modify `group_vars/all.yml` appropriately then deploy infrastructure using Terraform:

```shell
cd tf-cassandra
terraform init
terraform plan
terraform apply
```

Then install and configure nodes using Ansible:
```shell
. .venv/bin/activate
ansible-playbook -i inventory install.yml
```

This will generate a file `inventory`.

To log in to the cluster:
```shell
ssh <ansible_ssh_common_args> centos@<node_ip>
```
where:
- `ansible_ssh_common_args` is given in the `inventory`
- `node_ip` is from the `ansible_host` parameter for relevant node in the `inventory`

To destroy the cluster when done:
```shell
terraform destroy
```

# Usage

The role configures Cassadnra's `cqlsh` CLI tool to connect to the clsuter automatically. So you can log in to a node (as described above) then just run:

    cqlsh

See https://cassandra.apache.org/doc/latest/tools/cqlsh.html for reference.
