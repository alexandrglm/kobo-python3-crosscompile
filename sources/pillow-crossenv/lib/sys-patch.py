cross_compiling = True
build_path = ['/home/dev/Desktop/ClaraColour/python/py311venv/host/lib/python311.zip', '/home/dev/Desktop/ClaraColour/python/py311venv/host/lib/python3.11', '/home/dev/Desktop/ClaraColour/python/py311venv/host/lib/python3.11/lib-dynload', '/home/dev/Desktop/ClaraColour/python/crosstoolsng/pillow-crossenv/build/lib/python3.11/site-packages']
platform = 'linux'
abiflags = ''
if abiflags is None:
    del abiflags

implementation._multiarch = 'x86_64-linux-gnu'
if implementation._multiarch is None:
    del implementation._multiarch

# Remove cross-python from sys.path. It's not needed after startup.
path.remove('/home/dev/Desktop/ClaraColour/python/crosstoolsng/pillow-crossenv/lib')
path.remove('/home/dev/Desktop/ClaraColour/python/py311venv/host/lib/python3.11')

# If a process started by cross-python tries to start a subprocess with sys.executable,
# make sure that it points at cross-python.
executable = '/home/dev/Desktop/ClaraColour/python/crosstoolsng/pillow-crossenv/cross/bin/python3.11'
