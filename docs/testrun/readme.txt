This directory is used for testing new versions of miniSidewinder on github.io before releasing it.
To use:
1. copy release candidate files over to here.
2. Point web page that loads miniSidewinder to this directory.
   Typically:
     window.location.href = ('../Debug/index.html?'); // Location of miniSidewinder
   changed to:
     window.location.href = ('../testrun/index.html?'); // Location of miniSidewinder
3. Once the webpage is working with new version, copy it over to the release directory.
