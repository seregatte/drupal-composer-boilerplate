# Composer template for Drupal 7/8 projects

This project template should provide a kickstart for managing your site 
dependencies with [Composer](https://getcomposer.org/) and infrastructure with [Docker](https://docker.com/) via [Drupal Docker Boilerplate](https://github.com/seregatte/drupal-docker-boilerplate).

## Requirements

- make command 
- Docker 1.11+ [->](https://docs.docker.com/engine/installation/)
- Docker Composer 1.7+ [->](https://docs.docker.com/compose/install/)
- PHP cli stack and composer (Optional) [->](https://getcomposer.org/doc/00-intro.md#installation-linux-unix-osx)

## Usage

You can create the project via composer or via composer inside a docker.

If you have a php cli stack and composer, try this:

```
composer create-project seregatte/drupal-composer-boilerplate some-dir --stability dev --no-interaction
```

or if you prefer run via docker:

```
docker run --rm -v $(pwd):/app composer/composer create-project seregatte/drupal-composer-boilerplate some-dir --stability dev --no-interaction
```

With `composer require ...` or running the same command on docker, you can download new dependencies to your installation.

```
cd some-dir
composer require drupal/ctools:7.*
```

or

```
cd some-dir
docker run --rm -v $(pwd):/app composer/composer require drupal/ctools:7.*
```

## What does the template do?

When installing the given `composer.json` some tasks are taken care of:

* Drupal will be installed in the `web`-directory.
* Modules (packages of type `drupal-module`) will be placed in `web/sites/all/modules/contrib/`
* Theme (packages of type `drupal-module`) will be placed in `web/sites/all/themes/contrib/`
* Profiles (packages of type `drupal-profile`) will be placed in `web/profiles/`
* Docker stack will be placed in `infrastructure/environment/development/docker`
* Makefile will be placed in project's root folder

## Generate composer.json from existing project

With using [the "Composer Generate" drush extension](https://www.drupal.org/project/composer_generate)
you can now generate a basic `composer.json` file from an existing project. Note
that the generated `composer.json` might differ from this project's file.


## FAQ

### Should I commit the contrib modules I download

Composer recommends **no**. They provide [argumentation against but also 
workrounds if a project decides to do it anyway](https://getcomposer.org/doc/faqs/should-i-commit-the-dependencies-in-my-vendor-directory.md).

### How can I apply patches to downloaded modules?

If you need to apply patches (depending on the project being modified, a pull 
request is often a better solution), you can do so with the 
[composer-patches](https://github.com/cweagans/composer-patches) plugin.

To add a patch to drupal module foobar insert the patches section in the extra 
section of composer.json:
```json
"extra": {
    "patches": {
        "drupal/foobar": {
            "Patch description": "URL to patch"
        }
    }
}
```