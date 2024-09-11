FROM rust:1.76.0-bookworm

# Update and install dependencies
RUN apt-get update && \
    apt-get install -y snapd ca-certificates curl gnupg wget build-essential nano git pbzip2 \
    python3 python3-pip

# Clone the repository
COPY ./OPI /OPI

# Build ord for main and runes
WORKDIR /OPI/ord
RUN cargo build --release

# Install Python libraries
RUN python3 -m pip install --break-system-packages python-dotenv psycopg2-binary json5 stdiomask requests boto3 tqdm

# Install nodejs
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y nodejs

# Install Node.js modules for each module
WORKDIR /OPI
RUN npm install --prefix modules/main_index && \
    npm install --prefix modules/brc20_api && \
    npm install --prefix modules/bitmap_api && \
    npm install --prefix modules/pow20_api && \
    npm install --prefix modules/sns_api && \
    npm install --prefix modules/runes_index && \
    npm install --prefix modules/runes_api

# Expose necessary ports
EXPOSE 3000

# Define the default command
CMD ["/bin/bash"]
