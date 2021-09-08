import raylib;
import raymath;
import basic;
import lerpdata;
enum windowx=800;
enum windowy=600;


Vector2 lerpvec2(Vector2 a, Vector2 b,float f){
		return a*(1-f)+b*f;
}
ubyte toubyte(float i){
	import std.math;
	if(i.isNaN){return 0;}
	if(i>ubyte.max){return ubyte.max;}//we are all very very impressed with your safty std -__-
	if(i<ubyte.min){return ubyte.min;}
	return i.to!ubyte;
}
Color lerpcolor(Color a, Color b,float f){
	return Color(
		toubyte(a.r*(1-f)+b.r*f),
		toubyte(a.g*(1-f)+b.g*f),
		toubyte(a.b*(1-f)+b.b*f),
		toubyte(a.a*(1-f)+b.a*f));
}
void main(){
	InitWindow(windowx,windowy, "Hello, Raylib-D!");
	SetWindowPosition(2000,0);
	SetTargetFPS(60);
	
	//rainbow dot data
	cornorcut!(lerpvec2,5,2) dot;
	alias path=dot.element;
	cyclelerp!(lerpcolor) rainbow;
	rainbow~=Colors.RED;
	rainbow~=Colors.ORANGE;
	rainbow~=Colors.YELLOW;
	rainbow~=Colors.GREEN;
	rainbow~=Colors.BLUE;
	rainbow~=Colors.PURPLE;
	rainbow~=Colors.VIOLET;
	
	//taffic light data
	cyclelerp!lerpvec2 lightpos;
	alias poselem=lightpos.element;
	cyclelerp!lerpcolor signels;
	alias sigelem=signels.element;
	enum greentime=10*60;
	enum yellowtime=3*60;
	enum redtime=greentime+yellowtime+1*60;
	enum timingoffset=redtime;
	enum spaceing=50;
	enum zippy=zip(
			[greentime,yellowtime,redtime],
			[Colors.GREEN,Colors.YELLOW,Colors.RED],
			[Vector2(0,2*spaceing),Vector2(0,spaceing),Vector2(0,0)]);
	static foreach(time,Color color,pos;zippy){
		//writeln(time,",",color,",",ypos);
		lightpos~=poselem(pos,0);
		lightpos~=poselem(pos,time);
		signels~=sigelem(color,0);
		signels~=sigelem(color,time);
	}
	enum light1=Vector2(20,30);
	enum light2=Vector2(windowx-20,30);
	
	//space battle data
	Texture2D ship1=LoadTexture("ship1.png".toStringz);
	Texture2D ship2=LoadTexture("ship2.png".toStringz);
	enum shipoffset=Vector2(23,21);
	cornorcut!(lerpvec2,7,2) ship1path;
	cornorcut!(lerpvec2,7,2) ship2path;
	lerplist!lerpvec2 bulletpath;
	alias shippath=ship1path.element;
	alias bullettarget=bulletpath.element;
	auto heading(T)(T range){
		import std.math;
		auto h=Vector2Angle(range[0],range[5]);
		if(h.isNaN){return 0;}
		return (h+270)%360;
	}
	auto randomvec(){
		return Vector2(uniform(0,windowx),uniform(0,windowy));}
	ship1path~=randomvec();
	ship2path~=randomvec();
	
	
	while (!WindowShouldClose()){
		BeginDrawing();
			ClearBackground(Colors.BLACK);
			
			//draw rainbow dot
			if(Vector2Distance(dot.data[$-1],GetMousePosition) > 10){//add mouse to path if far enough away
				dot~=path(GetMousePosition,
						Vector2Distance(dot.data[$-1],GetMousePosition).to!int/10);
			}
			static foreach(i;0..10){
				DrawCircleV(dot[i*2],i*2,rainbow[i*4]);
			}
			dot++;rainbow++;
			
			//draw taffic light
			foreach(time,Color color,pos;zippy){
				DrawCircleV(pos+light1,20,lerpcolor(color,Colors.BLACK,.7));
				DrawCircleV(pos+light2,20,lerpcolor(color,Colors.BLACK,.7));
			}
			DrawCircleV(lightpos+light1,20,signels);
			DrawCircleV(lightpos[timingoffset]+light2,20,signels[timingoffset]);
			lightpos++; signels++;
			
			//draw space battle
			void drawship(T)(Texture2D s,T path){
				DrawTextureEx(s,path-Vector2Rotate(shipoffset,heading(path)),heading(path),.5,Colors.WHITE);
			}
			drawship(ship1,ship1path);
			drawship(ship2,ship2path);
			//DrawCircleV(ship1path,3,Colors.RED);
			//DrawCircleV(ship2path,3,Colors.RED);
			DrawLineV(bulletpath,bulletpath[3],Colors.RED);
			if(ship1path.length<100){
				auto r=randomvec();
				auto d=Vector2Distance(ship1path.data[$-1],r);
				ship1path~=shippath(r,(d/3).to!int);
			}
			if(ship2path.length<100){
				auto r=randomvec();
				auto d=Vector2Distance(ship2path.data[$-1],r);
				ship2path~=shippath(r,(d/5).to!int);
			}
			if(bulletpath.empty){
				int i;
				enum bulletmaxspeed=5;
				loop: i++;
				if(
					Vector2Distance(ship1path[0],ship2path[i])
					> i*bulletmaxspeed
					&& i<99){
						goto loop;}
				bulletpath~=bullettarget(ship1path[0],0);
				bulletpath~=bullettarget(ship2path[i-1],i+1);
				bulletpath~=bullettarget(ship2path[i],3);
			}
			ship1path++;ship2path++;bulletpath++;
		EndDrawing();
	}
	CloseWindow();
}