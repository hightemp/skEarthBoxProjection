
import java.awt.event.KeyEvent;
import java.util.Date;
import java.util.*;

PImage texture_earth;
PShape globe;
PShape sphere;

String AppSketchPath;
String AppDataPath;

float angle_x = 0;
float angle_y = 0;
float scale_base = 1;

int old_mouse_x;
int old_mouse_y;
  
int globe_radius = 100;

int shift_angle = 27;

int parallel_33_height = Math.round(globe_radius/3);
int parallel_33_radius = Math.round((int) Math.sqrt(globe_radius*globe_radius-parallel_33_height*parallel_33_height));

boolean mouse_pressed_flag = false;

long start_stamp = Math.round((new Date()).getTime()/1000);

class TextObject {
  public Float x;
  public Float y;
  public Float z;
  public String text;
}

HashMap<String, TextObject> TextList = new HashMap<String, TextObject>();

static class Toggler {
  private static HashMap<String, Boolean> tog_array = new HashMap<String, Boolean>();
  private Toggler self = new Toggler();
  
  public static void addIfNotExists(String name) {
    if (tog_array.get(name) == null) 
      tog_array.put(name, true);
  }

  public static boolean isOn(String name) {
    Boolean value = tog_array.get(name);
    if (value == null) 
      return false;
    return value;
  }

  public static void toggle(String name) {
    Boolean value = tog_array.get(name);
    if (value != null) {
      tog_array.put(name, !value);
    }
  }
  
  public static void on(String name) {
    Boolean value = tog_array.get(name);
    if (value != null) {
      tog_array.put(name, true);
    }
  }
  
  public static void off(String name) {
    Boolean value = tog_array.get(name);
    if (value != null) {
      tog_array.put(name, false);
    }
  }
}

class EarthPoint {
  public String name;
  public float lat;
  public float lon;
  
  EarthPoint(String in_name, float in_lat, float in_lon) {
    name = in_name;
    lat = in_lat;
    lon = in_lon;
  }
}

ArrayList<EarthPoint> earth_points = new ArrayList<EarthPoint>();

void settings() {
  size(1000, 1000, P3D);
  
  AppSketchPath = sketchPath();
  AppDataPath = dataPath("");
}

void setup() {
  PFont font = createFont("Arial", 30);
  textFont(font);

  //frameRate(300);

  texture_earth = loadImage(AppDataPath+"/earth.jpg", "jpg");

  globe = createShape(SPHERE, globe_radius); 
  globe.enableStyle();
  globe.colorMode(ARGB);
  globe.setFill(color(255, 255, 255, 200));
  globe.setTexture(texture_earth);
    
  String[] paths = { AppSketchPath, AppDataPath };

  Table EarthPointsTable = loadTable("world_cities.csv", "header");
  
  for (TableRow row : EarthPointsTable.rows()) {
    earth_points.add(new EarthPoint(row.getString("city"), row.getFloat("lat"), row.getFloat("lng")));
  }
}

void draw_cube(String name, int rotate_angle_x, int rotate_angle_y, int rotate_angle_z) {
  Toggler.addIfNotExists(name);
  if (!Toggler.isOn(name))
    return;
    
  blendMode(NORMAL);
  
  pushMatrix();
  pushStyle();
    rotateX(radians(rotate_angle_x));
    rotateY(radians(rotate_angle_y+shift_angle));
    rotateZ(radians(rotate_angle_z));
    rotateX(radians(90));
    
    int r_x[] = {0, 90, 90, 90, 90, 180};
    int r_y[] = {0, 0, 90, 180, 270, 0};
    int r_z[] = {0, 0, 0, 0, 0, 0};
    int t_x[] = {0,  0, 1, 0, -1,  0};
    int t_y[] = {0, -1, 0, 1, 0,  0};
    int t_z[] = {1,  0, 0, 0, 0, -1};
    int c[][] = {{255, 255, 255}, {0, 0, 255}, {255, 0, 0}, {0, 255, 0}, {255, 255, 0}, {0, 0, 0}};
    
    for (int i=0; i<6; i++) {
      pushStyle();
        fill(c[i][0], c[i][1], c[i][2], 100);
        pushMatrix();
          translate(t_x[i]*1.0001, t_y[i]*1.0001, t_z[i]*1.0001);
          rotateX(radians(r_x[i]));
          rotateY(radians(r_y[i]));
          rotateZ(radians(r_z[i]));
          rectMode(RADIUS);
          beginShape(TRIANGLE_STRIP);
            vertex(-globe_radius*2, globe_radius*2, globe_radius*2);
            vertex(0, 0, 0);
            vertex(globe_radius*2, globe_radius*2, globe_radius*2);
            vertex(0, 0, 0);
            vertex(globe_radius*2, -globe_radius*2, globe_radius*2);
            vertex(0, 0, 0);
            vertex(-globe_radius*2, -globe_radius*2, globe_radius*2);
            vertex(0, 0, 0);
            vertex(-globe_radius*2, globe_radius*2, globe_radius*2);
          endShape(CLOSE);      
        popMatrix();
      popStyle();
    }
  popStyle();
  popMatrix();
}

