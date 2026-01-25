FROM nginx:alpine

WORKDIR /usr/share/nginx/html

COPY ./build/web /usr/share/nginx/html

EXPOSE 7860

# 修改nginx配置文件，监听7860端口
RUN sed -i 's/listen       80;/listen       7860;/g' /etc/nginx/conf.d/default.conf

CMD ["nginx", "-g", "daemon off"]