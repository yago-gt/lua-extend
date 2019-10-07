---------------------------------------------------set random seed----------------------------------------------------------

math.randomseed(os.clock()^-4)

----------------------------------------------extend table funtionality---------------------------------------------------

function clone(orig)
	if type(orig) == "table" then
		return table.clone(orig)
	else
		return orig
	end
end

function table.minn(tbl)
	local min = #tbl
	for i, _ in pairs(tbl) do
		if i < min then min = i end
	end
	return min
end 

function table.clone(orig)
	local copy = {}
		for orig_key, orig_value in pairs(orig) do
			copy[orig_key] = orig_value
		end
	return setmetatable(copy, getmetatable(orig))
end

-- Save copied tables in `copies`, indexed by original table.
function table.copy(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            setmetatable(copy, table.copy(getmetatable(orig), copies))
            for orig_key, orig_value in next, orig, nil do
                copy[table.copy(orig_key, copies)] = table.copy(orig_value, copies)
            end
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function table.generate(size, val)
    val = val or 0
    local new_tbl = {}
    for i = 1, size do
        new_tbl[i] = val
    end
    return new_tbl
end

function table.random(size, min, max)
	local new_tbl = {}
	if min == nil then
		for i = 1, size do
			new_tbl[i] = math.random()
		end
	elseif max == nil then
		for i = 1, size do
			new_tbl[i] = math.random(min)
		end
	else
		for i = 1, size do
			new_tbl[i] = math.random(min, max)
		end
	end
		return new_tbl
end

function table.print(tbl)
	for k, v in pairs(tbl) do
		print("["..k.."] = "..tostring(v))
	end
end

function table.iprint(tbl)
	for i, v in ipairs(tbl) do
		print("["..i.."] = "..tostring(v))
	end
end

----------------------------------------------extend strings funtionality---------------------------------------------------

function string.change(str, pos, char)
	return str:sub(1, pos-1) .. char .. str:sub(pos+1)
end

function string.replace(str, pos, rep_str)
	return str:sub(1, pos) .. rep_str .. str:sub(pos+1+#rep_str)
end

function string.insert(str, pos, ins_str)
	return str:sub(1, pos) .. ins_str .. str:sub(pos+1)
end

-------------------------------------------------extend math funtionality---------------------------------------------------

function math.sign(x)
    if x < 0 then return -1
	else return 1 end
end

-------------------------------------------------------class----------------------------------------------------------------

class = { __type = "object"}
class.__index = class

-- constructor with the name of the class
function class:__call(...) -- this will call a function with just it's name
    local instance = setmetatable({}, self)
    instance:new(...)
    return instance
end

-- constructor new
function class:new() end

-- create a new class for inheritance
function class:derive(type)
    local subclass = {}
    subclass.__type = type
	subclass.__index = subclass
	subclass.__call = self.__call
    subclass.super = self
    setmetatable(subclass, self)
	return subclass 
end

-- get the type of the class
function classtype(var)
	return var.__type
end

--------------------------------------------------------const---------------------------------------------------------------

function const(consttable)
    return setmetatable({__ = consttable}, {
		__index = function (tbl, key)
					  return clone(tbl.__[key])
				  end,
    	__newindex = function(tbl, key, value)
                        error("Attempt to write the const "..key.." value of "..value)
					  end,
        __metatable = false
    })
end

---------------------------------------------------------enum---------------------------------------------------------------
-- https://github.com/sulai/Lib-Pico8/blob/master/lang.lua
function enum(names, offset)
	offset = offset or 1
	local objects = {}
	local size = 0
	for idr,name in pairs(names) do
		local id = idr + offset - 1
		local obj = {
			id = id,       -- id
			idr = idr,     -- 1-based relative id, without offset being added
			name = name    -- name of the object
		}
		objects[name] = obj
		objects[id] = obj
		size = size + 1
	end
	objects.idstart = offset        -- start of the id range being used
	objects.idend = offset + size - 1   -- end of the id range being used
	objects.size = size
	objects.all = function()
		local list = {}
		for _,name in pairs(names) do
			add(list,objects[name])
		end
		local i = 0
		return function() i = i + 1 if i <= #list then return list[i] end end
	end
	return objects
end

----------------------------------------------------------------------------------------------------------------------------
