local function writeLine(s,r,g,b)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage(s, r or 1, g or 1, b or 0.5)
    end
end

function QuickHeal_Paladin_GetRatioHealthyExplanation()
    local RatioHealthy = QuickHeal_GetRatioHealthy();
    local RatioFull = QuickHealVariables["RatioFull"];

    if RatioHealthy >= RatioFull then
        return QUICKHEAL_SPELL_HOLY_LIGHT .. " will never be used in combat. ";
    else
        if RatioHealthy > 0 then
            return QUICKHEAL_SPELL_HOLY_LIGHT .. " will only be used in combat if the target has more than " .. RatioHealthy*100 .. "% life, and only if the healing done is greater than the greatest " .. QUICKHEAL_SPELL_FLASH_OF_LIGHT .. " available. ";
        else
            return QUICKHEAL_SPELL_HOLY_LIGHT .. " will only be used in combat if the healing done is greater than the greatest " .. QUICKHEAL_SPELL_FLASH_OF_LIGHT .. " available. ";
        end
    end
end

function QuickHeal_Paladin_FindSpellToUse(Target, healType, multiplier, forceMaxHPS)
    local healneed = UnitHealthMax(Target) - UnitHealth(Target);

    local SpellIDsFL = QuickHeal_GetSpellIDs(QUICKHEAL_SPELL_FLASH_OF_LIGHT);
    local FoLR5_Heal = 294; local FoLR5_Mana = 115;
    local FoLR6_Heal = 369; local FoLR6_Mana = 140;
    local FoLR7_Heal = 461; local FoLR7_Mana = 180;

    local _,_,_,_,talentRank,_ = GetTalentInfo(1,5);
    local hlMod = 4*talentRank/100 + 1;

    local Bonus = 0;
    if (BonusScanner) then
        Bonus = tonumber(BonusScanner:GetBonus("HEAL"));
    end
    local healMod15 = (1.5/3.5) * Bonus;

    local ManaLeft = UnitMana('player');
    local SpellID = nil;
    local HealSize = 0;

    if healneed <= (FoLR5_Heal * hlMod + healMod15) and ManaLeft >= FoLR5_Mana then
        SpellID = SpellIDsFL[5]; HealSize = FoLR5_Heal * hlMod + healMod15;
    elseif healneed <= (FoLR6_Heal * hlMod + healMod15) and ManaLeft >= FoLR6_Mana then
        SpellID = SpellIDsFL[6]; HealSize = FoLR6_Heal * hlMod + healMod15;
    elseif ManaLeft >= FoLR7_Mana then
        SpellID = SpellIDsFL[7]; HealSize = FoLR7_Heal * hlMod + healMod15;
    end

    return SpellID, HealSize;
end

function QuickHeal_Paladin_FindHealSpellToUseNoTarget(maxhealth, healDeficit, healType, multiplier, forceMaxHPS, forceMaxRank, hdb, incombat)
    local healneed = healDeficit * multiplier;

    local SpellIDsFL = QuickHeal_GetSpellIDs(QUICKHEAL_SPELL_FLASH_OF_LIGHT);
    local FoLR5_Heal = 294; local FoLR5_Mana = 115;
    local FoLR6_Heal = 369; local FoLR6_Mana = 140;
    local FoLR7_Heal = 461; local FoLR7_Mana = 180;

    local _,_,_,_,talentRank,_ = GetTalentInfo(1,5);
    local hlMod = 4*talentRank/100 + 1;

    local Bonus = 0;
    if (BonusScanner) then
        Bonus = tonumber(BonusScanner:GetBonus("HEAL"));
    end
    local healMod15 = (1.5/3.5) * Bonus;

    local ManaLeft = UnitMana('player');
    local SpellID = nil;
    local HealSize = 0;

    if healneed <= (FoLR5_Heal * hlMod + healMod15) and ManaLeft >= FoLR5_Mana then
        SpellID = SpellIDsFL[5]; HealSize = FoLR5_Heal * hlMod + healMod15;
    elseif healneed <= (FoLR6_Heal * hlMod + healMod15) and ManaLeft >= FoLR6_Mana then
        SpellID = SpellIDsFL[6]; HealSize = FoLR6_Heal * hlMod + healMod15;
    elseif ManaLeft >= FoLR7_Mana then
        SpellID = SpellIDsFL[7]; HealSize = FoLR7_Heal * hlMod + healMod15;
    end

    return SpellID, HealSize;
end

