-- MetaHunt Items Extras (generated from pfQuest/pfQuest-turtle)
-- Adds missing ranged items and missing V/U/O source data
if not MTH_DS then MTH_DS = {} end
if not MTH_DS_AmmoItems then MTH_DS_AmmoItems = {} end

do
  local item = MTH_DS_AmmoItems[2098]
  if not item then
    item = {}
    MTH_DS_AmmoItems[2098] = item
  end
  if not item["name"] then item["name"] = 'Double-barreled Shotgun' end
  if not item["level"] then item["level"] = 27 end
  if not item["reqlevel"] then item["reqlevel"] = 22 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_08' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 13.3 end
  if not item["speed"] then item["speed"] = 2.3 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][7] == nil then item["vendors"][7] = 0 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][2849] == nil then item["objects"][2849] = 0.01 end
  if item["objects"][2850] == nil then item["objects"][2850] = 0.01 end
  if item["objects"][2852] == nil then item["objects"][2852] = 0.01 end
  if item["objects"][2855] == nil then item["objects"][2855] = 0.01 end
  if item["objects"][3714] == nil then item["objects"][3714] = 0.01 end
  if item["objects"][3715] == nil then item["objects"][3715] = 0.01 end
  if item["objects"][4095] == nil then item["objects"][4095] = 0.01 end
  if item["objects"][4096] == nil then item["objects"][4096] = 0.01 end
  if item["objects"][74447] == nil then item["objects"][74447] = 0.01 end
  if item["objects"][74448] == nil then item["objects"][74448] = 0.01 end
  if item["objects"][75295] == nil then item["objects"][75295] = 0.01 end
  if item["objects"][75296] == nil then item["objects"][75296] = 0.01 end
  if item["objects"][75297] == nil then item["objects"][75297] = 0.01 end
  if item["objects"][75298] == nil then item["objects"][75298] = 0.01 end
  if item["objects"][75299] == nil then item["objects"][75299] = 0.01 end
  if item["objects"][75300] == nil then item["objects"][75300] = 0.01 end
  if item["objects"][105570] == nil then item["objects"][105570] = 0.01 end
  if item["objects"][105578] == nil then item["objects"][105578] = 0.01 end
  if item["objects"][105579] == nil then item["objects"][105579] = 0.01 end
  if item["objects"][111095] == nil then item["objects"][111095] = 0.01 end
  if item["objects"][153462] == nil then item["objects"][153462] = 0.02 end
end

do
  local item = MTH_DS_AmmoItems[2099]
  if not item then
    item = {}
    MTH_DS_AmmoItems[2099] = item
  end
  if not item["name"] then item["name"] = 'Dwarven Hand Cannon' end
  if not item["level"] then item["level"] = 58 end
  if not item["reqlevel"] then item["reqlevel"] = 53 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_09' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 2 end
  if not item["dps"] then item["dps"] = 32.8 end
  if not item["speed"] then item["speed"] = 2.9 end
end

do
  local item = MTH_DS_AmmoItems[2100]
  if not item then
    item = {}
    MTH_DS_AmmoItems[2100] = item
  end
  if not item["name"] then item["name"] = 'Precisely Calibrated Boomstick' end
  if not item["level"] then item["level"] = 48 end
  if not item["reqlevel"] then item["reqlevel"] = 43 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_06' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 2 end
  if not item["dps"] then item["dps"] = 27.7 end
  if not item["speed"] then item["speed"] = 1.5 end
end

do
  local item = MTH_DS_AmmoItems[2504]
  if not item then
    item = {}
    MTH_DS_AmmoItems[2504] = item
  end
  if not item["name"] then item["name"] = 'Worn Shortbow' end
  if not item["level"] then item["level"] = 2 end
  if not item["reqlevel"] then item["reqlevel"] = 1 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_05' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 5 end
  if not item["dps"] then item["dps"] = 1.5 end
  if not item["speed"] then item["speed"] = 2.3 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][1297] == nil then item["vendors"][1297] = 0 end
  if item["vendors"][1459] == nil then item["vendors"][1459] = 0 end
  if item["vendors"][12029] == nil then item["vendors"][12029] = 0 end
  if item["vendors"][14301] == nil then item["vendors"][14301] = 0 end
end

do
  local item = MTH_DS_AmmoItems[2505]
  if not item then
    item = {}
    MTH_DS_AmmoItems[2505] = item
  end
  if not item["name"] then item["name"] = 'Polished Shortbow' end
  if not item["level"] then item["level"] = 4 end
  if not item["reqlevel"] then item["reqlevel"] = 1 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_02' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 5 end
  if not item["dps"] then item["dps"] = 1.8 end
  if not item["speed"] then item["speed"] = 2 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][1297] == nil then item["vendors"][1297] = 0 end
  if item["vendors"][1459] == nil then item["vendors"][1459] = 0 end
  if item["vendors"][12029] == nil then item["vendors"][12029] = 0 end
  if item["vendors"][14301] == nil then item["vendors"][14301] = 0 end
end

do
  local item = MTH_DS_AmmoItems[2506]
  if not item then
    item = {}
    MTH_DS_AmmoItems[2506] = item
  end
  if not item["name"] then item["name"] = 'Hornwood Recurve Bow' end
  if not item["level"] then item["level"] = 8 end
  if not item["reqlevel"] then item["reqlevel"] = 3 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_11' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 5 end
  if not item["dps"] then item["dps"] = 2.4 end
  if not item["speed"] then item["speed"] = 2.1 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][150] == nil then item["vendors"][150] = 0 end
  if item["vendors"][1198] == nil then item["vendors"][1198] = 0 end
  if item["vendors"][1297] == nil then item["vendors"][1297] = 0 end
  if item["vendors"][1459] == nil then item["vendors"][1459] = 0 end
  if item["vendors"][1859] == nil then item["vendors"][1859] = 0 end
  if item["vendors"][3165] == nil then item["vendors"][3165] = 0 end
  if item["vendors"][3589] == nil then item["vendors"][3589] = 0 end
  if item["vendors"][3610] == nil then item["vendors"][3610] = 0 end
  if item["vendors"][10369] == nil then item["vendors"][10369] = 0 end
  if item["vendors"][12029] == nil then item["vendors"][12029] = 0 end
  if item["vendors"][14301] == nil then item["vendors"][14301] = 0 end
  if item["vendors"][62088] == nil then item["vendors"][62088] = 0 end
  if item["vendors"][91246] == nil then item["vendors"][91246] = 0 end
end

do
  local item = MTH_DS_AmmoItems[2507]
  if not item then
    item = {}
    MTH_DS_AmmoItems[2507] = item
  end
  if not item["name"] then item["name"] = 'Laminated Recurve Bow' end
  if not item["level"] then item["level"] = 16 end
  if not item["reqlevel"] then item["reqlevel"] = 11 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_01' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 5 end
  if not item["dps"] then item["dps"] = 5.8 end
  if not item["speed"] then item["speed"] = 2.6 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][150] == nil then item["vendors"][150] = 0 end
  if item["vendors"][1198] == nil then item["vendors"][1198] = 0 end
  if item["vendors"][1297] == nil then item["vendors"][1297] = 0 end
  if item["vendors"][1459] == nil then item["vendors"][1459] = 0 end
  if item["vendors"][1668] == nil then item["vendors"][1668] = 0 end
  if item["vendors"][1687] == nil then item["vendors"][1687] = 0 end
  if item["vendors"][1859] == nil then item["vendors"][1859] = 0 end
  if item["vendors"][3165] == nil then item["vendors"][3165] = 0 end
  if item["vendors"][3409] == nil then item["vendors"][3409] = 0 end
  if item["vendors"][3488] == nil then item["vendors"][3488] = 0 end
  if item["vendors"][3589] == nil then item["vendors"][3589] = 0 end
  if item["vendors"][3610] == nil then item["vendors"][3610] = 0 end
  if item["vendors"][3951] == nil then item["vendors"][3951] = 0 end
  if item["vendors"][4203] == nil then item["vendors"][4203] = 0 end
  if item["vendors"][9549] == nil then item["vendors"][9549] = 0 end
  if item["vendors"][9553] == nil then item["vendors"][9553] = 0 end
  if item["vendors"][10369] == nil then item["vendors"][10369] = 0 end
  if item["vendors"][12029] == nil then item["vendors"][12029] = 0 end
  if item["vendors"][14301] == nil then item["vendors"][14301] = 0 end
  if item["vendors"][60659] == nil then item["vendors"][60659] = 0 end
  if item["vendors"][62088] == nil then item["vendors"][62088] = 0 end
  if item["vendors"][91246] == nil then item["vendors"][91246] = 0 end
  if item["vendors"][91977] == nil then item["vendors"][91977] = 0 end
end

do
  local item = MTH_DS_AmmoItems[2508]
  if not item then
    item = {}
    MTH_DS_AmmoItems[2508] = item
  end
  if not item["name"] then item["name"] = 'Old Blunderbuss' end
  if not item["level"] then item["level"] = 2 end
  if not item["reqlevel"] then item["reqlevel"] = 1 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_01' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 5 end
  if not item["dps"] then item["dps"] = 1.5 end
  if not item["speed"] then item["speed"] = 2.3 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][5510] == nil then item["vendors"][5510] = 0 end
end

do
  local item = MTH_DS_AmmoItems[2509]
  if not item then
    item = {}
    MTH_DS_AmmoItems[2509] = item
  end
  if not item["name"] then item["name"] = 'Ornate Blunderbuss' end
  if not item["level"] then item["level"] = 9 end
  if not item["reqlevel"] then item["reqlevel"] = 4 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_02' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 5 end
  if not item["dps"] then item["dps"] = 3 end
  if not item["speed"] then item["speed"] = 2.2 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][904] == nil then item["vendors"][904] = 0 end
  if item["vendors"][1243] == nil then item["vendors"][1243] = 0 end
  if item["vendors"][1297] == nil then item["vendors"][1297] = 0 end
  if item["vendors"][1469] == nil then item["vendors"][1469] = 0 end
  if item["vendors"][2997] == nil then item["vendors"][2997] = 0 end
  if item["vendors"][3018] == nil then item["vendors"][3018] = 0 end
  if item["vendors"][3078] == nil then item["vendors"][3078] = 0 end
  if item["vendors"][3322] == nil then item["vendors"][3322] = 0 end
  if item["vendors"][3488] == nil then item["vendors"][3488] = 0 end
  if item["vendors"][4603] == nil then item["vendors"][4603] = 0 end
  if item["vendors"][5123] == nil then item["vendors"][5123] = 0 end
  if item["vendors"][5510] == nil then item["vendors"][5510] = 0 end
  if item["vendors"][7976] == nil then item["vendors"][7976] = 0 end
  if item["vendors"][9551] == nil then item["vendors"][9551] = 0 end
  if item["vendors"][61445] == nil then item["vendors"][61445] = 0 end
  if item["vendors"][61751] == nil then item["vendors"][61751] = 0 end
  if item["vendors"][62403] == nil then item["vendors"][62403] = 0 end
  if item["vendors"][92217] == nil then item["vendors"][92217] = 0 end
end

do
  local item = MTH_DS_AmmoItems[2510]
  if not item then
    item = {}
    MTH_DS_AmmoItems[2510] = item
  end
  if not item["name"] then item["name"] = 'Solid Blunderbuss' end
  if not item["level"] then item["level"] = 3 end
  if not item["reqlevel"] then item["reqlevel"] = 1 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_07' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 5 end
  if not item["dps"] then item["dps"] = 2 end
  if not item["speed"] then item["speed"] = 2.2 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][904] == nil then item["vendors"][904] = 0 end
  if item["vendors"][1243] == nil then item["vendors"][1243] = 0 end
  if item["vendors"][3018] == nil then item["vendors"][3018] = 0 end
  if item["vendors"][3078] == nil then item["vendors"][3078] = 0 end
  if item["vendors"][4603] == nil then item["vendors"][4603] = 0 end
  if item["vendors"][5123] == nil then item["vendors"][5123] = 0 end
  if item["vendors"][5510] == nil then item["vendors"][5510] = 0 end
end

do
  local item = MTH_DS_AmmoItems[2511]
  if not item then
    item = {}
    MTH_DS_AmmoItems[2511] = item
  end
  if not item["name"] then item["name"] = "Hunter's Boomstick" end
  if not item["level"] then item["level"] = 14 end
  if not item["reqlevel"] then item["reqlevel"] = 9 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_04' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 5 end
  if not item["dps"] then item["dps"] = 5 end
  if not item["speed"] then item["speed"] = 2.1 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][1297] == nil then item["vendors"][1297] = 0 end
  if item["vendors"][1469] == nil then item["vendors"][1469] = 0 end
  if item["vendors"][1686] == nil then item["vendors"][1686] = 0 end
  if item["vendors"][2997] == nil then item["vendors"][2997] = 0 end
  if item["vendors"][3018] == nil then item["vendors"][3018] = 0 end
  if item["vendors"][3088] == nil then item["vendors"][3088] = 0 end
  if item["vendors"][3322] == nil then item["vendors"][3322] = 0 end
  if item["vendors"][3488] == nil then item["vendors"][3488] = 0 end
  if item["vendors"][5814] == nil then item["vendors"][5814] = 0 end
  if item["vendors"][7976] == nil then item["vendors"][7976] = 0 end
  if item["vendors"][9551] == nil then item["vendors"][9551] = 0 end
  if item["vendors"][61445] == nil then item["vendors"][61445] = 0 end
  if item["vendors"][61751] == nil then item["vendors"][61751] = 0 end
  if item["vendors"][62403] == nil then item["vendors"][62403] = 0 end
  if item["vendors"][92217] == nil then item["vendors"][92217] = 0 end
end

do
  local item = MTH_DS_AmmoItems[2512]
  if item then
    if not item["vendors"] then item["vendors"] = {} end
    if item["vendors"][150] == nil then item["vendors"][150] = 0 end
    if item["vendors"][151] == nil then item["vendors"][151] = 0 end
    if item["vendors"][152] == nil then item["vendors"][152] = 0 end
    if item["vendors"][228] == nil then item["vendors"][228] = 0 end
    if item["vendors"][491] == nil then item["vendors"][491] = 0 end
    if item["vendors"][789] == nil then item["vendors"][789] = 0 end
    if item["vendors"][791] == nil then item["vendors"][791] = 0 end
    if item["vendors"][829] == nil then item["vendors"][829] = 0 end
    if item["vendors"][1198] == nil then item["vendors"][1198] = 0 end
    if item["vendors"][1250] == nil then item["vendors"][1250] = 0 end
    if item["vendors"][1285] == nil then item["vendors"][1285] = 0 end
    if item["vendors"][1287] == nil then item["vendors"][1287] = 0 end
    if item["vendors"][1297] == nil then item["vendors"][1297] = 0 end
    if item["vendors"][1298] == nil then item["vendors"][1298] = 0 end
    if item["vendors"][1455] == nil then item["vendors"][1455] = 0 end
    if item["vendors"][1459] == nil then item["vendors"][1459] = 0 end
    if item["vendors"][1462] == nil then item["vendors"][1462] = 0 end
    if item["vendors"][1668] == nil then item["vendors"][1668] = 0 end
    if item["vendors"][1682] == nil then item["vendors"][1682] = 0 end
    if item["vendors"][1685] == nil then item["vendors"][1685] = 0 end
    if item["vendors"][1687] == nil then item["vendors"][1687] = 0 end
    if item["vendors"][1691] == nil then item["vendors"][1691] = 0 end
    if item["vendors"][1859] == nil then item["vendors"][1859] = 0 end
    if item["vendors"][2115] == nil then item["vendors"][2115] = 0 end
    if item["vendors"][2134] == nil then item["vendors"][2134] = 0 end
    if item["vendors"][2140] == nil then item["vendors"][2140] = 0 end
    if item["vendors"][2286] == nil then item["vendors"][2286] = 0 end
    if item["vendors"][2839] == nil then item["vendors"][2839] = 0 end
    if item["vendors"][3015] == nil then item["vendors"][3015] = 0 end
    if item["vendors"][3072] == nil then item["vendors"][3072] = 0 end
    if item["vendors"][3076] == nil then item["vendors"][3076] = 0 end
    if item["vendors"][3158] == nil then item["vendors"][3158] = 0 end
    if item["vendors"][3164] == nil then item["vendors"][3164] = 0 end
    if item["vendors"][3165] == nil then item["vendors"][3165] = 0 end
    if item["vendors"][3186] == nil then item["vendors"][3186] = 0 end
    if item["vendors"][3313] == nil then item["vendors"][3313] = 0 end
    if item["vendors"][3409] == nil then item["vendors"][3409] = 0 end
    if item["vendors"][3410] == nil then item["vendors"][3410] = 0 end
    if item["vendors"][3481] == nil then item["vendors"][3481] = 0 end
    if item["vendors"][3488] == nil then item["vendors"][3488] = 0 end
    if item["vendors"][3498] == nil then item["vendors"][3498] = 0 end
    if item["vendors"][3587] == nil then item["vendors"][3587] = 0 end
    if item["vendors"][3589] == nil then item["vendors"][3589] = 0 end
    if item["vendors"][3608] == nil then item["vendors"][3608] = 0 end
    if item["vendors"][3610] == nil then item["vendors"][3610] = 0 end
    if item["vendors"][3951] == nil then item["vendors"][3951] = 0 end
    if item["vendors"][4082] == nil then item["vendors"][4082] = 0 end
    if item["vendors"][4084] == nil then item["vendors"][4084] = 0 end
    if item["vendors"][4170] == nil then item["vendors"][4170] = 0 end
    if item["vendors"][4173] == nil then item["vendors"][4173] = 0 end
    if item["vendors"][4182] == nil then item["vendors"][4182] = 0 end
    if item["vendors"][4203] == nil then item["vendors"][4203] = 0 end
    if item["vendors"][4241] == nil then item["vendors"][4241] = 0 end
    if item["vendors"][4555] == nil then item["vendors"][4555] = 0 end
    if item["vendors"][4602] == nil then item["vendors"][4602] = 0 end
    if item["vendors"][4604] == nil then item["vendors"][4604] = 0 end
    if item["vendors"][4892] == nil then item["vendors"][4892] = 0 end
    if item["vendors"][5122] == nil then item["vendors"][5122] = 0 end
    if item["vendors"][6028] == nil then item["vendors"][6028] = 0 end
    if item["vendors"][7942] == nil then item["vendors"][7942] = 0 end
    if item["vendors"][7976] == nil then item["vendors"][7976] = 0 end
    if item["vendors"][8362] == nil then item["vendors"][8362] = 0 end
    if item["vendors"][9548] == nil then item["vendors"][9548] = 0 end
    if item["vendors"][9549] == nil then item["vendors"][9549] = 0 end
    if item["vendors"][9551] == nil then item["vendors"][9551] = 0 end
    if item["vendors"][9552] == nil then item["vendors"][9552] = 0 end
    if item["vendors"][9553] == nil then item["vendors"][9553] = 0 end
    if item["vendors"][9555] == nil then item["vendors"][9555] = 0 end
    if item["vendors"][10369] == nil then item["vendors"][10369] = 0 end
    if item["vendors"][12027] == nil then item["vendors"][12027] = 0 end
    if item["vendors"][12029] == nil then item["vendors"][12029] = 0 end
    if item["vendors"][12960] == nil then item["vendors"][12960] = 0 end
    if item["vendors"][14301] == nil then item["vendors"][14301] = 0 end
    if item["vendors"][17598] == nil then item["vendors"][17598] = 0 end
    if item["vendors"][21002] == nil then item["vendors"][21002] = 0 end
    if item["vendors"][60659] == nil then item["vendors"][60659] = 0 end
    if item["vendors"][61115] == nil then item["vendors"][61115] = 0 end
    if item["vendors"][61443] == nil then item["vendors"][61443] = 0 end
    if item["vendors"][61651] == nil then item["vendors"][61651] = 0 end
    if item["vendors"][61742] == nil then item["vendors"][61742] = 0 end
    if item["vendors"][62086] == nil then item["vendors"][62086] = 0 end
    if item["vendors"][62088] == nil then item["vendors"][62088] = 0 end
    if item["vendors"][62096] == nil then item["vendors"][62096] = 0 end
    if item["vendors"][62307] == nil then item["vendors"][62307] = 0 end
    if item["vendors"][62402] == nil then item["vendors"][62402] = 0 end
    if item["vendors"][62404] == nil then item["vendors"][62404] = 0 end
    if item["vendors"][62409] == nil then item["vendors"][62409] = 0 end
    if item["vendors"][62437] == nil then item["vendors"][62437] = 0 end
    if item["vendors"][62628] == nil then item["vendors"][62628] = 0 end
    if item["vendors"][62739] == nil then item["vendors"][62739] = 0 end
    if item["vendors"][80102] == nil then item["vendors"][80102] = 0 end
    if item["vendors"][80214] == nil then item["vendors"][80214] = 0 end
    if item["vendors"][80267] == nil then item["vendors"][80267] = 0 end
    if item["vendors"][81035] == nil then item["vendors"][81035] = 0 end
    if item["vendors"][91246] == nil then item["vendors"][91246] = 0 end
    if item["vendors"][91248] == nil then item["vendors"][91248] = 0 end
    if item["vendors"][91725] == nil then item["vendors"][91725] = 0 end
    if item["vendors"][91977] == nil then item["vendors"][91977] = 0 end
    if item["vendors"][92169] == nil then item["vendors"][92169] = 0 end
  end
end

do
  local item = MTH_DS_AmmoItems[2515]
  if item then
    if not item["vendors"] then item["vendors"] = {} end
    if item["vendors"][150] == nil then item["vendors"][150] = 0 end
    if item["vendors"][227] == nil then item["vendors"][227] = 0 end
    if item["vendors"][228] == nil then item["vendors"][228] = 0 end
    if item["vendors"][491] == nil then item["vendors"][491] = 0 end
    if item["vendors"][734] == nil then item["vendors"][734] = 0 end
    if item["vendors"][789] == nil then item["vendors"][789] = 0 end
    if item["vendors"][791] == nil then item["vendors"][791] = 0 end
    if item["vendors"][1149] == nil then item["vendors"][1149] = 0 end
    if item["vendors"][1198] == nil then item["vendors"][1198] = 0 end
    if item["vendors"][1285] == nil then item["vendors"][1285] = 0 end
    if item["vendors"][1287] == nil then item["vendors"][1287] = 0 end
    if item["vendors"][1297] == nil then item["vendors"][1297] = 0 end
    if item["vendors"][1298] == nil then item["vendors"][1298] = 0 end
    if item["vendors"][1448] == nil then item["vendors"][1448] = 0 end
    if item["vendors"][1452] == nil then item["vendors"][1452] = 0 end
    if item["vendors"][1455] == nil then item["vendors"][1455] = 0 end
    if item["vendors"][1459] == nil then item["vendors"][1459] = 0 end
    if item["vendors"][1462] == nil then item["vendors"][1462] = 0 end
    if item["vendors"][1668] == nil then item["vendors"][1668] = 0 end
    if item["vendors"][1682] == nil then item["vendors"][1682] = 0 end
    if item["vendors"][1685] == nil then item["vendors"][1685] = 0 end
    if item["vendors"][1687] == nil then item["vendors"][1687] = 0 end
    if item["vendors"][1859] == nil then item["vendors"][1859] = 0 end
    if item["vendors"][2084] == nil then item["vendors"][2084] = 0 end
    if item["vendors"][2140] == nil then item["vendors"][2140] = 0 end
    if item["vendors"][2286] == nil then item["vendors"][2286] = 0 end
    if item["vendors"][2401] == nil then item["vendors"][2401] = 0 end
    if item["vendors"][2803] == nil then item["vendors"][2803] = 0 end
    if item["vendors"][2806] == nil then item["vendors"][2806] = 0 end
    if item["vendors"][2808] == nil then item["vendors"][2808] = 0 end
    if item["vendors"][2820] == nil then item["vendors"][2820] = 0 end
    if item["vendors"][2839] == nil then item["vendors"][2839] = 0 end
    if item["vendors"][2908] == nil then item["vendors"][2908] = 0 end
    if item["vendors"][3015] == nil then item["vendors"][3015] = 0 end
    if item["vendors"][3165] == nil then item["vendors"][3165] = 0 end
    if item["vendors"][3313] == nil then item["vendors"][3313] = 0 end
    if item["vendors"][3350] == nil then item["vendors"][3350] = 0 end
    if item["vendors"][3409] == nil then item["vendors"][3409] = 0 end
    if item["vendors"][3410] == nil then item["vendors"][3410] = 0 end
    if item["vendors"][3481] == nil then item["vendors"][3481] = 0 end
    if item["vendors"][3488] == nil then item["vendors"][3488] = 0 end
    if item["vendors"][3498] == nil then item["vendors"][3498] = 0 end
    if item["vendors"][3541] == nil then item["vendors"][3541] = 0 end
    if item["vendors"][3589] == nil then item["vendors"][3589] = 0 end
    if item["vendors"][3610] == nil then item["vendors"][3610] = 0 end
    if item["vendors"][3625] == nil then item["vendors"][3625] = 0 end
    if item["vendors"][3951] == nil then item["vendors"][3951] = 0 end
    if item["vendors"][3962] == nil then item["vendors"][3962] = 0 end
    if item["vendors"][4082] == nil then item["vendors"][4082] = 0 end
    if item["vendors"][4084] == nil then item["vendors"][4084] = 0 end
    if item["vendors"][4170] == nil then item["vendors"][4170] = 0 end
    if item["vendors"][4173] == nil then item["vendors"][4173] = 0 end
    if item["vendors"][4182] == nil then item["vendors"][4182] = 0 end
    if item["vendors"][4203] == nil then item["vendors"][4203] = 0 end
    if item["vendors"][4241] == nil then item["vendors"][4241] = 0 end
    if item["vendors"][4555] == nil then item["vendors"][4555] = 0 end
    if item["vendors"][4602] == nil then item["vendors"][4602] = 0 end
    if item["vendors"][4604] == nil then item["vendors"][4604] = 0 end
    if item["vendors"][4876] == nil then item["vendors"][4876] = 0 end
    if item["vendors"][4892] == nil then item["vendors"][4892] = 0 end
    if item["vendors"][4896] == nil then item["vendors"][4896] = 0 end
    if item["vendors"][5101] == nil then item["vendors"][5101] = 0 end
    if item["vendors"][5122] == nil then item["vendors"][5122] = 0 end
    if item["vendors"][5134] == nil then item["vendors"][5134] = 0 end
    if item["vendors"][6028] == nil then item["vendors"][6028] = 0 end
    if item["vendors"][7942] == nil then item["vendors"][7942] = 0 end
    if item["vendors"][7976] == nil then item["vendors"][7976] = 0 end
    if item["vendors"][8139] == nil then item["vendors"][8139] = 0 end
    if item["vendors"][8362] == nil then item["vendors"][8362] = 0 end
    if item["vendors"][9320] == nil then item["vendors"][9320] = 0 end
    if item["vendors"][9548] == nil then item["vendors"][9548] = 0 end
    if item["vendors"][9549] == nil then item["vendors"][9549] = 0 end
    if item["vendors"][9551] == nil then item["vendors"][9551] = 0 end
    if item["vendors"][9552] == nil then item["vendors"][9552] = 0 end
    if item["vendors"][9553] == nil then item["vendors"][9553] = 0 end
    if item["vendors"][9555] == nil then item["vendors"][9555] = 0 end
    if item["vendors"][10369] == nil then item["vendors"][10369] = 0 end
    if item["vendors"][11038] == nil then item["vendors"][11038] = 0 end
    if item["vendors"][11555] == nil then item["vendors"][11555] = 0 end
    if item["vendors"][12021] == nil then item["vendors"][12021] = 0 end
    if item["vendors"][12027] == nil then item["vendors"][12027] = 0 end
    if item["vendors"][12029] == nil then item["vendors"][12029] = 0 end
    if item["vendors"][12036] == nil then item["vendors"][12036] = 0 end
    if item["vendors"][12246] == nil then item["vendors"][12246] = 0 end
    if item["vendors"][12959] == nil then item["vendors"][12959] = 0 end
    if item["vendors"][12960] == nil then item["vendors"][12960] = 0 end
    if item["vendors"][14301] == nil then item["vendors"][14301] = 0 end
    if item["vendors"][14624] == nil then item["vendors"][14624] = 0 end
    if item["vendors"][15174] == nil then item["vendors"][15174] = 0 end
    if item["vendors"][17598] == nil then item["vendors"][17598] = 0 end
    if item["vendors"][21002] == nil then item["vendors"][21002] = 0 end
    if item["vendors"][51656] == nil then item["vendors"][51656] = 0 end
    if item["vendors"][60456] == nil then item["vendors"][60456] = 0 end
    if item["vendors"][60641] == nil then item["vendors"][60641] = 0 end
    if item["vendors"][60646] == nil then item["vendors"][60646] = 0 end
    if item["vendors"][60653] == nil then item["vendors"][60653] = 0 end
    if item["vendors"][60659] == nil then item["vendors"][60659] = 0 end
    if item["vendors"][60663] == nil then item["vendors"][60663] = 0 end
    if item["vendors"][60740] == nil then item["vendors"][60740] = 0 end
    if item["vendors"][60766] == nil then item["vendors"][60766] = 0 end
    if item["vendors"][60790] == nil then item["vendors"][60790] = 0 end
    if item["vendors"][60803] == nil then item["vendors"][60803] = 0 end
    if item["vendors"][60813] == nil then item["vendors"][60813] = 0 end
    if item["vendors"][60966] == nil then item["vendors"][60966] = 0 end
    if item["vendors"][60989] == nil then item["vendors"][60989] = 0 end
    if item["vendors"][61058] == nil then item["vendors"][61058] = 0 end
    if item["vendors"][61115] == nil then item["vendors"][61115] = 0 end
    if item["vendors"][61140] == nil then item["vendors"][61140] = 0 end
    if item["vendors"][61272] == nil then item["vendors"][61272] = 0 end
    if item["vendors"][61288] == nil then item["vendors"][61288] = 0 end
    if item["vendors"][61369] == nil then item["vendors"][61369] = 0 end
    if item["vendors"][61440] == nil then item["vendors"][61440] = 0 end
    if item["vendors"][61443] == nil then item["vendors"][61443] = 0 end
    if item["vendors"][61478] == nil then item["vendors"][61478] = 0 end
    if item["vendors"][61523] == nil then item["vendors"][61523] = 0 end
    if item["vendors"][61563] == nil then item["vendors"][61563] = 0 end
    if item["vendors"][61651] == nil then item["vendors"][61651] = 0 end
    if item["vendors"][61742] == nil then item["vendors"][61742] = 0 end
    if item["vendors"][61743] == nil then item["vendors"][61743] = 0 end
    if item["vendors"][61812] == nil then item["vendors"][61812] = 0 end
    if item["vendors"][62086] == nil then item["vendors"][62086] = 0 end
    if item["vendors"][62088] == nil then item["vendors"][62088] = 0 end
    if item["vendors"][62096] == nil then item["vendors"][62096] = 0 end
    if item["vendors"][62148] == nil then item["vendors"][62148] = 0 end
    if item["vendors"][62307] == nil then item["vendors"][62307] = 0 end
    if item["vendors"][62402] == nil then item["vendors"][62402] = 0 end
    if item["vendors"][62404] == nil then item["vendors"][62404] = 0 end
    if item["vendors"][62409] == nil then item["vendors"][62409] = 0 end
    if item["vendors"][62436] == nil then item["vendors"][62436] = 0 end
    if item["vendors"][62437] == nil then item["vendors"][62437] = 0 end
    if item["vendors"][62462] == nil then item["vendors"][62462] = 0 end
    if item["vendors"][62469] == nil then item["vendors"][62469] = 0 end
    if item["vendors"][62628] == nil then item["vendors"][62628] = 0 end
    if item["vendors"][62739] == nil then item["vendors"][62739] = 0 end
    if item["vendors"][65002] == nil then item["vendors"][65002] = 0 end
    if item["vendors"][65003] == nil then item["vendors"][65003] = 0 end
    if item["vendors"][80267] == nil then item["vendors"][80267] = 0 end
    if item["vendors"][80808] == nil then item["vendors"][80808] = 0 end
    if item["vendors"][81035] == nil then item["vendors"][81035] = 0 end
    if item["vendors"][91246] == nil then item["vendors"][91246] = 0 end
    if item["vendors"][91403] == nil then item["vendors"][91403] = 0 end
    if item["vendors"][91725] == nil then item["vendors"][91725] = 0 end
    if item["vendors"][91868] == nil then item["vendors"][91868] = 0 end
    if item["vendors"][91956] == nil then item["vendors"][91956] = 0 end
    if item["vendors"][91977] == nil then item["vendors"][91977] = 0 end
    if item["vendors"][92169] == nil then item["vendors"][92169] = 0 end
    if item["vendors"][92177] == nil then item["vendors"][92177] = 0 end
    if item["vendors"][92200] == nil then item["vendors"][92200] = 0 end
  end
end

do
  local item = MTH_DS_AmmoItems[2516]
  if item then
    if not item["vendors"] then item["vendors"] = {} end
    if item["vendors"][151] == nil then item["vendors"][151] = 0 end
    if item["vendors"][152] == nil then item["vendors"][152] = 0 end
    if item["vendors"][491] == nil then item["vendors"][491] = 0 end
    if item["vendors"][791] == nil then item["vendors"][791] = 0 end
    if item["vendors"][829] == nil then item["vendors"][829] = 0 end
    if item["vendors"][904] == nil then item["vendors"][904] = 0 end
    if item["vendors"][1243] == nil then item["vendors"][1243] = 0 end
    if item["vendors"][1250] == nil then item["vendors"][1250] = 0 end
    if item["vendors"][1285] == nil then item["vendors"][1285] = 0 end
    if item["vendors"][1297] == nil then item["vendors"][1297] = 0 end
    if item["vendors"][1461] == nil then item["vendors"][1461] = 0 end
    if item["vendors"][1469] == nil then item["vendors"][1469] = 0 end
    if item["vendors"][1682] == nil then item["vendors"][1682] = 0 end
    if item["vendors"][1685] == nil then item["vendors"][1685] = 0 end
    if item["vendors"][1686] == nil then item["vendors"][1686] = 0 end
    if item["vendors"][1691] == nil then item["vendors"][1691] = 0 end
    if item["vendors"][2115] == nil then item["vendors"][2115] = 0 end
    if item["vendors"][2134] == nil then item["vendors"][2134] = 0 end
    if item["vendors"][2140] == nil then item["vendors"][2140] = 0 end
    if item["vendors"][2685] == nil then item["vendors"][2685] = 0 end
    if item["vendors"][2997] == nil then item["vendors"][2997] = 0 end
    if item["vendors"][3018] == nil then item["vendors"][3018] = 0 end
    if item["vendors"][3053] == nil then item["vendors"][3053] = 0 end
    if item["vendors"][3072] == nil then item["vendors"][3072] = 0 end
    if item["vendors"][3076] == nil then item["vendors"][3076] = 0 end
    if item["vendors"][3078] == nil then item["vendors"][3078] = 0 end
    if item["vendors"][3088] == nil then item["vendors"][3088] = 0 end
    if item["vendors"][3158] == nil then item["vendors"][3158] = 0 end
    if item["vendors"][3164] == nil then item["vendors"][3164] = 0 end
    if item["vendors"][3186] == nil then item["vendors"][3186] = 0 end
    if item["vendors"][3313] == nil then item["vendors"][3313] = 0 end
    if item["vendors"][3322] == nil then item["vendors"][3322] = 0 end
    if item["vendors"][3481] == nil then item["vendors"][3481] = 0 end
    if item["vendors"][3488] == nil then item["vendors"][3488] = 0 end
    if item["vendors"][3498] == nil then item["vendors"][3498] = 0 end
    if item["vendors"][3587] == nil then item["vendors"][3587] = 0 end
    if item["vendors"][3608] == nil then item["vendors"][3608] = 0 end
    if item["vendors"][4082] == nil then item["vendors"][4082] = 0 end
    if item["vendors"][4084] == nil then item["vendors"][4084] = 0 end
    if item["vendors"][4170] == nil then item["vendors"][4170] = 0 end
    if item["vendors"][4182] == nil then item["vendors"][4182] = 0 end
    if item["vendors"][4241] == nil then item["vendors"][4241] = 0 end
    if item["vendors"][4555] == nil then item["vendors"][4555] = 0 end
    if item["vendors"][4603] == nil then item["vendors"][4603] = 0 end
    if item["vendors"][4889] == nil then item["vendors"][4889] = 0 end
    if item["vendors"][5123] == nil then item["vendors"][5123] = 0 end
    if item["vendors"][5510] == nil then item["vendors"][5510] = 0 end
    if item["vendors"][6028] == nil then item["vendors"][6028] = 0 end
    if item["vendors"][7942] == nil then item["vendors"][7942] = 0 end
    if item["vendors"][7976] == nil then item["vendors"][7976] = 0 end
    if item["vendors"][8131] == nil then item["vendors"][8131] = 0 end
    if item["vendors"][8362] == nil then item["vendors"][8362] = 0 end
    if item["vendors"][9548] == nil then item["vendors"][9548] = 0 end
    if item["vendors"][9551] == nil then item["vendors"][9551] = 0 end
    if item["vendors"][11184] == nil then item["vendors"][11184] = 0 end
    if item["vendors"][12027] == nil then item["vendors"][12027] = 0 end
    if item["vendors"][12960] == nil then item["vendors"][12960] = 0 end
    if item["vendors"][21002] == nil then item["vendors"][21002] = 0 end
    if item["vendors"][61445] == nil then item["vendors"][61445] = 0 end
    if item["vendors"][61651] == nil then item["vendors"][61651] = 0 end
    if item["vendors"][61743] == nil then item["vendors"][61743] = 0 end
    if item["vendors"][61751] == nil then item["vendors"][61751] = 0 end
    if item["vendors"][62086] == nil then item["vendors"][62086] = 0 end
    if item["vendors"][62096] == nil then item["vendors"][62096] = 0 end
    if item["vendors"][62402] == nil then item["vendors"][62402] = 0 end
    if item["vendors"][62403] == nil then item["vendors"][62403] = 0 end
    if item["vendors"][62409] == nil then item["vendors"][62409] = 0 end
    if item["vendors"][62628] == nil then item["vendors"][62628] = 0 end
    if item["vendors"][80102] == nil then item["vendors"][80102] = 0 end
    if item["vendors"][80214] == nil then item["vendors"][80214] = 0 end
    if item["vendors"][80267] == nil then item["vendors"][80267] = 0 end
    if item["vendors"][91248] == nil then item["vendors"][91248] = 0 end
    if item["vendors"][91725] == nil then item["vendors"][91725] = 0 end
    if item["vendors"][92169] == nil then item["vendors"][92169] = 0 end
    if item["vendors"][92217] == nil then item["vendors"][92217] = 0 end
  end
