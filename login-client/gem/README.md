# munidp-gem

### Build the gem
```
cd muni-core/login-client/gem
gem build muni-login-client.gemspec
```

### Install the gem
```
gem install ./muni-login-client-0.0.5.gem
```

### Use from IRB
```
$ irb
require "muni-login-client"
Muni::Login::Client::IdpCache.new.settings
```

### References:
* https://guides.rubygems.org/make-your-own-gem/
