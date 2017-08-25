# ansible-vault-tools changelog

## v? (?)

 * Fixed tabs in README
 * Add `git grep` section to README

## v2.0.2 (2017-08-14)

 * ansible-vault-merge: Fix script when `$EDITOR` is not set. Defaults to `vi`.

## v2.0.1 (2016-08-02)

 * #3 - Fixup `Makefile` to better follow the [GNU Coding Standards][].
   * [Do not set `DESTDIR` explicitly][destdir]
   * [Use `exec_prefix` as the base path for `bindir`][bindir]

 [GNU Coding Standards]: https://www.gnu.org/prep/standards/html_node/Makefile-Conventions.html
 [destdir]: https://www.gnu.org/prep/standards/html_node/DESTDIR.html
 [bindir]: https://www.gnu.org/prep/standards/html_node/Directory-Variables.html

## v2.0.0 (2016-06-16)

 * Change `gpg-vault-password-file` so that if you give it a file that already
   exists, it will get the password from that, and encrypt it. Makes it easier
   to add encryption to existing password file.

## v1.0.1 (2016-01-26)

 * #1 - Updated README
 * #2 - Even more improved docs

## v1.0.0 (2016-01-12)

 * Initial release
