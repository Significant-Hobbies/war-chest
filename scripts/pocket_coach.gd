extends RefCounted
## Read-only contextual teaching. Never restricts legal commands.
const ATTACK=1
const RANGE=2
const BLOCK=4
const TURN=8
const COMPLETE=15
const UNLOCKS={
 2:["Merrin · recruit for 60 gold, then pack his Storm staff.","Talent · choose +1 damage or +4 health for free.","Also open: side quests, contracts and forge rank I."],
 3:["Ballista · buy for 85 gold and pack it to deploy.","Medicine · buy for 35 gold; Merrin needs it packed to heal.","Also open: forge rank II."],
 4:["Fen's Pin down · ready now; strike and stun on his front.","Frostfang · free in storage; pack it for Lysa's Freeze."],
 5:["Rally · ready now; Rowan gives every ally 4 block.","Seven orders per turn · ready now. Forge rank III is open."],
 6:["Talon · choose the owl at Recruit & upgrade, for free.","Gust · Talon can stun a foe on any front.","Final campaign challenge: The Hollow Crown."]
}

static func hint(game,selected: String,chosen: String) -> Dictionary:
 if game.battle.is_empty() or game.battle.phase!="playing" or game.level()!=1: return {}
 var bits=int(game.campaign.get("lessons",COMPLETE))
 if bits==COMPLETE: return {}
 var step=1
 for bit in [ATTACK,RANGE,BLOCK,TURN]:
  if bits & bit: step+=1
 var heading="Field lesson %d/4" % step
 if game.battle.commands==0:
  return {"heading":heading+" · Refresh your orders","body":"No orders left. Choose End turn: enemies act, then your six orders return."}
 if chosen!="": return {"heading":heading+" · Choose a target","body":"Click a troop, or T to preview a legal target and F to confirm. Esc cancels; Z undoes your last order."}
 if not bits & ATTACK:
  if game.reason("rowan","cleave")=="":
   for e in game.battle.enemies:
    if game.reason("rowan","cleave",e.id)=="":
     return {"heading":heading+" · Attack a whole front","body":"Select Rowan → Cleave → a foe on front %d. Cleave hits every foe on his front; it costs 2 orders." % (int(game.ally("rowan").lane)+1)}
  for h in game.battle.heroes:
   for e in game.battle.enemies:
    if game.reason(h.id,"strike",e.id)=="":
     return {"heading":heading+" · Make your first attack","body":"Select %s → Strike → a foe on front %d. Z undoes your last order." % [h.name,int(h.lane)+1]}
 if not bits & RANGE and game.ally("lysa").hp>0 and game.reason("lysa","volley")=="":
  for e in game.battle.enemies:
   if e.hp>0 and e.lane!=game.ally("lysa").lane:
    return {"heading":heading+" · Reach another front","body":"Select Lysa → Volley → a foe on another front. Your whole company shares the six gold orders."}
 if not bits & BLOCK:
  for h in game.battle.heroes:
   if game.reason(h.id,"guard")=="":
    return {"heading":heading+" · Read the enemy's plan","body":"The arrow under a foe names its target. Select a threatened hero → Guard: 6 block for this enemy turn."}
 if not bits & TURN:
  return {"heading":heading+" · Let the enemy respond","body":"Spend your remaining orders, then End turn. Block absorbs damage; unused block expires. Hold out for 4 turns."}
 if not bits & RANGE and not game.campaign.placements.has("bow"):
  return {"heading":heading+" · Ranged lesson needs a bow","body":"Lysa's bow is stored. Finish this fight, then Pack equipment at the keep to restore Volley. You can skip lessons at any time."}
 if not bits & RANGE and game.ally("lysa").hp<=0:
  return {"heading":heading+" · Lysa returns next battle","body":"Lysa is down, so the ranged lesson must wait. Keep the gate standing; fallen heroes return for your next battle."}
 return {"heading":heading+" · Plan your next turn","body":"No lesson action is available now. Spend useful orders, then End turn. New waves arrive on turns 2 and 4; hold out through turn 4."}

static func unlock_text(level: int) -> String:
 return "\n".join(UNLOCKS.get(level,[]))
