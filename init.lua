-- =====================================================================
-- 0. TOPOGRAPHIC DATUM AND PERSISTENT MEMORY (Hard Drive)
-- =====================================================================
local storage = minetest.get_mod_storage()
local S = minetest.get_translator("exploration_catholic_church")

exploration_catholic_church_origen = nil
exploration_catholic_church_altares = {}
exploration_catholic_church_audio_states = {}

if storage:get_int("datum_establecido") == 1 then
    exploration_catholic_church_origen = {
        x = storage:get_int("origen_x"),
        y = storage:get_int("origen_y"),
        z = storage:get_int("origen_z")
    }
end

minetest.register_chatcommand("anclar_datum", {
    description = S("Sets the Topographic Datum by automatically scanning the marble floor"),
    func = function(name, param)
        local jugador = minetest.get_player_by_name(name)
        if not jugador then return false, S("Error: Player not found.") end

        local pos = jugador:get_pos()
        local x_orig = math.floor(pos.x)
        local z_orig = math.floor(pos.z)
        local y_orig = math.floor(pos.y)

        for i = -1, 4 do
            local cota_y = math.floor(pos.y) - i
            local nodo = minetest.get_node({x = x_orig, y = cota_y, z = z_orig})
            if nodo.name == "exploration_catholic_church:marmol_blanco" then
                y_orig = cota_y
                break
            end
        end
        
        exploration_catholic_church_origen = {x = x_orig, y = y_orig, z = z_orig}
        
        if storage then
            storage:set_int("datum_establecido", 1)
            storage:set_int("origen_x", x_orig)
            storage:set_int("origen_y", y_orig)
            storage:set_int("origen_z", z_orig)
        end

        return true, S("Datum anchored with laser precision. Origin Y detected at level: ") .. y_orig
    end,
})

minetest.register_chatcommand("construir_nave", {
    description = S("Sets the Topographic Datum, generates the floor and clears the area"),
    func = function(name, param)
        local jugador = minetest.get_player_by_name(name)
        if not jugador then return false, S("Error: Player not found.") end

        local pos_jugador = jugador:get_pos()
        exploration_catholic_church_origen = {
            x = math.floor(pos_jugador.x),
            y = math.floor(pos_jugador.y) - 1,
            z = math.floor(pos_jugador.z)
        }
        
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
        return true, S("Datum permanently established on disk. Blocks processed: ") .. operaciones
    end,
})

-- =====================================================================
-- REGISTRATION OF MATERIALS AND SACRED ART
-- =====================================================================

minetest.register_node("exploration_catholic_church:madera_pulpito", {
    description = S("Carved Pulpit Wood"),
    tiles = {"vaticano_madera_pulpito.png"},
    paramtype = "light",
    light_source = 14,
    groups = {choppy = 2, wood = 1, arte_sacro = 1}
})

minetest.register_node("exploration_catholic_church:tornavoz_pulpito", {
    description = S("Acoustic Sounding Board"),
    tiles = {"vaticano_tornavoz.png"},
    paramtype = "light",
    light_source = 14,
    groups = {choppy = 2, wood = 1, arte_sacro = 1}
})

minetest.register_node("exploration_catholic_church:piso_coro", {
    description = S("Choir Parquet Floor"),
    tiles = {"vaticano_piso_coro.png"},
    paramtype = "light",
    light_source = 14,
    groups = {choppy = 3, wood = 1, arte_sacro = 1}
})

minetest.register_node("exploration_catholic_church:escalera_coro", {
    description = S("Mahogany Stairs"),
    tiles = {"vaticano_escalera_coro.png"},
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
    groups = {choppy = 3, wood = 1, arte_sacro = 1}
})

minetest.register_node("exploration_catholic_church:marmol_blanco", {
    description = S("Central White Marble"),
    tiles = {"vaticano_marmol_blanco.png"},
    paramtype = "light",
    light_source = 14,
    groups = {cracky = 3, stone = 1},
})

minetest.register_node("exploration_catholic_church:pilar_piedra", {
    description = S("Stone Pillar"),
    tiles = {"vaticano_pilar_piedra.png"},
    paramtype = "light",
    light_source = 14,
    groups = {cracky = 3, stone = 1},
})

minetest.register_node("exploration_catholic_church:muro_lateral", {
    description = S("Stone Side Wall"),
    tiles = {"vaticano_muro_lateral.png"},
    paramtype = "light",
    light_source = 14,
    groups = {cracky = 3, stone = 1},
})

minetest.register_node("exploration_catholic_church:vitral", {
    description = S("Sacred Stained Glass"),
    tiles = {"vaticano_vitral.png"},
    drawtype = "glasslike",
    paramtype = "light",
    sunlight_propagates = true,
    use_texture_alpha = "blend",
    light_source = 14,
    groups = {cracky = 3, oddly_breakable_by_hand = 3, arte_sacro = 1}
})

minetest.register_node("exploration_catholic_church:roseton", {
    description = S("Rose Window Stained Glass"),
    tiles = {"vaticano_roseton.png"},
    drawtype = "glasslike",
    paramtype = "light",
    sunlight_propagates = true,
    use_texture_alpha = "blend",
    light_source = 14,
    groups = {cracky = 3, glass = 1, arte_sacro = 1}
})

minetest.register_node("exploration_catholic_church:porton_bronce", {
    description = S("Sacred Vatican Bronze"),
    tiles = {"vaticano_porton_bronce.png"},
    paramtype = "light",
    light_source = 14,
    groups = {cracky = 2, stone = 1},
})

minetest.register_node("exploration_catholic_church:techo_fresco", {
    description = S("Renaissance Fresco Vault"),
    tiles = {"vaticano_techo_fresco.png"},
    paramtype = "light",
    light_source = 14,
    groups = {cracky = 3, stone = 1},
})

minetest.register_node("exploration_catholic_church:cupula_elegante", {
    description = S("Golden Transept Mosaic"),
    tiles = {"vaticano_cupula_elegante.png"},
    paramtype = "light",
    light_source = 14,
    groups = {cracky = 3, stone = 1},
})

minetest.register_node("exploration_catholic_church:techo_lateral", {
    description = S("Elegant Coffered Ceiling"),
    tiles = {"vaticano_techo_lateral.png"},
    paramtype = "light",
    light_source = 14,
    groups = {cracky = 3, stone = 1},
})

