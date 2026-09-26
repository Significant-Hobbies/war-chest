extends SceneTree
const Main=preload("res://scripts/pocket_main.gd")
var failures=0
func _init(): call_deferred("run")
func check(ok: bool,label: String):
 if not ok: failures+=1;push_error("FAIL: "+label)
func run():
 if "--pocket-demo" not in OS.get_cmdline_user_args():
  push_error("UI tests require --pocket-demo to isolate saves.");quit(1);return
 var screen=Main.new();root.add_child(screen)
 # Dummy headless audio has no device to drain queued playback at fast teardown.
 # Sound quality is outside this rule/UI wiring test.
 screen.muted=true
 screen.game.campaign.mastery.rowan=1
 screen.game.begin(0);screen.page="battle";screen.show_page()
 await process_frame
 screen.card_buttons[0].pressed.emit()
 screen.cycle_target();screen.on_actor(screen.target)
 check(screen.game.battle.commands==4,"Cleave spends 2 orders")
 check(screen.game.battle.enemies[0].hp==0,"Cleave kills first foe")
 screen.undo_action()
 check(screen.game.battle.commands==6,"Undo restores orders")
 check(screen.game.battle.enemies[0].hp==10,"Undo restores foes")
 check(screen.inspection.text=="Last command undone.","Undo feedback is current")
 await process_frame
 screen.card_buttons[0].pressed.emit()
 screen.cycle_target();screen.on_actor(screen.target)
 check(screen.game.battle.commands==4,"Card remains functional after undo")
 screen.select_hero("lysa")
 check(screen.selected=="lysa","Hero selection after undo")
 screen.resolve_turn()
 check(screen.game.battle.round==2,"End turn after undo")
 var before=screen.game.snapshot()
 screen.choose_card("strike");screen.on_actor("rowan")
 check(screen.game.snapshot()==before,"Invalid target is atomic")
 check(screen.inspection.text==screen.game.message,"Invalid target reason remains visible")
 screen.chosen="";screen.target=""
 for i in range(3): screen.resolve_turn()
 check(screen.game.battle.phase=="victory","First siege completes")
 check(screen.game.level()==2,"Victory unlocks level two")
 check(screen.game.has_loot(),"Victory opens persistent reward choice")
 check(screen.finishing_impact,"Final turn briefly preserves battlefield impact")
 await create_timer(0.65).timeout
 check(not screen.finishing_impact,"Final impact automatically reveals reward controls")
 screen.show_mastery("rowan")
 check(screen.status.text.contains("Guard") and screen.status.text.contains("next battle"),"Rank up inspection explains unlocked effect and timing")
 var banner=screen.game.battle.loot[0]
 var clicked=false
 for node in screen.hud.get_children():
  if node is Button and node.text.begins_with(screen.Game.BANNERS[banner].name):
   node.pressed.emit();clicked=true;break
 check(clicked and not screen.game.has_loot(),"Reward button claims one banner")
 screen.return_to_keep()
 check(screen.page=="keep" and screen.game.battle.is_empty(),"Reward returns to keep")
 screen.keep_mode="contracts";screen.show_page()
 for node in screen.hud.get_children():
  if node is Button and node.text=="War contracts": node.grab_focus();break
 screen.show_page()
 check(screen.get_viewport().gui_get_focus_owner() is Button and screen.get_viewport().gui_get_focus_owner().text=="War contracts","Keep selector focus survives rebuild")
 for node in screen.hud.get_children():
  if node is Button and node.get_meta("focus_key","")=="mastery_lysa":
   node.grab_focus();node.pressed.emit();break
 check(screen.mastery_notice.contains("Volley") and screen.status.text==screen.mastery_notice,"Keep mastery inspection explains future effect")
 check(screen.get_viewport().gui_get_focus_owner().get_meta("focus_key","")=="mastery_lysa","Mastery inspection preserves exact hero focus")
 clicked=false
 for node in screen.hud.get_children():
  if node is Button and node.text=="Take contract  →": node.pressed.emit();clicked=true;break
 check(clicked and screen.game.battle.has("contract") and screen.page=="battle","Contract action opens a real battle")
 var atlas=load("res://assets/pocket-v2/company-atlas.png").get_image()
 check(atlas.get_pixel(0,0).a==0,"Sprite atlas has actual transparency")
 var support=load("res://assets/pocket-v2/support-atlas.png").get_image()
 check(support.get_pixel(0,0).a==0 and support.get_pixel(512,512).a==0,"Support sprites have actual transparency")
 screen.queue_free()
 await process_frame
 await process_frame
 print("POCKET UI TEST: %d failures" % failures)
 quit(1 if failures else 0)
