-- =====================================================================
-- 0. DATUM TOPOGRÁFICO Y MEMORIA PERSISTENTE (Disco Duro)
-- =====================================================================
local storage = minetest.get_mod_storage() -- Invoca la base de datos del mod
local S = minetest.get_translator("exploration_catholic_church")

exploration_catholic_church_origen = nil
exploration_catholic_church_altares = {}
exploration_catholic_church_audio_states = {}

-- El motor lee el disco duro al arrancar; si hay un Datum guardado, lo restaura a la RAM
if storage:get_int("datum_establecido") == 1 then
    exploration_catholic_church_origen = {
        x = storage:get_int("origen_x"),
        y = storage:get_int("origen_y"),
        z = storage:get_int("origen_z")
    }
end

-- Comando de Rescate Quirúrgico con Escáner Topográfico (Corregido)
minetest.register_chatcommand("anclar_datum", {
    description = S("Fija el Datum Topográfico escaneando automáticamente el suelo de mármol"),
    func = function(name, param)
        local jugador = minetest.get_player_by_name(name)
        if not jugador then return false, S("Error: Jugador no encontrado.") end

        local pos = jugador:get_pos()
        local x_orig = math.floor(pos.x)
        local z_orig = math.floor(pos.z)
        local y_orig = math.floor(pos.y) -- Cota por defecto

        -- Algoritmo de escaneo: busca el mármol en la columna bajo el jugador
        for i = -1, 4 do
            local cota_y = math.floor(pos.y) - i
            local nodo = minetest.get_node({x = x_orig, y = cota_y, z = z_orig})
            if nodo.name == "exploration_catholic_church:marmol_blanco" then
                y_orig = cota_y -- Ancla la Y exactamente en el mármol
                break
            end
        end
        
        exploration_catholic_church_origen = {
            x = x_orig,
            y = y_orig,
            z = z_orig
        }
        
        -- Guardado termo-magnético utilizando la variable 'storage' de la línea 4
        if storage then
            storage:set_int("datum_establecido", 1)
            storage:set_int("origen_x", x_orig)
            storage:set_int("origen_y", y_orig)
            storage:set_int("origen_z", z_orig)
        end

        return true, S("Datum anclado con precisión láser. Origen Y detectado en la cota: ") .. y_orig
    end,
})

minetest.register_chatcommand("construir_nave", {
    description = S("Establece el Datum Topográfico, genera el suelo y despeja el área"),
    func = function(name, param)
        local jugador = minetest.get_player_by_name(name)
        if not jugador then return false, S("Error: Jugador no encontrado.") end

        local pos_jugador = jugador:get_pos()
        
        -- Fijamos el Datum Topográfico en la RAM
        exploration_catholic_church_origen = {
            x = math.floor(pos_jugador.x),
            y = math.floor(pos_jugador.y) - 1,
            z = math.floor(pos_jugador.z)
        }
        
        -- Respaldamos el Datum en el disco duro desde el inicio
        if storage then
            storage:set_int("datum_establecido", 1)
            storage:set_int("origen_x", exploration_catholic_church_origen.x)
            storage:set_int("origen_y", exploration_catholic_church_origen.y)
            storage:set_int("origen_z", exploration_catholic_church_origen.z)
        end

        local origen = exploration_catholic_church_origen
        local operaciones = 0

        for y = 0, 50 do
            for z = 0, 100 do
                for x = -20, 20 do
                    local pos = {x = origen.x + x, y = origen.y + y, z = origen.z + z}
                    if y == 0 then
                        minetest.set_node(pos, {name = "exploration_catholic_church:marmol_blanco"})
                    else
                        minetest.set_node(pos, {name = "air"})
                    end
                    operaciones = operaciones + 1
                end
            end
        end
        return true, S("Datum establecido permanentemente en disco. Bloques procesados: ") .. operaciones
    end,
})

-- =====================================================================
-- REGISTRO DE MATERIALES Y OBRAS DE ARTE
-- =====================================================================


-- =====================================================================
-- Registro de Nodos del Púlpito y Tornavoz
-- =====================================================================

minetest.register_node("exploration_catholic_church:madera_pulpito", {
    description = S("Madera Tallada del Púlpito"),
    tiles = {"vaticano_madera_pulpito.png"},
    paramtype = "light",
    light_source = 14, -- Resplandor estático sin coste de CPU
    groups = {choppy = 2, wood = 1, arte_sacro = 1}
})

minetest.register_node("exploration_catholic_church:tornavoz_pulpito", {
    description = S("Tornavoz Acústico"),
    tiles = {"vaticano_tornavoz.png"},
    paramtype = "light",
    light_source = 14, -- Resplandor estático sin coste de CPU
    groups = {choppy = 2, wood = 1, arte_sacro = 1}
})


-- =====================================================================
-- Registro de Estructuras del Coro Alto
-- =====================================================================

minetest.register_node("exploration_catholic_church:piso_coro", {
    description = S("Piso de Parquet del Coro"),
    tiles = {"vaticano_piso_coro.png"},
    paramtype = "light",
    light_source = 14, -- Emisión lumínica masiva desde el suelo de la tribuna
    groups = {choppy = 3, wood = 1, arte_sacro = 1}
})

minetest.register_node("exploration_catholic_church:escalera_coro", {
    description = S("Escalera de Caoba"),
    tiles = {"vaticano_escalera_coro.png"},
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.5, 0.5, 0.0, 0.5}, -- Peldaño inferior (base completa)
            {-0.5, 0.0, 0.0, 0.5, 0.5, 0.5},   -- Peldaño superior (mitad trasera)
        }
    },
    groups = {choppy = 3, wood = 1, arte_sacro = 1}
})

minetest.register_node("exploration_catholic_church:marmol_blanco", {
    description = S("Marmol Blanco Central"),
    tiles = {"vaticano_marmol_blanco.png"},
    paramtype = "light",
    light_source = 14, -- Inyección de luz máxima desde el suelo
    groups = {cracky = 3, stone = 1},
})

minetest.register_node("exploration_catholic_church:pilar_piedra", {
    description = S("Pilar de Piedra"),
    tiles = {"vaticano_pilar_piedra.png"},
    paramtype = "light",
    light_source = 14, -- Emisión lumínica masiva estática
    groups = {cracky = 3, stone = 1},
})

minetest.register_node("exploration_catholic_church:muro_lateral", {
    description = S("Muro Lateral de Piedra"),
    tiles = {"vaticano_muro_lateral.png"},
    paramtype = "light",
    light_source = 14, -- Inyección de luz máxima desde las paredes perimetrales
    groups = {cracky = 3, stone = 1},
})

minetest.register_node("exploration_catholic_church:vitral", {
    description = S("Vitral Sagrado"),
    tiles = {"vaticano_vitral.png"},
    drawtype = "glasslike",
    paramtype = "light",
    sunlight_propagates = true,
    use_texture_alpha = "blend",
    light_source = 14, -- Inyección térmica: Ilumina la nave baja a 0 coste de CPU
    groups = {cracky = 3, oddly_breakable_by_hand = 3, arte_sacro = 1}
})

minetest.register_node("exploration_catholic_church:roseton", {
    description = S("Vitral de Rosetón"),
    tiles = {"vaticano_roseton.png"},
    drawtype = "glasslike",
    paramtype = "light",
    sunlight_propagates = true,
    use_texture_alpha = "blend",
    light_source = 14, -- Genera iluminación estática radial máxima
    groups = {cracky = 3, glass = 1, arte_sacro = 1} -- Añadido al inventario sacro
})

minetest.register_node("exploration_catholic_church:porton_bronce", {
    description = S("Bronce Sacro Vaticano"),
    tiles = {"vaticano_porton_bronce.png"},
    paramtype = "light",
    light_source = 14, -- Emisión lumínica masiva estática
    groups = {cracky = 2, stone = 1},
})

minetest.register_node("exploration_catholic_church:techo_fresco", {
    description = S("Bóveda de Fresco Renacentista"),
    tiles = {"vaticano_techo_fresco.png"},
    paramtype = "light",
    light_source = 14, -- Inyección de luz máxima desde la bóveda de cañón
    groups = {cracky = 3, stone = 1},
})

minetest.register_node("exploration_catholic_church:cupula_elegante", {
    description = S("Mosaico Dorado del Crucero"),
    tiles = {"vaticano_cupula_elegante.png"},
    paramtype = "light",
    light_source = 14, -- Emisión lumínica masiva estática
    groups = {cracky = 3, stone = 1},
})

minetest.register_node("exploration_catholic_church:techo_lateral", {
    description = S("Artesonado Elegante Lateral"),
    tiles = {"vaticano_techo_lateral.png"},
    paramtype = "light",
    light_source = 14, -- Emisión lumínica masiva estática
    groups = {cracky = 3, stone = 1},
})

minetest.register_node("exploration_catholic_church:techo_transepto", {
    description = S("Fresco del Transepto"),
    tiles = {"vaticano_techo_transepto.png"},
    paramtype = "light",
    light_source = 14, -- Inyección de luz máxima desde la bóveda transversal
    groups = {cracky = 3, stone = 1},
})

minetest.register_node("exploration_catholic_church:candelabro_oro", {
    description = S("Candelabro Sacro de Oro"),
    drawtype = "plantlike",
    tiles = {"vaticano_candelabro.png"},
    inventory_image = "vaticano_candelabro.png",
    paramtype = "light",
    light_source = 14,
    walkable = false,
    groups = {cracky = 2, oddly_breakable_by_hand = 3},
})

minetest.register_node("exploration_catholic_church:estatua_marmol", {
    description = S("Estatua Sagrada"),
    drawtype = "plantlike",
    tiles = {"vaticano_estatua.png"},
    inventory_image = "vaticano_estatua.png",
    paramtype = "light",
    walkable = false,
    groups = {cracky = 3}
})

minetest.register_node("exploration_catholic_church:banca_madera", {
    description = S("Banca de Caoba"),
    tiles = {"vaticano_madera.png"},
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.1, 0.5, 0.0, 0.5},
            {-0.5, 0.0, 0.3, 0.5, 0.5, 0.5},
        }
    },
    groups = {choppy = 2, oddly_breakable_by_hand = 2},
})

-- =====================================================================
-- Registro de Nodos del Campanario Monumental
-- =====================================================================

minetest.register_node("exploration_catholic_church:muro_campanario", {
    description = S("Sillería del Campanario"),
    tiles = {"vaticano_muro_campanario.png"},
    paramtype = "light",
    light_source = 14, -- Emisión lumínica masiva estática
    groups = {cracky = 3, stone = 1, arte_sacro = 1}
})

minetest.register_node("exploration_catholic_church:techo_campanario", {
    description = S("Cobre Oxidado del Chapitel"),
    tiles = {"vaticano_techo_campanario.png"},
    paramtype = "light",
    light_source = 14, -- Emisión lumínica masiva estática
    groups = {cracky = 3, stone = 1, arte_sacro = 1}
})

minetest.register_node("exploration_catholic_church:campana_bronce", {
    description = S("Campana Monumental de Bronce"),
    tiles = {"vaticano_campana.png"},
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = {
        type = "fixed",
        fixed = {
            {-0.4, -0.5, -0.4, 0.4, 0.0, 0.4},   -- Falda inferior ancha de la campana
            {-0.3, 0.0, -0.3, 0.3, 0.3, 0.3},    -- Cuerpo central
            {-0.15, 0.3, -0.15, 0.15, 0.5, 0.15} -- Corona y anclaje superior
        }
    },
    groups = {cracky = 2, oddly_breakable_by_hand = 2, arte_sacro = 1},
    
    -- Optimización Tuxmatic: Interacción segura (clic derecho). 0 ciclos de CPU en reposo.
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        minetest.sound_play("exploration_catholic_church_campana", {
            pos = pos,
            gain = 5.0, -- Máxima ganancia acústica
            max_hear_distance = 300, -- Se escuchará en todo el valle generado
        })
        return itemstack
    end,
})