end

do
  local item = MTH_DS_AmmoItems[2519]
  if item then
    if not item["vendors"] then item["vendors"] = {} end
    if item["vendors"][227] == nil then item["vendors"][227] = 0 end
    if item["vendors"][491] == nil then item["vendors"][491] = 0 end
    if item["vendors"][734] == nil then item["vendors"][734] = 0 end
    if item["vendors"][791] == nil then item["vendors"][791] = 0 end
    if item["vendors"][904] == nil then item["vendors"][904] = 0 end
    if item["vendors"][1149] == nil then item["vendors"][1149] = 0 end
    if item["vendors"][1243] == nil then item["vendors"][1243] = 0 end
    if item["vendors"][1285] == nil then item["vendors"][1285] = 0 end
    if item["vendors"][1297] == nil then item["vendors"][1297] = 0 end
    if item["vendors"][1448] == nil then item["vendors"][1448] = 0 end
    if item["vendors"][1452] == nil then item["vendors"][1452] = 0 end
    if item["vendors"][1461] == nil then item["vendors"][1461] = 0 end
    if item["vendors"][1469] == nil then item["vendors"][1469] = 0 end
    if item["vendors"][1682] == nil then item["vendors"][1682] = 0 end
    if item["vendors"][1685] == nil then item["vendors"][1685] = 0 end
    if item["vendors"][1686] == nil then item["vendors"][1686] = 0 end
    if item["vendors"][2084] == nil then item["vendors"][2084] = 0 end
    if item["vendors"][2140] == nil then item["vendors"][2140] = 0 end
    if item["vendors"][2401] == nil then item["vendors"][2401] = 0 end
    if item["vendors"][2685] == nil then item["vendors"][2685] = 0 end
    if item["vendors"][2803] == nil then item["vendors"][2803] = 0 end
    if item["vendors"][2806] == nil then item["vendors"][2806] = 0 end
    if item["vendors"][2808] == nil then item["vendors"][2808] = 0 end
    if item["vendors"][2820] == nil then item["vendors"][2820] = 0 end
    if item["vendors"][2908] == nil then item["vendors"][2908] = 0 end
    if item["vendors"][2997] == nil then item["vendors"][2997] = 0 end
    if item["vendors"][3018] == nil then item["vendors"][3018] = 0 end
    if item["vendors"][3053] == nil then item["vendors"][3053] = 0 end
    if item["vendors"][3078] == nil then item["vendors"][3078] = 0 end
    if item["vendors"][3088] == nil then item["vendors"][3088] = 0 end
    if item["vendors"][3313] == nil then item["vendors"][3313] = 0 end
    if item["vendors"][3322] == nil then item["vendors"][3322] = 0 end
    if item["vendors"][3350] == nil then item["vendors"][3350] = 0 end
    if item["vendors"][3481] == nil then item["vendors"][3481] = 0 end
    if item["vendors"][3488] == nil then item["vendors"][3488] = 0 end
    if item["vendors"][3498] == nil then item["vendors"][3498] = 0 end
    if item["vendors"][3541] == nil then item["vendors"][3541] = 0 end
    if item["vendors"][3625] == nil then item["vendors"][3625] = 0 end
    if item["vendors"][3962] == nil then item["vendors"][3962] = 0 end
    if item["vendors"][4082] == nil then item["vendors"][4082] = 0 end
    if item["vendors"][4084] == nil then item["vendors"][4084] = 0 end
    if item["vendors"][4170] == nil then item["vendors"][4170] = 0 end
    if item["vendors"][4182] == nil then item["vendors"][4182] = 0 end
    if item["vendors"][4241] == nil then item["vendors"][4241] = 0 end
    if item["vendors"][4555] == nil then item["vendors"][4555] = 0 end
    if item["vendors"][4603] == nil then item["vendors"][4603] = 0 end
    if item["vendors"][4876] == nil then item["vendors"][4876] = 0 end
    if item["vendors"][4889] == nil then item["vendors"][4889] = 0 end
    if item["vendors"][4896] == nil then item["vendors"][4896] = 0 end
    if item["vendors"][5101] == nil then item["vendors"][5101] = 0 end
    if item["vendors"][5123] == nil then item["vendors"][5123] = 0 end
    if item["vendors"][5134] == nil then item["vendors"][5134] = 0 end
    if item["vendors"][5510] == nil then item["vendors"][5510] = 0 end
    if item["vendors"][6028] == nil then item["vendors"][6028] = 0 end
    if item["vendors"][7942] == nil then item["vendors"][7942] = 0 end
    if item["vendors"][7976] == nil then item["vendors"][7976] = 0 end
    if item["vendors"][8131] == nil then item["vendors"][8131] = 0 end
    if item["vendors"][8139] == nil then item["vendors"][8139] = 0 end
    if item["vendors"][8362] == nil then item["vendors"][8362] = 0 end
    if item["vendors"][9320] == nil then item["vendors"][9320] = 0 end
    if item["vendors"][9548] == nil then item["vendors"][9548] = 0 end
    if item["vendors"][9551] == nil then item["vendors"][9551] = 0 end
    if item["vendors"][11038] == nil then item["vendors"][11038] = 0 end
    if item["vendors"][11184] == nil then item["vendors"][11184] = 0 end
    if item["vendors"][11555] == nil then item["vendors"][11555] = 0 end
    if item["vendors"][12021] == nil then item["vendors"][12021] = 0 end
    if item["vendors"][12027] == nil then item["vendors"][12027] = 0 end
    if item["vendors"][12036] == nil then item["vendors"][12036] = 0 end
    if item["vendors"][12246] == nil then item["vendors"][12246] = 0 end
    if item["vendors"][12959] == nil then item["vendors"][12959] = 0 end
    if item["vendors"][12960] == nil then item["vendors"][12960] = 0 end
    if item["vendors"][14624] == nil then item["vendors"][14624] = 0 end
    if item["vendors"][15174] == nil then item["vendors"][15174] = 0 end
    if item["vendors"][21002] == nil then item["vendors"][21002] = 0 end
    if item["vendors"][51656] == nil then item["vendors"][51656] = 0 end
    if item["vendors"][60456] == nil then item["vendors"][60456] = 0 end
    if item["vendors"][60641] == nil then item["vendors"][60641] = 0 end
    if item["vendors"][60646] == nil then item["vendors"][60646] = 0 end
    if item["vendors"][60653] == nil then item["vendors"][60653] = 0 end
    if item["vendors"][60663] == nil then item["vendors"][60663] = 0 end
    if item["vendors"][60740] == nil then item["vendors"][60740] = 0 end
    if item["vendors"][60766] == nil then item["vendors"][60766] = 0 end
    if item["vendors"][60790] == nil then item["vendors"][60790] = 0 end
    if item["vendors"][60813] == nil then item["vendors"][60813] = 0 end
    if item["vendors"][60966] == nil then item["vendors"][60966] = 0 end
    if item["vendors"][60989] == nil then item["vendors"][60989] = 0 end
    if item["vendors"][61058] == nil then item["vendors"][61058] = 0 end
    if item["vendors"][61115] == nil then item["vendors"][61115] = 0 end
    if item["vendors"][61140] == nil then item["vendors"][61140] = 0 end
    if item["vendors"][61272] == nil then item["vendors"][61272] = 0 end
    if item["vendors"][61288] == nil then item["vendors"][61288] = 0 end
    if item["vendors"][61369] == nil then item["vendors"][61369] = 0 end
    if item["vendors"][61440] == nil then item["vendors"][61440] = 0 end
    if item["vendors"][61443] == nil then item["vendors"][61443] = 0 end
    if item["vendors"][61445] == nil then item["vendors"][61445] = 0 end
    if item["vendors"][61478] == nil then item["vendors"][61478] = 0 end
    if item["vendors"][61523] == nil then item["vendors"][61523] = 0 end
    if item["vendors"][61563] == nil then item["vendors"][61563] = 0 end
    if item["vendors"][61651] == nil then item["vendors"][61651] = 0 end
    if item["vendors"][61743] == nil then item["vendors"][61743] = 0 end
    if item["vendors"][61751] == nil then item["vendors"][61751] = 0 end
    if item["vendors"][61812] == nil then item["vendors"][61812] = 0 end
    if item["vendors"][62086] == nil then item["vendors"][62086] = 0 end
    if item["vendors"][62096] == nil then item["vendors"][62096] = 0 end
    if item["vendors"][62148] == nil then item["vendors"][62148] = 0 end
    if item["vendors"][62402] == nil then item["vendors"][62402] = 0 end
    if item["vendors"][62403] == nil then item["vendors"][62403] = 0 end
    if item["vendors"][62404] == nil then item["vendors"][62404] = 0 end
    if item["vendors"][62409] == nil then item["vendors"][62409] = 0 end
    if item["vendors"][62436] == nil then item["vendors"][62436] = 0 end
    if item["vendors"][62437] == nil then item["vendors"][62437] = 0 end
    if item["vendors"][62462] == nil then item["vendors"][62462] = 0 end
    if item["vendors"][62469] == nil then item["vendors"][62469] = 0 end
    if item["vendors"][62628] == nil then item["vendors"][62628] = 0 end
    if item["vendors"][65002] == nil then item["vendors"][65002] = 0 end
    if item["vendors"][65003] == nil then item["vendors"][65003] = 0 end
    if item["vendors"][80267] == nil then item["vendors"][80267] = 0 end
    if item["vendors"][80808] == nil then item["vendors"][80808] = 0 end
    if item["vendors"][91403] == nil then item["vendors"][91403] = 0 end
    if item["vendors"][91725] == nil then item["vendors"][91725] = 0 end
    if item["vendors"][91868] == nil then item["vendors"][91868] = 0 end
    if item["vendors"][91956] == nil then item["vendors"][91956] = 0 end
    if item["vendors"][92169] == nil then item["vendors"][92169] = 0 end
    if item["vendors"][92177] == nil then item["vendors"][92177] = 0 end
    if item["vendors"][92200] == nil then item["vendors"][92200] = 0 end
    if item["vendors"][92217] == nil then item["vendors"][92217] = 0 end
  end
end

do
  local item = MTH_DS_AmmoItems[2550]
  if not item then
    item = {}
    MTH_DS_AmmoItems[2550] = item
  end
  if not item["name"] then item["name"] = 'Monster - Bow, Short' end
  if not item["level"] then item["level"] = 1 end
  if not item["reqlevel"] then item["reqlevel"] = 1 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_05' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 6 end
  if not item["dps"] then item["dps"] = 0.8 end
  if not item["speed"] then item["speed"] = 2 end
end

do
  local item = MTH_DS_AmmoItems[2551]
  if not item then
    item = {}
    MTH_DS_AmmoItems[2551] = item
  end
  if not item["name"] then item["name"] = 'Monster - Crossbow' end
  if not item["level"] then item["level"] = 1 end
  if not item["reqlevel"] then item["reqlevel"] = 1 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Crossbow_02' end
  if not item["subtype"] then item["subtype"] = 'crossbow' end
  if not item["quality"] then item["quality"] = 6 end
  if not item["dps"] then item["dps"] = 0.8 end
  if not item["speed"] then item["speed"] = 2 end
end

do
  local item = MTH_DS_AmmoItems[2552]
  if not item then
    item = {}
    MTH_DS_AmmoItems[2552] = item
  end
  if not item["name"] then item["name"] = 'Monster - Gun' end
  if not item["level"] then item["level"] = 1 end
  if not item["reqlevel"] then item["reqlevel"] = 1 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_03' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 6 end
  if not item["dps"] then item["dps"] = 0.8 end
  if not item["speed"] then item["speed"] = 2 end
end

do
  local item = MTH_DS_AmmoItems[2773]
  if not item then
    item = {}
    MTH_DS_AmmoItems[2773] = item
  end
  if not item["name"] then item["name"] = 'Cracked Shortbow' end
  if not item["level"] then item["level"] = 8 end
  if not item["reqlevel"] then item["reqlevel"] = 3 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_05' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 6 end
  if not item["dps"] then item["dps"] = 2 end
  if not item["speed"] then item["speed"] = 2.3 end
  if not item["drops"] then item["drops"] = {} end
  if item["drops"][1769] == nil then item["drops"][1769] = 1.42 end
  if item["drops"][2965] == nil then item["drops"][2965] = 0.39 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][2039] == nil then item["objects"][2039] = 2.32 end
end

do
  local item = MTH_DS_AmmoItems[2774]
  if not item then
    item = {}
    MTH_DS_AmmoItems[2774] = item
  end
  if not item["name"] then item["name"] = 'Rust-covered Blunderbuss' end
  if not item["level"] then item["level"] = 7 end
  if not item["reqlevel"] then item["reqlevel"] = 2 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_03' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 6 end
  if not item["dps"] then item["dps"] = 1.9 end
  if not item["speed"] then item["speed"] = 2.4 end
end

do
  local item = MTH_DS_AmmoItems[2777]
  if not item then
    item = {}
    MTH_DS_AmmoItems[2777] = item
  end
  if not item["name"] then item["name"] = 'Feeble Shortbow' end
  if not item["level"] then item["level"] = 13 end
  if not item["reqlevel"] then item["reqlevel"] = 8 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_05' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 6 end
  if not item["dps"] then item["dps"] = 3.3 end
  if not item["speed"] then item["speed"] = 1.8 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][2039] == nil then item["objects"][2039] = 0.62 end
end

do
  local item = MTH_DS_AmmoItems[2778]
  if not item then
    item = {}
    MTH_DS_AmmoItems[2778] = item
  end
  if not item["name"] then item["name"] = 'Cheap Blunderbuss' end
  if not item["level"] then item["level"] = 13 end
  if not item["reqlevel"] then item["reqlevel"] = 8 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_03' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 6 end
  if not item["dps"] then item["dps"] = 3.2 end
  if not item["speed"] then item["speed"] = 2.2 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][2039] == nil then item["objects"][2039] = 0.72 end
end

do
  local item = MTH_DS_AmmoItems[2780]
  if not item then
    item = {}
    MTH_DS_AmmoItems[2780] = item
  end
  if not item["name"] then item["name"] = 'Light Hunting Bow' end
  if not item["level"] then item["level"] = 19 end
  if not item["reqlevel"] then item["reqlevel"] = 14 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_02' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 6 end
  if not item["dps"] then item["dps"] = 4.4 end
  if not item["speed"] then item["speed"] = 1.7 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][3642] == nil then item["objects"][3642] = 4.4 end
  if item["objects"][152608] == nil then item["objects"][152608] = 4.4 end
  if item["objects"][152618] == nil then item["objects"][152618] = 4.4 end
end

do
  local item = MTH_DS_AmmoItems[2781]
  if not item then
    item = {}
    MTH_DS_AmmoItems[2781] = item
  end
  if not item["name"] then item["name"] = 'Dirty Blunderbuss' end
  if not item["level"] then item["level"] = 18 end
  if not item["reqlevel"] then item["reqlevel"] = 13 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_01' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 6 end
  if not item["dps"] then item["dps"] = 4.1 end
  if not item["speed"] then item["speed"] = 2.2 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][3642] == nil then item["objects"][3642] = 3.3 end
  if item["objects"][152608] == nil then item["objects"][152608] = 3.3 end
  if item["objects"][152618] == nil then item["objects"][152618] = 3.3 end
end

do
  local item = MTH_DS_AmmoItems[2782]
  if not item then
    item = {}
    MTH_DS_AmmoItems[2782] = item
  end
  if not item["name"] then item["name"] = 'Mishandled Recurve Bow' end
  if not item["level"] then item["level"] = 24 end
  if not item["reqlevel"] then item["reqlevel"] = 19 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_03' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 6 end
  if not item["dps"] then item["dps"] = 5.6 end
  if not item["speed"] then item["speed"] = 2.4 end
  if not item["drops"] then item["drops"] = {} end
  if item["drops"][4279] == nil then item["drops"][4279] = 0.32 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][153462] == nil then item["objects"][153462] = 0.12 end
end

do
  local item = MTH_DS_AmmoItems[2783]
  if not item then
    item = {}
    MTH_DS_AmmoItems[2783] = item
  end
  if not item["name"] then item["name"] = 'Shoddy Blunderbuss' end
  if not item["level"] then item["level"] = 22 end
  if not item["reqlevel"] then item["reqlevel"] = 17 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_01' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 6 end
  if not item["dps"] then item["dps"] = 5 end
  if not item["speed"] then item["speed"] = 2.1 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][153462] == nil then item["objects"][153462] = 0.14 end
end

do
  local item = MTH_DS_AmmoItems[2785]
  if not item then
    item = {}
    MTH_DS_AmmoItems[2785] = item
  end
  if not item["name"] then item["name"] = 'Stiff Recurve Bow' end
  if not item["level"] then item["level"] = 28 end
  if not item["reqlevel"] then item["reqlevel"] = 23 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_05' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 6 end
  if not item["dps"] then item["dps"] = 6.8 end
  if not item["speed"] then item["speed"] = 2.8 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][153462] == nil then item["objects"][153462] = 0.03 end
end

do
  local item = MTH_DS_AmmoItems[2786]
  if not item then
    item = {}
    MTH_DS_AmmoItems[2786] = item
  end
  if not item["name"] then item["name"] = 'Oiled Blunderbuss' end
  if not item["level"] then item["level"] = 29 end
  if not item["reqlevel"] then item["reqlevel"] = 24 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_01' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 6 end
  if not item["dps"] then item["dps"] = 7 end
  if not item["speed"] then item["speed"] = 2 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][153462] == nil then item["objects"][153462] = 0.03 end
end

do
  local item = MTH_DS_AmmoItems[2824]
  if not item then
    item = {}
    MTH_DS_AmmoItems[2824] = item
  end
  if not item["name"] then item["name"] = 'Hurricane' end
  if not item["level"] then item["level"] = 53 end
  if not item["reqlevel"] then item["reqlevel"] = 48 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_12' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 2 end
  if not item["dps"] then item["dps"] = 30.3 end
  if not item["speed"] then item["speed"] = 1.6 end
end

do
  local item = MTH_DS_AmmoItems[2825]
  if not item then
    item = {}
    MTH_DS_AmmoItems[2825] = item
  end
  if not item["name"] then item["name"] = 'Bow of Searing Arrows' end
  if not item["level"] then item["level"] = 42 end
  if not item["reqlevel"] then item["reqlevel"] = 37 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_09' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 2 end
  if not item["dps"] then item["dps"] = 25 end
  if not item["speed"] then item["speed"] = 2.7 end
end

do
  local item = MTH_DS_AmmoItems[2903]
  if not item then
    item = {}
    MTH_DS_AmmoItems[2903] = item
  end
  if not item["name"] then item["name"] = "Daryl's Hunting Bow" end
  if not item["level"] then item["level"] = 15 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_02' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 5.9 end
  if not item["speed"] then item["speed"] = 2.3 end
end

do
  local item = MTH_DS_AmmoItems[2904]
  if not item then
    item = {}
    MTH_DS_AmmoItems[2904] = item
  end
  if not item["name"] then item["name"] = "Daryl's Hunting Rifle" end
  if not item["level"] then item["level"] = 16 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_03' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 6.4 end
  if not item["speed"] then item["speed"] = 2.5 end
end

do
  local item = MTH_DS_AmmoItems[3021]
  if not item then
    item = {}
    MTH_DS_AmmoItems[3021] = item
  end
  if not item["name"] then item["name"] = 'Ranger Bow' end
  if not item["level"] then item["level"] = 25 end
  if not item["reqlevel"] then item["reqlevel"] = 20 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_11' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 12.6 end
  if not item["speed"] then item["speed"] = 2.7 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][2849] == nil then item["objects"][2849] = 0.01 end
  if item["objects"][2850] == nil then item["objects"][2850] = 0.01 end
  if item["objects"][2852] == nil then item["objects"][2852] = 0.01 end
  if item["objects"][2855] == nil then item["objects"][2855] = 0.01 end
  if item["objects"][3714] == nil then item["objects"][3714] = 0.01 end
  if item["objects"][3715] == nil then item["objects"][3715] = 0.01 end
  if item["objects"][4095] == nil then item["objects"][4095] = 0.01 end
  if item["objects"][4096] == nil then item["objects"][4096] = 0.01 end
  if item["objects"][74447] == nil then item["objects"][74447] = 0.01 end
  if item["objects"][74448] == nil then item["objects"][74448] = 0.01 end
  if item["objects"][75295] == nil then item["objects"][75295] = 0.01 end
  if item["objects"][75296] == nil then item["objects"][75296] = 0.01 end
  if item["objects"][75297] == nil then item["objects"][75297] = 0.01 end
  if item["objects"][75298] == nil then item["objects"][75298] = 0.01 end
  if item["objects"][75299] == nil then item["objects"][75299] = 0.01 end
  if item["objects"][75300] == nil then item["objects"][75300] = 0.01 end
  if item["objects"][105570] == nil then item["objects"][105570] = 0.01 end
  if item["objects"][105578] == nil then item["objects"][105578] = 0.01 end
  if item["objects"][105579] == nil then item["objects"][105579] = 0.01 end
  if item["objects"][106319] == nil then item["objects"][106319] = 0.01 end
  if item["objects"][111095] == nil then item["objects"][111095] = 0.01 end
  if item["objects"][153462] == nil then item["objects"][153462] = 0.01 end
end

do
  local item = MTH_DS_AmmoItems[3023]
  if not item then
    item = {}
    MTH_DS_AmmoItems[3023] = item
  end
  if not item["name"] then item["name"] = 'Large Bore Blunderbuss' end
  if not item["level"] then item["level"] = 21 end
  if not item["reqlevel"] then item["reqlevel"] = 16 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_03' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 5 end
  if not item["dps"] then item["dps"] = 7.4 end
  if not item["speed"] then item["speed"] = 2.5 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][1297] == nil then item["vendors"][1297] = 0 end
  if item["vendors"][1461] == nil then item["vendors"][1461] = 0 end
  if item["vendors"][1686] == nil then item["vendors"][1686] = 0 end
  if item["vendors"][3018] == nil then item["vendors"][3018] = 0 end
  if item["vendors"][3053] == nil then item["vendors"][3053] = 0 end
  if item["vendors"][3088] == nil then item["vendors"][3088] = 0 end
  if item["vendors"][3322] == nil then item["vendors"][3322] = 0 end
  if item["vendors"][4603] == nil then item["vendors"][4603] = 0 end
  if item["vendors"][4889] == nil then item["vendors"][4889] = 0 end
  if item["vendors"][5123] == nil then item["vendors"][5123] = 0 end
  if item["vendors"][8131] == nil then item["vendors"][8131] = 0 end
  if item["vendors"][9548] == nil then item["vendors"][9548] = 0 end
  if item["vendors"][9551] == nil then item["vendors"][9551] = 0 end
  if item["vendors"][11184] == nil then item["vendors"][11184] = 0 end
  if item["vendors"][61445] == nil then item["vendors"][61445] = 0 end
  if item["vendors"][62403] == nil then item["vendors"][62403] = 0 end
  if item["vendors"][92217] == nil then item["vendors"][92217] = 0 end
end

do
  local item = MTH_DS_AmmoItems[3024]
  if not item then
    item = {}
    MTH_DS_AmmoItems[3024] = item
  end
  if not item["name"] then item["name"] = 'BKP 2700 "Enforcer"' end
  if not item["level"] then item["level"] = 26 end
  if not item["reqlevel"] then item["reqlevel"] = 21 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_03' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 5 end
  if not item["dps"] then item["dps"] = 9.6 end
  if not item["speed"] then item["speed"] = 2.7 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][1297] == nil then item["vendors"][1297] = 0 end
  if item["vendors"][1461] == nil then item["vendors"][1461] = 0 end
  if item["vendors"][3018] == nil then item["vendors"][3018] = 0 end
  if item["vendors"][3053] == nil then item["vendors"][3053] = 0 end
  if item["vendors"][3322] == nil then item["vendors"][3322] = 0 end
  if item["vendors"][4603] == nil then item["vendors"][4603] = 0 end
  if item["vendors"][4889] == nil then item["vendors"][4889] = 0 end
  if item["vendors"][5123] == nil then item["vendors"][5123] = 0 end
  if item["vendors"][8131] == nil then item["vendors"][8131] = 0 end
  if item["vendors"][9548] == nil then item["vendors"][9548] = 0 end
  if item["vendors"][9551] == nil then item["vendors"][9551] = 0 end
  if item["vendors"][11184] == nil then item["vendors"][11184] = 0 end
  if item["vendors"][61445] == nil then item["vendors"][61445] = 0 end
  if item["vendors"][61751] == nil then item["vendors"][61751] = 0 end
  if item["vendors"][62403] == nil then item["vendors"][62403] = 0 end
  if item["vendors"][92217] == nil then item["vendors"][92217] = 0 end
end

do
  local item = MTH_DS_AmmoItems[3025]
  if not item then
    item = {}
    MTH_DS_AmmoItems[3025] = item
  end
  if not item["name"] then item["name"] = 'BKP 42 "Ultra"' end
  if not item["level"] then item["level"] = 36 end
  if not item["reqlevel"] then item["reqlevel"] = 31 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_03' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 5 end
  if not item["dps"] then item["dps"] = 13.8 end
  if not item["speed"] then item["speed"] = 2.1 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][3322] == nil then item["vendors"][3322] = 0 end
  if item["vendors"][8131] == nil then item["vendors"][8131] = 0 end
  if item["vendors"][9548] == nil then item["vendors"][9548] = 0 end
  if item["vendors"][11184] == nil then item["vendors"][11184] = 0 end
end

do
  local item = MTH_DS_AmmoItems[3026]
  if not item then
    item = {}
    MTH_DS_AmmoItems[3026] = item
  end
  if not item["name"] then item["name"] = 'Reinforced Bow' end
  if not item["level"] then item["level"] = 21 end
  if not item["reqlevel"] then item["reqlevel"] = 16 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_02' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 5 end
  if not item["dps"] then item["dps"] = 7.5 end
  if not item["speed"] then item["speed"] = 2.2 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][228] == nil then item["vendors"][228] = 0 end
  if item["vendors"][1297] == nil then item["vendors"][1297] = 0 end
  if item["vendors"][1298] == nil then item["vendors"][1298] = 0 end
  if item["vendors"][1455] == nil then item["vendors"][1455] = 0 end
  if item["vendors"][1459] == nil then item["vendors"][1459] = 0 end
  if item["vendors"][1668] == nil then item["vendors"][1668] = 0 end
  if item["vendors"][1687] == nil then item["vendors"][1687] = 0 end
  if item["vendors"][2286] == nil then item["vendors"][2286] = 0 end
  if item["vendors"][2839] == nil then item["vendors"][2839] = 0 end
  if item["vendors"][3015] == nil then item["vendors"][3015] = 0 end
  if item["vendors"][3409] == nil then item["vendors"][3409] = 0 end
  if item["vendors"][3410] == nil then item["vendors"][3410] = 0 end
  if item["vendors"][3488] == nil then item["vendors"][3488] = 0 end
  if item["vendors"][3951] == nil then item["vendors"][3951] = 0 end
  if item["vendors"][4173] == nil then item["vendors"][4173] = 0 end
  if item["vendors"][4203] == nil then item["vendors"][4203] = 0 end
  if item["vendors"][4604] == nil then item["vendors"][4604] = 0 end
  if item["vendors"][4892] == nil then item["vendors"][4892] = 0 end
  if item["vendors"][5122] == nil then item["vendors"][5122] = 0 end
  if item["vendors"][9548] == nil then item["vendors"][9548] = 0 end
  if item["vendors"][9549] == nil then item["vendors"][9549] = 0 end
  if item["vendors"][9551] == nil then item["vendors"][9551] = 0 end
  if item["vendors"][9552] == nil then item["vendors"][9552] = 0 end
  if item["vendors"][9553] == nil then item["vendors"][9553] = 0 end
  if item["vendors"][9555] == nil then item["vendors"][9555] = 0 end
  if item["vendors"][12029] == nil then item["vendors"][12029] = 0 end
  if item["vendors"][14301] == nil then item["vendors"][14301] = 0 end
  if item["vendors"][60659] == nil then item["vendors"][60659] = 0 end
  if item["vendors"][62739] == nil then item["vendors"][62739] = 0 end
  if item["vendors"][91977] == nil then item["vendors"][91977] = 0 end
end

do
  local item = MTH_DS_AmmoItems[3027]
  if not item then
    item = {}
    MTH_DS_AmmoItems[3027] = item
  end
  if not item["name"] then item["name"] = 'Heavy Recurve Bow' end
  if not item["level"] then item["level"] = 25 end
  if not item["reqlevel"] then item["reqlevel"] = 20 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_01' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 5 end
  if not item["dps"] then item["dps"] = 9.2 end
  if not item["speed"] then item["speed"] = 2.4 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][228] == nil then item["vendors"][228] = 0 end
  if item["vendors"][1297] == nil then item["vendors"][1297] = 0 end
  if item["vendors"][1298] == nil then item["vendors"][1298] = 0 end
  if item["vendors"][1455] == nil then item["vendors"][1455] = 0 end
  if item["vendors"][1459] == nil then item["vendors"][1459] = 0 end
  if item["vendors"][2286] == nil then item["vendors"][2286] = 0 end
  if item["vendors"][2839] == nil then item["vendors"][2839] = 0 end
  if item["vendors"][3015] == nil then item["vendors"][3015] = 0 end
  if item["vendors"][3410] == nil then item["vendors"][3410] = 0 end
  if item["vendors"][4173] == nil then item["vendors"][4173] = 0 end
  if item["vendors"][4604] == nil then item["vendors"][4604] = 0 end
  if item["vendors"][4892] == nil then item["vendors"][4892] = 0 end
  if item["vendors"][5122] == nil then item["vendors"][5122] = 0 end
  if item["vendors"][9548] == nil then item["vendors"][9548] = 0 end
  if item["vendors"][9551] == nil then item["vendors"][9551] = 0 end
  if item["vendors"][9552] == nil then item["vendors"][9552] = 0 end
  if item["vendors"][9555] == nil then item["vendors"][9555] = 0 end
  if item["vendors"][12029] == nil then item["vendors"][12029] = 0 end
  if item["vendors"][14301] == nil then item["vendors"][14301] = 0 end
  if item["vendors"][62739] == nil then item["vendors"][62739] = 0 end
end

do
  local item = MTH_DS_AmmoItems[3028]
  if not item then
    item = {}
    MTH_DS_AmmoItems[3028] = item
  end
  if not item["name"] then item["name"] = 'Longbow' end
  if not item["level"] then item["level"] = 34 end
  if not item["reqlevel"] then item["reqlevel"] = 29 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_07' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 5 end
  if not item["dps"] then item["dps"] = 13 end
  if not item["speed"] then item["speed"] = 2.3 end
end

do
  local item = MTH_DS_AmmoItems[3030]
  if item then
    if not item["vendors"] then item["vendors"] = {} end
    if item["vendors"][227] == nil then item["vendors"][227] = 0 end
    if item["vendors"][228] == nil then item["vendors"][228] = 0 end
    if item["vendors"][734] == nil then item["vendors"][734] = 0 end
    if item["vendors"][789] == nil then item["vendors"][789] = 0 end
    if item["vendors"][1149] == nil then item["vendors"][1149] = 0 end
    if item["vendors"][1285] == nil then item["vendors"][1285] = 0 end
    if item["vendors"][1287] == nil then item["vendors"][1287] = 0 end
    if item["vendors"][1297] == nil then item["vendors"][1297] = 0 end
    if item["vendors"][1298] == nil then item["vendors"][1298] = 0 end
    if item["vendors"][1448] == nil then item["vendors"][1448] = 0 end
    if item["vendors"][1452] == nil then item["vendors"][1452] = 0 end
    if item["vendors"][1455] == nil then item["vendors"][1455] = 0 end
    if item["vendors"][1459] == nil then item["vendors"][1459] = 0 end
    if item["vendors"][1462] == nil then item["vendors"][1462] = 0 end
    if item["vendors"][2084] == nil then item["vendors"][2084] = 0 end
    if item["vendors"][2286] == nil then item["vendors"][2286] = 0 end
    if item["vendors"][2401] == nil then item["vendors"][2401] = 0 end
    if item["vendors"][2803] == nil then item["vendors"][2803] = 0 end
    if item["vendors"][2806] == nil then item["vendors"][2806] = 0 end
    if item["vendors"][2808] == nil then item["vendors"][2808] = 0 end
    if item["vendors"][2820] == nil then item["vendors"][2820] = 0 end
    if item["vendors"][2839] == nil then item["vendors"][2839] = 0 end
    if item["vendors"][2908] == nil then item["vendors"][2908] = 0 end
    if item["vendors"][3015] == nil then item["vendors"][3015] = 0 end
    if item["vendors"][3313] == nil then item["vendors"][3313] = 0 end
    if item["vendors"][3350] == nil then item["vendors"][3350] = 0 end
    if item["vendors"][3410] == nil then item["vendors"][3410] = 0 end
    if item["vendors"][3541] == nil then item["vendors"][3541] = 0 end
    if item["vendors"][3625] == nil then item["vendors"][3625] = 0 end
    if item["vendors"][3962] == nil then item["vendors"][3962] = 0 end
    if item["vendors"][4084] == nil then item["vendors"][4084] = 0 end
    if item["vendors"][4170] == nil then item["vendors"][4170] = 0 end
    if item["vendors"][4173] == nil then item["vendors"][4173] = 0 end
    if item["vendors"][4241] == nil then item["vendors"][4241] = 0 end
    if item["vendors"][4555] == nil then item["vendors"][4555] = 0 end
    if item["vendors"][4602] == nil then item["vendors"][4602] = 0 end
    if item["vendors"][4604] == nil then item["vendors"][4604] = 0 end
    if item["vendors"][4876] == nil then item["vendors"][4876] = 0 end
    if item["vendors"][4892] == nil then item["vendors"][4892] = 0 end
    if item["vendors"][4896] == nil then item["vendors"][4896] = 0 end
    if item["vendors"][5101] == nil then item["vendors"][5101] = 0 end
    if item["vendors"][5122] == nil then item["vendors"][5122] = 0 end
    if item["vendors"][5134] == nil then item["vendors"][5134] = 0 end
    if item["vendors"][6028] == nil then item["vendors"][6028] = 0 end
    if item["vendors"][7942] == nil then item["vendors"][7942] = 0 end
    if item["vendors"][7976] == nil then item["vendors"][7976] = 0 end
    if item["vendors"][8139] == nil then item["vendors"][8139] = 0 end
    if item["vendors"][8362] == nil then item["vendors"][8362] = 0 end
    if item["vendors"][9320] == nil then item["vendors"][9320] = 0 end
    if item["vendors"][9548] == nil then item["vendors"][9548] = 0 end
    if item["vendors"][9551] == nil then item["vendors"][9551] = 0 end
    if item["vendors"][9552] == nil then item["vendors"][9552] = 0 end
    if item["vendors"][9555] == nil then item["vendors"][9555] = 0 end
    if item["vendors"][11038] == nil then item["vendors"][11038] = 0 end
    if item["vendors"][11555] == nil then item["vendors"][11555] = 0 end
    if item["vendors"][12021] == nil then item["vendors"][12021] = 0 end
    if item["vendors"][12027] == nil then item["vendors"][12027] = 0 end
    if item["vendors"][12029] == nil then item["vendors"][12029] = 0 end
    if item["vendors"][12036] == nil then item["vendors"][12036] = 0 end
    if item["vendors"][12246] == nil then item["vendors"][12246] = 0 end
    if item["vendors"][12959] == nil then item["vendors"][12959] = 0 end
    if item["vendors"][12960] == nil then item["vendors"][12960] = 0 end
    if item["vendors"][14301] == nil then item["vendors"][14301] = 0 end
    if item["vendors"][14624] == nil then item["vendors"][14624] = 0 end
    if item["vendors"][15174] == nil then item["vendors"][15174] = 0 end
    if item["vendors"][17598] == nil then item["vendors"][17598] = 0 end
    if item["vendors"][21002] == nil then item["vendors"][21002] = 0 end
    if item["vendors"][51656] == nil then item["vendors"][51656] = 0 end
    if item["vendors"][60456] == nil then item["vendors"][60456] = 0 end
    if item["vendors"][60641] == nil then item["vendors"][60641] = 0 end
    if item["vendors"][60646] == nil then item["vendors"][60646] = 0 end
    if item["vendors"][60653] == nil then item["vendors"][60653] = 0 end
    if item["vendors"][60663] == nil then item["vendors"][60663] = 0 end
    if item["vendors"][60740] == nil then item["vendors"][60740] = 0 end
    if item["vendors"][60766] == nil then item["vendors"][60766] = 0 end
    if item["vendors"][60790] == nil then item["vendors"][60790] = 0 end
    if item["vendors"][60803] == nil then item["vendors"][60803] = 0 end
    if item["vendors"][60813] == nil then item["vendors"][60813] = 0 end
    if item["vendors"][60966] == nil then item["vendors"][60966] = 0 end
    if item["vendors"][60989] == nil then item["vendors"][60989] = 0 end
    if item["vendors"][61058] == nil then item["vendors"][61058] = 0 end
    if item["vendors"][61115] == nil then item["vendors"][61115] = 0 end
    if item["vendors"][61140] == nil then item["vendors"][61140] = 0 end
    if item["vendors"][61272] == nil then item["vendors"][61272] = 0 end
    if item["vendors"][61288] == nil then item["vendors"][61288] = 0 end
    if item["vendors"][61369] == nil then item["vendors"][61369] = 0 end
    if item["vendors"][61440] == nil then item["vendors"][61440] = 0 end
    if item["vendors"][61443] == nil then item["vendors"][61443] = 0 end
    if item["vendors"][61478] == nil then item["vendors"][61478] = 0 end
    if item["vendors"][61523] == nil then item["vendors"][61523] = 0 end
    if item["vendors"][61563] == nil then item["vendors"][61563] = 0 end
    if item["vendors"][61651] == nil then item["vendors"][61651] = 0 end
    if item["vendors"][61743] == nil then item["vendors"][61743] = 0 end
    if item["vendors"][61812] == nil then item["vendors"][61812] = 0 end
    if item["vendors"][62086] == nil then item["vendors"][62086] = 0 end
    if item["vendors"][62096] == nil then item["vendors"][62096] = 0 end
    if item["vendors"][62148] == nil then item["vendors"][62148] = 0 end
    if item["vendors"][62307] == nil then item["vendors"][62307] = 0 end
    if item["vendors"][62402] == nil then item["vendors"][62402] = 0 end
    if item["vendors"][62404] == nil then item["vendors"][62404] = 0 end
    if item["vendors"][62409] == nil then item["vendors"][62409] = 0 end
    if item["vendors"][62436] == nil then item["vendors"][62436] = 0 end
    if item["vendors"][62437] == nil then item["vendors"][62437] = 0 end
    if item["vendors"][62462] == nil then item["vendors"][62462] = 0 end
    if item["vendors"][62469] == nil then item["vendors"][62469] = 0 end
    if item["vendors"][62628] == nil then item["vendors"][62628] = 0 end
    if item["vendors"][62739] == nil then item["vendors"][62739] = 0 end
    if item["vendors"][65002] == nil then item["vendors"][65002] = 0 end
    if item["vendors"][65003] == nil then item["vendors"][65003] = 0 end
    if item["vendors"][80267] == nil then item["vendors"][80267] = 0 end
    if item["vendors"][80808] == nil then item["vendors"][80808] = 0 end
    if item["vendors"][91403] == nil then item["vendors"][91403] = 0 end
    if item["vendors"][91725] == nil then item["vendors"][91725] = 0 end
    if item["vendors"][91868] == nil then item["vendors"][91868] = 0 end
    if item["vendors"][91956] == nil then item["vendors"][91956] = 0 end
    if item["vendors"][92169] == nil then item["vendors"][92169] = 0 end
    if item["vendors"][92177] == nil then item["vendors"][92177] = 0 end
    if item["vendors"][92200] == nil then item["vendors"][92200] = 0 end
  end
