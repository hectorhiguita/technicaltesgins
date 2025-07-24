
FROM httpd:2.4-alpine

COPY ./public-html/ /usr/local/apache2/htdocs/

EXPOSE 80

CMD ["httpd-foreground"]
