envy(1) -- handle sensitive environments
========================================

> Note that there is a golang-based implementation which is nearly 100% feature complete. This version stands out because it does not requires you to have a ruby runtime on target machines; instead you would just build and use a OS specific binary.
> 
> You'll find it [here](https://github.com/radiospiel/envy-rb/pull/2).

## SYNOPSIS

    envy run [ --secret=name ] path/to/env.file cmd [ args .. ]
    envy edit [ --secret=name ] path/to/env.file
    envy generate [ --secret=name ] path/to/env.file
    envy secret:generate name

## DESCRIPTION

envy is a tool to help handle environment settings in a secure fashion.

### Environment files

An environment file contains configuration settings in generally human
readable form. Its format is inspired by the .INI configuration file format;
for details see the EXAMPLE section below.

An environment file may contain secure parts - those ending in `.secure`.
All values in these parts are encrypted before writing to disk. This makes
the environment file safe to keep in source control - thereby helping
with the distribution of environment settings across team members and
deployments.

### Running in an envy environment

To load an environment file and then run a command with that you use

    envy run path/to/envy.file command arg arg ..

### Encrypting

Encoding is done in symmetric fashion. The encryption and decryption key is stored
in a secret file; you can create a new secret via `envy --generate-secret`.

This secret must be shared amongst all parties that may need to read
and/or edit an environment file.

### Create a new environment file

To create a new environment file use `envy [ --secret name ] --generate`

### Editing

To edit secure entries in the file one needs to have the secet file available,
and uses `envy edit` to run a $EDITOR.

## EXAMPLE

An environment file might look like this:

    # This is a comment
    [mailgun]

    # A block which ends in ".secure" is a secure block. Entries
    # are encrypted or decrypted as necessary
    [mailgun.secure]
    MAILGUN_DOMAIN=CaOGaeKlYEmEXoR2xEuqkNCUS7BkK48wpf/KONQg8cQ=
    MAILGUN_API_KEY=CaOGaeKlYEmEXoR2xEuqkLWjk4DWyVHAwsdpChNXYrY=

    [database]
    DATABASE_POOL_SIZE=10

    [database.secure]
    DATABASE_URL=8DkIDbY+hG7VKSmw5MiYGRR04EYX3HBdf1tJYbSu+6Y=

    [http]
    # Port=80
    HOST_NAME=foo

    [http.secure]
    SECRET_KEY_BASE=8DkIDbY+hG7VKSmw5MiYGRR04EYX3HBdf1tJYbSu+6Y=

This example features two secure parts.

When processed by `envy` this generates the following output:

    MAILGUN_DOMAIN=my.secret.mailgun.domain
    MAILGUN_API_KEY=my.secret.mailgun.key
    DATABASE_POOL_SIZE=10
    DATABASE_URL=postgres://my.database/setting
    HOST_NAME=foo
    SECRET_KEY_BASE=bar\ bar\ bar

## ENVIRONMENT VALUES

- `ENVY_SECRET_PATH` - the path to the secret file, defaults to ~/.secret.envy

## INSTALLATION

Depending on your system

    make install

or

    sudo make install
    
installs `envy` in `/usr/local`.

## LIMITATIONS

1. Environment values may not contain non-printable and non-ASCII characters,
   cannot span multple lines, and must not start with or end in space characters.
2. Security must be audited.
3. No salt is used.
4. Encryption, decryption, and key derivation is currently done via openssl(1).
   This might change in the future.

## COPYRIGHT

The **envy** package is Copyright (C) 2016,2017 @radiospiel <https://github.com/radiospiel>.
It is released under the terms of the MIT license.
