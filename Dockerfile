# Dockerfile based on ideas from https://pythonspeed.com/

FROM docker.io/python:3.8-slim AS compile-image

LABEL maintainer "Steven Armstrong <steven@armstrong.cc>"

ENV \
   LANG=C.UTF-8 \
   LC_ALL=C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get -y install --no-install-recommends build-essential gcc

# Create a venv so it can later be copied into the runtime-image
# without all the build dependencies.
ENV VIRTUAL_ENV=/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN pip install --upgrade pip
RUN pip install wheel

# Install python packages into virtual env.
COPY requirements.txt .
RUN pip install -r requirements.txt

# Dumb-init as pid 1.
RUN pip install dumb-init


FROM docker.io/python:3.8-slim AS runtime-image

# Install runtime dependencies.
COPY install-packages.sh .
RUN ./install-packages.sh

COPY --from=compile-image /venv /venv

RUN mkdir /target
RUN mkdir /cdist
RUN mkdir /cdist/config

COPY remote /cdist/remote
COPY bin/ /usr/local/bin/

ADD entrypoint.sh /entrypoint

ADD cdist.cfg /etc/cdist.cfg
ENV CDIST_CONFIG_FILE=/etc/cdist.cfg

RUN useradd --home-dir /home/cdist --create-home --uid 1000 cdist
WORKDIR /home/cdist

# Place to store the cdist and ssh configuration.
RUN mkdir /home/cdist/.cdist
RUN mkdir /home/cdist/.ssh && chmod 700 /home/cdist/.ssh
RUN chown -R cdist: /home/cdist

#VOLUME /tmp
#VOLUME /home/cdist/.cdist
#VOLUME /home/cdist/.ssh

# Ensure exectutables from virtualenv are prefered.
ENV PATH "/venv/bin:${PATH}"
ENTRYPOINT ["/venv/bin/dumb-init", "--", "/entrypoint"]
