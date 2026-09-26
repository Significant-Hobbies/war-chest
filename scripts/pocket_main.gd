extends Control
## THESIS: an enduring company, built through equipment decisions and visible threats.
## OWN-WORLD: warm stone, olive standards, ink controls, brick enemies, ochre orders.
## STORY: defend the gate, recover a rune, pack it, use its power in the next battle.
## FIRST VIEWPORT: three illustrated approaches, live troops and a compact command rail.
## FORM: owner-selected A, refined Banner & Steel. Flat 2D, adult proportions, no chibi.
const Game=preload("res://scripts/opening_game.gd")
const Art=preload("res://scripts/pocket_art.gd")
const Field=preload("res://scripts/pocket_field.gd")
const Chest=preload("res://scripts/pocket_chest.gd")
const Coach=preload("res://scripts/pocket_coach.gd")
const Unlock=preload("res://scripts/pocket_unlock.gd")
const SAVE="user://iron-and-ember-v2.json"
const SETTINGS="user://pocket-settings.cfg"
const PAPER=Color("f4ebd8")
const NAVY=Color("203340")
const BLUE=Color("405947")
const SKY=Color("dfd4bb")
const GOLD=Color("dbac51")
const MUTED=Color("596050")
const CORAL=Color("9d4133")
const SHORT={"cleave":"Cleave","ward":"Shield","volley":"Volley","spark":"Storm","mend":"Heal","pin":"Pin","frost":"Freeze","rally":"Rally","gust":"Gust","bolt":"Bolt","strike":"Strike","guard":"Guard","move":"Move"}
const GEAR_EFFECT={"blade":"Rowan · Cleave hits every foe on his front.","bow":"Lysa · Volley reaches any front.","ward":"Rowan · Shield protects any ally.","cube":"Touch weapons to add 2 damage to their commands.","staff":"Merrin · Storm deals damage and cancels an attack.","flask":"Merrin · Heal restores an ally's health.","ballista":"Adds a ballista with ranged Bolt in every battle.","frost":"Lysa · Freeze deals damage and cancels an attack."}
var game=Game.new()
var field
var hud: Control
var inspection: Label
var status: Label
var page="keep"
var selected="rowan"
var chosen=""
var target=""
var battle_notice=""
var mission=0
var keep_mode="campaign"
var mastery_notice=""
var contract_id="raid"
var quest_id="scout"
var contract_tier=1
var gear="blade"
var chest
var rotation_index=0
var chest_cursor=Vector2i.ZERO
var undo={}
var guide_return="keep"
var retreat_confirm=false
var reduced_motion=false
var muted=false
var coaching=true
var unlock_seen=""
var demo=false
var font=SystemFont.new()
var display_font=SystemFont.new()
var sound: AudioStreamPlayer
var card_buttons=[]
var finishing_impact=false
var finish_tween: Tween
var last_surface=""
var actor_controls=[]
var motion_was_active=false

func _ready():
 get_window().min_size=Vector2i(1152,720)
 var args=OS.get_cmdline_user_args()
 demo="--pocket-demo" in args or "--pocket-battle" in args
 var fresh=(not demo and not FileAccess.file_exists(SAVE)) or (demo and "--banner-opening" in args)
 if not demo:
  game.load_from(SAVE)
  var settings=ConfigFile.new()
  if settings.load(SETTINGS)==OK:
   muted=bool(settings.get_value("play","muted",false))
   reduced_motion=bool(settings.get_value("play","reduced_motion",false))
   coaching=bool(settings.get_value("play","coaching",true))
 font.font_names=PackedStringArray(["Avenir Next","Arial"]);font.font_weight=500
 display_font.font_names=PackedStringArray(["Georgia","Times New Roman"]);display_font.font_weight=700
 var t=Theme.new();t.default_font=font;t.default_font_size=18;theme=t
 field=Field.new();field.game=game;field.size=Vector2(1440,900);add_child(field)
 sound=AudioStreamPlayer.new();add_child(sound)
 if fresh and game.enroll_opening(): game.begin(0);persist()
 elif "--pocket-battle" in args: game.begin(0)
 if not game.battle.is_empty(): page="battle"
 elif game.opening_guided() and game.opening_stage() in [1,2]: page="chest";gear="cube"
 mission=mini(game.campaign.unlocked,game.level()-1)
 show_page()

func rounded(fill: Color,radius=4,edge=Color(0,0,0,0),border=0) -> StyleBoxFlat:
 var s=StyleBoxFlat.new();s.bg_color=fill;s.set_corner_radius_all(mini(radius,4));s.border_color=edge;s.set_border_width_all(border)
 s.content_margin_left=12;s.content_margin_right=12;s.content_margin_top=4;s.content_margin_bottom=4
 return s

func panel(rect: Rect2,color=PAPER,radius=18):
 var p=Panel.new();p.position=rect.position;p.size=rect.size;p.mouse_filter=Control.MOUSE_FILTER_IGNORE
 p.add_theme_stylebox_override("panel",rounded(color,radius));hud.add_child(p)
 return p

func text(value: String,rect: Rect2,sz=20,color=NAVY,bold=false) -> Label:
 var l=Label.new();l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 l.add_theme_font_override("font",display_font if bold else font);l.add_theme_font_size_override("font_size",sz);l.add_theme_color_override("font_color",color)
 # Establish wrapping width before text; otherwise Label first measures at 0px
 # and retains a thousands-of-pixels minimum height for this HUD rebuild.
 l.mouse_filter=Control.MOUSE_FILTER_IGNORE;l.position=rect.position;l.size=rect.size;l.text=value;hud.add_child(l)
 return l

