class hardening {

  include hardening::params
  include hardening::partitions
  include hardening::grub
  include hardening::boot
  include hardening::limits
  include hardening::sysctl
  include hardening::packages
  include hardening::services
  include hardening::noipv6
  include hardening::interfaces
  include hardening::cronconf
  include hardening::authconf

}
