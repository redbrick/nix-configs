
# Get all services
SERVICES="$(find ./services/ -maxdepth 1 | sed -n '1!p')"

echo "let 
  variables = import ./common/variables.nix;"

echo "in {
  imports = ["

for SERVICE in $SERVICES
do
  echo "    $SERVICE"
done

echo "  ];
  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09";
}"

