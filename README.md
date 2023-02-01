# SlicerCustomAppUtilities by Kitware

Specialized Slicer modules and scripts to support development of [custom 3D Slicer application](https://github.com/KitwareMedical/SlicerCustomAppTemplate).

At [Kitware](https://www.kitware.com), we help customers develop commercial products based on 3D Slicer and we have used the platform to rapidly prototype solutions in nearly every aspect of medical imaging.

## Slicer custom application integration

A snippet like the following should be added in the custom application `CMakeLists.txt`

Make sure to replace `<SHA>` with a valid value.

Note the explicit path appended to `Slicer_EXTENSION_SOURCE_DIRS`.

```
# Add remote extension source directories

# SlicerCustomAppUtilities
set(extension_name "SlicerCustomAppUtilities")
set(${extension_name}_SOURCE_DIR "${CMAKE_BINARY_DIR}/${extension_name}")
FetchContent_Populate(${extension_name}
  SOURCE_DIR     ${${extension_name}_SOURCE_DIR}
  GIT_REPOSITORY https://github.com/KitwareMedical/SlicerCustomAppUtilities.git
  GIT_TAG        <SHA>
  GIT_PROGRESS   1
  QUIET
  )
message(STATUS "Remote - ${extension_name} [OK]")
list(APPEND Slicer_EXTENSION_SOURCE_DIRS ${${extension_name}_SOURCE_DIR}/Modules/Scripted/SlicerCustomAppUtilities)
```

## License

This project template is distributed under the Apache 2.0 license. Please see
the *LICENSE* file for details.
