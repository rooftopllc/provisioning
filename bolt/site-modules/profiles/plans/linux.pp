plan profiles::linux(
  TargetSpec $targets,
) {
  $targets.apply_prep

  apply($targets) {
    include lookup('puppet_classes')

    user { 'andrew':
      comment => "Andrew Forgue",
      require => Class['fish'],
    }

    file { [ dirname($facts['puppet_vardir']), $facts['puppet_vardir'] ]:
      ensure => directory,
      before => Class['letsencrypt'],
    }

    letsencrypt::certonly { $fqdn: }

    package { ['ssl-cert', 'tmux', 'vim-tiny']:
      ensure => latest,
    }

    apt::setting {
      'conf-noreccommends':
        priority => 99,
        content  => @("EOF"/L)
         APT::Install-Suggests "0";
         APT::Install-Reccomends "0";
        | EOF
    }

    # Switch to systemd-timesyncd
    service { 'ntp':
      ensure => stopped,
    } -> package { 'ntp':
      ensure => purged,
      before => Class['systemd'],
    }
  }
}
