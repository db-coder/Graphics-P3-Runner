// Student's should use this to render their model


void showDancer(pt LeftFoot, float transfer, pt RightFoot, vec Forward, pt Top, pt Bottom)
  {
  float footRadius=3, kneeRadius = 6,  hipRadius=12 ; // radius of foot, knee, hip
  float hipSpread = hipRadius; // half-displacement between hips
  float bodyHeight = 100; // height of body center B
  float ankleBackward=10, ankleInward=4, ankleUp=6, ankleRadius=4; // ankle position with respect to footFront and size
  float pelvisHeight=10, pelvisForward=hipRadius/2, pelvisRadius=hipRadius*1.3; // vertical distance form BodyCenter to Pelvis 
  float LeftKneeForward = 20; // arbitrary knee offset for mid (B,H)

  vec Up = V(0,0,1); // up vector
  vec dir = U(V(Bottom,Top));
  
  vec Right = N(dir,Forward); // side vector pointing towards the right
  
  // BODY
  pt BodyProjection = L(LeftFoot,1./3+transfer/3,RightFoot); // floor projection of B
  pt BodyCenter = P(BodyProjection,bodyHeight,dir); // Body center
  fill(blue); showShadow(BodyCenter,5); // sphere(BodyCenter,hipRadius);
  //fill(blue); arrow(BodyCenter,V(100,Forward),5); // forward arrow
  
 
 // ANKLES
  pt RightAnkle =  P(RightFoot, -ankleBackward,Forward, -ankleInward,Right, ankleUp,dir);
  fill(red);  
  capletSection(RightFoot,footRadius,RightAnkle,ankleRadius);  
  pt LeftAnkle =  P(LeftFoot, -ankleBackward,Forward, ankleInward,Right, ankleUp,dir);
  fill(green);  
  capletSection(LeftFoot,footRadius,LeftAnkle,ankleRadius);  
  fill(blue);  
  sphere(RightAnkle,ankleRadius);
  sphere(LeftAnkle,ankleRadius);
 
  // FEET (CENTERS OF THE BALLS OF THE FEET)
  fill(blue);  
  sphere(RightFoot,footRadius);
  pt RightToe =   P(RightFoot,5,Forward);
  capletSection(RightFoot,footRadius,RightToe,1);
  sphere(LeftFoot,footRadius);
  pt LeftToe =   P(LeftFoot,5,Forward);
  capletSection(LeftFoot,footRadius,LeftToe,1);

  // HIPS
  pt RightHip =  P(BodyCenter,hipSpread,Right);
  fill(red);  sphere(RightHip,hipRadius);
  pt LeftHip =  P(BodyCenter,-hipSpread,Right);
  fill(green);  sphere(LeftHip,hipRadius);

  // KNEES AND LEGs
  float RightKneeForward = 20;
  pt RightMidleg = P(RightHip,RightAnkle);
  pt RightKnee =  P(RightMidleg, RightKneeForward,Forward);
  fill(red);  
  sphere(RightKnee,kneeRadius);
  capletSection(RightHip,hipRadius,RightKnee,kneeRadius);  
  capletSection(RightKnee,kneeRadius,RightAnkle,ankleRadius);  
   
  pt LeftMidleg = P(LeftHip,LeftAnkle);
  pt LeftKnee =  P(LeftMidleg, LeftKneeForward,Forward);
  fill(green);  
  sphere(LeftKnee,kneeRadius);
  capletSection(LeftHip,hipRadius,LeftKnee,kneeRadius);  
  capletSection(LeftKnee,kneeRadius,LeftAnkle,ankleRadius);  

  // PELVIS
  pt Pelvis = P(BodyCenter,pelvisHeight,dir, pelvisForward,Forward); 
  fill(blue); sphere(Pelvis,pelvisRadius);
  capletSection(LeftHip,hipRadius,Pelvis,pelvisRadius);  
  capletSection(RightHip,hipRadius,Pelvis,pelvisRadius);  

  //TORSO
  pt Neck = P(Top,-3.5*pelvisRadius,dir);
  fill(magenta);
  capletSection(Neck,1.5*pelvisRadius,Pelvis,pelvisRadius);
  
  //HEAD
  Neck = P(Top,-3.7*pelvisRadius,dir);
  pt Head = P(Top,-1.5*pelvisRadius,dir);
  fill(yellow);
  sphere(Head,1.5*pelvisRadius);
  capletSection(Head,pelvisRadius/2,Neck,1.6*pelvisRadius);
  
  // SHOLDERS
  pt RightSholder =  P(Neck,hipSpread,Right);
  fill(red);  sphere(RightSholder,hipRadius);
  pt LeftSholder =  P(Neck,-hipSpread,Right);
  fill(green);  sphere(LeftSholder,hipRadius);
  
  // JOINT
  pt RightJoint =  P(BodyCenter,4*hipRadius,Right);  
  pt LeftJoint =  P(BodyCenter,-4*hipRadius,Right);
  fill(blue);  
  sphere(RightJoint,ankleRadius);
  sphere(LeftJoint,ankleRadius);
 
  // PALM (CENTERS OF THE BALLS OF THE PALMS)
  fill(blue);  
  sphere(RightJoint,footRadius);
  pt RightFinger =   P(RightJoint,15,Forward);
  capletSection(RightJoint,footRadius,RightFinger,2);
  sphere(LeftJoint,footRadius);
  pt LeftFinger =   P(LeftJoint,15,Forward);
  capletSection(LeftJoint,footRadius,LeftFinger,2);
  
  // ELBOWS AND HANDS
  float RightElbowForward = 10, LeftElbowForward = 10;
  pt RightMidHand = P(RightSholder,RightJoint);
  pt RightElbow =  P(RightMidHand,-RightElbowForward,Forward);
  fill(red);  
  sphere(RightElbow,kneeRadius);
  capletSection(RightSholder,hipRadius,RightElbow,kneeRadius);  
  capletSection(RightElbow,kneeRadius,RightJoint,ankleRadius);  
   
  pt LeftMidHand = P(LeftSholder,LeftJoint);
  pt LeftElbow =  P(LeftMidHand,-LeftElbowForward,Forward);
  fill(green);  
  sphere(LeftElbow,kneeRadius);
  capletSection(LeftSholder,hipRadius,LeftElbow,kneeRadius);  
  capletSection(LeftElbow,kneeRadius,LeftJoint,ankleRadius);
  }
  
void capletSection(pt A, float a, pt B, float b) { // cone section surface that is tangent to Sphere(A,a) and to Sphere(B,b)
  coneSection(A,B,a,b);
  }  