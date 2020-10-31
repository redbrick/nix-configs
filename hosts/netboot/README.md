# Redbrick Netboot environment

Used for freshly installing hosts and doing recoveries

## Building

```bash
# Build the files
nix-build build-netboot.nix
# ./result will contain an initrd, bzImage, netboot.ipxe
```

## Setup on netboot Docker image on zeus

- Copy the initrd and bzImage to `/etc/docker-compose/services/netbooter/httproot/nixos`
- Copy the init= line out of `netboot.ipxe` and update it in the `.../netbooter/menu.ipxe`
