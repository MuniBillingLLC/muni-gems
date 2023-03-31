# muni-login-client gem

### Clone the repos
```
mkdir muni
cd muni
git clone git@github.com:MuniBillingLLC/dev-meta.git
git clone git@github.com:MuniBillingLLC/muni-gems.git
dev-meta/symlink 
```

### Switch branches
```
cd dev-meta
git switch gems-mac

cd muni-gems
git switch dev
```

### Build the project
```
bin/dc/build
```

### Build the gem
```
bin/dc/gems/login-client/make
```

### Copy the gem into the target project
```
cp muni-gems/login-client/gem/*.gem muni-core/connect/rails/vendor/gems/
```

### Install the gem
```
cd muni-core/connect/rails
gem install vendor/gems/muni-login-client-0.0.1.gem
gem list | grep muni
```