end

do
  local item = MTH_DS_AmmoItems[3033]
  if item then
    if not item["vendors"] then item["vendors"] = {} end
    if item["vendors"][227] == nil then item["vendors"][227] = 0 end
    if item["vendors"][734] == nil then item["vendors"][734] = 0 end
    if item["vendors"][1149] == nil then item["vendors"][1149] = 0 end
    if item["vendors"][1285] == nil then item["vendors"][1285] = 0 end
    if item["vendors"][1297] == nil then item["vendors"][1297] = 0 end
    if item["vendors"][1448] == nil then item["vendors"][1448] = 0 end
    if item["vendors"][1452] == nil then item["vendors"][1452] = 0 end
    if item["vendors"][1461] == nil then item["vendors"][1461] = 0 end
    if item["vendors"][1686] == nil then item["vendors"][1686] = 0 end
    if item["vendors"][2084] == nil then item["vendors"][2084] = 0 end
    if item["vendors"][2401] == nil then item["vendors"][2401] = 0 end
    if item["vendors"][2685] == nil then item["vendors"][2685] = 0 end
    if item["vendors"][2803] == nil then item["vendors"][2803] = 0 end
    if item["vendors"][2806] == nil then item["vendors"][2806] = 0 end
    if item["vendors"][2808] == nil then item["vendors"][2808] = 0 end
    if item["vendors"][2820] == nil then item["vendors"][2820] = 0 end
    if item["vendors"][2908] == nil then item["vendors"][2908] = 0 end
    if item["vendors"][3018] == nil then item["vendors"][3018] = 0 end
    if item["vendors"][3053] == nil then item["vendors"][3053] = 0 end
    if item["vendors"][3088] == nil then item["vendors"][3088] = 0 end
    if item["vendors"][3313] == nil then item["vendors"][3313] = 0 end
    if item["vendors"][3322] == nil then item["vendors"][3322] = 0 end
    if item["vendors"][3350] == nil then item["vendors"][3350] = 0 end
    if item["vendors"][3541] == nil then item["vendors"][3541] = 0 end
    if item["vendors"][3625] == nil then item["vendors"][3625] = 0 end
    if item["vendors"][3962] == nil then item["vendors"][3962] = 0 end
    if item["vendors"][4170] == nil then item["vendors"][4170] = 0 end
    if item["vendors"][4241] == nil then item["vendors"][4241] = 0 end
    if item["vendors"][4555] == nil then item["vendors"][4555] = 0 end
    if item["vendors"][4603] == nil then item["vendors"][4603] = 0 end
    if item["vendors"][4876] == nil then item["vendors"][4876] = 0 end
    if item["vendors"][4889] == nil then item["vendors"][4889] = 0 end
    if item["vendors"][4896] == nil then item["vendors"][4896] = 0 end
    if item["vendors"][5101] == nil then item["vendors"][5101] = 0 end
    if item["vendors"][5123] == nil then item["vendors"][5123] = 0 end
    if item["vendors"][5134] == nil then item["vendors"][5134] = 0 end
    if item["vendors"][6028] == nil then item["vendors"][6028] = 0 end
    if item["vendors"][7942] == nil then item["vendors"][7942] = 0 end
    if item["vendors"][8131] == nil then item["vendors"][8131] = 0 end
    if item["vendors"][8139] == nil then item["vendors"][8139] = 0 end
    if item["vendors"][8362] == nil then item["vendors"][8362] = 0 end
    if item["vendors"][9320] == nil then item["vendors"][9320] = 0 end
    if item["vendors"][9548] == nil then item["vendors"][9548] = 0 end
    if item["vendors"][9551] == nil then item["vendors"][9551] = 0 end
    if item["vendors"][11038] == nil then item["vendors"][11038] = 0 end
    if item["vendors"][11184] == nil then item["vendors"][11184] = 0 end
    if item["vendors"][11555] == nil then item["vendors"][11555] = 0 end
    if item["vendors"][12021] == nil then item["vendors"][12021] = 0 end
    if item["vendors"][12027] == nil then item["vendors"][12027] = 0 end
    if item["vendors"][12036] == nil then item["vendors"][12036] = 0 end
    if item["vendors"][12246] == nil then item["vendors"][12246] = 0 end
    if item["vendors"][12959] == nil then item["vendors"][12959] = 0 end
    if item["vendors"][12960] == nil then item["vendors"][12960] = 0 end
    if item["vendors"][14624] == nil then item["vendors"][14624] = 0 end
    if item["vendors"][15174] == nil then item["vendors"][15174] = 0 end
    if item["vendors"][21002] == nil then item["vendors"][21002] = 0 end
    if item["vendors"][51656] == nil then item["vendors"][51656] = 0 end
    if item["vendors"][60456] == nil then item["vendors"][60456] = 0 end
    if item["vendors"][60641] == nil then item["vendors"][60641] = 0 end
    if item["vendors"][60646] == nil then item["vendors"][60646] = 0 end
    if item["vendors"][60653] == nil then item["vendors"][60653] = 0 end
    if item["vendors"][60663] == nil then item["vendors"][60663] = 0 end
    if item["vendors"][60740] == nil then item["vendors"][60740] = 0 end
    if item["vendors"][60766] == nil then item["vendors"][60766] = 0 end
    if item["vendors"][60790] == nil then item["vendors"][60790] = 0 end
    if item["vendors"][60813] == nil then item["vendors"][60813] = 0 end
    if item["vendors"][60966] == nil then item["vendors"][60966] = 0 end
    if item["vendors"][60989] == nil then item["vendors"][60989] = 0 end
    if item["vendors"][61058] == nil then item["vendors"][61058] = 0 end
    if item["vendors"][61115] == nil then item["vendors"][61115] = 0 end
    if item["vendors"][61140] == nil then item["vendors"][61140] = 0 end
    if item["vendors"][61272] == nil then item["vendors"][61272] = 0 end
    if item["vendors"][61288] == nil then item["vendors"][61288] = 0 end
    if item["vendors"][61369] == nil then item["vendors"][61369] = 0 end
    if item["vendors"][61440] == nil then item["vendors"][61440] = 0 end
    if item["vendors"][61443] == nil then item["vendors"][61443] = 0 end
    if item["vendors"][61445] == nil then item["vendors"][61445] = 0 end
    if item["vendors"][61478] == nil then item["vendors"][61478] = 0 end
    if item["vendors"][61523] == nil then item["vendors"][61523] = 0 end
    if item["vendors"][61563] == nil then item["vendors"][61563] = 0 end
    if item["vendors"][61651] == nil then item["vendors"][61651] = 0 end
    if item["vendors"][61743] == nil then item["vendors"][61743] = 0 end
    if item["vendors"][61812] == nil then item["vendors"][61812] = 0 end
    if item["vendors"][62086] == nil then item["vendors"][62086] = 0 end
    if item["vendors"][62096] == nil then item["vendors"][62096] = 0 end
    if item["vendors"][62148] == nil then item["vendors"][62148] = 0 end
    if item["vendors"][62402] == nil then item["vendors"][62402] = 0 end
    if item["vendors"][62403] == nil then item["vendors"][62403] = 0 end
    if item["vendors"][62404] == nil then item["vendors"][62404] = 0 end
    if item["vendors"][62409] == nil then item["vendors"][62409] = 0 end
    if item["vendors"][62436] == nil then item["vendors"][62436] = 0 end
    if item["vendors"][62437] == nil then item["vendors"][62437] = 0 end
    if item["vendors"][62462] == nil then item["vendors"][62462] = 0 end
    if item["vendors"][62469] == nil then item["vendors"][62469] = 0 end
    if item["vendors"][62628] == nil then item["vendors"][62628] = 0 end
    if item["vendors"][65002] == nil then item["vendors"][65002] = 0 end
    if item["vendors"][65003] == nil then item["vendors"][65003] = 0 end
    if item["vendors"][80267] == nil then item["vendors"][80267] = 0 end
    if item["vendors"][80808] == nil then item["vendors"][80808] = 0 end
    if item["vendors"][91403] == nil then item["vendors"][91403] = 0 end
    if item["vendors"][91725] == nil then item["vendors"][91725] = 0 end
    if item["vendors"][91868] == nil then item["vendors"][91868] = 0 end
    if item["vendors"][91956] == nil then item["vendors"][91956] = 0 end
    if item["vendors"][92169] == nil then item["vendors"][92169] = 0 end
    if item["vendors"][92177] == nil then item["vendors"][92177] = 0 end
    if item["vendors"][92200] == nil then item["vendors"][92200] = 0 end
    if item["vendors"][92217] == nil then item["vendors"][92217] = 0 end
  end
end

do
  local item = MTH_DS_AmmoItems[3036]
  if not item then
    item = {}
    MTH_DS_AmmoItems[3036] = item
  end
  if not item["name"] then item["name"] = 'Heavy Shortbow' end
  if not item["level"] then item["level"] = 15 end
  if not item["reqlevel"] then item["reqlevel"] = 10 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_12' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 6 end
  if not item["speed"] then item["speed"] = 2.5 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][2039] == nil then item["objects"][2039] = 0.02 end
end

do
  local item = MTH_DS_AmmoItems[3037]
  if not item then
    item = {}
    MTH_DS_AmmoItems[3037] = item
  end
  if not item["name"] then item["name"] = 'Whipwood Recurve Bow' end
  if not item["level"] then item["level"] = 34 end
  if not item["reqlevel"] then item["reqlevel"] = 29 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_12' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 13.6 end
  if not item["speed"] then item["speed"] = 1.8 end
  if not item["drops"] then item["drops"] = {} end
  if item["drops"][7073] == nil then item["drops"][7073] = 0.22 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][153462] == nil then item["objects"][153462] = 0.44 end
end

do
  local item = MTH_DS_AmmoItems[3039]
  if not item then
    item = {}
    MTH_DS_AmmoItems[3039] = item
  end
  if not item["name"] then item["name"] = 'Short Ash Bow' end
  if not item["level"] then item["level"] = 23 end
  if not item["reqlevel"] then item["reqlevel"] = 18 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_03' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 9.2 end
  if not item["speed"] then item["speed"] = 1.9 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][153462] == nil then item["objects"][153462] = 0.19 end
end

do
  local item = MTH_DS_AmmoItems[3040]
  if not item then
    item = {}
    MTH_DS_AmmoItems[3040] = item
  end
  if not item["name"] then item["name"] = "Hunter's Muzzle Loader" end
  if not item["level"] then item["level"] = 19 end
  if not item["reqlevel"] then item["reqlevel"] = 14 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_01' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 7.5 end
  if not item["speed"] then item["speed"] = 1.8 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][3642] == nil then item["objects"][3642] = 1.6 end
  if item["objects"][152608] == nil then item["objects"][152608] = 1.6 end
  if item["objects"][152618] == nil then item["objects"][152618] = 1.6 end
end

do
  local item = MTH_DS_AmmoItems[3041]
  if not item then
    item = {}
    MTH_DS_AmmoItems[3041] = item
  end
  if not item["name"] then item["name"] = '"Mage-Eye" Blunderbuss' end
  if not item["level"] then item["level"] = 31 end
  if not item["reqlevel"] then item["reqlevel"] = 26 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_05' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 12.5 end
  if not item["speed"] then item["speed"] = 2.8 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][153462] == nil then item["objects"][153462] = 0.53 end
end

do
  local item = MTH_DS_AmmoItems[3042]
  if not item then
    item = {}
    MTH_DS_AmmoItems[3042] = item
  end
  if not item["name"] then item["name"] = 'BKP "Sparrow" Smallbore' end
  if not item["level"] then item["level"] = 33 end
  if not item["reqlevel"] then item["reqlevel"] = 28 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_01' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 13.2 end
  if not item["speed"] then item["speed"] = 1.7 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][153462] == nil then item["objects"][153462] = 0.42 end
end

do
  local item = MTH_DS_AmmoItems[3078]
  if not item then
    item = {}
    MTH_DS_AmmoItems[3078] = item
  end
  if not item["name"] then item["name"] = 'Naga Heartpiercer' end
  if not item["level"] then item["level"] = 26 end
  if not item["reqlevel"] then item["reqlevel"] = 21 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_04' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 10.6 end
  if not item["speed"] then item["speed"] = 1.8 end
end

do
  local item = MTH_DS_AmmoItems[3079]
  if not item then
    item = {}
    MTH_DS_AmmoItems[3079] = item
  end
  if not item["name"] then item["name"] = "Skorn's Rifle" end
  if not item["level"] then item["level"] = 12 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_01' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 5 end
  if not item["speed"] then item["speed"] = 1.9 end
end

do
  local item = MTH_DS_AmmoItems[3430]
  if not item then
    item = {}
    MTH_DS_AmmoItems[3430] = item
  end
  if not item["name"] then item["name"] = 'Sniper Rifle' end
  if not item["level"] then item["level"] = 44 end
  if not item["reqlevel"] then item["reqlevel"] = 39 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_05' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 20.2 end
  if not item["speed"] then item["speed"] = 3 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][141979] == nil then item["objects"][141979] = 2.3 end
  if item["objects"][142184] == nil then item["objects"][142184] = 2.1 end
end

do
  local item = MTH_DS_AmmoItems[3493]
  if not item then
    item = {}
    MTH_DS_AmmoItems[3493] = item
  end
  if not item["name"] then item["name"] = "Raptor's End" end
  if not item["level"] then item["level"] = 30 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_03' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 12.1 end
  if not item["speed"] then item["speed"] = 2.9 end
end

do
  local item = MTH_DS_AmmoItems[3567]
  if not item then
    item = {}
    MTH_DS_AmmoItems[3567] = item
  end
  if not item["name"] then item["name"] = 'Dwarven Fishing Pole' end
  if not item["level"] then item["level"] = 19 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_01' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 7.4 end
  if not item["speed"] then item["speed"] = 1.9 end
end

do
  local item = MTH_DS_AmmoItems[3742]
  if not item then
    item = {}
    MTH_DS_AmmoItems[3742] = item
  end
  if not item["name"] then item["name"] = 'Bow of Plunder' end
  if not item["level"] then item["level"] = 28 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_02' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 11.3 end
  if not item["speed"] then item["speed"] = 2.6 end
end

do
  local item = MTH_DS_AmmoItems[3778]
  if not item then
    item = {}
    MTH_DS_AmmoItems[3778] = item
  end
  if not item["name"] then item["name"] = 'Taut Compound Bow' end
  if not item["level"] then item["level"] = 31 end
  if not item["reqlevel"] then item["reqlevel"] = 26 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_02' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 6 end
  if not item["dps"] then item["dps"] = 7.6 end
  if not item["speed"] then item["speed"] = 2.5 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][153462] == nil then item["objects"][153462] = 0.39 end
end

do
  local item = MTH_DS_AmmoItems[3780]
  if not item then
    item = {}
    MTH_DS_AmmoItems[3780] = item
  end
  if not item["name"] then item["name"] = 'Long-barreled Musket' end
  if not item["level"] then item["level"] = 33 end
  if not item["reqlevel"] then item["reqlevel"] = 28 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_01' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 6 end
  if not item["dps"] then item["dps"] = 7.9 end
  if not item["speed"] then item["speed"] = 2.6 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][153462] == nil then item["objects"][153462] = 0.41 end
end

do
  local item = MTH_DS_AmmoItems[4025]
  if not item then
    item = {}
    MTH_DS_AmmoItems[4025] = item
  end
  if not item["name"] then item["name"] = 'Balanced Long Bow' end
  if not item["level"] then item["level"] = 45 end
  if not item["reqlevel"] then item["reqlevel"] = 40 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_02' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 6 end
  if not item["dps"] then item["dps"] = 12.2 end
  if not item["speed"] then item["speed"] = 1.8 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][141596] == nil then item["objects"][141596] = 0.4 end
  if item["objects"][153462] == nil then item["objects"][153462] = 0.02 end
end

do
  local item = MTH_DS_AmmoItems[4026]
  if not item then
    item = {}
    MTH_DS_AmmoItems[4026] = item
  end
  if not item["name"] then item["name"] = 'Sentinel Musket' end
  if not item["level"] then item["level"] = 43 end
  if not item["reqlevel"] then item["reqlevel"] = 38 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_01' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 6 end
  if not item["dps"] then item["dps"] = 11.6 end
  if not item["speed"] then item["speed"] = 2.8 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][141596] == nil then item["objects"][141596] = 0.5 end
  if item["objects"][153462] == nil then item["objects"][153462] = 0.02 end
end

do
  local item = MTH_DS_AmmoItems[4086]
  if not item then
    item = {}
    MTH_DS_AmmoItems[4086] = item
  end
  if not item["name"] then item["name"] = 'Flash Rifle' end
  if not item["level"] then item["level"] = 37 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_07' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 15.3 end
  if not item["speed"] then item["speed"] = 1.8 end
end

do
  local item = MTH_DS_AmmoItems[4087]
  if not item then
    item = {}
    MTH_DS_AmmoItems[4087] = item
  end
  if not item["name"] then item["name"] = 'Trueshot Bow' end
  if not item["level"] then item["level"] = 41 end
  if not item["reqlevel"] then item["reqlevel"] = 36 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_10' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 18.2 end
  if not item["speed"] then item["speed"] = 1.9 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][141979] == nil then item["objects"][141979] = 2 end
  if item["objects"][142184] == nil then item["objects"][142184] = 0.4 end
end

do
  local item = MTH_DS_AmmoItems[4089]
  if not item then
    item = {}
    MTH_DS_AmmoItems[4089] = item
  end
  if not item["name"] then item["name"] = 'Ricochet Blunderbuss' end
  if not item["level"] then item["level"] = 48 end
  if not item["reqlevel"] then item["reqlevel"] = 43 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_03' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 22.4 end
  if not item["speed"] then item["speed"] = 2.3 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][153462] == nil then item["objects"][153462] = 0.02 end
end

do
  local item = MTH_DS_AmmoItems[4110]
  if not item then
    item = {}
    MTH_DS_AmmoItems[4110] = item
  end
  if not item["name"] then item["name"] = "Master Hunter's Bow" end
  if not item["level"] then item["level"] = 45 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_11' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 20.8 end
  if not item["speed"] then item["speed"] = 2.4 end
end

do
  local item = MTH_DS_AmmoItems[4111]
  if not item then
    item = {}
    MTH_DS_AmmoItems[4111] = item
  end
  if not item["name"] then item["name"] = "Master Hunter's Rifle" end
  if not item["level"] then item["level"] = 45 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_05' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 20.6 end
  if not item["speed"] then item["speed"] = 2.6 end
end

do
  local item = MTH_DS_AmmoItems[4127]
  if not item then
    item = {}
    MTH_DS_AmmoItems[4127] = item
  end
  if not item["name"] then item["name"] = 'Shrapnel Blaster' end
  if not item["level"] then item["level"] = 40 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_02' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 17.4 end
  if not item["speed"] then item["speed"] = 1.9 end
end

do
  local item = MTH_DS_AmmoItems[4362]
  if not item then
    item = {}
    MTH_DS_AmmoItems[4362] = item
  end
  if not item["name"] then item["name"] = 'Rough Boomstick' end
  if not item["level"] then item["level"] = 10 end
  if not item["reqlevel"] then item["reqlevel"] = 5 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_03' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 4.1 end
  if not item["speed"] then item["speed"] = 2.3 end
end

do
  local item = MTH_DS_AmmoItems[4369]
  if not item then
    item = {}
    MTH_DS_AmmoItems[4369] = item
  end
  if not item["name"] then item["name"] = 'Deadly Blunderbuss' end
  if not item["level"] then item["level"] = 21 end
  if not item["reqlevel"] then item["reqlevel"] = 16 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_07' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 8.3 end
  if not item["speed"] then item["speed"] = 2.6 end
end

do
  local item = MTH_DS_AmmoItems[4372]
  if not item then
    item = {}
    MTH_DS_AmmoItems[4372] = item
  end
  if not item["name"] then item["name"] = 'Lovingly Crafted Boomstick' end
  if not item["level"] then item["level"] = 24 end
  if not item["reqlevel"] then item["reqlevel"] = 19 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_07' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 9.7 end
  if not item["speed"] then item["speed"] = 1.8 end
end

do
  local item = MTH_DS_AmmoItems[4379]
  if not item then
    item = {}
    MTH_DS_AmmoItems[4379] = item
  end
  if not item["name"] then item["name"] = 'Silver-plated Shotgun' end
  if not item["level"] then item["level"] = 26 end
  if not item["reqlevel"] then item["reqlevel"] = 21 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_07' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 10.4 end
  if not item["speed"] then item["speed"] = 2.7 end
end

do
  local item = MTH_DS_AmmoItems[4383]
  if not item then
    item = {}
    MTH_DS_AmmoItems[4383] = item
  end
  if not item["name"] then item["name"] = 'Moonsight Rifle' end
  if not item["level"] then item["level"] = 29 end
  if not item["reqlevel"] then item["reqlevel"] = 24 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_06' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 11.8 end
  if not item["speed"] then item["speed"] = 1.7 end
end

do
  local item = MTH_DS_AmmoItems[4474]
  if not item then
    item = {}
    MTH_DS_AmmoItems[4474] = item
  end
  if not item["name"] then item["name"] = 'Ravenwood Bow' end
  if not item["level"] then item["level"] = 32 end
  if not item["reqlevel"] then item["reqlevel"] = 27 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_10' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 12.9 end
  if not item["speed"] then item["speed"] = 1.9 end
end

do
  local item = MTH_DS_AmmoItems[4576]
  if not item then
    item = {}
    MTH_DS_AmmoItems[4576] = item
  end
  if not item["name"] then item["name"] = 'Light Bow' end
  if not item["level"] then item["level"] = 21 end
  if not item["reqlevel"] then item["reqlevel"] = 16 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_07' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 7.9 end
  if not item["speed"] then item["speed"] = 1.7 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][153462] == nil then item["objects"][153462] = 0.17 end
end

do
  local item = MTH_DS_AmmoItems[4577]
  if not item then
    item = {}
    MTH_DS_AmmoItems[4577] = item
  end
  if not item["name"] then item["name"] = 'Compact Shotgun' end
  if not item["level"] then item["level"] = 13 end
  if not item["reqlevel"] then item["reqlevel"] = 8 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_03' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 5.3 end
  if not item["speed"] then item["speed"] = 2 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][2039] == nil then item["objects"][2039] = 0.12 end
end

do
  local item = MTH_DS_AmmoItems[4763]
  if not item then
    item = {}
    MTH_DS_AmmoItems[4763] = item
  end
  if not item["name"] then item["name"] = 'Blackwood Recurve Bow' end
  if not item["level"] then item["level"] = 9 end
  if not item["reqlevel"] then item["reqlevel"] = 4 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_12' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 3.9 end
  if not item["speed"] then item["speed"] = 2.7 end
end

do
  local item = MTH_DS_AmmoItems[4931]
  if not item then
    item = {}
    MTH_DS_AmmoItems[4931] = item
  end
  if not item["name"] then item["name"] = 'Hickory Shortbow' end
  if not item["level"] then item["level"] = 11 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_05' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 5 end
  if not item["dps"] then item["dps"] = 3.8 end
  if not item["speed"] then item["speed"] = 2 end
end

do
  local item = MTH_DS_AmmoItems[5258]
  if not item then
    item = {}
    MTH_DS_AmmoItems[5258] = item
  end
  if not item["name"] then item["name"] = 'Monster - Bow, Black' end
  if not item["level"] then item["level"] = 1 end
  if not item["reqlevel"] then item["reqlevel"] = 1 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_05' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 6 end
  if not item["dps"] then item["dps"] = 0.8 end
  if not item["speed"] then item["speed"] = 2 end
end

do
  local item = MTH_DS_AmmoItems[5259]
  if not item then
    item = {}
    MTH_DS_AmmoItems[5259] = item
  end
  if not item["name"] then item["name"] = 'Monster - Bow, Red' end
  if not item["level"] then item["level"] = 1 end
  if not item["reqlevel"] then item["reqlevel"] = 1 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_05' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 6 end
  if not item["dps"] then item["dps"] = 0.8 end
  if not item["speed"] then item["speed"] = 2 end
end

do
  local item = MTH_DS_AmmoItems[5260]
  if not item then
    item = {}
    MTH_DS_AmmoItems[5260] = item
  end
  if not item["name"] then item["name"] = 'Monster - Bow, Brown' end
  if not item["level"] then item["level"] = 1 end
  if not item["reqlevel"] then item["reqlevel"] = 1 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_05' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 6 end
  if not item["dps"] then item["dps"] = 0.8 end
  if not item["speed"] then item["speed"] = 2 end
end

do
  local item = MTH_DS_AmmoItems[5261]
  if not item then
    item = {}
    MTH_DS_AmmoItems[5261] = item
  end
  if not item["name"] then item["name"] = 'Monster - Bow, Gray' end
  if not item["level"] then item["level"] = 1 end
  if not item["reqlevel"] then item["reqlevel"] = 1 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_05' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 6 end
  if not item["dps"] then item["dps"] = 0.8 end
  if not item["speed"] then item["speed"] = 2 end
end

do
  local item = MTH_DS_AmmoItems[5262]
  if not item then
    item = {}
    MTH_DS_AmmoItems[5262] = item
  end
  if not item["name"] then item["name"] = 'Monster - Bow, Dark Brown' end
  if not item["level"] then item["level"] = 1 end
  if not item["reqlevel"] then item["reqlevel"] = 1 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_05' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 6 end
  if not item["dps"] then item["dps"] = 0.8 end
  if not item["speed"] then item["speed"] = 2 end
end

do
  local item = MTH_DS_AmmoItems[5309]
  if not item then
    item = {}
    MTH_DS_AmmoItems[5309] = item
  end
  if not item["name"] then item["name"] = 'Privateer Musket' end
  if not item["level"] then item["level"] = 20 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_04' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 7.8 end
  if not item["speed"] then item["speed"] = 2.3 end
end

do
  local item = MTH_DS_AmmoItems[5346]
  if not item then
    item = {}
    MTH_DS_AmmoItems[5346] = item
  end
  if not item["name"] then item["name"] = 'Orcish Battle Bow' end
  if not item["level"] then item["level"] = 14 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_08' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 5.5 end
  if not item["speed"] then item["speed"] = 1.9 end
end

do
  local item = MTH_DS_AmmoItems[5568]
  if item then
    if not item["drops"] then item["drops"] = {} end
    if item["drops"][2156] == nil then item["drops"][2156] = 30.97 end
    if item["drops"][2157] == nil then item["drops"][2157] = 30.53 end
    if item["drops"][6206] == nil then item["drops"][6206] = 0.04 end
    if item["drops"][6207] == nil then item["drops"][6207] = 0.02 end
    if item["drops"][6210] == nil then item["drops"][6210] = 0.02 end
    if item["drops"][6211] == nil then item["drops"][6211] = 0.06 end
    if item["drops"][6218] == nil then item["drops"][6218] = 0.02 end
    if item["drops"][6219] == nil then item["drops"][6219] = 0.02 end
    if item["drops"][6220] == nil then item["drops"][6220] = 0.02 end
    if item["drops"][6221] == nil then item["drops"][6221] = 0.02 end
    if item["drops"][6223] == nil then item["drops"][6223] = 0.02 end
    if item["drops"][6233] == nil then item["drops"][6233] = 0.02 end
    if item["drops"][6234] == nil then item["drops"][6234] = 0.02 end
    if item["drops"][6329] == nil then item["drops"][6329] = 0.08 end
    if item["drops"][6391] == nil then item["drops"][6391] = 0.2 end
    if item["drops"][6392] == nil then item["drops"][6392] = 0.56 end
    if item["drops"][6407] == nil then item["drops"][6407] = 0.6 end
    if item["drops"][9676] == nil then item["drops"][9676] = 25 end
    if item["drops"][11920] == nil then item["drops"][11920] = 5.96 end
    if item["drops"][60442] == nil then item["drops"][60442] = 30.97 end
  end
end

do
  local item = MTH_DS_AmmoItems[5596]
  if not item then
    item = {}
    MTH_DS_AmmoItems[5596] = item
  end
  if not item["name"] then item["name"] = 'Ashwood Bow' end
  if not item["level"] then item["level"] = 11 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_01' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 5 end
  if not item["dps"] then item["dps"] = 3.8 end
  if not item["speed"] then item["speed"] = 2.1 end
end

do
  local item = MTH_DS_AmmoItems[5748]
  if not item then
    item = {}
    MTH_DS_AmmoItems[5748] = item
  end
  if not item["name"] then item["name"] = 'Centaur Longbow' end
  if not item["level"] then item["level"] = 16 end
  if not item["reqlevel"] then item["reqlevel"] = 11 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_07' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 6.1 end
  if not item["speed"] then item["speed"] = 2.2 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][80941] == nil then item["vendors"][80941] = 0 end
  if item["vendors"][80942] == nil then item["vendors"][80942] = 0 end
end

do
  local item = MTH_DS_AmmoItems[5817]
  if not item then
    item = {}
    MTH_DS_AmmoItems[5817] = item
  end
  if not item["name"] then item["name"] = 'Lunaris Bow' end
  if not item["level"] then item["level"] = 30 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_01' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 12.2 end
  if not item["speed"] then item["speed"] = 2.7 end
end

do
  local item = MTH_DS_AmmoItems[6315]
  if not item then
    item = {}
    MTH_DS_AmmoItems[6315] = item
  end
  if not item["name"] then item["name"] = 'Steelarrow Crossbow' end
  if not item["level"] then item["level"] = 27 end
  if not item["reqlevel"] then item["reqlevel"] = 22 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Crossbow_01' end
  if not item["subtype"] then item["subtype"] = 'crossbow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 10.9 end
  if not item["speed"] then item["speed"] = 3.4 end
  if not item["drops"] then item["drops"] = {} end
  if item["drops"][6523] == nil then item["drops"][6523] = 2 end
end

do
  local item = MTH_DS_AmmoItems[6469]
  if not item then
    item = {}
    MTH_DS_AmmoItems[6469] = item
  end
  if not item["name"] then item["name"] = 'Venomstrike' end
  if not item["level"] then item["level"] = 24 end
  if not item["reqlevel"] then item["reqlevel"] = 19 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_10' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 9.6 end
  if not item["speed"] then item["speed"] = 2.4 end
end

do
  local item = MTH_DS_AmmoItems[6696]
  if not item then
    item = {}
    MTH_DS_AmmoItems[6696] = item
  end
  if not item["name"] then item["name"] = 'Nightstalker Bow' end
  if not item["level"] then item["level"] = 32 end
  if not item["reqlevel"] then item["reqlevel"] = 27 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_12' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 16.2 end
  if not item["speed"] then item["speed"] = 1.7 end
end

do
  local item = MTH_DS_AmmoItems[6739]
  if not item then
    item = {}
    MTH_DS_AmmoItems[6739] = item
  end
  if not item["name"] then item["name"] = "Cliffrunner's Aim" end
  if not item["level"] then item["level"] = 29 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_08' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 12 end
  if not item["speed"] then item["speed"] = 2.3 end
end

do
  local item = MTH_DS_AmmoItems[6798]
  if not item then
    item = {}
    MTH_DS_AmmoItems[6798] = item
  end
  if not item["name"] then item["name"] = 'Blasting Hackbut' end
  if not item["level"] then item["level"] = 37 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_04' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 15.4 end
  if not item["speed"] then item["speed"] = 2.8 end
end

do
  local item = MTH_DS_AmmoItems[7729]
  if not item then
    item = {}
    MTH_DS_AmmoItems[7729] = item
  end
  if not item["name"] then item["name"] = 'Chesterfall Musket' end
  if not item["level"] then item["level"] = 33 end
  if not item["reqlevel"] then item["reqlevel"] = 28 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_06' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 16.5 end
  if not item["speed"] then item["speed"] = 2.3 end
  if not item["drops"] then item["drops"] = {} end
  if item["drops"][4282] == nil then item["drops"][4282] = 0.02 end
  if item["drops"][4283] == nil then item["drops"][4283] = 0.02 end
  if item["drops"][4285] == nil then item["drops"][4285] = 0.02 end
  if item["drops"][4286] == nil then item["drops"][4286] = 0.02 end
  if item["drops"][4287] == nil then item["drops"][4287] = 0.02 end
  if item["drops"][4288] == nil then item["drops"][4288] = 0.04 end
  if item["drops"][4290] == nil then item["drops"][4290] = 0.02 end
  if item["drops"][4291] == nil then item["drops"][4291] = 0.02 end
  if item["drops"][4292] == nil then item["drops"][4292] = 0.02 end
  if item["drops"][4293] == nil then item["drops"][4293] = 0.02 end
  if item["drops"][4294] == nil then item["drops"][4294] = 0.02 end
  if item["drops"][4295] == nil then item["drops"][4295] = 0.02 end
  if item["drops"][4296] == nil then item["drops"][4296] = 0.02 end
  if item["drops"][4298] == nil then item["drops"][4298] = 0.02 end
  if item["drops"][4299] == nil then item["drops"][4299] = 0.02 end
  if item["drops"][4300] == nil then item["drops"][4300] = 0.02 end
  if item["drops"][4301] == nil then item["drops"][4301] = 0.02 end
  if item["drops"][4302] == nil then item["drops"][4302] = 0.02 end
  if item["drops"][4303] == nil then item["drops"][4303] = 0.02 end
  if item["drops"][4304] == nil then item["drops"][4304] = 0.02 end
  if item["drops"][4306] == nil then item["drops"][4306] = 0.02 end
  if item["drops"][4308] == nil then item["drops"][4308] = 0.02 end
  if item["drops"][4540] == nil then item["drops"][4540] = 0.02 end
  if item["drops"][6426] == nil then item["drops"][6426] = 0.02 end
  if item["drops"][6427] == nil then item["drops"][6427] = 0.02 end
  if item["drops"][61971] == nil then item["drops"][61971] = 0.02 end
  if item["drops"][62537] == nil then item["drops"][62537] = 0.02 end
  if item["drops"][62645] == nil then item["drops"][62645] = 0.02 end
  if item["drops"][62647] == nil then item["drops"][62647] = 0.02 end
  if item["drops"][62651] == nil then item["drops"][62651] = 0.02 end
  if item["drops"][62659] == nil then item["drops"][62659] = 0.02 end
  if item["drops"][62663] == nil then item["drops"][62663] = 0.02 end
  if item["drops"][62666] == nil then item["drops"][62666] = 0.02 end
  if item["drops"][62669] == nil then item["drops"][62669] = 0.02 end
