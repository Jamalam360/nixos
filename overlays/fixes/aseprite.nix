# Fix Aseprite build with cmake 4
# Waiting on PR #450575 to come to unstable
final: prev: {
  aseprite = prev.aseprite.overrideAttrs (old: {
    cmakeFlags =
      (old.cmakeFlags or [])
      ++ [
        "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
      ];
  });
}
