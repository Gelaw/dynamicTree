nodeTypes = {"root", "active", "passive", "mod"}

nodeLib = {
  --passives
  {nodeType = "passive", name = "mana", tag = {"mana", "ressource"}, effects = {manaMax = 100, manaPer = 1}},
  {nodeType = "passive", name = "stamina", tag = {"mana", "ressource"}, effects = {staminaMax = 20, staminaPer = 1}},
  {nodeType = "passive", name = "energy shield", tag = {"energy shield", "ressource"}, effects = {ESMax = 20}},

  --actives
  {nodeType = "active", name= "fireball", tags= {"mana"}, tags ={"fire", "mana", "damage", "hit"}, effects= {mana= -10, damage=10}},
  {nodeType = "active", name= "dash", ressource = {"stamina"}, tags ={"stamina", "deplacement"}, effects= {stamina= -10, range=20}},

  --mods
  {nodeType = "mod", name = "arcane Knowledge", tags = {"mana", "ressource"}, effects = {manaMax = 30, manaPer = 1}},
  {nodeType = "mod", name = "combat training", tags = {"stamina", "ressource"}, effects = {staminaMax = 10, staminaInCombat = "true"}},
  {nodeType = "mod", name = "burn", tags = {"fire"}, effects = {extraCostPercent = 10, damagePer = 1, duration = 10}}
}
