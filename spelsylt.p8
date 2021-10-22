pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
-- main

-- abbreviations
-- pl = player
-- sp = sprite index
-- flp = flip
demo_mode = false
display_cw = true
use_eng = false
new_game_plus = false
new_game_plus_option = false

function add_new_game_plus_option()
	new_game_plus_option = true
	
	local t = "play new game★"
	if new_game_plus then
		t = "play normal game"
	end

	menuitem(2, t, function()
		new_game_plus = not new_game_plus
		add_new_game_plus_option()
		
		if new_game_plus then
			_init()
		end
		
		return false
	end)
end

function add_lang()
	local t = "english please!"
	if use_eng then
		t = "svenska tack!"
	end
	menuitem(1, t, function()
		use_eng = not use_eng
		add_lang()
		return false
	end)
end

function _init()
	add_lang()
	if new_game_plus_option then
		add_new_game_plus_option()
	end
	dbg = ""
	scn = 0
	bkg_blue = 12
	title_index = nil
	_lastt = time()
	p_car = 0
	music_index = nil
	lvl_init()
	make_darker(12)
end

function make_darker(i)
	pal(i, i+128,1)
end

function msc_sad()
	play_music(16)
end

function msc_none()
	play_music(-1)
end

function msc_happy()
	play_music(0)
end

function rand_music()
	local m = flr(rnd(3))
	if m == 0 then
		msc_none()
	elseif m == 1 then
		msc_happy()
	else
		msc_sad()
	end
end

function update_story()
	if demo_mode then
		return
	end
	
	if scn == 3 then
		if pl.x > 215 then
			msc_happy()
			-- change text!
			scn = 4
			bkg_color = bkg_blue
		end
	elseif scn == 4 then
		bkg_color = bkg_blue
		if pl.x > 990 then
			popup = 1
			scn = 5
		end
	elseif scn == 5 then
		bkg_color = bkg_blue
		if pl.x < 160 then
			title_index = 42
			scn = 6
			add_new_game_plus_option()
		end
	end
end

function fall_outside()
	if demo_mode == false then
		if scn == 0 or scn == 1 or scn == 2 then
			if scn == 0 then
				msc_sad()
				title_index = 1
			end
			scn += 1
		end
	end
	lvl()
end

function can_jump()
	if demo_mode then
		return true
	end
	return scn > 2
end

function lvl_init()
	bkg_color = 1
	bkg_par = true
	if demo_mode then
		har_text =
		{
			2,
			3
		}
		rand_music()
		clear_upper()
		clear_right()
	else
		har_text = {}
		if scn == 0 then
			bkg_par = false
			msc_none()
			bkg_color = 0
			clear_upper()
			clear_right()
		elseif scn == 1 then
			msc_sad()
			har_text =
			{
				4,
				5
			}
			clear_upper()
			clear_right()
		elseif scn == 2 then
			msc_sad()
			har_text =
			{
				6,
				7
			}
			clear_upper()
			clear_right()
		elseif scn == 3 then
			msc_sad()
			if not new_game_plus then
				har_text =
				{
					8,
					9
				}
			else
				har_text =
				{
					8,
					21
				}
			end
			clear_upper()
		elseif scn == 4 then
			msc_happy()
			bkg_color = bkg_blue
			har_text =
			{
				10,
				11,
				12
			}
		end
	end
	
	local px = 4
	if scn == 5 then
		px = 970
	end
	
	pl = {
		sp=1,
		x=px,
		y=110,
		w=6,
		h=8,
		flp=false,
		dx=0,
		dy=0,
		max_dx=2,
		max_dy=3,
		jump=3,
		anim=0, --time
		animi=0, -- index in frame
		
		srun=false,
		sjump=false,
		sfall=false,
		sslid=false,
		sland=false
	}
	cam = {
		-- camera on player
		x=0,
		-- camera left
		cx=0,
		-- half hor space
		w=10,
		-- left + right in pixels
		-- 8 pixels per tile
		l=8 * 0,
		r=8 * 127
	}
	gravity=0.3
	blink = 0
	blinkt = 0
	popup = nil
	
	
	ground_fric=0.85
	ground_acc =0.5
	air_fric=0.99
	air_acc =0.15
	
	setup_carrots()
	setup_harar()
