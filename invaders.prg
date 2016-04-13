// space invaders atari 2600

PROGRAM invaders2600;

//import "dll/zx.so";


GLOBAL

invhit=0;
invisible=0;
movingbases=0;

invanim=0;
invx=-4;
invy=200;
hitwall=0;
invdir=1;
cd=0;
invcount=0;
sounds[10];
playing=0;
pscore[2];
digit[10];
level=0;
invl[5]=(0,36,36*2,36*2+18,36*3);
shieldson=1;
landed=0;
saucer=0;
invshots=3;

LOCAL

colid;
pid;

BEGIN

set_mode(640480);

load_fpg("invaders.fpg");
graph=200;
x=320;
y=240;

frame(10000);
fade(0,0,0,10);
while(fading)
frame;
end
graph=0;
set_fps(60,2);

fade(100,100,100,10);

put_screen(file,100);
define_region(1,0,48,640,351);

sounds[0]=load_wav("sounds/shoot.wav",0);
sounds[1]=load_wav("sounds/explod.wav",0);
sounds[2]=load_wav("sounds/invmov.wav",0);
sounds[3]=load_wav("sounds/death.wav",0);
sounds[4]=load_wav("sounds/saucer.wav",1);

//write_int(0,0,0,0,&fps);
//write_int(0,0,20,0,&invshots);


pscore[0]=0;
pscore[1]=0;
level=0;
landed=0;
//fx();
loop
    player(150,388);
    invx=-4;
    //invy=200;
    if(level<4)
        invy=invl[level];
    else
        invy=invl[3];
    end

    hitwall=0;
    invdir=1;
    invanim=0;
    cd=0;
    invcount=0;
    invaders();
    shieldson=1;
    if(level<2)
    shields();
    end
    showscores();
    calcscores();
    playing=0;
    invshots=2;


    WHILE(invcount>0 && landed==0)

        if(playing)
            //stop_sound(colid);
            //colid=
            sound(sounds[2],256,256);

            if(hitwall==0)
                invanim=1-invanim;
                invx+=((4+(2*invcount<24)+(2*invcount<12))*invdir);
            else
                cd=1;
                invy+=18;
            end

            frame((invcount)*100);

            if(cd==1)
                hitwall=0;
                invdir=-invdir;
                cd=0;
            end
        else
            frame;
        end


    END
    if(landed==0)
        frame(20000);
        while(saucer)
            frame;
        end

        let_me_alone();
        level++;
    else
        loop
            frame;
        end

    end

END


END


PROCESS player(x,y)
private
flash=0;

BEGIN

GRAPH=1;

FROM flash = 0 to 6;
graph=0;
frame(1000);
graph=1;
frame(1000);
END

playing=1;


WHILE(!collision(type ishoot))

IF(key(_left) && x>150)
x-=2;
END

IF(key(_right) && x<478)
x+=2;
END

if(key(_space) && !get_id(type pshoot))
pshoot(x);
END

if(key(_s) && saucer==0)
saucership();
end


FRAME;

END

sound(sounds[3],256,256);
playing=0;

FROM flash = 0 to 6;
graph=5;
frame(1000);
graph=6;
frame(1000);
END

player(150,388);


END


PROCESS pshoot(x)

BEGIN

graph=3;

y=388;
region=1;
sound(sounds[0],256,256);

WHILE(!out_region(id,1))

y-=4;

FRAME;

END

//invshots++;

END

FUNCTION invaders()

BEGIN

for(x=108;x<464;x+=64)
for(graph=0;graph<6;graph++)

invader(graph,x,80+graph*36);
END
END

END

PROCESS invader(itype,ox,oy)

PRIVATE

anim=1;
c=0;

BEGIN

//flags=4;
invcount++;
frame;

repeat
x=ox+invx;
y=oy+invy;

graph=10+itype;
if(invanim)
graph+=10;
end
if((invdir == 1 && x>530) || (invdir ==-1 && x< 118))
hitwall=1;
end
if(playing && rand(0,invcount)>invcount-1)
y+=36;

