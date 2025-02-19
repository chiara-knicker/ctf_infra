#!/bin/bash

# Run the challenge server using socat
socat TCP-LISTEN:12345,reuseaddr,fork EXEC:/home/ctf/challenge-name,pty,stderr,echo=0,close