-- =====================================================================
-- SISTEMA ACÚSTICO BIOMECÁNICO UNIFICADO (Altares y Órganos)
-- =====================================================================

exploration_catholic_church_organos = {}
exploration_catholic_church_audio_organo_states = {}

minetest.register_node("exploration_catholic_church:altar_mayor", {
    description = S("Altar Mayor con Reliquias"),
    tiles = {
        "vaticano_altar_top.png", "vaticano_marmol_blanco.png",
        "vaticano_altar_side.png", "vaticano_altar_side.png",
        "vaticano_altar_side.png", "vaticano_altar_front.png"
    },
    paramtype2 = "facedir",
    light_source = 8,
    groups = {cracky = 2, arte_sacro = 1},
    on_construct = function(pos) exploration_catholic_church_altares[minetest.pos_to_string(pos)] = pos end,
    on_destruct = function(pos) exploration_catholic_church_altares[minetest.pos_to_string(pos)] = nil end,
})

minetest.register_node("exploration_catholic_church:organo_tubular", {
    description = S("Órgano Tubular Majestuoso"),
    tiles = {
        "vaticano_madera_coro.png", "vaticano_madera_coro.png",
        "vaticano_madera_coro.png", "vaticano_madera_coro.png",
        "vaticano_madera_coro.png", "vaticano_organo_tubos.png"
    },
    paramtype2 = "facedir",
    groups = {choppy = 2, arte_sacro = 1},
    on_construct = function(pos) exploration_catholic_church_organos[minetest.pos_to_string(pos)] = pos end,
    on_destruct = function(pos) exploration_catholic_church_organos[minetest.pos_to_string(pos)] = nil end,
})

minetest.register_lbm({
    label = S("Indexar Emisores Acústicos en Memoria"),
    name = "exploration_catholic_church:indexar_acustica",
    nodenames = {"exploration_catholic_church:altar_mayor", "exploration_catholic_church:organo_tubular"},
    run_at_every_load = true,
    action = function(pos, node)
        local clave = minetest.pos_to_string(pos)
        if node.name == "exploration_catholic_church:altar_mayor" then
            exploration_catholic_church_altares[clave] = pos
        elseif node.name == "exploration_catholic_church:organo_tubular" then
            exploration_catholic_church_organos[clave] = pos
        end
    end,
})

-- =====================================================================
-- RADAR ACÚSTICO DE EXCLUSIÓN MUTUA (Protección de Hilos de CPU)
-- =====================================================================
local RADIO_ACUSTICO = 250
local tiempo_transcurrido = 0

-- Limitador térmico de 2 segundos para no asfixiar el CPU
minetest.register_globalstep(function(dtime)
    tiempo_transcurrido = tiempo_transcurrido + dtime
    if tiempo_transcurrido < 2.0 then return end 
    tiempo_transcurrido = 0

    for _, jugador in ipairs(minetest.get_connected_players()) do
        local nombre = jugador:get_player_name()
        local pos_jugador = jugador:get_pos()
        
        local dist_altar = math.huge
        local dist_organo = math.huge
        
        -- Escaneo del altar más cercano
        for _, pos_a in pairs(exploration_catholic_church_altares) do
            local d = vector.distance(pos_jugador, pos_a)
            if d < dist_altar then dist_altar = d end
        end
        
        -- Escaneo del órgano más cercano
        for _, pos_o in pairs(exploration_catholic_church_organos) do
            local d = vector.distance(pos_jugador, pos_o)
            if d < dist_organo then dist_organo = d end
        end
        
        local reproducir = "silencio"
        
        -- Condicional de exclusión: solo se elige el emisor más cercano dentro del radio
        if dist_altar <= RADIO_ACUSTICO or dist_organo <= RADIO_ACUSTICO then
            if dist_altar < dist_organo then
                reproducir = "altar"
            else
                reproducir = "organo"
            end
        end
        
        -- Despliegue de audio
        if reproducir == "altar" then
            if not exploration_catholic_church_audio_states[nombre] then
                exploration_catholic_church_audio_states[nombre] = minetest.sound_play("exploration_catholic_church_gregoriano", {to_player = nombre, gain = 1.5, loop = true})
            end
            if exploration_catholic_church_audio_organo_states[nombre] then
                minetest.sound_stop(exploration_catholic_church_audio_organo_states[nombre])
                exploration_catholic_church_audio_organo_states[nombre] = nil
            end
            
        elseif reproducir == "organo" then
            if not exploration_catholic_church_audio_organo_states[nombre] then
                exploration_catholic_church_audio_organo_states[nombre] = minetest.sound_play("exploration_catholic_church_polifonia", {to_player = nombre, gain = 1.2, loop = true})
            end
            if exploration_catholic_church_audio_states[nombre] then
                minetest.sound_stop(exploration_catholic_church_audio_states[nombre])
                exploration_catholic_church_audio_states[nombre] = nil
            end
            
        else
            -- Apagado total si el jugador sale del recinto
            if exploration_catholic_church_audio_states[nombre] then
                minetest.sound_stop(exploration_catholic_church_audio_states[nombre])
                exploration_catholic_church_audio_states[nombre] = nil
            end
            if exploration_catholic_church_audio_organo_states[nombre] then
                minetest.sound_stop(exploration_catholic_church_audio_organo_states[nombre])
                exploration_catholic_church_audio_organo_states[nombre] = nil
            end
        end
    end
end)

minetest.register_chatcommand("apagar_cantos", {
    description = S("Detiene temporalmente la reproducción de los cantos gregorianos"),
    func = function(name, param)
        if exploration_catholic_church_audio_states[name] then
            minetest.sound_stop(exploration_catholic_church_audio_states[name])
            exploration_catholic_church_audio_states[name] = nil
            return true, S("El coro ha guardado silencio.")
        else
            return false, S("No hay cantos reproduciéndose para ti.")
        end
    end,
})

-- =====================================================================
-- COMANDOS DE CONSTRUCCIÓN ARQUITECTÓNICA (Anclados al Datum)
-- =====================================================================

minetest.register_chatcommand("construir_nave", {
    description = S("Establece el Datum Topográfico, genera el suelo y despeja el área"),
    func = function(name, param)
        local jugador = minetest.get_player_by_name(name)
        if not jugador then return false, S("Error: Jugador no encontrado.") end

        local pos_jugador = jugador:get_pos()
        
        -- Fijamos el Datum Topográfico en la RAM
        exploration_catholic_church_origen = {
            x = math.floor(pos_jugador.x),
            y = math.floor(pos_jugador.y) - 1,
            z = math.floor(pos_jugador.z)
        }
        local origen = exploration_catholic_church_origen
        local operaciones = 0

        for y = 0, 50 do
            for z = 0, 100 do
                for x = -20, 20 do
                    local pos = {x = origen.x + x, y = origen.y + y, z = origen.z + z}
                    if y == 0 then
                        minetest.set_node(pos, {name = "exploration_catholic_church:marmol_blanco"})
                    else
                        minetest.set_node(pos, {name = "air"})
                    end
                    operaciones = operaciones + 1
                end
            end
        end
        return true, S("Datum establecido y área despejada. Bloques procesados: ") .. operaciones
    end,
})

