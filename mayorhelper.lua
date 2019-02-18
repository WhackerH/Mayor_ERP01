script_name('Mayor Helper')
script_version('1')
script_author('Thomas Lawson')
key = require 'vkeys'
rkeys = require 'rkeys'
imgui = require 'imgui'
imadd = require 'imgui_addons'
sp = require 'lib.samp.events'
inicfg = require 'inicfg'
encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8
mainwin = imgui.ImBool(false)
tLastKeys = {}
ooplistt = {}
config_keys ={
	hikey = {v = {key.VK_I}},
	summakey = {v = {key.VK_L}},
	freenalkey = {v = {key.VK_Y}},
	freebankkey = {v = {key.VK_U}}
}
config = {
	main = {
		clist = 0,
		clistb = false,
		passb = false,
		pass = 'pass',
		colormb = false
	}
}
function autoupdate(json_url, prefix, url)
  local dlstatus = require('moonloader').download_status
  local json = getWorkingDirectory() .. '\\'..thisScript().name..'-version.json'
  if doesFileExist(json) then os.remove(json) end
  downloadUrlToFile(json_url, json,
    function(id, status, p1, p2)
      if status == dlstatus.STATUSEX_ENDDOWNLOAD then
        if doesFileExist(json) then
          local f = io.open(json, 'r')
          if f then
            local info = decodeJson(f:read('*a'))
            updatelink = info.updateurl
            updateversion = info.latest
            f:close()
            os.remove(json)
            if updateversion > thisScript().version then
              lua_thread.create(function()
                local dlstatus = require('moonloader').download_status
                local color = -1
                SCM('Обнаружено обновление. Пытаюсь обновиться c '..thisScript().version..' на '..updateversion)
                wait(250)
                downloadUrlToFile(updatelink, thisScript().path,
                  function(id3, status1, p13, p23)
                    if status1 == dlstatus.STATUS_DOWNLOADINGDATA then
                      print(string.format('Загружено %d из %d.', p13, p23))
                    elseif status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
                      print('Загрузка обновления завершена.')
                      SCM('Обновление завершено!')
                      goupdatestatus = true
                      lua_thread.create(function() wait(500) thisScript():reload() end)
                    end
                    if status1 == dlstatus.STATUSEX_ENDDOWNLOAD then
                      if goupdatestatus == nil then
                        SCM('Обновление прошло неудачно. Запускаю устаревшую версию..')
                        update = false
                      end
                    end
                  end
                )
                end, prefix
              )
            else
              update = false
              print('v'..thisScript().version..': Обновление не требуется.')
            end
          end
        else
          print('v'..thisScript().version..': Не могу проверить обновление. Смиритесь или проверьте самостоятельно на '..url)
          update = false
        end
      end
    end
  )
  while update ~= false do wait(100) end
end
function apply_custom_style()
	imgui.SwitchContext()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4

	style.WindowRounding = 2.0
	style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
	style.ChildWindowRounding = 2.0
	style.FrameRounding = 2.0
	style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
	style.ScrollbarSize = 13.0
	style.ScrollbarRounding = 0
	style.GrabMinSize = 8.0
	style.GrabRounding = 1.0
	-- style.Alpha =
	-- style.WindowPadding =
	-- style.WindowMinSize =
	-- style.FramePadding =
	-- style.ItemInnerSpacing =
	-- style.TouchExtraPadding =
	-- style.IndentSpacing =
	-- style.ColumnsMinSpacing = ?
	-- style.ButtonTextAlign =
	-- style.DisplayWindowPadding =
	-- style.DisplaySafeAreaPadding =
	-- style.AntiAliasedLines =
	-- style.AntiAliasedShapes =
	-- style.CurveTessellationTol =

	colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
	colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
	colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
	colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
	colors[clr.ComboBg]                = colors[clr.PopupBg]
	colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
	colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.FrameBg]                = ImVec4(0.16, 0.29, 0.48, 0.54)
	colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.59, 0.98, 0.40)
	colors[clr.FrameBgActive]          = ImVec4(0.26, 0.59, 0.98, 0.67)
	colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
	colors[clr.TitleBgActive]          = ImVec4(0.16, 0.29, 0.48, 1.00)
	colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
	colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
	colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
	colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
	colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
	colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
	colors[clr.CheckMark]              = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.SliderGrab]             = ImVec4(0.24, 0.52, 0.88, 1.00)
	colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.Button]                 = ImVec4(0.26, 0.59, 0.98, 0.40)
	colors[clr.ButtonHovered]          = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.ButtonActive]           = ImVec4(0.06, 0.53, 0.98, 1.00)
	colors[clr.Header]                 = ImVec4(0.26, 0.59, 0.98, 0.31)
	colors[clr.HeaderHovered]          = ImVec4(0.26, 0.59, 0.98, 0.80)
	colors[clr.HeaderActive]           = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.Separator]              = colors[clr.Border]
	colors[clr.SeparatorHovered]       = ImVec4(0.26, 0.59, 0.98, 0.78)
	colors[clr.SeparatorActive]        = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.ResizeGrip]             = ImVec4(0.26, 0.59, 0.98, 0.25)
	colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.59, 0.98, 0.67)
	colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.59, 0.98, 0.95)
	colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
	colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
	colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
	colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
	colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
	colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
	colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end
