//Zaehler fuer ROI Manager nROI und Measure Funktion nMeasure
nROI = 0;
nMeasure = 0;
//Bild oeffnen
open("");
//Grauwert auf 100 normieren
//run("Measure");
//Grauwert = getResult("Max", nMeasure);
//nMeasure=nMeasure+1;
//multiplyValue=255/Grauwert;
//run("Multiply...", "value="+multiplyValue);
//Output Ordner auf Ordner des Bildes festlegen
dir = getDirectory("image");
//Zaehler fuer Anzahl Arteriolen counter
counter = 1;
Ende = 1;
//Messungen anpassen 
run("Set Measurements...", "area mean min fit redirect=None decimal=3");
//Skala festlegen
waitForUser("create scalaline");
run("Measure");
Skalalaenge = getResult("Length", nMeasure);
nMeasure=nMeasure+1;
Skalawert = getNumber("Laenge der Skala in mm", 20);
Skala = Skalawert/Skalalaenge;
run("Set Scale...", "distance="+Skalalaenge+" known="+Skalawert+" unit=mm");
//Referenzlinie am Distalen Fesselbein erstellen und messen
waitForUser("Create straight line that marks the width of the distal fetlock");
roiManager("add");
roiManager("Show All");
roiManager("select", nROI);
nROI = nROI+1;
roiManager("Measure");
lReferenz = getResult("Length", nMeasure);
nMeasure = nMeasure+1;
//horizontale Referenzlinie erstellen und messen
waitForUser(" draw a transversal line at the level of the coffin joint");
roiManager("add");
roiManager("select", nROI);
nROI = nROI+1;
roiManager("Measure");
alphaReferenz = getResult("Angle", nMeasure);
nMeasure = nMeasure+1;
//Outputfile erstellen
f=File.open(dir+"output.txt");
getDateAndTime(year, month, week, day, hour, min, sec, msec);
month=month+1;
print(f,"Date: "+day+"/"+month+"/"+year+"  Time: " +hour+":"+min+":"+sec);
print(f, "Breite Distales Fesselbein [mm]:"+lReferenz)
print(f, "Skala [mm/Pixel]:"+Skala)
print(f, "Arteriole" + "  \t" + "Winkel [°]" + "  \t" + "Flaeche [mm2]" + " \t" + "rel. Flaeche [%]" + " \t" + "Laenge [mm]" + " \t" + "rel. Laenge [%]"+ " \t" + "Breite [mm]" + " \t" + "rel. Breite [%]" + " \t" + "Oeffnungswinkel[°]" + " \t" + "rel. Laenge bis Arcus Terminalis");
File.close(f);
//Schleife für Arteriolen
while (Ende == 1) {
//Drei Basislinien erstellen
waitForUser("Create the left line from margo solearis to arcus termininalis");
roiManager("add");
waitForUser("Create the right line from margo solearis to the visible end of the arteriole");
roiManager("add");
waitForUser("Create the closing line of the arteriole");
roiManager("add");
//Punkte der Linien speichern und Winkel messen
waitForUser("Chose left line of the arteriole in the ROI Manager");
roiManager("select", nROI);
roiManager("Measure");
Anglea = getResult("Angle", nMeasure);
mlength = getResult("Length", nMeasure);
nMeasure = nMeasure+1;
roiManager("select", nROI);
nROI = nROI+1;
Roi.getCoordinates(xpoints, ypoints);
a0 = newArray(xpoints[0],ypoints[0]);
a1 = newArray(xpoints[1],ypoints[1]);
roiManager("select", nROI);
nROI=nROI+1;
roiManager("Measure");
Angleb = getResult("Angle", nMeasure);
nMeasure=nMeasure+1;
Roi.getCoordinates(xpoints, ypoints);
b0 = newArray(xpoints[0],ypoints[0]);
b1 = newArray(xpoints[1],ypoints[1]);
roiManager("select", nROI);
nROI=nROI+1;
Roi.getCoordinates(xpoints, ypoints);
c0 = newArray(xpoints[0],ypoints[0]);
c1 = newArray(xpoints[1],ypoints[1]);
//Schnittpunkt fuer Polygon berechnen
ra = a1[1]-(((a0[1]-a1[1])/(a0[0]-a1[0]))*a1[0]);
rc = c1[1]-(((c0[1]-c1[1])/(c0[0]-c1[0]))*c1[0]);
ma = ((a0[1]-a1[1])/(a0[0]-a1[0]));
mc = ((c0[1]-c1[1])/(c0[0]-c1[0]));
s1y = ma*((rc-ra)/(ma-mc))+ra;
s1x = (rc-ra)/(ma-mc);

rb = b1[1]-(((b0[1]-b1[1])/(b0[0]-b1[0]))*b1[0]);
rc = c1[1]-(((c0[1]-c1[1])/(c0[0]-c1[0]))*c1[0]);
mb = ((b0[1]-b1[1])/(b0[0]-b1[0]));
mc = ((c0[1]-c1[1])/(c0[0]-c1[0]));
s2y = mb*((rc-rb)/(mb-mc))+rb;
s2x = (rc-rb)/(mb-mc);

//Polygon erstellen und Flaeche messen
makePolygon(a0[0],a0[1],s1x,s1y,s2x,s2y,b0[0],b0[1]);
roiManager("add");
roiManager("select", nROI);
nROI=nROI+1;
roiManager("Measure");
area = getResult("Area", nMeasure);
nMeasure=nMeasure+1;
//Relative Flaeche berechnen
relarea = (area / (lReferenz*lReferenz))*100;
//Laenge der Arteriole als Durchschnitt der beiden Seiten berechnen
la= sqrt(((a0[0]-s1x)*(a0[0]-s1x))+((a0[1]-s1y)*(a0[1]-s1y)));
lb= sqrt(((b0[0]-s2x)*(b0[0]-s2x))+((b0[1]-s2y)*(b0[1]-s2y)));
dla= ((la+lb)*Skala)/2;
//Laenge der ersten Linie als Referenz fuer Laenge berechnen
lar= (sqrt(((a0[0]-a1[0])*(a0[0]-a1[0]))+((a0[1]-a1[1])*(a0[1]-a1[1]))))*Skala;
//Relative Laenge berechnen
reldla = (dla/lar)*100;
reldlaneu = (dla/lReferenz)*100;
//breite arteriole berechnen
dba = (area/dla);
//Relative Breite berechnen
reldba = (dba/lReferenz)*100;
//Oeffnungswinkel berechnen
alpha=abs(Anglea-Angleb);
//Mittellinie erstellen
mux = a0[0]-((a0[0]-b0[0])/2);
muy = a0[1]-((a0[1]-b0[1])/2);
mox = s1x-(s1x-s2x)/2;
moy = s1y-(s1y-s2y)/2;
makeLine(mux,muy,mox,moy,2);
roiManager("add")
nROI=nROI+1;
roiManager("Measure");
alpham = getResult("Angle", nMeasure);
nMeasure = nMeasure+1;
//Winkel zur horizontalen berechnen
alphadiff = alpham-alphaReferenz;
//f=File.open(dir+"output.txt");
//Ergebnisse in Outputfile schreiben
File.append(counter + "  \t" + alphadiff + "  \t" + area + " \t" + relarea + " \t" + dla + " \t" + reldlaneu + " \t" + dba + " \t" + reldba + " \t" + alpha + " \t" + reldla, dir+"output.txt");
//File.close(f);
counter = counter+1;
//Abfrage ob weiter Arteriole vermessen werden soll
Ende = getBoolean("Shoud an other arteriole be mesured?");
}
counter = 1;
Ende = getBoolean(" Shoud an ellipse be mesured?");
if(Ende == 1){
File.append("Ellipses present?",dir+"output.txt");
File.append("Ellipse"+ "  \t" + "Hauptachse [mm]" + "  \t" + "Rel. Hauptachse [%]" + "  \t" + "Nebenachse [mm]" + "  \t" + "Rel. Nebenachse [%]" + "  \t" + "Quotient" + "  \t" + "Flaeche [mm2]" + "  \t" + "Rel. Flaeche [%]" + "  \t" ,dir+"output.txt");
} else {
File.append("keine Ellipsen vorhanden",dir+"output.txt");}
//Schleife für Ellipsoide
while (Ende == 1) {
//Lagune erstellen
waitForUser("Create Ellipse");
roiManager("add");
roiManager("select", nROI);
nROI = nROI+1;
waitForUser("chose Ellipse in the ROI Manager");
roiManager("Measure");
Major = getResult("Major", nMeasure);
Minor = getResult("Minor", nMeasure);
areaellipse = getResult("Area", nMeasure);
nMeasure = nMeasure+1;
relMajor = (Major/lReferenz)*100;
relMinor = (Minor/lReferenz)*100;
relareaellipse = (areaellipse/(lReferenz*lReferenz))*100;
quotient = Major/Minor;
File.append(counter + "  \t"  + Major + "  \t" + relMajor + "  \t" + Minor + "  \t" + relMinor + "  \t"  + quotient + "  \t"  + areaellipse + "  \t"  + relareaellipse,dir+"output.txt");
counter = counter+1;
Ende = getBoolean("Shoud another Ellipse be mesured?");
}
//Bild mit Linien speichern
run("From ROI Manager");
saveAs("Jpeg", dir+"analyzed.jpg");