end

function clear_upper()
	for y=0,5
	do
		for x=0,127
		do
			mset(x, y, 0)
		end
	end
end

function clear_right()
	for y=0,16
	do
		for x=26,127
		do
			mset(x, y, 0)
		end
	end
end

function lvl()
	reload()
	lvl_init()
end

function play_music(m)
	if m != music_index then
		music(m)
	end
	music_index = m
end

function sfx_car()
	sfx(19)
end

function sfx_jmp()
	sfx(18)
end

function sfx_fall()
	sfx(17)
end

-->8
-- update and draw

function _update()
	local t=time()
	dt=t - _lastt
	_lastt=t
	
	text_anim += dt*0.9
	if text_anim > 1 then
		text_anim -= 1
	end
	
	blinkt += dt
	if blinkt>0.3 then
		blinkt -= 0.3
		blink = (blink + 1)%10
	end
	
	if display_cw then
		if btnp(❎) then
			display_cw = false
		end
	end
	
	if title_index != nil then
		camera(0,0)
		if btnp(❎) then
			if title_index == 42 then
				_init()
			else
				title_index = nil
			end
		end
		return
	end
	
	if popup == nil then
		player_update()
		player_animate()
		pickup_carrots()
		update_harar()
		update_camera()
		update_story()
	else
		if btnp(🅾️) then
			popup = nil
		end
	end
end
	

function update_camera()
	-- camera logic
	local cx = pl.x
	cx = mid(cx-cam.w, cam.x, cx+cam.w)
	cam.x = cx
	
	-- set camera using cx var
	cx = cx - 64+pl.w/2
	cx = mid(cam.l, cx, cam.r-120)
	camera(cx, 0)
	cam.cx = cx
end

function bkg(t, spd)
	local x = (cam.cx - cam.l)*spd
	x = flr(x)%128
	local xx = cam.cx-x
	map(t, 48, xx, 0)
	map(t, 48, xx+128, 0)
end

end_jump = 0

function _draw()
	if display_cw then
		cls(0)
		sweprint(13, 10, 40, 7)
		sweprint(14, 10, 50, 7)
		
		if blink % 2 == 0 then
			print("❎", 60, 110, 14)
		end
		return
	end
	if title_index != nil then
		cls(0)
		if title_index == 42 then
			sweprint(15, 20, 25, 7)
			sweprint(16, 20, 40, 7)
			sweprint(17, 70, 40, 10, true)
			
			end_jump += dt * 0.75
			if end_jump > 1 then
				end_jump -= 1
			end
			spr(3, 12, 50 + sin(end_jump) * 10)
			spr(3, 110, 50 + cos(end_jump) * 10, 1, 1, true)
			
			for i=0, 3 do
				if not new_game_plus then
					spr(17, 35+i*16, 57)
				else
					print("★", 35+i*16, 57, 10)
				end
			end
		else
			sweprint(18, 20, 40, 7)
		end
		

		sweprint(19, 15, 70, 7)
		
		sweprint(20, 10, 80, 7)
		
		if blink % 2 == 0 then
			print("❎", 60, 110, 14)
		end
		return
	end
	
	cls(bkg_color)
	if bkg_par then
		bkg(0, 0.15)
		bkg(32, 0.3)
	end
	map(0, 0)
	local o=0
	if pl.srun and pl.animi%4==3 then
		o=-1
	end
	draw_carrots()
	draw_harar()
	spr(pl.sp, pl.x-(8-pl.w)/2, pl.y+o,1,1,pl.flp)
	
	local cax = 0
	
	if new_game_plus then
		print("★", 2+cam.cx, 2, 10)
		cax = 7
	end
	
	if p_car > 0 then
		spr(17, 2+cam.cx+cax, 0)
		print(p_car, 2+8+cam.cx+cax, 2, 7)
	end
	
	if popup != nil then
		print_popup()
	end
	
	print(dbg, 2+cam.cx, 8, 7)