function SCM(text)
	sampAddChatMessage(string.format(' [Mayor Helper] {ffffff}%s', text), 0x114D71)
end
function rkeys.onHotKey(id, keys)
	if sampIsChatInputActive() or sampIsDialogActive() or isSampfuncsConsoleActive() then
		return false
	end
end
function getFreeCost(lvl)
	if lvl >= 1 and lvl <= 2 then cost = 1000 end
	if lvl >= 3 and lvl <= 6 then cost = 3000 end
	if lvl >= 7 and lvl <= 13 then cost = 6000 end
	if lvl >= 14 and lvl <= 23 then cost = 9000 end
	if lvl >= 24 and lvl <= 35 then cost = 12000 end
	if lvl >= 36 then cost = 15000 end
	return cost
end
function main()
	while not isSampAvailable() do wait(0) end
	SCM('Mayor Helper для Evolve RP 01 успешно загружен')
	if not doesDirectoryExist('moonloader\\config') then createDirectory('moonloader\\config') end
	if not doesDirectoryExist('moonloader\\config\\Mayor Helper') then createDirectory('moonloader\\config\\Mayor Helper') end
	cfg = inicfg.load(config, 'Mayor Helper\\config.ini')
	if not doesFileExist("moonloader/config/Mayor Helper/keys.json") then
        local fa = io.open("moonloader/config/Mayor Helper/keys.json", "w")
        fa:close()
    else
        local fa = io.open("moonloader/config/Mayor Helper/keys.json", 'r')
        if fa then
            config_keys = decodeJson(fa:read('*a'))
		end
	end
	sampRegisterChatCommand('mhe', function() mainwin.v = not mainwin.v end)
	sampRegisterChatCommand('ooplist', ooplist)
	apply_custom_style()
	lua_thread.create(oopCheckDialog)
	hibind = rkeys.registerHotKey(config_keys.hikey.v, true, hikeyk)
	summabind = rkeys.registerHotKey(config_keys.summakey.v, true, summakeyk)
	freenalbind = rkeys.registerHotKey(config_keys.freenalkey.v, true, freenalkeyk)
	freebankbind = rkeys.registerHotKey(config_keys.freebankkey.v, true, freebankkeyk)
	autoupdate("https://raw.githubusercontent.com/WhackerH/Mayor_ERP01/master/mayorhelp.json", '[Mayor Helper]', "https://evolve-rp.su/viewtopic.php?f=21&t=151439")
	while true do wait(0)
		imgui.Process = mainwin.v
	end
end
function onScriptTerminate(scr)
	if doesFileExist('moonloader/config/Mayor Helper/keys.json') then
		os.remove('moonloader/config/Mayor Helper/keys.json')
	end
	local fa = io.open("moonloader/config/Mayor Helper/keys.json", "w")
	if fa then
		fa:write(encodeJson(config_keys))
		fa:close()
	end
