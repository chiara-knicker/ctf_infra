FROM ubuntu:20.04

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    socat 
    #&& rm -rf /var/lib/apt/lists/*  # Clean up package lists to reduce image size

RUN useradd -m ctf

WORKDIR /home/ctf

# Copy the challenge files
COPY ./challenge_files /home/ctf/

# Compile the C program
RUN gcc source.c -o challenge-name

# Copy entrypoint
COPY ./entrypoint.sh /entrypoint.sh

# Ensure the entrypoint script is executable
RUN chmod +x /entrypoint.sh

# Run the challenge using the entrypoint script
CMD ["/entrypoint.sh"]

# Expose the port for the challenge
EXPOSE 12345