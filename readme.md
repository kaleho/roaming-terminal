# Readme  

Launch with the following command.  

```bash
docker run -it --rm \
  -v /etc/timezone:/etc/timezone:ro \
  -v /etc/localtime:/etc/localtime:ro \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v ~/.p10k.zsh:/home/user01/.p10k.zsh \
  -v ~/.zshrc:/home/user01/.zshrc \
  -v ~/.oh-my-zsh:/home/user01/.oh-my-zsh \
  -v ~/.azure:/home/user01/.azure \
  devops-terminal:latest
```