void draw_globe() {
  Toggler.addIfNotExists("draw_globe");
  if (!Toggler.isOn("draw_globe"))
    return;
  
  blendMode(NORMAL);

  pushMatrix();
  pushStyle();
    pushMatrix();
      rotateX(radians(0));
      rotateY(radians(-3));
      rotateZ(radians(0));
      shape(globe);
    popMatrix();
  
    pushMatrix(); // zero lat
      stroke(0, 255, 255, 100);
      rotateY(radians(27));
      ellipse(0, 0, globe_radius*2, globe_radius*2);
    popMatrix(); // zero lat
    
    pushMatrix();
      stroke(0, 255, 255, 100);
      rotateX(PI/2);
      ellipse(0, 0, globe_radius*2, globe_radius*2);
    popMatrix();
    
    pushMatrix();
      stroke(255, 0, 0, 200);
      rotateX(PI/2);
      translate(0, 0, parallel_33_height);
      ellipse(0, 0, parallel_33_radius*2, parallel_33_radius*2);
    popMatrix();

    pushMatrix();
      stroke(255, 0, 0, 200);
      rotateX(PI/2);
      translate(0, 0, -parallel_33_height);
      ellipse(0, 0, parallel_33_radius*2, parallel_33_radius*2);
    popMatrix();  
  popStyle();
  popMatrix();  
}

void draw_axis() {
  Toggler.addIfNotExists("draw_axis");
  if (!Toggler.isOn("draw_axis"))
    return;

  blendMode(NORMAL);
  
  pushMatrix();
  pushStyle();
    rotateX(radians(90));
    stroke(255, 0, 0);
    
    line(0, -globe_radius*2, 0, 0, globe_radius*2, 0);
    line(0, globe_radius*2, 0, 10, globe_radius*2-5, 0);
    line(0, globe_radius*2, 0, -10, globe_radius*2-5, 0);
    
    line(-globe_radius*2, 0, 0, globe_radius*2, 0, 0);
    line(globe_radius*2, 0, 0, globe_radius*2-5, 10, 0);
    line(globe_radius*2, 0, 0, globe_radius*2-5, -10, 0);

    line(0, 0, -globe_radius*2, 0, 0, globe_radius*2);
    line(0, 0, globe_radius*2, 0, 10, globe_radius*2-5);
    line(0, 0, globe_radius*2, 0, -10, globe_radius*2-5);
  popStyle();
  popMatrix();
  
  pushMatrix();
    translate(globe_radius*2-20, -5, 10);
    scale(0.5);
    draw_text("X", 0, 0, 0, true);
  popMatrix();
  pushMatrix();
    translate(5, -globe_radius*2+20, 0);
    scale(0.5);
    draw_text("Z", 0, 0, 0, true);
  popMatrix();
  pushMatrix();
    translate(0, -5, globe_radius*2-20);
    scale(0.5);
    draw_text("Y", 0, 0, 0, true);
  popMatrix();
}

void add_text_to_draw_list(String text, float x, float y, float z) {
  if (TextList.containsKey(text))
    return;
  TextObject temporal = new TextObject();
  temporal.x = x;
  temporal.y = y;
  temporal.z = z;
  temporal.text = text;
  TextList.put(text, temporal);
}

void draw_text_from_list() {
  for (Map.Entry item : TextList.entrySet()) {
    TextObject temporal = (TextObject) item.getValue();
    draw_text(temporal.text, temporal.x, temporal.y, temporal.z, true);
  }
}

