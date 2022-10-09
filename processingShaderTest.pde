//https://www.shadertoy.com/view/3s3GDn
int dv = 20;
float arcWidth = 5;
PShader shade;
PShader channels;
PShader blur;
PShader brcosa;

Burst burst1;
Burst burst2;


void setup(){
  size(640,640,P2D);
  //smooth(16);
  colorMode(HSB,100);
  background(0);
  noStroke();
  burst1 = new Burst();
  burst2 = new Burst();
  
  shade = loadShader("burst2.glsl");
  //shade = loadShader("burst.glsl","texVert.glsl");
  //shade = loadShader("randomFlares.glsl");   
  channels = loadShader("channels.glsl");
  blur = loadShader("myBlur.glsl"); 
  brcosa = loadShader("brcosa.glsl");
}

void draw(){

    burst1.fadePercent = lerp(burst1.lastFadePercent, burst1.fade, .2);
    burst1.lastFadePercent = burst1.fadePercent;
  
    shade.set("time", (float) millis()/1000.0);
    shade.set("burst1Fade", burst1.fadePercent);
    shade.set("burst1Fract", burst1.fract);
    shade.set("burst2Fade", burst2.fadePercent);
    shade.set("burst2Fract", burst2.fract);
    
    
    channels.set("rbias", 0.0, 0.0);
    //channels.set("gbias", map(mouseY, 0, height, -0.2, 0.2), 0.0);
    //float gbias = -0.01 + .01 * cos(.005 * float(frameCount)) + 0.008 * noise(frameCount);
    float gbias = -0.01 + .0025 * sin(.052 * float(frameCount))- 0.0013 * noise(frameCount);    
    channels.set("gbias", gbias, 0.0);
    channels.set("bbias", 0.0, 0.0);
    //channels.set("rmult", map(mouseX, 0, width, 0.8, 1.5), 1.0);
    float rmult = 1.01 + .01 * sin(.035 * float(frameCount)) - 0.01 * noise(frameCount);
    channels.set("rmult", rmult, 1.0);
    channels.set("gmult", 1.0, 1.0);
    channels.set("bmult", 1.0, 1.0);
   
   
   //blur.set("sigma", map(mouseX, 0.1, width, 0, 10.0));
   //blur.set("blurSize", (int) map(mouseY, 0.1, height, 0, 30.0));
   blur.set("sigma", 4.0);
   int blurSize = int(map(noise(frameCount+2000),0,1,3,5));
   blur.set("blurSize", blurSize);
   
   //shade.set("threshold", map(mouseX, 0, width, 0, 1));
    //shade.set("pixels", mouseX/5, 250.0);
    //shade.set("rollRate", map(mouseY, 0, height, 0, 10.0));
    //shade.set("rollAmount", 0.25);
    
    
    brcosa.set("brightness", 1.0);
    //brcosa.set("contrast", map(mouseX, 0, width, -5, 5));
    brcosa.set("contrast", 1.0);
    //brcosa.set("saturation", map(mouseY, 0, height, -5, 5));
    float saturationAmnt = map(noise(frameCount+1000),0,1,3,4);
    brcosa.set("saturation", saturationAmnt);
    
  for(float i=0; i < dv; i++){
    float step = i/dv;
    float n = map(noise(step, frameCount),0,1,-1,1) * 0.1;
    float h = map(sin(TWO_PI * step)+n, -1, 1, 0, 100);
    float b = pow( map(cos(2*TWO_PI * step)+n, -1, 1, 0 ,1), 0.5)*100;
    fill(h, 100, b);
    arc(width/2, height/2, width * 0.8, height * 0.8, TWO_PI *step, TWO_PI *step + TWO_PI/dv/arcWidth);
  }

  filter(shade);
  //filter(brcosa);  
  //filter(channels);
  //filter(blur);
  
}

public void keyPressed() {
  if (key=='a' || key=='A') {burst1.fract += 0.5;}
  if (key=='s' || key=='s') {burst2.fract += 0.5;}
  if (key=='1'){fadeInOutBurst(1); }
  if (key=='i'){printInfo();}
  
  
}
 
public void fadeInOutBurst(int burstIndex){
  burst1.fade = burst1.fade > 0 ? 0 : 1.0;
  println(burst1.fade);
}

public void printInfo(){
  println(burst1.lastFadePercent);
  println(burst1.fadePercent);
  println(burst2.lastFadePercent);
  println(burst2.fadePercent);  
}
