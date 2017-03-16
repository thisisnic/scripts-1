BREWDIR="$TMPDIR/homebrew"
BREW="$BREWDIR/bin/brew"
rm -Rf $BREWDIR
mkdir -p $BREWDIR
echo "Auto-brewing $PKG_BREW_NAME in $BREWDIR..."
curl -fsSL https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C $BREWDIR
HOMEBREW_CACHE="/tmp" $BREW install pkg-config 2>&1 | perl -pe 's/Warning/Note/gi'
HOMEBREW_CACHE="/tmp" $BREW install --force-bottle libpng jpeg libtiff leptonica ${PKG_BREW_NAME}  2>&1 | perl -pe 's/Warning/Note/gi'
PKG_CFLAGS=`$BREWDIR/opt/pkg-config/bin/pkg-config --cflags ${PKG_CONFIG_NAME}`
PKG_LIBS=`$BREWDIR/opt/pkg-config/bin/pkg-config --libs --static ${PKG_CONFIG_NAME}`
PKG_LIBS="-L$BREWDIR/lib $PKG_LIBS"
rm -f $BREWDIR/lib/*.dylib
rm -f $BREWDIR/Cellar/*/*/lib/*.dylib

# Prevent CRAN builder from linking against old libs in /usr/local/lib
for FILE in $BREWDIR/Cellar/*/*/lib/*.a; do
  BASENAME=$(basename $FILE)
  LIBNAME=$(echo "${BASENAME%.*}" | cut -c4-)
  cp -f $FILE $BREWDIR/lib/libbrew$LIBNAME.a
  echo "created $BREWDIR/lib/libbrew$LIBNAME.a"
  PKG_LIBS=$(echo $PKG_LIBS | sed "s/-l$LIBNAME /-lbrew$LIBNAME /g")
done

# Include share directory
mkdir -p inst
cp -Rf  $BREWDIR/opt/tesseract/share/tessdata inst/