void draw_text(String text, float x, float y, float z, boolean camera_orientaion) {
  hint(DISABLE_DEPTH_TEST);
  blendMode(NORMAL);
  
  pushMatrix();
  pushStyle();
    translate(x, y, z);

    if (camera_orientaion) {
      rotateY(-angle_y);
      rotateX(-angle_x);
    }
    
    pushMatrix();
    pushStyle();
      fill(0, 0, 0);
      scale(0.512);
      text(text, 17, -1);
    popStyle();
    popMatrix(); 
    
    pushMatrix();
    pushStyle();
      fill(255, 255, 255);
      stroke(0, 0, 0);
      scale(0.51);
      text(text, 20, 0);
    popStyle();
    popMatrix(); 
  popStyle();
  popMatrix(); 

  hint(ENABLE_DEPTH_TEST);
}

void draw_points() {
  Toggler.addIfNotExists("draw_points");
  if (!Toggler.isOn("draw_points"))
    return;
  
  blendMode(NORMAL);
  
  for (int i=0; i<earth_points.size(); i++) {
    pushMatrix();
    pushStyle();
      
      noLights();
      
      EarthPoint earth_point = earth_points.get(i);
      
      float x = (float) globe_radius*(float) Math.cos(radians(earth_point.lon+shift_angle))*(float) Math.cos(radians(earth_point.lat));
      float y = (float) globe_radius*(float) Math.sin(-radians(earth_point.lat));
      float z = (float) globe_radius*(float) -Math.sin(radians(earth_point.lon+shift_angle))*(float) Math.cos(radians(earth_point.lat));

      //translate(x, y, z);
      
      stroke(255, 0, 0);
      //20 = sqrt((x1-x2)^2+(y1-y2)^2+(z1-z2)^2)
      //
      line(x*1.02, y*1.02, z*1.02, 0, 0, 0);
      
      //add_text_to_draw_list(earth_point.name, x, y, z);

    popStyle();
    popMatrix();
  }
}

void draw_info() {
  Toggler.addIfNotExists("draw_info");
  Toggler.isOn("draw_info");
  
  blendMode(NORMAL);
  
  pushMatrix();
  pushStyle();
  
  draw_text(String.format("%f", frameRate), 10, 40, 0, false);

  popStyle();
  popMatrix();
}

void mouse_control() {
  int new_mouse_x = mouseX;
  int new_mouse_y = mouseY;

  if (mousePressed) {
    if (Math.abs(new_mouse_y-old_mouse_y)>0) {
      angle_x = angle_x + map(new_mouse_y-old_mouse_y, 0, 1, PI/800, -PI/800);
      old_mouse_y = new_mouse_y;
    }
    if (Math.abs(new_mouse_x-old_mouse_x)>0) {
      angle_y = angle_y + map(new_mouse_x-old_mouse_x, 0, 1, -PI/800, PI/800);
      old_mouse_x = new_mouse_x;
    }
  } else {
    old_mouse_x = new_mouse_x;
    old_mouse_y = new_mouse_y;
  }

  rotateX(angle_x);
  rotateY(angle_y);  
}

void draw() {
  background(0);
  noLights();
  hint(ENABLE_DEPTH_TEST);
  
  pushMatrix();
  pushStyle();

    translate(width/2, height/2);
    scale(scale_base);
  
    mouse_control();
    draw_globe();
    draw_cube("draw_cube1", 0, 0, 0);
    draw_cube("draw_cube2", 15, 15, -15);
    draw_axis();
    draw_points();
    draw_text_from_list();
  
  popStyle();
  popMatrix();
  
  draw_info();
}

void keyPressed() {
  print(keyCode);
  switch (keyCode) {
    case KeyEvent.VK_1:
      Toggler.toggle("draw_globe");
    break;
    case KeyEvent.VK_2:
      Toggler.toggle("draw_cube1");
    break;
    case KeyEvent.VK_3:
      Toggler.toggle("draw_cube2");
    break;
    case KeyEvent.VK_4:
      Toggler.toggle("draw_axis");
    break;
    case KeyEvent.VK_5:
      Toggler.toggle("draw_points");
    break;
    case 61: //KeyEvent.VK_PLUS:
      scale_base += 0.1;
    break;
    case KeyEvent.VK_MINUS:
      scale_base -= 0.1;
    break;
  }
}