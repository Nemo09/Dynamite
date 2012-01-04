--[[

Author: Nemo08

mod: nparticle v 0.0.1

]]--
	math.randomseed(os.time())

--[ ************************************* FIRE************************************]--
	minetest.register_node("nparticle:fire_cloud1", {
		drawtype = "plantlike",
        	tile_images = {"fire_cloud_1.png","fire_cloud_1.png","fire_cloud_1.png","fire_cloud_1.png","fire_cloud_1.png","fire_cloud_1.png"},
		paramtype = "light",
		walkable = false,
		pointable = false,
		diggable = false,
		buildable_to = false,
		alpha = 230,		
		sunlight_propagates = true,
		light_source = 25,
		damage_per_second = 4*2,
		post_effect_color = {a=192, r=255, g=64, b=0},
	})

	minetest.register_node("nparticle:fire_cloud2", {
		drawtype = "plantlike",
        	tile_images = {"fire_cloud_2.png","fire_cloud_2.png","fire_cloud_2.png","fire_cloud_2.png","fire_cloud_2.png","fire_cloud_2.png"},
		paramtype = "light",
		walkable = false,
		pointable = false,
		diggable = false,
		buildable_to = false,
		alpha = 200,
		sunlight_propagates = true,
		light_source = 15,
		damage_per_second = 2*2,
		post_effect_color = {a=192, r=255, g=64, b=0},
	})



--[ ************************************* FIRE ABMs ***************************************]--


	FIRE1_INTERVAL 	= 5
	FIRE1_CHANSE	= 0.7
	FIRE1_MOVE_CUBE = 1    --пределы распространения
	FIRE_MOVE_CHANSE = 3  --шанс переместиться [1..100]
	FIRE_CHANGE_CHANSE = 70  --шанс потерять температуру [1..100]

	minetest.register_abm({
		nodenames 	= {"nparticle:fire_cloud1"},
		interval 	= FIRE1_INTERVAL,
		chanse		= FIRE1_CHANSE,
		action 		= function(pos, node, _, __)
						
					for x = -FIRE1_MOVE_CUBE,FIRE1_MOVE_CUBE do
					for y = -FIRE1_MOVE_CUBE,FIRE1_MOVE_CUBE do
					for z = -FIRE1_MOVE_CUBE,FIRE1_MOVE_CUBE do
						local dynpos 	= {x = pos.x+x,y = pos.y+y,z = pos.z+z}
						local targetnode = minetest.env:get_node(dynpos)
						local rand_move = math.random(1,100)
						if targetnode.type == "node" then
						if ((targetnode.name == "air")or 
						   (strfind(targetnode.name,"nparticle:dust_cloud") ~= nil) or
						   (strfind(targetnode.name,"nparticle:fire_cloud") ~= nil))and
						   (rand_move <= FIRE_MOVE_CHANSE) 
						then 
							minetest.env:add_node(dynpos,{name = "nparticle:fire_cloud2"})
						end
						end

					end
					end
					end

					local rand_change = math.random(1,100)
					if rand_change <= FIRE_CHANGE_CHANSE then
						minetest.env:add_node(pos,{name = "nparticle:fire_cloud2"})
					else
						minetest.env:remove_node(pos)
					end
				  end
	})

	minetest.register_abm({
		nodenames 	= {"nparticle:fire_cloud2"},
		interval 	= FIRE1_INTERVAL ,
		chanse		= FIRE1_CHANSE  ,
		action 		= function(pos, node, _, __)
						
					for x = -FIRE1_MOVE_CUBE,FIRE1_MOVE_CUBE do
					for y = -FIRE1_MOVE_CUBE,FIRE1_MOVE_CUBE do
					for z = -FIRE1_MOVE_CUBE,FIRE1_MOVE_CUBE do
						local dynpos 	= {x = pos.x+x,y = pos.y+y,z = pos.z+z}
						local targetnode = minetest.env:get_node(dynpos)
						local rand_move = math.random(1,100)

						if targetnode.type == "node" then
						if ((targetnode.name == "air")or 
						   (strfind(targetnode.name,"nparticle:dust_cloud") ~= nil) or
						   (strfind(targetnode.name,"nparticle:fire_cloud") ~= nil))and
						   (rand_move <= (FIRE_MOVE_CHANSE / 3)) 
						then 
							minetest.env:add_node(dynpos,{name = "nparticle:fire_cloud2"})
							minetest.env:remove_node(pos)
						end
						end

					end
					end
					end

						minetest.env:add_node(pos,{name = "nparticle:dust_cloud3"})

				  end
	})

--[ ************************************* DUST ************************************]--
	

	DUST_INTERVAL 	= 3
	DUST_CHANSE	= 0.5
	DUST_MOVE_CUBE = 2    --пределы распространения
	DUST_BREAK_CHANSE = 50  -- [1..100]  шанс частицы "разлететься"
	DUST_MOVE_NODE_CHANSE = 50  -- [1..100]  шанс разлетевшейся частицы попасть в конкретную ячейку
	DUST_DENSITY_MAX = 230  -- максимальное значение плотности пыли
	DUST_COLLAPSE = 70    -- предел плотности, после которого частица пыли исчезает
	
		
