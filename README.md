# Ansible vault tools

[Ansible vault][] is a wonderful tool for being able to put secrets in a version
control system, while still protecting them. Unfortunately, these vault files
are a pain to deal with in version control. Any change to the vault results in a
re-encryption, which changes every character in the ciphertext.

Fortunately, git has several configuration options so that we can have tools
which can encrypt and decrypt vault files on the fly. Ansible also has some
configuration options and features which can help us to avoid typing in our
vault password a million times a day.

## Installation

This project provides some helper scripts for dealing with ansible vault files.
These scripts can be installed by running `make install`, which may or may not
require root permissions to run.

There is also a `make uninstall`, in case you change your mind.

## Vault Filename Conventions

In order for git to know when to use the ansible vault tools for decrypting
files, it needs to know when it's dealing with a vault file. To do this, you
will need to have a consistent naming convention for your vault files. I
recommend either `vault.yml` (if you like having a single vault) or
`*.vault.yml` (if you like having lots of vaults).

## Git configuration

The pattern for your vault files can be configured in one of three places for
git.

 * `./.gitattributes` - per project, checked into git
 * `./.git/info/attributes` - per project, not checked in
 * `$HOME/.config/git/attributes` - per user config

Wherever you chose to put it, the configuration is the same:

```
vault.yml diff=ansible-vault merge=ansible-vault
*.vault.yml diff=ansible-vault merge=ansible-vault
```

## git diff

Git diff can be configured to convert binary files into text, allowing for an
effective [binary diff][]. Some other projects use this to do some
[pretty cool stuff][spaceman-diff].

The configuration for the ansible-vault diff handler goes into
`$HOME/.gitconfig`.

```ini
[diff "ansible-vault"]
	textconv = ansible-vault view
    # Do not cache the vault contents
	cachetextconv = false
```

## git merge

You can similarly configure a merge driver for use with ansible vault files. The
provided merge driver uses the underlying `git merge-files` command to merge the
unencrypted contents of the vault files being merged. If there are any merge
conflicts, `$EDITOR` is opened allowing you to resolve the conflict before the
merged file is re-encrypted.

```ini
[merge "ansible-vault"]
	name = ansible-vault merge driver
	driver = /usr/local/bin/ansible-vault-merge -- %O %A %B %P
```

## ansible vault password caching

Ansible vault allows you to configure the
[location of the vault password file][vault-config], which can go into any of
Ansible's configuration files.

 * `./ansible.cfg` - per project configuration
 * `$HOME/.ansible.cfg` - per user configuration
 * `/etc/ansible/ansible.cfg` - per system configuration

```ini
[defaults]
vault_password_file = /path/to/vault_password_file
```

While normally the vault file is a file that contains the plain text vault
password (which seems like a bad idea), this password file could be an
executable script, which can use a tool with good password caching (like
[gpg][]) to decrypt the password file. Please look up the [gpg-agent][] for
instructions on how to use it effectively.

The helper `gpg-vault-password-file` can be used to create a script that can be
used to store the vault password in a GPG encrypted file.

## License

[ISC License](./License.md)

 [ansible vault]: http://docs.ansible.com/ansible/playbooks_vault.html
 [binary diff]:  http://git-scm.com/docs/gitattributes#_performing_text_diffs_of_binary_files
 [spaceman-diff]: https://github.com/holman/spaceman-diff
 [vault-config]: http://docs.ansible.com/ansible/intro_configuration.html#vault-password-file
 [gpg]: http://docs.ansible.com/ansible/intro_configuration.html#vault-password-file
 [gpg-agent]: https://www.gnupg.org/documentation/manuals/gnupg/Invoking-GPG_002dAGENT.html