func button(value: String,rect: Rect2,action: Callable,primary=false,disabled=false) -> Button:
 var b=Button.new();b.text=value;b.position=rect.position;b.size=rect.size;b.disabled=disabled
 b.add_theme_stylebox_override("normal",rounded(NAVY if primary else PAPER,4,Color("b5aa90"),1))
 b.add_theme_stylebox_override("hover",rounded(BLUE if primary else Color("e4d9bf"),4,NAVY,1))
 b.add_theme_stylebox_override("pressed",rounded(GOLD))
 b.add_theme_stylebox_override("disabled",rounded(Color("ddd5c5")))
 b.add_theme_stylebox_override("focus",rounded(Color(0,0,0,0),16,NAVY,3))
 b.add_theme_color_override("font_color",PAPER if primary else NAVY)
 b.add_theme_color_override("font_hover_color",PAPER if primary else NAVY)
 b.add_theme_color_override("font_pressed_color",NAVY)
 b.add_theme_color_override("font_disabled_color",MUTED)
 b.add_theme_font_override("font",font);b.add_theme_font_size_override("font_size",18)
 b.button_down.connect(func():
  if reduced_motion or b.disabled: return
  var previous=b.get_meta("press_tween",null)
  if previous: previous.kill()
  b.self_modulate=Color(0.93,0.89,0.80)
  var press=b.create_tween();b.set_meta("press_tween",press)
  press.tween_property(b,"self_modulate",Color.WHITE,0.14))
 b.pressed.connect(action);hud.add_child(b);return b

func icon(id: String,rect: Rect2,color=BLUE):
 var a=Art.new();a.kind=id;a.tint=color;a.illustrated=true;a.position=rect.position;a.size=rect.size;hud.add_child(a);return a

func show_page():
 if reduced_motion and finishing_impact: cancel_combat_animation()
 var focused=get_viewport().gui_get_focus_owner()
 var keep_focus=focused.get_meta("focus_key",focused.text) if focused is Button else ""
 if hud: remove_child(hud);hud.queue_free()
 hud=Control.new();hud.size=Vector2(1440,900);hud.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(hud)
 inspection=null;card_buttons=[];actor_controls=[]
 field.battle_view=page=="battle";field.selected=selected;field.card=chosen;field.highlighted=target;field.reduced_motion=reduced_motion;field.queue_redraw()
 if page!="battle": field.clear_motion()
 match page:
  "keep": keep_page()
  "chest": chest_page()
  "shop": shop_page()
  "guide": guide_page()
  "battle":
   if game.battle.phase=="playing" or finishing_impact: battle_page()
   else: reward_page()
 var surface=page+(game.battle.get("phase","") if page=="battle" and not finishing_impact else "")
 if surface!=last_surface and page=="battle" and not finishing_impact and game.battle.phase=="victory" and not reduced_motion:
  for node in hud.get_children():
   if node.get_script()==Art:
    node.pivot_offset=node.size/2;node.scale=Vector2.ONE*0.94
    node.create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).tween_property(node,"scale",Vector2.ONE,0.32)
 last_surface=surface
 if page!="battle" or game.save_error!="" or mastery_notice!="":
  panel(Rect2(20,857,1400,32),PAPER,10)
  status=text(game.save_error if game.save_error!="" else (mastery_notice if mastery_notice!="" else game.message),Rect2(34,859,1240,30),18 if mastery_notice!="" else 15,CORAL if game.save_error!="" else MUTED)
 text("Practice session" if demo else "Local play",Rect2(1292,872,128,22),12,MUTED)
 if keep_focus!="":
  for node in hud.get_children():
   if node is Button and node.get_meta("focus_key",node.text)==keep_focus and not node.disabled:
    node.grab_focus();break
 if game.save_error!="":
  panel(Rect2(20,824,1400,71),PAPER,10)
  text("SAVING DISABLED — this session will not be kept. "+game.save_error,Rect2(34,829,1360,62),18,CORAL,true)

func persist():
 if not demo: game.save_to(SAVE)

func navigate(to: String):
 cancel_combat_animation()
 mastery_notice=""
 page=to;chosen="";target="";retreat_confirm=false;show_page()

func header(title: String,sub: String):
 text(title,Rect2(48,30,900,60),38,NAVY,true)
 text(sub,Rect2(50,99,1030,38),19,MUTED)
 text("Lv %d  ·  %d gold" % [game.level(),game.campaign.gold],Rect2(1137,34,270,35),21,NAVY,true)
 button("How to play",Rect2(1203,87,185,44),func():guide_return=page;navigate("guide"))

func keep_page():
 var first=game.level()==1
 var starter_packed=game.campaign.placements.has_all(["blade","bow","ward","cube"])
 header("War Chest", ("Your gear is already packed. Start the first battle; learn by giving real orders." if starter_packed else "Stored gear gives no commands. Pack equipment before battle, or fight with your current loadout.") if first else "Your company, your next move. Inspect a hero to see their growth.")
 text("A company worth\ncommanding.",Rect2(57,202,700,126),47,NAVY,true)
 var early=game.opening_guided()
 for i in range(4):
  var modes=["campaign","quests","contracts","banners"]
  var labels=["Campaign","Side quests","War contracts","Banners"]
  var mode_button=button(labels[i]+("\nAfter battle 2" if early and i>0 else ("\nLevel 2" if first and i>0 else "")),Rect2(56+i*152,351,143,48),func():keep_mode=modes[i];show_page(),keep_mode==modes[i],(first or early) and i>0)
  mode_button.add_theme_font_size_override("font_size",15)
 var members=["rowan","lysa","fen"]
 if game.campaign.mage: members.append("merrin")
 for i in range(members.size()):
  var id=members[i];var x=155+i*147
  icon("owl" if id=="fen" and game.campaign.pet=="owl" else id,Rect2(x,425,190,210))
  text({"rowan":"Rowan","lysa":"Lysa","fen":"Fen" if game.campaign.pet=="wolf" else "Talon","merrin":"Merrin"}[id],Rect2(x+47,650,140,30),19,NAVY,true)
  var mastery_button=button(game.mastery_progress(id),Rect2(x+22,685,141,57),func():show_mastery(id))
  mastery_button.add_theme_font_size_override("font_size",16)
  mastery_button.set_meta("focus_key","mastery_"+id)
  mastery_button.tooltip_text=game.mastery_effect(id,maxi(1,game.mastery_rank(id)))
 button("Pack equipment",Rect2(56,752,284,66),func():navigate("chest"))
 button("Explore all systems" if early else "Recruit & upgrade",Rect2(361,752,291,66),func():
  if early: game.skip_opening();persist();show_page()
  else: navigate("shop"))
 if keep_mode=="quests":
  quests_panel()
  return
 if keep_mode=="contracts":
  contracts_panel()
  return
 if keep_mode=="banners":
  banners_panel()
  return
 var m=Game.SIEGES[mission]
 text("Chapter %d · Battle %d of 6 · %s" % [int(mission/2)+1,mission+1,m.kind.to_lower()],Rect2(871,226,507,33),18,MUTED)
 text(m.name,Rect2(870,276,493,100),35,NAVY,true)
 text(m.desc,Rect2(873,387,485,74),23,NAVY)
 text("+%d gold  ·  %s" % [m.gold if game.campaign.wins[mission]==0 else int(m.gold/2),"new level" if game.level()<6 and game.campaign.wins[mission]==0 else "veteran rewards"],Rect2(873,473,474,37),19,MUTED)
 for i in range(6):
  var locked=i>game.campaign.unlocked or i>=game.level()
  var b=button(str(i+1),Rect2(872+i*83,542,62,48),func():mission=i;show_page(),mission==i,locked)
  b.tooltip_text=Game.SIEGES[i].name+(" · win the previous battle first" if locked else "")
 text("Win to advance. Side quests offer optional gear and routes.",Rect2(873,600,460,48),17,MUTED)
 button("Play first battle  →" if first else "Start battle  →",Rect2(872,657,493,67),start_battle,true)
 text("Next: "+Game.REWARDS[game.level()+1][0] if game.level()<6 else "Try a different company build in veteran battles.",Rect2(872,765,500,66),19,NAVY)

