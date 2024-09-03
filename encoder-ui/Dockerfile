FROM node:18.20-alpine AS builder

USER root
WORKDIR /app
COPY /encoder-ui .

RUN npm install
RUN node node_modules/@angular/cli/bin/ng build --configuration production

FROM nginx
COPY --from=builder ./app/dist/encoder-ui/ /usr/share/nginx/html

COPY /encoder-ui/cert/encoder_ui.crt /etc/nginx/ssl/encoder_ui.crt
COPY /encoder-ui/cert/encoder_ui.key /etc/nginx/ssl/encoder_ui.key

COPY /encoder-ui/nginx.conf /etc/nginx/nginx.conf
EXPOSE 80 443