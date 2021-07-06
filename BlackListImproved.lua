--author Hasan Smirnov 2021
--black_list_improved = {["player1"] = {reason = "description1", date = "date", block_channels = true}, ["player2"] = {reason = "description2", date = "date", block_channels = true}}
local addonName = "BlackListImproved"
SLASH_BLACKLISTIMPROVED1, SLASH_BLACKLISTIMPROVED2 = "/bli", "/blacklistimproved"
local addonVersion = "1.0"
local bli_buttons = {}
local bli_main_frame = CreateFrame("Frame", "bliFrame", UIParent)
local bli_tooltip = CreateFrame("GameTooltip", "bliDescriptionTooltip", bli_main_frame, "GameTooltipTemplate")
local label_main = bli_main_frame:CreateFontString(nil, "OVERLAY", "GameTooltipText")
local label_search = bli_main_frame:CreateFontString(nil, "OVERLAY", "GameTooltipText")
local last_num_raid_members -- хранит текущее количество игроков в вашем рейде/группе или 0 если не в группе

function bli_main_frame:ShowBlackList()
	kids = {bli_main_frame:GetChildren()}

	for _, child in ipairs(kids) do
		child:Hide()
	end
	
	label_main:SetPoint("TOP", 0, -5)
	label_main:SetText("Black List Improved v"..addonVersion)

	label_search:SetPoint("TOPLEFT", 10, -30)
	label_search:SetText("Search:")

	--Show my parent Frame
	bli_main_frame:SetMovable(true)
	bli_main_frame:EnableMouse(true)
	bli_main_frame:RegisterForDrag("LeftButton")
	bli_main_frame:SetClampedToScreen(true)
	bli_main_frame:SetScript("OnDragStart", function(self)
			self:StartMoving()
	end)
	bli_main_frame:SetScript("OnDragStop", function(self)
			self:StopMovingOrSizing()
	end)
	bli_main_frame:SetSize(300, 600)
	bli_main_frame:SetPoint("CENTER")

	local bgd_texture = bli_main_frame:CreateTexture()
	bgd_texture:SetAllPoints()
	bgd_texture:SetColorTexture(.2, .2, .2, 1)
	bli_main_frame.background = bgd_texture

	--scrollframe
	local scrollframe = CreateFrame("ScrollFrame", "bliScrollFrame", bli_main_frame)
	scrollframe:SetPoint("TOPLEFT", 10, -50)
	scrollframe:SetPoint("BOTTOMRIGHT", -10, 10)

	local scrollframe_texture = scrollframe:CreateTexture()
	scrollframe_texture:SetAllPoints()
	scrollframe_texture:SetColorTexture(.2, .1, .1, 1)
	scrollframe.background = scrollframe_texture

	bli_main_frame.scrollframe = scrollframe

	--scrollbar
	local scrollbar = CreateFrame("Slider", "bliScrollBar", scrollframe, "UIPanelScrollBarTemplate")
	scrollbar:SetPoint("TOPLEFT", bli_main_frame, "TOPRIGHT", 4, -16)
	scrollbar:SetPoint("BOTTOMLEFT", bli_main_frame, "BOTTOMRIGHT", 4, 16)
	scrollbar:SetMinMaxValues(1, 500)
	scrollbar:SetValueStep(1)
	scrollbar.scrollStep = 1
	scrollbar:SetValue(0)
	scrollbar:SetWidth(16)
	scrollbar:SetScript("OnValueChanged", function(self, value) 
		self:GetParent():SetVerticalScroll(value) 
	end)
	bli_main_frame.scrollbar = scrollbar

	scrollframe:SetScrollChild(content)

	local bli_button_close = CreateFrame("Button", "bliCloseButton", bli_main_frame, "UIPanelCloseButton")
	bli_button_close:SetSize(25, 25)
	bli_button_close:SetPoint("TOPRIGHT", 0, 0)
	bli_button_close:SetScript("OnClick", function() bli_main_frame:Hide() end)
	bli_main_frame.bli_button_close = bli_button_close
	
	local bli_button_add = CreateFrame("Button", "bliAddButton", bli_main_frame, "UIPanelButtonTemplate")
	bli_button_add:SetSize(80, 25)
	bli_button_add:SetPoint("TOPRIGHT", -10, -23)
	bli_button_add:SetText("Add player")
	bli_button_add:SetScript("OnClick", function() bli_main_frame:addDescription(nil, nil) end)
	bli_main_frame.bli_button_add = bli_button_add

	local bli_editbox_search = CreateFrame("EditBox", "bliSearchEditBox", bli_main_frame, "InputBoxTemplate")
	bli_editbox_search:SetSize(120, 1)
	bli_editbox_search:SetPoint("TOPLEFT", 65, -36)
	bli_editbox_search:SetScript("OnTextChanged", function() bli_main_frame:filling_list_players(bli_editbox_search:GetText()) end)
	bli_main_frame.bli_editbox_search = bli_editbox_search

	bli_main_frame:filling_list_players(nil)
	bli_main_frame:Show()