end

do
  local item = MTH_DS_AmmoItems[8179]
  if not item then
    item = {}
    MTH_DS_AmmoItems[8179] = item
  end
  if not item["name"] then item["name"] = "Cadet's Bow" end
  if not item["level"] then item["level"] = 6 end
  if not item["reqlevel"] then item["reqlevel"] = 1 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_05' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 5 end
  if not item["dps"] then item["dps"] = 2.3 end
  if not item["speed"] then item["speed"] = 2 end
  if not item["drops"] then item["drops"] = {} end
  if item["drops"][40] == nil then item["drops"][40] = 0.06 end
  if item["drops"][43] == nil then item["drops"][43] = 0.02 end
  if item["drops"][46] == nil then item["drops"][46] = 0.02 end
  if item["drops"][97] == nil then item["drops"][97] = 0.02 end
  if item["drops"][116] == nil then item["drops"][116] = 0.02 end
  if item["drops"][285] == nil then item["drops"][285] = 0.1 end
  if item["drops"][390] == nil then item["drops"][390] = 0.38 end
  if item["drops"][475] == nil then item["drops"][475] = 0.02 end
  if item["drops"][476] == nil then item["drops"][476] = 0.14 end
  if item["drops"][524] == nil then item["drops"][524] = 0.1 end
  if item["drops"][735] == nil then item["drops"][735] = 0.14 end
  if item["drops"][880] == nil then item["drops"][880] = 0.04 end
  if item["drops"][1117] == nil then item["drops"][1117] = 0.02 end
  if item["drops"][1120] == nil then item["drops"][1120] = 0.14 end
  if item["drops"][1124] == nil then item["drops"][1124] = 0.02 end
  if item["drops"][1126] == nil then item["drops"][1126] = 0.12 end
  if item["drops"][1127] == nil then item["drops"][1127] = 0.1 end
  if item["drops"][1131] == nil then item["drops"][1131] = 0.1 end
  if item["drops"][1135] == nil then item["drops"][1135] = 0.1 end
  if item["drops"][1138] == nil then item["drops"][1138] = 0.12 end
  if item["drops"][1196] == nil then item["drops"][1196] = 0.12 end
  if item["drops"][1201] == nil then item["drops"][1201] = 0.06 end
  if item["drops"][1520] == nil then item["drops"][1520] = 0.08 end
  if item["drops"][1522] == nil then item["drops"][1522] = 0.12 end
  if item["drops"][1526] == nil then item["drops"][1526] = 0.12 end
  if item["drops"][1527] == nil then item["drops"][1527] = 0.12 end
  if item["drops"][1531] == nil then item["drops"][1531] = 0.1 end
  if item["drops"][1535] == nil then item["drops"][1535] = 0.12 end
  if item["drops"][1536] == nil then item["drops"][1536] = 0.1 end
  if item["drops"][1543] == nil then item["drops"][1543] = 0.05 end
  if item["drops"][1548] == nil then item["drops"][1548] = 0.14 end
  if item["drops"][1553] == nil then item["drops"][1553] = 0.12 end
  if item["drops"][1554] == nil then item["drops"][1554] = 0.02 end
  if item["drops"][1674] == nil then item["drops"][1674] = 0.12 end
  if item["drops"][1675] == nil then item["drops"][1675] = 0.12 end
  if item["drops"][1922] == nil then item["drops"][1922] = 0.05 end
  if item["drops"][1934] == nil then item["drops"][1934] = 0.1 end
  if item["drops"][1941] == nil then item["drops"][1941] = 0.12 end
  if item["drops"][1993] == nil then item["drops"][1993] = 0.04 end
  if item["drops"][1996] == nil then item["drops"][1996] = 0.12 end
  if item["drops"][1997] == nil then item["drops"][1997] = 0.02 end
  if item["drops"][1999] == nil then item["drops"][1999] = 0.14 end
  if item["drops"][2004] == nil then item["drops"][2004] = 0.12 end
  if item["drops"][2005] == nil then item["drops"][2005] = 0.24 end
  if item["drops"][2008] == nil then item["drops"][2008] = 0.16 end
  if item["drops"][2009] == nil then item["drops"][2009] = 0.14 end
  if item["drops"][2010] == nil then item["drops"][2010] = 0.12 end
  if item["drops"][2011] == nil then item["drops"][2011] = 0.02 end
  if item["drops"][2015] == nil then item["drops"][2015] = 0.02 end
  if item["drops"][2025] == nil then item["drops"][2025] = 0.14 end
  if item["drops"][2027] == nil then item["drops"][2027] = 0.02 end
  if item["drops"][2043] == nil then item["drops"][2043] = 0.08 end
  if item["drops"][2152] == nil then item["drops"][2152] = 0.16 end
  if item["drops"][2949] == nil then item["drops"][2949] = 0.02 end
  if item["drops"][2950] == nil then item["drops"][2950] = 0.12 end
  if item["drops"][2951] == nil then item["drops"][2951] = 0.14 end
  if item["drops"][2956] == nil then item["drops"][2956] = 0.08 end
  if item["drops"][2959] == nil then item["drops"][2959] = 0.12 end
  if item["drops"][2960] == nil then item["drops"][2960] = 0.02 end
  if item["drops"][2962] == nil then item["drops"][2962] = 0.08 end
  if item["drops"][2970] == nil then item["drops"][2970] = 0.12 end
  if item["drops"][2972] == nil then item["drops"][2972] = 0.1 end
  if item["drops"][2976] == nil then item["drops"][2976] = 0.18 end
  if item["drops"][2977] == nil then item["drops"][2977] = 0.14 end
  if item["drops"][2989] == nil then item["drops"][2989] = 0.16 end
  if item["drops"][3035] == nil then item["drops"][3035] = 0.1 end
  if item["drops"][3099] == nil then item["drops"][3099] = 0.1 end
  if item["drops"][3100] == nil then item["drops"][3100] = 0.02 end
  if item["drops"][3103] == nil then item["drops"][3103] = 0.12 end
  if item["drops"][3104] == nil then item["drops"][3104] = 0.12 end
  if item["drops"][3107] == nil then item["drops"][3107] = 0.14 end
  if item["drops"][3111] == nil then item["drops"][3111] = 0.18 end
  if item["drops"][3112] == nil then item["drops"][3112] = 0.12 end
  if item["drops"][3115] == nil then item["drops"][3115] = 0.12 end
  if item["drops"][3116] == nil then item["drops"][3116] = 0.08 end
  if item["drops"][3119] == nil then item["drops"][3119] = 0.12 end
  if item["drops"][3120] == nil then item["drops"][3120] = 0.16 end
  if item["drops"][3121] == nil then item["drops"][3121] = 0.12 end
  if item["drops"][3122] == nil then item["drops"][3122] = 0.08 end
  if item["drops"][3126] == nil then item["drops"][3126] = 0.12 end
  if item["drops"][3129] == nil then item["drops"][3129] = 0.14 end
  if item["drops"][3131] == nil then item["drops"][3131] = 0.02 end
  if item["drops"][3197] == nil then item["drops"][3197] = 0.02 end
  if item["drops"][3203] == nil then item["drops"][3203] = 0.04 end
  if item["drops"][3204] == nil then item["drops"][3204] = 0.04 end
  if item["drops"][5826] == nil then item["drops"][5826] = 0.1 end
  if item["drops"][6866] == nil then item["drops"][6866] = 0.02 end
  if item["drops"][7235] == nil then item["drops"][7235] = 0.12 end
  if item["drops"][14428] == nil then item["drops"][14428] = 0.14 end
  if item["drops"][61656] == nil then item["drops"][61656] = 0.08 end
  if item["drops"][61657] == nil then item["drops"][61657] = 0.08 end
  if item["drops"][61658] == nil then item["drops"][61658] = 0.12 end
  if item["drops"][61659] == nil then item["drops"][61659] = 0.12 end
  if item["drops"][61660] == nil then item["drops"][61660] = 0.12 end
  if item["drops"][61661] == nil then item["drops"][61661] = 0.12 end
  if item["drops"][61662] == nil then item["drops"][61662] = 0.12 end
  if item["drops"][61682] == nil then item["drops"][61682] = 0.1 end
  if item["drops"][61683] == nil then item["drops"][61683] = 0.1 end
  if item["drops"][61684] == nil then item["drops"][61684] = 0.1 end
  if item["drops"][61685] == nil then item["drops"][61685] = 0.1 end
  if item["drops"][61686] == nil then item["drops"][61686] = 0.1 end
  if item["drops"][61687] == nil then item["drops"][61687] = 0.1 end
  if item["drops"][61695] == nil then item["drops"][61695] = 0.08 end
  if item["drops"][61701] == nil then item["drops"][61701] = 0.14 end
  if item["drops"][61709] == nil then item["drops"][61709] = 0.02 end
  if item["drops"][61710] == nil then item["drops"][61710] = 0.02 end
  if item["drops"][61712] == nil then item["drops"][61712] = 0.02 end
  if item["drops"][61713] == nil then item["drops"][61713] = 0.02 end
  if item["drops"][61714] == nil then item["drops"][61714] = 0.14 end
  if item["drops"][61716] == nil then item["drops"][61716] = 0.08 end
  if item["drops"][61759] == nil then item["drops"][61759] = 0.1 end
  if item["drops"][61783] == nil then item["drops"][61783] = 0.24 end
  if item["drops"][61789] == nil then item["drops"][61789] = 0.08 end
  if item["drops"][61790] == nil then item["drops"][61790] = 0.14 end
  if item["drops"][61895] == nil then item["drops"][61895] = 0.04 end
  if item["drops"][62717] == nil then item["drops"][62717] = 0.14 end
  if item["drops"][80250] == nil then item["drops"][80250] = 0.08 end
end

do
  local item = MTH_DS_AmmoItems[8180]
  if not item then
    item = {}
    MTH_DS_AmmoItems[8180] = item
  end
  if not item["name"] then item["name"] = 'Hunting Bow' end
  if not item["level"] then item["level"] = 11 end
  if not item["reqlevel"] then item["reqlevel"] = 6 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_03' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 4.6 end
  if not item["speed"] then item["speed"] = 2.6 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][2039] == nil then item["objects"][2039] = 0.24 end
end

do
  local item = MTH_DS_AmmoItems[8181]
  if not item then
    item = {}
    MTH_DS_AmmoItems[8181] = item
  end
  if not item["name"] then item["name"] = 'Hunting Rifle' end
  if not item["level"] then item["level"] = 9 end
  if not item["reqlevel"] then item["reqlevel"] = 4 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_04' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 5 end
  if not item["dps"] then item["dps"] = 3 end
  if not item["speed"] then item["speed"] = 2.7 end
  if not item["drops"] then item["drops"] = {} end
  if item["drops"][40] == nil then item["drops"][40] = 0.03 end
  if item["drops"][43] == nil then item["drops"][43] = 1 end
  if item["drops"][46] == nil then item["drops"][46] = 0.28 end
  if item["drops"][60] == nil then item["drops"][60] = 0.3 end
  if item["drops"][79] == nil then item["drops"][79] = 0.4 end
  if item["drops"][97] == nil then item["drops"][97] = 0.36 end
  if item["drops"][99] == nil then item["drops"][99] = 0.24 end
  if item["drops"][116] == nil then item["drops"][116] = 0.3 end
  if item["drops"][118] == nil then item["drops"][118] = 0.34 end
  if item["drops"][199] == nil then item["drops"][199] = 0.14 end
  if item["drops"][285] == nil then item["drops"][285] = 0.06 end
  if item["drops"][327] == nil then item["drops"][327] = 0.08 end
  if item["drops"][330] == nil then item["drops"][330] = 0.18 end
  if item["drops"][390] == nil then item["drops"][390] = 0.16 end
  if item["drops"][471] == nil then item["drops"][471] = 0.15 end
  if item["drops"][473] == nil then item["drops"][473] = 0.12 end
  if item["drops"][474] == nil then item["drops"][474] = 0.34 end
  if item["drops"][475] == nil then item["drops"][475] = 0.02 end
  if item["drops"][476] == nil then item["drops"][476] = 0.14 end
  if item["drops"][478] == nil then item["drops"][478] = 0.3 end
  if item["drops"][480] == nil then item["drops"][480] = 0.26 end
  if item["drops"][481] == nil then item["drops"][481] = 0.08 end
  if item["drops"][524] == nil then item["drops"][524] = 0.16 end
  if item["drops"][583] == nil then item["drops"][583] = 0.14 end
  if item["drops"][732] == nil then item["drops"][732] = 0.28 end
  if item["drops"][735] == nil then item["drops"][735] = 0.06 end
  if item["drops"][822] == nil then item["drops"][822] = 0.26 end
  if item["drops"][834] == nil then item["drops"][834] = 0.07 end
  if item["drops"][880] == nil then item["drops"][880] = 0.11 end
  if item["drops"][881] == nil then item["drops"][881] = 0.48 end
  if item["drops"][1115] == nil then item["drops"][1115] = 0.14 end
  if item["drops"][1116] == nil then item["drops"][1116] = 0.14 end
  if item["drops"][1117] == nil then item["drops"][1117] = 0.36 end
  if item["drops"][1120] == nil then item["drops"][1120] = 0.18 end
  if item["drops"][1121] == nil then item["drops"][1121] = 0.34 end
  if item["drops"][1122] == nil then item["drops"][1122] = 0.36 end
  if item["drops"][1123] == nil then item["drops"][1123] = 0.32 end
  if item["drops"][1124] == nil then item["drops"][1124] = 0.38 end
  if item["drops"][1126] == nil then item["drops"][1126] = 0.04 end
  if item["drops"][1127] == nil then item["drops"][1127] = 0.14 end
  if item["drops"][1131] == nil then item["drops"][1131] = 0.14 end
  if item["drops"][1133] == nil then item["drops"][1133] = 0.28 end
  if item["drops"][1135] == nil then item["drops"][1135] = 0.04 end
  if item["drops"][1138] == nil then item["drops"][1138] = 0.04 end
  if item["drops"][1172] == nil then item["drops"][1172] = 0.12 end
  if item["drops"][1173] == nil then item["drops"][1173] = 0.12 end
  if item["drops"][1190] == nil then item["drops"][1190] = 0.05 end
  if item["drops"][1195] == nil then item["drops"][1195] = 0.07 end
  if item["drops"][1196] == nil then item["drops"][1196] = 0.12 end
  if item["drops"][1201] == nil then item["drops"][1201] = 0.07 end
  if item["drops"][1211] == nil then item["drops"][1211] = 0.32 end
  if item["drops"][1397] == nil then item["drops"][1397] = 0.16 end
  if item["drops"][1520] == nil then item["drops"][1520] = 0.06 end
  if item["drops"][1522] == nil then item["drops"][1522] = 0.14 end
  if item["drops"][1523] == nil then item["drops"][1523] = 0.3 end
  if item["drops"][1526] == nil then item["drops"][1526] = 0.06 end
  if item["drops"][1527] == nil then item["drops"][1527] = 0.22 end
  if item["drops"][1528] == nil then item["drops"][1528] = 0.26 end
  if item["drops"][1529] == nil then item["drops"][1529] = 0.32 end
  if item["drops"][1530] == nil then item["drops"][1530] = 0.07 end
  if item["drops"][1531] == nil then item["drops"][1531] = 0.12 end
  if item["drops"][1532] == nil then item["drops"][1532] = 0.12 end
  if item["drops"][1533] == nil then item["drops"][1533] = 0.62 end
  if item["drops"][1534] == nil then item["drops"][1534] = 0.34 end
  if item["drops"][1535] == nil then item["drops"][1535] = 0.06 end
  if item["drops"][1536] == nil then item["drops"][1536] = 0.14 end
  if item["drops"][1537] == nil then item["drops"][1537] = 0.28 end
  if item["drops"][1538] == nil then item["drops"][1538] = 0.34 end
  if item["drops"][1539] == nil then item["drops"][1539] = 0.22 end
  if item["drops"][1540] == nil then item["drops"][1540] = 0.1 end
  if item["drops"][1543] == nil then item["drops"][1543] = 0.06 end
  if item["drops"][1544] == nil then item["drops"][1544] = 0.36 end
  if item["drops"][1545] == nil then item["drops"][1545] = 0.32 end
  if item["drops"][1548] == nil then item["drops"][1548] = 0.14 end
  if item["drops"][1549] == nil then item["drops"][1549] = 0.5 end
  if item["drops"][1553] == nil then item["drops"][1553] = 0.06 end
  if item["drops"][1554] == nil then item["drops"][1554] = 0.36 end
  if item["drops"][1555] == nil then item["drops"][1555] = 0.4 end
  if item["drops"][1654] == nil then item["drops"][1654] = 0.1 end
  if item["drops"][1655] == nil then item["drops"][1655] = 0.14 end
  if item["drops"][1656] == nil then item["drops"][1656] = 0.14 end
  if item["drops"][1657] == nil then item["drops"][1657] = 0.16 end
  if item["drops"][1660] == nil then item["drops"][1660] = 0.26 end
  if item["drops"][1662] == nil then item["drops"][1662] = 0.26 end
  if item["drops"][1674] == nil then item["drops"][1674] = 0.06 end
  if item["drops"][1675] == nil then item["drops"][1675] = 0.12 end
  if item["drops"][1689] == nil then item["drops"][1689] = 0.32 end
  if item["drops"][1753] == nil then item["drops"][1753] = 0.22 end
  if item["drops"][1765] == nil then item["drops"][1765] = 0.14 end
  if item["drops"][1769] == nil then item["drops"][1769] = 0.12 end
  if item["drops"][1922] == nil then item["drops"][1922] = 0.07 end
  if item["drops"][1934] == nil then item["drops"][1934] = 0.06 end
  if item["drops"][1941] == nil then item["drops"][1941] = 0.06 end
  if item["drops"][1981] == nil then item["drops"][1981] = 0.24 end
  if item["drops"][1993] == nil then item["drops"][1993] = 0.28 end
  if item["drops"][1996] == nil then item["drops"][1996] = 0.18 end
  if item["drops"][1997] == nil then item["drops"][1997] = 0.24 end
  if item["drops"][1999] == nil then item["drops"][1999] = 0.14 end
  if item["drops"][2000] == nil then item["drops"][2000] = 0.38 end
  if item["drops"][2001] == nil then item["drops"][2001] = 0.06 end
  if item["drops"][2004] == nil then item["drops"][2004] = 0.06 end
  if item["drops"][2005] == nil then item["drops"][2005] = 0.14 end
  if item["drops"][2008] == nil then item["drops"][2008] = 0.04 end
  if item["drops"][2009] == nil then item["drops"][2009] = 0.14 end
  if item["drops"][2010] == nil then item["drops"][2010] = 0.14 end
  if item["drops"][2011] == nil then item["drops"][2011] = 0.3 end
  if item["drops"][2012] == nil then item["drops"][2012] = 0.24 end
  if item["drops"][2013] == nil then item["drops"][2013] = 0.3 end
  if item["drops"][2014] == nil then item["drops"][2014] = 0.02 end
  if item["drops"][2015] == nil then item["drops"][2015] = 0.15 end
  if item["drops"][2017] == nil then item["drops"][2017] = 0.12 end
  if item["drops"][2018] == nil then item["drops"][2018] = 0.56 end
  if item["drops"][2019] == nil then item["drops"][2019] = 0.22 end
  if item["drops"][2020] == nil then item["drops"][2020] = 0.4 end
  if item["drops"][2025] == nil then item["drops"][2025] = 0.12 end
  if item["drops"][2027] == nil then item["drops"][2027] = 0.26 end
  if item["drops"][2029] == nil then item["drops"][2029] = 0.26 end
  if item["drops"][2030] == nil then item["drops"][2030] = 0.1 end
  if item["drops"][2033] == nil then item["drops"][2033] = 0.26 end
  if item["drops"][2034] == nil then item["drops"][2034] = 0.06 end
  if item["drops"][2038] == nil then item["drops"][2038] = 0.1 end
  if item["drops"][2043] == nil then item["drops"][2043] = 0.12 end
  if item["drops"][2070] == nil then item["drops"][2070] = 0.12 end
  if item["drops"][2152] == nil then item["drops"][2152] = 0.06 end
  if item["drops"][2162] == nil then item["drops"][2162] = 0.08 end
  if item["drops"][2166] == nil then item["drops"][2166] = 1 end
  if item["drops"][2176] == nil then item["drops"][2176] = 0.12 end
  if item["drops"][2189] == nil then item["drops"][2189] = 0.12 end
  if item["drops"][2231] == nil then item["drops"][2231] = 0.44 end
  if item["drops"][2234] == nil then item["drops"][2234] = 0.18 end
  if item["drops"][2950] == nil then item["drops"][2950] = 0.04 end
  if item["drops"][2951] == nil then item["drops"][2951] = 0.1 end
  if item["drops"][2956] == nil then item["drops"][2956] = 0.08 end
  if item["drops"][2957] == nil then item["drops"][2957] = 0.26 end
  if item["drops"][2959] == nil then item["drops"][2959] = 0.14 end
  if item["drops"][2960] == nil then item["drops"][2960] = 0.3 end
  if item["drops"][2962] == nil then item["drops"][2962] = 0.12 end
  if item["drops"][2963] == nil then item["drops"][2963] = 0.26 end
  if item["drops"][2964] == nil then item["drops"][2964] = 0.36 end
  if item["drops"][2965] == nil then item["drops"][2965] = 0.1 end
  if item["drops"][2967] == nil then item["drops"][2967] = 0.42 end
  if item["drops"][2968] == nil then item["drops"][2968] = 0.12 end
  if item["drops"][2970] == nil then item["drops"][2970] = 0.28 end
  if item["drops"][2971] == nil then item["drops"][2971] = 0.32 end
  if item["drops"][2972] == nil then item["drops"][2972] = 0.1 end
  if item["drops"][2973] == nil then item["drops"][2973] = 0.08 end
  if item["drops"][2976] == nil then item["drops"][2976] = 0.02 end
  if item["drops"][2977] == nil then item["drops"][2977] = 0.12 end
  if item["drops"][2978] == nil then item["drops"][2978] = 0.32 end
  if item["drops"][2979] == nil then item["drops"][2979] = 0.26 end
  if item["drops"][2989] == nil then item["drops"][2989] = 0.08 end
  if item["drops"][2990] == nil then item["drops"][2990] = 0.22 end
  if item["drops"][3035] == nil then item["drops"][3035] = 0.14 end
  if item["drops"][3068] == nil then item["drops"][3068] = 0.06 end
  if item["drops"][3099] == nil then item["drops"][3099] = 0.06 end
  if item["drops"][3100] == nil then item["drops"][3100] = 0.32 end
  if item["drops"][3103] == nil then item["drops"][3103] = 0.06 end
  if item["drops"][3104] == nil then item["drops"][3104] = 0.1 end
  if item["drops"][3105] == nil then item["drops"][3105] = 0.6 end
  if item["drops"][3107] == nil then item["drops"][3107] = 0.2 end
  if item["drops"][3108] == nil then item["drops"][3108] = 0.58 end
  if item["drops"][3110] == nil then item["drops"][3110] = 0.22 end
  if item["drops"][3111] == nil then item["drops"][3111] = 0.06 end
  if item["drops"][3112] == nil then item["drops"][3112] = 0.14 end
  if item["drops"][3113] == nil then item["drops"][3113] = 0.3 end
  if item["drops"][3114] == nil then item["drops"][3114] = 0.14 end
  if item["drops"][3115] == nil then item["drops"][3115] = 0.14 end
  if item["drops"][3116] == nil then item["drops"][3116] = 0.14 end
  if item["drops"][3117] == nil then item["drops"][3117] = 0.32 end
  if item["drops"][3118] == nil then item["drops"][3118] = 0.12 end
  if item["drops"][3119] == nil then item["drops"][3119] = 0.06 end
  if item["drops"][3120] == nil then item["drops"][3120] = 0.14 end
  if item["drops"][3121] == nil then item["drops"][3121] = 0.2 end
  if item["drops"][3122] == nil then item["drops"][3122] = 0.12 end
  if item["drops"][3123] == nil then item["drops"][3123] = 0.4 end
  if item["drops"][3126] == nil then item["drops"][3126] = 0.16 end
  if item["drops"][3127] == nil then item["drops"][3127] = 0.32 end
  if item["drops"][3129] == nil then item["drops"][3129] = 0.08 end
  if item["drops"][3130] == nil then item["drops"][3130] = 0.36 end
  if item["drops"][3131] == nil then item["drops"][3131] = 0.1 end
  if item["drops"][3141] == nil then item["drops"][3141] = 0.36 end
  if item["drops"][3192] == nil then item["drops"][3192] = 0.12 end
  if item["drops"][3195] == nil then item["drops"][3195] = 0.34 end
  if item["drops"][3196] == nil then item["drops"][3196] = 0.46 end
  if item["drops"][3197] == nil then item["drops"][3197] = 0.32 end
  if item["drops"][3198] == nil then item["drops"][3198] = 0.12 end
  if item["drops"][3199] == nil then item["drops"][3199] = 0.08 end
  if item["drops"][3205] == nil then item["drops"][3205] = 0.3 end
  if item["drops"][3206] == nil then item["drops"][3206] = 0.28 end
  if item["drops"][3207] == nil then item["drops"][3207] = 0.32 end
  if item["drops"][3225] == nil then item["drops"][3225] = 0.08 end
  if item["drops"][3227] == nil then item["drops"][3227] = 0.1 end
  if item["drops"][3228] == nil then item["drops"][3228] = 0.08 end
  if item["drops"][3232] == nil then item["drops"][3232] = 0.38 end
  if item["drops"][3267] == nil then item["drops"][3267] = 0.12 end
  if item["drops"][3268] == nil then item["drops"][3268] = 0.12 end
  if item["drops"][3379] == nil then item["drops"][3379] = 0.12 end
  if item["drops"][3566] == nil then item["drops"][3566] = 0.38 end
  if item["drops"][5807] == nil then item["drops"][5807] = 0.18 end
  if item["drops"][6123] == nil then item["drops"][6123] = 0.3 end
  if item["drops"][6789] == nil then item["drops"][6789] = 0.28 end
  if item["drops"][6846] == nil then item["drops"][6846] = 0.34 end
  if item["drops"][6866] == nil then item["drops"][6866] = 0.3 end
  if item["drops"][6911] == nil then item["drops"][6911] = 0.46 end
  if item["drops"][6927] == nil then item["drops"][6927] = 0.52 end
  if item["drops"][7234] == nil then item["drops"][7234] = 0.1 end
  if item["drops"][7235] == nil then item["drops"][7235] = 0.04 end
  if item["drops"][7318] == nil then item["drops"][7318] = 0.2 end
  if item["drops"][14428] == nil then item["drops"][14428] = 0.08 end
  if item["drops"][14431] == nil then item["drops"][14431] = 0.08 end
  if item["drops"][60708] == nil then item["drops"][60708] = 0.14 end
  if item["drops"][60893] == nil then item["drops"][60893] = 0.14 end
  if item["drops"][60898] == nil then item["drops"][60898] = 0.14 end
  if item["drops"][60980] == nil then item["drops"][60980] = 0.08 end
  if item["drops"][61464] == nil then item["drops"][61464] = 0.26 end
  if item["drops"][61656] == nil then item["drops"][61656] = 0.14 end
  if item["drops"][61657] == nil then item["drops"][61657] = 0.14 end
  if item["drops"][61658] == nil then item["drops"][61658] = 0.14 end
  if item["drops"][61659] == nil then item["drops"][61659] = 0.14 end
  if item["drops"][61660] == nil then item["drops"][61660] = 0.16 end
  if item["drops"][61661] == nil then item["drops"][61661] = 0.16 end
  if item["drops"][61662] == nil then item["drops"][61662] = 0.16 end
  if item["drops"][61663] == nil then item["drops"][61663] = 0.3 end
  if item["drops"][61664] == nil then item["drops"][61664] = 0.3 end
  if item["drops"][61665] == nil then item["drops"][61665] = 0.3 end
  if item["drops"][61666] == nil then item["drops"][61666] = 0.3 end
  if item["drops"][61667] == nil then item["drops"][61667] = 0.3 end
  if item["drops"][61668] == nil then item["drops"][61668] = 0.3 end
  if item["drops"][61669] == nil then item["drops"][61669] = 0.3 end
  if item["drops"][61670] == nil then item["drops"][61670] = 0.28 end
  if item["drops"][61672] == nil then item["drops"][61672] = 0.28 end
  if item["drops"][61673] == nil then item["drops"][61673] = 0.28 end
  if item["drops"][61674] == nil then item["drops"][61674] = 0.28 end
  if item["drops"][61675] == nil then item["drops"][61675] = 0.28 end
  if item["drops"][61676] == nil then item["drops"][61676] = 0.28 end
  if item["drops"][61677] == nil then item["drops"][61677] = 0.28 end
  if item["drops"][61678] == nil then item["drops"][61678] = 0.6 end
  if item["drops"][61679] == nil then item["drops"][61679] = 0.6 end
  if item["drops"][61680] == nil then item["drops"][61680] = 0.58 end
  if item["drops"][61681] == nil then item["drops"][61681] = 0.58 end
  if item["drops"][61682] == nil then item["drops"][61682] = 0.06 end
  if item["drops"][61683] == nil then item["drops"][61683] = 0.06 end
  if item["drops"][61684] == nil then item["drops"][61684] = 0.06 end
  if item["drops"][61685] == nil then item["drops"][61685] = 0.06 end
  if item["drops"][61686] == nil then item["drops"][61686] = 0.06 end
  if item["drops"][61687] == nil then item["drops"][61687] = 0.06 end
  if item["drops"][61694] == nil then item["drops"][61694] = 0.4 end
  if item["drops"][61695] == nil then item["drops"][61695] = 0.08 end
  if item["drops"][61699] == nil then item["drops"][61699] = 0.26 end
  if item["drops"][61700] == nil then item["drops"][61700] = 0.26 end
  if item["drops"][61701] == nil then item["drops"][61701] = 0.12 end
  if item["drops"][61702] == nil then item["drops"][61702] = 0.28 end
  if item["drops"][61703] == nil then item["drops"][61703] = 0.28 end
  if item["drops"][61704] == nil then item["drops"][61704] = 0.58 end
  if item["drops"][61705] == nil then item["drops"][61705] = 0.28 end
  if item["drops"][61706] == nil then item["drops"][61706] = 0.28 end
  if item["drops"][61707] == nil then item["drops"][61707] = 0.28 end
  if item["drops"][61708] == nil then item["drops"][61708] = 0.28 end
  if item["drops"][61709] == nil then item["drops"][61709] = 0.28 end
  if item["drops"][61710] == nil then item["drops"][61710] = 0.28 end
  if item["drops"][61712] == nil then item["drops"][61712] = 0.28 end
  if item["drops"][61713] == nil then item["drops"][61713] = 0.28 end
  if item["drops"][61714] == nil then item["drops"][61714] = 0.12 end
  if item["drops"][61715] == nil then item["drops"][61715] = 0.4 end
  if item["drops"][61716] == nil then item["drops"][61716] = 0.08 end
  if item["drops"][61717] == nil then item["drops"][61717] = 0.14 end
  if item["drops"][61718] == nil then item["drops"][61718] = 0.12 end
  if item["drops"][61719] == nil then item["drops"][61719] = 0.12 end
  if item["drops"][61759] == nil then item["drops"][61759] = 0.06 end
  if item["drops"][61783] == nil then item["drops"][61783] = 0.14 end
  if item["drops"][61789] == nil then item["drops"][61789] = 0.08 end
  if item["drops"][61790] == nil then item["drops"][61790] = 0.12 end
  if item["drops"][61792] == nil then item["drops"][61792] = 0.6 end
  if item["drops"][61794] == nil then item["drops"][61794] = 0.28 end
  if item["drops"][61863] == nil then item["drops"][61863] = 0.3 end
  if item["drops"][62711] == nil then item["drops"][62711] = 0.3 end
  if item["drops"][62712] == nil then item["drops"][62712] = 0.3 end
  if item["drops"][62713] == nil then item["drops"][62713] = 0.3 end
  if item["drops"][62714] == nil then item["drops"][62714] = 0.3 end
  if item["drops"][62715] == nil then item["drops"][62715] = 0.3 end
  if item["drops"][62717] == nil then item["drops"][62717] = 0.12 end
  if item["drops"][62753] == nil then item["drops"][62753] = 0.3 end
  if item["drops"][80250] == nil then item["drops"][80250] = 0.12 end
  if item["drops"][80257] == nil then item["drops"][80257] = 0.14 end
end

