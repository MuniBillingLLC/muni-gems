# muni-login-client

Ruby client for Muni Login Service SSO authentication and session management.

### Build the gem
From the stack root:
```
bin/dc/login/client/make
```

### Run specs
```
bin/dc/login/client/spec
```

### Install the gem
```
gem install ./muni-login-client-0.0.44.gem
```

### Use from IRB
```
$ irb
require "muni-login-client"
Muni::Login::Client::IdpCache.new.settings
```

### References:
* https://guides.rubygems.org/specification-reference/
