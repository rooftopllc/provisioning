plan profiles::kubelet(
  TargetSpec $targets,
  Hash $kubelet_certificate_data
) {
  $targets.apply_prep

  apply($targets) {
    package { 'kubernetes-node':
      ensure => '1.18.2-3',
    }

    package { 'containerd':
      ensure => '1.3.4~ds1-1',
    }

    package { 'containernetworking-plugins':
      ensure => '0.8.5-1',
    }

    package { 'ipvsadm':
      ensure => installed,
    }

    file { '/etc/kubernetes':
      ensure => directory,
    }

    file { '/etc/kubernetes/pki':
      ensure => directory,
    }

    file { '/etc/kubernetes/pki/ca.pem':
      ensure  => file,
      content => $kubelet_certificate_data["data"]["issuing_ca"],
    }

    file { '/etc/kubernetes/pki/kubelet.key':
      ensure  => file,
      content => Sensitive($kubelet_certificate_data["data"]["private_key"]),
    }

    file { '/etc/kubernetes/pki/kubelet.crt':
      ensure  => file,
      content => $kubelet_certificate_data["data"]["certificate"],
    }

    file { '/etc/kubernetes/kubelet-config':
      notify => Service['kubelet'],
      content => @("EOF"/L)
        apiVersion: kubelet.config.k8s.io/v1beta1
        kind: KubeletConfiguration
        evictionHard:
            memory.available:  "200Mi"
        address: "${::facts['ipaddress6']}"
        cgroupDriver: "systemd"
        authentication:
          x509:
            clientCAFile: "/etc/kubernetes/pki/ca.pem"
        clusterDNS:
          - "fd00::1"
        healthzBindAddress: "${::facts['ipaddress6']}"
        tlsCertFile: "/etc/kubernetes/pki/kubelet.crt"
        tlsPrivateKeyFile: "/etc/kubernetes/pki/kubelet.key"
        | EOF
    }

    file { '/etc/kubernetes/kubelet-kubeconfig':
      notify => Service['kubelet'],
      content => @("EOF"/L)
      apiVersion: v1
      clusters:
      - cluster:
          certificate-authority: /etc/kubernetes/pki/ca.pem
          server: https://kube.rtnet.io:6443
        name: rooftop
      contexts:
      - context:
          cluster: rooftop
          user: kubelet
        name: system
      current-context: "system"
      kind: Config
      preferences: {}
      users:
      - name: kubelet
        user:
          client-certificate: /etc/kubernetes/pki/kubelet.crt
          client-key: /etc/kubernetes/pki/kubelet.key
      | EOF
    }

    systemd::unit_file { 'kubelet.service':
      content => @("EOF"/L)
        [Unit]
        Description=Kubernetes Kubelet
        Wants=containerd.service

        [Service]
        WorkingDirectory=/var/lib/kubelet
        ExecStart=/usr/bin/kubelet \\
            --config /etc/kubernetes/kubelet-config \\
            --kubeconfig /etc/kubernetes/kubelet-kubeconfig \\
            --hostname-override ${::facts["fqdn"]} \\
            --container-runtime remote \\
            --container-runtime-endpoint unix:///run/containerd/containerd.sock
       | EOF
    }

    service { 'kubelet':
      ensure => running,
    }
  }
}
