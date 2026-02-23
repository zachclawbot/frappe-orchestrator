FROM python:3.11-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    FRAPPE_USER=frappe \
    FRAPPE_HOME=/home/frappe

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    wget \
    git \
    nano \
    vim \
    build-essential \
    libffi-dev \
    libssl-dev \
    mariadb-client \
    redis-tools \
    nodejs \
    npm \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Create frappe user and directories
RUN useradd -m -d ${FRAPPE_HOME} ${FRAPPE_USER} && \
    mkdir -p ${FRAPPE_HOME}/frappe-bench

WORKDIR ${FRAPPE_HOME}/frappe-bench

# Install Frappe Bench
RUN pip install --upgrade pip setuptools wheel && \
    pip install frappe-bench

# Copy any custom configuration
COPY docker/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Change ownership to frappe user
RUN chown -R ${FRAPPE_USER}:${FRAPPE_USER} ${FRAPPE_HOME}

# Switch to frappe user
USER ${FRAPPE_USER}

# Initialize Frappe Bench
RUN bench init --frappe-branch version-14 frappe-bench-init && \
    cd frappe-bench-init && \
    bench setup requirements

EXPOSE 8000 9000 6787 6788

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["bench", "start"]
