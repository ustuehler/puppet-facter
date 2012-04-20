# Manage the facts.d directory for facter
#
# This class manages the facts.d directory and collects all virtual
# facter::fact resources to populate the directory.  You can trigger
# actions on updates of the managed fact values by subscribing to
# this class, as in the following example:
#
#  include facter::facts_d
#
#  notify { $name:
#    message   => "facts have changed",
#    subscribe => Class['facter::facts_d']
#  }
#
# == Variables
#
# - *path*: Absolute path to the facts.d directory.
#
# == Globals
#
# - *operatingsystem*: *path* is operating system-dependent.
#
# == See Also
#
# - facter::fact
class facter::facts_d
{
  case $::operatingsystem {
    Debian, Ubuntu, Solaris: {
      $confdir = '/etc/facter'
      $path    = "${confdir}/facts.d"
      $owner   = 'root'
      $group   = 'root'
    }

    default: {
      fail("${::operatingsystem} is currently unsupported")
    }
  }

  file { $confdir:
    ensure => directory
  }

  file { $path:
    ensure  => directory,
    require => File[$confdir]
  }

  $puppet_txt = "${path}/puppet.txt"

  file_concat { $puppet_txt:
    owner   => $owner,
    group   => $group,
    mode    => '0444',
    require => File[$path]
  }

  Facter::Fact <| |>
  File_fragment <| path == $puppet_txt |>
}
