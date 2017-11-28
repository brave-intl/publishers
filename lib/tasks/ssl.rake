namespace :ssl do
  task :generate => [ :environment ] do
    sh 'which openssl' do |ok, res|
      if ! ok
        puts "The `openssl` executable is not available. Please manually generate a key `ssl/server.key` and certificate `ssl/server.crt`."
      else
        sh 'openssl genrsa -out ssl/rootCA.key 4096'
        sh 'echo "openssl req -x509 -new -nodes -key ssl/rootCA.key -sha256 -days 3650 -out ssl/rootCA.pem -config <( cat lib/tasks/ssl/rootCA.cnf )" | bash'
        sh 'echo "openssl req -new -sha256 -nodes -out ssl/server.csr -newkey rsa:4096 -keyout ssl/server.key -config <( cat lib/tasks/ssl/server.csr.cnf )" | bash'
        sh 'openssl x509 -req -in ssl/server.csr -CA ssl/rootCA.pem -CAkey ssl/rootCA.key -CAcreateserial -out ssl/server.crt -days 3650 -sha256 -extfile lib/tasks/ssl/v3.ext'
      end
    end
  end
end
