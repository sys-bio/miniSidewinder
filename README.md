# miniSidewinder
A client side web application for simulating biological reactions using models written in SBML (Systems Biology Markup Language).

miniSidewinder is a Delphi, Object Pascal based, client-side browser application that makes use of TMS Web Core to convert Delphi to javascript code. The compiled application consists of html, css, javascript, and wasm files and is run completely within the client (user) browser.
- Google sites demo: https://sites.google.com/view/interactive-modeling/home  

- Demo embedded in simple webpage: https://sys-bio.github.io/miniSidewinder/

- For more information on Sidewinder, a web application for building and simulating of biological reactions, see: https://github.com/sys-bio/sidewinder

## Building miniSidewinder
The following tools are needed to build miniSidewinder:
- Delphi 11.1, https://www.embarcadero.com/products/delphi
- TMS Web Core version 2.0.2 or greater, https://www.tmssoftware.com/site/tmswebcoreintro.asp
- TMS FNC UI pack, https://www.tmssoftware.com/site/tmsfncuipack.asp

The build incorporates a web assembly (wasm) library libsbml.wasm that may need to be updated from time to time. Please see https://github.com/sys-bio/libsbmljs for further information. Currently the libsbml.wasm and libsbml.js files are kept in the ../sbml/ directory.
