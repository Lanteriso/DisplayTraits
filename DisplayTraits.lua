local LCG = LibStub("LibCustomGlow-1.0")
local config={
J_showKeystone = false, --显示M+钥匙
J_showChest = false,--显示每周胸部水平
J_showTalents = true,--显示天赋
J_showWarmode = false,--显示战争模式状态
J_showPvP = false,--显示PVP天赋
J_showTrinkets = true,--显示饰品
J_showAmulet = true,    --展示艾泽拉斯的心
J_showEssence = true,--显示精华(8.2)
J_showAzeriteEmpoweredItems = true,--展示艾泽里特授权的物品或特征
J_hideItems = false,--隐藏项目
J_showLegendaries = false,--显示传奇
J_showTooltips = true,--在鼠标悬停上显示工具提示
J_showUpgrade = true,--Display+5 ilvl升级层
J_upgradeTexture = 2065618,--纹理+5 ilvl升级特性。必须是在WOWhead上找到的图标编号
J_showMaxTiers = 2,--要显示的特征层的最大数量1 Hide all tiers 2 Show all tiers 3 1 tier ... 7 5 tiers
J_direction = 2, --拾取图标增长方向 1~8
J_spacing = 1,--图标间距
J_mode = 1,--显示方式 1~5
}
local J_modules = {
    ["talent"] = 6,
    ["trinket"] = 1,
    ["essence"] = 2,
    ["trait"] =17,
}




local data = {
    ["talent"] = {},
    ["trinket"] = {},
    ["essence"] = {},
    ["trait"] ={},
}
local t = {}
local frames = {}
local loadMe = C_AzeriteEssence and true or false --8.2 wow version check

local frame = CreateFrame("Frame",nil,UIParent)
frame:SetFrameStrata("BACKGROUND")
frame:SetWidth(38) -- Set these to whatever height/width is needed 
frame:SetHeight(38) -- for your Texture
frame:Show()
frame:EnableMouse(true)
frame:SetMovable(true)
frame:SetPropagateKeyboardInput(true)
frame:SetScript("OnMouseDown", frame.StartMoving)
frame:SetScript("OnMouseUp", frame.StopMovingOrSizing)
frame:SetScript("OnEnter", function(self)
end);
frame:SetScript("OnLeave", function(self)
    DisplayTraitsDB["Point"],_,DisplayTraitsDB["Relay"],DisplayTraitsDB["X"],DisplayTraitsDB["Y"]=frame:GetPoint()
end);
for k,v in pairs(J_modules) do
    for i = 0,v do
        --t[k..i]= frame:CreateTexture(nil,"BACKGROUND")
        frames[k..i] = CreateFrame("Frame",nil,frame)
        frames[k..i]:SetFrameStrata("BACKGROUND")
        
        frames[k..i]:SetWidth(38) -- Set these to whatever height/width is needed 
        frames[k..i]:SetHeight(38) -- for your Texture
        frames[k..i]:Show()

        

        t[k..i] = frames[k..i]:CreateTexture(nil,"BACKGROUND") 
    end
end