end
--ShowBlackList

--заполню таблицу значениями(кнопками) игроков из черного списка
--str_find - строка отбора по имени
function bli_main_frame:filling_list_players(str_find)

	kids = {bli_main_frame.scrollframe:GetChildren()}
	for _, child in ipairs(kids) do
		if child:IsObjectType("Button") then
			child:Hide()
		end
	end

	local i = 0

	if str_find ~= nil and string.len(str_find) > 0 then
		for key, value in pairs(black_list_improved) do
			if string.find(key, str_find) ~= nil then
				i = i + 1
				local bli_button = CreateFrame("Button", nil, bli_main_frame.scrollframe)
				bli_button:SetSize(150, 15)
				bli_button:SetNormalFontObject("GameFontNormal")
				bli_button:SetHighlightFontObject("GameFontHighlight")
				bli_button:SetText(key)
				bli_button:SetScript("OnEnter", function() bli_main_frame:getDescriptionTooltip(bli_button, value.reason) end)
				bli_button:SetScript("OnClick", function() bli_main_frame:editDescription(bli_button, value) end)

				if i == 1 then
		    	bli_button:SetPoint("TOPLEFT", bli_main_frame.scrollframe, 2, -1)
		  	else
		    	bli_button:SetPoint("TOP", bli_buttons[i-1], "BOTTOM")
		  	end

		  	bli_buttons[i] = bli_button
			end
		end
	else
		for key, value in pairs(black_list_improved) do
			i = i + 1
		  local bli_button = CreateFrame("Button", nil, bli_main_frame.scrollframe)
		  bli_button:SetSize(150, 15)
		  bli_button:SetNormalFontObject("GameFontNormal")
		  bli_button:SetHighlightFontObject("GameFontHighlight")
		  bli_button:SetText(key)
		  bli_button:SetScript("OnEnter", function() bli_main_frame:getDescriptionTooltip(bli_button, value.reason) end)
		  bli_button:SetScript("OnClick", function() bli_main_frame:editDescription(bli_button, value) end)
		   
		  if i == 1 then
		  	bli_button:SetPoint("TOPLEFT", bli_main_frame.scrollframe, 2, -1)
		  else
		    bli_button:SetPoint("TOP", bli_buttons[i-1], "BOTTOM")
		  end

		 --  local bli_separator_line = bli_main_frame.scrollframe:CreateLine()
			-- bli_separator_line:SetColorTexture(.1, 0, .1, 1)
			-- bli_separator_line:SetStartPoint("BOTTOMLEFT", bli_button, 0, 0)
			-- bli_separator_line:SetEndPoint("BOTTOMRIGHT", bli_button, 0, 0)
			-- bli_separator_line:SetThickness(2)
 
		  bli_buttons[i] = bli_button
		end
	end
end

function bli_main_frame:getDescriptionTooltip(bli_button, description)
	bli_tooltip:Hide()
	bli_tooltip:SetOwner(bli_button, "ANCHOR_RIGHT")
	--bli_tooltip:AddLine("Причина:")
	--bli_tooltip:AddLine(description)
	bli_tooltip:SetText(description)
	bli_tooltip:Show()
	bli_tooltip:FadeOut()
end

function bli_main_frame:editDescription(bli_button, value)
	bli_main_frame:addDescription(bli_button, value)
end

