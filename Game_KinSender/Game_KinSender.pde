//
//          Spout Sender
//
//      Sharing image frames between applications
//      by Opengl/directx texture or memory map sharing
//
//      Demonstrates drawing onto the Processing
//      screen and sending out as a shared texture
//      to a Spout receiver.
//
//      Based on a Processing example sketch by by Dave Bollinger
//      http://processing.org/examples/texturecube.html
//
//      See Spout.pde for function details
//

// DECLARE A SPOUT OBJECT HERE
import SimpleOpenNI.*;
import sprites.utils.*;
import sprites.maths.*;
import sprites.*;

PImage bimg;

Sprite dragon;
Sprite knight;
Sprite knight_bullet;
Sprite dragon_bullet;
Sprite wall;
Sprite dragon_hit;

StopWatch sw = new StopWatch();

SimpleOpenNI  context;

Spout spout;


void setup() {

  size(817, 789, P2D);
  bimg = loadImage("wall.png");

  //Kinect
  context = new SimpleOpenNI(this);
  if (context.isInit() == false) {
    println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
    exit();
    return;
  }

  context.enableDepth();
  context.enableUser();

  smooth();
  //end Kinect 
  knight_bullet = new Sprite(this, "knight_bullet.png", 4, 1, 300);
  dragon_bullet = new Sprite(this, "dragon_bullet.png", 4, 1, 300);
  
  dragon_hit = new Sprite(this, "dragon_hit.png", 4, 1, 300);
  
  dragon = new Sprite(this, "dragon.png", 13, 5, 100);
  dragon.setXY(682, 625);
  dragon.setVisible(true);
  dragon.setVelXY(0.0f, 0);
  dragon.setFrameSequence(0, 60, 0.05f);

  wall = new Sprite(this, "wallbord.png", 1, 1, 400);
  wall.setXY(409, 393);
  wall.setVisible(false);
  wall.setVelXY(0.0f, 0);
  // wall.setFrameSequence(0, 60, 0.05f);


  knight = new Sprite(this, "knight.png", 13, 5, 200);
  knight.setXY(195, 660);
  knight.setVisible(true);
  knight.setVelXY(0.0f, 0);
  knight.setFrameSequence(0, 60, 0.05f);

  registerMethod("pre", this);
  registerMethod("keyEvent", this);

  // CREATE A NEW SPOUT OBJECT HERE
  spout = new Spout();

  // INITIALIZE A SPOUT SENDER HERE
  spout.initSender("Processing 3", 817, 789);

  // Alternative for memoryshare only
  //spout.initSender(width, height);
} 

void draw() { 
  background(bimg);
  S4P.drawSprites();    
  // SEND A SHARED TEXTURE HERE
  spout.sendTexture();
  //Kinect\
  // update the cam
  context.update();

  // draw depthImageMap
  //image(context.depthImage(),0,0);
  //image(context.userImage(),0,0);

  // draw the skeleton if it's available
  int[] userList = context.getUsers();
  for (int i=0; i<userList.length; i++)
  {
    if (context.isTrackingSkeleton(userList[i]))
    {
      calcPlayerAngle(userList[i]);
      calcArmShoot(userList[i]);
    }
  }
  //End Kinect
}


final int ARM_STATE_UNARMED = 0;
final int ARM_STATE_ARMED = 1;

int arm_state = ARM_STATE_UNARMED;

void calcArmShoot(int userId) {
  PVector rshoulder = new PVector();
  PVector rhand = new PVector();
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, rshoulder);  
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, rhand);  

  int above_or_below = -1;

  if (rhand.y - rshoulder.y > 30) {
    above_or_below = 1;
  } else if (rshoulder.y - rhand.y > 30 ) {
    above_or_below = -1;
  } else {
    above_or_below = 0;
  }

  if (arm_state == ARM_STATE_UNARMED) {
    if (above_or_below == 1) {
      println("arming!");
      arm_state = ARM_STATE_ARMED;
    }
  } else if (arm_state == ARM_STATE_ARMED) {
    if (above_or_below == -1) {
      println("KABOOM!");
      dragon_shoot();
      arm_state = ARM_STATE_UNARMED;
    }
  }
}

