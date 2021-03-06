SOURCE_DIR="/git_source"
DIST_DIR="/usr"

SUPPORTED_GIT_VERSION="2.24"

mkdir -p ${DIST_DIR}

# Install build dependencies
echo "Installing git build dependencies"
apt-get update
apt-get install -y --no-install-recommends git dh-autoreconf libcurl4-gnutls-dev libexpat1-dev libz-dev libssl-dev

# cut -c53- here drops the SHA (40), tab (1) and "refs/tags/v" (11), because some things, like the
# snapshot URL and tarball root directory, don't have the leading "v" from the tag in them
# Thanks to Bryan Turner for this improved method of retrieving the appropriate git version
GIT_VERSION=$(git ls-remote git://git.kernel.org/pub/scm/git/git.git | cut -c53- | grep "^${SUPPORTED_GIT_VERSION}\.[0-9\.]\+$" | sort -V | tail -n 1)
curl -s -o - "https://git.kernel.org/pub/scm/git/git.git/snapshot/git-${GIT_VERSION}.tar.gz" | tar -xz --strip-components=1 --one-top-level="${SOURCE_DIR}"
cd "${SOURCE_DIR}"

# Uninstall pkg git
apt-get purge -y git

# Install git from source
make configure
./configure --prefix=${DIST_DIR}
make NO_TCLTK=1 NO_GETTEXT=1 install

# Remove and clean up dependencies
cd /
rm -rf ${SOURCE_DIR}
apt-get purge -y dh-autoreconf
apt-get clean autoclean
apt-get autoremove -y
rm -rf /var/lib/apt/lists/*
