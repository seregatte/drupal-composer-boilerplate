#!/bin/bash
cp -Rf vendor/seregatte/drupal-docker-boilerplate/infrastructure .
cp -Rf vendor/seregatte/drupal-docker-boilerplate/Makefile .
patch -p0 < resources/patches/setup.patch
make set_variable DRUPAL_VERSION=7
