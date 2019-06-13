FROM docker:stable
LABEL Description="Application container"

ENV PS1='\[\033[1;32m\]🐳  \[\033[1;36m\][\u@\h] \[\033[1;34m\]\w\[\033[0;35m\] \[\033[1;36m\]# \[\033[0m\]'

ENV PATH /scripts:/scripts/aliases:$PATH

RUN apk add --no-cache openssh-client vim

RUN apk add --update \
    python \
    python-dev \
    py-pip \
    build-base \
  && pip install envs pyyaml \
  && rm -rf /var/cache/apk/*



COPY ./aliases/* /scripts/aliases/
COPY ./docker /docker
COPY ./deploy.sh /deploy.sh
COPY ./package.sh /package.sh

RUN chmod +x /deploy.sh && chmod +x /package.sh
WORKDIR /app