class client::wordpress (
  String $client_name,
  String $domain,
) {
  $docroot = "/var/www/${domain}/htdocs"

  # Baixa e extrai o WordPress APENAS se o wp-settings.php não existir
  exec { "download_and_extract_wp_${domain}":
    command => "/usr/bin/wget -qO- https://wordpress.org/latest.tar.gz | /bin/tar -xz --strip-components=1 -C ${docroot}",
    creates => "${docroot}/wp-settings.php",
    user    => $client_name,
    require => File[$docroot],
  }

  # Cria o wp-config.php a partir do sample e INJETA a ativação do cache
  exec { "enable_wp_cache_${domain}":
    command => "/bin/cp ${docroot}/wp-config-sample.php ${docroot}/wp-config.php && /bin/sed -i \"1 a define('WP_CACHE', true);\" ${docroot}/wp-config.php",
    creates => "${docroot}/wp-config.php", # Idempotência: só roda se o config não existir
    user    => $client_name,
    require => Exec["download_and_extract_wp_${domain}"],
  }
}
