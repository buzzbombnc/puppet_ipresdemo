class profile::proxy (
    String $cluster_name = lookup('profile::cluster_name', String)
)
{
    # Apache and proxy configuration.
    class { "apache" :
        default_vhost => false,
    }
    class { "apache::mod::proxy" : }
    apache::vhost { "default_proxy":
        port => 80,
        docroot => '/var/www/html',
        proxy_pass => [
            { 'path' => '/app', 'url' => "balancer://$cluster_name" }
        ],
    }

    apache::balancer { "$cluster_name":
        require => Class['apache::mod::proxy'],
    }
    
    # Firewall configuration.
    class { "firewalld" : }
    
    firewalld_service { 'http' :
        ensure => 'present',
        service => 'http',
        zone   => 'public',
    }
    
    # Allow Apache to make proxy connections if selinux is running.
    if $facts['os']['selinux']['enabled'] {
        include selinux
        selinux::boolean { 'httpd_can_network_connect': }
    }
}
