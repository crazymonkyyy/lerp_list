struct lerplist(T,alias lerp,bool cyclic=false,bool rush=false){
	static assert( ! (cyclic && rush),"that hurts to think about");
	struct elem{
		T e; alias e this;
		int t;
	}
	elem[] data=[elem(T.init,-1)];
	static if( ! cyclic){
		int length;
		int maxlength=-1;
	}
	static if( ! cyclic){
		auto first(){
			return data[0].e;
		}
		auto second(){
			return data[1].e;
		}
	} else {
		int i;
		auto first(){
			return data[i%$].e;
		}
		auto second(){
			return data[(i+1)%$].e;
		}
	}
	int count;
	void maybepop(){
		static if( ! cyclic){
			assert(data.length>1,"how did you manage to get less the one element?");
			length-=data[0].t;
			data=data[1..$];
		} else {
			if(data[0].t==-1&&data.length>1){
				data=data[1..$];
			}
			i++;
			i%=data.length;
		}
	}
	static if(rush){
		T rushfront(int j){
			assert(maxlength!=-1,"please set max length");
			float f=float(j)/data[1].t;
			//assert(f<1.001,"I think this is true");
			if(f>1.001){f=1;}
			assert(length>maxlength,"otherwise why are you rushing?");
			int i=1;
			auto o=data[0].e;
			while(f>0 && i<data.length){
				o=lerp(o,data[i],f);
				i++;
				f/=2;
				f-=.1;
			}
			return o;
		}
	}
	
	T front(){
		if(data.length<=1){
			error:return first;
		}
		if(data[0].t==-1){
			popFront();goto error;
		}
		static if(rush){ if(length>maxlength){
			return rushfront(count);
		} }
		return lerp(first,second,float(count)/data[1].t);
	}
	alias front this;
	void popFront(){
		if(data.length!=1){
			if(count >= data[1].t){
				count=0;
				maybepop;
			} else {
				count++;
			}
		}
	}
	static if( ! cyclic){
		bool empty(){
			return data.length<=1;
		}
	} else {
		enum empty=false;
	}
	void opOpAssign(string s:"~")(elem e){
		data ~= e;
		static if( ! cyclic){
			length+=e.t;
		}
	}
	
	T opIndex(int j){
		int k=0;
		j+=count;
		if(j<data[1%$].t){ undo:
			while(data[k].t<j){
				if(k==data.length-1){
					goto cant;
				}
				j-=data[k].t;
				k++;
			}
			cant:
			float f=float(j)/data[k].t;  //I should write a blog post about ugly access array mathz
			if(f>1 || f<0){f=0.5;}       //int[10] foo=[1,2,3,4,5,6,7,8,9,10];
			return lerp(                 //foreach(i;0..15){                  
				data[k>=$? $-1 : k ],     //	import basic;                    
				data[k+1>=$?$-1:k+1],     //	foo[i>=$? $-1 : i].writeln;      
				f);
		} else {//ugly as fuck
			static if(rush){
				if(length>maxlength){
					return rushfront(j);
				} else {
					goto undo;
				}
			} else{
				goto undo;
			}
		}
	}
}