do
  local item = MTH_DS_AmmoItems[8182]
  if not item then
    item = {}
    MTH_DS_AmmoItems[8182] = item
  end
  if not item["name"] then item["name"] = 'Pellet Rifle' end
  if not item["level"] then item["level"] = 7 end
  if not item["reqlevel"] then item["reqlevel"] = 2 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_04' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 5 end
  if not item["dps"] then item["dps"] = 2.5 end
  if not item["speed"] then item["speed"] = 2.6 end
  if not item["drops"] then item["drops"] = {} end
  if item["drops"][40] == nil then item["drops"][40] = 0.11 end
  if item["drops"][43] == nil then item["drops"][43] = 0.1 end
  if item["drops"][46] == nil then item["drops"][46] = 0.02 end
  if item["drops"][60] == nil then item["drops"][60] = 0.44 end
  if item["drops"][97] == nil then item["drops"][97] = 0.08 end
  if item["drops"][116] == nil then item["drops"][116] = 0.12 end
  if item["drops"][285] == nil then item["drops"][285] = 0.3 end
  if item["drops"][327] == nil then item["drops"][327] = 0.06 end
  if item["drops"][390] == nil then item["drops"][390] = 0.46 end
  if item["drops"][471] == nil then item["drops"][471] = 0.02 end
  if item["drops"][475] == nil then item["drops"][475] = 0.02 end
  if item["drops"][476] == nil then item["drops"][476] = 0.26 end
  if item["drops"][478] == nil then item["drops"][478] = 0.02 end
  if item["drops"][524] == nil then item["drops"][524] = 0.34 end
  if item["drops"][583] == nil then item["drops"][583] = 0.14 end
  if item["drops"][735] == nil then item["drops"][735] = 0.24 end
  if item["drops"][822] == nil then item["drops"][822] = 0.1 end
  if item["drops"][880] == nil then item["drops"][880] = 0.34 end
  if item["drops"][1115] == nil then item["drops"][1115] = 0.07 end
  if item["drops"][1117] == nil then item["drops"][1117] = 0.02 end
  if item["drops"][1120] == nil then item["drops"][1120] = 0.36 end
  if item["drops"][1121] == nil then item["drops"][1121] = 0.12 end
  if item["drops"][1123] == nil then item["drops"][1123] = 0.12 end
  if item["drops"][1126] == nil then item["drops"][1126] = 0.2 end
  if item["drops"][1127] == nil then item["drops"][1127] = 0.3 end
  if item["drops"][1131] == nil then item["drops"][1131] = 0.38 end
  if item["drops"][1133] == nil then item["drops"][1133] = 0.22 end
  if item["drops"][1135] == nil then item["drops"][1135] = 0.18 end
  if item["drops"][1138] == nil then item["drops"][1138] = 0.24 end
  if item["drops"][1196] == nil then item["drops"][1196] = 0.3 end
  if item["drops"][1201] == nil then item["drops"][1201] = 0.18 end
  if item["drops"][1211] == nil then item["drops"][1211] = 0.1 end
  if item["drops"][1397] == nil then item["drops"][1397] = 0.07 end
  if item["drops"][1520] == nil then item["drops"][1520] = 0.22 end
  if item["drops"][1522] == nil then item["drops"][1522] = 0.32 end
  if item["drops"][1523] == nil then item["drops"][1523] = 0.08 end
  if item["drops"][1526] == nil then item["drops"][1526] = 0.22 end
  if item["drops"][1527] == nil then item["drops"][1527] = 0.34 end
  if item["drops"][1528] == nil then item["drops"][1528] = 0.16 end
  if item["drops"][1531] == nil then item["drops"][1531] = 0.12 end
  if item["drops"][1533] == nil then item["drops"][1533] = 0.02 end
  if item["drops"][1535] == nil then item["drops"][1535] = 0.26 end
  if item["drops"][1536] == nil then item["drops"][1536] = 0.36 end
  if item["drops"][1537] == nil then item["drops"][1537] = 0.1 end
  if item["drops"][1543] == nil then item["drops"][1543] = 0.16 end
  if item["drops"][1544] == nil then item["drops"][1544] = 0.16 end
  if item["drops"][1548] == nil then item["drops"][1548] = 0.36 end
  if item["drops"][1553] == nil then item["drops"][1553] = 0.22 end
  if item["drops"][1554] == nil then item["drops"][1554] = 0.12 end
  if item["drops"][1660] == nil then item["drops"][1660] = 0.2 end
  if item["drops"][1674] == nil then item["drops"][1674] = 0.18 end
  if item["drops"][1675] == nil then item["drops"][1675] = 0.36 end
  if item["drops"][1922] == nil then item["drops"][1922] = 0.2 end
  if item["drops"][1934] == nil then item["drops"][1934] = 0.18 end
  if item["drops"][1941] == nil then item["drops"][1941] = 0.2 end
  if item["drops"][1996] == nil then item["drops"][1996] = 0.34 end
  if item["drops"][1997] == nil then item["drops"][1997] = 0.12 end
  if item["drops"][1999] == nil then item["drops"][1999] = 0.42 end
  if item["drops"][2000] == nil then item["drops"][2000] = 0.06 end
  if item["drops"][2004] == nil then item["drops"][2004] = 0.2 end
  if item["drops"][2005] == nil then item["drops"][2005] = 0.48 end
  if item["drops"][2008] == nil then item["drops"][2008] = 0.22 end
  if item["drops"][2009] == nil then item["drops"][2009] = 0.34 end
  if item["drops"][2010] == nil then item["drops"][2010] = 0.3 end
  if item["drops"][2011] == nil then item["drops"][2011] = 0.12 end
  if item["drops"][2015] == nil then item["drops"][2015] = 0.06 end
  if item["drops"][2017] == nil then item["drops"][2017] = 0.07 end
  if item["drops"][2025] == nil then item["drops"][2025] = 0.3 end
  if item["drops"][2027] == nil then item["drops"][2027] = 0.14 end
  if item["drops"][2033] == nil then item["drops"][2033] = 0.1 end
  if item["drops"][2038] == nil then item["drops"][2038] = 0.22 end
  if item["drops"][2043] == nil then item["drops"][2043] = 0.3 end
  if item["drops"][2152] == nil then item["drops"][2152] = 0.2 end
  if item["drops"][2162] == nil then item["drops"][2162] = 0.34 end
  if item["drops"][2950] == nil then item["drops"][2950] = 0.18 end
  if item["drops"][2951] == nil then item["drops"][2951] = 0.42 end
  if item["drops"][2956] == nil then item["drops"][2956] = 0.24 end
  if item["drops"][2957] == nil then item["drops"][2957] = 0.18 end
  if item["drops"][2959] == nil then item["drops"][2959] = 0.3 end
  if item["drops"][2962] == nil then item["drops"][2962] = 0.36 end
  if item["drops"][2963] == nil then item["drops"][2963] = 0.08 end
  if item["drops"][2964] == nil then item["drops"][2964] = 0.02 end
  if item["drops"][2965] == nil then item["drops"][2965] = 0.02 end
  if item["drops"][2967] == nil then item["drops"][2967] = 0.14 end
  if item["drops"][2970] == nil then item["drops"][2970] = 0.18 end
  if item["drops"][2971] == nil then item["drops"][2971] = 0.13 end
  if item["drops"][2972] == nil then item["drops"][2972] = 0.24 end
  if item["drops"][2976] == nil then item["drops"][2976] = 0.22 end
  if item["drops"][2977] == nil then item["drops"][2977] = 0.38 end
  if item["drops"][2978] == nil then item["drops"][2978] = 0.1 end
  if item["drops"][2989] == nil then item["drops"][2989] = 0.32 end
  if item["drops"][2990] == nil then item["drops"][2990] = 0.08 end
  if item["drops"][3035] == nil then item["drops"][3035] = 0.32 end
  if item["drops"][3099] == nil then item["drops"][3099] = 0.26 end
  if item["drops"][3100] == nil then item["drops"][3100] = 0.12 end
  if item["drops"][3103] == nil then item["drops"][3103] = 0.2 end
  if item["drops"][3104] == nil then item["drops"][3104] = 0.2 end
  if item["drops"][3107] == nil then item["drops"][3107] = 0.38 end
  if item["drops"][3111] == nil then item["drops"][3111] = 0.18 end
  if item["drops"][3112] == nil then item["drops"][3112] = 0.34 end
  if item["drops"][3113] == nil then item["drops"][3113] = 0.1 end
  if item["drops"][3115] == nil then item["drops"][3115] = 0.36 end
  if item["drops"][3116] == nil then item["drops"][3116] = 0.3 end
  if item["drops"][3118] == nil then item["drops"][3118] = 0.02 end
  if item["drops"][3119] == nil then item["drops"][3119] = 0.22 end
  if item["drops"][3120] == nil then item["drops"][3120] = 0.26 end
  if item["drops"][3121] == nil then item["drops"][3121] = 0.36 end
  if item["drops"][3122] == nil then item["drops"][3122] = 0.26 end
  if item["drops"][3123] == nil then item["drops"][3123] = 0.1 end
  if item["drops"][3126] == nil then item["drops"][3126] = 0.34 end
  if item["drops"][3129] == nil then item["drops"][3129] = 0.2 end
  if item["drops"][3141] == nil then item["drops"][3141] = 1.1 end
  if item["drops"][3192] == nil then item["drops"][3192] = 0.2 end
  if item["drops"][3195] == nil then item["drops"][3195] = 0.12 end
  if item["drops"][3197] == nil then item["drops"][3197] = 0.02 end
  if item["drops"][3198] == nil then item["drops"][3198] = 0.02 end
  if item["drops"][3203] == nil then item["drops"][3203] = 0.02 end
  if item["drops"][3206] == nil then item["drops"][3206] = 0.16 end
  if item["drops"][3207] == nil then item["drops"][3207] = 0.14 end
  if item["drops"][6123] == nil then item["drops"][6123] = 0.02 end
  if item["drops"][6846] == nil then item["drops"][6846] = 0.04 end
  if item["drops"][6927] == nil then item["drops"][6927] = 0.16 end
  if item["drops"][7234] == nil then item["drops"][7234] = 0.2 end
  if item["drops"][7235] == nil then item["drops"][7235] = 0.18 end
  if item["drops"][8996] == nil then item["drops"][8996] = 0.98 end
  if item["drops"][14428] == nil then item["drops"][14428] = 0.43 end
  if item["drops"][14431] == nil then item["drops"][14431] = 0.08 end
  if item["drops"][61656] == nil then item["drops"][61656] = 0.3 end
  if item["drops"][61657] == nil then item["drops"][61657] = 0.3 end
  if item["drops"][61658] == nil then item["drops"][61658] = 0.3 end
  if item["drops"][61659] == nil then item["drops"][61659] = 0.3 end
  if item["drops"][61660] == nil then item["drops"][61660] = 0.34 end
  if item["drops"][61661] == nil then item["drops"][61661] = 0.34 end
  if item["drops"][61662] == nil then item["drops"][61662] = 0.34 end
  if item["drops"][61663] == nil then item["drops"][61663] = 0.02 end
  if item["drops"][61664] == nil then item["drops"][61664] = 0.02 end
  if item["drops"][61665] == nil then item["drops"][61665] = 0.02 end
  if item["drops"][61666] == nil then item["drops"][61666] = 0.02 end
  if item["drops"][61667] == nil then item["drops"][61667] = 0.02 end
  if item["drops"][61668] == nil then item["drops"][61668] = 0.02 end
  if item["drops"][61669] == nil then item["drops"][61669] = 0.02 end
  if item["drops"][61670] == nil then item["drops"][61670] = 0.1 end
  if item["drops"][61672] == nil then item["drops"][61672] = 0.1 end
  if item["drops"][61673] == nil then item["drops"][61673] = 0.1 end
  if item["drops"][61674] == nil then item["drops"][61674] = 0.1 end
  if item["drops"][61675] == nil then item["drops"][61675] = 0.1 end
  if item["drops"][61676] == nil then item["drops"][61676] = 0.1 end
  if item["drops"][61677] == nil then item["drops"][61677] = 0.1 end
  if item["drops"][61682] == nil then item["drops"][61682] = 0.3 end
  if item["drops"][61683] == nil then item["drops"][61683] = 0.3 end
  if item["drops"][61684] == nil then item["drops"][61684] = 0.3 end
  if item["drops"][61685] == nil then item["drops"][61685] = 0.3 end
  if item["drops"][61686] == nil then item["drops"][61686] = 0.3 end
  if item["drops"][61687] == nil then item["drops"][61687] = 0.3 end
  if item["drops"][61694] == nil then item["drops"][61694] = 0.1 end
  if item["drops"][61695] == nil then item["drops"][61695] = 0.24 end
  if item["drops"][61699] == nil then item["drops"][61699] = 0.1 end
  if item["drops"][61700] == nil then item["drops"][61700] = 0.1 end
  if item["drops"][61701] == nil then item["drops"][61701] = 0.3 end
  if item["drops"][61709] == nil then item["drops"][61709] = 0.02 end
  if item["drops"][61710] == nil then item["drops"][61710] = 0.02 end
  if item["drops"][61712] == nil then item["drops"][61712] = 0.02 end
  if item["drops"][61713] == nil then item["drops"][61713] = 0.02 end
  if item["drops"][61714] == nil then item["drops"][61714] = 0.3 end
  if item["drops"][61715] == nil then item["drops"][61715] = 0.1 end
  if item["drops"][61716] == nil then item["drops"][61716] = 0.24 end
  if item["drops"][61759] == nil then item["drops"][61759] = 0.3 end
  if item["drops"][61783] == nil then item["drops"][61783] = 0.48 end
  if item["drops"][61789] == nil then item["drops"][61789] = 0.24 end
  if item["drops"][61790] == nil then item["drops"][61790] = 0.3 end
  if item["drops"][61794] == nil then item["drops"][61794] = 0.1 end
  if item["drops"][61863] == nil then item["drops"][61863] = 0.02 end
  if item["drops"][61895] == nil then item["drops"][61895] = 0.02 end
  if item["drops"][62717] == nil then item["drops"][62717] = 0.3 end
  if item["drops"][62753] == nil then item["drops"][62753] = 0.02 end
  if item["drops"][80250] == nil then item["drops"][80250] = 0.3 end
end

do
  local item = MTH_DS_AmmoItems[8183]
  if not item then
    item = {}
    MTH_DS_AmmoItems[8183] = item
  end
  if not item["name"] then item["name"] = 'Precision Bow' end
  if not item["level"] then item["level"] = 27 end
  if not item["reqlevel"] then item["reqlevel"] = 22 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_04' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 11 end
  if not item["speed"] then item["speed"] = 2.6 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][153462] == nil then item["objects"][153462] = 0.08 end
end

do
  local item = MTH_DS_AmmoItems[8188]
  if not item then
    item = {}
    MTH_DS_AmmoItems[8188] = item
  end
  if not item["name"] then item["name"] = 'Explosive Shotgun' end
  if not item["level"] then item["level"] = 37 end
  if not item["reqlevel"] then item["reqlevel"] = 32 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_08' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 15.2 end
  if not item["speed"] then item["speed"] = 2.1 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][153462] == nil then item["objects"][153462] = 0.27 end
end

do
  local item = MTH_DS_AmmoItems[9399]
  if item then
    if not item["drops"] then item["drops"] = {} end
    if item["drops"][6906] == nil then item["drops"][6906] = 100 end
  end
end

do
  local item = MTH_DS_AmmoItems[9400]
  if not item then
    item = {}
    MTH_DS_AmmoItems[9400] = item
  end
  if not item["name"] then item["name"] = "Baelog's Shortbow" end
  if not item["level"] then item["level"] = 41 end
  if not item["reqlevel"] then item["reqlevel"] = 36 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_11' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 5 end
  if not item["dps"] then item["dps"] = 18.3 end
  if not item["speed"] then item["speed"] = 2.3 end
end

do
  local item = MTH_DS_AmmoItems[9412]
  if not item then
    item = {}
    MTH_DS_AmmoItems[9412] = item
  end
  if not item["name"] then item["name"] = "Galgann's Fireblaster" end
  if not item["level"] then item["level"] = 47 end
  if not item["reqlevel"] then item["reqlevel"] = 42 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_07' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 24.6 end
  if not item["speed"] then item["speed"] = 2.6 end
end

do
  local item = MTH_DS_AmmoItems[9422]
  if not item then
    item = {}
    MTH_DS_AmmoItems[9422] = item
  end
  if not item["name"] then item["name"] = 'Shadowforge Bushmaster' end
  if not item["level"] then item["level"] = 43 end
  if not item["reqlevel"] then item["reqlevel"] = 38 end
  if not item["icon"] then item["icon"] = 'INV_Musket_02' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 22.8 end
  if not item["speed"] then item["speed"] = 2.9 end
  if not item["drops"] then item["drops"] = {} end
  if item["drops"][4849] == nil then item["drops"][4849] = 0.02 end
  if item["drops"][4853] == nil then item["drops"][4853] = 0.02 end
  if item["drops"][4855] == nil then item["drops"][4855] = 0.02 end
  if item["drops"][4857] == nil then item["drops"][4857] = 0.02 end
  if item["drops"][4860] == nil then item["drops"][4860] = 0.02 end
  if item["drops"][7012] == nil then item["drops"][7012] = 0.02 end
  if item["drops"][7022] == nil then item["drops"][7022] = 0.02 end
  if item["drops"][7290] == nil then item["drops"][7290] = 0.02 end
  if item["drops"][7320] == nil then item["drops"][7320] = 0.02 end
  if item["drops"][7321] == nil then item["drops"][7321] = 0.04 end
  if item["drops"][60906] == nil then item["drops"][60906] = 0.02 end
end

do
  local item = MTH_DS_AmmoItems[9426]
  if not item then
    item = {}
    MTH_DS_AmmoItems[9426] = item
  end
  if not item["name"] then item["name"] = 'Monolithic Bow' end
  if not item["level"] then item["level"] = 41 end
  if not item["reqlevel"] then item["reqlevel"] = 36 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_01' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 21.9 end
  if not item["speed"] then item["speed"] = 2.7 end
  if not item["drops"] then item["drops"] = {} end
  if item["drops"][4848] == nil then item["drops"][4848] = 0.02 end
  if item["drops"][4850] == nil then item["drops"][4850] = 0.02 end
  if item["drops"][4852] == nil then item["drops"][4852] = 0.02 end
  if item["drops"][4853] == nil then item["drops"][4853] = 0.02 end
  if item["drops"][4855] == nil then item["drops"][4855] = 0.04 end
  if item["drops"][4857] == nil then item["drops"][4857] = 0.02 end
  if item["drops"][4860] == nil then item["drops"][4860] = 0.02 end
  if item["drops"][4861] == nil then item["drops"][4861] = 0.02 end
  if item["drops"][4863] == nil then item["drops"][4863] = 0.02 end
  if item["drops"][7022] == nil then item["drops"][7022] = 0.02 end
  if item["drops"][7023] == nil then item["drops"][7023] = 0.06 end
  if item["drops"][7320] == nil then item["drops"][7320] = 0.02 end
  if item["drops"][7321] == nil then item["drops"][7321] = 0.02 end
  if item["drops"][62725] == nil then item["drops"][62725] = 0.02 end
end

do
  local item = MTH_DS_AmmoItems[9456]
  if not item then
    item = {}
    MTH_DS_AmmoItems[9456] = item
  end
  if not item["name"] then item["name"] = 'Glass Shooter' end
  if not item["level"] then item["level"] = 35 end
  if not item["reqlevel"] then item["reqlevel"] = 30 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_02' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 17.9 end
  if not item["speed"] then item["speed"] = 2.9 end
end

do
  local item = MTH_DS_AmmoItems[9487]
  if not item then
    item = {}
    MTH_DS_AmmoItems[9487] = item
  end
  if not item["name"] then item["name"] = 'Hi-tech Supergun' end
  if not item["level"] then item["level"] = 29 end
  if not item["reqlevel"] then item["reqlevel"] = 24 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_06' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 14.3 end
  if not item["speed"] then item["speed"] = 2.3 end
  if not item["drops"] then item["drops"] = {} end
  if item["drops"][6206] == nil then item["drops"][6206] = 0.02 end
  if item["drops"][6207] == nil then item["drops"][6207] = 0.02 end
  if item["drops"][6208] == nil then item["drops"][6208] = 0.02 end
  if item["drops"][6211] == nil then item["drops"][6211] = 0.04 end
  if item["drops"][6212] == nil then item["drops"][6212] = 0.04 end
  if item["drops"][6213] == nil then item["drops"][6213] = 0.02 end
  if item["drops"][6220] == nil then item["drops"][6220] = 0.12 end
  if item["drops"][6223] == nil then item["drops"][6223] = 0.04 end
  if item["drops"][6225] == nil then item["drops"][6225] = 0.06 end
  if item["drops"][6226] == nil then item["drops"][6226] = 0.02 end
  if item["drops"][6227] == nil then item["drops"][6227] = 0.02 end
  if item["drops"][6230] == nil then item["drops"][6230] = 0.04 end
  if item["drops"][6231] == nil then item["drops"][6231] = 0.04 end
  if item["drops"][6232] == nil then item["drops"][6232] = 0.1 end
  if item["drops"][6233] == nil then item["drops"][6233] = 0.04 end
  if item["drops"][6234] == nil then item["drops"][6234] = 0.04 end
  if item["drops"][6329] == nil then item["drops"][6329] = 0.02 end
end

do
  local item = MTH_DS_AmmoItems[10508]
  if not item then
    item = {}
    MTH_DS_AmmoItems[10508] = item
  end
  if not item["name"] then item["name"] = 'Mithril Blunderbuss' end
  if not item["level"] then item["level"] = 41 end
  if not item["reqlevel"] then item["reqlevel"] = 36 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_07' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 17.9 end
  if not item["speed"] then item["speed"] = 2.9 end
end

do
  local item = MTH_DS_AmmoItems[10510]
  if not item then
    item = {}
    MTH_DS_AmmoItems[10510] = item
  end
  if not item["name"] then item["name"] = 'Mithril Heavy-bore Rifle' end
  if not item["level"] then item["level"] = 44 end
  if not item["reqlevel"] then item["reqlevel"] = 39 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_07' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 20.2 end
  if not item["speed"] then item["speed"] = 2.9 end
end

do
  local item = MTH_DS_AmmoItems[10567]
  if not item then
    item = {}
    MTH_DS_AmmoItems[10567] = item
  end
  if not item["name"] then item["name"] = 'Quillshooter' end
  if not item["level"] then item["level"] = 38 end
  if not item["reqlevel"] then item["reqlevel"] = 33 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_01' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 15.9 end
  if not item["speed"] then item["speed"] = 2.8 end
  if not item["drops"] then item["drops"] = {} end
  if item["drops"][7328] == nil then item["drops"][7328] = 0.08 end
  if item["drops"][7329] == nil then item["drops"][7329] = 0.02 end
  if item["drops"][7332] == nil then item["drops"][7332] = 0.02 end
  if item["drops"][7335] == nil then item["drops"][7335] = 0.06 end
  if item["drops"][7337] == nil then item["drops"][7337] = 0.02 end
  if item["drops"][7341] == nil then item["drops"][7341] = 0.04 end
  if item["drops"][7342] == nil then item["drops"][7342] = 0.06 end
  if item["drops"][7345] == nil then item["drops"][7345] = 0.04 end
  if item["drops"][7347] == nil then item["drops"][7347] = 0.02 end
  if item["drops"][7348] == nil then item["drops"][7348] = 0.04 end
  if item["drops"][7349] == nil then item["drops"][7349] = 0.02 end
  if item["drops"][7352] == nil then item["drops"][7352] = 0.04 end
  if item["drops"][7353] == nil then item["drops"][7353] = 0.04 end
end

do
  local item = MTH_DS_AmmoItems[10624]
  if not item then
    item = {}
    MTH_DS_AmmoItems[10624] = item
  end
  if not item["name"] then item["name"] = 'Stinging Bow' end
  if not item["level"] then item["level"] = 47 end
  if not item["reqlevel"] then item["reqlevel"] = 42 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_08' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 24.5 end
  if not item["speed"] then item["speed"] = 2.1 end
  if not item["drops"] then item["drops"] = {} end
  if item["drops"][5224] == nil then item["drops"][5224] = 0.04 end
  if item["drops"][5225] == nil then item["drops"][5225] = 0.03 end
  if item["drops"][5226] == nil then item["drops"][5226] = 0.06 end
  if item["drops"][5228] == nil then item["drops"][5228] = 0.02 end
  if item["drops"][5235] == nil then item["drops"][5235] = 0.03 end
  if item["drops"][5243] == nil then item["drops"][5243] = 0.04 end
  if item["drops"][5256] == nil then item["drops"][5256] = 0.04 end
  if item["drops"][5259] == nil then item["drops"][5259] = 0.02 end
  if item["drops"][5261] == nil then item["drops"][5261] = 0.02 end
  if item["drops"][5263] == nil then item["drops"][5263] = 0.04 end
  if item["drops"][5267] == nil then item["drops"][5267] = 0.04 end
  if item["drops"][5269] == nil then item["drops"][5269] = 0.04 end
  if item["drops"][5270] == nil then item["drops"][5270] = 0.02 end
  if item["drops"][5271] == nil then item["drops"][5271] = 0.02 end
  if item["drops"][5273] == nil then item["drops"][5273] = 0.02 end
  if item["drops"][5277] == nil then item["drops"][5277] = 0.04 end
  if item["drops"][5280] == nil then item["drops"][5280] = 0.02 end
  if item["drops"][5283] == nil then item["drops"][5283] = 0.01 end
  if item["drops"][5291] == nil then item["drops"][5291] = 0.02 end
  if item["drops"][5708] == nil then item["drops"][5708] = 0.02 end
  if item["drops"][8336] == nil then item["drops"][8336] = 0.02 end
  if item["drops"][8438] == nil then item["drops"][8438] = 0.02 end
  if item["drops"][8497] == nil then item["drops"][8497] = 0.02 end
end

do
  local item = MTH_DS_AmmoItems[11021]
  if not item then
    item = {}
    MTH_DS_AmmoItems[11021] = item
  end
  if not item["name"] then item["name"] = 'Monster - Big Sniper Gun' end
  if not item["level"] then item["level"] = 1 end
  if not item["reqlevel"] then item["reqlevel"] = 1 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_03' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 6 end
  if not item["dps"] then item["dps"] = 0.8 end
  if not item["speed"] then item["speed"] = 2 end
end

do
  local item = MTH_DS_AmmoItems[11284]
  if item then
    if not item["vendors"] then item["vendors"] = {} end
    if item["vendors"][734] == nil then item["vendors"][734] = 0 end
    if item["vendors"][1149] == nil then item["vendors"][1149] = 0 end
    if item["vendors"][1285] == nil then item["vendors"][1285] = 0 end
    if item["vendors"][1297] == nil then item["vendors"][1297] = 0 end
    if item["vendors"][1461] == nil then item["vendors"][1461] = 0 end
    if item["vendors"][2084] == nil then item["vendors"][2084] = 0 end
    if item["vendors"][2401] == nil then item["vendors"][2401] = 0 end
    if item["vendors"][2803] == nil then item["vendors"][2803] = 0 end
    if item["vendors"][2806] == nil then item["vendors"][2806] = 0 end
    if item["vendors"][2808] == nil then item["vendors"][2808] = 0 end
    if item["vendors"][2820] == nil then item["vendors"][2820] = 0 end
    if item["vendors"][2908] == nil then item["vendors"][2908] = 0 end
    if item["vendors"][3018] == nil then item["vendors"][3018] = 0 end
    if item["vendors"][3053] == nil then item["vendors"][3053] = 0 end
    if item["vendors"][3313] == nil then item["vendors"][3313] = 0 end
    if item["vendors"][3322] == nil then item["vendors"][3322] = 0 end
    if item["vendors"][3350] == nil then item["vendors"][3350] = 0 end
    if item["vendors"][3541] == nil then item["vendors"][3541] = 0 end
    if item["vendors"][3625] == nil then item["vendors"][3625] = 0 end
    if item["vendors"][4170] == nil then item["vendors"][4170] = 0 end
    if item["vendors"][4241] == nil then item["vendors"][4241] = 0 end
    if item["vendors"][4555] == nil then item["vendors"][4555] = 0 end
    if item["vendors"][4603] == nil then item["vendors"][4603] = 0 end
    if item["vendors"][4889] == nil then item["vendors"][4889] = 0 end
    if item["vendors"][4896] == nil then item["vendors"][4896] = 0 end
    if item["vendors"][5101] == nil then item["vendors"][5101] = 0 end
    if item["vendors"][5123] == nil then item["vendors"][5123] = 0 end
    if item["vendors"][5134] == nil then item["vendors"][5134] = 0 end
    if item["vendors"][7942] == nil then item["vendors"][7942] = 0 end
    if item["vendors"][8131] == nil then item["vendors"][8131] = 0 end
    if item["vendors"][8139] == nil then item["vendors"][8139] = 0 end
    if item["vendors"][8362] == nil then item["vendors"][8362] = 0 end
    if item["vendors"][9320] == nil then item["vendors"][9320] = 0 end
    if item["vendors"][9548] == nil then item["vendors"][9548] = 0 end
    if item["vendors"][9551] == nil then item["vendors"][9551] = 0 end
    if item["vendors"][11038] == nil then item["vendors"][11038] = 0 end
    if item["vendors"][11184] == nil then item["vendors"][11184] = 0 end
    if item["vendors"][11555] == nil then item["vendors"][11555] = 0 end
    if item["vendors"][12021] == nil then item["vendors"][12021] = 0 end
    if item["vendors"][12027] == nil then item["vendors"][12027] = 0 end
    if item["vendors"][12036] == nil then item["vendors"][12036] = 0 end
    if item["vendors"][12246] == nil then item["vendors"][12246] = 0 end
    if item["vendors"][12959] == nil then item["vendors"][12959] = 0 end
    if item["vendors"][12960] == nil then item["vendors"][12960] = 0 end
    if item["vendors"][14624] == nil then item["vendors"][14624] = 0 end
    if item["vendors"][15174] == nil then item["vendors"][15174] = 0 end
    if item["vendors"][21002] == nil then item["vendors"][21002] = 0 end
    if item["vendors"][51656] == nil then item["vendors"][51656] = 0 end
    if item["vendors"][60456] == nil then item["vendors"][60456] = 0 end
    if item["vendors"][60641] == nil then item["vendors"][60641] = 0 end
    if item["vendors"][60646] == nil then item["vendors"][60646] = 0 end
    if item["vendors"][60653] == nil then item["vendors"][60653] = 0 end
    if item["vendors"][60663] == nil then item["vendors"][60663] = 0 end
    if item["vendors"][60766] == nil then item["vendors"][60766] = 0 end
    if item["vendors"][60790] == nil then item["vendors"][60790] = 0 end
    if item["vendors"][61115] == nil then item["vendors"][61115] = 0 end
    if item["vendors"][61140] == nil then item["vendors"][61140] = 0 end
    if item["vendors"][61272] == nil then item["vendors"][61272] = 0 end
    if item["vendors"][61288] == nil then item["vendors"][61288] = 0 end
    if item["vendors"][61369] == nil then item["vendors"][61369] = 0 end
    if item["vendors"][61440] == nil then item["vendors"][61440] = 0 end
    if item["vendors"][61443] == nil then item["vendors"][61443] = 0 end
    if item["vendors"][61445] == nil then item["vendors"][61445] = 0 end
    if item["vendors"][61478] == nil then item["vendors"][61478] = 0 end
    if item["vendors"][61523] == nil then item["vendors"][61523] = 0 end
    if item["vendors"][61563] == nil then item["vendors"][61563] = 0 end
    if item["vendors"][61651] == nil then item["vendors"][61651] = 0 end
    if item["vendors"][61812] == nil then item["vendors"][61812] = 0 end
    if item["vendors"][62086] == nil then item["vendors"][62086] = 0 end
    if item["vendors"][62096] == nil then item["vendors"][62096] = 0 end
    if item["vendors"][62148] == nil then item["vendors"][62148] = 0 end
    if item["vendors"][62403] == nil then item["vendors"][62403] = 0 end
    if item["vendors"][62404] == nil then item["vendors"][62404] = 0 end
    if item["vendors"][62409] == nil then item["vendors"][62409] = 0 end
    if item["vendors"][62436] == nil then item["vendors"][62436] = 0 end
    if item["vendors"][62437] == nil then item["vendors"][62437] = 0 end
    if item["vendors"][62462] == nil then item["vendors"][62462] = 0 end
    if item["vendors"][62469] == nil then item["vendors"][62469] = 0 end
    if item["vendors"][62628] == nil then item["vendors"][62628] = 0 end
    if item["vendors"][65002] == nil then item["vendors"][65002] = 0 end
    if item["vendors"][65003] == nil then item["vendors"][65003] = 0 end
    if item["vendors"][80008] == nil then item["vendors"][80008] = 0 end
    if item["vendors"][80267] == nil then item["vendors"][80267] = 0 end
    if item["vendors"][80808] == nil then item["vendors"][80808] = 0 end
    if item["vendors"][91403] == nil then item["vendors"][91403] = 0 end
    if item["vendors"][91725] == nil then item["vendors"][91725] = 0 end
    if item["vendors"][91868] == nil then item["vendors"][91868] = 0 end
    if item["vendors"][91956] == nil then item["vendors"][91956] = 0 end
    if item["vendors"][92169] == nil then item["vendors"][92169] = 0 end
    if item["vendors"][92177] == nil then item["vendors"][92177] = 0 end
    if item["vendors"][92200] == nil then item["vendors"][92200] = 0 end
    if item["vendors"][92217] == nil then item["vendors"][92217] = 0 end
  end
end

do
  local item = MTH_DS_AmmoItems[11285]
  if item then
    if not item["vendors"] then item["vendors"] = {} end
    if item["vendors"][228] == nil then item["vendors"][228] = 0 end
    if item["vendors"][734] == nil then item["vendors"][734] = 0 end
    if item["vendors"][789] == nil then item["vendors"][789] = 0 end
    if item["vendors"][1149] == nil then item["vendors"][1149] = 0 end
    if item["vendors"][1285] == nil then item["vendors"][1285] = 0 end
    if item["vendors"][1298] == nil then item["vendors"][1298] = 0 end
    if item["vendors"][1455] == nil then item["vendors"][1455] = 0 end
    if item["vendors"][1462] == nil then item["vendors"][1462] = 0 end
    if item["vendors"][2084] == nil then item["vendors"][2084] = 0 end
    if item["vendors"][2286] == nil then item["vendors"][2286] = 0 end
    if item["vendors"][2401] == nil then item["vendors"][2401] = 0 end
    if item["vendors"][2803] == nil then item["vendors"][2803] = 0 end
    if item["vendors"][2806] == nil then item["vendors"][2806] = 0 end
    if item["vendors"][2808] == nil then item["vendors"][2808] = 0 end
    if item["vendors"][2820] == nil then item["vendors"][2820] = 0 end
    if item["vendors"][2839] == nil then item["vendors"][2839] = 0 end
    if item["vendors"][2908] == nil then item["vendors"][2908] = 0 end
    if item["vendors"][3015] == nil then item["vendors"][3015] = 0 end
    if item["vendors"][3313] == nil then item["vendors"][3313] = 0 end
    if item["vendors"][3350] == nil then item["vendors"][3350] = 0 end
    if item["vendors"][3410] == nil then item["vendors"][3410] = 0 end
    if item["vendors"][3541] == nil then item["vendors"][3541] = 0 end
    if item["vendors"][3625] == nil then item["vendors"][3625] = 0 end
    if item["vendors"][4170] == nil then item["vendors"][4170] = 0 end
    if item["vendors"][4173] == nil then item["vendors"][4173] = 0 end
    if item["vendors"][4241] == nil then item["vendors"][4241] = 0 end
    if item["vendors"][4555] == nil then item["vendors"][4555] = 0 end
    if item["vendors"][4604] == nil then item["vendors"][4604] = 0 end
    if item["vendors"][4892] == nil then item["vendors"][4892] = 0 end
    if item["vendors"][4896] == nil then item["vendors"][4896] = 0 end
    if item["vendors"][5101] == nil then item["vendors"][5101] = 0 end
    if item["vendors"][5122] == nil then item["vendors"][5122] = 0 end
    if item["vendors"][5134] == nil then item["vendors"][5134] = 0 end
    if item["vendors"][6028] == nil then item["vendors"][6028] = 0 end
    if item["vendors"][7942] == nil then item["vendors"][7942] = 0 end
    if item["vendors"][8139] == nil then item["vendors"][8139] = 0 end
    if item["vendors"][8362] == nil then item["vendors"][8362] = 0 end
    if item["vendors"][9320] == nil then item["vendors"][9320] = 0 end
    if item["vendors"][9548] == nil then item["vendors"][9548] = 0 end
    if item["vendors"][9551] == nil then item["vendors"][9551] = 0 end
    if item["vendors"][9552] == nil then item["vendors"][9552] = 0 end
    if item["vendors"][9555] == nil then item["vendors"][9555] = 0 end
    if item["vendors"][11038] == nil then item["vendors"][11038] = 0 end
    if item["vendors"][11555] == nil then item["vendors"][11555] = 0 end
    if item["vendors"][12021] == nil then item["vendors"][12021] = 0 end
    if item["vendors"][12027] == nil then item["vendors"][12027] = 0 end
    if item["vendors"][12036] == nil then item["vendors"][12036] = 0 end
    if item["vendors"][12246] == nil then item["vendors"][12246] = 0 end
    if item["vendors"][12959] == nil then item["vendors"][12959] = 0 end
    if item["vendors"][12960] == nil then item["vendors"][12960] = 0 end
    if item["vendors"][14301] == nil then item["vendors"][14301] = 0 end
    if item["vendors"][14624] == nil then item["vendors"][14624] = 0 end
    if item["vendors"][15174] == nil then item["vendors"][15174] = 0 end
    if item["vendors"][17598] == nil then item["vendors"][17598] = 0 end
    if item["vendors"][21002] == nil then item["vendors"][21002] = 0 end
    if item["vendors"][51656] == nil then item["vendors"][51656] = 0 end
    if item["vendors"][60456] == nil then item["vendors"][60456] = 0 end
    if item["vendors"][60641] == nil then item["vendors"][60641] = 0 end
    if item["vendors"][60646] == nil then item["vendors"][60646] = 0 end
    if item["vendors"][60653] == nil then item["vendors"][60653] = 0 end
    if item["vendors"][60663] == nil then item["vendors"][60663] = 0 end
    if item["vendors"][60766] == nil then item["vendors"][60766] = 0 end
    if item["vendors"][60790] == nil then item["vendors"][60790] = 0 end
    if item["vendors"][60803] == nil then item["vendors"][60803] = 0 end
    if item["vendors"][61115] == nil then item["vendors"][61115] = 0 end
    if item["vendors"][61140] == nil then item["vendors"][61140] = 0 end
    if item["vendors"][61272] == nil then item["vendors"][61272] = 0 end
    if item["vendors"][61288] == nil then item["vendors"][61288] = 0 end
    if item["vendors"][61369] == nil then item["vendors"][61369] = 0 end
    if item["vendors"][61440] == nil then item["vendors"][61440] = 0 end
    if item["vendors"][61443] == nil then item["vendors"][61443] = 0 end
    if item["vendors"][61478] == nil then item["vendors"][61478] = 0 end
    if item["vendors"][61523] == nil then item["vendors"][61523] = 0 end
    if item["vendors"][61563] == nil then item["vendors"][61563] = 0 end
    if item["vendors"][61651] == nil then item["vendors"][61651] = 0 end
    if item["vendors"][61812] == nil then item["vendors"][61812] = 0 end
    if item["vendors"][62086] == nil then item["vendors"][62086] = 0 end
    if item["vendors"][62096] == nil then item["vendors"][62096] = 0 end
    if item["vendors"][62148] == nil then item["vendors"][62148] = 0 end
    if item["vendors"][62307] == nil then item["vendors"][62307] = 0 end
    if item["vendors"][62402] == nil then item["vendors"][62402] = 0 end
    if item["vendors"][62404] == nil then item["vendors"][62404] = 0 end
    if item["vendors"][62409] == nil then item["vendors"][62409] = 0 end
    if item["vendors"][62436] == nil then item["vendors"][62436] = 0 end
    if item["vendors"][62437] == nil then item["vendors"][62437] = 0 end
    if item["vendors"][62462] == nil then item["vendors"][62462] = 0 end
    if item["vendors"][62469] == nil then item["vendors"][62469] = 0 end
    if item["vendors"][62628] == nil then item["vendors"][62628] = 0 end
    if item["vendors"][62739] == nil then item["vendors"][62739] = 0 end
    if item["vendors"][65002] == nil then item["vendors"][65002] = 0 end
    if item["vendors"][65003] == nil then item["vendors"][65003] = 0 end
    if item["vendors"][80267] == nil then item["vendors"][80267] = 0 end
    if item["vendors"][80808] == nil then item["vendors"][80808] = 0 end
    if item["vendors"][91403] == nil then item["vendors"][91403] = 0 end
    if item["vendors"][91725] == nil then item["vendors"][91725] = 0 end
    if item["vendors"][91868] == nil then item["vendors"][91868] = 0 end
    if item["vendors"][91956] == nil then item["vendors"][91956] = 0 end
    if item["vendors"][92169] == nil then item["vendors"][92169] = 0 end
    if item["vendors"][92177] == nil then item["vendors"][92177] = 0 end
    if item["vendors"][92200] == nil then item["vendors"][92200] = 0 end
  end
end

