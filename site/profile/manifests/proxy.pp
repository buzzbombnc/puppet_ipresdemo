class profile::proxy (
    String $cluster_name
)
{
    class { "apache" : }
    class { "apache::mod::proxy" : }
}

