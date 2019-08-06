pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- (title goes here)
-- by @nucleartide

-- current state:

current_state={
  state=nil,
}

-- game loop:

function _init()
  transition{to=game}
end

game={}

function game.init()
  poke(0x5f2c,3)
  game.player=player{
    pos=vec3(0, 5, 0),
  }
  game.cam=cam{
    player=game.player,
  }
  game.level=level{
    cam=game.cam,
    player=game.player,
  }
end

function game.update()
  -- note: order is important here
  player_update(game.player)
  cam_update(game.cam)
  level_update(game.level)
end

function game.draw()
  cls(1)
  cam_draw(game.cam)
  level_draw(game.level)
  player_draw(game.player)
  camera()

  -- debug
  cursor()
  color(6)
  print('cpu:'..stat(1))
  print('xoffset:'..game.level.x_offset)
  --print('camx:'..game.cam.pos.x)
  -- map( celx, cely, sx, sy, celw, celh, [layer] )
  --[[
  local x_offset=32-game.player.pos.x
  map(8, 0, x_offset/2, 0, 8, 8)
  map(0, 0, 0, 0, 8, 8)
  player_draw(game.player)
  ]]
end
-->8
-- player:

function player(o)
  return {
    pos=assert(o.pos~=nil) and o.pos,
    vel=vec3(),
    acc=vec3(),
    w=5,
    h=5,
    speed=50, -- pixels per second
  }
end

function player_update(p)
  -- update acc
  local left=btn(button.left)
  local right=btn(button.right)
  if left and not right then
    p.acc.x=-p.speed
  elseif not left and right then
    p.acc.x=p.speed
  else
    p.acc.x=0
  end

  -- update vel
  p.vel=vec3_damp(p.vel,p.acc,0.001)

  -- update pos
  p.pos=vec3_add(p.pos,vec3_mul(p.vel,1/60))
end

function player_draw(p)
  local x,y=vec3_to_screen_space(p.pos)
  rectfill(x,y,x+p.w-1,y+p.h-1,7)
end

function cam(o)
  return {
    player=assert(o.player~=nil) and o.player,
    pos=vec3(),
  }
end

function cam_update(c)
  c.pos.x=c.player.pos.x-32
  --[[
  if c.pos.x<0 then
    c.pos.x=0
  end
  if c.pos.x>64*2 then
    c.pos.x=64*2
  end
  ]]
end

function cam_draw(c)
  -- camera(c.pos.x,0)
end

function level(o)
  return {
    cam=assert(o.cam~=nil) and o.cam,
    player=assert(o.player~=nil) and o.player,
  }
end

function level_update()
  -- nothing to do here
end

function level_draw(l)
  -- map( celx, cely, sx, sy, celw, celh, [layer] )
  local center_x=0.5*64
  local x_offset=center_x-l.player.pos.x
  -- map(16, 0, -x_offset, 0, 8, 8)
  line(center_x,0,center_x,64,7)
  map(8, 0, x_offset, 0, 8, 8)
  map(0, 0, 0, 0, 8, 8)
  l.x_offset=x_offset
  --print('x_offset:'..x_offset)
end
-->8
-- utils:

function transition(o)
 -- preconditions.
 assert(o.to~=nil)

 -- clean up old state.
 -- optional.
 if o.from~=nil and o.from.die~=nil then
  o.from.die()
 end

 -- initialize new state.
 -- optional.
 if o.to.init~=nil and not o.skip_init then
  o.to.init(o.prev_state)
 end

 -- transition.
 current_state.state=o.to
 -- printh('transition to:'..current_state.state.label)
 _update60=o.to.update
 _draw=o.to.draw
end

function vec3(x,y,z)
 return {
  x=x or 0,
  y=y or 0,
  z=z or 0,
 }
end

function vec3_to_screen_space(v)
  return v.x, 64-v.y
end

button={
  left = 0,
  right = 1,
  up = 2,
  down = 3,
  z = 4,
  x = 5,
}

function lerp(a,b,t)
 return (1-t)*a + t*b
end

function damp(
 source,
 target,
 smoothing,
 custom_exp
)
 if custom_exp~=nil then
  return lerp(
   source,
   target,
   1-smoothing^custom_exp
  )
 else
  local dt=1/60
  return lerp(
   source,
   target,
   1-smoothing^dt
  )
 end
end

function vec3_lerp(v1,v2,t)
 return vec3(
  lerp(v1.x, v2.x, t),
  lerp(v1.y, v2.y, t),
  lerp(v1.z, v2.z, t)
 )
end

function vec3_damp(
 source,
 target,
 smoothing,
 custom_exp
)
 if custom_exp~=nil then
  return vec3_lerp(
   source,
   target,
   1-smoothing^custom_exp
  )
 else
  local dt=1/60
  return vec3_lerp(
   source,
   target,
   1-smoothing^dt
  )
 end
end

function vec3_add(a,b)
 return vec3(
  a.x+b.x,
  a.y+b.y,
  a.z+b.z
 )
end

function vec3_mul(v,c)
 return vec3(
  v.x*c,
  v.y*c,
  v.z*c
 )
end
__gfx__
000000006666666600000000ffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000006666666600003000ffffffff004444005555555544000000060000000066660000600000006000000066660000000000000000000000000000000000
007007006666666600033000ffffffff044000004444044444404444060060000060000000600000006000000060060000000000000000000000000000000000
000770006666666603333000ffffffff040044000444444444444440060060000066660000600000006000000060060000000000000000000000000000000000
000770006666666600033000ffffffff040444405555555544444440066660000060000000600000006000000066660000000000000000000000000000000000
007007006666666600033330ffffffff044004400000000044444400060060000066600000666000006000000000000000000000000000000000000000000000
000000006666666600033000ffffffff004444000000000044444400000000000000000000000000006666000000000000000000000000000000000000000000
000000006666666600033000ffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010101000001010100070802090b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010505010101000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