do
  local item = MTH_DS_AmmoItems[11303]
  if not item then
    item = {}
    MTH_DS_AmmoItems[11303] = item
  end
  if not item["name"] then item["name"] = 'Fine Shortbow' end
  if not item["level"] then item["level"] = 16 end
  if not item["reqlevel"] then item["reqlevel"] = 11 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_07' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 6.2 end
  if not item["speed"] then item["speed"] = 1.7 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][150] == nil then item["vendors"][150] = 0 end
  if item["vendors"][1198] == nil then item["vendors"][1198] = 0 end
  if item["vendors"][1298] == nil then item["vendors"][1298] = 0 end
  if item["vendors"][1455] == nil then item["vendors"][1455] = 0 end
  if item["vendors"][1859] == nil then item["vendors"][1859] = 0 end
  if item["vendors"][3015] == nil then item["vendors"][3015] = 0 end
  if item["vendors"][3410] == nil then item["vendors"][3410] = 0 end
  if item["vendors"][4173] == nil then item["vendors"][4173] = 0 end
  if item["vendors"][4604] == nil then item["vendors"][4604] = 0 end
  if item["vendors"][5122] == nil then item["vendors"][5122] = 0 end
  if item["vendors"][14846] == nil then item["vendors"][14846] = 0 end
end

do
  local item = MTH_DS_AmmoItems[11304]
  if not item then
    item = {}
    MTH_DS_AmmoItems[11304] = item
  end
  if not item["name"] then item["name"] = 'Fine Longbow' end
  if not item["level"] then item["level"] = 19 end
  if not item["reqlevel"] then item["reqlevel"] = 14 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_02' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 7.4 end
  if not item["speed"] then item["speed"] = 2.7 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][228] == nil then item["vendors"][228] = 0 end
  if item["vendors"][1459] == nil then item["vendors"][1459] = 0 end
  if item["vendors"][1668] == nil then item["vendors"][1668] = 0 end
  if item["vendors"][1687] == nil then item["vendors"][1687] = 0 end
  if item["vendors"][3488] == nil then item["vendors"][3488] = 0 end
  if item["vendors"][3534] == nil then item["vendors"][3534] = 0 end
  if item["vendors"][9549] == nil then item["vendors"][9549] = 0 end
  if item["vendors"][9551] == nil then item["vendors"][9551] = 0 end
  if item["vendors"][9553] == nil then item["vendors"][9553] = 0 end
end

do
  local item = MTH_DS_AmmoItems[11305]
  if not item then
    item = {}
    MTH_DS_AmmoItems[11305] = item
  end
  if not item["name"] then item["name"] = 'Dense Shortbow' end
  if not item["level"] then item["level"] = 35 end
  if not item["reqlevel"] then item["reqlevel"] = 30 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_07' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 14.2 end
  if not item["speed"] then item["speed"] = 1.9 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][2839] == nil then item["vendors"][2839] = 0 end
  if item["vendors"][3951] == nil then item["vendors"][3951] = 0 end
  if item["vendors"][4892] == nil then item["vendors"][4892] = 0 end
  if item["vendors"][9551] == nil then item["vendors"][9551] = 0 end
  if item["vendors"][9552] == nil then item["vendors"][9552] = 0 end
  if item["vendors"][9555] == nil then item["vendors"][9555] = 0 end
  if item["vendors"][14301] == nil then item["vendors"][14301] = 0 end
  if item["vendors"][14846] == nil then item["vendors"][14846] = 0 end
end

do
  local item = MTH_DS_AmmoItems[11306]
  if not item then
    item = {}
    MTH_DS_AmmoItems[11306] = item
  end
  if not item["name"] then item["name"] = 'Sturdy Recurve' end
  if not item["level"] then item["level"] = 32 end
  if not item["reqlevel"] then item["reqlevel"] = 27 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_07' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 13 end
  if not item["speed"] then item["speed"] = 2.2 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][1298] == nil then item["vendors"][1298] = 0 end
  if item["vendors"][1455] == nil then item["vendors"][1455] = 0 end
  if item["vendors"][3015] == nil then item["vendors"][3015] = 0 end
  if item["vendors"][4173] == nil then item["vendors"][4173] = 0 end
  if item["vendors"][4604] == nil then item["vendors"][4604] = 0 end
  if item["vendors"][5122] == nil then item["vendors"][5122] = 0 end
  if item["vendors"][14846] == nil then item["vendors"][14846] = 0 end
end

do
  local item = MTH_DS_AmmoItems[11307]
  if not item then
    item = {}
    MTH_DS_AmmoItems[11307] = item
  end
  if not item["name"] then item["name"] = 'Massive Longbow' end
  if not item["level"] then item["level"] = 47 end
  if not item["reqlevel"] then item["reqlevel"] = 42 end
  if not item["icon"] then item["icon"] = 'GenBow_twow3F' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 22 end
  if not item["speed"] then item["speed"] = 2.8 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][1298] == nil then item["vendors"][1298] = 0 end
  if item["vendors"][1455] == nil then item["vendors"][1455] = 0 end
  if item["vendors"][3015] == nil then item["vendors"][3015] = 0 end
  if item["vendors"][4604] == nil then item["vendors"][4604] = 0 end
  if item["vendors"][5122] == nil then item["vendors"][5122] = 0 end
end

do
  local item = MTH_DS_AmmoItems[11308]
  if not item then
    item = {}
    MTH_DS_AmmoItems[11308] = item
  end
  if not item["name"] then item["name"] = 'Sylvan Shortbow' end
  if not item["level"] then item["level"] = 49 end
  if not item["reqlevel"] then item["reqlevel"] = 44 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_07' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 22.8 end
  if not item["speed"] then item["speed"] = 2 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][4173] == nil then item["vendors"][4173] = 0 end
  if item["vendors"][9548] == nil then item["vendors"][9548] = 0 end
  if item["vendors"][12029] == nil then item["vendors"][12029] = 0 end
  if item["vendors"][14846] == nil then item["vendors"][14846] = 0 end
end

do
  local item = MTH_DS_AmmoItems[11628]
  if not item then
    item = {}
    MTH_DS_AmmoItems[11628] = item
  end
  if not item["name"] then item["name"] = "Houndmaster's Bow" end
  if not item["level"] then item["level"] = 53 end
  if not item["reqlevel"] then item["reqlevel"] = 48 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_04' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 27.2 end
  if not item["speed"] then item["speed"] = 1.8 end
end

do
  local item = MTH_DS_AmmoItems[11629]
  if not item then
    item = {}
    MTH_DS_AmmoItems[11629] = item
  end
  if not item["name"] then item["name"] = "Houndmaster's Rifle" end
  if not item["level"] then item["level"] = 53 end
  if not item["reqlevel"] then item["reqlevel"] = 48 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_07' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 27.4 end
  if not item["speed"] then item["speed"] = 2.3 end
end

do
  local item = MTH_DS_AmmoItems[11630]
  if item then
    if not item["drops"] then item["drops"] = {} end
    if item["drops"][9025] == nil then item["drops"][9025] = 16 end
  end
end

do
  local item = MTH_DS_AmmoItems[12446]
  if not item then
    item = {}
    MTH_DS_AmmoItems[12446] = item
  end
  if not item["name"] then item["name"] = 'Anvilmar Musket' end
  if not item["level"] then item["level"] = 5 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_07' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 5 end
  if not item["dps"] then item["dps"] = 2.2 end
  if not item["speed"] then item["speed"] = 2.7 end
end

do
  local item = MTH_DS_AmmoItems[12447]
  if not item then
    item = {}
    MTH_DS_AmmoItems[12447] = item
  end
  if not item["name"] then item["name"] = 'Thistlewood Bow' end
  if not item["level"] then item["level"] = 5 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_02' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 5 end
  if not item["dps"] then item["dps"] = 2.2 end
  if not item["speed"] then item["speed"] = 2.3 end
end

do
  local item = MTH_DS_AmmoItems[12448]
  if not item then
    item = {}
    MTH_DS_AmmoItems[12448] = item
  end
  if not item["name"] then item["name"] = 'Light Hunting Rifle' end
  if not item["level"] then item["level"] = 5 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_07' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 5 end
  if not item["dps"] then item["dps"] = 2.1 end
  if not item["speed"] then item["speed"] = 1.9 end
end

do
  local item = MTH_DS_AmmoItems[12449]
  if not item then
    item = {}
    MTH_DS_AmmoItems[12449] = item
  end
  if not item["name"] then item["name"] = 'Primitive Bow' end
  if not item["level"] then item["level"] = 5 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_02' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 5 end
  if not item["dps"] then item["dps"] = 2.2 end
  if not item["speed"] then item["speed"] = 2.7 end
end

do
  local item = MTH_DS_AmmoItems[12523]
  if not item then
    item = {}
    MTH_DS_AmmoItems[12523] = item
  end
  if not item["name"] then item["name"] = 'Monster - Gun, Silver Musket' end
  if not item["level"] then item["level"] = 1 end
  if not item["reqlevel"] then item["reqlevel"] = 1 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_03' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 6 end
  if not item["dps"] then item["dps"] = 0.8 end
  if not item["speed"] then item["speed"] = 2 end
end

do
  local item = MTH_DS_AmmoItems[12651]
  if not item then
    item = {}
    MTH_DS_AmmoItems[12651] = item
  end
  if not item["name"] then item["name"] = 'Blackcrow' end
  if not item["level"] then item["level"] = 59 end
  if not item["reqlevel"] then item["reqlevel"] = 54 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Crossbow_04' end
  if not item["subtype"] then item["subtype"] = 'crossbow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 30.3 end
  if not item["speed"] then item["speed"] = 3.2 end
end

do
  local item = MTH_DS_AmmoItems[12653]
  if not item then
    item = {}
    MTH_DS_AmmoItems[12653] = item
  end
  if not item["name"] then item["name"] = 'Riphook' end
  if not item["level"] then item["level"] = 59 end
  if not item["reqlevel"] then item["reqlevel"] = 54 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_08' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 30.2 end
  if not item["speed"] then item["speed"] = 2.2 end
end

do
  local item = MTH_DS_AmmoItems[12654]
  if item then
    if not item["drops"] then item["drops"] = {} end
    if item["drops"][9236] == nil then item["drops"][9236] = 100 end
  end
end

do
  local item = MTH_DS_AmmoItems[13019]
  if not item then
    item = {}
    MTH_DS_AmmoItems[13019] = item
  end
  if not item["name"] then item["name"] = 'Harpyclaw Short Bow' end
  if not item["level"] then item["level"] = 32 end
  if not item["reqlevel"] then item["reqlevel"] = 27 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_11' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 16.1 end
  if not item["speed"] then item["speed"] = 1.8 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][2852] == nil then item["objects"][2852] = 0.01 end
  if item["objects"][2855] == nil then item["objects"][2855] = 0.01 end
  if item["objects"][2857] == nil then item["objects"][2857] = 0.01 end
  if item["objects"][4095] == nil then item["objects"][4095] = 0.01 end
  if item["objects"][4096] == nil then item["objects"][4096] = 0.01 end
  if item["objects"][4149] == nil then item["objects"][4149] = 0.01 end
  if item["objects"][75296] == nil then item["objects"][75296] = 0.01 end
  if item["objects"][75297] == nil then item["objects"][75297] = 0.01 end
  if item["objects"][75299] == nil then item["objects"][75299] = 0.01 end
  if item["objects"][75300] == nil then item["objects"][75300] = 0.01 end
  if item["objects"][105570] == nil then item["objects"][105570] = 0.01 end
  if item["objects"][105578] == nil then item["objects"][105578] = 0.01 end
  if item["objects"][105579] == nil then item["objects"][105579] = 0.01 end
  if item["objects"][105581] == nil then item["objects"][105581] = 0.01 end
  if item["objects"][153462] == nil then item["objects"][153462] = 0.03 end
end

do
  local item = MTH_DS_AmmoItems[13020]
  if not item then
    item = {}
    MTH_DS_AmmoItems[13020] = item
  end
  if not item["name"] then item["name"] = 'Skystriker Bow' end
  if not item["level"] then item["level"] = 39 end
  if not item["reqlevel"] then item["reqlevel"] = 34 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_11' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 20.7 end
  if not item["speed"] then item["speed"] = 2.1 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][2855] == nil then item["objects"][2855] = 0.01 end
  if item["objects"][2857] == nil then item["objects"][2857] = 0.01 end
  if item["objects"][4149] == nil then item["objects"][4149] = 0.01 end
  if item["objects"][105570] == nil then item["objects"][105570] = 0.01 end
  if item["objects"][105578] == nil then item["objects"][105578] = 0.01 end
  if item["objects"][105579] == nil then item["objects"][105579] = 0.01 end
  if item["objects"][105581] == nil then item["objects"][105581] = 0.01 end
  if item["objects"][153462] == nil then item["objects"][153462] = 0.03 end
end

do
  local item = MTH_DS_AmmoItems[13021]
  if not item then
    item = {}
    MTH_DS_AmmoItems[13021] = item
  end
  if not item["name"] then item["name"] = 'Needle Threader' end
  if not item["level"] then item["level"] = 47 end
  if not item["reqlevel"] then item["reqlevel"] = 42 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_08' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 24.5 end
  if not item["speed"] then item["speed"] = 2 end
  if not item["drops"] then item["drops"] = {} end
  if item["drops"][1653] == nil then item["drops"][1653] = 3.85 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][4149] == nil then item["objects"][4149] = 0.01 end
  if item["objects"][153451] == nil then item["objects"][153451] = 0.01 end
  if item["objects"][153453] == nil then item["objects"][153453] = 0.01 end
end

do
  local item = MTH_DS_AmmoItems[13022]
  if not item then
    item = {}
    MTH_DS_AmmoItems[13022] = item
  end
  if not item["name"] then item["name"] = 'Gryphonwing Long Bow' end
  if not item["level"] then item["level"] = 55 end
  if not item["reqlevel"] then item["reqlevel"] = 50 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_11' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 28.3 end
  if not item["speed"] then item["speed"] = 2.7 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][153451] == nil then item["objects"][153451] = 0.01 end
  if item["objects"][153453] == nil then item["objects"][153453] = 0.01 end
  if item["objects"][153454] == nil then item["objects"][153454] = 0.01 end
  if item["objects"][153463] == nil then item["objects"][153463] = 0.01 end
  if item["objects"][153464] == nil then item["objects"][153464] = 0.01 end
  if item["objects"][153468] == nil then item["objects"][153468] = 0.01 end
  if item["objects"][153469] == nil then item["objects"][153469] = 0.01 end
  if item["objects"][160836] == nil then item["objects"][160836] = 0.1 end
end

do
  local item = MTH_DS_AmmoItems[13023]
  if not item then
    item = {}
    MTH_DS_AmmoItems[13023] = item
  end
  if not item["name"] then item["name"] = 'Eaglehorn Long Bow' end
  if not item["level"] then item["level"] = 63 end
  if not item["reqlevel"] then item["reqlevel"] = 58 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_11' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 32.2 end
  if not item["speed"] then item["speed"] = 1.8 end
end

do
  local item = MTH_DS_AmmoItems[13037]
  if not item then
    item = {}
    MTH_DS_AmmoItems[13037] = item
  end
  if not item["name"] then item["name"] = 'Crystalpine Stinger' end
  if not item["level"] then item["level"] = 32 end
  if not item["reqlevel"] then item["reqlevel"] = 27 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Crossbow_04' end
  if not item["subtype"] then item["subtype"] = 'crossbow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 15.9 end
  if not item["speed"] then item["speed"] = 2.8 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][2852] == nil then item["objects"][2852] = 0.01 end
  if item["objects"][2855] == nil then item["objects"][2855] = 0.01 end
  if item["objects"][2857] == nil then item["objects"][2857] = 0.01 end
  if item["objects"][3703] == nil then item["objects"][3703] = 0.01 end
  if item["objects"][4095] == nil then item["objects"][4095] = 0.01 end
  if item["objects"][4096] == nil then item["objects"][4096] = 0.01 end
  if item["objects"][4149] == nil then item["objects"][4149] = 0.01 end
  if item["objects"][75296] == nil then item["objects"][75296] = 0.01 end
  if item["objects"][75297] == nil then item["objects"][75297] = 0.01 end
  if item["objects"][75299] == nil then item["objects"][75299] = 0.01 end
  if item["objects"][75300] == nil then item["objects"][75300] = 0.01 end
  if item["objects"][105570] == nil then item["objects"][105570] = 0.01 end
  if item["objects"][105578] == nil then item["objects"][105578] = 0.01 end
  if item["objects"][105579] == nil then item["objects"][105579] = 0.01 end
  if item["objects"][105581] == nil then item["objects"][105581] = 0.01 end
  if item["objects"][153462] == nil then item["objects"][153462] = 0.03 end
end

do
  local item = MTH_DS_AmmoItems[13038]
  if not item then
    item = {}
    MTH_DS_AmmoItems[13038] = item
  end
  if not item["name"] then item["name"] = 'Swiftwind' end
  if not item["level"] then item["level"] = 40 end
  if not item["reqlevel"] then item["reqlevel"] = 35 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Crossbow_04' end
  if not item["subtype"] then item["subtype"] = 'crossbow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 21.3 end
  if not item["speed"] then item["speed"] = 2 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][2855] == nil then item["objects"][2855] = 0.01 end
  if item["objects"][2857] == nil then item["objects"][2857] = 0.01 end
  if item["objects"][4149] == nil then item["objects"][4149] = 0.01 end
  if item["objects"][105570] == nil then item["objects"][105570] = 0.01 end
  if item["objects"][105578] == nil then item["objects"][105578] = 0.01 end
  if item["objects"][105579] == nil then item["objects"][105579] = 0.01 end
  if item["objects"][105581] == nil then item["objects"][105581] = 0.01 end
  if item["objects"][153451] == nil then item["objects"][153451] = 0.01 end
  if item["objects"][153462] == nil then item["objects"][153462] = 0.04 end
end

do
  local item = MTH_DS_AmmoItems[13039]
  if not item then
    item = {}
    MTH_DS_AmmoItems[13039] = item
  end
  if not item["name"] then item["name"] = 'Skull Splitting Crossbow' end
  if not item["level"] then item["level"] = 48 end
  if not item["reqlevel"] then item["reqlevel"] = 43 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Crossbow_04' end
  if not item["subtype"] then item["subtype"] = 'crossbow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 25.2 end
  if not item["speed"] then item["speed"] = 2.6 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][4149] == nil then item["objects"][4149] = 0.01 end
  if item["objects"][153451] == nil then item["objects"][153451] = 0.01 end
  if item["objects"][153453] == nil then item["objects"][153453] = 0.01 end
end

do
  local item = MTH_DS_AmmoItems[13040]
  if not item then
    item = {}
    MTH_DS_AmmoItems[13040] = item
  end
  if not item["name"] then item["name"] = 'Heartseeking Crossbow' end
  if not item["level"] then item["level"] = 56 end
  if not item["reqlevel"] then item["reqlevel"] = 51 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Crossbow_04' end
  if not item["subtype"] then item["subtype"] = 'crossbow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 28.9 end
  if not item["speed"] then item["speed"] = 3.1 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][153453] == nil then item["objects"][153453] = 0.01 end
  if item["objects"][153454] == nil then item["objects"][153454] = 0.01 end
  if item["objects"][153462] == nil then item["objects"][153462] = 0.02 end
end

do
  local item = MTH_DS_AmmoItems[13136]
  if not item then
    item = {}
    MTH_DS_AmmoItems[13136] = item
  end
  if not item["name"] then item["name"] = "Lil Timmy's Peashooter" end
  if not item["level"] then item["level"] = 21 end
  if not item["reqlevel"] then item["reqlevel"] = 16 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_08' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 11 end
  if not item["speed"] then item["speed"] = 2.6 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][2849] == nil then item["objects"][2849] = 0.01 end
  if item["objects"][2850] == nil then item["objects"][2850] = 0.01 end
  if item["objects"][2852] == nil then item["objects"][2852] = 0.01 end
  if item["objects"][2855] == nil then item["objects"][2855] = 0.01 end
  if item["objects"][3714] == nil then item["objects"][3714] = 0.01 end
  if item["objects"][3715] == nil then item["objects"][3715] = 0.01 end
  if item["objects"][4095] == nil then item["objects"][4095] = 0.01 end
  if item["objects"][4096] == nil then item["objects"][4096] = 0.01 end
  if item["objects"][74447] == nil then item["objects"][74447] = 0.01 end
  if item["objects"][74448] == nil then item["objects"][74448] = 0.01 end
  if item["objects"][75295] == nil then item["objects"][75295] = 0.01 end
  if item["objects"][75296] == nil then item["objects"][75296] = 0.01 end
  if item["objects"][75297] == nil then item["objects"][75297] = 0.01 end
  if item["objects"][75298] == nil then item["objects"][75298] = 0.01 end
  if item["objects"][75299] == nil then item["objects"][75299] = 0.01 end
  if item["objects"][75300] == nil then item["objects"][75300] = 0.01 end
  if item["objects"][105570] == nil then item["objects"][105570] = 0.01 end
  if item["objects"][105578] == nil then item["objects"][105578] = 0.01 end
  if item["objects"][105579] == nil then item["objects"][105579] = 0.01 end
  if item["objects"][106319] == nil then item["objects"][106319] = 0.01 end
  if item["objects"][111095] == nil then item["objects"][111095] = 0.01 end
  if item["objects"][153462] == nil then item["objects"][153462] = 0.01 end
end

do
  local item = MTH_DS_AmmoItems[13137]
  if not item then
    item = {}
    MTH_DS_AmmoItems[13137] = item
  end
  if not item["name"] then item["name"] = 'Ironweaver' end
  if not item["level"] then item["level"] = 34 end
  if not item["reqlevel"] then item["reqlevel"] = 29 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_08' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 17.3 end
  if not item["speed"] then item["speed"] = 2.6 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][2852] == nil then item["objects"][2852] = 0.01 end
  if item["objects"][2855] == nil then item["objects"][2855] = 0.01 end
  if item["objects"][2857] == nil then item["objects"][2857] = 0.01 end
  if item["objects"][4095] == nil then item["objects"][4095] = 0.01 end
  if item["objects"][4096] == nil then item["objects"][4096] = 0.01 end
  if item["objects"][4149] == nil then item["objects"][4149] = 0.01 end
  if item["objects"][75296] == nil then item["objects"][75296] = 0.01 end
  if item["objects"][75297] == nil then item["objects"][75297] = 0.01 end
  if item["objects"][75299] == nil then item["objects"][75299] = 0.01 end
  if item["objects"][75300] == nil then item["objects"][75300] = 0.01 end
  if item["objects"][105570] == nil then item["objects"][105570] = 0.01 end
  if item["objects"][105578] == nil then item["objects"][105578] = 0.01 end
  if item["objects"][105579] == nil then item["objects"][105579] = 0.01 end
  if item["objects"][105581] == nil then item["objects"][105581] = 0.01 end
  if item["objects"][153462] == nil then item["objects"][153462] = 0.02 end
end

do
  local item = MTH_DS_AmmoItems[13138]
  if not item then
    item = {}
    MTH_DS_AmmoItems[13138] = item
  end
  if not item["name"] then item["name"] = 'The Silencer' end
  if not item["level"] then item["level"] = 42 end
  if not item["reqlevel"] then item["reqlevel"] = 37 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_08' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 22.3 end
  if not item["speed"] then item["speed"] = 2.8 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][2855] == nil then item["objects"][2855] = 0.01 end
  if item["objects"][2857] == nil then item["objects"][2857] = 0.01 end
  if item["objects"][4149] == nil then item["objects"][4149] = 0.01 end
  if item["objects"][105570] == nil then item["objects"][105570] = 0.01 end
  if item["objects"][105578] == nil then item["objects"][105578] = 0.01 end
  if item["objects"][105579] == nil then item["objects"][105579] = 0.01 end
  if item["objects"][105581] == nil then item["objects"][105581] = 0.01 end
  if item["objects"][153451] == nil then item["objects"][153451] = 0.01 end
end

do
  local item = MTH_DS_AmmoItems[13139]
  if not item then
    item = {}
    MTH_DS_AmmoItems[13139] = item
  end
  if not item["name"] then item["name"] = 'Guttbuster' end
  if not item["level"] then item["level"] = 50 end
  if not item["reqlevel"] then item["reqlevel"] = 45 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_08' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 26.1 end
  if not item["speed"] then item["speed"] = 2.7 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][4149] == nil then item["objects"][4149] = 0.01 end
  if item["objects"][153451] == nil then item["objects"][153451] = 0.01 end
  if item["objects"][153453] == nil then item["objects"][153453] = 0.01 end
  if item["objects"][153454] == nil then item["objects"][153454] = 0.01 end
end

do
  local item = MTH_DS_AmmoItems[13146]
  if not item then
    item = {}
    MTH_DS_AmmoItems[13146] = item
  end
  if not item["name"] then item["name"] = 'Shell Launcher Shotgun' end
  if not item["level"] then item["level"] = 58 end
  if not item["reqlevel"] then item["reqlevel"] = 53 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_08' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 29.8 end
  if not item["speed"] then item["speed"] = 2.3 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][153453] == nil then item["objects"][153453] = 0.01 end
  if item["objects"][153454] == nil then item["objects"][153454] = 0.01 end
  if item["objects"][153462] == nil then item["objects"][153462] = 0.02 end
end

do
  local item = MTH_DS_AmmoItems[13147]
  if not item then
    item = {}
    MTH_DS_AmmoItems[13147] = item
  end
  if not item["name"] then item["name"] = 'Monster - Bow, White' end
  if not item["level"] then item["level"] = 1 end
  if not item["reqlevel"] then item["reqlevel"] = 1 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_05' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 6 end
  if not item["dps"] then item["dps"] = 0.8 end
  if not item["speed"] then item["speed"] = 2 end
end

do
  local item = MTH_DS_AmmoItems[13175]
  if not item then
    item = {}
    MTH_DS_AmmoItems[13175] = item
  end
  if not item["name"] then item["name"] = "Voone's Twitchbow" end
  if not item["level"] then item["level"] = 60 end
  if not item["reqlevel"] then item["reqlevel"] = 55 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_10' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 27.8 end
  if not item["speed"] then item["speed"] = 1.6 end
  if not item["drops"] then item["drops"] = {} end
  if item["drops"][9237] == nil then item["drops"][9237] = 1 end
end

do
  local item = MTH_DS_AmmoItems[13248]
  if not item then
    item = {}
    MTH_DS_AmmoItems[13248] = item
  end
  if not item["name"] then item["name"] = 'Burstshot Harquebus' end
  if not item["level"] then item["level"] = 56 end
  if not item["reqlevel"] then item["reqlevel"] = 51 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_06' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 28.8 end
  if not item["speed"] then item["speed"] = 2.6 end
end

do
  local item = MTH_DS_AmmoItems[13377]
  if item then
    if not item["drops"] then item["drops"] = {} end
    if item["drops"][10997] == nil then item["drops"][10997] = 100 end
  end
end

do
  local item = MTH_DS_AmmoItems[13380]
  if not item then
    item = {}
    MTH_DS_AmmoItems[13380] = item
  end
  if not item["name"] then item["name"] = "Willey's Portable Howitzer" end
  if not item["level"] then item["level"] = 61 end
  if not item["reqlevel"] then item["reqlevel"] = 56 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_07' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 31.2 end
  if not item["speed"] then item["speed"] = 2.9 end
end

do
  local item = MTH_DS_AmmoItems[13474]
  if not item then
    item = {}
    MTH_DS_AmmoItems[13474] = item
  end
  if not item["name"] then item["name"] = "Farmer Dalson's Shotgun" end
  if not item["level"] then item["level"] = 56 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_04' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 25.8 end
  if not item["speed"] then item["speed"] = 1.9 end
end

do
  local item = MTH_DS_AmmoItems[13824]
  if not item then
    item = {}
    MTH_DS_AmmoItems[13824] = item
  end
  if not item["name"] then item["name"] = 'Recurve Long Bow' end
  if not item["level"] then item["level"] = 55 end
  if not item["reqlevel"] then item["reqlevel"] = 45 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_02' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 6 end
  if not item["dps"] then item["dps"] = 15.2 end
  if not item["speed"] then item["speed"] = 2.5 end
  if not item["drops"] then item["drops"] = {} end
  if item["drops"][68] == nil then item["drops"][68] = 0.46 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][153462] == nil then item["objects"][153462] = 0.03 end
  if item["objects"][176224] == nil then item["objects"][176224] = 2.3 end
end

do
  local item = MTH_DS_AmmoItems[13825]
  if not item then
    item = {}
    MTH_DS_AmmoItems[13825] = item
  end
  if not item["name"] then item["name"] = 'Primed Musket' end
  if not item["level"] then item["level"] = 57 end
  if not item["reqlevel"] then item["reqlevel"] = 52 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_01' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 6 end
  if not item["dps"] then item["dps"] = 15.8 end
  if not item["speed"] then item["speed"] = 1.8 end
  if not item["drops"] then item["drops"] = {} end
  if item["drops"][68] == nil then item["drops"][68] = 0.7 end
  if item["drops"][4624] == nil then item["drops"][4624] = 0.74 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][153462] == nil then item["objects"][153462] = 0.02 end
  if item["objects"][176224] == nil then item["objects"][176224] = 2.5 end
end

do
  local item = MTH_DS_AmmoItems[13923]
  if not item then
    item = {}
    MTH_DS_AmmoItems[13923] = item
  end
  if not item["name"] then item["name"] = 'Monster - Gun, Tauren Blade Silver' end
  if not item["level"] then item["level"] = 1 end
  if not item["reqlevel"] then item["reqlevel"] = 1 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_03' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 6 end
  if not item["dps"] then item["dps"] = 0.8 end
  if not item["speed"] then item["speed"] = 2 end
end

do
  local item = MTH_DS_AmmoItems[13924]
  if not item then
    item = {}
    MTH_DS_AmmoItems[13924] = item
  end
  if not item["name"] then item["name"] = 'Monster - Gun, Tauren Scope Blade Feathered Silver Deluxe' end
  if not item["level"] then item["level"] = 1 end
  if not item["reqlevel"] then item["reqlevel"] = 1 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_03' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 6 end
  if not item["dps"] then item["dps"] = 0.8 end
  if not item["speed"] then item["speed"] = 2 end
end

do
  local item = MTH_DS_AmmoItems[14105]
  if not item then
    item = {}
    MTH_DS_AmmoItems[14105] = item
  end
  if not item["name"] then item["name"] = 'Monster - Bow, C01/B02 White' end
  if not item["level"] then item["level"] = 1 end
  if not item["reqlevel"] then item["reqlevel"] = 1 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_05' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 6 end
  if not item["dps"] then item["dps"] = 0.8 end
  if not item["speed"] then item["speed"] = 2 end
end

do
  local item = MTH_DS_AmmoItems[14118]
  if not item then
    item = {}
    MTH_DS_AmmoItems[14118] = item
  end
  if not item["name"] then item["name"] = 'Monster - Bow, C02/B02 Black' end
  if not item["level"] then item["level"] = 1 end
  if not item["reqlevel"] then item["reqlevel"] = 1 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_05' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 6 end
  if not item["dps"] then item["dps"] = 0.8 end
  if not item["speed"] then item["speed"] = 2 end
end

do
  local item = MTH_DS_AmmoItems[14394]
  if not item then
    item = {}
    MTH_DS_AmmoItems[14394] = item
  end
  if not item["name"] then item["name"] = 'Durability Bow' end
  if not item["level"] then item["level"] = 1 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_02' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 5 end
  if not item["dps"] then item["dps"] = 1.1 end
  if not item["speed"] then item["speed"] = 1.8 end
end

do
  local item = MTH_DS_AmmoItems[14642]
  if not item then
    item = {}
    MTH_DS_AmmoItems[14642] = item
  end
  if not item["name"] then item["name"] = 'Monster - Gun, Tauren Feathers Silver' end
  if not item["level"] then item["level"] = 1 end
  if not item["reqlevel"] then item["reqlevel"] = 1 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_03' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 6 end
  if not item["dps"] then item["dps"] = 0.8 end
  if not item["speed"] then item["speed"] = 2 end
end

do
  local item = MTH_DS_AmmoItems[15205]
  if not item then
    item = {}
    MTH_DS_AmmoItems[15205] = item
  end
  if not item["name"] then item["name"] = 'Owlsight Rifle' end
  if not item["level"] then item["level"] = 20 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_04' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 7.9 end
  if not item["speed"] then item["speed"] = 2.6 end
end

do
  local item = MTH_DS_AmmoItems[15284]
  if not item then
    item = {}
    MTH_DS_AmmoItems[15284] = item
  end
  if not item["name"] then item["name"] = 'Long Battle Bow' end
  if not item["level"] then item["level"] = 29 end
  if not item["reqlevel"] then item["reqlevel"] = 24 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_01' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 11.8 end
  if not item["speed"] then item["speed"] = 2.2 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][153462] == nil then item["objects"][153462] = 0.07 end
end

do
  local item = MTH_DS_AmmoItems[15285]
  if not item then
    item = {}
    MTH_DS_AmmoItems[15285] = item
  end
  if not item["name"] then item["name"] = "Archer's Longbow" end
  if not item["level"] then item["level"] = 32 end
  if not item["reqlevel"] then item["reqlevel"] = 27 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_03' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 12.9 end
  if not item["speed"] then item["speed"] = 2.6 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][153462] == nil then item["objects"][153462] = 0.45 end
end

do
  local item = MTH_DS_AmmoItems[15286]
  if not item then
    item = {}
    MTH_DS_AmmoItems[15286] = item
  end
  if not item["name"] then item["name"] = 'Long Redwood Bow' end
  if not item["level"] then item["level"] = 35 end
  if not item["reqlevel"] then item["reqlevel"] = 30 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_10' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 14.3 end
  if not item["speed"] then item["speed"] = 2.8 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][153462] == nil then item["objects"][153462] = 0.47 end
end

do
  local item = MTH_DS_AmmoItems[15287]
  if not item then
    item = {}
    MTH_DS_AmmoItems[15287] = item
  end
  if not item["name"] then item["name"] = 'Crusader Bow' end
  if not item["level"] then item["level"] = 45 end
  if not item["reqlevel"] then item["reqlevel"] = 40 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_02' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 20.9 end
  if not item["speed"] then item["speed"] = 2.2 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][141979] == nil then item["objects"][141979] = 2.4 end
  if item["objects"][142184] == nil then item["objects"][142184] = 0.4 end
end

do
  local item = MTH_DS_AmmoItems[15288]
  if not item then
    item = {}
    MTH_DS_AmmoItems[15288] = item
  end
  if not item["name"] then item["name"] = 'Blasthorn Bow' end
  if not item["level"] then item["level"] = 61 end
  if not item["reqlevel"] then item["reqlevel"] = 56 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_07' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 28.3 end
  if not item["speed"] then item["speed"] = 2.6 end
end

do
  local item = MTH_DS_AmmoItems[15289]
  if not item then
    item = {}
    MTH_DS_AmmoItems[15289] = item
  end
  if not item["name"] then item["name"] = 'Archstrike Bow' end
  if not item["level"] then item["level"] = 65 end
  if not item["reqlevel"] then item["reqlevel"] = 60 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_06' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 30.2 end
  if not item["speed"] then item["speed"] = 2.3 end
end

do
  local item = MTH_DS_AmmoItems[15291]
  if not item then
    item = {}
    MTH_DS_AmmoItems[15291] = item
  end
  if not item["name"] then item["name"] = 'Harpy Needler' end
  if not item["level"] then item["level"] = 51 end
  if not item["reqlevel"] then item["reqlevel"] = 46 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_08' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 23.7 end
  if not item["speed"] then item["speed"] = 2.7 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][153462] == nil then item["objects"][153462] = 0.02 end
  if item["objects"][179697] == nil then item["objects"][179697] = 0.3 end
end

do
  local item = MTH_DS_AmmoItems[15294]
  if not item then
    item = {}
    MTH_DS_AmmoItems[15294] = item
  end
  if not item["name"] then item["name"] = 'Siege Bow' end
  if not item["level"] then item["level"] = 53 end
  if not item["reqlevel"] then item["reqlevel"] = 48 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_07' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 24.6 end
  if not item["speed"] then item["speed"] = 2.8 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][153462] == nil then item["objects"][153462] = 0.02 end
end

do
  local item = MTH_DS_AmmoItems[15295]
  if not item then
    item = {}
    MTH_DS_AmmoItems[15295] = item
  end
  if not item["name"] then item["name"] = 'Quillfire Bow' end
  if not item["level"] then item["level"] = 55 end
  if not item["reqlevel"] then item["reqlevel"] = 50 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_10' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 25.7 end
  if not item["speed"] then item["speed"] = 2.3 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][179697] == nil then item["objects"][179697] = 0.5 end
end

do
  local item = MTH_DS_AmmoItems[15296]
  if not item then
    item = {}
    MTH_DS_AmmoItems[15296] = item
  end
  if not item["name"] then item["name"] = 'Hawkeye Bow' end
  if not item["level"] then item["level"] = 63 end
  if not item["reqlevel"] then item["reqlevel"] = 58 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_12' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 29.4 end
  if not item["speed"] then item["speed"] = 1.7 end
end

do
  local item = MTH_DS_AmmoItems[15322]
  if not item then
    item = {}
    MTH_DS_AmmoItems[15322] = item
  end
  if not item["name"] then item["name"] = 'Smoothbore Gun' end
  if not item["level"] then item["level"] = 39 end
  if not item["reqlevel"] then item["reqlevel"] = 34 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_01' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 16.6 end
  if not item["speed"] then item["speed"] = 2.5 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][153462] == nil then item["objects"][153462] = 0.33 end
end

