# CTF Infrastructure

Infrastructure for hosting a CTF.

# Setup
- explain terraform files and variables
- explain .env
- explain scripts
- explain nginx config
- providers (e.g. Oracle Cloud, Cloudflare)

# CTFd
## VM Information
- some info about VM used for CTFd
- specs, terraform variables

monitor cloud-init: 
```
ssh -i ~/.ssh/oracle_key ubuntu@[ip]
sudo tail -f /var/log/cloud-init-output.log

```

## Theme
- explain compiling scss (and js?)
```
docker run --rm -v $(pwd):/mnt -w /mnt node:18 bash -c "npm install -g sass && sass --style=compressed CTFd/themes/porticoHack/assets/css/main.scss CTFd/themes/porticoHack/static/css/main.min.css"
```
```
docker run --rm -v $(pwd):/mnt -w /mnt node:18 bash -c "npm install -g sass && sass --style=compressed CTFd/themes/porticoHack/assets/css/challenge-board.scss CTFd/themes/porticoHack/static/css/challenge-board.min.css"
```
- explain update script

## Pages
- explain pages

# Challenges
## VM Information
- some info about VM used for CTFd
- specs, terraform variables

## Challenge Directory Structure
- explain how files are organized
- explain required files
- explain what each file is for
- explain how configuration works

## Docker Registry
## Kubernetes

## Resources

