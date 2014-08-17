int[][] walls = new int[10][10];
PImage wall;
PImage floor;
PImage goblinWall;
PImage player;
PVector pLoc;
ArrayList<Character> keys = new ArrayList<Character>();
boolean collide = false;
float speed = 2;
boolean showDebug = false;

void setup() {
  size(1000, 1000);
  pLoc = new PVector(350, 650);
  wall = loadImage("wall.png");
  goblinWall = loadImage("goblin_wall.png");
  floor = loadImage("floor.png");
  player = loadImage("miner.png");
  player.resize(70, 0);
  loadMap();
}

void draw() {
  background(200);
  walls();
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
    saveMap();
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
    if(i == 'w') {
      pLoc.y -= speed;
    }
    
    if(i == 's') {
      pLoc.y += speed;
    }
    
    if(i == 'a') {
      pLoc.x -= speed;
    }
    
    if(i == 'd') {
      pLoc.x += speed;
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
  rot = rot + HALF_PI;
  return rot;
}

void player() {
  float rot = getRot(mouseLoc(), pLoc);
  
  pushMatrix();
  translate(pLoc.x, pLoc.y);
  rotate(rot);
  image(player, -player.width/2, -player.height/2);
  if(showDebug) {
    noFill();
    if(collide){
      stroke(255,0,0);
    } else {
      stroke(0,255,0);
    }
    ellipse(0, 0, 75, 75);
  }
  popMatrix();
}

void physics() {
  PVector rot = new PVector(0, -37.5);
  int boom = 0;
  int iter = 20;
  PVector bounce = new PVector(0,0);
  for(int r = 0; r < iter; r++){
    PVector test = PVector.add(rot, pLoc);
    int[] sq = getRect(test);
    
    if(showDebug) {
      pushMatrix();
      fill(0);
      ellipse(test.x, test.y, 2, 2);
      popMatrix();
    }
    
    if(walls[sq[0]][sq[1]] != 0){
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

int[] getRect(PVector loc) {
  int x = floor(loc.x / 100);
  int y = floor(loc.y / 100);
  return new int[] {x, y};
}

PVector mouseLoc() {
 return new PVector(mouseX, mouseY);
}

void mousePressed() {
  int[] loc = getRect(mouseLoc());
  walls[loc[0]][loc[1]]++;
  if(walls[loc[0]][loc[1]] > 2) {
    walls[loc[0]][loc[1]] = 0;
  }
}

void pointer() {
  noFill();
  stroke(255,0,0);
  int[] loc = getRect(mouseLoc());
  int mx = loc[0] * 100;
  int my = loc[1] * 100;
  rect(mx, my, 100, 100);
}

void walls() {
  for(int x = 0; x < walls.length; x++) {
    for(int y = 0; y < walls.length; y++) {
      if(walls[x][y] == 0){
        image(floor, x*100, y*100);
      } 
      if(walls[x][y] == 1) {
        image(wall, x*100, y*100);
      }
      
      if(walls[x][y] == 2) {
        image(goblinWall, x*100, y*100);
      }
    }
  }
}

void saveMap() {
  PrintWriter output = createWriter("data/world.txt");
  String line = "";
  println("saving map!");
  int[] player = getRect(pLoc);
  for(int y = 0; y < walls.length; y++) {
    for(int x = 0; x < walls.length; x++) {
      if(player[0] == x && player[1] == y) {
        line = line + "p";
      } else {
        line = line + walls[x][y];
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
          pLoc = new PVector(x * 100 + 50, y  * 100 + 50);
        } else {
          walls[x][y] = Integer.valueOf(pieces[x]);
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
