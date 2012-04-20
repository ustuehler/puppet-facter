# Define a custom fact in a text file in the facts.d directory
#
# == Parameters
#
# - *name*: Name of the fact (must be a valid fact name).
# - *value*: Plain-text value of the fact, will not be escaped
#   so be sure to only use simple values.
define facter::fact($value)
{
  include facter::facts_d

  validate_string($facter::facts_d::puppet_txt)
  validate_string($value)
  validate_re($name, '^[A-Za-z_][A-Za-z0-9_]+$')

  @file_fragment { "${facter::facts_d::puppet_txt}/${name}":
    path    => $facter::facts_d::puppet_txt,
    content => "${name}=${value}\n"
  }
}
