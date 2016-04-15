# Idr Client

## Documentation
TODO

## Example use

Get roles for subject identifier
```ruby
require 'idr_client'

roles_uri = SoarSc::Providers::ServiceRegistry::find_first_service_uri('idr-staff-get-roles')
idr_client = SoarSc::IdrClient.new(uri)
subject_identifier = 'charles.mulder@hetzner.co.za'
roles = idr_client.ask_idr(subject_identifier)
```

Get attributes for specific role of subject identifier
```ruby
role = 'hetznerPerson'
attributes_uri = SoarSc::Providers::ServiceRegistry::find_first_service_uri('idr-staff-get-attributes')
idr_client = SoarSc::IdrClient.new(uri)
subject_identifier = 'charles.mulder@hetzner.co.za'
attributes = idr_client.ask_idr(subject_identifier, role)
```

## Test

Run unit tests with
```bash
$ rspec
```