func start_battle():
 mastery_notice=""
 unlock_seen=""
 var started=game.begin_quest(quest_id) if keep_mode=="quests" else (game.begin_contract(contract_id,contract_tier) if keep_mode=="contracts" else game.begin(mission))
 if started: page="battle";selected="rowan";chosen="";battle_notice="";undo={};persist()
 show_page()

func quests_panel():
 text("The company's side-story",Rect2(871,217,510,48),29,NAVY,true)
 text("%d/6 complete · optional, no daily timers" % game.campaign.journey.completed.size(),Rect2(874,276,493,29),17,MUTED)
 var i=0
 for id in Game.QUESTS:
  var q=Game.QUESTS[id];var locked=game.quest_lock(id)
  var label="%d · %s%s" % [q.chapter,q.name," ✓" if game.quest_done(id) else ""]
  var b=button(label,Rect2(872,318+i*49,493,42),func():quest_id=id;show_page(),quest_id==id)
  b.add_theme_font_size_override("font_size",17)
  b.tooltip_text=locked if locked!="" else q.desc
  i+=1
 var selected_quest=Game.QUESTS[quest_id];var reason=game.quest_lock(quest_id)
 text(reason if reason!="" else selected_quest.desc,Rect2(874,616,493,95),18,NAVY)
 text(("Replay: half gold; no repeat relic or XP." if game.quest_done(quest_id) else selected_quest.reward),Rect2(874,715,493,57),17,MUTED)
 button("Quest locked" if reason!="" else ("Replay side quest  →" if game.quest_done(quest_id) else "Start side quest  →"),Rect2(872,779,493,57),start_battle,true,reason!="")

func contracts_panel():
 text("War contracts",Rect2(871,217,510,54),34,NAVY,true)
 text("%d renown · %d contracts won" % [game.war().renown,game.war().contracts],Rect2(874,277,493,29),18,MUTED)
 contract_tier=mini(contract_tier,game.max_tier())
 for i in range(5):
  var b=button("Tier %d" % (i+1),Rect2(873+i*100,320,94,44),func():contract_tier=i+1;show_page(),contract_tier==i+1,i>=game.max_tier())
  b.tooltip_text="Tier %d · %s" % [i+1,game.tier_unlock_text(i+1)]
 if game.max_tier()<5:
  text("Next: "+game.tier_unlock_text(game.max_tier()+1),Rect2(874,367,493,24),16,MUTED)
 var i=0
 for id in Game.CONTRACTS:
  var info=game.contract_info(id,contract_tier)
  var y=393+i*75
  button("%s · %dg" % [Game.CONTRACTS[id].name,info.gold+game.banner_rank("fortune")*10],Rect2(872,y,493,49),func():contract_id=id;show_page(),contract_id==id)
  i+=1
 var info=game.contract_info(contract_id,contract_tier)
 text(info.desc,Rect2(874,628,491,83),19,NAVY)
 button("Take contract  →" if game.level()>=2 else "Contracts unlock at level 2",Rect2(872,730,493,61),start_battle,true,game.level()<2)
 text("Win: +%d renown, 35 XP and one banner. No time limit." % contract_tier,Rect2(873,801,495,48),17,MUTED)

func banners_panel():
 text("Your company banner",Rect2(871,217,510,54),31,NAVY,true)
 text("Equip one, up to rank III. Bonuses need the matching commands unlocked and packed.",Rect2(874,278,493,60),18,MUTED)
 var i=0
 for id in Game.BANNERS:
  var rank=int(game.war().banners.get(id,0));var y=344+i*75
  var b=button(Game.BANNERS[id].name+(" · Rank %d" % rank if rank else " · Not found"),Rect2(872,y,493,44),func():transact(func():game.equip_banner(id)),game.war().equipped==id,rank==0)
  b.tooltip_text=game.banner_text(id,maxi(1,rank))
  text(game.banner_text(id,maxi(1,rank)),Rect2(880,y+47,484,27),16,MUTED)
  i+=1
 text("Earn your first banner by winning a battle." if game.war().equipped=="" else "Active: "+Game.BANNERS[game.war().equipped].name,Rect2(874,806,493,43),17,MUTED)

