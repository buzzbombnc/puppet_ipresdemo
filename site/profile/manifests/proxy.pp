class profile::proxy (
    String $cluster_name
)
{
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
}
