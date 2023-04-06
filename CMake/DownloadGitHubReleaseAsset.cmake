# SPDX-FileCopyrightText: 2023 Kitware, Inc. and Contributors
# SPDX-License-Identifier: Apache-2.0

#[=======================================================================[.rst:

DownloadGitHubReleaseAsset
--------------------------

Download a GitHub release asset.

The module can be used when running in cmake -P script mode.

.. warning::

  It requires the environment variable ``GITHUB_TOKEN`` to be set.

Usage:

::

  cmake \
   -DGITHUB_ORG:STRING=<org> \
   -DGITHUB_REPO:STRING=<repo> \
   -DGITHUB_RELEASE:STRING=<release> \
   -DGITHUB_ASSET_FILENAME:STRING=<filename> \
   -DEXPECTED_SHA256:STRING=<sha256> \
   -DOUTPUT_DIR:STRING=<dir> \
   [-OUTPUT_FILENAME:STRING=<filename>] \
   -P DownloadGitHubReleaseAsset.cmake

Specifying ``OUTPUT_FILENAME`` allows to save asset using a different filename.


Example:

::

  cmake \
   -DGITHUB_ORG:STRING=Slicer \
   -DGITHUB_REPO:STRING=SlicerTestingData \
   -DGITHUB_RELEASE:STRING=SHA256 \
   -DGITHUB_ASSET_FILENAME:STRING=5793a202127f69a993b1e8247f98cb4e8a6a6b34d6345665121b6b0a9102c7b2 \
   -DEXPECTED_SHA256:STRING=5793a202127f69a993b1e8247f98cb4e8a6a6b34d6345665121b6b0a9102c7b2 \
   -DOUTPUT_DIR:STRING=/tmp \
   -DOUTPUT_FILENAME:STRING=ThresholdScalarVolumeTest.nhdr \
   -P DownloadGitHubReleaseAsset.cmake

#]=======================================================================]

if(NOT DEFINED ENV{GITHUB_TOKEN})
  message(FATAL_ERROR "GITHUB_TOKEN env. variable is expected to be defined !")
endif()

# Sanity checks
set(expected_nonempty_vars
  GITHUB_ORG
  GITHUB_REPO
  GITHUB_RELEASE
  GITHUB_ASSET_FILENAME
  EXPECTED_SHA256
  OUTPUT_DIR
  )
foreach(var ${expected_nonempty_vars})
  if("${${var}}" STREQUAL "")
    message(FATAL_ERROR "CMake variable ${var} is empty !")
  endif()
endforeach()

if(NOT OUTPUT_FILENAME)
  set(OUTPUT_FILENAME ${GITHUB_ASSET_FILENAME})
endif()

function(_retrieve_asset_id output_var)

  set(json_output_file "${OUTPUT_DIR}/DownloadGitHubReleaseAsset-${GITHUB_ORG}-${GITHUB_REPO}-${GITHUB_RELEASE}-${GITHUB_ASSET_FILENAME}.json")

  file(DOWNLOAD "https://api.github.com/repos/${GITHUB_ORG}/${GITHUB_REPO}/releases/tags/${GITHUB_RELEASE}" ${json_output_file}
    HTTPHEADER "Authorization: token $ENV{GITHUB_TOKEN}"
    HTTPHEADER "Accept: application/vnd.github+json"
    )

  file(READ ${json_output_file} json_output)

  string(JSON assets GET ${json_output} "assets")

  string(JSON assets_count LENGTH ${assets})

  message(STATUS "Found release ${GITHUB_RELEASE} with ${assets_count} assets")

  # This variable is set only if an asset with its "name" attribute matching the given "filename" is found
  set(asset_id "")

  # Since json arrays are 0-based indexed, set range "stop" value accordingly
  math(EXPR range_stop "${assets_count}-1")

  foreach(index RANGE 0 ${range_stop})
    string(JSON nth_asset GET ${assets} "${index}")

    string(JSON asset_name GET ${nth_asset} "name")
    if(asset_name STREQUAL "${GITHUB_ASSET_FILENAME}")
      string(JSON asset_id GET ${nth_asset} "id")
      break()
    endif()
  endforeach()

  set(${output_var} "${asset_id}" PARENT_SCOPE)

endfunction()

function(_check_datafile dest_file expected_sha256 output_var)
  get_filename_component(filename ${dest_file} NAME)
  message(STATUS "Checking ${filename}")

  if(NOT EXISTS ${dest_file})
    message(STATUS "Checking ${filename} - nonexistent")
    set(${output_var} "nonexistent" PARENT_SCOPE)
    return()
  endif()

  file(SHA256 ${dest_file} current_hash)
  if(NOT ${current_hash} STREQUAL ${expected_sha256})
    message(STATUS "Checking ${filename} - expired")
    set(${output_var} "expired" PARENT_SCOPE)
    return()
  endif()

  message(STATUS "Checking ${filename} - up-to-date")
  set(${output_var} "ok" PARENT_SCOPE)
endfunction()

function(_download_asset dest_file url userpwd expected_sha256)
  get_filename_component(filename ${dest_file} NAME)

  _check_datafile(${dest_file} ${expected_sha256} result)

  if(result MATCHES "^(nonexistent|expired)$")
    message(STATUS "Downloading ${filename}")
    file(DOWNLOAD "${url}" ${dest_file}
      USERPWD "${userpwd}"
      HTTPHEADER "Accept: application/octet-stream"
      #SHOW_PROGRESS
      EXPECTED_HASH SHA256=${expected_sha256}
      )
    message(STATUS "Downloading ${filename} - done")
  elseif(result STREQUAL "ok")
    return()
  else()
    message(FATAL_ERROR "Unknown result value: ${result}")
  endif()
endfunction()

_retrieve_asset_id(asset_id)
message(STATUS "Found asset ${GITHUB_ASSET_FILENAME} with id ${asset_id}")
if(NOT ${asset_id})
  message(FATAL_ERROR "${filename} not found")
endif()

_download_asset(
  "${OUTPUT_DIR}/${OUTPUT_FILENAME}"
  "https://api.github.com/repos/${GITHUB_ORG}/${GITHUB_REPO}/releases/assets/${asset_id}"
  "${GITHUB_ORG}/${GITHUB_REPO}:$ENV{GITHUB_TOKEN}"
  ${EXPECTED_SHA256}
  )

