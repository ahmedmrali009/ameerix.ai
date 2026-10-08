{{flutter_js}}
{{flutter_build_config}}

// Version the compiled entry point and do not register an offline app cache.
for (const build of _flutter.buildConfig.builds) {
  if (build.mainJsPath) build.mainJsPath += '?v=AMHILO_BUILD_ID';
}
_flutter.loader.load();