minetest.register_node("exploration_catholic_church:techo_transepto", {
    description = S("Transept Fresco"),
    tiles = {"vaticano_techo_transepto.png"},
    paramtype = "light",
    light_source = 14,
    groups = {cracky = 3, stone = 1},
})

minetest.register_node("exploration_catholic_church:candelabro_oro", {
    description = S("Sacred Golden Chandelier"),
    drawtype = "plantlike",
    tiles = {"vaticano_candelabro.png"},
    inventory_image = "vaticano_candelabro.png",
    paramtype = "light",
    light_source = 14,
    walkable = false,
    groups = {cracky = 2, oddly_breakable_by_hand = 3},
})

minetest.register_node("exploration_catholic_church:estatua_marmol", {
    description = S("Sacred Statue"),
    drawtype = "plantlike",
    tiles = {"vaticano_estatua.png"},
    inventory_image = "vaticano_estatua.png",
    paramtype = "light",
    walkable = false,
    groups = {cracky = 3}
})

minetest.register_node("exploration_catholic_church:banca_madera", {
    description = S("Mahogany Pew"),
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

minetest.register_node("exploration_catholic_church:muro_campanario", {
    description = S("Belltower Ashlar"),
    tiles = {"vaticano_muro_campanario.png"},
    paramtype = "light",
    light_source = 14,
    groups = {cracky = 3, stone = 1, arte_sacro = 1}
})

minetest.register_node("exploration_catholic_church:techo_campanario", {
    description = S("Oxidized Copper Spire"),
    tiles = {"vaticano_techo_campanario.png"},
    paramtype = "light",
    light_source = 14,
    groups = {cracky = 3, stone = 1, arte_sacro = 1}
})

minetest.register_node("exploration_catholic_church:campana_bronce", {
    description = S("Monumental Bronze Bell"),
    tiles = {"vaticano_campana.png"},
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = {
        type = "fixed",
        fixed = {
            {-0.4, -0.5, -0.4, 0.4, 0.0, 0.4},
            {-0.3, 0.0, -0.3, 0.3, 0.3, 0.3},
            {-0.15, 0.3, -0.15, 0.15, 0.5, 0.15}
        }
    },
    groups = {cracky = 2, oddly_breakable_by_hand = 2, arte_sacro = 1},
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        minetest.sound_play("exploration_catholic_church_campana", {
            pos = pos,
            gain = 5.0,
            max_hear_distance = 300,
        })
        return itemstack
    end,
})

-- =====================================================================
-- ACOUSTIC SYSTEM
-- =====================================================================

exploration_catholic_church_organos = {}
exploration_catholic_church_audio_organo_states = {}

minetest.register_node("exploration_catholic_church:altar_mayor", {
    description = S("High Altar with Relics"),
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
    description = S("Majestic Pipe Organ"),
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
    label = S("Index Acoustic Emitters in Memory"),
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

local RADIO_ACUSTICO = 250
local tiempo_transcurrido = 0

minetest.register_globalstep(function(dtime)
    tiempo_transcurrido = tiempo_transcurrido + dtime
    if tiempo_transcurrido < 2.0 then return end 
    tiempo_transcurrido = 0

    for _, jugador in ipairs(minetest.get_connected_players()) do
        local nombre = jugador:get_player_name()
        local pos_jugador = jugador:get_pos()
        
        local dist_altar = math.huge
        local dist_organo = math.huge
        
        for _, pos_a in pairs(exploration_catholic_church_altares) do
            local d = vector.distance(pos_jugador, pos_a)
            if d < dist_altar then dist_altar = d end
        end
        
        for _, pos_o in pairs(exploration_catholic_church_organos) do
            local d = vector.distance(pos_jugador, pos_o)
            if d < dist_organo then dist_organo = d end
        end
        
        local reproducir = "silencio"
        
        if dist_altar <= RADIO_ACUSTICO or dist_organo <= RADIO_ACUSTICO then
            if dist_altar < dist_organo then
                reproducir = "altar"
            else
                reproducir = "organo"
            end
        end
        
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
    description = S("Temporarily stops the reproduction of Gregorian chants"),
    func = function(name, param)
        if exploration_catholic_church_audio_states[name] then
            minetest.sound_stop(exploration_catholic_church_audio_states[name])
            exploration_catholic_church_audio_states[name] = nil
            return true, S("The choir is now silent.")
        else
            return false, S("There are no chants playing for you.")
        end
    end,
})

-- =====================================================================
-- BUILD COMMANDS
-- =====================================================================

minetest.register_chatcommand("construir_pilares", {
    description = S("Erects structural pillars"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Execute /construir_nave first.") end

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
        return true, S("Colonnades generated: ") .. bloques .. S(" blocks.")
    end,
})

minetest.register_node("exploration_catholic_church:muro_triforio", {
    description = S("Triforium Arcade"),
    tiles = {"vaticano_triforio.png"},
    groups = {cracky = 3, stone = 1, arte_sacro = 1},
})

minetest.register_node("exploration_catholic_church:vitral_gotico", {
    description = S("Clerestory Gothic Stained Glass"),
    tiles = {"vaticano_vitral_gotico.png"},
    drawtype = "glasslike",
    paramtype = "light",
    sunlight_propagates = true,
    use_texture_alpha = "blend",
    light_source = 14,
    groups = {cracky = 3, glass = 1, arte_sacro = 1}
})

minetest.register_chatcommand("construir_muros", {
    description = S("Builds ashlar, triforium, and clerestory in a single mathematical calculation"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Execute /construir_nave first.") end

        local bloques = 0
        
        for z = 0, 100 do
            local modulo_z = z % 10 
            
            for y = 1, 50 do
                local nodo_nombre = "exploration_catholic_church:muro_lateral"
                
                if y >= 31 and y <= 34 then
                    if modulo_z >= 2 and modulo_z <= 8 then
                        nodo_nombre = "exploration_catholic_church:muro_triforio"
                    end
                elseif y >= 35 and y <= 46 then
                    if modulo_z >= 3 and modulo_z <= 7 then
                        nodo_nombre = "exploration_catholic_church:vitral_gotico"
                    end
                end

                minetest.set_node({x = origen.x - 20, y = origen.y + y, z = origen.z + z}, {name = nodo_nombre})
                minetest.set_node({x = origen.x + 20, y = origen.y + y, z = origen.z + z}, {name = nodo_nombre})
                bloques = bloques + 2
            end
        end
        return true, S("Architectural extrusion complete. ") .. bloques .. S(" blocks processed in a single pass.")
    end,
})

minetest.register_chatcommand("construir_vitrales", {
    description = S("Installs illuminated stained glass in the lower part of the perimeter walls"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Execute /construir_nave first.") end

        local bloques = 0
        
        for z = 10, 90 do
            local modulo_z = z % 10
            if modulo_z >= 3 and modulo_z <= 7 then
                for y = 12, 26 do
                    minetest.set_node({x = origen.x - 20, y = origen.y + y, z = origen.z + z}, {name = "exploration_catholic_church:vitral"})
                    minetest.set_node({x = origen.x + 20, y = origen.y + y, z = origen.z + z}, {name = "exploration_catholic_church:vitral"})
                    bloques = bloques + 2
                end
            end
        end
        return true, S("Lower stained glass installed mathematically. Illuminated blocks: ") .. bloques
    end,
})

minetest.register_chatcommand("construir_fachadas", {
    description = S("Erects facades and monumental door"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Execute /construir_nave first.") end

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
        return true, S("Facades completed.")
    end,
})

minetest.register_chatcommand("construir_roseton", {
    description = S("Installs the great front rose window"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Execute /construir_nave first.") end

        local radio, centro_y, bloques = 6, 35, 0
        for x = -radio, radio do
            for y = centro_y - radio, centro_y + radio do
                if (x*x) + ((y-centro_y)*(y-centro_y)) <= (radio*radio) then
                    minetest.set_node({x = origen.x + x, y = origen.y + y, z = origen.z}, {name = "exploration_catholic_church:roseton"})
                    bloques = bloques + 1
                end
            end
        end
        return true, S("Rose window installed.")
    end,
})

minetest.register_chatcommand("construir_timpano", {
    description = S("Seals the front facade with a classic tympanum"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Execute /construir_nave first.") end

        for x = -15, 15 do
            local y_max = 65 - math.abs(x)
            for y = 50, y_max do
                minetest.set_node({x = origen.x + x, y = origen.y + y, z = origen.z}, {name = "exploration_catholic_church:muro_lateral"})
            end
        end
        return true, S("Tympanum built.")
    end,
})

minetest.register_chatcommand("construir_crucero_cupula", {
    description = S("Generates the transept, drum, and dome"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Execute /construir_nave first.") end

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
        return true, S("Transept and dome erected.")
    end,
})

minetest.register_chatcommand("construir_pechinas", {
    description = S("Generates the transept pendentives"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Execute /construir_nave first.") end

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
        return true, S("Golden pendentives assembled.")
    end,
})

minetest.register_chatcommand("construir_techos_transeptos", {
    description = S("Seals the transepts"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Execute /construir_nave first.") end

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
        return true, S("Transepts sealed.")
    end,
})

minetest.register_chatcommand("construir_abside", {
    description = S("Generates the apse"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Execute /construir_nave first.") end

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

        return true, S("Apse built.")
    end,
})

minetest.register_chatcommand("construir_techos_laterales", {
    description = S("Seals the side naves"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Execute /construir_nave first.") end

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
        return true, S("Side roofs assembled.")
    end,
})

minetest.register_chatcommand("construir_boveda", {
    description = S("Builds the real clerestory in the central nave and the vault"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Execute /construir_nave first.") end

        for z = 0, 100 do
            local modulo_z = z % 10
            for y = 40, 50 do
                local nodo_muro = "exploration_catholic_church:muro_lateral"
                if y >= 42 and y <= 48 and modulo_z >= 3 and modulo_z <= 7 then
                    nodo_muro = "exploration_catholic_church:vitral_gotico"
                end
                for x = -15, -13 do minetest.set_node({x = origen.x + x, y = origen.y + y, z = origen.z + z}, {name = nodo_muro}) end
                for x = 13, 15 do minetest.set_node({x = origen.x + x, y = origen.y + y, z = origen.z + z}, {name = nodo_muro}) end
            end
        end

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

        for z_luz = 20, 80, 20 do
            minetest.set_node({x = origen.x, y = origen.y + 62, z = origen.z + z_luz}, {name = "exploration_catholic_church:candelabro_oro"})
            for y_cad = 63, 64 do
                minetest.set_node({x = origen.x, y = origen.y + y_cad, z = origen.z + z_luz}, {name = "exploration_catholic_church:cadena"})
            end
        end

        return true, S("Vault and illuminated central clerestory successfully assembled.")
    end,
})

minetest.register_chatcommand("iluminar_laterales", {
    description = S("Installs chandeliers with chains in the perimeter aisles"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Execute /construir_nave first.") end

        for z = 10, 90, 20 do
            minetest.set_node({x = origen.x - 17, y = origen.y + 33, z = origen.z + z}, {name = "exploration_catholic_church:candelabro_oro"})
            for y_cad = 34, 37 do minetest.set_node({x = origen.x - 17, y = origen.y + y_cad, z = origen.z + z}, {name = "exploration_catholic_church:cadena"}) end
            
            minetest.set_node({x = origen.x + 17, y = origen.y + 33, z = origen.z + z}, {name = "exploration_catholic_church:candelabro_oro"})
            for y_cad = 34, 37 do minetest.set_node({x = origen.x + 17, y = origen.y + y_cad, z = origen.z + z}, {name = "exploration_catholic_church:cadena"}) end
        end
        return true, S("Minor aisles illuminated and anchored.")
    end,
})

minetest.register_chatcommand("iluminar_interseccion", {
    description = S("Deploys major luminaires and statuary in the transept, transepts, and apse"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Execute /construir_nave first.") end
        local luces = 0

        minetest.set_node({x = origen.x, y = origen.y + 60, z = origen.z + 120}, {name = "exploration_catholic_church:candelabro_papal"})
        for y_cad = 61, 84 do minetest.set_node({x = origen.x, y = origen.y + y_cad, z = origen.z + 120}, {name = "exploration_catholic_church:cadena"}) end
        luces = luces + 1

        for _, x in ipairs({-35, -55, 35, 55}) do
            minetest.set_node({x = origen.x + x, y = origen.y + 50, z = origen.z + 120}, {name = "exploration_catholic_church:candelabro_papal"})
            for y_cad = 51, 69 do minetest.set_node({x = origen.x + x, y = origen.y + y_cad, z = origen.z + 120}, {name = "exploration_catholic_church:cadena"}) end
            luces = luces + 1
        end

        for z = 105, 135, 10 do
            minetest.set_node({x = origen.x - 68, y = origen.y + 1, z = origen.z + z}, {name = "exploration_catholic_church:candelabro_pie"})
            minetest.set_node({x = origen.x + 68, y = origen.y + 1, z = origen.z + z}, {name = "exploration_catholic_church:candelabro_pie"})
            luces = luces + 2
        end

        minetest.set_node({x = origen.x - 8, y = origen.y + 1, z = origen.z + 138}, {name = "exploration_catholic_church:candelabro_pie"})
        minetest.set_node({x = origen.x + 8, y = origen.y + 1, z = origen.z + 138}, {name = "exploration_catholic_church:candelabro_pie"})
        luces = luces + 2

        for x_abs = -12, 12, 6 do
            local z_curva = 140 + math.floor(math.sqrt((17 * 17) - (x_abs * x_abs)))
            minetest.set_node({x = origen.x + x_abs, y = origen.y + 1, z = origen.z + z_curva}, {name = "exploration_catholic_church:veladora_gigante"})
            luces = luces + 1
        end

        return true, S("Transept and apse eradicated from the gloom. Chains forged.")
    end,
})

minetest.register_chatcommand("construir_detalles", {
    description = S("Generates pews and statues safely"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Execute /construir_nave first.") end

        for z = 15, 85, 3 do
            for x = -12, -3 do minetest.set_node({x = origen.x + x, y = origen.y + 1, z = origen.z + z}, {name = "exploration_catholic_church:banca_madera", param2 = 2}) end
            for x = 3, 12 do minetest.set_node({x = origen.x + x, y = origen.y + 1, z = origen.z + z}, {name = "exploration_catholic_church:banca_madera", param2 = 2}) end
        end

        for z = 10, 90, 10 do
            minetest.set_node({x = origen.x - 12, y = origen.y + 1, z = origen.z + z}, {name = "exploration_catholic_church:estatua_marmol"})
            minetest.set_node({x = origen.x + 12, y = origen.y + 1, z = origen.z + z}, {name = "exploration_catholic_church:estatua_marmol"})
        end
        return true, S("Furniture and statuary generated on the marble.")
    end,
})

minetest.register_chatcommand("construir_altar", {
    description = S("Positions the High Altar in the apse"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Execute /construir_nave first.") end

        local pos_altar = {x = origen.x, y = origen.y + 1, z = origen.z + 138}
        minetest.set_node(pos_altar, {name = "exploration_catholic_church:altar_mayor", param2 = 2})
        
        local clave = minetest.pos_to_string(pos_altar)
        exploration_catholic_church_altares[clave] = pos_altar
        return true, S("High Altar erected on the Datum.")
    end,
})

minetest.register_node("exploration_catholic_church:veladora_gigante", {
    description = S("Giant Paschal Candle"),
    tiles = {
        "vaticano_veladora_top.png", "vaticano_marmol_blanco.png", 
        "vaticano_veladora_side.png", "vaticano_veladora_side.png",
        "vaticano_veladora_side.png", "vaticano_veladora_side.png"
    },
    drawtype = "nodebox",
    paramtype = "light",
    light_source = 13,
    node_box = {
        type = "fixed",
        fixed = {
            {-0.2, -0.5, -0.2, 0.2, 0.6, 0.2},
            {-0.05, 0.6, -0.05, 0.05, 0.8, 0.05},
        }
    },
    groups = {choppy = 2, oddly_breakable_by_hand = 2}
})

minetest.register_node("exploration_catholic_church:lampara_muro", {
    description = S("Renaissance Wall Sconce"),
    drawtype = "torchlike",
    tiles = {"vaticano_lampara_muro.png"},
    inventory_image = "vaticano_lampara_muro.png",
    paramtype = "light",
    paramtype2 = "wallmounted",
    sunlight_propagates = true,
    walkable = false,
    light_source = 14,
    groups = {cracky = 2, attached_node = 1}
})

minetest.register_chatcommand("iluminar_columnas", {
    description = S("Fixes wrought iron lamps on the pillars and giant candles in the nave"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Execute /construir_nave first.") end

        local luces = 0

        for z = 10, 90, 10 do
            minetest.set_node({x = origen.x - 6, y = origen.y + 1, z = origen.z + z}, {name = "exploration_catholic_church:veladora_gigante"})
            minetest.set_node({x = origen.x + 6, y = origen.y + 1, z = origen.z + z}, {name = "exploration_catholic_church:veladora_gigante"})
            minetest.set_node({x = origen.x - 13, y = origen.y + 6, z = origen.z + z}, {name = "exploration_catholic_church:lampara_muro", param2 = 1})
            minetest.set_node({x = origen.x + 13, y = origen.y + 6, z = origen.z + z}, {name = "exploration_catholic_church:lampara_muro", param2 = 0})
            luces = luces + 4
        end

        return true, S("Colonnades sanctified. Lit ") .. luces .. S(" new light sources.")
    end,
})

minetest.register_node("exploration_catholic_church:cadena", {
    description = S("Wrought Iron Chain"),
    drawtype = "plantlike",
    tiles = {"vaticano_cadena.png"},
    inventory_image = "vaticano_cadena.png",
    paramtype = "light",
    walkable = false,
    groups = {cracky = 2}
})

minetest.register_node("exploration_catholic_church:candelabro_papal", {
    description = S("Grand Papal Chandelier"),
    drawtype = "plantlike", 
    tiles = {"vaticano_candelabro_papal.png"},
    inventory_image = "vaticano_candelabro_papal.png",
    paramtype = "light", 
    light_source = 14, 
    walkable = false,
    visual_scale = 2.0,
    groups = {cracky = 2, oddly_breakable_by_hand = 3},
})

minetest.register_node("exploration_catholic_church:candelabro_pie", {
    description = S("Golden Standing Candelabra"),
    drawtype = "plantlike",
    tiles = {"vaticano_candelabro_pie.png"},
    inventory_image = "vaticano_candelabro_pie.png",
    paramtype = "light",
    light_source = 12,
    walkable = false,
    groups = {cracky = 2, oddly_breakable_by_hand = 3},
})

minetest.register_chatcommand("inventario_sacro", {
    description = S("Grants a stack of all basilica materials and luminaires"),
    func = function(name, param)
        local jugador = minetest.get_player_by_name(name)
        if not jugador then return false, S("Error: Player not found.") end
        
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
        
        return true, S("Sacred inventory supplied. You have all materials in your backpack.")
    end,
})

minetest.register_node("exploration_catholic_church:velas_voto", {
    description = S("Votive Candle Tray"),
    tiles = {
        "vaticano_velas_voto.png", "vaticano_marmol_blanco.png", 
        "vaticano_velas_voto.png", "vaticano_velas_voto.png",
        "vaticano_velas_voto.png", "vaticano_velas_voto.png"
    },
    drawtype = "nodebox",
    paramtype = "light",
    light_source = 11,
    node_box = {
        type = "fixed",
        fixed = {-0.4, -0.5, -0.4, 0.4, -0.3, 0.4}
    },
    groups = {choppy = 2, oddly_breakable_by_hand = 2, arte_sacro = 1}
})

minetest.register_node("exploration_catholic_church:lampara_techo", {
    description = S("Minor Ceiling Lamp"),
    drawtype = "plantlike",
    tiles = {"vaticano_lampara_techo.png"},
    inventory_image = "vaticano_lampara_techo.png",
    paramtype = "light",
    light_source = 13,
    walkable = false,
    groups = {cracky = 2, oddly_breakable_by_hand = 3, arte_sacro = 1}
})

minetest.register_node("exploration_catholic_church:aplique_tambor", {
    description = S("Dome Drum Sconce"),
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

minetest.register_chatcommand("iluminar_alturas", {
    description = S("Injects lamps with chains into the voids of the transept, pendentives, and apse"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Execute /construir_nave first.") end
        
        local cx = origen.x
        local cz = origen.z + 120
        local luces = 0

        for _, radio in ipairs({-17, 17}) do
            minetest.set_node({x = cx + radio, y = origen.y + 55, z = cz}, {name = "exploration_catholic_church:lampara_techo"})
            minetest.set_node({x = cx, y = origen.y + 55, z = cz + radio}, {name = "exploration_catholic_church:lampara_techo"})
            
            for y_cad = 56, 65 do
                minetest.set_node({x = cx + radio, y = origen.y + y_cad, z = cz}, {name = "exploration_catholic_church:cadena"})
                minetest.set_node({x = cx, y = origen.y + y_cad, z = cz + radio}, {name = "exploration_catholic_church:cadena"})
            end
            luces = luces + 2
        end

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

        for _, x_trans in ipairs({-45, -60, 45, 60}) do
            for z_trans = 110, 130, 20 do
                minetest.set_node({x = origen.x + x_trans, y = origen.y + 45, z = origen.z + z_trans}, {name = "exploration_catholic_church:lampara_techo"})
                for y_cad = 46, 55 do
                    minetest.set_node({x = origen.x + x_trans, y = origen.y + y_cad, z = origen.z + z_trans}, {name = "exploration_catholic_church:cadena"})
                end
                luces = luces + 1
            end
        end

        for x_abs = -15, 15, 3 do
            local z_curva = 140 + math.floor(math.sqrt((18 * 18) - (x_abs * x_abs))) - 1
            minetest.set_node({x = origen.x + x_abs, y = origen.y + 1, z = origen.z + z_curva}, {name = "exploration_catholic_church:velas_voto"})
        end

        return true, S("Illuminated height. Added new sources and chains (") .. luces .. S(" aerial lamps).")
    end,
})

minetest.register_chatcommand("perforar_oculo", {
    description = S("Opens an oculus at the zenith of the dome sealed with stained glass for natural light"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Execute /construir_nave first.") end

        local cx = origen.x
        local cz = origen.z + 120 
        local radio_oculo = 3
        local bloques = 0

        for dy = 15, 21 do
            for dx = -radio_oculo, radio_oculo do
                for dz = -radio_oculo, radio_oculo do
                    if (dx*dx) + (dz*dz) <= (radio_oculo * radio_oculo) then
                        local y_absoluta = origen.y + 65 + dy
                        local nodo_actual = minetest.get_node({x = cx + dx, y = y_absoluta, z = cz + dz}).name
                        
                        if nodo_actual == "exploration_catholic_church:cupula_elegante" then
                            minetest.set_node({x = cx + dx, y = y_absoluta, z = cz + dz}, {name = "exploration_catholic_church:vitral"})
                            bloques = bloques + 1
                        end
                    end
                end
            end
        end

        return true, S("Oculus successfully perforated. The sun now illuminates the transept. Blocks replaced: ") .. bloques
    end,
})

minetest.register_node("exploration_catholic_church:estacion_viacrucis", {
    description = S("Station of the Cross"),
    drawtype = "signlike",
    tiles = {"vaticano_viacrucis.png"},
    inventory_image = "vaticano_viacrucis.png",
    paramtype = "light",
    paramtype2 = "wallmounted",
    sunlight_propagates = true,
    light_source = 14,
    walkable = false,
    groups = {cracky = 2, attached_node = 1, arte_sacro = 1}
})

minetest.register_chatcommand("construir_viacrucis", {
    description = S("Installs the 14 Stations of the Cross on the nave walls"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Execute /construir_nave first.") end
        
        local estaciones = 0
        local y_altura = origen.y + 2

        local posiciones_z = {15, 25, 35, 45, 55, 65, 75}

        for _, z in ipairs(posiciones_z) do
            minetest.set_node({x = origen.x - 19, y = y_altura, z = origen.z + z}, {
                name = "exploration_catholic_church:estacion_viacrucis",
                param2 = 2
            })
            minetest.set_node({x = origen.x + 19, y = y_altura, z = origen.z + z}, {
                name = "exploration_catholic_church:estacion_viacrucis",
                param2 = 3
            })
            estaciones = estaciones + 2
        end

        return true, S("Algorithm completed. ") .. estaciones .. S(" Stations of the Cross assembled without thermal impact.")
    end,
})

minetest.register_node("exploration_catholic_church:confesionario_base", {
    description = S("Built-in Confessional (Base)"),
    tiles = {
        "vaticano_madera_oscura.png", "vaticano_madera_oscura.png", 
        "vaticano_madera_oscura.png", "vaticano_madera_oscura.png", 
        "vaticano_madera_oscura.png", "vaticano_celosia.png"        
    },
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, 0.2, 0.5, 0.5, 0.5},
            {-0.5, -0.5, -0.5, -0.4, 0.5, 0.2},
            {0.4, -0.5, -0.5, 0.5, 0.5, 0.2},
        }
    },
    groups = {choppy = 2, oddly_breakable_by_hand = 2, arte_sacro = 1}
})

minetest.register_node("exploration_catholic_church:confesionario_techo", {
    description = S("Built-in Confessional (Roof)"),
    tiles = {
        "vaticano_madera_oscura.png", "vaticano_madera_oscura.png", 
        "vaticano_madera_oscura.png", "vaticano_madera_oscura.png", 
        "vaticano_madera_oscura.png", "vaticano_celosia.png"        
    },
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, 0.2, 0.5, 0.5, 0.5},
            {-0.5, -0.5, -0.5, -0.4, 0.5, 0.2},
            {0.4, -0.5, -0.5, 0.5, 0.5, 0.2},
            {-0.5, 0.4, -0.5, 0.5, 0.5, 0.2},
        }
    },
    groups = {choppy = 2, oddly_breakable_by_hand = 2, arte_sacro = 1}
})

minetest.register_chatcommand("construir_confesionarios", {
    description = S("Perforates the side walls and embeds 2-meter high confessionals"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Execute /construir_nave first.") end

        local agregados = 0
        
        for z = 20, 80, 20 do
            minetest.set_node({x = origen.x - 20, y = origen.y + 1, z = origen.z + z}, {name = "exploration_catholic_church:confesionario_base", param2 = 3})
            minetest.set_node({x = origen.x - 20, y = origen.y + 2, z = origen.z + z}, {name = "exploration_catholic_church:confesionario_techo", param2 = 3})
            
            minetest.set_node({x = origen.x + 20, y = origen.y + 1, z = origen.z + z}, {name = "exploration_catholic_church:confesionario_base", param2 = 1})
            minetest.set_node({x = origen.x + 20, y = origen.y + 2, z = origen.z + z}, {name = "exploration_catholic_church:confesionario_techo", param2 = 1})
            
            agregados = agregados + 2
        end

        return true, S("Perforation corrected. ") .. agregados .. S(" embedded confessionals facing the central aisle.")
    end,
})

minetest.register_node("exploration_catholic_church:pilar_baldaquino", {
    description = S("Solomonic Bronze Pillar"),
    tiles = {"vaticano_pilar_baldaquino.png"},
    paramtype = "light",
    light_source = 14,
    groups = {cracky = 2, stone = 1, arte_sacro = 1}
})

minetest.register_node("exploration_catholic_church:techo_baldaquino", {
    description = S("Bronze Baldachin Canopy"),
    tiles = {"vaticano_techo_baldaquino.png"},
    paramtype = "light",
    light_source = 14,
    groups = {cracky = 2, stone = 1, arte_sacro = 1}
})

minetest.register_chatcommand("construir_baldaquino", {
    description = S("Extrudes the bronze baldachin over the high altar"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Execute /construir_nave first.") end

        local cx = origen.x
        local cz = origen.z + 138
        local bloques = 0

        for _, dx in ipairs({-3, 3}) do
            for _, dz in ipairs({-3, 3}) do
                for dy = 1, 15 do
                    minetest.set_node({x = cx + dx, y = origen.y + dy, z = cz + dz}, {name = "exploration_catholic_church:pilar_baldaquino"})
                    bloques = bloques + 1
                end
            end
        end

        for dx = -4, 4 do
            for dz = -4, 4 do
                minetest.set_node({x = cx + dx, y = origen.y + 16, z = cz + dz}, {name = "exploration_catholic_church:techo_baldaquino"})
                bloques = bloques + 1
            end
        end

        for dx = -2, 2 do
            for dz = -2, 2 do
                minetest.set_node({x = cx + dx, y = origen.y + 17, z = cz + dz}, {name = "exploration_catholic_church:techo_baldaquino"})
                bloques = bloques + 1
            end
        end
        minetest.set_node({x = cx, y = origen.y + 18, z = cz}, {name = "exploration_catholic_church:techo_baldaquino"})
        
        minetest.set_node({x = cx, y = origen.y + 15, z = cz}, {name = "exploration_catholic_church:candelabro_oro"})

        return true, S("Baldachin assembled with ") .. bloques .. S(" bronze blocks over the presbytery.")
    end,
})

minetest.register_node("exploration_catholic_church:muro_cripta", {
    description = S("Dark Crypt Ashlar"),
    tiles = {"vaticano_muro_cripta.png"},
    groups = {cracky = 3, stone = 1, arte_sacro = 1}
})

minetest.register_node("exploration_catholic_church:sarcofago_marmol", {
    description = S("Marble Papal Sarcophagus"),
    tiles = {"vaticano_sarcofago.png"},
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = {
        type = "fixed",
        fixed = {-0.4, -0.5, -0.9, 0.4, 0.3, 0.9}
    },
    groups = {cracky = 2, stone = 1, arte_sacro = 1}
})

minetest.register_node("exploration_catholic_church:reja_hierro", {
    description = S("Antique Wrought Iron Grille"),
    tiles = {"vaticano_reja_forja.png"},
    drawtype = "glasslike",
    paramtype = "light",
    sunlight_propagates = true,
    use_texture_alpha = "clip",
    groups = {cracky = 2, oddly_breakable_by_hand = 2, arte_sacro = 1}
})

minetest.register_node("exploration_catholic_church:escalera_cripta", {
    description = S("Crypt Stairs"),
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
    description = S("Excavates the crypt, generates the access staircase, and positions sarcophagi"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Execute /construir_nave first.") end
        local bloques = 0
        
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

        for i = 0, 9 do
            local y_peldano = -i
            local z_peldano = 90 + i
            
            for x = -3, 3 do
                minetest.set_node({x = origen.x + x, y = origen.y + y_peldano, z = origen.z + z_peldano}, {
                    name = "exploration_catholic_church:escalera_cripta", 
                    param2 = 2 
                })
                for dy = 1, 3 do
                    minetest.set_node({x = origen.x + x, y = origen.y + y_peldano + dy, z = origen.z + z_peldano}, {name = "air"})
                end
            end
            bloques = bloques + 4
        end

        minetest.set_node({x = origen.x, y = origen.y - 9, z = origen.z + 120}, {name = "exploration_catholic_church:sarcofago_marmol", param2 = 1})
        minetest.set_node({x = origen.x, y = origen.y - 9, z = origen.z + 138}, {name = "exploration_catholic_church:sarcofago_marmol", param2 = 1})

        for x = -3, 3 do
            minetest.set_node({x = origen.x + x, y = origen.y - 9, z = origen.z + 117}, {name = "exploration_catholic_church:reja_hierro"})
            minetest.set_node({x = origen.x + x, y = origen.y - 9, z = origen.z + 123}, {name = "exploration_catholic_church:reja_hierro"})
        end
        for z = 118, 122 do
            minetest.set_node({x = origen.x - 3, y = origen.y - 9, z = origen.z + z}, {name = "exploration_catholic_church:reja_hierro"})
            minetest.set_node({x = origen.x + 3, y = origen.y - 9, z = origen.z + z}, {name = "exploration_catholic_church:reja_hierro"})
        end

        local luces = {{-7, 115}, {7, 115}, {-7, 125}, {7, 125}}
        for _, coord in ipairs(luces) do
            minetest.set_node({x = origen.x + coord[1], y = origen.y - 9, z = origen.z + coord[2]}, {name = "exploration_catholic_church:velas_voto"})
        end

        return true, S("Crypt excavated with access and reliquaries finished. Blocks processed: ") .. bloques
    end,
})

minetest.register_chatcommand("construir_capillas", {
    description = S("Hollows out the lower perimeter walls, lays foundations, and generates chapels"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Execute /construir_nave first.") end
        local bloques = 0

        for z = 10, 90 do
            local modulo_z = z % 10
            if modulo_z >= 2 and modulo_z <= 8 then
                for dx = 20, 25 do
                    for y = 0, 15 do
                        if y == 0 then
                            minetest.set_node({x = origen.x - dx, y = origen.y + y, z = origen.z + z}, {name = "exploration_catholic_church:marmol_blanco"})
                            minetest.set_node({x = origen.x + dx, y = origen.y + y, z = origen.z + z}, {name = "exploration_catholic_church:marmol_blanco"})
                        elseif dx == 25 or modulo_z == 2 or modulo_z == 8 or y == 15 then
                            minetest.set_node({x = origen.x - dx, y = origen.y + y, z = origen.z + z}, {name = "exploration_catholic_church:muro_lateral"})
                            minetest.set_node({x = origen.x + dx, y = origen.y + y, z = origen.z + z}, {name = "exploration_catholic_church:muro_lateral"})
                        else
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
        return true, S("Side chapels excavated and founded. Blocks altered: ") .. bloques
    end,
})

minetest.register_chatcommand("construir_coro", {
    description = S("Erects the second floor, side stairs, and organ on the main facade"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Execute /construir_nave first.") end
        local bloques = 0

        for x = -15, 15 do
            for z = 2, 12 do
                minetest.set_node({x = origen.x + x, y = origen.y + 15, z = origen.z + z}, {name = "exploration_catholic_church:piso_coro"})
                bloques = bloques + 1
            end
        end

        for _, x in ipairs({-14, -7, 7, 14}) do
            for y = 1, 14 do
                minetest.set_node({x = origen.x + x, y = origen.y + y, z = origen.z + 12}, {name = "exploration_catholic_church:pilar_piedra"})
                bloques = bloques + 1
            end
        end

        for i = 1, 14 do
            local y_escalera = 15 - i
            local z_escalera = 12 + i
            
            minetest.set_node({x = origen.x - 14, y = origen.y + y_escalera, z = origen.z + z_escalera}, {
                name = "exploration_catholic_church:escalera_coro",
                param2 = 2
            })
            
            minetest.set_node({x = origen.x + 14, y = origen.y + y_escalera, z = origen.z + z_escalera}, {
                name = "exploration_catholic_church:escalera_coro",
                param2 = 2
            })
            bloques = bloques + 2
        end

        for x = -6, 6 do
            for y = 16, 35 do
                minetest.set_node({x = origen.x + x, y = origen.y + y, z = origen.z + 2}, {
                    name = "exploration_catholic_church:organo_tubular",
                    param2 = 2
                })
                bloques = bloques + 1
            end
        end

        for x = -10, 10 do
            if x < -2 or x > 2 then
                minetest.set_node({x = origen.x + x, y = origen.y + 16, z = origen.z + 10}, {name = "exploration_catholic_church:banca_madera", param2 = 2})
            end
        end

        return true, S("Tribune founded, stairs, and front organ successfully assembled. Blocks: ") .. bloques
    end,
})

minetest.register_chatcommand("construir_campanario", {
    description = S("Erects the monumental bell tower, spiral stairs, floor, and interactive bell"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Execute /construir_nave first.") end
        local bloques = 0
        
        local cx = origen.x - 26
        local cz = origen.z + 5

        for dx = -4, 4 do
            for dz = -4, 4 do
                minetest.set_node({x = cx + dx, y = origen.y, z = cz + dz}, {name = "exploration_catholic_church:marmol_blanco"})
                bloques = bloques + 1
            end
        end
        
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
                            minetest.set_node(pos, {name = "exploration_catholic_church:escalera_coro", param2 = sdir})
                        elseif dz == -3 and dx > 0 and dx <= 3 then
                            minetest.set_node(pos, {name = "air"})
                        else
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
        
        minetest.set_node({x = cx, y = origen.y + 93, z = cz}, {name = "exploration_catholic_church:muro_campanario"})
        minetest.set_node({x = cx, y = origen.y + 94, z = cz}, {name = "exploration_catholic_church:muro_campanario"})
        minetest.set_node({x = cx - 1, y = origen.y + 94, z = cz}, {name = "exploration_catholic_church:muro_campanario"})
        minetest.set_node({x = cx + 1, y = origen.y + 94, z = cz}, {name = "exploration_catholic_church:muro_campanario"})
        minetest.set_node({x = cx, y = origen.y + 95, z = cz}, {name = "exploration_catholic_church:muro_campanario"})

        minetest.set_node({x = cx, y = origen.y + 75, z = cz}, {name = "exploration_catholic_church:campana_bronce"})
        for y_cad = 76, 82 do
            minetest.set_node({x = cx, y = origen.y + y_cad, z = cz}, {name = "exploration_catholic_church:cadena"})
        end

        for z_puerta = 4, 6 do
            minetest.set_node({x = origen.x - 21, y = origen.y, z = origen.z + z_puerta}, {name = "exploration_catholic_church:marmol_blanco"})
        end

        for y_puerta = 1, 3 do
            for z_puerta = 4, 6 do
                minetest.set_node({x = origen.x - 20, y = origen.y + y_puerta, z = origen.z + z_puerta}, {name = "air"})
                minetest.set_node({x = origen.x - 21, y = origen.y + y_puerta, z = origen.z + z_puerta}, {name = "air"})
                minetest.set_node({x = origen.x - 22, y = origen.y + y_puerta, z = origen.z + z_puerta}, {name = "air"})
            end
        end

        for z_puerta = 4, 6 do
            minetest.set_node({x = origen.x - 21, y = origen.y + 4, z = origen.z + z_puerta}, {name = "exploration_catholic_church:muro_lateral"})
        end
        for y_puerta = 1, 4 do
            minetest.set_node({x = origen.x - 21, y = origen.y + y_puerta, z = origen.z + 3}, {name = "exploration_catholic_church:muro_lateral"})
            minetest.set_node({x = origen.x - 21, y = origen.y + y_puerta, z = origen.z + 7}, {name = "exploration_catholic_church:muro_lateral"})
        end

        return true, S("Bell tower founded and connected to the nave. Blocks: ") .. bloques
    end,
})

minetest.register_chatcommand("construir_pulpito", {
    description = S("Erects the asymmetrical wooden pulpit in the central nave"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: Execute /construir_nave first.") end
        local bloques = 0

        local cx = origen.x - 11
        local cz = origen.z + 60

        for y = 1, 6 do
            for dx = -2, 2 do
                for dz = -2, 2 do
                    local d_sq = (dx*dx) + (dz*dz)
                    local pos = {x = cx + dx, y = origen.y + y, z = cz + dz}
                    
                    if y < 5 and d_sq <= 1 then
                        minetest.set_node(pos, {name = "exploration_catholic_church:pilar_piedra"})
                        bloques = bloques + 1
                    elseif y == 5 and d_sq <= 4 then
                        minetest.set_node(pos, {name = "exploration_catholic_church:madera_pulpito"})
                        bloques = bloques + 1
                    elseif y == 6 and d_sq > 0 and d_sq <= 4 then
                        if not (dx == 2 and dz == 0) then
                            minetest.set_node(pos, {name = "exploration_catholic_church:madera_pulpito"})
                            bloques = bloques + 1
                        end
                    end
                end
            end
        end

        for i = 1, 4 do
            local x_escalera = cx + 7 - i
            minetest.set_node({x = x_escalera, y = origen.y + i, z = cz}, {
                name = "exploration_catholic_church:escalera_coro", 
                param2 = 3
            })
            bloques = bloques + 1
        end

        for dx = -3, 3 do
            for dz = -3, 3 do
                local d_sq = (dx*dx) + (dz*dz)
                if d_sq <= 9 then
                    minetest.set_node({x = cx + dx, y = origen.y + 11, z = cz + dz}, {name = "exploration_catholic_church:tornavoz_pulpito"})
                    bloques = bloques + 1
                end
                if d_sq <= 4 then
                    minetest.set_node({x = cx + dx, y = origen.y + 12, z = cz + dz}, {name = "exploration_catholic_church:tornavoz_pulpito"})
                    bloques = bloques + 1
                end
            end
        end
        
        minetest.set_node({x = cx, y = origen.y + 13, z = cz}, {name = "exploration_catholic_church:candelabro_oro"})

        return true, S("Asymmetrical pulpit and acoustic sounding board successfully assembled. Blocks: ") .. bloques
    end,
})

minetest.register_chatcommand("exportar_basilica", {
    description = S("Compiles the finished basilica into a universal .mts binary file"),
    func = function(name, param)
        local origen = exploration_catholic_church_origen
        if not origen then return false, S("Error: The Topographic Datum is not fixed in memory.") end

        local p1 = {x = origen.x - 75, y = origen.y - 15, z = origen.z - 5}
        local p2 = {x = origen.x + 75, y = origen.y + 100, z = origen.z + 165}
        
        local ruta_archivo = minetest.get_worldpath() .. "/basilica_latina.mts"
        local exito = minetest.create_schematic(p1, p2, nil, ruta_archivo, nil)
        
        if exito then
            return true, S("Bounding Box expanded! Basilica compiled in: ") .. ruta_archivo
        else
            return false, S("Critical failure compiling the geometric schematic.")
        end
    end,
})

minetest.register_chatcommand("importar_basilica", {
    description = S("Materializes the basilica instantly from the .mts schematic"),
    func = function(name, param)
        local jugador = minetest.get_player_by_name(name)
        if not jugador then return false, S("Error: Player not found.") end
        
        local pos = jugador:get_pos()
        
        local pos_anclaje = {
            x = math.floor(pos.x) - 75,
            y = math.floor(pos.y) - 16,
            z = math.floor(pos.z) - 5
        }
        
        local ruta_mod = minetest.get_modpath("exploration_catholic_church")
        local ruta_schematic = ruta_mod .. "/schematics/basilica_latina.mts"
        
        local exito = minetest.place_schematic(pos_anclaje, ruta_schematic, "0", nil, true)
        
        if exito then
            return true, S("Structure anchored with laser precision. The basilica surrounds you.")
        else
            return false, S("Error: .mts file not found in the mod's 'schematics' folder.")
        end
    end,
})