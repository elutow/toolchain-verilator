# -- Compile Verilator script

VER=4.028
VERILATOR=verilator-$VER
TAR_VERILATOR=v$VER.tar.gz
REL_VERILATOR=https://github.com/verilator/verilator/archive/$TAR_VERILATOR
# -- Setup
. $WORK_DIR/scripts/build_setup.sh

cd $UPSTREAM_DIR

# -- Check and download the release
test -e $TAR_VERILATOR || wget $REL_VERILATOR

# -- Unpack the release
tar zxf $TAR_VERILATOR

# -- Copy the upstream sources into the build directory
rsync -a $VERILATOR $BUILD_DIR --exclude .git

cd $BUILD_DIR/$VERILATOR

if [ $ARCH != "darwin" ]; then
  export CC="$HOST-gcc $CONFIG_HOST"
  export CXX="$HOST-g++ $CONFIG_HOST"
fi

if [ ${ARCH:0:7} == "windows" ]; then
  cp /usr/include/FlexLexer.h $BUILD_DIR/$VERILATOR/src/.
fi

# -- Prepare for building
autoconf
echo CFLAGS="$MAKE_CFLAGS" CXXFLAGS="$MAKE_CXXFLAGS" LDFLAGS="$MAKE_LDFLAGS"
./configure --build=$BUILD --host=$HOST --prefix="$PACKAGE_DIR/$NAME" CFLAGS="$MAKE_CFLAGS" CXXFLAGS="$MAKE_CXXFLAGS" LDFLAGS="$MAKE_LDFLAGS"

# -- Compile it
make -j$J
make install

# -- Test the generated executables
if [ $ARCH != "darwin" ]; then
  test_bin $PACKAGE_DIR/$NAME/bin/verilator_bin
fi
