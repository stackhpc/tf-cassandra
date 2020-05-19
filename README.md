Example of using [Terraform](https://www.terraform.io/) with Ansible-deployed Cassandra DB using [`ansible-cassandra`](https://github.com/wireapp/ansible-cassandra).

**NB: This is for teaching purposes only and is NOT intended as a production deployment.**

# Deployment Host Setup

The host we're using for the workshop already has several things set up:
- `git`, `python`, `pip`, `virtualenv`, `wget` and `unzip` installed.
- A virtualenv at `~/venv` which has `openstacksdk` and `ansible` installed.
- `terraform` installed.
- An openstack rc file and a `~/.config/openstack/clouds.yaml` file to authenticate against openstack.
- Ansible galaxy roles downloaded to `~/.ansible/roles`
- An ssh keypair at `~/.ssh/id_rsa{.pub}`.

To avoid treading on other's work, create your own directory and work in that:

    cd
    . ~/venv/bin/activate   # makes openstack and ansible available
    mkdir <yourname>
    cd <yourname>
    git clone https://github.com/stackhpc/tf-cassandra.git   # this repo
    cd tf-cassandra

Clone the cassandra role and install its requirements into a local directory:
```shell
mkdir roles
git clone https://github.com/wireapp/ansible-cassandra.git roles/ansible-cassandra
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

1. In `group_vars/all.yml`, change `instance_prefix` to your name.

2. Deploy infrastructure using Terraform:

        terraform init
        terraform plan
        terraform apply

   This will generate a file `./inventory`.

3. Install and configure software using Ansible:
    
        . ~/venv/bin/activate
        ansible-playbook -i inventory install.yml

4. To log in to the cluster use:

        ssh centos@<ssh_proxy>

   where `ssh_proxy` is given in the inventory.

To destroy the cluster when done:
```shell
terraform destroy
```

# Usage

The role configures Cassadnra's `cqlsh` CLI tool to connect to the clsuter automatically. So you can log in to a node (as described above) then just run:

    cqlsh

See https://cassandra.apache.org/doc/latest/tools/cqlsh.html for reference.
