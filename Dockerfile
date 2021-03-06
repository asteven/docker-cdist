# Dockerfile based on ideas from https://pythonspeed.com/

FROM docker.io/python:3.8-slim AS compile-image

LABEL maintainer "Steven Armstrong <steven.armstrong@id.ethz.ch>"

RUN apt-get update
RUN apt-get install -y --no-install-recommends build-essential gcc

ENV VIRTUAL_ENV=/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

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

RUN useradd --create-home cdist
WORKDIR /home/cdist
USER cdist

ADD --chown=cdist cdist.cfg /home/cdist/

# Place to store the cdist and ssh configuration.
RUN mkdir /home/cdist/.cdist
RUN mkdir /home/cdist/.ssh && chmod 700 /home/cdist/.ssh

#VOLUME /tmp
#VOLUME /home/cdist/.cdist
#VOLUME /home/cdist/.ssh

# Ensure exectutables from virtualenv are prefered.
ENV PATH "/venv/bin:${PATH}"
ENTRYPOINT ["/venv/bin/dumb-init", "--"]
CMD ["cdist"]
