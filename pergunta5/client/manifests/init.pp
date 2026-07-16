class client (
  String $client_name,
  String $domain,
) {
  include client::webstack

  class { 'client::vhost':
    client_name => $client_name,
    domain      => $domain,
  }

  class { 'client::wordpress':
    client_name => $client_name,
    domain      => $domain,
  }
}
