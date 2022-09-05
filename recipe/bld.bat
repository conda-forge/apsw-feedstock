set CFLAGS="-DSQLITE_ENABLE_COLUMN_METADATA=1 %CFLAGS%"
%PYTHON% setup.py build --enable-all-extensions --enable=load_extension
%PYTHON% setup.py install --single-version-externally-managed --record record.txt
%PYTHON% setup.py test
