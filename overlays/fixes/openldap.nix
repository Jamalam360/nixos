# Fix OpenLDAP failing check phase
final: prev: {
  openldap = prev.openldap.overrideAttrs (oldAttrs: {
    doCheck = false;
  });
}
