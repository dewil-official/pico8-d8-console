pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

-- persistant variables

gamestate = 0 // 0=menu,1=ingame,2=gameover
ticks = 0
height = 64
acc = 0
towers = {}
clouds = {}
coins = {}
score = 0
highscore = 0
plane = 0
menuplaneanim = 0
planedrop = { 0.2, 1, 0.1, 0.5}

-- main functions

function _draw()
	if(gamestate==0)then drawmenu() end
	if(gamestate==1)then drawgame() end
	if(gamestate==2)then drawgameover() end
end

function _init()
	menuitem(1,'back to menu',function() load('menu.p8') run() end)
end

function _update()
	if(gamestate==1)then
		-- main ingame updates
		checkdeath() 
 	controls()
 	updatetowers()
 	updateclouds()
 	updatecoins()
 	height += acc
 	if (plane==1) then acc += planedrop[plane+1]
 	elseif (acc<=0) then acc+=planedrop[plane+1] end
 	ticks += 1
 elseif(gamestate==0)then
 	menu()
 elseif(gamestate==2)then
 	if(btn(5)) then
 		reset()
 	end
 	ticks += 1
 end
end

-- draw functions

function drawmenu()
	rectfill(0,0,127,127,1)
	spr(64,32,61)
	spr(65,40,61)
	spr(66,48,61)
	spr(67,56,61)
	spr(68,64,61)
	spr(69,72,61)
	spr(70,80,61)
	spr(71,88,61)
	if (menuplaneanim<6) then
		menuplaneanim+=0.1
	else
		menuplaneanim=0
	end
	if (menuplaneanim<3) then
		pos = menuplaneanim
	else
		pos = 6-menuplaneanim
	end
	pos+=60
	if (plane==0) then
		spr(0,16,pos)
		spr(1,24,pos)
	elseif (plane==1) then
		spr(16,16,pos)
		spr(17,24,pos)
	end
	print('❎: start / 🅾️: choose plane',8,122,12)
end

function drawgame()
	rectfill(0,0,127,127,1)
	if (plane==0) then
		-- normales flugzeug
 	spr(0,10,height)
 	spr(1,18,height)
 elseif (plane==1) then
 	-- ufo
 	if (divby(ticks,3)) then
  	spr(32,10,height)
  	spr(33,18,height)
 	elseif (divby(ticks,5)) then
  	spr(48,10,height)
  	spr(49,18,height)
 	else
  	spr(16,10,height)
  	spr(17,18,height)
  end
 end
 -- draw coins
 for coin in all(coins) do
 	spr(25,coin.x,coin.y)
 end
	-- draw towers
	for i=1,#towers do
 	local cury = 120
 	if (towers[i].t==1) then
  	for u=1,towers[i].h do
  		spr(2,towers[i].x,cury)
  		spr(3,towers[i].x+8,cury)
  		spr(4,towers[i].x+16,cury)
  		cury-=8
  	end
 	elseif (towers[i].t==2) then
 		local curh = towers[i].h
  	for u=1,towers[i].h do
  		if (curh==towers[i].h) then
   		spr(50,towers[i].x,cury)
   		spr(51,towers[i].x+8,cury)
   		spr(52,towers[i].x+16,cury)
   		cury-=8
   		curh-=1
   	elseif (curh>1) then
   		spr(34,towers[i].x,cury)
   		spr(35,towers[i].x+8,cury)
   		spr(36,towers[i].x+16,cury)
   		cury-=8
   		curh-=1
   	else
   		spr(18,towers[i].x,cury)
   		spr(19,towers[i].x+8,cury)
   		spr(20,towers[i].x+16,cury)
   		cury-=8
   		curh-=1
   	end
  	end
 	elseif (towers[i].t==3) then
 		for u=1,towers[i].h do
 			for p=1,towers[i].w do
  			spr(5,towers[i].x+p*8,cury)
  		end
  		cury-=8
  	end
 	elseif (towers[i].t==4) then
 		for u=1,towers[i].h do
 			for p=1,towers[i].w do
  			spr(6,towers[i].x+p*8,cury)
  		end
  		cury-=8
  	end
 	end
 end
 -- draw clouds
 for i=1,#clouds do
 	if (clouds[i].t==1) then
 		spr(7,clouds[i].x,clouds[i].h)
 		spr(8,clouds[i].x+8,clouds[i].h)
 	elseif (clouds[i].t==2) then
 		spr(9,clouds[i].x,clouds[i].h)
 	elseif (clouds[i].t==3) then
 		spr(10,clouds[i].x,clouds[i].h)
 		spr(11,clouds[i].x+8,clouds[i].h)
 	else
 		spr(23,clouds[i].x,clouds[i].h)
 		spr(24,clouds[i].x+8,clouds[i].h)
 		spr(39,clouds[i].x,clouds[i].h+8)
 		spr(40,clouds[i].x+8,clouds[i].h+8)
 	end
 end
 -- draw score
 spr(25,1,0)
 print(score,9,2,7)
