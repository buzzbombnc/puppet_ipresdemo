class profile::common {
    package { ['git', 'python-virtualenv', 'python-setuptools']:
        ensure => present,
    }
}