end

function print_popup()
	local l = flr(cam.cx)
	local b =8
	local t =b
	local r = l+127-b
	local bt =t+32
	rectfill(l+b, t, r, bt-1, 0)
	spr(11, l+b, t)
	spr(13, r-7, t)
	spr(43, l+b, bt-8)
	spr(45, r-7, bt-8)
	
	for i=1, 2 do
		spr(27, l+b, t+i*8)
		spr(29, l+127-b-7, t+i*8)
	end
	for i=1, 12 do
		spr(12, l+b+i*8,t)
		spr(44, l+b+i*8,bt-8)
	end
	
	local py = 22
	if hasn(get_text(popup)) then
		py -= 4
	end
	sweprint(popup, l+16, py, 7)
	
	if blink % 2 == 0 then
		print("🅾️", r-12, bt-10, 14)
	end
end

function hasn(text)
	for i=0, #text-1 do
		local c = sub(text, i+1, i+1)
		if c=="\n" then
			return true
		end
	end
	return false
end

text_anim = 0

function sweprint(texti, ax, y, cc, animate)
	local ox = ax
	local x = ax
	local text = get_text(texti)

	for i=0, #text-1 do
		local c = sub(text, i+1, i+1)
		local d = 0
		local step = true
		local dy = 0
		if animate then
			dy = cos(text_anim+0.15*i)*1.5-0.5
		end
		if c=="…" then
			print("a", x, y+dy, cc)
			d = 1
		elseif c=="∧" then
			print("a", x, y+dy, cc)
			d = 2
		elseif c=="░" then
			print("o", x, y+dy, cc)
			d = 2
		elseif c=="\n" then
			x = ox
			y += 8
			step = false
		else
			print(c, x, y+dy, cc)
		end
		
		if d==1 then
			print(".", x, y-6+dy, cc)
		elseif d==2 then
			print(".", x-1, y-6+dy, cc)
			print(".", x+1, y-6+dy, cc)
		end
		
		if step then
			x += 4
		end
	end
end
-->8
-- languages

lang_swe =
{
	-- 1
	"nu kan jag ge mor░tter\ntill mina harv∧nner!",
	-- 2
	"hej kodsnack!\nh░r …lar h∧rska!",
	-- 3
	"spelsylt e najs",
	-- 4
	"hoppet har ░vergett oss",
	-- 5
	"inte du ocks…\n:(",
	-- 6
	"varf░r forts∧tta leva\nutan hopp?",
	-- 7
	"inga mor░tter, inget hopp\ninget hopp, inget liv",
	-- 8
	"vi borde hoppa mer!",
	-- 9
	"fungerar ❎  f░r dig?",
	-- 10
	"kan du hitta\nmor░terna?",
	-- 11
	"hittar du mor░tter\nblir allt bra!",
	-- 12
	"hej kompis ♥\njag tror p… dig!",
	-- 13
	"varning: inneh…ller",
	-- 14
	"referenser till sj∧lvmord",
	-- 15
	"tack f░r att du spelat",
	-- 16
	"hararna fr…n",
	-- 17
	"hoppsl░sa",
	-- 18
	"hararna fr…n hoppl░sa",
	-- 19
	"av gustav \"madeso\" jansson",
	-- 20
	"med musik av stefan forsberg",
	-- 21
	"du beh░ver ju inte ❎"
}

lang_eng =
{
	"now i can give carrots\nto my friends!",
	"hej kodsnack!\nh░r …lar h∧rska!",
	"spelsylt e najs",
	"hope has left us",
	"please don't...\n:(",
	"why live if you\ncan't jump??",
	"no carrots no hope\nno hope not life",
	"we should jump more!",
	"is your ❎  working?",
	"can you find carrots?",
	"if you find carrots\nall is good!",
	"hello friend ♥\ngood luck!",
	"content warning!!!",
	"contains suicide",
	"thanks for playing",
	"  hares from",
	"happyland",
	"hares from city of no hope",
	"by gustav \"madeso\" jansson",
	"with music by stefan forsberg",
	"you don't need any ❎"
}