-- Добавлю игрока и причину
function bli_main_frame:addDescription(bli_button, value)

	if bli_main_frame.frameAddDescription ~= nil then
		bli_main_frame.frameAddDescription:Hide()
		bli_main_frame.frameAddDescription = nil
	end

	local frameAddDescription = CreateFrame("Frame", nil, bli_main_frame)
	frameAddDescription:SetSize(250, 220)
	frameAddDescription:SetPoint("TOPRIGHT", bli_main_frame, "TOPRIGHT", 275, 0)

	local texture = frameAddDescription:CreateTexture()
	texture:SetAllPoints()
	texture:SetColorTexture(.2, .2, .2, 1)
	frameAddDescription.background = texture

	bli_main_frame.frameAddDescription = frameAddDescription

	local bli_button_close = CreateFrame("Button", "bliCloseButtonDescription", frameAddDescription, "UIPanelCloseButton")
	bli_button_close:SetSize(25, 25)
	bli_button_close:SetPoint("TOPRIGHT", 0, 0)
	bli_button_close:SetScript("OnClick", function() frameAddDescription:Hide() end)

	local label_editboxPlayer = frameAddDescription:CreateFontString(frameAddDescription, "OVERLAY", "GameTooltipText")
	label_editboxPlayer:SetPoint("TOPLEFT", 15, -30)
	label_editboxPlayer:SetText("Player:")

	local editboxPlayer = CreateFrame("EditBox", "bliAddPlayerEditBox", frameAddDescription, "InputBoxTemplate")
	editboxPlayer:SetSize(150, 1)
	editboxPlayer:SetPoint("LEFT", frameAddDescription, "TOPLEFT", 65, -35)
	editboxPlayer:SetFontObject(ChatFontNormal)
	editboxPlayer:SetScript("OnEscapePressed", function() frameAddDescription:Hide() end)

	local label_editboxDescription = frameAddDescription:CreateFontString(frameAddDescription, "OVERLAY", "GameTooltipText")
	label_editboxDescription:SetPoint("TOPLEFT", 15, -55)
	label_editboxDescription:SetText("Description:")

	local scrollFrameDescription = CreateFrame("ScrollFrame", nil, frameAddDescription, "UIPanelScrollFrameTemplate")
	scrollFrameDescription:SetSize(200, 100)
	scrollFrameDescription:SetPoint("LEFT", frameAddDescription, "TOPLEFT", 15, -120)

	local edit_texture = scrollFrameDescription:CreateTexture()
	edit_texture:SetAllPoints()
	edit_texture:SetColorTexture(0, 0, 0, .5)
	scrollFrameDescription.background = edit_texture
	
	local editboxDescription = CreateFrame("EditBox", "bliAddDescriptionEditBox", scrollFrameDescription)
	editboxDescription:SetMultiLine(true)
	editboxDescription:SetFontObject(ChatFontNormal)
	editboxDescription:SetWidth(200)
	scrollFrameDescription:SetScrollChild(editboxDescription)
	editboxDescription:SetScript("OnEscapePressed", function() frameAddDescription:Hide() end)

	local checkbuttonBlockChannels = CreateFrame("CheckButton", "bliBlockChannelsCheckButton", frameAddDescription, "ChatConfigCheckButtonTemplate")
	checkbuttonBlockChannels:SetPoint("BOTTOMLEFT", frameAddDescription, 13, 25)
	checkbuttonBlockChannels.tooltip = "Block channels for player"
	--_G[checkbuttonBlockChannels:GetName().."Text"]:SetText(checkbuttonBlockChannels.tooltip)

	local label_BlockChannels = frameAddDescription:CreateFontString(frameAddDescription, "OVERLAY", "GameTooltipText")
	label_BlockChannels:SetPoint("BOTTOMLEFT", 38, 30)
	label_BlockChannels:SetText("Block channels for player")

	local player = GetUnitName("target")

	if bli_button ~= nil then
		editboxPlayer:SetText(bli_button:GetText())
		editboxDescription:SetText(value.reason)
		checkbuttonBlockChannels:SetChecked(value.block_channels)
		editboxDescription:SetFocus()
	elseif player ~= nil then
		editboxPlayer:SetText(player)
		editboxDescription:SetFocus()
	else
		editboxPlayer:SetFocus()
	end

	local buttonSaveDescription = CreateFrame("Button", "bliSaveButton", frameAddDescription, "UIPanelButtonTemplate")
	buttonSaveDescription:SetSize(80, 25)
	buttonSaveDescription:SetPoint("BOTTOMLEFT")
	buttonSaveDescription:SetText("Save")
	buttonSaveDescription:SetScript("OnClick", function() 
		bli_main_frame:saveDescription(editboxPlayer:GetText(), editboxDescription:GetText(), checkbuttonBlockChannels:GetChecked()) 
	end)

	local buttonDeletePlayer = CreateFrame("Button", "bliDeleteButton", frameAddDescription, "UIPanelButtonTemplate")
	buttonDeletePlayer:SetSize(80, 25)
	buttonDeletePlayer:SetPoint("BOTTOMRIGHT")
	buttonDeletePlayer:SetText("Delete")
	buttonDeletePlayer:SetScript("OnClick", function() bli_main_frame:deletePlayer(editboxPlayer:GetText()) end)

	bli_main_frame:filling_list_players(bli_main_frame.bli_editbox_search:GetText())
