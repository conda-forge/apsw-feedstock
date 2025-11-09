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

if [[ $target_platform =~ linux.* ]]; then
    # So for linux find out the options
    echo "
[build_ext]
use_system_sqlite_config = True" >> setup.apsw
else
    # FIXME: MacOS CI failed to build with autodetection (locally on my M1
    # Macbooked it worked)

    # error: dlopen([...]lib/libsqlite3.3.51.0.dylib' (mach-o file, but is an
    # incompatible architecture (have 'arm64', need 'x86_64h' or 'x86_64'))

    # so we tried to build with options copioed from sqlite recipe:
    # https://github.com/conda-forge/sqlite-feedstock/blob/main/recipe/build.sh

    echo "
[build_ext]
definevalues = DSQLITE_DQS=3,\
SQLITE_ENABLE_COLUMN_METADATA,\
SQLITE_ENABLE_DBSTAT_VTAB,\
SQLITE_ENABLE_DESERIALIZE,\
SQLITE_ENABLE_EXPLAIN_COMMENTS,\
SQLITE_ENABLE_FTS3,\
SQLITE_ENABLE_FTS3_PARENTHESIS,\
SQLITE_ENABLE_FTS3_TOKENIZER,\
SQLITE_ENABLE_FTS4,\
SQLITE_ENABLE_FTS5,\
SQLITE_ENABLE_GEOPOLY,\
SQLITE_ENABLE_JSON1,\
SQLITE_ENABLE_MATH_FUNCTIONS,\
SQLITE_ENABLE_PREUPDATE_HOOK,\
SQLITE_ENABLE_RTREE,\
SQLITE_ENABLE_SESSION,\
SQLITE_ENABLE_STAT4,\
SQLITE_ENABLE_STMTVTAB,\
SQLITE_ENABLE_UNLOCK_NOTIFY,\
SQLITE_ENABLE_UPDATE_DELETE_LIMIT,\
SQLITE_LIKE_DOESNT_MATCH_BLOBS,\
SQLITE_MAX_EXPR_DEPTH=10000,\
SQLITE_MAX_VARIABLE_NUMBER=250000,\
SQLITE_SOUNDEX,\
SQLITE_STRICT_SUBTYPE=1,\
SQLITE_THREADSAFE=1,\
SQLITE_USE_URI,\
HAVE_ISNAN" >> setup.apsw
fi

$PYTHON setup.py build --enable=column_metadata,session,preupdate_hook
$PYTHON setup.py install --single-version-externally-managed --record record.txt

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
    $PYTHON setup.py test
fi
