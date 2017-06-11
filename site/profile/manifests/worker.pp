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
        gid    => "$app_group",
        home   => "$app_dir",
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
        #gunicorn        => 'present',
        #manage_gunicorn => true,
    }

    # Clone
    vcsrepo { "${app_dir}/src":
        ensure   => 'present',
        provider => 'git',
        source   => "$git_repo",
        revision => "$app_version",
        user     => "$app_user",
        force    => true,
        require  => [
            Package['git'],
            User["$app_user"],
        ],
    }

    # Virtualenv
    # Requirements
    # Test
    # Gunicorn
}

