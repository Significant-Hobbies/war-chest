extends "res://scripts/pocket_art.gd"
const Game=preload("res://scripts/siege_game.gd")
const SCENERY=preload("res://assets/banner-steel/lantern-gate.png")
var game
var battle_view=false
var selected="rowan"
var highlighted=""
var card=""
var font=SystemFont.new()
const Motion=preload("res://scripts/pocket_motion.gd")
var motion=Motion.new()
var reduced_motion=false:
 set(value):
  reduced_motion=value
  if value: motion.clear();queue_redraw()
const FRONTS=[350.0,720.0,1090.0]

func _ready():
 super()
 font.font_names=PackedStringArray(["Avenir Next"])
 font.font_weight=600

func unit_position(u: Dictionary,enemy: bool) -> Vector2:
 return Motion.point(u,enemy,game.battle)

func unit_rect(u: Dictionary,enemy: bool) -> Rect2:
 return Rect2(motion.position(u.id,unit_position(u,enemy))-Vector2(54,75),Vector2(108,140))

func _draw():
 draw_texture_rect(SCENERY,Rect2(0,0,1440,900),false)
 if not battle_view:
  draw_rect(Rect2(0,0,1440,900),Color(PAPER,0.94))
 if not battle_view or game==null or game.battle.is_empty(): return
 if game.has_method("hazard"):
  var threat=game.hazard()
  if not threat.is_empty():
   draw_rect(Rect2(FRONTS[threat.lane]-155,210,310,408),Color(CORAL,0.12))
   draw_rect(Rect2(FRONTS[threat.lane]-155,210,310,408),CORAL,false,3)
 for lane in range(3):
  pill(Rect2(FRONTS[lane]-98,171,196,32),NAVY,4)
  draw_string(font,Vector2(FRONTS[lane]-84,193),"%d · %s" % [lane+1,["High wall","Causeway","Lower gate"][lane]],HORIZONTAL_ALIGNMENT_LEFT,-1,17,PAPER)
 for h in game.battle.heroes:
  if h.hp>0: render_unit(h,false)
 for e in game.battle.enemies:
  if e.hp>0: render_unit(e,true)
 for fx in motion.effects:
  if fx.kind=="vanish": render_effect(fx)
 for fx in motion.effects:
  if fx.kind!="vanish": render_effect(fx)

func render_unit(u: Dictionary,enemy: bool):
 var p=motion.position(u.id,unit_position(u,enemy))
 draw_actor(u,enemy,p+motion.offset(u.id),1.0,motion.impact(u.id))
 # Labels and native hit regions follow the same interpolated troop position.
 if u.id==selected and not enemy:
  draw_ellipse(p+Vector2(0,60),43,7,Color(BLUE,0.2),true)
  draw_ellipse(p+Vector2(0,60),43,7,BLUE,false,2,true)
 if u.id==highlighted: draw_rect(Rect2(p-Vector2(53,72),Vector2(106,136)),GOLD,false,3)
 render_badge(u,enemy,p)

func draw_actor(u: Dictionary,enemy: bool,p: Vector2,alpha=1.0,impact=0.0):
 var name=u.id
 if enemy: name="boss" if u.boss else "skeleton"
 if enemy and not u.boss and u.get("trait","") in ["armored","archer","sapper"]: name=u.trait
 if name=="fen" and game.campaign.pet=="owl": name="owl"
 draw_set_transform(p+Vector2(impact*(7 if enemy else -7),0),impact*0.07,Vector2(1+impact*0.06,1-impact*0.06))
 if has_sprite(name): sprite(name,Rect2(Vector2(-64,-83),Vector2(128,144)),Color(1,1,1,alpha))
 else:
  glyph(name)
 draw_set_transform(Vector2.ZERO)

