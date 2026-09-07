FROM ubuntu:latest

RUN apt-get update && apt-get install -y \
    bash coreutils grep gawk procps \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY scripts/ /app/
RUN chmod +x /app/*.sh

# Mantiene el contenedor vivo para poder entrar con docker compose exec
CMD ["bash"]
