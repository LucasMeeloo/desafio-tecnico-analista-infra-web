class client::webstack {
  # Instala Nginx e um worker PHP genérico (simulando o LSPHP)
  package { ['nginx', 'php-fpm']:
    ensure => installed,
  }

  service { 'nginx':
    ensure  => running,
    enable  => true,
    require => Package['nginx'],
  }
}
