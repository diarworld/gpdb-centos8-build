# gpdb-centos8-build
Build gpdb rpm for centos8 

# Docker container with GPDB for development/testing


## Build locally
```
# Centos 8 (includes dependencies for building GPDB)
docker build -t local/gpdb-dev:centos8 .
```
OR
## Download from docker hub
```
docker pull diarworld/gpdb-dev:centos8
```

# Build GPDB code with Docker and run it

Clone GPDB repo
```
git clone https://github.com/greenplum-db/gpdb.git
cd gpdb
```
Use docker image
```
docker run -w /home/build/gpdb -v ${PWD}:/home/build/gpdb:cached -it local/gpdb-dev:centos8 /bin/bash
```

Inside docker
(Total time to build and run ~ 15-20 min)
```
# ORCA is disabled here to keep the instructions simple
./configure --enable-debug --with-perl --with-python --with-libxml --disable-orca --prefix=/usr/local/gpdb
make -j4

# Install Greenplum binaries (to /usr/local/gpdb)
make install

# Create a single node demo cluster with three segments
source /usr/local/gpdb/greenplum_path.sh
make create-demo-cluster
source ./gpAux/gpdemo/gpdemo-env.sh

# Create and use a test database
createdb greenplum
psql -d greenplum
```

# Create centos8 rpm package

Clone greenplum release repo:
```
mkdir release
cd release
git clone https://github.com/diarworld/greenplum-database-release.git
wget https://github.com/greenplum-db/gpdb/releases/download/6.0.1/6.0.1.tar.gz
tar xzf ../6.0.1.tar.gz  --strip-components=1 --directory=gpdb_src
```
Use docker image
```
docker run -w /home/build/gpdb -v ${PWD}:/home/build/gpdb:cached -it local/gpdb-dev:centos8 /bin/bash
```
Inside docker
(Total time to build and run ~ 15-20 min)
```
pip2 install -r gpdb_src/python-dependencies.txt
mkdir gpdb_artifacts
git clone https://github.com/boundary/sigar
cd sigar && mkdir build && cd build && CFLAGS='-include sys/sysmacros.h' CXXFLAGS='-include sys/sysmacros.h' cmake .. && make && make install && cd ../..
./greenplum-database-release/ci/concourse/scripts/compile_gpdb_oss.bash
mv gpdb_artifacts bin_gpdb
export PYTHONPATH=greenplum-database-release/ci/concourse/
export PLATFORM="rhel8"
export GPDB_NAME="greenplum-db"
export GPDB_RELEASE="1"
export GPDB_SUMMARY="OSS GPDB 6"
export GPDB_LICENSE="Apache"
export GPDB_URL="https://github.com/greenplum-db/gpdb"
export GPDB_BUILDARCH="x86_64"
export GPDB_DESCRIPTION="Open Source greenplum"
export GPDB_PREFIX="/usr/local"
export GPDB_OSS="true"
mkdir gpdb_rpm_installer
mkdir license_file
touch license_file/open_source_license_greenplum_database.txt
python greenplum-database-release/ci/concourse/scripts/build_gpdb_rpm.py

```