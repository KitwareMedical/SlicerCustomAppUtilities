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

## Styling

### Stylesheet

The custom application Qt stylesheet may be defined in a single `Home.qss` file.

Corresponding stylesheet may be applied to the application (`slicer.app`) during module initialization using the `SlicerCustomAppUtilities.applyStyle()` function.

CSS rules should be organized in the stylesheet files from the most general to the most specific rules. Use of `/* */` comment is recommended to group the rules.

```
/*  General styling */

/* Light colors */

/* Dark colors */
```

References:
* https://doc.qt.io/qt-5/stylesheet.html
* https://doc.qt.io/qt-5/stylesheet-syntax.html

### The `cssClass` dynamic Qt property

When styling of widgets should be dynamically updated based on the application current state, the relevant states may be described using CSS classes.

In the context of Slicer custom application, CSS classes may be associated with the Qt dynamic property called `cssClass`.

These class names may be set/added/removed from a specific Qt widget using `setCssClass/addCssClass/removeCssClass` functions available in the `SlicerCustomAppUtilities` Python module.

For example, styling of `QPushButton` based on a "CSS" class called `widget--color-light` associated with one of its ancestors may be done doing the following:

```
QWidget[cssClass~="widget--color-light"] QPushButton {
    background-color: #666666;
}
```

See references below to learn more about the `[attr~=value]` syntax.

After setting, adding or removing CSS class, the function `SlicerCustomAppUtilities.polish()` should be called to ensure the stylesheet is re-applied to consider the updated `cssClass` property.

References:
* https://doc.qt.io/qt-5/properties.html#dynamic-properties
* https://developer.mozilla.org/en-US/docs/Web/CSS/Attribute_selectors#syntax

### CSS class naming convention

The naming convention based on BEM (Block, Element, Modifier) may be used.

In the example below, the classes `widget--color-light` and `widget--color-dark` are used where
* `widget` is the `Block`
* `color` is the `Element`
* `light` or `dark` are the `Modifier`

```
/* General styling */
QWidget {
    background-color: #2a2a2a;
    color: #B7B7B7;
}

QPushButton {
    background-color: #434343;
}

/* Light colors */
QWidget[cssClass~="widget--color-light"] QWidget {
    background-color: #434343;
}

QWidget[cssClass~="widget--color-light"] QPushButton {
    background-color: #666666;
}

/* Dark colors */
QWidget[cssClass~="widget--color-dark"] QWidget {
    background-color: #2a2a2a;
}

QWidget[cssClass~="widget--color-dark"] QPushButton {
    background-color: #434343;
}
```

References:
* https://getbem.com/naming/

## CMake Modules

### DownloadGitHubReleaseAsset

Download a GitHub release asset.

The module can be used when running in cmake -P script mode and it requires
the environment variable `GITHUB_TOKEN` to be set.

For example:

```cmake
  set(EP_DOWNLOAD_DIR ${CMAKE_BINARY_DIR})
  set(EP_SOURCE_DIR ${CMAKE_BINARY_DIR}/${proj})

  set(asset_filename "<assetname>")
  set(asset_sha256 "<assetsha256>")

  # The CMake function _ep_write_extractfile_script is internally provided by the
  # ExternalProject CMake module.
  if(NOT COMMAND _ep_write_extractfile_script)
    message(FATAL_ERROR "_ep_write_extractfile_script CMake function is not available")
  endif()
  _ep_write_extractfile_script(
    "${EP_DOWNLOAD_DIR}/${proj}-extract-archive.cmake" # script_filename
    "${proj}" # name
    "${EP_DOWNLOAD_DIR}/${asset_filename}" # filename
    "${EP_SOURCE_DIR}" # directory
    "" # options (introduced in CMake 3.24 through Kitware/CMake@a283e58b5)
    )

  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    DOWNLOAD_DIR ${EP_DOWNLOAD_DIR}
    DOWNLOAD_COMMAND ${CMAKE_COMMAND}
      -DGITHUB_ORG:STRING=<organization>
      -DGITHUB_REPO:STRING=<repository>
      -DGITHUB_RELEASE:STRING=<releasename>
      -DGITHUB_ASSET_FILENAME:STRING=${asset_filename}
      -DEXPECTED_SHA256:STRING=${asset_sha256}
      -DOUTPUT_DIR:STRING=${EP_DOWNLOAD_DIR}
      -P ${SlicerCustomAppUtilities_SOURCE_DIR}/CMake/DownloadGitHubReleaseAsset.cmake
    COMMAND ${CMAKE_COMMAND}
      -P "${EP_DOWNLOAD_DIR}/${proj}-extract-archive.cmake"
    SOURCE_DIR ${EP_SOURCE_DIR}
    BUILD_IN_SOURCE 1
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
    DEPENDS
      ${${proj}_DEPENDS}
    )
  set(${proj}_DIR ${EP_SOURCE_DIR})
```

where the following placeholders would need to be updated:

```
<assetname>
<assetsha256>
<organization>
<repository>
<releasename>
```

## License

This project template is distributed under the Apache 2.0 license. Please see
the *LICENSE* file for details.