func render_badge(u: Dictionary,enemy: bool,p: Vector2):
 # Health and intent share a single under-foot badge, avoiding the next front.
 if enemy:
  var label=("★ " if u.boss else "")+"%d HP" % u.hp
  pill(Rect2(p+Vector2(-55,62),Vector2(110,46)),NAVY,4)
  draw_string(font,p+Vector2(-48,80),label,HORIZONTAL_ALIGNMENT_LEFT,-1,16,PAPER)
  var intent="Stunned" if u.stunned else "%d → %s" % [game.attack_power(u),"Gate" if u.target=="gate" else game.ally(u.target).get("name","Ally")]
  draw_string(font,p+Vector2(-48,99),intent,HORIZONTAL_ALIGNMENT_LEFT,-1,14,GOLD)
 else:
  var label="%d HP" % u.hp+(" · +%d block" % u.shield if u.shield>0 else "")
  var width=font.get_string_size(label,HORIZONTAL_ALIGNMENT_LEFT,-1,16).x+14
  pill(Rect2(p+Vector2(-width/2,62),Vector2(width,24)),PAPER,9)
  draw_string(font,p+Vector2(-width/2+7,80),label,HORIZONTAL_ALIGNMENT_LEFT,-1,16,NAVY)

func animate_change(before: Dictionary,actor="",command="",resolved=false):
 motion.build(before,game.battle,actor,command,resolved)
 if reduced_motion:
  if motion.summary!="": game.message=motion.summary
  motion.clear()
 queue_redraw()

func clear_motion():
 motion.clear();queue_redraw()

func render_effect(fx: Dictionary):
 var elapsed=motion.age-float(fx.get("delay",0))
 if elapsed<0:
  if fx.kind=="vanish": draw_actor(fx.unit,fx.enemy,fx.at)
  return
 var duration=float(fx.get("duration",Motion.LENGTH-float(fx.get("delay",0))))
 if elapsed>=duration: return
 var t=clampf(elapsed/duration,0,1)
 var fade=1-smoothstep(0.55,1.0,t)
 var at: Vector2=fx.at
 var color=Color(fx.color,fade)
 if fx.kind=="vanish":
  draw_actor(fx.unit,fx.enemy,at+Vector2(12*t,8*t),1-t,t*0.7)
 elif fx.kind in ["arrow","spell","enemy"]:
  var flight=clampf(elapsed/0.24,0,1)
  if flight<1:
   var head: Vector2=fx.from.lerp(at,flight)
   var direction: Vector2=(at-fx.from).normalized()
   if fx.kind=="spell":
    draw_circle(head,7,color)
    draw_line(head-direction*26,head,color,4,true)
    draw_line(head-direction*40+Vector2(0,-7),head-direction*24,color,2,true)
   else:
    draw_line(head-direction*28,head,color,4,true)
    draw_line(head-direction.rotated(0.55)*10,head,color,3,true)
    draw_line(head-direction.rotated(-0.55)*10,head,color,3,true)
 elif fx.kind=="slash":
  if elapsed<0.3:
   draw_arc(at,30,-1.7+elapsed*5,0.5+elapsed*5,18,color,5*(1-t),true)
   draw_arc(at,39,-1.9+elapsed*5,-0.3+elapsed*5,14,Color(GOLD,fade),2,true)
   var burst=clampf(elapsed/0.18,0,1)
   if burst<1:
    for i in range(4):
     var direction=Vector2.from_angle(PI/4+i*PI/2)
     draw_line(at+direction*(15+burst*12),at+direction*(22+burst*18),Color(GOLD,1-burst),3,true)
 elif fx.kind in ["shield","heal","stun","arrival"]:
  if t<0.7:
   draw_arc(at,24+t*38,0,TAU,32,color,2,true)
   if fx.kind=="heal":
    draw_line(at+Vector2(-10,0),at+Vector2(10,0),color,4,true)
    draw_line(at+Vector2(0,-10),at+Vector2(0,10),color,4,true)
 if fx.label!="":
  var lift=12*(1-pow(1-t,2))
  var y=-10 if fx.kind in ["damage","heal"] else 20
  var p=at+Vector2(58,y-lift)
  var width=font.get_string_size(fx.label,HORIZONTAL_ALIGNMENT_LEFT,-1,20).x+16
  pill(Rect2(p-Vector2(width/2,23),Vector2(width,30)),Color(PAPER,fade),9)
  draw_string(font,p+Vector2(-width/2+8,0),fx.label,HORIZONTAL_ALIGNMENT_LEFT,-1,20,color)

func _process(delta):
 if not motion.active(): return
 if not battle_view or reduced_motion: motion.clear()
 else: motion.advance(delta)
 queue_redraw()
