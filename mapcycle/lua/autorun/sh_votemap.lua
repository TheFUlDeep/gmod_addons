AddCSLuaFile("autorun/sh_votemap.lua")
AVMS = {}
function AVMS.timeToStr( time )
	local tmp = time
	local s = tmp % 60
	tmp = math.floor( tmp / 60 )
	local m = tmp % 60
	tmp = math.floor( tmp / 60 )
	local h = tmp % 24
	tmp = math.floor( tmp / 24 )
	local d = tmp
	if d > 0 then
		return string.format( "%id %02ih %02im", d, h, m )
	elseif h > 0 then
		return string.format( "%02ih %02imin", h, m )
	elseif m > 0 then
		return string.format( "%02imin %02isec", m,s )
	else
		return string.format( "%01i seconds", s )
	end
end

if CLIENT then
	include("cl_automapvote.lua")
elseif SERVER then
	AddCSLuaFile("cl_automapvote.lua")
	include("sv_automapvote.lua")
end