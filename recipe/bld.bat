set "CL= -DSQLITE_ENABLE_COLUMN_METADATA=1"

echo "
[build_ext]
use_system_sqlite_config = True" >> setup.apsw

%PYTHON% setup.py build --enable=column_metadata,session,preupdate_hook
%PYTHON% setup.py install --single-version-externally-managed --record record.txt
%PYTHON% setup.py test
