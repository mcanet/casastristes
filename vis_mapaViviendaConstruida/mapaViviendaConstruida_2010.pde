// Visualizing constructed apartments in Spain from 1991-2006
// http://casastristes.org
// Gerald Kogler
// last compiled on Processing 1.2.1

//adapt map values!
boolean com = false;  //true=comunidad; false=provincia
int max_val = 0;  //maximum value of data source
int ynum = 16;  //número de años que visualizamos
float col_min = 55/3.6;
float col_max = 100/3.6;
int fac=500;  //factor de división para definir el tamaño de los circulos
String unidad = "";  //unidad del número mostrado

PShape total, layer;
String[] com_names;  //leyenda
float[][] com_vals;  //rows->vals; cols->años
float[][] com_pobl;  //rows->vals; cols->años
int[][] locs;  //x+y location
String title,titlePobl;
int yact,ypri,yfin;
String fileStatistics;
Integrator thisVals[];
Integrator thisPobl[];
PFont fontA;
PImage logo;

void setup(){
  if (com){
    size(700, 643);
    fileStatistics = new String("ViviendasCA19912006.csv");
  } else{
    size(600, 400);
    fileStatistics = new String("ViviendasProvincias19912006.csv");
  }
  smooth();
  background(255);
  colorMode(HSB,100);
  fontA = loadFont("ArialMT-14.vlw");
  logo = loadImage("casastristes-hor.png");
  //mapping
  getLayers();
  getPoblacion();
  getLocations();
  if (com) total = loadShape("comunidades.svg");
  else total = loadShape("provincias.svg");
  smooth();
  drawLayers();
} 

void draw(){
  for (int i = 0; i < thisVals.length; i++) {
    thisVals[i].update();
  }
  drawLayers();
}

/********************************* DRAW FUNCTIONS ************************************/
void drawLayers(){
  background(100,0,100);
  
  for (int i=0; i<com_names.length; i++) {
    layer = total.getChild(com_names[i]);
    float val_org = com_vals[i][yact-ypri];

    //draw layer
    float val = lerp(col_min,col_max,val_org/max_val);
    //val = map(val_org,col_min,col_max,0,max_val);
    stroke(100,0,100);
    fill(int(val),100,95);
    layer.disableStyle();
    shape(layer,0,0);
  }
  drawTitle();
  drawCircle();
  drawLegend();
}

void drawTitle(){
  //draw logo
  image(logo,width-200,0);

  //draw text
  fill(0,0,0);
  textFont(fontA, 14);
  textAlign(RIGHT,TOP);
  //text(title+" vs. "+titlePobl+" ["+ypri+":"+yfin+"]", width/2, 10, width/2-10, 50);
  text("Aumento de personas menos numero de viviendas construidas ["+ypri+":"+yfin+"]", width-200, 40, 200, 50);
  fill(100,100,100);
  text(str(yact), width-200, 100, 200, 20);  
}

void drawCircle(){
  for (int i=0; i<com_names.length; i++) {
    float val_org = com_vals[i][yact-ypri];

    //sustrair viviendas nuevas de la poblacion
    int result = int(com_pobl[i][yact-ypri])-int(val_org+unidad);
    int resAbs = abs(result);

    //draw circle
    stroke(0,0,50);
    if (result<0) fill(100,50,100,50);
    else fill(100,0,100,50);
    //ellipse(locs[i][0],locs[i][1],thisVals[i].value/fac,thisVals[i].value/fac);
    ellipse(locs[i][0],locs[i][1],resAbs/fac,resAbs/fac);
    
    //draw text
    if (result<0) fill(100,100,100);
    else fill(0,0,0);
    textFont(fontA, 10);
    textAlign(CENTER,TOP);
    text(result,locs[i][0],locs[i][1]+resAbs/(fac*2)+2);
    //text((int)val_org+unidad+"-"+int(com_pobl[i][yact-ypri]),locs[i][0],locs[i][1]+val_org/(fac*2)+2);
    //println(com_names[i]+"> val:"+com_vals[i][yact-ypri]+" - lerp val:"+val);
  }
}

void drawLegend(){
  textFont(fontA, 14);
  textAlign(LEFT,BOTTOM);

  fill(0,0,0);
  text("numero de viviendas libres terminadas", 10, height-60);
  
  //min
  fill(0,0,0);
  text("min (0"+unidad+")",10,height-30);
  fill(col_min,100,95);
  rect(100,height-40,15,15);
  //max
  fill(0,0,0);
  text("max ("+max_val+unidad+")",10,height-10);
  fill(col_max,100,95);
  rect(100,height-20,15,15);
}

