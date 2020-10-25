{ lib }:
with lib;
let
  # This file exports a single function which converts a nix attribute set into
  # an inspircd config file.
  # Below is an example which demonstrats some representative inspircd things you can represent:
  # {
  #   # https://github.com/inspircd/inspircd/blob/v2.0.29/docs/conf/opers.conf.example#L42
  #   # tags that have a 'name' attribute have the below sugar:
  #   class = {
  #      SACommands = { commands = "SAJOIN SAPART"; }; # <class name="SACommands" commands="SAJOIN SAPART">
  #      ServerLink = { commands = "CONNECT etc"; }; # <class name="ServerLink" commands="CONNECT etc">
  #   };
  #   # https://github.com/inspircd/inspircd/blob/v2.0.29/docs/conf/inspircd.conf.example#L166-L167
  #   # Things without a 'name' have to use this desugared list-value form
  #   bind = [
  #     { address = ""; port = "7000,7001"; type = "servers"; } # <bind address="" port="7000,7001" type="servers">
  #     { address = "1.2.3.4"; port = "7005"; type = "servers"; ssl = "openssl"; }
  #   ];
  #   # It's possible to have an empty attrset for something that only has a name, like many modules
  #   module = {
  #     "m_sakick.so" = {}; # <module name="m_sakick.so">
  #     "m_sajoin.so" = {}; # <module name="m_sajoin.so">
  #   };
  #   # XML escaping does not happen. It's your responsibility to take care of that.
  #   options = [{
  #     suffixpart = "&quot;"; # <options suffixpart="&quot;">
  #   }];
  #   # And that's it! That should be enough to represent an inspircd config.
  # }
  #
  # inspircd uses mostly named tags like '<tag name="foo" attr="value">'.
  # We optimize for this case because it's so common.
  # So, here's the goal:
  # {
  #   tag = { foo = { attr = "value"; }; bar = { baz = 1; }; }
  # }
  # is used to declare '<tag name="foo" attr="value"> <tag name="bar" baz="1">'
  # That seems reasonable so far. However, there's also non-named tags,
  # including ones that have multiple.
  # For those, we'll go with something like
  # {
  #   tag = [ { key = "value"; } { key2 = "value2"; } ]
  # }
  # which turns into '<tag key="value"> <tag key2="value2">'
  # I believe this covers all possible inspircd configs.
  # This is also unambiguous to parse. The key of the attribute set is always
  # the tag name, and fi the value is an attrset, that means it's a named tag,
  # and otherwise it's a non-named tag.
  # Technically, all named tags can be represented in the second form too, but
  # that's okay.
  attrsToKeyVals = attrset: concatStringsSep " " (
    mapAttrsToList (name: value: ''${name}="${value}"'') attrset
  );
  # As above, but add the tag
  attrsToConfigTag = tag: attrs: ''<${tag} ${attrsToKeyVals attrs}>'';
  # This transforms an object of the form:
  # '{ foo = { bar = "baz"; }; a = { b = "c"; }; }'
  # into
  # '<tag name="foo" bar="baz"> <tag name="a" b="c">'
  # inspircd happens to contain many xml objects of this type.
  namedAttrsToTags = tag: mapAttrsToList (name: subAttrs: (attrsToConfigTag tag ({ name = name; } // subAttrs)));
  listAttrsToTags = tag: map (attrs: attrsToConfigTag tag attrs);
  attrPairToTags = tag: value:
    if builtins.isList value
    then listAttrsToTags tag value
    else if builtins.isAttrs value
    then namedAttrsToTags tag value
    else throw "Value must be a list or attr, was ${builtins.typeOf value}";

  attrsToInspircdConf' = attrset: concatStringsSep "\n" (flatten (mapAttrsToList attrPairToTags attrset));
  # The standard '<config format="xml">' attr inspircd uses to identify this format
  # As far as I can tell, this is the only order-sensitive tag. It _must_ be
  # the first thing in the file, so we force its order here.
  formatTag = attrsToInspircdConf' { config = [{ format = "xml"; }]; };
  attrsToInspircdConf = attrs: formatTag + "\n" + (attrsToInspircdConf' attrs);
in
attrsToInspircdConf