end
function sp.onServerMessage(color, text)
	if (text:match('дело на имя .+ рассмотрению не подлежит, ООП') or text:match('дело .+ рассмотрению не подлежит %- ООП.')) and (color == -8224086 or color == -65366) then
        local ooptext = text:match('Mayor, (.+)')
        table.insert(ooplistt, ooptext)
    end
	if text:find('Рабочий день начат') and color ~= -1 then
        if cfg.main.clistb then
            lua_thread.create(function()
                wait(100)
                SCM('Цвет ника сменен на: {114D71}'..cfg.main.clist)
                sampSendChat('/clist '..tonumber(cfg.main.clist))
                rabden = true
            end)
        end
    end
    if text:find('Рабочий день окончен') and color ~= -1 then
        rabden = false
    end
	if cfg.main.colormb then
		if text:match('ID: .+ | .+: .+ %- .+') and color == 479068104 then
	        local id, nick, rang, stat = text:match('ID: (%d+) | (.+): (.+) %- (.+)')
	        local color = ("%06X"):format(bit.band(sampGetPlayerColor(id), 0xFFFFFF))
	        local color = string.format('0x'..color..'AA')
	        return {color, text}
	    end
	    if text:match('ID: .+ | .+: .+') and color == 479068104 then
	        local id, nick, rang = text:match('ID: (%d+) | (.+): (.-)')
	        local color = ("%06X"):format(bit.band(sampGetPlayerColor(id), 0xFFFFFF))
	        local color = string.format('0x'..color..'AA')
	        return {color, text}
	    end
	end
end
function sp.onSendSpawn()
    if cfg.main.clistb and rabden then
        lua_thread.create(function()
            wait(1200)
            ftext('Цвет ника сменен на: {114D71}' .. cfg.main.clist)
            sampSendChat('/clist '..cfg.main.clist)
        end)
    end
end
function sp.onShowDialog(id, style, title, button1, button2, text)
	if id == 1 and cfg.main.passb and #cfg.main.pass >= 6 then
        sampSendDialogResponse(id, 1, _, cfg.main.pass)
        return false
    end
end
function imgui.OnDrawFrame()
	if mainwin.v then
		local clistbb = imgui.ImBool(cfg.main.clistb)
		local clistint = imgui.ImInt(cfg.main.clist)
		local passbb = imgui.ImBool(cfg.main.passb)
		local passbuff = imgui.ImBuffer(u8(cfg.main.pass), 256)
		local iScreenWidth, iScreenHeight = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(iScreenWidth / 2, iScreenHeight / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin('Mayor Helper', mainwin, imgui.WindowFlags.NoResize)
		imgui.BeginChild('##1', imgui.ImVec2(260, 150), true)
		if imadd.HotKey('##hik', config_keys.hikey, tLastKeys, 100) then rkeys.changeHotKey(hibind, config_keys.hikey.v) end imgui.SameLine() imgui.Text(u8 'Приветствие')
		if imadd.HotKey('##sumk', config_keys.summakey, tLastKeys, 100) then rkeys.changeHotKey(summabind, config_keys.summakey.v) end imgui.SameLine() imgui.Text(u8 'Огласить сумму')
		if imadd.HotKey('##freenk', config_keys.freenalkey, tLastKeys, 100) then rkeys.changeHotKey(freenalbind, config_keys.freenalkey.v) end imgui.SameLine() imgui.Text(u8 'Выпустить наличными')
		if imadd.HotKey('##freebk', config_keys.freebankkey, tLastKeys, 100) then rkeys.changeHotKey(freebankbind, config_keys.freebankkey.v) end imgui.SameLine() imgui.Text(u8 'Выпустить через банк')
		imgui.EndChild()
		imgui.SameLine()
		imgui.BeginChild('##2', imgui.ImVec2(300, 150), true)
		if imgui.Checkbox(u8 'Использовать автоклист', clistbb) then cfg.main.clistb = clistbb.v inicfg.save(config, 'Mayor Helper\\config.ini') end
		if clistbb.v then
			imgui.PushItemWidth(50)
			if imgui.InputInt(u8 'Номер цвета', clistint, 0) then cfg.main.clist = clistint.v inicfg.save(config, 'Mayor Helper\\config.ini') end
			imgui.PopItemWidth()
		end
		if imgui.Checkbox(u8 'Использовать автологин', passbb) then cfg.main.passb = passbb.v inicfg.save(config, 'Mayor Helper\\config.ini') end
		if passbb.v then
			if imgui.InputText(u8 'Ваш пароль', passbuff) then cfg.main.pass = u8:decode(passbuff.v) inicfg.save(config, 'Mayor Helper\\config.ini') end
		end
		imgui.EndChild()
		imgui.End()
	end
end
function hikeyk()
	lua_thread.create(function()
		sampSendChat(string.format('Приветствую, я адвокат %s. Кто нуждается в моих услугах?', sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))):gsub('_', ' ')))
		wait(1200)
		sampSendChat(string.format('/b /showpass %s', select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))))
	end)