/********************************* DATA FUNCTIONS ************************************/
void getLayers(){
  //load txt
  String[] lines = loadStrings(fileStatistics);
  int num = lines.length-1;  // menos primera
  com_names = new String[num];
  com_vals = new float[num][ynum];
  thisVals = new Integrator[num];
  println("layers encontrado (num de comunidades o provincias): "+num);

  //get first row
  String[] pieces = split(lines[0], '\t');
  if (pieces.length == ynum+1) {
    title = new String(pieces[0]);
    ypri = int(pieces[1]);
    yact = ypri;
    yfin = ypri+ynum-1;
  } else {
    println("error en archivo TXT statistics");
  }
  println("Titulo: "+title+" del "+yact+" al "+yfin);
  
  //get rows 1..rownum
  for (int i=1; i<=num; i++) {
    pieces = split(lines[i], '\t');
    if (pieces.length == ynum+1) {
      com_names[i-1] = new String(pieces[0]);
      for (int j=0; j<ynum; j++){
        com_vals[i-1][j] = float(pieces[j+1]);
        int ythis = j+ypri;
        //println(com_names[i-1]+" > "+yact+":"+com_vals[i-1][j]);
      }
      if (max(com_vals[i-1]) > max_val) max_val=int(max(com_vals[i-1]));
      //fill integrator array
      thisVals[i-1] = new Integrator(com_vals[i-1][0]);
    } else {
      println("error en archivo TXT statistics");
    }
  }
  println("max val found:"+max_val);
}

void getPoblacion(){
  //load txt
  String[] lines;
  if (com) lines = loadStrings("PoblacionCA.csv");
  else lines = loadStrings("PoblacionProvincias.csv");
  int num = lines.length-1;  // menos primera
  
  com_pobl = new float[num][ynum];
  thisPobl = new Integrator[num];
  println("poblacion (num de comunidades o provincias): "+num);

  //get first row
  String[] pieces = split(lines[0], '\t');
  if (pieces.length == ynum+1) {
    titlePobl = new String(pieces[0]);
    if (int(pieces[1]) != ypri){
      println("error en archivo TXT poblacion: ypri");
    }
  } else {
    println("error en archivo TXT poblacion: ynum="+pieces.length);
  }
  println("Titulo Poblacion: "+titlePobl+" del "+yact+" al "+yfin);
  
  //get rows 1..rownum
  for (int i=1; i<=num; i++) {
    pieces = split(lines[i], '\t');
    if (pieces.length == ynum+1) {
      if (com_names[i-1].equals(new String(pieces[0]))){
        for (int j=0; j<ynum; j++){
          com_pobl[i-1][j] = float(pieces[j+1]);
          //println(com_names[i-1]+" > "+yact+":"+com_pobl[i-1][j]);
        }
      } else {
        println("error en archivo TXT poblacion: orden no conincide con archivo de datos: "+com_names[i-1]+"-"+new String(pieces[0]));
      }
      //fill integrator array
      thisPobl[i-1] = new Integrator(com_pobl[i-1][0]);
    } else {
      println("error en archivo TXT poblacion: ynum2");
    }
  }
}

void getLocations(){
  //hasta ahora el archivo locations.txt tiene que tener el mismo orden de provincias/comunidades que el archivo de datos
  String[] lines;
  if (com) lines = loadStrings("locs_comunidades.tsv");
  else lines = loadStrings("locs_provincias.tsv");
  locs = new int[lines.length][2];
  if (lines.length >= com_names.length){
    for (int i=0; i<lines.length; i++) {
      String[] pieces = split(lines[i], '\t');
      if (pieces.length == 3) {
        int pos = getPos(pieces[0]);  //posición de dato en array de leyenda
        if (pos >= 0){
          locs[pos][0] = int(pieces[1]);  //x
          locs[pos][1] = int(pieces[2]);  //y
          //println(pieces[0]+" x:"+pieces[1]+" y:"+pieces[2]);
        }
      } else {
        println("locations: error en formato del archivo");
      }
    }
  } else {
    println("locations: faltan datos ya que son menos que array com_names");    
  }  
}

int getPos(String name){
  for (int i=0; i<com_names.length; i++){
    if(name.equals(com_names[i])) return(i);
  }
  return(-1);
}

void mousePressed(){
  if (yact < yfin) yact++;
  else yact = ypri;
  drawLayers();
  //actualizar integrator array
  for (int i = 0; i < thisVals.length; i++) {
    thisVals[i].target(com_vals[i][yact-ypri]);
  }
}
