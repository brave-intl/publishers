namespace :ssl do
  task :generate => [ :environment ] do
    sh 'which openssl' do |ok, res|
      if ! ok
        puts "The `openssl` executable is not available. Please manually generate a key `ssl/server.key` and certificate `ssl/server.crt`."
      else
        sh 'openssl genrsa -out ssl/server.key 4096'
        sh "echo \"openssl req -new -key ssl/server.key -x509 -nodes -new -out ssl/server.crt -subj /CN=localhost.ssl -reqexts SAN -extensions SAN -config <(cat /System/Library/OpenSSL/openssl.cnf <(printf '[SAN]\\nsubjectAltName=DNS:localhost.ssl')) -sha256 -days 3650\" | bash"
      end
    end
  end

  task :install => [ :environment ] do
    sh 'which security' do |ok, res|
      if ! ok
        puts "The `securty` executable is not available. Please manually trust the certificates in `ssl/`."
      else
        sh 'security add-trusted-cert -d -r trustRoot -k ~/Library/Keychains/login.keychain ssl/server.crt'
      end
    end
  end
end
