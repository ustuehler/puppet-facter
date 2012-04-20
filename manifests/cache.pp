# Maintain a cache of facts
#
# Running facter can take too long to do it synchronously in MCollective
# or other tools, so we maintain a cache of facts asynchronously via a
# cron job that runs every 10 minutes, by default.  Another way to update
# the cache of facts is to notify this class, as in the following example:
#
#  include facter::cache
#  include facter::facts_d
#
#  file { "${facter::facts_d::path}/my_facts.txt":
#    ensure  => present,
#    content => "puppet_environment=${::environment}\n",
#    notify  => Class['facter::cache']
#  }
#
# == Parameters
#
# - *ensure_cron*: Whether to install or remove the cron job: +present+
#   or +absent+, respectively.
# - *minute*: Minute(s) of the hour at which the cache should be
#   updated by the cron job.  The value is passed directly to the
#   'cron' resource, which see.  (Default: every ten minutes)
#
# == Variables
#
# - *facts_yaml*: Full path to the cached facts in YAML format.
# - *path*: Base directory for all files in the cache.
#
# == Facts
#
# - *operatingsystem*: *path* is chosen based on the operating system.
class facter::cache($ensure_cron = present,
  $minute = [10, 20, 30, 40, 50])
{
  include facter::facts_d

  case $::operatingsystem {
    Debian, Ubuntu: {
      $path = '/var/cache/facter'

      file { $path:
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0755'
      }
    }

    default: {
      fail("${::operatingsystem} is currently unsupported")
    }
  }

  $facts_yaml = "${path}/facts.yaml"
  $update_yaml = "/bin/sh -c 'facter --puppet --yaml >${facts_yaml}.tmp && mv -f ${facts_yaml}.tmp ${facts_yaml}'"

  exec { "${name}/facts_yaml":
    command     => $update_yaml,
    logoutput   => on_failure,
    refreshonly => true,
    subscribe   => Class['facter::facts_d']
  }

  cron { $name:
    ensure  => $ensure_cron,
    command => $update_yaml,
    minute  => $minute
  }
}
