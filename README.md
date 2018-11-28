# Ansible vault tools

[Ansible vault][] is a great tool for managing secrets for Ansible playbooks,
but dealing with the vault can be a pain. This repo contains instructions and
helper scripts to reduce that pain.

## Installation

This project provides some helper scripts for dealing with ansible vault files.
These scripts can be installed by running `make install`, which may or may not
require root permissions.

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
# gitattributes
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
# gitconfig
[diff "ansible-vault"]
	textconv = ansible-vault view
	# Do not cache the vault contents
	cachetextconv = false
```

## git grep

With the textconv settings above, this also allows you to grep into vaulted
files. To do this, you need to pass the `--textconv` option to `git grep`.

```bash
$ git grep --textconv super_secret
group_vars/all/vault.yml:super_secret: tell no one
```

## git merge

You can similarly configure a merge driver for use with ansible vault files. The
provided merge driver uses the underlying `git merge-files` command to merge the
unencrypted contents of the vault files being merged. If there are any merge
conflicts, `$EDITOR` is opened allowing you to resolve the conflict before the
merged file is re-encrypted.

```ini
# gitconfig
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
# ansible.cfg
[defaults]
vault_password_file = /path/to/vault_password_file
```

While normally the vault password file is a file that contains the plain text
vault password (which seems like a bad idea), this password file could be an
executable script, which can use a tool with good password caching (like
[gpg][]) to decrypt the password file. Please look up the [gpg-agent][] for
instructions on how to use it effectively.

The helper `gpg-vault-password-file` can be used to create a script that can be
used to store the vault password in a GPG encrypted file. This will create an
executable script in the location given, and the vault password encrypted with
the default self key.

Used in this manner, `ansible-vault` will prompt for your GPG password when
used, which will be cached for some period of time.

```bash
$ gpg-vault-password-file /path/to/vault_password_file
```

## Temporarily disabling decryption when using `git diff`, `git log`, etc.

If you have setup your .gitconfig following the above instructions, git will use
`ansible-vault view` to convert your vault files into plaintext, but this can be a
problem if you want to see the unconverted diff between two vaultfile revisions.

That is, if you temporarily want to see the diff between two encrypted
vaultfile text blobs, perhaps to double-check that you didn't accidentally decrypt
the file before pushing to a remote, use the [--no-textconv][] flag to turn off
the textconv feature on a case-by-case basis:

```bash
$ git diff --no-textconv
$ git log -p --no-textconv
```

These commands should allow you to look at the regular diffs that git
produces, just like you hadn't used this repo at all. The next time you run the
plain `git diff` or `git log -p`, you will see the decrypted version again.

## License

[ISC License](./LICENSE)

 [ansible vault]: http://docs.ansible.com/ansible/playbooks_vault.html
 [binary diff]:  http://git-scm.com/docs/gitattributes#_performing_text_diffs_of_binary_files
 [spaceman-diff]: https://github.com/holman/spaceman-diff
 [vault-config]: http://docs.ansible.com/ansible/intro_configuration.html#vault-password-file
 [gpg]: https://www.gnupg.org/
 [gpg-agent]: https://www.gnupg.org/documentation/manuals/gnupg/Invoking-GPG_002dAGENT.html
 [--no-textconv]: https://git.wiki.kernel.org/index.php/Textconv#Blame_and_diff
