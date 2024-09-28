# Docker Proxy

## `docker pull/push` (Docker Daemon)
> 当我们拉取镜像的时候本质上是通过 **Docker Client** 向 **Docker Daemon** 发送请求，由 **Docker Daemon** 执行拉取请求，当无法拉取镜像时需要给 **Docker Daemon** 配置 **Proxy**。  
> 详见：[https://docs.docker.com/engine/daemon/proxy/](https://docs.docker.com/engine/daemon/proxy/)

### 方式一：`daemon.json`
**Docker Daemon** 的配置文件所在位置如下：
|||
| :- | :- |
| Linux 常规模式 | `/etc/docker/daemon.json` |
| Linux Rootless 模式 | `~/.config/docker/daemon.json` |
| Windows | `C:\ProgramData\docker\config\daemon.json` |
| macOS Docker Desktop | `~/.docker/config/daemon.json` |
| macOS OrbStack | `~/.orbstack/config/docker.json` |  

* `daemon.json` 文件内容如下：
```json
{
    "proxies": {
        "no-proxy": "*.local,localhost,127.0.0.0/8",
        "http-proxy": "http://IP_OR_DOMAIN:6152",
        "https-proxy": "https://IP_OR_DOMAIN:6152",
    }
}
```

***Docker Daemon**并不支持 `ALL_PROXY` 或 `all-proxy` 这个配置。*

* 重启 **Docker Daemon** 服务：
```
sudo systemctl restart docker
```

### 方式二：`http-proxy.conf`
除了配置 `daemon.json`，我们还可以通过 **Systemd** 的服务配置来为 **Docker Daemon** 设置 **Proxy**：
```
sudo mkdir -p /etc/systemd/system/docker.service.d
touch /etc/systemd/system/docker.service.d/http-proxy.conf
```
* `http-proxy.conf` 文件内容如下：
```ini
[Service]
Environment="HTTP_PROXY=http://proxy.example.com:3128"
Environment="HTTPS_PROXY=https://proxy.example.com:3129"
Environment="NO_PROXY=localhost,127.0.0.0/8"
```
* **Reload** 服务配置并重启 **Docker Daemon** 服务：
```
sudo systemctl daemon-reload
sudo systemctl restart docker
```
* 验证结果是否符合预期：
```
sudo systemctl show --property=Environment docker

Environment=HTTP_PROXY=http://proxy.example.com:3128 HTTPS_PROXY=https://proxy.example.com:3129 NO_PROXY=localhost,127.0.0.0/8
```

## `docker build/run` (Docker Client)
> 当我们要运行容器或者构建镜像时，需要用到 Proxy 的话，则需要设置 Docker Client 的 Proxy。(`~/.docker/config.json`)  
> 详见：[https://docs.docker.com/engine/cli/proxy/](https://docs.docker.com/engine/cli/proxy/)

```json
{
    "proxies": {
        "default": {
            "noProxy": "*.test,localhost,127.0.0.0/8",
            "allProxy": "socks5://host.docker.internal:6153",
            "httpProxy": "http://host.docker.internal:6152",
            "httpsProxy": "http://host.docker.internal:6152"
        }
    }
}
```
**Docker Client** 设置 **Proxy** 后不用重启 **Docker**，但是需要明白 **Docker Client** 是通过 **ENV** 的形式为容器注入代理，这就意味着之前已经存在的容器，在修改配置后是不会生效的，必须停止并删除容器，再重新用 `docker run` 或者 `docker compose up` 重新创建容器，这样才会在容器的 **ENV** 中增加上述 **Proxy** 配置。

除了这种方式还可以在 **CLI** 中通过 `–env` 和 `–build-arg` 来设置临时代理：
```
docker build --build-arg HTTP_PROXY="http://proxy.example.com:3128" .
docker run --env HTTP_PROXY="http://proxy.example.com:3128" redis
```

转：[https://george.betterde.com/technology/20240608.html](https://george.betterde.com/technology/20240608.html)
