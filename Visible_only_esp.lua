--[[ Swing prediction for  Lmaobox  ]]--
--[[      (Modded misc-tools)       ]]--
--[[          --Authors--           ]]--
--[[           Terminator           ]]--
--[[  (github.com/titaniummachine1  ]]--

local menuLoaded, MenuLib = pcall(require, "Menu")                                -- Load MenuLib
assert(menuLoaded, "MenuLib not found, please install it!")                       -- If not found, throw error
assert(MenuLib.Version >= 1.44, "MenuLib version is too old, please update it!")  -- If version is too old, throw error

--[[ Menu ]]--
local menu = MenuLib.Create("visible_only_esp", MenuFlags.AutoSize)
menu.Style.TitleBg = { 205, 95, 50, 255 } -- Title Background Color (Flame Pea)
menu.Style.Outline = true                 -- Outline around the menu

local Visible_Only = menu:AddComponent(MenuLib.Checkbox("Visible Only", true))

local defaultSetting = gui.GetValue("minimal priority")                                     -- If autobackstab is enabled, set it to legit

if defaultSetting ~= "off" then
    gui.SetValue("minimal priority", 1)
elseif defaultSetting == 1 then
    gui.SetValue("minimal priority", 1)
end

local hitboxes = {
    HEAD = 1,
    NECK = 2,
    PELVIS = 4,
    BODY = 5,
    CHEST = 7
}

local function is_visible(target, from, to)
    local trace = engine.TraceLine(from, to, MASK_SHOT)
    return trace.entity == target or trace.fraction > 0.99
end

local function get_hitbox_position(entity, hitbox)
    local hitbox_table = entity:GetHitboxes()[hitbox]
    if not hitbox_table then return end
    return (hitbox_table[1] + hitbox_table[2]) * 0.5
end

local function OnCreateMove()
    if Visible_Only:GetValue() == false then
        gui.SetValue("minimal priority", defaultSetting)
        return
    else
        gui.SetValue("minimal priority", 1)
    end
    local local_player = entities.GetLocalPlayer()
    if not local_player or not local_player:IsAlive() then return end
    
    local players = entities.FindByClass("CTFPlayer")
    for i, player in ipairs(players) do
        if not player:IsValid() or not player:IsAlive() or player:GetTeamNumber() == local_player:GetTeamNumber() then
            playerlist.SetPriority(player, 0)
        else
            local priority = 0
            local local_pos = local_player:GetAbsOrigin()
            local local_eye_pos = local_pos + local_player:GetPropVector("localdata", "m_vecViewOffset[0]")
            local player_pos = player:GetAbsOrigin()
            local player_eye_pos = get_hitbox_position(player, hitboxes.HEAD)

            -- Check if player_eye_pos is within view
            local player_screen_pos = client.WorldToScreen(player:GetAbsOrigin() + player:GetPropVector("localdata", "m_vecViewOffset[0]"))
            if player_screen_pos and player_screen_pos[1] >= 0 and player_screen_pos[1] <= 1920 and player_screen_pos[2] >= 0 and player_screen_pos[2] <= 1080 then
                if is_visible(player, local_eye_pos, player_eye_pos) then
                    priority = 1
                end
            end
            
            playerlist.SetPriority(player, priority)
        end
    end
end


--[[ Remove the menu when unloaded ]]--
local function OnUnload()                                -- Called when the script is unloaded
    MenuLib.RemoveMenu(menu)                             -- Remove the menu
    client.Command('play "ui/buttonclickrelease"', true) -- Play the "buttonclickrelease" sound
end

callbacks.Unregister("Unload", "MCT_Unload")                    -- Unregister the "Unload" callback
callbacks.Unregister("CreateMove", "MCT_CreateMove")            -- Unregister the "CreateMove" callback

callbacks.Register("Unload", "MCT_Unload", OnUnload)                         -- Register the "Unload" callback
callbacks.Register("CreateMove", "MCT_CreateMove", OnCreateMove)             -- Register the "CreateMove" callback
