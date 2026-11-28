local M = {}

M.codes = {"en", "es", "pt", "it", "de"}
M.names = {"English", "Español", "Português (BR)", "Italiano", "Deutsch"}

local en = {
    pick_title = "Import Skin", hint_select = "Select", unreadable = "Unreadable", unsupported = "unsupported",
    lbl_skin = "Skin", d_skin = "Set as custom skin when the game starts.",
    u_skin = "Copy .png skins into Import Skins.", v_none = "None",
    setup_apk = "Setup APK", settings = "Settings", update = "Update", exit = "Exit",
    act_setup_sub = "Install from APK", act_settings_sub = "Theme, language, boost",
    act_update_sub = "Check for updates", act_exit_sub = "Back to Ports",
    installed_v = "Installed v%s", arch_title = "Architecture", arch_sel_title = "Select Architecture",
    device = "DEVICE",
    hint_play = "Play", hint_delete = "Delete", hint_move = "Move", hint_menu = "Menu", hint_exit = "Exit",
    hint_open = "Open", hint_versions = "Versions", hint_install = "Install", hint_cancel = "Cancel",
    hint_back = "Back", hint_confirm = "Confirm", hint_change = "Change", hint_next = "Next",
    sec_menu = "MENU", sec_versions = "VERSIONS", sec_apks = "APK FILES",
    sec_both = "THIS APK HAS BOTH ARM32 AND ARM64",
    n_installed = "%d installed", n_found = "%d found",
    no_versions = "No versions installed", no_versions_sub = "Open Setup APK to install one.",
    again_delete = "X again: delete", play = "PLAY",
    no_apk = "No APK found", copy_apk = "Copy your .apk files into:",
    both = "Both", both_d = "The right one is picked at launch.",
    a32_only = "ARM32 only", a32_d = "32-bit, smaller install.",
    a64_only = "ARM64 only", a64_d = "64-bit, smaller install.",
    no_arm = "NO ARM LIBS",
    lbl_theme = "Menu theme", d_theme = "Look of this menu.",
    lbl_language = "Language", d_language = "Language of this menu.",
    lbl_menu_ab = "Menu buttons", d_menu_ab = "Swap confirm and back in menus.",
    lbl_game_ab = "Game A/B", d_game_ab = "Swap the A and B buttons in game.",
    lbl_cpu = "CPU governor", d_cpu = "Used while playing, restored on exit.",
    lbl_gpu = "GPU clock", d_gpu = "GPU speed while playing (Max or fixed MHz).",
    lbl_ram = "RAM boost", d_ram = "Memory bus at full speed while playing.",
    lbl_zram = "ZRAM", d_zram = "Compressed RAM size. Auto = half of RAM.",
    v_classic = "Classic", v_modern = "Modern", v_auto = "Auto", v_swapped = "Swapped",
    v_normal = "Normal", v_default = "Default", v_off = "Off", v_on = "On", v_max = "Max",
    na = "N/A", not_avail = "Not available on this system.",
    c_setup = "[ Setup Apk ]", c_settings = "[ Settings ]", c_update = "[ Update Port ]", c_exit = "Exit",
    c_installed = "Installed: v%s", c_delete_q = "Delete?", yes = "Yes", no = "No",
    c_setup_short = "Setup", c_leftright = "Left/Right",
}

