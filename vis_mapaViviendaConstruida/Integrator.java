/* -*- mode: jde; c-basic-offset: 2; indent-tabs-mode: nil -*- */


public class Integrator {

  static final float DAMPING = 0.5f;  // formerly 0.9f
  static final float ATTRACTION = 0.2f;  // formerly 0.1f

  float value   = 0;
  float vel     = 0;
  float accel   = 0;
  float force   = 0;
  float mass    = 1;


  // faux spring

  float damping     = DAMPING;
  float attraction  = ATTRACTION;
  boolean targeting = false;
  float target      = 0;


  public Integrator() { }


  public Integrator(float value) {
    this.value = value;
  }


  public Integrator(float value, float damping, float attraction) {
    this.value = value;
    this.damping = damping;
    this.attraction = attraction;
  }


  public void set(float v) {
    value = v;
    //targeting = false  ?
  }


  public void update() {  // default dtime = 1.0
    if (targeting) {
      force += attraction * (target - value);      
    }

    accel = force / mass;
    vel = (vel + accel) * damping; /* e.g. 0.90 */
    value += vel;

    force = 0; // implicit reset
  }


  public void target(float t) {
    targeting = true;
    target = t;
  }


  public void noTarget() {
    targeting = false;
  }
}