--LCG.PixelGlow_Start(frame, {0.95,0.95,0.32,1}, nil, -0.25, nil, 2)
--PixelGlow_start(框架[，颜色[，N[，频率[，长度[，th[，xoffset[，yoffset[，边框[，key]
--PixelGlow_Start(frame[, color[, N[, frequency[, length[, th[, xOffset[, yOffset[, border[ ,key]]]]]]]])
frame:RegisterEvent("ADDON_LOADED") 
frame:SetScript("OnEvent", function(self, event,...) 
    if (event == "CHALLENGE_MODE_COMPLETED" or event == "CHALLENGE_MODE_START" or event == "CHALLENGE_MODE_RESET") then
        J_CHALLENGE_MODE_CSR(self, event, ...)
    elseif (event == "ACTIVE_TALENT_GROUP_CHANGED" or event == "PLAYER_TALENT_UPDATE") then
        J_PLAYER_TALENT(event)
    elseif (event == "PLAYER_EQUIPMENT_CHANGED") then
        J_PLAYER_TRINKETS(event)
    elseif (event == "AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED") then
        J_PLAYER_TRAITS(event)
    elseif (event == "AZERITE_ESSENCE_ACTIVATED" or event == "AZERITE_ESSENCE_UPDATE" or event == "AZERITE_ESSENCE_CHANGED") then
        J_PLAYER_ESSENCE(event)
    elseif self[event] then
       
        return self[event](self, event, ...)
    end
end )


----------------------------------------1------------keystone
local function J_TALENT_SETUP(header,data)
    for k,v in pairs(data) do


            if v.header == header then              
                t[v.header..v.count]:SetTexture(v.icon)
                frames[v.header..v.count]:SetPoint("CENTER",v.xpoint,v.ypoint)
                t[v.header..v.count]:SetPoint("CENTER",0,0)  
                t[v.header..v.count]:SetWidth(38) -- Set these to whatever height/width is needed 
                t[v.header..v.count]:SetHeight(38) -- for your Texture            v.show = false
                v.changed = true
                --LCG.PixelGlow_Start(frames[v.header..v.count], {0.95,0.95,0.32,1}, nil, -0.25, nil, 2)
            end

    end
    return true
end






--4talents
function J_PLAYER_TALENT(event)
    if config["J_showTalents"]
    and (event == "ACTIVE_TALENT_GROUP_CHANGED" or event == "PLAYER_TALENT_UPDATE")
    then
    local header = "talent"

    local count = 0
        for i = 1, 7 do
            for j = 1, 3 do
                local talentID, name, texture, selected, available, spellID, unknown, row, column, known, byRing = GetTalentInfo(i, j, 1)
                if talentID and (known or byRing) then
                    data["talent"][count] = {
                        header = header,
                        name = name,
                        icon = texture,
                        count = count,

                        spellid = spellID,
                        description = GetSpellDescription(spellID),
                        ilvl = "|cFFbbbbbbT"..i.."|r",
                        xpoint = count*38,
                        ypoint = 0,
                        changed = true,
                        show = true,
                    }
                    count = count + 1
                end
            end
        end
   

    J_TALENT_SETUP(header,data["talent"])
    end
end


--8 trinkets 
function J_PLAYER_TRINKETS(event)
    if config["J_showTrinkets"] then

        local header = "trinket"
        local count = 0
        for i = 1, 2 do
            local trinketSlot = 12 + i
            local itemID = GetInventoryItemLink("player", trinketSlot)
            if itemID then
                local name, _, quality, ilvl = GetItemInfo(itemID)
                local icon = GetItemIcon(itemID)
                if quality ~= 5 and name then
                
                    data["trinket"][count] = {
                        header = header,
                        name = ITEM_QUALITY_COLORS[quality].hex..name.."|r",
                        icon = icon,
                        count = count,
                        link = itemID,
                        ilvl = ITEM_QUALITY_COLORS[quality].hex..ilvl.."|r",
                        description = "",
                        xpoint = count*38,
                        ypoint = 38,  
                        changed = true,
                        show = true,
                    }

                    count = count + 1

                end
            end
        end
      
    J_TALENT_SETUP(header,data["trinket"])
    end
end

--10 essence
function J_PLAYER_ESSENCE(event)

    if config["J_showEssence"]
    and loadMe
    and IsEquippedItem(158075) 
    then
     
       
        local header = "essence"
        local count = 0
        local countWith, countWithout, total = 0, 0, 0
        for k, v in pairs(C_AzeriteEssence.GetEssences()) do
            if v.unlocked then
                total = total + 1
            end
        end
        if total > 0 then
            for i = 115, 117 do
                local MilestoneInfo = C_AzeriteEssence.GetMilestoneInfo(i)
                if MilestoneInfo.unlocked then
                    local essence = C_AzeriteEssence.GetMilestoneEssence(MilestoneInfo.ID)
                    if not essence then
                        local name = i == 115 and "Primary Slot" or i == 116 and "Secondary 1 Slot" or "Secondary 2 Slot"
                        data["essence"][count] = {
                            header = header,
                            --name = MilestoneInfo.slot==0 and "Primary Slot" or ("Secondary %s Slot"):format(MilestoneInfo.slot),
                            icon = 1869493,
                            notWorking = true,
                            count = count,
                            xpoint = count*38+76,
                            ypoint = 38,
                            canSelect = MilestoneInfo.canUnlock or false,
                            itemSlot = i==115 and "AMULET" or false,
                            relativeTo = i==115 and false or "AMULET",
                            without = true,
                            description = MilestoneInfo.canUnlock and "Can be unlocked!" or "empty",
                            --ilvl = MilestoneInfo.slot==0 and "|cFFbbbbbbP|r" or ("|cFFbbbbbbS%s|r"):format(MilestoneInfo.slot),
                            changed = true,
                            show = true,
                        }
                        count = count + 1
                        countWithout = countWithout + 1
                    elseif essence then
                        local EssenceInfo = C_AzeriteEssence.GetEssenceInfo(essence)
                        if EssenceInfo then
                            local col = EssenceInfo.rank + 1
                            local link = C_AzeriteEssence.GetEssenceHyperlink(essence, EssenceInfo.rank)
                            data["essence"][count] = {
                                header = header,
                                name = EssenceInfo.name,
                                icon = EssenceInfo.icon,
                                notWorking = not EssenceInfo.valid,
                                count = count,
                                xpoint = count*38+76,
                                ypoint = 38,
                                canSelect = false,
                                itemSlot = i==115 and "AMULET" or false,
                                relativeTo = i==115 and false or "AMULET",
                                without = false,
                                link = link,
                                description = "",
                                --ilvl = MilestoneInfo.slot==0 and ("%sP\124r"):format(ITEM_QUALITY_COLORS[col].hex) or ("%sS%s\124r"):format(ITEM_QUALITY_COLORS[col].hex, MilestoneInfo.slot),
                                --plvl = ("%s[%s]\124r"):format(ITEM_QUALITY_COLORS[col].hex, EssenceInfo.rank),
                                changed = true,
                                show = true,
                            }
                            count = count + 1
                            countWith = countWith + 1
                        end
                    end
                end
            end
        end
        if total - countWith > 0 and countWithout > 0 then
            for k, v in pairs(data["essence"]) do
                if v.without and not v.canSelect then
                    v.canSelect = true
                end
            end
        end
       
        J_TALENT_SETUP(header,data["essence"])
    end
end

--11 azerite traits 
function J_PLAYER_TRAITS(event)

    if (config["J_mode"] == 3 or config["J_mode"] == 5)
    and config["J_showMaxTiers"] ~= 1
    
    then
  

        local header = "trait"
        local count = 0
        local county = 1
        local specID = GetSpecializationInfo(GetSpecialization())
        for _, slot in next, {1,3,5} do
            local item = Item:CreateFromEquipmentSlot(slot)
            if (not item:IsItemEmpty()) then
                local itemLocation = item:GetItemLocation()
                if (C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItem(itemLocation)) then
                    local itemID = GetInventoryItemLink("player", slot)
                    local name, _, quality, ilvl = GetItemInfo(itemID)
                    name = name or ""
                    
                    local circle = 1
                    local tierInfo = C_AzeriteEmpoweredItem.GetAllTierInfo(itemLocation)
                    for tier, info in next, tierInfo do
                        if config["J_showMaxTiers"] == 2 or tier <= config["J_showMaxTiers"]-2 then
                            for _, powerID in next, info.azeritePowerIDs do
                                local powerInfo = C_AzeriteEmpoweredItem.GetPowerInfo(powerID)
                                local id = name..powerInfo.spellID
                                local spellName, _, spellIcon = GetSpellInfo(powerInfo.spellID)
                                local description = GetSpellDescription(powerInfo.spellID)
                                local canSelect = C_AzeriteEmpoweredItem.CanSelectPower(itemLocation, powerID)
                                if powerInfo.spellID == 263978 then
                                    spellIcon = config["J_upgradeTexture"]
                                end
                                if powerID and specID then
                                    if powerInfo.spellID ~= 263978 and C_AzeriteEmpoweredItem.IsPowerSelected(itemLocation, powerID) then
                                        if not data[powerInfo.spellID] then
                                            data[powerInfo.spellID] = {
                                                header = header,
                                                name = spellName,
                                                icon = spellIcon,
                                                spellid = powerInfo.spellID,
                                                count = count,
                                                xpoint = count*38-(county-1)*38*6,
                                                ypoint = 192-county*38,
                                                totalTraits = 1,
                                                description = description,
                                                notWorking = not C_AzeriteEmpoweredItem.IsPowerAvailableForSpec(powerID, specID),
                                                ilvl = "|cFFbbbbbb1|r",
                                                canSelect = false,
                                                relativeTo = itemSlot,
                                                changed = true,
                                                show = true,
                                            }
                                            count = count + 1
                                            county = math.modf(count/6)+1
                                        elseif data[powerInfo.spellID] then
                                            data[powerInfo.spellID].totalTraits = data[powerInfo.spellID].totalTraits + 1
                                            data[powerInfo.spellID].ilvl = "|cFFbbbbbb"..data[powerInfo.spellID].totalTraits.."|r"
                                        end
                                    elseif canSelect then
                                        data["trait"][count] = {
                                            header = header,
                                            name = spellName,
                                            icon = spellIcon,
                                            spellid = powerInfo.spellID,
                                            count = count,
                                            xpoint = count*38-(county-1)*38*6,
                                            ypoint = 192-county*38,
                                            description = description,
                                            notWorking = not C_AzeriteEmpoweredItem.IsPowerAvailableForSpec(powerID, specID),
                                            ilvl = "|cFFbbbbbbT"..circle.."|r",
                                            canSelect = true,
                                            relativeTo = itemSlot,
                                            changed = true,
                                            show = true,
                                        }
                                        count = count + 1
                                        county = math.modf(count/6)+1
                                    end
                                end
                            end
                        end
                        circle = circle + 1
                    end
                end
            end
        end
        J_TALENT_SETUP(header,data["trait"])
    elseif (config["J_mode"] == 1 or config["J_mode"] == 2 or config["J_mode"] == 4)
    and config["J_showAzeriteEmpoweredItems"]
    
    then

        local header = "trait"
        local count = 0
        local county = 1
        local specID = GetSpecializationInfo(GetSpecialization())
        for _, slot in next, {1,3,5} do
            local item = Item:CreateFromEquipmentSlot(slot)
            if (not item:IsItemEmpty()) then
                local itemLocation = item:GetItemLocation()
                if (C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItem(itemLocation)) then
                    local itemID = GetInventoryItemLink("player", slot)
                    local name, _, quality, ilvl = GetItemInfo(itemID)
                    name = name or ""
                    ilvl = ilvl or 1
                    quality = quality or 2
                    local icon = GetItemIcon(itemID)
                    local itemSlot = slot == 1 and "HEAD" or slot == 3 and "SHOULDERS" or slot == 5 and "CHEST"
                    data["trait"][count] = {
                        header = header,
                        name = config["J_hideItems"] and "" or ITEM_QUALITY_COLORS[quality].hex..name.."|r",
                        icon = icon,
                        count = count,
                        xpoint = count*38-(county-1)*38*6,
                        ypoint = 192-county*38,
                        link = itemID,
                        description = "",
                        hideMe = config["J_hideItems"],
                        ilvl = config["J_hideItems"] and "" or ITEM_QUALITY_COLORS[quality].hex..ilvl.."|r",
                        itemSlot = itemSlot,
                        changed = true,
                        show = true,
                    }
                    count = count + 1
                    county = math.modf(count/6)+1
                    if config["J_showMaxTiers"] ~= 1 then
                        local circle = 1
                        local tierInfo = C_AzeriteEmpoweredItem.GetAllTierInfo(itemLocation)
                        for tier, info in next, tierInfo do
                            if config["J_showMaxTiers"] == 2 or tier <= config["J_showMaxTiers"]-2 then
                                for _, powerID in next, info.azeritePowerIDs do
                                    local powerInfo = C_AzeriteEmpoweredItem.GetPowerInfo(powerID)
                                    local id = name..powerInfo.spellID
                                    local spellName, _, spellIcon = GetSpellInfo(powerInfo.spellID)
                                    if powerInfo.spellID == 263978 then
                                        spellIcon = config["J_upgradeTexture"]
                                    end
                                    local description = GetSpellDescription(powerInfo.spellID)
                                    local canSelect = C_AzeriteEmpoweredItem.CanSelectPower(itemLocation, powerID)
                                    if powerID and specID and (C_AzeriteEmpoweredItem.IsPowerSelected(itemLocation, powerID) or canSelect) then
                                        if powerInfo.spellID == 263978 and not canSelect then
                                            if config["J_showUpgrade"] and config["J_showMaxTiers"] == 2 then
                                                
                                                data["trait"][count] = {
                                                    header = header,
                                                    name = spellName,
                                                    icon = spellIcon,
                                                    spellid = powerInfo.spellID,
                                                    count = count,
                                                    xpoint = count*38-(county-1)*38*6,
                                                    ypoint = 192-county*38,
                                                    description = description,
                                                    notWorking = not C_AzeriteEmpoweredItem.IsPowerAvailableForSpec(powerID, specID),
                                                    ilvl = "|cFFbbbbbbT"..circle.."|r",
                                                    canSelect = canSelect,
                                                    relativeTo = itemSlot,
                                                    changed = true,
                                                    show = true,
                                                }
                                            end
                                        count = count + 1
                                        county = math.modf(count/6)+1
                                        else

                                            data["trait"][count] = {
                                                header = header,
                                                name = spellName,
                                                icon = spellIcon,
                                                spellid = powerInfo.spellID,
                                                count = count,
                                                xpoint = count*38-(county-1)*38*6,
                                                ypoint = 192-county*38,
                                                description = description,
                                                notWorking = not C_AzeriteEmpoweredItem.IsPowerAvailableForSpec(powerID, specID),
                                                ilvl = "|cFFbbbbbbT"..circle.."|r",
                                                canSelect = canSelect,
                                                relativeTo = itemSlot,
                                                changed = true,
                                                show = true,
                                            }
                                            count = count + 1
                                            county = math.modf(count/6)+1
                                        end
                                    end
                                end
                            end
                            circle = circle + 1
                        end
                    end
                end
            end
        end

        J_TALENT_SETUP(header,data["trait"])
    end
end



local Stalker = {
["剑刃乱舞"]="钢铁之舞",--盗贼
["可乘之机"]="快速拔枪",
}





function frame:COMBAT_LOG_EVENT_UNFILTERED(event,...)
    --事件类型  Arg 1   Arg 2   Arg3    第四条 第5条     第6条 第7条     第8条 第9条 Arg 10  Arg 11  第12条    第13条        第14条        Arg 15      Arg 16  第17条    Arg 18  第19条    Arg 20
    --拼写缺失  时间戳 事件  藏匿者 源GUID   SourceName  源旗  源RaidFlags  底座  底座名 台旗  台旗  斯佩尔 拼写名称    斯佩尔学派   错误类型    等距  额漏
    --摆动损伤  时间戳 事件  藏匿者 源GUID   SourceName  源旗  源RaidFlags  底座  底座名 台旗  台旗  金额  过火      学校      抵挡      封堵  吸收  临界性 扫视  压碎
    local timestamp,EventType, SourceName, destName, SpellID, ExtraskillID = select(1, CombatLogGetCurrentEventInfo()),select(2, CombatLogGetCurrentEventInfo()), select(5, CombatLogGetCurrentEventInfo()), select(9, CombatLogGetCurrentEventInfo()), select(12, CombatLogGetCurrentEventInfo()), select(15, CombatLogGetCurrentEventInfo())

    local spellname=GetSpellInfo(SpellID)--获取技能名字
    local spelllink=GetSpellLink(SpellID)--获取技能名字详细
    local Extraskilllink=GetSpellLink(ExtraskillID)--被打断的技能


    if UnitIsPlayer(SourceName)then
    print(timestamp,EventType, SourceName, destName, spellname, ExtraskillID)

        if EventType=="SPELL_AURA_REFRESH" or EventType=="SPELL_AURA_APPLIED" then
            if Stalker[spellname] then 
                J_LCG_Highlight_REFRESH(0,Stalker[spellname])
                return
            end
            J_LCG_Highlight_REFRESH(0,spellname)
 
        elseif EventType=="SPELL_AURA_REMOVED" then
            if Stalker[spellname] then 
                J_LCG_Highlight_REMOVED(0.5,Stalker[spellname])
                return
            end
            J_LCG_Highlight_REMOVED(1,spellname)
        end

    end


end
function J_LCG_Highlight_REFRESH(J_time,J_spellName)
    for k,v in pairs(data) do
        for i,j in pairs(v) do
            --print(k,i,j.name,j.spellid)
            if j.name ==J_spellName then
                LCG.PixelGlow_Start(frames[j.header..j.count], {0.95,0.95,0.32,1}, nil, -0.25, nil, 2)
            end
        end
    end
end
function J_LCG_Highlight_REMOVED(J_time,J_spellName)
    for k,v in pairs(data) do
        for i,j in pairs(v) do
            --print(k,i,j.name,j.spellid)
            if j.name ==J_spellName then
                C_Timer.After(J_time, function() LCG.PixelGlow_Stop(frames[j.header..j.count]) end)
            end
        end
    end
end
function frame:ADDON_LOADED(event,...)
    if DisplayTraitsDB == nil then DisplayTraitsDB = {} end
    if DisplayTraitsDB["Point"] == nil then DisplayTraitsDB["Point"] = "BOTTOMLEFT" end
    if DisplayTraitsDB["Relay"] == nil then DisplayTraitsDB["Relay"] = "BOTTOMLEFT" end
    if DisplayTraitsDB["X"] == nil then DisplayTraitsDB["X"] = 530 end
    if DisplayTraitsDB["Y"] == nil then DisplayTraitsDB["Y"] = 530 end
    frame:SetPoint(DisplayTraitsDB["Point"],nil,DisplayTraitsDB["Relay"],DisplayTraitsDB["X"],DisplayTraitsDB["Y"])

      frame:RegisterEvent("CHALLENGE_MODE_COMPLETED")
      frame:RegisterEvent("CHALLENGE_MODE_START")
      frame:RegisterEvent("CHALLENGE_MODE_RESET")
      frame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
      frame:RegisterEvent("PLAYER_TALENT_UPDATE")
      frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
      frame:RegisterEvent("AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED")

      frame:RegisterEvent("AZERITE_ESSENCE_ACTIVATED")
      frame:RegisterEvent("AZERITE_ESSENCE_UPDATE")
      frame:RegisterEvent("AZERITE_ESSENCE_CHANGED")

      frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
      
      J_PLAYER_TRINKETS("event")
      C_Timer.After(5,J_PLAYER_TRAITS)
      J_PLAYER_ESSENCE("event")
end


