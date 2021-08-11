# Readme  

Launch with the following command.  

```bash
docker run -it --rm \
  -v /etc/timezone:/etc/timezone:ro \
  -v /etc/localtime:/etc/localtime:ro \
  -v /var/run/docker.sock:/var/run/docker.sock \
  devops-terminal:latest
```
