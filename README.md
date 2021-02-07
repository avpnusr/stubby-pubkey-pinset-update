**DNS over TLS stubby pinset check**
===

A reliable way to get DNS over TLS working is to use [stubby](https://dnsprivacy.org/wiki/display/DP/DNS+Privacy+Daemon+-+Stubby).

For security's sake, a "tls_pubkey_pinset" (basically a unique sha256 hash identifiying the server) can be added to the config.
As most public / free DNS over TLS servers rely on free certificate services e.g. (LetsEncrypt), these hash can change over time.
If the "tls_pubkey_pinset" from your config does not match the server-hash, stubby stops working, so you don't possibly leak your DNS queries.

To automate the update of these hashes on your stubby-client, this script was created.

For bests result and mind-free updates, simply integrate the script via cronjob.
If you want the script to automatically update stubby-config and restart stubby-service, the account which runs the script needs the necessary privileges.

Basically there is only one variable you could / shoud change - "$STUBBYCFG" tells where your stubby-config can be found.

Have fun ;)