if(!collision(type invader))
ishoot(x,y-36);
end
y-=36;
end
if(y>305)
shieldson=0;
end
if(y>350 && playing)
    landed=1;
    invy+=14;
    signal(get_id(type player),s_kill);
    playing=0;
    sound(sounds[3],256,256);
end
if(invisible==1 && invhit==0 && playing)
size=0;
end

FRAME;
size=100;

UNTIL (collision(type pshoot))
signal(get_id(type pshoot),s_kill);
sound(sounds[1],256,256);
invcount--;
pscore[0]+=5*(6-itype);
FROM graph = 30 to 33;
FROM c = 1 to 5;

x=ox+invx;
y=oy+invy;
invhit=1;
FRAME;
END

END
invhit=0;

END

PROCESS ishoot(x,y)

BEGIN

graph=3;

//y=388;
region=1;
//sound(sounds[0],256,256);
if(invshots<1)
return;
end

invshots--;

WHILE(!out_region(id,1))

y+=3;

FRAME;

END

invshots++;

END

function shields()

BEGIN

FROM x = 184 TO 450 step 128;

shield(x,340);

END


END



PROCESS shield(x,y)

private

bx=0;
plotx;
ploty;
sx=0;
ex=0;


BEGIN
bx=x;

graph=new_map(32,36,16,18,0);
map_put(file,graph,2,16,18);


//graph = 2;
//flags=2;

while(shieldson)
if(movingbases)
x=bx+(cos(timer*2000)/200)*4;
end

colid=collision(type pshoot);
if(!colid)
colid=collision(type ishoot);
if(colid)
colid.y+=12;
end

end

if(colid)
//colid.x=colid.x/4;
//colid.x*=4;
colid.x+=14;
colid.y+=4;
for(ploty=0;ploty<16;ploty+=4)
sx=0-4*(rand(0,10)>9);
ex=4+4*(rand(0,10)>9);
for(plotx=sx;plotx<ex;plotx++)
map_put_pixel(file,graph,(colid.x-x)+plotx,(colid.y-y)+ploty,0);
map_put_pixel(file,graph,(colid.x-x)+plotx,(colid.y-y)+ploty+1,0);
map_put_pixel(file,graph,(colid.x-x)+plotx,(colid.y-y)+ploty+2,0);
map_put_pixel(file,graph,(colid.x-x)+plotx,(colid.y-y)+ploty+3,0);

end
end

colid.x=-50;
//signal(colid,s_kill);

end



FRAME;

END

unload_map(graph);


END

process showscores()

begin
//write_int(0,0,0,0,&pscore[0]);
FROM graph = 0 to 1;
FROM x = 0 to 3;

score(graph,x,(x*64)+40+320*graph,37+2*(x==1 || x==2));

END
END


end

process score(sid,idx,x,y)

private
sscore=0;
//digit[5];
i=0;
begin

loop
if(!saucer)
graph=digit[idx+sid*5]+50+sid*10;
else
graph=0;
end

frame;

end

end


process calcscores()
private
sscore;
oldscores[2];
i=0;
power=0;

begin

loop

for(graph=0;graph<2;graph++)
sscore=pscore[graph];
if(sscore!=oldscores[graph])
oldscores[graph]=sscore;
i=0;
//x++;
power=1000;
while(i<4)
digit[i+graph*5]=sscore/power;
sscore=sscore%power;
power=power/10;
i++;
end

end

end
graph=0;

frame;

end

end


process saucership()

private
ssound=0;

BEGIN

saucer=1;

x=640;
y=40;
graph=4;

ssound=sound(sounds[4],256,256);
define_region(1,0,28,640,371);
while(x>0)
x-=2;
frame;
end

stop_sound(ssound);
saucer=0;
define_region(1,0,48,640,351);

end


process fx()
private

map;

begin
//return;

map=new_map(640,480,320,240,0);
screen_copy(0,file,map,0,0,640,480);
//clear_screen();
graph=map;
x=320;
y=240;
flags=4;
size=95;
//angle=18000;
frame;

loop
screen_copy(0,file,map,0,0,640,480);
//clear_screen();

frame;

end

end
