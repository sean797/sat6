class hardening::packages (

  $remove_pkgs          = $hardening::params::remove_pkgs,
  $remove_pkgs          = $hardening::params::remove_pkgs

) inherits hardening::params {

  if $remove_pkgs {

    $remove_pkg_list=['mcstrans', 'setroubleshoot', 'telnet-server', 'rsh-server', 'rsh', 'ypbind', 'ypserv', 'tftp', 'tftp-server', 'talk', 'talk-server', 'xinetd', 'chargen-dgram', 'chargen-stream', 'daytime-dgram', 'daytime-stream', 'echo-dgram', 'echo-stream', 'tcpmux-server', 'dhcp', 'xorg-x11-server-common']

    package { $remove_pkg_list:
      ensure   => absent,
      provider => 'yum',
    }
  }

  if $install_pkgs {

    $install_pkg_list=['aide']

    package { $install_pkg_list:
      ensure   => "latesT",
      provider => 'yum',
    }
  }

}
