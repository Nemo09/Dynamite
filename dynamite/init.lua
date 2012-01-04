--[[

Author: Nemo08

mod:dynamite v 0.0.4


]]--

--[ ***********************   coal dust  ***************** ]--

	minetest.register_craft({
		output = 'craft "dynamite:coal_dust" 1',
		recipe = {
			{'craft "default:coal_lump"'},
			{'craft "default:coal_lump"'},
			}
	})

	minetest.register_craftitem("dynamite:coal_dust", {
	    image = "coal_dust.png",
	    stack_max = 10,
	    dropcount = 1,
	    liquids_pointable = false,
	    on_place_on_ground = minetest.craftitem_place_item,
	})

  DYNAMITE_TABLE = {}

--[ ******************************** DYNAMITE *************************** ]]--
findeq = function (text,pattern)
	if text == pattern then
		return true
	else
		if (string.find(text, pattern) ~= nil)and(string.find(pattern, ":") ~= nil) then
			return true			
		else
			return false
		end
	end
end
print(findeq("moreores:mineral_copper",".:mineral_."))

	explode_area = function (posd, half_size, change_node_list) --[[,callback_node_list]]-- 
	       --[[
			change list format:             список имен нод, которые изменяются взрывом
				{node_name1 = node_name1x, node_name2 = node_name2x, .. }

			callback node list format:	список имен нод, при попадании на которые вызывается коллбек
				{{{node_name1, node_name2, .. }, callback_function(finded_node_pos) }, ..}
		]]--

		minetest.env:remove_node(posd)
				
		local rnd = 35

		for x = -half_size, half_size do
		for y = -half_size, half_size do
		for z = -half_size, half_size do

			dynpos = {x = posd.x+x,y = posd.y+y,z = posd.z+z}
			target_node = minetest.env:get_node(dynpos)
		
			local explode_this = true

				--check explosible а не динамит ли тут?
			for i, i_state in pairs(DYNAMITE_TABLE) do
				if (target_node.name == i)or(target_node.name == (i .. "_fired")) then
					minetest.env:add_node(dynpos, {name= (i .. "_fired")})
					explode_this = false    -- we not explose
					break
				end
			end

				--check change
			if change_node_list ~= nil then
				for i, i_state in pairs(change_node_list) do
					if i_state == '*' then
						i_state = i
					end
					
					print(target_node.name .. " -- " .. i .. " -- ") print( findeq(target_node.name,i))
					if findeq(target_node.name,i) then

					    if (string.match(i_state,"craft",1,true) ~= nil) then
						minetest.env:add_item(dynpos, i_state)
						explode_this = false    -- we not explose
					    else
						minetest.env:add_node(dynpos, {name= (i_state)})
						explode_this = false    -- we not explose
						break
					    end
					end
			

					if (i == "*") or (i_state == "") then
						explode_this = true;	
					end

				end
				end
				
				--[[			не убирать!!!!!!	
				--check callback
				if callback_node_list ~= nil then
				for i, i_state in ipairs(callback_node_list) do
					if table.getn(i_state) ~= 0 then
					for j, j_state in ipairs(i_state) do
						local callb_func = j_state
						if table.getn(j_state) ~= 0 then
						for k, k_state in ipairs(j_state) do
							if target_node.name == k_state then
								callb_func(dynpos)	--find callback
							end
						end
						end
					end
					end
				end
				end
				]]--
				
				if target_node.name == "default:tree" then
					local rnd_base = 0.04 + half_size * 0.01
					for i = 1, 4 do
					  wood_pos = {	x=(dynpos.x + (rnd_base/2)-(math.random(1,100)*rnd_base)), 
							y=(dynpos.y + (rnd_base/2) - (math.random(1,100)*rnd_base)), 
							z=(dynpos.z + (rnd_base/2) -(math.random(1,100)*rnd_base))}
						target_wood_node = minetest.env:get_node(wood_pos)
						if target_wood_node.name == "air" then 
							if (math.random(1,100) < 40) then
								minetest.env:add_item(wood_pos, 'craft "default:stick" 1')
							else
								minetest.env:add_item(wood_pos, 'craft "moarcraft:ash" 1')
							end
						end
					end
					explode_this = true
				end

			if (explode_this)or(target_node.name == "air") then
					minetest.env:remove_node(dynpos)
					local rnd = math.random(1,100)
					if rnd < 35 then 
						minetest.env:add_node(dynpos, {name="nparticle:fire_cloud1"})
					end				
				end

		end
		end
		end
	end


	register_dynamite = function (dyn_node_name, dyn_image, dyn_image_fired, explode_cube_half_size, dyn_interval, dyn_chance, dyn_lightness, dyn_craft_recipe,
				      change_node_list,callback_node_list)
		
		DYNAMITE_TABLE["dynamite:dyn_" .. dyn_node_name] = tostring(explode_cube_half_size)
	
		minetest.register_abm({
			nodenames 	= {"dynamite:dyn_" .. dyn_node_name .. "_fired"},
			interval 	= dyn_interval,
			chanse		= dyn_chance,
			action 		= function(pos, node, _, __)							
						explode_area(pos, explode_cube_half_size,change_node_list,callback_node_list)
					  end
		})
	

		minetest.register_node("dynamite:dyn_" .. dyn_node_name , {
			drawtype = "plantlike",
       			tile_images = {dyn_image},
			inventory_image = dyn_image,
			paramtype = "light",
			is_ground_content = true,
			walkable = false,
			sunlight_propagates = true,
			--light_source = dyn_lightness,
			material = minetest.digprop_constanttime(0.4),
       			dug_item = 'craft "dynamite:dyn_' .. dyn_node_name .. '_craft" 1',
		})

		minetest.register_node("dynamite:dyn_" .. dyn_node_name .. "_fired", {
			drawtype = "plantlike",
       			tile_images = {dyn_image_fired},
			inventory_image = dyn_image,
			paramtype = "light",
			is_ground_content = true,
			walkable = false,
			sunlight_propagates = true,
			light_source = dyn_lightness,
			material = minetest.digprop_constanttime(0.4),
       			dug_item = 'craft "dynamite:dyn_' .. dyn_node_name .. '_craft" 1',
		})  


		minetest.register_craft({
			output = 'craft "dynamite:dyn_' .. dyn_node_name .. '_craft" 1',
			recipe = dyn_craft_recipe,
		})
	
		minetest.register_craftitem("dynamite:dyn_" .. dyn_node_name .. "_craft", {
		    image = dyn_image,
		    stack_max = 10,
		    usable = true,
		    dropcount = 1,
		    liquids_pointable = false,
	
		    on_place_on_ground = function (item, placer, pos)
			minetest.env:add_node(pos, {name="dynamite:dyn_" .. dyn_node_name})
		        return true	
		    end,

		    on_use = function(item, player, pointed_thing)
			if pointed_thing.type == "node" then		
				minetest.env:add_node(pointed_thing.above, {name="dynamite:dyn_" .. dyn_node_name .. "_fired"})
				return true	
			end
	
		        return false
		    end,

		})
		return true
	end

