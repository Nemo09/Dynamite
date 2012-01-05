--[[

Author: Nemo08

mod: nparticle v 0.0.1

]]--
	math.randomseed(os.time())

	add_entity_chk = function (pos, name)
		local objs = minetest.env:get_objects_inside_radius(pos,0)
		local find_ent = false

		if (# objs)~=0 then
			for k, obj in pairs(objs) do
			
				if (obj:get_entity_name() ~= nil) then
					find_ent = true
				end
			end
		end
		if fint_ent == false then
			minetest.env:add_entity(pos,name)
		end
		return not (find_ent)
	end


--[ ************************************* FIRE2 ***************************************]--

	minetest.register_node("nparticle:lpoint", {
        	tile_images = {"lpoint.png"},
		paramtype = "light",
		walkable = false,
		pointable = false,
		diggable = false,
		drawtype="plantlike",
		buildable_to = false,
		sunlight_propagates = true,
		light_source = 15,
		damage_per_second = 2*2,
		post_effect_color = {a=192, r=255, g=64, b=0},
	})

	minetest.register_abm({
		nodenames 	= {"nparticle:lpoint"},
		interval 	= 6 ,
		chanse		= 1  ,
		action 		= function(pos, node, _, __)
			minetest.env:remove_node(pos)
		end
	})

	FIRE_ENT_MOVE_CUBE = 1    --пределы распространения
	FIRE_ENT_MOVE_CHANSE = 5  --шанс переместиться [1..100]

	local fire_ent_table = {}

 
	for i=1,3 do

		fire_ent_table['fire' .. i ..'_entity'] = {
			physical = false,
			textures = {"fire_cloud_" .. i .. ".png"},
			lastpos={},
			timer = 0,
			full_timer = 0,
			my_num = i,
			my_tik = math.random(1,10),
		}

		fire_ent_table['fire' .. i ..'_entity'].on_step = function(self, dtime)
			self.timer = self.timer + dtime
			self.full_timer = self.full_timer + dtime

			if self.timer >= math.random(3,7) then
				self.timer = 0
				local pos = self.object:getpos()
				for x = -FIRE_ENT_MOVE_CUBE, FIRE_ENT_MOVE_CUBE do
				for y = -FIRE_ENT_MOVE_CUBE, FIRE_ENT_MOVE_CUBE do
				for z = -FIRE_ENT_MOVE_CUBE, FIRE_ENT_MOVE_CUBE do
					local dynpos 	= {x = pos.x+x,y = pos.y+y,z = pos.z+z}
					local targetnode = minetest.env:get_node(dynpos)

					if ((targetnode.name == "air") and (math.random(1,100) < FIRE_ENT_MOVE_CHANSE))	then 
						if self.my_num<2 then
							minetest.env:add_entity(dynpos,'nparticle:fire' .. (self.my_num+1) ..'_entity')
							minetest.env:add_node(dynpos,{name='nparticle:lpoint'})
						end

						self.object:remove()
						minetest.env:remove_node(pos)	
						nodeupdate(pos)

						if (math.random(1,100) < 15) then
							minetest.env:add_entity(dynpos,'nparticle:dust_cloud3_entity')
						end
					end
				end
				end
				end

				nodeupdate(pos)

			end
			if self.full_timer >=20 then
				self.object:remove()
				minetest.env:remove_node(self.object:getpos())					
			end
		end

		minetest.register_entity("nparticle:fire" .. i .. "_entity", fire_ent_table['fire' .. i ..'_entity'])
	end

--[ ************************************* SMOKE2 ************************************]--

	SMOKE_ENT_MOVE_CUBE = 1    --пределы распространения
	SMOKE_ENT_BREAK_CHANSE = 80  -- [1..100]  шанс частицы "разлететься"
	SMOKE_ENT_MOVE_NODE_CHANSE = 60  -- [1..100]  шанс разлетевшейся частицы попасть в конкретную ячейку

	local smoke_ent_table = {}

	for i=0,4 do
		smoke_ent_table['smoke_cloud' .. i ..'_entity'] = {
			physical = false,
			textures = {"smoke" .. i .. ".png"},
			lastpos={},
			collisionbox = {0,0,0,0,0,0},
			timer = 0,
			full_timer = 0,
		}
		smoke_ent_table['smoke_cloud' .. i ..'_entity'].on_step = function(self, dtime)
			self.timer = self.timer + dtime
			self.full_timer = self.full_timer + dtime

			while self.timer >= 2.5 do
				self.timer = 0
				local pos = self.object:getpos()
				local this_node = minetest.env:get_node(pos)
				local kp = i
				local rand_break = math.random(1,100)
					
					if rand_break <= SMOKE_ENT_BREAK_CHANSE then
						for x = -SMOKE_ENT_MOVE_CUBE,SMOKE_ENT_MOVE_CUBE do
						for y = 0,SMOKE_ENT_MOVE_CUBE do
						for z = -SMOKE_ENT_MOVE_CUBE,SMOKE_ENT_MOVE_CUBE do
							local rand_move = math.random(1,100-y*15)
							if rand_move <= SMOKE_ENT_MOVE_NODE_CHANSE then
								local dynpos 	= {x = pos.x+x,y = pos.y+y,z = pos.z+z}
								local targetnode = minetest.env:get_node(dynpos)
								local rand = math.random(1,100)							
								if (targetnode.name == "air")and  ((kp-1) >1)and(rand<20) then
										add_entity_chk(dynpos,'nparticle:smoke_cloud' .. (i-1) ..'_entity')
								end
								local rand = math.random(1,100)
								if rand<15 then
									self.object:remove()
								end
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
								local dynpos = pos	
							end
						end
	
						if (kp>0) then
							local rand_break = math.random(1,100)
							if rand_break < 15 then
								--minetest.env:add_node(dynpos, {name="nparticle:smoke_cloud" .. tostring(k-1)})
								add_entity_chk(dynpos,'nparticle:smoke_cloud' .. (i-1) ..'_entity')	
							else
								add_entity_chk(dynpos,'nparticle:smoke_cloud' .. i ..'_entity')
							end
						end
						local rand = math.random(1,100)
						if rand<15 then
							self.object:remove()
						end
					end
			end	
			if self.full_timer>15 then
				self.object:remove()
			end
		end

		minetest.register_entity("nparticle:smoke_cloud" .. i .. "_entity", smoke_ent_table['smoke_cloud' .. i ..'_entity'])
	end

--[ ************************************* DUST2 ************************************]--
	DUST_ENT_MOVE_CUBE = 2    --пределы распространения
	DUST_ENT_BREAK_CHANSE = 10 -- [1..100]  шанс частицы "разлететься"
	DUST_ENT_MOVE_NODE_CHANSE = 5  -- [1..100]  шанс разлетевшейся частицы попасть в конкретную ячейку

	local dust_ent_table = {}

	for i=0,4 do

		dust_ent_table['dust_cloud' .. i ..'_entity'] = {
			physical = false,
			textures = {"dust" .. i .. ".png"},
			lastpos={},
			collisionbox = {0,0,0,0,0,0},
			timer = 0,
			full_timer = 0,
			my_num = i,
		}

		dust_ent_table['dust_cloud' .. i ..'_entity'].on_step = function(self, dtime)
			self.timer = self.timer + dtime
			self.full_timer = self.full_timer + dtime

			if self.timer >= math.random(2,6) then
				self.timer = 0
				local pos = self.object:getpos()
				local rand_move = math.random(1,100)
				local this_node = minetest.env:get_node(pos)
					
				if rand_move <= DUST_ENT_BREAK_CHANSE then
					
					for x = -DUST_ENT_MOVE_CUBE,DUST_ENT_MOVE_CUBE do
					for y = -DUST_ENT_MOVE_CUBE,DUST_ENT_MOVE_CUBE do
					for z = -DUST_ENT_MOVE_CUBE,DUST_ENT_MOVE_CUBE do
					
						if (math.random(1,100)+y*20) <= DUST_ENT_MOVE_NODE_CHANSE then --пыль оседает
							local dynpos 	= {x = pos.x+x,y = pos.y+y,z = pos.z+z}
							local targetnode = minetest.env:get_node(dynpos)			
	
							if (targetnode.name == "air") and (self.my_num > 1) then
								minetest.env:add_entity(dynpos,'nparticle:dust_cloud' .. (self.my_num-1) ..'_entity')
							end
						end
					end
					end
					end
				
					self.object:remove()					
				end			
			end
			if self.full_timer>math.random(8,15) then
				self.object:remove()
			end
		end

		minetest.register_entity("nparticle:dust_cloud" .. i .. "_entity", dust_ent_table['dust_cloud' .. i ..'_entity'])
	end

print("[nParticles] Loaded!")	
