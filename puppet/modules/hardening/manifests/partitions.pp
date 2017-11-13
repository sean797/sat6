class hardening::partitions (

  $secure_partitions      = $hardening::params::secure_partitions,

) inherits hardening::params {

  if $secure_partitions {

    file {'file_etc_fstab':
      path  => '/etc/fstab',
      owner => root,
      group => root,
      mode  => '0600',
    }

    mount {'/tmp':
      ensure   => mounted,
      options  => 'nodev,nosuid,noexec',
      pass     => '2',
      remounts => true,
      atboot   => true,
    }

    mount { '/var/tmp':
      ensure  => mounted,
      device  => '/tmp',
      fstype  => 'none',
      options => 'rw,noexec,nosuid,nodev,bind',
      atboot  => true,
    }

    mount {'/home':
      ensure   => mounted,
      options  => 'rw,nodev',
      pass     => '2',
      remounts => true,
      atboot   => true,
    }

    mount {'/dev/shm':
      ensure   => mounted,
      device   => 'tmpfs',
      fstype   => 'tmpfs',
      options  => 'nodev,nosuid,noexec',
      remounts => true,
      atboot   => true,
    }

    mount {'/var':
      pass     => '2',
      remounts => true,
      atboot   => true,
    }

    mount {'/':
      pass     => '1',
      remounts => true,
      atboot   => true,
    }

    mount {'/boot':
      pass     => '2',
      remounts => true,
      atboot   => true,
    }

    file { 'cis_modprobe_file':
      ensure  => present,
      path    => '/etc/modprobe.d/cis.conf',
      source => 'puppet:///modules/hardening/cis_modprobe.conf',
      owner   => root,
      group   => root,
      mode    => '0600',
    }
  }

}
