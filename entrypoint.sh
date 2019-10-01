#! /bin/sh

set -xe

ODASA_URL="$1"
ODASA_LICENSE="$2"
LANGUAGE="$3"
PROJECT_NAME="${GITHUB_REPOSITORY//\//_}"
SOURCE_LOCATION="${GITHUB_WORKSPACE}/source"

WORK=`/bin/mktemp -d -p .`
chmod +x "${WORK}"

/usr/bin/wget -O "${WORK}/odasa.zip" "${ODASA_URL}"
/usr/bin/wget -O "${WORK}/license.dat" "${ODASA_LICENSE}"
cat "${WORK}/license.dat"

/usr/bin/unzip -q "${WORK}/odasa.zip" -d "${WORK}"

export SEMMLE_LICENSE_DIR="${WORK}"
export SEMMLE_JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk

/bin/mkdir "${WORK}/${PROJECT_NAME}"

/usr/bin/java -jar "${WORK}/odasa/tools/lgtm-buildtools/lgtmbuild.jar" "${WORK}/odasa/tools/lgtm-buildtools" "${WORK}/${PROJECT_NAME}" `pwd` "${LANGUAGE}"

"${WORK}/odasa/tools/odasa" addSnapshot --source-location "$SOURCE_LOCATION" --latest --name "rev-${GITHUB_SHA}" --project "${WORK}/${PROJECT_NAME}"
"${WORK}/odasa/tools/odasa" buildSnapshot --latest --project "${WORK}/${PROJECT_NAME}" --fail-early --ignore-errors
"${WORK}/odasa/tools/odasa" export --latest --project "${WORK}/${PROJECT_NAME}" --output "${WORK}/${PROJECT_NAME}.zip" --keep-cached

rm -rf "${WORK}/${PROJECT_NAME}"
/usr/bin/unzip -q -d "${WORK}" "${WORK}/${PROJECT_NAME}.zip"

echo ::set-output name=snapshot::"${WORK}/${PROJECT_NAME}"