function get_text(id)
	if use_eng then
		return lang_eng[id]
	else
		return lang_swe[id]
	end
end
-->8
-- player

function player_update()
	if pl.y > 130 then
		fall_outside()
		sfx_fall()
		return
	end
	local fric=ground_fric
	local acc =ground_acc
	if pl.sjump or pl.sfall then
		fric=air_fric
		acc=air_acc
	end
	pl.dy += gravity
	pl.dx *= fric
	
	if btn(⬅️) then
	 pl.dx -= acc
	 pl.srun = true
	 pl.flp = true
	end
	if btn(➡️) then
	 pl.dx += acc
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
	local button_down = btn(❎)
	if new_game_plus then
		button_down = true
	end
	if button_down and can_jump() and
	pl.sland then
		pl.dy = -pl.jump
		pl.sland = false
		sfx_jmp()
	end
	
	-- vertical collision
	if pl.dy > 0 then
		pl.sfall = true
		pl.sland = false
		pl.sjump = false
		pl.dy = lim(pl.dy, pl.max_dy)
		if map_col(pl, 2, 0) then
			pl.sland = true
			pl.sfall = false
			pl.dy=0
			pl.y -= ((pl.y+pl.h+1)%8)-1
		end
	elseif pl.dy < 0 then
		pl.sjump = true
		if map_col(pl, 8, 1) then
			pl.dy = 0
		end
	end
	
	-- horizontal collision
	if pl.dx < 0 then
		if map_col(pl, 4, 1) then
			pl.dx = 0
		end
	elseif pl.dx > 0 then
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
	
	pl.x = mid(cam.l, pl.x, cam.r)
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
		x1=x+w y1=y
		x2=x+w+1   y2=y+h-1
	elseif aim==8 then
		x1=x+2   y1=y-1
		x2=x+w-3 y2=y
	elseif aim==2 then
		x1=x+1   y1=y+h
		x2=x+w-2 y2=y+h
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

function int(n)
	return flr(n)
end
-->8
-- carrots


function setup_carrots()
	crts={}
	for y=0,16
	do
		for x=0,127
		do
			local s
			s = mget(x,y)
			if s == 17 then
				local c
				mset(x, y, 0)
				c = add(crts, {})
				c.x = x*8
				c.y = y*8
				c.an = rnd()
			end
		end
	end
end

function draw_car(c)
	spr(17, c.x, c.y+sin(car_tim+c.an)*2)
end

function draw_carrots()
	for i=1,#crts
	do
 	draw_car(crts[i])
	end
end

car_tim = 0
function pickup_carrots()
	local r=nil
	local c
	car_tim += dt*0.75
	if car_tim > 1 then
		car_tim -= 1
	end
	for i=1,#crts
	do
		local dx, dy
 	c=crts[i]
 	dx = abs(c.x+4 - pl.x)
 	dy = abs(c.y - pl.y)
 	if (dx+dy) < 8 then
 		r = i
 	end
	end
	
	if r != nil then
		deli(crts, r)
		p_car += 1
		sfx_car()
	end
end
-->8
--harar


function setup_harar()
	har={}
	local index = 1
	for x=0,127
	do
		for y=0,16
		do
			local s
			s = mget(x,y)
			if s == 1 then
				local c
				mset(x, y, 0)
				local t = har_text[index]
				if t != nil then
					c = add(har, {})
					c.x = x*8
					c.y = y*8
					c.sp = 1
					c.plclose=false
					c.text = t
					c.anim=rnd(1) --time
					c.animi=0 -- index in frame
				end
				index += 1
			end
		end
	end
end

function draw_harar()
	for i=1,#har
	do
		local c = har[i]
		local flp = c.x - pl.x > 0
		spr(c.sp, c.x, c.y, 1,1, flp)
		if popup == nil then
			if c.plclose then
				if blink % 2 == 0 then
					print("🅾️", c.x, c.y-7, 14)
				end
			end
		end
	end