end

function drawgameover()
	rectfill(0,0,127,127,8)
	print('press x',50,67,0)
	if(divby(ticks,4) or divby(ticks,5)) then
		print('game over!',44,61,13)
	else
		print('game over!',44,61,0)
	end
	print('score: '..score,1,1,0)
	print('max: '..highscore,1,7,0)
end

-- update functions

function menu()
	if (btnp(5)) then
		gamestate = 1
	end
	if (btnp(4)) then
		plane+=1
		if (plane>1) then plane=0 end
	end
end

function controls()
	if (plane == 0) then
		if (btn(2)) then
			acc = -1.3
		end
		if (btn(3)) then
			acc = 0.2
			height += 0.8
		end
	end
	if (plane == 1) then
		if (btnp(2)) then
 		sfx(0)
 		acc = -2
		end
	end
end

function checkdeath()
	if (height<-4) then die() end
	if (height>131) then die() end
	-- tower collision check
	for i=1,#towers do
		local twidth = 1
		if (towers[i].t==1 or towers[i].t==2) then twidth=3
		elseif (towers[i]==3 or towers[i].t==4) then twidth=towers[i].t
		else
			-- future tower nr. 5
		end
		if (towers[i].x<=18) then
			if (towers[i].x+twidth*8>10) then
				if (128-towers[i].h*8<height+8) then
					die()
				end
			end
		end
	end
	-- cloud collision check
	for i=1,#clouds do
		if (clouds[i].t==1) then
			if (clouds[i].x>=-5 and clouds[i].x<=26) then
				if (height<=clouds[i].h+6 and clouds[i].h+5<=height+7) then
					die()
				end
			end
		elseif (clouds[i].t==2) then
			if (clouds[i].x>=4 and clouds[i].x<=25) then
				if (height<=clouds[i].h+6 and clouds[i].h+1<=height+7) then
					die()
				end
			end
		elseif (clouds[i].t==3) then
			if (clouds[i].x>=-4 and clouds[i].x<=25) then
				if (height<=clouds[i].h+6 and clouds[i].h+1<=height+7) then
					die()
				end
			end
		elseif (clouds[i].t==4) then
			if (clouds[i].x>=-4 and clouds[i].x<=25) then
				if (height<=clouds[i].h+14 and clouds[i].h+1<=height+7) then
					die()
				end
			end
		end
	end
	-- although this is the checkdeath function, collect coin here
	for coin in all(coins) do
		if (coin.x<=24 and coin.x>=4) then
			if (coin.y+1<=height+7 and coin.y+6>=height+1) then
			 score += 1
			 del(coins,coin)
			end
		end
	end
end

function updatetowers()
	checkspawntower()
	movetowers()
	removetowers()
end

function checkspawntower()
	if (ticks<=1000) then
		gentower(1)
 elseif (ticks<=4000) then
 	gentower(2)
 elseif (ticks<=6000) then
 	gentower(3)
 else
 	gentower(4)
 end
end

