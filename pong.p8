pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- 2 player pong game

gamestate = 0 -- 0=menu, 1=game, 2=death
a = { y=60,score=0 }
b = { y=60,score=0 }
padheight = 22 -- can change
ball = { x=63, y=63, dx=1, dy=0 }
winner = ''

function _draw()
	if (gamestate==0) drawmenu()
	if (gamestate==1) drawgame()
	if (gamestate==2) drawend()
end

function _update()
	if (gamestate==0) updatemenu()
	if (gamestate==1) updategame()
	if (gamestate==2) updateend()
end

-->8
function drawmenu()
	rectfill(0,0,127,127,0)
	print('pong! press ❎ to start.',16,60,7)
end

function drawgame()
	-- interface
	rectfill(0,0,127,127,0)
	line(0,8,127,8,7)
	print(a.score,1,1,7)
	print(b.score,124,1,7)
	-- actors
	rectfill(2,a.y,3,a.y+padheight,7)
	rectfill(124,b.y,125,b.y+padheight,7)
	rectfill(ball.x,ball.y,ball.x+1,ball.y+1,8)
end

function drawend()
	rectfill(0,0,127,127,11)
	print('player '+winner+' wins!',20,60,0)
end

-->8
function updatemenu()
	if (btnp(5)) gamestate = 1
end

function updategame()
	-- controls
 	-- player a
 	if (btn(2,1) and a.y>10) a.y-=2
 	if (btn(3,1) and a.y<(126-padheight)) a.y+=2
		-- player b
 	if (btn(2,0) and b.y>10) b.y-=2
 	if (btn(3,0) and b.y<(126-padheight)) b.y+=2
	-- ball
	if (collide() == 0) then
		ball.x += ball.dx
		ball.y += ball.dy
	else
		ball.dx = ball.dx * -1
	end
end

function collide()
	-- left side
	if (2 < ball.x and ball.x < 4 and (a.y-2) < ball.y and ball.y < (a.y+padheight)) return 1
	-- right side
	if (121 < ball.x and ball.x < 126 and (b.y-2) < ball.y and ball.y < (b.y+padheight)) return 1
	return 0
end

function updateend()

end