minetest.register_chatcommand("construir_pilares", {
    description = S("Erige pilares estructurales"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Ejecuta /construir_nave primero.") end

        local grosor = tonumber(param:match("%d+")) or 1
        local material = param:find("borrar") and "air" or "exploration_catholic_church:pilar_piedra"
        local bloques = 0
        local desplazamiento = math.floor(grosor / 2)

        for z_paso = 10, 90, 10 do
            for y = 1, 40 do
                for dx = 0, grosor - 1 do
                    for dz = 0, grosor - 1 do
                        local offset_x = dx - desplazamiento
                        local offset_z = dz - desplazamiento
                        
                        minetest.set_node({x = origen.x - 15 + offset_x, y = origen.y + y, z = origen.z + z_paso + offset_z}, {name = material})
                        minetest.set_node({x = origen.x + 15 + offset_x, y = origen.y + y, z = origen.z + z_paso + offset_z}, {name = material})
                        bloques = bloques + 2
                    end
                end
            end
        end
        return true, S("Columnatas generadas: ") .. bloques .. S(" bloques.")
    end,
})

-- =====================================================================
-- Registro de Nodos del Triforio y Claristorio
-- =====================================================================

minetest.register_node("exploration_catholic_church:muro_triforio", {
    description = S("Arcada de Triforio"),
    tiles = {"vaticano_triforio.png"},
    groups = {cracky = 3, stone = 1, arte_sacro = 1},
})

minetest.register_node("exploration_catholic_church:vitral_gotico", {
    description = S("Vitral Gótico del Claristorio"),
    tiles = {"vaticano_vitral_gotico.png"},
    drawtype = "glasslike",
    paramtype = "light",
    sunlight_propagates = true,
    use_texture_alpha = "blend",
    light_source = 14, -- Optimización: Iluminación estática masiva a coste 0 de CPU
    groups = {cracky = 3, glass = 1, arte_sacro = 1}
})

-- =====================================================================
-- Algoritmo Refactorizado de Muros Perimetrales (Una sola pasada)
-- =====================================================================

minetest.register_chatcommand("construir_muros", {
    description = S("Levanta la sillería, triforio y claristorio en un solo cálculo matemático"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Ejecuta /construir_nave primero.") end

        local bloques = 0
        
        -- Recorremos la nave central (Z = 0 a 100) y la altura de los muros (Y = 1 a 50)
        for z = 0, 100 do
            local modulo_z = z % 10 -- Extraemos el residuo para detectar la posición entre pilares
            
            for y = 1, 50 do
                local nodo_nombre = "exploration_catholic_church:muro_lateral"
                
                -- Nivel del Triforio (Y = 31 a 34)
                -- Dejamos 2 bloques de piedra sólida a cada lado del vano
                if y >= 31 and y <= 34 then
                    if modulo_z >= 2 and modulo_z <= 8 then
                        nodo_nombre = "exploration_catholic_church:muro_triforio"
                    end
                
                -- Nivel del Claristorio / Ventanales (Y = 35 a 46)
                -- Dejamos 3 bloques de piedra sólida a cada lado como marco estructural
                elseif y >= 35 and y <= 46 then
                    if modulo_z >= 3 and modulo_z <= 7 then
                        nodo_nombre = "exploration_catholic_church:vitral_gotico"
                    end
                end

                -- Ejecutamos la escritura en ambos muros laterales simultáneamente
                minetest.set_node({x = origen.x - 20, y = origen.y + y, z = origen.z + z}, {name = nodo_nombre})
                minetest.set_node({x = origen.x + 20, y = origen.y + y, z = origen.z + z}, {name = nodo_nombre})
                bloques = bloques + 2
            end
        end
        return true, S("Extrusión arquitectónica completa. ") .. bloques .. S(" bloques procesados en una sola pasada.")
    end,
})

-- =====================================================================
-- Instalación Óptima de Vitrales Inferiores (Basado en Módulo Z)
-- =====================================================================

minetest.register_chatcommand("construir_vitrales", {
    description = S("Instala vitrales iluminados en la parte baja de los muros perimetrales"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Ejecuta /construir_nave primero.") end

        local bloques = 0
        
        -- Recorremos únicamente la longitud de la nave central (eje Z)
        for z = 10, 90 do
            local modulo_z = z % 10 -- Evalúa el espacio entre los pilares estructurales
            
            -- Si estamos en el vano central entre los pilares (5 bloques de ancho)
            if modulo_z >= 3 and modulo_z <= 7 then
                
                -- Extruimos por debajo de la línea del triforio (Y=31)
                for y = 12, 26 do
                    -- Reemplazamos la sillería en ambos muros perimetrales (X=-20 y X=20)
                    minetest.set_node({x = origen.x - 20, y = origen.y + y, z = origen.z + z}, {name = "exploration_catholic_church:vitral"})
                    minetest.set_node({x = origen.x + 20, y = origen.y + y, z = origen.z + z}, {name = "exploration_catholic_church:vitral"})
                    bloques = bloques + 2
                end
            end
        end
        return true, S("Vitrales inferiores instalados matemáticamente. Bloques iluminados: ") .. bloques
    end,
})

minetest.register_chatcommand("construir_fachadas", {
    description = S("Erige fachadas y portón monumental"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Ejecuta /construir_nave primero.") end

        local bloques = 0
        local radio_arco, altura_jamba = 4, 8

        for x = -20, 20 do
            for y = 1, 50 do
                local pos = {x = origen.x + x, y = origen.y + y, z = origen.z}
                local es_vano = false
                local es_marco = false

                if math.abs(x) <= radio_arco then
                    if y <= altura_jamba then es_vano = true
                    elseif y > altura_jamba and y <= (altura_jamba + radio_arco) then
                        if (x*x) + ((y-altura_jamba)*(y-altura_jamba)) <= (radio_arco*radio_arco) then es_vano = true end
                    end
                end

                if not es_vano and math.abs(x) <= (radio_arco + 1) and y <= (altura_jamba + radio_arco + 1) then es_marco = true end

                if es_vano then minetest.set_node(pos, {name = "air"})
                elseif es_marco then minetest.set_node(pos, {name = "exploration_catholic_church:porton_bronce"})
                else minetest.set_node(pos, {name = "exploration_catholic_church:muro_lateral"}) end
                
                minetest.set_node({x = origen.x + x, y = origen.y + y, z = origen.z + 100}, {name = "exploration_catholic_church:muro_lateral"})
                bloques = bloques + 2
            end
        end
        return true, S("Fachadas completadas.")
    end,
})

minetest.register_chatcommand("construir_roseton", {
    description = S("Instala el gran rosetón frontal"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Ejecuta /construir_nave primero.") end

        local radio, centro_y, bloques = 6, 35, 0
        for x = -radio, radio do
            for y = centro_y - radio, centro_y + radio do
                if (x*x) + ((y-centro_y)*(y-centro_y)) <= (radio*radio) then
                    minetest.set_node({x = origen.x + x, y = origen.y + y, z = origen.z}, {name = "exploration_catholic_church:roseton"})
                    bloques = bloques + 1
                end
            end
        end
        return true, S("Rosetón instalado.")
    end,
})

minetest.register_chatcommand("construir_timpano", {
    description = S("Sella la fachada frontal con un tímpano clásico"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Ejecuta /construir_nave primero.") end

        for x = -15, 15 do
            local y_max = 65 - math.abs(x)
            for y = 50, y_max do
                minetest.set_node({x = origen.x + x, y = origen.y + y, z = origen.z}, {name = "exploration_catholic_church:muro_lateral"})
            end
        end
        return true, S("Tímpano construido.")
    end,
})

minetest.register_chatcommand("construir_crucero_cupula", {
    description = S("Genera el transepto, tambor y cúpula"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Ejecuta /construir_nave primero.") end

        local cx, cz = origen.x, origen.z + 120
        local r_ext, grosor = 20, 2
        local r_ext_sq, r_int_sq = r_ext*r_ext, (r_ext-grosor)*(r_ext-grosor)

        for x = -70, 70 do
            for z = 100, 140 do
                minetest.set_node({x = origen.x + x, y = origen.y, z = origen.z + z}, {name = "exploration_catholic_church:marmol_blanco"})
                for y = 1, 50 do minetest.set_node({x = origen.x + x, y = origen.y + y, z = origen.z + z}, {name = "air"}) end
            end
        end

        for x = -15, 15 do
            for y = 1, 35 do minetest.set_node({x = origen.x + x, y = origen.y + y, z = origen.z + 100}, {name = "air"}) end
        end

        for _, z_muro in ipairs({100, 140}) do
            for x = -70, 70 do
                if x < -20 or x > 20 then
                    for y = 1, 50 do minetest.set_node({x = origen.x + x, y = origen.y + y, z = origen.z + z_muro}, {name = "exploration_catholic_church:muro_lateral"}) end
                end
            end
        end

        for _, x_ex in ipairs({-70, 70}) do
            for z = 100, 140 do
                for y = 1, 50 do minetest.set_node({x = origen.x + x_ex, y = origen.y + y, z = origen.z + z}, {name = "exploration_catholic_church:muro_lateral"}) end
            end
        end

        for y = 51, 65 do
            for dx = -r_ext, r_ext do
                for dz = -r_ext, r_ext do
                    local d_sq = (dx*dx) + (dz*dz)
                    if d_sq >= r_int_sq and d_sq <= r_ext_sq then
                        local n = ((y >= 55 and y <= 60) and (math.abs(dx)%6 <= 1 or math.abs(dz)%6 <= 1)) and "exploration_catholic_church:vitral" or "exploration_catholic_church:muro_lateral"
                        minetest.set_node({x = cx + dx, y = origen.y + y, z = cz + dz}, {name = n})
                    end
                end
            end
        end

        for dy = 0, r_ext do
            for dx = -r_ext, r_ext do
                for dz = -r_ext, r_ext do
                    if (dx*dx)+(dy*dy)+(dz*dz) >= r_int_sq and (dx*dx)+(dy*dy)+(dz*dz) <= r_ext_sq then
                        minetest.set_node({x = cx + dx, y = origen.y + 65 + dy, z = cz + dz}, {name = "exploration_catholic_church:cupula_elegante"})
                    end
                end
            end
        end
        return true, S("Crucero y cúpula erigidos.")
    end,
})

minetest.register_chatcommand("construir_pechinas", {
    description = S("Genera las pechinas del crucero"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Ejecuta /construir_nave primero.") end

        local cx, cz = origen.x, origen.z + 120
        local y_in, y_fin, r_cil = 40, 51, 20
        local r_esq = math.sqrt(800)

        for y = y_in, y_fin do
            local prog = (y - y_in) / (y_fin - y_in)
            local r_act = r_esq - (prog * (r_esq - r_cil))
            local r_act_sq, r_vac_sq = r_act*r_act, r_cil*r_cil

            for dx = -20, 20 do
                for dz = -20, 20 do
                    local d_sq = (dx*dx) + (dz*dz)
                    if d_sq > r_vac_sq and d_sq <= r_act_sq then
                        minetest.set_node({x = cx + dx, y = origen.y + y, z = cz + dz}, {name = "exploration_catholic_church:cupula_elegante"})
                    end
                end
            end
        end
        return true, S("Pechinas doradas ensambladas.")
    end,
})

minetest.register_chatcommand("construir_techos_transeptos", {
    description = S("Sella los transeptos"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Ejecuta /construir_nave primero.") end

        local r_ext, r_int_sq = 20, 324
        for y = 50, 70 do
            for z = 100, 140 do
                local d_sq = ((z-120)*(z-120)) + ((y-50)*(y-50))
                if d_sq >= r_int_sq and d_sq <= 400 then
                    for x = -70, -20 do minetest.set_node({x = origen.x + x, y = origen.y + y, z = origen.z + z}, {name = "exploration_catholic_church:techo_transepto"}) end
                    for x = 20, 70 do minetest.set_node({x = origen.x + x, y = origen.y + y, z = origen.z + z}, {name = "exploration_catholic_church:techo_transepto"}) end
                end
            end
        end
        return true, S("Transeptos sellados.")
    end,
})

minetest.register_chatcommand("construir_abside", {
    description = S("Genera el ábside"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Ejecuta /construir_nave primero.") end

        local cx, cz, r_ext_sq, r_int_sq = origen.x, origen.z + 140, 400, 324

        for y = 1, 50 do
            for dx = -20, 20 do
                for dz = 0, 20 do 
                    local d_sq = (dx*dx) + (dz*dz)
                    local pos = {x = cx + dx, y = origen.y + y, z = cz + dz}
                    if d_sq >= r_int_sq and d_sq <= r_ext_sq then minetest.set_node(pos, {name = "exploration_catholic_church:muro_lateral"})
                    elseif d_sq < r_int_sq then minetest.set_node(pos, {name = "air"}) end
                end
            end
        end

        for dy = 0, 20 do
            for dx = -20, 20 do
                for dz = 0, 20 do
                    if (dx*dx)+(dy*dy)+(dz*dz) >= r_int_sq and (dx*dx)+(dy*dy)+(dz*dz) <= r_ext_sq then
                        minetest.set_node({x = cx + dx, y = origen.y + 50 + dy, z = cz + dz}, {name = "exploration_catholic_church:muro_lateral"})
                    end
                end
            end
        end

        for dx = -20, 20 do
            for dz = 0, 20 do
                if (dx*dx) + (dz*dz) <= r_ext_sq then minetest.set_node({x = cx + dx, y = origen.y, z = cz + dz}, {name = "exploration_catholic_church:marmol_blanco"}) end
            end
        end

        for x = -18, 18 do
            for y = 1, 48 do minetest.set_node({x = cx + x, y = origen.y + y, z = cz}, {name = "air"}) end
        end

        return true, S("Ábside construido.")
    end,
})

minetest.register_chatcommand("construir_techos_laterales", {
    description = S("Sella las naves laterales"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Ejecuta /construir_nave primero.") end

        for z = 0, 100 do
            for y = 35, 38 do
                for x = -20, -14 do
                    if ((x+17)*(x+17)) + ((y-35)*(y-35)) <= 9 and ((x+17)*(x+17)) + ((y-35)*(y-35)) >= 4 then
                        minetest.set_node({x = origen.x + x, y = origen.y + y, z = origen.z + z}, {name = "exploration_catholic_church:techo_lateral"})
                    end
                end
                for x = 14, 20 do
                    if ((x-17)*(x-17)) + ((y-35)*(y-35)) <= 9 and ((x-17)*(x-17)) + ((y-35)*(y-35)) >= 4 then
                        minetest.set_node({x = origen.x + x, y = origen.y + y, z = origen.z + z}, {name = "exploration_catholic_church:techo_lateral"})
                    end
                end
            end
        end
        return true, S("Techos laterales ensamblados.")
    end,
})

-- =====================================================================
-- COMANDOS REFACTORIZADOS CON FÍSICA DE CADENAS E ILUMINACIÓN MASIVA
-- =====================================================================

minetest.register_chatcommand("construir_boveda", {
    description = S("Levanta el claristorio real en la nave central y la bóveda"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Ejecuta /construir_nave primero.") end

        -- 1. Muros Superiores de la Nave Central (El verdadero Claristorio)
        -- Estos muros sostienen la bóveda en X=-15 y X=15
        for z = 0, 100 do
            local modulo_z = z % 10 -- Detectamos el espacio entre pilares
            for y = 40, 50 do
                local nodo_muro = "exploration_catholic_church:muro_lateral"
                
                -- Si la altura es la del ventanal (42 a 48) y estamos en el centro (3 a 7)
                if y >= 42 and y <= 48 and modulo_z >= 3 and modulo_z <= 7 then
                    nodo_muro = "exploration_catholic_church:vitral_gotico"
                end

                -- Tallamos el muro izquierdo (Grosor de 3 bloques)
                for x = -15, -13 do 
                    minetest.set_node({x = origen.x + x, y = origen.y + y, z = origen.z + z}, {name = nodo_muro}) 
                end
                -- Tallamos el muro derecho (Grosor de 3 bloques)
                for x = 13, 15 do 
                    minetest.set_node({x = origen.x + x, y = origen.y + y, z = origen.z + z}, {name = nodo_muro}) 
                end
            end
        end

        -- 2. Ensamblaje de la Bóveda de Cañón
        for z = 0, 100 do
            for y = 50, 65 do
                for x = -15, 15 do
                    local d_sq = (x*x) + ((y-50)*(y-50))
                    if d_sq >= 169 and d_sq <= 225 then
                        minetest.set_node({x = origen.x + x, y = origen.y + y, z = origen.z + z}, {name = "exploration_catholic_church:techo_fresco"})
                    end
                end
            end
        end

        -- 3. Candelabros y Cadenas en la Nave Central
        for z_luz = 20, 80, 20 do
            minetest.set_node({x = origen.x, y = origen.y + 62, z = origen.z + z_luz}, {name = "exploration_catholic_church:candelabro_oro"})
            for y_cad = 63, 64 do
                minetest.set_node({x = origen.x, y = origen.y + y_cad, z = origen.z + z_luz}, {name = "exploration_catholic_church:cadena"})
            end
        end

        return true, S("Bóveda y Claristorio central iluminado ensamblados con éxito.")
    end,
})

minetest.register_chatcommand("iluminar_laterales", {
    description = S("Instala candelabros con cadenas en los pasillos perimetrales"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Ejecuta /construir_nave primero.") end

        for z = 10, 90, 20 do
            -- Lado izquierdo
            minetest.set_node({x = origen.x - 17, y = origen.y + 33, z = origen.z + z}, {name = "exploration_catholic_church:candelabro_oro"})
            for y_cad = 34, 37 do
                minetest.set_node({x = origen.x - 17, y = origen.y + y_cad, z = origen.z + z}, {name = "exploration_catholic_church:cadena"})
            end
            
            -- Lado derecho
            minetest.set_node({x = origen.x + 17, y = origen.y + 33, z = origen.z + z}, {name = "exploration_catholic_church:candelabro_oro"})
            for y_cad = 34, 37 do
                minetest.set_node({x = origen.x + 17, y = origen.y + y_cad, z = origen.z + z}, {name = "exploration_catholic_church:cadena"})
            end
        end
        return true, S("Pasillos menores iluminados y anclados.")
    end,
})

minetest.register_chatcommand("iluminar_interseccion", {
    description = S("Despliega luminarias mayores y estatuaria en crucero, transeptos y ábside"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Ejecuta /construir_nave primero.") end
        local luces = 0

        -- 1. Eje Central: Gran Candelabro Papal bajo la cúpula
        minetest.set_node({x = origen.x, y = origen.y + 60, z = origen.z + 120}, {name = "exploration_catholic_church:candelabro_papal"})
        for y_cad = 61, 84 do
            minetest.set_node({x = origen.x, y = origen.y + y_cad, z = origen.z + 120}, {name = "exploration_catholic_church:cadena"})
        end
        luces = luces + 1

        -- 2. Transeptos: Candelabros papales con cadenas kilométricas (Techo en Y=70)
        for _, x in ipairs({-35, -55, 35, 55}) do
            minetest.set_node({x = origen.x + x, y = origen.y + 50, z = origen.z + 120}, {name = "exploration_catholic_church:candelabro_papal"})
            for y_cad = 51, 69 do
                minetest.set_node({x = origen.x + x, y = origen.y + y_cad, z = origen.z + 120}, {name = "exploration_catholic_church:cadena"})
            end
            luces = luces + 1
        end

        -- 3. Candelabros de pie en los Muros Ciegos de los transeptos
        for z = 105, 135, 10 do
            minetest.set_node({x = origen.x - 68, y = origen.y + 1, z = origen.z + z}, {name = "exploration_catholic_church:candelabro_pie"})
            minetest.set_node({x = origen.x + 68, y = origen.y + 1, z = origen.z + z}, {name = "exploration_catholic_church:candelabro_pie"})
            luces = luces + 2
        end

        -- 4. Ábside: Candelabros flanqueando el Altar
        minetest.set_node({x = origen.x - 8, y = origen.y + 1, z = origen.z + 138}, {name = "exploration_catholic_church:candelabro_pie"})
        minetest.set_node({x = origen.x + 8, y = origen.y + 1, z = origen.z + 138}, {name = "exploration_catholic_church:candelabro_pie"})
        luces = luces + 2

        -- 5. Corona de Cirios en la pared curva trasera del ábside
        for x_abs = -12, 12, 6 do
            local z_curva = 140 + math.floor(math.sqrt((17 * 17) - (x_abs * x_abs)))
            minetest.set_node({x = origen.x + x_abs, y = origen.y + 1, z = origen.z + z_curva}, {name = "exploration_catholic_church:veladora_gigante"})
            luces = luces + 1
        end

        return true, S("Crucero y ábside erradicados de la penumbra. Cadenas forjadas.")
    end,
})

minetest.register_chatcommand("construir_detalles", {
    description = S("Genera bancas y estatuas de forma segura"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Ejecuta /construir_nave primero.") end

        for z = 15, 85, 3 do
            for x = -12, -3 do minetest.set_node({x = origen.x + x, y = origen.y + 1, z = origen.z + z}, {name = "exploration_catholic_church:banca_madera", param2 = 2}) end
            for x = 3, 12 do minetest.set_node({x = origen.x + x, y = origen.y + 1, z = origen.z + z}, {name = "exploration_catholic_church:banca_madera", param2 = 2}) end
        end

        for z = 10, 90, 10 do
            minetest.set_node({x = origen.x - 12, y = origen.y + 1, z = origen.z + z}, {name = "exploration_catholic_church:estatua_marmol"})
            minetest.set_node({x = origen.x + 12, y = origen.y + 1, z = origen.z + z}, {name = "exploration_catholic_church:estatua_marmol"})
        end
        return true, S("Mobiliario y estatuaria generados sobre el mármol.")
    end,
})

minetest.register_chatcommand("construir_altar", {
    description = S("Posiciona el Altar Mayor en el ábside"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Ejecuta /construir_nave primero.") end

        local pos_altar = {x = origen.x, y = origen.y + 1, z = origen.z + 138}
        minetest.set_node(pos_altar, {name = "exploration_catholic_church:altar_mayor", param2 = 2})
        
        local clave = minetest.pos_to_string(pos_altar)
        exploration_catholic_church_altares[clave] = pos_altar
        return true, S("Altar Mayor erigido en el Datum.")
    end,
})

-- =====================================================================
-- 27. Registro de Luminarias Sagradas (Veladoras y Apliques)
-- =====================================================================

minetest.register_node("exploration_catholic_church:veladora_gigante", {
    description = S("Cirio Pascual Gigante"),
    -- Texturas: Arriba, Abajo, Derecha, Izquierda, Atrás, Frente
    tiles = {
        "vaticano_veladora_top.png", 
        "vaticano_marmol_blanco.png", 
        "vaticano_veladora_side.png",
        "vaticano_veladora_side.png",
        "vaticano_veladora_side.png",
        "vaticano_veladora_side.png"
    },
    drawtype = "nodebox",
    paramtype = "light",
    light_source = 13, -- Luz cálida e intensa desde el suelo
    node_box = {
        type = "fixed",
        fixed = {
            {-0.2, -0.5, -0.2, 0.2, 0.6, 0.2}, -- Cuerpo grueso de cera y base
            {-0.05, 0.6, -0.05, 0.05, 0.8, 0.05}, -- Mecha y llama superior
        }
    },
    groups = {choppy = 2, oddly_breakable_by_hand = 2}
})

minetest.register_node("exploration_catholic_church:lampara_muro", {
    description = S("Aplique de Pared Renacentista"),
    drawtype = "torchlike", -- Renderiza un sprite plano pegado al bloque adyacente
    tiles = {"vaticano_lampara_muro.png"},
    inventory_image = "vaticano_lampara_muro.png",
    paramtype = "light",
    paramtype2 = "wallmounted", -- Permite que el motor calcule la rotación contra el muro
    sunlight_propagates = true,
    walkable = false,
    light_source = 14, -- Intensidad lumínica máxima del motor
    groups = {cracky = 2, attached_node = 1}
})

-- =====================================================================
-- 28. Comando de Iluminación Perimetral y Columnatas
-- =====================================================================

minetest.register_chatcommand("iluminar_columnas", {
    description = S("Fija lámparas de forja en los pilares y cirios gigantes en la nave"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Ejecuta /construir_nave primero para fijar el Datum.") end

        local luces = 0

        -- Recorremos la misma matemática de los pilares (Z de 10 a 90)
        for z = 10, 90, 10 do
            
            -- 1. Cirios Gigantes en el suelo
            -- Se colocan flanqueando el pasillo central, delante de las bancas (X = -6 y X = 6)
            minetest.set_node({x = origen.x - 6, y = origen.y + 1, z = origen.z + z}, {name = "exploration_catholic_church:veladora_gigante"})
            minetest.set_node({x = origen.x + 6, y = origen.y + 1, z = origen.z + z}, {name = "exploration_catholic_church:veladora_gigante"})
            
            -- 2. Apliques de pared en los pilares
            -- Los pilares masivos de 3x3 están anclados en X = -15 y 15. 
            -- Su cara interna (la que mira al pasillo) está en X = -13 y X = 13.
            -- Las lámparas se colocan a 6 bloques de altura (Y = 6).
            -- param2 dictamina la rotación (wallmounted direction).
            
            -- Cara interna del pilar izquierdo (apunta hacia la derecha)
            minetest.set_node({x = origen.x - 13, y = origen.y + 6, z = origen.z + z}, {
                name = "exploration_catholic_church:lampara_muro", 
                param2 = 1 -- Anclado a la cara X positiva del bloque
            })
            
            -- Cara interna del pilar derecho (apunta hacia la izquierda)
            minetest.set_node({x = origen.x + 13, y = origen.y + 6, z = origen.z + z}, {
                name = "exploration_catholic_church:lampara_muro", 
                param2 = 0 -- Anclado a la cara X negativa del bloque
            })

            luces = luces + 4
        end

        return true, S("Columnatas santificadas. Se encendieron ") .. luces .. S(" nuevas fuentes de luz.")
    end,
})

-- =====================================================================
-- 29. Registro de Cadenas Estructurales y Luminarias Mayores
-- =====================================================================

minetest.register_node("exploration_catholic_church:cadena", {
    description = S("Cadena de Forja"),
    drawtype = "plantlike",
    tiles = {"vaticano_cadena.png"},
    inventory_image = "vaticano_cadena.png",
    paramtype = "light",
    walkable = false, -- Evita que el jugador choque contra las cadenas al volar
    groups = {cracky = 2}
})

minetest.register_node("exploration_catholic_church:candelabro_papal", {
    description = S("Gran Candelabro Papal"),
    drawtype = "plantlike", 
    tiles = {"vaticano_candelabro_papal.png"},
    inventory_image = "vaticano_candelabro_papal.png",
    paramtype = "light", 
    light_source = 14, 
    walkable = false,
    visual_scale = 2.0, -- Duplica el tamaño visual para llenar las grandes bóvedas
    groups = {cracky = 2, oddly_breakable_by_hand = 3},
})

minetest.register_node("exploration_catholic_church:candelabro_pie", {
    description = S("Candelabro de Pie de Oro"),
    drawtype = "plantlike",
    tiles = {"vaticano_candelabro_pie.png"},
    inventory_image = "vaticano_candelabro_pie.png",
    paramtype = "light",
    light_source = 12,
    walkable = false,
    groups = {cracky = 2, oddly_breakable_by_hand = 3},
})

-- =====================================================================
-- 30. Algoritmo de Iluminación para Crucero y Ábside
-- =====================================================================
minetest.register_chatcommand("iluminar_interseccion", {
    description = S("Despliega luminarias en el crucero, transeptos y ábside"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Ejecuta /construir_nave primero.") end

        local luces = 0

        -- 1. Eje Central: Gran Candelabro bajo la Cúpula (Z = 120)
        -- Lo suspendemos a 60 bloques de altura para bañar de luz la caída del tambor
        minetest.set_node({x = origen.x, y = origen.y + 60, z = origen.z + 120}, {name = "exploration_catholic_church:candelabro_papal"})
        luces = luces + 1

        -- 2. Bóvedas de los Transeptos (Brazos laterales)
        -- Suspendemos candelabros papales a Y=50 a lo largo del eje X
        for _, x in ipairs({-35, -55, 35, 55}) do
            minetest.set_node({x = origen.x + x, y = origen.y + 50, z = origen.z + 120}, {name = "exploration_catholic_church:candelabro_papal"})
            for y_cad = 51, 69 do
                minetest.set_node({x = origen.x + x, y = origen.y + y_cad, z = origen.z + 120}, {name = "exploration_catholic_church:cadena"})
            end
            luces = luces + 1
        end

        -- 3. Candelabros de pie en los Muros Ciegos de los transeptos
        for z = 105, 135, 10 do
            minetest.set_node({x = origen.x - 68, y = origen.y + 1, z = origen.z + z}, {name = "exploration_catholic_church:candelabro_pie"})
            minetest.set_node({x = origen.x + 68, y = origen.y + 1, z = origen.z + z}, {name = "exploration_catholic_church:candelabro_pie"})
            luces = luces + 2
        end

        -- 4. Ábside: Candelabros flanqueando el Altar
        minetest.set_node({x = origen.x - 8, y = origen.y + 1, z = origen.z + 138}, {name = "exploration_catholic_church:candelabro_pie"})
        minetest.set_node({x = origen.x + 8, y = origen.y + 1, z = origen.z + 138}, {name = "exploration_catholic_church:candelabro_pie"})
        luces = luces + 2

        -- 5. Corona de Cirios en la pared curva trasera del ábside
        for x_abs = -12, 12, 6 do
            local z_curva = 140 + math.floor(math.sqrt((17 * 17) - (x_abs * x_abs)))
            minetest.set_node({x = origen.x + x_abs, y = origen.y + 1, z = origen.z + z_curva}, {name = "exploration_catholic_church:veladora_gigante"})
            luces = luces + 1
        end

        return true, S("Intersección iluminada con precisión. Se anclaron ") .. luces .. S(" nuevas fuentes de luz.")
    end,
})

-- =====================================================================
-- 31. Sistema de Inventario Sacro y Abastecimiento
-- =====================================================================

minetest.register_chatcommand("inventario_sacro", {
    description = S("Otorga un stack de todos los materiales y luminarias de la basílica"),
    func = function(name, param)
        local jugador = minetest.get_player_by_name(name)
        if not jugador then return false, S("Jugador no encontrado.") end
        
        local inventario = jugador:get_inventory()
        local items = {
            "exploration_catholic_church:marmol_blanco",
            "exploration_catholic_church:pilar_piedra",
            "exploration_catholic_church:muro_lateral",
            "exploration_catholic_church:vitral",
            "exploration_catholic_church:roseton",
            "exploration_catholic_church:techo_fresco",
            "exploration_catholic_church:cupula_elegante",
            "exploration_catholic_church:banca_madera",
            "exploration_catholic_church:candelabro_oro",
            "exploration_catholic_church:candelabro_papal",
            "exploration_catholic_church:candelabro_pie",
            "exploration_catholic_church:veladora_gigante",
            "exploration_catholic_church:cadena",
            "exploration_catholic_church:estacion_viacrucis",
            "exploration_catholic_church:confesionario_base",
            "exploration_catholic_church:confesionario_techo",
            "exploration_catholic_church:pilar_baldaquino", 
            "exploration_catholic_church:techo_baldaquino",
            "exploration_catholic_church:muro_triforio", 
            "exploration_catholic_church:vitral_gotico",
            "exploration_catholic_church:muro_cripta",
            "exploration_catholic_church:sarcofago_marmol",
            "exploration_catholic_church:reja_hierro",
            "exploration_catholic_church:escalera_cripta",
            "exploration_catholic_church:organo_tubular",
            "exploration_catholic_church:piso_coro",    
            "exploration_catholic_church:escalera_coro",
            "exploration_catholic_church:muro_campanario", 
            "exploration_catholic_church:techo_campanario",
            "exploration_catholic_church:campana_bronce",
            "exploration_catholic_church:madera_pulpito", 
            "exploration_catholic_church:tornavoz_pulpito" 
        }
        
        for _, item in ipairs(items) do
            inventario:add_item("main", item .. " 99")
        end
        
        return true, S("Inventario sacro abastecido. Tienes todos los materiales en tu mochila.")
    end,
})

-- =====================================================================
-- 32. Registro de Luminarias Auxiliares (Bóvedas y Ábside)
-- =====================================================================

minetest.register_node("exploration_catholic_church:velas_voto", {
    description = S("Bandeja de Velas Votivas"),
    tiles = {
        "vaticano_velas_voto.png", 
        "vaticano_marmol_blanco.png", 
        "vaticano_velas_voto.png",
        "vaticano_velas_voto.png",
        "vaticano_velas_voto.png",
        "vaticano_velas_voto.png"
    },
    drawtype = "nodebox",
    paramtype = "light",
    light_source = 11,
    node_box = {
        type = "fixed",
        fixed = {-0.4, -0.5, -0.4, 0.4, -0.3, 0.4} -- Bandeja plana en el suelo
    },
    groups = {choppy = 2, oddly_breakable_by_hand = 2, arte_sacro = 1}
})

minetest.register_node("exploration_catholic_church:lampara_techo", {
    description = S("Lámpara de Techo Menor"),
    drawtype = "plantlike",
    tiles = {"vaticano_lampara_techo.png"},
    inventory_image = "vaticano_lampara_techo.png",
    paramtype = "light",
    light_source = 13,
    walkable = false,
    groups = {cracky = 2, oddly_breakable_by_hand = 3, arte_sacro = 1}
})

minetest.register_node("exploration_catholic_church:aplique_tambor", {
    description = S("Aplique del Tambor de la Cúpula"),
    drawtype = "torchlike",
    tiles = {"vaticano_aplique_tambor.png"},
    inventory_image = "vaticano_aplique_tambor.png",
    paramtype = "light",
    paramtype2 = "wallmounted",
    sunlight_propagates = true,
    walkable = false,
    light_source = 14,
    groups = {cracky = 2, attached_node = 1, arte_sacro = 1}
})

-- =====================================================================
-- 33. Algoritmo de Supresión de Penumbra (Cúpula y Transeptos)
-- =====================================================================

minetest.register_chatcommand("iluminar_alturas", {
    description = S("Inyecta lámparas con cadenas en los vacíos del crucero, pechinas y ábside"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Ejecuta /construir_nave primero.") end
        
        local cx = origen.x
        local cz = origen.z + 120 -- Centro del crucero
        local luces = 0

        -- 1. Iluminar el Tambor de la Cúpula (Y=55)
        -- Colocamos lámparas suspendidas cerca de los vitrales altos
        for _, radio in ipairs({-17, 17}) do
            minetest.set_node({x = cx + radio, y = origen.y + 55, z = cz}, {name = "exploration_catholic_church:lampara_techo"})
            minetest.set_node({x = cx, y = origen.y + 55, z = cz + radio}, {name = "exploration_catholic_church:lampara_techo"})
            
            -- Cadenas hasta la cúpula (Y=65)
            for y_cad = 56, 65 do
                minetest.set_node({x = cx + radio, y = origen.y + y_cad, z = cz}, {name = "exploration_catholic_church:cadena"})
                minetest.set_node({x = cx, y = origen.y + y_cad, z = cz + radio}, {name = "exploration_catholic_church:cadena"})
            end
            luces = luces + 2
        end

        -- 2. Pechinas (Esquinas del Crucero en Y=45)
        local offset_pechina = 14
        local esquinas = {
            {x = -offset_pechina, z = -offset_pechina}, {x = offset_pechina, z = -offset_pechina},
            {x = -offset_pechina, z = offset_pechina},  {x = offset_pechina, z = offset_pechina}
        }
        for _, pos in ipairs(esquinas) do
            minetest.set_node({x = cx + pos.x, y = origen.y + 45, z = cz + pos.z}, {name = "exploration_catholic_church:lampara_techo"})
            for y_cad = 46, 50 do
                minetest.set_node({x = cx + pos.x, y = origen.y + y_cad, z = cz + pos.z}, {name = "exploration_catholic_church:cadena"})
            end
            luces = luces + 1
        end

        -- 3. Techos de los Transeptos (Para eliminar los huecos oscuros laterales)
        for _, x_trans in ipairs({-45, -60, 45, 60}) do
            for z_trans = 110, 130, 20 do
                minetest.set_node({x = origen.x + x_trans, y = origen.y + 45, z = origen.z + z_trans}, {name = "exploration_catholic_church:lampara_techo"})
                -- Cadenas hasta el techo del transepto (Y=55)
                for y_cad = 46, 55 do
                    minetest.set_node({x = origen.x + x_trans, y = origen.y + y_cad, z = origen.z + z_trans}, {name = "exploration_catholic_church:cadena"})
                end
                luces = luces + 1
            end
        end

        -- 4. Suelo del Ábside (Velas Votivas a los pies del muro semicircular)
        for x_abs = -15, 15, 3 do
            local z_curva = 140 + math.floor(math.sqrt((18 * 18) - (x_abs * x_abs))) - 1
            minetest.set_node({x = origen.x + x_abs, y = origen.y + 1, z = origen.z + z_curva}, {name = "exploration_catholic_church:velas_voto"})
        end

        return true, S("Altura iluminada. Se añadieron nuevas fuentes y cadenas (") .. luces .. S(" lámparas aéreas).")
    end,
})

-- =====================================================================
-- 34. Perforación del Óculo (Reloj Solar Pasivo)
-- =====================================================================

minetest.register_chatcommand("perforar_oculo", {
    description = S("Abre un óculo en el cenit de la cúpula sellado con vitrales para luz natural"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Ejecuta /construir_nave primero.") end

        -- El centro exacto del crucero donde converge la cúpula
        local cx = origen.x
        local cz = origen.z + 120 
        local radio_oculo = 3
        local bloques = 0

        -- La base de la cúpula está en Y=65. El techo máximo está en Y=85 (65+20).
        -- Iteramos desde Y=80 hasta Y=86 para asegurarnos de atravesar el grosor de la bóveda.
        for dy = 15, 21 do
            for dx = -radio_oculo, radio_oculo do
                for dz = -radio_oculo, radio_oculo do
                    -- Teorema de Pitágoras para tallar un cilindro perfecto
                    if (dx*dx) + (dz*dz) <= (radio_oculo * radio_oculo) then
                        local y_absoluta = origen.y + 65 + dy
                        -- Extraemos el nodo actual para no reemplazar las lámparas o cadenas que ya existan abajo
                        local nodo_actual = minetest.get_node({x = cx + dx, y = y_absoluta, z = cz + dz}).name
                        
                        if nodo_actual == "exploration_catholic_church:cupula_elegante" then
                            minetest.set_node({x = cx + dx, y = y_absoluta, z = cz + dz}, {name = "exploration_catholic_church:vitral"})
                            bloques = bloques + 1
                        end
                    end
                end
            end
        end

        return true, S("Óculo perforado con éxito. El sol ahora ilumina el crucero. Bloques reemplazados: ") .. bloques
    end,
})

-- =====================================================================
-- 34. Registro y Despliegue del Vía Crucis (Geometría Signlike)
-- =====================================================================

minetest.register_node("exploration_catholic_church:estacion_viacrucis", {
    description = S("Estación del Vía Crucis"),
    drawtype = "signlike", -- Renderiza un plano 2D sin volumen
    tiles = {"vaticano_viacrucis.png"},
    inventory_image = "vaticano_viacrucis.png",
    paramtype = "light",
    paramtype2 = "wallmounted", -- El motor delega la rotación a una matriz C++
    sunlight_propagates = true,
    light_source = 14, -- Irradiación de luz estática desde los relieves
    walkable = false, -- Se desactiva la colisión física para proteger la CPU
    groups = {cracky = 2, attached_node = 1, arte_sacro = 1}
})

minetest.register_chatcommand("construir_viacrucis", {
    description = S("Instala las 14 estaciones del Vía Crucis en los muros de la nave"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Ejecuta /construir_nave primero.") end
        
        local estaciones = 0
        local y_altura = origen.y + 2 -- A la altura de los ojos del jugador

        -- Eje Z: Distribuimos 7 estaciones por muro, desde la entrada (Z=15) hasta el crucero (Z=75)
        local posiciones_z = {15, 25, 35, 45, 55, 65, 75}

        for _, z in ipairs(posiciones_z) do
            -- Muro Izquierdo: Los muros perimetrales están en X = -20. 
            -- Colocamos el nodo en X = -19 (un bloque antes) y lo anclamos mirando hacia la derecha.
            minetest.set_node({x = origen.x - 19, y = y_altura, z = origen.z + z}, {
                name = "exploration_catholic_church:estacion_viacrucis",
                param2 = 2 -- Anclado a la pared en X- (mirando hacia X+)
            })
            
            -- Muro Derecho: Los muros están en X = 20. 
            -- Colocamos el nodo en X = 19 y lo anclamos mirando hacia la izquierda.
            minetest.set_node({x = origen.x + 19, y = y_altura, z = origen.z + z}, {
                name = "exploration_catholic_church:estacion_viacrucis",
                param2 = 3 -- Anclado a la pared en X+ (mirando hacia X-)
            })
            estaciones = estaciones + 2
        end

        return true, S("Algoritmo completado. ") .. estaciones .. S(" estaciones del Vía Crucis ensambladas sin impacto térmico.")
    end,
})

-- =====================================================================
-- 35. Registro y Emplazamiento de Confesionarios a Doble Altura
-- =====================================================================

minetest.register_node("exploration_catholic_church:confesionario_base", {
    description = S("Confesionario Empotrado (Base)"),
    tiles = {
        "vaticano_madera_oscura.png", 
        "vaticano_madera_oscura.png", 
        "vaticano_madera_oscura.png", 
        "vaticano_madera_oscura.png", 
        "vaticano_madera_oscura.png", 
        "vaticano_celosia.png"        
    },
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, 0.2, 0.5, 0.5, 0.5},   -- Pared de fondo
            {-0.5, -0.5, -0.5, -0.4, 0.5, 0.2}, -- Tabique izquierdo
            {0.4, -0.5, -0.5, 0.5, 0.5, 0.2},   -- Tabique derecho
            -- Techo eliminado para permitir el paso del torso
        }
    },
    groups = {choppy = 2, oddly_breakable_by_hand = 2, arte_sacro = 1}
})

minetest.register_node("exploration_catholic_church:confesionario_techo", {
    description = S("Confesionario Empotrado (Techo)"),
    tiles = {
        "vaticano_madera_oscura.png", 
        "vaticano_madera_oscura.png", 
        "vaticano_madera_oscura.png", 
        "vaticano_madera_oscura.png", 
        "vaticano_madera_oscura.png", 
        "vaticano_celosia.png"        
    },
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, 0.2, 0.5, 0.5, 0.5},   -- Pared de fondo
            {-0.5, -0.5, -0.5, -0.4, 0.5, 0.2}, -- Tabique izquierdo
            {0.4, -0.5, -0.5, 0.5, 0.5, 0.2},   -- Tabique derecho
            {-0.5, 0.4, -0.5, 0.5, 0.5, 0.2},   -- Techo del nicho restaurado
        }
    },
    groups = {choppy = 2, oddly_breakable_by_hand = 2, arte_sacro = 1}
})

minetest.register_chatcommand("construir_confesionarios", {
    description = S("Perfora los muros laterales y empotra confesionarios de 2 metros de altura"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Ejecuta /construir_nave primero.") end

        local agregados = 0
        
        for z = 20, 80, 20 do
            -- Muro Izquierdo (X = -20)
            -- param2 = 3 hace que el frente (la apertura) apunte hacia el interior de la nave (+X)
            minetest.set_node({x = origen.x - 20, y = origen.y + 1, z = origen.z + z}, {name = "exploration_catholic_church:confesionario_base", param2 = 3})
            minetest.set_node({x = origen.x - 20, y = origen.y + 2, z = origen.z + z}, {name = "exploration_catholic_church:confesionario_techo", param2 = 3})
            
            -- Muro Derecho (X = 20)
            -- param2 = 1 hace que el frente (la apertura) apunte hacia el interior de la nave (-X)
            minetest.set_node({x = origen.x + 20, y = origen.y + 1, z = origen.z + z}, {name = "exploration_catholic_church:confesionario_base", param2 = 1})
            minetest.set_node({x = origen.x + 20, y = origen.y + 2, z = origen.z + z}, {name = "exploration_catholic_church:confesionario_techo", param2 = 1})
            
            agregados = agregados + 2
        end

        return true, S("Perforación corregida. ") .. agregados .. S(" confesionarios empotrados mirando hacia el pasillo central.")
    end,
})

-- =====================================================================
-- 36. Registro y Ensamblaje del Baldaquino Monumental
-- =====================================================================

minetest.register_node("exploration_catholic_church:pilar_baldaquino", {
    description = S("Pilar Torso de Bronce"),
    tiles = {"vaticano_pilar_baldaquino.png"},
    paramtype = "light",
    light_source = 14, -- Emisión lumínica masiva estática
    groups = {cracky = 2, stone = 1, arte_sacro = 1}
})

minetest.register_node("exploration_catholic_church:techo_baldaquino", {
    description = S("Dosel de Bronce del Baldaquino"),
    tiles = {"vaticano_techo_baldaquino.png"},
    paramtype = "light",
    light_source = 14, -- Emisión lumínica masiva estática
    groups = {cracky = 2, stone = 1, arte_sacro = 1}
})


minetest.register_chatcommand("construir_baldaquino", {
    description = S("Extruye el baldaquino de bronce sobre el altar mayor"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Ejecuta /construir_nave primero.") end

        -- Focalizamos el eje en el altar mayor (Z=138)
        local cx = origen.x
        local cz = origen.z + 138
        local bloques = 0

        -- 1. Extrusión de los 4 pilares (Bucles anidados X, Z, Y)
        -- Usamos offsets simétricos (-3 y 3) para esquivar el altar central
        for _, dx in ipairs({-3, 3}) do
            for _, dz in ipairs({-3, 3}) do
                for dy = 1, 15 do
                    minetest.set_node({x = cx + dx, y = origen.y + dy, z = cz + dz}, {name = "exploration_catholic_church:pilar_baldaquino"})
                    bloques = bloques + 1
                end
            end
        end

        -- 2. Dosel Principal (Techo en Y=16)
        -- Un bucle tradicional para sellar el perímetro de los pilares
        for dx = -4, 4 do
            for dz = -4, 4 do
                minetest.set_node({x = cx + dx, y = origen.y + 16, z = cz + dz}, {name = "exploration_catholic_church:techo_baldaquino"})
                bloques = bloques + 1
            end
        end

        -- 3. Escalón Superior del Dosel (Y=17 y Y=18)
        for dx = -2, 2 do
            for dz = -2, 2 do
                minetest.set_node({x = cx + dx, y = origen.y + 17, z = cz + dz}, {name = "exploration_catholic_church:techo_baldaquino"})
                bloques = bloques + 1
            end
        end
        minetest.set_node({x = cx, y = origen.y + 18, z = cz}, {name = "exploration_catholic_church:techo_baldaquino"})
        
        -- 4. Foco de Luz Cenital Interna
        -- Candelabro suspendido dentro del baldaquino, apuntando directo al altar
        minetest.set_node({x = cx, y = origen.y + 15, z = cz}, {name = "exploration_catholic_church:candelabro_oro"})

        return true, S("Baldaquino ensamblado con ") .. bloques .. S(" bloques de bronce sobre el presbiterio.")
    end,
})

-- =====================================================================
-- 37. Registro y Excavación de la Cripta Subterránea (Con Accesos y Arte)
-- =====================================================================

minetest.register_node("exploration_catholic_church:muro_cripta", {
    description = S("Sillería Oscura de la Cripta"),
    tiles = {"vaticano_muro_cripta.png"},
    groups = {cracky = 3, stone = 1, arte_sacro = 1}
})

minetest.register_node("exploration_catholic_church:sarcofago_marmol", {
    description = S("Sarcófago Papal de Mármol"),
    tiles = {"vaticano_sarcofago.png"},
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = {
        type = "fixed",
        fixed = {-0.4, -0.5, -0.9, 0.4, 0.3, 0.9} -- Tumba rectangular que abarca casi 2 bloques de largo
    },
    groups = {cracky = 2, stone = 1, arte_sacro = 1}
})

minetest.register_node("exploration_catholic_church:reja_hierro", {
    description = S("Reja de Forja Antigua"),
    tiles = {"vaticano_reja_forja.png"},
    drawtype = "glasslike",
    paramtype = "light",
    sunlight_propagates = true,
    use_texture_alpha = "clip", -- Optimización Extrema: no hace blending, solo recorta los huecos de la reja
    groups = {cracky = 2, oddly_breakable_by_hand = 2, arte_sacro = 1}
})

minetest.register_node("exploration_catholic_church:escalera_cripta", {
    description = S("Escalera de la Cripta"),
    tiles = {"vaticano_escalera_cripta.png"},
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.5, 0.5, 0.0, 0.5},
            {-0.5, 0.0, 0.0, 0.5, 0.5, 0.5},
        }
    },
    groups = {cracky = 3, stone = 1, arte_sacro = 1}
})

minetest.register_chatcommand("construir_cripta", {
    description = S("Excava la cripta, genera la escalinata de acceso y posiciona sarcófagos"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Ejecuta /construir_nave primero.") end
        local bloques = 0
        
        -- 1. Vaciado del subsuelo (Z=100 a Z=140 bajo el crucero, Y=-1 a Y=-10)
        for z = 100, 140 do
            for x = -20, 20 do
                for y = -10, -1 do
                    local pos = {x = origen.x + x, y = origen.y + y, z = origen.z + z}
                    
                    if x == -20 or x == 20 or z == 100 or z == 140 or y == -10 then
                        minetest.set_node(pos, {name = "exploration_catholic_church:muro_cripta"})
                    else
                        minetest.set_node(pos, {name = "air"})
                    end
                    bloques = bloques + 1
                end
            end
        end

        -- 2. Pilares Achatados de Carga (Soportan las 4 esquinas de la cúpula superior)
        local esquinas = {{-15, 105}, {15, 105}, {-15, 135}, {15, 135}}
        for _, coord in ipairs(esquinas) do
            for dx = -2, 2 do
                for dz = -2, 2 do
                    for y = -9, -1 do
                        minetest.set_node({x = origen.x + coord[1] + dx, y = origen.y + y, z = origen.z + coord[2] + dz}, {name = "exploration_catholic_church:muro_cripta"})
                    end
                end
            end
        end

        -- 3. Escalinata Monumental de Acceso (Desde la Nave Central hacia la Cripta)
        -- Descendemos desde Y=0 hasta Y=-9, avanzando en el eje Z (Z=90 a Z=99)
        for i = 0, 9 do
            local y_peldano = -i
            local z_peldano = 90 + i
            
            -- Anchura de la escalera: 6 bloques en el centro de la nave
            for x = -3, 3 do
                -- Colocamos el peldaño mirando hacia -Z para descender al avanzar
                minetest.set_node({x = origen.x + x, y = origen.y + y_peldano, z = origen.z + z_peldano}, {
                    name = "exploration_catholic_church:escalera_cripta", 
                    param2 = 2 
                })
                -- Vaciamos 3 bloques de aire por encima del peldaño para evitar que el jugador se golpee la cabeza con el mármol
                for dy = 1, 3 do
                    minetest.set_node({x = origen.x + x, y = origen.y + y_peldano + dy, z = origen.z + z_peldano}, {name = "air"})
                end
            end
            bloques = bloques + 4
        end

        -- 4. El Relicario: Sarcófagos y Rejas de Forja
        -- Colocamos la Tumba Papal principal exactamente bajo la cúpula (Z=120)
        minetest.set_node({x = origen.x, y = origen.y - 9, z = origen.z + 120}, {name = "exploration_catholic_church:sarcofago_marmol", param2 = 1})
        
        -- Colocamos una segunda tumba fundacional exactamente bajo el altar mayor (Z=138)
        minetest.set_node({x = origen.x, y = origen.y - 9, z = origen.z + 138}, {name = "exploration_catholic_church:sarcofago_marmol", param2 = 1})

        -- Cerramos la tumba central (Z=120) con un perímetro de rejas de forja
        for x = -3, 3 do
            minetest.set_node({x = origen.x + x, y = origen.y - 9, z = origen.z + 117}, {name = "exploration_catholic_church:reja_hierro"})
            minetest.set_node({x = origen.x + x, y = origen.y - 9, z = origen.z + 123}, {name = "exploration_catholic_church:reja_hierro"})
        end
        for z = 118, 122 do
            minetest.set_node({x = origen.x - 3, y = origen.y - 9, z = origen.z + z}, {name = "exploration_catholic_church:reja_hierro"})
            minetest.set_node({x = origen.x + 3, y = origen.y - 9, z = origen.z + z}, {name = "exploration_catholic_church:reja_hierro"})
        end

        -- 5. Iluminación Lúgubre (Contraste con la nave superior brillante)
        local luces = {{-7, 115}, {7, 115}, {-7, 125}, {7, 125}}
        for _, coord in ipairs(luces) do
            minetest.set_node({x = origen.x + coord[1], y = origen.y - 9, z = origen.z + coord[2]}, {name = "exploration_catholic_church:velas_voto"})
        end

        return true, S("Cripta excavada con accesos y relicarios terminados. Bloques procesados: ") .. bloques
    end,
})

-- =====================================================================
-- 38. Perforación y Extrusión de Capillas Laterales (Con Mármol Base)
-- =====================================================================

minetest.register_chatcommand("construir_capillas", {
    description = S("Ahueca los muros perimetrales inferiores, cimenta y genera capillas"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Ejecuta /construir_nave primero.") end
        local bloques = 0

        for z = 10, 90 do
            local modulo_z = z % 10
            if modulo_z >= 2 and modulo_z <= 8 then
                for dx = 20, 25 do
                    -- Iteramos desde la cota 0 para sellar el suelo
                    for y = 0, 15 do
                        if y == 0 then
                            -- Cimentación de piso
                            minetest.set_node({x = origen.x - dx, y = origen.y + y, z = origen.z + z}, {name = "exploration_catholic_church:marmol_blanco"})
                            minetest.set_node({x = origen.x + dx, y = origen.y + y, z = origen.z + z}, {name = "exploration_catholic_church:marmol_blanco"})
                        elseif dx == 25 or modulo_z == 2 or modulo_z == 8 or y == 15 then
                            -- Perímetro de muros
                            minetest.set_node({x = origen.x - dx, y = origen.y + y, z = origen.z + z}, {name = "exploration_catholic_church:muro_lateral"})
                            minetest.set_node({x = origen.x + dx, y = origen.y + y, z = origen.z + z}, {name = "exploration_catholic_church:muro_lateral"})
                        else
                            -- Vacío interno transitable
                            minetest.set_node({x = origen.x - dx, y = origen.y + y, z = origen.z + z}, {name = "air"})
                            minetest.set_node({x = origen.x + dx, y = origen.y + y, z = origen.z + z}, {name = "air"})
                        end
                        bloques = bloques + 2
                    end
                end

                if modulo_z == 5 then
                    minetest.set_node({x = origen.x - 24, y = origen.y + 1, z = origen.z + z}, {name = "exploration_catholic_church:altar_mayor", param2 = 1})
                    minetest.set_node({x = origen.x + 24, y = origen.y + 1, z = origen.z + z}, {name = "exploration_catholic_church:altar_mayor", param2 = 3})
                    minetest.set_node({x = origen.x - 25, y = origen.y + 10, z = origen.z + z}, {name = "exploration_catholic_church:roseton"})
                    minetest.set_node({x = origen.x + 25, y = origen.y + 10, z = origen.z + z}, {name = "exploration_catholic_church:roseton"})
                end
            end
        end
        return true, S("Capillas laterales excavadas y cimentadas. Bloques alterados: ") .. bloques
    end,
})

-- =====================================================================
-- 39. Ensamblaje Frontal del Coro Alto, Escaleras y Órgano Tubular
-- =====================================================================

minetest.register_chatcommand("construir_coro", {
    description = S("Erige el segundo piso, escaleras laterales y el órgano en la fachada principal"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Ejecuta /construir_nave primero.") end
        local bloques = 0

        -- 1. Tribuna del Coro Alto (Segundo Piso en Y=15)
        -- Se extiende desde la fachada (Z=2) hasta Z=12, abarcando el ancho total
        for x = -15, 15 do
            for z = 2, 12 do
                minetest.set_node({x = origen.x + x, y = origen.y + 15, z = origen.z + z}, {name = "exploration_catholic_church:piso_coro"})
                bloques = bloques + 1
            end
        end

        -- 2. Pilares de Soporte de la Tribuna (Evita la suspensión irreal)
        -- Descienden desde el borde del coro (Z=12) hasta el mármol (Y=1)
        for _, x in ipairs({-14, -7, 7, 14}) do
            for y = 1, 14 do
                minetest.set_node({x = origen.x + x, y = origen.y + y, z = origen.z + 12}, {name = "exploration_catholic_church:pilar_piedra"})
                bloques = bloques + 1
            end
        end

        -- 3. Escalinatas Laterales de Acceso
        -- Descienden desde el coro (Z=13, Y=14) hacia el interior de la nave (Z=26, Y=1)
        for i = 1, 14 do
            local y_escalera = 15 - i
            local z_escalera = 12 + i
            
            -- Escalera del muro izquierdo (X = -14)
            minetest.set_node({x = origen.x - 14, y = origen.y + y_escalera, z = origen.z + z_escalera}, {
                name = "exploration_catholic_church:escalera_coro",
                param2 = 2 -- Rotación matemática para que el jugador suba caminando hacia la entrada (-Z)
            })
            
            -- Escalera del muro derecho (X = 14)
            minetest.set_node({x = origen.x + 14, y = origen.y + y_escalera, z = origen.z + z_escalera}, {
                name = "exploration_catholic_church:escalera_coro",
                param2 = 2
            })
            bloques = bloques + 2
        end

        -- 4. Matriz del Órgano Tubular ("Enfrente", sobre la tribuna)
        -- Adosado al muro de bronce de la fachada principal (Z=2)
        for x = -6, 6 do
            for y = 16, 35 do
                minetest.set_node({x = origen.x + x, y = origen.y + y, z = origen.z + 2}, {
                    name = "exploration_catholic_church:organo_tubular",
                    param2 = 2
                })
                bloques = bloques + 1
            end
        end

        -- 5. Bancas del Coro para el ensamble vocal
        for x = -10, 10 do
            if x < -2 or x > 2 then -- Respetar el pasillo central hacia el órgano
                minetest.set_node({x = origen.x + x, y = origen.y + 16, z = origen.z + 10}, {name = "exploration_catholic_church:banca_madera", param2 = 2})
            end
        end

        return true, S("Tribuna cimentada, escalinatas y órgano frontal ensamblados con éxito. Bloques: ") .. bloques
    end,
})

-- =====================================================================
-- 40. Extrusión del Campanario Monumental (Con Entrada y Cimentación)
-- =====================================================================

minetest.register_chatcommand("construir_campanario", {
    description = S("Erige el campanario monumental, escaleras de caracol, piso y campana interactiva"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Ejecuta /construir_nave primero.") end
        local bloques = 0
        
        -- Coordenadas centrales del campanario (Adosado a la izquierda de la fachada)
        local cx = origen.x - 26
        local cz = origen.z + 5

        -- 0. Cimentación Base del Campanario (Cota Y=0)
        for dx = -4, 4 do
            for dz = -4, 4 do
                minetest.set_node({x = cx + dx, y = origen.y, z = cz + dz}, {name = "exploration_catholic_church:marmol_blanco"})
                bloques = bloques + 1
            end
        end
        
        -- 1. Fuste del Campanario y Escalera de Caracol Matemática (Y=1 a Y=70)
        for y = 1, 70 do
            local paso = (y - 1) % 24
            local sx, sz, sdir
            
            if paso < 6 then 
                sx = -3; sz = -3 + paso; sdir = 0 
            elseif paso < 12 then 
                sx = -3 + (paso - 6); sz = 3; sdir = 1 
            elseif paso < 18 then 
                sx = 3; sz = 3 - (paso - 12); sdir = 2 
            else 
                sx = 3 - (paso - 18); sz = -3; sdir = 3 
            end

            for dx = -4, 4 do
                for dz = -4, 4 do
                    local pos = {x = cx + dx, y = origen.y + y, z = cz + dz}
                    
                    if math.abs(dx) == 4 or math.abs(dz) == 4 then
                        minetest.set_node(pos, {name = "exploration_catholic_church:muro_campanario"})
                    elseif y == 70 then
                        if dx == sx and dz == sz then
                            -- Peldaño final de la escalera
                            minetest.set_node(pos, {name = "exploration_catholic_church:escalera_coro", param2 = sdir})
                        elseif dz == -3 and dx > 0 and dx <= 3 then
                            -- Escotilla matemática: Vacío para que pase la cabeza del jugador
                            minetest.set_node(pos, {name = "air"})
                        else
                            -- Piso del campanario
                            minetest.set_node(pos, {name = "exploration_catholic_church:piso_coro"})
                        end
                    elseif dx == sx and dz == sz then
                        minetest.set_node(pos, {name = "exploration_catholic_church:escalera_coro", param2 = sdir})
                    else
                        minetest.set_node(pos, {name = "air"})
                    end
                    bloques = bloques + 1
                end
            end
        end
        
        -- 2. Cuerpo de Campanas (Arcadas Abiertas de Y=71 a Y=82)
        for y = 71, 82 do
            for dx = -4, 4 do
                for dz = -4, 4 do
                    local pos = {x = cx + dx, y = origen.y + y, z = cz + dz}
                    local es_borde = (math.abs(dx) == 4 or math.abs(dz) == 4)
                    local es_pilar = (math.abs(dx) == 4 and math.abs(dz) == 4) 
                    
                    if es_pilar or (es_borde and (y < 73 or y > 80)) then
                        minetest.set_node(pos, {name = "exploration_catholic_church:muro_campanario"})
                    elseif es_borde then
                        minetest.set_node(pos, {name = "air"})
                    else
                        minetest.set_node(pos, {name = "air"})
                    end
                    bloques = bloques + 1
                end
            end
        end

        -- 3. Chapitel Piramidal (Reducción matemática del radio de Y=83 a Y=92)
        for i = 0, 9 do
            local y_act = 83 + i
            local radio = 4 - math.floor(i / 2) 
            
            for dx = -radio, radio do
                for dz = -radio, radio do
                    minetest.set_node({x = cx + dx, y = origen.y + y_act, z = cz + dz}, {name = "exploration_catholic_church:techo_campanario"})
                    bloques = bloques + 1
                end
            end
        end
        
        -- 4. Cruz de Remate (Cúspide de Y=93 a Y=95)
        minetest.set_node({x = cx, y = origen.y + 93, z = cz}, {name = "exploration_catholic_church:muro_campanario"})
        minetest.set_node({x = cx, y = origen.y + 94, z = cz}, {name = "exploration_catholic_church:muro_campanario"})
        minetest.set_node({x = cx - 1, y = origen.y + 94, z = cz}, {name = "exploration_catholic_church:muro_campanario"})
        minetest.set_node({x = cx + 1, y = origen.y + 94, z = cz}, {name = "exploration_catholic_church:muro_campanario"})
        minetest.set_node({x = cx, y = origen.y + 95, z = cz}, {name = "exploration_catholic_church:muro_campanario"})

        -- 5. Instalación de la Campana y Cadenas en el centro del vano
        minetest.set_node({x = cx, y = origen.y + 75, z = cz}, {name = "exploration_catholic_church:campana_bronce"})
        for y_cad = 76, 82 do
            minetest.set_node({x = cx, y = origen.y + y_cad, z = cz}, {name = "exploration_catholic_church:cadena"})
        end

        -- =================================================================
        -- 6. Pasillo de Conexión (Perforación y Sellado del Vacío X=-21)
        -- =================================================================
        
        -- Suelo de mármol para el umbral del pasillo
        for z_puerta = 4, 6 do
            minetest.set_node({x = origen.x - 21, y = origen.y, z = origen.z + z_puerta}, {name = "exploration_catholic_church:marmol_blanco"})
        end

        -- Perforamos el arco de 3x3 bloques (Y=1 a Y=3)
        for y_puerta = 1, 3 do
            for z_puerta = 4, 6 do
                minetest.set_node({x = origen.x - 20, y = origen.y + y_puerta, z = origen.z + z_puerta}, {name = "air"}) -- Rompe muro iglesia
                minetest.set_node({x = origen.x - 21, y = origen.y + y_puerta, z = origen.z + z_puerta}, {name = "air"}) -- Vacía el espacio intermedio
                minetest.set_node({x = origen.x - 22, y = origen.y + y_puerta, z = origen.z + z_puerta}, {name = "air"}) -- Rompe muro torre
            end
        end

        -- Sellamos el pasillo intermedio (Techo y Muros de contención en el hueco X=-21)
        for z_puerta = 4, 6 do
            minetest.set_node({x = origen.x - 21, y = origen.y + 4, z = origen.z + z_puerta}, {name = "exploration_catholic_church:muro_lateral"})
        end
        for y_puerta = 1, 4 do
            minetest.set_node({x = origen.x - 21, y = origen.y + y_puerta, z = origen.z + 3}, {name = "exploration_catholic_church:muro_lateral"})
            minetest.set_node({x = origen.x - 21, y = origen.y + y_puerta, z = origen.z + 7}, {name = "exploration_catholic_church:muro_lateral"})
        end

        return true, S("Campanario cimentado y conectado a la nave. Bloques: ") .. bloques
    end,
})

-- =====================================================================
-- 41. Extrusión Asimétrica del Púlpito y el Tornavoz
-- =====================================================================

minetest.register_chatcommand("construir_pulpito", {
    description = S("Erige el púlpito asimétrico de madera en la nave central"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Ejecuta /construir_nave primero.") end
        local bloques = 0

        -- Centro del Púlpito: Adosado al pilar izquierdo en Z=60
        -- El pilar está en X=-15, por lo que el púlpito sobresale hasta X=-11
        local cx = origen.x - 11
        local cz = origen.z + 60

        -- 1. Fuste de Piedra, Tribuna de Madera y Barandilla (Y=1 a Y=6)
        for y = 1, 6 do
            for dx = -2, 2 do
                for dz = -2, 2 do
                    local d_sq = (dx*dx) + (dz*dz)
                    local pos = {x = cx + dx, y = origen.y + y, z = cz + dz}
                    
                    if y < 5 and d_sq <= 1 then
                        -- Columna central de soporte
                        minetest.set_node(pos, {name = "exploration_catholic_church:pilar_piedra"})
                        bloques = bloques + 1
                    elseif y == 5 and d_sq <= 4 then
                        -- Suelo de la tribuna (Radio 2)
                        minetest.set_node(pos, {name = "exploration_catholic_church:madera_pulpito"})
                        bloques = bloques + 1
                    elseif y == 6 and d_sq > 0 and d_sq <= 4 then
                        -- Barandilla de madera perimetral
                        if not (dx == 2 and dz == 0) then -- Perforamos un hueco en +X para la entrada de la escalera
                            minetest.set_node(pos, {name = "exploration_catholic_church:madera_pulpito"})
                            bloques = bloques + 1
                        end
                    end
                end
            end
        end

        -- 2. Escalinata Frontal (Y=1 a Y=4)
        -- Sube desde el pasillo central hacia el interior del púlpito
        for i = 1, 4 do
            local x_escalera = cx + 7 - i -- Inicia en cx+6 y termina en cx+3
            minetest.set_node({x = x_escalera, y = origen.y + i, z = cz}, {
                name = "exploration_catholic_church:escalera_coro", 
                param2 = 3 -- Rotación: la escalera mira hacia el centro de la nave (+X)
            })
            bloques = bloques + 1
        end

        -- 3. El Tornavoz (Techo Acústico de Madera en Y=11 y Y=12)
        for dx = -3, 3 do
            for dz = -3, 3 do
                local d_sq = (dx*dx) + (dz*dz)
                if d_sq <= 9 then
                    -- Alero ancho del tornavoz
                    minetest.set_node({x = cx + dx, y = origen.y + 11, z = cz + dz}, {name = "exploration_catholic_church:tornavoz_pulpito"})
                    bloques = bloques + 1
                end
                if d_sq <= 4 then
                    -- Cúpula menor del tornavoz
                    minetest.set_node({x = cx + dx, y = origen.y + 12, z = cz + dz}, {name = "exploration_catholic_church:tornavoz_pulpito"})
                    bloques = bloques + 1
                end
            end
        end
        
        -- Remate dorado en la cúspide del techo
        minetest.set_node({x = cx, y = origen.y + 13, z = cz}, {name = "exploration_catholic_church:candelabro_oro"})

        return true, S("Púlpito asimétrico y tornavoz acústico ensamblados exitosamente. Bloques: ") .. bloques
    end,
})

-- =====================================================================
-- 42. Sistema de Compilación y Despliegue Universal (.mts)
-- =====================================================================

minetest.register_chatcommand("exportar_basilica", {
    description = S("Compila la basílica terminada en un archivo binario universal .mts"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: El Datum Topográfico no está fijado en la memoria.") end

        -- 1. Cálculo de la Caja Delimitadora (Bounding Box) Corregida
        -- X: Los transeptos de ambos lados llegan a -70 y +70. Damos un margen de 75.
        -- Y: Desde la cripta en -10 hasta la cruz del campanario en +95. Margen (-15 a 100).
        -- Z: Desde la entrada (-5) hasta el ábside en Z=140 con radio 20 (Z=160). Margen (-5 a 165).
        local p1 = {x = origen.x - 75, y = origen.y - 15, z = origen.z - 5}
        local p2 = {x = origen.x + 75, y = origen.y + 100, z = origen.z + 165}
        
        local ruta_archivo = minetest.get_worldpath() .. "/basilica_latina.mts"
        local exito = minetest.create_schematic(p1, p2, nil, ruta_archivo, nil)
        
        if exito then
            return true, S("¡Caja Delimitadora expandida! Basílica compilada en: ") .. ruta_archivo
        else
            return false, S("Fallo crítico al compilar el esquema geométrico.")
        end
    end,
})

minetest.register_chatcommand("importar_basilica", {
    description = S("Materializa la basílica instantáneamente desde el esquema .mts"),
    func = function(name, param)
        local jugador = minetest.get_player_by_name(name)
        if not jugador then return false, S("Jugador no encontrado.") end
        
        local pos = jugador:get_pos()
        
        -- 2. Corrección de Anclaje mediante Sustracción de Vectores
        -- El motor intentará poner la coordenada p1 (-75, -15, -5) en los pies del jugador.
        -- Para obligar a que la coordenada 0,0,0 (la entrada) quede exactamente en el jugador,
        -- restamos la distancia de p1 a la posición de anclaje.
        local pos_anclaje = {
            x = math.floor(pos.x) - 75,
            y = math.floor(pos.y) - 16, -- Restamos 15 del fondo, y 1 extra para que el mármol quede bajo los pies
            z = math.floor(pos.z) - 5
        }
        
        local ruta_mod = minetest.get_modpath("exploration_catholic_church")
        local ruta_schematic = ruta_mod .. "/schematics/basilica_latina.mts"
        
        local exito = minetest.place_schematic(pos_anclaje, ruta_schematic, "0", nil, true)
        
        if exito then
            return true, S("Estructura anclada con precisión láser. La basílica te rodea.")
        else
            return false, S("Error: No se encontró el archivo .mts en la carpeta 'schematics' del mod.")
        end
    end,
})