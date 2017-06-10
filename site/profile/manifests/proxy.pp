class profile::proxy (
    String $cluster_name
)
{
    class { "apache" : }
    class { "apache::mod::proxy" : }

    apache::balancer { "$cluster_name":
        require => Class['apache::mod::proxy'],
    }
}
