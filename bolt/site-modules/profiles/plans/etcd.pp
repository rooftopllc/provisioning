plan profiles::etcd(
  TargetSpec $targets,
) {
  $targets.apply_prep

  apply($targets) {

    user { 'etcd':
      groups  => [ 'ssl-cert' ],
      require => Package['etcd'],
      before  => Service['etcd'],
    }

    class { 'etcd':
      ensure                      => 'latest',
      etcd_name                   => $::facts['fqdn'],

      listen_client_urls          => "https://[${::facts['networking']['ip6']}]:2379",
      listen_peer_urls            => "https://[${::facts['networking']['ip6']}]:2380",

      advertise_client_urls       => "https://${::facts['fqdn']}:2379",
      initial_advertise_peer_urls => "https://${::facts['fqdn']}:2380",

      config_file_path            => "/etc/default/etcd",

      initial_cluster             => [
        "${::facts['fqdn']}=https://${::facts['fqdn']}:2380"
      ],

      cert_file                   => "/etc/letsencrypt/live/${::facts['fqdn']}/fullchain.pem",
      key_file                    => "/etc/letsencrypt/live/${::facts['fqdn']}/privkey.pem",

      peer_cert_file              => "/etc/letsencrypt/live/${::facts['fqdn']}/fullchain.pem",
      peer_key_file               => "/etc/letsencrypt/live/${::facts['fqdn']}/privkey.pem",

      client_cert_auth            => false,
      peer_client_cert_auth       => true,
    }
  }
}
