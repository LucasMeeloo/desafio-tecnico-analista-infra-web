class client::webstack {
  package { ['nginx', 'php-fpm']:
    ensure => installed,
  }

  service { 'nginx':
    ensure  => running,
    enable  => true,
    require => Package['nginx'],
  }

  service { 'php8.1-fpm':
    ensure  => running,
    enable  => true,
    require => Package['php-fpm'],
  }
}
