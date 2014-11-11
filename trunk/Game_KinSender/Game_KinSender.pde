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

import SimpleOpenNI.*;
import sprites.utils.*;
import sprites.maths.*;
import sprites.*;

//import ddf.minim.*;
//
//Minim minim;
//
//AudioPlayer knight_sound;
//AudioPlayer dragon_sound;
//AudioPlayer player;

final int DRAGON_MAX_ANGLE_FRAME = 30;
final int KNIGHT_MAX_ANGLE_FRAME = 30;

final int MAX_BULLET_BOUNCE_COUNT = 5;

final int ENERGY_DECAY_INTERVAL = 100;
final int ENERGY_DECAY_STEP = 30;

long last_decay_tstamp = 0;
int last_torso_height = -1;
int energizer = 0;

PImage bimg;

Sprite wall;

Sprite dragon_body;
Sprite dragon_head;
Sprite dragon_bullet;
Sprite dragon_hit;
Sprite dragon_health;
Sprite dragon_power;
int dragon_angle = 0;
int dragon_bullet_bounce_counter = 0;
// DEBUG ZVIKA >>>
//int dragon_hits_counter = 0;
int dragon_hits_counter = 5;

int dragon_life_box_counter=0;
int knight_life_box_counter=0;

Sprite knight_body;
Sprite knight_head;
Sprite knight_bullet;
Sprite knight_hit;
Sprite knight_health;
Sprite knight_power;
int knight_angle = 0;
int knight_bullet_bounce_counter = 0;
int knight_hits_counter = 0;

Sprite hit_bounce;
Sprite life_box;


StopWatch sw = new StopWatch();

SimpleOpenNI  context;

Spout spout;


void setup() {

  size(817, 789, P2D);
  bimg = loadImage("wall01.png");
  // minim = new Minim(this);
  //  player = minim.loadFile("Bg.wav");
  //  player.play();
   kinect_init();
  //knight_sound =minim.loadFile( "knight_hit.wav");
  //dragon_sound =minim.loadFile( "dragon_hit.wav");
 

  Domain domain = new Domain(0, 0, width, height);

  knight_bullet = new Sprite(this, "knight_bullet.png", 4, 1, 400);
  dragon_bullet = new Sprite(this, "dragon_bullet.png", 4, 1, 400);



  knight_bullet.setDomain(domain, Sprite.REBOUND);
  dragon_bullet.setDomain(domain, Sprite.REBOUND);


  life_box = new Sprite(this, "life_box.png", 5, 2, 300);
  life_box.setXY(440, 435);
  life_box.setVisible(false);
  life_box.setVelXY(0.0f, 0);
  life_box.setFrameSequence(0, 10, 0.0f);


  dragon_hit = new Sprite(this, "dragon_hit.png", 6, 2, 400);
  dragon_hit.setXY(700, 600);
  dragon_hit.setVisible(false);
  dragon_hit.setVelXY(0.00f, 0);
  dragon_hit.setFrameSequence(0, 12, 0.0f);


  dragon_head = new Sprite(this, "dragon_head.png", 13, 5, 300);
  dragon_head.setXY(710, 720);
  dragon_head.setVisible(true);
  dragon_head.setVelXY(0.0f, 0);
  dragon_head.setFrameSequence(0, 33, 0.0f);

  dragon_body = new Sprite(this, "dragon_body.png", 13, 5, 200);
  dragon_body.setXY(682, 725);
  dragon_body.setVisible(true);
  dragon_body.setVelXY(0.0f, 0);
  dragon_body.setFrameSequence(0, 60, 0.05f);

  dragon_health = new Sprite(this, "dragon_health.png", 1, 12, 800);
  dragon_health.setXY(680, 395);
  dragon_health.setVisible(true);
  dragon_health.setVelXY(0.0f, 0);
  dragon_health.setFrameSequence(0, 60, 0.0f);

  dragon_power = new Sprite(this, "dragon_power.png", 1, 12, 800);
  dragon_power.setXY(700, 408);
  dragon_power.setVisible(true);
  dragon_power.setVelXY(0.0f, 0);
  dragon_power.setFrameSequence(0, 60, 0.0f);
  dragon_power.setFrame(dragon_hits_counter);





  hit_bounce = new Sprite(this, "hit_bounce.png", 1, 1, 400);
  hit_bounce.setXY(408, 394);
  hit_bounce.setVisible(true);
  hit_bounce.setVelXY(0.0f, 0);
 





  knight_body = new Sprite(this, "knight_body.png", 13, 5, 300);
  knight_body.setXY(195, 660);
  knight_body.setVisible(true);
  knight_body.setVelXY(0.0f, 0);
  knight_body.setFrameSequence(0, 60, 0.05f);

  knight_head = new Sprite(this, "knight_head.png", 13, 5, 300);
  knight_head.setXY(195, 638);
  knight_head.setVisible(false);
  knight_head.setVelXY(0.0f, 0);
  knight_head.setFrameSequence(0, 60, 0.00f);


  knight_health = new Sprite(this, "knight_health.png", 1, 12, 800);
  knight_health.setXY(200, 395);
  knight_health.setVisible(true);
  knight_health.setVelXY(0.0f, 0);
  knight_health.setFrameSequence(0, 60, 0.0f);

  knight_power = new Sprite(this, "knight_power.png", 1, 12, 800);
  knight_power.setXY(180, 405);
  knight_power.setVisible(true);
  knight_power.setVelXY(0.0f, 0);
  knight_power.setFrameSequence(0, 60, 0.0f);
  knight_power.setFrame(knight_hits_counter);


  knight_hit = new Sprite(this, "knight_hit.png", 6, 2, 400);
  knight_hit.setXY(200, 615);
  knight_hit.setVisible(false);
  knight_hit.setVelXY(0.00f, 0);
  knight_hit.setFrameSequence(0, 12, 0.0f);



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

  kinect_update();
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
  } 
  else if (rshoulder.y - rhand.y > 30 ) {
    above_or_below = -1;
  } 
  else {
    above_or_below = 0;
  }

  if (arm_state == ARM_STATE_UNARMED) {
    if (above_or_below == 1) {
      arm_state = ARM_STATE_ARMED;
    }
  } 
  else if (arm_state == ARM_STATE_ARMED) {
    if (above_or_below == -1) {
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
  int frame = int(map(ang, 0, 180, 0, DRAGON_MAX_ANGLE_FRAME));
  switch(userId) {
  case 0:
    knight_angle = frame;
    knight_head.setFrame(knight_angle);
    
    break;
  case 1:
   dragon_angle = frame;
    dragon_head.setFrame(dragon_angle);
    break;
  }
}

void calc_energize(int userId) {
  PVector jointPos = new PVector();
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_TORSO,jointPos);
  int torso_height = int(jointPos.y);
  // print("torso_height: " + torso_height); 
  if(last_torso_height > 0) {
    int delta_height = abs(last_torso_height - torso_height);
    //println("delta_height: " + delta_height); 
    energizer += delta_height;
  }
  if(millis() - last_decay_tstamp > ENERGY_DECAY_INTERVAL) {
    energizer -= ENERGY_DECAY_STEP;
  }
  if(energizer < 0) {
    energizer = 0;
  }
  last_torso_height = torso_height;
  println("\tenergizer: " + energizer);
  if(energizer > 50) {
    dragon_hits_counter--;
    
    energizer = 0;
    if(dragon_hits_counter < 0) {
      dragon_hits_counter = 0;
    }
    dragon_power.setFrame(dragon_hits_counter);
  }
  
}


