# OpenLDAP Server

Database for user credentials.

## Kickstarting a new Cluster

This only needs to be performed when there are no existing LDAP servers.

- Generate some passwords for root and slurpd (replication user)

```bash
# Create a password for root (and save it to the passwordsafe).
slappasswd
echo -n 'thenewhash' > /var/secrets/ldap.secret
# Create a password for slurpd. -n removes new line
echo -n 'mynewpassword' > /var/secrets/slurpd.pwd.secret
# Generate a hash for the new password
slappasswd
echo -n 'thenewhash' > /var/secrets/slurpd.secret
# Fix permissions
chmod 400 /var/secrets/slurpd*.secret /var/secrets/ldap.secret
```

- Add an entry in [ldap.nix](../../common/ldap.nix) servers array.
- Import the ldap service in the host's configuration.nix.
- Once running, import the initialise.ldif like so:

```bash
ldapadd -vc -x -f initialise.ldif -D cn=root,ou=services,o=redbrick -W
```

## Adding new hosts

- Copy the secret files mentioned above from an existing host to the new host.
- Add an entry in [ldap.nix](../../common/ldap.nix) servers array.
- Import the ldap service in the host's configuration.nix.

That's it! On startup, it will self replicate from the existing server(s).