end --addDescription

function bli_main_frame:saveDescription(player, description, block_channels)
	player = string.gsub(player, "%s+", "")
	black_list_improved[player] = {}
	black_list_improved[player].reason = description
	black_list_improved[player].date = date("%m/%d/%y %H:%M")
	black_list_improved[player].block_channels = block_channels
	bli_main_frame.frameAddDescription:Hide()
	bli_main_frame:filling_list_players(bli_main_frame.bli_editbox_search:GetText())
end

function bli_main_frame:deletePlayer(player)
	black_list_improved[player] = nil
	bli_main_frame.frameAddDescription:Hide()
	bli_main_frame:filling_list_players(bli_main_frame.bli_editbox_search:GetText())
end

function bli_main_frame:checkPlayersInRaid(num_members)
	for i = 1, num_members, 1 do
		name = GetRaidRosterInfo(i)

		if black_list_improved[name] ~= nil then
			print("|cFFFF1C1C "..name.." <-- is on the ignore list! Reason:")
			print("|cFFFF1C1C "..black_list_improved[name].reason)
		end
	end
end

--GROUP_ROSTER_UPDATE вызывается столько раз, сколько [членов рейда]*2
--по этому я отсеиваю хотя бы те события когда счетчик группы еще не увеличился на 1
--все равно пока что вызываются два события вместо одного...
function bli_main_frame:OnEvent(event, ...)
	local args = {...}

	if event == "ADDON_LOADED" and args[1] == "BlackListImproved" then
		print("|cFFFF1C1C Addon "..addonName.." v"..addonVersion.." loaded")
		bli_main_frame:UnregisterEvent("ADDON_LOADED")

		if black_list_improved == nil then
			black_list_improved = {}
		end
	elseif event == "GROUP_ROSTER_UPDATE" then
		local current_num_members = GetNumGroupMembers()
		--print(last_num_raid_members, current_num_members)
		
		if last_num_raid_members < current_num_members then
			--print("add player")
			bli_main_frame:checkPlayersInRaid(current_num_members)
			last_num_raid_members = current_num_members
		else
			last_num_raid_members = current_num_members
		end
	end
end

local function bliPrint(msg, numberChat)
  if numberChat == nil then
    numberChat = 1
  end
  
  if numberChat == 1 then
    ChatFrame1:AddMessage(msg)
  elseif numberChat == 2 then
    ChatFrame2:AddMessage(msg)
  end
end

local function filterChat(self, event, msg, author, ...)
	--local args = {...}
	local player = string.match(author, "(%S+)-")

	if black_list_improved[player] ~= nil and not black_list_improved[player].block_channels then
		return false, "|cFFFA1C1C <IGNORED>"..msg, author, ...
	elseif black_list_improved[player] ~= nil and black_list_improved[player].block_channels then
		return true
	end
end

function BlackListImproved_OnLoad()
	last_num_raid_members = GetNumGroupMembers()
	bli_main_frame:Hide()
	bli_main_frame:RegisterEvent("ADDON_LOADED")
	bli_main_frame:RegisterEvent("GROUP_ROSTER_UPDATE")
	bli_main_frame:SetScript("OnEvent", bli_main_frame.OnEvent)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", filterChat)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", filterChat)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", filterChat)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", filterChat)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", filterChat)
end

function SlashCmdList.BLACKLISTIMPROVED(msg, editbox)
	bli_main_frame:ShowBlackList()
end


BlackListImproved_OnLoad()