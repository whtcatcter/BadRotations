
--[[-------------------------------------------------------------------------------------------------------------------------------------------------------]]
--[[---------          ---           --------       -------           --------------------------------------------------------------------------------------------------------------------]]
--[[---------  -----  ----   ---------------  ----  -------  --------  ---------------------------------------------------------------------------------------------------]]
--[[---------  ----  -----           ------  ------  ------  ---------  ----------------------------------------------------------------------------------------------------------]]
--[[---------       ------  --------------             ----  ---------  -------------------------------------------------------------------------------------------------------------]]
--[[---------  ----  -----  -------------  ----------  ----  --------  -------------------------------------------------------------------------------------------------]]
--[[---------  -----  ----           ---  ------------  ---            -------------------------------------------------------------------------------------------------------------------]]
--[[-------------------------------------------------------------------------------------------------------------------------------------------------------]]

-- Chat Overlay: Originally written by Sheuron.
local function onUpdate(self,elapsed) 
  	if self.time < GetTime() - 2.0 then if self:GetAlpha() == 0 then self:Hide(); else self:SetAlpha(self:GetAlpha() - 0.02); end end 
end
chatOverlay = CreateFrame("Frame",nil,ChatFrame1); 
chatOverlay:SetSize(ChatFrame1:GetWidth(),50);
chatOverlay:Hide();
chatOverlay:SetScript("OnUpdate",onUpdate);
chatOverlay:SetPoint("TOP",0,0);
chatOverlay.text = chatOverlay:CreateFontString(nil,"OVERLAY","MovieSubtitleFont");
chatOverlay.text:SetAllPoints();
chatOverlay.texture = chatOverlay:CreateTexture();
chatOverlay.texture:SetAllPoints();
chatOverlay.texture:SetTexture(0,0,0,.50);
chatOverlay.time = 0;
function ChatOverlay(message) 
	chatOverlay:SetSize(ChatFrame1:GetWidth(),50);
  	chatOverlay.text:SetText(message);
  	chatOverlay:SetAlpha(1);
  	chatOverlay.time = GetTime(); 
  	chatOverlay:Show(); 
end	


local frame = CreateFrame("FRAME");
frame:RegisterEvent("ADDON_LOADED");
frame:RegisterEvent("PLAYER_LOGOUT");

function frame:OnEvent(event, arg1)
 	if event == "ADDON_LOADED" and arg1 == "BadBoy" then
 		ChatOverlay("Addons Loaded. Starting BadBoy.");
 		BadBoy_data = BadBoy_data;
 		BadBoyRun();
	end
end
frame:SetScript("OnEvent", frame.OnEvent);



-- Sell Greys Macros
SLASH_Greys1 = "/grey"
SLASH_Greys2 = "/greys"
function SlashCmdList.Greys(msg, editbox)
	SellGreys();
end

function SellGreys()
  	for bag = 0, 4 do
    	for slot = 1, GetContainerNumSlots(bag) do
      		local item = GetContainerItemLink(bag,slot)
      		if item then
				    -- Is it grey quality item?
        		if string.find(item, qualityColors.grey) ~= nil then
          			greyPrice = select(11, GetItemInfo(item)) * select(2, GetContainerItemInfo(bag, slot))
          			if greyPrice > 0 then
            			PickupContainerItem(bag, slot)
            			PickupMerchantItem()
            		end
            	end
            end
        end
    end
    RepairAllItems(1);
    RepairAllItems(0);
    ChatOverlay("Sold Greys.")
end

-- Dump Greys Macros
SLASH_DumpGrey1 = "/dumpgreys"
SLASH_DumpGrey2 = "/dg"
function SlashCmdList.DumpGrey(msg, editbox)
    DumpGreys(1);