func battle_page():
 var m=game.encounter()
 panel(Rect2(20,18,1400,143),PAPER)
 panel(Rect2(20,632,1400,250),PAPER)
 text("Complete the mission" if game.battle.has("quest") else ("Hold the gate" if m.kind=="DEFENSE" else "Break their line"),Rect2(46,25,530,55),38,NAVY,true)
 panel(Rect2(39,78,565,33),PAPER,8)
 text("%s  ·  %s" % [m.name,("within %d turns" % m.rounds) if game.battle.has("quest") else ("survive %d turns" % m.rounds if m.kind=="DEFENSE" else "defeat every foe")],Rect2(49,80,565,32),19,MUTED)
 if game.war().equipped!="":
  var banner=game.war().equipped
  var badge=button("%s · %d" % [Game.BANNERS[banner].name,game.banner_rank(banner)],Rect2(46,118,310,34),func():inspect(game.banner_text(banner,game.banner_rank(banner))))
  badge.tooltip_text=game.banner_text(banner,game.banner_rank(banner))
 var lesson=coach_hint()
 if not lesson.is_empty():
  panel(Rect2(380,118,808,35),PAPER,8)
  text(lesson.heading,Rect2(392,122,783,29),18,NAVY)
  button("Skip lessons",Rect2(1200,116,171,39),func():coaching=false;save_settings();show_page())
 elif game.battle_brief()!="":
  var briefing=button(game.battle_brief(),Rect2(380,118,991,35),func():inspect(game.encounter().desc+" · Optional: "+game.objective_text()))
  briefing.add_theme_font_size_override("font_size",17)
  briefing.tooltip_text=game.encounter().desc+" · Optional: "+game.objective_text()
 elif game.battle.has("objective"):
  panel(Rect2(380,118,991,35),PAPER,8)
  text("Optional · "+game.objective_text(),Rect2(392,122,972,29),18,NAVY)
 text("Turn %d  ·  %d orders" % [game.battle.round,game.battle.commands],Rect2(650,33,365,36),23,NAVY,true)
 for i in range(6+(1 if game.level()>=5 else 0)):
  panel(Rect2(660+i*33,80,22,22),GOLD if i<game.battle.commands else SKY,11)
 icon("ward",Rect2(1097,29,33,33),BLUE)
 text("%d / 30" % game.battle.gate,Rect2(1141,29,144,36),23,NAVY,true)
 text("YOUR GATE",Rect2(1098,75,150,25),12,MUTED,true)
 button("Menu",Rect2(1299,30,104,43),func():guide_return=page;navigate("guide"))
 var h=game.ally(selected)
 if h.is_empty() or h.hp<=0:
  for member in game.battle.heroes:
   if member.hp>0: selected=member.id;h=member;break
 field.selected=selected
 for member in game.battle.heroes:
  if member.hp>0: actor_button(member,false)
 for enemy in game.battle.enemies:
  if enemy.hp>0: actor_button(enemy,true)
 # Rules appear in one quiet line; the scene remains visible behind live controls.
 inspection=text(default_detail(),Rect2(302,642,927,57),19,NAVY)
 inspection.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 icon("owl" if selected=="fen" and game.campaign.pet=="owl" else selected,Rect2(43,699,104,113))
 text(h.name,Rect2(164,713,159,37),25,NAVY,true)
 text("%d / %d HP" % [h.hp,h.max_hp],Rect2(164,755,160,26),16,MUTED)
 for i in range(game.battle.heroes.size()):
  var member=game.battle.heroes[i];var x=40+i*59
  var b=button("",Rect2(x,807,55,55),func():select_hero(member.id),member.id==selected,member.hp<=0)
  b.text="";b.accessibility_name=member.name;b.set_meta("focus_key","hero_"+member.id)
  icon("owl" if member.id=="fen" and game.campaign.pet=="owl" else member.id,Rect2(x+5,812,45,43))
  b.tooltip_text=member.name+" · select [%d]" % (i+1)
 var list=game.cards(selected).duplicate()
 if selected!="ballista": list.append("move")
 var width=866.0/list.size()
 for i in range(list.size()):
  var id=list[i];var cost=(0 if game.free_march() else 1) if id=="move" else Game.COMMANDS[id].cost
  var error=game.move_reason(selected) if id=="move" else game.reason(selected,id)
  var x=341+i*width
  var y=701 if chosen==id else 708
  var b=button(SHORT[id],Rect2(x,y,width-12,145),func():choose_card(id),false,error!="")
  b.text="";b.accessibility_name=SHORT[id]+" · %d orders" % cost
  b.set_meta("focus_key","command_"+id)
  var card_style=rounded(GOLD if chosen==id else PAPER,4,NAVY if chosen==id else Color("b5aa90"),2 if chosen==id else 1)
  b.add_theme_stylebox_override("normal",card_style)
  icon(id,Rect2(x+(width-12)/2-34,y+24,68,67),BLUE)
  var name_label=text(SHORT[id],Rect2(x+4,y+102,width-20,34),21,MUTED if error!="" else NAVY,true)
  name_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
  panel(Rect2(x+width-48,y+9,27,27),SKY if error!="" else GOLD,4)
  var cost_label=text(str(cost),Rect2(x+width-48,y+10,27,25),16,NAVY,true)
  cost_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
  b.tooltip_text=error if error!="" else detail(id)
  b.mouse_entered.connect(func():inspect(error if error!="" else detail(id)))
  b.focus_entered.connect(func():inspect(error if error!="" else detail(id)))
  b.mouse_exited.connect(func():inspect(default_detail()))
  card_buttons.append(b)
 button("Continue  →" if finishing_impact else "End turn  →",Rect2(1233,753,171,67),resolve_turn,true)
 button("Undo [Z]",Rect2(1253,828,133,31),undo_action,false,undo.is_empty())
 if chosen=="move":
  inspection.text=""
  for lane in range(3):
   var count=0
   for member in game.battle.heroes:
    if member.hp>0 and member.lane==lane: count+=1
   button("Front %d" % (lane+1),Rect2(493+lane*180,649,167,43),func():move_to(lane),false,h.lane==lane or count>=2)