function gentower(lvl)
	local type = 1
	local divnr = 200
	if (lvl==1) then
		type = 1
		divnr = 170
	elseif (lvl==2) then
		type = flr(rnd(2)+1.9) -- 1-3
		divnr = 150
	elseif (lvl==3) then
		type = flr(rnd(3)+1.9) -- 1-4
		divnr = 130
	else
		type = flr(rnd(4)+1.9) -- 1-5
		divnr = 100
	end
	
	if (divby(ticks,divnr)) then
 	local h = flr(rnd(7)+1.9) -- 1-8
 	if (type==3 or type==4) then
 		local w = flr(rnd(6)+1.9) -- 1-7
			add(towers, {x=127,h=h,t=type,w=w})
			--towers[#towers+1]={x=127,h=h,t=type,w=w}
 	else
			add(towers, {x=127,h=h,t=type})
			--towers[#towers+1]={x=127,h=h,t=type}
		end
	end
end

function movetowers()
	for i=1,#towers do
		towers[i].x-=1
	end
end

function removetowers()
	for tower in all(towers) do
		if (tower.x<-64) then
			del(towers, tower)
		end
	end
end

function updateclouds()
	checkspawncloud()
	moveclouds()
	removeclouds()
end

function checkspawncloud()
	if (divby(ticks,100)) then
		local lol = 5
		if (ticks<=1200) then lol=5
		elseif (ticks<=2200) then lol=4
		elseif (ticks<=3600) then lol=3.5
		else lol=3
		end
		if (rnd(lol)<1.7) then
  	local type = 1
  	if (ticks<=1000) then
  		type = flr(rnd(1)+1.5) -- 1-2
   elseif (ticks<=4000) then
   	type = flr(rnd(2)+1.5) -- 1-3
   else
   	type = flr(rnd(3)+1.5) -- 1-4
   end
   local speed = rnd(1) -- 0-1.0
   local h = flr(rnd(60)+1.5) -- 1-4
   --clouds[#clouds+1]={x=127,h=h,t=type,speed=speed}
  	add(clouds, {x=127,h=h,t=type,speed=speed})
  end
 end
end

function moveclouds()
	for i=1,#clouds do
		clouds[i].x-=clouds[i].speed
	end
end

function removeclouds()
	for cloud in all(clouds) do
		if (cloud.x<-32) then
			del(clouds,cloud)
		end
	end
end

function updatecoins()
	if (divby(ticks,145)) then
		add(coins,{x=127,y=62})
	end
	for coin in all(coins) do
		coin.x-=1
	end
	for coin in all(coins) do
		if (coin.x<-8) then del(coins,coin) end
	end
end

function die()
	gamestate = 2
	-- todo: sound effect here
	highscorecheck()
end

function highscorecheck()
	if (highscore<score) then
		highscore = score
	end
end

function reset()
	score = 0
	coins = {}
	towers = {}
	clouds = {}
	ticks = 0
	gamestate = 0
	height = 64
	acc = 0
end

-- helper functions

function divby(a,b)
	local val = a
	while (val>0) do
		val-=b
	end
	if (val==0) then
		return true
	else
		return false
	end
end

__gfx__
6000000000000000d5555555555555555555555dffffffff9555f565000000000000000000770000000777007770000000000000000000000000000000000000
7600000000000000766667666676666676666667442f442f9555f657000000000000000000777077007777707777700000000000000000000000000000000000
7777777777777770766666766666666666667667442f442ff5679fff000000000000000077777777077777777777770000000000000000000000000000000000
7770707070707076766666666666666666666767222f222ff6759555000000000000000077776777777777776777777000000000000000000000000000000000
7777777777777776d5555555555555555555555dffffffffff999566000000000000000077667776777766777777767600000000000000000000000000000000
67775677776666607676666666666666667666672f442f445555f555007777777777777777777776777767767777677600000000000000000000000000000000
00096776660000007667666666667666666766672f442f4456779557077766666666000066777660007777666677776000000000000000000000000000000000
00005660000000007666666666666766666676672f222f229fff999f000000000000000000666000006666000066660000000000000000000000000000000000
00000777777000000007555555555555555570000000000000000000000777700000000000000000000000000000000000000000000000000000000000000000
00006666666600000075555555555555555557006600000000000000007777770077077600999900000000000000000000000000000000000000000000000000
05555555555555500555555555555555555555506566600000000000007777777777777609aaaa90000000000000000000000000000000000000000000000000
653b53b55b35b3560566666666666666666666505555555555777000077777777777777009aa9a90000000000000000000000000000000000000000000000000
06666677776666600562d2d2d2d2d2d2d2d2d650ce5555555556666d077777677777777009a99a90000000000000000000000000000000000000000000000000
00cec000000cec000562d2d2d2d2d2d2d2d2d650cc5555555555555d076777677777776009aaaa90000000000000000000000000000000000000000000000000
000cc000000ccc000562d2d2d2d2d2d2d2d2d650055dddddddddddd0077666777677767000999900000000000000000000000000000000000000000000000000
000c00000000c0000562d2d2d2d2d2d2d2d2d650ddd0000000000000077777777777677700000000000000000000000000000000000000000000000000000000
00000777777000000562d2d2d2d2d2d2d2d2d6500000000000000000077777777777777000000000000000000000000000000000000000000000000000000000
00006666666600000562d2d2d2d2d2d2d2d2d6500000008888800000077777777777777600000000000000000000000000000000000000000000000000000000
05555555555555500562d2d2d2d2d2d2d2d2d6500800000606000000777777777677777600000000000000000000000000000000000000000000000000000000
653b53b55b35b3560562d2d2d2d2d2d2d2d2d6500888888888888070776777776777777600000000000000000000000000000000000000000000000000000000
06666677776666600562d2d2d2d2d2d2d2d2d6500888888888888760777677677777776000000000000000000000000000000000000000000000000000000000
00cec00000ccec000562d2d2d2d2d2d2d2d2d65008000dddddddd060077766777777760000000000000000000000000000000000000000000000000000000000
00cc0000000cc0000562d2d2d2d2d2d2d2d2d6500000000606000000077777767777600000000000000000000000000000000000000000000000000000000000
00c00000000000000562d2d2d2d2d2d2d2d2d6500000008888800000006666600666000000000000000000000000000000000000000000000000000000000000
00000777777000000562d2d2d2d2d2d2d2d2d6500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006666666600000562d2d2d2d2d2d2d2d2d6500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05555555555555500562d2d2d2d2d2d2d2d2d6500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
653b53b55b35b3560566666666666666666666500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06666677776666605555555555555555555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00cec000000cec005777777777777777777777650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c00000000cc005666666666666666666666650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c00000000c0005555555555555555555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
099990900009999a099990999909a09099990900009999a09009a099990566650000000000000000000000000000000000000000000000000000000000000000
09aaa0900009a09a09aa909aa909a0909aa90900009a09a09909a090000577750000000000000000000000000000000000000000000000000000000000000000
09a000900009a09a09a0909a0909a0909a090900009a09a09999a099990566650000000000000000000000000000000000000000000000000000000000000000
099900900009999a099990999909999099990900009999a09a99a09aaa0577750000000000000000000000000000000000000000000000000000000000000000
09aa00999909aa9a09aaa09aaa009aa09aaa0999909aa9a090a9a09a000566650000000000000000000000000000000000000000000000000000000000000000
09a000aaaa09a09a09a0009a00009a009a000aaaa09a09a09009a099990577750000000000000000000000000000000000000000000000000000000000000000
__sfx__
00010000000000305001050020500205002050020500205002050030500205002050020500205002050020500205003050030500405005050070500805008050090500905009050090500c0500d0500f05010050
001000000e05010050100500e05015050130500e0500e050100500e05013050150500e0500e050100500e0501505013050100500e0500e0501005013050000000000000000000000000000000000000000000000
000100003505035050350503505035050350503505035050340503305033050330503305033050320503205032050320503205032050320503205032050320503205032050320503205032050320503105030050
__music__
00 01424344

