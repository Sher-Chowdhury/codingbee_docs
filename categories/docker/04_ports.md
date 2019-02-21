# Managing ports

If a container has a process taht's listening on particular port number. then you can access it by mapping one of your macbook's port to the container's port, e.g.


```bash
docker run --detach --publish 8000:80 httpd
```

You can then verify that this mapping is in place, by view the PORTS column:

```bash
$ docker container ls
CONTAINER ID        IMAGE               COMMAND              CREATED             STATUS              PORTS                  NAMES
a648b5280f54        httpd               "httpd-foreground"   9 seconds ago       Up 8 seconds        0.0.0.0:8000->80/tcp   quirky_archimedes
```

Then you can access this service via your web browser, by going to http://localhost:8000. You can test this using curl:

```bash
$ curl -Lv http://localhost:8000
* Rebuilt URL to: http://localhost:8000/
*   Trying ::1...
* TCP_NODELAY set
* Connected to localhost (::1) port 8000 (#0)
> GET / HTTP/1.1
> Host: localhost:8000
> User-Agent: curl/7.54.0
> Accept: */*
>
< HTTP/1.1 200 OK
< Date: Wed, 20 Feb 2019 14:29:17 GMT
< Server: Apache/2.4.38 (Unix)
< Last-Modified: Mon, 11 Jun 2007 18:53:14 GMT
< ETag: "2d-432a5e4a73a80"
< Accept-Ranges: bytes
< Content-Length: 45
< Content-Type: text/html
<
<html><body><h1>It works!</h1></body></html>
* Connection #0 to host localhost left intact
```

When doing port mapping you need to ensure that your mapping on a port that's being listened on from inside the container. 