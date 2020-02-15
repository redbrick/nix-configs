{
  concurrent-ruby = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "094387x4yasb797mv07cs3g6f08y56virc2rjcpb1k79rzaj3nhl";
      type = "gem";
    };
    version = "1.1.6";
  };
  "cool.io" = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "08jlx7bzf8zc0pq4p0f0pmpw39r5lv54v7lyj2d901r734x4nxha";
      type = "gem";
    };
    version = "1.6.0";
  };
  fluent-plugin-grafana-loki = {
    dependencies = ["fluentd"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0hgqbkwagb2fyjamwwydqilldqjimrivhss4p7i7dwwb0igw8zwq";
      type = "gem";
    };
    version = "1.2.7";
  };
  fluentd = {
    dependencies = ["cool.io" "http_parser.rb" "msgpack" "serverengine" "sigdump" "strptime" "tzinfo" "tzinfo-data" "yajl-ruby"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0kbid3adh4rnj0cksss0rdpwyhgiv7fch8rw294xmq6ppj7cv126";
      type = "gem";
    };
    version = "1.9.2";
  };
  "http_parser.rb" = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "15nidriy0v5yqfjsgsra51wmknxci2n2grliz78sf9pga3n0l7gi";
      type = "gem";
    };
    version = "0.6.0";
  };
  msgpack = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1lva6bkvb4mfa0m3bqn4lm4s4gi81c40jvdcsrxr6vng49q9daih";
      type = "gem";
    };
    version = "1.3.3";
  };
  serverengine = {
    dependencies = ["sigdump"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1qqj6bhjlxab9512fbh3phlrq6myb0smy4v2ask7ppz75gcqdlqg";
      type = "gem";
    };
    version = "2.2.1";
  };
  sigdump = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1mqf06iw7rymv54y7rgbmfi6ppddgjjmxzi3hrw658n1amp1gwhb";
      type = "gem";
    };
    version = "0.2.4";
  };
  strptime = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1yj5wwa7wbhgi7w8d9ihpzpf99niw956fhyxddhayj09fgmdcxd8";
      type = "gem";
    };
    version = "0.2.3";
  };
  tzinfo = {
    dependencies = ["concurrent-ruby"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1yvbgwzrzfhgsp8w5bmv609zfs3wfiq50l9ph9pkfwj9pl6az2d8";
      type = "gem";
    };
    version = "2.0.1";
  };
  tzinfo-data = {
    dependencies = ["tzinfo"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "17fbf05qhcxp8anmp7k5wnafw3ypy607h5ybnqg92dqgh4b1c3yi";
      type = "gem";
    };
    version = "1.2019.3";
  };
  yajl-ruby = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "16v0w5749qjp13xhjgr2gcsvjv6mf35br7iqwycix1n2h7kfcckf";
      type = "gem";
    };
    version = "1.4.1";
  };
}