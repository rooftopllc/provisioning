plan profiles::kube_api_server(
  TargetSpec $targets,
  Hash $master_certificate_data,
  Hash $kubelet_client_certificate_data,
  String $secret_signing_key,
) {
  $targets.apply_prep

  apply($targets) {
    $interface = lookup("primary_interface.'${fqdn}'")

    $etcd_servers = "https://etcd.rtnet.io:2379"
    $address = $::facts['networking']['interfaces'][$interface]['ip6']
    $service_cluster_ip_range = "fd00::/108"

    package { 'kubernetes-master':
      ensure => '1.18.2-3',
      notify  => Service["kube-apiserver"],
    }

    file { '/etc/kubernetes':
      ensure => directory,
    }

    file { '/etc/kubernetes/pki':
      ensure => directory,
    }

    file { '/etc/kubernetes/pki/apiserver-ca.pem':
      ensure  => file,
      content => $master_certificate_data["data"]["issuing_ca"],
      notify  => Service["kube-apiserver"],
    }

    file { '/etc/kubernetes/pki/apiserver.key':
      ensure  => file,
      content => Sensitive($master_certificate_data["data"]["private_key"]),
      notify  => Service["kube-apiserver"],
    }

    file { '/etc/kubernetes/pki/apiserver.crt':
      ensure  => file,
      content => $master_certificate_data["data"]["certificate"],
      notify  => Service["kube-apiserver"],
    }

    file { '/etc/kubernetes/pki/apiserver-kubelet-client-ca.pem':
      ensure  => file,
      content => $kubelet_client_certificate_data["data"]["issuing_ca"],
      notify  => Service["kube-apiserver"],
    }

    file { '/etc/kubernetes/pki/apiserver-kubelet-client.key':
      ensure  => file,
      content => Sensitive($kubelet_client_certificate_data["data"]["private_key"]),
      notify  => Service["kube-apiserver"],
    }

    file { '/etc/kubernetes/pki/apiserver-kubelet-client.crt':
      ensure  => file,
      content => $kubelet_client_certificate_data["data"]["certificate"],
      notify  => Service["kube-apiserver"],
    }

    file { '/etc/kubernetes/pki/apiserver-secret-signing-key.key':
      ensure  => file,
      content => $secret_signing_key,
      notify  => Service["kube-apiserver"],
    }

    systemd::unit_file { 'kube-apiserver.service':
      notify  => Service["kube-apiserver"],
      content => @("EOF"/L)
        [Unit]
        Description=Kubernetes API Server

        [Service]
        WorkingDirectory=/var/lib/kubelet
        ExecStart=/usr/bin/kube-apiserver \\
            --etcd-servers ${etcd_servers} \\
            --bind-address ${address} \\
            --service-cluster-ip-range ${service_cluster_ip_range} \\
            --port=0 \\
            --allow-privileged \\
            --tls-cert-file /etc/kubernetes/pki/apiserver.crt \\
            --tls-private-key-file /etc/kubernetes/pki/apiserver.key \\
            --client-ca-file /etc/kubernetes/pki/apiserver-ca.pem \\
            --kubelet-certificate-authority /etc/kubernetes/pki/apiserver-kubelet-client-ca.pem \\
            --kubelet-client-certificate /etc/kubernetes/pki/apiserver-kubelet-client.crt \\
            --kubelet-client-key /etc/kubernetes/pki/apiserver-kubelet-client.key \\
            --service-account-key-file /etc/kubernetes/pki/apiserver-secret-signing-key.key \\
            --v=2
       | EOF
    }

    service { 'kube-apiserver':
      ensure => running,
    }
  }
}
