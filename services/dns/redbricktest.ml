$ORIGIN redbricktest.ml.
$TTL 300
@       IN      SOA     ns1.redbricktest.ml.     admins.redbricktest.ml. (
                        2019060506      ; Serial
                        1M              ; Slave refresh interval
                        5M              ; Query retry interval
                        1H              ; Expiry
                        5M )            ; Cache time
        IN      NS      ns1.redbricktest.ml.
        IN      NS      ns2.redbricktest.ml.

        IN      MX      10      mail.redbricktest.ml.
                IN      TXT     "v=spf1 mx -all"

                IN      A       136.206.15.5
server1         IN      A       136.206.15.5
ns1             IN      A       136.206.15.5
ns2             IN      A       136.206.15.5
mail            IN      A       136.206.15.5

www             IN      CNAME   server1
wiki            IN      CNAME   server1