for k=0,4 do
	minetest.register_node("nparticle:dust_cloud" .. tostring(k), {
		drawtype = "glasslike",
        	tile_images = {"dust" .. tostring(k) .. ".png"},
		paramtype="light",
		walkable = false,
		pointable = false,
		diggable = false,
		buildable_to = false,
		sunlight_propagates = true,
		is_ground_content = true,
		material = minetest.digprop_glasslike(1.0),
		post_effect_color = {a=(50 + k*50), r=48, g=48, b=48},
		alpha = 50 + k*50,
		
	})



	minetest.register_abm({
		nodenames 	= {"nparticle:dust_cloud" .. tostring(k)},
		interval 	= DUST_INTERVAL ,
		chanse		= DUST_CHANSE  ,
		action 		= function(pos, node, _, __)
		
					local rand_move = math.random(1,100)
					local this_node = minetest.env:get_node(pos)
					local kp = k
					
					if rand_move <= DUST_BREAK_CHANSE then
						
						for x = -DUST_MOVE_CUBE,DUST_MOVE_CUBE do
						for y = -DUST_MOVE_CUBE,DUST_MOVE_CUBE do
						for z = -DUST_MOVE_CUBE,DUST_MOVE_CUBE do
							local rand_move = math.random(1,100)+y*20
							if rand_move <= DUST_MOVE_NODE_CHANSE then
								local dynpos 	= {x = pos.x+x,y = pos.y+y,z = pos.z+z}
								local targetnode = minetest.env:get_node(dynpos)
																									
								if (targetnode.name == "air") and  ((kp-1)>1) then
									minetest.env:add_node(dynpos, {name="nparticle:dust_cloud" .. tostring(k-1)})
								end
								
								if targetnode.type == "node" then
									if strfind(targetnode.name,"nparticle:dust_cloud")~=nil then
										local target_k = (targetnode.alpha-50)/50
										local new_k = (target_k + kp)
										if new_k >=4 then 
											minetest.env:add_node(dynpos, {name="nparticle:dust_cloud4"})
										else
											minetest.env:add_node(dynpos, {name="nparticle:dust_cloud" .. tostring(new_k)})
										end
									end
								end
							end
						end
						end
						end
							
							minetest.env:remove_node(pos)
						
					end
					
					if kp <=0 then
						minetest.env:remove_node(pos)
					end

				  end
	})
end	


--[ ************************************* SMOKE ************************************]--
	

	SMOKE_INTERVAL 	= 1
	SMOKE_CHANSE	= 0.7
	SMOKE_MOVE_CUBE = 1    --пределы распространения
	SMOKE_BREAK_CHANSE = 15  -- [1..100]  шанс частицы "разлететься"
	SMOKE_MOVE_NODE_CHANSE = 30  -- [1..100]  шанс разлетевшейся частицы попасть в конкретную ячейку
	SMOKE_COLLAPSE = 70    -- предел плотности, после которого частица пыли исчезает
	
		
for k=0,4 do
	minetest.register_node("nparticle:smoke_cloud" .. tostring(k), {
		drawtype = "plantlike",
        	tile_images = {"smoke" .. tostring(k) .. ".png"},
		paramtype="light",
		walkable = false,
		pointable = false,
		diggable = false,
		buildable_to = false,
		sunlight_propagates = true,
		is_ground_content = true,
		material = minetest.digprop_glasslike(1.0),
		post_effect_color = {a=(50 + k*50), r=255, g=255, b=255},
		alpha = 50 + k*50,
		
	})

	minetest.register_abm({
		nodenames 	= {"nparticle:smoke_cloud" .. tostring(k)},
		interval 	= SMOKE_INTERVAL ,
		chanse		= SMOKE_CHANSE  ,
		action 		= function(pos, node, _, __)
		
					local this_node = minetest.env:get_node(pos)
					local kp = k
					local rand_break = math.random(1,100)
					
					if rand_break <= SMOKE_BREAK_CHANSE then
						for x = -SMOKE_MOVE_CUBE,SMOKE_MOVE_CUBE do
						for y = 0,SMOKE_MOVE_CUBE do
						for z = -SMOKE_MOVE_CUBE,SMOKE_MOVE_CUBE do
							local rand_move = math.random(1,100-y*15)
							if rand_move <= SMOKE_MOVE_NODE_CHANSE then
								local dynpos 	= {x = pos.x+x,y = pos.y+y,z = pos.z+z}
								local targetnode = minetest.env:get_node(dynpos)
																									
								if (targetnode.name == "air")and  ((kp-1) >1) then
										minetest.env:add_node(dynpos, {name="nparticle:smoke_cloud" .. tostring(k-1)})
								end
								minetest.env:remove_node(pos)
							end							
						end
						end
						end
					else
						local dynpos 	= {x = pos.x,y = pos.y+1,z = pos.z}
						local targetnode = minetest.env:get_node(dynpos)
						if (targetnode.name ~= "air") then
							dynpos 	= {x = (pos.x+math.random(-1,1)),y = pos.y,z = (pos.z+math.random(-1,1))}
							local targetnode = minetest.env:get_node(dynpos)
							if (targetnode.name ~= "air") then
								local dynpos 	= pos	
							end
						end
	
						if (kp>0) then
							local rand_break = math.random(1,100)
							if rand_break < 15 then
								minetest.env:add_node(dynpos, {name="nparticle:smoke_cloud" .. tostring(k-1)})
							else
								minetest.env:add_node(dynpos, {name="nparticle:smoke_cloud" .. tostring(k)})
							end
						end
						minetest.env:remove_node(pos)
					end
					
				  end
	})
end		

print("[nParticles] Loaded!")	