end

function update_harar()
	local mdis = 1000
	local closest = nil
	for i=1,#har
	do
		local dx, dy
 	c=har[i]
 	dx = abs(c.x+4 - pl.x)
 	dy = abs(c.y - pl.y)
 	anim(c, {1, 2}, 0.5)
 	c.plclose = false
 	local dis = dx+dy
 	if dis < mdis then
 		mdis = dis
 		closest = i
 	end
	end
	
	if closest != nil then
		local c = har[closest]
		if mdis < 32 then
			c.plclose = true
			
			if btnp(🅾️) then
		 	popup = c.text
		 end
		end
	end
end
__gfx__
00000000000060600000000000060600000606000000000000000000000000000000000000000000000000000707070707070707070707070000000000000000
00000000000060600000606000006060000060600000606000000000000000000000000000000000000000007070707070707070707070700000000000000000
00700700000066660000606000006666000066660000606000000000000000000000000000000000000000000707070707070707070707070000000000000000
00077000770061667700666600006166770061667700666600000000000000000000000000000000000000007070000000000000000000700000000000000000
00077000770066667700616677006666770066667700616600000000000000000000000000000000000000000700000000000000000007070000000000000000
00700700066660000666666677666000066660000666666600000000000000000000000000000000000000007070000000000000000000700000000000000000
00000000066660000666600006666000066660000666600000000000000000000000000000000000000000000700000000000000000007070000000000000000
00000000060060000600600060000600006600000060060000000000000000000000000000000000000000007070000000000000000000700000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000000007070000000000000000
00000000000303000000000000000000000000000000000000000000000000000000000000000000000000007070000000000000000000700000000000000000
00000000000030000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000000007070000000000000000
00000000000999000000000000000000000000000000000000000000000000000000000000000000000000007070000000000000000000700000000000000000
00000000000999000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000000007070000000000000000
00000000000999000000000000000000000000000000000000000000000000000000000000000000000000007070000000000000000000700000000000000000
00000000000090000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000000007070000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000007070000000000000000000700000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000000007070000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000007070000000000000000000700000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000000007070000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000007070000000000000000000700000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000000007070000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000007070707070707070707070700000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000707070707070707070707070000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000007070707070707070707070700000000000000000
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
44444444444444444444444444444444000000000444040000404440000000000000000000000000005555500055550000555500000b0000000bbb0000000000
44444444004000040004000044444444000000055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444004000400004000044444444000000555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444d4640004004000040000464d4444000005555550000000000000000000000000000000000000000000333300000000000000000000000000000000000000
43444444000400000040000044444434000055555555000000000000000000000000000000000000000033333333000000000000000000000000000000000000
44344444000000000040000044444344000555555555500000000000000000000000000000000000000333333333300000000000000000000000000000000000
44444b44000000000040000044b44444005555555555550000000000000000000000000000000000003333333333330000000000000000000000000000000000
04444444000000000000000044444440055555555555555000000000000000000000000000000000033333333333333000000000000000000000000000000000
00444444000000000000000044444400555555555555555500000000000000000000000000000000333333333333333300000000000000000000000000000000
00770700007777000777077000000000555555550000000000000000000000000000000033333333000000000030300000000000000000000000000000000000
07777770077777707777777700000000555555550000000000000000000000000000000033333333000000000003000000000000000000000000000000000000
77777777777777777777777700000000555555550000000000000000000000000000000033333333333333333333333300000000000000000000000000000000
00000000777777770777777000000000555555550000000000000000000000000000000033333333333333333333333300000000000000000000000000000000
00000000000000000000000000000000555555550000000000000000000000000000000033333333333333333333333300000000000000000000000000000000
00000000000000000000000000000000555555550000000000000000000000000000000033333333333333333333333300000000000000000000000000000000
00000000000000000000000000000000555555550000000000000000000000000000000033333333333333333333333300000000000000000000000000000000
00000000000000000000000000000000555555550000000000000000000000000000000033333333333333333333333300000000000000000000000000000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000004656000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000464747560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000046474747475600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00004647474747474756000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00464747474747474747560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4647474747474747474747560000000000000000000000000000000000000000000000000000a6a7b7b60000a6a7b60000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
47474747474747474747474756000000000000000000000000000000000000000000000000009797979700009797970000000000000000000000000000000000
__label__
ss777sssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssss7sssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
sss77sssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssss7sssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ss777sssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
sssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss6s6ssssssssssssssssssssssssssssssssssssssssssssssss55ss
sssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss6s6sssssssssssssssssssssssssssssssssssssssssssssss5555s
sssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss6666sssssssssssssssssssssssssssssssssssssssssssss555555
5ssssssssssssssssssssssssssssssssss7sssssssssssssssssssssssssssssssss77ss6166ssssssssssssssssssssssssssssssssssssssssssss5555555
55ssssssssssssssssssssssssssssssss7a7ssssssssssssssssssssssssssssssss77ss6666sssssssssssssssssssssssssssss55ssssssssssss55555555
555ssssssssssssssssssssssssssssssss7ssssssbsbsssssssssssssssssssssssss6666sssssssssssssssssssssssssssssss5555ssssssssss555555555
5555sssssssssssssssssssssssssssssssbsssssbsbbsssssssssssssssssssssssss6666sssssssssssssssssssssssssssssss55555ssssssss5555555555
55555sssssssssssssssssssssssssssssbsssssssbbssssssssssssssssssssssssss6ss6sssssssssssssssssssssssssssssss55555sssssss55555555555
555555sssssssssssssssssssbbbbbbbbbbbbbbbbbbbbssssssssssssssssssssbbbbbbbbbbbbssssssssssssssssssssbbbbbbbbbbbbsssssss555555555555
5555555sssssssssssssssssbbbbbbbbbbbbbbbbbbbbbbssssssssssssssssssbbbbbbbbbbbbbbssssssssssssssssssbbbbbbbbbbbbbbsssss5555555555555
55555555sssssssssssssssbbbb33333bb33bb33333bbbbssssssssssssssssbbbb33333333bbbbssssssssssssssssbbbb33333333bbbbsss55555555555555
555555555ssssssssssssssbbb344443b3443b344443bbbssssssssssssssssbbb3444444443bbbssssssssssssssssbbb3444444443bbbss555555555555555
5555555555sssssssssssssbbb3444443b343b3442443bbssssssssssssssssbbb34444442443bbssssssssssssssssbbb34444442443bbs5555555555555555
55555555555ssssssssssssbb3444d444344434444443bbssssssssssssssssbb3444d4444443bbssssssssssssssssbb3444d4444443bb55555555555555555
555555555555sssssssssssb34244444244d4444444d43bssssssssssssssssb34244444444d43bssssssssssssssssb34244444444d43b55555555555555555
5555555555555ssssssssss34d444444444444444444443ssssssssssssssss34d4444444444443ssssssssssssssss34d444444444444355555555555555555
55555555555555sssssssss444444444444444444444444ssssssssssssssss4444444444444444ssssssssssssssss444444444444444455555555555555555
555555555555555ssssssss444444444444444444444444ssssssssssssssss4444444444444444ssssssssssssssss444444444444444455555555555555555
5555555555555555ss7ss7s4444d4644444d4644444d464ssssssssssssssss4444d4644444d464ssssssssssssssss4444d4644444d46455555555555555555
55555555555555555ssaass444444444444444444444444ssssssssssssssss4444444444444444ssssssssssssssss444444444444444455555555555555555
555555555555555555saass443444444434444444344444ssssssssssssssss4434444444344444ssssssssssssssss443444444434444455555555555555555
5555555555555555557bs7s44444b4444444b4444444b44ssssssssssssssss44444b4444444b44ssssssssssssssss44444b4444444b4455555555555555555
5555555555555555555bsss434444444344444443444444ssssssssssssssss4344444443444444ssssssssssssssss434444444344444455555555555555555
555555555555555555bbbss444444444444444444444444ssssssssssssssss4444444444444444ssssssssssssssss444444444444444455555555555555555
555555555bbbbbbbbbbbbbb444444444444444444444444ssssssssssssssss4444444444444444ssssssssssssssss444444444444444455555555555555555
55353555bbbbbbbbbb33bbb444444444444444444444444ssssssssssssssss4444444444444444ssssssssssssssss444444444444444455555555555555555
5553555bbbb33333b3443b34444d4644444d4644444d464ssssssssssssssss4444d4644444d464ssssssssssssssss4444d4644444d46455555555555555555
5599955bbb3444443b343b4444444444444444444444444ssssssssssssssss4444444444444444ssssssssssssssss444444444444444455555555555555555
5599955bbb3444444344434443444444434444444344444ssssssssssssssss4434444444344444ssssssssssssssss443444444434444455555555555555555
5599955bb3444d444444d4444444b4444444b4444444b44ssssssssssssssss44444b4444444b44ssssssssssssssss44444b4444444b4455555555555555555
5559555b34244444244d444434444444344444443444444ssssssssssssssss4344444443444444sssssssssssssss5434444444344444455555555555555555
555555534d4444444444444444444444444444444444444ssssssssssssssss4444444444444444ssssssssssssss55444444444444444455555555555555555
bbbbbbb4444444444444444444444444444444444444444ssssssssssssssss4444444444444444sssssssssssss555444444444444444455555555555555555
bbbbbbb4444444444444444444444444444444444444444ssssssssssssssss4444444444444444ssssssssssss5555444434444444444455555555555555555
bb33bb34444d4644444d4644444d4644444d4644444d464ssssssssssssssss4444d4644444d464sssssssssss5555544b444444444d46455555555555555555
b3443b34444444444444444444444444444444444444444ssssssssssssssss4444444444444444ssssssssss55555544444b444444444455555555555555555
3b343b34434444444344444443444444434444444344444ssssssssssssssss4434444444344444sssssssss5555555444444644434444455555555555555555
434443444444b4444444b4444444b4444444b4444444b44ssssssssssssssss44444b4444444b44ssssssss555555554566444444444b4455555555555555555
244d4444344444443444444434444444344444443444444ssssssssssssssss4344444443444444sssssss555555555466543444344444455555555555555555
44444444444444444444444444444444444444444444444ssssssssssssssss4444444444444444ssssss5555555555444444444444444455555555555555555
44444444444444444444444444444444444444444444444ssssssssssssssss4444444444444444sssss55555553535444444444444444455555555555555555
44444444444444444444444444444444444444444444444ssssssssssssssss4444444444444444ssss555555555355444434444444444455555555555555555
444d4644444d4644444d4644444d4644444d4644444d464ssssssssssssssss4444d4644444d464333333333333333344b444444444d46455555555555555553
44444444444444444444444444444444444444444444444ssssssssssssssss4444444444444444333333333333333344444b444444444455555555555555333
43444444434444444344444443444444434444444344444ssssssssssssssss44344444443444443333333333333333444444644434444455555555555553333
4444b4444444b4444444b4444444b4444444b4444444b44ssssssssssssssss44444b4444444b4433333333333333334566444444444b4455555555555533333
34444444344444443444444434444444344444443444444ssssssssssssssss43444444434444443333333333333333466543444344444455555555555333333
44444444444444444444444444444444444444444444444ssssssssssssssss44444444444444443333333333333333444444444444444455555555553333333
44444444444444444444444444444444444444444444444ssssssssssssssss44444444444444443333333333333333444444444444444455555555553333333
44444444444444444444444444444444444444444444444ssssssssssssssss44444444444444443333333333333333444444444444444455555555553333333
444d4644444d4644444d4644444d4644444d4644444d4645sssssssssssssss4444d4644444d46433333333333333334444d4644444d46455555555553333333
4444444444444444444444444444444444444444444444455ssssssssssssss44444444444444443333333333333333444444444444444455555555553333333
43444444434444444344444443444444434444444344444555sssssssssssss44344444443444443333333333333333443444444434444455555555553333333
4444b4444444b4444444b4444444b4444444b4444444b445555ssssssssssss44444b4444444b44333333333333333344444b4444444b4455555555553333333
3444444434444444344444443444444434444444344444455555sssssssssss43444444434444443333333333333333434444444344444455555555553333333
44444444444444444444444444444444444444444444444555555ssssssssss44444444444444443333333333333333444444444444444455555555553333333

