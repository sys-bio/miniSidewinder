
// Functions which grab user model to run and then call the simulator (minSidewinder). 
 
 function getInfo(iframeId, modelSBML, newRT, newSS, staticRun, parSliders, spPlot, xLabel, yLabel) {
   if (typeof window !== 'undefined') {
 // Perform sessionStorage action
   const item = sessionStorage.getItem('key')
   }
   console.log('getInfo: iframeId: ', iframeId);
   sessionStorage.setItem("MODEL", modelSBML); // model: XML formated string 
   sessionStorage.setItem('RUNTIME', newRT);
   sessionStorage.setItem('STEPSIZE', newSS);
   sessionStorage.setItem('STATIC', staticRun);
   sessionStorage.setItem('SLIDERS', parSliders);
   sessionStorage.setItem('PLOT_SPECIES', spPlot);
   sessionStorage.setItem('X_LABEL', xLabel);
   sessionStorage.setItem('Y_LABEL', yLabel);
   // TEST:
   const params = sessionStorage.getItem('SLIDERS');
   console.log('getInfo() - sessionStorage(SLIDERS):', params);
  // window.location.href = ('Debug/index.html?')
  document.getElementById(iframeId).src = 'Debug/index.html'; // Location of miniSidewinder
 }
 

function runModel(frameId, modelURL, newRT, newSS, staticRun, parSliders, spPlot, xLabel, yLabel) {
  console.log('miniSidewinderSimSetup.runModel(): Values Received:');
  console.log(frameId, modelURL, newRT, newSS, staticRun, parSliders, spPlot, xLabel, yLabel);
// Use this code if you have a predefined model to run located at some URL:
//fetch('http://localhost/models/simpleRXN.xml')
//fetch('models/BIOMD0098_Goldbeter1990.xml')
 try {
   fetch(modelURL)
     .then(response => response.text())
     .then((data) => {
       console.log(data);
	   newModel = data;
	   getInfo(frameId, newModel, newRT, newSS, staticRun, parSliders, spPlot, xLabel, yLabel);
     })
 } catch(error) {
	 var errmsg = 'Model not loaded from: ' + modelURL + '. ' + error;
	 alert(errmsg);
   }
  
 }





  
  