func actor_button(u: Dictionary,enemy: bool):
 var b=button("",field.unit_rect(u,enemy),func():on_actor(u.id))
 b.text="";b.accessibility_name=u.name;b.set_meta("focus_key","actor_"+u.id)
 actor_controls.append({"button":b,"unit":u,"enemy":enemy})
 for state in ["normal","hover","pressed","disabled"]: b.add_theme_stylebox_override(state,rounded(Color(0,0,0,0),12))
 for state in ["font_color","font_hover_color","font_pressed_color"]: b.add_theme_color_override(state,Color(0,0,0,0))
 var info=target_detail(u.id) if chosen!="" and chosen!="move" else actor_detail(u,enemy)
 b.tooltip_text=info
 b.mouse_entered.connect(func():field.highlighted=u.id;field.queue_redraw();inspect(info))
 b.focus_entered.connect(func():field.highlighted=u.id;field.queue_redraw();inspect(info))
 b.mouse_exited.connect(func():field.highlighted=target;field.queue_redraw();inspect(default_detail()))

func actor_detail(u: Dictionary,enemy: bool) -> String:
 var info=u.name+" · %d/%d HP" % [u.hp,u.max_hp]
 if enemy: info+=" · "+game.threat(u)+" · "+game.enemy_detail(u)
 elif u.shield>0: info+=" · %d block" % u.shield
 if not enemy and u.id in Game.MASTERY_HEROES:
  var rank=game.mastery_rank(u.id)
  info+=" · Mastery %s: " % Game.RANK_NAMES[rank]+game.mastery_effect(u.id,rank) if rank>0 else " · "+game.mastery_progress(u.id).replace("\n"," · ")
 return info

func inspect(value: String):
 if is_instance_valid(inspection): inspection.text=value

func default_detail() -> String:
 if finishing_impact: return "Victory!" if game.battle.phase=="victory" else "Your company is safe."
 if battle_notice!="": return battle_notice
 var lesson=coach_hint()
 if not lesson.is_empty(): return lesson.body
 if chosen!="": return detail(chosen)+"  ·  Choose a target."
 return "Choose a command card, then a target."

func coach_hint() -> Dictionary:
 if coaching and game.opening_guided() and game.opening_stage()==2 and game.battle.get("mission",-1)==1 and not game.campaign.opening.rune_used:
  if chosen!="": return {}
  for option in [["blade","rowan","cleave"],["bow","lysa","volley"]]:
   if not game.empowered(option[0]): continue
   for enemy in game.battle.enemies:
    if game.reason(option[1],option[2],enemy.id)=="":
     return {"heading":"Your build is ready · test the linked weapon", "body":"%s gains +2 rune damage. Select %s, then %s and a foe %s." % [SHORT[option[2]],game.ally(option[1]).name,SHORT[option[2]],"on this front" if option[1]=="rowan" else "on any front"]}
  if game.empowered("blade") or game.empowered("bow"):
   return {"heading":"Your rune stays with the company", "body":"No linked attack is available now. Use other orders or End turn; fallen heroes recover after battle."}
 return Coach.hint(game,selected,chosen) if coaching else {}

func target_detail(id: String) -> String:
 var reason=game.reason(selected,chosen,id)
 if reason!="": return reason
 var enemy=game.foe(id)
 if not enemy.is_empty() and chosen!="gust":
  var damage=game.damage_against(selected,chosen,enemy)
  if enemy.get("trait","")=="armored": damage=maxi(1,damage-2)
  var effect=" · hits every foe on this front" if chosen=="cleave" else (" · stuns: cancels its next attack" if chosen in ["spark","pin","frost"] else "")
  return "%s → %s · %d damage after armor%s" % [SHORT[chosen],enemy.name,damage,effect]
 var ally=game.ally(id)
 return detail(chosen)+" → "+(enemy.name if not enemy.is_empty() else ally.name)

func detail(id: String) -> String:
 if id=="move": return "Move to another front · %s · once per hero per turn." % ("free with Scout's pennant" if game.free_march() else "1 order")
 return game.card_text(selected,id).replace("\n"," · ")

func select_hero(id: String):
 if game.ally(id).hp<=0: return
 selected=id;chosen="";target="";battle_notice="";show_page()

func choose_card(id: String):
 chosen=id;target="";battle_notice=""
 if id!="move" and Game.COMMANDS[id].target=="self": on_actor(selected)
 else: show_page()

func on_actor(id: String):
 if finishing_impact: finish_combat_animation();return
 if chosen=="":
  if not game.ally(id).is_empty(): select_hero(id)
  else: inspect(actor_detail(game.foe(id),true))
  return
 if chosen=="move": return
 var before=game.snapshot()
 var played=game.play(selected,chosen,id)
 if played:
  game.message=game.ally(selected).name+" used "+SHORT[chosen]+"."
  undo=before;field.animate_change(before.battle,selected,chosen);chosen="";target="";tone(450);persist()
  hold_final_impact()
 battle_notice="" if played and not reduced_motion and not coach_hint().is_empty() else game.message
 show_page()

func move_to(lane: int):
 var before=game.snapshot()
 if game.reposition(selected,lane):
  undo=before;field.animate_change(before.battle,selected,"move");chosen="";target="";persist()
 battle_notice=game.message
 show_page()

func cycle_target():
 if chosen in ["","move"]: return
 var targets=[]
 for u in game.battle.heroes+game.battle.enemies:
  if game.reason(selected,chosen,u.id)=="": targets.append(u.id)
 if targets.is_empty(): return
 target=targets[posmod(targets.find(target)+1,targets.size())]
 field.highlighted=target;field.queue_redraw()
 inspect(target_detail(target)+" · F confirms")

func resolve_turn():
 if finishing_impact: finish_combat_animation();return
 if page!="battle" or game.battle.phase!="playing": return
 var before=game.battle.duplicate(true)
 for e in before.enemies: e.motion_power=game.attack_power(e)
 game.resolve()
 before.motion_attack_state=game.resolution_start;before.motion_absorbed=game.hazard_absorbed
 before.motion_enemy_turn=game.enemy_turn_started
 field.animate_change(before,"","",true);hold_final_impact()
 chosen="";target="";battle_notice=game.message if reduced_motion else "";undo={};tone(160);persist();show_page()

