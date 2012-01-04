--[[

Author: Nemo08

mod: wikimod v 0.0.1

]]--

local mods_path = string.gsub(minetest.get_modpath('default'),'default','') .. '/'

local wikimod_path = minetest.get_modpath('wikimod') .. '/'
local wiki_page_path = minetest.get_modpath('wikimod') .. '/'



print("[Wikimod] Loaded!")


--[[***********************************]]--




function printtbl( t,tab,lookup )
	local lookup = lookup or { [t] = 1 }
	local tab = tab or ""
	for i,v in pairs( t ) do
		print( tab..tostring(i), v )
		if type(i) == "table" and not lookup[i] then
			lookup[i] = 1
			print( tab.."Table: i" )
			printtbl( i,tab.."\t",lookup )
		end
		if type(v) == "table" and not lookup[v] then
			lookup[v] = 1
			print( tab.."Table: v" )
			printtbl( v,tab.."\t",lookup )
		end
	end
end



---------------------------------------------------------------------------

--[[**********************************************************]]--
local file_pat = assert(io.open(wikimod_path .. '/' .. "wiki_pattern.html", "r"))
local file_pat_content = file_pat:read("*all")
file_pat:close(file)
local mcontent = {}
local content = {}
--[[ html header]]--

local html_header = '<html><head>' ..
'<meta http-equiv="content-type" content="text/html; charset=utf-8" />' ..
'<link rel="stylesheet" href="style.css" type="text/css" /></head>' ..
'<script type="text/javascript" src="jquery-1.7.1.min.js"></script>' ..
'<body> <div id="container"><div id="nav"><ul>'

--file:write(html_header)

--[[ /html header]]--
function pairsByKeys (t, f)
    local a = {}
    for n in pairs(t) do
        table.insert(a, n)
    end
    table.sort(a, f)
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then
                return nil
        else
                return a[i], t[a[i]]
        end
    end
    return iter
end
SortFunc = function (myTable)
    local t = {}
    for title,value in pairsByKeys(myTable) do
        table.insert(t, { title = title, value = value })
    end
myTable = t
    return myTable
end

setunknown = function (myTable)
    local t = {}
    for title,value in pairsByKeys(myTable) do
	local delpos = string.find(title,':')
	if delpos == nil then
		t["unknown:" .. title] = value
	else
		t[title] = value
	end
    end
myTable = t
    return myTable
end


get_all_nodes = function ()
	local nodetable = minetest.registered_nodes
	local prevmod=''
	local mod=''
	local nodename=''
	--nodetable = SortFunc(nodetable)

	nodetable = setunknown(nodetable)
	nodetable = SortFunc(nodetable)

	for i, pair in pairs(nodetable) do
		--print ("---------------------------------------------------------------------")
		print(">>> " .. i .. " ")
		--print(nodetable[i].title)
		mod = string.sub(nodetable[i].title,1,string.find(nodetable[i].title,':')-1)
		nodename = string.sub(nodetable[i].title,string.find(nodetable[i].title,':')+1,-1)
		if prevmod ~= mod then 
			prevmod = mod 
			mcontent[mod] = '\n<div id="menuentry" modname="' .. mod .. '"  vis="false" >' .. mod .. '</div>' ..
					'<div itype="allnodes" vis="false" modname="' .. mod .. '" class="sub" >All nodes </div>' ..
					'<div itype="allcrafts" vis="false" modname="' .. mod .. '" class="sub" >All craft </div>' .. 
					'<div itype="alltools" vis="false" modname="' .. mod .. '" class="sub" >All tools </div>'
			mcontent[mod] = mcontent[mod] .. '<div itype="node" vis="false" modname="' .. mod .. '" class="sub" name="' .. nodename .. '">' .. nodename .. ' </div>'
			content[nodetable[i].title] = '<div itype="node"  modname="' .. mod .. '"  class="msub" vis="false" name="' .. nodename .. '">' 
					.. nodename .. '<img src="' .. mods_path .. mod .. "/textures/" .. nodetable[i].value["tile_images"][1] .. '"> </div>'
			prevmod = mod
		else
			local res =''
			for j, jpair in pairs(nodetable[i].value["__index"]) do
				if (tostring(j) ~= "__index") then
				if (type(jpair) ~= "table") then
					res = res .. tostring(j) .. " = " .. tostring(nodetable[i].value[j]) .. "<br/><br/>"
				else	
					res = res .. tostring(j) .. " = {" .. "<br/>"
					for k, kpair in pairs(nodetable[i].value[j]) do
						res = res .. tostring(k) .. " = " .. tostring(kpair) .. "<br/>"
					end
					res = res .. "}".. "<br/>"
				end
				end
			end
			mcontent[mod] = mcontent[mod] .. '<div itype="node" vis="false" modname="' .. mod .. '" class="sub" name="' .. nodename .. '">' .. nodename .. ' </div>'
			content[nodetable[i].title] = '<div itype="node"  modname="' .. mod .. '"  class="msub" vis="false" name="' .. nodename .. '">' .. nodename 
			.. "<div class='param'>" .. res .. "</div>"
			.. ' </div>'
				
			--print(printtbl(nodetable[i].value))
			print('---------------------------------------------')
			--print((nodetable[i].value['drawtype']))

			print('---------------------------------------------')
			--print(table.tostring(nodetable[i].value))
		end
		--print(mod .. "----" .. nodename)
		
		
		--printtbl(pair)
		--print(splittbl(pair))

	end
end

get_all_nodes()

--file:write("</ul></div>")
--file:write("</div></div></body></html>")

local file = assert(io.open(wiki_page_path  .. "wiki.html", "w"))
local all_mcont ='';
local all_cont ='';
for i, pair in pairs(mcontent) do
	all_mcont = all_mcont .. '\n' .. pair
end
for i, pair in pairs(content) do
	all_cont = all_cont .. '\n' .. pair
end
print("mmmmmmm " .. string.find(file_pat_content,'MENUCONTENT'))
file_pat_content = string.gsub(file_pat_content,"MENUCONTENT",all_mcont)
file_pat_content = string.gsub(file_pat_content,'MAINCONTENT',all_cont)
print(wiki_page_path  .. "wiki.html")
file:write(file_pat_content)
file:close(file)