--	function register_dynamite (dyn_node_name, dyn_image, dyn_image_fired, explode_cube_half_size, dyn_interval, dyn_chance, dyn_lightness, dyn_craft_recipe)
	
	local nnn = register_dynamite("small","dynamite_small.png","dynamite_small_fired.png", 2, 5, 0.8, 8,
					{{'node "default:papyrus"','craft "dynamite:coal_dust"','node "default:papyrus"'}},
					{["default:stone"] = "default:gravel",["default:sand"] = "*", ["moreores:mineral_*"] = "*"})

	local nnn = register_dynamite("normal","dynamite.png","dynamite_fired.png", 3, 5, 0.8, 10,
					{{'node "default:papyrus"','craft "dynamite:coal_dust"','node "default:papyrus"'},
					 {'node "default:papyrus"','craft "dynamite:coal_dust"','node "default:papyrus"'}},
	  	 			{["default:stone"] = "default:gravel",["default:sand"] = "*", ["moreores:mineral_*"] = "*"})
	
	local nnn = register_dynamite("big","dynamite_big.png","dynamite_big_fired.png", 4, 5, 0.8, 12,
					{{'node "default:papyrus"','craft "dynamite:coal_dust"','node "default:papyrus"'},
					 {'node "default:papyrus"','craft "dynamite:coal_dust"','node "default:papyrus"'},
					 {'node "default:papyrus"','craft "dynamite:coal_dust"','node "default:papyrus"'}},
	  	 			{["*"] = ""})

-------------------------------------------------------------------------------------------

	minetest.register_craft({
		output = 'craft "dynamite:woods" 1',
		recipe = {{'craft "default:stick"','craft "default:stick"','craft "default:stick"'}},
	})

	minetest.register_craftitem("dynamite:woods", {
	    image = "woods.png",
	    stack_max = 10,
	    dropcount = 1,
	    liquids_pointable = false,
	    on_place_on_ground = function (item, placer, pos)
		minetest.env:add_node(pos, {name="dynamite:fire1"})
		target_node = minetest.env:get_node({x=pos.x,y=pos.y-1,z=pos.z})
		if (target_node.name == "default:dirt_with_grass") then
			minetest.env:add_node({x=pos.x,y=pos.y-1,z=pos.z}, {name="default:dirt"})
		end
	        return true	
	    end,
	})

	for i = 1,3 do
		minetest.register_node("dynamite:fire" .. tostring(i), {
			drawtype = "plantlike",
			tile_images = {"fire" .. tostring(i) .. ".png"},
			paramtype = "light",
			is_ground_content = true,
			walkable = false,
			sunlight_propagates = true,
			light_source = dyn_lightness,
			damage_per_second = 1*2,
			alpha = 150,
			light_source = 15,
			post_effect_color = {a=192, r=255, g=64, b=0},
		})
	
		minetest.register_abm({
			nodenames 	= {"dynamite:fire".. tostring(i)},
			interval 	= 1,
			chanse		= 1,
			action 		= function(pos, node, _, __)							
					if i ~= 3 then
						minetest.env:add_node(pos, {name= ("dynamite:fire".. tostring(i+1))})
					else
						minetest.env:add_node(pos, {name= ("dynamite:fire1")})
					end
					local rnd = math.random(1,100)
					if rnd < 45 then 
						local dynpos = {x=pos.x,y=pos.y+2,z=pos.z}
						minetest.env:add_node(dynpos, {name= ("nparticle:smoke_cloud3")})
					end
				  end
		})
	end

print("[Dynamite] Loaded!")


