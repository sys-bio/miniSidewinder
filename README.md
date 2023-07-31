# miniSidewinder
A client side web application for simulating biological reactions using models written in SBML (Systems Biology Markup Language).

MiniSidewinder is a Delphi, Object Pascal based, client-side browser application that makes use of TMS Web Core to convert Delphi to javascript code. The compiled application consists of html, css, javascript, and wasm files and is run completely within the client (user) browser. This project was funded by NIH/NIGMS (R01-GM123032-04).

- Google sites demo: https://sites.google.com/view/interactive-modeling/home  

- Demo embedded in simple webpage: https://sys-bio.github.io/miniSidewinder/

- For more information on Sidewinder, a web application for building and simulating of biological reactions, see: https://github.com/sys-bio/sidewinder

## Using miniSidewinder in your website
To embed miniSidewinder in your website and simulate SBML models, follow the steps below:
- Copy the `../docs/simulator/` folder over to a location on your website. This contains the actual miniSidewinder executable code.
- Place your SBML formatted models to a location on your website (ex: /models/)
- Fill out a copy of `basicTemplate.html` in the `../docs/basicWebpage/` directory and insert it into the webpage on your site. A very basic webpage example is `example.html` and can be viewed through your web browser at https://sys-bio.github.io/miniSidewinder/basicWebpage/example.html
- Below is the information you need to fill out in `basicTemplate.html`:
  
  - `const modelURL = '../models/sbmlmodelname.xml';` Location of sbml model file on your website.
  - `const newRT = '10';` Length of run in model time units.
  - `const newSS = '0.10';` Integrator step size, total pts = newRt/newSS, 100 points: (10/0.10)
  - `const staticRun = 'true';` Display after all calculations are done.
  - `const sliders = 'VM1,Keq1,h,V4,S1,S2';` Parameter and species sliders, exact id match, '' defaults to first 8 params and first 4 species of model.
  - `const spPlot = 'S1,S2,S3,S4';` Species to plot, exact id match, '' defaults to first up to 8 species.
  - `const yLabel = 'conc (uM)';`   Plot label, displayed at bottom as: yLabel vs. xLabel.
  - `const xLabel = 'sec';`
  
  Simulator location on web server (adjust as needed):
  - `const simURL = "../simulator/index.html"; `
   
If you want to place the miniSidewinder code on a different server from the model webpage then you must deal with Same-origin policy for browsers.  See: Same-origin policy [mozilla.org] (https://developer.mozilla.org/en-US/docs/Web/Security/Same-origin_policy) . For an example of a work around, see our implementation on Google Sites: https://sites.google.com/view/interactive-modeling/home . In the Google Sites example miniSidewinder and the SBML model file are on a different website (GitHub) from the model webpage. The web page code and template is in the `../docs/sysbiomodels/` directory. The pertinent files are `sysbioLoadSim.html` and `sysbioTemplate.html`.

## Building miniSidewinder
The following tools are needed to build miniSidewinder:
- Delphi 11.1, https://www.embarcadero.com/products/delphi
- TMS Web Core version 2.0.2 or greater, https://www.tmssoftware.com/site/tmswebcoreintro.asp
- TMS FNC UI pack, https://www.tmssoftware.com/site/tmsfncuipack.asp

The build incorporates a web assembly (wasm) library `libsbml.wasm` that may need to be updated from time to time. Please see https://github.com/sys-bio/libsbmljs for further information. Currently the `libsbml.wasm` and `libsbml.js` files are kept in the `../sbml/ directory`.

## Unsupported SBML features
MiniSidewinder does not support the full SBML specification (https://sbml.org/documents/specifications/).
- There are no SBML packages supported.
- SBML **piecewise** and **event** objects are unsupported.
- There currently is no support for reactions that involve species in different compartments.
- Many MathML contructs are currently not supported, such as **piece, factorial, sin, cos, tan, sec, csc, cot sech, csch, coth, arcsin, arccos,
 arctan, arcsec, arccsc, arccot, arcsinh, arccosh, arctanh, arcsech, arccsch, arccoth**.

Please submit an **Issue** if you would like an unsupport SBML feature added to miniSidewinder. As time permits, new features will be added.