local es = {
    pick_title = "Importar skin", hint_select = "Elegir", unreadable = "Ilegible", unsupported = "no compatible",
    lbl_skin = "Skin", d_skin = "Se pone como skin personalizada al iniciar.",
    u_skin = "Copia skins .png en Import Skins.", v_none = "Ninguna",
    setup_apk = "Instalar APK", settings = "Ajustes", update = "Actualizar", exit = "Salir",
    act_setup_sub = "Instalar desde APK", act_settings_sub = "Tema, idioma, boost",
    act_update_sub = "Buscar actualizaciones", act_exit_sub = "Volver a Ports",
    installed_v = "Instalada v%s", arch_title = "Arquitectura", arch_sel_title = "Elegir arquitectura",
    device = "DISPOSITIVO",
    hint_play = "Jugar", hint_delete = "Borrar", hint_move = "Mover", hint_menu = "Menú", hint_exit = "Salir",
    hint_open = "Abrir", hint_versions = "Versiones", hint_install = "Instalar", hint_cancel = "Cancelar",
    hint_back = "Atrás", hint_confirm = "Confirmar", hint_change = "Cambiar", hint_next = "Siguiente",
    sec_menu = "MENÚ", sec_versions = "VERSIONES", sec_apks = "ARCHIVOS APK",
    sec_both = "ESTE APK TIENE ARM32 Y ARM64",
    n_installed = "Instaladas: %d", n_found = "Encontrados: %d",
    no_versions = "No hay versiones instaladas", no_versions_sub = "Abre Instalar APK para añadir una.",
    again_delete = "X otra vez: borrar", play = "JUGAR",
    no_apk = "No se encontró ningún APK", copy_apk = "Copia tus archivos .apk en:",
    both = "Ambas", both_d = "Se elige la correcta al iniciar.",
    a32_only = "Solo ARM32", a32_d = "32 bits, instalación más ligera.",
    a64_only = "Solo ARM64", a64_d = "64 bits, instalación más ligera.",
    no_arm = "SIN LIBS ARM",
    lbl_theme = "Tema del menú", d_theme = "Aspecto de este menú.",
    lbl_language = "Idioma", d_language = "Idioma de este menú.",
    lbl_menu_ab = "Botones del menú", d_menu_ab = "Invierte aceptar y atrás en menús.",
    lbl_game_ab = "A/B del juego", d_game_ab = "Invierte los botones A y B al jugar.",
    lbl_cpu = "Governor de CPU", d_cpu = "Se usa al jugar, se restaura al salir.",
    lbl_gpu = "Reloj GPU", d_gpu = "Velocidad de GPU al jugar (Máx. o MHz fijos).",
    lbl_ram = "Boost de RAM", d_ram = "Bus de memoria a máxima velocidad.",
    lbl_zram = "ZRAM", d_zram = "Tamaño de RAM comprimida. Auto = mitad de la RAM.",
    v_classic = "Clásico", v_modern = "Moderno", v_auto = "Auto", v_swapped = "Invertido",
    v_normal = "Normal", v_default = "Por defecto", v_off = "Desact.", v_on = "Act.", v_max = "Máx.",
    na = "N/D", not_avail = "No disponible en este sistema.",
    c_setup = "[ Instalar APK ]", c_settings = "[ Ajustes ]", c_update = "[ Actualizar Port ]", c_exit = "Salir",
    c_installed = "Instalada: v%s", c_delete_q = "¿Borrar?", yes = "Sí", no = "No",
    c_setup_short = "Instalar", c_leftright = "Izq./Der.",
}

local pt = {
    pick_title = "Importar skin", hint_select = "Selecionar", unreadable = "Ilegível", unsupported = "incompatível",
    lbl_skin = "Skin", d_skin = "Definida como skin personalizada ao iniciar.",
    u_skin = "Copie skins .png para Import Skins.", v_none = "Nenhuma",
    setup_apk = "Instalar APK", settings = "Ajustes", update = "Atualizar", exit = "Sair",
    act_setup_sub = "Instalar a partir do APK", act_settings_sub = "Tema, idioma, boost",
    act_update_sub = "Buscar atualizações", act_exit_sub = "Voltar aos Ports",
    installed_v = "Instalada v%s", arch_title = "Arquitetura", arch_sel_title = "Escolher arquitetura",
    device = "DISPOSITIVO",
    hint_play = "Jogar", hint_delete = "Excluir", hint_move = "Mover", hint_menu = "Menu", hint_exit = "Sair",
    hint_open = "Abrir", hint_versions = "Versões", hint_install = "Instalar", hint_cancel = "Cancelar",
    hint_back = "Voltar", hint_confirm = "Confirmar", hint_change = "Alterar", hint_next = "Próximo",
    sec_menu = "MENU", sec_versions = "VERSÕES", sec_apks = "ARQUIVOS APK",
    sec_both = "ESTE APK TEM ARM32 E ARM64",
    n_installed = "Instaladas: %d", n_found = "Encontrados: %d",
    no_versions = "Nenhuma versão instalada", no_versions_sub = "Abra Instalar APK para adicionar uma.",
    again_delete = "X de novo: excluir", play = "JOGAR",
    no_apk = "Nenhum APK encontrado", copy_apk = "Copie seus arquivos .apk para:",
    both = "Ambas", both_d = "A certa é escolhida ao iniciar.",
    a32_only = "Somente ARM32", a32_d = "32 bits, instalação menor.",
    a64_only = "Somente ARM64", a64_d = "64 bits, instalação menor.",
    no_arm = "SEM LIBS ARM",
    lbl_theme = "Tema do menu", d_theme = "Aparência deste menu.",
    lbl_language = "Idioma", d_language = "Idioma deste menu.",
    lbl_menu_ab = "Botões do menu", d_menu_ab = "Troca confirmar e voltar nos menus.",
    lbl_game_ab = "A/B do jogo", d_game_ab = "Troca os botões A e B no jogo.",
    lbl_cpu = "Governor da CPU", d_cpu = "Usado ao jogar, restaurado ao sair.",
    lbl_gpu = "Clock da GPU", d_gpu = "Velocidade da GPU ao jogar (Máx. ou MHz fixo).",
    lbl_ram = "Boost da RAM", d_ram = "Barramento de memória no máximo.",
    lbl_zram = "ZRAM", d_zram = "Tamanho da RAM comprimida. Auto = metade da RAM.",
    v_classic = "Clássico", v_modern = "Moderno", v_auto = "Auto", v_swapped = "Trocado",
    v_normal = "Normal", v_default = "Padrão", v_off = "Desl.", v_on = "Lig.", v_max = "Máx.",
    na = "N/D", not_avail = "Indisponível neste sistema.",
    c_setup = "[ Instalar APK ]", c_settings = "[ Ajustes ]", c_update = "[ Atualizar Port ]", c_exit = "Sair",
    c_installed = "Instalada: v%s", c_delete_q = "Excluir?", yes = "Sim", no = "Não",
    c_setup_short = "Instalar", c_leftright = "Esq./Dir.",
}

