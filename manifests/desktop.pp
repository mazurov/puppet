$local_files="/home/amazurov/UbuntuOne/System/Puppet/files"

define apt::key($ensure, $apt_key_url = "http://www.example.com/apt/keys", $uid = "") {
        case $ensure {
                "present": {
                        exec { "apt-key present $name":
                                command => "/usr/bin/wget -q $apt_key_url -O -|/usr/bin/apt-key add -",
                                unless => "/usr/bin/apt-key list|/bin/grep -c $uid",
                        }
                }
                "absent": {
                        exec { "apt-key absent $name":
                                command => "/usr/bin/apt-key del $uid",
                                onlyif => "/usr/bin/apt-key list|/bin/grep -c $uid",
                        }
                }
                default: {
                        fail "Invalid 'ensure' value '$ensure' for apt::key"
                }
        }
}

define apt::key_from_server($ensure, $apt_key_url = "keyserver.ubuntu.com", $uid = "") {
        case $ensure {
                "present": {
                        exec { "apt-key present $name":
                                command => "/usr/bin/apt-key adv --keyserver $apt_key_url --recv-keys $uid",
                                unless => "/usr/bin/apt-key list|/bin/grep -c $uid",
                        }
                }
                "absent": {
                        exec { "apt-key absent $name":
                                command => "/usr/bin/apt-key del $uid",
                                onlyif => "/usr/bin/apt-key list|/bin/grep -c $uid",
                        }
                }
                default: {
                        fail "Invalid 'ensure' value '$ensure' for apt::key_from_server"
                }
        }
}


file { "/etc/apt/sources.list":
        owner => "root",
        group => "root",
        mode => 0444,
        content => template("etc_apt_sources.list.erb"),
}

file { "/home/amazurov/.bashrc":
        owner => "amazurov",
        group => "amazurov",
        mode => 0660,
        source => "file://${local_files}/dotfiles/bashrc"
}


apt::key {"google":
	ensure => "present",
	apt_key_url => "https://dl-ssl.google.com/linux/linux_signing_key.pub",
	uid =>  "7FAC5991"
}

apt::key {"virtualbox":
	ensure => "present",
	apt_key_url => "http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc",
	uid =>  "98AB5139"
}

apt::key_from_server{"guido-iodice":
	ensure => "present",
	uid =>  "666270B8"
}

apt::key_from_server{"dropbox":
	ensure => "present",
	apt_key_url => "pgp.mit.edu",
	uid =>  "5044912E"
}



exec{"/usr/bin/apt-get update":
	refreshonly => true,
        subscribe => File["/etc/apt/sources.list"],
        require => [File["/etc/apt/sources.list"], Exec["apt-key present google"], Exec["apt-key present virtualbox"], Exec["apt-key present dropbox"], Exec["apt-key present guido-iodice"]]
}

package { ["skype","google-chrome-beta", "flashplugin-installer", "git", "subversion", "mc", "vim", "rubygems1.8","virtualbox-4.0", "libboost1.46-all-dev", "keepassx", "nautilus-dropbox"]:
	ensure => installed
}

package { ["vagrant"]:
	ensure => "installed",
	provider => "gem",
	require => Package["rubygems1.8"]
}


