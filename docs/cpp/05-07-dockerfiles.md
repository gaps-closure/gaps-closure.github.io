## Dockerfile [TODO: MIKE] {#dockerfile}

### Dockerfile for Source release {#src-docker}
The following dockerfile is used to build a source release from scratch.

```
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive
ENV HOME /home/closure
etc...
```