end
function summakeyk()
	lua_thread.create(function()
		local valid, tped = getCharPlayerIsTargeting(PLAYER_HANDLE)
		if valid and doesCharExist(tped) then
			local result, tid = sampGetPlayerIdByCharHandle(tped)
			if result then
				local tlvl = sampGetPlayerScore(tid)
				sampSendChat(string.format('Сумма вашего вызволения составляет %s.', getFreeCost(tlvl)))
				wait(1200)
				sampSendChat('Чем желаете оплатить, банком или наличными?')
			end
		end
	end)
end
function freenalkeyk()
	lua_thread.create(function()
		local valid, tped = getCharPlayerIsTargeting(PLAYER_HANDLE)
		if valid and doesCharExist(tped) then
			local result, tid = sampGetPlayerIdByCharHandle(tped)
			if result then
				local tlvl = sampGetPlayerScore(tid)
				sampSendChat('/me достал бланк из кейса и начал его заполнять')
				wait(1200)
				sampSendChat('/me поставил печать в бланке и передал заключенному')
				wait(1200)
				sampSendChat(string.format('/free %s 1 %s', tid, getFreeCost(tlvl)))
			end
		end
	end)
end
function freebankkeyk()
	lua_thread.create(function()
		local valid, tped = getCharPlayerIsTargeting(PLAYER_HANDLE)
		if valid and doesCharExist(tped) then
			local result, tid = sampGetPlayerIdByCharHandle(tped)
			if result then
				local tlvl = sampGetPlayerScore(tid)
				sampSendChat('/me достал бланк из кейса и начал его заполнять')
				wait(1200)
				sampSendChat('/me поставил печать в бланке и передал заключенному')
				wait(1200)
				sampSendChat(string.format('/free %s 2 %s', tid, getFreeCost(tlvl)))
			end
		end
	end)
end
function ooplist(pam)
    lua_thread.create(function()
        local oopid = tonumber(pam)
        if oopid ~= nil and sampIsPlayerConnected(oopid) then
            for k, v in pairs(ooplistt) do
                sampSendChat('/sms '..oopid..' '..v)
                wait(1200)
            end
        else
            sampShowDialog(2458, '{114D71}Mayor Helper | {ffffff}Список ООП', table.concat(ooplistt, '\n'), '»', "x", 2)
            SCM('Для отправки списка ООП адвокату введите /ooplist [id]')
        end
    end)
end
function oopCheckDialog()
	while true do wait(0)
		local ooplresult, button, list, input = sampHasDialogRespond(2458)
        local oopdelresult, button, list, input = sampHasDialogRespond(2459)
		if oopdelresult then
            if button == 1 then
                local oopi = 1
                while oopi <= #ooplistt do
                    if ooplistt[oopi]:find(oopdelnick) then
                        table.remove(ooplistt, oopi)
                    else
                        oopi = oopi + 1
                    end
                end
                SCM('Игрок {114D71}'..oopdelnick..'{ffffff} был удален из списка ООП')
            elseif button == 0 then
                sampShowDialog(2458, '{114D71}Mayor Helper | {ffffff}Список ООП', table.concat(ooplistt, '\n'), '»', "x", 2)
            end
        end
        if ooplresult then
            if button == 1 then
                local ltext = sampGetListboxItemText(list)
                if ltext:match("дело на имя .+ рассмотрению не подлежит, ООП") then
                    oopdelnick = ltext:match("дело на имя (.+) рассмотрению не подлежит, ООП")
                    sampShowDialog(2459, '{114D71}Mayor Helper | {ffffff}Удаление из ООП', "{ffffff}Вы действительно желаете удалить {114D71}"..oopdelnick.."\n{ffffff}Из списка ООП?", "»", "«", 0)
                elseif ltext:match("дело .+ рассмотрению не подлежит %- ООП.") then
                    oopdelnick = ltext:match("дело (.+) рассмотрению не подлежит %- ООП.")
                    sampShowDialog(2459, '{114D71}Mayor Helper | {ffffff}Удаление из ООП', "{ffffff}Вы действительно желаете удалить {114D71}"..oopdelnick.."\n{ffffff}Из списка ООП?", "»", "«", 0)
                end
            end
        end
	end
end