__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003030303000303000300000000000000030303030000000000000000000000000300000300000000000000000000000001010100000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000015e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000454600000000710000007100000071000000710000004541424600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000616100000000000000000000000000000000000000000061006200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
525d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
41424600000000000000000000000000000000000000000000000000000000000000000000000000000000000000005d4e000000110000005a0000000000115d00000000004d000000000011000000004a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6100610000004b00000000000000000000000000000000000000000000000000000000000000000000000000000045404600004546000045460000000045414346000000454346000000004800000045434600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000454046000000000000000000000000000000000000000000000000000000000000000000000000115e5050500000505000005050000000005050505000000050505000000000520000005050505c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000006100000000000000000000000000000000000000000000000000000000000000000000005a11454350505000005050000050500000000062006100000000006100000000006200000050505041460000110000000000000000000000000000000000000000000000000000000000000000000000000000001100
0000000000000000000045460000000000004546000000000000000000000000000000110000000000454240505050505000005050000052500000000000000000000000000000000000000000000000610000620045460000000000000000004546000000000011110000000000000000561100000000000000000000001100
005b0001005d004d0000006200014b00004a00625b5d560000000000004a560000000056000000115c505050505050505000005050000052500000000000000000000000000000004a005b004c0000560000005d005051001156115d4c00115c515100114a00114546004e004c11115d004546004b111156005a11114c11115d
4041414140414040414042424140404041404240404141460000000045404046000045434600004541425050505050505000005050000050500000000000000000000000000045424340414243404142434041424251514243404142434041425153414243404142434041424340414243404142434041424340414243404142
__sfx__
151000001805318615186251861518655186151862518615180531861518625186151865518615186251861518053186151862518615186551861518625186151805318615186251861518655186151862518615
011000000054000520005400051000520005300052000510005400052000540005100052000542005200051002540025200254002510025200253002520025100254002520025400251002520025420252002510
01100000241371c2172b12724317281371f4172b12728517241371c2172b12224317281321f4172b12228517261371d2172d1272631729137214172d1272951726137292172d12226317291322d4172d12229517
0110000024742247422474524744247422474424742247422b7422b7422b7452b744297422974428742287422674226742267452674426742267442874228742247422474224745247441f7421f7441f7421f742
011000000554005540055400551005520055300552005510055400552005540055100552005542055200551004540045400454004510045200453004520045100454004520045400451004520045420452004510
011000001d1372121724127213171d1372141724127215171d1372121724122213171d13221417211221d5171c1371f217231271f3171c1371f417231271f5171c1371f217231221f3171c1321f4171f1221c517
001000002174221742217452174421742217442874228742247422474224745247442974229744297422974228742287422674526744287422874424742247422674226742247452474423742237442674226742
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0008000032650256401e64019640136300f6200e61000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
0104000020071260712800011000160001b0002600030000360003600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00040000213702a3602e3002d3002a3002a3001130000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
011400001805318615186211861518621000031805318615000000000018622000001805300000186260000018053186151862118615186210000318053186150000000000186220000018053000001862600000
b914000018350183521a3501b3521f350000001f3521f3521f3521f3321f3421f3221f3101f3001f302000001835018332183501834214350143521b3521b3521a3501a3321a3421a3321a3101f3001a30000000
011400001805018040180201804018050180401802018040130501304013020130401302013040130201304014050140401402014040140501404014020140401105011040110201105011020110401102011040
881400002b7502b7522b7522b7522b7522b75227750277532675026752277502775226750277522675027752297502975029750297502975029750267522775224750247221f7501f7321f750207212473224752
__music__
01 00010203
02 04050006
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
03 14151657

