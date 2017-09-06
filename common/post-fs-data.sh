#!/system/bin/sh

MODDIR=${0%/*}
DISABLE=/data/data/de.robv.android.xposed.installer/conf/disabled
MIRRDIR=/dev/magisk/mirror

log_print() {
  log -p i -t Magisk "XposedHelper: $1"
}

bind_mount() {
  if [ -e $1 -a -e $2 ]; then
    mount -o bind $1 $2 && log_print "Mount: $1" || log_print "Mount Fail: $1"
  fi
}

[ -f $DISABLE ] && exit

# Cleanup
if [ -f $MODDIR/lists ]; then
  for dir in `cat $MODDIR/lists`; do
    rm -rf $MODDIR$dir 2>/dev/null
  done
fi
rm -f $MODDIR/lists

for ODEX in `find /system -type f -name "*.odex*" 2>/dev/null`; do
  # Rename the odex files
  mkdir -p $MODDIR${ODEX%/*}
  touch $MODDIR${ODEX%/*}/.replace
  ln -s $MIRRDIR$ODEX $MODDIR${ODEX}.xposed
  # Record so we can remove afterwards
  echo ${ODEX%/*} >> $MODDIR/lists
done
for BOOT in `find /system/framework -type f -name "boot.*" 2>/dev/null`; do
  ln -s $MIRRDIR$BOOT $MODDIR$BOOT 2>/dev/null
done