local it = {
    pick_title = "Importa skin", hint_select = "Seleziona", unreadable = "Illeggibile", unsupported = "non supportata",
    lbl_skin = "Skin", d_skin = "Impostata come skin personalizzata all'avvio.",
    u_skin = "Copia le skin .png in Import Skins.", v_none = "Nessuna",
    setup_apk = "Installa APK", settings = "Impostazioni", update = "Aggiorna", exit = "Esci",
    act_setup_sub = "Installa da APK", act_settings_sub = "Tema, lingua, boost",
    act_update_sub = "Cerca aggiornamenti", act_exit_sub = "Torna ai Ports",
    installed_v = "Installata v%s", arch_title = "Architettura", arch_sel_title = "Scegli architettura",
    device = "DISPOSITIVO",
    hint_play = "Gioca", hint_delete = "Elimina", hint_move = "Sposta", hint_menu = "Menu", hint_exit = "Esci",
    hint_open = "Apri", hint_versions = "Versioni", hint_install = "Installa", hint_cancel = "Annulla",
    hint_back = "Indietro", hint_confirm = "Conferma", hint_change = "Cambia", hint_next = "Avanti",
    sec_menu = "MENU", sec_versions = "VERSIONI", sec_apks = "FILE APK",
    sec_both = "QUESTO APK HA ARM32 E ARM64",
    n_installed = "Installate: %d", n_found = "Trovati: %d",
    no_versions = "Nessuna versione installata", no_versions_sub = "Apri Installa APK per aggiungerne una.",
    again_delete = "X ancora: elimina", play = "GIOCA",
    no_apk = "Nessun APK trovato", copy_apk = "Copia i tuoi file .apk in:",
    both = "Entrambe", both_d = "Quella giusta è scelta all'avvio.",
    a32_only = "Solo ARM32", a32_d = "32 bit, installazione più leggera.",
    a64_only = "Solo ARM64", a64_d = "64 bit, installazione più leggera.",
    no_arm = "NESSUNA LIB ARM",
    lbl_theme = "Tema del menu", d_theme = "Aspetto di questo menu.",
    lbl_language = "Lingua", d_language = "Lingua di questo menu.",
    lbl_menu_ab = "Tasti del menu", d_menu_ab = "Scambia conferma e indietro nei menu.",
    lbl_game_ab = "A/B del gioco", d_game_ab = "Scambia i tasti A e B in gioco.",
    lbl_cpu = "Governor CPU", d_cpu = "Usato in gioco, ripristinato all'uscita.",
    lbl_gpu = "Clock GPU", d_gpu = "Velocità GPU in gioco (Max o MHz fissi).",
    lbl_ram = "Boost RAM", d_ram = "Bus memoria a piena velocità in gioco.",
    lbl_zram = "ZRAM", d_zram = "Dimensione RAM compressa. Auto = metà RAM.",
    v_classic = "Classico", v_modern = "Moderno", v_auto = "Auto", v_swapped = "Scambiati",
    v_normal = "Normale", v_default = "Predefinito", v_off = "Off", v_on = "On", v_max = "Max",
    na = "N/D", not_avail = "Non disponibile su questo sistema.",
    c_setup = "[ Installa APK ]", c_settings = "[ Impostazioni ]", c_update = "[ Aggiorna Port ]", c_exit = "Esci",
    c_installed = "Installata: v%s", c_delete_q = "Eliminare?", yes = "Sì", no = "No",
    c_setup_short = "Installa", c_leftright = "Sin./Des.",
}