end
function DumpGreys(Num)
    local greyTable = {};
    for bag = 0, 4 do
      for slot = 1, GetContainerNumSlots(bag) do
          local item = GetContainerItemLink(bag,slot)
          if item then
            -- Is it grey quality item?
            if string.find(item, qualityColors.grey) ~= nil then
                greyPrice = select(11, GetItemInfo(item)) * select(2, GetContainerItemInfo(bag, slot))
                if greyPrice > 0 then
                    tinsert(greyTable, { Bag = bag, Slot = slot, Price = greyPrice, Item = item});
                end
              end
            end
        end
    end
    table.sort(greyTable, function(x,y)
        if x.Price and y.Price then return x.Price < y.Price; end
    end)
    for i = 1, Num do
        if greyTable[i]~= nil then 
            PickupContainerItem(greyTable[i].Bag, greyTable[i].Slot)
            DeleteCursorItem()
            print("|cffFF0000Removed Grey Item:"..greyTable[i].Item)
        end
    end
end

-------------------------
-- idTip by Silverwind --
-------------------------
local select, UnitBuff, UnitDebuff, UnitAura, UnitGUID, GetGlyphSocketInfo, tonumber, strfind, hooksecurefunc = select, UnitBuff, UnitDebuff, UnitAura, UnitGUID, GetGlyphSocketInfo, tonumber, strfind, hooksecurefunc

local types = {
    spell = "|cffFF0000SpellID",
    item  = "|cffFF0000ItemID",
    glyph = "|cffFF0000GlyphID",
    unit  = "|cffFF0000NPC ID"
}

local function addLine(tooltip, id, type)
    tooltip:AddDoubleLine(type .. ":", "|cffffffff" .. id)
    tooltip:Show()
end

-- Spells
hooksecurefunc(GameTooltip, "SetUnitBuff", function(self, ...)
    local id = select(11, UnitBuff(...))
    if id then addLine(self, id, types.spell) end
end)

hooksecurefunc(GameTooltip, "SetUnitDebuff", function(self,...)
    local id = select(11, UnitDebuff(...))
    if id then addLine(self, id, types.spell) end
end)

hooksecurefunc(GameTooltip, "SetUnitAura", function(self,...)
    local id = select(11, UnitAura(...))
    if id then addLine(self, id, types.spell) end
end)

GameTooltip:HookScript("OnTooltipSetSpell", function(self)
    local id = select(3, self:GetSpell())
    if id then addLine(self, id, types.spell) end
end)

-- Units
local f = CreateFrame("frame")
f:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
f:SetScript("OnEvent", function()
    if GameTooltip:IsVisible() and not UnitIsPlayer("mouseover") and not C_PetBattles.IsInBattle() then
        local id = tonumber(UnitGUID("mouseover"):sub(6, 10), 16)
        if id ~= 0 then
            addLine(GameTooltip, id, types.unit);
        end
    end
end)

-- Items
hooksecurefunc("SetItemRef", function(link, ...)
    local id = tonumber(link:match("spell:(%d+)"))
    if id then addLine(ItemRefTooltip, id, types.item) end
end)

local function attachItemTooltip(self)
    local link = select(2, self:GetItem())
    if link then
        local id = select(3, strfind(link, "^|%x+|Hitem:(%-?%d+):(%d+):(%d+).*"))
        if id then addLine(self, id, types.item) end
    end
end

GameTooltip:HookScript("OnTooltipSetItem", attachItemTooltip)
ItemRefTooltip:HookScript("OnTooltipSetItem", attachItemTooltip)
ItemRefShoppingTooltip1:HookScript("OnTooltipSetItem", attachItemTooltip)
ItemRefShoppingTooltip2:HookScript("OnTooltipSetItem", attachItemTooltip)
ItemRefShoppingTooltip3:HookScript("OnTooltipSetItem", attachItemTooltip)
ShoppingTooltip1:HookScript("OnTooltipSetItem", attachItemTooltip)
ShoppingTooltip2:HookScript("OnTooltipSetItem", attachItemTooltip)
ShoppingTooltip3:HookScript("OnTooltipSetItem", attachItemTooltip)

-- Glyphs
hooksecurefunc(GameTooltip, "SetGlyph", function(self, ...)
    local id = select(4, GetGlyphSocketInfo(...))
    if id then addLine(self, id, types.glyph) end
end)

hooksecurefunc(GameTooltip, "SetGlyphByID", function(self, id)
    if id then addLine(self, id, types.glyph) end
end)