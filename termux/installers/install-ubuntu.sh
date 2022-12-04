#!/bin/bash

DEPENDENCY_PATH="/data/data/com.termux/files/home/dependency-files"
DEPENDENCY_NAMES="PATHS FORCE_INSTALL"
ETC_HOSTS_CONFIG="127.0.0.1 localhost"
PACKAGES_FOR_HOME="git wget proot vim"
PACKAGES_FOR_ROOT="sudo vim python3-pip"
PIP3_PACKAGES_FOR_ROOT="pillow onnx onnxruntime numpy torchvision"


















PATHS=$(cat << \EOF
#!/bin/bash
HOME_PATH="/data/data/com.termux/files/home"
CLONE_PATH="$HOME_PATH/ubuntu-in-termux"
UBUNTU_PATH="$CLONE_PATH/ubuntu-fs"
ROOT_PATH="$UBUNTU_PATH/root"
BASHRC_PATH="$ROOT_PATH/.bashrc"
OLD_BASHRC_PATH="$HOME_PATH/.bashrc"
EOF
)














FORCE_INSTALL=$(cat << \EOF
#!/bin/bash

MAX_FORCE_INSTALL=0

is_number () {
    (($1 + 0)) &> /dev/null && {
        return 0
    }
}

input=$1
is_number $input && {
    MAX_FORCE_INSTALL=$input
}

is_limited () {
    (($MAX_FORCE_INSTALL != 0)) && {
        return 0
    }
}

is_installed () {
    package_manager=$1
    package=$2
    case $package_manager in
        apt|apt-get) dpkg -s $package &> /dev/null && {
            return 0
        };;
        pip3) python3 -c "import pkgutil, sys; sys.exit(0 if pkgutil.find_loader(\"$package\") else 1)" || pip3 show $package &> /dev/null && {
            return 0
        };;
        *) {
             echo "$package_manager is not defined."
        };;
    esac
}

is_installed_all () {
    package_manager=$1
    shift
    packages=("$@")
    for package in ${packages[@]}; do {
        is_installed $package_manager $package && {
            continue
        }
        return 1
    } done
    return 0
}

announce_force_install_status () {
    echo FORCE_INSTALL
}

get_sudo_string () {
    string=""
    is_installed apt sudo && {
        string=sudo
    }
    echo $string
}

update () {
    package_manager=$1
    sudo=$(get_sudo_string)
    case $package_manager in
        apt|apt-get) {
            yes | $sudo $package_manager update
            yes | $sudo $package_manager upgrade
        };;
        pip3) {
            $sudo pip3 install --upgrade --no-input pip
        };;
        *) {
            echo $package_manager is not defined.
        };;
    esac
}

install () {
    package_manager=$1
    package=$2
    sudo=$(get_sudo_string)
    case $package_manager in
        apt | apt-get) {
            yes | $sudo $package_manager install $package
        };;
        pip3) {
            $sudo pip3 install --upgrade --no-input $package
        };;
        *) {
            echo $package_manager is not defined.
        };;
    esac
}

install_all () {
    package_manager=$1
    shift
    packages=("$@")
    for package in ${packages[@]}; do {
        install $package_manager $package
    } done
}

force_install () {
    package_manager=$1
    shift
    packages=("$@")
    max_i=$MAX_FORCE_INSTALL
    i=0
    while :; do {
        is_limited && (($i >= $max_i)) && {
            break
        }
        is_installed_all $package_manager ${packages[@]} && {
            break
        }
        i=$(($i + 1))
        announce_force_install_status
        update $package_manager
        install_all $package_manager ${packages[@]}
    } done
}
EOF
)













INCLUDE_DEPENDENCIES=$(cat << \EOF

DEPENDENCY_PATH="/data/data/com.termux/files/home/dependency-files"

add_sh_suffix_to () {
    dependency_name=$1
    file_name=${dependency_name}.sh
    echo $file_name
}

include () {
    dependency_name=$1
    file_name=$(add_sh_suffix_to $dependency_name)
    file_path=$DEPENDENCY_PATH/$file_name
    shift
    dependency_args=("$@")
    source $file_path ${dependency_args[@]}
}

include_dependency_scripts () {
    include PATHS
    include FORCE_INSTALL 5
}

include_dependency_scripts
EOF
)


AUTOSTARTER_FOR_ROOT=$(cat << EOF

packages=("$PACKAGES_FOR_ROOT")
pip3_packages=("$PIP3_PACKAGES_FOR_ROOT")

fix_unresolved_hostname_error () {
    config="$ETC_HOSTS_CONFIG"
    etc_hosts_path="/etc/hosts"
    echo "$config" > $etc_hosts_path
}

install_dependency_packages () {
    force_install apt \${packages[@]}
    force_install pip3 \${pip3_packages[@]}
}

fix_
install_dependency_packages
EOF
)


AUTOSTARTER_FOR_HOME=$(cat << \EOF

ubuntu_starter=$CLONE_PATH/startubuntu.sh
bash $ubuntu_starter
EOF
)
















add_sh_suffix_to () {
    dependency_name=$1
    file_name=${dependency_name}.sh
    echo $file_name
}




create_file_for () {
    commands="$1"
    dependency_name=$2
    file_name=$(add_sh_suffix_to $dependency_name)
    file_path=$DEPENDENCY_PATH/$file_name
    touch $file_path
    echo "$commands" > $file_path
    chmod +x $file_path
}

create_dependency_scripts () {
    mkdir -p $DEPENDENCY_PATH
    dependency_names=("$DEPENDENCY_NAMES")
    for dependency_name in ${dependency_names[@]}; do {
        commands="${!dependency_name}"
        create_file_for "$commands" $dependency_name
    } done
}




include () {
    dependency_name=$1
    file_name=$(add_sh_suffix_to $dependency_name)
    file_path=$DEPENDENCY_PATH/$file_name
    shift
    dependency_args=("$@")
    source $file_path ${dependency_args[@]}
}

include_dependency_scripts () {
    include PATHS
    include FORCE_INSTALL 5
}




install_dependency_packages () {
    packages=("$PACKAGES_FOR_HOME")
    force_install apt ${packages[@]}
}




install_ubuntu_root_fs () {
    git clone https://github.com/MFDGaming/ubuntu-in-termux.git $CLONE_PATH
    ubuntu_installer=$CLONE_PATH/ubuntu.sh
    chmod +x $ubuntu_installer
    cd $CLONE_PATH
    yes | bash $ubuntu_installer
}





add_autostarter_scripts () {
    echo "$INCLUDE_DEPENDENCIES" >> $BASHRC_PATH
    echo "$INCLUDE_DEPENDENCIES" >> $OLD_BASHRC_PATH
    echo "$AUTOSTARTER_FOR_ROOT" >> $BASHRC_PATH
    echo "$AUTOSTARTER_FOR_HOME" >> $OLD_BASHRC_PATH
}




start_ubuntu_fs () {
    ubuntu_starter=$CLONE_PATH/startubuntu.sh
    bash $ubuntu_starter
}



get_ubuntu_root_fs () {
    create_dependency_scripts
    include_dependency_scripts
    install_dependency_packages
    install_ubuntu_root_fs
    add_autostarter_scripts
    start_ubuntu_fs
}


get_ubuntu_root_fs