func hold_final_impact():
 if game.battle.phase=="playing" or reduced_motion or not field.motion.active(): return
 finishing_impact=true
 if finish_tween: finish_tween.kill()
 finish_tween=create_tween()
 finish_tween.tween_interval(maxf(0.39,field.motion.last_impact())+0.18)
 finish_tween.tween_callback(finish_combat_animation)

func cancel_combat_animation():
 finishing_impact=false
 if finish_tween: finish_tween.kill();finish_tween=null
 field.clear_motion()

func finish_combat_animation():
 cancel_combat_animation()
 if page=="battle": show_page()

func undo_action():
 if undo.is_empty() or game.battle.phase!="playing": return
 cancel_combat_animation()
 game.restore(undo);undo={};chosen="";target="";game.message="Last command undone.";battle_notice=game.message;persist();show_page()

func reward_page():
 field.battle_view=false;field.queue_redraw()
 var won=game.battle.phase=="victory"
 if won and game.opening_stage()==1 and game.opening_guided():
  opening_reward_page();return
 header("Victory secured" if won else "The company survives.",game.encounter().name)
 icon("rowan",Rect2(129,288,370,370));icon("fen",Rect2(353,416,222,222))
 if won and game.battle.has("quest_reward"):
  text("Side quest secured",Rect2(80,173,590,35),23,NAVY,true)
  text(game.battle.quest_reward,Rect2(80,218,570,63),18,NAVY)
 if won and game.battle.get("mastery_rules",false):
  var awards=game.battle.get("mastery_awards",[])
  var complete=true
  for h in game.battle.heroes:
   if h.id in Game.MASTERY_HEROES and game.mastery_wins(h.id)<9: complete=false
  text("Mastery unlocked · select a hero" if not awards.is_empty() else ("A fully mastered company" if complete else "Mastery grows with every victory"),Rect2(80,684,590,35),23,NAVY,true)
  if awards.is_empty(): text("Every deployed hero has reached mastery III. Try new equipment and banner combinations." if complete else "Each deployed hero gains a mastery win, up to 9. Ranks unlock at 2, 5 and 9 wins.",Rect2(80,730,570,103),19,MUTED)
  else:
   var i=0
   for h in game.battle.heroes:
    var rank=game.rank_from_wins(game.mastery_wins(h.id))
    if rank<=int(h.get("mastery",0)): continue
    button("%s · Mastery %s" % [h.name,Game.RANK_NAMES[rank]],Rect2(80+(i%2)*284,730+int(i/2)*57,272,47),func():show_mastery(h.id))
    i+=1
  text("Bonus objective: +%d gold included" % game.battle.objective.gold if game.battle.objective.paid else "Bonus objective missed · no penalty",Rect2(706,271,630,27),17,MUTED)
 text("+%d gold" % game.battle.reward if won else "Your company is safe.",Rect2(703,229,658,65),40,NAVY,true)
 if won and game.battle.has("contract"): text("+%d renown · %d total" % [game.battle.contract.tier,game.war().renown],Rect2(706,301,634,30),20,BLUE,true)
 var new_level=int(game.battle.new_level)
 if new_level>0:
  text("Level %d unlocked" % new_level,Rect2(706,332,520,44),28,BLUE,true)
  var seal=Unlock.new();seal.level=new_level;seal.position=Vector2(1250,320);seal.size=Vector2(72,72)
  var key="%d:%d:%d" % [new_level,game.battle.mission,game.campaign.xp]
  seal.reduced_motion=reduced_motion or unlock_seen==key;unlock_seen=key;hud.add_child(seal)
  text(Coach.unlock_text(new_level),Rect2(706,382,634,81),18,NAVY)
 elif not won: text(game.battle.get("quest_failure","Your heroes, gear and gold are kept. Try shielding a threatened ally, stunning a sapper or moving to protect your gate."),Rect2(704,365,622,165),24,NAVY)
 if game.has_loot():
  text("Choose one banner upgrade",Rect2(706,468,643,39),24,NAVY,true)
  for i in range(game.battle.loot.size()):
   var id=game.battle.loot[i];var rank=int(game.war().banners.get(id,0));var y=520+i*78
   button(Game.BANNERS[id].name+(" · Rank %d" % (rank+1) if rank<3 else " · Mastered: +40 gold"),Rect2(706,y,611,45),func():transact(func():game.claim_banner(id)))
   text(game.banner_text(id,mini(3,rank+1)),Rect2(715,y+47,601,29),17,MUTED)
  text("Bonuses apply when their commands are unlocked and packed.",Rect2(715,749,601,23),16,MUTED)
 elif won:
  text(game.battle.get("claim_message","Banner claimed. Choose your active banner at the keep.") if game.battle.get("loot_claimed",false) else "Victory secured. Plan your next expedition at the keep.",Rect2(706,510,611,130),23,NAVY)
 button("Choose a banner first" if game.has_loot() else "Back to the keep  →",Rect2(706,774,611,62),return_to_keep,true,game.has_loot())

func return_to_keep():
 var pack_next=game.opening_guided() and game.opening_stage()==1 and game.battle.get("phase","")=="victory"
 game.return_to_camp()
 if not game.battle.is_empty(): show_page();return
 mission=mini(game.campaign.unlocked,game.level()-1);undo={};persist()
 if pack_next: gear="cube";chest_cursor=Vector2i(1,0);navigate("chest")
 else: navigate("keep")

