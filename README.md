# php-apache

A docker image for Wordpress or Drupal development

This image is based off of the official PHP-apache image and is tailored to be suitable for development of Drupal and Wordpress sites.

The image is build with `mod_rewrite` enabled for Apache, and `gd` and `zip` php extensions enabled. Composer and Drush launcher are included.

## Avoiding permission problems

The webserver runs as the user `www-data`, with UID:GID of 33:33 by default. This will cause permission problems as the webserver would be unable to write files in directories created on the host.

To avoid this, we can explicitly set the user and group ID to match the user on the host system. **This can only be done at buildtime.**

The `Dockerfile` has default values of 1000:1000 which will match the first user on many modern linux systems but these can be overridden at build time. If you require different values:

```bash
    docker build --build-arg UID=$(echo $UID) --build-arg GID=$(echo $GID) -t surreymagpie/php-apache:7.3 .
```