// -----------------------------------------------------------------
// SimpleOpenNI events

void onNewUser(SimpleOpenNI curContext, int userId)
{
  //  println("onNewUser - userId: " + userId);
  //  println("\tstart tracking skeleton");
  curContext.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId) {
  //  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext, int userId) {
  //println("onVisibleUser - userId: " + userId);
}


void keyPressed()
{
  //  switch(key)
  //  {
  //  case ' ':
  //    context.setMirror(!context.mirror());
  //    break;
  //  }
}  




public void keyEvent(KeyEvent e) {
  if (key == CODED) {
    switch(keyCode) {
    case DOWN:
      dragon_angle -=1;
      dragon_angle = constrain(dragon_angle, 0, DRAGON_MAX_ANGLE_FRAME);
      dragon_head.setFrame(dragon_angle);

      knight_angle -=1;
      knight_head.setVisible(true);
      knight_body.setVisible(false);
      knight_angle = constrain(knight_angle, 0, KNIGHT_MAX_ANGLE_FRAME);
      knight_head.setFrame(knight_angle);

      break;
    case UP:
      dragon_angle +=1;
      dragon_angle = constrain(dragon_angle, 0, DRAGON_MAX_ANGLE_FRAME);
      dragon_head.setFrame(dragon_angle);

      knight_angle +=1;
      knight_head.setVisible(true);
      knight_body.setVisible(false);
      knight_angle = constrain(knight_angle, 0, KNIGHT_MAX_ANGLE_FRAME);
      knight_head.setFrame(knight_angle);
      break;
    case LEFT:
      dragon_shoot();
      break;
    case RIGHT:
      knight_shoot();
      break;
    }
  } 
  else {
    switch(e.getKeyCode()) {
    case '1':    

      knight_bullet.setFrame(0);
      dragon_bullet.setFrame(0);

      break;
    case '2':   

      knight_bullet.setFrame(1);
      dragon_bullet.setFrame(1);
      break;
    case '3':   

      knight_bullet.setFrame(2);
      dragon_bullet.setFrame(2);
      break;
    case '4':   
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

  if (!knight_bullet.isDead() && knight_bullet.pp_collision(hit_bounce)) {
    if (knight_bullet_bounce_counter++ < MAX_BULLET_BOUNCE_COUNT) {
      knight_bullet.setVelX(knight_bullet.getVelX() * -1);
    }
    else {
      knight_bullet_bounce_counter = 0;
      knight_bullet.setVisible(false);
    }
  }

  if (!dragon_bullet.isDead() && dragon_bullet.pp_collision(hit_bounce)) {
    if (dragon_bullet_bounce_counter++ < MAX_BULLET_BOUNCE_COUNT) {
      dragon_bullet.setVelX(dragon_bullet.getVelX() * -1);
    }
    else {
      dragon_bullet_bounce_counter = 0;
      dragon_bullet.setVisible(false);
    }
  }

  if (!dragon_body.isDead() && (knight_bullet.oo_collision(dragon_body, 60) || knight_bullet.oo_collision(dragon_head, 60))) {
    dragon_hits_counter += 1;
    // dragon_sound.trigger();
    dragon_hit.setVisible(true);
    knight_bullet.setXY(-10000, -10000);
    knight_bullet.setVisible(false);
    dragon_hit.setFrameSequence(0, 12, 0.05f, 1);

    if (dragon_hits_counter < 12) {
      dragon_health.setFrame(dragon_hits_counter);
    }
    if (dragon_hits_counter>=12) {
      dragon_hit.setFrameSequence(0, 12, 0.05f, 1);
      dragon_body.setXY(1000, 1000);
      dragon_body.setVelXY(0, 0);
      dragon_body.setDead(true);
      dragon_head.setDead(true);
      knight_bullet.setVisible(false);
      dragon_bullet.setDead(true);
      dragon_hit.setVisible(true);
    }
    //    break;
  }
  //     break;
  if (!knight_body.isDead() && (dragon_bullet.oo_collision(knight_body, 60) || dragon_bullet.oo_collision(knight_head, 60))) {
    knight_hits_counter += 1;
    // knight_sound.trigger();
    knight_hit.setVisible(true);
    dragon_bullet.setXY(-10000, -10000);
    dragon_bullet.setVisible(false);
    knight_hit.setFrameSequence(0, 12, 0.05f, 1); 

    if (knight_hits_counter < 12) {
      knight_health.setFrame(knight_hits_counter);
    }
    if (knight_hits_counter >= 12) {
      println("DEAD!!");
      knight_health.setFrame(11);
      knight_hit.setVisible(true);
      knight_hit.setFrameSequence(0, 12, 0.05f, 1);
      knight_body.setXY(1000, 1000);
      knight_body.setVelXY(0, 0);
      knight_head.setXY(1000, 1000);
      knight_head.setVelXY(0, 0);
      knight_body.setDead(true);
      knight_head.setDead(true);
      knight_bullet.setDead(true);
      //
    }
  }
  if (knight_hits_counter == 5 || dragon_hits_counter == 5) {
    life_box.setVisible(true);
  }
  //dragon
  if (dragon_bullet.oo_collision(life_box, 60)) {
    dragon_life_box_counter +=1;
    int life_dragon = dragon_life_box_counter;
    if (life_dragon == 5) {
      dragon_health.setFrame(1);
      life_box.setVisible(false);
    }
  }
  // knight
  if (knight_bullet.oo_collision(life_box, 60)) {
    knight_life_box_counter +=1;
    int life_knight = knight_life_box_counter;
    if (life_knight == 5) {
      knight_health.setFrame(1);
      life_box.setVisible(false);
    }
  }
}
public void pre() {
  // Calculate time difference since last call
  float elapsedTime = (float) sw.getElapsedTime();
  processCollisions();
  S4P.updateSprites(elapsedTime);
  // println(millis());
}

void knight_shoot() {
  knight_bullet.setXY(219, 500);
  knight_bullet.setVisible(true);
  knight_bullet.setVelXY(750.0f, map(knight_angle, 0, KNIGHT_MAX_ANGLE_FRAME, 0, -750));
}

void dragon_shoot() {
  dragon_bullet.setXY(682, 550);
  dragon_bullet.setVisible(true);
  dragon_bullet.setVelXY(-750.0f, map(dragon_angle, 0, DRAGON_MAX_ANGLE_FRAME, 0, -750));
}

// over-ride exit to release sharing
void exit() {
  // CLOSE THE SPOUT SENDER HERE
   spout.closeSender();
  super.exit(); // necessary
} 

void kinect_init() {
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
}

void kinect_update() {
  // update the cam
  context.update();

  int[] userList = context.getUsers();
  for (int i=0; i<userList.length; i++)
  {
    if (context.isTrackingSkeleton(userList[i]))
    {
      calcPlayerAngle(userList[i]);
      calcArmShoot(userList[i]);
      calc_energize(userList[i]);
    }
  }
  //End Kinect
}

