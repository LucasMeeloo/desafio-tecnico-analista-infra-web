class client::vhost (
  String $client_name,
  String $domain,
) {
  $docroot = "/var/www/${domain}/htdocs"

  # Cria o usuário do cliente sem acesso a shell por segurança
  user { $client_name:
    ensure     => present,
    managehome => true,
    shell      => '/bin/false',
  }

  # Cria a estrutura de pastas e garante a posse correta
  file { ["/var/www/${domain}", $docroot]:
    ensure  => directory,
    owner   => $client_name,
    group   => $client_name,
    mode    => '0755',
    require => User[$client_name],
  }

# Gera o Virtual Host a partir de um template e notifica o Nginx
  file { "/etc/nginx/conf.d/${domain}.conf":
    ensure  => file,
    content => template('client/nginx_vhost.erb'),
    require => Package['nginx'],
    notify  => Service['nginx'], 
  }
}
