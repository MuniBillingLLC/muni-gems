ARG BASE_IMAGE=ubuntu

FROM ${BASE_IMAGE}

ARG HOST_UID=0
ARG HOST_GID=0
ARG RUBY_VERSION=2.4.9
ARG BUNLDER_VERSION=2.3.26
ARG RAKE_VERSION=13.0.6

# a directory for storing image artifacts. This should be strictly data & logs
# no executables / source code please
ARG META_DIR=/usr/src/meta

# ENV is for future running containers. ARG for this current build.
# both ENV & ARG are available during build
# ARG are not available after the build
ENV \
    APP_ROOT=/usr/src/app \
    APP_NAME="core-login-client" \
    USER_NAME="hermit" \
    DEBIAN_FRONTEND=noninteractive \
    BUNDLE_IGNORE_FUNDING_REQUESTS=1

# Create the meta directory
WORKDIR ${META_DIR}

# general packages
RUN \
    apt-get update && \
    apt-get install -y curl nano wget software-properties-common build-essential \
            default-libmysqlclient-dev mysql-client libxslt-dev libxml2-dev \
            sqlite3 libsqlite3-dev tzdata dos2unix iputils-ping

# Install nodejs from nodesource since it has the latest version
# The nodejs package includes both 'node' and 'npm' binaries.
# The later is used for installing several other dependencies
RUN \
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y nodejs && \
    npm install --global yarn

# install RVM for all users
RUN \
    curl -sSL https://rvm.io/mpapis.asc | gpg --import - && \
    curl -sSL https://rvm.io/pkuczynski.asc | gpg --import - && \
    curl -sSL https://get.rvm.io | bash -s stable


# install ruby for all users
# also ugrade to more recent version fo rubygems & install required versions of
# bundler and rake
RUN \
    /bin/bash -c "source /etc/profile.d/rvm.sh && \
    rvm pkg install openssl && \
    rvm install ${RUBY_VERSION} --with-openssl-dir=/usr/local/rvm/usr && \
    gem update --system 3.2.3 --no-document && \
    gem install bundler -v ${BUNLDER_VERSION} && \
    gem install rake -v ${RAKE_VERSION}"

# bring the source into the container
COPY gem $APP_ROOT

# create local user/group & take ownership of the source files
RUN if [ ${HOST_GID} -eq 0 ]; \
    then \
      # When HOST_GID is not set we do the default user creation
      echo "Argument HOST_GID not set, using defaults" >> ${META_DIR}/build.log; \
      useradd --create-home --shell /bin/bash $USER_NAME; \
      chown --recursive ${USER_NAME}:${USER_NAME} $APP_ROOT; \
    else \
      # When HOST_GID is set we create an user with specific groupd and user id \
      # note that if setting HOST_GID, you also need to set HOST_UID
      echo "Argument HOST_GID=${HOST_GID}" >> ${META_DIR}/build.log; \
      export CONTAINER_GROUPNAME=$(cat /etc/group | grep ":$HOST_GID:" | cut -d ":" -f 1) && \
      if [ -z "$CONTAINER_GROUPNAME" ]; \
        then groupadd --gid ${HOST_GID} $USER_NAME; \
      fi; \
      useradd --create-home --no-user-group --shell /bin/bash --gid ${HOST_GID} --uid ${HOST_UID} $USER_NAME; \
      chown --changes --silent --no-dereference --recursive ${HOST_UID}:${HOST_GID} $APP_ROOT; \
    fi

# add user to the RVM group
RUN usermod -a -G rvm $USER_NAME

# switch to the newly created user
USER $USER_NAME

# Install the dependencies
WORKDIR $APP_ROOT
RUN \
    /bin/bash -c "source /etc/profile.d/rvm.sh && \
    bundle install"

# show APP_NAME on command prompt (for future sessions)
WORKDIR /home/$USER_NAME
RUN \
    echo >>  /home/$USER_NAME/.bashrc && \
    echo -n "export PS1='" >>  /home/$USER_NAME/.bashrc && \
    echo -n "\\[\\\033[01;32m\]" >>  /home/$USER_NAME/.bashrc && \
    echo -n "\${debian_chroot:+(\$debian_chroot)}\\u@\${APP_NAME}" >>  /home/$USER_NAME/.bashrc && \
    echo -n "\\[\\\033[00m\]" >>  /home/$USER_NAME/.bashrc && \
    echo ":\\w\\$ '\n" >>  /home/$USER_NAME/.bashrc

# Add RVM to PATH (for future sessions). Make sure this is the last PATH variable change.
RUN echo >>  /home/$USER_NAME/.bashrc && \
    echo "export PATH=\"\$PATH:/usr/local/rvm/bin\"\n" >> /home/$USER_NAME/.bashrc

# Load RVM into a shell session *as a function* (for future sessions)
RUN echo >> /home/$USER_NAME/.bashrc && \
    echo "[[ -s \"/etc/profile.d/rvm.sh\" ]] && source \"/etc/profile.d/rvm.sh\"\n" >> /home/$USER_NAME/.bashrc && \
    echo >> /home/$USER_NAME/.profile && \
    echo "[[ -s \"/etc/profile.d/rvm.sh\" ]] && source \"/etc/profile.d/rvm.sh\"\n" >> /home/$USER_NAME/.profile