do
  local item = MTH_DS_AmmoItems[15323]
  if not item then
    item = {}
    MTH_DS_AmmoItems[15323] = item
  end
  if not item["name"] then item["name"] = 'Percussion Shotgun' end
  if not item["level"] then item["level"] = 50 end
  if not item["reqlevel"] then item["reqlevel"] = 45 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_01' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 23.3 end
  if not item["speed"] then item["speed"] = 2.3 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][153462] == nil then item["objects"][153462] = 0.02 end
end

do
  local item = MTH_DS_AmmoItems[15324]
  if not item then
    item = {}
    MTH_DS_AmmoItems[15324] = item
  end
  if not item["name"] then item["name"] = 'Burnside Rifle' end
  if not item["level"] then item["level"] = 56 end
  if not item["reqlevel"] then item["reqlevel"] = 51 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_01' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 26 end
  if not item["speed"] then item["speed"] = 2.5 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][153462] == nil then item["objects"][153462] = 0.14 end
  if item["objects"][160845] == nil then item["objects"][160845] = 0.7 end
  if item["objects"][176224] == nil then item["objects"][176224] = 0.1 end
end

do
  local item = MTH_DS_AmmoItems[15325]
  if not item then
    item = {}
    MTH_DS_AmmoItems[15325] = item
  end
  if not item["name"] then item["name"] = 'Sharpshooter Harquebus' end
  if not item["level"] then item["level"] = 60 end
  if not item["reqlevel"] then item["reqlevel"] = 55 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_06' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 28 end
  if not item["speed"] then item["speed"] = 2.2 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][153462] == nil then item["objects"][153462] = 0.12 end
  if item["objects"][160845] == nil then item["objects"][160845] = 0.3 end
end

do
  local item = MTH_DS_AmmoItems[15460]
  if not item then
    item = {}
    MTH_DS_AmmoItems[15460] = item
  end
  if not item["name"] then item["name"] = 'Monster - Gun, Shotgun' end
  if not item["level"] then item["level"] = 1 end
  if not item["reqlevel"] then item["reqlevel"] = 1 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_03' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 6 end
  if not item["dps"] then item["dps"] = 0.8 end
  if not item["speed"] then item["speed"] = 2 end
end

do
  local item = MTH_DS_AmmoItems[15691]
  if not item then
    item = {}
    MTH_DS_AmmoItems[15691] = item
  end
  if not item["name"] then item["name"] = 'Sidegunner Shottie' end
  if not item["level"] then item["level"] = 38 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_04' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 16 end
  if not item["speed"] then item["speed"] = 2.9 end
end

do
  local item = MTH_DS_AmmoItems[15807]
  if not item then
    item = {}
    MTH_DS_AmmoItems[15807] = item
  end
  if not item["name"] then item["name"] = 'Light Crossbow' end
  if not item["level"] then item["level"] = 8 end
  if not item["reqlevel"] then item["reqlevel"] = 3 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Crossbow_02' end
  if not item["subtype"] then item["subtype"] = 'crossbow' end
  if not item["quality"] then item["quality"] = 5 end
  if not item["dps"] then item["dps"] = 2.6 end
  if not item["speed"] then item["speed"] = 2.5 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][1287] == nil then item["vendors"][1287] = 0 end
  if item["vendors"][4602] == nil then item["vendors"][4602] = 0 end
  if item["vendors"][7976] == nil then item["vendors"][7976] = 0 end
  if item["vendors"][81035] == nil then item["vendors"][81035] = 0 end
end

do
  local item = MTH_DS_AmmoItems[15808]
  if not item then
    item = {}
    MTH_DS_AmmoItems[15808] = item
  end
  if not item["name"] then item["name"] = 'Fine Light Crossbow' end
  if not item["level"] then item["level"] = 21 end
  if not item["reqlevel"] then item["reqlevel"] = 16 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Crossbow_02' end
  if not item["subtype"] then item["subtype"] = 'crossbow' end
  if not item["quality"] then item["quality"] = 5 end
  if not item["dps"] then item["dps"] = 7.4 end
  if not item["speed"] then item["speed"] = 2.7 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][1287] == nil then item["vendors"][1287] = 0 end
  if item["vendors"][4602] == nil then item["vendors"][4602] = 0 end
  if item["vendors"][7976] == nil then item["vendors"][7976] = 0 end
end

do
  local item = MTH_DS_AmmoItems[15809]
  if not item then
    item = {}
    MTH_DS_AmmoItems[15809] = item
  end
  if not item["name"] then item["name"] = 'Heavy Crossbow' end
  if not item["level"] then item["level"] = 34 end
  if not item["reqlevel"] then item["reqlevel"] = 29 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Crossbow_03' end
  if not item["subtype"] then item["subtype"] = 'crossbow' end
  if not item["quality"] then item["quality"] = 5 end
  if not item["dps"] then item["dps"] = 13 end
  if not item["speed"] then item["speed"] = 2.8 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][1287] == nil then item["vendors"][1287] = 0 end
  if item["vendors"][4602] == nil then item["vendors"][4602] = 0 end
  if item["vendors"][7976] == nil then item["vendors"][7976] = 0 end
end

do
  local item = MTH_DS_AmmoItems[15995]
  if not item then
    item = {}
    MTH_DS_AmmoItems[15995] = item
  end
  if not item["name"] then item["name"] = 'Thorium Rifle' end
  if not item["level"] then item["level"] = 52 end
  if not item["reqlevel"] then item["reqlevel"] = 47 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_07' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 24.2 end
  if not item["speed"] then item["speed"] = 2.5 end
end

do
  local item = MTH_DS_AmmoItems[15997]
  if item then
    if not item["vendors"] then item["vendors"] = {} end
    if item["vendors"][17078] == nil then item["vendors"][17078] = 0 end
  end
end

do
  local item = MTH_DS_AmmoItems[16004]
  if not item then
    item = {}
    MTH_DS_AmmoItems[16004] = item
  end
  if not item["name"] then item["name"] = 'Dark Iron Rifle' end
  if not item["level"] then item["level"] = 55 end
  if not item["reqlevel"] then item["reqlevel"] = 50 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_08' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 28.4 end
  if not item["speed"] then item["speed"] = 3.1 end
end

do
  local item = MTH_DS_AmmoItems[16007]
  if not item then
    item = {}
    MTH_DS_AmmoItems[16007] = item
  end
  if not item["name"] then item["name"] = 'Flawless Arcanite Rifle' end
  if not item["level"] then item["level"] = 61 end
  if not item["reqlevel"] then item["reqlevel"] = 56 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_03' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 31.3 end
  if not item["speed"] then item["speed"] = 3.1 end
end

do
  local item = MTH_DS_AmmoItems[16622]
  if not item then
    item = {}
    MTH_DS_AmmoItems[16622] = item
  end
  if not item["name"] then item["name"] = 'Thornflinger' end
  if not item["level"] then item["level"] = 57 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_06' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 26.6 end
  if not item["speed"] then item["speed"] = 2.8 end
end

do
  local item = MTH_DS_AmmoItems[16992]
  if not item then
    item = {}
    MTH_DS_AmmoItems[16992] = item
  end
  if not item["name"] then item["name"] = "Smokey's Explosive Launcher" end
  if not item["level"] then item["level"] = 60 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_08' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 27.8 end
  if not item["speed"] then item["speed"] = 2.7 end
end

do
  local item = MTH_DS_AmmoItems[16996]
  if not item then
    item = {}
    MTH_DS_AmmoItems[16996] = item
  end
  if not item["name"] then item["name"] = 'Gorewood Bow' end
  if not item["level"] then item["level"] = 62 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_04' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 31.8 end
  if not item["speed"] then item["speed"] = 2.5 end
end

do
  local item = MTH_DS_AmmoItems[17042]
  if not item then
    item = {}
    MTH_DS_AmmoItems[17042] = item
  end
  if not item["name"] then item["name"] = 'Nail Spitter' end
  if not item["level"] then item["level"] = 36 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_01' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 14.7 end
  if not item["speed"] then item["speed"] = 1.9 end
end

do
  local item = MTH_DS_AmmoItems[17069]
  if not item then
    item = {}
    MTH_DS_AmmoItems[17069] = item
  end
  if not item["name"] then item["name"] = "Striker's Mark" end
  if not item["level"] then item["level"] = 69 end
  if not item["reqlevel"] then item["reqlevel"] = 60 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_08' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 2 end
  if not item["dps"] then item["dps"] = 39.6 end
  if not item["speed"] then item["speed"] = 2.5 end
end

do
  local item = MTH_DS_AmmoItems[17072]
  if not item then
    item = {}
    MTH_DS_AmmoItems[17072] = item
  end
  if not item["name"] then item["name"] = 'Blastershot Launcher' end
  if not item["level"] then item["level"] = 70 end
  if not item["reqlevel"] then item["reqlevel"] = 60 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_09' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 2 end
  if not item["dps"] then item["dps"] = 40.2 end
  if not item["speed"] then item["speed"] = 2.6 end
end

do
  local item = MTH_DS_AmmoItems[17686]
  if not item then
    item = {}
    MTH_DS_AmmoItems[17686] = item
  end
  if not item["name"] then item["name"] = "Master Hunter's Bow" end
  if not item["level"] then item["level"] = 43 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_11' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 19.4 end
  if not item["speed"] then item["speed"] = 2.4 end
end

do
  local item = MTH_DS_AmmoItems[17687]
  if not item then
    item = {}
    MTH_DS_AmmoItems[17687] = item
  end
  if not item["name"] then item["name"] = "Master Hunter's Rifle" end
  if not item["level"] then item["level"] = 43 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_05' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 19.4 end
  if not item["speed"] then item["speed"] = 2.6 end
end

do
  local item = MTH_DS_AmmoItems[17717]
  if not item then
    item = {}
    MTH_DS_AmmoItems[17717] = item
  end
  if not item["name"] then item["name"] = 'Megashot Rifle' end
  if not item["level"] then item["level"] = 53 end
  if not item["reqlevel"] then item["reqlevel"] = 48 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_05' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 27.4 end
  if not item["speed"] then item["speed"] = 1.7 end
end

do
  local item = MTH_DS_AmmoItems[17753]
  if not item then
    item = {}
    MTH_DS_AmmoItems[17753] = item
  end
  if not item["name"] then item["name"] = "Verdant Keeper's Aim" end
  if not item["level"] then item["level"] = 53 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_03' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 27.3 end
  if not item["speed"] then item["speed"] = 2.8 end
end

do
  local item = MTH_DS_AmmoItems[18042]
  if item then
    if not item["vendors"] then item["vendors"] = {} end
    if item["vendors"][17078] == nil then item["vendors"][17078] = 0 end
  end
end

do
  local item = MTH_DS_AmmoItems[18282]
  if not item then
    item = {}
    MTH_DS_AmmoItems[18282] = item
  end
  if not item["name"] then item["name"] = 'Core Marksman Rifle' end
  if not item["level"] then item["level"] = 66 end
  if not item["reqlevel"] then item["reqlevel"] = 60 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_05' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 2 end
  if not item["dps"] then item["dps"] = 37.5 end
  if not item["speed"] then item["speed"] = 3.2 end
end

do
  local item = MTH_DS_AmmoItems[18323]
  if not item then
    item = {}
    MTH_DS_AmmoItems[18323] = item
  end
  if not item["name"] then item["name"] = "Satyr's Bow" end
  if not item["level"] then item["level"] = 58 end
  if not item["reqlevel"] then item["reqlevel"] = 53 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_03' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 29.8 end
  if not item["speed"] then item["speed"] = 2.4 end
end

do
  local item = MTH_DS_AmmoItems[18388]
  if not item then
    item = {}
    MTH_DS_AmmoItems[18388] = item
  end
  if not item["name"] then item["name"] = 'Stoneshatter' end
  if not item["level"] then item["level"] = 62 end
  if not item["reqlevel"] then item["reqlevel"] = 57 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Crossbow_08' end
  if not item["subtype"] then item["subtype"] = 'crossbow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 31.7 end
  if not item["speed"] then item["speed"] = 2.9 end
end

do
  local item = MTH_DS_AmmoItems[18460]
  if not item then
    item = {}
    MTH_DS_AmmoItems[18460] = item
  end
  if not item["name"] then item["name"] = 'Unsophisticated Hand Cannon' end
  if not item["level"] then item["level"] = 60 end
  if not item["reqlevel"] then item["reqlevel"] = 55 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_07' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 27.8 end
  if not item["speed"] then item["speed"] = 2.5 end
end

do
  local item = MTH_DS_AmmoItems[18482]
  if not item then
    item = {}
    MTH_DS_AmmoItems[18482] = item
  end
  if not item["name"] then item["name"] = 'Ogre Toothpick Shooter' end
  if not item["level"] then item["level"] = 60 end
  if not item["reqlevel"] then item["reqlevel"] = 55 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_05' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 28 end
  if not item["speed"] then item["speed"] = 2.2 end
end

do
  local item = MTH_DS_AmmoItems[18680]
  if not item then
    item = {}
    MTH_DS_AmmoItems[18680] = item
  end
  if not item["name"] then item["name"] = 'Ancient Bone Bow' end
  if not item["level"] then item["level"] = 61 end
  if not item["reqlevel"] then item["reqlevel"] = 56 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_08' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 31.3 end
  if not item["speed"] then item["speed"] = 2.8 end
end

do
  local item = MTH_DS_AmmoItems[18713]
  if not item then
    item = {}
    MTH_DS_AmmoItems[18713] = item
  end
  if not item["name"] then item["name"] = "Rhok'delar, Longbow of the Ancient Keepers" end
  if not item["level"] then item["level"] = 75 end
  if not item["reqlevel"] then item["reqlevel"] = 60 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_01' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 2 end
  if not item["dps"] then item["dps"] = 44 end
  if not item["speed"] then item["speed"] = 2.9 end
end

do
  local item = MTH_DS_AmmoItems[18729]
  if not item then
    item = {}
    MTH_DS_AmmoItems[18729] = item
  end
  if not item["name"] then item["name"] = 'Screeching Bow' end
  if not item["level"] then item["level"] = 60 end
  if not item["reqlevel"] then item["reqlevel"] = 55 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_12' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 30.7 end
  if not item["speed"] then item["speed"] = 2.3 end
end

do
  local item = MTH_DS_AmmoItems[18738]
  if not item then
    item = {}
    MTH_DS_AmmoItems[18738] = item
  end
  if not item["name"] then item["name"] = 'Carapace Spine Crossbow' end
  if not item["level"] then item["level"] = 61 end
  if not item["reqlevel"] then item["reqlevel"] = 56 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Crossbow_04' end
  if not item["subtype"] then item["subtype"] = 'crossbow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 31.2 end
  if not item["speed"] then item["speed"] = 3.3 end
end

do
  local item = MTH_DS_AmmoItems[18755]
  if not item then
    item = {}
    MTH_DS_AmmoItems[18755] = item
  end
  if not item["name"] then item["name"] = 'Xorothian Firestick' end
  if not item["level"] then item["level"] = 62 end
  if not item["reqlevel"] then item["reqlevel"] = 57 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_03' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 31.7 end
  if not item["speed"] then item["speed"] = 2.6 end
end

do
  local item = MTH_DS_AmmoItems[18833]
  if not item then
    item = {}
    MTH_DS_AmmoItems[18833] = item
  end
  if not item["name"] then item["name"] = "Grand Marshal's Bullseye" end
  if not item["level"] then item["level"] = 83 end
  if not item["reqlevel"] then item["reqlevel"] = 60 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_12' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 2 end
  if not item["dps"] then item["dps"] = 50.8 end
  if not item["speed"] then item["speed"] = 1.8 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][12782] == nil then item["vendors"][12782] = 0 end
end

do
  local item = MTH_DS_AmmoItems[18835]
  if not item then
    item = {}
    MTH_DS_AmmoItems[18835] = item
  end
  if not item["name"] then item["name"] = "High Warlord's Recurve" end
  if not item["level"] then item["level"] = 83 end
  if not item["reqlevel"] then item["reqlevel"] = 60 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_08' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 2 end
  if not item["dps"] then item["dps"] = 50.8 end
  if not item["speed"] then item["speed"] = 1.8 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][14581] == nil then item["vendors"][14581] = 0 end
end

do
  local item = MTH_DS_AmmoItems[18836]
  if not item then
    item = {}
    MTH_DS_AmmoItems[18836] = item
  end
  if not item["name"] then item["name"] = "Grand Marshal's Repeater" end
  if not item["level"] then item["level"] = 83 end
  if not item["reqlevel"] then item["reqlevel"] = 60 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Crossbow_04' end
  if not item["subtype"] then item["subtype"] = 'crossbow' end
  if not item["quality"] then item["quality"] = 2 end
  if not item["dps"] then item["dps"] = 50.9 end
  if not item["speed"] then item["speed"] = 2.9 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][12782] == nil then item["vendors"][12782] = 0 end
end

do
  local item = MTH_DS_AmmoItems[18837]
  if not item then
    item = {}
    MTH_DS_AmmoItems[18837] = item
  end
  if not item["name"] then item["name"] = "High Warlord's Crossbow" end
  if not item["level"] then item["level"] = 83 end
  if not item["reqlevel"] then item["reqlevel"] = 60 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Crossbow_10' end
  if not item["subtype"] then item["subtype"] = 'crossbow' end
  if not item["quality"] then item["quality"] = 2 end
  if not item["dps"] then item["dps"] = 50.9 end
  if not item["speed"] then item["speed"] = 2.9 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][14581] == nil then item["vendors"][14581] = 0 end
end

do
  local item = MTH_DS_AmmoItems[18855]
  if not item then
    item = {}
    MTH_DS_AmmoItems[18855] = item
  end
  if not item["name"] then item["name"] = "Grand Marshal's Hand Cannon" end
  if not item["level"] then item["level"] = 83 end
  if not item["reqlevel"] then item["reqlevel"] = 60 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_08' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 2 end
  if not item["dps"] then item["dps"] = 50.9 end
  if not item["speed"] then item["speed"] = 2.9 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][12782] == nil then item["vendors"][12782] = 0 end
end

do
  local item = MTH_DS_AmmoItems[18860]
  if not item then
    item = {}
    MTH_DS_AmmoItems[18860] = item
  end
  if not item["name"] then item["name"] = "High Warlord's Street Sweeper" end
  if not item["level"] then item["level"] = 83 end
  if not item["reqlevel"] then item["reqlevel"] = 60 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_06' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 2 end
  if not item["dps"] then item["dps"] = 50.9 end
  if not item["speed"] then item["speed"] = 2.9 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][14581] == nil then item["vendors"][14581] = 0 end
end

do
  local item = MTH_DS_AmmoItems[19107]
  if not item then
    item = {}
    MTH_DS_AmmoItems[19107] = item
  end
  if not item["name"] then item["name"] = 'Bloodseeker' end
  if not item["level"] then item["level"] = 63 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Crossbow_07' end
  if not item["subtype"] then item["subtype"] = 'crossbow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 32.3 end
  if not item["speed"] then item["speed"] = 3.3 end
end

do
  local item = MTH_DS_AmmoItems[19114]
  if not item then
    item = {}
    MTH_DS_AmmoItems[19114] = item
  end
  if not item["name"] then item["name"] = 'Highland Bow' end
  if not item["level"] then item["level"] = 51 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_08' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 23.6 end
  if not item["speed"] then item["speed"] = 2.5 end
end

do
  local item = MTH_DS_AmmoItems[19316]
  if item then
    if not item["vendors"] then item["vendors"] = {} end
    if item["vendors"][13216] == nil then item["vendors"][13216] = 0 end
    if item["vendors"][13217] == nil then item["vendors"][13217] = 0 end
    if item["vendors"][13218] == nil then item["vendors"][13218] = 0 end
    if item["vendors"][13219] == nil then item["vendors"][13219] = 0 end
  end
end

do
  local item = MTH_DS_AmmoItems[19317]
  if item then
    if not item["vendors"] then item["vendors"] = {} end
    if item["vendors"][13216] == nil then item["vendors"][13216] = 0 end
    if item["vendors"][13217] == nil then item["vendors"][13217] = 0 end
    if item["vendors"][13218] == nil then item["vendors"][13218] = 0 end
    if item["vendors"][13219] == nil then item["vendors"][13219] = 0 end
  end
end

do
  local item = MTH_DS_AmmoItems[19350]
  if not item then
    item = {}
    MTH_DS_AmmoItems[19350] = item
  end
  if not item["name"] then item["name"] = 'Heartstriker' end
  if not item["level"] then item["level"] = 75 end
  if not item["reqlevel"] then item["reqlevel"] = 60 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_09' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 2 end
  if not item["dps"] then item["dps"] = 44 end
  if not item["speed"] then item["speed"] = 2.6 end
end

do
  local item = MTH_DS_AmmoItems[19361]
  if not item then
    item = {}
    MTH_DS_AmmoItems[19361] = item
  end
  if not item["name"] then item["name"] = "Ashjre'thul, Crossbow of Smiting" end
  if not item["level"] then item["level"] = 77 end
  if not item["reqlevel"] then item["reqlevel"] = 60 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Crossbow_09' end
  if not item["subtype"] then item["subtype"] = 'crossbow' end
  if not item["quality"] then item["quality"] = 2 end
  if not item["dps"] then item["dps"] = 45.6 end
  if not item["speed"] then item["speed"] = 3.4 end
end

do
  local item = MTH_DS_AmmoItems[19368]
  if not item then
    item = {}
    MTH_DS_AmmoItems[19368] = item
  end
  if not item["name"] then item["name"] = 'Dragonbreath Hand Cannon' end
  if not item["level"] then item["level"] = 75 end
  if not item["reqlevel"] then item["reqlevel"] = 60 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_02' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 2 end
  if not item["dps"] then item["dps"] = 43.9 end
  if not item["speed"] then item["speed"] = 3.1 end
end

do
  local item = MTH_DS_AmmoItems[19558]
  if not item then
    item = {}
    MTH_DS_AmmoItems[19558] = item
  end
  if not item["name"] then item["name"] = "Outrider's Bow" end
  if not item["level"] then item["level"] = 71 end
  if not item["reqlevel"] then item["reqlevel"] = 60 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_06' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 36.7 end
  if not item["speed"] then item["speed"] = 2.4 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][14754] == nil then item["vendors"][14754] = 0 end
end

do
  local item = MTH_DS_AmmoItems[19559]
  if not item then
    item = {}
    MTH_DS_AmmoItems[19559] = item
  end
  if not item["name"] then item["name"] = "Outrider's Bow" end
  if not item["level"] then item["level"] = 53 end
  if not item["reqlevel"] then item["reqlevel"] = 48 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_06' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 27.5 end
  if not item["speed"] then item["speed"] = 2.4 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][14754] == nil then item["vendors"][14754] = 0 end
end

do
  local item = MTH_DS_AmmoItems[19560]
  if not item then
    item = {}
    MTH_DS_AmmoItems[19560] = item
  end
  if not item["name"] then item["name"] = "Outrider's Bow" end
  if not item["level"] then item["level"] = 43 end
  if not item["reqlevel"] then item["reqlevel"] = 38 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_06' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 22.7 end
  if not item["speed"] then item["speed"] = 2.4 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][14754] == nil then item["vendors"][14754] = 0 end
end

do
  local item = MTH_DS_AmmoItems[19561]
  if not item then
    item = {}
    MTH_DS_AmmoItems[19561] = item
  end
  if not item["name"] then item["name"] = "Outrider's Bow" end
  if not item["level"] then item["level"] = 33 end
  if not item["reqlevel"] then item["reqlevel"] = 28 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_06' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 16.7 end
  if not item["speed"] then item["speed"] = 2.4 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][14754] == nil then item["vendors"][14754] = 0 end
end

do
  local item = MTH_DS_AmmoItems[19562]
  if not item then
    item = {}
    MTH_DS_AmmoItems[19562] = item
  end
  if not item["name"] then item["name"] = "Outrunner's Bow" end
  if not item["level"] then item["level"] = 71 end
  if not item["reqlevel"] then item["reqlevel"] = 60 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_02' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 36.7 end
  if not item["speed"] then item["speed"] = 2.4 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][14753] == nil then item["vendors"][14753] = 0 end
end

do
  local item = MTH_DS_AmmoItems[19563]
  if not item then
    item = {}
    MTH_DS_AmmoItems[19563] = item
  end
  if not item["name"] then item["name"] = "Outrunner's Bow" end
  if not item["level"] then item["level"] = 53 end
  if not item["reqlevel"] then item["reqlevel"] = 48 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_02' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 27.5 end
  if not item["speed"] then item["speed"] = 2.4 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][14753] == nil then item["vendors"][14753] = 0 end
end

do
  local item = MTH_DS_AmmoItems[19564]
  if not item then
    item = {}
    MTH_DS_AmmoItems[19564] = item
  end
  if not item["name"] then item["name"] = "Outrunner's Bow" end
  if not item["level"] then item["level"] = 43 end
  if not item["reqlevel"] then item["reqlevel"] = 38 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_02' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 22.7 end
  if not item["speed"] then item["speed"] = 2.4 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][14753] == nil then item["vendors"][14753] = 0 end
end

do
  local item = MTH_DS_AmmoItems[19565]
  if not item then
    item = {}
    MTH_DS_AmmoItems[19565] = item
  end
  if not item["name"] then item["name"] = "Outrunner's Bow" end
  if not item["level"] then item["level"] = 33 end
  if not item["reqlevel"] then item["reqlevel"] = 28 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_02' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 16.7 end
  if not item["speed"] then item["speed"] = 2.4 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][14753] == nil then item["vendors"][14753] = 0 end
end

do
  local item = MTH_DS_AmmoItems[19853]
  if not item then
    item = {}
    MTH_DS_AmmoItems[19853] = item
  end
  if not item["name"] then item["name"] = 'Gurubashi Dwarf Destroyer' end
  if not item["level"] then item["level"] = 68 end
  if not item["reqlevel"] then item["reqlevel"] = 60 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_10' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 2 end
  if not item["dps"] then item["dps"] = 38.9 end
  if not item["speed"] then item["speed"] = 2.8 end
end

do
  local item = MTH_DS_AmmoItems[19993]
  if not item then
    item = {}
    MTH_DS_AmmoItems[19993] = item
  end
  if not item["name"] then item["name"] = 'Hoodoo Hunting Bow' end
  if not item["level"] then item["level"] = 68 end
  if not item["reqlevel"] then item["reqlevel"] = 60 end
  if not item["icon"] then item["icon"] = 'INV_Waepon_Bow_ZulGrub_D_02' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 35 end
  if not item["speed"] then item["speed"] = 2.8 end
end

do
  local item = MTH_DS_AmmoItems[20038]
  if not item then
    item = {}
    MTH_DS_AmmoItems[20038] = item
  end
  if not item["name"] then item["name"] = "Mandokir's Sting" end
  if not item["level"] then item["level"] = 66 end
  if not item["reqlevel"] then item["reqlevel"] = 60 end
  if not item["icon"] then item["icon"] = 'INV_Waepon_Bow_ZulGrub_D_01' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 2 end
  if not item["dps"] then item["dps"] = 37.5 end
  if not item["speed"] then item["speed"] = 2.6 end
end

do
  local item = MTH_DS_AmmoItems[20245]
  if not item then
    item = {}
    MTH_DS_AmmoItems[20245] = item
  end
  if not item["name"] then item["name"] = '90 Green Warrior Gun' end
  if not item["level"] then item["level"] = 90 end
  if not item["reqlevel"] then item["reqlevel"] = 60 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_05' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 46.4 end
  if not item["speed"] then item["speed"] = 2.5 end
end

do
  local item = MTH_DS_AmmoItems[20285]
  if not item then
    item = {}
    MTH_DS_AmmoItems[20285] = item
  end
  if not item["name"] then item["name"] = '63 Green Warrior Gun' end
  if not item["level"] then item["level"] = 63 end
  if not item["reqlevel"] then item["reqlevel"] = 58 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_05' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 29.4 end
  if not item["speed"] then item["speed"] = 2.5 end
end

do
  local item = MTH_DS_AmmoItems[20299]
  if not item then
    item = {}
    MTH_DS_AmmoItems[20299] = item
  end
  if not item["name"] then item["name"] = '90 Green Rogue Bow' end
  if not item["level"] then item["level"] = 90 end
  if not item["reqlevel"] then item["reqlevel"] = 60 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_04' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 46.4 end
  if not item["speed"] then item["speed"] = 2.5 end
end

do
  local item = MTH_DS_AmmoItems[20313]
  if not item then
    item = {}
    MTH_DS_AmmoItems[20313] = item
  end
  if not item["name"] then item["name"] = '63 Green Rogue Bow' end
  if not item["level"] then item["level"] = 63 end
  if not item["reqlevel"] then item["reqlevel"] = 58 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_04' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 29.4 end
  if not item["speed"] then item["speed"] = 2.5 end
end

do
  local item = MTH_DS_AmmoItems[20368]
  if not item then
    item = {}
    MTH_DS_AmmoItems[20368] = item
  end
  if not item["name"] then item["name"] = 'Bland Bow of Steadiness' end
  if not item["level"] then item["level"] = 60 end
  if not item["reqlevel"] then item["reqlevel"] = 60 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_08' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 30.7 end
  if not item["speed"] then item["speed"] = 1.5 end
end

do
  local item = MTH_DS_AmmoItems[20437]
  if not item then
    item = {}
    MTH_DS_AmmoItems[20437] = item
  end
  if not item["name"] then item["name"] = "Outrider's Bow" end
  if not item["level"] then item["level"] = 23 end
  if not item["reqlevel"] then item["reqlevel"] = 18 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_06' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 11.7 end
  if not item["speed"] then item["speed"] = 2.4 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][14754] == nil then item["vendors"][14754] = 0 end
end

do
  local item = MTH_DS_AmmoItems[20438]
  if not item then
    item = {}
    MTH_DS_AmmoItems[20438] = item
  end
  if not item["name"] then item["name"] = "Outrunner's Bow" end
  if not item["level"] then item["level"] = 23 end
  if not item["reqlevel"] then item["reqlevel"] = 18 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_02' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 11.7 end
  if not item["speed"] then item["speed"] = 2.4 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][14753] == nil then item["vendors"][14753] = 0 end
end

do
  local item = MTH_DS_AmmoItems[20488]
  if not item then
    item = {}
    MTH_DS_AmmoItems[20488] = item
  end
  if not item["name"] then item["name"] = "Rhok'delar, Longbow of the Ancient Keepers DEP" end
  if not item["level"] then item["level"] = 75 end
  if not item["reqlevel"] then item["reqlevel"] = 60 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_01' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 2 end
  if not item["dps"] then item["dps"] = 44 end
  if not item["speed"] then item["speed"] = 2.9 end
end

do
  local item = MTH_DS_AmmoItems[20599]
  if not item then
    item = {}
    MTH_DS_AmmoItems[20599] = item
  end
  if not item["name"] then item["name"] = 'Polished Ironwood Crossbow' end
  if not item["level"] then item["level"] = 76 end
  if not item["reqlevel"] then item["reqlevel"] = 60 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Crossbow_11' end
  if not item["subtype"] then item["subtype"] = 'crossbow' end
  if not item["quality"] then item["quality"] = 2 end
  if not item["dps"] then item["dps"] = 44.8 end
  if not item["speed"] then item["speed"] = 3.1 end
end

do
  local item = MTH_DS_AmmoItems[20646]
  if not item then
    item = {}
    MTH_DS_AmmoItems[20646] = item
  end
  if not item["name"] then item["name"] = "Sandstrider's Mark" end
  if not item["level"] then item["level"] = 59 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_03' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 27.4 end
  if not item["speed"] then item["speed"] = 2.3 end
end

do
  local item = MTH_DS_AmmoItems[20663]
  if not item then
    item = {}
    MTH_DS_AmmoItems[20663] = item
  end
  if not item["name"] then item["name"] = 'Deep Strike Bow' end
  if not item["level"] then item["level"] = 60 end
  if not item["reqlevel"] then item["reqlevel"] = 55 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_10' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 30.7 end
  if not item["speed"] then item["speed"] = 2.7 end
  if not item["drops"] then item["drops"] = {} end
  if item["drops"][15307] == nil then item["drops"][15307] = 5.72 end
end

do
  local item = MTH_DS_AmmoItems[20722]
  if not item then
    item = {}
    MTH_DS_AmmoItems[20722] = item
  end
  if not item["name"] then item["name"] = 'Crystal Slugthrower' end
  if not item["level"] then item["level"] = 65 end
  if not item["reqlevel"] then item["reqlevel"] = 60 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_03' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 33.4 end
  if not item["speed"] then item["speed"] = 2.8 end
end

do
  local item = MTH_DS_AmmoItems[21272]
  if not item then
    item = {}
    MTH_DS_AmmoItems[21272] = item
  end
  if not item["name"] then item["name"] = 'Blessed Qiraji Musket' end
  if not item["level"] then item["level"] = 79 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_11' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 2 end
  if not item["dps"] then item["dps"] = 47.3 end
  if not item["speed"] then item["speed"] = 3.1 end
end

do
  local item = MTH_DS_AmmoItems[21459]
  if not item then
    item = {}
    MTH_DS_AmmoItems[21459] = item
  end
  if not item["name"] then item["name"] = 'Crossbow of Imminent Doom' end
  if not item["level"] then item["level"] = 72 end
  if not item["reqlevel"] then item["reqlevel"] = 60 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Crossbow_06' end
  if not item["subtype"] then item["subtype"] = 'crossbow' end
  if not item["quality"] then item["quality"] = 2 end
  if not item["dps"] then item["dps"] = 41.6 end
  if not item["speed"] then item["speed"] = 3.1 end
end

do
  local item = MTH_DS_AmmoItems[21478]
  if not item then
    item = {}
    MTH_DS_AmmoItems[21478] = item
  end
  if not item["name"] then item["name"] = 'Bow of Taut Sinew' end
  if not item["level"] then item["level"] = 68 end
  if not item["reqlevel"] then item["reqlevel"] = 60 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_13' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 2 end
  if not item["dps"] then item["dps"] = 38.6 end
  if not item["speed"] then item["speed"] = 2.2 end
end

do
  local item = MTH_DS_AmmoItems[21550]
  if not item then
    item = {}
    MTH_DS_AmmoItems[21550] = item
  end
  if not item["name"] then item["name"] = 'Monster - Bow, Kaldorei' end
  if not item["level"] then item["level"] = 1 end
  if not item["reqlevel"] then item["reqlevel"] = 1 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_05' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 6 end
  if not item["dps"] then item["dps"] = 0.8 end
  if not item["speed"] then item["speed"] = 2 end
end

do
  local item = MTH_DS_AmmoItems[21554]
  if not item then
    item = {}
    MTH_DS_AmmoItems[21554] = item
  end
  if not item["name"] then item["name"] = 'Monster - Gun, PvP Horde' end
  if not item["level"] then item["level"] = 1 end
  if not item["reqlevel"] then item["reqlevel"] = 1 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_03' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 6 end
  if not item["dps"] then item["dps"] = 0.8 end
  if not item["speed"] then item["speed"] = 2 end
end

do
  local item = MTH_DS_AmmoItems[21564]
  if not item then
    item = {}
    MTH_DS_AmmoItems[21564] = item
  end
  if not item["name"] then item["name"] = 'Monster - Gun, Kaldorei PVP Alliance' end
  if not item["level"] then item["level"] = 1 end
  if not item["reqlevel"] then item["reqlevel"] = 1 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_03' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 6 end
  if not item["dps"] then item["dps"] = 0.8 end
  if not item["speed"] then item["speed"] = 2 end
end

do
  local item = MTH_DS_AmmoItems[21616]
  if not item then
    item = {}
    MTH_DS_AmmoItems[21616] = item
  end
  if not item["name"] then item["name"] = "Huhuran's Stinger" end
  if not item["level"] then item["level"] = 78 end
  if not item["reqlevel"] then item["reqlevel"] = 60 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_14' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 2 end
  if not item["dps"] then item["dps"] = 46.3 end
  if not item["speed"] then item["speed"] = 2.7 end
end

do
  local item = MTH_DS_AmmoItems[21800]
  if not item then
    item = {}
    MTH_DS_AmmoItems[21800] = item
  end
  if not item["name"] then item["name"] = 'Silithid Husked Launcher' end
  if not item["level"] then item["level"] = 68 end
  if not item["reqlevel"] then item["reqlevel"] = 60 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_10' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 35 end
  if not item["speed"] then item["speed"] = 2.8 end
  if not item["drops"] then item["drops"] = {} end
  if item["drops"][15318] == nil then item["drops"][15318] = 0.08 end
  if item["drops"][15320] == nil then item["drops"][15320] = 0.04 end
  if item["drops"][15323] == nil then item["drops"][15323] = 0.04 end
  if item["drops"][15324] == nil then item["drops"][15324] = 0.1 end
  if item["drops"][15325] == nil then item["drops"][15325] = 0.05 end
  if item["drops"][15327] == nil then item["drops"][15327] = 0.05 end
  if item["drops"][15333] == nil then item["drops"][15333] = 0.05 end
  if item["drops"][15335] == nil then item["drops"][15335] = 0.08 end
  if item["drops"][15336] == nil then item["drops"][15336] = 0.11 end
  if item["drops"][15338] == nil then item["drops"][15338] = 0.06 end
  if item["drops"][15343] == nil then item["drops"][15343] = 0.06 end
  if item["drops"][15355] == nil then item["drops"][15355] = 0.05 end
  if item["drops"][15386] == nil then item["drops"][15386] = 0.1 end
  if item["drops"][15387] == nil then item["drops"][15387] = 0.22 end
  if item["drops"][15389] == nil then item["drops"][15389] = 0.03 end
  if item["drops"][15390] == nil then item["drops"][15390] = 0.04 end
  if item["drops"][15391] == nil then item["drops"][15391] = 0.07 end
  if item["drops"][15392] == nil then item["drops"][15392] = 0.02 end
  if item["drops"][15462] == nil then item["drops"][15462] = 0.1 end
