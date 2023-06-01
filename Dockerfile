# Dockerfile
FROM python:3.10-slim-buster
LABEL MAINTAINER="Raskitoma/EAJ"
LABEL VERSION="1.0"
LABEL LICENSE="GPLv3"
LABEL DESCRIPTION="Raskitoma - PLS data grab"

# setting env vars
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV LC_ALL=C.UTF-8
ENV PYTHONUNBUFFERED=1
ENV PIP_DISABLE_PIP_VERSION_CHECK=1
# customizable env vars via docker-compose
ENV INFLUX_HOST_PORT=https://my.influx.com:8086
ENV INFLUX_ORG=myorg
ENV INFLUX_BUCKET=pls 
ENV INFLUX_KEY=mykey==
ENV PLS_PRICE_URI=https://api.dexscreener.com/latest/dex/pairs/pulsechain/0x1b45b9148791d3a104184cd5dfe5ce57193a3ee9
ENV PLS_LAUNCH_URI=https://launchpad.pulsechain.com/en/

# install required packages
RUN apt update && apt install --no-install-recommends -y cron curl tzdata tar unzip bzip2

# install geckodriver
RUN BASE_URL=https://github.com/mozilla/geckodriver/releases/download \
  && VERSION=$(curl -sL \
    https://api.github.com/repos/mozilla/geckodriver/releases/latest | \
    grep tag_name | cut -d '"' -f 4) \
  && curl -sL "$BASE_URL/$VERSION/geckodriver-$VERSION-linux64.tar.gz" | \
    tar -xz -C /usr/local/bin \
  && chmod +x /usr/local/bin/geckodriver

# install firefox
RUN apt-get purge firefox
RUN curl -o firefox.tar.bz2 -#L "https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-US"
RUN tar xjf firefox.tar.bz2 -C /opt/
RUN ln -s /opt/firefox/firefox /usr/bin/firefox
RUN rm firefox.tar.bz2

# Cleaning image
RUN apt-get autoremove -y

# create required folders
RUN mkdir -p /app

# Copy the requirements file into the container
COPY requirements.txt .

# Install the required packages
RUN /usr/local/bin/python -m pip install --no-cache-dir -r requirements.txt

# Copy the script into the container
COPY plsgrabber.py .

# Copy the entrypoint script into the container
COPY entrypoint.sh .

RUN chmod +x entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]