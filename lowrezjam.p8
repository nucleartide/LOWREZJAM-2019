pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- lowrezjam
-- by @nucleartide

--[[

  todo:

  [ ] parallax

]]

-- initial state:

current_state={
  state=nil,
}

function _init()
  poke(0x5f2c,3)
  transition{to=game}
end

-- game state:

game={}

function game.init()
  game.player=player{
    -- note that vec3_to_screen_space() defines the origin:
    pos=vec3(0,0,0),
  }
  game.level=level{
  }
  game.cam=cam{
    player=game.player,
  }
end

function game.update()
  player_update(game.player)

  -- update camera after player,
  -- as camera's position depends on player's:
  cam_update(game.cam)
end

function game.draw()
  -- sky color:
  cls(12)

  -- draw entities:
  cam_draw(game.cam)
    level_draw(game.level)
    player_draw(game.player)
  camera()

  -- debug:
  cursor()
  color(6)
  print('cpu:'..stat(1))
  if(game.player.z_action_held)print('shooting')
end

-- player entity:

function player(o)
  return {
    pos=assert(o.pos~=nil) and o.pos,
    vel=vec3(),
    acc=vec3(),
    w=5,
    h=5,

    -- in pixels per second:
    speed=50,

    -- player faces right initially.
    -- this value can be 'left' or 'right':
    last_facing_dir='right',

    z_action_held=false,
  }
end

function player_update(p)
  -- grab inputs:
  local left=btn(button.left)
  local right=btn(button.right)
  local z_action=btn(button.z)

  -- update acceleration:
  if left and not right then
    p.acc.x=-p.speed
  elseif not left and right then
    p.acc.x=p.speed
  else
    p.acc.x=0
  end

  -- update last-facing direction:
  if p.acc.x<0 then
    p.last_facing_dir='left'
  elseif p.acc.x>0 then
    p.last_facing_dir='right'
  end

  -- detect shots fired:
  p.z_action_held=z_action

  -- update velocity:
  p.vel=vec3_damp(p.vel,p.acc,0.001)

  -- update position:
  p.pos=vec3_add(p.pos,vec3_mul(p.vel,1/60))
end

function player_draw(p)
  local x,y=vec3_to_screen_space(p.pos)
  rectfill(
    x,
    y-p.h,
    x+p.w-1,
    y-1,
    7)
end

-- camera entity:

function cam(o)
  return {
    player=assert(o.player) and o.player,
    pos=vec3(),
  }
end

function cam_update(c)
  -- player is always in center of screen:
  c.pos.x=c.player.pos.x-32

  -- don't move camera past left bound:
  if(c.pos.x<0)c.pos.x=0
end

function cam_draw(c)
  camera(c.pos.x,0)
end

-- level entity:

function level()
  return {
  }
end

function level_update()
  assert(false, 'level is static for now, no update needed')
end

function level_draw()
  -- map( celx, cely, sx, sy, celw, celh, [layer] )

  -- layer 2:
  map(8, 0, 0, 0, 8, 8)

  -- layer 1:
  map(0, 0, 0, 0, 8, 8)
end

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

 current_state.state=o.to
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

function vec3_to_screen_space(v)
  return v.x, 64-v.y
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
