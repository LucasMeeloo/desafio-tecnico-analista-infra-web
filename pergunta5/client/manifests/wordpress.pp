class client::wordpress (
  String $client_name,
  String $domain,
) {
  $docroot = "/var/www/${domain}/htdocs"

  # Baixa e extrai o WordPress APENAS se o wp-settings.php não existir
  exec { "download_and_extract_wp_${domain}":
    command => "/usr/bin/wget -qO- https://wordpress.org/latest.tar.gz | /bin/tar -xz --strip-components=1 -C ${docroot}",
    creates => "${docroot}/wp-settings.php", # <-- GARANTIA DE IDEMPOTÊNCIA
    user    => $client_name,
    require => File[$docroot],
  }

  # Em produção, usaríamos o wp-cli para instalar o plugin de cache via bash:
  # exec { "install_lscache_${domain}":
  #   command => "/usr/local/bin/wp plugin install litespeed-cache --activate --path=${docroot}",
  #   unless  => "/usr/local/bin/wp plugin is-active litespeed-cache --path=${docroot}",
  #   user    => $client_name,
  #   require => Exec["download_and_extract_wp_${domain}"],
  # }
}