function QuickHeal_Command_Paladin(msg)

    --if PlayerClass == "priest" then
    --  writeLine("PALADIN", 0, 1, 0);
    --end

    local _, _, arg1, arg2, arg3 = string.find(msg, "%s?(%w+)%s?(%w+)%s?(%w+)")

    -- match 3 arguments
    if arg1 ~= nil and arg2 ~= nil and arg3 ~= nil then
        if arg1 == "player" or arg1 == "target" or arg1 == "targettarget" or arg1 == "party" or arg1 == "subgroup" or arg1 == "mt" or arg1 == "nonmt" then
            if arg2 == "heal" and arg3 == "max" then
                --writeLine(QuickHealData.name .. " qh " .. arg1 .. " HEAL(maxHPS)", 0, 1, 0);
                --QuickHeal(arg1, nil, nil, true);
                QuickHeal(arg1, nil, nil, true);
                return;
            end
        end
    end

    -- match 2 arguments
    local _, _, arg4, arg5= string.find(msg, "%s?(%w+)%s?(%w+)")

    if arg4 ~= nil and arg5 ~= nil then
        if arg4 == "debug" then
            if arg5 == "on" then
                QHV.DebugMode = true;
                --writeLine(QuickHealData.name .. " debug mode enabled", 0, 0, 1);
                return;
            elseif arg5 == "off" then
                QHV.DebugMode = false;
                --writeLine(QuickHealData.name .. " debug mode disabled", 0, 0, 1);
                return;
            end
        end
        if arg4 == "heal" and arg5 == "max" then
            --writeLine(QuickHealData.name .. " HEAL (max)", 0, 1, 0);
            QuickHeal(nil, nil, nil, true);
            return;
        end
        if arg4 == "player" or arg4 == "target" or arg4 == "targettarget" or arg4 == "party" or arg4 == "subgroup" or arg4 == "mt" or arg4 == "nonmt" then
            if arg5 == "heal" then
                --writeLine(QuickHealData.name .. " qh " .. arg1 .. " HEAL", 0, 1, 0);
                QuickHeal(arg1, nil, nil, false);
                return;
            end
        end
    end

    -- match 1 argument
    local cmd = string.lower(msg)

    if cmd == "cfg" then
        QuickHeal_ToggleConfigurationPanel();
        return;
    end

    if cmd == "toggle" then
        QuickHeal_Toggle_Healthy_Threshold();
        return;
    end

    if cmd == "downrank" or cmd == "dr" then
        ToggleDownrankWindow()
        return;
    end

    if cmd == "tanklist" or cmd == "tl" then
        QH_ShowHideMTListUI();
        return;
    end

    if cmd == "reset" then
        QuickHeal_SetDefaultParameters();
        writeLine(QuickHealData.name .. " reset to default configuration", 0, 0, 1);
        QuickHeal_ToggleConfigurationPanel();
        QuickHeal_ToggleConfigurationPanel();
        return;
    end

    if cmd == "heal" then
        --writeLine(QuickHealData.name .. " HEAL", 0, 1, 0);
        QuickHeal();
        return;
    end

    if cmd == "" then
        --writeLine(QuickHealData.name .. " qh", 0, 1, 0);
        QuickHeal(nil);
        return;
    elseif cmd == "player" or cmd == "target" or cmd == "targettarget" or cmd == "party" or cmd == "subgroup" or cmd == "mt" or cmd == "nonmt" then
        --writeLine(QuickHealData.name .. " qh " .. cmd, 0, 1, 0);
        QuickHeal(cmd);
        return;
    end

    -- Print usage information if arguments do not match
    --writeLine(QuickHealData.name .. " Usage:");
    writeLine("== QUICKHEAL USAGE : PALADIN ==");
    writeLine("/qh cfg - Opens up the configuration panel.");
    writeLine("/qh toggle - Switches between High HPS and Normal HPS.  Heals (Healthy Threshold 0% or 100%).");
    writeLine("/qh downrank | dr - Opens the slider to limit QuickHeal to constrain healing to lower ranks.");
    writeLine("/qh tanklist | tl - Toggles display of the main tank list UI.");
    writeLine("/qh [mask] [type] [mod] - Heals the party/raid member that most needs it with the best suited healing spell.");
    writeLine(" [mask] constrains healing pool to:");
    writeLine("  [player] yourself");
    writeLine("  [target] your target");
    writeLine("  [targettarget] your target's target");
    writeLine("  [party] your party");
    writeLine("  [mt] main tanks (defined in the configuration panel)");
    writeLine("  [nonmt] everyone but the main tanks");
    writeLine("  [subgroup] raid subgroups (defined in the configuration panel)");

    writeLine(" [mod] (optional) modifies [heal] options:");
    writeLine("  [max] applies maximum rank HPS [heal] to subgroup members that have <100% health");

    writeLine("/qh reset - Reset configuration to default parameters for all classes.");
end