func opening_reward_page():
 header("The gate holds.","Your company has earned its first advantage.")
 icon("rowan",Rect2(73,276,235,328));icon("lysa",Rect2(284,299,215,305));icon("fen",Rect2(444,397,225,207))
 text("+%d gold · Company level 2" % game.battle.reward,Rect2(91,663,550,46),25,NAVY,true)
 text("The company will grow. First, make its equipment work together.",Rect2(91,721,531,81),22,MUTED)
 icon("cube",Rect2(1001,216,126,126),BLUE)
 text("Recovered: Storm rune",Rect2(744,373,600,51),32,NAVY,true)
 text("One cell. A stronger weapon.",Rect2(746,444,590,37),23,NAVY)
 text("Pack the rune beside your sword or bow. An edge-touching weapon gains +2 damage on its equipment command.",Rect2(746,503,587,118),24,NAVY)
 button("Pack the storm rune  →",Rect2(746,663,600,64),return_to_keep,true)
 button("Explore without guidance",Rect2(746,749,600,48),func():game.skip_opening();return_to_keep())

func show_mastery(id: String):
 var rank=game.rank_from_wins(game.mastery_wins(id))
 mastery_notice=("Next unlock: " if rank==0 else "Mastery %s: " % Game.RANK_NAMES[rank])+game.mastery_effect(id,maxi(1,rank))
 if page=="battle": mastery_notice+=" Applies next battle."
 show_page()

func chest_page():
 var teaching=game.opening_guided() and game.opening_stage() in [1,2]
 header("One cell. A stronger weapon." if teaching else "Pack your next victory", "Place the storm rune in a free cell sharing an edge with the sword or bow." if teaching else "Equipment gives you commands. Fit your chosen loadout into the chest.")
 button("← Keep",Rect2(46,157,148,44),func():navigate("keep"))
 chest=Chest.new();chest.game=game;chest.selected=gear;chest.item_rotation=rotation_index;chest.cursor=chest_cursor;chest.position=Vector2(110,329);chest.scale=Vector2.ONE*1.1;hud.add_child(chest)
 chest.selected_item.connect(func(id):gear=id;rotation_index=int(game.campaign.placements[id][2]);chest_cursor=chest.cursor;show_page())
 chest.placed.connect(func(id,x,y,r):gear=id;rotation_index=r;chest_cursor=Vector2i(x,y);game.place(id,x,y,r);persist();show_page())
 text("6 × 5 chest",Rect2(112,247,540,49),29,NAVY,true)
 text("Olive dot = rune-linked · +2 command damage",Rect2(112,299,585,28),16,MUTED)
 text("Your equipment · pack or leave behind",Rect2(777,247,581,46),26,NAVY,true)
 var i=0
 for id in game.campaign.items:
  var packed=game.campaign.placements.has(id)
  var b=button(Game.ITEMS[id].name+("\nPacked" if packed else "\nStored"),Rect2(779+(i%2)*299,310+int(i/2)*62,286,55),func():gear=id;rotation_index=int(game.campaign.placements.get(id,[0,0,0])[2]);show_page(),gear==id)
  b.add_theme_font_size_override("font_size",17)
  i+=1
 text(Game.ITEMS[gear].name,Rect2(780,727,572,34),23,NAVY,true)
 text(GEAR_EFFECT.get(gear,Game.ITEMS[gear].desc),Rect2(780,771,575,62),19,NAVY)
 button("Rotate [R]",Rect2(112,788,204,46),func():chest.rotate_preview();rotation_index=chest.item_rotation)
 button("Store item",Rect2(334,788,205,46),func():game.stow(gear);persist();show_page())
 text("Drag to pack · WASD: cursor · R: rotate · F: place",Rect2(112,724,572,49),17,MUTED)
 if teaching:
  var linked=game.empowered("blade") or game.empowered("bow")
  button("Test this loadout  →" if linked else "Pack a rune beside a weapon",Rect2(777,158,578,53),func():mission=1;keep_mode="campaign";start_battle(),true,not linked)
  if not linked and gear=="cube":
   chest.suggested=rune_suggestions();chest.queue_redraw()
  text("+2 Cleave damage"+(" · +2 Volley damage" if game.empowered("bow") else "") if game.empowered("blade") else ("+2 Volley damage" if game.empowered("bow") else "Select the storm rune, then an outlined free cell beside a weapon."),Rect2(112,206,570,38),18,BLUE)
  button("Explore without guidance",Rect2(235,158,397,43),func():game.skip_opening();persist();navigate("keep"))

func rune_suggestions() -> Array:
 var result=[]
 for y in range(5):
  for x in range(6):
   if not game.can_place("cube",x,y,0): continue
   for id in ["blade","bow"]:
    if not game.campaign.placements.has(id): continue
    for cell in game.cells(id,game.campaign.placements[id]):
     if absi(cell[0]-x)+absi(cell[1]-y)==1 and Vector2i(x,y) not in result: result.append(Vector2i(x,y))
 return result

func transact(action: Callable):
 action.call();persist();show_page()

