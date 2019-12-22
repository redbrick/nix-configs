;<?php http_response_code(403); /*
[main]
name = "Redbrick Paste"
discussion = false
opendiscussion = false
password = true
fileupload = false
burnafterreadingselected = false
defaultformatter = "plaintext"
sizelimit = 10485760
template = "bootstrap"
languageselection = false

[expire]
default = "1week"

[expire_options]
5min = 300
10min = 600
1hour = 3600
1day = 86400
1week = 604800

[formatter_options]
plaintext = "Plain Text"
syntaxhighlighting = "Source Code"
markdown = "Markdown"

[traffic]
limit = 10
dir = "/var/lib/privatebin"

[purge]
limit = 300
batchsize = 10
dir = "/var/lib/privatebin"

[model]
class = Filesystem

[model_options]
dir = "/var/lib/privatebin"