void calcPlayerAngle(int userId) {
  PVector lshoulder = new PVector();
  PVector lhand = new PVector();
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, lshoulder);  
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HAND, lhand);  
  // println("lsholder x:" + lshoulder.x + "\tlsholder y:" + lshoulder.y + "\tlhand x:" + lhand.x +  "\tlhand y:" + lhand.y +  "\tlhip x:" + lhip.x +  "\tlhip y:" + lhip.y);   
  float dx = lshoulder.x - lhand.x;
  float dy = lshoulder.y - lhand.y;
  float ang = degrees(atan2(dx, dy));
  if (ang < 0) ang = 180;
  int frame = int(map(ang, 0, 180, 0, 62));
  // println(ang + "\t" + frame);
}


// -----------------------------------------------------------------
// SimpleOpenNI events

void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");

  curContext.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext, int userId)
{
  //println("onVisibleUser - userId: " + userId);
}


void keyPressed()
{
  switch(key)
  {
  case ' ':
    context.setMirror(!context.mirror());
    break;
  }
}  




public void keyEvent(KeyEvent e) {
  int ang = 62;
  if (key == CODED) {
    switch(keyCode) {

    case DOWN:
      ang -=1;
      dragon.setFrame(ang);
      break;
    case UP:
      ang +=1;
      dragon.setFrame(ang);
      break;
    case LEFT:
      dragon_shoot();
      break;
    case RIGHT:
      knight_shoot();
      break;
    }
  } else {
    switch(e.getKeyCode()) {
    case '1':    // spacebar

      knight_bullet.setFrame(0);
      dragon_bullet.setFrame(0);

      break;
    case '2':    // spacebar

      knight_bullet.setFrame(1);
      dragon_bullet.setFrame(1);
      break;
    case '3':    // spacebar

      knight_bullet.setFrame(2);
      dragon_bullet.setFrame(2);
      break;
    case '4':    // spacebar
      knight_bullet.setFrame(3);
      dragon_bullet.setFrame(3);
      break;
    }
  }
}

void handleSpriteEvents(Sprite sprite) { 
  /* code */
}

void processCollisions() {
  if (!dragon.isDead() && knight_bullet.oo_collision(dragon, 60)) {
    knight_bullet.setXY(-10000, -10000);
    dragon.setXY(1000, 1000);
    dragon.setVelXY(0, 0);
    dragon.setDead(true);
    knight_bullet.setVisible(false);
    dragon_bullet.setDead(true);
    //    break;
  }
  //     break;
  if (!knight.isDead() && dragon_bullet.oo_collision(knight, 60)) {
    dragon_bullet.setXY(-10000, -10000);
    knight.setXY(1000, 1000);
    knight.setVelXY(0, 0);
    knight.setDead(true);
    dragon_bullet.setVisible(false);
    knight_bullet.setDead(true);
  }
//if (!wall.isDead() && dragon_bullet.oo_collision(knight,60)){
//   dragon_hit.setFrameSequence(0, 60, 0.05f);
////   dragon_bullet.setDead(true);
//}
}
public void pre() {
  // Calculate time difference since last call
  float elapsedTime = (float) sw.getElapsedTime();
  processCollisions();
  S4P.updateSprites(elapsedTime);
  println(millis());
}
void knight_shoot() {

  knight_bullet.setXY(219, 500);
  knight_bullet.setVisible(true);
  knight_bullet.setVelXY(1500.0f, 0);
}

void dragon_shoot() {

  dragon_bullet.setXY(682, 500);
  dragon_bullet.setVisible(true);
  dragon_bullet.setVelXY(-1500.0f, 0);
}

// over-ride exit to release sharing
void exit() {
  // CLOSE THE SPOUT SENDER HERE
  spout.closeSender();
  super.exit(); // necessary
} 

