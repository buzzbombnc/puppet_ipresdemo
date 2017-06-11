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

    # Group, User

    # Python
    # Clone
    # Virtualenv
    # Requirements
    # Test
    # Gunicorn
}

