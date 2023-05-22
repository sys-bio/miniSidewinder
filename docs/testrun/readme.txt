This directory is used for testing new versions of miniSidewinder on github.io before releasing it.
To use:
1. copy release candidate files over to here.
2. Point web page (..libretexts/libreTextsTemplateTestPage.html) that loads miniSidewinder to this directory.
   Typically:
    //const simURL = "https://sys-bio.github.io/miniSidewinder/libretexts/libreTextsLoadSim.html"; // Release location
   change to:	
    const simURL = "https://sys-bio.github.io/miniSidewinder/testrun/libreTexts_testrunLoadSim.html"; // testing location
   
3. Once the webpage is working with new version, copy it over to the release directory.
