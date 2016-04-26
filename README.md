# Idr Client

## Documentation
TODO

## Example use

Get roles for subject identifier
```ruby
idr_client = SoarSc::IdrClient.new
idr_client.roles_uri = SoarSc::Providers::ServiceRegistry::find_first_service_uri('idr-staff-get-roles')
subject_identifier = 'charles.mulder@hetzner.co.za'
roles = idr_client.get_roles(subject_identifier)
```

Get attributes for specific role of subject identifier
```ruby
idr_client = SoarSc::IdrClient.new
idr_client.roles_uri = SoarSc::Providers::ServiceRegistry::find_first_service_uri('idr-staff-get-roles')
idr_client.attributes_uri = SoarSc::Providers::ServiceRegistry::find_first_service_uri('idr-staff-get-attributes')
subject_identifier = 'charles.mulder@hetzner.co.za'
role = 'hetznerPerson'
attributes = idr_client.get_attributes(subject_identifier, role)
```

## Test

Run unit tests with
```bash
$ rspec
```
