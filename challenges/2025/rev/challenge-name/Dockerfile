FROM ubuntu:20.04

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    socat
    #rm -rf /var/lib/apt/lists/*  # Clean up package lists to reduce image size

# Set the working directory
WORKDIR /challenge_files

# Copy the challenge files
COPY . .

# Compile the C program
RUN gcc source.c -o challenge-name

# Ensure the entrypoint script is executable
RUN chmod +x entrypoint.sh

# Expose the port for the challenge
EXPOSE 12345

# Run the challenge using the entrypoint script
CMD ["./entrypoint.sh"]