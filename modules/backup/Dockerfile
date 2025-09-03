FROM debian:bookworm-slim

# Install dependencies
RUN apt-get update 
RUN apt-get install -y \
    curl \
    ca-certificates \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Add Docker’s official GPG key
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up the Docker CLI repo
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

# Install the Docker CLI only (no engine)
RUN apt-get update && apt-get install -y docker-ce-cli 

# Install borgmatic & borg
RUN apt install cron pipx ssh borgbackup -y
RUN pipx install borgmatic

# Cleanup
RUN rm -rf /var/lib/apt/lists/*

# Copy backup script & set permissions
COPY ./script.sh /script.sh
RUN chmod +x /script.sh

# Set environment variables
ENV PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/.local/bin"

RUN touch /var/log/cron.log

CMD ["sh", "-c", "cron && tail -f /var/log/cron.log"]
# CMD ["sleep", "infinity"]
