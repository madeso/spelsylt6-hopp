pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
-- main

-- abbreviations
-- pl = player
-- sp = sprite index
-- flp = flip

function _init()
	dbg = "init"
	_lastt = time()
	pl = {
		sp=1,
		x=59,
		y=59,
		w=8,
		h=8,
		flp=false,
		dx=0,
		dy=0,
		max_dx=2,
		max_dy=3,
		acc=0.5,
		jump=3,
		anim=0, --time
		animi=0, -- index in frame
		
		srun=false,
		sjump=false,
		sfall=false,
		sslid=false,
		sland=false
	}
	gravity=0.3
	friction=0.85
end

-->8
-- update and draw

function _update()
	local t=time()
	dt=t - _lastt
	_lastt=t
	player_update()
	player_animate()
end

function _draw()
	cls()
	map(0, 0)
	local o=0
	if pl.srun and pl.sp%2==1 then
		o=-1
	end
	spr(pl.sp, pl.x, pl.y+o,1,1,pl.flp)
	print(dbg, 0, 0)
end
-->8
-- collision

-- flag 0: stand on
-- flag 1: unable to jump thru

-- object to collide with
--  needs x,y,w,h
-- aim movement dir, numpad val
-- flag to check for
function map_col(o,aim,f)
	local x=o.x local y=o.y
	local w=o.w local h=o.h

	-- x1y1 top left
	-- x2y2 bottom right	
	local x1=0 local y1=0
	local x2=0 local y2=0
	
	if aim==4 then
		x1=x-1   y1=y
		x2=x     y2=y+h-1
	elseif aim==6 then
		x1=x+w   y1=y
		x2=x+w+1 y2=y+h-1
	elseif aim==8 then
		x1=x+1   y1=y-1
		x2=x+w-1 y2=y
	elseif aim==2 then
		x1=x     y1=y+h
		x2=x+w   y2=y+h
	end
	
	-- convert pix to tile
	x1/=8 y1/=8
	x2/=8 y2/=8
	
	-- fget - get flag of tile
	-- mget - get map tile
	if fget(mget(x1,y1), f)
	or fget(mget(x1,y2), f)
	or fget(mget(x2,y1), f)
	or fget(mget(x2,y2), f) then
		return true
	else
		return false
	end
	
end

-->8
-- player

function player_update()
	pl.dy += gravity
	pl.dx *= friction
	
	if btn(⬅️) then
	 pl.dx -= pl.acc
	 pl.srun = true
	 pl.flp = true
	end
	if btn(➡️) then
	 pl.dx += pl.acc
	 pl.srun = true
	 pl.flp = false
	end
	
	-- handle sliding(move no inp)
	if pl.srun
	and not btn(⬅️)
	and not btn(➡️)
	and not pl.sfall
	and not pl.sjump then
		pl.srun = false
		pl.sslid = true
	end
	
	-- jumping x
	if btnp(❎) and
	pl.sland then
		pl.dy = -pl.jump
		pl.sland = false
	end
	
	-- vertical collision
	if pl.dy > 0 then
		pl.sfall = true
		pl.sland = false
		pl.sjump = false
		dbg = "fall"
		pl.dy = lim(pl.dy, pl.max_dy)
		if map_col(pl, 2, 0) then
			pl.sland = true
			pl.sfall = false
			pl.dy=0
			pl.y -= (pl.y+pl.h)%8
			dbg = "c"
		end
	elseif pl.dy < 0 then
		pl.sjump = true
		if map_col(pl, 8, 1) then
			pl.dy = 0
		end
	end
	
	-- horizontal collision
	if pl.dx < 0 then
		dbg="le"
		if map_col(pl, 4, 1) then
			pl.dx = 0
		end
	elseif pl.dx > 0 then
		dbg="ri"
		if map_col(pl, 6, 1) then
			pl.dx = 0
		end
	end
	
	-- stop sliding
	if pl.sslid then
		if abs(pl.dx)<.2
		or pl.srun then
			pl.dx=0
			pl.sslid = false
		end
	end
	
	pl.dx = lim(pl.dx, pl.max_dx)
	
	pl.x += pl.dx
	pl.y += pl.dy
end

function player_animate()
	if pl.sjump then
		pl.sp = 3
		pl.anim = 0
	elseif pl.sfall then
		pl.sp = 3
		pl.anim = 0
	elseif pl.sslid then
		pl.sp = 5
		pl.anim = 0
	elseif pl.srun then
		anim(pl, {1, 3, 1, 4}, .1)
	else
		anim(pl, {1, 2}, .5)
	end
end
-->8
-- utils

function anim(o, fr, step)		
		o.anim -= dt
		if o.anim < 0 then
			o.anim += step
			o.animi += 1
		end
		o.animi %= #fr
		o.sp = fr[o.animi+1]
end

function lim(n, l)
	return mid(-l, n, l)
end
__gfx__
00000000000060600000000000060600000606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000060600000606000006060000060600000606000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000066660000606000006666000066660000606000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000770060667700666600006066770060667700666600000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000770066667700606677006666770066667700606600000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700066660000666666677666000066660000666666600000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000066660000666600006666000066660000666600000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000060060000600600060000600006600000060060000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000000000bbbbbbbbbbbb000000000000bbbb0000000000000000000000000000000000000000000000000000000000
bbbbbbbbb3bb3bbbbbbb3bbbbbb33bbb000000000bbbbbbbbbbbbbb0000000000bbbbbb000000000000000000000000000000000000000000000000000000000
3bb33bb3343b3b333bb343b33b3443b300000000bbbb33333333bbbb00000000bb3333bb00000000000000000000000000000000000000000000000000000000
3b3443b334434b3443bb3b3443b343b400000000bbb3444444443bbb00000000b344443b00000000000000000000000000000000000000000000000000000000
43b343b3444443b44433b3444434443400000000bbb34444442443bb00000000b342443b00000000000000000000000000000000000000000000000000000000
44344434443444344444344444444d4400000000bb3444d4444443bb00000000b344443b00000000000000000b0000b00000b00000000000000b0b0000000000
4244d444444442444d4442444244d44400000000b34244444444d43b00000000b344d4430000000000b0b00000b00b0000b0b0b00b0b0b0000b0bb0000000000
4444444444d4444444444444444444440000000034d4444444444443000000003444444300000000000bb000000bbbb00bbbbbbb00bbb000000bb00000000000
44444444444444444444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444444444344444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444d4644444644444b4444444444744000000000000000000000000000000000000000000000000000000000000000000000000000000000007007000000000
44444444464444b444444b4444444774000000000000000000000000000000000000000000000000000000000000000000005500000070000000aa0000000000
443444444444444444444464444476440000000000000000000000000000000000000000000000000005500000000000005555500007a7000000aa0000000000
44444b444444d4444566444444776444000000000000000000000000000000000000000000000000005555000005500005555550000070000007b07000000000
4344444444b4434446654344444744440000000000000000000000000000000000000000000000000055555000555500055555500000b0000000b00000000000
44444444444444444444444444444444000000000000000000000000000000000000000000000000005555500055550000555500000b0000000bbb0000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00770700007777000777077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777770077777707777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777777777777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777770777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003030303000303000300000000000000030303030000000000000000000000000000000000000000000000000000000001010100000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070000072000000000000007100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000005a4800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000004550465e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000004a4b505150465b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
004c005d005c4541505250524600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4042434043415153515150515143404300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5150515051515151505051515050505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5051515152505051515151515050505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5151505151505150515151505053500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000