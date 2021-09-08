import std.traits;
bool isvalidlerp(alias lerp)(){
	alias para=Parameters!lerp;
	static assert( is (para[0]== para[1]));
	static assert( is( para[2]==float));
	return true;
}
auto lerptype(alias lerp)(){
	alias para=Parameters!lerp;
	alias T=para[0];
	return T();
}
mixin template copypaste(){
	static assert(isvalidlerp!lerp);
	alias T=typeof(lerptype!lerp());
	struct element{
		T e; alias e this;
		int t;
	}
	element[] data=[element(T.init,-1)];
	int length;
	int count;
	alias front this;
	void opOpAssign(string s:"~")(element e){
		if(data==[element(T.init,-1)]){
			data=[];}
		length+=e.t;
		data ~= e;
	}
	void opOpAssign(string s:"~")(T e){
		this ~= element(e,defaulttime);}
	T opUnary(string s:"++")(){
		popFront;
		return front;
	}
	T lerpat(int node,int step){
		return lerp(data[node%$].e,data[(node+1)%$].e,float(step)/data[(node+1)%$].t);
	}
}


struct lerplist(alias lerp,int defaulttime=10){
	mixin copypaste!();
	T front(){
		if(data.length<=1){
			error:return data[0].e;
		}
		return lerp(data[0].e,data[1].e,float(count)/data[1].t);
	}
	void popFront(){
		if(data.length!=1){
			length--;
			if(count >= data[1].t){
				count=0;
				data=data[1..$];
			} else {
				count++;
			}
		}
	}
	bool empty(){
		return data.length<=1;}
	T opIndex(int j){
		j+=count;
		int k=1;
		while(data[k%$].t<j){
			if(k>=data.length-1){
				goto cant;
			}
			j-=data[k%$].t;
			k++;
		}
		cant:
		k--;
		return lerpat(k,j);
	}
}
struct litteral{
	int i; alias i this;
}
struct cyclelerp(alias lerp,int defaulttime=10){
	mixin copypaste!();
	int iter;
	int countiter;
	T front(){
		return lerpat(iter,countiter);
	}
	void popFront(){
		if(countiter >= data[(iter+1)%$].t){
			iter++; countiter=0;
			iter%=data.length;
		} else { countiter++;}
		
		if(length!=0){
			length--;
			count++;
		} else {
			length=count;
			count=0;
		}
	}
	bool empty(){
		return length==0;}
	T opIndex(int j){
		auto truelength=count+length;
		j+=count;
		j%=truelength;
		int k=0;
		while(data[(k+1)%$].t<j){
			if(k==data.length+1){
				goto cant;
			}
			j-=data[(k+1)%$].t;
			k++;
		}
		cant:
		return lerpat(k,j);
	}
	T opIndex(litteral j){
		return this[int(j-count)];}
}
struct cornorcut(alias lerp,int offset,int depth){
	static if(depth==1){
		lerplist!lerp payload; 
	} else {
		cornorcut!(lerp,offset*2,depth-1) payload;
	}
	alias payload this;
	auto opIndex(int i){
		return lerp(payload[i],payload[i+offset],0.5);}
	auto front(){
		return this[0];}
}