end

do
  local item = MTH_DS_AmmoItems[22318]
  if not item then
    item = {}
    MTH_DS_AmmoItems[22318] = item
  end
  if not item["name"] then item["name"] = "Malgen's Long Bow" end
  if not item["level"] then item["level"] = 61 end
  if not item["reqlevel"] then item["reqlevel"] = 56 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_12' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 31.2 end
  if not item["speed"] then item["speed"] = 2.9 end
  if not item["drops"] then item["drops"] = {} end
  if item["drops"][8925] == nil then item["drops"][8925] = 0.03 end
  if item["drops"][8927] == nil then item["drops"][8927] = 0.02 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][181074] == nil then item["objects"][181074] = 26 end
end

do
  local item = MTH_DS_AmmoItems[22347]
  if not item then
    item = {}
    MTH_DS_AmmoItems[22347] = item
  end
  if not item["name"] then item["name"] = "Fahrad's Reloading Repeater" end
  if not item["level"] then item["level"] = 65 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Crossbow_04' end
  if not item["subtype"] then item["subtype"] = 'crossbow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 33.3 end
  if not item["speed"] then item["speed"] = 3.2 end
end

do
  local item = MTH_DS_AmmoItems[22656]
  if not item then
    item = {}
    MTH_DS_AmmoItems[22656] = item
  end
  if not item["name"] then item["name"] = 'The Purifier' end
  if not item["level"] then item["level"] = 63 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_06' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 2 end
  if not item["dps"] then item["dps"] = 35.3 end
  if not item["speed"] then item["speed"] = 3 end
end

do
  local item = MTH_DS_AmmoItems[22810]
  if not item then
    item = {}
    MTH_DS_AmmoItems[22810] = item
  end
  if not item["name"] then item["name"] = 'Toxin Injector' end
  if not item["level"] then item["level"] = 83 end
  if not item["reqlevel"] then item["reqlevel"] = 60 end
  if not item["icon"] then item["icon"] = 'INV_weapon_rifle_13' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 2 end
  if not item["dps"] then item["dps"] = 50.8 end
  if not item["speed"] then item["speed"] = 2 end
end

do
  local item = MTH_DS_AmmoItems[22811]
  if not item then
    item = {}
    MTH_DS_AmmoItems[22811] = item
  end
  if not item["name"] then item["name"] = 'Soulstring' end
  if not item["level"] then item["level"] = 86 end
  if not item["reqlevel"] then item["reqlevel"] = 60 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_13' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 2 end
  if not item["dps"] then item["dps"] = 54.1 end
  if not item["speed"] then item["speed"] = 2.9 end
end

do
  local item = MTH_DS_AmmoItems[22812]
  if not item then
    item = {}
    MTH_DS_AmmoItems[22812] = item
  end
  if not item["name"] then item["name"] = 'Nerubian Slavemaker' end
  if not item["level"] then item["level"] = 89 end
  if not item["reqlevel"] then item["reqlevel"] = 60 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Crossbow_12' end
  if not item["subtype"] then item["subtype"] = 'crossbow' end
  if not item["quality"] then item["quality"] = 2 end
  if not item["dps"] then item["dps"] = 57.2 end
  if not item["speed"] then item["speed"] = 3.2 end
end

do
  local item = MTH_DS_AmmoItems[23557]
  if not item then
    item = {}
    MTH_DS_AmmoItems[23557] = item
  end
  if not item["name"] then item["name"] = 'Larvae of the Great Worm' end
  if not item["level"] then item["level"] = 81 end
  if not item["reqlevel"] then item["reqlevel"] = 60 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_10' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 2 end
  if not item["dps"] then item["dps"] = 49.2 end
  if not item["speed"] then item["speed"] = 3 end
end

do
  local item = MTH_DS_AmmoItems[41023]
  if not item then
    item = {}
    MTH_DS_AmmoItems[41023] = item
  end
  if not item["name"] then item["name"] = 'Water-logged Musket' end
  if not item["level"] then item["level"] = 5 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_03' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 5 end
  if not item["dps"] then item["dps"] = 1.8 end
  if not item["speed"] then item["speed"] = 2.2 end
end

do
  local item = MTH_DS_AmmoItems[41190]
  if not item then
    item = {}
    MTH_DS_AmmoItems[41190] = item
  end
  if not item["name"] then item["name"] = "Bow of Alah'Thalas" end
  if not item["level"] then item["level"] = 13 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_01' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 5.4 end
  if not item["speed"] then item["speed"] = 2.5 end
end

do
  local item = MTH_DS_AmmoItems[41725]
  if not item then
    item = {}
    MTH_DS_AmmoItems[41725] = item
  end
  if not item["name"] then item["name"] = 'Dragonmaw Battle Bow' end
  if not item["level"] then item["level"] = 33 end
  if not item["reqlevel"] then item["reqlevel"] = 28 end
  if not item["icon"] then item["icon"] = 'GenBow_twow3F' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 16.7 end
  if not item["speed"] then item["speed"] = 2.4 end
  if not item["drops"] then item["drops"] = {} end
  if item["drops"][62070] == nil then item["drops"][62070] = 25 end
end

do
  local item = MTH_DS_AmmoItems[51746]
  if not item then
    item = {}
    MTH_DS_AmmoItems[51746] = item
  end
  if not item["name"] then item["name"] = 'Shadowblaster' end
  if not item["level"] then item["level"] = 62 end
  if not item["reqlevel"] then item["reqlevel"] = 57 end
  if not item["icon"] then item["icon"] = 'INV_Musket_02' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 31.9 end
  if not item["speed"] then item["speed"] = 3.1 end
end

do
  local item = MTH_DS_AmmoItems[51759]
  if not item then
    item = {}
    MTH_DS_AmmoItems[51759] = item
  end
  if not item["name"] then item["name"] = 'Siege Bomber' end
  if not item["level"] then item["level"] = 42 end
  if not item["reqlevel"] then item["reqlevel"] = 37 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_04' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 18.6 end
  if not item["speed"] then item["speed"] = 2.8 end
  if not item["drops"] then item["drops"] = {} end
  if item["drops"][2749] == nil then item["drops"][2749] = 70 end
end

do
  local item = MTH_DS_AmmoItems[51768]
  if not item then
    item = {}
    MTH_DS_AmmoItems[51768] = item
  end
  if not item["name"] then item["name"] = "Bow of Quel'Danil" end
  if not item["level"] then item["level"] = 49 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_16' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 21.7 end
  if not item["speed"] then item["speed"] = 2.1 end
end

do
  local item = MTH_DS_AmmoItems[51780]
  if not item then
    item = {}
    MTH_DS_AmmoItems[51780] = item
  end
  if not item["name"] then item["name"] = 'Ghoulslayer Shotgun' end
  if not item["level"] then item["level"] = 66 end
  if not item["reqlevel"] then item["reqlevel"] = 60 end
  if not item["icon"] then item["icon"] = 'INV_weapon_rifle_13' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 2 end
  if not item["dps"] then item["dps"] = 37.4 end
  if not item["speed"] then item["speed"] = 3.1 end
end

do
  local item = MTH_DS_AmmoItems[51794]
  if not item then
    item = {}
    MTH_DS_AmmoItems[51794] = item
  end
  if not item["name"] then item["name"] = 'Otherworldly Rifle' end
  if not item["level"] then item["level"] = 52 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_04' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 24.1 end
  if not item["speed"] then item["speed"] = 2.6 end
end

do
  local item = MTH_DS_AmmoItems[51828]
  if not item then
    item = {}
    MTH_DS_AmmoItems[51828] = item
  end
  if not item["name"] then item["name"] = 'Hawkwind Rifle' end
  if not item["level"] then item["level"] = 10 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_07' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 5 end
  if not item["dps"] then item["dps"] = 3.5 end
  if not item["speed"] then item["speed"] = 2.6 end
end

do
  local item = MTH_DS_AmmoItems[51844]
  if not item then
    item = {}
    MTH_DS_AmmoItems[51844] = item
  end
  if not item["name"] then item["name"] = 'Stunning Crossbow' end
  if not item["level"] then item["level"] = 41 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Crossbow_08' end
  if not item["subtype"] then item["subtype"] = 'crossbow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 16.6 end
  if not item["speed"] then item["speed"] = 3.4 end
end

do
  local item = MTH_DS_AmmoItems[51862]
  if not item then
    item = {}
    MTH_DS_AmmoItems[51862] = item
  end
  if not item["name"] then item["name"] = "Brave's Rifle" end
  if not item["level"] then item["level"] = 20 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_04' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 9 end
  if not item["speed"] then item["speed"] = 2.6 end
end

do
  local item = MTH_DS_AmmoItems[55028]
  if not item then
    item = {}
    MTH_DS_AmmoItems[55028] = item
  end
  if not item["name"] then item["name"] = "Kavdan's Patient Watch" end
  if not item["level"] then item["level"] = 62 end
  if not item["reqlevel"] then item["reqlevel"] = 60 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Crossbow_04' end
  if not item["subtype"] then item["subtype"] = 'crossbow' end
  if not item["quality"] then item["quality"] = 2 end
  if not item["dps"] then item["dps"] = 37.4 end
  if not item["speed"] then item["speed"] = 3.1 end
end

do
  local item = MTH_DS_AmmoItems[55068]
  if not item then
    item = {}
    MTH_DS_AmmoItems[55068] = item
  end
  if not item["name"] then item["name"] = "Zan's Leperification Blaster" end
  if not item["level"] then item["level"] = 50 end
  if not item["reqlevel"] then item["reqlevel"] = 45 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_06' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 26.1 end
  if not item["speed"] then item["speed"] = 2.7 end
end

do
  local item = MTH_DS_AmmoItems[55096]
  if not item then
    item = {}
    MTH_DS_AmmoItems[55096] = item
  end
  if not item["name"] then item["name"] = 'Phase-shifting Crossbow' end
  if not item["level"] then item["level"] = 88 end
  if not item["reqlevel"] then item["reqlevel"] = 60 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Crossbow_18' end
  if not item["subtype"] then item["subtype"] = 'crossbow' end
  if not item["quality"] then item["quality"] = 2 end
  if not item["dps"] then item["dps"] = 56.1 end
  if not item["speed"] then item["speed"] = 2.8 end
  if not item["drops"] then item["drops"] = {} end
  if item["drops"][61951] == nil then item["drops"][61951] = 25 end
end

do
  local item = MTH_DS_AmmoItems[55346]
  if not item then
    item = {}
    MTH_DS_AmmoItems[55346] = item
  end
  if not item["name"] then item["name"] = 'Rain of Spiders' end
  if not item["level"] then item["level"] = 96 end
  if not item["reqlevel"] then item["reqlevel"] = 60 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_BoneBow2' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 2 end
  if not item["dps"] then item["dps"] = 64.4 end
  if not item["speed"] then item["speed"] = 3.1 end
  if not item["drops"] then item["drops"] = {} end
  if item["drops"][93333] == nil then item["drops"][93333] = 5.6 end
end

do
  local item = MTH_DS_AmmoItems[55379]
  if not item then
    item = {}
    MTH_DS_AmmoItems[55379] = item
  end
  if not item["name"] then item["name"] = 'Slag Slugger' end
  if not item["level"] then item["level"] = 23 end
  if not item["reqlevel"] then item["reqlevel"] = 18 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_03' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 9.3 end
  if not item["speed"] then item["speed"] = 2.3 end
  if not item["drops"] then item["drops"] = {} end
  if item["drops"][61963] == nil then item["drops"][61963] = 25 end
end

do
  local item = MTH_DS_AmmoItems[58016]
  if not item then
    item = {}
    MTH_DS_AmmoItems[58016] = item
  end
  if not item["name"] then item["name"] = 'Ashwood Bow' end
  if not item["level"] then item["level"] = 39 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_11' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 17.2 end
  if not item["speed"] then item["speed"] = 2.3 end
end

do
  local item = MTH_DS_AmmoItems[58083]
  if not item then
    item = {}
    MTH_DS_AmmoItems[58083] = item
  end
  if not item["name"] then item["name"] = "Nippsy's Precision Rifle" end
  if not item["level"] then item["level"] = 47 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_02' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 24.7 end
  if not item["speed"] then item["speed"] = 2.9 end
end

do
  local item = MTH_DS_AmmoItems[58086]
  if not item then
    item = {}
    MTH_DS_AmmoItems[58086] = item
  end
  if not item["name"] then item["name"] = 'Standard Grade Rifle' end
  if not item["level"] then item["level"] = 8 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_04' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 5 end
  if not item["dps"] then item["dps"] = 2.5 end
  if not item["speed"] then item["speed"] = 2.6 end
end

do
  local item = MTH_DS_AmmoItems[58193]
  if not item then
    item = {}
    MTH_DS_AmmoItems[58193] = item
  end
  if not item["name"] then item["name"] = 'Demon Hair Bow' end
  if not item["level"] then item["level"] = 40 end
  if not item["reqlevel"] then item["reqlevel"] = 35 end
  if not item["icon"] then item["icon"] = 'GenBow_twow3F' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 21.3 end
  if not item["speed"] then item["speed"] = 3.1 end
  if not item["drops"] then item["drops"] = {} end
  if item["drops"][62665] == nil then item["drops"][62665] = 25 end
end

do
  local item = MTH_DS_AmmoItems[58284]
  if not item then
    item = {}
    MTH_DS_AmmoItems[58284] = item
  end
  if not item["name"] then item["name"] = 'Waterlogged Blunderbuss' end
  if not item["level"] then item["level"] = 35 end
  if not item["reqlevel"] then item["reqlevel"] = 30 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_03' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 14.3 end
  if not item["speed"] then item["speed"] = 3 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][12843] == nil then item["objects"][12843] = 12.5 end
end

do
  local item = MTH_DS_AmmoItems[60165]
  if not item then
    item = {}
    MTH_DS_AmmoItems[60165] = item
  end
  if not item["name"] then item["name"] = 'Wobblefree Fizz-rifle' end
  if not item["level"] then item["level"] = 59 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_06' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 34.2 end
  if not item["speed"] then item["speed"] = 2.6 end
end

do
  local item = MTH_DS_AmmoItems[60309]
  if not item then
    item = {}
    MTH_DS_AmmoItems[60309] = item
  end
  if not item["name"] then item["name"] = "'Jadewood' Longbow" end
  if not item["level"] then item["level"] = 40 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_08' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 17.9 end
  if not item["speed"] then item["speed"] = 1.9 end
end

do
  local item = MTH_DS_AmmoItems[60338]
  if not item then
    item = {}
    MTH_DS_AmmoItems[60338] = item
  end
  if not item["name"] then item["name"] = 'Lordaeron Rusty Crossbow' end
  if not item["level"] then item["level"] = 15 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Crossbow_01' end
  if not item["subtype"] then item["subtype"] = 'crossbow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 5.8 end
  if not item["speed"] then item["speed"] = 3 end
end

do
  local item = MTH_DS_AmmoItems[60339]
  if not item then
    item = {}
    MTH_DS_AmmoItems[60339] = item
  end
  if not item["name"] then item["name"] = 'High Elven Rotten Bow' end
  if not item["level"] then item["level"] = 15 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_11' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 5.9 end
  if not item["speed"] then item["speed"] = 2.3 end
end

do
  local item = MTH_DS_AmmoItems[60440]
  if not item then
    item = {}
    MTH_DS_AmmoItems[60440] = item
  end
  if not item["name"] then item["name"] = 'Bloodscalp Longbow' end
  if not item["level"] then item["level"] = 50 end
  if not item["reqlevel"] then item["reqlevel"] = 45 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_02' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 27.3 end
  if not item["speed"] then item["speed"] = 3 end
  if not item["drops"] then item["drops"] = {} end
  if item["drops"][80269] == nil then item["drops"][80269] = 25 end
end

do
  local item = MTH_DS_AmmoItems[60506]
  if not item then
    item = {}
    MTH_DS_AmmoItems[60506] = item
  end
  if not item["name"] then item["name"] = 'Vigilance' end
  if not item["level"] then item["level"] = 65 end
  if not item["reqlevel"] then item["reqlevel"] = 60 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Crossbow_05' end
  if not item["subtype"] then item["subtype"] = 'crossbow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 33.2 end
  if not item["speed"] then item["speed"] = 2.8 end
  if not item["objects"] then item["objects"] = {} end
  if item["objects"][2010867] == nil then item["objects"][2010867] = 25 end
end

do
  local item = MTH_DS_AmmoItems[60545]
  if not item then
    item = {}
    MTH_DS_AmmoItems[60545] = item
  end
  if not item["name"] then item["name"] = 'Techrifle X-TREME 5200' end
  if not item["level"] then item["level"] = 56 end
  if not item["reqlevel"] then item["reqlevel"] = 51 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_06' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 28.1 end
  if not item["speed"] then item["speed"] = 2.6 end
  if not item["drops"] then item["drops"] = {} end
  if item["drops"][60736] == nil then item["drops"][60736] = 20 end
end

do
  local item = MTH_DS_AmmoItems[60624]
  if not item then
    item = {}
    MTH_DS_AmmoItems[60624] = item
  end
  if not item["name"] then item["name"] = 'Goldplated Royal Crossbow' end
  if not item["level"] then item["level"] = 65 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Crossbow_03' end
  if not item["subtype"] then item["subtype"] = 'crossbow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 32.9 end
  if not item["speed"] then item["speed"] = 3.3 end
end

do
  local item = MTH_DS_AmmoItems[60782]
  if not item then
    item = {}
    MTH_DS_AmmoItems[60782] = item
  end
  if not item["name"] then item["name"] = 'Shieldbreaker Arbalest' end
  if not item["level"] then item["level"] = 61 end
  if not item["reqlevel"] then item["reqlevel"] = 56 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Crossbow_15' end
  if not item["subtype"] then item["subtype"] = 'crossbow' end
  if not item["quality"] then item["quality"] = 2 end
  if not item["dps"] then item["dps"] = 34.3 end
  if not item["speed"] then item["speed"] = 3 end
end

do
  local item = MTH_DS_AmmoItems[60821]
  if not item then
    item = {}
    MTH_DS_AmmoItems[60821] = item
  end
  if not item["name"] then item["name"] = 'Theramore Arbalest' end
  if not item["level"] then item["level"] = 47 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Crossbow_02' end
  if not item["subtype"] then item["subtype"] = 'crossbow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 24 end
  if not item["speed"] then item["speed"] = 3.4 end
end

do
  local item = MTH_DS_AmmoItems[60882]
  if not item then
    item = {}
    MTH_DS_AmmoItems[60882] = item
  end
  if not item["name"] then item["name"] = 'Magram Windstriker' end
  if not item["level"] then item["level"] = 53 end
  if not item["reqlevel"] then item["reqlevel"] = 48 end
  if not item["icon"] then item["icon"] = 'GenBow_twow3F' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 30.2 end
  if not item["speed"] then item["speed"] = 2.9 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][80942] == nil then item["vendors"][80942] = 0 end
end

do
  local item = MTH_DS_AmmoItems[60953]
  if not item then
    item = {}
    MTH_DS_AmmoItems[60953] = item
  end
  if not item["name"] then item["name"] = 'Brackenwall Longbow' end
  if not item["level"] then item["level"] = 47 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_07' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 24 end
  if not item["speed"] then item["speed"] = 2.9 end
end

do
  local item = MTH_DS_AmmoItems[61011]
  if not item then
    item = {}
    MTH_DS_AmmoItems[61011] = item
  end
  if not item["name"] then item["name"] = "Flintlocke's Hand Cannon" end
  if not item["level"] then item["level"] = 65 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_09' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 2 end
  if not item["dps"] then item["dps"] = 36.9 end
  if not item["speed"] then item["speed"] = 3.2 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][80943] == nil then item["vendors"][80943] = 0 end
end

do
  local item = MTH_DS_AmmoItems[61068]
  if not item then
    item = {}
    MTH_DS_AmmoItems[61068] = item
  end
  if not item["name"] then item["name"] = 'Dark Iron Desecrator' end
  if not item["level"] then item["level"] = 65 end
  if not item["icon"] then item["icon"] = 'Spell_frost_fireresistancetotem' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 2 end
  if not item["dps"] then item["dps"] = 39.5 end
  if not item["speed"] then item["speed"] = 2.9 end
end

do
  local item = MTH_DS_AmmoItems[61165]
  if not item then
    item = {}
    MTH_DS_AmmoItems[61165] = item
  end
  if not item["name"] then item["name"] = 'Bow of the Night Huntress' end
  if not item["level"] then item["level"] = 35 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_01' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 14.3 end
  if not item["speed"] then item["speed"] = 2.2 end
end

do
  local item = MTH_DS_AmmoItems[61248]
  if not item then
    item = {}
    MTH_DS_AmmoItems[61248] = item
  end
  if not item["name"] then item["name"] = "Beasthunter's Blunderbuss" end
  if not item["level"] then item["level"] = 66 end
  if not item["reqlevel"] then item["reqlevel"] = 60 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_TWoW_02_Gray' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 2 end
  if not item["dps"] then item["dps"] = 37.5 end
  if not item["speed"] then item["speed"] = 2.8 end
  if not item["drops"] then item["drops"] = {} end
  if item["drops"][61223] == nil then item["drops"][61223] = 20 end
end

do
  local item = MTH_DS_AmmoItems[61307]
  if not item then
    item = {}
    MTH_DS_AmmoItems[61307] = item
  end
  if not item["name"] then item["name"] = 'Worgen Hunter Musket' end
  if not item["level"] then item["level"] = 46 end
  if not item["reqlevel"] then item["reqlevel"] = 41 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_TWoW_02_Ironblack' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 24.5 end
  if not item["speed"] then item["speed"] = 2.9 end
  if not item["drops"] then item["drops"] = {} end
  if item["drops"][61419] == nil then item["drops"][61419] = 2 end
end

do
  local item = MTH_DS_AmmoItems[61383]
  if not item then
    item = {}
    MTH_DS_AmmoItems[61383] = item
  end
  if not item["name"] then item["name"] = 'Intricate Gnomish Blunderbuss' end
  if not item["level"] then item["level"] = 37 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_TWoW_01_Gold_Noglow' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 18 end
  if not item["speed"] then item["speed"] = 3 end
end

do
  local item = MTH_DS_AmmoItems[61472]
  if not item then
    item = {}
    MTH_DS_AmmoItems[61472] = item
  end
  if not item["name"] then item["name"] = 'Brigade Rifle' end
  if not item["level"] then item["level"] = 45 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_TWoW_02_Gray' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 21.1 end
  if not item["speed"] then item["speed"] = 2.8 end
end

do
  local item = MTH_DS_AmmoItems[61525]
  if not item then
    item = {}
    MTH_DS_AmmoItems[61525] = item
  end
  if not item["name"] then item["name"] = "Nature's Call" end
  if not item["level"] then item["level"] = 81 end
  if not item["reqlevel"] then item["reqlevel"] = 60 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_04' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 2 end
  if not item["dps"] then item["dps"] = 49 end
  if not item["speed"] then item["speed"] = 3 end
end

do
  local item = MTH_DS_AmmoItems[61569]
  if not item then
    item = {}
    MTH_DS_AmmoItems[61569] = item
  end
  if not item["name"] then item["name"] = 'Time Frozen Bow' end
  if not item["level"] then item["level"] = 64 end
  if not item["reqlevel"] then item["reqlevel"] = 59 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_09' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 32.7 end
  if not item["speed"] then item["speed"] = 3.5 end
end

do
  local item = MTH_DS_AmmoItems[61629]
  if not item then
    item = {}
    MTH_DS_AmmoItems[61629] = item
  end
  if not item["name"] then item["name"] = "Farmer's Musket" end
  if not item["level"] then item["level"] = 46 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_TWoW_02_Purple' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 21.9 end
  if not item["speed"] then item["speed"] = 2.6 end
end

do
  local item = MTH_DS_AmmoItems[61683]
  if not item then
    item = {}
    MTH_DS_AmmoItems[61683] = item
  end
  if not item["name"] then item["name"] = 'Battered Arbalest' end
  if not item["level"] then item["level"] = 45 end
  if not item["reqlevel"] then item["reqlevel"] = 40 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Crossbow_02' end
  if not item["subtype"] then item["subtype"] = 'crossbow' end
  if not item["quality"] then item["quality"] = 6 end
  if not item["dps"] then item["dps"] = 12.3 end
  if not item["speed"] then item["speed"] = 2.2 end
  if not item["drops"] then item["drops"] = {} end
  if item["drops"][61364] == nil then item["drops"][61364] = 6 end
end

do
  local item = MTH_DS_AmmoItems[70049]
  if not item then
    item = {}
    MTH_DS_AmmoItems[70049] = item
  end
  if not item["name"] then item["name"] = 'Worn Crossbow' end
  if not item["level"] then item["level"] = 2 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Crossbow_02' end
  if not item["subtype"] then item["subtype"] = 'crossbow' end
  if not item["quality"] then item["quality"] = 5 end
  if not item["dps"] then item["dps"] = 1.5 end
  if not item["speed"] then item["speed"] = 3 end
end

do
  local item = MTH_DS_AmmoItems[80106]
  if not item then
    item = {}
    MTH_DS_AmmoItems[80106] = item
  end
  if not item["name"] then item["name"] = 'Miscalibrated Rifle' end
  if not item["level"] then item["level"] = 6 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_01' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 5 end
  if not item["dps"] then item["dps"] = 2.5 end
  if not item["speed"] then item["speed"] = 2.8 end
end

do
  local item = MTH_DS_AmmoItems[80127]
  if not item then
    item = {}
    MTH_DS_AmmoItems[80127] = item
  end
  if not item["name"] then item["name"] = 'Polished Boomstick' end
  if not item["level"] then item["level"] = 11 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_03' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 4.8 end
  if not item["speed"] then item["speed"] = 2.4 end
end

do
  local item = MTH_DS_AmmoItems[80207]
  if not item then
    item = {}
    MTH_DS_AmmoItems[80207] = item
  end
  if not item["name"] then item["name"] = 'Worn Wooden Bow' end
  if not item["level"] then item["level"] = 6 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_02' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 5 end
  if not item["dps"] then item["dps"] = 2.5 end
  if not item["speed"] then item["speed"] = 2.8 end
end

do
  local item = MTH_DS_AmmoItems[80223]
  if not item then
    item = {}
    MTH_DS_AmmoItems[80223] = item
  end
  if not item["name"] then item["name"] = "Farstrider Lodge Protector's Bow" end
  if not item["level"] then item["level"] = 23 end
  if not item["reqlevel"] then item["reqlevel"] = 18 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_17' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 11.7 end
  if not item["speed"] then item["speed"] = 2.4 end
end

do
  local item = MTH_DS_AmmoItems[80503]
  if not item then
    item = {}
    MTH_DS_AmmoItems[80503] = item
  end
  if not item["name"] then item["name"] = 'Well-balanced Short Bow' end
  if not item["level"] then item["level"] = 16 end
  if not item["reqlevel"] then item["reqlevel"] = 10 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_02' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 6.8 end
  if not item["speed"] then item["speed"] = 1.7 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][80266] == nil then item["vendors"][80266] = 0 end
end

do
  local item = MTH_DS_AmmoItems[80546]
  if not item then
    item = {}
    MTH_DS_AmmoItems[80546] = item
  end
  if not item["name"] then item["name"] = "Quel'dorei Ranger's Longbow" end
  if not item["level"] then item["level"] = 65 end
  if not item["reqlevel"] then item["reqlevel"] = 60 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_17' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 33.3 end
  if not item["speed"] then item["speed"] = 2.9 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][80266] == nil then item["vendors"][80266] = 0 end
end

do
  local item = MTH_DS_AmmoItems[80603]
  if not item then
    item = {}
    MTH_DS_AmmoItems[80603] = item
  end
  if not item["name"] then item["name"] = 'Sturdy Short Bow' end
  if not item["level"] then item["level"] = 16 end
  if not item["reqlevel"] then item["reqlevel"] = 10 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_02' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 6.2 end
  if not item["speed"] then item["speed"] = 1.7 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][80807] == nil then item["vendors"][80807] = 0 end
  if item["vendors"][80915] == nil then item["vendors"][80915] = 0 end
end

do
  local item = MTH_DS_AmmoItems[80646]
  if not item then
    item = {}
    MTH_DS_AmmoItems[80646] = item
  end
  if not item["name"] then item["name"] = "Revantusk Shadow Hunter's Longbow" end
  if not item["level"] then item["level"] = 65 end
  if not item["reqlevel"] then item["reqlevel"] = 60 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_08' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 33.3 end
  if not item["speed"] then item["speed"] = 2.9 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][80807] == nil then item["vendors"][80807] = 0 end
  if item["vendors"][80915] == nil then item["vendors"][80915] = 0 end
end

do
  local item = MTH_DS_AmmoItems[80745]
  if not item then
    item = {}
    MTH_DS_AmmoItems[80745] = item
  end
  if not item["name"] then item["name"] = 'Abomination Crossbow' end
  if not item["level"] then item["level"] = 42 end
  if not item["reqlevel"] then item["reqlevel"] = 37 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Crossbow_04' end
  if not item["subtype"] then item["subtype"] = 'crossbow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 22.3 end
  if not item["speed"] then item["speed"] = 3 end
end

do
  local item = MTH_DS_AmmoItems[80795]
  if not item then
    item = {}
    MTH_DS_AmmoItems[80795] = item
  end
  if not item["name"] then item["name"] = 'Burstshot Harquebus' end
  if not item["level"] then item["level"] = 56 end
  if not item["reqlevel"] then item["reqlevel"] = 51 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_06' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 28.8 end
  if not item["speed"] then item["speed"] = 2.6 end
  if not item["drops"] then item["drops"] = {} end
  if item["drops"][9045] == nil then item["drops"][9045] = 0.01 end
  if item["drops"][9097] == nil then item["drops"][9097] = 0.01 end
  if item["drops"][9098] == nil then item["drops"][9098] = 0.01 end
  if item["drops"][9196] == nil then item["drops"][9196] = 0.01 end
  if item["drops"][9197] == nil then item["drops"][9197] = 0.005 end
  if item["drops"][9199] == nil then item["drops"][9199] = 0.005 end
  if item["drops"][9200] == nil then item["drops"][9200] = 0.005 end
  if item["drops"][9201] == nil then item["drops"][9201] = 0.005 end
  if item["drops"][9216] == nil then item["drops"][9216] = 0.005 end
  if item["drops"][9219] == nil then item["drops"][9219] = 0.005 end
  if item["drops"][9236] == nil then item["drops"][9236] = 0.02 end
  if item["drops"][9239] == nil then item["drops"][9239] = 0.01 end
  if item["drops"][9240] == nil then item["drops"][9240] = 0.01 end
  if item["drops"][9257] == nil then item["drops"][9257] = 0.01 end
  if item["drops"][9258] == nil then item["drops"][9258] = 0.02 end
  if item["drops"][9259] == nil then item["drops"][9259] = 0.005 end
  if item["drops"][9260] == nil then item["drops"][9260] = 0.005 end
  if item["drops"][9261] == nil then item["drops"][9261] = 0.005 end
  if item["drops"][9262] == nil then item["drops"][9262] = 0.005 end
  if item["drops"][9264] == nil then item["drops"][9264] = 0.005 end
  if item["drops"][9265] == nil then item["drops"][9265] = 0.02 end
  if item["drops"][9268] == nil then item["drops"][9268] = 0.005 end
  if item["drops"][9583] == nil then item["drops"][9583] = 0.01 end
  if item["drops"][9692] == nil then item["drops"][9692] = 0.02 end
  if item["drops"][9693] == nil then item["drops"][9693] = 0.005 end
  if item["drops"][9716] == nil then item["drops"][9716] = 0.01 end
  if item["drops"][9717] == nil then item["drops"][9717] = 0.005 end
  if item["drops"][61191] == nil then item["drops"][61191] = 0.01 end
  if item["drops"][61192] == nil then item["drops"][61192] = 0.01 end
  if item["drops"][61193] == nil then item["drops"][61193] = 0.01 end
  if item["drops"][61194] == nil then item["drops"][61194] = 0.01 end
  if item["drops"][61211] == nil then item["drops"][61211] = 0.01 end
  if item["drops"][62555] == nil then item["drops"][62555] = 0.005 end
  if item["drops"][65100] == nil then item["drops"][65100] = 0.01 end
  if item["drops"][65101] == nil then item["drops"][65101] = 0.01 end
  if item["drops"][65102] == nil then item["drops"][65102] = 0.01 end
  if item["drops"][65105] == nil then item["drops"][65105] = 0.01 end
end

do
  local item = MTH_DS_AmmoItems[80820]
  if not item then
    item = {}
    MTH_DS_AmmoItems[80820] = item
  end
  if not item["name"] then item["name"] = 'Quilflinger' end
  if not item["level"] then item["level"] = 13 end
  if not item["reqlevel"] then item["reqlevel"] = 8 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_02' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 4 end
  if not item["dps"] then item["dps"] = 5.5 end
  if not item["speed"] then item["speed"] = 2.1 end
  if not item["drops"] then item["drops"] = {} end
  if item["drops"][5785] == nil then item["drops"][5785] = 35 end
end

do
  local item = MTH_DS_AmmoItems[80825]
  if not item then
    item = {}
    MTH_DS_AmmoItems[80825] = item
  end
  if not item["name"] then item["name"] = 'Flamestring Bow' end
  if not item["level"] then item["level"] = 47 end
  if not item["reqlevel"] then item["reqlevel"] = 42 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_09' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 26.3 end
  if not item["speed"] then item["speed"] = 2.6 end
  if not item["drops"] then item["drops"] = {} end
  if item["drops"][2447] == nil then item["drops"][2447] = 33.3 end
end

do
  local item = MTH_DS_AmmoItems[80876]
  if not item then
    item = {}
    MTH_DS_AmmoItems[80876] = item
  end
  if not item["name"] then item["name"] = 'Silvermoon Bow' end
  if not item["level"] then item["level"] = 2 end
  if not item["reqlevel"] then item["reqlevel"] = 1 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_02' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 5 end
  if not item["dps"] then item["dps"] = 1.5 end
  if not item["speed"] then item["speed"] = 2.3 end
end

do
  local item = MTH_DS_AmmoItems[83094]
  if not item then
    item = {}
    MTH_DS_AmmoItems[83094] = item
  end
  if not item["name"] then item["name"] = 'Monster - Rifle2H, Mechagnome' end
  if not item["level"] then item["level"] = 7 end
  if not item["reqlevel"] then item["reqlevel"] = 2 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_29' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 5 end
  if not item["dps"] then item["dps"] = 2.5 end
  if not item["speed"] then item["speed"] = 2.6 end
end

do
  local item = MTH_DS_AmmoItems[83225]
  if not item then
    item = {}
    MTH_DS_AmmoItems[83225] = item
  end
  if not item["name"] then item["name"] = 'Bow of the Grove' end
  if not item["level"] then item["level"] = 40 end
  if not item["reqlevel"] then item["reqlevel"] = 35 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_11' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 21.3 end
  if not item["speed"] then item["speed"] = 2.6 end
  if not item["drops"] then item["drops"] = {} end
  if item["drops"][92109] == nil then item["drops"][92109] = 23.75 end
end

do
  local item = MTH_DS_AmmoItems[83257]
  if not item then
    item = {}
    MTH_DS_AmmoItems[83257] = item
  end
  if not item["name"] then item["name"] = 'Caer Darrow Reserve Rifle' end
  if not item["level"] then item["level"] = 62 end
  if not item["reqlevel"] then item["reqlevel"] = 56 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Rifle_07' end
  if not item["subtype"] then item["subtype"] = 'gun' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 32.7 end
  if not item["speed"] then item["speed"] = 2.6 end
  if not item["drops"] then item["drops"] = {} end
  if item["drops"][49007] == nil then item["drops"][49007] = 25 end
end

do
  local item = MTH_DS_AmmoItems[83452]
  if not item then
    item = {}
    MTH_DS_AmmoItems[83452] = item
  end
  if not item["name"] then item["name"] = 'Windbreaker' end
  if not item["level"] then item["level"] = 65 end
  if not item["reqlevel"] then item["reqlevel"] = 60 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Bow_01' end
  if not item["subtype"] then item["subtype"] = 'bow' end
  if not item["quality"] then item["quality"] = 3 end
  if not item["dps"] then item["dps"] = 35 end
  if not item["speed"] then item["speed"] = 2.3 end
  if not item["drops"] then item["drops"] = {} end
  if item["drops"][91916] == nil then item["drops"][91916] = 10 end
end

do
  local item = MTH_DS_AmmoItems[83517]
  if not item then
    item = {}
    MTH_DS_AmmoItems[83517] = item
  end
  if not item["name"] then item["name"] = 'Balanced Light Crossbow' end
  if not item["level"] then item["level"] = 16 end
  if not item["reqlevel"] then item["reqlevel"] = 11 end
  if not item["icon"] then item["icon"] = 'INV_Weapon_Crossbow_01' end
  if not item["subtype"] then item["subtype"] = 'crossbow' end
  if not item["quality"] then item["quality"] = 5 end
  if not item["dps"] then item["dps"] = 5.7 end
  if not item["speed"] then item["speed"] = 2.9 end
  if not item["vendors"] then item["vendors"] = {} end
  if item["vendors"][81035] == nil then item["vendors"][81035] = 0 end
end