local de = {
    pick_title = "Skin importieren", hint_select = "Auswählen", unreadable = "Unlesbar", unsupported = "nicht unterstützt",
    lbl_skin = "Skin", d_skin = "Wird beim Start als eigener Skin gesetzt.",
    u_skin = "Kopiere .png-Skins nach Import Skins.", v_none = "Keine",
    setup_apk = "APK einrichten", settings = "Einstellungen", update = "Aktualisieren", exit = "Beenden",
    act_setup_sub = "Aus APK installieren", act_settings_sub = "Design, Sprache, Boost",
    act_update_sub = "Nach Updates suchen", act_exit_sub = "Zurück zu Ports",
    installed_v = "Installiert v%s", arch_title = "Architektur", arch_sel_title = "Architektur wählen",
    device = "GERÄT",
    hint_play = "Spielen", hint_delete = "Löschen", hint_move = "Bewegen", hint_menu = "Menü", hint_exit = "Beenden",
    hint_open = "Öffnen", hint_versions = "Versionen", hint_install = "Installieren", hint_cancel = "Abbrechen",
    hint_back = "Zurück", hint_confirm = "Bestätigen", hint_change = "Ändern", hint_next = "Weiter",
    sec_menu = "MENÜ", sec_versions = "VERSIONEN", sec_apks = "APK-DATEIEN",
    sec_both = "DIESE APK HAT ARM32 UND ARM64",
    n_installed = "Installiert: %d", n_found = "Gefunden: %d",
    no_versions = "Keine Version installiert", no_versions_sub = "Öffne APK einrichten, um eine hinzuzufügen.",
    again_delete = "X nochmal: löschen", play = "SPIELEN",
    no_apk = "Keine APK gefunden", copy_apk = "Kopiere deine .apk-Dateien nach:",
    both = "Beide", both_d = "Die passende wird beim Start gewählt.",
    a32_only = "Nur ARM32", a32_d = "32 Bit, kleinere Installation.",
    a64_only = "Nur ARM64", a64_d = "64 Bit, kleinere Installation.",
    no_arm = "KEINE ARM-LIBS",
    lbl_theme = "Menü-Design", d_theme = "Aussehen dieses Menüs.",
    lbl_language = "Sprache", d_language = "Sprache dieses Menüs.",
    lbl_menu_ab = "Menü-Tasten", d_menu_ab = "Bestätigen/Zurück im Menü tauschen.",
    lbl_game_ab = "Spiel A/B", d_game_ab = "A- und B-Taste im Spiel tauschen.",
    lbl_cpu = "CPU-Governor", d_cpu = "Beim Spielen aktiv, danach zurückgesetzt.",
    lbl_gpu = "GPU-Takt", d_gpu = "GPU-Takt beim Spielen (Max oder feste MHz).",
    lbl_ram = "RAM-Boost", d_ram = "Speicherbus beim Spielen mit vollem Takt.",
    lbl_zram = "ZRAM", d_zram = "Größe des komprimierten RAM. Auto = halber RAM.",
    v_classic = "Klassisch", v_modern = "Modern", v_auto = "Auto", v_swapped = "Getauscht",
    v_normal = "Normal", v_default = "Standard", v_off = "Aus", v_on = "An", v_max = "Max",
    na = "k. A.", not_avail = "Auf diesem System nicht verfügbar.",
    c_setup = "[ APK einrichten ]", c_settings = "[ Einstellungen ]", c_update = "[ Port aktualisieren ]", c_exit = "Beenden",
    c_installed = "Installiert: v%s", c_delete_q = "Löschen?", yes = "Ja", no = "Nein",
    c_setup_short = "Einrichten", c_leftright = "Links/Rechts",
}

local TABLES = {en = en, es = es, pt = pt, it = it, de = de}
local cur = en

function M.set(code)
    cur = TABLES[code] or en
end

function M.valid(code)
    return TABLES[code] ~= nil
end

function M.t(key, ...)
    local s = cur[key] or en[key] or key
    if select("#", ...) > 0 then return string.format(s, ...) end
    return s
end

function M.font(path, size)
    local f = love.graphics.newFont(path, size)
    pcall(function() f:setFallbacks(love.graphics.newFont(size)) end)
    return f
end

return M
