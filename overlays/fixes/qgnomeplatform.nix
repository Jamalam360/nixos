# Fix qgnomeplatform build with cmake 4
# Waiting on PR #449396 to be merged
final: prev: {
  qgnomeplatform = prev.qgnomeplatform.overrideAttrs (old: {
    cmakeFlags =
      (old.cmakeFlags or [])
      ++ [
        (prev.lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.31")
      ];
  });
}
