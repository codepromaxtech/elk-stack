# Use an official base image with all Elastic components
FROM ubuntu:22.04

# Set environment variables for Elasticsearch and Logstash
ENV ES_HOME=/usr/share/elasticsearch \
    LOGSTASH_HOME=/usr/share/logstash \
    KIBANA_HOME=/usr/share/kibana \
    PATH=$PATH:/usr/share/elasticsearch/bin:/usr/share/logstash/bin:/usr/share/kibana/bin

# Install prerequisites and tools
RUN apt update && apt install -y \
    openjdk-11-jdk \
    curl \
    wget \
    gnupg \
    apt-transport-https \
    ca-certificates \
    && apt clean

# Download and install Elasticsearch
RUN wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.10.2-amd64.deb && \
    dpkg -i elasticsearch-8.10.2-amd64.deb && \
    rm elasticsearch-8.10.2-amd64.deb

# Download and install Logstash
RUN wget https://artifacts.elastic.co/downloads/logstash/logstash-8.10.2-amd64.deb && \
    dpkg -i logstash-8.10.2-amd64.deb && \
    rm logstash-8.10.2-amd64.deb

# Download and install Kibana
RUN wget https://artifacts.elastic.co/downloads/kibana/kibana-8.10.2-amd64.deb && \
    dpkg -i kibana-8.10.2-amd64.deb && \
    rm kibana-8.10.2-amd64.deb

# Configure Elasticsearch (single-node mode)
RUN echo "network.host: 0.0.0.0\n\
discovery.type: single-node" > /etc/elasticsearch/elasticsearch.yml

# Configure Kibana
RUN echo "server.host: 0.0.0.0\n\
elasticsearch.hosts: [\"http://localhost:9200\"]" > /etc/kibana/kibana.yml

# Copy Logstash configuration files
COPY logstash/config/logstash.yml /usr/share/logstash/config/logstash.yml
COPY logstash/pipeline/logstash.conf /usr/share/logstash/pipeline/logstash.conf

# Expose necessary ports
EXPOSE 9200 5601 5044

# Start all services in the background
CMD service elasticsearch start && \
    service logstash start && \
    service kibana start && \
    tail -f /dev/null
