class profile::worker (
    String $git_repo,
    String $app_user,
    String $app_group,
    String $app_address = '0.0.0.0',
    Integer $app_port = 5000,
    String $app_dir,
    String $app_version = 'HEAD',
)
{
    # Make sure that git is installed.
    package {'git':
        ensure => 'present',
    }

    # Group, User, directory
    group { "$app_group":
        ensure => 'present',
    }
    user { "$app_user":
        ensure => 'present',
        gid    => $app_group,
        home   => $app_dir,
        managehome => true,
    }
    file { "$app_dir":
        ensure => 'directory',
        backup => false,
        group  => $app_group,
        owner  => $app_user,
    }

    # Python
    class { 'python':
        ensure          => 'present',
        version         => 'system',
        pip             => 'present',
        # virtualenv requires the devel components.
        dev             => 'present',
        virtualenv      => 'present',
    }

    # Clone
    vcsrepo { "${app_dir}/src":
        ensure   => 'present',
        provider => 'git',
        source   => $git_repo,
        revision => $app_version,
        user     => $app_user,
        force    => true,
        require  => [
            Package['git'],
            User[$app_user],
        ],
    }

    # Virtualenv
    python::virtualenv { "${app_dir}/virtualenv":
        ensure => 'present',
        version => 'system',
        requirements => "${app_dir}/src/requirements.txt",
        owner        => $app_user,
        group        => $app_group,
        cwd          => "${app_dir}/virtualenv",
        subscribe    => Vcsrepo["${app_dir}/src"],
    }

    # gunicorn.socket
    $_socket_vars = {
        'address' => "${app_address}:${app_port}",
    }

    file { '/etc/systemd/system/gunicorn.socket':
        ensure => 'file',
        content => epp('profile/gunicorn.socket.epp', $_socket_vars),
        group => 'root',
        mode    => '0755',
        owner   => 'root',
        notify  => [
            Exec['systemd reload'],
            Exec['enable socket'],
            Exec['start socket'],
        ],
    }

    # gunicorn.service
    $_service_vars = $_socket_vars + {
        'user'       => $app_user,
        'group'      => $app_group,
        'workdir'    => "${app_dir}/src",
        'virtualenv' => "${app_dir}/virtualenv",
    }

    file { '/etc/systemd/system/gunicorn.service':
        ensure => 'file',
        content => epp('profile/gunicorn.service.epp', $_service_vars),
        group => 'root',
        mode    => '0755',
        owner   => 'root',
        notify  => [
            Exec['systemd reload'],
            Exec['enable service'],
            Exec['start service'],
        ],
    }

    # Service refresh and restart.
    exec { 'systemd reload':
        command     => '/usr/bin/systemctl daemon-reload',
        refreshonly => true,
    }

    exec { 'enable socket':
        command     => '/usr/bin/systemctl enable gunicorn.socket',
        refreshonly => true,
    }

    exec { 'start socket':
        command     => '/usr/bin/systemctl restart gunicorn.socket',
        refreshonly => true,
    }

    exec { 'enable service':
        command     => '/usr/bin/systemctl enable gunicorn.service',
        refreshonly => true,
    }

    exec { 'start service':
        command     => '/usr/bin/systemctl restart gunicorn.service',
        refreshonly => true,
    }
    # Test
    # Gunicorn
    #python::gunicorn {"${hostname}_worker":
    #    ensure => 'present',
    #    virtualenv => "${app_dir}/virtualenv",
    #    mode       => 'wsgi',
    #    dir        => "${app_dir}/src",
    #    bind       => "${app_address}:${app_port}",
    #    subscribe  => Python::Virtualenv["${app_dir}/virtualenv"],
    #}
}

