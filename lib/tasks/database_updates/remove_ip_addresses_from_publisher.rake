namespace :database_updates do
  task remove_ip_addresses_from_publisher: [:environment] do
    Publisher.update_all(current_sign_in_ip: nil, last_sign_in_ip: nil)
  end
end
