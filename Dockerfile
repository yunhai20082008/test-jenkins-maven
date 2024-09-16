# Alpine Dockerfile
# 
FROM alpine:latest
LABEL maintainer="yqc<20251839@qq.com>"
copy target/*.jar app.jar
