#!/usr/bin/env bash

# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -x
set -e
set -u

WORK="$(pwd)"

GH_RELEASE_TOOL_ARCH="linux_amd64"
BUILD_PLATFORM="Linux_x64"
PYTHON="python3"

###### START EDIT ######
TARGET_REPO_ORG="google"
TARGET_REPO_NAME="graphicsfuzz"
BUILD_REPO_ORG="google"
BUILD_REPO_NAME="gfbuild-graphicsfuzz"
###### END EDIT ######

COMMIT_ID="$(cat "${WORK}/COMMIT_ID")"

ARTIFACT="${BUILD_REPO_NAME}"
ARTIFACT_VERSION="${COMMIT_ID}"
GROUP_DOTS="github.${BUILD_REPO_ORG}"
GROUP_SLASHES="github/${BUILD_REPO_ORG}"
TAG="${GROUP_SLASHES}/${ARTIFACT}/${ARTIFACT_VERSION}"

BUILD_REPO_SHA="${GITHUB_SHA}"
POM_FILE="${BUILD_REPO_NAME}-${ARTIFACT_VERSION}.pom"
INSTALL_DIR="${ARTIFACT}-${ARTIFACT_VERSION}"

GH_RELEASE_TOOL_USER="c4milo"
GH_RELEASE_TOOL_VERSION="v1.1.0"

export PATH="${HOME}/bin:$PATH"

mkdir -p "${HOME}/bin"

pushd "${HOME}/bin"

# Install github-release.
curl -fsSL -o github-release.tar.gz "https://github.com/${GH_RELEASE_TOOL_USER}/github-release/releases/download/${GH_RELEASE_TOOL_VERSION}/github-release_${GH_RELEASE_TOOL_VERSION}_${GH_RELEASE_TOOL_ARCH}.tar.gz"
tar xf github-release.tar.gz

ls

popd

###### START EDIT ######

git clone https://github.com/${TARGET_REPO_ORG}/${TARGET_REPO_NAME}.git "${TARGET_REPO_NAME}"
cd "${TARGET_REPO_NAME}"
git checkout "${COMMIT_ID}"
###### END EDIT ######

###### BEGIN BUILD ######

# -Djava.net.preferIPv4Stack=true
#   Probably not needed but can help with the issue where Maven dependency downloading freezes.
# -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn
#   Increase log level of the "Download*" messages from Maven so they are hidden.
MAVEN_OPTS="-Djava.net.preferIPv4Stack=true -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn"

export PYTHON_GF="python3.6"

python3.6 --version || true

java -version

set +u
echo "${JAVA_HOME}"
echo "${PATH}"

mvn --version || true

###### END BUILD ######

###### START EDIT ######
#for f in "${INSTALL_DIR}/bin/"*; do
#  echo "${BUILD_REPO_SHA}">"${f}.build-version"
#  cp "${WORK}/COMMIT_ID" "${f}.version"
#done
###### END EDIT ######

## Add licenses file.
#cp "${WORK}/third_party/OPEN_SOURCE_LICENSES.TXT" "${INSTALL_DIR}/"
#cp "${WORK}/third_party/OPEN_SOURCE_LICENSES.TXT" ./
#
## zip file.
#pushd "${INSTALL_DIR}"
#zip -r "../${INSTALL_DIR}.zip" ./*
#popd
#
#sha1sum "${INSTALL_DIR}.zip" >"${INSTALL_DIR}.zip.sha1"
#
## POM file.
#sed -e "s/@GROUP@/${GROUP_DOTS}/g" -e "s/@ARTIFACT@/${ARTIFACT}/g" -e "s/@VERSION@/${ARTIFACT_VERSION}/g" "../fake_pom.xml" >"${POM_FILE}"
#
#sha1sum "${POM_FILE}" >"${POM_FILE}.sha1"
#
#DESCRIPTION="$(echo -e "Automated build for ${TARGET_REPO_NAME} version ${COMMIT_ID}.\n$(git log --graph -n 3 --abbrev-commit --pretty='format:%h - %s <%an>')")"
#
## Only release from master branch commits.
## shellcheck disable=SC2153
#if test "${GITHUB_REF}" != "refs/heads/master"; then
#  exit 0
#fi
#
## We do not use the GITHUB_TOKEN provided by GitHub Actions.
## We cannot set enviroment variables or secrets that start with GITHUB_ in .yml files,
## but the github-release tool requires GITHUB_TOKEN, so we set it here.
#export GITHUB_TOKEN="${GH_TOKEN}"
#
#github-release \
#  "${BUILD_REPO_ORG}/${BUILD_REPO_NAME}" \
#  "${TAG}" \
#  "${BUILD_REPO_SHA}" \
#  "${DESCRIPTION}" \
#  "${INSTALL_DIR}.zip"
#
#github-release \
#  "${BUILD_REPO_ORG}/${BUILD_REPO_NAME}" \
#  "${TAG}" \
#  "${BUILD_REPO_SHA}" \
#  "${DESCRIPTION}" \
#  "${INSTALL_DIR}.zip.sha1"
#
## Don't fail if pom cannot be uploaded, as it might already be there.
#
#github-release \
#  "${BUILD_REPO_ORG}/${BUILD_REPO_NAME}" \
#  "${TAG}" \
#  "${BUILD_REPO_SHA}" \
#  "${DESCRIPTION}" \
#  "${POM_FILE}" || true
#
#github-release \
#  "${BUILD_REPO_ORG}/${BUILD_REPO_NAME}" \
#  "${TAG}" \
#  "${BUILD_REPO_SHA}" \
#  "${DESCRIPTION}" \
#  "${POM_FILE}.sha1" || true
#
## Don't fail if OPEN_SOURCE_LICENSES.TXT cannot be uploaded, as it might already be there.
#
#github-release \
#  "${BUILD_REPO_ORG}/${BUILD_REPO_NAME}" \
#  "${TAG}" \
#  "${BUILD_REPO_SHA}" \
#  "${DESCRIPTION}" \
#  "OPEN_SOURCE_LICENSES.TXT" || true
