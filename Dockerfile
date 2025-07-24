
# Dockerfile para aplicación web simple
FROM httpd:2.4-alpine

# Copiar contenido personalizado
COPY ./public-html/ /usr/local/apache2/htdocs/

# Exponer puerto 80
EXPOSE 80

# Comando por defecto
CMD ["httpd-foreground"]