func shop_page():
 header("The quartermaster", "Spend earned gold on heroes and equipment. No real-money purchases.")
 button("← Keep",Rect2(46,157,148,44),func():navigate("keep"))
 text("Upgrade & equip",Rect2(50,236,650,47),30,NAVY,true)
 var i=0
 for id in Game.ITEMS:
  if id in Game.RELICS: continue
  var owned=game.campaign.items.has(id);var unlocked=game.level()>=game.item_level(id);var y=309+i*62
  icon(id,Rect2(44,y,39,39));text(Game.ITEMS[id].name,Rect2(97,y,236,37),19,NAVY,true)
  var b: Button
  if owned:
   var rank=int(game.campaign.items[id]);var locked=id in ["cube","ballista"] or rank>=game.forge_limit()
   b=button("+%d · Upgrade %dg" % [rank,30+rank*25] if not locked else ("+%d · Complete" % rank if rank==3 or id in ["cube","ballista"] else "+%d · Next rank locked" % rank),Rect2(340,y,312,44),func():transact(func():game.upgrade(id)),false,locked or game.campaign.gold<30+rank*25)
  else: b=button("Buy · %d gold" % Game.ITEMS[id].price if unlocked else "Level %d" % game.item_level(id),Rect2(340,y,312,44),func():transact(func():game.buy(id)),false,not unlocked or game.campaign.gold<Game.ITEMS[id].price)
  b.tooltip_text=GEAR_EFFECT[id]
  i+=1
 icon("merrin",Rect2(758,264,160,183))
 text("Merrin",Rect2(962,286,410,45),31,NAVY,true)
 text("Storm mage · damage + stun\nComes with a storm staff.",Rect2(964,344,430,76),20,MUTED)
 button("Already recruited" if game.campaign.mage else ("Recruit · 60 gold" if game.level()>=2 else "Recruit at level 2"),Rect2(778,473,601,52),func():transact(func():game.recruit()),true,game.campaign.mage or game.level()<2 or game.campaign.gold<60)
 text("Choose one lasting talent",Rect2(779,559,599,39),23,NAVY,true)
 button("Battlecraft · +1 damage",Rect2(779,611,599,44),func():transact(func():game.choose_talent("might")),game.campaign.talent=="might",game.level()<2 or game.campaign.talent!="")
 button("Resolve · +4 health",Rect2(779,669,599,44),func():transact(func():game.choose_talent("resolve")),game.campaign.talent=="resolve",game.level()<2 or game.campaign.talent!="")
 button("Fen · Wolf",Rect2(779,765,284,47),func():transact(func():game.choose_pet("wolf")),game.campaign.pet=="wolf")
 button("Talon · Owl" if game.level()>=6 else "Owl · Level 6",Rect2(1084,765,294,47),func():transact(func():game.choose_pet("owl")),game.campaign.pet=="owl",game.level()<6)

func guide_page():
 header("Field manual", "No timer. Take your time with every turn.")
 button("← Back to game",Rect2(47,158,234,48),func():navigate(guide_return))
 var sections=[
  ["Pack","Gear in your chest grants commands. Touch weapons with the rune for +2 damage. Buy gear and recruit at the keep."],
  ["Command","Choose a hero, then a command and target. Share 6 orders per turn (7 from level 5). Each command is usable once per hero each turn."],
  ["Protect","Read enemy intentions. Archers hunt weak allies, sappers target the gate, and iron guards block 2 damage per hit. Hover a foe for its rule."],
  ["Grow","Wins give gold, banners and hero mastery. Mastery ranks at 2/5/9 wins improve each hero's existing commands. Inspect heroes to read effects. Optional objectives award extra gold."]]
 for i in range(4):
  var x=50+(i%2)*704;var y=260+int(i/2)*190
  text(sections[i][0],Rect2(x,y,629,40),30,NAVY,true)
  text(sections[i][1],Rect2(x,y+55,625,123),23,NAVY)
 button("Sound off" if muted else "Sound on",Rect2(49,720,206,49),func():muted=not muted;save_settings();show_page())
 button("Less motion" if reduced_motion else "Motion on",Rect2(274,720,225,49),func():reduced_motion=not reduced_motion;save_settings();show_page())
 var can_replay=game.level()==1 and int(game.campaign.get("lessons",15))==15
 button("Replay lessons" if can_replay else ("Lessons on" if coaching else "Lessons off"),Rect2(518,720,206,49),func():
  if can_replay: game.campaign.lessons=0;coaching=true;persist()
  else: coaching=not coaching
  save_settings();show_page())
 text("1–5: hero · Tab / Enter: controls · T / F: target\nSpace: end turn · Z: undo · Esc: cancel / back",Rect2(746,719,645,67),18,MUTED)
 if guide_return=="battle" and not game.battle.is_empty() and game.battle.phase=="playing":
  button("Withdraw — keep gear, forfeit reward?" if retreat_confirm else "Retreat to keep",Rect2(51,788,610,47),func():
   if retreat_confirm: game.retreat();persist();navigate("battle")
   else: retreat_confirm=true;show_page(),retreat_confirm)

func save_settings():
 if demo: return
 var settings=ConfigFile.new();settings.set_value("play","muted",muted);settings.set_value("play","reduced_motion",reduced_motion)
 settings.set_value("play","coaching",coaching)
 if settings.save(SETTINGS)!=OK: game.message="Could not save preferences. They still apply for this session."

func tone(frequency: float):
 if muted: return
 var data=PackedByteArray();data.resize(4410)
 for i in range(2205): data.encode_s16(i*2,int(sin(TAU*frequency*i/22050)*pow(1.0-float(i)/2205,2)*2000))
 var wave=AudioStreamWAV.new();wave.format=AudioStreamWAV.FORMAT_16_BITS;wave.mix_rate=22050;wave.data=data;sound.stop();sound.stream=wave;sound.play()

func _process(_delta):
 if not is_instance_valid(field): return
 var active=field.motion.active()
 if active or motion_was_active:
  for entry in actor_controls:
   if is_instance_valid(entry.button): entry.button.position=field.unit_rect(entry.unit,entry.enemy).position
 motion_was_active=active

func _input(event):
 if not event is InputEventKey or not event.pressed or event.echo: return
 if finishing_impact and event.keycode in [KEY_SPACE,KEY_ENTER]:
  finish_combat_animation();get_viewport().set_input_as_handled();return
 if event.keycode==KEY_ESCAPE:
  if page=="guide": navigate(guide_return)
  elif chosen!="": chosen="";target="";show_page()
  elif page!="keep" and page!="battle": navigate("keep")
 elif page=="chest" and event.keycode in [KEY_W,KEY_A,KEY_S,KEY_D,KEY_R,KEY_F]:
  chest.keyboard(event.keycode);rotation_index=chest.item_rotation;chest_cursor=chest.cursor
 elif page=="battle" and game.battle.phase=="playing":
  if event.keycode==KEY_SPACE: resolve_turn()
  elif event.keycode==KEY_Z: undo_action()
  elif event.keycode==KEY_T: cycle_target()
  elif event.keycode==KEY_F and target!="": on_actor(target)
  elif event.keycode>=KEY_1 and event.keycode<=KEY_5:
   var index=event.keycode-KEY_1
   if index<game.battle.heroes.size(): select_hero(game.battle.heroes[index].id)
  else: return
 else: return
 get_viewport().set_input_as_handled()
