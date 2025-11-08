#!/bin/bash
set -euxo pipefail

export CFLAGS="-I${PREFIX}/include -DSQLITE_ENABLE_COLUMN_METADATA=1 ${CFLAGS}"
export LDFLAGS="-L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib ${LDFLAGS}"

# see https://github.com/rogerbinns/apsw/issues/585#issuecomment-3496816950
#
# Don't use --enable-all-extensions because you are using the system SQLite,
# and need to match its extensions. Those are defined in the sqlite recipe and
# carray is not one of them, so linking would fail.
#
# There is specific advice in the APSW doc
# (https://rogerbinns.github.io/apsw/install.html#advice-for-packagers) on how
# to match the system SQLite configuration.

echo "
[build_ext]
use_system_sqlite_config = True" >> setup.apsw

$PYTHON setup.py build --enable=column_metadata,session,preupdate_hook
$PYTHON setup.py install --single-version-externally-managed --record record.txt

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
    $PYTHON setup.py test
fi
