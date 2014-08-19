HashMap<PVector, Integer> structures = new HashMap();
PImage wall;
PImage floor;
PImage goblinWall;
PImage player;
PVector pLoc;
float pRot;
ArrayList<Character> keys = new ArrayList<Character>();
boolean collide = false;
float speed = 2;
boolean showDebug = false;
float scale = 50; //Number of pixels width of a square

void setup() {
  size(800, 600);
  pRot = 0;
  pLoc = new PVector(0, 0);
  wall = loadImage("wall.png");
  goblinWall = loadImage("goblin_wall.png");
  floor = loadImage("floor.png");
  player = loadImage("miner.png");
  player.resize(floor(scale * .7), 0);
  loadMap();
}

void draw() {
  background(200);
  //walls();
  pointer();
  control();
  player();
  physics();
}

/*
go through both x and y
then take the location add the players location to it
then render the ones on the screen
*/

void keyTyped() {
  if(key == 'p') {
    saveMap();
  }
  
  if(key == 'x') {
    exit();
  }
  
  if(key == TAB) {
    //show minimap
  }
  
  if(key == 'l') {
    showDebug = !showDebug;
  }

//  if(key == 'CHAR') {
//    //DO SOMTHING
//  }
}

void keyPressed() {
  if(!keys.contains(key)) {
    keys.add(key);
  }
}

void keyReleased() {
  if(keys.contains(key)) {
    keys.remove(keys.indexOf(key));
  }
}

void control() {
  ArrayList<Character> temp = keys;
  for(char i : temp) {
    PVector add = PVector.fromAngle(pRot);
    add.setMag(speed);
    if(i == 'w') {
      PVector w = add.get();
      pLoc.add(w);
    }
    
    if(i == 's') {
      PVector s = add.get();
      s.rotate(PI);
      pLoc.add(s);
    }
    
    if(i == 'a') {
      PVector a = add.get();
      a.rotate(PI + HALF_PI);
      pLoc.add(a);
    }
    
    if(i == 'd') {
      PVector d = add.get();
      d.rotate(HALF_PI);
      pLoc.add(d);
    }
  }
}

float getRot(PVector m, PVector p) {
  float rot = 0;
  if(p.x < m.x ) {
    rot = atan((p.y - m.y) / (p.x - m.x));
  } else { 
    rot = PI + atan((m.y - p.y) / (m.x - p.x));
  }
  return rot;
}

void player() {
  float rot = getRot(mouseLoc(), pLoc);
  pRot = rot;
  pushMatrix();
  translate(pLoc.x, pLoc.y);
  rotate(rot + HALF_PI);
  image(player, -player.width/2, -player.height/2);
  popMatrix();
}

void physics() {
  PVector rot = new PVector(0, -player.width / 2);
  int boom = 0;
  int iter = 20;
  PVector bounce = new PVector(0,0);
  for(int r = 0; r < iter; r++){
    PVector test = PVector.add(rot, pLoc);
    PVector sq = getRect(test);
    
    if(showDebug) {
      pushMatrix();
      if(collide){
        stroke(255,0,0);
      } else {
        stroke(0,255,0);
      }
      fill(0);
      ellipse(test.x, test.y, 2, 2);
      popMatrix();
    }
    
    if(structures.get(new PVector(sq.x, sq.y)) != 0){
      PVector face = rot.get();
      face.rotate(PI);
      face.setMag(speed);
      bounce.add(face);
      boom++;
    }
    rot.rotate(PI * 2 /iter);
  }
  
  if(boom == 0){
    collide = false;
  } else {
    pLoc.add(bounce);
    collide = true;
  }
}

PVector getRect(PVector loc) {
  int x = floor(loc.x / scale);
  int y = floor(loc.y / scale);
  return new PVector(x, y);
}

PVector mouseLoc() {
 return new PVector(mouseX, mouseY);
}

void mousePressed() {
  PVector loc = getRect(mouseLoc());
  int temp = structures.get(loc);
  temp++;
  if(temp > 2) {
    temp = 0;
  }
  structures.put(loc, temp);
}

void pointer() {
  noFill();
  stroke(255,0,0);
  PVector loc = getRect(mouseLoc());
  int mx = floor(loc.x * scale);
  int my = floor(loc.y * scale);
  rect(mx, my, scale, scale);
}

void walls() {
  for(int x = 0; x < structures.size(); x++) {
    for(int y = 0; y < structures.size(); y++) {
      int temp = structures.get(new PVector(x, y));
      if(temp == 0){
        image(floor, x*scale, y*scale);
      } 
      if(temp == 1) {
        image(wall, x*scale, y*scale);
      }
      
      if(temp == 2) {
        image(goblinWall, x*scale, y*scale);
      }
    }
  }
}

void saveMap() {
  PrintWriter output = createWriter("data/world.txt");
  String line = "";
  println("saving map!");
  PVector player = getRect(pLoc);
  for(int y = 0; y < structures.size(); y++) {
    for(int x = 0; x < structures.size(); x++) {
      if(player.x == x && player.y == y) {
        line = line + "p";
      } else {
        line = line + structures.get(new PVector(x, y));
      }
      
      if(x != 9) {
        line = line + ",";
      }
    }
    println(line);
    output.println(line);
    line = "";
  }
  output.close();
  println("saved!");
}

void loadMap() {
  BufferedReader reader = createReader("world.txt");
  String line = null;
  int y = 0;
  
  while(true){
    try {
      line = reader.readLine();
    } catch (IOException e){
      e.printStackTrace();
      line = null;
    }
    
    if (line == null) {
      break; 
    } else {
      String[] pieces = split(line, ',');
      for(int x = 0; x < pieces.length; x++) {
        if(pieces[x].equalsIgnoreCase("p")) {
          pLoc = new PVector(x * scale + 50, y  * scale + 50);
          structures.put(new PVector(x, y), 0);
        } else {
          structures.put(new PVector(x, y), Integer.valueOf(pieces[x]));
        }
      }   
      y++;
    }
  }
  try {
    reader.close();
  } catch (IOException e){
    e.printStackTrace();
  }
}
